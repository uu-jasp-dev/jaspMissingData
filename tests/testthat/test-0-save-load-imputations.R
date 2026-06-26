boys <- readRDS(test_path("fixtures", "boys.rds"))
options <- readRDS(test_path("fixtures", "mi_options.rds"))

options$tracePlot <- TRUE
options$saveImps <- TRUE
options$savePath <- savePath <- test_path("tmp", "testSave.jaspImp")

results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

jaspMids <- results[["state"]][["other"]][[1]]
loadMids <- readRDS(savePath)

### --------------------------------------------------------------------------------------------------------------------

test_that("Saving imputed data works.", {
  expect_equal(loadMids, jaspMids, ignore_attr = TRUE)
  expect_s3_class(loadMids, class(jaspMids))
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Loading imputed data works.", {
  options$impDataSource <- "loadImpData"
  options$saveImps <- FALSE
  options$savePath <- ""
  options$loadImpPath <- savePath

  results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlot"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]

  jaspTools::expect_equal_plots(testPlot, "trace-plot")
  expect_equal(
    jaspMids,
    results[["state"]][["other"]][[1]]
  )
})

unlink(savePath)
