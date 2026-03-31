//
// Copyright (C) 2026 Utrecht University
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
// import QtQuick.Layouts
import JASP
import JASP.Controls
// import JASP.Widgets
// import JASP.Theme
// import "./regression"	as	Regression
// import "./common"		as	Common

// All Analysis forms must be built with the Form QML item
// This headless file is meant to be included as a QML component elsewhere
Group
{

	VariablesForm
	{

		AvailableVariablesList
		{
			name:	"allVariables"
			title:	qsTr("Candidate Variables")
		}

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

		title:		qsTr("Diagnostics")
		columns:	2

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

			title:	qsTr('Logged events')

			IntegerField
			{
				name:			"maxLoggedEvents"
				label:			qsTr("Maximum number of events to display")
				min:			1
				max:			1000
				defaultValue:	10
				enabled:		!printAllLoggedEvents
			}

			CheckBox
			{
				name:	"printAllLoggedEvents"
				label:	qsTr("Show all logged events")
			}

		}
	}

}
