library(tidyverse)
library(dplyr)
library(stringr)
library(leaflet)
data <- read.csv("dataset.csv", stringsAsFactors = FALSE)
#clean up dataset
data <- data %>% mutate_if(is.factor, as.character)
options(scipen = 999) #normal notation
unique(data$Series.Name)
data <- data %>%
  rename_with(~str_remove_all(.x, "X|\\.YR"), starts_with("X"))
#convert to long format
data_long <- data %>%
  pivot_longer(
    cols = starts_with("20"), # Selects all columns that start with '20', which are your year columns
    names_to = "Year",        # The new column that will contain the year
    values_to = "Value"       # The new column that will contain the values from the year columns
  )
data_long <- data_long %>%
  rename(Continents = Country.Name)

