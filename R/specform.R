#' specform
#'
#' @description ensures the user supplied correct syntax to use fluximplied
#'
#' @param species
#' @param geneformat
#'
#' @return
#' @export
#'
#' @examples specform(species='mmu',geneformat='symbol')
specform <- function(species,geneformat) {
  RLSdatabase<<-read.csv('https://raw.githubusercontent.com/sportiellomike/fluximplied/master/RLSdatabase.csv',stringsAsFactors = F,colClasses = c(kegg.pathway.id='character'))
  ifelse(species=='Mmu' || species=='MMU' || species=='mmu',
         ifelse(geneformat=='Symbol'||geneformat=='SYMBOL'||geneformat=='symbol', RLSgenes<-RLSdatabase$mouse.gene.symbol,
                ifelse(geneformat== 'Entrezid'||geneformat=='ENTREZ'||geneformat=='Entrez'||geneformat=='entrez'||geneformat=='entrezid'||geneformat=='ENTREZID',
                       RLSgenes<-RLSdatabase$mouse.entrez, print('Your species was accepted as Mmu, but your geneformat was neither Symbol nor ENTREZID'))),
         ifelse(species=='Hsa'||species=='hsa'||species=='HSA',
                ifelse(geneformat=='Symbol'||geneformat=='SYMBOL'||geneformat=='symbol', RLSgenes<-RLSdatabase$human.gene.symbol,
                       ifelse(geneformat== 'Entrezid'||geneformat=='ENTREZ'||geneformat=='Entrez'||geneformat=='entrez'||geneformat=='entrezid'||geneformat=='ENTREZID',
                              RLSgenes<-RLSdatabase$human.entrez,print('Your species was accepted as Hsa, but your geneformat was neither Symbol nor ENTREZID'))),
                print('Your species must be Mmu or Hsa')))
  RLSgenes<<-RLSgenes
}
