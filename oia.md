OIA
================
Tom Saunders

``` r
library(readxl)
library(readr)
library(lubridate)
library(dplyr)
library(forcats)
library(ggplot2)
```

Read data, save as csv, read back in.

``` r
oia <- read_excel("data_raw/OIAStatisticsAllData-v2.xlsx",
                  col_types = c("numeric", "text", "text", "text", 
                                "guess", "numeric", "numeric", "numeric", 
                                "numeric", "numeric", "numeric", "numeric",
                                "numeric", "numeric", "numeric", "numeric",
                                "numeric", "numeric", "numeric"))

write_csv(oia, "data_raw/OIAStatisticsAllData-v2.csv")
rm(oia)
oia <- read_csv("data_raw/OIAStatisticsAllData-v2.csv",
                col_select = c(1:7, 9:10, 12, 14, 16, 19))
```

change column names, convert `survey_end` to date.

``` r
names(oia) <- c("org", "type", "agency", "agency_pref", 
                "survey_end", "oia_num", "oia_within_time", 
                "oia_pub", "oia_ext", "oia_tran", "oia_ref", 
                "ombud_complaints", "ombud_decisions")

oia$survey_end <- ymd(oia$survey_end)
```

Data contains duplicated entries for 2016 and 2017 in an apparent
attempt to make it easier to compare the first two collection periods
(12 months) with the other collection periods (6 months). This
effectively doubles the OIA request numbers for these periods so the
‘total’ from each of these periods needs to be removed, leaving the
total split evenly between the two 6 month periods.

``` r
remove <- oia |> 
  filter(type != "NA" & survey_end == "2016-06-30" | survey_end == "2017-06-30") |> 
  group_by(agency, survey_end) |> 
  filter(oia_num == max(oia_num))

oia <- anti_join(oia, remove)
```

Remove rows where OrgID (org) is 0 as these rows appear to again be
totals based on Agency Type.

``` r
oia <- oia |> 
  filter(org != 0)
```

For each agency, get total requests, proportion handled within statutory
timeframe, and proportions of request extensions, transfers, refusals,
ombudsman complaints, and ombudsman decisions from those complaints.

``` r
agency_totals <- oia |> 
  group_by(agency) |> 
  summarise(
    requests = sum(oia_num, na.rm = TRUE),
    within_time = sum(oia_within_time,  na.rm = TRUE) / requests,
    extensions = sum(oia_ext, na.rm = TRUE) / sum(oia_num, na.rm = TRUE),
    transfers = sum(oia_tran, na.rm = TRUE) / sum(oia_num, na.rm = TRUE),
    refusals = sum(oia_ref, na.rm = TRUE) / sum(oia_num, na.rm = TRUE),
    ombud_com = sum(ombud_complaints, na.rm = TRUE) / sum(oia_num, na.rm = TRUE),
    ombud_dec = sum(ombud_decisions, na.rm = TRUE) / sum(ombud_complaints, na.rm = TRUE),
  )
```

Pull out year from date column.

``` r
oia$year <- as_factor(year(oia$survey_end))
```

Look at trend of requests over time for NZ Police.

``` r
oia |> 
  filter(agency == "New Zealand Police") |> 
  group_by(year) |> 
  tally(oia_num) |> 
  ggplot(aes(x = year, y = n)) +
  geom_col() +
  theme_classic()
```

![](figs/nz-police-request-trend-1.png)