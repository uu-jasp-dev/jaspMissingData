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

	id:		passiveImp
	title:	qsTr("Passive imputation")

	TextArea
	{
		id:					passiveImputation
		name:				"passiveImputation"
		textType:			JASP.PassiveImputation
		showLineNumber:		true
		placeholderText:	"Passive imputation models can be specified as:\na=b+(2*c)^2"
	}

}
