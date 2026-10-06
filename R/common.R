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

.errorHandling <- function(dataset, options) {
  ## First, check for constant variance, since we only want to target numeric variables
  numericVars <- names(dataset)[sapply(dataset, is.numeric)]
  .hasErrors(
    dataset,
    "run",
    type = 'variance',
    variance.target = intersect(options$imputationTargets, numericVars),
    exitAnalysisIfErrors = TRUE
  )

  ## Now, check for all other possible issues with the imputation targets
  .hasErrors(
    dataset,
    "run",
    type = c('infinity', 'factorLevels', 'observations', 'duplicateColumns'),
    all.target = options$imputationTargets,
    observations.amount = '< 2',
    factorLevels.amount = '< 2',
    exitAnalysisIfErrors = TRUE
  )
}

### --------------------------------------------------------------------------------------------------------------------

.readyToLoad <- function(options) {
  with(
    options,
    impDataSource == "loadImpData" && loadImpPath != ""
  )
}

### --------------------------------------------------------------------------------------------------------------------

.readyForMi <- function(options) {
  with(
    options,
    length(imputationTargets) > 0 &&
      !is.null(nImps) &&
      nImps >= 1 &&
      !is.null(nIters) &&
      nIters >= 1 &&
      !is.null(seed)
  )
}

### --------------------------------------------------------------------------------------------------------------------

.readyForLinReg <- function(options, miceMids) {
  inherits(miceMids$object, "mids") && # We can't do an analysis before imputing
    options$dependent != "" &&
    (length(unlist(options$modelTerms)) > 0 || options$interceptTerm)
}

### --------------------------------------------------------------------------------------------------------------------

.imputationDependencies <- function() {
  c(
    "impDataSource",
    "loadImpPath",
    "imputationVariables",
    "passiveImputation",
    "changeFullModel",
    "changeNullModel",
    "visitSequence",
    "nImps",
    "nIters",
    "quickpred",
    "quickpredMincor",
    "quickpredMinpuc",
    "quickpredMethod",
    "quickpredIncludes",
    "quickpredExcludes",
    "seed"
  )
}

### --------------------------------------------------------------------------------------------------------------------

.analysisDependencies <- function(options) {
  deps <- NULL
  if (options$linreg) {
    deps <- c(
      deps,
      "dependent",
      "method",
      "covariates",
      "factors",
      "weights",
      "modelTerms",
      "steppingMethodCriteriaType",
      "steppingMethodCriteriaPEntry",
      "steppingMethodCriteriaPRemoval",
      "steppingMethodCriteriaFEntry",
      "steppingMethodCriteriaFRemoval",
      "interceptTerm",
      "quadraticTerms",
      "fStat",
      "llEst"
    )
  }
  deps
}

### --------------------------------------------------------------------------------------------------------------------

## Convert a formula object to a printable character string
# f2Char <- function(f) enquote(f)[2] |> as.character()
