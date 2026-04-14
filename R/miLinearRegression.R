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

.runRegression <- function(jaspResults, options, ready, lmFunction) {

  impData <- jaspResults[["MiceMids"]]$object |> mice::complete("all")

  # modelContainer <- .linregGetModelContainer(jaspResults, position = 1)
  modelContainer <- jaspResults[["ModelContainer"]]
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

###------------------------------------------------------------------------------------------------------------------###
