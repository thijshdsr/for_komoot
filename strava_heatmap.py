"""
Create your own strave heatmap, Thijs de Lange 2-1-2020 

Run first section of the code and accept access of the app

Get code of response URL and insert this in the access part of the calculation part

Then run the calculation part
"""

#%%
""" Access part """ 
# import modules
from stravalib.client import Client
import pandas as pd
import webbrowser
from polyline.codec import PolylineCodec
import plotly.express as px
import os
import numpy as np
import datetime 
import calendar as cl

# set working directory
os.chdir(r'D:\ThijsL\python_cursus')

# set up client
client = Client()

# Personal app values
# id of personal app
strava_client_id = '41729'
# secret code of the app (not so secret anymore)
strava_secret = '2827c1093739e5f75cc1d304be41f642ae13f8a4'

# url  voor toestemming
url = client.authorization_url(client_id=strava_client_id, 
                               redirect_uri='http://localhost/authorization',
                               scope = ['activity:write', 'activity:read_all', 'profile:write'])
# open browser to accept download, copy code from response URL
webbrowser.open(url)

#%%
""" Api part 

In this part the API request is done. Because it's non-payed I can only request the API server every 15 minutes 600 times
This means that only 600 activities can be loaded every 15 minutes.
In order to load more than 600 activities, run this part of the code again after 15 minutes

"""

# Get code from ressponse URL and paste in code
code = '340cbba910a8a37fe7cb7f531ec3d04a599e1409'

# Use ID and codes to get access token
access_token = client.exchange_code_for_token(client_id=strava_client_id, client_secret=strava_secret, code=code)
token = access_token['access_token']
client = Client(token)

# load activities use limit=n to limit number of activities and before/after= to use a date
# Limit per 15 minutes is 600 requests
limit = 500

try:
    activities = client.get_activities(before=enddate, limit=limit)
except (NameError):
    activities = client.get_activities(limit=limit)



# number of decimals to round coordinates of points, less decimals decreases computational time, 6 is default
rond = 3
count = 0

df = pd.DataFrame()
df = pd.read_pickle('olddf')

starttime =  datetime.datetime.now()
for act in activities:
    try:
        #maps = act.map
        act_id = act.id
        types = ['latlng']
        streams = client.get_activity_streams(act_id, types=types)
        df = df.append(streams['latlng'].data)
        count += 1
        print(count, 'activiteiten gedaan')
        if count==limit:
            enddate = act.start_date
    except (TypeError, KeyError):
        count += 1
        print(count, 'activiteit heeft geen stream.') 
        print(act)

        

df.to_pickle('olddf')


#%%
'''

This is the calculation and plot part

'''

# rename columns and round coordinates
df.columns = ['lon','lat']
df['lon'] = round(df['lon'],rond)
df['lat'] = round(df['lat'],rond)

# get number of same locations and name the new column z
grouped = df.groupby(['lon','lat'], as_index=False).size()
grouped = grouped.reset_index()
grouped.columns = ['lat','lon','z']

# make heatmap plot
fig = px.density_mapbox(grouped, lat='lat', lon='lon', z='z', radius=10,
                        center=dict(lat=52.090736, lon=5.121420), zoom=0,
                        mapbox_style="stamen-terrain", range_color=(0,30))
# save plot
fig.write_html('heatmap2.html')

#%%
'''

Now we going to do some extra analysis

'''

# Get code from ressponse URL and paste in code
code = '32646f2a0ae745588dcfd22dd945a39574323a06'

# Use ID and codes to get access token
access_token = client.exchange_code_for_token(client_id=strava_client_id, client_secret=strava_secret, code=code)
token = access_token['access_token']
client = Client(token)

# load activities use limit=n to limit number of activities and before/after= to use a date
# Limit per 15 minutes is 600 requests
limit = 20

activities = client.get_activities()

count = 0
actdf = pd.DataFrame(columns=['temperatuur', 'calories', 'afstand', 'kilojoules', 'kudos', 
                     'land', 'tijd', 'datum', 'elevation', 'snelheid'])
#dfappend = pd.DataFrame(index=1, columns=['calories','test'])

