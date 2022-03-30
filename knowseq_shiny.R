library(shiny)
library(BiocManager)

source("ui.R", encoding = "UTF-8")
source("server.R")

shinyApp(ui = ui, server = server)