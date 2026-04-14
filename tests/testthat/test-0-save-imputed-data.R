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
      here::here(), "/", test_path("fixtures", "testSave.jaspImp")
    )

    results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

    expect_equal(
      results[["state"]][["other"]][[1]],
      readRDS(test_path("fixtures", "testSave.jaspImp"))$mids
    )
  }
)
