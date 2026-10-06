boys <- readRDS(test_path("fixtures", "boys.rds"))
options <- readRDS(test_path("fixtures", "mi_options.rds"))

# options$savePath <- savePath <- test_path("tmp", "testSave.jaspImp")
savePath <- tempfile("testSave-", fileext = ".jaspImp")
on.exit(unlink(savePath), add = TRUE)

options$savePath <- savePath
options$tracePlot <- TRUE
options$saveImps <- TRUE

results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

jaspMids <- results[["state"]][["other"]][[1]]
loadMids <- readRDS(savePath)

class(jaspMids)
class(loadMids)

### --------------------------------------------------------------------------------------------------------------------

test_that("Saving imputed data works.", {
  expect_equal(loadMids, jaspMids, ignore_attr = TRUE)
  expect_s3_class(loadMids, class(jaspMids))
})

### --------------------------------------------------------------------------------------------------------------------

# fmt: skip
test_that("Loading imputed data works.", {
  options$impDataSource <- "loadImpData"
  options$saveImps <- FALSE
  options$savePath <- ""
  options$loadImpPath <- savePath

  results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

  expect_equal(
    jaspMids,
    results[["state"]][["other"]][[1]],
    ignore_attr = TRUE
  )

  expect_s3_class(
    results[["state"]][["other"]][[1]],
    c(class(jaspMids), "jaspImputation")
  )

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_bmi"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "bmi-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_gen"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "gen-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_hc"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "hc-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_hgt"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "hgt-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_phb"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "phb-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_reg"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "reg-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_tv"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "tv-trace")

  plotName <- results[["results"]][["ConvergencePlots"]][["collection"]][["ConvergencePlots_TracePlots"]][["collection"]][["ConvergencePlots_TracePlots_wgt"]][["data"]]
  testPlot <- results[["state"]][["figures"]][[plotName]][["obj"]]
  jaspTools::expect_equal_plots(testPlot, "wgt-trace")
})
