# data-preparation
This repository contains the logic for preparing several publicly available data sources for consolidated reporting and analysis. Output consists of 13 years of data for Georgia counties, but can be easily be modified to include all US counties.

Sources: 
1. U.S. Bureau of Labor Statistics (BLS)
State and County Employment and Wages (NAICS 722 - Food services and drinking places)
(Quarterly Census of Employment & Wages - QCEW) 
https://www.bls.gov/cew/datatoc.htm
         
1. Census Population:
https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/
https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/

1. Census Housing Units: 
https://www.census.gov/data/tables/2017/demo/popest/total-housing-units.html
         
1. Federal Deposit Insurance Corporation (FDIC):                                         
https://www5.fdic.gov/idasp/warp_download_all.asp -> Branch Office Deposits
         
1. Federal Reserve Economic Data | FRED | St. Louis Fed
FRED Household Median Income (Used quantmod package and getSymbols() to access data)
https://fred.stlouisfed.org/
         
1. BLS Unemployment:
https://download.bls.gov/pub/time.series/la/
