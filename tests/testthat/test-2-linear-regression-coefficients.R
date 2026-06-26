# rm(list = ls(all = TRUE))
#
# remotes::install_github("kylelang/jaspRegression@missingData")
#
# setupJaspTools()
# install.packages("here")
#
# library(testthat)
# library(mice)
# library(dplyr)
# library(jaspTools)
#
# setPkgOption("module.dirs", here::here())
#
# setwd(here::here())
# source(test_path("setup.R"))

boys <- readRDS(test_path("fixtures", "boys.rds"))
miceMids <- readRDS(test_path("fixtures", "mice_mids.rds"))
options <- readRDS(test_path("fixtures", "lin_reg_options.rds"))

options$covarianceMatrix <- TRUE

results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

# Extract and processing the coefficients table from JASP
coefTab <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffTable"]][["data"]]
jaspCoefTab <- data.frame(
  est = sapply(coefTab, "[[", x = "unstandCoeff"),
  se = sapply(coefTab, "[[", x = "SE"),
  t = sapply(coefTab, "[[", x = "t"),
  p = sapply(coefTab, "[[", x = "p")
)

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pooled correctly for an intercept-only model.", {
  mipoCoef <- with(miceMids, lm(tv ~ 1)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  expect_equal(head(jaspCoefTab, 1), mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly with only numeric predictors.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  jaspCoefTab[2:4, ] |>
    data.frame(row.names = 1:3) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("Linear regression parameters pool correctly with numeric and categorical predictors.", {
  mipoCoef <- with(miceMids, lm(tv ~ hgt + wgt + reg)) |>
    mice::pool() |>
    summary() |>
    dplyr::select(-term, -df) |>
    as.data.frame()

  colnames(mipoCoef) <- c("est", "se", "t", "p")

  tail(jaspCoefTab, 7) |>
    data.frame(row.names = 1:7) |>
    expect_equal(mipoCoef)
})

### --------------------------------------------------------------------------------------------------------------------

test_that("The coefficients covariance matrices are pooled correctly.", {})

### --------------------------------------------------------------------------------------------------------------------

# fmt: skip
test_that("Coefficients table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffTable"]][["data"]]
	jaspTools::expect_equal_tables(
    table,
		list(
      "FALSE", 0.317136961972974,  "M<unicode>", "(Intercept)", 1.35330367518679e-68, 26.8975708497525,  8.53021390374332,
      "TRUE",  1.12294585537918,   "M<unicode>", "(Intercept)", 0.623439537219199,    0.501333872418568, 0.562970794193624,
      "FALSE", 0.0143862762569725, "M<unicode>", "hgt",         0.103017056467338,    "",                -1.71107017886869, -0.0246159282882723,
      "FALSE", 0.0235543976790782, "M<unicode>", "wgt",         2.26827112777922e-14, "",                12.7906300989981,  0.301275587917789,
      "TRUE",  1.14364457591177,   "M<unicode>", "(Intercept)", 0.835784106152615,    0.209392120408636, 0.239470162744001,
      "FALSE", 0.0149121191054207, "M<unicode>", "hgt",         0.0752398180676156,   "",                -1.90983633392695, -0.0284797068833786,
      "FALSE", 0.0241501272576832, "M<unicode>", "wgt",         1.23922439792427e-12, "",                13.0111237547281,  0.314220294442148,
      "FALSE", 1.00543719969302,   "M<unicode>", "reg (east)",  0.542292613001919,    0.6303635594114,   0.633790971963124,
      "FALSE", 0.953701784350436,  "M<unicode>", "reg (north)", 0.0134465278143179,   -2.70670672925286, -2.58139103740179,
      "FALSE", 0.889180258751549,  "M<unicode>", "reg (south)", 0.383197362172974,    0.901355194941502, 0.801467245465137,
      "FALSE", 0.731908549034349,  "M<unicode>", "reg (west)",  0.228924837688115,    1.22763875396341,  0.898519299151693
    )
  )
})

### --------------------------------------------------------------------------------------------------------------------

# fmt: skip
test_that("Coefficients Covariance Matrix table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_coeffCovMatrixTable"]][["data"]]
	jaspTools::expect_equal_tables(
    table,
		list(
      "TRUE",  0.00020696494454193,  "M<unicode>", "hgt",         "",                   "",                   "",                   "",                  -0.000323630371339812,
      "FALSE", "",                   "M<unicode>", "wgt",         "",                   "",                   "",                   "",                  0.000554809650024162,
      "TRUE",  0.000222371296214252, "M<unicode>", "hgt",         -0.00654075922958338, -0.00371701880119683, -0.00453491157177295, -0.0016099510620988, -0.000345122815213528,
      "FALSE", "",                   "M<unicode>", "wgt",         0.0091067673272683,   0.00466488512459495,  0.00637937962480349,  0.00212160674735191, 0.000583228646562292,
      "FALSE", "",                   "M<unicode>", "reg (east)",  1.01090396252654,     0.743951985474387,    0.773924650974141,    0.561347905525883,   "",
      "FALSE", "",                   "M<unicode>", "reg (north)", "",                   0.909547093473206,    0.669189476374106,    0.52322635874467,    "",
      "FALSE", "",                   "M<unicode>", "reg (south)", "",                   "",                   0.790641532553472,    0.523987552453788,   "",
      "FALSE", "",                   "M<unicode>", "reg (west)",  "",                   "",                   "",                   0.535690124149566,   ""
    )
  )
})
