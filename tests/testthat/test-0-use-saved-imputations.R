test_that("A full MI run works.",
  {
    boys <- readRDS(test_path("fixtures", "boys.rds"))

    impMethods <- mice::make.method(boys)

    options <- addImputationVariables(
      options   = jaspTools::analysisOptions("MissingDataImputation"),
      variables = colnames(boys),
      methods   = impMethods,
      types     = c("scale", "scale", "scale", "scale", "scale", "ordinal", "ordinal", "scale", "nominal")
    )
    
    options$saveImps <- TRUE
    options$savePath <- paste0(
      here::here(), "/", test_path("fixtures", "testSaveForLoad.jaspImp")
    )
    options$tracePlot <- TRUE
    results1 <- jaspTools::runAnalysis("MissingDataImputation", boys, options, makeTests = TRUE)
    
    options$saveImps <- FALSE
    options$savePath <- ""

    options$loadImpPath <- testthat::test_path("fixtures", "testSaveForLoad.jaspImp")
    results2 <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

	  plotName <- results2[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlot"]][["data"]]
	  testPlot <- results2[["state"]][["figures"]][[plotName]][["obj"]]
	  
    jaspTools::expect_equal_plots(testPlot, "trace-plot")
    expect_equal(
      results1[["state"]][["other"]][[1]],
      results2[["state"]][["other"]][[1]]
    )
  }
)
