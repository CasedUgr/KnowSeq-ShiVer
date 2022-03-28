## KnowSeq Shiver: The Shiny Version of KnowSeq R/Bioc Package

*KnowSeq Shiver* is the shiny-based web application of the [KnowSeq
R/Bioc package](https://github.com/CasedUgr/KnowSeq) that allows users
with no previous knowledge of programming to analyze transcriptomics
data using all the functionalities available at KnowSeq.

*KnowSeq Shiver* is currently available at
<https://knowseqshiver.shinyapps.io/KnowSeq_ShiVer/>

## Citation

    Castillo-Secilla, D., Gálvez, J. M., Carrillo-Pérez, F., Verona-Almeida, M., Redondo-Sánchez, D., Ortuno, F. M., Herrera, L. J. & Rojas, I. (2021). KnowSeq R-Bioc package: The automatic smart gene expression tool for retrieving relevant biological knowledge. Computers in Biology and Medicine, 133, 104387.

## Authors

Daniel Castillo. University of Granada.

Juan Manuel Gálvez. University of Granada.

Francisco Carrillo-Pérez. University of Granada.

Marta Verona-Almeida. University of Granada.

Daniel Redondo-Sánchez. Granada Cancer Registry, ibs.GRANADA.

Francisco Manuel Ortuño. Fundación Progreso y Salud (FPS), Hospital
Virgen del Rocio, Sevilla.

Luis Javier Herrera. University of Granada.

Ignacio Rojas. University of Granada.

## Contact

Daniel Castillo-Secilla (cased at ugr.es) is the main developer of the R
package KnowSeq.

Daniel Redondo-Sánchez (daniel.redondo.easp at juntadeandalucia.es) is
the main developer of this Shiny App.

## Session info

``` r
library(devtools)
devtools::session_info()
```

    ## - Session info ---------------------------------------------------------------
    ##  setting  value
    ##  version  R version 4.1.0 (2021-05-18)
    ##  os       Windows 10 x64 (build 19043)
    ##  system   x86_64, mingw32
    ##  ui       RTerm
    ##  language (EN)
    ##  collate  Spanish_Spain.1252
    ##  ctype    Spanish_Spain.1252
    ##  tz       Europe/Paris
    ##  date     2022-03-28
    ##  pandoc   2.17.1.1 @ C:/Program Files/RStudio/bin/quarto/bin/ (via rmarkdown)
    ## 
    ## - Packages -------------------------------------------------------------------
    ##  package          * version    date (UTC) lib source
    ##  annotate           1.72.0     2021-10-26 [1] Bioconductor
    ##  AnnotationDbi      1.56.2     2021-11-09 [1] Bioconductor
    ##  assertthat         0.2.1      2019-03-21 [2] CRAN (R 4.1.0)
    ##  backports          1.4.1      2021-12-13 [2] CRAN (R 4.1.2)
    ##  base64enc          0.1-3      2015-07-28 [2] CRAN (R 4.1.0)
    ##  Biobase            2.54.0     2021-10-26 [1] Bioconductor
    ##  BiocGenerics       0.40.0     2021-10-26 [1] Bioconductor
    ##  BiocManager      * 1.30.16    2021-06-15 [1] CRAN (R 4.1.3)
    ##  BiocParallel       1.28.3     2021-12-09 [1] Bioconductor
    ##  Biostrings         2.62.0     2021-10-26 [1] Bioconductor
    ##  bit                4.0.4      2020-08-04 [2] CRAN (R 4.0.2)
    ##  bit64              4.0.5      2020-08-30 [2] CRAN (R 4.0.2)
    ##  bitops             1.0-7      2021-04-24 [2] CRAN (R 4.0.5)
    ##  blob               1.2.2      2021-07-23 [2] CRAN (R 4.1.0)
    ##  brio               1.1.3      2021-11-30 [2] CRAN (R 4.1.2)
    ##  cachem             1.0.6      2021-08-19 [2] CRAN (R 4.1.1)
    ##  callr              3.7.0      2021-04-20 [2] CRAN (R 4.0.5)
    ##  caret            * 6.0-91     2022-03-11 [2] CRAN (R 4.1.3)
    ##  checkmate          2.0.0      2020-02-06 [2] CRAN (R 4.0.2)
    ##  class              7.3-20     2022-01-13 [2] CRAN (R 4.1.2)
    ##  cli                3.1.1      2022-01-20 [1] CRAN (R 4.1.2)
    ##  cluster            2.1.2      2021-04-17 [1] CRAN (R 4.1.3)
    ##  codetools          0.2-18     2020-11-04 [2] CRAN (R 4.1.0)
    ##  colorspace         2.0-3      2022-02-21 [2] CRAN (R 4.1.2)
    ##  cqn              * 1.40.0     2021-10-26 [2] Bioconductor
    ##  crayon             1.5.1      2022-03-26 [1] CRAN (R 4.1.0)
    ##  data.table         1.14.2     2021-09-27 [1] CRAN (R 4.1.1)
    ##  DBI                1.1.2      2021-12-20 [2] CRAN (R 4.1.2)
    ##  desc               1.4.1      2022-03-06 [2] CRAN (R 4.1.0)
    ##  devtools         * 2.4.3      2021-11-30 [1] CRAN (R 4.1.3)
    ##  digest             0.6.29     2021-12-01 [2] CRAN (R 4.1.2)
    ##  dplyr            * 1.0.8      2022-02-08 [2] CRAN (R 4.1.2)
    ##  DT               * 0.21       2022-02-26 [2] CRAN (R 4.1.2)
    ##  e1071              1.7-9      2021-09-16 [2] CRAN (R 4.1.0)
    ##  edgeR              3.36.0     2021-10-26 [1] Bioconductor
    ##  ellipsis           0.3.2      2021-04-29 [2] CRAN (R 4.0.5)
    ##  evaluate           0.15       2022-02-18 [2] CRAN (R 4.1.2)
    ##  fansi              1.0.2      2022-01-14 [1] CRAN (R 4.1.3)
    ##  fastmap            1.1.0      2021-01-25 [2] CRAN (R 4.0.2)
    ##  foreach            1.5.2      2022-02-02 [2] CRAN (R 4.1.2)
    ##  foreign            0.8-82     2022-01-13 [2] CRAN (R 4.1.2)
    ##  Formula            1.2-4      2020-10-16 [2] CRAN (R 4.0.2)
    ##  fs                 1.5.2      2021-12-08 [2] CRAN (R 4.1.2)
    ##  future             1.24.0     2022-02-19 [2] CRAN (R 4.1.2)
    ##  future.apply       1.8.1      2021-08-10 [2] CRAN (R 4.1.1)
    ##  genefilter         1.76.0     2021-10-26 [1] Bioconductor
    ##  generics           0.1.2      2022-01-31 [2] CRAN (R 4.1.2)
    ##  GenomeInfoDb       1.30.1     2022-01-30 [1] Bioconductor
    ##  GenomeInfoDbData   1.2.7      2022-03-28 [1] Bioconductor
    ##  ggalluvial       * 0.12.3     2020-12-05 [2] CRAN (R 4.0.3)
    ##  ggplot2          * 3.3.5      2021-06-25 [2] CRAN (R 4.1.0)
    ##  globals            0.14.0     2020-11-22 [2] CRAN (R 4.1.0)
    ##  glue               1.6.2      2022-02-24 [1] CRAN (R 4.1.2)
    ##  gower              1.0.0      2022-02-03 [2] CRAN (R 4.1.2)
    ##  gridExtra          2.3        2017-09-09 [2] CRAN (R 4.0.2)
    ##  gtable             0.3.0      2019-03-25 [2] CRAN (R 4.0.2)
    ##  hardhat            0.2.0      2022-01-24 [2] CRAN (R 4.1.2)
    ##  Hmisc              4.6-0      2021-10-07 [2] CRAN (R 4.1.1)
    ##  htmlTable          2.4.0      2022-01-04 [2] CRAN (R 4.1.2)
    ##  htmltools          0.5.2      2021-08-25 [1] CRAN (R 4.1.1)
    ##  htmlwidgets        1.5.4      2021-09-08 [2] CRAN (R 4.1.1)
    ##  httpuv             1.6.5      2022-01-05 [1] CRAN (R 4.1.2)
    ##  httr               1.4.2      2020-07-20 [2] CRAN (R 4.0.2)
    ##  ipred              0.9-12     2021-09-15 [2] CRAN (R 4.1.1)
    ##  IRanges            2.28.0     2021-10-26 [1] Bioconductor
    ##  iterators          1.0.14     2022-02-05 [2] CRAN (R 4.1.2)
    ##  jpeg               0.1-9      2021-07-24 [2] CRAN (R 4.1.0)
    ##  jsonlite           1.8.0      2022-02-22 [2] CRAN (R 4.1.2)
    ##  KEGGREST           1.34.0     2021-10-26 [1] Bioconductor
    ##  kernlab            0.9-29     2019-11-12 [2] CRAN (R 4.0.0)
    ##  knitr              1.38       2022-03-25 [1] CRAN (R 4.1.0)
    ##  KnowSeq          * 1.8.0      2021-10-26 [1] Bioconductor
    ##  later              1.3.0      2021-08-18 [1] CRAN (R 4.1.1)
    ##  lattice          * 0.20-45    2021-09-22 [2] CRAN (R 4.1.1)
    ##  latticeExtra       0.6-29     2019-12-19 [2] CRAN (R 4.0.2)
    ##  lava               1.6.10     2021-09-02 [2] CRAN (R 4.1.1)
    ##  lifecycle          1.0.1      2021-09-24 [2] CRAN (R 4.1.0)
    ##  limma              3.50.1     2022-02-17 [1] Bioconductor
    ##  listenv            0.8.0      2019-12-05 [2] CRAN (R 4.1.1)
    ##  locfit             1.5-9.5    2022-03-03 [2] CRAN (R 4.1.2)
    ##  lubridate          1.8.0      2021-10-07 [1] CRAN (R 4.1.2)
    ##  magrittr           2.0.2      2022-01-26 [2] CRAN (R 4.1.2)
    ##  MASS               7.3-56     2022-03-23 [1] CRAN (R 4.1.3)
    ##  Matrix             1.4-1      2022-03-23 [1] CRAN (R 4.1.3)
    ##  MatrixModels       0.5-0      2021-03-02 [2] CRAN (R 4.0.2)
    ##  matrixStats        0.61.0     2021-09-17 [2] CRAN (R 4.1.1)
    ##  mclust           * 5.4.9      2021-12-17 [2] CRAN (R 4.1.2)
    ##  memoise            2.0.1      2021-11-26 [2] CRAN (R 4.1.2)
    ##  mgcv               1.8-39     2022-02-24 [2] CRAN (R 4.1.2)
    ##  mime               0.12       2021-09-28 [2] CRAN (R 4.1.0)
    ##  ModelMetrics       1.2.2.2    2020-03-17 [2] CRAN (R 4.0.2)
    ##  munsell            0.5.0      2018-06-12 [2] CRAN (R 4.0.2)
    ##  nlme               3.1-155    2022-01-13 [1] CRAN (R 4.1.3)
    ##  nnet               7.3-17     2022-01-13 [2] CRAN (R 4.1.2)
    ##  nor1mix          * 1.3-0      2019-06-13 [2] CRAN (R 4.0.2)
    ##  parallelly         1.30.0     2021-12-17 [2] CRAN (R 4.1.2)
    ##  pillar             1.7.0      2022-02-01 [2] CRAN (R 4.1.2)
    ##  pkgbuild           1.3.1      2021-12-20 [2] CRAN (R 4.1.2)
    ##  pkgconfig          2.0.3      2019-09-22 [2] CRAN (R 4.0.2)
    ##  pkgload            1.2.4      2021-11-30 [2] CRAN (R 4.1.2)
    ##  plyr               1.8.6      2020-03-03 [1] CRAN (R 4.1.3)
    ##  png                0.1-7      2013-12-03 [2] CRAN (R 4.0.0)
    ##  praznik            10.0.0     2021-11-09 [2] CRAN (R 4.1.2)
    ##  preprocessCore   * 1.56.0     2021-10-26 [2] Bioconductor
    ##  prettyunits        1.1.1      2020-01-24 [2] CRAN (R 4.0.2)
    ##  pROC               1.18.0     2021-09-03 [2] CRAN (R 4.1.1)
    ##  processx           3.5.2      2021-04-30 [1] CRAN (R 4.1.3)
    ##  prodlim            2019.11.13 2019-11-17 [2] CRAN (R 4.0.2)
    ##  promises           1.2.0.1    2021-02-11 [2] CRAN (R 4.0.3)
    ##  proxy              0.4-26     2021-06-07 [2] CRAN (R 4.0.5)
    ##  ps                 1.6.0      2021-02-28 [2] CRAN (R 4.0.4)
    ##  purrr              0.3.4      2020-04-17 [2] CRAN (R 4.0.2)
    ##  quantreg         * 5.88       2022-02-05 [2] CRAN (R 4.1.2)
    ##  R.methodsS3        1.8.1      2020-08-26 [2] CRAN (R 4.0.2)
    ##  R.oo               1.24.0     2020-08-26 [2] CRAN (R 4.0.2)
    ##  R.utils            2.11.0     2021-09-26 [2] CRAN (R 4.1.0)
    ##  R6                 2.5.1      2021-08-19 [2] CRAN (R 4.1.0)
    ##  randomForest       4.7-1      2022-02-03 [2] CRAN (R 4.1.2)
    ##  RColorBrewer       1.1-2      2014-12-07 [2] CRAN (R 4.0.0)
    ##  Rcpp               1.0.8      2022-01-13 [1] CRAN (R 4.1.3)
    ##  RCurl              1.98-1.6   2022-02-08 [2] CRAN (R 4.1.2)
    ##  recipes            0.2.0      2022-02-18 [2] CRAN (R 4.1.2)
    ##  remotes            2.4.2      2021-11-30 [2] CRAN (R 4.1.2)
    ##  reshape2         * 1.4.4      2020-04-09 [2] CRAN (R 4.0.2)
    ##  rlang              1.0.2      2022-03-04 [1] CRAN (R 4.1.2)
    ##  rlist              0.4.6.2    2021-09-03 [2] CRAN (R 4.1.0)
    ##  rmarkdown          2.13       2022-03-10 [1] CRAN (R 4.1.3)
    ##  rpart              4.1.16     2022-01-24 [2] CRAN (R 4.1.2)
    ##  rprojroot          2.0.2      2020-11-15 [2] CRAN (R 4.0.3)
    ##  RSQLite            2.2.11     2022-03-23 [1] CRAN (R 4.1.3)
    ##  rstudioapi         0.13       2020-11-12 [2] CRAN (R 4.0.3)
    ##  S4Vectors          0.32.3     2021-11-21 [1] Bioconductor
    ##  scales             1.1.1      2020-05-11 [2] CRAN (R 4.0.2)
    ##  sessioninfo        1.2.2      2021-12-06 [2] CRAN (R 4.1.2)
    ##  shiny            * 1.7.1      2021-10-02 [2] CRAN (R 4.1.0)
    ##  shinydashboard   * 0.7.2      2021-09-30 [2] CRAN (R 4.1.0)
    ##  SparseM          * 1.81       2021-02-18 [2] CRAN (R 4.0.4)
    ##  stringi            1.7.6      2021-11-29 [1] CRAN (R 4.1.2)
    ##  stringr            1.4.0      2019-02-10 [2] CRAN (R 4.0.2)
    ##  survival           3.3-1      2022-03-03 [2] CRAN (R 4.1.3)
    ##  sva                3.42.0     2021-10-26 [1] Bioconductor
    ##  testthat           3.1.2      2022-01-20 [2] CRAN (R 4.1.2)
    ##  tibble             3.1.6      2021-11-07 [2] CRAN (R 4.1.2)
    ##  tidyselect         1.1.2      2022-02-21 [2] CRAN (R 4.1.2)
    ##  timeDate           3043.102   2018-02-21 [2] CRAN (R 4.0.0)
    ##  usethis          * 2.1.5      2021-12-09 [2] CRAN (R 4.1.0)
    ##  utf8               1.2.2      2021-07-24 [2] CRAN (R 4.1.0)
    ##  vctrs              0.3.8      2021-04-29 [2] CRAN (R 4.0.5)
    ##  waiter           * 0.2.5      2022-01-03 [2] CRAN (R 4.1.2)
    ##  withr              2.5.0      2022-03-03 [2] CRAN (R 4.1.0)
    ##  xfun               0.30       2022-03-02 [1] CRAN (R 4.1.2)
    ##  XML                3.99-0.9   2022-02-24 [2] CRAN (R 4.1.2)
    ##  xtable             1.8-4      2019-04-21 [2] CRAN (R 4.0.2)
    ##  XVector            0.34.0     2021-10-26 [1] Bioconductor
    ##  yaml               2.3.5      2022-02-21 [2] CRAN (R 4.1.2)
    ##  zlibbioc           1.40.0     2021-10-26 [1] Bioconductor
    ## 
    ##  [1] C:/Users/dredondo/Documents/R/win-library/4.1
    ##  [2] C:/Users/dredondo/Documents/R/R-4.1.0/library
    ## 
    ## ------------------------------------------------------------------------------
