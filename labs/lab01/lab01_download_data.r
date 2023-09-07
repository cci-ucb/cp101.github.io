librarian::shelf(cancensus, stringr, tidyverse)

# you will need an api from cancensus to be able to use this script 

# uncomment, set this in global options if you don't want to keep reassigning the key for each R session
api_key = as.vector(read.table("~/data/api_keys/censusmapper.txt", header = FALSE))[[1]]
options(cancensus.api_key = api_key)
# cache-ing the vectors is also a nice setting to avoid repeating api pulls while debugging/tweaking this
# see https://cran.r-project.org/web/packages/cancensus/vignettes/cancensus.html for getting started

CSD_regions <- list_census_regions('CA16') %>% 
  filter(level == "CSD", (name %in% c("Toronto"))) %>%
  pull(region)

CSD_regions

# 6 Canadian CMAs over 1,000,000 pop: Toronto, Montreal, Vancouver, Ottawa-Gatineau, Calgary, Edmonton
# the 2 digit province code + 3 digit CMA code is required for cancensus lookup

# to pull year census data
dataset_var = "CA21"

# lines 17 - 
census_vecs <- c("v_CA16_2207", # median individual income
                 "v_CA16_2397", # median household income
                 "v_CA16_2405", # Total - Household total income groups in 2015 for private households - 100% data
                 "v_CA16_2406", # under 5k
                 "v_CA16_2407", # 5k to 9,999
                 "v_CA16_2408", # 10k to 14,999
                 "v_CA16_2409", # 15k to 19,999
                 "v_CA16_2410", # 20k to 24,999
                 "v_CA16_2411", # 25k to 29,999
                 "v_CA16_2412", # 30k to 34,999
                 "v_CA16_2413", # 35k to 39,999
                 "v_CA16_2414", # 40k to 44,999
                 "v_CA16_2415", # 45k to 49,999
                 "v_CA16_2416", # 50k to 59,999
                 "v_CA16_2417", # 60k to 69,999
                 "v_CA16_2418", # 70k to 79,999
                 "v_CA16_2419", # 80k to 89,999
                 "v_CA16_2420", # 90k to 99,999
                 "v_CA16_2421", # 100k and over
                 "v_CA16_2422", # 100k and over - 100k to 124,999
                 "v_CA16_2423", # 100k and over - 125 to 149,999
                 "v_CA16_2424", # 100k and over - 150k to 199,999
                 "v_CA16_2425", # 100k and over - 200k and over
                 "v_CA16_2510", # Total - Low-income status in 2015 for the population in private households to whom low-income concepts are applicable - 100% data
                 "v_CA16_3954", # Total - Visible minority for the population in private households - 25% sample data
                 "v_CA16_3957", # Total visible minority population
                 "v_CA16_4836", # Total - Private households by tenure - 25% sample data
                 "v_CA16_4837", # Owner
                 "v_CA16_4838", # Renter
                 "v_CA16_4862", # Total - Occupied private dwellings by period of construction - 25% sample data
                 "v_CA16_4863", # Total - Occupied private dwellings by period of construction - 1960 or before
                 "v_CA16_4890", # Total - Owner households in non-farm, non-reserve private dwellings - 25% sample data
                 "v_CA16_4891", # % of owner households with a mortgage
                 "v_CA16_4892", # % of owner households spending 30% or more of its income on shelter costs
                 "v_CA16_4893", # median monthly shelter costs - owners
                 "v_CA16_4894", # Average monthly shelter costs for owned dwellings ($)
                 "v_CA16_4895", # median value of dwellings
                 "v_CA16_4896", # average value of dwellings
                 "v_CA16_4897", # Total - Tenant households in non-farm, non-reserve private dwellings - 25% sample data
                 "v_CA16_4898", # % of tenant households in subsidized housing
                 "v_CA16_4899", # % of tenant households spending 30% or more of its income on shelter costs
                 "v_CA16_4900", # median monthly shelter costs - renters
                 "v_CA16_4901", # Average monthly shelter costs for rented dwellings ($)
                 "v_CA16_4985", # Average total income of households in 2015 ($)
                 "v_CA16_5051", # uni educated households denom
                 "v_CA16_5105", # uni educated households
                 "v_CA16_6692", # Total - Mobility status 1 year ago - 25% sample data
                 "v_CA16_6695", # mobility, non-movers
                 "v_CA16_6698", # movers
                 "v_CA16_6701", # movers, non-migrants
                 "v_CA16_6704", # movers, migrants
                 "v_CA16_6707", # movers, migrants, internal migrants
                 "v_CA16_6710", # movers, migrants, internal migrants, intraprovincial
                 "v_CA16_6713", # movers, migrants, internal migrants, interprovincial
                 "v_CA16_6716", # movers, migrants, external migrants
                 
                 ### end UDP vectors
                 
                 # add vectors for visible minority groups
                 "v_CA16_3852",	#Total	Total - Aboriginal identity for the population in private households - 25% sample data
                 "v_CA16_3855",	#Total	Aboriginal identity
                 "v_CA16_3858",	#Total	Single Aboriginal responses
                 "v_CA16_3861",	#Total	First Nations (North American Indian)
                 "v_CA16_3864",	#Total	Métis
                 "v_CA16_3867",	#Total	Inuk (Inuit)
                 "v_CA16_3870",	#Total	Multiple Aboriginal responses
                 "v_CA16_3873",	#Total	Aboriginal responses not included elsewhere
                 "v_CA16_3876",	#Total	Non-Aboriginal identity
                 "v_CA16_3879",	#Total	Total - Population by Registered or Treaty Indian status for the population in private households - 25% sample data
                 "v_CA16_3882",	#Total	Registered or Treaty Indian
                 "v_CA16_3885",	#Total	Not a Registered or Treaty Indian
                 "v_CA16_3888",	#Total	Total - Aboriginal ancestry for the population in private households - 25% sample data
                 "v_CA16_3891",	#Total	Aboriginal ancestry (only)
                 "v_CA16_3894",	#Total	Single Aboriginal ancestry (only)
                 "v_CA16_3897",	#Total	First Nations (North American Indian) single ancestry
                 "v_CA16_3900",	#Total	Métis single ancestry
                 "v_CA16_3903",	#Total	Inuit single ancestry
                 "v_CA16_3906",	#Total	Multiple Aboriginal ancestries (only)
                 "v_CA16_3909",	#Total	First Nations (North American Indian) and Métis ancestries
                 "v_CA16_3912",	#Total	First Nations (North American Indian) and Inuit ancestries
                 "v_CA16_3915",	#Total	Métis and Inuit ancestries
                 "v_CA16_3918",	#Total	First Nations (North American Indian), Métis and Inuit ancestries
                 "v_CA16_3921",	#Total	Aboriginal and non-Aboriginal ancestries
                 "v_CA16_3924",	#Total	Single Aboriginal and non-Aboriginal ancestries
                 "v_CA16_3927",	#Total	First Nations (North American Indian) and non-Aboriginal ancestries
                 "v_CA16_3930",	#Total	Métis and non-Aboriginal ancestries
                 "v_CA16_3933",	#Total	Inuit and non-Aboriginal ancestries
                 "v_CA16_3936",	#Total	Multiple Aboriginal and non-Aboriginal ancestries
                 "v_CA16_3939",	#Total	First Nations (North American Indian), Métis and non-Aboriginal ancestries
                 "v_CA16_3942",	#Total	First Nations (North American Indian), Inuit and non-Aboriginal ancestries
                 "v_CA16_3945",	#Total	Métis, Inuit and non-Aboriginal ancestries
                 "v_CA16_3948",	#Total	First Nations (North American Indian), Métis, Inuit and non-Aboriginal ancestries
                 "v_CA16_3951",	#Total	Non-Aboriginal ancestry (only)
                 
                 
                 
                 
                 
                 
                 "v_CA16_3954",	#Total	Total - Visible minority for the population in private households - 25% sample data
                 "v_CA16_3957",	#Total	Total visible minority population
                 "v_CA16_3960",	#Total	South Asian
                 "v_CA16_3963",	#Total	Chinese
                 "v_CA16_3966",	#Total	Black
                 "v_CA16_3969",	#Total	Filipino
                 "v_CA16_3972",	#Total	Latin American
                 "v_CA16_3975",	#Total	Arab
                 "v_CA16_3978",	#Total	Southeast Asian
                 "v_CA16_3981",	#Total	West Asian
                 "v_CA16_3984",	#Total	Korean
                 "v_CA16_3987",	#Total	Japanese
                 "v_CA16_3990",	#Total	Visible minority, n.i.e.
                 "v_CA16_3993",	#Total	Multiple visible minorities
                 
                 # add vectors for employment by industry
                 "v_CA16_5693",	#Total	Total Labour Force population aged 15 years and over by Industry - North American Industry Classification System (NAICS) 2012 - 25% sample data
                 "v_CA16_5696",	#Total	Industry - NAICS2012 - not applicable
                 "v_CA16_5699",	#Total	All industry categories
                 "v_CA16_5702",	#Total	11 Agriculture, forestry, fishing and hunting
                 "v_CA16_5705",	#Total	21 Mining, quarrying, and oil and gas extraction
                 "v_CA16_5708",	#Total	22 Utilities
                 "v_CA16_5711",	#Total	23 Construction
                 "v_CA16_5714",	#Total	31-33 Manufacturing
                 "v_CA16_5717",	#Total	41 Wholesale trade
                 "v_CA16_5720",	#Total	44-45 Retail trade
                 "v_CA16_5723",	#Total	48-49 Transportation and warehousing
                 "v_CA16_5726",	#Total	51 Information and cultural industries
                 "v_CA16_5729",	#Total	52 Finance and insurance
                 "v_CA16_5732",	#Total	53 Real estate and rental and leasing
                 "v_CA16_5735",	#Total	54 Professional, scientific and technical services
                 "v_CA16_5738",	#Total	55 Management of companies and enterprises
                 "v_CA16_5741",	#Total	56 Administrative and support, waste management and remediation services
                 "v_CA16_5744",	#Total	61 Educational services
                 "v_CA16_5747",	#Total	62 Health care and social assistance
                 "v_CA16_5750",	#Total	71 Arts, entertainment and recreation
                 "v_CA16_5753",	#Total	72 Accommodation and food services
                 "v_CA16_5756",	#Total	81 Other services (except public administration)
                 "v_CA16_5759",	#Total	91 Public administration
                 
                 # median age does not exist in 2016 census data api
                 "v_CA16_379" #Total	Average age
                 
)

