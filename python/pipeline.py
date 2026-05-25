"""
Pipeline Python - Influence Marketing
======================================
Connexion MySQL → Enrichissement API → Scoring → Écriture résultats
"""

import os
import pandas as pd
import numpy as np
import requests
import json
from datetime import datetime
from dotenv import load_dotenv

# Chargement des variables d'environnement (mot de passe MySQL)
load_dotenv()

# ──────────────────────────────────────────────────────────────────
# CONFIG
# ──────────────────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     os.getenv("DB_HOST", "localhost"),
    "user":     os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "influence_marketing"),
}


# ──────────────────────────────────────────────────────────────────
# 1. CONNEXION & EXTRACTION MYSQL
# ──────────────────────────────────────────────────────────────────

def load_data_from_db() -> dict[str, pd.DataFrame]:
    """
    Charge les 4 tables principales depuis MySQL.
    Retourne un dictionnaire de DataFrames.
    """
    try:
        import mysql.connector
        conn = mysql.connector.connect(**DB_CONFIG)
        tables = {}
        for table in ["influencers", "brands", "campaigns", "publications"]:
            tables[table] = pd.read_sql(f"SELECT * FROM {table}", conn)
            print(f"  ✓ {table}: {len(tables[table])} lignes chargées")
        conn.close()
        return tables
    except Exception as e:
        print(f"  ⚠ MySQL non disponible ({e}), chargement depuis CSV...")
        return load_data_from_csv()


def load_data_from_csv() -> dict[str, pd.DataFrame]:
    """Fallback : chargement depuis les CSV locaux."""
    base = os.path.join(os.path.dirname(__file__), "..", "data")
    tables = {}
    for table in ["influencers", "brands", "campaigns", "publications"]:
        path = os.path.join(base, f"{table}.csv")
        tables[table] = pd.read_csv(path)
        print(f"  ✓ {table}: {len(tables[table])} lignes (CSV)")
    return tables


# ──────────────────────────────────────────────────────────────────
# 2. ENRICHISSEMENT VIA API EXTERNE
# ──────────────────────────────────────────────────────────────────

def enrich_with_exchange_rates(df_influencers: pd.DataFrame) -> pd.DataFrame:
    """
    Enrichit les influenceurs avec le taux de conversion EUR de leur pays
    via l'API publique open.er-api.com (gratuite, sans clé).
    Ajoute la colonne price_per_post_eur.
    """
    # Mapping pays → devise ISO
    country_to_currency = {
        "France": "EUR", "Germany": "EUR", "Spain": "EUR", "Italy": "EUR",
        "USA": "USD", "UK": "GBP", "Brazil": "BRL", "Japan": "JPY",
        "Netherlands": "EUR", "Sweden": "SEK",
    }

    print("\n[API] Appel open.er-api.com pour les taux de change...")
    try:
        url = "https://open.er-api.com/v6/latest/EUR"
        resp = requests.get(url, timeout=8)
        resp.raise_for_status()
        data = resp.json()
        rates = data.get("rates", {})
        print(f"  ✓ Taux reçus pour {len(rates)} devises (base EUR)")

        def convert_to_eur(row):
            currency = country_to_currency.get(row["country"], "EUR")
            rate = rates.get(currency, 1.0)
            return round(row["price_per_post"] / rate, 2)

        df_influencers = df_influencers.copy()
        df_influencers["currency"] = df_influencers["country"].map(
            country_to_currency).fillna("EUR")
        df_influencers["price_per_post_eur"] = df_influencers.apply(
            convert_to_eur, axis=1)
        df_influencers["exchange_rate_fetched_at"] = datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S")

    except requests.exceptions.RequestException as e:
        print(f"  ⚠ API indisponible ({e}), fallback taux fixe")
        df_influencers = df_influencers.copy()
        df_influencers["currency"] = "EUR"
        df_influencers["price_per_post_eur"] = df_influencers["price_per_post"]
        df_influencers["exchange_rate_fetched_at"] = datetime.now().strftime(
            "%Y-%m-%d %H:%M:%S")

    return df_influencers


# ──────────────────────────────────────────────────────────────────
# 3. ALGORITHME DE SCORING INFLUENCEURS
# ──────────────────────────────────────────────────────────────────

