# data-preparation
This repository contains the logic for preparing several publicly available data sources for consolidated reporting and analysis. I focused 13 years of data for Georgia counties, but can be easily be modified to include all US counties.

Sources: 
U.S. Bureau of Labor Statistics (BLS)
State and County Employment and Wages (NAICS 722 - Food services and drinking places)
(Quarterly Census of Employment & Wages - QCEW) 
https://www.bls.gov/cew/datatoc.htm
         
Census Population:
https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/
https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/

Census Housing Units: 
https://www.census.gov/data/tables/2017/demo/popest/total-housing-units.html
         
Federal Deposit Insurance Corporation (FDIC):                                         
https://www5.fdic.gov/idasp/warp_download_all.asp -> Branch Office Deposits
         
Federal Reserve Economic Data | FRED | St. Louis Fed
FRED Household Median Income (Used quantmod package and getSymbols() to access data)
https://fred.stlouisfed.org/
         
BLS Unemployment:
https://download.bls.gov/pub/time.series/la/
