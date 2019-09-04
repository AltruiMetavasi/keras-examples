# prepare environment -----------------------------------------------------

# clear-up environment
rm(list = ls())

# import libs
library(glue)
library(keras)
library(magick)
library(scales)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(tidyverse)

# import model
model <- load_model_hdf5("models/final-model.hdf5")

# import sample meta
data_meta <- read_csv("data/data-test.csv")

classes <- unique(data_meta$class)
