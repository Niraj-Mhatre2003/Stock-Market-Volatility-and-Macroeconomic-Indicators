
library(httr)
library(jsonlite)

country <- "US"
indicator <- "NY.GDP.MKTP.CD"
url <- paste0("http://api.worldbank.org/v2/country/", country,
              "/indicator/", indicator,
              "?format=json&per_page=100")

response <- GET(url)
wb_data <- fromJSON(rawToChar(response$content))


wb_df <- wb_data[[2]]
worldbank_gdp <- data.frame(
  year = wb_df$date,
  value = as.numeric(wb_df$value)
)

write.csv(worldbank_gdp, "worldbank_gdp_basic.csv", row.names = FALSE)
head(worldbank_gdp)
