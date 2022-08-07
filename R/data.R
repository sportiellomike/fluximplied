#' @title Scores of Group A and Group B
#'
#' @description A data set that simulates a DESeq2 result.
#'
#' @format A data frame with 40 rows and 3 variables:
#' \describe{
#'   \item{pvalue}{Gene's p value for differential expression.}
#'   \item{padj}{Gene's p value for differential expression.}
#'   \item{log2FoldChange}{Gene's LFC}
#' }
#' @source <https://www.github.com/mvuorre/exampleRPackage>
library(Cairo)
library(ggplot2)
library(shiny)
library(shinythemes)
library(viridis)
"exampleData"
