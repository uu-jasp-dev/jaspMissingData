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

	info: qsTr("You can load a previously imputed dataset to run the selected analysis on an already imputed version of the data.")

	id:								exportSection
	title:							qsTr("Import Imputed Data")

	FileSelector
	{
		name:				"loadImpPath"
		label:				qsTr("Imputed data")
		placeholderText:	qsTr("e.g., location/imputations.jaspImp")
		filter:				"*.jaspImp"
		save:				false
		fieldWidth:			180 * preferencesModel.uiScale
	}
}

