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
	property alias impVars:	variables.impVars
	// property bool hasFile:	importSection.loadImpPath !== "" && importSection.loadImpPath !== null

	DropDown
	{
		name:	"impDataSource"
		id:		impDataSource
		label:	qsTr("Source of Imputed Data")
		info:	qsTr("You can generate new imputations or load a set of imputed data that you generated in a previous jaspMissingData session.")
		values:	[
			{ label: qsTr("Generate New Imputations"),	value: "createImpData"	},
			{ label: qsTr("Load Imputed Datasets"),		value: "loadImpData"	}
		]
	}

	ImportImputation { id: importSection; visible: impDataSource.value === "loadImpData" }

	Group
	{
		visible: impDataSource.value === "createImpData"

		Variables { id:	variables }
		Parameterization {}
		PredictorMatrix {}
		ModelSpec {}
		PassiveImputation {}
	}

	Diagnostics {}

	ExportImputation
	{
		enabled:	impVars.count > 0;
		visible:	impDataSource.value === "createImpData"
	}
}
