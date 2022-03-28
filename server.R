library(KnowSeq)
library(waiter)
library(dplyr)
library(reshape2)
library(caret)
library(ggplot2)
library(ggalluvial)

# Define some spinners
spinner_abrir <- tagList(
  spin_folding_cube,
  span(br(), h4("Loading application..."), style="color:white;")
)

spinner <- tagList(
  waiter::spin_chasing_dots(),
  span(br(), h4("Loading..."), style="color:white; display: inline-block;")
)


server <- function(input, output){
  
  values <- reactiveValues(ranking = NULL, optimalSVM_train = NULL, optimalkNN_train = NULL)
  
  # Server of tab: Data loading ------
  
  observeEvent(input$boton_importar, {
    
    # If files are selected, they are imported
    # Read labels
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    # Read DEGsMatrix
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_DEGsMatrix$datapath, row.names = 1))
    filas <- rownames(DEGsMatrix)
    DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
    rownames(DEGsMatrix) <- filas
    # Create DEGsMatrixML (for machine learning purposes)
    DEGsMatrixML <- t(DEGsMatrix)
    
    # Train-test partition
    set.seed(31415)
    indices <- reactive(createDataPartition(labels, p = input$porcentaje_entrenamiento / 100, list = FALSE))
    particion <- reactive(list(training = DEGsMatrixML[indices(), ], test = DEGsMatrixML[-indices(), ]))
    
    particion.entrenamiento <- reactive(particion()$training)
    particion.test <- reactive(particion()$test)
    
    # Labels
    labels_train <- reactive(labels[indices()])
    labels_test  <- reactive(labels[-indices()])
    
    # Table
    output$tabla1 <- renderTable({
      if(is.null(input$file_labels)) return(NULL)
      
      # Message if file is correctly imported
      showModal(modalDialog(
        h3(icon("check-circle", lib = "font-awesome", class = "fa-1x"),
           " File imported"),
        easyClose = TRUE,
        footer = NULL
      ))
      
      tabla_aux <- as.data.frame(table(labels)) %>% rename(Label = labels, Samples = Freq)
      return(tabla_aux)
    })
    
    output$sankey <- renderPlot({
      if(is.null(input$file_labels)) return(NULL)
      
      # Train
      #table(labels_train)
      entr_tum <- table(labels_train())[1]
      entr_san <- table(labels_train())[2]
      
      # Test
      #table(labels_test)
      test_tum <- table(labels_test())[1]
      test_san <- table(labels_test())[2]
      
      # Sankey diagram
      datos_sankey <- data.frame(tipo = c(paste0("Tumour\n", entr_tum + test_tum, " cases"), paste0("Tumour\n", entr_tum + test_tum, " cases"),
                                          paste0("Normal tissue\n", entr_san + test_san, " cases"), paste0("Normal tissue\n", entr_san + test_san, " cases")),
                                 traintest = c(paste0("Train\n", entr_tum, " tumour\n", entr_san, " normal tissue"),
                                               paste0("Test\n", test_tum, " tumour\n", test_san, " normal tissue"),
                                               paste0("Train\n", entr_tum, " tumour\n", entr_san, " normal tissue"),
                                               paste0("Test\n", test_tum, " tumour\n", test_san, " normal tissue")),
                                 value = c(entr_tum, test_tum, entr_san, test_san))
      
      # Reordering types
      datos_sankey$tipo <- factor(datos_sankey$tipo,
                                  levels = c(paste0("Tumour\n", entr_tum + test_tum, " cases"), paste0("Normal tissue\n", entr_san + test_san, " cases")),
                                  ordered = T)
      
      ggplot(data = datos_sankey,
             aes(axis1 = tipo, axis2 = traintest, y = value, label = after_stat(stratum))) +
        scale_x_discrete(limits = c("Type of sample", "Train-test"),
                         expand = c(.1, .05)) +
        ylab("") +
        geom_alluvium(col = "black", alpha = 1) +
        geom_alluvium(aes(fill = tipo), alpha = .6, show.legend = FALSE) +
        geom_stratum() +
        geom_text(stat = "stratum", cex = 3) +
        theme_minimal() +
        ggtitle("Train-test partition") +
        theme(plot.title = element_text(hjust = .5),
              axis.text = element_text(color = "black", margin = margin(t = -30), size = 12),
              axis.text.y = element_blank(),
              axis.ticks = element_blank(),
              panel.grid = element_blank()) 
    })
  }) # Close import button
  
  
  # Server of tab: Genes selection ------
  
  w <- Waiter$new(html = span(""))
  
  observeEvent(input$boton_genes, {
    
    w$show()
    
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_DEGsMatrix$datapath, row.names = 1))
    filas <- rownames(DEGsMatrix)
    DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
    rownames(DEGsMatrix) <- filas
    DEGsMatrixML <- t(DEGsMatrix)
    
    set.seed(31415)
    indices <- reactive(createDataPartition(labels, p = input$porcentaje_entrenamiento / 100, list = FALSE))
    particion <- reactive(list(training = DEGsMatrixML[indices(), ], test = DEGsMatrixML[-indices(), ]))
    
    particion.entrenamiento <- reactive(particion()$training)
    particion.test <- reactive(particion()$test)
    
    labels_train <- reactive(labels[indices()])
    labels_test  <- reactive(labels[-indices()])
    w$hide()
    
    # mRMR method
    w <- Waiter$new(html = tagList(spin_folding_cube(),
                                   span(br(), br(), br(), h4("Running mRMR algorithm..."),
                                        style="color:white;")))
    w$show()
    mrmrRanking <- featureSelection(particion.entrenamiento(), labels_train(), colnames(particion.entrenamiento()),
                                    mode = "mrmr")
    mrmrRanking <- names(mrmrRanking)
    w$hide()
    
    # RF method
    w <- Waiter$new(html = tagList(spin_folding_cube(),
                                   span(br(), br(), br(), h4("Running RF algorithm..."),
                                        style="color:white;")))
    w$show()
    rfRanking <- featureSelection(particion.entrenamiento(), labels_train(), colnames(particion.entrenamiento()),
                                  mode = "rf")
    w$hide()
    
    # DA method
    w <- Waiter$new(html = tagList(spin_folding_cube(),
                                   span(br(), br(), br(), h4("Running DA algorithm..."),
                                        style="color:white;")))
    w$show()
    daRanking <- NULL
    
    daRanking <- featureSelection(particion.entrenamiento(), labels_train(), colnames(particion.entrenamiento()),
                                  mode = "da", disease = input$disease_da)
    daRanking <- names(daRanking)
    
    # If there has been any problem in the API call, it's repeated after a 3 second break
    while(is.null(daRanking)){
      Sys.sleep(3)
      daRanking <- featureSelection(particion.entrenamiento(), labels_train(), colnames(particion.entrenamiento()),
                                    mode = "da", disease = input$disease_da)
      daRanking <- names(daRanking)
    }
    
    w$hide()
    
    
    values$ranking <- cbind(mrmrRanking, rfRanking, daRanking)
    
    # Ranking tables
    
    output$genes_mrmr <- renderTable({
      mrmrRanking <- mrmrRanking[1:input$numero_genes]
      return(mrmrRanking)
    }, colnames = FALSE)
    
    output$genes_rf <- renderTable({
      rfRanking <- rfRanking[1:input$numero_genes]
      return(rfRanking)
    }, colnames = FALSE)
    
    output$genes_da <- renderTable({
      daRanking <- daRanking[1:input$numero_genes]
      return(daRanking)
    }, colnames = FALSE)
    
  }) # Close button
  
  # Server of tab: Model training ------
  
  w2 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4(""),
                                       style="color:white;")))  
  
  observeEvent(input$boton_model_training, {
    
    w2$show()
    
    
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_DEGsMatrix$datapath, row.names = 1))
    filas <- rownames(DEGsMatrix)
    DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
    rownames(DEGsMatrix) <- filas
    DEGsMatrixML <- t(DEGsMatrix)
    
    set.seed(31415)
    indices <- reactive(createDataPartition(labels, p = input$porcentaje_entrenamiento / 100, list = FALSE))
    particion <- reactive(list(training = DEGsMatrixML[indices(), ], test = DEGsMatrixML[-indices(), ]))
    
    particion.entrenamiento <- reactive(particion()$training)
    particion.test <- reactive(particion()$test)
    
    labels_train <- reactive(labels[indices()])
    labels_test  <- reactive(labels[-indices()])
    w2$hide()
    
    if(input$fs_algorithm == "mRMR"){
      ranking <- values$ranking[1:input$numero_genes, 1]
    }
    
    if(input$fs_algorithm == "RF"){
      ranking <- values$ranking[1:input$numero_genes, 2]
    }
    
    if(input$fs_algorithm == "DA"){
      ranking <- values$ranking[1:input$numero_genes, 3]
    }
    
    if(input$cl_algorithm == "SVM"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Training SVM algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_cv <- svm_trn(particion.entrenamiento(), labels_train(), ranking,
                            numFold = as.numeric(input$number_folds))
      values$optimalSVM_train <- results_cv$bestParameters
      w3$hide()
    }
    
    if(input$cl_algorithm == "RF"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Training RF algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_cv <- rf_trn(particion.entrenamiento(), labels_train(), ranking,
                           numFold = as.numeric(input$number_folds))
      w3$hide()
    }
    
    if(input$cl_algorithm == "kNN"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Training kNN algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_cv <- knn_trn(particion.entrenamiento(), labels_train(), ranking,
                            numFold = as.numeric(input$number_folds))
      values$optimalkNN_train <- results_cv$bestK
      
      w3$hide()
    }
    
    output$optimal_svm <- renderText(paste0("\nOptimal coefficients for ", input$numero_genes, " genes : cost = ", results_cv$bestParameters[1], "; gamma = ", results_cv$bestParameters[2]))
    
    output$optimal_knn <- renderText(paste0("\nOptimal number of neighbours for ", input$numero_genes, " genes = ", results_cv$bestK))
    
    output$results_cv <- renderDataTable({
      df <- data.frame(`Number of genes` = 1:length(ranking),
                       Accuracy = round(100 * results_cv$accuracyInfo$meanAccuracy, 2),
                       `F1-Score` = round(100 * results_cv$F1Info$meanF1, 2), 
                       Sensitivity = round(100 * results_cv$sensitivityInfo$meanSensitivity, 2),
                       Specificity = round(100 * results_cv$specificityInfo$meanSpecificity, 2),
                       check.names = F)
      dat <- datatable(df, rownames = F, options = list(pageLength = 10)) %>% formatStyle(names(df)[2:5],
                                                                                          background = styleColorBar(range(df[, 2:5]) - c(1, 0), "forestgreen"),
                                                                                          backgroundSize = "98% 88%",
                                                                                          backgroundRepeat = "no-repeat",
                                                                                          backgroundPosition = "center")
      return(dat)}
    )
    
  }) 
  
  
  # Server of tab: Model validation  ------
  
  w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Validating model..."),
                                       style="color:white;")))  
  
  observeEvent(input$boton_model_validation, {
    
    w3$show()
    
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_DEGsMatrix$datapath, row.names = 1))
    filas <- rownames(DEGsMatrix)
    DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
    rownames(DEGsMatrix) <- filas
    DEGsMatrixML <- t(DEGsMatrix)
    
    set.seed(31415)
    indices <- reactive(createDataPartition(labels, p = input$porcentaje_entrenamiento / 100, list = FALSE))
    particion <- reactive(list(training = DEGsMatrixML[indices(), ], test = DEGsMatrixML[-indices(), ]))
    
    particion.entrenamiento <- reactive(particion()$training)
    particion.test <- reactive(particion()$test)
    
    labels_train <- reactive(labels[indices()])
    labels_test  <- reactive(labels[-indices()])
    w3$hide()
    
    if(input$fs_algorithm_validation == "mRMR"){
      ranking <- values$ranking[1:input$numero_genes, 1]
    }
    
    if(input$fs_algorithm_validation == "RF"){
      ranking <- values$ranking[1:input$numero_genes, 2]
    }
    
    if(input$fs_algorithm_validation == "DA"){
      ranking <- values$ranking[1:input$numero_genes, 3]
    }
    
    if(input$cl_algorithm_validation == "SVM"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Validating SVM algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_validation <- svm_test(train = particion.entrenamiento(), labels_train(),
                                     test = particion.test(), labels_test(),
                                     ranking,
                                     bestParameters = values$optimalSVM_train)
      w3$hide()
    }
    
    if(input$cl_algorithm_validation == "RF"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Validating RF algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_validation <- rf_test(train = particion.entrenamiento(), labels_train(),
                                    test = particion.test(), labels_test(),
                                    ranking)
      w3$hide()
    }
    
    if(input$cl_algorithm_validation == "kNN"){
      w3 <- Waiter$new(html = tagList(spin_folding_cube(),
                                      span(br(), br(), br(), h4("Validating kNN algorithm..."),
                                           style="color:white;")))  
      w3$show()
      results_validation <- knn_test(train = particion.entrenamiento(), labels_train(),
                                     test = particion.test(), labels_test(),
                                     ranking, bestK = values$optimalkNN_train)
      w3$hide()
    }
    
    output$results_validation <- renderPlot({
      tabla <- results_validation$cfMats[[input$numero_genes_validation]]$table
      plotConfMatrix(tabla)
    })
    
  })
  
  w4 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving GOs information..."),
                                       style="color:white;")))  
  # Server of tab: Related GOs ------
  output$gene_for_go_table <- renderDataTable(
    {
      w4$show()
      gos <- geneOntologyEnrichment(input$gene_for_disease, geneType = "GENE_SYMBOL")
      dis <- as.data.frame(gos$`All Ontologies GO`[,-15])
      w4$hide()
      
      #names(dis) <- c("Disease", "Overall score", "Literature", "RNA Expr.", "Genetic", "Somatic Mut.", "Drug", "Animal", "Pathways")
      return(dis)}
    , filter = "top", options = list(pageLength = 10)
  )
  
  
  w5 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving KEGG Pathways information..."),
                                       style="color:white;")))  
  # Server of tab: Related diseases ------
  output$gene_for_pathways_table <- renderDataTable(
    {
      w5$show()
      dis <- as.data.frame(DEGsToPathways(input$gene_for_disease))
      w5$hide()

      return(dis)}
    , filter = "top", options = list(pageLength = 10)
  )
  
  w6 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving genes information..."),
                                       style="color:white;")))  
  # Server of tab: Related diseases ------
  output$gene_for_disease_table <- renderDataTable(
    {
      w6$show()
      dis <- as.data.frame(DEGsToDiseases(input$gene_for_disease, size = 10000))
      w6$hide()
    # Round coefficients
    for(i in 2:9){
      dis[, i] <- round(as.numeric(dis[, i]), 2)
    }
    
    names(dis) <- c("Disease", "Overall score", "Literature", "RNA Expr.", "Genetic", "Somatic Mut.", "Drug", "Animal", "Pathways")
    return(dis)}
    , filter = "top", options = list(pageLength = 10)
  )
  
  
}
