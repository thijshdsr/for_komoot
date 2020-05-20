rm(list = ls())

if (!require("data.table")) install.packages("data.table")
library(data.table)
if (!require("tibble")) install.packages("tibble")
library(tibble)
if (!require("lubridate")) install.packages("lubridate")
library(lubridate)
if (!require("caret")) install.packages("caret")
library(caret)
if (!require("berryFunctions")) install.packages("berryFunctions")
library(berryFunctions)
if (!require("rattle")) install.packages("rattle")
library(rattle)
if (!require("tidyr")) install.packages("tidyr")
library(tidyr)
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
if (!require("zoo")) install.packages("zoo")
library(zoo)
if (!require("base")) install.packages("base")
library(base)
if (!require("Hmisc")) install.packages("Hmisc")
library(Hmisc)
if (!require("rpart")) install.packages("rpart")
library(rpart)
if (!require("rpart.plot")) install.packages("rpart.plot")
library(rpart.plot)
if (!require("gbm")) install.packages("gbm")
library(gbm)
if (!require("ggplot2")) install.packages("ggplot2")
library(ggplot2)
if (!require("e1071")) install.packages("e1071")
library(e1071)
if(!require("h2o")) install.packages("h2o")
library(h2o)
if(!require("readr")) install.packages("readr")
library(readr)
h2o.init()


#set working direction
dir = "D:\\ThijsL\\debietvoorspelling\\OR"
setwd(dir)

#--------------------------- data uitleg --------------------------------------
# BRON: KONINKLIJK NEDERLANDS METEOROLOGISCH INSTITUUT (KNMI)
# Opmerking: door stationsverplaatsingen en veranderingen in waarneemmethodieken zijn deze tijdreeksen van uurwaarden mogelijk inhomogeen! Dat betekent dat deze reeks van gemeten waarden niet geschikt is voor trendanalyse. Voor studies naar klimaatverandering verwijzen we naar de gehomogeniseerde reeks maandtemperaturen van De Bilt <http://www.knmi.nl/klimatologie/onderzoeksgegevens/homogeen_260/index.html> of de Centraal Nederland Temperatuur <http://www.knmi.nl/klimatologie/onderzoeksgegevens/CNT/>.
# 
# 
# STN      LON(east)   LAT(north)     ALT(m)  NAME
# 348:         4.926       51.970      -0.70  CABAUW
# 
# YYYYMMDD = datum (YYYY=jaar,MM=maand,DD=dag); 
# HH       = tijd (HH=uur, UT.12 UT=13 MET, 14 MEZT. Uurvak 05 loopt van 04.00 UT tot 5.00 UT; 
# DD       = Windrichting (in graden) gemiddeld over de laatste 10 minuten van het afgelopen uur (360=noord, 90=oost, 180=zuid, 270=west, 0=windstil 990=veranderlijk. Zie http://www.knmi.nl/kennis-en-datacentrum/achtergrond/klimatologische-brochures-en-boeken; 
# FH       = Uurgemiddelde windsnelheid (in 0.1 m/s). Zie http://www.knmi.nl/kennis-en-datacentrum/achtergrond/klimatologische-brochures-en-boeken; 
# FF       = Windsnelheid (in 0.1 m/s) gemiddeld over de laatste 10 minuten van het afgelopen uur; 
# FX       = Hoogste windstoot (in 0.1 m/s) over het afgelopen uurvak; 
# T        = Temperatuur (in 0.1 graden Celsius) op 1.50 m hoogte tijdens de waarneming; 
# T10n     = Minimumtemperatuur (in 0.1 graden Celsius) op 10 cm hoogte in de afgelopen 6 uur; 
# TD       = Dauwpuntstemperatuur (in 0.1 graden Celsius) op 1.50 m hoogte tijdens de waarneming; 
# SQ       = Duur van de zonneschijn (in 0.1 uren) per uurvak, berekend uit globale straling  (-1 for <0.05 uur); 
# Q        = Globale straling (in J/cm2) per uurvak; 
# DR       = Duur van de neerslag (in 0.1 uur) per uurvak; 
# RH       = Uursom van de neerslag (in 0.1 mm) (-1 voor <0.05 mm); 
# P        = Luchtdruk (in 0.1 hPa) herleid naar zeeniveau, tijdens de waarneming; 
# VV       = Horizontaal zicht tijdens de waarneming (0=minder dan 100m, 1=100-200m, 2=200-300m,..., 49=4900-5000m, 50=5-6km, 56=6-7km, 57=7-8km, ..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=meer dan 70km); 
# N        = Bewolking (bedekkingsgraad van de bovenlucht in achtsten), tijdens de waarneming (9=bovenlucht onzichtbaar); 
# U        = Relatieve vochtigheid (in procenten) op 1.50 m hoogte tijdens de waarneming; 
# WW       = Weercode (00-99), visueel(WW) of automatisch(WaWa) waargenomen, voor het actuele weer of het weer in het afgelopen uur. Zie http://bibliotheek.knmi.nl/scholierenpdf/weercodes_Nederland; 
# IX       = Weercode indicator voor de wijze van waarnemen op een bemand of automatisch station (1=bemand gebruikmakend van code uit visuele waarnemingen, 2,3=bemand en weggelaten (geen belangrijk weersverschijnsel, geen gegevens), 4=automatisch en opgenomen (gebruikmakend van code uit visuele waarnemingen), 5,6=automatisch en weggelaten (geen belangrijk weersverschijnsel, geen gegevens), 7=automatisch gebruikmakend van code uit automatische waarnemingen); 
# M        = Mist 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming; 
# R        = Regen 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming; 
# S        = Sneeuw 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming; 
# O        = Onweer 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming; 
# Y        = IJsvorming 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming; 
# 

