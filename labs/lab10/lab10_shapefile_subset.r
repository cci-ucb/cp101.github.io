librarian::shelf(sf, sp, rgdal, tidyverse)

### CANADA ###
canadian_shapefile_full <- st_read("~/git/cp101.github.io/labs/lab10/lct_000b21a_e/lct_000b21a_e.shp")

canadian_shapefile_full %>% glimpse()

toronto_census_vectors <- read.csv("~/git/cp101.github.io/labs/lab03/census21_data.csv", stringsAsFactors = FALSE)

toronto_census_vectors %>% select(GeoUID) %>% glimpse()

toronto_shapefile <- canadian_shapefile_full %>%
  left_join()

can_city_index <- read.csv(paste(path, "input_data/can_city_index.csv", sep = ""))

canadian_shapefile <- inner_join(canadian_shapefile_full, can_city_index, by = c("DAUID" = "postal_code"))

st_write(canadian_shapefile, paste(path, "can_shp/study_area_canada.shp", sep = ""))