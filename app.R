# Load libraries
library(shiny)
library(plotly)
library(DT)
library(dplyr)
library(shinythemes)

# =============== SYNTHETIC DATA GENERATION ===============
set.seed(123)
n <- 365 * 3  # 3 years of daily data
dates <- seq.Date(from = as.Date("2022-01-01"), by = "day", length.out = n)
sp500_close <- cumsum(rnorm(n, mean = 0.2, sd = 5)) + 4000
sp500_return <- c(NA, diff(sp500_close)/head(sp500_close, -1))
gdp_growth <- sin(seq(0, 10, length.out = n)) * 2 + 3 + rnorm(n, 0, 0.3)
unemployment <- runif(n, min = 3.5, max = 7)
inflation <- runif(n, min = 1.5, max = 8)
interest_rate <- runif(n, min = 0.5, max = 6)

data_dash <- data.frame(
  date = dates,
  sp500_close = round(sp500_close, 2),
  sp500_return = round(sp500_return, 4),
  gdp_growth = round(gdp_growth, 2),
  unemployment = round(unemployment, 2),
  inflation = round(inflation, 2),
  interest_rate = round(interest_rate, 2)
)

# =============== DASHBOARD UI ===============
ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML("
      body {
        background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
        color: #212529 !important;
      }
      .panel, .well, .card, .tab-pane, .form-control, .dataTable {
        background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);
        color: #212529 !important;
        border-radius: 12px;
        box-shadow: 0 4px 12px 0 rgba(0,0,0,0.10);
      }
      .sidebarPanel {
        background: linear-gradient(135deg, #fcb69f 0%, #ffecd2 100%);
        color: #212529 !important;
        border-radius: 12px;
      }
      .navbar, .tabbable > .nav > li > a {
        background: linear-gradient(135deg, #a1c4fd 0%, #c2e9fb 100%);
        color: #212529 !important;
      }
      .tabbable > .nav > li.active > a, .tabbable > .nav > li.active > a:focus, .tabbable > .nav > li.active > a:hover {
        background: linear-gradient(135deg, #fcb69f 0%, #ffecd2 100%);
        color: #212529 !important;
      }
      .shiny-output-error { color: #ff0000; }
      h4, h5 {
        color: #532E63;
      }
    "))
  ),
  titlePanel(
    div(icon("chart-line", "fa-2x"), "Stock Market & Macroeconomics Dashboard"),
    windowTitle = "Stock Market Dashboard"
  ),
  sidebarLayout(
    sidebarPanel(
      h4("Filters"),
      dateRangeInput('date_range', 'Select Date Range:',
                     start = min(data_dash$date), end = max(data_dash$date),
                     min = min(data_dash$date), max = max(data_dash$date)),
      selectInput('macro_var', 'Macroeconomic Indicator:',
                  choices = c('GDP Growth' = 'gdp_growth',
                              'Unemployment Rate' = 'unemployment',
                              'Inflation Rate' = 'inflation',
                              'Interest Rate' = 'interest_rate'),
                  selected = 'gdp_growth'),
      br(),
      helpText("Use the controls above to filter the data and explore relationships.")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Overview",
                 fluidRow(
                   column(6,
                          plotlyOutput('sp500_plot', height = "300px")
                   ),
                   column(6,
                          plotlyOutput('macro_plot', height = "300px")
                   )
                 ),
                 br(),
                 fluidRow(
                   column(12,
                          wellPanel(
                            h5("Summary Statistics"),
                            verbatimTextOutput("summary_stats")
                          )
                   )
                 )
        ),
        tabPanel("Correlation",
                 fluidRow(
                   column(8,
                          plotlyOutput('scatter_plot', height = "350px")
                   ),
                   column(4,
                          wellPanel(
                            h5("Correlation Value"),
                            verbatimTextOutput('cor_value')
                          )
                   )
                 )
        ),
        tabPanel("Data Table",
                 DTOutput('data_table')
        ),
        tabPanel("About",
                 wellPanel(
                   h4("Project Overview"),
                   p("This dashboard visualizes the relationship between the S&P 500 index and various macroeconomic indicators such as GDP growth, unemployment, inflation, and interest rates. Use the tabs to explore trends, correlations, and raw data. Designed for academic and project submissions.")
                 )
        )
      )
    )
  )
)

# =============== SERVER LOGIC ===============
server <- function(input, output, session) {
  filtered <- reactive({
    data_dash %>%
      filter(date >= input$date_range[1], date <= input$date_range[2])
  })

  output$sp500_plot <- renderPlotly({
    plot_ly(filtered(), x = ~date, y = ~sp500_close, type = 'scatter', mode = 'lines',
            line = list(color = 'steelblue'), name = 'S&P 500 Close') %>%
      layout(title = "S&P 500 Closing Price", xaxis = list(title = "Date"), yaxis = list(title = "Price"))
  })

  output$macro_plot <- renderPlotly({
    plot_ly(filtered(), x = ~date, y = as.formula(paste0("~", input$macro_var)), type = 'scatter', mode = 'lines',
            line = list(color = 'orange'), name = input$macro_var) %>%
      layout(title = paste(names(which(c('gdp_growth','unemployment','inflation','interest_rate') == input$macro_var)), "over Time"),
             xaxis = list(title = "Date"), yaxis = list(title = input$macro_var))
  })

  output$scatter_plot <- renderPlotly({
    plot_ly(filtered(), x = as.formula(paste0("~", input$macro_var)), y = ~sp500_return, type = 'scatter', mode = 'markers',
            marker = list(color = 'purple', size = 8, opacity = 0.5)) %>%
      layout(title = paste("S&P 500 Return vs", input$macro_var),
             xaxis = list(title = input$macro_var), yaxis = list(title = "S&P 500 Return"))
  })

  output$cor_value <- renderText({
    cor_val <- cor(filtered()[[input$macro_var]], filtered()$sp500_return, use = 'complete.obs')
    paste("Correlation:", round(cor_val, 4))
  })

  output$data_table <- renderDT({
    datatable(filtered(), options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })

  output$summary_stats <- renderPrint({
    data <- filtered()
    stats <- data.frame(
      Variable = c("S&P 500 Close", "S&P 500 Return", "GDP Growth", "Unemployment", "Inflation", "Interest Rate"),
      Mean = sapply(data[, c("sp500_close", "sp500_return", "gdp_growth", "unemployment", "inflation", "interest_rate")], mean, na.rm = TRUE),
      SD = sapply(data[, c("sp500_close", "sp500_return", "gdp_growth", "unemployment", "inflation", "interest_rate")], sd, na.rm = TRUE)
    )
    print(stats, row.names = FALSE)
  })
}

# =============== RUN APP ===============
shinyApp(ui, server)
