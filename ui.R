library(waiter)
library(shinydashboard)
library(DT)

# Define some spinners
spinner_abrir <- tagList(
  spin_folding_cube(),
  span(br(), h4("Loading application..."), style="color:white;")
)

spinner <- tagList(
  spin_chasing_dots(),
  span(br(), h4("Loading..."), style="color:white; display: inline-block;")
)


ui <- dashboardPage(title = "KnowSeq ShiVer", # Title in web browser
                    ## Theme
                    skin = "black",
                    ## Header
                    dashboardHeader(title = span(
                      "KnowSeq ShiVer",
                      style = "font-family: Lucida Console; font-weight: bold"
                    )),
                    ## Sidebar
                    dashboardSidebar(
                      tags$head(
                        tags$link(rel = "stylesheet", type = "text/css", href = "style/style.css")
                      ),
                      
                      sidebarMenu(
                        menuItem("Introduction", tabName = "intro", icon = icon("file-alt")),
                        menuItem("Data loading", tabName = "data", icon = icon("database")),
                        menuItem("Genes selection", tabName = "genes", icon = icon("dna")),
                        menuItem("Model training", tabName = "training", icon = icon("play")),
                        menuItem("Model validation", tabName = "validation", icon = icon("check-circle")),
                        menuItem("Gene Ontologies", tabName = "GO", icon = icon("book-medical")),
                        menuItem("KEGG Pathways", tabName = "kegg", icon = icon("project-diagram")),
                        menuItem("Related diseases", tabName = "diseases", icon = icon("disease")),
                        menuItem("Data visualization", tabName = "dataviz", icon = icon("chart-pie"))
                      )
                    ),
                    ## Body
                    dashboardBody(
                      use_waiter(),
                      # Spinners to show on load, or when the application is busy
                      #waiter_show_on_load(spinner_abrir, color = "#027368"),
                      #waiter_on_busy(spinner, color = "#027368"),
                      tabItems(
                        # Tab 1
                        tabItem(tabName = "intro",
                                
                                h1("KnowSeq Shiver: The Shiny Version of KnowSeq R/Bioc Package"),
                                tags$i("KnowSeq Shiver"), "is the shiny-based web application of the ",
                                tags$a("KnowSeq R/Bioc package", href = "https://github.com/CasedUgr/KnowSeq", target = "_blank"),
                                " that allows users with no previous knowledge of programming to analyze transcriptomics
                                data using all the functionalities available at KnowSeq.",
                                br(),
                                
                                h2("Citation"),
                                tags$article("Castillo-Secilla, D., Gálvez, J. M., Carrillo-Pérez, F., Verona-Almeida, M., Redondo-Sánchez, D., Ortuno, F. M., Herrera, L. J. & Rojas, I. (2021). KnowSeq R-Bioc package: The automatic smart gene expression tool for retrieving relevant biological knowledge. Computers in Biology and Medicine, 133, 104387."),
                                
                                h2("Code"),
                                "The code of this web application is available on ", tags$a("GitHub", href = "https://github.com/CasedUgr/KnowSeq-ShiVer", target="_blank"), ".",
                                
                                
                                h2("Authors"),
                                tags$p(
                                  tags$li("Daniel Castillo. University of Granada."), br(),
                                  tags$li("Juan Manuel Gálvez. University of Granada."), br(),
                                  tags$li("Francisco Carrillo-Pérez. University of Granada."), br(),
                                  tags$li("Marta Verona-Almeida. University of Granada."), br(),
                                  tags$li("Daniel Redondo-Sánchez. ibs.GRANADA, CIBERESP, EASP."), br(),
                                  tags$li("Francisco Manuel Ortuño. Fundación Progreso y Salud (FPS), Hospital Virgen del Rocio, Sevilla."), br(),
                                  tags$li("Luis Javier Herrera. University of Granada."), br(),
                                  tags$li("Ignacio Rojas. University of Granada.")),
                                
                                h2("Contact"),
                                "Daniel Castillo-Secilla (cased at ugr.es) is the main developer of the R package KnowSeq.", br(),
                                "Daniel Redondo-Sánchez (daniel.redondo.easp at juntadeandalucia.es) is the main developer of this Shiny App.", br(),
                                
                                # Images
                                br(), br(), br(),
                                fluidRow(column(4, tags$img(src = "images/ugr.png", height = "120px")),
                                         column(4, br(), br(), tags$img(src = "images/ibs.jpg", height = "40px")),
                                         column(4, tags$img(src = "images/knowseq.png", height = "120px"))),
                        ),
                        
                        # Tab 2
                        tabItem(tabName = "data",
                                
                                # Left column
                                fluidRow(column(6, 
                                                h1("Data loading"),
                                                fileInput(inputId = "file_labels",
                                                          label = span("Select CSV file with labels (see ",
                                                                       tags$a(
                                                                         "here",
                                                                         href = "https://raw.githubusercontent.com/danielredondo/TFM_ciencia_de_datos/master/shiny/datos/higado_200genes_labels.csv",
                                                                         target="_blank"
                                                                       ),
                                                                       "an example)"),
                                                          accept = ".csv",
                                                          width = "100%"
                                                ),
                                                fileInput(inputId = "file_DEGsMatrix",
                                                          label = span("Select CSV file with DEGsMatrix (see ",
                                                                       tags$a(
                                                                         "here",
                                                                         href = "https://github.com/danielredondo/TFM_ciencia_de_datos/raw/master/shiny/datos/higado_200genes_DEGsMatrix.csv",
                                                                         target="_blank"
                                                                       ),
                                                                       "an example)"),
                                                          accept = ".csv",
                                                          width = "100%"
                                                ),
                                                
                                                actionButton(inputId = "boton_importar",
                                                             label = "Import files",
                                                             icon = icon("fas fa-file-import", lib = "font-awesome"),
                                                             width = "100%"),
                                                br(),
                                                
                                                conditionalPanel(condition = "input.boton_importar!=0",
                                                                 
                                                                 h2("Distribution of classes"),
                                                                 
                                                                 tableOutput("tabla1")
                                                                 
                                                )),
                                         # Right column
                                         column(6, br(), br(), br(),
                                                conditionalPanel(condition = "input.boton_importar!=0",
                                                                 h2("Train-test partition"),
                                                                 
                                                                 sliderInput("porcentaje_entrenamiento",
                                                                             label = "Train percentage (%)",
                                                                             value = 75, min = 5, max = 95, step = 5,
                                                                             width = "100%"
                                                                 ),
                                                                 h2("Sankey plot"),
                                                                 plotOutput("sankey", width = "100%")))
                                )
                                
                        ),
                        
                        # Tab 3
                        tabItem(tabName = "genes",
                                h1("Genes selection"),
                                # If data is loaded, you can proceed
                                conditionalPanel(condition = "input.boton_importar!=0",
                                                 
                                  sliderInput(inputId = "numero_genes", label = "Select the number of genes to use", value = 50, min = 1, max = 50, step = 1, width = "50%"),
                                  
                                  textInput(inputId = "disease_da", label = "Disease for DA algorithm", value = "liver cancer", width = "50%"),
                                  
                                  actionButton(inputId = "boton_genes",
                                               label = "Select most relevant genes",
                                               icon = icon("dna", lib = "font-awesome"),
                                               width = "50%"),
                                  br(),
                                  br(),
                                  conditionalPanel(condition = "input.boton_genes!=0",
                                                   
                                                   h3("Table of more relevant genes by feature selection method:"),
                                                   br(),
                                                   fluidRow(
                                                     column(4, h4(tags$b("  MRMR")), tableOutput("genes_mrmr")),
                                                     column(4, h4(tags$b("  RF")), tableOutput("genes_rf")),
                                                     column(4, h4(tags$b("  DA")), tableOutput("genes_da")),
                                                   )
                                )
                                
                        ),
                                # If not, the app tells you to load data 
                                conditionalPanel(condition = "input.boton_importar==0",
                                                 h3("First you need to load data in ''Data loading''", style = "color: #D95032")
                                )
                        ),
                        
                        # Tab 4
                        tabItem(tabName = "training",
                                h1("Model training"),
                                
                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                                 
                                  # Choose classification algorithm
                                  selectInput("cl_algorithm",
                                              label = "Classification algorithm",
                                              choices = c("SVM", "RF", "kNN"),
                                              selected = "kNN",
                                              width = "50%"),
                                  
                                  # Choose feature selection algorithm
                                  selectInput("fs_algorithm",
                                              label = "Feature selection algorithm",
                                              choices = c("mRMR", "RF", "DA"),
                                              selected = "mRMR",
                                              width = "50%"),
                                  
                                  # Choose number of folds
                                  selectInput("number_folds",
                                              label = "Number of folds",
                                              choices = c(3, 5, 10),
                                              selected = 5,
                                              width = "50%"),
                                  
                                  # Train model button
                                  actionButton(inputId = "boton_model_training",
                                               label 
                                               = "Train model",
                                               icon = icon("play", lib = "font-awesome"),
                                               width = "50%"),
                                  
                                  br(),
                                  br(),
                                  
                                  # Show optimal parameters (if the classification method is SVM or kNN)
                                  conditionalPanel(condition = "input.cl_algorithm == 'SVM'",
                                                   br(),
                                                   textOutput("optimal_svm"),
                                                   br()),
                                  conditionalPanel(condition = "input.cl_algorithm == 'RF'",
                                                   br(),
                                                   textOutput("optimal_rf"),
                                                   br()),
                                  conditionalPanel(condition = "input.cl_algorithm == 'kNN'",
                                                   br(),
                                                   textOutput("optimal_knn"),
                                                   br()),
                                  
                                  dataTableOutput("results_cv")
                                ),
                                
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                                 h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                                
                        ),
                        
                        # Tab 5
                        tabItem(tabName = "validation",
                                h1("Model validation"),
                                
                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                  selectInput("cl_algorithm_validation",
                                              label = "Classification algorithm (The algorithm must be trained first to obtain optimal parameters):",
                                              choices = c("SVM", "RF", "kNN"),
                                              selected = "kNN",
                                              width = "50%"),
                                  
                                  selectInput("fs_algorithm_validation",
                                              label = "Feature selection algorithm:",
                                              choices = c("mRMR", "RF", "DA"),
                                              selected = "mRMR",
                                              width = "50%"),
                                  
                                  sliderInput(inputId = "numero_genes_validation", label = "Select the number of genes to use:",
                                              value = 10, min = 1, max = 50, step = 1, width = "50%", ticks = F),
                                  
                                  actionButton(inputId = "boton_model_validation",
                                               label = "Validate model in test",
                                               icon = icon("play", lib = "font-awesome"),
                                               width = "50%"),
                                  
                                  br(),
                                  br(),
                                  
                                  plotOutput("results_validation",
                                             width = "50%")
                                ),
                                
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                                 h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                        ),
                        # Tab 6
                        tabItem(tabName = "GO",
                                h1("Gene Ontologies"),
                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                selectInput("fs_algorithm_go",
                                            label = "Feature selection algorithm",
                                            choices = c("mRMR", "RF", "DA"),
                                            selected = "mRMR",
                                            width = "50%"),
                                sliderInput(inputId = "number_genes_go", label = "Number of genes",
                                            value = 2, min = 1, max = 50, step = 1, width = "50%", ticks = F),
                                textOutput("genes_for_go_text"), br(),
                                textOutput("genes_for_go_list"),
                                 actionButton(inputId = "button_go",
                                              label = "Retrieve gene ontologies information",
                                              icon = icon("dna", lib = "font-awesome"),
                                              width = "50%"),
                                 br(),br(),
                                 dataTableOutput("genes_for_go_datatable")
                                ),
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                                 h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                        ),
                        # Tab 7
                        tabItem(tabName = "kegg",
                                   h1("KEGG Pathways"),
                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                  selectInput("fs_algorithm_kegg",
                                              label = "Feature selection algorithm",
                                              choices = c("mRMR", "RF", "DA"),
                                              selected = "mRMR",
                                              width = "50%"),
                                  sliderInput(inputId = "number_genes_kegg", label = "Number of genes",
                                              value = 2, min = 1, max = 50, step = 1, width = "50%", ticks = F),
                                  textOutput("genes_for_kegg_text"), br(),
                                  textOutput("genes_for_kegg_list"),
                                  actionButton(inputId = "button_kegg",
                                               label = "Retrieve KEGG Pathways information",
                                               icon = icon("dna", lib = "font-awesome"),
                                               width = "50%"),
                                  br(),br(),
                                  dataTableOutput("genes_for_kegg_datatable")
                                ),
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                                 h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                        ),
                        # Tab 8
                        tabItem(tabName = "diseases",
                                   h1("Related diseases"),

                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                       selectInput("fs_algorithm_disease",
                                                   label = "Feature selection algorithm",
                                                   choices = c("mRMR", "RF", "DA"),
                                                   selected = "mRMR",
                                                   width = "50%"),
                                       sliderInput(inputId = "number_genes_disease", label = "Number of genes",
                                                   value = 10, min = 1, max = 50, step = 1, width = "50%", ticks = F),

                                       textOutput("genes_for_disease_text"),
                                       textOutput("genes_for_disease_list"),
                                       
                                       br(),
                                       
                                       # Choose specific gen
                                       selectInput("gen_for_disease",
                                                   label = "Choose the gene to obtain related diseases",
                                                   choices = NULL,
                                                   width = "50%"),
                                       
                                       actionButton(inputId = "button_disease",
                                               label = "Retrieve related diseases",
                                               icon = icon("dna", lib = "font-awesome"),
                                               width = "50%"),
                                   br(),br(),
                                   dataTableOutput("genes_for_disease_datatable")),
                                
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                        h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                          ),
                        # Tab 9
                        tabItem(tabName = "dataviz",
                                h1("Data visualization"),
                                
                                # If the best genes for each feature selection algorithm are already created, you can proceed
                                conditionalPanel(condition = "input.boton_genes!=0",
                                                 selectInput("fs_algorithm_dataviz",
                                                             label = "Feature selection algorithm",
                                                             choices = c("mRMR", "RF", "DA"),
                                                             selected = "mRMR",
                                                             width = "50%"),
                                                 sliderInput(inputId = "number_genes_dataviz", label = "Number of genes",
                                                             value = 10, min = 1, max = 50, step = 1, width = "50%", ticks = F),
                                                 
                                                 textOutput("genes_for_dataviz_text"),
                                                 textOutput("genes_for_dataviz_list"),
                                                 
                                                 br(),
                                                 
                                                 selectInput(inputId = "dataviz_type",
                                                             label = "Choose the type of plot",
                                                             choices = c("heatmap", "boxplot"),
                                                             selected = "heatmap"),
                                                 
                                                 br(),

                                                 actionButton(inputId = "button_dataviz",
                                                              label = "Obtain data visualization",
                                                              icon = icon("chart-pie", lib = "font-awesome"),
                                                              width = "50%"),
                                                 br(),br(),
                                                 
                                                 #fluidRow(column(6, 
                                                 conditionalPanel(condition = "input.dataviz_type == 'boxplot'",
                                                                  plotOutput("dataviz_boxplot1", height = "1300px")),
                                                 #),
                                                 #column(6,
                                                 conditionalPanel(condition = "input.dataviz_type == 'boxplot' && input.number_genes_dataviz > 25",
                                                                  plotOutput("dataviz_boxplot2", height = "1300px")),
                                                 #)),
                                                 conditionalPanel(condition = "input.dataviz_type == 'heatmap'",
                                                                  plotOutput("dataviz_heatmap", height = "800px")),
                                                 br(),
                                                 ),
                                
                                # If not, the app tells you to load data and select the best genes
                                conditionalPanel(condition = "input.boton_genes==0",
                                                 h3("First you need to load data in ''Data loading'' and then select genes in ''Genes selection''", style = "color: #D95032")
                                )
                        )
                      ) # Close tabs
                    ) # Close dashboard body
) # Close dashboard page
