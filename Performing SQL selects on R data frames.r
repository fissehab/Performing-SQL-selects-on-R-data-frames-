
setwd("C:/Fish/R/SQL")
options(jupyter.plot_mimetypes = 'image/png')
options(repr.plot.width = 6)
options(repr.plot.height = 4)

require(downloader)
library(dplyr)
library(sqldf)
library(data.table)
library(ggplot2)
library(compare)
library(plotrix)

try.error = function(url)

{
  try_error = tryCatch(download(url,dest="data.zip"), error=function(e) e)

  if (!inherits(try_error, "error")){

      download.file(url,dest="data.zip") #you can use download instead of download.file
        unzip ("data.zip")
      }
      
    else if (inherits(try_error, "error")){

    cat(url,"not found\n")
      }
      } 


year_start=2013
year_last=year(Sys.time())

for (i in year_start:year_last){
            j=c(1:4)
            
            for (m in j){
            
            url1<-paste0("http://www.nber.org/fda/faers/",i,"/demo",i,"q",m,".csv.zip")
            url2<-paste0("http://www.nber.org/fda/faers/",i,"/drug",i,"q",m,".csv.zip")
            url3<-paste0("http://www.nber.org/fda/faers/",i,"/reac",i,"q",m,".csv.zip")
            url4<-paste0("http://www.nber.org/fda/faers/",i,"/outc",i,"q",m,".csv.zip")
            url5<-paste0("http://www.nber.org/fda/faers/",i,"/indi",i,"q",m,".csv.zip")
     
           try.error(url1)
           try.error(url2)
           try.error(url3)
           try.error(url4)
           try.error(url5)     
            }
        }

filenames <- list.files(pattern="^demo.*.csv", full.names=TRUE)

cat('We have downloaded the following quarterly demography datasets')
filenames

options(warn=-1) # Disable any warnings for this session

demo=lapply(filenames,fread)


demo_all=do.call(rbind,lapply(1:length(demo), function(i) select(as.data.frame(demo[i]),primaryid,caseid, age,age_cod,event_dt,sex,reporter_country)))

dim(demo_all)

names(demo_all)

filenames <- list.files(pattern="^drug.*.csv", full.names=TRUE)

cat('We have downloaded the following quarterly drug datasets:\n')
filenames

drug=lapply(filenames,fread)

cat('\n')
cat('Variable names:\n')
names(drug[[1]])

drug_all=do.call(rbind,lapply(1:length(drug), function(i) select(as.data.frame(drug[i]),primaryid,caseid, drug_seq,drugname,route)))

filenames <- list.files(pattern="^indi.*.csv", full.names=TRUE)


cat('We have downloaded the following quarterly diagnoses/indications datasets:\n')

filenames

indi=lapply(filenames,fread)

cat('\n')
cat('Variable names:\n')

names(indi[[15]])

indi_all=do.call(rbind,lapply(1:length(indi), function(i) select(as.data.frame(indi[i]),primaryid,caseid, indi_drug_seq,indi_pt)))

filenames <- list.files(pattern="^outc.*.csv", full.names=TRUE)


cat('We have downloaded the following quarterly patient outcome datasets:\n')


filenames

outc_all=lapply(filenames,fread)


cat('\n')
cat('Variable names\n')

names(outc_all[[1]])

names(outc_all[[4]])

colnames(outc_all[[4]])=c("primaryid", "caseid", "outc_cod")
outc_all=do.call(rbind,lapply(1:length(outc_all), function(i) select(as.data.frame(outc_all[i]),primaryid,outc_cod)))

filenames <- list.files(pattern="^reac.*.csv", full.names=TRUE)


cat('We have downloaded the following quarterly reaction (adverse event)  datasets:\n')


filenames

reac=lapply(filenames,fread)

cat('\n')
cat('Variable names:\n')
names(reac[[3]])

reac_all=do.call(rbind,lapply(1:length(indi), function(i) select(as.data.frame(reac[i]),primaryid,pt)))

all=as.data.frame(list(Demography=nrow(demo_all),Drug=nrow(drug_all),
                   Indications=nrow(indi_all),Outcomes=nrow(outc_all),
                   Reactions=nrow(reac_all)))

row.names(all)='Number of rows'

all

#SQL

