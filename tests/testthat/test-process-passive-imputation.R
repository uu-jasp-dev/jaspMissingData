
test_that(".processPassive yields correct method vector and predictormatrix", {
  dataset <- mice::boys
  options <- jaspTools::analysisOptions("MissingDataImputation")
  options$passiveImputation <- "bmi = wgt/(hgt/100)^2"
  methVec <- mice::make.method(dataset)
  predMat <- mice::make.predictorMatrix(dataset)

  methVecTest <- methVec
  methVecTest["bmi"] <- "~I(wgt/(hgt/100)^2)"
  expect_equal(
    .processPassive(dataset, options, methVec, predMat)$meth,
    methVecTest
  )
  predMatTest <- predMat
  predMatTest[c("hgt", "wgt"), "bmi"] <- 0
  expect_equal(
    .processPassive(dataset, options, methVec, predMat)$pred,
    predMatTest
  )

  options$passiveImputation <- "bmij = wgt/(hgt/100)^2"
  expect_error(
    .processPassive(dataset, options, methVec, predMat)
  )
  options$passiveImputation <- "bmi2 = wgt/(hgt/100)^2"
  expect_error(
    .processPassive(dataset, options, methVec, predMat)
  )
  options$passiveImputation <- "bmi = wgt/(hgt/100)^2 \n hgtj = wgt + hgt"
  expect_error(
    .processPassive(dataset, options, methVec, predMat)
  )

})
