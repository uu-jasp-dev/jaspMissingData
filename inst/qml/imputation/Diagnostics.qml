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
