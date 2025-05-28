#
# Copyright (C) 2024 Utrecht University
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

###------------------------------------------------------------------------------------------------------------------###

# miFits <- readRDS("../data/miFits.rds")

# meta <- miFits$meta
# fits <- miFits$fits

# fits0 <- fits[[1]]
# fits1 <- fits[[2]]

# f0 <- fits0[[1]]
# s0 <- summary(f0)

# f1 <- fits1[[1]]
# s1 <- summary(f1)

# f0$rank

# ls(f0)
# ls(f1)

# ls(s0)
# ls(s1)

# s0$r.squared
# s0$adj.r.rsquared

# f0$effects

# getwd()

# f0$terms
# f0$rank
# f0$model

# fits <- fits1
# fType <- 3

###------------------------------------------------------------------------------------------------------------------###

#' @export
pooledLm <- function(formula, data, weights, fType = 1, ...) {

  # saveRDS(formula, "~/software/jasp/modules/imputation/data/formula2.rds")
  # saveRDS(data, "~/software/jasp/modules/imputation/data/impList2.rds")

  if (mice::is.mids(data))
    fits <- with(data, stats::lm(formula = as.formula(formula), weights = weights, ...))
    # fits <- with(data, stats::lm(formula = as.formula(form), weights = weights, ...))
  else if (is.list(data) && !is.data.frame(data))
    fits <- lapply(data, function(datM) stats::lm(formula = formula, data = datM, weights = weights, ...))
  else
    stop("The 'data' argument must be a 'mids' object or a list of data.frames containing separate imputed datsets.")

  # browser() ############################################################################################################

  pooledLmObject(fits, fType, ...)
}

###------------------------------------------------------------------------------------------------------------------###

#' @export
pooledLmObject <- function(fits,
                           fType = 1,
                           include = list(model = FALSE, qr = FALSE, x = FALSE),
                           ...)
{
  fits <- .checkInputs(fits, fType)

  ## Much of the lm object doesn't change across imputed datasets, so we can keep one of the original fits and replace
  ## the appropriate parts with MI-based estimates.
  obj        <- fits$analyses[[1]]
  class(obj) <- c("pooledlm", class(obj))

  ## We need to extract these things before casting the 'fits' as a mira object:
  residuals <- sapply(fits$analyses, resid)
  yHats     <- sapply(fits$analyses, fitted)
  effects   <- sapply(fits$analyses, effects)

  ## The pooled estimates of linear effects are just the arithmetic mean across imputations:
  obj$residuals     <- rowMeans(residuals)
  obj$fitted.values <- rowMeans(yHats)
  obj$effects       <- rowMeans(effects)

  obj$singularityCheckValue <- sapply(fits$analyses, function(x) x$qr$qr |> ncol()) |> min()

  ## Do we keep the stuff we can't pool?
  if(include$model) obj$model <- lapply(fits$analyses, "[[", x = "model") else obj$model <- NA
  if(include$qr)    obj$qr    <- lapply(fits$analyses, "[[", x = "qr")    else obj$qr    <- NA
  if(include$x)     obj$x     <- lapply(fits$analyses, "[[", x = "x")     else obj$x     <- NA

  ## Use the mice pooling routines for the more complicated cases:
  pooled      <- list()
  pooled$coef <- mice::pool(fits)
  pooled$r2   <- mice::pool.r.squared(fits)
  pooled$r2A  <- mice::pool.r.squared(fits, adjusted = TRUE)

  if (obj$rank > 1) { # We can only compute pooled F when we have some predictors
    fFun            <- switch(fType, mice::D1, mice::D2, mice::D3)
    pooled$f        <- fFun(fits)
    obj$df.residual <- as.numeric(pooled$f$result)[3]
  } else if (obj$rank == 1) { # We're pooling an intercpet-only model
    pooled$f        <- NULL
    obj$df.residual <- pooled$coef$pooled$df
  } else {
    stop("Wow! Something has gone terribly wrong. You should not be able to access this condition.")
  }

  ## Replace pool-able stats with their pooled versions
  obj$coefficients        <- pooled$coef$pooled$estimate
  names(obj$coefficients) <- as.character(pooled$coef$pooled$term)

  ## Calculate the pooled residual variance:
  resVars   <- pooled$coef$glanced$sigma^2
  w         <- mean(resVars)
  b         <- var(resVars)
  pooled$s2 <- w + b + (b / length(fits))

  ## Calculate the pooled asymptotic covariance matrix of the regression coefficients:
  if(obj$rank > 1)
    pooled$vcov <- .pooledAsymptoticCov(fits$analyses)
  else
    pooled$vcov <- with(pooled$coef$pooled, matrix(ubar + b + (b / m), dimnames = list(term, term)))

  ## Include the extra pooled stats we'll need downstream
  obj$pooled <- pooled

  obj
}

# mice::pool.r.squared(mice::as.mira(fits0))
# mice::pool.r.squared(mice::as.mira(fits0), adjusted = TRUE)

###------------------------------------------------------------------------------------------------------------------###

.checkInputs <- function(fits, fType) {
  if (!(mice::is.mira(fits) || is.list(fits)))
    stop("The 'fits' argument must be a a 'mira' object or list of fitted lm models.")

  if (!mice::is.mira(fits)) {
    fitsAreLm <- sapply(fits, inherits, what = "lm")
    if (!all(fitsAreLm)) stop("All entries in the 'fits' list must have class 'lm'.")

    ## We want 'fits' to be a mira object
    fits <- mice::as.mira(fits)
  }

  if (!fType %in% 1:3) stop("The 'fType' argument must be 1, 2, or 3.")

  ranks <- sapply(fits$analyses, "[[", x = "rank")
  if (any(ranks <= 0)) stop("I don't know how to pool models with rank(X) < 1.")

  fits
}

