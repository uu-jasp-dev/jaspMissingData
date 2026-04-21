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
    options$rHats <- TRUE

    results <- jaspTools::runAnalysis("MissingDataImputation", boys, options, makeTests = TRUE)

	table <- results[["results"]][["RHatsTable"]][["data"]]
	jaspTools::expect_equal_tables(table,
		list(2.67379679144385, 1.21308542096154, 1.31596919371433, "hgt", 0.53475935828877,
			 2.364649466864, 2.40821869308255, "wgt", 2.80748663101604, 1.59316528159034,
			 1.93359479402224, "bmi", 6.14973262032086, 1.04004681378673,
			 1.02795572032064, "hc", 67.2459893048128, 0.970509869230375,
			 1.02878779537377, "gen", 67.2459893048128, 1.04627516399056,
			 0.978316455318444, "phb", 69.7860962566845, 1.14705285955143,
			 1.00179589287088, "tv", 0.401069518716578, 0.992327859444602,
			 0.988527469182713, "reg"))
  }
)