sqldf("SELECT COUNT(primaryid)as 'Number of rows of Demography data'
FROM demo_all;")

# R

nrow(demo_all)

#  SQL
sqldf("SELECT *
FROM demo_all 
LIMIT 6;")

#R

head(demo_all,6)

R1=head(demo_all,6)

SQL1 =sqldf("SELECT *
FROM demo_all 
LIMIT 6;")

all.equal(R1,SQL1)

names(demo_all)


SQL2=sqldf("SELECT *
FROM demo_all WHERE sex ='F';")

R2 = filter(demo_all, sex=="F")


identical(SQL2, R2)

SQL3=sqldf("SELECT *
FROM demo_all WHERE age BETWEEN 20 AND 25;")

R3 = filter(demo_all, age >= 20 & age <= 25)

identical(SQL3, R3)

names(drug_all)

head(SQL4)
head(R4)

#SQL

sqldf("SELECT sex, COUNT(primaryid) as Total
FROM demo_all
WHERE sex IN ('F','M','NS','UNK')
GROUP BY sex
ORDER BY Total DESC ;")

# R

demo_all%>%filter(sex %in%c('F','M','NS','UNK'))%>%group_by(sex) %>%
        summarise(Total = n())%>%arrange(desc(Total))

SQL3 = sqldf("SELECT sex, COUNT(primaryid) as Total
FROM demo_all
GROUP BY sex
ORDER BY Total DESC ;")

R3 = demo_all%>%group_by(sex) %>%
        summarise(Total = n())%>%arrange(desc(Total))

compare(SQL3,R3, allowAll=TRUE)

SQL=sqldf("SELECT sex, COUNT(primaryid) as Total
FROM demo_all
WHERE sex IN ('F','M','NS','UNK')
GROUP BY sex
ORDER BY Total DESC ;")

SQL$Total=as.numeric(SQL$Total)

pie3D(SQL$Total, labels = SQL$sex,explode=0.1,col=rainbow(4),
   main="Pie Chart of adverse event reports by gender",cex.lab=0.5, cex.axis=0.5, cex.main=1,labelcex=1)

names(indi_all)
names(drug_all)

names(indi_all)=c("primaryid", "drug_seq", "indi_pt" ) # so as to have the same name (drug_seq)

R4= merge(drug_all,indi_all, by = intersect(names(drug_all), names(indi_all)))

R4=arrange(R3, primaryid,drug_seq,drugname,indi_pt)


SQL4= sqldf("SELECT d.primaryid as primaryid, d.drug_seq as drug_seq, d.drugname as drugname,
                       d.route as route,i.indi_pt as indi_pt
                       FROM drug_all d
                       INNER JOIN indi_all i
                      ON d.primaryid= i.primaryid AND d.drug_seq=i.drug_seq
                      ORDER BY primaryid,drug_seq,drugname, i.indi_pt")


compare(R4,SQL4,allowAll=TRUE)

R5 = merge(reac_all,outc_all,by=intersect(names(reac_all), names(outc_all)))



SQL5 =reac_outc_new4=sqldf("SELECT r.*, o.outc_cod as outc_cod
                     FROM reac_all r 
                     INNER JOIN outc_all o
                     ON r.primaryid=o.primaryid
                     ORDER BY r.primaryid,r.pt,o.outc_cod")


compare(R5,SQL5,allowAll = TRUE)  #TRUE

ggplot(sqldf('SELECT age, sex
             FROM demo_all
             WHERE age between 0 AND 100 AND sex IN ("F","M")
             LIMIT 10000;'), aes(x=age, fill = sex))+ geom_density(alpha = 0.6)

ggplot(sqldf("SELECT d.age as age, o.outc_cod as outcome
                     FROM demo_all d
                     INNER JOIN outc_all o
                     ON d.primaryid=o.primaryid
                     WHERE d.age BETWEEN 20 AND 100
                     LIMIT 20000;"),aes(x=age, fill = outcome))+ geom_density(alpha = 0.6)

ggplot(sqldf("SELECT de.sex as sex, dr.route as route
                     FROM demo_all de
                     INNER JOIN drug_all dr
                     ON de.primaryid=dr.primaryid
                     WHERE de.sex IN ('M','F') AND dr.route IN ('ORAL','INTRAVENOUS','TOPICAL')
                     LIMIT 200000;"),aes(x=route, fill = sex))+ geom_bar(alpha=0.6)

ggplot(sqldf("SELECT d.sex as sex, o.outc_cod as outcome
                     FROM demo_all d
                     INNER JOIN outc_all o
                     ON d.primaryid=o.primaryid
                     WHERE d.age BETWEEN 20 AND 100 AND sex IN ('F','M')
                     LIMIT 20000;"),aes(x=outcome,fill=sex))+ geom_bar(alpha = 0.6)

demo1= demo_all[1:20000,]
demo2=demo_all[20001:40000,]

R6 <- rbind(demo1, demo2)
SQL6 <- sqldf("SELECT  * FROM demo1 UNION ALL SELECT * FROM demo2;")
compare(R6,SQL6, allowAll = TRUE)


R7 <- semi_join(demo1, demo2)
SQL7 <- sqldf("SELECT  * FROM demo1 INTERSECT SELECT * FROM demo2;")
compare(R7,SQL7, allowAll = TRUE)

R8 <- anti_join(demo1, demo2)
SQL8 <- sqldf("SELECT  * FROM demo1 EXCEPT SELECT * FROM demo2;")
compare(R8,SQL8, allowAll = TRUE)
