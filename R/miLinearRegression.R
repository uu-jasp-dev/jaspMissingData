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

###------------------------------------------------------------------------------------------------------------------###

# .estimateRegressionModels <- function(miceMids, options) {
#   ready <- inherits(miceMids$object, "mids") && # We can't do an analysis before imputing
#     options$dependent != "" &&
#     (length(unlist(options$modelTerms)) > 0 || options$interceptTerm)

#   # browser() ############################################################################################################

#   dummyContainer <- createJaspContainer()
#   outData <- list()
#   models <- list()
#   for (m in 1:options$nImp) {
#     dataset <- outData[[m]] <- miceMids$object |> complete(m) 
#     model   <- createJaspContainer() |> .linregCalcModel(dataset, options, ready)

#     models[[m]] <- model

#     if (m == 1) {
#       meta <- lapply(model, "[", x = c("predictors", "number", "title"))
#       fits <- vector("list", length(model))
#     }

#     for (i in seq_along(model)) fits[[i]][[m]] <- model[[i]]$fit
#     
#   }

#   saveRDS(outData, "/home/kylelang/software/jasp/modules/imputation/data/outData.rds")
#   saveRDS(models, "/home/kylelang/software/jasp/modules/imputation/data/models.rds")

#   list(meta = meta, fits = fits)
# }

###------------------------------------------------------------------------------------------------------------------###

# .poolRegressionEstimates <- function(jaspResults, miFits, options, offset) {

#   # browser() ############################################################################################################

#   modelContainer <- .linregGetModelContainer(jaspResults, position = offset + 1)

#   models <- miFits$meta
#   for (i in seq_along(miFits$fits)) {
#     pooledFit <- pooledLmObject(miFits$fits[[i]], fType = options$fType)
#     models[[i]]$fit <- pooledFit
#   }

#   modelContainer[["models"]] <- models
# }

###------------------------------------------------------------------------------------------------------------------###

.runRegression <- function(jaspResults, miceMids, options, ready, lmFunction) {

  # .lmFunction <- jaspMissingData::pooledLm
  # .linregSetLmFunction(pooledLm)
  impData <- miceMids$object |> mice::complete("all") # For some reason, with.mids won't parse the formula correctly. Seems related to the bug I patched in ggmice.

  # saveRDS(impData, "~/software/jasp/modules/imputation/data/impList.rds")
  # saveRDS(options$factors, "~/software/jasp/modules/imputation/data/factors.rds")
  # saveRDS(options, "~/data/software/jasp/modules/missing_data/data/options.rds")

  # weights <- .linregGetWeights(impData, options)
  # print("These are the weights:")
  # print(weights)
  # saveRDS(weights, "~/data/software/jasp/modules/missing_data/data/weights.rds")

  modelContainer <- .linregGetModelContainer(jaspResults, position = 1)
  model          <- .linregCalcModel(modelContainer, impData, options, ready, lmFunction)

  if (is.null(modelContainer[["summaryTable"]]))
    .linregCreateSummaryTable(modelContainer, model, options, position = 1)

  # TODO (KML): Check the R2, F, AIC/BIC stuff and put MI appropriate versions in
  # TODO (KML): Add footnotes about pooling

  if (options$modelFit && is.null(modelContainer[["anovaTable"]]))
    .linregCreateAnovaTable(modelContainer, model, options, position = 2)

  # TODO (KML): Check the ANOVA stats.
  #             - Are they correct for MI data
  #             - Do they correctly adjust for D1, D2, D3?

  if (options$coefficientEstimate && is.null(modelContainer[["coeffTable"]]))
    .linregCreateCoefficientsTable(modelContainer, model, impData, options, position = 3)

  # TODO (KML): Check what we can do about the bootstrapping, partial cor, and collinearity tables

  # if (options$coefficientBootstrap && is.null(modelContainer[["bootstrapCoeffTable"]]))
  #   jaspRegression:::.linregCreateBootstrapCoefficientsTable(modelContainer, model, dataset, options, position = 4)

  # if (options$partAndPartialCorrelation && is.null(modelContainer[["partialCorTable"]]))
  #   jaspRegression:::.linregCreatePartialCorrelationsTable(modelContainer, model, dataset, options, position = 6)

  if (options$covarianceMatrix && is.null(modelContainer[["coeffCovMatrixTable"]]))
    .linregCreateCoefficientsCovarianceMatrixTable(modelContainer, model, options, position = 4)

  # if (options$collinearityDiagnostic && is.null(modelContainer[["collinearityTable"]]))
  #   jaspRegression:::.linregCreateCollinearityDiagnosticsTable(modelContainer, model, options, position = 8)
}

