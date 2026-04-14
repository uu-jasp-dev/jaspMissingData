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

// All Analysis forms must be built with the Form QML item
// This headless file is meant to be included as a QML component elsewhere
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

	// DropDown
	// {
	// 	name: "visitSequence"

	// 	label: qsTr("Visit Sequence")
	// 	values: [
	// 		{ label: qsTr("Top to Bottom"),		value: "roman"		},
	// 		{ label: qsTr("Bottom to Top"),		value: "arabic"		},
	// 		{ label: qsTr("Monotone"),			value: "monotone"	},
	// 		{ label: qsTr("Reverse Monotone"),	value: "revmonotone"}
	// 	]
	// }

}
