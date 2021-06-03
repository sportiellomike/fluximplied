exampleData<-read.csv('./data-raw/exampleData.csv',row.names = c(1))

usethis::use_data(exampleData,overwrite = T)
