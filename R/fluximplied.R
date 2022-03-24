#' fluximplied
#'
#' @description Pathway analysis of DESeq2 result or character vector of differentially expressed genes which also plots results.
#' @param inputdat what you are using as your input data, either a dataframe with genes as the rownames, a column for LFC, and a column for padj values
#' @param species either mus or hsa
#' @param geneformat either ENTREZ or symbol
#' @param inputformat either df or vector
#' @param padjcolname the name of the column in your dataframe, if applicable, that stores the padj values
#' @param pcutoff the alpha threshold for your padjustadjust
#'
#' @return If a dataframe was supplied, it should also return a dataframe as well as a bar graph of the enriched pathways.
#' @export
#'
#' @examples
#' fluximplied(inputdat=exampleData,species='mmu',geneformat='SYMBOL',inputformat='df',padjcolname='adj_pvalue',pcutoff=0.05)
fluximplied <- function(inputdat,species='mmu',geneformat='SYMBOL',inputformat='df',padjcolname='adj_pvalue',RLSdatabase=RLSdatabase,pcutoff=0.05) {
  list.of.packages <- c("viridis",
                        "ggplot2",
                        'shinythemes',
                        'Cairo',
                        'shiny')
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(list.of.packages, require, character.only = TRUE)

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
   ifelse(inputformat=='vector'||inputformat=='Vector'||inputformat=='VECTOR',
         print('We are using your vector of genes as the inputdat'),
         ifelse(inputformat=='df'||inputformat=='DF'||inputformat=='Df'||inputformat=='dataframe'||inputformat=='Dataframe',{
                inputdat<-subset(inputdat,rownames(inputdat) %in% RLSgenes)
                  inputdat$padjadj<-p.adjust(inputdat[[padjcolname]],method = 'BH')
                  inputssubset<-subset(inputdat,inputdat$padjadj<pcutoff)
                  inputdat<-rownames(inputssubset)},
                print('It appears that you supplied an input that was neither a dataframe nor a vector.')
         )
  )
  #subset the database to only include genes in your set
  subset<-subset(RLS,RLS$RLSgenes %in% inputdat)
  #change the column names so the user knows what each column actually is
  colnames(subset)<-c('RLS genes in your set','Pathway associated with gene','KEGG Pathway ID')
  #create an intersect so we can actually count them
  intersect<-intersect(inputdat,RLSgenes)
  lengthintersect<-length(intersect)
  print1<<-ifelse(lengthintersect==0,
         (paste('There are no genes in your set that are in our rate limiting step database. Make sure you gave the correct species (Mmu or Hsa only) and geneformat (Symbol or ENTREZID only). If you are using the interactive GUI, you should be uploading a dataframe with a column of p values, a column called log2FoldChange, and genes should be in the first column. If you are not using the GUI, you can use the dataframe from a DESeq2 result with genes as rownames, or a character vector of genes. Sorry about that. We are as sad as you.')),
               {(paste0('Your gene set has --------> ',lengthintersect,' <-------- genes that have been identified as encoding enzymes involved as rate-limiting steps in the gene set you provided. If you are running this from Rstudio or the command line (not the interactive app), your RLS genes are saved as myRLSgenes and a dataframe of genes and corresponding pathways is saved as myRLStable.'))})
  #save the outputs so the user can hold onto them and look at them
  myRLStable<<-subset
  myRLSgenes<<-intersect(RLS$RLSgenes,inputdat)
  #print the RLS database that has been subset to only include genes that are in user's list
  ifelse(inputformat=='df'||inputformat=='DF'||inputformat=='Df'||inputformat=='dataframe'||inputformat=='Dataframe',
         {significancetable<-inputssubset
         significancetable$metabolic_rxn <- myRLStable$`Pathway associated with gene`[match(rownames(significancetable), myRLStable$`RLS genes in your set`)]
         significancetable$kegg_pathway_id <- myRLStable$`KEGG Pathway ID`[match(rownames(significancetable), myRLStable$`RLS genes in your set`)]
         significancetable<<-significancetable
         plottable<-significancetable
         plottable$genepath<-paste0(rownames(plottable),' (RLS of ',plottable$metabolic_rxn,')')
         if (!require(ggplot2)) {
           stop("ggplot2 is not installed. Install it from CRAN.")}
         if (!require(viridis)) {
           stop("viridis is not installed. Install it from CRAN.")}
         fluximpliedplot<<-ggplot(plottable, aes(x=reorder(genepath,log2FoldChange), y=log2FoldChange , label=log2FoldChange)) +
           geom_bar(stat='identity', aes(fill=padjadj), width=.5,position="dodge")  +
           scale_fill_viridis(end=.9) +
           labs(title= "Pathway analysis with 'fluximplied'",x='',y=bquote('Log'[2]('Fold Change')),fill=bquote('P'['adjadj'])) +
           theme(axis.title = element_text(size=12),
                 axis.text = element_text(size=12))+
           coord_flip()
         plot(fluximpliedplot)},1+1)
  return((print1))

 }