python_colnames <- c('v_CA16_2397: Median total income of households in 2015 ($)',
                     'v_CA16_379: Average age',
                     'v_CA16_3999: Total - Ethnic origin for the population in private households - 25% sample data',
                     'v_CA16_401: Population, 2016', 'v_CA16_4044: European origins',
                     'v_CA16_404: Total private dwellings',
                     'v_CA16_405: Private dwellings occupied by usual residents',
                     'v_CA16_407: Land area in square kilometres',
                     'v_CA16_408: Occupied private dwellings by structural type of dwelling data',
                     'v_CA16_409: Single-detached house',
                     'v_CA16_410: Apartment in a building that has five or more storeys',
                     'v_CA16_411: Other attached dwelling',
                     'v_CA16_412: Semi-detached house', 'v_CA16_413: Row house',
                     'v_CA16_414: Apartment or flat in a duplex',
                     'v_CA16_415: Apartment in a building that has fewer than five storeys',
                     'v_CA16_416: Other single-attached house',
                     'v_CA16_417: Movable dwelling', 'v_CA16_4368: Hispanic',
                     'v_CA16_4404: African origins', 'v_CA16_4608: Asian origins',
                     'v_CA16_4836: Total - Private households by tenure - 25% sample data',
                     'v_CA16_4838: Renter',
                     'v_CA16_4855: Average number of rooms per dwelling',
                     'v_CA16_4862: Total - Occupied private dwellings by period of construction - 25% sample data',
                     'v_CA16_4863: 1960 or before', 'v_CA16_4864: 1961 to 1980',
                     'v_CA16_4865: 1981 to 1990', 'v_CA16_4866: 1991 to 2000',
                     'v_CA16_4867: 2001 to 2005', 'v_CA16_4868: 2006 to 2010',
                     'v_CA16_4869: 2011 to 2016',
                     'v_CA16_4900: Median monthly shelter costs for rented dwellings ($)',
                     'v_CA16_5051: Total - Highest certificate, diploma or degree for the population aged 15 years and over in private households - 25% sample data',
                     'v_CA16_5078: University certificate, diploma or degree at bachelor level or above',
                     "v_CA16_5081: Bachelor's degree",
                     'v_CA16_5084: University certificate or diploma above bachelor level',
                     'v_CA16_5087: Degree in medicine, dentistry, veterinary medicine or optometry',
                     "v_CA16_5090: Master's degree", 'v_CA16_5093: Earned doctorate',
                     'v_CA16_5792: Total - Main mode of commuting for the employed labour force aged 15 years and over in private households with a usual place of work or no fixed workplace address - 25% sample data',
                     'v_CA16_5795: Car, truck, van - as a driver',
                     'v_CA16_5798: Car, truck, van - as a passenger',
                     'v_CA16_5801: Public transit', 'v_CA16_5804: Walked',
                     'v_CA16_5807: Bicycle', 'v_CA16_5810: Other method',
                     'v_CA16_5813: Total - Commuting duration for the employed labour force aged 15 years and over in private households with a usual place of work or no fixed workplace address - 25% sample data',
                     'v_CA16_5816: Less than 15 minutes', 'v_CA16_5819: 15 to 29 minutes',
                     'v_CA16_5822: 30 to 44 minutes', 'v_CA16_5825: 45 to 59 minutes',
                     'v_CA16_5828: 60 minutes and over')

