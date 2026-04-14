//
// Copyright (C) 2013-2018 University of Amsterdam
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
// import "./common"		as Common

Section
{
	title: qsTr("Statistics")

	columns: 2
	Group
	{
		title: qsTr("Model Summary")
		CheckBox { name: "rSquaredChange";				label: qsTr("R squared change")	; info: qsTr("Change in R squared between the different models, with corresponding significance test."); checked: true}
		CheckBox { name: "fChange";						label: qsTr("F change")	; info: qsTr("Change in F-statistic between the different models, with corresponding significance test.")			}
		CheckBox { name: "modelAICBIC";					label: qsTr("AIC and BIC")	; info: qsTr("Displays Akaike Information Criterion and Bayesian Information Criterion.")			}
		CheckBox { name: "residualDurbinWatson";		label: qsTr("Durbin-Watson"); info: qsTr("Durbin-Watson statistic to test the autocorrelation of the residuals.")	}

	}

	Group
	{
		title: qsTr("Coefficients")
		CheckBox
		{
			name: "coefficientEstimate"
			label: qsTr("Estimates")
			info: qsTr("Unstandardized and standardized coefficient estimates, standard errors, t-values, and their corresponding p-values.")
			checked: true
			onClicked: { if (!checked && bootstrapping.checked) bootstrapping.click() }
			CheckBox
			{
				id: bootstrapping
				name: "coefficientBootstrap"
				label: qsTr("From")
				info: qsTr("Apply bootstrapped estimation. By default, the number of replications is set to 1000, but this can be changed to the desired number.")
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
			name: "coefficientCi"; label: qsTr("Confidence intervals"); info: qsTr("Includes confidence intervals for the estimated mean difference. By default the confidence level is set to 95%, but this can be changed to the desired percentage.")
			childrenOnSameRow: true
			CIField { name: "coefficientCiLevel" }
		}
		CheckBox { name: "collinearityStatistic";		label: qsTr("Tolerance and VIF"); info: qsTr("Displays Tolerance and Variance Inflation Factor for each predictor in the model in order to assess multicollinearity.")		}
		CheckBox { name: "vovkSellke"; label: qsTr("Vovk-Sellke maximum p-ratio"); info: qsTr("Shows the maximum ratio of the likelihood of the obtained p-value under H1 vs the likelihood of the obtained p value under H0. For example, if the two-sided p-value equals .05, the Vovk-Sellke MPR equals 2.46, indicating that this p-value is at most 2.46 times more likely to occur under H1 than under H0.") }
	}

	Group
	{
		title: qsTr("Display")
		CheckBox { name: "modelFit";					label: qsTr("Model fit"); info: qsTr("Separate ANOVA table for each model, i.e., each step in Backward, Forward, and Stepwise regression.") ; checked: true		}
		CheckBox { name: "descriptives";				label: qsTr("Descriptives")	; info: qsTr("Samples size, sample mean, sample standard deviation, and standard error of the mean.")				}
		CheckBox { name: "partAndPartialCorrelation";	label: qsTr("Part and partial correlations"); info: qsTr("Semipartial and partial correlations.")	}
		CheckBox { name: "covarianceMatrix"; label: qsTr("Coefficients covariance matrix"); info: qsTr("Displays the covariance matrix of the predictor variables, per model.") }
		CheckBox { name: "collinearityDiagnostic";		label: qsTr("Collinearity diagnostics")	; info: qsTr("Collinearity statistics, eigenvalues, condition indices, and variance proportions.")	}
		CheckBox { name: "equationTable";		label: qsTr("Regression equation")	; info: qsTr("Displays regression equations for each model.")	}
	}

	Group
	{
		title:	qsTr("Pooling")
		DropDown
		{
			name: "fType"
			label: qsTr("Pooling Rule for F-Statistic")
			values: [
				{ label: qsTr("D1"),	value: "d1"},
				{ label: qsTr("D2"),	value: "d2"},
				{ label: qsTr("D3"),	value: "d3"}
			]
			startValue: "1"
		}
	}

	// Common.OutlierComponent { id: outlierComponentt}

}
