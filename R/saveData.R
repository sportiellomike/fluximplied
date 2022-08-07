#' saveData
#'
#' @description used in shiny app
#'
#' @param data
#'
#' @return
#' @export
#'
saveData <- function(data) {
library(Cairo)
library(ggplot2)
library(shiny)
library(shinythemes)
library(viridis)
  data <- as.data.frame(t(data))
  if (exists("responses")) {
    responses <<- rbind(responses, data)
  } else {
    responses <<- data
  }
}
