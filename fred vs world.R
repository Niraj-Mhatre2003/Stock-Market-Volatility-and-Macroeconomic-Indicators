library(httr)
library(jsonlite)
library(tibble)
library(purrr)
library(dplyr)
library(readr)

fred_key <- "d70e177752ca3ea3cbb7672ff9ec309c"

get_fred <- function(series_id) {
  url <- paste0(
    "https://api.stlouisfed.org/fred/series/observations?",
    "series_id=", series_id,
    "&api_key=", fred_key,
    "&file_type=json",
    "&realtime_start=2000-01-01&realtime_end=9999-12-31"
  )

  message("Fetching data for series: ", series_id)

  res <- GET(url)
  if (http_error(res)) {
    stop("API request failed for ", series_id,
         " - Status: ", status_code(res))
  }

  json_data <- fromJSON(content(res, "text", encoding = "UTF-8"))
  if (is.null(json_data$observations) || nrow(json_data$observations) == 0) {
    warning("No data returned for series: ", series_id)
    return(tibble(date = as.Date(character()), value = numeric()))
  }

  data <- json_data$observations

  tibble(
    date = as.Date(data$date),
    value = as.numeric(data$value)
  )
}

gdp <- get_fred("GDP")
inflation <- get_fred("CPIAUCSL")
interest_rate <- get_fred("FEDFUNDS")
unemployment <- get_fred("UNRATE")
write_csv(gdp, "data/gdp.csv")
write_csv(inflation, "data/inflation.csv")
write_csv(interest_rate, "data/interest_rate.csv")
write_csv(unemployment, "data/unemployment.csv")
macro_data <- list(
  GDP = gdp,
  Inflation = inflation,
  Interest = interest_rate,
  Unemployment = unemployment
) %>%
  reduce(full_join, by = "date")

write_csv(macro_data, "data/macro_data.csv")

view(macro_data)