## Execute .runRegression() within the 'jaspRegression' namespace:
environment(.runRegression) <- asNamespace('jaspRegression')

# .runRegression <- function(jaspResults, miceMids, options) {

#   # ready <- inherits(miceMids$object, "mids") && # We can't do an analysis before imputing
#   #   options$dependent != "" &&
#   #   (length(unlist(options$modelTerms)) > 0 || options$interceptTerm)

#   ready <- .readyForLinReg(options, miceMids)

#   .lmFunction <<- pooledLm

#   # browser() ############################################################################################################

#   impData <- miceMids$object |> mice::complete("all") # For some reason, with.mids won't parse the formula correctly. Seems related to the bug I patched in ggmice.

#   # saveRDS(impData, "~/software/jasp/modules/imputation/data/impList.rds")
#   # saveRDS(options$factors, "~/software/jasp/modules/imputation/data/factors.rds")
#   # saveRDS(options$covariates, "~/software/jasp/modules/imputation/data/covariates.rds")

#   modelContainer <- jaspRegression:::.linregGetModelContainer(jaspResults, position = 1)
#   model          <- jaspRegression:::.linregCalcModel(modelContainer, impData, options, ready)

#   if (is.null(modelContainer[["summaryTable"]]))
#     jaspRegression:::.linregCreateSummaryTable(modelContainer, model, options, position = 1)

#   # TODO (KML): Check the R2, F, AIC/BIC stuff and put MI appropriate versions in
#   # TODO (KML): Add footnotes about pooling

#   if (options$modelFit && is.null(modelContainer[["anovaTable"]]))
#     jaspRegression:::.linregCreateAnovaTable(modelContainer, model, options, position = 2)

#   # TODO (KML): Check the ANOVA stats.
#   #             - Are they correct for MI data
#   #             - Do they correctly adjust for D1, D2, D3?

#   if (options$coefficientEstimate && is.null(modelContainer[["coeffTable"]]))
#     jaspRegression:::.linregCreateCoefficientsTable(modelContainer, model, impData, options, position = 3)

#   # TODO (KML): Check what we can do about the bootstrapping, partial cor, and collinearity tables

#   # if (options$coefficientBootstrap && is.null(modelContainer[["bootstrapCoeffTable"]]))
#   #   jaspRegression:::.linregCreateBootstrapCoefficientsTable(modelContainer, model, dataset, options, position = 4)

#   # if (options$partAndPartialCorrelation && is.null(modelContainer[["partialCorTable"]]))
#   #   jaspRegression:::.linregCreatePartialCorrelationsTable(modelContainer, model, dataset, options, position = 6)

#   if (options$covarianceMatrix && is.null(modelContainer[["coeffCovMatrixTable"]]))
#     jaspRegression:::.linregCreateCoefficientsCovarianceMatrixTable(modelContainer, model, options, position = 4)

#   # if (options$collinearityDiagnostic && is.null(modelContainer[["collinearityTable"]]))
#   #   jaspRegression:::.linregCreateCollinearityDiagnosticsTable(modelContainer, model, options, position = 8)
# }

# ###------------------------------------------------------------------------------------------------------------------###
