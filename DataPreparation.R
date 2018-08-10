# Make sure library is installed, if not install it
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("readr" %in% rownames(installed.packages()) == FALSE) {install.packages("readr")}
if("purrr" %in% rownames(installed.packages()) == FALSE) {install.packages("purrr")}
if("stringr" %in% rownames(installed.packages()) == FALSE) {install.packages("stringr")}
if("quantmod" %in% rownames(installed.packages()) == FALSE) {install.packages("quantmod")}
if("lubridate" %in% rownames(installed.packages()) == FALSE) {install.packages("lubridate")}
if("Hmisc" %in% rownames(installed.packages()) == FALSE) {install.packages("Hmisc")}


# Attach libraries
library(dplyr)
library(tidyr)
library(readr)
library(purrr)
library(stringr)
library(quantmod)
library(lubridate)
library(Hmisc, quietly=TRUE)



'******************************************************************************************

                            BLS County Data Preparation    
                        State and County Employment and Wages
                    (Quarterly Census of Employment & Wages - QCEW)

                        https://www.bls.gov/cew/datatoc.htm

******************************************************************************************'

# Set working directory (local of source files)
setwd("C:/BLS")

BLSFiles <- list.files(pattern='_annual_singlefile.zip$') # readr can read csv in zip files. No need to unzip

# create an empty list to store dataframes in below loop
dfList = list()

#FileName <- '2005_annual_singlefile.zip' # Use to debug and test

for (i in 1:length(BLSFiles))
{
  FileName <- BLSFiles[i]
  #print(FileName) # For Testing
  #FileName <- "2006_annual_singlefile.zip" # For Testing
  
  
  df1 <- FileName             %>% # read in the individual file, using
    # the function read_csv() from the readr package look into fread data.table package
    # change col_types for 4 columns that are throwing parsing errors (int to double)
    # or adjust guess_max arguement
    map(read_csv, col_types = cols(
      annual_contributions = col_double(),
      oty_taxable_annual_wages_chg = col_double(),
      oty_annual_contributions_chg = col_double(),
      oty_total_annual_wages_chg = col_double())
    ) %>%  
    as.data.frame() %>%
    filter(industry_code == '722' & agglvl_code == 75 & own_code == 5 # 75 = 3-digit code, 78 = 6-digit  5 = private ownership
           # State of Georgia Only, substring the state code using the area_fips value
           & substr(area_fips, start = 1, stop = 2) == '13') %>%
    rename(fipscode = area_fips) %>%
    select(year, fipscode, industry_code, qtr, disclosure_code, annual_avg_estabs,
           annual_avg_emplvl, total_annual_wages, taxable_annual_wages, annual_avg_wkly_wage
           , avg_annual_pay)
  
  dfList[[i]] <- df1 # add dataframe to list
  
  # Loop back up to get the next file and run again...
}

df_BLS <- bind_rows(dfList) # bind dataframes together into single dataframe

df_BLS$source <- 'BLS'

# Get data ready for Business Intelligence 
df_BLS_stg <- df_BLS %>%
              select(fipscode, year, source, annual_avg_estabs, annual_avg_emplvl, total_annual_wages, 
                     taxable_annual_wages, annual_avg_wkly_wage, avg_annual_pay) %>%
              gather('measure','value',4:8) %>%
              # example using melt from reshape2
              # melt(id=c("fipscode","year")) 
              select(fipscode, year, measure, value, source)

# Clean up. Removing unused dfs to free up memory on my PC for next data process.
rm(dfList)
rm(df1)


'******************************************************************************************

                          Census Population Data Preparation   

   https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/

******************************************************************************************'

setwd("C:/Census")

# Can get data from census FTP site
# File2017 <- "https://www2.census.gov/programs-surveys/popest/datasets/2010-2017/counties/totals/co-est2017-alldata.csv"
# Faster just to download file and run locally. 
File2017 <-'co-est2017-alldata.csv'
File2009 <-'co-est2009-alldata.csv'

# Load 2017 data
df2017 <- File2017 %>%  # read in all the files individually, using
          map(read_csv)  %>%  # the function read_csv() from the readr package
          as.data.frame()  # Initially creates a list make it a dataframe

# Set columns names to lower case and assign back to df1
RenameCols <- tolower(colnames(df2017))
colnames(df2017) <- RenameCols

