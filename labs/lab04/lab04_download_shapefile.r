#-------------------------------------------------------------------------------
# Download 2021 Canadian spatial census data at the tract level using cancensus.
#
# Note that this code is almost the same as 'lab02_download_data.r' except for
# the final argument, geo_format = 'sf', in the 'get_census' function towards
# the bottom. This argument results in the 'geometry' column - which stores
# the geographic coordinates of each census tract polygon - being added to the
# 'census21_data' object. This object is a shapefile, rather than just an
# attribute table.
#-------------------------------------------------------------------------------

# Load packages and API key
#-----------------------------

librarian::shelf(cancensus, stringr, tidyverse, sf)

api_key = as.vector(read.table("~/data/api_keys/censusmapper.txt", header = FALSE))[[1]]
options(cancensus.api_key = api_key)

# Download data
#-----------------------------

# to pull year census data
dataset_var = "CA21"

CSD_regions <- list_census_regions(dataset_var) %>% 
  filter(level == "CSD", (name %in% c("Toronto"))) %>%
  pull(region)

CSD_regions

# to view available census vectors for this year
all21_census_vecs <- list_census_vectors(dataset_var)

# take a look
head(all21_census_vecs)

# to view available Census variables
vars21 <- list_census_vectors("CA21") %>% data.frame()
View(vars21)

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

census21_vecs <- c(visible_minority21, means_of_transportation21, 
                   housing_type21, hh_income21)

# create census data objects
census21_data <- get_census(dataset = "CA21", 
                            regions = list(CSD = CSD_regions),
                            vectors = census21_vecs, 
                            level = "CT",
                            geo_format = 'sf') # this line requests spatial data

# Explore data
#-----------------------------

head(census21_data)
class(census21_data) # what type of object is this? -> 'sf' means 'shapefile'

# map the 'geometry' column to make sure it looks like Toronto
plot(census21_data$geometry)

# Calculate new field for map
#-----------------------------

# In this lab, we'll be mapping the % of employees age 15+ who commuted to
# work via public transit. We need to calculate this variable:

census21_final <- census21_data %>%
  # shorten the variable names to make creation of new variable easier:
  rename_if(startsWith(names(.), "v_CA"), ~str_extract(., 'v_CA\\d{2}_\\d+')) %>%
  mutate(transit_pc = v_CA21_7644/v_CA21_7632) %>%
  select(transit_pc) # only keep variable we want to map

head(census21_final)

# Export data as shapefile
#-----------------------------

st_write(census21_final, "~/git/cp101.github.io/labs/lab04/lab04_data/census21_data.shp")
