#' loadData
#'
#'@description used in shiny app
#'
#' @return
#' @export
#'
loadData <- function() {
  if (exists("responses")) {
library(Cairo)
library(ggplot2)
library(shiny)
library(shinythemes)
library(viridis)
    responses
  }
}