df_pop_2017 <- df2017 %>%
               gather('measure','value',8:132) %>% # Pivot columns to rows for column #s 8 to 132
               filter(state == 13 & sumlev == 50) %>% # Select Georgia at County Level
               # Add leading zeros. Not really necessary as we filter on GA (13), but will be an issue if we do other states e.g. AL
               mutate(fipscode = paste(str_pad(state, 2, pad="0"),str_pad(county, 3, pad="0"), sep = "")) %>%
               mutate(year = as.numeric(str_extract(measure, '[0-9]+'))) %>% # Extract year from measure name convert to interger
               mutate(measure = gsub('[0-9]+', '', measure)) %>% # Remove numbers from measure name and assign back to measure name
               select(year, stname, ctyname, fipscode, measure, value) #%>% # Select specific columns to work with

# Load 2009 data
df2009 <- File2009 %>%  # read in all the files individually, using
          map(read_csv) %>%  # the function read_csv() from the readr package
          as.data.frame()  # Initially creates a list make it a dataframe

# Set columns names to lower case and assign back to df2009
RenameCols <- tolower(colnames(df2009))
colnames(df2009) <- RenameCols

df_pop_2009 <- df2009 %>%
               gather('measure','value',8:164) %>% # Pivot columns to rows for column #s 8 to 164
               filter(state == 13 & sumlev == 50) %>% # Select Georgia at County Level'
               # Add leading zeros. Not really necessary as we filter on GA (13), but will be an issue if we do other states e.g. AL
               mutate(fipscode = paste(str_pad(state, 2, pad="0"),str_pad(county, 3, pad="0"), sep = "")) %>%
               mutate(year = as.numeric(str_extract(measure, '[0-9]+'))) %>% # Extract year from measure name
               mutate(measure = gsub('[0-9]+', '', measure)) %>% # Remove numbers from measure name and assign back to measure name
               select(year, stname, ctyname, fipscode, measure, value) %>% # Select specific columns to work with
               mutate(value = as.numeric(value))

# Combine dataframes
df_cen_pop <- bind_rows(df_pop_2009, df_pop_2017)

df_cen_pop$source <- 'CensusPop'

# Get data ready for Business Intelligence 
df_cen_pop_stg <- df_cen_pop %>%
                  select(fipscode, year, measure, value, source)

# Explore data..check year measure combos
# unique(df_cen_pop[c('year', 'measure')])

# Clean up
rm(df_pop_2009)
rm(df_pop_2017)
rm(df2009)
rm(df2017)

'******************************************************************************************

                        Census Housing Units Data Preparation 

      https://www.census.gov/data/tables/2017/demo/popest/total-housing-units.html

*******************************************************************************************'

# Set Working Directory
setwd("C:/Census/HousingUnits/PEP_2017_PEPANNHU")

HUE2017 <- list.files(pattern='_with_ann.csv$') 

df1 <- HUE2017    %>%  # read in all the files individually, using
       map(read_csv) %>%  # the function read_csv() from the readr package
       as.data.frame()  # Creates a large list make it a dataframe

# Set columns names to lower case and assign back to df1
RenameCols <- tolower(colnames(df1))
colnames(df1) <- RenameCols

df_hue_2017 <-  df1 %>%
                slice(2:n()) %>% # Start at line 2 and return all observations.
                rename(fipscode = geo.id2) %>% # rename GEO.id2 to fipscode
                rename(county = geo.display.label) %>% # rename GEO.display.label to county
                select(2:3, 6:13) %>% #Select columns
                filter(substr(fipscode, start = 1, stop = 2) == '13') %>% # filter on GA
                gather('measure','value',3:10) %>% # Pivot columns to rows
                mutate(year = substr(as.numeric(str_extract(measure, '[0-9]+')), start = 2, stop = 5)) %>% # create year column from measure
                mutate(measure = substr(measure, start =1, stop = 5))


# Get historical data and combine into a single data frame
setwd("C:/Census/HousingUnits")

HUE2009 <- "hu-est2009-us.csv.csv"

df1 <- HUE2009    %>%  # read in all the files individually, using
       map(read_csv) %>%  # the function read_csv() from the readr package
       as.data.frame()  # Creates a large list make it a dataframe

# Set columns names to lower case and assign back to df1
RenameCols <- tolower(colnames(df1))
colnames(df1) <- RenameCols

