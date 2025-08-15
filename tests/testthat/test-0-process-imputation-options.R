test_that(".processImputationOptions returns expected output",
  {
    options <- addImputationVariables(
      options   = jaspTools::analysisOptions("MissingDataImputation"),
      variables = c("hgt", "reg", "bmi"),
      methods   = c("pmm", "logreg", "pmm"),
      types     = c("scale", "nominal", "scale")
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
  }
)
