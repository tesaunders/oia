library(readr)
library(forcats)
library(dplyr)
library(ggplot2)
library(purrr)

# Read data

oia <- read_csv("data_raw/OIAStatisticsAllData-v2.csv")

# Inspect factors

oia <- oia |> 
  mutate(across(1:5, as.factor))

oia$SurveyPeriodEndDate <- fct_collapse(oia$SurveyPeriodEndDate,
                    "2015" = "2015-12-31",
                    "2016" = c("2016-06-30", "2016-12-31"),
                    "2017" = c("2017-06-30", "2017-12-31"),
                    "2018" = c("2018-06-30", "2018-12-31"),
                    "2019" = c("2019-06-30", "2019-12-31"),
                    "2020" = c("2020-06-30", "2020-12-31"),
                    "2021" = c("2021-06-30", "2021-12-31"),
                    "2022" = c("2022-06-30", "2022-12-31")
                    )