#------------------------------------------- data inladen -------------------------------------

meteoq = read.csv("KNMI_cabauw_hourly_2004_bijna2019.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)[,-1]

#Goed omschrijven naar datum formaat
meteoq$YYYYMMDD = ymd(meteoq$YYYYMMDD)
meteoq$YYYYMMDD = paste0(meteoq$YYYYMMDD,sep = " ", meteoq$HH,":00:00")
meteoq$YYYYMMDD = as.POSIXct(strptime(meteoq$YYYYMMDD, "%Y-%m-%d %H:%M:%S")) +60*60*24

#NA in datum door van winter naar zomertijd verwijderen
meteoq = meteoq[which(!is.na(meteoq$YYYYMMDD)),]

#niet geintreseerd in het station nummer, dus eruit
#meteoq = meteoq[,-2]

#speciale Flags omschrijven --> zie data uitleg
meteoq$SQ[meteoq$SQ == -1] = 0
meteoq$RH[meteoq$RH == -1] = 0

#zeker niet relevant
meteoq = as.data.frame(meteoq[,which(!colnames(meteoq) == "IX")])

#alle kolom indexen behalve datum
nc = 2:ncol(meteoq)

for(i in c(6:12)*6){
  print(i)
  #pak gemiddelde voor i uren
  met1 = as.data.table(rollapply(meteoq[,nc],i,mean,na.rm = TRUE, by.column = TRUE))
  #kolom naam aanpassen extra i als indicatie van aantal uren
  n = paste0(colnames(met1),sep = "_", i)
  #Goede datum reek er aan toevoegen
  met1 = cbind(meteoq$YYYYMMDD[-c(1:(i-1))],met1)
  #Kolom namen toevoegen aan i uur data reeks
  colnames(met1) = cbind("YYYYMMDD",t(n))
  #samenvoegen met het bestaande meteo frame
  meteoq = merge(meteoq,met1,by = "YYYYMMDD")
}


#verwijderen omdat het netjes is
rm(met1,n)

#-------------------------------- open en omschrijven weersvoorspelling data ----------------------------------
# omschrijven <- function(data,nm){
# 
#   data2 = data
#   #Ik wil alleen het uur hebben = eerste 2 cijfers
#   data2$tijd = substr(data2$tijd,1,2)
#   #maak datum als Y-m-d hh:mm:ss
#   data2$YMDH = paste0(data2$datum,sep = " ", data2$tijd,":00:00")
#   #handelingen om uur gemiddelde te pakken, dus als YMDH dezelfde waarde heeft
#   key <- "YMDH"
#   data2 = as.data.table(data2)
#   data2 = data2[,list(waarde = mean(waarde)),key] 
#   #Nieuwe namen voor de KOLOMMEN
#   colnames(data2) = c("YMDH",nm)
#   
#   #Kleine test of er momenten dubbel zijn
#   test = paste0(data2$datum,sep = "-", data2$tijd)
#   
#   if(length(test) == length(unique(test))){
#     print("Geen dubbele waardes")}else{
#       print("Wel dubbele waardes")
#     }
#   return(data2)
# }
# 
# 
# #Neerslag verwachting voor morgen
# p1 = read.csv("VerwachtingNeerslag1.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)[-1,]
# #1 waarde per uur met formule
# p1n = omschrijven(p1,"Neerslag [t+1]")
# #bijschrijven in het verwachtings data frame
# verw = p1n
# 
# #Neerslag verwachting voor overmorgen idem aan vorige
# p2 = read.csv("VerwachtingNeerslag2.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)[-1,]
# p2n = omschrijven(p2,"Neerslag [t+2]")
# verw = merge(verw,p2n,by = "YMDH")
# 
# #Verdamping verwachting voor morgen idem aan vorige
# e1 = read.csv("VerwachtingVerdamping1.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)[-1,]
# e1n = omschrijven(e1,"Verdamping [t+1]")
# verw = merge(verw,e1n,by = "YMDH")
# 
# #Verdamping verwachting voor morgen idem aan vorige
# e2 = read.csv("VerwachtingVerdamping2.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)[-1,]
# e2n = omschrijven(e2,"Verdamping [t+2]")
# verw = merge(verw,e2n,by = "YMDH")
# 
# #juiste format van het de datum
# verw$YMDH = as.POSIXct(strptime(verw$YMDH, "%Y-%m-%d %H:%M:%S"))
# 
# #netjes alles weer oruimen
# rm(p1,p1n,p2,p2n,e1,e1n,e2,e2n)
#------------------------------------- inladen en bijwerken bodemvocht ---------------------------------------
# 
# bv = read.csv("bodemvocht.csv", header = TRUE, sep = ";", dec = ",",stringsAsFactors = FALSE)
# 
# #Eerst omschrijven naar datum format
# bv[,1] = as.Date(bv[,1], format = "%d-%m-%Y")
# #dan omschrijven naar POSIXCT format
# bv[,1] = as.POSIXct(bv[,1], format = "%Y-%m-%d")
# #Gemiddelde pakken van alle afvoergebieden en daarvan de NA waardes weg halen door lineare interpolatie
# bv[,(ncol(bv)+1)] = na.approx(rowMeans(bv[,-1]))
# #Ik wil alleen de datum en gemiddelde hebben
# bv = bv[,c(1,ncol(bv))]
# #Kolomnamen aanpassen om het beter te begrijpen
# colnames(bv) = c("Datum","bodemvocht")

#----------------------------------- inladen debieten -------------------------------------------

q = read.csv("debiet_2004_bijna2019.csv", header = T, sep = ";", dec = ",", stringsAsFactors = F)
#Weer naar juiste datum format
q$Datum = as.POSIXct(strptime(q$Datum, "%d-%m-%Y %H:%M"))
#Geeft NA waarde om 24:00:00 doordat daar geen tijd bij wordt gezet door excel. 
#Pakt nu de waarde van de dag ervoor en telt er 60*60 seconde bij (1 uur dus)
q$Datum[which(is.na(q$Datum))] = q$Datum[(which(is.na(q$Datum))-1)]+60*60
#Verwijderen extra rijen
q = q[which(!is.na(q$Datum)),]
#negatieve waardes tellen niet
q$Debiet[q$Debiet<0] = 0

#--------------------------------- Alles samenvoegen in het master dataframe -------------------------

#Alle voorgaande datum frames samenvoegen tot 1
df = meteoq
#df = merge(df, verw, by.x = "YYYYMMDD", by.y = "YMDH", all = T)
#df = merge(df, bv, by.x = "YYYYMMDD", by.y = "Datum", all = T)
df = merge(df,q,by.x = "YYYYMMDD", by.y = "Datum", all = T)
rm(meteoq,q)

#bodemvocht waardes voor de hele dag vullen door laatst gemeten waarde te gebruiken, dus de waarde gemeten op die dag
#df$bodemvocht = na.locf(df$bodemvocht)

#Datum vector met stapjes van 6 uur
YYYYMMDD = df[seq(1,floor(nrow(df)/6)*6,6),1]
#Gemiddelde per 6 uur pakken voor alle parameters
sixh = as.data.frame(rollapply(df[,-1],width  = 6, by = 6, FUN = mean, na.rm =T, by.column = T, stringsAsFactors = F))
#6 uurs stappen van datum en data samenvoegen tot nieuw data frame
df = cbind(YYYYMMDD,sixh)
rm(sixh)
#---------------------------------- data plotten ------------------------------
#Parameter die je wilt plotten
plotvar = "Debiet"

#Hier bepalen we de minimale en maximale index (datum) met een waarde voor de te plotten waarde
minind = min(which(!is.na(df[,plotvar])))
maxind = max(which(!is.na(df[,plotvar])))

#Maken van een datum sequentie met stapjes van jaren
seu = as.Date(seq(df$YYYYMMDD[minind],df$YYYYMMDD[maxind],"years") )

#plotten van de te plotten parameter
plot(df$YYYYMMDD[minind:maxind],df[,plotvar][minind:maxind], xlab = "time", xaxt = "n", ylab = plotvar)
axis.POSIXct(1,at = seu, format= "%Y", labels = TRUE)
axis(2, labels = TRUE)
#--------------------------- maken model -----------------------------------

#Verwijder alle rije zonder debiet meting, hebben we niks aan bij voorspellen
df = subset(df,!is.na(Debiet))

#test of het begin overeen komt
if(meteoq$YYYYMMDD[1]>df$YYYYMMDD[1]){
  "Meteo begint later"
  #Meteo metingen zijn later dan debiet metingen. Starten vanaf eerste meteo meting
  df = df[-c(1:(which.min(meteoq$YYYYMMDD[1]>df$YYYYMMDD)-1)),]
}

#test of het einde overeen komt
if(tail(meteoq$YYYYMMDD, n=1)<tail(df$YYYYMMDD,n=1)){
  "Meteo eindigt eerder"
  #Meteo metingen zijn later dan debiet metingen. Starten vanaf eerste meteo meting
  df = df[-c(which.min(tail(meteoq$YYYYMMDD, n=1)>df$YYYYMMDD):length(df$YYYYMMDD)),]
}

#Wat wil je voorspellen?
npred = "Debiet"

#welke classes gebruik je, dit is het gemiddelde van de classe
classes = c("2.5", "7.5", "12.5", "17.5", "22.5")

#functie maken voor het gebruik van modellen
mod <- function(datadf,npred,classes){
    
    #Alleen gebruiken bij testen functie, anders uit
    datadf = df
    #rm(df)
    #data waar je aan de hand van gaat voorspellen
    features = names(datadf[2:(ncol(datadf)-1)])
    
    
    #per kolom percentage NA values
    pcom = sapply(datadf, function(y) sum(length(which(is.na(y)))))/nrow(datadf)
    #Alleen kolommen gebruiken met minder dan 10% NA values
    lim = which(pcom<0.1)
    
    #Verwijderen van de kolommen en features die minder dan 90% overlap hebben met wat je wilt voorspellen
    datadf = datadf[,lim]
    features = features[(lim[-c(1,length(lim))]-1)]
    
    #Zorgen dat je geen NaN maar NA values krijgt.
    datadf = as.data.frame(as.matrix(datadf), stringsAsFactors = F)
    datadf[,-1] = sapply(datadf[,-1], as.numeric)
    
    #traindata eerste 67% of laatste
    tr = datadf[1:(floor(nrow(datadf)*2/3)),]
    #tr = datadf[(ceiling(nrow(datadf)*1/3)):nrow(datadf),]
    
    #opdelen in classes min-5,5-10,10-15,15-20,20-max
    tr[,npred] = cut2(tr[,npred],c(5,10,15,20))
    tr = tr[,-1]
    levels(tr[,npred]) = paste0("Class",classes)
    tr = as.h2o(tr)
    
    #testdata eerste 33% of laatste
    te = datadf[(ceiling(nrow(datadf)*2/3)):nrow(datadf),]
    te[,npred] = cut2(te[,npred],c(5,10,15,20))
    levels(te[,npred]) = paste0("Class",classes)
    te = as.h2o(te)
    #te = datadf[1:(floor(nrow(datadf)*1/3)),]
    
    aml <- h2o.automl(y = npred,
                      training_frame = tr,
                      leaderboard_frame = te,
                      balance_classes = T,
                      #max_runtime_secs = 60,
                      seed = 1,
                      project_name = "ortest")
    print(aml@leaderboard)
    pred <- h2o.predict(aml@leader, te) 
    
    te = datadf[(ceiling(nrow(datadf)*2/3)):nrow(datadf),]

    #test data opdelen in classes
    teclass = cut2(te[,npred],c(5,10,15,20))
    levels(teclass) = paste0("Class",classes)
    
    #factor naar numeric voor plotten
    teclass = as.numeric(classes[teclass])
    fit =  parse_number(as.vector(pred$predict))
    
    #Bandbreedte maken voor de rest van de class
    lwr = fit-2.5
    upr = fit+2.5
    
    #Toeveogen aan predicitions dataframe
    pred = cbind(lwr,fit,upr)

    #ouput van results
    results = cbind(pred, te, teclass)
    return(results)
}

#verwerken model
out = mod(df,npred,classes)

#Functie om de fouten waardes te zien
difres <-function(fit,teclass){
  dif = (fit - teclass)
  res = table(dif)/length(fit)
  return(res)
}

#Fouten voor alle classes bij elkaar
res = difres(out$fit,out$teclass)

#plotten van de fouten
barplot(res, main = "Verkeerde geschatte groep",ylab = "Percentage [%]", xlab = "Voorspeld - werkelijkheid", ylim = c(0,1))

#tellen aantal rondes in de loop
count = 1

#Kleur vector voor plot in loop
kleur = c("black","red","blue","green","yellow")

for (i in as.numeric(classes)) {
  #Classes naam voor de matrix met de fouten
  nam = paste0("res",(i+2.5))
  #Gewoon dat je weet dat de boel nog bezig is
  print(i)
  #Geef de resultaten aan de net gemaakte naam can de matrix
  assign(nam,difres(out$fit[out$teclass == i],out$teclass[out$teclass == i]))
  
  #Plot en toevoegen van lijnen
  if(i == classes[1]){
    plot(eval(parse(text = nam)), type = "l",xlim = c(-20,20),xlab = 'Verschil [m^3/s]', ylab = "Percentage [%]",xaxt = "n")
  }else if (i == classes[length(classes)]){
    lines(eval(parse(text = nam)), type = "l", col = kleur[count])
    axis(1, labels = T)
    legend(-20,0.8,classes, col = kleur,lty = 1)
  }else{
    lines(eval(parse(text = nam)), type = "l", col = kleur[count])
  }
  count = count + 1
}


#Maken van een tijd plot
Legend = "Debiet meting Bodegraven"
ggplot(out, aes(x = YYYYMMDD, y = out[,npred], group = 1, colour = Legend)) +
  geom_point() +
  geom_line(aes(y = out$fit, colour = "Midden voorspelling")) +
  geom_ribbon(aes(ymin=lwr,ymax=upr, fill = "Voorspelde klasse"),  alpha=0.3, colour = NA) +
  scale_colour_manual(values =  c("black","red"),
                      guide = guide_legend(override.aes = list(
                        linetype = c("blank", "solid"),
                        shape = c(16,NA)))) +
  scale_fill_manual(values = c("red")) +
  labs(colour = "Legend", y = "Q [m3/s]", x = "datum")
h2o.shutdown()
