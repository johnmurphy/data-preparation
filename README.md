### Background/Objective:
I wanted to understand and analyze the correlations, if any, for the following attributes listed below and prepare the data, from different sources, for further analysis and reporting. I was particularly interested in correlations relating to NAICS 722 - Food services and drinking places. Do any of these attributes positively or negatively correlate? What is the strength of the correlation? Is there multicollinearity and if so how strong is it?  What do the relationships look like visually?  

__Attributes__
1. Annual Average No. Establishments (NAICS 722)
1. Annual Average No. Employees (NAICS 722)
1. Annual Wages - Total (NAICS 722)
1. Annual Average Weekly Wage (NAICS 722)
1. Population Estimates      
1. Net Migration
1. Bank Branches - Total
1. Bank Deposits - Total
1. Median Household Income
1. Housing Units Estimates
1. Unemployment Rates

### Data Sources: 
1. U.S. Bureau of Labor Statistics (BLS)
State and County Employment and Wages (NAICS 722 - Food services and drinking places)
[Quarterly Census of Employment & Wages - QCEW](https://www.bls.gov/cew/datatoc.htm)
         
1. US Census Population:
[County Populations 2010-2017](https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/)
[County Populations 2000-2009](https://www2.census.gov/programs-surveys/popest/datasets/2000-2009/counties/totals/)

1. US Census Housing Units: [Housing Units](https://www.census.gov/data/tables/2017/demo/popest/total-housing-units.html)
        
1. Federal Deposit Insurance Corporation (FDIC): [Branch Office Deposits](https://www5.fdic.gov/idasp/warp_download_all.asp)                    
1. Federal Reserve Economic Data | FRED | St. Louis Fed
(Used quantmod package and getSymbols() to access data)
[FRED Household Median Income ](https://fred.stlouisfed.org/)
         
1. BLS Unemployment:
[Unemployment](https://download.bls.gov/pub/time.series/la/)

### Correlation Matrix: 

````
# Stage data for visual analysis and correlation matrix
GA_corr <-   df_GA_ALL          %>%
  filter(year == 2015)          %>% # filter on 2015
  select(-c(X,source, year))    %>% # remove source and year columns; Add X if loading from csv
  spread(measure, value)        %>% # rows to columns
  drop_na("annual_avg_estabs")  %>% # remove rows where annual_avg_estabs is NA: only one county
  select(-fipscode) # remove fipcode values   
 ```` 
![Georgia Correlation Matrix](/images/GeorgiaCorrelationMatrix.png)
