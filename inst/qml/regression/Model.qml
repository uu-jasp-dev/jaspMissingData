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
	title: qsTr("Model"); info: qsTr("Components and model terms.")

	FactorsForm
	{
		id:					factors
		name:				"modelTerms"
		info: qsTr("Model terms: The independent variables in the model. By default, all the main effects of the specified independent variables are included in the model. To include interactions, click multiple variables by holding the ctrl/command button while clicking, and drag those into the Model Terms box.")
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

	CheckBox { name: "interceptTerm"; label: qsTr("Include intercept"); info: qsTr("Include the intercept in the regression model.") ; checked: true }

	CheckBox { name: "quadraticTerms"; label: qsTr("Include quadratic terms"); info: qsTr("Include quadratic terms for the covariates in each model.") }

}
