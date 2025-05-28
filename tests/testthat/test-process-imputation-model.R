test_that(".processImpModel returns correct formulas", {
  dataset <- mice::boys
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
    formulas
  )
  options$changeNullModel <- "hgt ~ wgt"
  expect_error(
    .processImpModel(dataset, options, predMat)
  )
  options$changeNullModel <- "hgt2 ~ wgt"
  expect_error(
    .processImpModel(dataset, options, predMat)
  )
})
