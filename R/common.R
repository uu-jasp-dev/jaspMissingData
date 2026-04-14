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

.readyForMi <- function(options) {
  with(options,
    length(imputationTargets) > 0 &&
    !is.null(nImps) && nImps >= 1 &&
    !is.null(nIters) && nIters >= 1 &&
    !is.null(seed)
  )
}

###------------------------------------------------------------------------------------------------------------------###

.readyForLinReg <- function(options, miceMids) {
  inherits(miceMids$object, "mids") && # We can't do an analysis before imputing
  options$dependent != "" &&
  (length(unlist(options$modelTerms)) > 0 || options$interceptTerm)
}

###------------------------------------------------------------------------------------------------------------------###

# .readData <- function(dataset, options) dataset[options$imputationVariables]
#   vars <- unlist(options$variables)
#   # Read in the dataset using the built-in functions
#   if (!is.null(options$groupVar) && options$groupVar != "")
#     .readDataSetToEnd(columns = vars, columns.as.factor = options$groupVar)
#   else
#     .readDataSetToEnd(columns = vars)
# }

###------------------------------------------------------------------------------------------------------------------###

.errorHandling <- function(dataset, options)
  .hasErrors(dataset,
             "run",
             type = c('observations', 'variance', 'infinity'),
             all.target = options$imputationTargets,
             observations.amount = '< 2',
             exitAnalysisIfErrors = TRUE)
