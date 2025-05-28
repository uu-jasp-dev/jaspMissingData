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

###-Main Function----------------------------------------------------------------------------------------------------###

#' Multiply impute missing data with MICE
#' @export

# TODO: own logging

MissingDataImputation <- function(jaspResults, dataset, options) {

  # Set title
  jaspResults$title <- "Multiple Imputation with MICE"

  # Init options: add variables to options to be used in the remainder of the analysis
  options <- .processImputationOptions(options)

  if (.readyForMi(options)) {

    errors <- .errorHandling(dataset, options)

    # Output containers, tables, and plots based on the results. These functions should not return anything!
    # .createImputationContainer(jaspResults, options)

    .initMiceMids(jaspResults)
    options <- .imputeMissingData(jaspResults[["MiceMids"]], dataset, options)

    ## Initialize containers to hold the convergence plots and analysis results:
    .initConvergencePlots(jaspResults)
    .initAnalysisContainer(jaspResults)

    if (options$tracePlot)
      .createTracePlot(jaspResults[["ConvergencePlots"]], jaspResults[["MiceMids"]])
    if (options$densityPlot)
      .createDensityPlot(jaspResults[["ConvergencePlots"]], jaspResults[["MiceMids"]], options)

    if (options$runLinearRegression) {
      .lmFunction <<- .linregSetFittingFunction(options) # The deep assignment here is almost certainly a stupid idea

      .runRegression(jaspResults, jaspResults[["MiceMids"]], options)

    }
  }

  return()
}

###------------------------------------------------------------------------------------------------------------------###

# .createImputationContainer <- function(jaspResults, options) {
#   if (!is.null(jaspResults[["ImputationContainer"]])) return()
#
#   imputationContainer <- createJaspContainer("Missing Data Imputation")
#   imputationContainer$dependOn(options = c("variables", "groupVar", "nImps", "nIter", "seed"))
#
#   jaspResults[["ImputationContainer"]] <- imputationContainer
# }

###-Init Functions---------------------------------------------------------------------------------------------------###

.processImputationOptions <- function(options) {

  # Calculate any options common to multiple parts of the analysis
  options$lastMidsUpdate <- Sys.time()
  options$imputedVariables <- ""
  options$fType <- 1
  options$lmFunction <- pooledLm

  tmp <- options$imputationVariables
  if (interactive()) {
    options$imputationTargets <- sapply(tmp$value, "[[", x = "variable")
    options$imputationMethods <- sapply(tmp$value, "[[", x = "method")
  } else {
    options$imputationTargets <- sapply(tmp, "[[", x = "variable")
    options$imputationMethods <- sapply(tmp, "[[", x = "method")
  }

  names(options$imputationMethods) <- options$imputationTargets

  options
}

###------------------------------------------------------------------------------------------------------------------###

.initMiceMids <- function(jaspResults) {
  if(!is.null(jaspResults[["MiceMids"]])) return()

  miceMids <- jaspBase::createJaspState()
  miceMids$dependOn(options = c(
    "imputationTargets",
    "imputationMethods",
    "passiveImputation",
    "changeFullModel",
    "changeNullModel",
    "visitSequence",
    "nImps",
    "nIter",
    "seed")
  )

  jaspResults[["MiceMids"]] <- miceMids
}

###------------------------------------------------------------------------------------------------------------------###

.initConvergencePlots <- function(jaspResults) {
  if(!is.null(jaspResults[["ConvergencePlots"]])) return()

  convergencePlots <- jaspBase::createJaspContainer(title = "Convergence Plots")
  convergencePlots$dependOn(options = "lastMidsUpdate")

  jaspResults[["ConvergencePlots"]] <- convergencePlots

  # jaspResults[["ConvergencePlots"]]
}

###------------------------------------------------------------------------------------------------------------------###

.initAnalysisContainer <- function(jaspResults) {
  if(!is.null(jaspResults[["AnalysisContainer"]])) return()

  analysisContainer <- jaspBase::createJaspContainer(title = "Analyses")
  analysisContainer$dependOn(options = "lastMidsUpdate")

  jaspResults[["AnalysisContainer"]] <- analysisContainer

  # jaspResults[["AnalysisContainer"]]
}

###------------------------------------------------------------------------------------------------------------------###

