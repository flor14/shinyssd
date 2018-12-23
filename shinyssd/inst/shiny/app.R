library(shiny)
library(dplyr)
library(ggplot2)
library(fitdistrplus)
library(EnvStats)
library(actuar)
library(DT)
library(tibble)
library(ggiraph)
library(rmarkdown)

# Read preloaded database --------------------------------
colnames <- c("order", "cas_number", "chem_name",  "chem_purity",  "sps_sc_name", "sps_group", "org_lifestage",	"exp_type",
              "analytic_validation", "media_type", "test_location", "endpoint", "effect", "effect_measurement", "chem_type",
              "values", "units", "exposure_media")

tbl <- read.delim("database.csv", sep = ",", col.names = colnames, stringsAsFactors = FALSE)


# User Interfase -----------------------------------------

ui <- navbarPage(id = "navbar", "shinySSD v1.0: Species Sensitivity Distribution for Ecotoxicological Risk Assessment",
                 theme = "inst/shiny/www/bootstrap.css",
                 tabPanel("Database", h4("Upload a database"), fileInput("file1", "Choose CSV File", multiple = FALSE, accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"), buttonLabel = "Browse..."), hr(), span(textOutput("Alertunits"), hr( color = "purple" ), style = "color:red"), DT::dataTableOutput(outputId = "contents")),
                 tabPanel("SSD",
                          sidebarLayout(
                            sidebarPanel(h4("Define SSD parameters"),
                                         selectInput(inputId = "chem_name", "Chemical Name", ""),
                                         htmlOutput(outputId = "sps_group_out"),
                                         selectInput(inputId = "endpoint", "Endpoint", ""),
                                         htmlOutput(outputId = "effect_out"),
                                         tags$hr(style = "border-color: lightblue;"),
                                         h4("Remove data"),
                                         htmlOutput(outputId = "chem_type_out"),
                                         htmlOutput(outputId = "analytic_validation_out"),
                                         htmlOutput(outputId = "test_location_out"),
                                         htmlOutput(outputId = "exp_type_out"),
                                         htmlOutput(outputId = "exposure_media_out"),
                                         htmlOutput(outputId = "media_type_out"),
                                         htmlOutput(outputId = "org_lifestage_out"),
                                         downloadButton("report", "Download Report", class = "btn-info")),
                            mainPanel(tabsetPanel(id = "tabsetpanel",
                              tabPanel("Visualization", h4(textOutput("chemical")), plotOutput(outputId = "database")),
                              tabPanel("Goodness of Fit", plotOutput(outputId = "plotGof", height = 500, width = 500),
                                       h4("Goodness of Fit"), textOutput(outputId = "bestfit"), hr(),
                                       h4("Goodness of Fit (Complete Analysis)"), verbatimTextOutput(outputId = "goftest"), hr(),
                                       verbatimTextOutput(outputId = "gof"),
                                       h6("For the correct interpretation of this extended results, the reading of the fitdistrplus package manual is recommended")),
                              tabPanel("HC5 and Plot", h6("Slide the mouse over the dots to reveal the name of the species"), ggiraphOutput(outputId = "coolplot"), hr(),
                                       h4("Hazard Concentration (HC)"), textOutput(outputId = "bestfit2"), verbatimTextOutput(outputId = "hc5"), hr(), h4("Confidence Intervals (CI)"), verbatimTextOutput(outputId = "boot")))))),
                 tabPanel("Contact", h5("MAIL: florencia.dandrea@gmail.com + GITHUB: flor14/shinyssd")))

# Server -------------------------------------------------

server <- function(input, output, session){

  # UI selectize paramenters 

  output$effect_out <- renderUI ({
    selectizeInput(inputId = "effect", "Effect", choices = as.character(unique(filter()$`effect`)),
                   selected = as.character(unique(filter()$`effect`)), multiple = TRUE)
  })

  output$sps_group_out <- renderUI({
    selectizeInput(inputId = "sps_group", "Species Group", choices = as.character(unique(filter()$`sps_group`)),
                   selected = as.character(unique(filter()$`sps_group`)), multiple = TRUE)
  })

  output$chem_type_out <- renderUI ({
    selectizeInput(inputId = "chem_type", "Chemical Type", choices = as.character(unique(filter()$`chem_type`)),
                   selected = as.character(unique(filter()$`chem_type`)), multiple = TRUE)
  })

  output$analytic_validation_out <- renderUI({
    selectizeInput(inputId = "analytic_validation", "Analytic Validation", choices = as.character(unique(filter()$`analytic_validation`)),
                   selected = as.character(unique(filter()$`analytic_validation`)), multiple = TRUE)
  })

  output$test_location_out <- renderUI({
    selectizeInput(inputId = "test_location", "Test Location", choices = as.character(unique(filter()$`test_location`)),
                   selected = as.character(unique(filter()$`test_location`)), multiple = TRUE)
  })

  output$exp_type_out <- renderUI({
    selectizeInput(inputId = "exp_type", "Exposure Type", choices = as.character(unique(filter()$`exp_type`)),
                   selected = as.character(unique(filter()$`exp_type`)), multiple = TRUE)
  })

  output$exposure_media_out <- renderUI({
    selectizeInput(inputId = "exposure_media", "Exposure Media", choices = as.character(unique(filter()$`exposure_media`)),
                   selected = as.character(unique(filter()$`exposure_media`)), multiple = TRUE)
  })

  output$media_type_out <- renderUI({
    selectizeInput(inputId = "media_type", "Media Type", choices = as.character(unique(filter()$`media_type`)),
                   selected = as.character(unique(filter()$`media_type`)), multiple = TRUE)
  })

  output$org_lifestage_out <- renderUI({
    selectizeInput(inputId = "org_lifestage", "Organism Lifestage", choices = as.character(unique(filter()$`org_lifestage`)),
                   selected = as.character(unique(filter()$`org_lifestage`)), multiple = TRUE)
  })

  # change choices and selections of Select Input when a file is uploaded 
  
  observe({
    updateSelectInput(session, "chem_name",
                      label = "Chemical Name",
                      choices = tbl()$chem_name,
                      selected = tbl()$chem_name[1])
  })

  observe({
    updateSelectInput(session, "endpoint",
                      label = "Endpoint",
                      choices = tbl()$endpoint,
                      selected = tbl()$endpoint[length(tbl()$endpoint)])
  })
  
  # Tabpanel "Database" ------------------------------------
  # Size of the file

  options(shiny.maxRequestSize = 30*1024^2)

  # Read a preloaded table or upload a new one
  tbl <- reactive({
    in_file <- input$file1
    if (is.null(in_file)){
      return(tbl <- read.delim("database.csv", sep = ",", col.names = colnames, stringsAsFactors = FALSE))} else {
        return(tbl <- read.delim(in_file$datapath, sep = ",",  col.names = colnames, stringsAsFactors = FALSE))}
  })
 
  # Alertunits 
  
  textunits <- reactive({
    if(!length(unique(tbl()$units)) == 1){print("Check!Different units in the database")} else {
      print("Ok! Uniform units")}
  })

  output$Alertunits <- renderText({
    paste("Database:", textunits())
  })
 
  # Table 
  
  output$contents <- DT::renderDataTable({
    tbl()
  })
 
  # Filtering the database ----------------------------------
  # Filter pesticide + endpoint (user election)
  
  filter <- reactive ({
    tbl() %>%
      dplyr::filter(input$endpoint == endpoint & input$chem_name == chem_name )
  })

  # Filter pesticide type + chemical analysis + Exposure type + Species Group + Media type + Organism lifestage 
  
  filtered <- reactive ({
    filt <- filter() %>%
      dplyr::filter(chem_type %in% input$chem_type & analytic_validation %in% input$analytic_validation & 
                    exp_type %in% input$exp_type & sps_group %in% input$sps_group & effect %in% input$effect &
                    org_lifestage %in% input$org_lifestage & exposure_media %in% input$exposure_media & media_type %in% input$media_type)
    filt$sps_sc_name <- as.factor(filt$sps_sc_name)
    filt
  })

  # When there are reported bioassays for the same species, the geometric mean is calculated 
  geom <- reactive({
     faux <- filtered()
     ta <- as.data.frame(tapply(as.numeric(faux$values), faux$sps_sc_name, FUN = geoMean))
     ta <- tibble::rownames_to_column(ta, var = "rowname")
     colnames(ta) <- c("sps_sc_name", "values")
     ta <- ta[order(ta$values), ]
     ta$frac <- ppoints(ta$values, 0.5)
    
     lista <- data.frame(faux$sps_sc_name, faux$sps_group)
     colnames(lista) <- c("sps_sc_name", "sps_group")
     ul <- lista %>%
       dplyr::group_by(sps_sc_name, sps_group) %>%
       dplyr::summarise()
     colnames(ul) <- c("sps_sc_name", "sps_group")
     ta <- merge(ul, ta, sort = FALSE, by.x = "sps_sc_name", by.y = "sps_sc_name" )
     colnames(ta) <- c("sps_sc_name", "sps_group", "values", "frac")
     ta })

  
  # Processing the data for the geom_tile plot --------------
   visual <- reactive({
    visual <- tbl() %>%
      dplyr::filter(input$chem_name == chem_name) %>%
      dplyr::group_by(sps_group, sps_sc_name, endpoint, chem_name) %>%
      dplyr::summarise(n())
    colnames(visual)<-c("sps_group", "sps_sc_name", "endpoint", "chem_name", "n")
    vis <- visual %>%
      dplyr::group_by(sps_group, endpoint) %>%
      dplyr::summarise(n())
    colnames(vis)<-c("sps_group", "endpoint", "n")
    vis$Y1 <- cut(vis$n, breaks = c(0, 8, 10, 30, Inf), right = FALSE)
    print(vis)
  })
  
  # Title ----------------------------------------------------   
  output$chemical <- renderText({
    paste("Number of species by endpoint for", input$chem_name)
  })

  # ggplot / geom_tile ----------------------------------------------------   

  output$database <- renderPlot({
    print(ggplot(visual(), aes(x = endpoint, y = sps_group, fill = Y1)) +
            geom_tile(width = 0.4, height = 0.35) +
            scale_fill_manual(breaks = c("[0,8)", "[8,10)", "[10,30)", "[30,Inf)"),
                              values = c("red", "yellow", "lightgreen", "darkgreen"),
                              labels = c("1-8", "8-10", "10-30", "More than 30")) +
            labs(fill = "Number of species", size = 4, y = "Species group", x = "Endpoint") +
            theme_bw() +
            theme(aspect.ratio = 1.5))
  })
   
  # TABPanel "Goodness of Fit" -------------------------------
  # fitdist
  
  fit_ln <- reactive({
    fitdist(as.numeric(geom()$values), "lnorm")
  })

  fit_ll <- reactive({
    fitdist(as.numeric(geom()$values), "llogis")
  })

  fit_w <- reactive({
    fitdist(as.numeric(geom()$values), "weibull", lower = c(0, 0))
  })

  fit_P <- reactive({
    fitdist(as.numeric(geom()$values), "pareto")
  })

  # Plot goodness of fit 

  cdfreact <- reactive({
    cdfcomp(list(fit_ln(), fit_ll(), fit_w(), fit_P()), xlogscale = TRUE, ylogscale = FALSE,
            legendtext = c("log-normal", "log-logistic", "weibull", "pareto"), lwd = 2,
            xlab = paste("Log10 Conc. of", input$chem_name, "(", as.character(unique(tbl()$units)), ")", sep = " "),
            ylab = 'Fraction of species affected')
  })

  output$plotGof <- renderPlot({
    print(cdfreact())
  })

  # Best fit aic 
  
  aics <- reactive({
    sln <- summary(fit_ln())
    sll <- summary(fit_ll())
    slw <- summary(fit_w())
    slP <- summary(fit_P())
    aics <- data.frame(aic = c(round(sln$aic, digits = 5), round(sll$aic, digits = 5), round(slw$aic, digits = 5), round(slP$aic, digits = 5)), Names = c("log-normal", "log-logistic", "weibull", "pareto"))
    aics <- data.frame(aics[order(aics$aic),])
    print(aics)
  })

  output$bestfit <- renderText({
    paste("Lowest AIC value:", as.character(aics()[1,"Names"]), sep = " ")
  })

  # Goodness of fit 
  
  gof <- reactive({
    print(gof <- gofstat(list(fit_ln(), fit_ll(), fit_w(), fit_P()),
                         fitnames = c("log-normal", "log-logistic", "weibull", "pareto")))
  })

  output$gof <- renderPrint({
    gof()
  })

  output$goftest <- renderPrint({
    est_test <- data.frame(Test = cbind(gof()$kstest, gof()$cvmtest, gof()$adtest))
    colnames(est_test) <- c("Kolmogorov-Smirnov test", "Cramer Test", "Anderson-Darling test")
    print(est_test)
  })

# TABPanel "HC5 and Plot" ---------------------------------------------------------
  # plot 
  
  legend <- data.frame(value = as.numeric(c(0.01, 0.05, 0.1)), name = c("1%", "5%", "10%"))

  legend$name <- factor(legend$name, levels = c("1%", "5%", "10%"))


  codeplot<- reactive({
    ggplot(geom()) +
      geom_point_interactive(aes(x = values, y = frac, color = sps_group, tooltip = sps_sc_name), size = 1.5) +
      theme_bw() +
      geom_hline(data = legend, aes(yintercept = value, linetype = name), color = "black") +
      scale_linetype_manual(values = c(2, 4, 3), name = "HC")+
      scale_x_log10() +
      labs(x = paste("Log10 conc. of", input$chem_name, "(", as.character(unique(tbl()$units)), ")", sep = " "),
           y = "Fraction of species affected")
  })

  output$coolplot <- renderggiraph({
    ggiraph(code = print(codeplot()), selection_type = "none")
  })

  output$bestfit2 <- renderText({
    paste("Lowest AIC value:", as.character(aics()[1,"Names"]), sep = " ")
  })


  # HC5 

  hc5 <- reactive ({
    lognor <- quantile(fit_ln(), probs = c(0.01, 0.05, 0.1))
    loglog <- quantile(fit_ll(), probs = c(0.01, 0.05, 0.1))
    weib <- quantile(fit_w(), probs = c(0.01, 0.05, 0.1))
    pare <- quantile(fit_P(), probs = c(0.01, 0.05, 0.1))
    dist_data <- rbind(round(lognor$quantiles, digits = 3), round(loglog$quantiles, digits = 3), round(weib$quantiles, digits = 3), round(pare$quantiles, digits = 3))
    rownames(dist_data) <- c("log-normal", "log-logistic", "weibull", "pareto")
    colnames(dist_data) <- c("HC1%", "HC5%", "HC10%")
    print(dist_data)
  })

  output$hc5 <- renderPrint({
    hc5()
  })


  # Bootstrap 

  reac_ln <- reactive({
    bootdist(fit_ln(), bootmethod = "param", niter = 750)
  })
  reac_ll <- reactive({
    bootdist(fit_ll(), bootmethod = "param", niter = 750)
  })
  reac_w <- reactive({
    bootdist(fit_w(), bootmethod = "param", niter = 750)
  })
  reac_p <- reactive({
    bootdist(fit_P(), bootmethod = "param", niter = 750)
  })

  fit_boot <- reactive ({
    boot_ln <- quantile(reac_ln(), probs = c(0.01, 0.05, 0.1))
    boot_ll <- quantile(reac_ll(), probs = c(0.01, 0.05, 0.1))
    boot_w <- quantile(reac_w(), probs = c(0.01, 0.05, 0.1))
    boot_p <- quantile(reac_p(), probs = c(0.01, 0.05, 0.1))
    boot_data <- rbind(round(boot_ln$quantCI, digits = 3), round(boot_ll$quantCI, digits = 3),
                       round(boot_w$quantCI, digits = 3), round(boot_p$quantCI, digits = 3))
    boot_data[ ,"CI"] <- c("2.5%", "97.5%", "2.5%", "97.5%", "2.5%", "97.5%", "2.5%", "97.5%")
    boot_data[ ,"Names"] <- c("log-normal", "", "log-logistic", "", "weibull", "", "pareto", "")
    boot_data <- boot_data[ ,c("Names", "CI", "p=0.01", "p=0.05", "p=0.1")]
    colnames(boot_data) <- c("Names", "CI","HC1%","HC5%","HC10%")
    rownames(boot_data) <- NULL
    print(boot_data)

  })

  # CI 
  output$boot <- renderPrint({
    fit_boot()
  })

  # Download report ----------------------------------------

  output$report <- downloadHandler(
    filename = "report.docx",
    content = function(file) {
      temp_report <- file.path(tempdir(), "report.Rmd")
      temp_image <- file.path(tempdir(), "out.png")
      temp_image2 <- file.path(tempdir(), "out2.png")

      png("out.png")
      cdfreact()
      dev.off()

      png("out2.png")
      print(codeplot())
      dev.off()

      file.copy("out.png", temp_image, overwrite = TRUE)
      file.copy("out2.png", temp_image2, overwrite = TRUE)
      file.copy("report.Rmd", temp_report, overwrite = TRUE)

# Generate dataframes for the report 
      
      dfgof <- as.array(gof())
      dfhc5 <- as.data.frame(hc5())
      dfboot <- as.data.frame(fit_boot())

# Set up parameters for Rmd document 
      
      params <- list(chem_name = input$chem_name,
                     endpoint = input$endpoint,
                     effect = input$effect,
                     sps_group = input$sps_group,
                     chem_type = input$chem_type,
                     exp_type = input$exp_type,
                     test_location = input$test_location,
                     exposure_media = input$exposure_media,
                     media_type = input$media_type,
                     org_lifestage = input$org_lifestage,
                     outgof = dfgof,
                     outhc5 = dfhc5,
                     outboot = dfboot)


      rmarkdown::render("report.Rmd", output_file = file, params = params, envir = new.env(parent = globalenv()))
    }, contentType = 'image/png')}

  
  # Run the app --------------------------------------------

shiny::shinyApp(ui = ui, server = server)
