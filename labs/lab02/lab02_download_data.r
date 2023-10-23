librarian::shelf(cancensus, stringr, tidyverse)

# you will need an api from cancensus to be able to use this script 
# sign up here

# https://censusmapper.ca/users/sign_in
# see https://cran.r-project.org/web/packages/cancensus/vignettes/cancensus.html for getting started
api_key = as.vector(read.table("~/data/api_keys/censusmapper.txt", header = FALSE))[[1]]
options(cancensus.api_key = api_key)


# to pull year census data
dataset_var = "CA21"

CSD_regions <- list_census_regions(dataset_var) %>% 
  filter(level == "CSD", (name %in% c("Toronto"))) %>%
  pull(region)

CSD_regions

CSD_regions06 <- list_census_regions("CA06") %>% 
  filter(level == "CSD", (name %in% c("Toronto"))) %>%
  pull(region)

# if true, this is good - can use CSD_regions for both queries
CSD_regions06 == CSD_regions

# to view available census vectors for this year
all21_census_vecs <- list_census_vectors(dataset_var)

all21_census_vecs %>% glimpse()

## 2015 - 2019 ACS table <-> canadian census topics equivalent ##

# B01003: Total Population <-> Population
# B03002: Hispanic or Latino by Race <-> Visible minority
# B08301: Means of Transportation to Work <-> Main mode of commuting for the employed labour force
# B11016: Household Type by Household Size <-> Household type
# B19001: Household Income in the Past 12 Months (in 2018 Inflation-Adjusted Dollars) <-> 

# 2021 census vectors
visible_minority21 <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "total - visible") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

means_of_transportation21 <- all21_census_vecs %>%
  filter(((vector == "v_CA21_7632") | (parent_vector == "v_CA21_7632")) &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

housing_type21 <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "private households by household size") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)
  
hh_income21 <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "household \\S+ income groups") &
           (type == "Total") & is.na(parent_vector)) %>%
    select(vector, label, parent_vector, details) %>%
    distinct(vector) %>%
    pull(vector)

census21_vecs <- c(visible_minority21, means_of_transportation21, housing_type21, hh_income21)

# create census data objects
census21_data <- get_census(dataset = "CA21", regions = list(CSD = CSD_regions),
                            vectors = census21_vecs, level = "CT")

# check the columns 
census21_data %>% glimpse()

census21_data %>% head(5)

# write to csv
write.csv(census21_data, "~/git/cp101.github.io/labs/lab03/census21_data.csv")

# repeat all of the above for 2006 census vectors
# to pull year census data


# to view available census vectors for this year
all06_census_vecs <- list_census_vectors("CA06")

all06_census_vecs %>% glimpse()

## 2000 Census tables <-> canadian census topics equivalent ##

# P001.Total Population <-> Population
# P007. Hispanic or Latino by Race <-> Visible minority
# P014. Household Type by Household Size <-> Main mode of commuting for the employed labour force
# P030. Means of Transportation to Work <-> Household size
# P052. Household Income in 1999 <-> Income groups for all households


# 2006 census vectors
visible_minority06 <- all06_census_vecs %>%
  filter(str_detect(tolower(details), "population by visible minority groups") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

means_of_transportation06 <- all06_census_vecs %>%
  filter(str_detect(tolower(details), "mode of transportation") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

housing_type06 <- all06_census_vecs %>%
  filter(str_detect(tolower(details), "household size") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

hh_income06 <- all06_census_vecs %>%
  filter(str_detect(tolower(details), "all households; total income") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

census06_vecs <- c(visible_minority06, means_of_transportation06, housing_type06, hh_income06)

# create census data objects
census06_data <- get_census(dataset = "CA06", regions = list(CSD = CSD_regions),
                          vectors = census06_vecs, level = "CT")

# check the columns 
census06_data %>% glimpse()

census06_data %>% head(5)

# write to csv
write.csv(census06_data, "~/git/cp101.github.io/labs/lab02/census06_data.csv")
