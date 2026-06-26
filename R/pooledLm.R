#
# Copyright (C) 2026 Utrecht University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

### --------------------------------------------------------------------------------------------------------------------

makePooledLm <- function(pool, poolingParams) {
  function(formula, data, weights, ...) {
    ## TIL that formula objects are closures that capture the environment in which they are created. So, we need to create
    ## the formula object in an environment containing 'weights', otherwise lm() won't find 'weights'.
    form <- as.formula(formula)
    environment(form) <- environment()

    fits <- vector("list", length(data))
    for (m in 1:length(data)) {
      fits[[m]] <- lm(form, data = data[[m]], weights = weights[[m]], ...)
    }

    if (!pool) {
      return(fits)
    }

    new_pooledLm(fits, pooling = poolingParams)
  }
}

### --------------------------------------------------------------------------------------------------------------------

new_pooledLm <- function(
  fits,
  pooling = list(fStat = "d3", llEst = "qBar"),
  include = list(fits = TRUE, model = FALSE, qr = FALSE, x = FALSE)
) {
  fits <- .checkInputs(fits, pooling)

  ## Much of the lm object doesn't change across imputed datasets, so we can keep one of the original fits and replace
  ## the appropriate parts with MI-based estimates.
  obj <- fits$analyses[[1]]
  class(obj) <- c("pooledLm", class(obj))

  ## We need to extract these things before casting the 'fits' as a mira object:
  residuals <- sapply(fits$analyses, resid)
  yHats <- sapply(fits$analyses, fitted)
  effects <- sapply(fits$analyses, effects)

  ## The pooled estimates of linear effects are just the arithmetic mean across imputations:
  obj$residuals <- rowMeans(residuals)
  obj$fitted.values <- rowMeans(yHats)
  obj$effects <- rowMeans(effects)

  obj$singularityCheckValue <- sapply(fits$analyses, function(x) x$qr$qr |> ncol()) |> min()

  if (include$fits) {
    obj$fits <- fits
  }

  ## Do we keep all M replicates of the stuff we can't pool or just one?
  if (include$model) {
    obj$model <- lapply(fits$analyses, "[[", x = "model")
  }
  if (include$qr) {
    obj$qr <- lapply(fits$analyses, "[[", x = "qr")
  }
  if (include$x) {
    obj$x <- lapply(fits$analyses, "[[", x = "x")
  }

  ## Use the mice pooling routines for the more complicated cases:
  pooled <- list()
  pooled$coef <- mice::pool(fits)
  pooled$r2 <- mice::pool.r.squared(fits)
  pooled$r2A <- mice::pool.r.squared(fits, adjusted = TRUE)

  if (obj$rank > 1) {
    # We can only compute pooled F when we have some predictors
    obj$fFun <- switch(pooling$fStat, d1 = mice::D1, d2 = mice::D2, d3 = mice::D3)
    pooled$f <- obj$fFun(fits)
    obj$df.residual <- as.numeric(pooled$f$result)[3]
  } else if (obj$rank == 1) {
    # We're pooling an intercept-only model
    pooled$f <- NULL
    obj$df.residual <- pooled$coef$pooled$df
  } else {
    stop("Wow! Something has gone terribly wrong. You should not be able to access this condition.")
  }

  pooled$logLik <- .pooledLogLik(fits, est = pooling$llEst, pool = TRUE)

  ## Replace pool-able stats with their pooled versions
  obj$coefficients <- pooled$coef$pooled$estimate
  names(obj$coefficients) <- as.character(pooled$coef$pooled$term)

  ## Calculate the pooled residual variance:
  resVars <- pooled$coef$glanced$sigma^2
  w <- mean(resVars)
  b <- var(resVars)
  pooled$s2 <- w + b + (b / length(fits))

  ## Calculate the pooled asymptotic covariance matrix of the regression coefficients:
  if (obj$rank > 1) {
    pooled$vcov <- .pooledAsymptoticCov(fits$analyses)
  } else {
    pooled$vcov <- with(pooled$coef$pooled, matrix(ubar + b + (b / m), dimnames = list(term, term)))
  }

  ## Include the extra pooled stats we'll need downstream
  obj$pooled <- pooled

  obj
}

