
library(httr)
library(jsonlite)

fred_api_key <- "d70e177752ca3ea3cbb7672ff9ec309c"
series_id <- "GDP"  # Example: GDP
url <- paste0("https://api.stlouisfed.org/fred/series/observations?",
              "series_id=", series_id,
              "&api_key=", fred_api_key,
              "&file_type=json")

response <- GET(url)
fred_data <- fromJSON(rawToChar(response$content))


fred_df <- fred_data$observations
fred_gdp <- data.frame(
  date = fred_df$date,
  value = as.numeric(fred_df$value)
)


write.csv(fred_gdp, "fred_gdp_basic.csv", row.names = FALSE)
head(fred_gdp)
