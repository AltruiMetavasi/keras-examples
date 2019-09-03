# prepare environment -----------------------------------------------------

# clear-up environment
rm(list = ls())

# import libs
library(glue)
library(tidyverse)

# prepare dataset ---------------------------------------------------------

# get metadata
classes <- list.dirs("data-raw/", full.names = FALSE)
classes <- classes[-1]

images <- tibble(path = list.files("data-raw", recursive = TRUE)) %>%
  separate(path, into = c("class", "name"), sep = "/") %>%
  mutate(path = glue("{class}/{name}"))

# check train and test folder
if (length(list.files("data")) > 0) {

  # remove existing
  unlink("data/*", recursive = TRUE, force = TRUE)

  # create fresh
  dir.create("data/train")
  dir.create("data/validation")
  dir.create("data/test")

  for (i in classes) {

    dir.create(glue("data/train/{i}"))
    dir.create(glue("data/validation/{i}"))
    dir.create(glue("data/test/{i}"))

  }

} else {

  # create fresh
  dir.create("data/train")
  dir.create("data/validation")
  dir.create("data/test")

  for (i in classes) {

    dir.create(glue("data/train/{i}"))
    dir.create(glue("data/validation/{i}"))
    dir.create(glue("data/test/{i}"))

  }

}

# set sampling proportion
shrink <- 0.25
prop_val <- 0.25
prop_test <- 0.2

# start copy-loop
for (i in classes) {

  # get class subset
  data_subset <- images %>%
    filter(class == i)

  # sample shrink
  set.seed(100)

  data_subset <- data_subset %>%
    slice(sample(1:nrow(.), nrow(.) * shrink))

  # sample split
  set.seed(100)
  intrain <- sample(1:nrow(data_subset), nrow(data_subset) * (1 - prop_test))

  set.seed(100)
  inval <- sample(intrain, length(intrain) * prop_val)

  data_subset <- data_subset %>%
    mutate(data = ifelse(row_number() %in% intrain, "train", "test")) %>%
    mutate(data = ifelse(row_number() %in% inval, "validation", data)) %>%
    arrange(data, path)

  # set new path
  data_subset <- data_subset %>%
    group_by(data) %>%
    mutate(newname = glue("img_{str_pad(row_number(), width = 6, side = 'left', pad = '0')}.jpg")) %>%
    mutate(newpath = glue("{class}/{newname}")) %>%
    ungroup()

  # copy files
  for (j in 1:nrow(data_subset)) {

    from <- glue("data-raw/{data_subset$path[j]}")
    to <- glue("data/{data_subset$data[j]}/{data_subset$newpath[j]}")

    file.copy(from, to)

  }

}

# check sample sizes
data_size <- tibble(
  train = length(list.files("data/train", recursive = TRUE)),
  validation = length(list.files("data/validation", recursive = TRUE)),
  test = length(list.files("data/test", recursive = TRUE))
)

data_size %>%
  gather(data, size_n) %>%
  mutate(size_pct = size_n / sum(size_n))

# create train-validation-test meta
data_train <- tibble(path = list.files("data/train", recursive = TRUE)) %>%
  separate(path, into = c("class", "name"), sep = "/") %>%
  mutate(path = glue("data/train/{class}/{name}"))

data_val <- tibble(path = list.files("data/validation", recursive = TRUE)) %>%
  separate(path, into = c("class", "name"), sep = "/") %>%
  mutate(path = glue("data/validation/{class}/{name}"))

data_test <- tibble(path = list.files("data/test", recursive = TRUE)) %>%
  separate(path, into = c("class", "name"), sep = "/") %>%
  mutate(path = glue("data/test/{class}/{name}"))

# export ------------------------------------------------------------------

# write to csv
write_csv(data_train, "data/data-train.csv")
write_csv(data_val, "data/data-val.csv")
write_csv(data_test, "data/data-test.csv")
