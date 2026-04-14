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
import JASP.Controls

Group
{
	property alias enabled:			exportSection.enabled
	property alias showSave:		saveGroup.visible

	id:								exportSection
	title:							qsTr("Export Imputations")

	Group
	{
		id:							saveGroup

		CheckBox
		{
			name:					"saveImps"
			text:					qsTr("Save imputed data")
			info:					qsTr("When clicked, the model is exported to the specified file path.")

			FileSelector
			{
				name:				"savePath"
				label:				qsTr("Save as")
				placeholderText:	qsTr("e.g., location/imputations.jaspImp")
				filter:				"*.jaspImp"
				save:				true
				fieldWidth:			180 * preferencesModel.uiScale
				info:				qsTr("The file path for the saved model.")
			}
		}
	}
}