df_hue_2009 <-  df1 %>%
                mutate(fipscode = paste(str_pad(state, 2, pad="0"),str_pad(county, 3, pad="0"), sep = "")) %>% # Create fipscode
                filter(state == '13') %>% # filter on GA
                select(fipscode, 4, 7:16) %>% # Select columns
                gather('measure','value',3:12) %>% # Pivot columns to rows
                rename(county = ctyname) %>% # rename ctyname to county
                mutate(year = substr(as.numeric(str_extract(measure, '[0-9]+')), start = 1, stop = 5)) %>% # create year column from measure
                mutate(measure = substr(measure, start =1, stop = 5))



# combine dataframes
df_hue <- rbind(df_hue_2009, df_hue_2017)

# convert year and value from character to numeric
df_hue$year <- as.numeric(df_hue$year)
df_hue$value <- as.numeric(df_hue$value)
df_hue$source <- 'HUE'

# Get data ready for Business Intelligence 
df_hue_stg <- df_hue %>%
              select(fipscode, year, measure, value, source)

# Clean up
rm(df1)
rm(df_hue_2009)
rm(df_hue_2017)

'******************************************************************************************

              Federal Deposit Insurance Corporation (FDIC) Data Preparation                                  
                  
        https://www5.fdic.gov/idasp/warp_download_all.asp -> Branch Office Deposits

******************************************************************************************'

setwd("C:/FDIC/Annual")

#TestFile <- "ALL_2000.csv"

# create a list of the zip files and unzip them to working directory
# did this as there is more than csv in each zip file. 
FDICFiles <- lapply(list.files(pattern=".ZIP$"), unzip, overwrite = TRUE)

# Create a list with files that contain only one (1) underscore. Use reg express to fine them.
FDICFilesUZ <- list.files(pattern="^[A-Za-z0-9]+_[A-Za-z0-9]+\\.csv$")

# create an empty list to store dataframes in below loop
dfList = list()


for (i in 1:length(FDICFilesUZ))
{
  FileName <- FDICFilesUZ[i]
  
  
  df1 <- FileName %>%  # read in all the files individually, using
         map(read_csv, col_types = cols(
         # change col_type to character for fips code. data type changes after 2016. This will allow the dfs to bind
         STCNTYBR = col_character())) %>%  # the function read_csv() from the readr package
         as.data.frame() %>% # Initially creates a list make it a dataframe
         filter(STNUMBR == 13)  %>%
         select(YEAR, STCNTYBR, CNTYNAMB, BRNUM, DEPSUMBR) %>%
         group_by(YEAR, STCNTYBR, CNTYNAMB) %>%
         # make sure you either use summarise instead of summarize or if using the Hmisc package reference dplyr like below
         dplyr::summarize(totalbranches = n(), totaldeposits = sum(DEPSUMBR)) %>% 
         rename(year = YEAR, fipscode = STCNTYBR, county = CNTYNAMB) 
  
  # Validate Calculation using Bibb County set TestFile variable above
  # df_test <- subset(df1, STCNTYBR == 13021)
  # write out to a csv file
  # write.csv(df_test, file = "BibbCountyTest.csv")
  
  
  # Add df to list
  dfList[[i]] <- df1
  
} 

df_FDIC <- bind_rows(dfList) # bind dataframes together into single dataframe

df_FDIC$source <- 'FDIC'

# Get data ready for Business Intelligence 
df_FDIC_stg <- df_FDIC %>%
               select(fipscode, year, source, totalbranches, totaldeposits) %>%
               gather('measure', 'value', 4:5) %>%
               select(fipscode, year, measure, value, source)

# Clean up
rm(df1)
rm(dfList)
rm(FDICFiles)


'******************************************************************************************

                  FRED Household Median Income Data Preparation   

                          https://fred.stlouisfed.org/

******************************************************************************************'

# set working directory
setwd("C:/FRED")

# Get FipsCode for Georgia
# Source: https://www.census.gov/geo/reference/codes/cou.html
ga_fips_path <- "https://www2.census.gov/geo/docs/reference/codes/files/st13_ga_cou.txt"

# Build out fipscode list for below loop
df_ga_fips <- read_csv(ga_fips_path, col_names = FALSE , col_types = cols(X2 = col_character())) %>%
              rename(statename = X1, statecode = X2, countycode = X3, countyname = X4, classcode = X5) %>%
              mutate(fipscode = paste0(statecode, countycode)) %>%
              mutate(countyname = sub("\\s.*","",countyname))

# create an empty list to store dataframes in below loop
dfList = list()

