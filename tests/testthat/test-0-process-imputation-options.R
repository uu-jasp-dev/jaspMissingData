test_that(".processImputationOptions returns expected output", {
  options <- addImputationVariables(
    options = readRDS(test_path("fixtures", "mi_options.rds")),
    variables = c("hgt", "reg", "bmi"),
    methods = c("pmm", "logreg", "pmm"),
    types = c("scale", "nominal", "scale")
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
})
