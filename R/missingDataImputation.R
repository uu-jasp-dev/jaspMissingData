#
# Copyright (C) 2025 Utrecht University
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

  RNGkind(sample.kind = "Rejection") # Force the modern RNG sampler setting

  # Set title
  jaspResults$title <- "Multiple Imputation with MICE"

  # Init options: add variables to options to be used in the remainder of the analysis
  options <- .processImputationOptions(options)

  imputationDependencies <- c(
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

  .initMiceMids(jaspResults, imputationDependencies)
  if(is.null(jaspResults[["MiceMids"]]$object) & !.readyForMi(options)) {
    # Regular imputation part takes precedence over loading imputation models
    jaspResults[["MiceMids"]][["object"]] <- .loadImputedData(options)
    imputed <- TRUE
  }


  if (.readyForMi(options) | !is.null(jaspResults[["MiceMids"]][["object"]])) {

    errors <- .errorHandling(dataset, options)

    # Output containers, tables, and plots based on the results. These functions should not return anything!
    # .createImputationContainer(jaspResults, options)

    if(is.null(jaspResults[["MiceMids"]]$object)) {
      .imputeMissingData(jaspResults[["MiceMids"]], dataset[options$imputationTargets], options)
    }
    
    .loggedEventsToTable(jaspResults, options, imputationDependencies)

    ## Initialize containers to hold the convergence plots and analysis results:
    .initConvergencePlots(jaspResults, imputationDependencies)
    .initAnalysisContainer(jaspResults, imputationDependencies)

    if (options$tracePlot && is.null(jaspResults[["ConvergencePlots"]][["TracePlot"]]))
      .createTracePlot(jaspResults[["ConvergencePlots"]], jaspResults[["MiceMids"]])
    if (options$densityPlot && is.null(jaspResults[["ConvergencePlots"]][["DensityPlots"]]))
      .createDensityPlot(jaspResults[["ConvergencePlots"]], jaspResults[["MiceMids"]], options)
    
    if (options$saveImps && options[["savePath"]] != "") 
      .saveImputedData(jaspResults, dataset, options)
    if (options$runLinearRegression) {
      .lmFunction <<- .linregSetFittingFunction(options) # The deep assignment here is almost certainly a stupid idea

      .runRegression(jaspResults, jaspResults[["MiceMids"]], options)

    }
  }

  return()
}



###-Init Functions---------------------------------------------------------------------------------------------------###

.processImputationOptions <- function(options) {

  # Calculate any options common to multiple parts of the analysis
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

.initMiceMids <- function(jaspResults, imputationDependencies) {
  if(!is.null(jaspResults[["MiceMids"]])) return()

  miceMids <- jaspBase::createJaspState()
  miceMids$dependOn(imputationDependencies)

  jaspResults[["MiceMids"]] <- miceMids
}

###------------------------------------------------------------------------------------------------------------------###

.initConvergencePlots <- function(jaspResults, imputationDependencies) {
  if(!is.null(jaspResults[["ConvergencePlots"]])) return()

  convergencePlots <- createJaspContainer(title = "Convergence Plots")
  convergencePlots$dependOn(
    options = c(imputationDependencies, "tracePlot", "densityPlot")
  )

  jaspResults[["ConvergencePlots"]] <- convergencePlots
}

###------------------------------------------------------------------------------------------------------------------###

.initAnalysisContainer <- function(jaspResults, imputationDependencies) {
  if(!is.null(jaspResults[["AnalysisContainer"]])) return()

  analysisContainer <- createJaspContainer(title = "Analyses")
  analysisContainer$dependOn(options = c(imputationDependencies) # TODO: add regression qml options here
  )

  jaspResults[["AnalysisContainer"]] <- analysisContainer
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

###------------------------------------------------------------------------------------------------------------------###

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
      addSubtract <- ifelse(substr(modelsMat[2,i], 1, 1) == "-", "", "+")
      formulas[[y]] <- update(formulas[[y]], paste(". ~ .", addSubtract, modelsMat[2, i]))
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
    wantedIter      <- options$nIters
    addIter         <- max(0, wantedIter - currentIter)

    if (is.null(currentMiceMids$chainMean)) {
      savedIter <- nChains <- 0
    } else {
      savedIter <- dim(currentMiceMids$chainMean)[1]
      nChains   <- dim(currentMiceMids$chainMean)[3]
    }

    updateMids <- addIter > 0 && options$seed == currentMiceMids$seed && savedIter >= nChains
  }

  if (updateMids) {
    miceOut <- try(mice::mice.mids(currentMiceMids, maxit = addIter))
  } else {
    impMods <- .processImpModel(dataset, options, predMat)

    miceOut <- try(
      with(options,
           mice::mice(
             data            = dataset,
             m               = nImps,
             method          = methVec,
             formulas        = impMods,
             visitSequence   = visitSequence,
             maxit           = nIters,
             seed            = seed,
             print           = FALSE
           )
      )
    )
  }

  if (!inherits(miceOut, "try-error")) {
    miceMids$object          <- miceOut
  } else {
    stop(
      "The mice() function crashed when attempting to impute the missing data.\n",
      "The error message returned by mice is shown below.\n",
      miceOut
    )
  }
}

