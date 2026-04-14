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
			value: "pValue"; label: qsTr("Use p value"); info: qsTr("Use p-value as criterion for adding and removing predictors in Backward, Forward, and Stepwise regression.") ; checked: true
			columns: 2
			DoubleField { name: "steppingMethodCriteriaPEntry";		label: qsTr("Entry"); info: qsTr("Adds predictor if the p-value of the regression coefficient < x; default is x=0.05.")	;fieldWidth: 60; defaultValue: 0.05; max: 1; decimals: 3 }
			DoubleField { name: "steppingMethodCriteriaPRemoval";	label: qsTr("Removal"); info: qsTr("Removes predictor if the p-value of the regression coefficient > x; default is x=0.1.")	;fieldWidth: 60; defaultValue: 0.1; max: 1; decimals: 3	}
		}
		RadioButton
		{
			value: "fValue"; label: qsTr("Use F value"); info: qsTr("Use F-value as criterion for adding and removing predictors.")
			columns: 2
			DoubleField { name: "steppingMethodCriteriaFEntry";		label: qsTr("Entry"); info: qsTr("Adds predictor if the F-value (t^2) of the regression coefficient is > x; default is x=3.84.")	;fieldWidth: 60; defaultValue: 3.84; decimals: 3 }
			DoubleField { name: "steppingMethodCriteriaFRemoval";	label: qsTr("Removal"); info: qsTr("Removes predictor if the F-value (t^2) of the regression coefficient is < x; default is x=2.71.")	;fieldWidth: 60; defaultValue: 2.71; decimals: 3 }
		}
	}

	// RadioButtonGroup
	// {
	// 	name: "naAction"
	// 	title: qsTr("Missing Values")
	// 	debug: true
	// 	RadioButton { value: "listwise"; label: qsTr("Exclude cases listwise"); info: qsTr("Uses all complete observations for each individual pair of variables.") ;checked: true	}
	// 	RadioButton { value: "pairwise"; label: qsTr("Exclude cases pairwise")	; info: qsTr("Uses only complete cases across all variables.")				}
	// }
}
