library(dplyr)
library(tibble)
library(SummarizedExperiment)
library(DEPstoi)
library(shiny)
library(shinydashboard)

ui <- shinyUI(
	dashboardPage(
		dashboardHeader(title = "DEP - iBAQ"),
		dashboardSidebar(
		  sidebarMenu(
		    menuItem("Files", selected = TRUE,
		      fileInput('file1',
		      					'ProteinGroups.txt',
		      					accept=c('text/csv',
		      									 'text/comma-separated-values,text/plain',
		      									 '.csv')),
  		    fileInput('file2',
  		    					'ExperimentalDesign.txt',
  		    					accept=c('text/csv',
  		    									 'text/comma-separated-values,text/plain',
  		    									 '.csv')),
		      fileInput('file3',
		      					'Peptides.txt',
		      					accept=c('text/csv',
		      									 'text/comma-separated-values,text/plain',
		      									 '.csv')),
		      radioButtons("anno",
		      						 "Sample annotation",
		      						 choices = list("Parse from columns" = "columns",
		      						 							 "Use Experimental Design" = "expdesign"),
		      						 selected = "expdesign")
  		  ),
		    menuItemOutput("columns"),
  			menuItem("Imputation options",
  			  radioButtons("imputation",
  			  						 "Imputation type",
  			  						 choices = c("man", MSnbase::imputeMethods())[1:9],
  			  						 selected = "MinProb"),
  			  p(a("Detailed information link",
  			  		href = "https://www.rdocumentation.org/packages/MSnbase/versions/1.20.7/topics/impute-methods",
  			  		target="_blank"))
  			),
  			div(style="display:inline-block",actionButton("analyze", "Volcano")),
  			div(style="display:inline-block",uiOutput("button_stoi")),
  			tags$hr(),
        uiOutput("downloadTable"),
  			uiOutput("downloadButton1"),
  			tags$hr(),
  			uiOutput("downloadButton2")
  		  )
			),
		dashboardBody(
		  helpText("Please cite:",
		  				 a("Smits et al (2013). Stoichiometry of chromatin-associated protein complexes revealed by label-free quantitative mass spectrometry-based proteomics. Nucleic Acids Research. 41, e28",
		  				 	href="http://nar.oxfordjournals.org/content/41/1/e28.full")),
		  fluidRow(
		    box(numericInput("p",
		    								 "adj. P value",
		    								 min = 0.0001,
		    								 max = 0.1,
		    								 value = 0.05),
		    		width = 2),
		    box(numericInput("lfc",
		    								 "Log2 fold change",
		    								 min = 0,
		    								 max = 10,
		    								 value = 1),
		    		width = 2),
				infoBoxOutput("signBox"),
				box(radioButtons("pres",
												 "Data presentation",
												 c("contrast", "centered"),
												 selected = "contrast"),
						width = 2),
				box(radioButtons("contrasts",
												 "Contrasts",
												 c("control", "all"),
												 selected = "control"),
						width = 2)
			),
			fluidRow(
			  column(width = 7,
			    tabBox(title = "Tables", width = 12,
			      tabPanel(title = "Top Table",
			      				 box(uiOutput("select"), width = 6),
			      				 box(uiOutput("exclude"), width = 6),
			      				 DT::dataTableOutput("table")),
			      tabPanel(title = "Stoichiometry",
			      				 DT::dataTableOutput("stoi_table"))
			    )
			  ),
			  column(width = 5,
  				tabBox(title = "Result Plots", width = 12,
  				  tabPanel(title = "Selected Protein",
  				  				 plotOutput("selected_plot"),
  				  				 downloadButton('downloadPlot', 'Save plot')),
  				  tabPanel(title = "Heatmap",
  				    fluidRow(
  				      box(numericInput("k",
  				      								 "Kmeans clusters",
  				      								 min = 0,
  				      								 max = 15,
  				      								 value = 7),
  				      		width = 4),
  				      box(numericInput("limit",
  				      								 "Color limit (log2)",
  				      								 min = 0,
  				      								 max = 16,
  				      								 value = 6),
  				      		width = 4),
  				      box(numericInput("size",
  				      								 "Heatmap size (4-30)",
  				      								 min = 4,
  				      								 max = 30,
  				      								 value = 10),
  				      		width = 4)
  				    ),
  				    fluidRow(
  				      uiOutput("plot"),
  				      downloadButton('downloadHeatmap', 'Save heatmap'))
  				  ),
  				  tabPanel(title = "Volcano plot",
  				    fluidRow(
  				      box(uiOutput("volcano_cntrst"), width = 6),
  				      box(numericInput("fontsize",
  				      								 "Font size",
  				      								 min = 0,
  				      								 max = 8,
  				      								 value = 4),
  				      		width = 3),
  				      box(checkboxInput("check_names",
  				      									"Display names",
  				      									value = TRUE),
  				      		checkboxInput("p_adj",
  				      									"Adjusted p values",
  				      									value = FALSE),
  				      		width = 3)
  				    ),
  				    fluidRow(
  				      plotOutput("volcano", height = 600),
  				      downloadButton('downloadVolcano', 'Save volcano')
  				    )
  				  ),
  				  tabPanel(title = "iBAQ vs LFC plot",
  				           fluidRow(
  				             box(uiOutput("ibaq_cntrst"), width = 6),
  				             box(numericInput("ibaq_fontsize",
  				             								 "Font size",
  				             								 min = 0,
  				             								 max = 8,
  				             								 value = 2),
  				             		width = 6)
  				           ),
  				           fluidRow(
  				             plotOutput("ibaq_plot", height = 600),
  				             downloadButton('downloadIBAQ', 'Save iBAQ plot')
  				           )
  				  ),
  				  tabPanel(title = "Stoichiometry plot",
  				           fluidRow(
  				             box(uiOutput("stoi_cntrst"), width = 4),
  				             box(uiOutput("stoi_bait"), width = 4),
  				             box(numericInput("thr",
  				             								 "Threshold",
  				             								 min = 0,
  				             								 max = 1,
  				             								 value = 0.01),
  				             		width = 4)
  				           ),
  				           fluidRow(
  				             plotOutput("stoi", height = 600),
  				             downloadButton('downloadStoi', 'Save stoichiometry')
  				           )
  				  )
				  ),
  				tabBox(title = "QC Plots", width = 12,
  				  tabPanel(title = "Protein Numbers",
  				    plotOutput("numbers", height = 600),
  				    downloadButton('downloadNumbers', 'Save')
  				  ),
  				  tabPanel(title = "Sample coverage",
  				    plotOutput("coverage", height = 600),
  				    downloadButton('downloadCoverage', 'Save')
  				  ),
  			    tabPanel(title = "Normalization",
  				    plotOutput("norm", height = 600),
  				    downloadButton('downloadNorm', 'Save')
  				  ),
  				  tabPanel(title = "Missing values - Quant",
  				           plotOutput("detect", height = 600),
  				           downloadButton('downloadDetect', 'Save')
  				  ),
  				  tabPanel(title = "Missing values - Heatmap",
  				    plotOutput("missval", height = 600),
  				    downloadButton('downloadMissval', 'Save')
  				  ),
  				  tabPanel(title = "Imputation",
  				           plotOutput("imputation", height = 600),
  				           downloadButton('downloadImputation', 'Save')
  				  )
  				)
			  )
			)
		)
	)
)