###------------------------------------------------------------------------------------------------------------------###

.loggedEventsToTable <- function(jaspResults, options, imputationDependencies = imputationDependencies) {
  miceMids <- jaspResults[["MiceMids"]]
  miceOut <- miceMids$object
  events <- miceOut$loggedEvents

  if (is.null(events)) {
    return()
  } else {
    if (is.null(jaspResults[["LoggedEventsTable"]])) {
      table <- createJaspTable("Logged events")
      table$dependOn(options = c(imputationDependencies, "printAllLoggedEvents", "maxLoggedEvents"))
    
      table$addColumnInfo(name = "Iteration", title = "Iteration", type = "integer")
      table$addColumnInfo(name = "Imputation", title = "Imputation", type = "integer")
      table$addColumnInfo(name = "Variable", title = "Imputed variable", type = "string")
      table$addColumnInfo(name = "Method", title = "Method", type = "string")
      table$addColumnInfo(name = "Out", title = "Excluded variable", type = "string")
      jaspResults[["LoggedEventsTable"]] <- table
    } else {
      table <- jaspResults[["LoggedEventsTable"]]
    }
    
    maxToShow <- ifelse(options$printAllLoggedEvents, nrow(events), options$maxLoggedEvents)
    nShown <- min(nrow(events), maxToShow)
    shown <- seq_len(nShown)
    
    table$addRows(
      data.frame(
        Iteration = events[shown, "it"],
        Imputation = events[shown, "im"],
        Variable = events[shown, "dep"],
        Method = events[shown, "meth"],
        Out = events[shown, "out"]
      )
    )

    if (nShown < nrow(events)) {
      table$addFootnote(paste0("Showing ", nShown, " of ", nrow(events), " events."))
    } else {
      table$addFootnote(paste0("Showing all ", nrow(events), " events."))
    }
  }
}

###------------------------------------------------------------------------------------------------------------------###

.createTracePlot <- function(convergencePlots, miceMids) {

  tracePlot <- createJaspPlot(title = "Trace Plot", height = 320, width = 480)

  convergencePlots[["TracePlot"]] <- tracePlot

  tracePlot$plotObject <- miceMids$object |> ggmice::plot_trace()
}

###------------------------------------------------------------------------------------------------------------------###

.createDensityPlot <- function(convergencePlots, miceMids, options) {

  convergencePlots[["DensityPlots"]] <- jaspBase::createJaspContainer("Density Plots")

  nonNull <- !sapply(miceMids$object$imp, is.null)
  imputedVariables <- (sapply(miceMids$object$imp[nonNull], nrow) > 0) |> which() |> names()
  
  for(v in imputedVariables) {
    densityPlot <- createJaspPlot(title = v, height = 320, width = 480)

    ## Bind the density plot for variable 'v' to the 'densityPlots' container in jaspResults
    convergencePlots[["DensityPlots"]][[v]] <- densityPlot

    ## Populate the plot object
    densityPlot$plotObject <-
      ggmice::ggmice(miceMids$object, ggplot2::aes(x = .data[[v]], group = .imp)) +
      ggplot2::geom_density()
  }
}

###------------------------------------------------------------------------------------------------------------------###

.saveImputedData <- function(jaspResults, dataset, options) {
  imps <- jaspResults[["MiceMids"]]$object
  class(imps) <- c(class(jaspResults[["MiceMids"]][["object"]]), "jaspImputation")
  path <- options[["savePath"]]
  if (!endsWith(path, ".jaspImp")) {
    path <- paste0(path, ".jaspImp")
  }
  saveRDS(imps, file = path)
}

.loadImputedData <- function(options) {
  if (options[["loadImpPath"]] != "") {
    imps <- try({
      readRDS(options[["loadImpPath"]])
    })
    if (!inherits(imps, "jaspImputation")) {
      jaspBase:::.quitAnalysis(gettext("Error: The imputed data is not created in JASP."))
    }
  } else {
    imps <- NULL
  }
  return(imps)
}