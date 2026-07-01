# 📈 Stock Market & Macroeconomics Dashboard (Shiny App)

This R Shiny application visualizes synthetic S&P 500 market data and macroeconomic indicators like GDP growth, unemployment, inflation and interest rates.

---

## How to Run this App

### Step 1: (Recommended) Install RStudio
Download from:  
https://posit.co/download/rstudio-desktop/

### Step 2: Install Required Libraries
Open R or RStudio and run this once:

```r
install.packages(c("shiny", "plotly", "DT", "dplyr", "shinythemes"))


Create a folder anywhere on your system (example: C:/StockDashboard/)
Save the full R code you have into a file named:

app.R


In R or RStudio run:
shiny::runApp()