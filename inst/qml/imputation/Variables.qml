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
import JASP
import JASP.Controls

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
