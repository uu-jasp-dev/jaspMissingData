## Populate the 'imputationVariables' slot in the options list accounting for the different formats required for
## interactive and non-interactive sessions:
addImputationVariables <- function(options, variables, methods, types) {
  impVars <- vector("list", length(variables)) 
  for(i in 1:length(variables)) {
    impVars[[i]] <- list(method = methods[i], variable = variables[i])
  }

  if(interactive()) {
    options$imputationVariables <- list(
      optionKey = "variable",
      types     = types,
      value     = impVars
    )
  } else {
    options$imputationVariables       <- impVars
    options$imputationVariables.types <- types
  }

  options
}
