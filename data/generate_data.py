import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

random.seed(42)
np.random.seed(42)

# ── 1. INFLUENCEURS ────────────────────────────────────────────────
categories = ['Beauty', 'Fashion', 'Fitness', 'Food', 'Travel', 'Tech', 'Gaming', 'Lifestyle']
platforms  = ['Instagram', 'TikTok', 'YouTube', 'Twitter']
countries  = ['France', 'USA', 'UK', 'Germany', 'Spain', 'Italy', 'Brazil', 'Japan']

names = [
    "Lea Martin","Hugo Bernard","Camille Dubois","Lucas Moreau","Emma Petit",
    "Nathan Leroy","Chloe Simon","Theo Laurent","Manon Girard","Antoine Dupont",
    "Sofia Ramos","Marco Ferrari","Amelia Jones","Jake Wilson","Yuki Tanaka",
    "Priya Sharma","Carlos Silva","Elena Muller","Fatima Hassan","Tom Andrews",
    "Julie Blanc","Maxime Renard","Laura Fontaine","Pierre Morel","Ines Garnier",
    "Baptiste Chevalier","Alice Mercier","Nicolas Faure","Marie Lefebvre","Paul Bonnet",
    "Aya Diallo","Chen Wei","Sara Kowalski","Remi Bourgeois","Lucie Aubert",
    "Kevin Nkosi","Cecile Vidal","Arnaud Perrin","Jade Royer","Mathieu Caron",
    "Vanessa Lopez","Diego Herrera","Noemie Fabre","Florian Schmitt","Amandine Roy",
    "Tristan Marchand","Pauline Guerin","Julien Dufour","Elisa Bernard","Romain Tessier"
]

influencers = []
for i, name in enumerate(names):
    followers = random.randint(10_000, 5_000_000)
    eng_rate  = round(random.uniform(0.5, 12.0), 2)
    influencers.append({
        'influencer_id': i+1,
        'name': name,
        'username': name.lower().replace(' ', '_'),
        'platform': random.choice(platforms),
        'category': random.choice(categories),
        'country': random.choice(countries),
        'followers': followers,
        'avg_likes': int(followers * eng_rate / 100),
        'avg_comments': int(followers * eng_rate / 100 * 0.08),
        'engagement_rate': eng_rate,
        'price_per_post': int(followers * random.uniform(0.005, 0.02)),
        'verified': random.choice([0, 0, 1]),
        'created_at': (datetime(2018,1,1) + timedelta(days=random.randint(0,1800))).strftime('%Y-%m-%d')
    })

df_influencers = pd.DataFrame(influencers)

# ── 2. MARQUES ─────────────────────────────────────────────────────
brands_data = [
    (1,'LOreal Paris','Beauty','France','loreal.com'),
    (2,'Nike','Fitness','USA','nike.com'),
    (3,'Zara','Fashion','Spain','zara.com'),
    (4,'GoPro','Tech','USA','gopro.com'),
    (5,'Airbnb','Travel','USA','airbnb.com'),
    (6,'Sephora','Beauty','France','sephora.com'),
    (7,'Adidas','Fitness','Germany','adidas.com'),
    (8,'H&M','Fashion','Sweden','hm.com'),
    (9,'Apple','Tech','USA','apple.com'),
    (10,'Deliveroo','Food','UK','deliveroo.com'),
    (11,'HelloFresh','Food','Germany','hellofresh.com'),
    (12,'Booking.com','Travel','Netherlands','booking.com'),
    (13,'PlayStation','Gaming','Japan','playstation.com'),
    (14,'Maybelline','Beauty','USA','maybelline.com'),
    (15,'Decathlon','Fitness','France','decathlon.com'),
]
df_brands = pd.DataFrame(brands_data, columns=['brand_id','name','industry','country','website'])

# ── 3. CAMPAGNES ───────────────────────────────────────────────────
campaign_types = ['Sponsored Post', 'Story', 'Reel', 'Video Review', 'Giveaway', 'Ambassador']
campaigns = []
cid = 1
for brand in brands_data:
    n = random.randint(3, 6)
    for _ in range(n):
        start = datetime(2023,1,1) + timedelta(days=random.randint(0,500))
        end   = start + timedelta(days=random.randint(15, 90))
        budget = random.randint(5_000, 150_000)
        campaigns.append({
            'campaign_id': cid,
            'brand_id': brand[0],
            'name': f"Camp_{brand[1].replace(' ','_')}_{cid}",
            'campaign_type': random.choice(campaign_types),
            'start_date': start.strftime('%Y-%m-%d'),
            'end_date': end.strftime('%Y-%m-%d'),
            'budget': budget,
            'target_platform': random.choice(platforms),
            'target_category': random.choice(categories),
            'status': random.choice(['Active','Completed','Completed','Completed','Planned']),
        })
        cid += 1

df_campaigns = pd.DataFrame(campaigns)

# ── 4. PUBLICATIONS (many-to-many campagnes <-> influenceurs) ──────
publications = []
pid = 1
for _, camp in df_campaigns.iterrows():
    compatible = df_influencers[
        (df_influencers['platform'] == camp['target_platform']) |
        (df_influencers['category'] == camp['target_category'])
    ]
    if len(compatible) == 0:
        compatible = df_influencers
    selected = compatible.sample(min(random.randint(1,4), len(compatible)))
    for _, inf in selected.iterrows():
        post_date = datetime.strptime(camp['start_date'],'%Y-%m-%d') + timedelta(days=random.randint(0,20))
        reach = int(inf['followers'] * random.uniform(0.3, 0.9))
        likes = int(reach * inf['engagement_rate'] / 100)
        publications.append({
            'publication_id': pid,
            'campaign_id': int(camp['campaign_id']),
            'influencer_id': int(inf['influencer_id']),
            'post_date': post_date.strftime('%Y-%m-%d'),
            'content_type': random.choice(['Photo','Video','Reel','Story','Carousel']),
            'reach': reach,
            'impressions': int(reach * random.uniform(1.1, 2.5)),
            'likes': likes,
            'comments': int(likes * random.uniform(0.05, 0.15)),
            'shares': int(likes * random.uniform(0.01, 0.05)),
            'revenue_generated': random.randint(500, 50_000),
            'cost_paid': int(inf['price_per_post'] * random.uniform(0.8, 1.2)),
            'approved': random.choice([1,1,1,0]),
        })
        pid += 1

df_publications = pd.DataFrame(publications)

df_influencers.to_csv('/Users/wafaabenkorreche/influence_marketing/data/influencers.csv', index=False)
df_brands.to_csv('/Users/wafaabenkorreche/influence_marketing/data/brands.csv', index=False)
df_campaigns.to_csv('/Users/wafaabenkorreche/influence_marketing/data/campaigns.csv', index=False)
df_publications.to_csv('/Users/wafaabenkorreche/influence_marketing/data/publications.csv', index=False)

print(f"influencers  : {len(df_influencers)} lignes")
print(f"brands       : {len(df_brands)} lignes")
print(f"campaigns    : {len(df_campaigns)} lignes")
print(f"publications : {len(df_publications)} lignes")
