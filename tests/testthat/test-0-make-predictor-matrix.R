test_that(".makePredictorMatrix works",
  {
    dataset <- readRDS(test_path("fixtures", "boys.rds"))

    options <- jaspTools::analysisOptions("MissingDataImputation")
    expect_equal(
      .makePredictorMatrix(dataset, options),
      mice::make.predictorMatrix(dataset)
    )

    options$quickpred <- TRUE
    expect_equal(
      .makePredictorMatrix(dataset, options),
      mice::quickpred(dataset)
    )

    options$quickpredMincor <- 1
    expect_equal(
      .makePredictorMatrix(dataset, options),
      mice::quickpred(dataset, mincor = 1)
    )

    options$quickpredIncludes <- c("hgt", "wgt")
    options$quickpredMincor <- 0.5
    expect_equal(
      .makePredictorMatrix(dataset, options),
      mice::quickpred(dataset, mincor = 0.5, include = c("hgt", "wgt"))
    )
  }
)