###------------------------------------------------------------------------------------------------------------------###

#' @export
summary.pooledlm <- function(object, ...) {
  out <- structure(list(), class = c("summary.pooledlm", "summary.lm")) # Maybe we can just use the print method for summary.lm ?

  ## We can pull a few things directly from the input object
  out$call      <- object$call
  out$residuals <- object$residuals
  out$terms     <- object$terms
  out$weights   <- object$weights

  ## Tidy up the fit related stuff
  out$r.squared     <- object$pooled$r2[1, "est"]
  out$adj.r.squared <- object$pooled$r2A[1, "est"]
  out$sigma         <- object$pooled$s2 |> sqrt()

  ## Reverse engineer the unscaled covariance matrix:
  out$cov.unscaled <- with(object$pooled, vcov / s2)

  if (object$rank > 1) {
    f <- object$pooled$f$result |> as.numeric() |> head(3)
    names(f) <- c("value", "numdf", "dendf")
    out$fstatistic <- f
  }

  ## Generate a summary table from the pooled fits
  pooledCoefSum <- summary(object$pooled$coef)

  ## The coefficients table needs to formatting
  coefTab <- with(pooledCoefSum,
    cbind("Estimate" = estimate, "Std. Error" = std.error, "t value" = statistic, "Pr(>|t|)" = p.value)
  )
  rownames(coefTab) <- pooledCoefSum$term
  out$coefficients  <- coefTab

  ## Some values used for printing
  out$aliased <- is.na(object$coefficients)
  out$df      <- with(object, c(rank, df.residual, singularityCheckValue))

  invisible(out)
}

###------------------------------------------------------------------------------------------------------------------###

#' @export
print.summary.pooledlm <- function(object, allowStarGazing = FALSE, ...)
  stats:::print.summary.lm(object, signif.stars = allowStarGazing, ...)

###------------------------------------------------------------------------------------------------------------------###

#' @export
coef.pooledlm   <- function(object, ...) object$coefficients
#' @export
vcov.pooledlm   <- function(object, ...) object$pooled$vcov
#' @export
resid.pooledlm  <- function(object, ...) object$residuals
#' @export
fitted.pooledlm <- function(object, ...) object$fitted.values

###------------------------------------------------------------------------------------------------------------------###

.pooledAsymptoticCov <- function(fits) {
  m <- length(fits)

  coefs     <- sapply(fits, coef)
  coefNames <- rownames(coefs)

  ## Between-imputation var/covar:
  b <- coefs |> t() |> var()

  ## Average within-imputation var/covar:
  w <- sapply(fits, vcov) |>
    rowMeans() |>
    matrix(nrow = length(coefNames), dimnames = list(coefNames, coefNames))

  ## Total var/covar:
  w + b + (b / m)
}

###------------------------------------------------------------------------------------------------------------------###


# library(mice)
# library(miceadds)
# library(mitools)

# miceOut <- mice::mice(mice::boys)
# impData <- mice::complete(miceOut, "all")

# undebug("pooledLm")

# test <- pooledLm("hgt ~ wgt + hc + reg", miceOut, weights = NULL, fType = 1, x = TRUE)

# coef(test)
# stats::coefficients(test)

# stats::df.residual(test)
# test$df.residual

# fit0 <- lm("hgt ~ wgt + hc + reg", data = mice::boys)

# model.matrix(fit0) |> colnames()
# coef(fit0) |> names()

# summary(test) |> print()

# all.vars(formula(test))
# all.vars()

# x
# test <- pooledLm("hgt ~ wgt + hc + reg", impData, fType = 1)

# form <- "hgt ~ wgt + hc + reg"
# dat1 <- impData[[1]]

# .lmFunction(form, dat1) |> summary()
# .lmFunction(form, impData, FUN = pooledLm, fType = 2) |> summary() |> print()

# x

# test |> summary()
# test |> summary() |> print()

# sapply(fits$analyses, vcov)

# x
# fits <- with(miceOut, lm(hgt ~ wgt + hc + reg))

# test <- pooledLmObject(fits)
# sTest <- summary(test)

# summary(test)
# sTest

# vcov(test)
# coef(test)

# cTest <- sTest$cov.unscaled

# v2 <- cTest * sTest$sigma^2

# v2 - vcov(test)

# f1 <- fits$analyses[[1]]
# s1 <- summary(f1)

# s1

# v1 <- vcov(s1)

# c1 <- v1 / s1$sigma^2
# c2 <- s1$cov.unscaled

# c1 - c2

# ls(s1)

# ls(f1)


# p1 <- mice::pool(fits)
# p2 <- MIcombine(fits$analyses)

# p1
# p2

# coef(p2)
# vcov(p2)

# class(p2)
# mitools:::vcov.MIresult

# fits <- fits$analyses

# coefNames <- fits[[1]] |> coef() |> names()


# template <- w
# template
# covs


# v1 <- pooledAsymptoticCov(fits)
# v2 <- MIcombine(fits) |> vcov()

# v1 - v2

# sapply(fits$analyses, coef) |> t() |> var()
# lapply(fits$analyses, coef) |> do.call(rbind, args = _) |> var()

# fits$analyses[[1]] |> ls()

# fits$analyses[[1]][["rank"]]


# ?MIcombine
# x
# test <- pooledLmObject(fits)

# fits

# test

# coef(test)
# resid(test)
# fitted(test)

# test$pooled$coef |> summary()
# test$pooled$f
# ls(test)
# ls(testSum)

# test$rank

# testSum$df
# testSum <- summary(test)
# testSum
# testSum$fstatistic

# class(lmSum)
# class(testSum)

# testSum

# coef(test)
# resid(test)

# print(sum)

# print.summary.lm(sum)

# class(test)

# summary(test)
