import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "python"))
import pandas as pd
from dash import Dash, html, dcc, Input, Output, callback
import plotly.express as px
import plotly.graph_objects as go

BASE = os.path.join(os.path.dirname(__file__), "..", "data")
df_inf  = pd.read_csv(os.path.join(BASE, "influencers.csv"))
df_b    = pd.read_csv(os.path.join(BASE, "brands.csv"))
df_c    = pd.read_csv(os.path.join(BASE, "campaigns.csv"))
df_pub  = pd.read_csv(os.path.join(BASE, "publications.csv"))
sc_path = os.path.join(BASE, "influencer_scores.csv")
df_sc   = pd.read_csv(sc_path) if os.path.exists(sc_path) else pd.DataFrame()

df_full = df_pub.merge(df_c[["campaign_id","brand_id","name","budget","status"]], on="campaign_id")
df_full.rename(columns={"name":"campaign_name"}, inplace=True)
df_full = df_full.merge(df_b[["brand_id","name","industry"]], on="brand_id")
df_full.rename(columns={"name":"brand_name"}, inplace=True)
df_full = df_full.merge(df_inf[["influencer_id","name","platform","category","followers","engagement_rate"]], on="influencer_id")
df_full.rename(columns={"name":"influencer_name"}, inplace=True)

if len(df_sc) > 0 and "influence_score" in df_sc.columns:
    cols = ["influencer_id","influence_score"] + (["segment"] if "segment" in df_sc.columns else [])
    df_inf = df_inf.merge(df_sc[cols], on="influencer_id", how="left")
df_inf["influence_score"] = df_inf.get("influence_score", pd.Series([30]*len(df_inf))).fillna(30)
if "segment" not in df_inf.columns: df_inf["segment"] = "Niche Expert"
df_inf["segment"] = df_inf["segment"].fillna("Niche Expert")

p_opts = [{"label":"Toutes les plateformes","value":"ALL"}]+[{"label":x,"value":x} for x in sorted(df_inf["platform"].unique())]
b_opts = [{"label":"Toutes les marques","value":"ALL"}]+[{"label":x,"value":x} for x in sorted(df_b["name"].unique())]
c_opts = [{"label":"Toutes les catégories","value":"ALL"}]+[{"label":x,"value":x} for x in sorted(df_inf["category"].unique())]

app = Dash(__name__, title="Influence Marketing")
app.layout = html.Div([
    html.Div([html.H1("📊 Influence Marketing Dashboard", style={"margin":"0","color":"white","fontSize":"24px"}),
              html.P("Analyse ROI | MSc2 Manager Data Marketing", style={"color":"rgba(255,255,255,.7)","margin":"4px 0 0"})],
             style={"background":"linear-gradient(135deg,#1e3a5f,#2d6a9f)","padding":"20px 32px","marginBottom":"20px"}),
    html.Div([
        html.Div([html.Label("Plateforme",style={"fontSize":"12px","fontWeight":"600","color":"#555"}),
                  dcc.Dropdown(id="fp",options=p_opts,value="ALL",clearable=False)],style={"flex":"1","minWidth":"150px"}),
        html.Div([html.Label("Marque",style={"fontSize":"12px","fontWeight":"600","color":"#555"}),
                  dcc.Dropdown(id="fb",options=b_opts,value="ALL",clearable=False)],style={"flex":"1","minWidth":"150px"}),
        html.Div([html.Label("Catégorie",style={"fontSize":"12px","fontWeight":"600","color":"#555"}),
                  dcc.Dropdown(id="fc",options=c_opts,value="ALL",clearable=False)],style={"flex":"1","minWidth":"150px"}),
        html.Div([html.Label("Followers min",style={"fontSize":"12px","fontWeight":"600","color":"#555"}),
                  dcc.Slider(id="ff",min=0,max=1000000,step=50000,value=0,
                             marks={0:"0",500000:"500K",1000000:"1M"},
                             tooltip={"placement":"bottom","always_visible":True})],style={"flex":"2","minWidth":"200px"}),
    ],style={"display":"flex","flexWrap":"wrap","gap":"16px","alignItems":"flex-end",
             "background":"white","padding":"16px 24px","borderRadius":"8px",
             "boxShadow":"0 1px 4px rgba(0,0,0,.08)","margin":"0 20px 20px"}),
    html.Div(id="kpis",style={"margin":"0 20px 20px"}),
    html.Div([
        html.Div([dcc.Graph(id="g1",config={"displayModeBar":False})],
                 style={"flex":"1","minWidth":"350px","background":"white","borderRadius":"8px","padding":"16px","boxShadow":"0 1px 4px rgba(0,0,0,.08)"}),
        html.Div([dcc.Graph(id="g2",config={"displayModeBar":False})],
                 style={"flex":"1","minWidth":"350px","background":"white","borderRadius":"8px","padding":"16px","boxShadow":"0 1px 4px rgba(0,0,0,.08)"}),
    ],style={"display":"flex","flexWrap":"wrap","gap":"16px","margin":"0 20px 20px"}),
    html.Div([
        html.Div([dcc.Graph(id="g3",config={"displayModeBar":False})],
                 style={"flex":"1","minWidth":"280px","background":"white","borderRadius":"8px","padding":"16px","boxShadow":"0 1px 4px rgba(0,0,0,.08)"}),
        html.Div([dcc.Graph(id="g4",config={"displayModeBar":False})],
                 style={"flex":"2","minWidth":"350px","background":"white","borderRadius":"8px","padding":"16px","boxShadow":"0 1px 4px rgba(0,0,0,.08)"}),
    ],style={"display":"flex","flexWrap":"wrap","gap":"16px","margin":"0 20px 24px"}),
],style={"fontFamily":"'Segoe UI',sans-serif","background":"#f5f7fa","minHeight":"100vh"})

