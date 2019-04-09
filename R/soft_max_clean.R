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
      downloadButton("downloadReport", "Generate report"),
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
  
  output$downloadReport <- downloadHandler(
    filename = paste("report-", Sys.Date(), ".csv", sep=""),
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
    
      #params <- list(n = input$slider)
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        #params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
    
}
# Run the app ----
shinyApp(ui, server)