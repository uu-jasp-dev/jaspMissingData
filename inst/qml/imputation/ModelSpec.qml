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

	id:		predictorSpec
	title:	qsTr("Imputation model specification")

	DropDown
	{
		id:		changePredOption
		name:	"changePredOption"
		label:	qsTr("Change imputation predictors")
		values:	[
			{ label: qsTr("Fully flexible specification"),	value: "flex" }
		]
	}

	TextArea {
		id:					changeNullModel
		name:				"changeNullModel"
		placeholderText:	qsTr("Add terms to an intercept-only model.")
		visible:			changePredOption.currentValue === "flex"
	}

	TextArea {
		id:					changeFullModel
		name:				"changeFullModel"
		placeholderText:	qsTr("Add terms to a full model (containing all main-effects).")
		visible:			changePredOption.currentValue === "flex"
	}

}
