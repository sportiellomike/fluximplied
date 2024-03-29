
#' Interactive shiny
#'
#' @description Use this function shinyfluximplied() to launch the interactive
#'
#' @param ui This shiny app only works as we defined it, changes to either ui or server are not allowed.
#' @param server This shiny app only works as we defined it, changes to either ui or server are not allowed.
#'
#' @return A shiny app will be launched.
#' @export
#'
#' @examples shinyfluximplied()
shinyfluximplied=function(ui = ui, server= server){
  library(Cairo)
  library(ggplot2)
  library(shiny)
  library(shinythemes)
  library(viridis)
  #build shiny app
  if (interactive()) {
    # Define UI for application that draws a histogram
    ui <- fluidPage(theme = shinytheme("slate"),
                    # Application title
                    titlePanel("fluximplied"),
                    
                    # Sidebar with a slider input for number of bins
                    sidebarLayout(
                      sidebarPanel(
                        p('This interactive supports dataframe inputs to fluximplied only. Note that LFC col name must be log2FoldChange.'),
                        fileInput("file1", "Choose CSV File", accept = ".csv"),
                        p('This interactive supports dataframe inputs to fluximplied only. Example dataframe input available for download at at https://github.com/sportiellomike/fluximplieddev in file titled exampledeseqresultdataframe.csv.'),
                        selectInput("species", "species",
                                    c('Mouse'='Mmu',
                                      'Human'='Hsa')),
                        selectInput('geneformat','Gene format',
                                    c('Symbol','ENTREZID')),
                        selectInput('inputformat','Input format',
                                    c('Dataframe')),
                        selectInput("padjcolname", "Column to use for P value adjustment",''),
                        selectInput("LFCcolname", "Column with adjusted Log Fold Change values. Note that LFC col name must be log2FoldChange.",''),
                        numericInput("pcutoff", "Significance cutoff (alpha)", 0.05, min = 0, max = 1),
                        downloadButton("downloadData", "Download output table"),
                        # h1('This interactive supports dataframe inputs to fluximplied only.')
                      ),
                      
                      #create the main panel plotting and printing outputs
                      mainPanel(
                        h2("Output table"),
                        tableOutput(outputId = 'table'),
                        h2("Plot"),
                        plotOutput(outputId = 'plot'),
                        h4("We built this plot using the table above, which you can download with the button to the left. You can also copy and paste this chart."),
                        h2("Text output"),
                        h4(textOutput(outputId = "print"))
                      )
                    )
    )
    server = function(input, output, session) {
      #create reactive to be able to pull column names from uploaded CSV
      data <- reactive({
        req(input$file1) ## ?req #  require that the input is available
        
        inFile <- input$file1
        df <- read.csv(inFile$datapath, header = T,row.names = c(1))
        updateSelectInput(session, inputId = 'padjcolname', label = 'Column to use for P value adjustment',choices = colnames(df))
        updateSelectInput(session, inputId = 'LFCcolname', label = 'Column with adjusted Log Fold Change values. Note that LFC col name must be log2FoldChange.',choices = colnames(df))
        return(df)
      })
      #create each output
      output$table <- renderTable({
        inputdat<-data()
        species <-input$species
        geneformat <-input$geneformat
        inputformat <-input$inputformat
        padjcolname <-input$padjcolname
        LFCcolname <-input$LFCcolname
        pcutoff <- input$pcutoff
        # fluximplied(inputdat,species,geneformat,inputformat,padjcolname,pcutoff,LFCcolname)
        # fluximplied(inputdat,species,geneformat,padjcolname,inputformat,LFCcolname, pcutoff)
        fluximplied(inputdat = inputdat,
                    species = species,
                    geneformat = geneformat,
                    inputformat = inputformat,
                    padjcolname = padjcolname,
                    LFCcolname = LFCcolname,
                    pcutoff = pcutoff)
        return(significancetable)
      },rownames = T)
      output$plot <-renderPlot({
        inputdat<-data()
        species <-input$species
        geneformat <-input$geneformat
        inputformat <-input$inputformat
        padjcolname <-input$padjcolname
        LFCcolname <-input$LFCcolname
        pcutoff <- input$pcutoff
        # fluximplied(inputdat,species,geneformat,inputformat,padjcolname,pcutoff)
        # fluximplied(inputdat,species,geneformat,padjcolname,inputformat,LFCcolname, pcutoff)
        fluximplied(inputdat = inputdat,
                    species = species,
                    geneformat = geneformat,
                    inputformat = inputformat,
                    padjcolname = padjcolname,
                    LFCcolname = LFCcolname,
                    pcutoff = pcutoff)
        
        return(fluximpliedplot)
      })
      output$print <-renderText({
        inputdat<-data()
        species <-input$species
        geneformat <-input$geneformat
        inputformat <-input$inputformat
        padjcolname <-input$padjcolname
        LFCcolname <-input$LFCcolname
        pcutoff <- input$pcutoff
        # fluximplied(inputdat,species,geneformat,inputformat,padjcolname,pcutoff)
        # fluximplied(inputdat,species,geneformat,padjcolname,inputformat,LFCcolname, pcutoff)
        fluximplied(inputdat = inputdat,
                    species = species,
                    geneformat = geneformat,
                    inputformat = inputformat,
                    padjcolname = padjcolname,
                    LFCcolname = LFCcolname,
                    pcutoff = pcutoff)
        return(print1)
      })
      
      tabledownload <- reactive({
        inputdat<-data()
        species <-input$species
        geneformat <-input$geneformat
        inputformat <-input$inputformat
        padjcolname <-input$padjcolname
        LFCcolname <-input$LFCcolname
        pcutoff <- input$pcutoff
        # fluximplied(inputdat,species,geneformat,inputformat,padjcolname,pcutoff)
        # fluximplied(inputdat,species,geneformat,padjcolname,inputformat,LFCcolname, pcutoff)
        fluximplied(inputdat = inputdat,
                    species = species,
                    geneformat = geneformat,
                    inputformat = inputformat,
                    padjcolname = padjcolname,
                    LFCcolname = LFCcolname,
                    pcutoff = pcutoff)
        return(significancetable)
      })
      
      output$tabledownload <- renderTable({
        
        tabledownload()
      })
      
      output$downloadData  <- downloadHandler(
        filename = function() {
          paste('significancetable', ".csv", sep = "")
        },
        content = function(file) {
          write.csv(tabledownload(), file, row.names = T)
        }
      )
      
    }}
  #run shiny app
  shinyApp(ui = ui, server = server)
}
###FIN###