def compute_influence_score(df_inf: pd.DataFrame,
                             df_pub: pd.DataFrame) -> pd.DataFrame:
    """
    Calcule un score composite pour chaque influenceur sur 100 pts :

    Score = 0.35 * engagement_score
           + 0.25 * reach_score
           + 0.20 * roi_score
           + 0.10 * consistency_score
           + 0.10 * verified_bonus

    Paramètres
    ----------
    df_inf : DataFrame des influenceurs
    df_pub : DataFrame des publications approuvées

    Retourne le DataFrame enrichi avec score + segment.
    """
    df = df_inf.copy()
    pubs = df_pub[df_pub["approved"] == 1].copy()

    # Agrégats par influenceur
    agg = pubs.groupby("influencer_id").agg(
        total_reach=("reach", "sum"),
        total_revenue=("revenue_generated", "sum"),
        total_cost=("cost_paid", "sum"),
        nb_posts=("publication_id", "count"),
        pub_avg_likes=("likes", "mean"),
        pub_std_likes=("likes", "std"),
    ).reset_index()

    df = df.merge(agg, on="influencer_id", how="left")
    fill_cols = ["total_reach","total_revenue","total_cost","nb_posts","pub_avg_likes","pub_std_likes"]
    df[fill_cols] = df[fill_cols].fillna(0)

    # ── Score d'engagement (35 pts) ──
    eng_max = df["engagement_rate"].max()
    df["engagement_score"] = (df["engagement_rate"] / eng_max) * 35

    # ── Score de portée (25 pts) ──
    reach_max = df["total_reach"].clip(lower=1).max()
    df["reach_score"] = (df["total_reach"].clip(lower=0) / reach_max) * 25

    # ── Score ROI (20 pts) ──
    df["roi_ratio"] = df["total_revenue"] / df["total_cost"].clip(lower=1)
    roi_max = df["roi_ratio"].clip(lower=0).quantile(0.95)  # éviter outliers
    df["roi_score"] = (df["roi_ratio"].clip(upper=roi_max) / roi_max) * 20

    # ── Score de cohérence (10 pts) — faible écart-type = régularité ──
    df["cv"] = df["pub_std_likes"] / df["pub_avg_likes"].clip(lower=1)  # coefficient variation
    cv_max = df["cv"].replace([np.inf, -np.inf], np.nan).fillna(0).max()
    df["consistency_score"] = (1 - df["cv"].clip(upper=cv_max) / (cv_max + 1e-9)) * 10

    # ── Bonus vérifié (10 pts) ──
    df["verified_bonus"] = df["verified"] * 10

    # ── Score total ──
    df["influence_score"] = (
        df["engagement_score"] + df["reach_score"] +
        df["roi_score"] + df["consistency_score"] + df["verified_bonus"]
    ).round(2)

    # ── Segmentation ──
    def segment(score):
        if score >= 70:
            return "Top Performer"
        elif score >= 45:
            return "Rising Star"
        elif score >= 20:
            return "Niche Expert"
        else:
            return "Emerging"

    df["segment"] = df["influence_score"].apply(segment)
    df["scored_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    return df


# ──────────────────────────────────────────────────────────────────
# 4. ÉCRITURE DES RÉSULTATS DANS MYSQL
# ──────────────────────────────────────────────────────────────────

def write_scores_to_db(df_scored: pd.DataFrame):
    """
    Crée (si besoin) et remplit la table influencer_scores dans MySQL.
    """
    cols = [
        "influencer_id", "influence_score", "engagement_score", "reach_score",
        "roi_score", "consistency_score", "verified_bonus",
        "segment", "total_reach", "total_revenue", "total_cost",
        "roi_ratio", "nb_posts", "price_per_post_eur", "currency", "scored_at"
    ]
    # Garder uniquement les colonnes disponibles
    available = [c for c in cols if c in df_scored.columns]
    df_out = df_scored[available].copy()

    try:
        import mysql.connector
        conn = mysql.connector.connect(**DB_CONFIG)
        cur = conn.cursor()

        cur.execute("""
            CREATE TABLE IF NOT EXISTS influencer_scores (
                score_id         INT PRIMARY KEY AUTO_INCREMENT,
                influencer_id    INT NOT NULL,
                influence_score  DECIMAL(6,2),
                engagement_score DECIMAL(6,2),
                reach_score      DECIMAL(6,2),
                roi_score        DECIMAL(6,2),
                consistency_score DECIMAL(6,2),
                verified_bonus   DECIMAL(6,2),
                segment          VARCHAR(50),
                total_reach      BIGINT,
                total_revenue    DECIMAL(12,2),
                total_cost       DECIMAL(12,2),
                roi_ratio        DECIMAL(8,4),
                nb_posts         INT,
                price_per_post_eur DECIMAL(10,2),
                currency         VARCHAR(10),
                scored_at        DATETIME,
                FOREIGN KEY (influencer_id) REFERENCES influencers(influencer_id)
            )
        """)
        cur.execute("DELETE FROM influencer_scores")  # refresh à chaque run

        for _, row in df_out.iterrows():
            placeholders = ", ".join(["%s"] * len(available))
            col_names    = ", ".join(available)
            cur.execute(
                f"INSERT INTO influencer_scores ({col_names}) VALUES ({placeholders})",
                tuple(row[c] for c in available)
            )

        conn.commit()
        print(f"  ✓ {len(df_out)} scores écrits dans influencer_scores (MySQL)")
        conn.close()

    except Exception as e:
        print(f"  ⚠ Écriture MySQL échouée ({e}), sauvegarde CSV...")
        df_out.to_csv(
            os.path.join(os.path.dirname(__file__), "..", "data", "influencer_scores.csv"),
            index=False
        )
        print("  ✓ Scores sauvegardés dans data/influencer_scores.csv")


# ──────────────────────────────────────────────────────────────────
# 5. MAIN PIPELINE
# ──────────────────────────────────────────────────────────────────

def run_pipeline():
    print("=" * 55)
    print("  PIPELINE INFLUENCE MARKETING")
    print("=" * 55)

    # Étape 1 : chargement
    print("\n[1] Chargement des données...")
    tables = load_data_from_db()

    # Étape 2 : enrichissement API
    print("\n[2] Enrichissement via API taux de change...")
    df_enriched = enrich_with_exchange_rates(tables["influencers"])

    # Étape 3 : scoring
    print("\n[3] Calcul de l'Influence Score...")
    df_scored = compute_influence_score(df_enriched, tables["publications"])

    # Résumé scoring
    print(f"\n  Répartition des segments :")
    seg_counts = df_scored["segment"].value_counts()
    for seg, cnt in seg_counts.items():
        print(f"    {seg:20s} : {cnt} influenceurs")

    top3 = df_scored.nlargest(3, "influence_score")[["name","platform","influence_score","segment"]]
    print(f"\n  Top 3 influenceurs :")
    print(top3.to_string(index=False))

    # Étape 4 : écriture
    print("\n[4] Écriture des résultats...")
    write_scores_to_db(df_scored)

    print("\n✅ Pipeline terminé avec succès.")
    return df_scored


if __name__ == "__main__":
    df_result = run_pipeline()
