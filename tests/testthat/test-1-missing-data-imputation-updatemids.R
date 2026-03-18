test_that("execution of updateMids",
          {
            boys <- readRDS(test_path("fixtures", "boys.rds"))

            impMethods <- mice::make.method(boys)

            options <- addImputationVariables(
              options   = jaspTools::analysisOptions("MissingDataImputation"),
              variables = colnames(boys),
              methods   = impMethods,
              types     = c("scale", "scale", "scale", "scale", "scale", "ordinal", "ordinal", "scale", "nominal")
            )

            options$seed <- 123
            options$nImps <- 2
            options$nIters <- 5
            result <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

            options$nIters <- 10
            result_update <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

            options$nIters <- 5
            options$seed <- 999
            result_seed <- jaspTools::runAnalysis("MissingDataImputation", boys, options)

            mids <- result$state$other[[1]]
            mids_update <- result_update$state$other[[1]]
            mids_seed <- result_seed$state$other[[1]]

            expect_s3_class(mids, "mids") # mids object check
            expect_s3_class(mids_update, "mids")
            expect_s3_class(mids_seed, "mids")

            expect_true(mids$iteration < mids_update$iteration) # extra iterations check
            expect_true(dim(mids$chainMean)[2] < dim(mids_update$chainMean)[2]) # imputations are extended
            expect_equal(mids$chainMean[, 1:5, ], mids_update$chainMean[, 1:5, ]) # first iterations intact

            expect_equal(mids_seed$iteration, 5) # reset iteration number check
            expect_false(isTRUE(all.equal(mids$chainMean[, 1:5, ], mids_seed$chainMean[, 1:5, ]))) # imputations are updated
          }
)



test_that("call of updateMids",
          {
            boys <- readRDS(test_path("fixtures", "boys.rds"))
            impMethods <- mice::make.method(boys)

            options_base <- addImputationVariables(
              options   = jaspTools::analysisOptions("MissingDataImputation"),
              variables = colnames(boys),
              methods   = impMethods,
              types     = c("scale", "scale", "scale", "scale", "scale", "ordinal", "ordinal", "scale", "nominal")
            )

  make_mock_mids <- function(iter = 5, seed = 123) {
    obj <- list(
      iteration = iter,
      seed = seed,
      chainMean = array(1, dim = c(iter, 1, 2)),
      imp = lapply(colnames(boys)[1:2], function(x) data.frame(x = 1))
    )
    names(obj$imp) <- colnames(boys)[1:2]
    class(obj) <- "mids"
    obj
  }

  run_case <- function(existing_object, nIters, seed) {

    called_mice <- FALSE
    called_mice_mids <- FALSE

    mock_mice <- function(..., data, m, method, formulas, visitSequence, maxit, seed, print) {
      called_mice <<- TRUE
      list(
        iteration = maxit,
        seed = seed,
        chainMean = array(1, dim = c(maxit, 1, m)),
        imp = lapply(colnames(boys)[1:2], function(x) data.frame(x = 1))
      ) |> structure(class = "mids")
    }

    mock_mice_mids <- function(obj, maxit, ...) {
      called_mice_mids <<- TRUE
      obj$iteration <- obj$iteration + maxit
      obj
    }

    miceMids <- list(object = existing_object)

    options_case <- options_base
    options_case$nIters <- nIters
    options_case$seed   <- seed
    options_case$nImps  <- 2

    with_mocked_bindings(
      mice = mock_mice,
      mice.mids = mock_mice_mids,
      .package = "mice",
      {
        jaspMissingData:::.imputeMissingData(
          miceMids,
          boys,
          options_case
        )
      }
    )

    list(called_mice = called_mice, called_mice_mids = called_mice_mids)
  }

  result1 <- run_case(NULL, nIters = 5, seed = 123) # regular mice if no mids object is created
  expect_true(result1$called_mice)
  expect_false(result1$called_mice_mids)

  result2 <- run_case(make_mock_mids(5, 123), nIters = 5, seed = 999) # regular mice if seed is changed
  expect_true(result2$called_mice)
  expect_false(result2$called_mice_mids)

  result3 <- run_case(make_mock_mids(5, 123), nIters = 10, seed = 123) # mice mids if iterations are increased
  expect_false(result3$called_mice)
  expect_true(result3$called_mice_mids)

  result4 <- run_case(make_mock_mids(10, 123), nIters = 5, seed = 123) # regular mice if iterations are decreased
  expect_true(result4$called_mice)
  expect_false(result4$called_mice_mids)
})


