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