for (i in 1:nrow(df_ga_fips)) 
{
  # Assign values for beginning and ending of string to be use as the Symbol in the getSymbols function
  # FipsCode will be in the middle of the string
  Beginning <- "MHIGA"
  Ending <- "A052NCEN"
  
  # Assign measure type for reporting purposes later on.
  measure <- "Median Household Income"
  
  # Get FipsCode and CountyName from df_ga_fips. Make it a character as it is initally stored as a list
  # Need to do this to assign properly to final dataframe
  fipscode <- as.character(df_ga_fips[i, "fipscode"])
  countyname <- as.character(df_ga_fips[i,"countyname"])
  
  # Paste together the Beginning and the FipsCode assign to Step1
  Step1 <- paste0(Beginning,fipscode)
  
  # Paste Step1 and Ending together to get final Symbol value
  MHISymbol <- paste0(Step1,Ending)
  
  # use getSymbols from quantmod to obtain median household income data from 
  # Federal Reserve Economic Data | FRED | St. Louis Fed 
  df <- getSymbols(MHISymbol, src = 'FRED', auto.assign = F) 
  
  # take the xts object and convert date to value. coredate is from the zoo library
  df <- data.frame(date=time(df), coredata(df)) 
  
  # rename MHISymbol column using base r to "Value"
  names(df)[2] <- "value"
  
  # Get year from date and assign back to dataframe - use year function from lubridate library
  df$year <- year(as.Date(df$date, origin = '1900-1-1'))
  
  # Testing
  # df$FipsCode <- FipsCode
  # df$CountyName <- CountyName
  # df$MeasureType <- MeasureType
  
  # Put it all together in a single dateframe
  df1 <- df %>%
         mutate(countyname = countyname) %>%
         mutate(fipscode = fipscode) %>%
         mutate(measure = measure) %>%
         select(year, fipscode, countyname, measure, value)
  
  # Add df1 to list
  dfList[[i]] <- df1
  
  # Loop back and repeat 
  
}

# bind dataframes together into single dataframe
df_ga_mhi <- bind_rows(dfList) 

df_ga_mhi$source <- 'FRED'

write.csv(df_ga_mhi, file = "GeorgiaMHIFRED.csv")

# Get data ready for Business Intelligence 
df_mhi_stg <- df_ga_mhi %>%
              select(fipscode, year, measure, value, source)

# Clean up
rm(df1)
rm(df)

# End

'******************************************************************************************

                          BLS Unemployment Data Preparation    
                      
                      https://download.bls.gov/pub/time.series/la/

******************************************************************************************'

setwd("C:/Unemployment")

df_period <- read_tsv('la.period') 

df_series <- read_tsv('la.series') %>%
  filter( measure_code == '03' & # unemployment rate
            area_type_code == 'F' & # Counties and equivalents
            srd_code == '13') # Georgia Counties

df_georgia <- read_tsv('la.data.17.Georgia') %>% # Tab delimited file
  filter( period == 'M13') # Annual Average

df_unemp <- inner_join(df_georgia, df_series, by = "series_id") %>% # join datasets on series id
            mutate(fipscode = substr(area_code, start = 3, stop = 7)) %>% # substring out fips code from area code and create fipscode
            mutate(measure = 'Unemployment Rate') %>% # add measure feature
            select(fipscode, year, measure, value) # select only what I need

df_unemp$source <- 'unemp' # create column assign source 

# Clean up
rm(df_period)
rm(df_series)
rm(df_georgia)

'******************************************************************************************

                      Data Prep for Business Intelligence Work

******************************************************************************************'

setwd('C:/Data') # This is where I will save the file
df_GA_ALL <- bind_rows(df_BLS_stg, df_cen_pop_stg, df_FDIC_stg, df_mhi_stg, df_hue_stg, df_unemp) %>%
  filter(measure %in% c("annual_avg_estabs",
                        "annual_avg_emplvl",
                        "total_annual_wages",  
                        "annual_avg_wkly_wage",    
                        "popestimate",          
                        "netmig",
                        "totalbranches",
                        "totaldeposits",
                        "Median Household Income",
                        "huest",                
                        "Unemployment Rate")
         & year >= 2005 & fipscode != 13999) # fipscode 13999 is unknown. Filter it out.


# Save measures to a csv file
write.csv(df_GA_ALL, file = "GeorgiaData.csv")

# Save the fips codes to a csv file
df_ga_fips %>%
  select(fipscode, countyname) %>%
  write.csv( file = "GeorgiaFipsCodes.csv")


