#' fluximplied
#'
#' @description Pathway analysis of DESeq2 result or character vector of differentially expressed genes which also plots results.
#' @param inputdat what you are using as your input data, either a data frame with genes as the rownames, a column for LFC, and a column for padj values
#' @param species either mus or hsa
#' @param geneformat either ENTREZ or symbol
#' @param inputformat either df or vector
#' @param padjcolname the name of the column in your data frame, if applicable, that stores the padj values
#' @param LFCcolname the name of the column in your data frame, if applicable, that stores the Log2FoldChange Values
#' @param pcutoff the alpha threshold for your padjustadjust
#'
#' @return If a data frame was supplied, it should also return a data frame as well as a bar graph of the enriched pathways.
#' @export
#'
#' @examples
#' fluximplied(inputdat = exampleData,
#' geneformat="SYMBOL",
#' species = "mmu",
#' padjcolname = 'padj',
#' inputformat = 'df',
#' LFCcolname = 'log2FoldChange',
#' pcutoff = 0.05)
fluximplied <- function(inputdat,species='mmu',geneformat='SYMBOL',padjcolname='adj_pvalue', inputformat='df',LFCcolname,pcutoff=0.05) {
library(Cairo)
library(ggplot2)
library(shiny)
library(shinythemes)
library(viridis)

 
    #define df
  dflist<-c('df','DF','Df','dataframe','Dataframe','DataFrame','DATAFRAME','data.frame')
  # if(inputformat %in% dflist) {
  #   inputformat<-'df'
  #   }
  #define vector
  veclist<-c('vector','Vector','vec','Vec','VECTOR','character')
  # if(inputformat %in% veclist) {
  #   inputformat<-'vector'
  #   }
  
  # ensure all the inputs are of correct format
  canwefluxitup(inputdat=inputdat,species=species,geneformat=geneformat,padjcolname=padjcolname,
                LFCcolname=LFCcolname,pcutoff=pcutoff)
 
  # make sure their padjcolname is actually in the vector they supplied
  `%!in%` <- Negate(`%in%`) # First we have to define the 'not in' operator
  if(inputformat %in% dflist & padjcolname %!in% colnames(inputdat)) {
    stop("You told us your padjcolname was something that isn't actually in the data frame your provided. Please correct which column name is your padj column.")
    }
  
  # make sure their LFC column is actually in the vector they supplied
  if(inputformat %in% dflist & LFCcolname %!in% colnames(inputdat)) {
  stop("You told us your LFCcolname was something that isn't actually in the data frame your provided. Please correct which column name is your padj column.")
    }
  
  # function to see if there are any rate limiting steps in gene list
  #load the rate limiting step database
  #convert the database that matches your data for species and geneformat (Symbol or ENTREZID)
  RLSgenes<-specform(species,geneformat)
  #save the pathways
  RLSpathways<-RLSdatabase$metabolic.reaction
  #add kegg pathway ids
  KEGGpathwayids<-RLSdatabase$kegg.pathway.id
  #make a data frame with those genes and pathways
  RLS<-data.frame(RLSgenes,RLSpathways,KEGGpathwayids)
  #create the responses if there are any genes left after subsetting on your genes
  #that are also in our database for being rate limiting steps
  
  if(inputformat %in% veclist) {
    print('We are using your vector of genes as the inputdat')
  }
  if(inputformat %in% dflist) {
                inputdat<-subset(inputdat,rownames(inputdat) %in% RLSgenes)
                inputdat$padjadj<-p.adjust(inputdat[[padjcolname]],method = 'BH')
                inputssubset<-subset(inputdat,inputdat$padjadj<pcutoff)
                inputdat<-rownames(inputssubset)
                if(nrow(inputssubset)==0){
                stop("There are no genes in your set that reach significance according to your supplied pcutoff.")
                }
  }
    #subset the database to only include genes in your set
  subset<-subset(RLS,RLS$RLSgenes %in% inputdat)
  #change the column names so the user knows what each column actually is
  colnames(subset)<-c('RLS genes in your set','Pathway associated with gene','KEGG Pathway ID')
  #create an intersect so we can actually count them
  intersect<-intersect(inputdat,RLSgenes)
  lengthintersect<-length(intersect)
  print1<<-ifelse(lengthintersect==0, # prepare the message to print to console that describes the result.
         (paste('There are no genes in your set that are in our rate limiting step database. Make sure you gave the correct species (Mmu or Hsa only) and geneformat (Symbol or ENTREZID only). If you are using the interactive GUI, you should be uploading a dataframe with a column of p values, a column called log2FoldChange, and genes should be in the first column. If you are not using the GUI, you can use the dataframe from a seurat or DESeq2 result with genes as rownames, or a character vector of genes. Sorry about that. We are as sad as you.')),
               {(paste0('Your gene set has --------> ',lengthintersect,' <-------- genes that have been identified as encoding enzymes involved as rate-limiting steps in the gene set you provided. If you are running this from Rstudio or the command line (not the interactive app), your RLS genes are saved as myRLSgenes and a dataframe of genes and corresponding pathways is saved as myRLStable.'))})
  #save the outputs so the user can hold onto them and look at them
  myRLStable<<-subset
  myRLSgenes<<-intersect(RLS$RLSgenes,inputdat)
  #print the RLS database that has been subset to only include genes that are in user's list
  if(inputformat %in% dflist)
         {significancetable<-inputssubset
         significancetable$metabolicrxn <- myRLStable$`Pathway associated with gene`[match(rownames(significancetable), myRLStable$`RLS genes in your set`)]
         significancetable$keggpathwayid <- myRLStable$`KEGG Pathway ID`[match(rownames(significancetable), myRLStable$`RLS genes in your set`)]
         significancetable<<-significancetable # save the significance table so the user can look at it
         plottable<-significancetable
         plottable$genepath<-paste0(rownames(plottable),' (RLS of ',plottable$metabolicrxn,')')
         if (!require(ggplot2)) { # make sure these packages are actually installed
           stop("ggplot2 is not installed. Install it from CRAN.")}
         if (!require(viridis)) { # make sure these packages are actually installed
           stop("viridis is not installed. Install it from CRAN.")}
          # actually make the plot for the user
         # cat(plottable)
         fluximpliedplot<<-ggplot(plottable, aes(x=genepath, y=`log2FoldChange`)) +
           geom_col(aes(fill=padjadj), width=.5,position="dodge")  +
           scale_fill_viridis(end=.9) +
           labs(title= "Pathway analysis with 'fluximplied'",x='',y=bquote('Log'[2]('Fold Change')),fill=bquote('P'['adjadj'])) +
           theme(axis.title = element_text(size=12),
                 axis.text = element_text(size=12),
                 panel.background = element_blank(),
                 panel.grid.major = element_line(color='light grey'))+
          
           coord_flip()
         plot(fluximpliedplot)}
  cat(print1)

 }
