-- =============================================================
--  PROJET FINAL - Algo & BDD  |  MSc2 Manager Data Marketing
--  Sujet : Analyse ROI des campagnes d'Influence Marketing
--  Auteur : [Ton nom]  |  2026
-- =============================================================

DROP DATABASE IF EXISTS influence_marketing;
CREATE DATABASE influence_marketing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE influence_marketing;

-- =============================================================
-- PARTIE 1 : CRÉATION DES TABLES
-- =============================================================

CREATE TABLE brands (
    brand_id    INT          PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,
    industry    VARCHAR(50)  NOT NULL,
    country     VARCHAR(50)  NOT NULL,
    website     VARCHAR(100),
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE influencers (
    influencer_id   INT          PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(100) NOT NULL,
    username        VARCHAR(100) NOT NULL UNIQUE,
    platform        ENUM('Instagram','TikTok','YouTube','Twitter') NOT NULL,
    category        VARCHAR(50)  NOT NULL,
    country         VARCHAR(50)  NOT NULL,
    followers       INT          NOT NULL CHECK (followers > 0),
    avg_likes       INT          DEFAULT 0,
    avg_comments    INT          DEFAULT 0,
    engagement_rate DECIMAL(5,2) NOT NULL,
    price_per_post  INT          NOT NULL,
    verified        TINYINT(1)   DEFAULT 0,
    created_at      DATE
);

CREATE TABLE campaigns (
    campaign_id     INT          PRIMARY KEY AUTO_INCREMENT,
    brand_id        INT          NOT NULL,
    name            VARCHAR(150) NOT NULL,
    campaign_type   VARCHAR(50)  NOT NULL,
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    budget          DECIMAL(10,2) NOT NULL,
    target_platform VARCHAR(50),
    target_category VARCHAR(50),
    status          ENUM('Planned','Active','Completed') DEFAULT 'Planned',
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE CASCADE
);

-- Table de jonction = relation MANY-TO-MANY entre campagnes et influenceurs
CREATE TABLE publications (
    publication_id  INT  PRIMARY KEY AUTO_INCREMENT,
    campaign_id     INT  NOT NULL,
    influencer_id   INT  NOT NULL,
    post_date       DATE NOT NULL,
    content_type    ENUM('Photo','Video','Reel','Story','Carousel') NOT NULL,
    reach           INT  DEFAULT 0,
    impressions     INT  DEFAULT 0,
    likes           INT  DEFAULT 0,
    comments        INT  DEFAULT 0,
    shares          INT  DEFAULT 0,
    revenue_generated DECIMAL(10,2) DEFAULT 0,
    cost_paid       DECIMAL(10,2)   NOT NULL,
    approved        TINYINT(1)      DEFAULT 1,
    FOREIGN KEY (campaign_id)   REFERENCES campaigns(campaign_id)   ON DELETE CASCADE,
    FOREIGN KEY (influencer_id) REFERENCES influencers(influencer_id) ON DELETE CASCADE,
    UNIQUE KEY uq_pub (campaign_id, influencer_id, post_date)
);

-- =============================================================
-- PARTIE 2 : INSERTION DES DONNÉES
-- =============================================================

-- Marques
INSERT INTO brands (brand_id, name, industry, country, website) VALUES
  (1, 'LOreal Paris', 'Beauty', 'France', 'loreal.com'),
  (2, 'Nike', 'Fitness', 'USA', 'nike.com'),
  (3, 'Zara', 'Fashion', 'Spain', 'zara.com'),
  (4, 'GoPro', 'Tech', 'USA', 'gopro.com'),
  (5, 'Airbnb', 'Travel', 'USA', 'airbnb.com'),
  (6, 'Sephora', 'Beauty', 'France', 'sephora.com'),
  (7, 'Adidas', 'Fitness', 'Germany', 'adidas.com'),
  (8, 'H&M', 'Fashion', 'Sweden', 'hm.com'),
  (9, 'Apple', 'Tech', 'USA', 'apple.com'),
  (10, 'Deliveroo', 'Food', 'UK', 'deliveroo.com'),
  (11, 'HelloFresh', 'Food', 'Germany', 'hellofresh.com'),
  (12, 'Booking.com', 'Travel', 'Netherlands', 'booking.com'),
  (13, 'PlayStation', 'Gaming', 'Japan', 'playstation.com'),
  (14, 'Maybelline', 'Beauty', 'USA', 'maybelline.com'),
  (15, 'Decathlon', 'Fitness', 'France', 'decathlon.com');

-- Influenceurs
INSERT INTO influencers (influencer_id,name,username,platform,category,country,followers,avg_likes,avg_comments,engagement_rate,price_per_post,verified,created_at) VALUES
  (1,'Lea Martin','lea_martin','YouTube','Food','Germany',943912,7456,596,0.79,6695,0,'2021-10-17'),
  (2,'Hugo Bernard','hugo_bernard','Twitter','Beauty','France',4584866,68772,5501,1.5,29368,0,'2020-10-31'),
  (3,'Camille Dubois','camille_dubois','Twitter','Food','Japan',232599,16165,1293,6.95,3218,0,'2022-04-04'),
  (4,'Lucas Moreau','lucas_moreau','YouTube','Travel','UK',1349319,115096,9207,8.53,11104,0,'2018-07-29'),
  (5,'Emma Petit','emma_petit','YouTube','Tech','Spain',788008,38375,3070,4.87,13480,1,'2020-07-29'),
  (6,'Nathan Leroy','nathan_leroy','Twitter','Fashion','Spain',4508207,87459,6996,1.94,78627,1,'2022-10-31'),
  (7,'Chloe Simon','chloe_simon','Instagram','Beauty','Germany',3043614,217314,17385,7.14,50511,0,'2022-10-18'),
  (8,'Theo Laurent','theo_laurent','Twitter','Travel','Japan',1962791,205307,16424,10.46,28529,0,'2018-11-30'),
  (9,'Manon Girard','manon_girard','YouTube','Fashion','UK',3115303,142992,11439,4.59,40536,0,'2018-12-01'),
  (10,'Antoine Dupont','antoine_dupont','TikTok','Tech','France',3887719,188943,15115,4.86,32795,0,'2022-07-07'),
  (11,'Sofia Ramos','sofia_ramos','Instagram','Food','Italy',2656211,135732,10858,5.11,21752,0,'2020-03-21'),
  (12,'Marco Ferrari','marco_ferrari','TikTok','Food','Spain',3859128,82585,6606,2.14,62537,0,'2021-04-10'),
  (13,'Amelia Jones','amelia_jones','TikTok','Lifestyle','USA',3360414,156595,12527,4.66,54898,0,'2018-11-10'),
  (14,'Jake Wilson','jake_wilson','Twitter','Fashion','Brazil',1352026,129929,10394,9.61,14499,0,'2020-12-19'),
  (15,'Yuki Tanaka','yuki_tanaka','Instagram','Fashion','Spain',2119014,247288,19783,11.67,35025,0,'2018-08-17'),
  (16,'Priya Sharma','priya_sharma','Twitter','Beauty','Spain',2472057,135963,10877,5.5,48398,0,'2020-11-05'),
  (17,'Carlos Silva','carlos_silva','YouTube','Food','UK',902638,94867,7589,10.51,9575,0,'2021-01-09'),
  (18,'Elena Muller','elena_muller','YouTube','Lifestyle','France',4458929,493157,39452,11.06,29776,0,'2022-12-05'),
  (19,'Fatima Hassan','fatima_hassan','TikTok','Fashion','USA',2589615,84162,6732,3.25,41378,0,'2022-04-07'),
  (20,'Tom Andrews','tom_andrews','TikTok','Lifestyle','UK',4478663,416963,33357,9.31,40199,1,'2020-05-16'),
  (21,'Julie Blanc','julie_blanc','TikTok','Travel','Brazil',1786692,199752,15980,11.18,35603,1,'2020-02-04'),
  (22,'Maxime Renard','maxime_renard','Twitter','Fashion','Germany',3685049,399827,31986,10.85,30845,0,'2018-02-13'),
  (23,'Laura Fontaine','laura_fontaine','TikTok','Beauty','USA',4945091,339727,27178,6.87,77230,0,'2019-04-14'),
  (24,'Pierre Morel','pierre_morel','YouTube','Fashion','Germany',575394,62775,5022,10.91,5280,0,'2019-03-15'),
  (25,'Ines Garnier','ines_garnier','Twitter','Food','Japan',4533422,91575,7326,2.02,77577,0,'2018-07-13'),
  (26,'Baptiste Chevalier','baptiste_chevalier','YouTube','Gaming','Brazil',823114,66507,5320,8.08,9881,1,'2018-04-21'),
  (27,'Alice Mercier','alice_mercier','YouTube','Fashion','Germany',835588,10027,802,1.2,6579,1,'2020-07-07'),
  (28,'Nicolas Faure','nicolas_faure','YouTube','Lifestyle','Germany',1185934,63447,5075,5.35,21485,0,'2020-06-26'),
  (29,'Marie Lefebvre','marie_lefebvre','Instagram','Fashion','Germany',4626463,75411,6032,1.63,34673,0,'2020-09-12'),
  (30,'Paul Bonnet','paul_bonnet','Instagram','Fitness','Brazil',1803042,188237,15059,10.44,9073,0,'2019-06-28'),
  (31,'Aya Diallo','aya_diallo','Twitter','Fitness','Germany',3826886,144656,11572,3.78,36166,0,'2021-04-01'),
  (32,'Chen Wei','chen_wei','YouTube','Beauty','France',4558263,54699,4375,1.2,62733,1,'2022-10-13'),
  (33,'Sara Kowalski','sara_kowalski','Instagram','Fitness','USA',4465408,103150,8252,2.31,62183,1,'2022-11-01'),
  (34,'Remi Bourgeois','remi_bourgeois','TikTok','Beauty','USA',1983033,101927,8154,5.14,22385,1,'2021-03-03'),
  (35,'Lucie Aubert','lucie_aubert','YouTube','Food','Italy',4395419,181970,14557,4.14,37713,0,'2018-09-26'),
  (36,'Kevin Nkosi','kevin_nkosi','Instagram','Beauty','Japan',2526557,145529,11642,5.76,36173,1,'2018-07-24'),
  (37,'Cecile Vidal','cecile_vidal','YouTube','Fitness','Italy',624555,41720,3337,6.68,11374,0,'2020-01-27'),
  (38,'Arnaud Perrin','arnaud_perrin','YouTube','Beauty','Spain',2400647,55454,4436,2.31,45555,0,'2022-12-04'),
  (39,'Jade Royer','jade_royer','Instagram','Fitness','Spain',1136515,40232,3218,3.54,10485,0,'2022-01-09'),
  (40,'Mathieu Caron','mathieu_caron','YouTube','Lifestyle','Spain',2886288,81970,6557,2.84,53627,0,'2018-07-09'),
  (41,'Vanessa Lopez','vanessa_lopez','Instagram','Beauty','Italy',3563211,357746,28619,10.04,59030,1,'2019-06-21'),
  (42,'Diego Herrera','diego_herrera','Twitter','Beauty','USA',1365447,123163,9853,9.02,8368,1,'2018-11-02'),
  (43,'Noemie Fabre','noemie_fabre','YouTube','Fitness','Brazil',4586743,41739,3339,0.91,31702,0,'2020-01-17'),
  (44,'Florian Schmitt','florian_schmitt','TikTok','Food','USA',344662,37361,2988,10.84,3551,1,'2022-11-27'),
  (45,'Amandine Roy','amandine_roy','TikTok','Food','UK',3418940,400015,32001,11.7,67158,0,'2020-04-24'),
  (46,'Tristan Marchand','tristan_marchand','YouTube','Gaming','Germany',217923,5578,446,2.56,1961,1,'2018-08-10'),
  (47,'Pauline Guerin','pauline_guerin','Twitter','Food','Germany',3218992,338959,27116,10.53,55523,0,'2019-12-18'),
  (48,'Julien Dufour','julien_dufour','TikTok','Food','France',2570126,255470,20437,9.94,38296,0,'2019-11-04'),
  (49,'Elisa Bernard','elisa_bernard','YouTube','Tech','Brazil',2347091,245036,19602,10.44,35658,1,'2019-11-10'),
  (50,'Romain Tessier','romain_tessier','YouTube','Fitness','Spain',241530,4419,353,1.83,1346,1,'2020-06-08');

-- Campagnes
INSERT INTO campaigns (campaign_id,brand_id,name,campaign_type,start_date,end_date,budget,target_platform,target_category,status) VALUES
  (1,1,'Camp_LOreal_Paris_1','Giveaway','2024-01-09','2024-03-04',119398,'Instagram','Gaming','Planned'),
  (2,1,'Camp_LOreal_Paris_2','Ambassador','2023-04-08','2023-05-25',16635,'Twitter','Beauty','Planned'),
  (3,1,'Camp_LOreal_Paris_3','Reel','2024-04-18','2024-07-10',56651,'Twitter','Fashion','Completed'),
  (4,1,'Camp_LOreal_Paris_4','Ambassador','2023-11-16','2024-01-10',37669,'YouTube','Travel','Completed'),
  (5,1,'Camp_LOreal_Paris_5','Giveaway','2023-06-17','2023-08-22',82504,'TikTok','Food','Completed'),
  (6,2,'Camp_Nike_6','Video Review','2023-12-13','2024-01-19',83892,'Instagram','Travel','Completed'),
  (7,2,'Camp_Nike_7','Video Review','2023-04-18','2023-06-27',89475,'Twitter','Lifestyle','Completed'),
  (8,2,'Camp_Nike_8','Ambassador','2023-09-19','2023-12-03',49483,'Instagram','Travel','Planned'),
  (9,2,'Camp_Nike_9','Story','2023-12-06','2024-02-01',29480,'YouTube','Food','Completed'),
  (10,2,'Camp_Nike_10','Story','2023-03-17','2023-04-04',17114,'Twitter','Fashion','Completed'),
  (11,2,'Camp_Nike_11','Ambassador','2023-08-01','2023-10-28',55970,'Twitter','Lifestyle','Completed'),
  (12,3,'Camp_Zara_12','Video Review','2023-03-17','2023-04-01',32941,'TikTok','Fitness','Planned'),
  (13,3,'Camp_Zara_13','Sponsored Post','2023-08-26','2023-09-16',70325,'Twitter','Fitness','Completed'),
  (14,3,'Camp_Zara_14','Video Review','2023-12-08','2024-02-28',88177,'Twitter','Lifestyle','Completed'),
  (15,3,'Camp_Zara_15','Reel','2024-01-16','2024-03-31',122983,'TikTok','Travel','Planned'),
  (16,4,'Camp_GoPro_16','Video Review','2023-11-17','2024-01-01',76984,'Instagram','Travel','Completed'),
  (17,4,'Camp_GoPro_17','Giveaway','2023-05-20','2023-07-16',88809,'Instagram','Fitness','Completed'),
  (18,4,'Camp_GoPro_18','Ambassador','2023-04-29','2023-07-02',45056,'TikTok','Fashion','Completed'),
  (19,4,'Camp_GoPro_19','Video Review','2023-07-28','2023-09-23',147242,'Twitter','Beauty','Completed'),
  (20,4,'Camp_GoPro_20','Giveaway','2024-03-02','2024-05-09',107099,'Instagram','Gaming','Completed'),
  (21,4,'Camp_GoPro_21','Video Review','2023-01-04','2023-03-05',83279,'Twitter','Food','Completed'),
  (22,5,'Camp_Airbnb_22','Sponsored Post','2023-05-20','2023-07-29',132308,'Twitter','Tech','Completed'),
  (23,5,'Camp_Airbnb_23','Story','2024-01-06','2024-02-11',127523,'Instagram','Gaming','Planned'),
  (24,5,'Camp_Airbnb_24','Ambassador','2023-10-16','2023-11-03',27006,'Twitter','Fitness','Completed'),
  (25,5,'Camp_Airbnb_25','Video Review','2023-04-04','2023-04-25',73198,'YouTube','Food','Completed'),
  (26,6,'Camp_Sephora_26','Video Review','2023-06-22','2023-08-24',77943,'YouTube','Fashion','Completed'),
  (27,6,'Camp_Sephora_27','Reel','2023-01-10','2023-04-04',18653,'TikTok','Fashion','Active'),
  (28,6,'Camp_Sephora_28','Story','2024-01-22','2024-02-09',69823,'Instagram','Fitness','Completed'),
  (29,6,'Camp_Sephora_29','Giveaway','2023-03-06','2023-05-20',34986,'TikTok','Lifestyle','Completed'),
  (30,6,'Camp_Sephora_30','Giveaway','2024-01-28','2024-03-30',48984,'Instagram','Fitness','Completed'),
  (31,7,'Camp_Adidas_31','Giveaway','2023-10-24','2023-11-11',86777,'Twitter','Gaming','Completed'),
  (32,7,'Camp_Adidas_32','Sponsored Post','2023-02-08','2023-05-09',68661,'YouTube','Fashion','Planned'),
  (33,7,'Camp_Adidas_33','Giveaway','2024-02-05','2024-02-25',96017,'Twitter','Tech','Active'),
  (34,8,'Camp_H&M_34','Sponsored Post','2023-01-07','2023-03-16',133503,'Twitter','Tech','Completed'),
  (35,8,'Camp_H&M_35','Story','2023-12-29','2024-02-01',119160,'YouTube','Lifestyle','Completed'),
  (36,8,'Camp_H&M_36','Reel','2023-08-12','2023-11-10',75358,'TikTok','Fashion','Completed'),
  (37,8,'Camp_H&M_37','Video Review','2024-03-27','2024-06-07',68927,'Twitter','Tech','Active'),
  (38,8,'Camp_H&M_38','Video Review','2023-09-11','2023-11-06',52668,'TikTok','Tech','Completed'),
  (39,9,'Camp_Apple_39','Giveaway','2023-05-24','2023-07-13',7661,'TikTok','Fashion','Completed'),
  (40,9,'Camp_Apple_40','Giveaway','2024-01-04','2024-03-11',133077,'TikTok','Lifestyle','Completed'),
  (41,9,'Camp_Apple_41','Reel','2023-08-18','2023-09-04',29393,'TikTok','Gaming','Completed'),
  (42,9,'Camp_Apple_42','Video Review','2023-06-06','2023-09-03',101736,'YouTube','Gaming','Planned'),
  (43,9,'Camp_Apple_43','Reel','2023-06-19','2023-08-18',123946,'YouTube','Travel','Completed'),
  (44,10,'Camp_Deliveroo_44','Sponsored Post','2024-01-05','2024-02-13',87719,'TikTok','Food','Completed'),
  (45,10,'Camp_Deliveroo_45','Ambassador','2024-01-14','2024-03-30',77482,'YouTube','Fashion','Completed'),
  (46,10,'Camp_Deliveroo_46','Story','2023-06-01','2023-07-15',99602,'YouTube','Beauty','Planned'),
  (47,11,'Camp_HelloFresh_47','Giveaway','2023-05-21','2023-06-10',19293,'YouTube','Fitness','Completed'),
  (48,11,'Camp_HelloFresh_48','Video Review','2023-02-22','2023-03-10',79537,'Twitter','Lifestyle','Completed'),
  (49,11,'Camp_HelloFresh_49','Video Review','2023-04-05','2023-04-26',71185,'Instagram','Fashion','Completed'),
  (50,11,'Camp_HelloFresh_50','Story','2023-09-09','2023-10-03',19053,'TikTok','Travel','Active'),
  (51,12,'Camp_Booking.com_51','Giveaway','2023-03-02','2023-05-27',114097,'TikTok','Gaming','Completed'),
  (52,12,'Camp_Booking.com_52','Giveaway','2024-04-10','2024-06-20',82949,'Twitter','Travel','Planned'),
  (53,12,'Camp_Booking.com_53','Story','2023-11-14','2023-12-06',31013,'TikTok','Travel','Active'),
  (54,12,'Camp_Booking.com_54','Giveaway','2023-03-22','2023-05-06',50564,'Instagram','Fitness','Active'),
  (55,13,'Camp_PlayStation_55','Sponsored Post','2023-08-19','2023-11-02',81351,'TikTok','Travel','Completed'),
  (56,13,'Camp_PlayStation_56','Ambassador','2023-12-26','2024-03-08',23659,'TikTok','Travel','Planned'),
  (57,13,'Camp_PlayStation_57','Sponsored Post','2023-12-05','2024-01-14',116447,'TikTok','Fitness','Completed'),
  (58,13,'Camp_PlayStation_58','Sponsored Post','2024-02-28','2024-04-01',23719,'TikTok','Travel','Planned'),
  (59,13,'Camp_PlayStation_59','Video Review','2024-01-19','2024-04-15',80657,'Instagram','Lifestyle','Completed'),
  (60,13,'Camp_PlayStation_60','Giveaway','2023-12-25','2024-02-29',76367,'Twitter','Lifestyle','Active'),
  (61,14,'Camp_Maybelline_61','Giveaway','2024-03-31','2024-06-09',89494,'YouTube','Beauty','Active'),
  (62,14,'Camp_Maybelline_62','Ambassador','2023-04-28','2023-07-25',10438,'YouTube','Beauty','Completed'),
  (63,14,'Camp_Maybelline_63','Reel','2023-08-29','2023-11-18',120927,'TikTok','Gaming','Completed'),
  (64,15,'Camp_Decathlon_64','Reel','2023-08-29','2023-10-27',112046,'YouTube','Fashion','Completed'),
  (65,15,'Camp_Decathlon_65','Reel','2023-06-18','2023-08-24',134884,'Twitter','Beauty','Completed'),
  (66,15,'Camp_Decathlon_66','Reel','2023-02-15','2023-04-11',71164,'Instagram','Gaming','Planned');

-- Publications
INSERT INTO publications (publication_id,campaign_id,influencer_id,post_date,content_type,reach,impressions,likes,comments,shares,revenue_generated,cost_paid,approved) VALUES
  (1,1,30,'2024-01-26','Photo',1040690,1418060,108648,9363,4373,41486,8862,1),
  (2,2,25,'2023-04-16','Reel',2853933,4889821,57649,6907,856,41789,80955,1),
  (3,2,38,'2023-04-13','Photo',1167794,2187455,26976,1600,1340,7935,44852,1),
  (4,3,3,'2024-05-03','Reel',199940,362375,13895,1074,602,31447,2888,1),
  (5,3,47,'2024-04-30','Carousel',1333841,2416302,140453,19373,6258,18604,61578,0),
  (6,4,40,'2023-12-02','Photo',1328568,1987503,37731,3013,1263,43749,53404,1),
  (7,4,17,'2023-11-30','Reel',562477,880510,59116,7465,1483,21588,10990,1),
  (8,4,27,'2023-12-04','Story',442679,513997,5312,661,202,25484,6279,1),
  (9,5,12,'2023-06-18','Carousel',1450058,2269040,31031,1862,1359,7034,63186,0),
  (10,5,10,'2023-06-17','Story',2851510,6613524,138583,20371,1800,17868,30677,0),
  (11,5,19,'2023-07-07','Reel',901675,2067791,29304,3983,738,21252,43476,0),
  (12,5,1,'2023-07-04','Photo',303504,433609,2397,283,51,15408,7355,0),
  (13,6,33,'2024-01-02','Photo',3225518,5551600,74509,8896,3437,3514,57814,1),
  (14,7,3,'2023-04-29','Video',122092,176041,8485,773,316,12300,2793,1),
  (15,7,25,'2023-05-07','Carousel',3728756,7667770,75320,7514,2510,15716,76371,1),
  (16,7,13,'2023-05-02','Photo',1522926,3591778,70968,6850,1526,36321,47387,0),
  (17,8,8,'2023-10-07','Story',941143,1944814,98443,9419,2174,25711,32561,1),
  (18,8,36,'2023-09-26','Reel',1336090,2544899,76958,11487,1678,43637,34665,1),
  (19,8,30,'2023-10-07','Photo',1476764,3507113,154174,19197,6677,19256,10073,1),
  (20,9,25,'2023-12-13','Carousel',3091661,4485621,62451,7841,2541,45120,88075,1),
  (21,9,3,'2023-12-26','Reel',159982,352609,11118,592,273,9112,2690,1),
  (22,9,5,'2023-12-16','Video',589814,814599,28723,3695,1294,24476,13646,1),
  (23,10,14,'2023-03-25','Story',1147098,2815365,110236,8765,4940,8047,14315,1),
  (24,10,3,'2023-03-21','Video',175028,403298,12164,1489,598,37024,3045,0),
  (25,11,2,'2023-08-09','Story',2851527,4608124,42772,5342,876,25470,33155,1),
  (26,12,20,'2023-03-24','Carousel',2610550,6103279,243042,25796,11328,15007,42573,0),
  (27,13,47,'2023-09-15','Video',1754278,2041077,184725,9923,9206,8110,46576,1),
  (28,13,14,'2023-09-07','Carousel',773610,1304907,74343,9235,1202,27689,15397,0),
  (29,13,43,'2023-09-14','Reel',2499176,2863562,22742,1979,630,15973,36209,1),
  (30,14,16,'2023-12-25','Reel',2079043,2463188,114347,8871,5571,30300,40493,1),
  (31,14,42,'2023-12-28','Photo',933550,1093009,84206,7018,4172,37500,7381,1),
  (32,14,20,'2023-12-26','Video',1923902,3001255,179115,11598,8243,685,36617,1),
  (33,15,45,'2024-02-02','Video',1539864,1930830,180164,24618,2751,23977,74947,1),
  (34,15,4,'2024-02-03','Video',666918,981379,56888,3565,1526,7948,12195,0),
  (35,16,39,'2023-11-28','Photo',690936,1197259,24459,1764,846,48160,11672,1),
  (36,16,33,'2023-12-01','Photo',3063289,3630474,70761,6927,1844,45464,52431,0),
  (37,16,4,'2023-11-19','Reel',1132834,2210857,96630,5466,2029,41989,11483,1),
  (38,16,36,'2023-11-29','Carousel',2265757,3427765,130507,13123,3550,46491,30593,1),
  (39,17,50,'2023-06-03','Story',201159,316725,3681,350,98,6731,1245,1),
  (40,17,7,'2023-05-28','Video',1596620,3291511,113998,11106,1555,6094,42292,1),
  (41,17,30,'2023-05-31','Carousel',1419105,1680182,148154,21580,4810,44409,7702,1),
  (42,17,11,'2023-06-02','Photo',2180364,5354446,111416,12260,2681,38374,21816,1),
  (43,18,22,'2023-05-06','Reel',2978864,6802303,323206,28040,13091,38124,27466,0),
  (44,18,13,'2023-05-16','Carousel',2973052,5824216,138544,15831,1530,43611,62132,1),
  (45,18,12,'2023-04-29','Reel',1575487,3765654,33715,2869,581,9888,64196,0),
  (46,18,10,'2023-05-01','Photo',1497256,1839320,72766,7498,1822,30230,30707,1),
  (47,19,42,'2023-08-07','Carousel',1046070,2023845,94355,13052,1530,49942,8762,1),
  (48,19,36,'2023-08-05','Story',1429697,2544755,82350,7757,1723,49975,36351,1),
  (49,19,38,'2023-08-10','Carousel',879918,1567385,20326,2372,240,26403,54382,1),
  (50,20,39,'2024-03-08','Video',546495,1188238,19345,2445,417,8363,8420,0),
  (51,21,17,'2023-01-08','Video',476705,858244,50101,6680,2116,5223,9180,1),
  (52,21,22,'2023-01-17','Photo',1146952,2645965,124444,13387,4098,46997,32574,1),
  (53,22,10,'2023-06-01','Reel',1214966,1628810,59047,8547,1677,45694,38301,1),
  (54,23,26,'2024-01-09','Carousel',367100,609617,29661,1716,1329,49377,9246,1),
  (55,23,7,'2024-01-11','Photo',1052565,1939715,75153,5214,3084,23509,55105,1),
  (56,23,11,'2024-01-13','Reel',960705,1322103,49092,5411,1983,43459,18057,0),
  (57,23,36,'2024-01-20','Carousel',1901657,3286952,109535,15599,3568,42134,43212,1),
  (58,24,30,'2023-10-20','Story',1016659,1747729,106139,8521,2227,4181,8535,1),
  (59,24,16,'2023-10-25','Photo',1426489,1682752,78456,10447,1025,6417,50624,0),
  (60,24,3,'2023-10-30','Photo',150770,260775,10478,1372,377,21571,3353,1),
  (61,25,49,'2023-04-18','Reel',849884,2103751,88727,5184,3180,3065,32060,0),
  (62,26,14,'2023-07-08','Video',829669,1335316,79731,11305,2032,22675,15536,1),
  (63,26,27,'2023-07-12','Photo',575204,898219,6902,730,175,17014,7167,1),
  (64,26,26,'2023-07-02','Video',287185,684489,23204,1880,840,43893,9453,1),
  (65,26,38,'2023-07-01','Reel',1525258,3414227,35233,4122,1520,48916,54614,1),
  (66,27,13,'2023-01-26','Reel',1737659,2662810,80974,11750,1916,32368,48134,1),
  (67,27,22,'2023-01-14','Photo',1276128,2310768,138459,14396,5475,35006,25141,1),
  (68,27,24,'2023-01-29','Story',217861,286695,23768,1618,896,41442,5932,1),
  (69,27,12,'2023-01-24','Reel',1258907,2576866,26940,1986,748,19173,68850,0),
  (70,28,37,'2024-02-08','Story',276990,655237,18502,1284,687,37883,13578,0),
  (71,28,11,'2024-01-31','Carousel',2036980,3744873,104089,15262,4442,40127,18605,1),
  (72,29,40,'2023-03-26','Reel',1698160,3186354,48227,2906,2114,8670,49016,1),
  (73,30,29,'2024-02-11','Video',3900958,8829683,63585,3762,2951,30065,40007,1),
  (74,30,50,'2024-02-10','Carousel',80176,130169,1467,130,19,15215,1091,1),
  (75,30,41,'2024-02-17','Video',1785789,2308381,179293,14108,7743,46117,66848,0),
  (76,31,25,'2023-11-12','Photo',1374310,1548305,27761,1986,443,48160,80955,0),
  (77,31,6,'2023-10-27','Video',3451950,5252527,66967,3668,1794,41316,77278,1),
  (78,31,42,'2023-11-08','Photo',898523,1783331,81046,8712,3139,19588,8131,1),
  (79,31,8,'2023-10-31','Video',1260893,2559763,131889,7723,6460,4935,33703,1),
  (80,32,14,'2023-02-23','Story',440923,1090603,42372,3193,451,4927,13598,1),
  (81,32,17,'2023-02-26','Reel',668956,860794,70307,5992,1655,42626,8330,0),
  (82,32,4,'2023-02-23','Video',916243,1088808,78155,9974,2212,19731,9778,1),
  (83,32,40,'2023-02-09','Reel',1412426,2572786,40112,5973,1272,17101,43687,1),
  (84,33,14,'2024-02-16','Photo',1104988,2554862,106189,8834,1590,24618,14133,0),
  (85,33,16,'2024-02-19','Story',2068574,3257282,113771,7813,4287,24574,56612,1),
  (86,33,22,'2024-02-07','Photo',2713112,4620022,294372,44011,5068,19752,28639,1),
  (87,34,22,'2023-01-16','Carousel',1783186,3753121,193475,12897,5370,29803,25198,1),
  (88,34,14,'2023-01-26','Reel',1215323,2424881,116792,15083,1435,44486,15296,1),
  (89,34,25,'2023-01-23','Video',3539050,8613712,71488,4595,2452,29216,63141,1),
  (90,35,38,'2024-01-18','Story',1247849,3031342,28825,1534,465,29986,53733,1),
  (91,35,50,'2024-01-12','Carousel',183043,236633,3349,290,75,18764,1211,1),
  (92,36,10,'2023-08-17','Story',2330401,5543929,113257,6996,4643,46639,32090,1),
  (93,37,47,'2024-04-02','Photo',1202558,2083864,126629,17711,3520,6253,62419,1),
  (94,37,25,'2024-04-07','Carousel',3290014,6116267,66458,9246,2927,47149,84079,1),
  (95,37,14,'2024-04-07','Photo',818318,2028762,78640,10160,1531,32876,11751,1),
  (96,37,49,'2024-04-10','Carousel',1835887,2353019,191666,26531,2420,26593,42783,0),
  (97,38,44,'2023-09-24','Photo',273662,349044,29664,2423,384,31028,3806,1),
  (98,38,10,'2023-09-15','Carousel',3214273,6414761,156213,10653,7599,28852,32832,1),
  (99,38,23,'2023-09-14','Reel',3020764,4019186,207526,17072,7963,23176,91053,1),
  (100,38,19,'2023-09-13','Carousel',1166267,1731010,37903,4264,1310,6622,41420,1),
  (101,39,22,'2023-05-29','Carousel',2561992,4029161,277976,39581,3237,2359,25678,1),
  (102,39,21,'2023-06-13','Carousel',761997,1282609,85191,9703,2549,41601,36252,1),
  (103,40,10,'2024-01-11','Story',3043356,4614967,147907,8474,1833,29309,31688,0),
  (104,40,44,'2024-01-10','Video',173749,267159,18834,2294,741,23134,4226,1),
  (105,40,13,'2024-01-15','Photo',2046452,3165374,95364,9216,1973,16747,47011,1),
  (106,40,20,'2024-01-13','Carousel',3884035,6546108,361603,52891,16667,21958,47173,1),
  (107,41,26,'2023-08-23','Carousel',493011,864515,39835,5493,1190,6401,11640,0),
  (108,41,45,'2023-08-25','Reel',1467021,1713658,171641,13411,5818,43377,71792,1),
  (109,42,43,'2023-06-09','Reel',2561955,5427530,23313,2946,574,26752,26010,1),
  (110,43,38,'2023-07-06','Story',1135892,2051372,26239,3317,555,41344,48842,1),
  (111,43,21,'2023-06-23','Story',1581311,2565641,176790,26284,5712,24460,39234,1),
  (112,43,4,'2023-07-08','Carousel',816976,944715,69688,3755,2686,31547,11189,1),
  (113,44,45,'2024-01-15','Reel',2936258,3897890,343542,51208,13594,20110,69675,0),
  (114,44,35,'2024-01-23','Photo',2109248,3407913,87322,10249,4295,38753,34811,1),
  (115,45,24,'2024-01-22','Carousel',506486,966723,55257,6749,1842,11674,5331,0),
  (116,45,46,'2024-01-18','Video',172812,197731,4423,640,63,1741,1914,0),
  (117,45,49,'2024-01-18','Video',1285680,2152907,134224,17113,6284,48723,38901,1),
  (118,45,15,'2024-01-30','Reel',899320,2245936,104950,10268,2631,11849,34459,1),
  (119,46,16,'2023-06-21','Reel',1933622,3778504,106349,7362,2112,37074,44497,1),
  (120,46,32,'2023-06-10','Story',3295353,5087553,39544,3356,1872,47794,57048,1),
  (121,46,4,'2023-06-19','Story',952583,2242441,81255,7268,1934,10099,10173,1),
  (122,47,9,'2023-06-01','Reel',2661732,5712805,122173,8722,5267,18268,47557,1),
  (123,48,40,'2023-02-25','Carousel',1932099,2772552,54871,3022,2535,15289,56586,1),
  (124,48,47,'2023-02-25','Story',1763945,2188637,185743,23603,1895,36567,66137,1),
  (125,49,11,'2023-04-25','Story',2287048,4044479,116868,8174,5674,21548,19884,1),
  (126,49,39,'2023-04-07','Video',785762,1453041,27815,3402,1320,11973,10140,1),
  (127,49,29,'2023-04-06','Story',4155965,9156193,67742,4649,2706,19470,39898,1),
  (128,49,41,'2023-04-14','Photo',2283224,5479364,229235,19142,6458,42529,60052,0),
  (129,50,21,'2023-09-25','Video',1037732,2316570,116018,9637,4553,42986,32146,1),
  (130,50,48,'2023-09-09','Reel',1906958,3613482,189551,23831,3226,42359,44378,0),
  (131,51,26,'2023-03-04','Photo',444893,604473,35947,2302,824,16756,7931,0),
  (132,51,20,'2023-03-09','Reel',2544065,6196448,236852,18994,9217,1249,36364,1),
  (133,51,10,'2023-03-09','Photo',1311228,2296685,63725,4204,2386,46608,36334,1),
  (134,52,4,'2024-04-21','Video',902391,2202109,76973,7529,2170,40197,10542,0),
  (135,52,25,'2024-04-27','Video',3541495,7673015,71538,8443,2420,5865,78368,1),
  (136,52,6,'2024-04-12','Photo',3833539,4548345,74370,7791,2247,38032,79779,1),
  (137,53,4,'2023-11-30','Video',762506,1604072,65041,6431,2988,29695,12475,0),
  (138,53,23,'2023-11-18','Story',3006361,5680445,206537,21868,7623,20696,84127,0),
  (139,53,12,'2023-11-22','Video',3048216,5820982,65231,3556,1551,4678,63566,1),
  (140,54,30,'2023-04-06','Story',575244,777714,60055,3816,2141,48294,9602,0),
  (141,55,10,'2023-08-31','Story',2212587,3597453,107531,12718,3921,35843,27980,1),
  (142,55,44,'2023-08-22','Carousel',140306,231544,15209,954,747,727,3914,1),
  (143,55,20,'2023-09-02','Carousel',3153426,5341207,293583,25814,5632,30687,37725,1),
  (144,56,44,'2023-12-29','Story',110061,215817,11930,1713,543,16272,3133,1),
  (145,56,48,'2024-01-14','Carousel',822814,1679226,81787,11222,1618,3399,36798,1),
  (146,57,50,'2023-12-06','Reel',92767,132455,1697,240,56,38345,1398,1),
  (147,57,23,'2023-12-12','Video',2378878,5899555,163428,16690,4337,18532,63667,1),
  (148,58,8,'2024-03-16','Reel',1172517,2835405,122645,14365,5081,21388,30769,0),
  (149,58,12,'2024-03-03','Video',1852123,3993515,39635,3858,1742,20209,71480,1),
  (150,58,21,'2024-03-13','Carousel',1516624,2544513,169558,15540,5290,25955,31940,1),
  (151,58,13,'2024-03-09','Story',2312043,5285299,107741,6383,4200,12983,45050,0),
  (152,59,41,'2024-01-21','Carousel',1471242,3110245,147712,15640,4309,22321,54382,1),
  (153,60,8,'2023-12-31','Photo',1721851,3694456,180105,22591,8388,46088,29720,1),
  (154,60,42,'2024-01-06','Carousel',1159368,1797323,104574,8188,2996,43014,7896,1),
  (155,61,17,'2024-04-16','Story',748907,927185,78710,11659,2265,21486,11161,1),
  (156,61,36,'2024-04-10','Carousel',1385458,3200018,79802,9905,849,36761,42463,0),
  (157,61,50,'2024-04-09','Reel',94546,134446,1730,185,34,36586,1429,1),
  (158,62,40,'2023-05-13','Story',2539659,4432112,72126,8891,1737,9672,58352,0),
  (159,62,16,'2023-05-03','Carousel',2101593,5225512,115587,16843,3578,5371,57016,1),
  (160,62,4,'2023-04-28','Video',738664,882818,63008,4102,1181,30385,10540,0),
  (161,63,10,'2023-08-29','Carousel',1181739,1980445,57432,2967,2233,35610,39058,1),
  (162,63,12,'2023-09-14','Story',3040585,6776353,65068,9173,929,6812,63146,1),
  (163,63,48,'2023-09-04','Reel',1726786,3870245,171642,13170,4441,24948,45331,0),
  (164,63,21,'2023-09-16','Video',796730,1211001,89074,11829,1177,43091,39299,1),
  (165,64,15,'2023-09-10','Story',1115240,1314378,130148,6630,2193,33258,39863,1),
  (166,64,37,'2023-09-16','Photo',553604,1302468,36980,5248,709,45869,13137,0),
  (167,64,29,'2023-09-06','Photo',1517189,3122678,24730,1929,784,43629,28194,1),
  (168,64,18,'2023-08-29','Carousel',3909952,5090242,432440,57111,18524,5542,27385,1),
  (169,65,23,'2023-07-05','Video',2467787,5445658,169536,20163,2227,49354,91882,1),
  (170,65,32,'2023-06-21','Photo',2562896,4041250,30754,3902,1482,26498,74499,1),
  (171,65,22,'2023-06-18','Story',2507579,4480654,272072,23284,12963,28801,26967,0),
  (172,65,41,'2023-06-20','Reel',2719800,6030550,273067,33125,3626,10607,56196,1),
  (173,66,39,'2023-02-25','Photo',586919,649879,20776,1679,506,18179,8816,1),
  (174,66,15,'2023-02-20','Carousel',1183655,2221289,138132,12542,1526,23694,35784,1),
  (175,66,41,'2023-02-27','Story',1095346,1799565,109972,6430,5063,16408,60729,1),
  (176,66,30,'2023-02-27','Reel',724283,1102057,75615,7509,947,28986,8259,1);

-- =============================================================
-- PARTIE 3 : REQUÊTES SELECT (5 requêtes différentes)
-- =============================================================

-- Q1 : Top 10 influenceurs par taux d'engagement avec filtre followers
SELECT name, platform, category, followers, engagement_rate,
       ROUND(avg_likes / followers * 100, 2) AS calc_eng_rate
FROM influencers
WHERE followers > 50000
ORDER BY engagement_rate DESC
LIMIT 10;

-- Q2 : Budget total par marque et nombre de campagnes, filtrer > 1 campagne
SELECT b.name AS brand, b.industry,
       COUNT(c.campaign_id)   AS nb_campaigns,
       SUM(c.budget)          AS total_budget,
       AVG(c.budget)          AS avg_budget
FROM brands b
JOIN campaigns c ON b.brand_id = c.brand_id
GROUP BY b.brand_id, b.name, b.industry
HAVING COUNT(c.campaign_id) > 1
ORDER BY total_budget DESC;

-- Q3 : ROI par campagne (revenue généré vs coût) sur 3 tables
SELECT b.name AS brand, c.name AS campaign, c.campaign_type, c.status,
       SUM(p.cost_paid)          AS total_cost,
       SUM(p.revenue_generated)  AS total_revenue,
       ROUND(SUM(p.revenue_generated) / NULLIF(SUM(p.cost_paid),0), 2) AS roi_ratio,
       SUM(p.reach)              AS total_reach
FROM campaigns c
JOIN brands b       ON c.brand_id      = b.brand_id
JOIN publications p ON c.campaign_id   = p.campaign_id
WHERE p.approved = 1
GROUP BY c.campaign_id, b.name, c.name, c.campaign_type, c.status
ORDER BY roi_ratio DESC
LIMIT 15;

-- Q4 : Influenceurs ayant travaillé avec plus d'une marque (sous-requête)
SELECT i.name, i.platform, i.category, i.followers,
       brand_count.nb_brands
FROM influencers i
JOIN (
    SELECT p.influencer_id,
           COUNT(DISTINCT c.brand_id) AS nb_brands
    FROM publications p
    JOIN campaigns c ON p.campaign_id = c.campaign_id
    GROUP BY p.influencer_id
    HAVING COUNT(DISTINCT c.brand_id) > 1
) brand_count ON i.influencer_id = brand_count.influencer_id
ORDER BY brand_count.nb_brands DESC;

-- Q5 : Performance par plateforme et type de contenu (GROUP BY multiple)
SELECT i.platform, p.content_type,
       COUNT(*)                          AS nb_publications,
       ROUND(AVG(p.reach), 0)            AS avg_reach,
       ROUND(AVG(p.likes), 0)            AS avg_likes,
       ROUND(AVG(p.likes / NULLIF(p.reach,0) * 100), 2) AS avg_eng_pct,
       SUM(p.revenue_generated)          AS total_revenue
FROM publications p
JOIN influencers i ON p.influencer_id = i.influencer_id
WHERE p.approved = 1
GROUP BY i.platform, p.content_type
HAVING COUNT(*) >= 3
ORDER BY avg_eng_pct DESC;

-- =============================================================
-- PARTIE 4 : VUES
-- =============================================================

CREATE OR REPLACE VIEW v_influencer_performance AS
SELECT
    i.influencer_id, i.name, i.username, i.platform, i.category,
    i.country, i.followers, i.engagement_rate, i.verified,
    COUNT(p.publication_id)              AS total_publications,
    COALESCE(SUM(p.reach), 0)            AS total_reach,
    COALESCE(SUM(p.revenue_generated),0) AS total_revenue,
    COALESCE(SUM(p.cost_paid),0)         AS total_cost_paid,
    COALESCE(AVG(p.likes),0)             AS avg_likes_per_post,
    ROUND(COALESCE(SUM(p.revenue_generated),0)
          / NULLIF(COALESCE(SUM(p.cost_paid),1),0), 2) AS roi
FROM influencers i
LEFT JOIN publications p ON i.influencer_id = p.influencer_id AND p.approved = 1
GROUP BY i.influencer_id, i.name, i.username, i.platform, i.category,
         i.country, i.followers, i.engagement_rate, i.verified;

CREATE OR REPLACE VIEW v_campaign_summary AS
SELECT
    c.campaign_id, c.name AS campaign_name, c.campaign_type,
    c.status, c.budget, c.start_date, c.end_date,
    b.name AS brand_name, b.industry,
    COUNT(DISTINCT p.influencer_id)      AS nb_influencers,
    COALESCE(SUM(p.reach),0)             AS total_reach,
    COALESCE(SUM(p.revenue_generated),0) AS total_revenue,
    COALESCE(SUM(p.cost_paid),0)         AS total_cost,
    ROUND(COALESCE(SUM(p.revenue_generated),0)
          / NULLIF(c.budget,0) * 100, 1) AS budget_roi_pct
FROM campaigns c
JOIN brands b ON c.brand_id = b.brand_id
LEFT JOIN publications p ON c.campaign_id = p.campaign_id AND p.approved = 1
GROUP BY c.campaign_id, c.name, c.campaign_type, c.status, c.budget,
         c.start_date, c.end_date, b.name, b.industry;

-- =============================================================
-- PARTIE 5 : PROCÉDURE STOCKÉE
-- =============================================================

DELIMITER $$

CREATE PROCEDURE get_top_influencers_by_category(
    IN p_category     VARCHAR(50),
    IN p_min_followers INT,
    IN p_limit         INT
)
BEGIN
    SELECT
        i.name, i.username, i.platform, i.category,
        i.followers, i.engagement_rate, i.price_per_post, i.verified,
        IFNULL(perf.total_publications, 0) AS total_publications,
        IFNULL(perf.roi, 0)                AS roi_score
    FROM influencers i
    LEFT JOIN v_influencer_performance perf ON i.influencer_id = perf.influencer_id
    WHERE i.category    = p_category
      AND i.followers  >= p_min_followers
    ORDER BY i.engagement_rate DESC, perf.roi DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- Exemple d'appel :
-- CALL get_top_influencers_by_category('Beauty', 50000, 5);
