librarian::shelf(cancensus, stringr, tidyverse)

# you will need an api from cancensus to be able to use this script 
# sign up here

# https://censusmapper.ca/users/sign_in
# see https://cran.r-project.org/web/packages/cancensus/vignettes/cancensus.html for getting started
api_key = as.vector(read.table("~/data/api_keys/censusmapper.txt", header = FALSE))[[1]]
options(cancensus.api_key = api_key)


# to pull year census data
dataset_var = "CA21"

CMA_regions <- list_census_regions(dataset_var) %>% 
  filter(level == "CMA", (name %in% c("Toronto"))) %>%
  pull(region)

CMA_regions

# to view available census vectors for this year
all21_census_vecs <- list_census_vectors(dataset_var)

all21_census_vecs %>% glimpse()

## 2015 - 2019 ACS table <-> canadian census topics equivalent ##

# 2021 census vectors
low_income_pct <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "prevalence of") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

gini <- all21_census_vecs %>%
  filter(str_detect(tolower(details), "gini") &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

seniors <- all21_census_vecs %>%
  filter((vector %in% c("v_CA21_8", "v_CA21_251", "v_CA21_386", "v_CA21_389")) &
           (type == "Total")) %>%
  select(vector, label, parent_vector, details) %>%
  distinct(vector) %>%
  pull(vector)

census21_vecs <- c(low_income_pct, gini, seniors)

census21_vecs %>% print(n = Inf, na.print = "")

# create census data objects
census21_data <- get_census(dataset = "CA21", regions = list(CMA = CMA_regions),
                            vectors = census21_vecs, level = "CT")

# check the columns 
census21_data %>% glimpse()

census21_data %>% head(5)

# write to csv
write.csv(census21_data, "~/git/cp101.github.io/labs/lab10/census21_data.csv")