.makeMethodVector <- function(dataset, options) {

  method <- mice::make.method(dataset, defaultMethod = rep("", 4))

  method[options$imputationTargets] <- options$imputationMethods

  nLevels <- sapply(dataset, function(x) length(unique(na.omit(x))))

  binoms         <- method == "logistic" & nLevels == 2
  method[binoms] <- "logreg"

  multinoms         <- method == "logistic" & nLevels > 2
  method[multinoms] <- "polyreg"

  method
}

### Passive imputation ----------------------------------------------------------------------------------------------###

.parseCharacterFormula <- function(x, encoded, decoded) {
  for (i in seq_along(decoded)) {
    x <- paste0("\\b", decoded[i], "\\b") |> gsub(replacement = encoded[i], x = x)
  }
  splitted <- gsub("\\s", "", x) |> strsplit("=|~")
  c(var = splitted[[1]][1], eq = splitted[[1]][2])
}


.processPassive <- function(dataset, options, methodVector, predictorMatrix) {

  # TODO: passive imputation might run before the other imputation models in the sequence.
  # it might be wise to let it run after all other imputation models have been run. I now
  # filed an issue on the mice github page.
  encodedMethNames <- names(methodVector)
  decodedMethNames <- jaspBase::decodeColNames(encodedMethNames)

  passiveMethVec <- strsplit(options$passiveImputation, "\n")[[1]]

  passiveMat <- sapply(passiveMethVec,
                       .parseCharacterFormula,
                       encoded = encodedMethNames,
                       decoded = decodedMethNames)

  varsExist <- match(passiveMat[1,], encodedMethNames)
  if (any(is.na(varsExist))) {
    stop("The following variables in your passive imputation string do not exist in the data:\n",
         paste(passiveMat[1, is.na(varsExist)], collapse = ", "))
  }

  matchMethod <- sapply(passiveMat[1,], grep, x = encodedMethNames)
  methodVector[matchMethod] <- paste0("~I(", passiveMat[2,], ")")

  for (i in matchMethod) {
    setZero <- sapply(encodedMethNames, grepl, x = methodVector[i])
    predictorMatrix[setZero, i] <- 0
  }

  list(meth = methodVector, pred = predictorMatrix)
}

### Text-specified imputation models ---------------------------------------------------------------------------------###

.processImpModel <- function(dataset, options, predictorMatrix) {

  formulas <- mice::make.formulas(dataset, predictorMatrix = predictorMatrix)

  encodedMethNames <- rownames(predictorMatrix)
  decodedMethNames <- jaspBase::decodeColNames(encodedMethNames)

  fullModelVars <- nullModelVars <- NULL

  if (options$changeFullModel != "") {
    models <- strsplit(options$changeFullModel, "\n")[[1]]
    modelsMat <- sapply(models,
                        .parseCharacterFormula,
                        encoded = encodedMethNames,
                        decoded = decodedMethNames)

    fullModelVars <- modelsMat[1,]

    if (any(!fullModelVars %in% encodedMethNames)) {
      stop("The following variables in your full model do not exist in the data:\n",
           paste(fullModelVars[!fullModelVars %in% encodedMethNames], collapse = ", "))
    }

    for (i in seq_along(fullModelVars)) {
      y <- modelsMat[1, i]
      # check whether user wants to add to the full model or subtract from it (or both)
      addsubtract <- ifelse(substr(modelsMat[2,i], 1, 1) == "-", "", "+")
      formulas[[y]] <- update(formulas[[y]], paste(". ~ .", addsubtract, modelsMat[2, i]))
    }
  }

  if (options$changeNullModel != "") {
    models <- strsplit(options$changeNullModel, "\n")[[1]]
    modelsMat <- sapply(models,
                        .parseCharacterFormula,
                        encoded = encodedMethNames,
                        decoded = decodedMethNames)

    nullModelVars <- modelsMat[1,]

    if (!is.null(fullModelVars) && any(fullModelVars %in% nullModelVars)) {
      stop("You cannot specify imputation models starting from the full and the empty model simultaneously.")
    }
    if (any(!nullModelVars %in% encodedMethNames)) {
      stop("The following variables in your null model do not exist in the data:\n",
           paste(nullModelVars[!nullModelVars %in% encodedMethNames], collapse = ", "))
    }

    for (i in seq_along(nullModelVars)) {
      y <- modelsMat[1, i]
      formulas[[y]] <- paste(y, modelsMat[2, i], sep = " ~ ") |> as.formula()
    }
  }
  formulas
}

###------------------------------------------------------------------------------------------------------------------###