@callback(Output("kpis","children"),Output("g1","figure"),Output("g2","figure"),Output("g3","figure"),Output("g4","figure"),
          Input("fp","value"),Input("fb","value"),Input("fc","value"),Input("ff","value"))
def update(platform,brand,category,mf):
    i = df_inf.copy()
    if platform!="ALL": i=i[i["platform"]==platform]
    if category!="ALL": i=i[i["category"]==category]
    i=i[i["followers"]>=mf]
    p=df_full[df_full["influencer_id"].isin(i["influencer_id"])].copy()
    if brand!="ALL": p=p[p["brand_name"]==brand]
    pk=p[p["approved"]==1]

    def card(t,v,s,c):
        return html.Div([html.P(t,style={"margin":"0","fontSize":"12px","color":"#888"}),
                         html.H3(v,style={"margin":"4px 0 0","fontSize":"24px","fontWeight":"700","color":c}),
                         html.P(s,style={"margin":"2px 0 0","fontSize":"11px","color":"#aaa"})],
                        style={"background":"white","borderRadius":"8px","padding":"16px","flex":"1",
                               "minWidth":"130px","borderTop":f"3px solid {c}","boxShadow":"0 1px 4px rgba(0,0,0,.08)"})

    krow=html.Div([
        card("Influenceurs",f"{len(i):,}","sélectionnés","#2d6a9f"),
        card("Engagement",f"{round(i['engagement_rate'].mean(),2) if len(i)>0 else 0}%","taux moyen","#e67e22"),
        card("Portée",f"{pk['reach'].sum()/1e6:.1f}M","impressions","#27ae60"),
        card("ROI",f"{round(pk['revenue_generated'].sum()/max(pk['cost_paid'].sum(),1),2)}x","revenu/coût","#8e44ad"),
        card("Campagnes",f"{p['campaign_id'].nunique()}","impliquées","#e74c3c"),
        card("Revenus",f"€{pk['revenue_generated'].sum()/1e3:.0f}K","générés","#1abc9c"),
    ],style={"display":"flex","flexWrap":"wrap","gap":"12px"})

    if len(pk)>0:
        rb=pk.groupby("brand_name").agg(r=("revenue_generated","sum"),c=("cost_paid","sum")).reset_index()
        rb["roi"]=(rb["r"]/rb["c"].clip(lower=1)).round(2)
        rb=rb.sort_values("roi",ascending=True).tail(12)
        f1=px.bar(rb,x="roi",y="brand_name",orientation="h",color="roi",color_continuous_scale="Blues",
                  labels={"roi":"ROI (x)","brand_name":"Marque"},title="ROI par marque")
        f1.update_layout(coloraxis_showscale=False,plot_bgcolor="white",margin=dict(l=10,r=10,t=40,b=10),height=300)
    else:
        f1=go.Figure(); f1.update_layout(title="ROI par marque — aucune donnée",height=300)

    if len(i)>0:
        f2=px.scatter(i,x="followers",y="engagement_rate",color="segment",size="influence_score",
                      hover_data=["name","platform","category"],
                      color_discrete_map={"Top Performer":"#e74c3c","Rising Star":"#e67e22","Niche Expert":"#2d6a9f","Emerging":"#95a5a6"},
                      labels={"followers":"Followers","engagement_rate":"Engagement (%)"},title="Followers vs Engagement")
        f2.update_layout(plot_bgcolor="white",margin=dict(l=10,r=10,t=40,b=10),height=300)
    else:
        f2=go.Figure(); f2.update_layout(title="Scatter — aucune donnée",height=300)

    if len(i)>0:
        sg=i["segment"].value_counts().reset_index(); sg.columns=["segment","count"]
        cm={"Top Performer":"#e74c3c","Rising Star":"#e67e22","Niche Expert":"#2d6a9f","Emerging":"#95a5a6"}
        f3=go.Figure(go.Pie(labels=sg["segment"],values=sg["count"],hole=0.55,
                            marker_colors=[cm.get(s,"#aaa") for s in sg["segment"]],textinfo="label+percent"))
        f3.update_layout(title="Segments",showlegend=False,margin=dict(l=10,r=10,t=40,b=10),height=280)
    else:
        f3=go.Figure(); f3.update_layout(title="Segments — aucune donnée",height=280)

    if len(i)>0:
        top=i.nlargest(10,"influence_score").sort_values("influence_score",ascending=True)
        f4=px.bar(top,x="influence_score",y="name",orientation="h",color="platform",
                  labels={"influence_score":"Score (/100)","name":"Influenceur"},title="Top 10 Influence Score")
        f4.update_layout(plot_bgcolor="white",margin=dict(l=10,r=10,t=40,b=10),height=280)
        f4.update_xaxes(range=[0,100])
    else:
        f4=go.Figure(); f4.update_layout(title="Top 10 — aucune donnée",height=280)

    return krow,f1,f2,f3,f4

if __name__=="__main__":
    print("Dashboard sur http://127.0.0.1:8050")
    app.run(debug=False,host="127.0.0.1",port=8050)
