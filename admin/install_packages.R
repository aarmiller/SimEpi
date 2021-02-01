
## Note: We can install packages individually...
install.packages("tidyverse")

## or we can install packages from a vector of names
list_of_packages <- c("microbenchmark","deSolve","rootSolve","Rcpp","EpiModel",
                      "lobstr","statnetWeb","tidymodels","keras","caret","bit64")

install.packages(list_of_packages,dependencies = TRUE)

## old icd package
devtools::install_version("icd", version = "4.0.9", repos = "http://cran.us.r-project.org")

# remove the package list
rm(list=list_of_packages)