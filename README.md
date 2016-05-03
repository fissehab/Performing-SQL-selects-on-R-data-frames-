# Performing SQL selects on R data frames

For anyone who has SQL background and who wants to learn R, I guess the sqldf package is very useful because it enables us to use SQL commands in R. One who has basic SQL skills can manipulate data frames in R using their SQL skills.

You can read more about sqldf package from [cran](https://cran.r-project.org/web/packages/sqldf/sqldf.pdf).

In this post, we will see how to peform joins and other queries to retrieve, sort and filter data in R using SQL. We will also see how we can achieve the same tasks using non-SQL R commnads.

You can download the data [here](https://www.dropbox.com/s/m00i963vcbjur4d/merged_adverse_events_years_only?dl=0).

Currently, I am working with the [FDA adverse events data](http://www.fda.gov/Drugs/GuidanceComplianceRegulatoryInformation/Surveillance/AdverseDrugEffects/ucm082193.htm). These data sets are ideal for a data scientist or for any data enthusiast to work with because they contain almost any kind of data messiness: missing values, duplicates, compatibility problems of data sets created during different time periods, variable names and number of variables changing over time (e.g., sex in one dataset, gender in other dataset, if_cod in one dataset and if_code in other dataset), missing errors, etc.

In this post, we will use FDA adverse events data, which are publically available.

The FDA adverse events datasets can also be downloaded in csv format from the [National Bureau of Economic Research](http://www.nber.org/data/fda-adverse-event-reporting-system-faers-data.html). Since, it is easier to automate the data download in R from the National Bureau of Economic Research, in this post, we will download various datasets from this website. I encourage you to try the R codes and download data from the website and explore the adverse events datasets.

The adverse events datasets are created in quarterly temporal resolution and each quarter data includes demography information, drug/biologic information, adverse event, outcome and diagnosis, etc.

Let's download some datasets and use SQL queries to join, sort and fiter the various data frames.


You can read the full post [here](http://datascience-enthusiast.com/R/SQL_R_select.html).