# ----- Semilla aleatoria para reproducibilidad -----
rm(list = ls())
set.seed(31415)

# ----- Ruta de trabajo -----

# setwd("example_data/analisis_higado_data")

# ----- Carga de paquetes -----

# Instalación de KnowSeq: (es una versión fija de GitHub)
# devtools::install_github("CasedUgr/KnowSeq", ref = "f59cb9e1cb02702697c208cf2c61c45d6e0b7a08", force = TRUE) 
# Si hay problemas del tipo "Error: (converted from warning)" : Sys.setenv(R_REMOTES_NO_ERRORS_FROM_WARNINGS="true")
library(KnowSeq)     # Para trabajar con datos de transcriptómica de GDC Portal
library(dplyr)       # Para select, filter, pipes, ...
library(tictoc)      # Para medir tiempos con tic() y toc() a lo MATLAB 
library(beepr)       # Para avisar con beeps cuando acaba un proceso
library(caret)       # Para machine learning 
library(e1071)       # Para SVM
library(gplots)      # Para heatmaps
library(reshape2)    # Para melt
library(ggalluvial)  # Para diagrama de Sankey

# ----- Preprocesamiento para adecuar ficheros a KnowSeq -----

# Lectura de sample_sheet
samplesInfo <- read.table("gdc_sample_sheet.2020-06-11.tsv", sep = "\t", header = T)

# Se elimina ".counts.gz" de samplesInfo, porque countsToMatrix luego añade la extensión
samplesInfo[,2] <- as.character(samplesInfo[,2])
for(i in 1:nrow(samplesInfo)){
  samplesInfo[i,2] <- substr(samplesInfo[i,2], 1, nchar(samplesInfo[i, 2]) - 10)
}

# Comprobación de importación correcta
head(samplesInfo)

# Definición de parámetros
Run <- samplesInfo$File.Name
Path <- samplesInfo$File.ID
Class <- samplesInfo$Sample.Type

table(Class)

# Los casos que no son "Primary Tumor" o "Solid Tissue Normal" se eliminan de:
#    - El fichero gdc_sample_sheet
#    - El fichero gdc_manifest
#    - La carpeta de gdc_download 
Path[which(Class %in% c("Metastatic", "Recurrent Tumor"))]

# Creación de dataframe
SamplesDataFrame <- data.frame(Run, Path, Class)

# Exportación a CSV de SamplesDataFrame
setwd(dir = "gdc_download/")
write.csv(SamplesDataFrame, file = "03_SamplesDataFrame.csv")

# ----- Unificación de ficheros en formato matriz -----

tic("countsToMatrix") # 85 segundos
countsInformation <- countsToMatrix("03_SamplesDataFrame.csv", extension = "counts")
toc()

# ----- La matriz de cuentas y las etiquetas se guardan -----

countsMatrix <- countsInformation$countsMatrix
labels <- countsInformation$labels

# ----- Se descargan los nombres de los genes ----- 

myAnnotation <- getGenesAnnotation(rownames(countsMatrix))

# En myAnnotation no están todos los genes de countsMatrix, pero si la mayoría
dim(myAnnotation) #24747
dim(countsMatrix) #24983

# Quitamos duplicados
myAnnotation_names <- unique(myAnnotation[,1:2])
dim(myAnnotation_names)

countsMatrix2 <- countsMatrix[rownames(countsMatrix) %in% myAnnotation_names$ensembl_gene_id,]
dim(countsMatrix2)
rownames(countsMatrix2) <- myAnnotation_names$external_gene_name

# Quitar duplicados de nuevo
countsMatrix2 <- countsMatrix2[! duplicated(rownames(countsMatrix2)),]

write.csv2(labels, file = paste0("..\\..\\liver_labels.csv"), row.names = F)
write.csv2(countsMatrix2, file = paste0("..\\..\\liver_countsMatrix.csv"))


# ----- Cálculo de matriz de expresión de genes -----

tic("calculateGeneExpressionValues") # 82 segundos
expressionMatrix <- calculateGeneExpressionValues(countsMatrix, myAnnotation, genesNames = TRUE)
toc()

# Quitar una fila que tiene NA como nombre
table(is.na(rownames(expressionMatrix)))
expressionMatrix <- expressionMatrix[-which(is.na(rownames(expressionMatrix))),]
table(is.na(rownames(expressionMatrix)))

write.csv2(expressionMatrix, file = paste0("..\\..\\liver_expressionMatrix.csv"))

# ----- Sólo 200 genes - Extracción de DEG (Expresión Diferencial de Genes) -----

# Número de genes a seleccionar
number_of_genes <- 200

tic("DEGsExtraction") # 13 segundos
DEGsInformation <- DEGsExtraction(expressionMatrix, as.factor(labels),
                                  # p-valor
                                  #pvalue = 0.001,
                                  number = number_of_genes)
toc()

# Número de genes extraídos
print(nrow(DEGsInformation$DEG_Results$DEGs_Matrix))

topTable <- DEGsInformation$DEG_Results$DEGs_Table
DEGsMatrix <- DEGsInformation$DEG_Results$DEGs_Matrix

#write.csv2(DEGsMatrix, file = paste0("..\\..\\liver_DEGsMatrix_", number_of_genes, "genes.csv"))
#save.image(file = "all_objects.RData")