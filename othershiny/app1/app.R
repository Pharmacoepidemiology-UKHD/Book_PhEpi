library(shiny)
#https://www.r-bloggers.com/2024/03/add-shiny-in-quarto-blog-with-shinylive/

# Define UI for the application
ui <- fluidPage(
  titlePanel("Odds Ratio and Risk Ratio Calculator"),
  
  sidebarLayout(
    sidebarPanel(
      # Dropdown to select OR or RR
      selectInput("measure", "Select Measure:", 
                  choices = list("Odds Ratio (OR)" = "OR", "Risk Ratio (RR)" = "RR")),
      
      # Input for confidence interval level
      numericInput("CI_level", "Confidence Level (%):", value = 95, min = 50, max = 99),
      
      # 2x2 table layout
      h4("2x2 Contingency Table"),
      
      fluidRow(
        column(3, ""),  # Empty space for alignment
        column(3, h5("Disease (Yes)")),
        column(3, h5("Disease (No)"))
      ),
      
      fluidRow(
        column(3, h5("Exposure (Yes)")),
        column(3, numericInput("A_input", "A", value = 20)),
        column(3, numericInput("B_input", "B", value = 80))
      ),
      
      fluidRow(
        column(3, h5("Exposure (No)")),
        column(3, numericInput("C_input", "C", value = 15)),
        column(3, numericInput("D_input", "D", value = 85))
      )
    ),
    
    mainPanel(
      # Output text for the selected measure and custom CI
      textOutput("result")
    )
  )
)

# Define server logic for the application
server <- function(input, output) {
  
  output$result <- renderText({
    # Read input values
    A <- input$A_input
    B <- input$B_input
    C <- input$C_input
    D <- input$D_input
    CI_level <- input$CI_level / 100
    
    z_value <- qnorm(1 - (1 - CI_level) / 2)
    
    # Calculate OR and RR
    OR <- (A * D) / (B * C)
    RR <- (A / (A + B)) / (C / (C + D))
    
    lower_CI_OR <- exp(log(OR) - z_value * sqrt(1/A + 1/B + 1/C + 1/D))
    upper_CI_OR <- exp(log(OR) + z_value * sqrt(1/A + 1/B + 1/C + 1/D))
    
    lower_CI_RR <- exp(log(RR) - z_value * sqrt(1/A - 1/(A + B) + 1/C - 1/(C + D)))
    upper_CI_RR <- exp(log(RR) + z_value * sqrt(1/A - 1/(A + B) + 1/C - 1/(C + D)))
    
    # Select output based on the chosen measure (OR or RR)
    if (input$measure == "OR") {
      paste0("<b>Odds Ratio (OR):</b> ", round(OR, 2), 
             ", ", round(input$CI_level, 0), "% CI: ", 
             round(lower_CI_OR, 2), " - ", round(upper_CI_OR, 2))
    } else {
      paste0("<b>Risk Ratio (RR):</b> ", round(RR, 2), 
             ", ", round(input$CI_level, 0), "% CI: ", 
             round(lower_CI_RR, 2), " - ", round(upper_CI_RR, 2))
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)