server <- shinyServer(function(input, output) {
  options(shiny.maxRequestSize=200*1024^2)

  ### UI functions ### ----------------------------------------------------------------------------------------------------------------

  output$columns <- renderMenu({
    menuItem("Columns",
             selectizeInput("name",
             							 "Name column",
             							 choices=colnames(data()),
             							 selected = "Gene.names"),
             selectizeInput("id",
             							 "ID column",
             							 choices=colnames(data()),
             							 selected = "Protein.IDs"),
             selectizeInput("filt",
             							 "Filter on columns" ,
             							 colnames(data()),
             							 multiple = TRUE,
             							 selected = c("Reverse","Potential.contaminant")),
             if (input$anno == "columns" & !is.null(data())) {
               cols <- grep("^LFQ", colnames(data()))
               prefix <- get_prefix(data()[,cols] %>% colnames())
               selectizeInput("control",
               							 "Control",
               							 choices = make.names(colnames(data())[cols] %>%
               							 										 	gsub(prefix,"",.) %>%
               							 										 	substr(., 1, nchar(.)-1)))
             },
             if (input$anno == "expdesign" & !is.null(expdesign())) {
             	selectizeInput("control",
             								 "Control",
             								 choices=make.names(expdesign()$condition))
             }

    )
  })

  ### Reactive functions ### ----------------------------------------------------------------------------------------------------------
  data <- reactive({
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    data <- read.csv(inFile$datapath, header=T,
    								 sep="\t", stringsAsFactors = F)
  })
  expdesign <- reactive({
    inFile <- input$file2
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath, header=T,
    				 sep="\t", stringsAsFactors = F)
  })
  peptides <- reactive({
    inFile <- input$file3
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath, header=T,
    				 sep="\t", stringsAsFactors = F)
  })

  data_unique <- reactive({
    data <- data()
    make_unique(data, input$name, input$id)
  })

  filt <- reactive({
    data <- data_unique()
    cols <- grep("^LFQ", colnames(data))
    filtered <- DEP:::filter_MaxQuant(data, input$filt)

    if (input$anno == "columns") {
    	se <- make_se_parse(filtered, cols)
    }
    if (input$anno == "expdesign") {
    	se <- make_se(filtered, cols, expdesign())
    }
    filter_missval(se, 0)
  })

  norm <- reactive({
    normalize_vsn(filt())
  })

  imp <- reactive({
    DEP::impute(norm(), input$imputation)
  })

  df <- reactive({
    test_diff(imp(), input$contrasts, input$control)
  })

  dep <- reactive({
    add_rejections(df(), input$p, input$lfc)
  })

  ### All object and functions upon 'Analyze' input  ### ---------------------------------------------------------------------------

  observeEvent(input$analyze, {

    ### Interactive UI functions ### ----------------------------------------------------------------------------------------------

    output$button_stoi <- renderUI ({
    	if (!is.null(peptides())) {
    		actionButton("stoichiometry", "Stoichiometry")
    	}
    })

    output$downloadTable <- renderUI({
      selectizeInput("dataset",
      							 "Choose a dataset to save" ,
      							 c("results",
      							 	"significant_proteins",
      							 	"displayed_subset",
      							 	"full_dataset"))
    })

    output$downloadButton1 <- renderUI({
      downloadButton('downloadData', 'Save')
    })

    output$signBox <- renderInfoBox({
      infoBox("Significant proteins",
      				paste(dep() %>%
      								.[rowData(.)$significant, ] %>%
      								nrow(), " out of", dep() %>%
      								nrow(), sep = " "),
      				icon = icon("thumbs-up", lib = "glyphicon"),
      				color = "green",
      				width = 4)
    })

    output$select <- renderUI({
      row_data <- rowData(dep())
      cols <- grep("_significant",colnames(row_data))
      names <- colnames(row_data)[cols]
      names <- gsub("_significant", "", names)
      selectizeInput("select",
      							 "Select direct comparisons",
      							 choices=names,
      							 multiple = TRUE)
    })

    output$exclude <- renderUI({
      row_data <- rowData(dep())
      cols <- grep("_significant",colnames(row_data))
      names <- colnames(row_data)[cols]
      names <- gsub("_significant", "", names)
      selectizeInput("exclude",
      							 "Exclude direct comparisons",
      							 choices=names,
      							 multiple = TRUE)
    })

    output$volcano_cntrst <- renderUI({
      if (!is.null(selected())) {
        df <- rowData(selected())
        cols <- grep("_significant$",colnames(df))
        selectizeInput("volcano_cntrst",
        							 "Contrast",
        							 choices = gsub("_significant", "", colnames(df)[cols]))
      }
    })

    output$ibaq_cntrst <- renderUI({
      if (!is.null(selected())) {
        df <- rowData(selected())
        cols <- grep("_significant$",colnames(df))
        selectizeInput("ibaq_cntrst",
        							 "Contrast",
        							 choices = gsub("_significant", "", colnames(df)[cols]))
      }
    })

    ### Reactive functions ### ----------------------------------------------------------------------------------------------
    excluded <- reactive({
    	DEP:::exclude_deps(dep(), input$exclude)
    })

    selected <- reactive({
    	DEP:::select_deps(excluded(), input$select)
    })

    res <- reactive({
      get_results(selected())
    })

    table <- reactive({
    	DEP:::get_table(res(), input$pres)
    })

    selected_plot_input <- reactive ({
      if(!is.null(input$table_rows_selected)) {
        selected_id <- table()[input$table_rows_selected,1]
        plot_single(selected(), selected_id, input$pres)
      }
    })

    heatmap_input <- reactive({
      withProgress(message = 'Plotting', value = 0.66, {
        plot_heatmap(selected(),
        						 input$pres,
        						 kmeans = TRUE,
        						 input$k,
        						 input$limit)
      })
    })

    volcano_input <- reactive({
      if(!is.null(input$volcano_cntrst)) {
        plot_volcano(selected(),
        						 input$volcano_cntrst,
        						 input$fontsize,
        						 input$check_names,
        						 input$p_adj)
      }
    })

    ibaq_input <- reactive({
      if(!is.null(input$ibaq_cntrst)) {
        plot_ibaq(selected(),
        					input$ibaq_cntrst,
        					input$ibaq_fontsize)
      }
    })

    norm_input <- reactive({
      plot_normalization(filt(), norm())
    })

    missval_input <- reactive({
      plot_missval(norm())
    })

    detect_input <- reactive({
      plot_detect(norm())
    })

    imputation_input <- reactive({
      plot_imputation(norm(), df())
    })

    numbers_input <- reactive({
      plot_numbers(norm())
    })

    coverage_input <- reactive({
      plot_coverage(norm())
    })

    ### Output functions ### ----------------------------------------------------------------------------------------------
    output$table <- DT::renderDataTable({
      table()
    }, options = list(pageLength = 25, scrollX = T),
    selection = list(selected = c(1)))

    output$selected_plot <- renderPlot({
      selected_plot_input()
    })

    output$heatmap <- renderPlot({
      heatmap_input()
    })

    output$volcano <- renderPlot({
      volcano_input()
    })

    output$ibaq_plot <- renderPlot({
      ibaq_input()
    })

    output$norm <- renderPlot({
      norm_input()
    })

    output$missval <- renderPlot({
      missval_input()
    })

    output$detect <- renderPlot({
      detect_input()
    })

    output$imputation <- renderPlot({
      imputation_input()
    })

    output$numbers <- renderPlot({
      numbers_input()
    })

    output$coverage <- renderPlot({
      coverage_input()
    })

    observe({
      output$plot <- renderUI({
        plotOutput("heatmap", height = (100 * as.numeric(input$size)))
      })
    })

    ### Download objects and functions ### ---------------------------------------------------------------------------------
    datasetInput <- reactive({
      switch(input$dataset,
             "results" = get_results(dep()),
             "significant_proteins" = get_results(dep()) %>%
      			 	filter(significant) %>%
      			 	select(-significant),
             "displayed_subset" = res() %>%
      			 	filter(significant) %>%
      			 	select(-significant),
             "full_dataset" = get_df_wide(dep()))
    })

    output$downloadData <- downloadHandler(
      filename = function() { paste(input$dataset, ".txt", sep = "") },
      content = function(file) {
      	write.table(datasetInput(),
      							file,
      							col.names = TRUE,
      							row.names = FALSE,
      							sep ="\t")
      }
    )

    output$downloadPlot <- downloadHandler(
      filename = function() {
      	paste("Barplot_", table()[input$table_rows_selected,1], ".pdf", sep = "")
      },
      content = function(file) {
        pdf(file)
        print(selected_plot_input())
        dev.off()
      }
    )

    output$downloadHeatmap <- downloadHandler(
      filename = 'Heatmap.pdf',
      content = function(file) {
        pdf(file, height = 10, paper = "a4")
        print(heatmap_input())
        dev.off()
      }
    )

    output$downloadVolcano <- downloadHandler(
      filename = function() {
      	paste("Volcano_", input$contrast, ".pdf", sep = "")
      },
      content = function(file) {
        pdf(file)
        print(volcano_input())
        dev.off()
      }
    )

    output$downloadIBAQ <- downloadHandler(
      filename = function() {
      	paste("iBAQ_vs_LFC_", input$contrast, ".pdf", sep = "")
      },
      content = function(file) {
        pdf(file)
        print(ibaq_input())
        dev.off()
      }
    )

    output$downloadNorm <- downloadHandler(
      filename = "normalization.pdf",
      content = function(file) {
        pdf(file)
        print(norm_input())
        dev.off()
      }
    )

    output$downloadMissval <- downloadHandler(
      filename = "missing_values_heatmap.pdf",
      content = function(file) {
        pdf(file)
        print(missval_input())
        dev.off()
      }
    )

    output$downloadDetect <- downloadHandler(
      filename = "missing_values_quant.pdf",
      content = function(file) {
        pdf(file)
        gridExtra::grid.arrange(detect_input())
        dev.off()
      }
    )

    output$downloadImputation <- downloadHandler(
      filename = "imputation.pdf",
      content = function(file) {
        pdf(file)
        print(imputation_input())
        dev.off()
      }
    )

    output$downloadNumbers <- downloadHandler(
      filename = "numbers.pdf",
      content = function(file) {
        pdf(file)
        print(numbers_input())
        dev.off()
      }
    )

    output$downloadCoverage <- downloadHandler(
      filename = "coverage.pdf",
      content = function(file) {
        pdf(file)
        print(coverage_input())
        dev.off()
      }
    )

    ### All object and functions upon 'Stoichiometry' input  ### ---------------------------------------------------------------------------

    observeEvent(input$stoichiometry, {

      ### Interactive UI functions ### ----------------------------------------------------------------------------------------------

      output$downloadButton2 <- renderUI({
        downloadButton('downloadStoiTable', 'Save Stoichiometry')
      })

      output$stoi_cntrst <- renderUI({
        if (!is.null(dep())) {
          df <- rowData(dep())
          cols <- grep("_significant$",colnames(df))
          selectizeInput("stoi_cntrst",
          							 "Contrast",
          							 choices = gsub("_significant", "", colnames(df)[cols]))
        }
      })

      output$stoi_bait <- renderUI({
        if (!is.null(ibaq()) & !is.null(dep()) & !is.null(input$stoi_cntrst)) {
          row_data <- rowData(dep())
          ibaq <- ibaq()
          contrast <- input$stoi_cntrst
          col_sign <- grep(paste(contrast, "_significant", sep = ""),
          								 colnames(row_data)) # All significance columns
          row_data <- row_data[row_data[,col_sign], ]
          names <- row_data$name
          rows <- ibaq %>%
          	select(starts_with("name_")) %>%
          	apply(., 2, function(x) grep(paste("^", names, "$", sep = "", collapse = "|"), x)) %>%
          	unlist() %>%
          	unique()
          sub <- ibaq[rows,] %>%
          	select(name, starts_with("iBAQ.")) %>%
          	tidyr::gather(sample, iBAQ, 2:ncol(.)) %>%
          	group_by(name) %>%
          	summarize(mean = mean(iBAQ)) %>%
          	arrange(desc(mean))
          selectizeInput("stoi_bait", "Bait", choices = sub$name)
        }
      })

      ### Reactive functions ### ----------------------------------------------------------------------------------------------

      ibaq <- reactive({
        merge_ibaq(data_unique(), peptides())
      })

      stoi <- reactive({
        req(input$stoi_cntrst, input$stoi_bait)
      	get_stoichiometry(dep(), ibaq(), input$stoi_cntrst, input$stoi_bait)
      })

      input_plot_stoi <- reactive({
        if(!is.null(stoi())) {
          plot_stoichiometry(stoi(), thr = input$thr)
        }
      })

      ### Output functions ### ----------------------------------------------------------------------------------------------

      output$stoi_table <- DT::renderDataTable({
        stoi()
      }, options = list(pageLength = 25, scrollX = T))

      output$stoi <- renderPlot({
        input_plot_stoi()
      })

      ### Download objects and functions ### ---------------------------------------------------------------------------------

      output$downloadStoiTable <- downloadHandler(
        filename = function() { "stoichiometry.txt" },
        content = function(file) {
        	write.table(stoi(),
        							file,
        							col.names = TRUE,
        							row.names = FALSE,
        							sep ="\t")
        }
      )

      output$downloadStoi <- downloadHandler(
        filename = "stoichiometry.pdf",
        content = function(file) {
          pdf(file)
          print(input_plot_stoi())
          dev.off()
        }
      )

    })

  })
})


shinyApp(ui = ui, server = server)
