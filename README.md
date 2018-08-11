# data-preparation
This repository contains the logic for preparing several publicly available data sources for consolidated reporting and analysis. Output consists of 13 years of data for Georgia counties, but can be easily be modified to include all US counties.

Data Sources: 
1. U.S. Bureau of Labor Statistics (BLS)
State and County Employment and Wages (NAICS 722 - Food services and drinking places)
[Quarterly Census of Employment & Wages - QCEW](https://www.bls.gov/cew/datatoc.htm)
         
1. Census Population:
[County Populations 2010-2017](https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/)
[County Populations 2000-2009](https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/)

1. Census Housing Units: [Housing Units](https://www.census.gov/data/tables/2017/demo/popest/total-housing-units.html)
        
1. Federal Deposit Insurance Corporation (FDIC): [Branch Office Deposits](https://www5.fdic.gov/idasp/warp_download_all.asp)               
         
1. Federal Reserve Economic Data | FRED | St. Louis Fed
(Used quantmod package and getSymbols() to access data)
[FRED Household Median Income ](https://fred.stlouisfed.org/)
         
1. BLS Unemployment:
[Unemployment](https://download.bls.gov/pub/time.series/la/)
