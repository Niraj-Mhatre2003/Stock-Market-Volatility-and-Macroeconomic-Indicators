
library(rvest)
library(dplyr)

url <- "https://www.google.com/finance/markets/most-active"

page <- read_html(url)

symbols <- page %>% html_nodes(".eYHKkf .COaKTb") %>% html_text(trim = TRUE)
prices <- page %>% html_nodes(".ytSBif .YMlKec") %>% html_text(trim = TRUE)
changes <- page %>% html_nodes(".ghTit .P2Luy") %>% html_text(trim = TRUE)

google_data <- data.frame(Symbol = symbols, Price = prices, Change = changes)


write.csv(google_data, "google_finance_stocks.csv", row.names = FALSE)
