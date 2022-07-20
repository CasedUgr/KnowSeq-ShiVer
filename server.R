# 300MB as limit size
options(shiny.maxRequestSize=300*1024^2)


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
  
  values <- reactiveValues(ranking = NULL, optimalSVM_train = NULL, optimalkNN_train = NULL, optimalrf_train = NULL,
                           DEGsMatrix = NULL, DEGs = NULL)
  
  # Server of tab: Data loading ------
  
  observeEvent(input$boton_importar, {
    
    w1 <- Waiter$new(html = tagList(spin_folding_cube(),
                                    span(br(), br(), br(), h4("Calculating gene expression values..."),
                                         style="color:white;")))
    w2 <- Waiter$new(html = tagList(spin_folding_cube(),
                                    span(br(), br(), br(), h4("Extracting DEGs..."),
                                         style="color:white;")))
    
    # If files are selected, they are imported
    # Read labels
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    
    if(input$type_file == "counts_matrix"){
      w1$show()
      countsMatrix <- as.matrix(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
      myAnnotation <- getGenesAnnotation(rownames(countsMatrix), filter="external_gene_name")
      expressionMatrix <- calculateGeneExpressionValues(countsMatrix, myAnnotation, Ensembl_ID = FALSE)
      w1$hide()
      w2$show()
    } else {
      w2$show()
      expressionMatrix <- as.matrix(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
    }
  
    DEGsInformation <- DEGsExtraction(expressionMatrix, as.factor(labels),
                                      # p-valor
                                      pvalue = input$pvalue,
                                      #number = 200
                                      )
    DEGsMatrix <- DEGsInformation$DEG_Results$DEGs_Matrix
    
    # Read DEGsMatrix
    filas <- rownames(DEGsMatrix)
    DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
    rownames(DEGsMatrix) <- filas
    
    # Keep DEGsMatrix in memory
    values$DEGsMatrix <- DEGsMatrix
    values$DEGs       <- colnames(DEGsMatrix)
    
    # Create DEGsMatrixML (for machine learning purposes)
    DEGsMatrixML <- t(DEGsMatrix)
    
    w2$hide()
    
    # Train-test partition
    # set.seed(31415)
    # indices <- reactive(createDataPartition(labels, p = input$porcentaje_entrenamiento / 100, list = FALSE))
    # particion <- reactive(list(training = DEGsMatrixML[indices(), ], test = DEGsMatrixML[-indices(), ]))
    # 
    # particion.entrenamiento <- reactive(particion()$training)
    # particion.test <- reactive(particion()$test)
    # 
    # # Labels
    # labels_train <- reactive(labels[indices()])
    # labels_test  <- reactive(labels[-indices()])
    
    # Table
    output$tabla1 <- renderTable({
      if(is.null(input$file_labels)) return(NULL)
      
      # Message if file is correctly imported
      showModal(modalDialog(
        h3(icon("check-circle", lib = "font-awesome", class = "fa-1x"),
           " Files imported correctly"),
        easyClose = TRUE,
        footer = NULL
      ))
      
      tabla_aux <- as.data.frame(table(labels)) %>% rename(Label = labels, Samples = Freq)
      return(tabla_aux)
    })
    
    output$degs_number <- renderText(paste(nrow(DEGsInformation$DEG_Results$DEGs_Table),
                                           "DEGs were extracted."))
    
    output$degs_datatable <- renderDataTable(
      {
        return(DEGsInformation$DEG_Results$DEGs_Table)}
      , filter = "top", rownames = TRUE, options = list(pageLength = 25)
    )
    
  
    # output$sankey <- renderPlot({
    #   if(is.null(input$file_labels)) return(NULL)
    #   
    #   # Train
    #   #table(labels_train)
    #   entr_tum <- table(labels_train())[1]
    #   entr_san <- table(labels_train())[2]
    #   
    #   # Test
    #   #table(labels_test)
    #   test_tum <- table(labels_test())[1]
    #   test_san <- table(labels_test())[2]
    #   
    #   # Sankey diagram
    #   datos_sankey <- data.frame(tipo = c(paste0("Tumour\n", entr_tum + test_tum, " cases"), paste0("Tumour\n", entr_tum + test_tum, " cases"),
    #                                       paste0("Normal tissue\n", entr_san + test_san, " cases"), paste0("Normal tissue\n", entr_san + test_san, " cases")),
    #                              traintest = c(paste0("Train\n", entr_tum, " tumour\n", entr_san, " normal tissue"),
    #                                            paste0("Test\n", test_tum, " tumour\n", test_san, " normal tissue"),
    #                                            paste0("Train\n", entr_tum, " tumour\n", entr_san, " normal tissue"),
    #                                            paste0("Test\n", test_tum, " tumour\n", test_san, " normal tissue")),
    #                              value = c(entr_tum, test_tum, entr_san, test_san))
    #   
    #   # Reordering types
    #   datos_sankey$tipo <- factor(datos_sankey$tipo,
    #                               levels = c(paste0("Tumour\n", entr_tum + test_tum, " cases"), paste0("Normal tissue\n", entr_san + test_san, " cases")),
    #                               ordered = T)
    #   
    #   ggplot(data = datos_sankey,
    #          aes(axis1 = tipo, axis2 = traintest, y = value, label = after_stat(stratum))) +
    #     scale_x_discrete(limits = c("Type of sample", "Train-test"),
    #                      expand = c(.1, .05)) +
    #     ylab("") +
    #     geom_alluvium(col = "black", alpha = 1) +
    #     geom_alluvium(aes(fill = tipo), alpha = .6, show.legend = FALSE) +
    #     geom_stratum() +
    #     geom_text(stat = "stratum", cex = 3) +
    #     theme_minimal() +
    #     ggtitle("Train-test partition") +
    #     theme(plot.title = element_text(hjust = .5),
    #           axis.text = element_text(color = "black", margin = margin(t = -30), size = 12),
    #           axis.text.y = element_blank(),
    #           axis.ticks = element_blank(),
    #           panel.grid = element_blank()) 
    # })
  }) # Close import button
  
  
  # Server of tab: Genes selection ------
  
  w <- Waiter$new(html = span(""))
  
  observeEvent(input$boton_genes, {
    
    w$show()
    
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
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
                                        br(), h4("Please be patient, this can take a while..."),
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
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
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
                                           br(), h4("Please be patient, this can take a while..."),
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
                                           br(), h4("Please be patient, this can take a while..."),
                                           style="color:white;")))  
      w3$show()
      results_cv <- rf_trn(particion.entrenamiento(), labels_train(), ranking,
                           numFold = as.numeric(input$number_folds))
      values$optimalrf_train <- results_cv$bestParameters
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
    
    output$optimal_rf <- renderText(paste0("\nOptimal mtry for ", input$numero_genes, " genes = ", results_cv$bestParameters))
    
    output$optimal_knn <- renderText(paste0("\nOptimal number of neighbours for ", input$numero_genes, " genes = ", results_cv$bestK))
    
    output$results_cv <- renderDataTable({
      df <- data.frame(`Number of genes` = 1:length(ranking),
                       Accuracy = round(100 * results_cv$accuracyInfo$meanAccuracy, 2),
                       `F1-Score` = round(100 * results_cv$F1Info$meanF1, 2), 
                       Sensitivity = round(100 * results_cv$sensitivityInfo$meanSensitivity, 2),
                       Specificity = round(100 * results_cv$specificityInfo$meanSpecificity, 2),
                       check.names = F)
      dat <- datatable(df, rownames = F, options = list(pageLength = 10, searching = FALSE)) %>% formatStyle(names(df)[2:5],
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
    
    output$results_validation <- renderPlot({
      
    w3$show()
    
    labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
    DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
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
      ranking <- values$ranking[1:input$numero_genes_validation, 1]
    }
    
    if(input$fs_algorithm_validation == "RF"){
      ranking <- values$ranking[1:input$numero_genes_validation, 2]
    }
    
    if(input$fs_algorithm_validation == "DA"){
      ranking <- values$ranking[1:input$numero_genes_validation, 3]
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
                                    ranking, bestParameters = values$optimalrf_train)
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
    
      tabla <- results_validation$cfMats[[input$numero_genes_validation]]$table
      plotConfMatrix(tabla)
    })
    
  })
  

  # Server of tab: Related GOs ------
  
    w4 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving GOs information..."),
                                       br(), h4("Please be patient, this can take a while..."),
                                       style="color:white;")))  
  
  output$genes_for_go_text <- renderText({
    return(paste0("For the ", input$fs_algorithm_go, " feature selection algorithm, ",
                  "the best ", input$number_genes_go, " genes are:"))
  })
  
  output$genes_for_go_list <- renderText({
    if(input$fs_algorithm_go == "mRMR"){
      ranking <- values$ranking[1:input$number_genes_go, 1]
    }
    
    if(input$fs_algorithm_go == "RF"){
      ranking <- values$ranking[1:input$number_genes_go, 2]
    }
    
    if(input$fs_algorithm_go == "DA"){
      ranking <- values$ranking[1:input$number_genes_go, 3]
    }
    return(ranking)
  })  
  
  
  observeEvent(input$button_go, {
    
    output$genes_for_go_datatable <- renderDataTable(
      {
        
        w4$show()
        if(input$fs_algorithm_go == "mRMR"){
          ranking <- values$ranking[1:input$number_genes_go, 1]
        }
        
        if(input$fs_algorithm_go == "RF"){
          ranking <- values$ranking[1:input$number_genes_go, 2]
        }
        
        if(input$fs_algorithm_go == "DA"){
          ranking <- values$ranking[1:input$number_genes_go, 3]
        }
        
        gos <- geneOntologyEnrichment(ranking, geneType = "GENE_SYMBOL")
        
        gos <- as.data.frame(gos$`All Ontologies GO`[,c(1,2,14,15)])
        
        w4$hide()
        
        return(gos)}
      , filter = "top", rownames = FALSE, options = list(pageLength = 10)
    )
    
  })
  


  # Server of tab: KEGG ------
  
    w5 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving KEGG Pathways information..."),
                                       br(), h4("Please be patient, this can take a while..."),
                                       style="color:white;")))  
  
  output$genes_for_kegg_text <- renderText({
    return(paste0("For the ", input$fs_algorithm_kegg, " feature selection algorithm, ",
                  "the best ", input$number_genes_kegg, " genes are:"))
  })
  
  output$genes_for_kegg_list <- renderText({
    if(input$fs_algorithm_kegg == "mRMR"){
      ranking <- values$ranking[1:input$number_genes_kegg, 1]
    }
    
    if(input$fs_algorithm_kegg == "RF"){
      ranking <- values$ranking[1:input$number_genes_kegg, 2]
    }
    
    if(input$fs_algorithm_kegg == "DA"){
      ranking <- values$ranking[1:input$number_genes_kegg, 3]
    }
    return(ranking)
  })  
  
  
  observeEvent(input$button_kegg, {
    
    output$genes_for_kegg_datatable <- renderDataTable(
      {
        
        w5$show()
        if(input$fs_algorithm_kegg == "mRMR"){
          ranking <- values$ranking[1:input$number_genes_kegg, 1]
        }
        
        if(input$fs_algorithm_kegg == "RF"){
          ranking <- values$ranking[1:input$number_genes_kegg, 2]
        }
        
        if(input$fs_algorithm_kegg == "DA"){
          ranking <- values$ranking[1:input$number_genes_kegg, 3]
        }
        
        kegg <- as.data.frame(DEGsToPathways(ranking))
        
        w5$hide()
        
        
        return(kegg)}
      , filter = "top", rownames = FALSE, options = list(pageLength = 10)
    )
    
  })
  
  # Server of tab: Related diseases ------
  
    w6 <- Waiter$new(html = tagList(spin_folding_cube(),
                                  span(br(), br(), br(), h4("Retrieving genes information..."),
                                       style="color:white;")))  
  
  output$genes_for_disease_text <- renderText({
    return(paste0("For the ", input$fs_algorithm_disease, " feature selection algorithm, ",
            "the best ", input$number_genes_disease, " genes are:"))
    })
  
  output$genes_for_disease_list <- renderText({
    if(input$fs_algorithm_disease == "mRMR"){
      ranking <- values$ranking[1:input$number_genes_disease, 1]
    }
    
    if(input$fs_algorithm_disease == "RF"){
      ranking <- values$ranking[1:input$number_genes_disease, 2]
    }
    
    if(input$fs_algorithm_disease == "DA"){
      ranking <- values$ranking[1:input$number_genes_disease, 3]
    }
    return(ranking)
  })  
  
  # Update selectInput according to the specific gen selected
  possible_genes <- reactive({
    if(input$fs_algorithm_disease == "mRMR"){
      ranking <- values$ranking[1:input$number_genes_disease, 1]
    }
    
    if(input$fs_algorithm_disease == "RF"){
      ranking <- values$ranking[1:input$number_genes_disease, 2]
    }
    
    if(input$fs_algorithm_disease == "DA"){
      ranking <- values$ranking[1:input$number_genes_disease, 3]
    }
    return(ranking)
  })
  observeEvent(possible_genes(), {
    updateSelectInput(inputId = "gen_for_disease", choices = possible_genes())
  })
  
  
  
   observeEvent(input$button_disease, {
         
    w6$show()
    
    output$genes_for_disease_datatable <- renderDataTable(
      {
        dis_list <- DEGsToDiseases(input$gen_for_disease, size = 10000)
        if(length(dis_list) != 0) dis <- cbind(input$gen_for_disease, dis_list[[1]]$summary)
        else dis <- t(c(input$gen_for_disease, "None", rep(NA, 8)))
        dis <- as.data.frame(dis)
        
        w6$hide()
        # Round coefficients
        for(i in 3:10){
          dis[, i] <- round(as.numeric(dis[, i]), 2)
        }
        
        names(dis) <- c("Gen", "Disease", "Overall score", "Literature", "RNA Expr.", "Genetic", "Somatic Mut.", "Drug", "Animal", "Pathways")
        return(dis[, -1])}
      , filter = "top", rownames = FALSE, options = list(pageLength = 10)
    )
    
  })

   # Server of tab: data visualization ------
   
   w7 <- Waiter$new(html = tagList(spin_folding_cube(),
                                   span(br(), br(), br(), h4("Creating graph(s)..."),
                                        style="color:white;")))  
   
   output$genes_for_dataviz_text <- renderText({
     return(paste0("For the ", input$fs_algorithm_dataviz, " feature selection algorithm, ",
                   "the best ", input$number_genes_dataviz, " genes are:"))
   })
   
   output$genes_for_dataviz_list <- renderText({
     if(input$fs_algorithm_dataviz == "mRMR"){
       ranking <- values$ranking[1:input$number_genes_dataviz, 1]
     }
     
     if(input$fs_algorithm_dataviz == "RF"){
       ranking <- values$ranking[1:input$number_genes_dataviz, 2]
     }
     
     if(input$fs_algorithm_dataviz == "DA"){
       ranking <- values$ranking[1:input$number_genes_dataviz, 3]
     }
     return(ranking)
   })  
   
   
   observeEvent(input$button_dataviz, {
     
     output$dataviz_heatmap <- renderPlot(
       {
         
         w7$show()
         
         # Load data
         labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
         DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
         filas <- rownames(DEGsMatrix)
         DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
         rownames(DEGsMatrix) <- filas
         
         if(input$fs_algorithm_dataviz == "mRMR"){
           ranking <- values$ranking[1:input$number_genes_dataviz, 1]
         }
         
         if(input$fs_algorithm_dataviz == "RF"){
           ranking <- values$ranking[1:input$number_genes_dataviz, 2]
         }
         
         if(input$fs_algorithm_dataviz == "DA"){
           ranking <- values$ranking[1:input$number_genes_dataviz, 3]
         }
         
         dataviz <- dataPlot(DEGsMatrix[as.vector(t(ranking)), ], labels, mode = "heatmap")
         
         w7$hide()
         
         
         return(dataviz)}
     )
     
     output$dataviz_boxplot1 <- renderPlot(
       {
         w7$show()
         
         # Load data
         labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
         DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
         filas <- rownames(DEGsMatrix)
         DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
         rownames(DEGsMatrix) <- filas

         if(input$fs_algorithm_dataviz == "mRMR"){
           ranking <- values$ranking[1:min(input$number_genes_dataviz, 25), 1]
         }
         
         if(input$fs_algorithm_dataviz == "RF"){
           ranking <- values$ranking[1:min(input$number_genes_dataviz, 25), 2]
         }
         
         if(input$fs_algorithm_dataviz == "DA"){
           ranking <- values$ranking[1:min(input$number_genes_dataviz, 25), 3]
         }
         
         dataviz <- dataPlot(DEGsMatrix[as.vector(t(ranking)), ], labels, mode = "genesBoxplot")
         
         w7$hide()
         
         return(dataviz)}
     )
  
   output$dataviz_boxplot2 <- renderPlot(
     {
       w7$show()
       
       # Load data
       labels <- as.vector(t(read.csv2(file = input$file_labels$datapath)))
       DEGsMatrix <- as.data.frame(read.csv2(file = input$file_Matrix$datapath, row.names = 1))
       filas <- rownames(DEGsMatrix)
       DEGsMatrix <- apply(DEGsMatrix, 2, as.numeric)
       rownames(DEGsMatrix) <- filas
       
       if(input$fs_algorithm_dataviz == "mRMR"){
         ranking <- values$ranking[26:input$number_genes_dataviz, 1]
       }
       
       if(input$fs_algorithm_dataviz == "RF"){
         ranking <- values$ranking[26:input$number_genes_dataviz, 2]
       }
       
       if(input$fs_algorithm_dataviz == "DA"){
         ranking <- values$ranking[26:input$number_genes_dataviz, 3]
       }
       
       dataviz <- dataPlot(DEGsMatrix[as.vector(t(ranking)), ], labels, mode = "genesBoxplot")
       
       w7$hide()
       
       return(dataviz)}
   )
   
})
   
   
   # Update maximum value for enrichment and dataviz sections
   max_genes <- reactive({
     input$numero_genes
   })
   observeEvent(max_genes(), {
     updateSliderInput(inputId = "number_genes_dataviz", max = max_genes())
     updateSliderInput(inputId = "number_genes_go", max = max_genes())
     updateSliderInput(inputId = "number_genes_kegg", max = max_genes())
     updateSliderInput(inputId = "number_genes_disease", max = max_genes())
     updateSliderInput(inputId = "numero_genes_validation", max = max_genes())
   })
  
  
}