### --------------------------------------------------------------------------------------------------------------------

.checkInputs <- function(fits, pooling) {
  if (!(mice::is.mira(fits) || is.list(fits))) {
    stop("The 'fits' argument must be a a 'mira' object or list of fitted lm models.")
  }

  if (!mice::is.mira(fits)) {
    fitsAreLm <- sapply(fits, inherits, what = "lm")
    if (!all(fitsAreLm)) {
      stop("All entries in the 'fits' list must have class 'lm'.")
    }

    ## We want 'fits' to be a mira object
    fits <- mice::as.mira(fits)
  }

  if (!pooling$fStat %in% paste0("d", 1:3)) {
    stop("The pooling type for F-statistics must be 'd1', 'd2', or 'd3'.")
  }
  if (!pooling$llEst %in% c("qBar", "qHat")) {
    stop("The estimate type at which to evaluate the log-likelihood must be 'qBar' or 'qHat'.")
  }

  ranks <- sapply(fits$analyses, "[[", x = "rank")
  if (any(ranks <= 0)) {
    stop("I don't know how to pool models with rank(X) < 1.")
  }

  fits
}

### --------------------------------------------------------------------------------------------------------------------

#' @exportS3Method
summary.pooledLm <- function(object, ...) {
  ## Maybe we can just use the print method for summary.lm?
  out <- structure(list(), class = c("pooledLmSummary", "summary.lm"))

  ## We can pull a few things directly from the input object
  out$call <- object$call
  out$residuals <- object$residuals
  out$terms <- object$terms
  out$weights <- object$weights

  ## Tidy up the fit related stuff
  out$r.squared <- object$pooled$r2[1, "est"]
  out$adj.r.squared <- object$pooled$r2A[1, "est"]
  out$sigma <- object$pooled$s2 |> sqrt()

  ## Reverse engineer the unscaled covariance matrix:
  out$cov.unscaled <- with(object$pooled, vcov / s2)

  if (object$rank > 1) {
    f <- object$pooled$f$result |>
      as.numeric() |>
      head(3)
    names(f) <- c("value", "numdf", "dendf")
    out$fstatistic <- f
  }

  ## Generate a summary table from the pooled fits
  pooledCoefSum <- summary(object$pooled$coef)

  ## The coefficients table needs formatting
  coefTab <- with(
    pooledCoefSum,
    cbind("Estimate" = estimate, "Std. Error" = std.error, "t value" = statistic, "Pr(>|t|)" = p.value)
  )
  rownames(coefTab) <- pooledCoefSum$term
  out$coefficients <- coefTab

  ## Some values used for printing
  out$aliased <- is.na(object$coefficients)
  out$df <- with(object, c(rank, df.residual, singularityCheckValue))

  invisible(out)
}

### --------------------------------------------------------------------------------------------------------------------

# #' @exportS3Method
# print.pooledLmSummary <- function(object, ...) NextMethod()

### --------------------------------------------------------------------------------------------------------------------

#' @exportS3Method
coef.pooledLm <- function(object) object$coefficients
#' @exportS3Method
vcov.pooledLm <- function(object) object$pooled$vcov
#' @exportS3Method
resid.pooledLm <- function(object) object$residuals
#' @exportS3Method
fitted.pooledLm <- function(object) object$fitted.values
#' @exportS3Method
logLik.pooledLm <- function(object) object$pooled$logLik

### --------------------------------------------------------------------------------------------------------------------

