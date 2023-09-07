librarian::shelf(cancensus, stringr, tidyverse)

# you will need an api from cancensus to be able to use this script 
# sign up here
# https://censusmapper.ca/users/sign_in
# uncomment, set this in global options if you don't want to keep reassigning the key for each R session
options(cancensus.api_key = as.vector(read.table("~/data/api_keys/censusmapper.txt", header = FALSE)))

# cache-ing the vectors is also a nice setting to avoid repeating api pulls
# see https://cran.r-project.org/web/packages/cancensus/vignettes/cancensus.html for getting started

# parse commands
# expects region name at CSD level, CA + last two digits of year of dataset, level of geography
# for Toronto census tracts in 2021, the arguments would be: 
# Toronto CT CA21
args <- commandArgs(trailingOnly = TRUE)

region_name <- args[1]

# level of data aggregation
geographic_level <- args[2]

# year of census data
dataset_var = args[3]

CSD_regions <- list_census_regions(dataset_var) %>% 
  filter(level == "CSD", (name == region_name)) %>%
  pull(region)

CSD_regions

# to view available census vectors for this year
all21_census_vecs <- list_census_vectors(dataset_var)

all21_census_vecs %>% glimpse()

## creating canadian census vectors roughly equivalent to ACS DP04 table ##

# 25% data
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

# 25% data
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

# rbind all of them to one vector
query_census_vecs <- c(population_and_dwellings, dp04_vecs, dp05_vecs) %>% unique()

# create census data objects
census_data <- get_census(dataset = dataset_var, regions = list(CSD = CSD_regions),
                       vectors = query_census_vecs, level = geographic_level)

# check the columns 
census_data %>% glimpse()

census_data %>% head(5)

# write to csv
write.csv(census_data, paste0(output_path, str_replace_all(tolower(region_name), "\\W", "_"), "_", geographic_level, "_", dataset_var, ".csv"))


