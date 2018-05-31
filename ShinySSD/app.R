library(shiny)
library(dplyr)
library(ggplot2)
library(fitdistrplus)
library(EnvStats)
library(tibble)
library(actuar)
library(DT)
library(ggiraph)
library(rmarkdown)

#### Read preloaded database
colnames<-c("Order", "CASNumber", "ChemicalName",  "Chemical Purity Mean Op",  "SpeciesScientificName", "SpeciesGroup",  "OrganismLifestage",	"ExposureType", "ChemicalAnalysis", "MediaType", "Test Location", "Endpoint","Effect", "EffectMeasurement", "PesticideType",	"Values", "Units", "ExposureMedia" )		
tbl<-read.delim("database.csv", sep=",", col.names = colnames, stringsAsFactors = FALSE)


######## USER INTERFASE ########

ui <- navbarPage("Species Sensitivity Distribution", 
                 theme =  "bootstrap.css",
                 tabPanel("Database", h4("Upload a database"), fileInput("file1", "Choose CSV File", multiple=FALSE, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"), buttonLabel = "Browse..."), hr(), span(textOutput("AlertUnits"),hr( color="purple" ), style="color:red"), DT::dataTableOutput(outputId ="contents")),
                 tabPanel("SSD",
                          sidebarLayout(
                            sidebarPanel(h4("Define SSD parameters"),
                                         selectInput(inputId ="ChemicalName", "Chemical Name", ""),
                                         htmlOutput("SpeciesGroup"),
                                         selectInput(inputId ="Endpoint", "Endpoint", ""), 
                                         htmlOutput("Effect"),
                                         tags$hr(style="border-color: lightblue;"),
                                         h4("Remove data"),
                                         htmlOutput("PesticideType"),
                                         htmlOutput("ChemicalAnalysis"),
                                         htmlOutput("ExposureType"),
                                         htmlOutput("MediaType"),
                                         htmlOutput("ExposureMedia"),
                                         htmlOutput("OrganismLifestage"),
                                         downloadButton("report", "Download Report", class = "btn-info")),#sidebarpanel
                            mainPanel(tabsetPanel(
                              tabPanel("Visualization", h4(textOutput("chemical")), plotOutput(outputId = "Database")), 
                              tabPanel("Goodness of Fit", plotOutput(outputId = "plotGof"), h4("Goodness of Fit"), textOutput(outputId ="bestfit"), h4("Goodness of Fit (Complete Analysis)"), verbatimTextOutput(outputId = "goftest"), verbatimTextOutput(outputId = "gof")),
                              tabPanel("HC5 and Plot", h6("Slide the mouse over the dots to reveal the name of the species"), ggiraphOutput(outputId = "coolplot"), h4("Hazard Concentration (HC)"),textOutput(outputId ="bestfit2"), verbatimTextOutput(outputId = "hc5"), h4("Confidence Intervals (CI)"), verbatimTextOutput(outputId = "boot")))))),
                 tabPanel("Contact", h5("MAIL: florencia.dandrea@gmail.com + GITHUB: flor14/paper/ShinySSD")))


############ SERVER ##############

server <- function(input, output, session){
  
  #### UI selectize paramenters #####
  
  output$Effect <- renderUI ({
    selectizeInput('Effect', 'Effect', choices = as.character(unique(filter()$`Effect`)), selected=as.character(unique(filter()$`Effect`)), multiple = TRUE)
  })
  
  output$MediaType <- renderUI ({
    selectizeInput('MediaType', 'MediaType', choices = as.character(unique(filter()$`MediaType`)), selected=as.character(unique(filter()$`MediaType`)), multiple = TRUE)
  })
  
  output$OrganismLifestage <- renderUI ({
    selectizeInput('OrganismLifestage', 'OrganismLifestage', choices = as.character(unique(filter()$`OrganismLifestage`)), selected=as.character(unique(filter()$`OrganismLifestage`)), multiple = TRUE)
  })
  
  output$PesticideType <- renderUI ({
    selectizeInput('PesticideType', 'PesticideType', choices = as.character(unique(filter()$`PesticideType`)), selected=as.character(unique(filter()$`PesticideType`)), multiple = TRUE)
  })
  
  output$ChemicalAnalysis <- renderUI({ 
    selectizeInput("ChemicalAnalysis", "ChemicalAnalysis", choices= as.character(unique(filter()$`ChemicalAnalysis`)), selected=as.character(unique(filter()$`ChemicalAnalysis`)),  multiple = TRUE)
  })
  
  output$ExposureType <- renderUI({  
    selectizeInput("ExposureType", "ExposureType", choices= as.character(unique(filter()$`ExposureType`)), selected=as.character(unique(filter()$`ExposureType`)), multiple = TRUE)
  })
  
  output$ExposureMedia <- renderUI({  
    selectizeInput("ExposureMedia", "ExposureMedia", choices= as.character(unique(filter()$`ExposureMedia`)), selected=as.character(unique(filter()$`ExposureMedia`)), multiple = TRUE)
  })
  
  output$SpeciesGroup <- renderUI({  
    selectizeInput(inputId ="SpeciesGroup", "SpeciesGroup", choices = as.character(unique(filter()$`SpeciesGroup`)), selected = as.character(unique(filter()$`SpeciesGroup`)) , multiple = TRUE)
  })
  
  #### change choices and selections of Select Input when a file is uploaded
  
  observe({
    updateSelectInput(session, "ChemicalName", 
                      label = "ChemicalName",
                      choices = tbl()$ChemicalName,
                      selected = tbl()$ChemicalName[1])
  })
  
  observe({
    updateSelectInput(session, "Endpoint", 
                      label = "Endpoint",
                      choices = tbl()$Endpoint,
                      selected = tbl()$Endpoint[1])
  })
  
  #### TABPanel "Database" ######
  #### size of the file
  options(shiny.maxRequestSize = 30*1024^2)
  
  #### Read a preloaded table or upload a new one
  tbl <- reactive ({
    inFile <- input$file1
    if (is.null(inFile)){ 
      return(tbl<-read.delim("database.csv", sep=",", col.names = colnames, stringsAsFactors = FALSE))}else{ 
        return(tbl<-read.delim(inFile$datapath, sep=",",  col.names = colnames, stringsAsFactors = FALSE))}
      })

  #### AlertUnits
  textUnits<-reactive({ if(!length(unique(tbl()$Units))==1){print("Check!Different units in the database")}else{print("Ok! Uniform Units")} })
  output$AlertUnits <- renderText({ paste("Database:",textUnits()) })
  
  #### Table
  output$contents <- DT::renderDataTable({ tbl() })
  
  ##### Filtering the database
  #### Filter pesticide + endpoint (user election)
  filter<- reactive ({
    
    tbl() %>% dplyr::filter(input$Endpoint == Endpoint & input$ChemicalName == ChemicalName ) })
  
  #### filter pesticide type + chemical analysis + Exposure type + Species Group + Media type + Organism lifestage
  filtered <- reactive ({ 
    filt<- filter() %>% dplyr::filter(PesticideType %in% input$PesticideType  & ChemicalAnalysis %in% input$ChemicalAnalysis & ExposureType %in% input$ExposureType & SpeciesGroup %in% input$SpeciesGroup & Effect %in% input$Effect  & OrganismLifestage %in% input$OrganismLifestage & ExposureMedia %in% input$ExposureMedia & MediaType %in% input$MediaType) 
    filt$SpeciesScientificName<-as.factor(filt$SpeciesScientificName)
    filt})
     
  
  #### When there are reported bioassays for the same species, the geometric mean is calculated
  geom <- reactive ({ 
    ta<-as.data.frame(tapply(as.numeric(filtered()$Values), filtered()$SpeciesScientificName, FUN=geoMean))
    ta <- rownames_to_column(ta, var = "rowname")
    colnames(ta)<-c("SpeciesScientificName", "Values")
    ta <- ta[order(ta$Values), ]
    ta$frac<-ppoints(ta$Values, 0.5) 
    #Quiero agregar una columna con speciesgroup para despues usarlo para graficar
    
    list<-data.frame(filtered()$SpeciesScientificName, filtered()$SpeciesGroup)
    colnames(list)<-c("SpeciesScientificName", "SpeciesGroup")
    ul<- list %>% group_by(SpeciesScientificName, SpeciesGroup) %>% summarise()
    colnames(ul)<-c("SpeciesScientificName", "SpeciesGroup")
    ta<-merge(ul, ta, sort=FALSE, by.x="SpeciesScientificName", by.y="SpeciesScientificName" )
    colnames(ta)<-c("SpeciesScientificName", "SpeciesGroup", "Values", "frac")
    ta })
  
  
  #### Processing the data for the geom_tile plot
  visual <-reactive({ 
    visual<-tbl() %>% dplyr::filter(input$ChemicalName == ChemicalName) %>%
      group_by(SpeciesGroup, SpeciesScientificName,Endpoint, ChemicalName)  %>% summarise(n())
    colnames(visual)<-c("SpeciesGroup", "SpeciesScientificName", "Endpoint", "ChemicalName", "n")
    vis<-visual %>% group_by(SpeciesGroup, Endpoint) %>% summarise(n()) 
    colnames(vis)<-c("SpeciesGroup", "Endpoint", "n")
    vis$Y1 <- cut(vis$n, breaks = c(0,8,10,30,Inf), right = FALSE)
    print(vis)
  })
  
  #### Title
  output$chemical<-renderText({paste("Number of species by endpoint for",input$ChemicalName)})
  
  #### Plot geom_tile
  output$Database <- renderPlot({
    
    print(ggplot(visual(), aes(x=Endpoint, y=SpeciesGroup, fill=Y1)) + geom_tile(width=0.4, height=0.35) + 
            scale_fill_manual(breaks=c("[0,8)", "[8,10)", "[10,30)", "[30,Inf)"), values = c("red", "yellow", "lightgreen", "darkgreen"), labels=c("0-8", "8-10", "10-30", "More than 30"))+
            labs(fill="Number of species"))+ theme_bw()+  theme(aspect.ratio=1.5)
  })
  
  
  #### TABPanel "Goodness of Fit" ######
  #### fit distr
  fit_ln<-  reactive ({ fitdist(as.numeric(geom()$Values), "lnorm" )})
  fit_ll<- reactive ({ fitdist(as.numeric(geom()$Values), "llogis" )})
  fit_w<- reactive ({ fitdist(as.numeric(geom()$Values), "weibull" )})
  fit_P<- reactive ({ fitdist(as.numeric(geom()$Values), "pareto" )})
  
  #### Plot GoF
  cdfreact<- reactive({ cdfcomp(list(fit_ln(), fit_ll(), fit_w(), fit_P()), xlogscale = TRUE, ylogscale = FALSE,
                                legendtext = c("log-normal", "log-logistic", "weibull", "pareto"), lwd=2, xlab = paste("Log10 Conc. of", input$ChemicalName, "(",as.character(unique(tbl()$Units)),")", sep=" "), ylab = 'Fraction of species affected' )})
  
  output$plotGof<-renderPlot ({ print( cdfreact() ) })
  
  #### Best fit AIC
  AICS <- reactive({ 
    sln<-summary(fit_ln())
    sll<-summary(fit_ll())
    slw<-summary(fit_w())
    slP<-summary(fit_P())
    AICS<-data.frame(AIC=c(round(sln$aic, digits=5), round(sll$aic, digits=5), round(slw$aic, digits=5), round(slP$aic, digits=5)), Names=c("log-normal", "log-logistic", "weibull", "pareto"))
    AICS<-data.frame(AICS[order(AICS$AIC),])
    print(AICS)})
  
  output$bestfit <- renderText({ paste("Lowest AIC value:",as.character(AICS()[1,"Names"]), sep=" ") })
  
  #### Goodness of fit 
  gof<-reactive({ print(gof<-gofstat(list(fit_ln(), fit_ll(), fit_w(), fit_P()), fitnames = c("log-normal", "log-logistic", "weibull", "pareto")))}) 
  output$gof<- renderPrint({ gof() })
  
  output$goftest<- renderPrint({ 
    hola<-data.frame(Test=cbind(gof()$kstest, gof()$cvmtest, gof()$adtest)) 
    colnames(hola)<-c("Kolmogorov-Smirnov test", "Cramer Test", "Anderson-Darling test")
    print(hola)})
  
  
  #### TABPanel "HC5 and Plot" ######
  #### Plot
  d <- data.frame(value = as.numeric(c(0.01, 0.05,0.1)), 
                    name = c("1%", "5%", "10%"))
   
     d$name <- factor(d$name, levels = c("1%", "5%", "10%"))
  
  
  codeplot<- reactive({ ggplot(geom()) +
      geom_point_interactive(aes(x = Values, y = frac, color= SpeciesGroup, tooltip=SpeciesScientificName), size = 1.5) +
      theme_bw() + 
      geom_hline(data=d, aes(yintercept = value , linetype = name), color="black")+
      scale_linetype_manual(values=c(2,4,3), name = "HC")+
      scale_x_log10() +
      labs(x = paste("Log10 conc. of", input$ChemicalName, "(",as.character(unique(tbl()$Units)),")", sep=" "), 
           y = 'Fraction of species affected')  })
  
  output$coolplot <- renderggiraph({ ggiraph(code = print(codeplot()), selection_type = 'none') })
  
  output$bestfit2 <- renderText({ paste("Lowest AIC value:", as.character(AICS()[1,"Names"]), sep=" ")})
  
  #### HC5
  hc5 <- reactive ({ 
    a1<- quantile(fit_ln(), probs = c(0.01, 0.05 , 0.1))
    b1<- quantile(fit_ll(), probs = c(0.01, 0.05 , 0.1))
    c1<- quantile(fit_w(), probs = c(0.01, 0.05 , 0.1))
    d1<- quantile(fit_P(), probs = c(0.01, 0.05 , 0.1))
    e<- rbind(round(a1$quantiles, digits=5), round(b1$quantiles, digits=5),round(c1$quantiles, digits=5),round(d1$quantiles, digits=5))
    rownames(e)<-c("log-normal", "log-logistic", "weibull", "pareto")
    colnames(e)<-c("HC1%","HC5%","HC10%")
    print(e)
  })
  
  output$hc5<-renderPrint({ hc5() })
  
  #### BOOTSTRAP
  
  a2<-reactive({ bootdist(fit_ln(), bootmethod = 'param', niter = 100)})
  b2<-reactive({ bootdist(fit_ll(), bootmethod = 'param', niter = 100)})
  c2<-reactive({ bootdist(fit_w(), bootmethod = 'param', niter = 100)})
  d2<-reactive({ bootdist(fit_P(), bootmethod = 'param', niter = 100)})
  
  fit_boot <- reactive ({ 
    bda<-quantile(a2(), probs = c(0.01, 0.05 , 0.1))
    bdb<-quantile(b2(), probs = c(0.01, 0.05 , 0.1))
    bdc<-quantile(c2(), probs = c(0.01, 0.05 , 0.1))
    bdd<-quantile(d2(), probs = c(0.01, 0.05 , 0.1))
    bde<-rbind(round(bda$quantCI, digits=5),round(bdb$quantCI, digits=5),round(bdc$quantCI, digits=5),round(bdd$quantCI, digits=5))
    bde[,"CI"] <-c("2.5%","97.5%", "2.5%","97.5%", "2.5%","97.5%", "2.5%","97.5%")
    bde[,"Names"] <-c("log-normal","", "log-logistic","", "weibull","", "pareto", "")
    bde<-bde[,c("Names", "CI","p=0.01", "p=0.05", "p=0.1" )]
    colnames(bde)<-c("Names", "CI","HC1%","HC5%","HC10%")
    print(bde)
    
  }) 
  
  #### CI 95%
  output$boot<-renderPrint({ fit_boot() })
  
  #### Download Report ######
  output$report <- downloadHandler(
    filename = "report.docx",
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      tempImage <- file.path(tempdir(), "out.png")
      tempImage2 <- file.path(tempdir(), "out2.png")
      
      png("out.png")
      cdfreact()
      dev.off()
      
      png("out2.png")
      print(codeplot())
      dev.off()
      
      file.copy('out.png', tempImage, overwrite = TRUE)
      file.copy('out2.png', tempImage2, overwrite = TRUE)
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      
      ##### Generate dataframes for the report
      dfgof<-as.array(gof())
      dfhc5<-as.data.frame(hc5())
      dfboot<-as.data.frame(fit_boot())
      
      
      ##### Set up parameters to pass to Rmd document
      params <- list(Chemical = input$ChemicalName,
                     Endpoint= input$Endpoint, 
                     Effect=input$Effect,
                     OrganismLifestage = input$OrganismLifestage,
                     MediaType = input$MediaType,
                     PesticideType = input$PesticideType,
                     ExposureType = input$ExposureType,
                     ExposureMedia = input$ExposureMedia,
                     SpeciesGroup = input$SpeciesGroup,
                     outgof= dfgof,
                     outhc5= dfhc5,
                     outboot= dfboot)
      
      
      rmarkdown::render('report.Rmd', output_file = file, params = params, envir = new.env(parent = globalenv()))
      
    })}

# Run the app ----
shinyApp(ui, server)