#' @exportS3Method
anova.pooledLm <- function(object, ...) {
  objList <- list(object, ...)

  ## Stats for the baseline model
  df0 <- df.residual(objList[[1]])
  ms0 <- objList[[1]]$pooled$s2
  baseRow <- c(
    "Res.Df" = df0,
    "RSS" = ms0 * df0,
    "Df" = NA,
    "Sum of Sq" = NA,
    "F" = NA,
    "Pr(>F)" = NA
  )

  ## Model comparison stats
  compRows <- sapply(
    seq_along(objList)[-1],
    function(x, fits) .pooledAnovaStats(fits[[x - 1]], fits[[x]]),
    fits = objList
  ) |>
    t()

  ## Full ANOVA table
  out <- rbind.data.frame(
    baseRow,
    compRows[, 1:length(baseRow), drop = FALSE]
  )

  ## Descriptive model tags
  fStrings <- list()
  modNum <- 1
  for (n in seq_along(objList)) {
    fStrings[[n]] <- paste0("Model ", n, ": ", deparse(formula(objList[[n]])))
  }

  attr(out, "heading") <- c("Pooled Analysis of Variance Table\n", paste(fStrings, collapse = "\n"))
  attr(out, "row.names") <- as.character(row.names(out))
  attr(out, "riv") <- compRows[, ncol(compRows)]

  class(out) <- c("pooledLmAnova", "anova", class(out))

  out
}

### --------------------------------------------------------------------------------------------------------------------

.pooledAsymptoticCov <- function(fits) {
  m <- length(fits)

  coefs <- sapply(fits, coef)
  coefNames <- rownames(coefs)

  ## Between-imputation var/covar:
  b <- coefs |>
    t() |>
    var()

  ## Average within-imputation var/covar:
  w <- sapply(fits, vcov) |>
    rowMeans() |>
    matrix(nrow = length(coefNames), dimnames = list(coefNames, coefNames))

  ## Total var/covar:
  w + b + (b / m)
}

### --------------------------------------------------------------------------------------------------------------------

.pooledLogLik <- function(fits, est = "qBar", pool = TRUE) {
  if (est == "qBar") {
    ll <- mice::D3(fits)$deviances$dev1.L / -2
  } else if (est == "qHat") {
    ll <- sapply(fits$analyses, logLik)
  } else {
    stop(paste0("The 'est' argument is currently '", est, "' but it should be either 'qBar' or 'qHat'."))
  }

  if (pool) {
    ll <- mean(ll)
  }

  attr(ll, "nobs") <- fits$analyses[[1]]$residuals |> length()
  attr(ll, "df") <- fits$analyses[[1]]$rank + 1
  class(ll) <- "logLik"

  ll
}

### --------------------------------------------------------------------------------------------------------------------

.pooledAnovaStats <- function(fit0, fit1) {
  fTest <- fit1$fFun(fit0 = fit0$fits, fit1 = fit1$fits)$result

  dfMod <- fTest[[2]]
  dfRes <- df.residual(fit1)
  msRes <- fit1$pooled$s2
  ssRes <- msRes * dfRes
  ssMod <- fTest[[1]] * msRes * dfMod

  aov0 <- c(
    "Res.Df" = dfRes,
    "RSS" = ssRes,
    "Df" = dfMod,
    "Sum of Sq" = ssMod,
    "F" = fTest[[1]],
    "Pr(>F)" = fTest[[4]],
    "RIV" = fTest[[5]]
  )

  aov0
}

### --------------------------------------------------------------------------------------------------------------------

## Pool AIC and BIC via naive averaging or the "Pooled Paramters - Pooled Log-Likelihoods" method proposed in
## https://doi.org/10.1007/s41237-025-00281-6
# .pooledInfoCriteria <- function(fits, type = "ppl") {
#   d3 <- mice::D3(fits)

#   ll <- d3$deviances$dev1.L
#   p <- coef(fits$analyses[[1]]) |> length() + 1
#   n <- fits$analyses[[1]]$model |> nrow()

#   if (type == "ppl") {
#     aic <- (ll + 2 * p) |> mean()
#     bic <- (ll + log(n) * p) |> mean()
#   } else if (type == "avg") {
#     aic <- sapply(fits$analyses, AIC) |> mean()
#     bic <- sapply(fits$analyses, BIC) |> mean()
#   } else {
#     stop(paste0("'", type, "' is not a valid type of pooling for information criteria."))
#   }

#   list(aic = aic, bic = bic, p = p, n = n, type = type)
# }

### --------------------------------------------------------------------------------------------------------------------
