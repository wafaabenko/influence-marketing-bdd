# 📊 Influence Marketing — Analyse ROI des Campagnes

> **MSc2 Manager Data Marketing · Algo & Bases de Données · 2026**

---

## 🎯 Problématique métier

**Quels influenceurs et campagnes génèrent le meilleur ROI pour une marque ?**

Dans un marché de l'influence marketing dépassant les 20 Md€ mondiaux, les marques peinent à objectiver leur retour sur investissement. Ce projet construit un pipeline data complet — de la modélisation SQL à un dashboard interactif — pour répondre à cette question avec des données mesurables.

---

## 🗂️ Structure du projet

```
influence_marketing/
├── data/
│   ├── generate_data.py       # Génération des données simulées
│   ├── influencers.csv
│   ├── brands.csv
│   ├── campaigns.csv
│   ├── publications.csv
│   └── influencer_scores.csv  # Généré par le pipeline
├── sql/
│   └── influence_marketing.sql  # BDD complète (CREATE + INSERT + requêtes)
├── python/
│   └── pipeline.py            # Pipeline : connexion → API → scoring → export
├── dashboard/
│   └── app.py                 # Dashboard Plotly Dash interactif
├── .env.example               # Template variables d'environnement
├── .gitignore
├── requirements.txt
└── README.md
```

---

## 🗄️ Schéma de la base de données

> Schéma disponible sur [dbdiagram.io](https://dbdiagram.io) — voir capture ci-dessous.

```
brands ──< campaigns ──< publications >── influencers
```

| Table          | Lignes | Description                              |
|----------------|--------|------------------------------------------|
| `brands`       | 15     | Marques partenaires (L'Oréal, Nike…)     |
| `influencers`  | 50     | Créateurs de contenu multi-plateformes   |
| `campaigns`    | 66     | Campagnes marketing par marque           |
| `publications` | 176    | **Table de jonction** campagne × influenceur |

**Relations clés :**
- `publications` est la table **many-to-many** entre `campaigns` et `influencers`
- Deux `FOREIGN KEY` : `publications.campaign_id` → `campaigns` et `publications.influencer_id` → `influencers`
- Contraintes `NOT NULL` et `UNIQUE` sur les champs critiques (username, brand name…)

### Schéma dbdiagram.io

```
Table brands {
  brand_id    int [pk, increment]
  name        varchar(100) [not null, unique]
  industry    varchar(50)  [not null]
  country     varchar(50)  [not null]
  website     varchar(100)
}

Table influencers {
  influencer_id   int [pk, increment]
  name            varchar(100) [not null]
  username        varchar(100) [not null, unique]
  platform        enum [not null]
  category        varchar(50)  [not null]
  followers       int [not null]
  engagement_rate decimal(5,2) [not null]
  price_per_post  int [not null]
  verified        tinyint(1)
}

Table campaigns {
  campaign_id   int [pk, increment]
  brand_id      int [ref: > brands.brand_id]
  name          varchar(150) [not null]
  campaign_type varchar(50)
  budget        decimal(10,2) [not null]
  status        enum
}

Table publications {
  publication_id  int [pk, increment]
  campaign_id     int [ref: > campaigns.campaign_id]
  influencer_id   int [ref: > influencers.influencer_id]
  content_type    enum [not null]
  reach           int
  revenue_generated decimal(10,2)
  cost_paid       decimal(10,2) [not null]
  approved        tinyint(1)
}
```

---

## 🚀 Installation & lancement

### Prérequis
- Python 3.10+
- MySQL 8.0+ (optionnel — fallback CSV disponible)

### 1. Cloner le repo
```bash
git clone https://github.com/[ton-username]/influence-marketing-bdd
cd influence-marketing-bdd
```

### 2. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 3. Configurer MySQL (optionnel)
```bash
cp .env.example .env
# Éditer .env avec vos identifiants MySQL
```

### 4. Créer la base de données
```bash
mysql -u root -p < sql/influence_marketing.sql
```

### 5. Générer les données (si pas de MySQL)
```bash
python data/generate_data.py
```

### 6. Lancer le pipeline Python
```bash
python python/pipeline.py
```

### 7. Lancer le dashboard
```bash
python dashboard/app.py
# → http://localhost:8050
```

---

## 🧮 Algorithme : Influence Score

Score composite sur 100 points pour chaque influenceur :

| Composante          | Poids | Calcul                                     |
|---------------------|-------|--------------------------------------------|
| Engagement score    | 35 %  | `engagement_rate / max * 35`               |
| Reach score         | 25 %  | `total_reach / max * 25`                   |
| ROI score           | 20 %  | `(revenue/cost) / p95 * 20`                |
| Consistency score   | 10 %  | `(1 - coeff_variation) * 10`               |
| Verified bonus      | 10 %  | `+10 si compte certifié`                   |

**Segments :** Top Performer (≥70) · Rising Star (≥45) · Niche Expert (≥20) · Emerging (<20)

---

## 📈 Dashboard — Fonctionnalités

- **3 KPIs** : engagement moyen, ROI, portée totale
- **Bar chart** : ROI par marque
- **Scatter plot** : followers vs engagement coloré par segment
- **Donut** : répartition des segments d'influenceurs
- **Top 10** : classement par Influence Score
- **Filtres interactifs** : plateforme, marque, catégorie, followers minimum

---

## 🔑 Requête SQL mise en avant

ROI par campagne sur 3 tables :

```sql
SELECT b.name AS brand, c.name AS campaign,
       SUM(p.cost_paid)         AS total_cost,
       SUM(p.revenue_generated) AS total_revenue,
       ROUND(SUM(p.revenue_generated) / NULLIF(SUM(p.cost_paid),0), 2) AS roi_ratio
FROM campaigns c
JOIN brands b       ON c.brand_id    = b.brand_id
JOIN publications p ON c.campaign_id = p.campaign_id
WHERE p.approved = 1
GROUP BY c.campaign_id, b.name, c.name
ORDER BY roi_ratio DESC
LIMIT 15;
```

---

## 👤 Auteur

[Ton Prénom NOM] — MSc2 Manager Data Marketing, INSEEC 2026
