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

	title:		qsTr("Parameterization")
	columns:	2

	IntegerField
	{
		name:			"nImps"
		defaultValue:	5
		label:			qsTr("Number of Imputation")
		min:			1
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
		fieldWidth:		60
		defaultValue:	235711
	}

}