.makePredictorMatrix <- function(dataset, options) {

  if (options$quickpred) { # Use mice::quickpred() to construct the predictor matrix
    predMat <- with(options,
      mice::quickpred(
        data    = dataset,
        mincor  = quickpredMincor,
        minpuc  = quickpredMinpuc,
        include = quickpredIncludes,
        exclude = quickpredExcludes,
        method  = quickpredMethod
      )
    )

    return(predMat)
  }

  ## We're not using quickpred, so just do the boring thing:
  mice::make.predictorMatrix(dataset)
}

###-Output Functions-------------------------------------------------------------------------------------------------###

.imputeMissingData <- function(miceMids, dataset, options) {

  methVec <- .makeMethodVector(dataset, options)
  predMat <- .makePredictorMatrix(dataset, options)

  if (options$passiveImputation != "") {
    passive <- .processPassive(dataset, options, methVec, predMat)
    methVec <- passive$meth
    predMat <- passive$pred
  }

  updateMids <- FALSE
  if (!is.null(miceMids$object)) {
    currentMiceMids <- miceMids$object
    currentIter     <- currentMiceMids$iteration
    savedIter       <- if (is.null(currentMiceMids$chainMean)) 0 else dim(currentMiceMids$chainMean)[1]
    wantedIter      <- options$nIter
    addIter         <- max(0, wantedIter - currentIter)

    nActiveVars <- sum(!startsWith(methVec, "passive") & methVec != "")
    nChains <- if (is.null(currentMiceMids$chainMean)) 0 else dim(currentMiceMids$chainMean)[3]

    updateMids <- addIter > 0 && options$seed == currentMiceMids$seed && savedIter >= nChains && nChains == nActiveVars
  }

  if (updateMids) {
    miceOut <- try(mice::mice.mids(currentMiceMids, maxit = addIter))
  } else {
    impMods <- .processImpModel(dataset, options, predMat)

    miceOut <- try(
      with(options,
           mice::mice(
             data            = dataset,
             m               = nImp,
             method          = methVec,
             formulas        = impMods,
             visitSequence   = visitSequence,
             maxit           = nIter,
             seed            = seed,
             print           = FALSE
           )
      )
    )
  }

  if (!inherits(miceOut, "try-error")) {
    miceMids$object          <- miceOut
    options$lastMidsUpdate   <- Sys.time()
    nonnull <- !sapply(miceOut$imp, is.null)
    options$imputedVariables <- (sapply(miceOut$imp[nonnull], nrow) > 0) |> which() |> names()
  } else {
    stop(
      "The mice() function crashed when attempting to impute the missing data.\n",
      "The error message returned by mice is shown below.\n",
      miceOut
    )
  }

  # dataset <<- miceOut$data ##############################################################################################

  options
}

###------------------------------------------------------------------------------------------------------------------###

.createTracePlot <- function(convergencePlots, miceMids) {

  #if (!is.null(jaspResults[["tracePlot"]])) return()

  tracePlot <- jaspBase::createJaspPlot(title = "Trace Plot", height = 320, width = 480)
  tracePlot$dependOn(options = c("imputationTargets", "imputationMethods", "nImps", "nIter", "seed"))

  convergencePlots[["TracePlot"]] <- tracePlot


  tracePlot$plotObject <- miceMids$object |> ggmice::plot_trace()

  # Bind plot to jaspResults via the convergencePlots container:
  # convergencePlots[["TracePlot"]] <- tracePlot$plotObject
}

###------------------------------------------------------------------------------------------------------------------###

.createDensityPlot <- function(convergencePlots, miceMids, options) {

  convergencePlots[["DensityPlots"]] <- jaspBase::createJaspContainer("Density Plots")

  for(v in options$imputedVariables) {
    densityPlot <- jaspBase::createJaspPlot(title = v, height = 320, width = 480)
    densityPlot$dependOn(options = c("imputationTargets", "imputationMethods", "nImps", "nIter", "seed"))

    ## Bind the density plot for variable 'v' to the 'densityPlots' container in jaspResults
    convergencePlots[["DensityPlots"]][[v]] <- densityPlot

    ## Populate the plot object
    densityPlot$plotObject <-
      ggmice::ggmice(miceMids$object, ggplot2::aes(x = .data[[v]], group = .imp)) +
      ggplot2::geom_density()
  }
}

###------------------------------------------------------------------------------------------------------------------###
