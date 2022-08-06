## code to prepare `DATASET` dataset goes here
exampleData<-read.csv('./data-raw/exampleData.csv',row.names = c(1))

usethis::use_data(DATASET, overwrite = TRUE)
