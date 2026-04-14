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
import "./regression"	as	Regression
// import "./common"		as	Common

// All Analysis forms must be built with the Form QML item
Form
{

	HeadlessImputation {}

	Group
	{

		title:	qsTr("Analyses")

		CheckBox
		{
			name:		"runLinearRegression"
			label:		qsTr("Linear Regression")
			id:			runLinearRegression
			checked:	false
		}

		CheckBox
		{
			name:		"runLogisticRegression"
			label:		qsTr("Logistic Regression")
			id:			runLogisticRegression
			checked:	false
		}

	}

	Regression.RegressionLinear {}

}
