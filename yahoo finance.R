
library(rvest)
library(dplyr)
library(stringr)

url <- "https://finance.yahoo.com/markets/stocks/most-active/"

page <- read_html(url)
table_node <- page %>% html_element("table")

yahoo_data <- table_node %>% html_table()


yahoo_clean <- yahoo_data %>%
  rename(
    Symbol = 1, Name = 2, Price = 3, Change = 4,
    `% Change` = 5, Volume = 6, `Avg Volume` = 7, `Market Cap` = 9
  ) %>%
  mutate(across(c(Price, Change, `% Change`), ~str_replace_all(., ",", "")))


write.csv(yahoo_clean, "yahoo_finance_stocks.csv", row.names = FALSE)
