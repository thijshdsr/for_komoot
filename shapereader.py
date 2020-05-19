# -*- coding: utf-8 -*-
"""
Created on Wed May  6 14:07:55 2020

@author: Thijs de Lange

Still work in progress
"""

import os
os.chdir(r'D:\pastas_alles\18045025_WS_HDSR_Voorspelling_Pastas\03pfiles')
import pastas as ps
import geopandas as gpd
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import json

gdf = pd.read_pickle('060518')

geodf = gpd.read_file('peilgebiedenwgs.shp')


from shapely.geometry.polygon import Polygon
from shapely.geometry.multipolygon import MultiPolygon

geodf["geometry"] = [MultiPolygon([feature]) if type(feature) == Polygon \
    else feature for feature in geodf["geometry"]]



geodf.to_file("peilgebiden.geojson", driver = "GeoJSON")
with open("peilgebiden.geojson") as geofile:
    j_file = json.load(geofile)

i=1
for feature in j_file["features"]:
    feature ['id'] = feature['properties']['CODE']
    i += 1
    
    
#gdf['betrouwbaar'] = (gdf['evp']>70) & (gdf['lo']>100) & (~gdf['is_slow'])
gdf['verschil'] = gdf['gws_vandaag'] - gdf['mean08mei']
# zorg dat altijd het bovenste meetpunt wordt weergegeven
gdf['bovenste'] = True
for name in gdf.index:
    for i in range(1,int(name[-1])):
        name_top = name[:-1]+str(i)
        if name_top in gdf.index and gdf.loc[name_top,'betrouwbaar']:
            gdf.loc[name,'bovenste']=False


column = 'verschil'  
#Alleen betrouwbare en modellen met een waarde laten plotten, anders teveel witte punten
plottuble = gdf.loc[gdf[column] == gdf[column]]
plottuble = plottuble.loc[plottuble['betrouwbaar']&plottuble['bovenste']]


from pyproj import Proj, transform
  
# copy the SR-ORG:6781 definition in Proj4 format from http://spatialreference.org/ref/sr-org/6781/
p1 = Proj("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.237,50.0087,465.658,-0.406857,0.350733,-1.87035,4.0812 +units=m +no_defs")
p2 = Proj(proj='latlong',datum='WGS84')

plottuble['markersize'] = 20

for name in plottuble.index:
    plottuble.loc[name,'x'], plottuble.loc[name,'y'] = transform(p1, p2,
                plottuble.loc[name,'x'] , plottuble.loc[name,'y'])





import plotly.express as px
import plotly.graph_objects as go


geodf['peil'] = float('NaN')
for name in geodf.index:
    if (geodf.loc[name,"ZOMERPEIL"] != 0):
        geodf.loc[name,'peil'] = geodf.loc[name,"ZOMERPEIL"]
    elif (geodf.loc[name,"VASTPEIL"] != 0):
        geodf.loc[name,'peil'] = geodf.loc[name,"VASTPEIL"]
    else:
        geodf.loc[name,'peil'] = 0

minder = min(geodf['ZOMERPEIL'].append(plottuble['gws_vandaag']))
meer = max(geodf['ZOMERPEIL'].append(plottuble['gws_vandaag']))

acces_token = 'pk.eyJ1IjoidGhpanNkZWxhbmdlIiwiYSI6ImNrYTUzNHRqajA2aGkzcHFtc3Vyb3NpY3EifQ.RvOdMyAgqGt7Rt6jXVSKVw'
mapboxt = px.set_mapbox_access_token(acces_token)
open(acces_token).read().rstrip()

fig = px.choropleth(geodf, geojson=j_file, locations='CODE', color='peil',
                           color_continuous_scale="Viridis",
                           range_color=(minder, 4),
                           labels={'unemp':'unemployment rate'}
                          )


fig = go.Figure(go.Choroplethmapbox(geojson=j_file, 
                              locations=geodf['CODE'], 
                              z=geodf['peil'], 
                              colorscale=["green","blue","red"],
                              zmin=minder, 
                              zmax=4,
                              text = geodf['CODE'],
                              hovertemplate = '<b>Peilgebied</b>: <b>%{text}</b>'+
                                            '<br><b>Peil (mNAP)</b>: %{z}<br>',
                              marker_opacity=0.6))

fig.add_trace(
    go.Scattermapbox(
        lon = plottuble['x'],
        lat = plottuble['y'],
        text = plottuble['name'] + '<br>GWS (mNAP): ' + round(plottuble['gws_vandaag'],2).astype(str) + 
        '<br>Tov gem (m): ' + round(plottuble['verschil'],2).astype(str),
        mode = 'markers',
        marker = dict(
                size = 10,
                color = plottuble['gws_vandaag'],
                colorscale=["green","blue","red"],
                cmin = minder,
                cmax = 4,
               ),
        line = dict(width = 3,
                    color = 'black'),
        maxZoom = 5
    ))
layout = go.Layout(maxZoom = 5)

plt.graph_objects.layout.Mapbox(maxZoom = 5)

fig.update_layout(mapbox_style="carto-positron",
                  mapbox_zoom=8, mapbox_center = {"lat": 52.370216, "lon": 4.895168})
        
fig.update_geos(fitbounds="locations", visible=False,
                    projection_type='azimuthal equidistant')

fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0})
# save plot

fig.write_html('test.html')  