for act in activities:
    
    temperatuur = act.average_temp
    calories = act.calories
    afstand = act.distance.num
    kilojoules = act.kilojoules
    kudos = act.kudos_count
    land = act.location_country
    tijd = act.moving_time.seconds
    datum = act.start_date
    elevation = act.total_elevation_gain.num
    snelheid = act.average_speed.num
    
    actdf = actdf.append({'temperatuur': temperatuur, 'calories': calories, 
                          'afstand': afstand, 'kilojoules': kilojoules, 
                          'kudos': kudos, 'land': land, 'tijd': tijd, 
                          'datum': datum, 'elevation': elevation, 'snelheid': snelheid},
                            ignore_index=True)

    # number of activities
    count += 1
    print(count, 'actviteiten gedaan')
    
actdf['afstand'] = actdf['afstand']/1000
actdf['snelheid'] = actdf['snelheid']*3.6
actdf['tijd'] = actdf['tijd']/3600
actdf['tijd'] = actdf['tijd'].astype(float)
actdf['kudos'] = actdf['kudos'].astype(float)
actdf['temperatuur'] = actdf['temperatuur'].astype(float)
    
#%%
'''
Here we are going to visualize the data
'''

#actdf = actdf.fillna(0)


#sum(actdf['land'] == 'Netherlands')

#actdf['land'] = actdf['land'].replace('Netherlands', 'The Netherlands') 

actdf['year'] = actdf['datum'].dt.year
actdf['month'] = actdf['datum'].dt.month
actdf['day'] = actdf['datum'].dt.day_name()
actdf['hour'] = actdf['datum'].dt.hour

yeardf = pd.DataFrame()
normyeardf = pd.DataFrame()
monthdf = pd.DataFrame()
daydf = pd.DataFrame()
normmonthdf = pd.DataFrame() 
normdaydf = pd.DataFrame()
yeardf['aantal'] = actdf.groupby(['year']).size()
yeardf['afstand'] = actdf.groupby(['year']).afstand.sum()
yeardf['gem_afstand'] = actdf.groupby(['year']).afstand.mean()
yeardf['kilojoules'] =actdf.groupby(['year']).kilojoules.sum()
yeardf['kudos'] = actdf.groupby(['year']).kudos.sum()
yeardf['gem_kudos'] = actdf.groupby(['year']).kudos.mean()
yeardf['tijd'] = actdf.groupby(['year']).tijd.sum()
yeardf['gem_tijd'] = actdf.groupby(['year']).tijd.mean()
yeardf['elevation'] = actdf.groupby(['year']).elevation.sum()
yeardf['snelheid'] = actdf.groupby(['year']).snelheid.mean()
#yeardf['temperatuur'] = actdf.groupby(['year']).temperatuur.mean()

for i in yeardf.columns:
    normyeardf[i] = yeardf[i]/ yeardf[i].max()
    
normyeardf.plot.line(figsize=(10,8))

monthdf['afstand'] = actdf.groupby(['month']).afstand.sum()
monthdf['gem_afstand'] = actdf.groupby(['month']).afstand.mean()
monthdf['tijd'] = actdf.groupby(['month']).tijd.sum()
monthdf['gem_tijd'] = actdf.groupby(['month']).tijd.mean()
monthdf['snelheid'] = actdf.groupby(['month']).snelheid.mean()
monthdf['gem_kudos'] = actdf.groupby(['month']).kudos.mean()

for i in monthdf.columns:
    normmonthdf[i] = monthdf[i]/ monthdf[i].max()

normmonthdf.plot.line(figsize=(10,8))


daydf['afstand'] = actdf.groupby(['day']).afstand.sum()
daydf['gem_afstand'] = actdf.groupby(['day']).afstand.mean()
daydf['tijd'] = actdf.groupby(['day']).tijd.sum()
daydf['gem_tijd'] = actdf.groupby(['day']).tijd.mean()
daydf['snelheid'] = actdf.groupby(['day']).snelheid.mean()
daydf['gem_kudos'] = actdf.groupby(['day']).kudos.mean()

for i in daydf.columns:
    print(i)
    normdaydf[i] = daydf[i]/ daydf[i].max()

normdaydf = normdaydf.loc[cl.day_name[0:7]]    
normdaydf.plot(figsize=(10,8))

dayhour = pd.DataFrame(index=range(24))
for day in actdf.day.unique():
    dayhour = actdf[actdf.day==day].groupby(by='hour').sum()
   

dayhour = actdf.groupby(['day','hour'], as_index=False).size()
dayhour = dayhour.reset_index()
dayhour.index = dayhour['hour']
dayhour = dayhour.drop('hour', axis = 1)
dayhour.plot(kind = 'bar', figsize=(10,8))
