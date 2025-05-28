test_that(".processImputationOptions returns expected output", {

  options <- jaspTools::analysisOptions("MissingDataImputation")
  options$imputationVariables <- list(
    optionKey = "variable",
    types = c("scale", "nominal", "scale"),
    value = list(
      list(method = "pmm", variable = "hgt"),
      list(method = "logreg", variable = "reg"),
      list(method = "pmm", variable = "bmi")
    )
  )
  expect_equal(
    .processImputationOptions(options)$imputationTargets,
    c("hgt", "reg", "bmi")
  )
  expect_equal(
    .processImputationOptions(options)$imputationMethods,
    c(hgt = "pmm", reg = "logreg", bmi = "pmm")
  )
  expect_equal(
    .processImputationOptions(options)$imputedVariables,
    ""
  )
  expect_equal(
    .processImputationOptions(options)$fType,
    1
  )
  expect_equal(
    .processImputationOptions(options)$lmFunction,
    pooledLm
  )
})
