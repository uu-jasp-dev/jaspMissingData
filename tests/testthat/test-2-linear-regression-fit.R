boys <- readRDS(test_path("fixtures", "boys.rds"))
miceMids <- readRDS(test_path("fixtures", "mice_mids.rds"))
options <- readRDS(test_path("fixtures", "lin_reg_options.rds"))

miraList <- list(
  with(miceMids, lm(tv ~ 1)),
  with(miceMids, lm(tv ~ hgt + wgt)),
  with(miceMids, lm(tv ~ hgt + wgt + reg))
)

options$modelAICBIC <- TRUE
options$fChange <- TRUE

## Some previous test nukes the environment, so we need to re-export all our private functions
devtools::load_all()

### --------------------------------------------------------------------------------------------------------------------

options$fStat <- "d1"
options$llEst <- "qBar"

## Test everything
results <- testFitStats(miraList, boys, options)

fD1 <- getJaspFStats(results)
icQBar <- getJaspInfoCriteria(results)

# fmt: skip
test_that("ANOVA table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_anovaTable"]][["data"]]
	jaspTools::expect_equal_tables(table,
		list(
      "TRUE",  542.025163199051, 11536.6226392655, 23073.2452785309, "Regression",     2,                "M<unicode>", 1.19164542292206e-21,
      "FALSE", 21.2842934655947, 543.858206039319,                   "Residual",       25.5520911191366, "M<unicode>",
      "FALSE", 23617.1034845703,                                     "Total",          27.5520911191366, "M<unicode>",
      "TRUE",  188.141580750973, 3804.70649322502, 22828.2389593501, "Regression",     6,                "M<unicode>", 5.88099608737267e-56,
      "FALSE", 20.2225710979912, 2257.05294597123,                   "Residual",       111.610582800494, "M<unicode>",
      "FALSE", 25085.2919053214,                                     "Total",          117.610582800494, "M<unicode>"
    )
  )
})

# fmt: skip
test_that("Model Summary - tv table results match", {
  table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_summaryTable"]][["data"]]
  jaspTools::expect_equal_tables(table,
    list(
      5264.07217032725, 5273.3069762832,  "",               0,                 0,                 "",                 8.20888313504352, 0,                 0, 201.429231532675, "M<unicode>", "",
      4389.35883672888, 4407.82844864078, 542.025163199051, 0.831476298586239, 0.691352835110672, 0.691352835110672,  4.61349037775031, 0.690524102452899, 2, 25.5520911191366, "M<unicode>", 1.19164542292206e-21,
      4356.67603861978, 4393.61526244358, 6.49794128714925, 0.841627248054181, 0.708336424667255, 0.0169835895565824, 4.49695131149885, 0.705974382467772, 4, 68.4136454937619, "M<unicode>", 0.000171321455737634
    )
  )
})

### --------------------------------------------------------------------------------------------------------------------

devtools::load_all()

options$fStat <- "d2"
options$llEst <- "qHat"

## Don't test R^2: it doesn't change based on fStat or llEst
results <- testFitStats(miraList, boys, options, what = c("f", "ic"))

fD2 <- getJaspFStats(results)
icQHat <- getJaspInfoCriteria(results)

test_that(
  "The value of 'llEst' affects the information criteria.",
  expect_equal(
    unlist(icQBar) == unlist(icQHat),
    c(TRUE, FALSE, FALSE, TRUE, FALSE, FALSE),
    ignore_attr = TRUE
  )
)

# fmt: skip
test_that("ANOVA table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_anovaTable"]][["data"]]
	jaspTools::expect_equal_tables(table,
		list(
      "TRUE",  342.244248655022, 7284.42702528546, 14568.8540505709, "Regression",     2,                "M<unicode>", 3.56730541772611e-08,
      "FALSE", 21.2842934655947, 161.820101589705,                   "Residual",       7.60279413790647, "M<unicode>",
      "FALSE", 14730.6741521606,                                     "Total",          9.60279413790647, "M<unicode>",
      "TRUE",  119.421264388623, 2415.00500971095, 14490.0300582657, "Regression",     6,                "M<unicode>", 0.000263186551573597,
      "FALSE", 20.2225710979912, 76.8825801434865,                   "Residual",       3.80182024189414, "M<unicode>",
      "FALSE", 14566.9126384092,                                     "Total",          9.80182024189414, "M<unicode>"
    )
  )
})

# fmt: skip
test_that("Model Summary - tv table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_summaryTable"]][["data"]]
	jaspTools::expect_equal_tables(table,
		list(
      5264.07217032725, 5273.3069762832,  "",               0,                 0,                 "",                 8.20888313504352, 0,                 0, 201.429231532675, "M<unicode>", "",
      4388.66323124355, 4407.13284315545, 342.244248655022, 0.831476298586239, 0.691352835110672, 0.691352835110672,  4.61349037775031, 0.690524102452899, 2, 7.60279413790647, "M<unicode>", 3.56730541772611e-08,
      4354.3338058514,  4391.27302967519, 10.1641040943534, 0.841627248054181, 0.708336424667255, 0.0169835895565824, 4.49695131149885, 0.705974382467772, 4, 678.259294458718, "M<unicode>", 5.38195908886006e-08
    )
  )
})

### --------------------------------------------------------------------------------------------------------------------

devtools::load_all()

options$fStat <- "d3"

## Don't test AIC/BIC: they only depend on llEst, not fStat
results <- testFitStats(miraList, boys, options, what = "f")

fD3 <- getJaspFStats(results)

test_that("The value of 'fStat' affects the F statistics.", {
  expect_disjoint(fD1, fD2)
  expect_disjoint(fD1, fD3)
  expect_disjoint(fD2, fD3)
})

# fmt: skip
test_that("ANOVA table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_anovaTable"]][["data"]]
	jaspTools::expect_equal_tables(
    table,
		list(
      "TRUE",  288.726739159353, 6145.34464763188, 12290.6892952638, "Regression", 2,                "M<unicode>", 2.62000824959559e-19,
      "FALSE", 21.2842934655947, 591.011756652411,                   "Residual",   27.7675064764428, "M<unicode>",
      "FALSE", 12881.7010519162,                                     "Total",      29.7675064764428, "M<unicode>",
      "TRUE",  96.6427403180656, 1954.36468718679, 11726.1881231207, "Regression", 6,                "M<unicode>", 1.66585523137147e-46,
      "FALSE", 20.2225710979912, 2742.81723307344,                   "Residual",   135.631479290281, "M<unicode>",
      "FALSE", 14469.0053561942,                                     "Total",      141.631479290281, "M<unicode>"
    )
  )
})

# fmt: skip
test_that("Model Summary - tv table results match", {
	table <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_summaryTable"]][["data"]]
	jaspTools::expect_equal_tables(table,
		list(
      5264.07217032725, 5273.3069762832,  "",               0,                 0,                 "",                 8.20888313504352, 0,                 0, 201.429231532675, "M<unicode>", "",
      4388.66323124355, 4407.13284315545, 288.726739159353, 0.831476298586239, 0.691352835110672, 0.691352835110672,  4.61349037775031, 0.690524102452899, 2, 27.7675064764428, "M<unicode>", 2.62000824959559e-19,
      4354.3338058514,  4391.27302967519, 6.28797056778446, 0.841627248054181, 0.708336424667255, 0.0169835895565824, 4.49695131149885, 0.705974382467772, 4, 74.1048688479238, "M<unicode>", 0.000206126409128476
    )
  )
})
