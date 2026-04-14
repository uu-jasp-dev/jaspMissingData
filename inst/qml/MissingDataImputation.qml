//
// Copyright (C) 2024 Utrecht University
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import JASP.Widgets
import JASP.Theme
// import "./regression"	as	Regression
import "./common" as Common

// All Analysis forms must be built with the Form QML item
Form
{
	Common.ImportImputation { id: "importImputation"}

	// Common.Variables { id:	"variableSelection" }

	VariablesForm
	{

		AvailableVariablesList
		{
			name:	"allVariables"
			title:	qsTr("Candidate Variables")
		}
		// AvailableVariablesList { name:	"allVariablesList" }
		AssignedVariablesList
		{
			name:	"imputationVariables"
			id:		impVars
			title:	qsTr("Selected Variables")

			rowComponentTitle:	qsTr("Imputation Method")
			rowComponent:		DropDown
			{
				name:	"method"
				values:	[
					"pmm",
					"logistic",
					"polr",
					"midastouch",
					"sample",
					"cart",
					"rf",
					"mean",
					"norm",
					"norm.nob",
					"norm.boot",
					"norm.predict",
					"lasso.norm",
					"lasso.select.norm",
					"quadratic",
					"ri",
					"logreg",
					"logreg.boot",
					"lasso.logreg",
					"lasso.select.logreg",
					"polyreg",
					"lda",
					"2l.norm",
					"2l.lmer",
					"2l.pan",
					"2l.bin",
					"2lonly.mean",
					"2lonly.norm",
					"2lonly.pmm"
				]
				startValue:	{
					switch(impVars.getVariableType(rowValue))
					{
						case 2:		return "polr";		break // ordinal
						case 3:		return "logistic";	break // nominal
						default:	return "pmm";		break // otherwise => scale
					}
					// if (variables.getVariableType(rowValue) == "nominal")		return "logreg"
					// else if (variables.getVariableType(rowValue) == "ordinal")	return "polr"
					// else														return "norm"
				}
			}
		}

	}

	Group
	{

		title:	qsTr("Parameterization")

		IntegerField
		{
			name:			"nImps"
			defaultValue:	5
			label:			qsTr("Number of Imputation")
			min:			1
		}

		IntegerField
		{
			name:			"nIters"
			defaultValue:	10
			label:			qsTr("Number of Iterations")
			min:			1
		}

		IntegerField
		{
			name:			"seed"
			label:			qsTr("Random Number Seed")
			defaultValue:	235711
		}

	}

	Group
	{
		title:	qsTr("Predictor Matrix")

		CheckBox
		{
			name:		"quickpred"
			label:		qsTr("Use mice::quickpred()")
			id:			quickpred
			checked:	false
		}

		Group
		{
			visible:	quickpred.checked

			DoubleField
			{
				name:			"quickpredMincor"
				label:			qsTr("Minimum correlation threshold")
				min:			0
				max:			1
				defaultValue:	0.1
				inclusive:		1
			}

			DoubleField
			{
				name:			"quickpredMinpuc"
				label:			qsTr("Minimum proportion of usable cases")
				min:			0
				max:			1
				defaultValue:	0
				inclusive:		1
			}

			DropDown
			{
				name: "quickpredMethod"
				label: qsTr("Measure of association")
				values: [
					{ label: qsTr("Pearson's R"),		value: "pearson"},
					{ label: qsTr("Kendall's Tau"),		value: "kendall"},
					{ label: qsTr("Spearman's Rho"),	value: "spearman"}
				]
				startValue: "pearson"
			}

			VariablesForm
			{
				AvailableVariablesList	{ name:	"possiblePredictors";	label:	qsTr("Possible Predictor Variables")	}
				AssignedVariablesList	{ name:	"quickpredIncludes";	label:	qsTr("Included Variables")				}
				AssignedVariablesList	{ name:	"quickpredExcludes";	label:	qsTr("Excluded Variables")				}
			}

		}


	}

	DropDown
	{
		name: "visitSequence"

		label: qsTr("Visit Sequence")
		values: [
			{ label: qsTr("Top to Bottom"),		value: "roman"		},
			{ label: qsTr("Bottom to Top"),		value: "arabic"		},
			{ label: qsTr("Monotone"),			value: "monotone"	},
			{ label: qsTr("Reverse Monotone"),	value: "revmonotone"}
		]
	}

	Common.ExportImputation { id: "exportImputation"; enabled: impVars.count > 0 }

	Group
	{

		title:	qsTr("Convergence")

		CheckBox
		{
			name:		"tracePlot"
			label:		qsTr("Trace Plots")
			id:			tracePlot
			checked:	false
		}

		CheckBox
		{
			name:		"densityPlot"
			label:		qsTr("Density Plots")
			id:			densityPlot
			checked:	false
		}

		CheckBox
		{
			name:		"rHats"
			label:		qsTr("Potential Scale Reduction Factor")
			id:			rHats
			checked:	false
		}

	}

	Group
	{

		title:	qsTr("Analyses")

		CheckBox
		{
			name:		"runLinearRegression"
			label:		qsTr("Linear Regression")
			id:			runLinearRegression
			checked:	false
		}

		CheckBox
		{
			name:		"runLogisticRegression"
			label:		qsTr("Logistic Regression")
			id:			runLogisticRegression
			checked:	false
		}

	}

	Group
  {

    title: qsTr('Logged events')

    IntegerField
    {
      name: "maxLoggedEvents"
      label: qsTr("Maximum number of events to display")
      min: 1
      max: 1000
      defaultValue: 10
      enabled: !printAllLoggedEvents
    }

    CheckBox
    {
      name: "printAllLoggedEvents"
      label: qsTr("Show all logged events")
    }

  }

	Section
	{

		id:		passiveImp
		title:	qsTr("Passive imputation")

		TextArea
		{
			id:					passiveImputation
			name:				"passiveImputation"
			textType:			JASP.PassiveImputation
			showLineNumber:		true
			placeholderText:	"Passive imputation models can be specified as:\na=b+(2*c)^2"
		}

	}

	Section
	{

		id:		predictorSpec
		title:	qsTr("Imputation model specification")

		DropDown
		{
			id:		changePredOption
			name:	"changePredOption"
			label:	qsTr("Change imputation predictors")
			values:	[
				{ label: qsTr("Fully flexible specification"),	value: "flex" }
			]
		}

		TextArea {
			id:					changeNullModel
			name:				"changeNullModel"
			placeholderText:	qsTr("Add terms to an intercept-only model.")
			visible:			changePredOption.currentValue === "flex"
		}

		TextArea {
			id:					changeFullModel
			name:				"changeFullModel"
			placeholderText:	qsTr("Add terms to a full model (containing all main-effects).")
			visible:			changePredOption.currentValue === "flex"
		}

	}

	Section
	{

		id:		regressionAnalysis
		title:	qsTr("Regression Analysis")
		// property int analysis:	Common.Type.Analysis.LinearRegression
		// property int framework:	Common.Type.Framework.Classical

		Formula
		{
			lhs: "dependent"
			rhs: [{ name: "modelTerms", extraOptions: "isNuisance" }]
			userMustSpecify: "covariates"
		}

		VariablesForm
		{
			AvailableVariablesList { name: "analysisVariablesList" }
			AssignedVariablesList {
				name:			"dependent"
				title:			qsTr("Dependent Variable")
				allowedColumns:	["scale"]
				singleVariable:	true
			}
			DropDown
			{
				name: "method"
				label: qsTr("Method")
				values: [
					{ label: qsTr("Enter"),		value: "enter"},
					{ label: qsTr("Backward"),	value: "backward"},
					{ label: qsTr("Forward"),	value: "forward"},
					{ label: qsTr("Stepwise"),	value: "stepwise"}
				]
			}
			AssignedVariablesList { name: "covariates";	title: qsTr("Covariates");				allowedColumns: ["scale"];		minNumericLevels: 2	}
			AssignedVariablesList { name: "factors";	title: qsTr("Factors");					allowedColumns: ["nominal"];	minLevels: 2		}
			AssignedVariablesList { name: "weights";	title: qsTr("WLS Weights (optional)");	allowedColumns: ["scale"];		singleVariable: true}
		}

		Section
		{
			title: qsTr("Model")

			FactorsForm
			{
				id:					factors
				name:				"modelTerms"
				nested:				nested.checked
				allowInteraction:	true
				initNumberFactors:	2
				baseName:			"model"
				baseTitle:			"Model"
				availableVariablesList.source: ['covariates', 'factors']
				startIndex:			0
				availableVariablesListName: "availableTerms"
				allowedColumns:		[]
			}

			CheckBox
			{
				id:			nested
				label:		"Nested"
				name:		"nested"
				checked:	true
				visible: 	false
			}

			CheckBox { name: "interceptTerm"; label: qsTr("Include intercept"); checked: true }
		}

		Section
		{
			title: qsTr("Statistics")

			columns: 2
			Group
			{
				title: qsTr("Model Summary")
				CheckBox { name: "rSquaredChange";				label: qsTr("R squared change")				}
				CheckBox { name: "fChange";						label: qsTr("F change")				}
				CheckBox { name: "modelAICBIC";					label: qsTr("AIC and BIC")				}
				CheckBox { name: "residualDurbinWatson";		label: qsTr("Durbin-Watson")	}

			}

			Group
			{
				title: qsTr("Coefficients")
				CheckBox
				{
					name: "coefficientEstimate"
					label: qsTr("Estimates")
					checked: true
					onClicked: { if (!checked && bootstrapping.checked) bootstrapping.click() }
					CheckBox
					{
						id: bootstrapping
						name: "coefficientBootstrap"
						label: qsTr("From")
						childrenOnSameRow: true
						IntegerField
						{
							name: "coefficientBootstrapSamples"
							defaultValue: 5000
							fieldWidth: 50
							min: 100
							afterLabel: qsTr("bootstraps")
						}
					}
				}

				CheckBox
				{
					name: "coefficientCi"; label: qsTr("Confidence intervals")
					childrenOnSameRow: true
					CIField { name: "coefficientCiLevel" }
				}
				CheckBox { name: "collinearityStatistic";		label: qsTr("Tolerance and VIF")		}
				CheckBox { name: "vovkSellke"; label: qsTr("Vovk-Sellke maximum p-ratio") }
			}

			Group
			{
				title: qsTr("Display")
				CheckBox { name: "modelFit";					label: qsTr("Model fit");  checked: true		}
				CheckBox { name: "descriptives";				label: qsTr("Descriptives")					}
				CheckBox { name: "partAndPartialCorrelation";	label: qsTr("Part and partial correlations")	}
				CheckBox { name: "covarianceMatrix"; label: qsTr("Coefficients covariance matrix") }
				CheckBox { name: "collinearityDiagnostic";		label: qsTr("Collinearity diagnostics")		}

			}



			// Common.OutlierComponent { id: outlierComponentt}

		}

		Section
		{
			title: qsTr("Method Specification")
			columns: 1

			RadioButtonGroup
			{
				name: "steppingMethodCriteriaType"
				title: qsTr("Stepping Method Criteria")
				RadioButton
				{
					value: "pValue"; label: qsTr("Use p value"); checked: true
					columns: 2
					DoubleField { name: "steppingMethodCriteriaPEntry";		label: qsTr("Entry");	fieldWidth: 60; defaultValue: 0.05; max: 1; decimals: 3 }
					DoubleField { name: "steppingMethodCriteriaPRemoval";	label: qsTr("Removal");	fieldWidth: 60; defaultValue: 0.1; max: 1; decimals: 3	}
				}
				RadioButton
				{
					value: "fValue"; label: qsTr("Use F value")
					columns: 2
					DoubleField { name: "steppingMethodCriteriaFEntry";		label: qsTr("Entry");	fieldWidth: 60; defaultValue: 3.84; decimals: 3 }
					DoubleField { name: "steppingMethodCriteriaFRemoval";	label: qsTr("Removal");	fieldWidth: 60; defaultValue: 2.71; decimals: 3 }
				}
			}

			// RadioButtonGroup
			// {
			// 	name: "naAction"
			// 	title: qsTr("Missing Values")
			// 	debug: true
			// 	RadioButton { value: "listwise"; label: qsTr("Exclude cases listwise"); checked: true	}
			// 	RadioButton { value: "pairwise"; label: qsTr("Exclude cases pairwise")					}
			// }
		}

		// Section
		// {
		// 	title: qsTr("Plots")

		// 	Group
		// 	{
		// 		title: qsTr("Residuals Plots")
		// 		CheckBox { name: "residualVsDependentPlot";	label: qsTr("Residuals vs. dependent")					}
		//            CheckBox { name: "residualVsCovariatePlot";	label: qsTr("Residuals vs. covariates")					}
		// 		CheckBox { name: "residualVsFittedPlot";	label: qsTr("Residuals vs. predicted")					}
		// 		CheckBox
		// 		{
		//                name: "residualHistogramPlot";	label: qsTr("Residuals histogram")
		//                CheckBox { name: "residualHistogramStandardizedPlot";	label: qsTr("Standardized residuals"); checked: true	}
		// 		}
		// 		CheckBox { name: "residualQqPlot";			label: qsTr("Q-Q plot standardized residuals")			}
		//            CheckBox
		//            {
		//                name: "partialResidualPlot";	label: qsTr("Partial plots")
		//                CheckBox
		//                {
		//                    name: "partialResidualPlotCi";   label: qsTr("Confidence intervals")
		//                    childrenOnSameRow: true
		//                    CIField { name: "partialResidualPlotCiLevel"; }
		//                }
		//                CheckBox
		//                {
		//                    name: "partialResidualPlotPredictionInterval";   label: qsTr("Prediction intervals")
		//                    childrenOnSameRow: true
		//                    CIField { name: "partialResidualPlotPredictionIntervalLevel"; }
		//                }
		//            }
		// 	}

		//        Group
		//        {
		//            title: qsTr("Other Plots")
		//            CheckBox {
		//                name: "marginalPlot"; label: qsTr("Marginal effects plots")
		//                CheckBox
		//                {
		//                    name: "marginalPlotCi"; label: qsTr("Confidence intervals")
		//                    childrenOnSameRow: true
		//                    CIField { name: "marginalPlotCiLevel"; }
		//                }
		//                CheckBox
		//                {
		//                    name: "marginalPlotPredictionInterval"; label: qsTr("Prediction intervals")
		//                    childrenOnSameRow: true
		//                    CIField { name: "marginalPlotPredictionIntervalLevel"; }
		//                }
		//            }
		//        }
		// }
	}
	// Regression.RegressionLinear { id: regressionLinear;	visible: runLinearRegression.checked }

	// VariablesForm
	// {

	// 	AvailableVariablesList { name:	"potentialDependent" }
	// 	AssignedVariablesList
	// 	{
	// 		name:			"dependent"
	// 		title:			qsTr("Dependent Variable")
	// 		singleVariable:	true
	// 	}

	// }

	// VariablesForm
	// {

	// 	AvailableVariablesList { name:	"potentialIndependent" }
	// 	AssignedVariablesList
	// 	{
	// 		name:	"independents"
	// 		title:	qsTr("Independent Variables")
	// 	}

	// }

}
