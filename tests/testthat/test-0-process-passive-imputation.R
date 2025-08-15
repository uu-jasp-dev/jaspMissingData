test_that(".processPassive yields correct method vector and predictormatrix",
  {
    dataset <- readRDS(test_path("fixtures", "boys.rds"))
    options <- jaspTools::analysisOptions("MissingDataImputation")
    options$passiveImputation <- "bmi = wgt/(hgt/100)^2"
    methVec <- methVecTest <- mice::make.method(dataset)
    predMat <- predMatTest <- mice::make.predictorMatrix(dataset)

    methVecTest["bmi"] <- "~I(wgt/(hgt/100)^2)"
    expect_equal(
      .processPassive(dataset, options, methVec, predMat)$meth,
      methVecTest
    )

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
  }
)
