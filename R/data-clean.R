# prepare environment -----------------------------------------------------

# clean environment
rm(list = ls())

# import libs
library(lubridate)
library(snakecase)
library(readxl)
library(tidyverse)

# import dataset ----------------------------------------------------------

# import
data_raw <- read_excel("data-raw/WA_Fn-UseC_-HR-Employee-Attrition.xlsx")

# quick check
glimpse(data_raw)

# readjust factors --------------------------------------------------------

# readjust all column names
data_raw <- data_raw %>%
  rename_all(~ to_snake_case(.))

# readjust all nominal columns
data_raw <- data_raw %>%
  mutate_if(is.character, ~ to_snake_case(.))

# quick check
glimpse(data_raw)

# finalize ----------------------------------------------------------------

# readjust columns
data_clean <- data_raw %>%
  select(attrition, everything())

# export ------------------------------------------------------------------

# write to csv
write_csv(data_clean, "data/data-clean.csv")
