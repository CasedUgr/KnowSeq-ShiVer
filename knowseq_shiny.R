library(shiny)
library(BiocManager)

source('ui.R', local = TRUE)
source('server.R')

options(repos = BiocManager::repositories())
getOption("repos")

shinyApp(ui = ui, server = server)