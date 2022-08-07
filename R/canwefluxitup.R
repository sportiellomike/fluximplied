#' canwefluxitup
#'
#' @description This function makes sure that your arguments are formatted correctly. You can call it, but it is also called within fluximplied().
#' @param inputdat what you are using as your input data, either a data frame with genes as the rownames, a column for LFC, and a column for padj values
#' @param species either mus or hsa
#' @param geneformat either ENTREZ or symbol
#' @param padjcolname the name of the column in your data frame, if applicable, that stores the padj values
#' @param LFCcolname the name of the column in your data frame, if applicable, that stores the Log Fold Change values
#' @param pcutoff the alpha threshold for your padjustadjust
#'
#' @return It should stop and print out what is wrong with your inputs if anything.
#' @export
#'
#' @examples
#' canwefluxitup(inputdat=exampleData,
#' species='mmu',
#' geneformat='SYMBOL',
#' padjcolname='adj_pvalue',
#' LFCcolname='Log2FoldChange',
#' pcutoff=0.05)
canwefluxitup <- function(inputdat=inputdat,species=species,geneformat=geneformat,padjcolname=padjcolname, LFCcolname=LFCcolname,pcutoff=pcutoff) {
  # initiate the not in operator
`%!in%` <- Negate(`%in%`) # First we have to define the 'not in' operator
library(Cairo)
library(ggplot2)
library(shiny)
library(shinythemes)
library(viridis)
# ensure that the correct class was supplied to each argument
# confirm that input dat is actually a data frame or vector
if(class(inputdat) %!in% c('data.frame','character')){
stop("Your inputdat supplied is not of the correct class. Make sure it is either a vector of genes each in quotes like c('Ifng','Pfkl') or a data frame.")
}

if(class(species)!= 'character'){
  stop("You did not supply the correct class of argument to species. It should look something like species='mmu' with the argument in quotes.") 
}

if(class(geneformat)!= 'character'){
  stop("You did not supply the correct class of argument to geneformat It should look something like geneformat='symbol' with the argument in quotes.") 
}

if(class(padjcolname)!= 'character'){
  stop("You did not supply the correct class of argument to padjcolname It should look something like padjcolname='P_adjusted' with the argument in quotes.") 
}

if(class(LFCcolname)!= 'character'){
  stop("You did not supply the correct class of argument to LFCcolname It should look something like LFCcolname='log_2_foldchange' with the argument in quotes.") 
}

if(class(pcutoff)!= 'numeric'){
  stop("You did not supply the correct class of argument to pcutoff It should look something like pcutoff=0.1 with the argument being an actual number not in quotes.") 
}

# confirm that species are in the accepted list of species
# make list of accepted species
mouselist<-c('MMU','Mmu','mmu','mouse','Mouse','MOUSE')
humanlist<-c('HSA','Hsa','hsa','human','Human','HUMAN')

# confirm user supplied values are in our lists
if(species %!in% mouselist & species %!in% humanlist){
stop("Your species provided is not in our accepted list of species. Please make sure to specify species='mmu' or 'hsa'.")
}

if(species %in% mouselist){
  cat('We are using mouse (mmu) as your species.\n')
}

if(species %in% humanlist){
  cat('We are using human (hsa) as your species.\n')
}

# make the list of accepted gene formats
symbollist<-c('symbol','Symbol','SYMBOL')
entrezlist<-c('entrez','Entrez','ENTREZ','entrezid','ENTREZID','Entrezid','EntrezId','EntrezID')

# confirm user supplied values are in our lists
if(geneformat %!in% symbollist & geneformat %!in% entrezlist){
stop("Your geneformat provided is not in our accepted list of geneformats Please make sure to specify geneformat='symbol' or 'entrez'.")
}

if(geneformat %in% symbollist){
  cat('We are using symbol as your geneformat.\n')
}

if(geneformat %in% entrezlist){
  cat('We are using entrez as your geneformat.\n')
}
}
