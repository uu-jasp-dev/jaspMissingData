## Populate the 'imputationVariables' slot in the options list accounting for the different formats required for
## interactive and non-interactive sessions:
addImputationVariables <- function(options, variables, methods, types) {
  impVars <- vector("list", length(variables))
  for (i in 1:length(variables)) {
    impVars[[i]] <- list(method = methods[i], variable = variables[i])
  }

  options$imputationVariables <- impVars
  options$imputationVariables.types <- types

  options
}

### --------------------------------------------------------------------------------------------------------------------

testFitStats <- function(miraList, boys, options, what = c("r2", "f", "ic"), ...) {
  poolingParms <- with(options, list(fStat = fStat, llEst = llEst))
  pooledLm0 <- new_pooledLm(miraList[[1]], pooling = poolingParms)
  pooledLm1 <- new_pooledLm(miraList[[2]], pooling = poolingParms)
  pooledLm2 <- new_pooledLm(miraList[[3]], pooling = poolingParms)

  fFun <- switch(options$fStat, d1 = mice::D1, d2 = mice::D2, d3 = mice::D3)
  fOut <- rbind.data.frame(
    fFun(fit0 = miraList[[1]], fit1 = miraList[[2]])$result,
    fFun(fit0 = miraList[[1]], fit1 = miraList[[3]])$result
  )
  colnames(fOut) <- c("f", "df1", "df2", "p", "riv")

  mdAov1 <- anova(pooledLm0, pooledLm1)
  mdAov2 <- anova(pooledLm0, pooledLm2)

  mdAic <- AIC(pooledLm0, pooledLm1, pooledLm2)
  mdBic <- BIC(pooledLm0, pooledLm1, pooledLm2)

  results <- jaspTools::runAnalysis("MissingDataImputation", boys, options, ...)
  jaspAnovaData <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_anovaTable"]][["data"]]
  jaspSummaryData <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_summaryTable"]][["data"]]

  if ("r2" %in% what) {
    jR2 <- c(
      sapply(jaspSummaryData, "[[", x = "R2") |> unlist() |> tail(-1),
      sapply(jaspSummaryData, "[[", x = "adjR2") |> unlist() |> tail(-1)
    )

    rR2 <- rbind(
      mice::pool.r.squared(miraList[[2]]),
      mice::pool.r.squared(miraList[[3]]),
      mice::pool.r.squared(miraList[[2]], adjusted = TRUE),
      mice::pool.r.squared(miraList[[3]], adjusted = TRUE)
    )

    mdR2 <- rbind(
      pooledLm1$pooled$r2,
      pooledLm2$pooled$r2,
      pooledLm1$pooled$r2A,
      pooledLm2$pooled$r2A
    )

    test_that("R-Squared values in the model summary table match the R versions.", {
      expect_equal(rR2, mdR2)
      mdR2[, 1] |> as.numeric() |> expect_equal(jR2)
      rR2[, 1] |> as.numeric() |> expect_equal(jR2)
    })

    mdRmse <- c(
      pooledLm0$pooled$s2 |> sqrt(),
      pooledLm1$pooled$s2 |> sqrt(),
      pooledLm2$pooled$s2 |> sqrt()
    )

    jRmse <- sapply(jaspSummaryData, "[[", x = "RMSE")

    test_that(
      "RMSE values in the model summary table match the R versions.",
      expect_equal(jRmse, mdRmse)
    )
  }

  if ("f" %in% what) {
    mdF <- c(mdAov1[2, "F"], mdAov2[2, "F"])
    jF <- sapply(jaspAnovaData, "[[", x = "F") |> unlist()

    test_that("F-Stats in the ANOVA table match the R versions.", {
      expect_equal(jF, fOut$f)
      expect_equal(jF, mdF)
      expect_equal(fOut$f, mdF)
    })

    tmp <- c(mdAov1[2, "Sum of Sq"], mdAov1$RSS[2])
    mdSS <- c(tmp, sum(tmp))
    tmp <- c(mdAov2[2, "Sum of Sq"], mdAov2$RSS[2])
    mdSS <- c(mdSS, tmp, sum(tmp))

    test_that(
      "Sums of squares in the JASP ANOVA table match the R versions.",
      sapply(jaspAnovaData, "[[", x = "SS") |>
        unlist() |>
        expect_equal(mdSS)
    )

    tmp <- c(mdAov1[2, "Df"], mdAov1$Res.Df[2])
    mdDF <- c(tmp, sum(tmp))
    tmp <- c(mdAov2[2, "Df"], mdAov2$Res.Df[2])
    mdDF <- c(mdDF, tmp, sum(tmp))

    tmp <- with(fOut, rbind(df1, df2))
    rDF <- rbind(tmp, colSums(tmp)) |> as.numeric()

    jDF <- sapply(jaspAnovaData, "[[", x = "df") |> unlist()

    test_that("Degrees of freedom in the JASP ANOVA table match the R versions.", {
      expect_equal(jDF, mdDF)
      expect_equal(jDF, rDF)
      expect_equal(rDF, mdDF)
    })

    test_that(
      "Mean squares in the JASP ANOVA table match the R versions.",
      sapply(jaspAnovaData, "[[", x = "MS") |>
        unlist() |>
        expect_equal({
          mdSS / mdDF
        }[-c(3, 6)])
    )

    mdP <- c(mdAov1[2, "Pr(>F)"], mdAov2[2, "Pr(>F)"])
    jP <- sapply(jaspAnovaData, "[[", x = "p") |> unlist()

    test_that("P-values in the JASP ANOVA table match the R versions.", {
      expect_equal(jP, mdP)
      expect_equal(jP, fOut$p)
      expect_equal(fOut$p, mdP)
    })
  }

  if ("ic" %in% what) {
    test_that("Information criteria in the model summary table match the R versions.", {
      expect_equal(
        mdAic[, "AIC"],
        sapply(jaspSummaryData, "[[", x = "AIC") |> unlist()
      )
      expect_equal(
        mdBic[, "BIC"],
        sapply(jaspSummaryData, "[[", x = "BIC") |> unlist()
      )
    })
  }

  invisible(results)
}

### --------------------------------------------------------------------------------------------------------------------

getJaspFStats <- function(results) {
  results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_anovaTable"]][["data"]] |>
    sapply("[[", x = "F") |>
    unlist()
}

### --------------------------------------------------------------------------------------------------------------------

getJaspInfoCriteria <- function(results) {
  tmp <- results[["results"]][["ModelContainer"]][["collection"]][["ModelContainer_summaryTable"]][["data"]]

  list(
    aic = sapply(tmp, "[[", x = "AIC") |> unlist(),
    bic = sapply(tmp, "[[", x = "BIC") |> unlist()
  )
}
