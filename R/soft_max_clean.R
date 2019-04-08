library(shiny)
library(BKA.PREEMPT)
library(tidyverse)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Uploading Files"),
  #d
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a file ----
      fileInput("uploadFile", "Choose .XSLX File",
                multiple = FALSE,
                accept = c(".xlsx")),
      downloadButton("downloadData","Download"),
      
      # Horizontal line ----
      tags$hr()
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      # Output: Data file ----
      tableOutput("contents")
    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output) {
  Mydata <- reactive({
    inFile <- input$uploadFile
    if (is.null(inFile$datapath)) return(NULL)
    data <- BKA.PREEMPT::soft.max.clean(file_path= inFile$datapath, row_start_of_data =0, num_of_time_points=9)
    #data <- readxl::read_excel(inFile$datapath, sheet =  1)
    return(data)
  })
  

  output$downloadData <- downloadHandler(
    filename = function() { 
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(Mydata(), file)
    })
}
# Run the app ----
shinyApp(ui, server)