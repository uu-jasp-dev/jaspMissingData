test_that("A full MI run works.", {
  boys <- readRDS(test_path("fixtures", "boys.rds"))

  impMethods <- mice::make.method(boys)

  options <- readRDS(test_path("fixtures", "mi_options.rds"))
  options$changeNullModel <- "wgt ~ hgt + I(hgt*2)"

  results <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

  # fmt: skip
  jaspTools::expect_equal_tables(
    results[["results"]][["LoggedEventsTable"]][["data"]],
    list(
      1, 1, "pmm", "hgt", "wgt", 2, 1, "pmm", "hgt", "wgt", 
      3, 1, "pmm", "hgt", "wgt", 4, 1, "pmm", "hgt", "wgt", 
      5, 1, "pmm", "hgt", "wgt", 1, 2, "pmm", "hgt", "wgt", 
      2, 2, "pmm", "hgt", "wgt", 3, 2, "pmm", "hgt", "wgt", 
      4, 2, "pmm", "hgt", "wgt", 5, 2, "pmm", "hgt", "wgt"
    )
  )
})
