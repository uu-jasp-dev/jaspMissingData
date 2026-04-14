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

VariablesForm
{
	AvailableVariablesList { name: "allVariablesList" }
	AssignedVariablesList { name: "dependent";	title: qsTr("Dependent Variable"); info: qsTr("Dependent variable.")	; allowedColumns: ["scale"]; singleVariable: true;		}
	DropDown
	{
		name: "method"
		label: qsTr("Method")
		info: qsTr("Specify the method for entering predictors into the model. For the Enter method, predictors are added as specified in the Model tab. With Forward, Backward, or Stepwise methods, predictors listed in Model 1 are treated as candidate variables that can be added to or removed from the model based on statistical criteria (found under Method Specification). Predictors listed in Model 0 are forced into the model and remain in all steps, regardless of their fit.")
		values: [
			{ label: qsTr("Enter"),	info: qsTr("All predictors are entered into the models as specified in the Model tab.")	,value: "enter"},
			{ label: qsTr("Backward"), info: qsTr("All predictors are entered simultaneously, and then removed sequentially based on the criterion specified in Stepping method criteria."), value: "backward"},
			{ label: qsTr("Forward"), info: qsTr("Predictors are entered sequentially based on the criterion specified in Stepping method criteria.")	, value: "forward"},
			{ label: qsTr("Stepwise"), info: qsTr("Predictors are entered sequentially based on the criterion specified in Stepping method criteria; after each step, the least useful predictor is removed."), value: "stepwise"}
		]
	}
	AssignedVariablesList { name: "covariates";	title: qsTr("Covariates");	info: qsTr("Continuous predictor variable(s). If ordinal variables are entered it is assumed that their levels are equidistant. Hence, ordinal variables are treated as continuous predictor variables.")	;		allowedColumns: ["scale"];   minNumericLevels: 2					}
	AssignedVariablesList { name: "factors";	title: qsTr("Factors");		info: qsTr("Categorical predictor variable(s). Ordinal variables here are treated as categorical predictor variables, thus, the ordinal information is ignored.")	;		allowedColumns: ["nominal"]; minLevels: 2}
	AssignedVariablesList { name: "weights";	title: qsTr("WLS Weights (optional)"); info: qsTr("The weights used for weighted least squares regression.")	; allowedColumns: ["scale"];   singleVariable: true			}
}
