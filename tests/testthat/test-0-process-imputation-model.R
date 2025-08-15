test_that(".processImpModel returns correct formulas",
  {
    dataset <- readRDS(test_path("fixtures", "boys.rds"))

    options <- jaspTools::analysisOptions("MissingDataImputation")
    predMat <- mice::make.predictorMatrix(dataset)
    formulas <- mice::make.formulas(dataset, predictorMatrix = predMat)
    expect_equal(
      .processImpModel(dataset, options, predMat),
      formulas
    )

    options$changeFullModel <- "hgt ~ -wgt + I(bmi^2)"
    formulas$hgt <- update(formulas$hgt, ~ . -wgt + I(bmi^2))
    expect_equal(
      .processImpModel(dataset, options, predMat),
      formulas
    )

    options$changeNullModel <- "wgt ~ reg"
    formulas$wgt <- update(formulas$wgt, ~ reg)
    expect_equal(
      .processImpModel(dataset, options, predMat),
      formulas,
      ignore_formula_env = TRUE # testthat e3 migration
    )

    options$changeNullModel <- "hgt ~ wgt"
    expect_error(
      .processImpModel(dataset, options, predMat)
    )

    options$changeNullModel <- "hgt2 ~ wgt"
    expect_error(
      .processImpModel(dataset, options, predMat)
    )
  }
)

### testthat 3e migration:
## - testthat 3e uses waldo::compare() in place of base::all.equal(), so we need to ignore some environmental attibutes
## - More info: https://www.tidyverse.org/blog/2022/02/upkeep-testthat-3/#comparing-things--
