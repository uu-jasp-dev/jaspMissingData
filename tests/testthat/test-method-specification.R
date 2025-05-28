
test_that(".makeMethodVector works", {
  data <- mice::boys[,c("hgt", "wgt", "bmi")]
  options <- list(
    imputationTargets = c("hgt", "wgt", "bmi"),
    imputationMethods = c("pmm", "pmm", "pmm")
  )
  expect_equal(
    .makeMethodVector(data, options),
    c("pmm", "pmm", "pmm") |> setNames(colnames(data))
  )
  options$imputationMethods <- c("pmm", "norm", "norm")
  expect_equal(
    .makeMethodVector(data, options),
    c("pmm", "norm", "norm") |> setNames(colnames(data))
  )
  options$imputationMethods <- c("pmm", "logistic", "logistic")
  expect_equal(
    .makeMethodVector(data, options),
    c("pmm", "polyreg", "polyreg") |> setNames(colnames(data))
  )
})