python_colnames <- str_extract(python_colnames, "[^\\:]+")

sort(census_vecs)

all16_census_vecs <- list_census_vectors("CA16")

all16_census_vecs %>% glimpse()

all21_census_vecs <- list_census_vectors("CA21")

all21_census_vecs %>% glimpse()

## canadian census vectors roughly equivalent to ACS DP04 table ##

# it will be the housing data vecs + units in structure vecs
# the rest are for recordkeeping

# this is 25% data
housing_details_vecs <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "25% data; housing;") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

# 100% data
units_in_structure <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "structural type of dwelling") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

dp04_vecs <- c(housing_details_vecs, units_in_structure)

# 25% data
year_structure_built <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "period of construction") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  pull(vector, label)

# 25% data
number_of_rooms <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "number of rooms") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  pull(vector, label)

# 25% data
number_of_bedrooms <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "number of bedrooms") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  pull(vector, label)

# 25% data
housing_tenure <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "total - private households by tenure") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  pull(vector, label)

# 25% data
# this has value, avg & median monthly shelter costs, 30% or more of income on housing costs, etc by tenure
non_farm_private_dwellings <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "non-farm.* private dwellings") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  pull(vector, label)


## canadian census vectors roughly equivalent to ACS DP05 table ##

# 100% data
sex_and_age <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "100% data;.*(total -|average|median) age") & str_detect(label, "\\s")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

# race (visible minority) - 25% data
visible_minority <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "total - visible") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

# citizenship - 25% data
citizenship <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "total - citizenship") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

dp05_vecs <- c(sex_and_age, visible_minority, citizenship)

# population and dwellings data
population_and_dwellings <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "population and dwellings") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

# all of them
query_census_vecs <- c(population_and_dwellings, dp04_vecs, dp05_vecs) %>% unique()

# run this once to make a dataframe
census_data <- get_census(dataset = "CA21", regions = list(CSD = CSD_regions),
                          vectors = query_census_vecs, level = "CT")

census_data %>% glimpse()


census_data %>% head(5)

# write the entire collection of canadian census data to a single csv
write.csv(census_data, "~/git/urban-data-science-notebooks/labs/lab01/lab01_data.csv")


