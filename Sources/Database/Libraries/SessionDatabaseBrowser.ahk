;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database Browser        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"
#Include "..\..\Framework\Configuration.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

browseLapTelemetries(ownerOrCommand := false, arguments*) {
	local x, y, names, ignore, infos, index, name, dirName, driverName
	local carNames, trackNames, newSimulator, newCar, newTrack, force
	local userTelemetries, communityTelemetries, info
	local command, fileNames

	static sessionDB := false

	static browserGui

	static fileName := false
	static result := false

	static simulators := false
	static cars := false
	static tracks := false

	static simulator := false
	static car := false
	static track := false

	selectSimulator(*) {
		try
			browseLapTelemetries("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browseLapTelemetries("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browseLapTelemetries("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
	}

	if ((ownerOrCommand == kOk) || (ownerOrCommand == kCancel))
		result := ownerOrCommand
	else if (ownerOrCommand == "Load") {
		browserGui.Opt("+OwnDialogs")

		dirName := (SessionDatabase.DatabasePath . "User\")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, "M1", dirName, translate("Load Telemetry..."), "Lap Telemetry (*.telemetry; *.json; *.CSV)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if ((fileName != "") || (isObject(fileName) && (fileName.Length > 0))) {
			fileNames := []
			infos := []

			for ignore, fileName in isObject(fileName) ? fileName : [fileName] {
				browserGui.Block()

				try {
					fileName := sessionDB.importTelemetry(simulator, car, track, fileName, &info)
				}
				finally {
					browserGui.Unblock()
				}

				if fileName {
					fileNames.Push(fileName)
					infos.Push(info)
				}
			}

			if (fileNames.Length > 0) {
				fileName := [fileNames, infos]

				browseLapTelemetries(kOk)
			}
			else
				fileName := false
		}
		else
			fileName := false
	}
	else if (ownerOrCommand = "ChooseSimulator") {
		newSimulator := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if newSimulator
			newSimulator := sessionDB.getSimulatorName(newSimulator)

		if (force || (newSimulator != simulator)) {
			if (!newSimulator && (simulators.Length > 1))
				newSimulator := simulators[1]

			simulator := newSimulator

			if simulator {
				browserGui["simulatorDropDown"].Choose(inList(simulators, simulator))

				cars := sessionDB.getCars(simulator)
			}
			else {
				simulator := false

				cars := []
			}

			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			browserGui["carDropDown"].Delete()
			browserGui["carDropDown"].Add(carNames)

			browseLapTelemetries("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseCar") {
		newCar := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newCar != car)) {
			if (!newCar && (cars.Length > 1))
				newCar := cars[1]

			car := newCar

			if car {
				tracks := sessionDB.getTracks(simulator, car)

				browserGui["carDropDown"].Choose(inList(cars, car))
			}
			else
				tracks := []

			browserGui["trackDropDown"].Delete()
			browserGui["trackDropDown"].Add(collect(tracks, ObjBindMethod(sessionDB, "getTrackName", simulator)))

			browseLapTelemetries("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseTrack") {
		newTrack := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newTrack != track)) {
			if (!newTrack && (tracks.Length > 1))
				newTrack := tracks[1]

			track := newTrack

			browserGui["telemetryListView"].Delete()

			if track {
				browserGui["trackDropDown"].Choose(inList(tracks, track))

				sessionDB.getTelemetryNames(simulator, car, track, &userTelemetries := true
																 , &communityTelemetries := sessionDB.UseCommunity)

				for ignore, name in userTelemetries {
					info := sessionDB.readTelemetryInfo(simulator, car, track, name)

					if getMultiMapValue(info, "Telemetry", "Driver", false)
						driverName := SessionDatabase.getDriverName(simulator, getMultiMapValue(info, "Telemetry", "Driver"))
					else
						driverName := false

					if !driverName
						driverName := getMultiMapValue(info, "Telemetry", "Driver")

					if !driverName
						driverName := SessionDatabase.getUserName()

					browserGui["telemetryListView"].Add("", name, driverName
														  , FormatTime(getMultiMapValue(info, "Telemetry", "Date"), "ShortDate") . translate(" - ")
														  . FormatTime(getMultiMapValue(info, "Telemetry", "Date"), "Time"))
				}

				if sessionDB.UseCommunity
					for ignore, name in communityTelemetries
						if !inList(userTelemetries, name)
							browserGui["telemetryListView"].Add("", name, translate("Community"), translate("-"))

				if (browserGui["telemetryListView"].GetCount() > 1)
					browserGui["telemetryListView"].Modify(1, "Select +Vis")

				browserGui["telemetryListView"].ModifyCol()

				loop browserGui["telemetryListView"].GetCount("Col")
					browserGui["telemetryListView"].ModifyCol(A_Index, "AutoHdr")
			}
		}
	}
	else {
		fileName := false

		sessionDB := SessionDatabase()
		simulators := sessionDB.getSimulators()

		result := false

		browserGui := Window({Descriptor: "Lap Telemetry Browser", Options: "0x400000"}, translate("Load Telemetry..."))

		if ownerOrCommand
			browserGui.Opt("+Owner" . ownerOrCommand.Hwnd)

		browserGui.Add("Text", "x8 yp+8 w70 h23 +0x200", translate("Simulator"))
		browserGui.Add("DropDownList", "x90 yp w275 vsimulatorDropDown", simulators).OnEvent("Change", selectSimulator)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Car"))
		browserGui.Add("DropDownList", "x90 yp w275 vcarDropDown").OnEvent("Change", selectCar)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Track"))
		browserGui.Add("DropDownList", "x90 yp w275 vtrackDropDown").OnEvent("Change", selectTrack)

		browserGui.Add("ListView", "x8 yp+30 w357 h335 +Multi -LV0x10 AltSubmit vtelemetryListView", collect(["Telemetry", "Driver", "Date"], translate))
		browserGui["telemetryListView"].OnEvent("DoubleClick", browseLapTelemetries.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browseLapTelemetries.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browseLapTelemetries.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browseLapTelemetries.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browseLapTelemetries("ChooseSimulator", %arguments[1]%, true)
		browseLapTelemetries("ChooseCar", %arguments[2]%, true)
		browseLapTelemetries("ChooseTrack", %arguments[3]%, true)

		if getWindowPosition("Lap Telemetry Browser", &x, &y)
			browserGui.Show("x" . x . " y" . y)
		else
			browserGui.Show()

		try {
			loop {
				Sleep(100)

				if GetKeyState("Ctrl")
					browserGui["openButton"].Text := translate("Import...")
				else
					browserGui["openButton"].Text := translate("Open...")
			}
			until result

			if (result = kOk) {
				if (arguments.Length > 3)
					%arguments[4]% := false

				if fileName {
					%arguments[1]% := false
					%arguments[2]% := false
					%arguments[3]% := false

					if isObject(fileName) {
						if (arguments.Length > 3)
							%arguments[4]% := fileName[2]

						return fileName[1]
					}
					else
						return fileName
				}
				else {
					fileNames := []

					index := 0

					while (index := browserGui["telemetryListView"].GetNext(index)) {
						if FileExist(sessionDB.getTelemetryDirectory(simulator, car, track, "User")
								   . browserGui["telemetryListView"].GetText(index) . ".telemetry")
							fileNames.Push(sessionDB.getTelemetryDirectory(simulator, car, track, "User")
										 . browserGui["telemetryListView"].GetText(index) . ".telemetry")
						else
							fileNames.Push(sessionDB.getTelemetryDirectory(simulator, car, track, "Community")
										 . browserGui["telemetryListView"].GetText(index) . ".telemetry")
					}

					if (fileNames.Length > 0) {
						%arguments[1]% := simulator
						%arguments[2]% := car
						%arguments[3]% := track

						return fileNames
					}
					else
						return false
				}
			}
			else
				return false
		}
		finally {
			browserGui.Destroy()
		}
	}
}

browseSoloSessions(ownerOrCommand := false, arguments*) {
	local x, y, names, infos, index, name, dirName, driverName
	local carNames, trackNames, newSimulator, newCar, newTrack, force

	static sessionDB := false

	static browserGui

	static fileName := false
	static result := false

	static simulators := false
	static cars := false
	static tracks := false

	static simulator := false
	static car := false
	static track := false

	selectSimulator(*) {
		try
			browseSoloSessions("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browseSoloSessions("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browseSoloSessions("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
	}

	if ((ownerOrCommand == kOk) || (ownerOrCommand == kCancel))
		result := ownerOrCommand
	else if (ownerOrCommand == "Load") {
		browserGui.Opt("+OwnDialogs")

		if GetKeyState("Ctrl") {
			OnMessage(0x44, translateLoadCancelButtons)
			fileName := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Load Session..."))
			OnMessage(0x44, translateLoadCancelButtons, 0)
		}
		else {
			dirName := (SessionDatabase.DatabasePath . "User\")

			OnMessage(0x44, translateLoadCancelButtons)
			fileName := withBlockedWindows(FileSelect, 1, dirName, translate("Load Session..."), "Solo Session (*.solo)")
			OnMessage(0x44, translateLoadCancelButtons, 0)
		}

		if (fileName != "")
			browseSoloSessions(kOk)
		else
			fileName := false
	}
	else if (ownerOrCommand = "ChooseSimulator") {
		newSimulator := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if newSimulator
			newSimulator := sessionDB.getSimulatorName(newSimulator)

		if (force || (newSimulator != simulator)) {
			if (!newSimulator && (simulators.Length > 1))
				newSimulator := simulators[1]

			simulator := newSimulator

			if simulator {
				browserGui["simulatorDropDown"].Choose(inList(simulators, simulator))

				cars := sessionDB.getCars(simulator)
			}
			else {
				simulator := false

				cars := []
			}

			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			browserGui["carDropDown"].Delete()
			browserGui["carDropDown"].Add(carNames)

			browseSoloSessions("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseCar") {
		newCar := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newCar != car)) {
			if (!newCar && (cars.Length > 1))
				newCar := cars[1]

			car := newCar

			if car {
				tracks := sessionDB.getTracks(simulator, car)

				browserGui["carDropDown"].Choose(inList(cars, car))
			}
			else
				tracks := []

			browserGui["trackDropDown"].Delete()
			browserGui["trackDropDown"].Add(collect(tracks, ObjBindMethod(sessionDB, "getTrackName", simulator)))

			browseSoloSessions("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseTrack") {
		newTrack := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newTrack != track)) {
			if (!newTrack && (tracks.Length > 1))
				newTrack := tracks[1]

			track := newTrack

			browserGui["sessionListView"].Delete()

			if track {
				browserGui["trackDropDown"].Choose(inList(tracks, track))

				sessionDB.getSessions(simulator, car, track, "Solo", &names, &infos := true)

				for index, name in names {
					if getMultiMapValue(infos[index], "Session", "Driver", false)
						driverName := SessionDatabase.getDriverName(simulator, getMultiMapValue(infos[index], "Session", "Driver"))
					else
						driverName := false

					if !driverName
						driverName := getMultiMapValue(infos[index], "Creator", "Name")

					if !driverName
						driverName := SessionDatabase.getUserName()

					browserGui["sessionListView"].Add("", name, driverName
														, FormatTime(getMultiMapValue(infos[index], "Session", "Date"), "ShortDate") . translate(" - ")
														. FormatTime(getMultiMapValue(infos[index], "Session", "Date"), "Time"))
				}

				if (names.Length > 1)
					browserGui["sessionListView"].Modify(1, "Select +Vis")

				browserGui["sessionListView"].ModifyCol()

				loop browserGui["sessionListView"].GetCount("Col")
					browserGui["sessionListView"].ModifyCol(A_Index, "AutoHdr")
			}
		}
	}
	else {
		fileName := false

		sessionDB := SessionDatabase()
		simulators := sessionDB.getSimulators()

		result := false

		browserGui := Window({Descriptor: "Practice Session Browser", Options: "0x400000"}, translate("Load Session..."))

		if ownerOrCommand
			browserGui.Opt("+Owner" . ownerOrCommand.Hwnd)

		browserGui.Add("Text", "x8 yp+8 w70 h23 +0x200", translate("Simulator"))
		browserGui.Add("DropDownList", "x90 yp w275 vsimulatorDropDown", simulators).OnEvent("Change", selectSimulator)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Car"))
		browserGui.Add("DropDownList", "x90 yp w275 vcarDropDown").OnEvent("Change", selectCar)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Track"))
		browserGui.Add("DropDownList", "x90 yp w275 vtrackDropDown").OnEvent("Change", selectTrack)

		browserGui.Add("ListView", "x8 yp+30 w357 h335 -Multi -LV0x10 AltSubmit vsessionListView", collect(["Session", "Driver", "Date"], translate))
		browserGui["sessionListView"].OnEvent("DoubleClick", browseSoloSessions.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browseSoloSessions.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browseSoloSessions.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browseSoloSessions.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browseSoloSessions("ChooseSimulator", %arguments[1]%, true)
		browseSoloSessions("ChooseCar", %arguments[2]%, true)
		browseSoloSessions("ChooseTrack", %arguments[3]%, true)

		if getWindowPosition("Practice Session Browser", &x, &y)
			browserGui.Show("x" . x . " y" . y)
		else
			browserGui.Show()

		try {
			loop {
				Sleep(100)

				if GetKeyState("Ctrl")
					browserGui["openButton"].Text := translate("Import...")
				else
					browserGui["openButton"].Text := translate("Open...")
			}
			until result

			if (result = kOk) {
				if fileName {
					%arguments[1]% := false
					%arguments[2]% := false
					%arguments[3]% := false

					return fileName
				}
				else {
					index := browserGui["sessionListView"].GetNext()

					if index {
						%arguments[1]% := simulator
						%arguments[2]% := car
						%arguments[3]% := track

						return (sessionDB.getSessionDirectory(simulator, car, track, "Solo")
							  . browserGui["sessionListView"].GetText(index) . ".solo")
					}
					else
						return false
				}
			}
			else
				return false
		}
		finally {
			browserGui.Destroy()
		}
	}
}

browseTeamSessions(ownerOrCommand := false, arguments*) {
	local x, y, names, infos, index, name, driverName
	local carNames, trackNames, newSimulator, newCar, newTrack, force, dirName

	static sessionDB := false

	static browserGui
	static result := false

	static simulators := false
	static cars := false
	static tracks := false

	static simulator := false
	static car := false
	static track := false

	static fileName := false

	selectSimulator(*) {
		try
			browseTeamSessions("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browseTeamSessions("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browseTeamSessions("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
	}

	if ((ownerOrCommand == kOk) || (ownerOrCommand == kCancel))
		result := ownerOrCommand
	else if (ownerOrCommand = "Load") {
		browserGui.Opt("+OwnDialogs")

		if GetKeyState("Ctrl") {
			OnMessage(0x44, translateLoadCancelButtons)
			fileName := withBlockedWindows(FileSelect, "D1", kDatabaseDirectory, translate("Load Session..."))
			OnMessage(0x44, translateLoadCancelButtons, 0)
		}
		else {
			dirName := (SessionDatabase.DatabasePath . "User\")

			OnMessage(0x44, translateLoadCancelButtons)
			fileName := withBlockedWindows(FileSelect, 1, dirName, translate("Load Session..."), "Team Session (*.team)")
			OnMessage(0x44, translateLoadCancelButtons, 0)
		}

		if (fileName != "")
			browseTeamSessions(kOk)
		else
			fileName := false
	}
	else if (ownerOrCommand = "ChooseSimulator") {
		newSimulator := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if newSimulator
			newSimulator := sessionDB.getSimulatorName(newSimulator)

		if (force || (newSimulator != simulator)) {
			if (!newSimulator && (simulators.Length > 1))
				newSimulator := simulators[1]

			simulator := newSimulator

			if simulator {
				browserGui["simulatorDropDown"].Choose(inList(simulators, simulator))

				cars := sessionDB.getCars(simulator)
			}
			else {
				simulator := false

				cars := []
			}

			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			browserGui["carDropDown"].Delete()
			browserGui["carDropDown"].Add(carNames)

			browseTeamSessions("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseCar") {
		newCar := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newCar != car)) {
			if (!newCar && (cars.Length > 1))
				newCar := cars[1]

			car := newCar

			if car {
				tracks := sessionDB.getTracks(simulator, car)

				browserGui["carDropDown"].Choose(inList(cars, car))
			}
			else
				tracks := []

			browserGui["trackDropDown"].Delete()
			browserGui["trackDropDown"].Add(collect(tracks, ObjBindMethod(sessionDB, "getTrackName", simulator)))

			browseTeamSessions("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseTrack") {
		newTrack := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newTrack != track)) {
			if (!newTrack && (tracks.Length > 1))
				newTrack := tracks[1]

			track := newTrack

			browserGui["sessionListView"].Delete()

			if track {
				browserGui["trackDropDown"].Choose(inList(tracks, track))

				sessionDB.getSessions(simulator, car, track, "Team", &names, &infos := true)

				for index, name in names
					browserGui["sessionListView"].Add("", name
														, (FormatTime(getMultiMapValue(infos[index], "Session", "Date"), "ShortDate") . translate(" - ")
														 . FormatTime(getMultiMapValue(infos[index], "Session", "Date"), "Time")))

				if (names.Length > 1)
					browserGui["sessionListView"].Modify(1, "Select +Vis")

				browserGui["sessionListView"].ModifyCol()

				loop browserGui["sessionListView"].GetCount("Col")
					browserGui["sessionListView"].ModifyCol(A_Index, "AutoHdr")
			}
		}
	}
	else {
		sessionDB := SessionDatabase()
		simulators := sessionDB.getSimulators()

		fileName := false
		result := false

		browserGui := Window({Descriptor: "Race Session Browser", Options: "0x400000"}, translate("Load Session..."))

		if ownerOrCommand
			browserGui.Opt("+Owner" . ownerOrCommand.Hwnd)

		browserGui.Add("Text", "x8 yp+8 w70 h23 +0x200", translate("Simulator"))
		browserGui.Add("DropDownList", "x90 yp w275 vsimulatorDropDown", simulators).OnEvent("Change", selectSimulator)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Car"))
		browserGui.Add("DropDownList", "x90 yp w275 vcarDropDown").OnEvent("Change", selectCar)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Track"))
		browserGui.Add("DropDownList", "x90 yp w275 vtrackDropDown").OnEvent("Change", selectTrack)

		browserGui.Add("ListView", "x8 yp+30 w357 h335 -Multi -LV0x10 AltSubmit vsessionListView", collect(["Session", "Date"], translate))
		browserGui["sessionListView"].OnEvent("DoubleClick", browseTeamSessions.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browseTeamSessions.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browseTeamSessions.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browseTeamSessions.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browseTeamSessions("ChooseSimulator", %arguments[1]%, true)
		browseTeamSessions("ChooseCar", %arguments[2]%, true)
		browseTeamSessions("ChooseTrack", %arguments[3]%, true)

		if getWindowPosition("Race Session Browser", &x, &y)
			browserGui.Show("x" . x . " y" . y)
		else
			browserGui.Show()

		try {
			loop {
				Sleep(100)

				if GetKeyState("Ctrl")
					browserGui["openButton"].Text := translate("Import...")
				else
					browserGui["openButton"].Text := translate("Open...")
			}
			until result

			if (result = kOk) {
				if fileName {
					%arguments[1]% := false
					%arguments[2]% := false
					%arguments[3]% := false

					return fileName
				}
				else {
					index := browserGui["sessionListView"].GetNext()

					if index {
						%arguments[1]% := simulator
						%arguments[2]% := car
						%arguments[3]% := track

						return (sessionDB.getSessionDirectory(simulator, car, track, "Team") . browserGui["sessionListView"].GetText(index) . ".team")
					}
					else
						return false
				}
			}
			else
				return false
		}
		finally {
			browserGui.Destroy()
		}
	}
}

browseStrategies(ownerOrCommand := false, arguments*) {
	local x, y, names, infos, index, name, driverName
	local carNames, trackNames, newSimulator, newCar, newTrack, force, dirName
	local userStrategies, communityStrategies

	static sessionDB := false

	static browserGui
	static result := false

	static strategyTypes := []

	static simulators := false
	static cars := false
	static tracks := false

	static simulator := false
	static car := false
	static track := false

	static fileName := false

	selectSimulator(*) {
		try
			browseStrategies("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browseStrategies("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browseStrategies("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
	}

	if ((ownerOrCommand == kOk) || (ownerOrCommand == kCancel))
		result := ownerOrCommand
	else if (ownerOrCommand = "Load") {
		browserGui.Opt("+OwnDialogs")

		dirName := (SessionDatabase.DatabasePath . "User\")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, 1, dirName, translate("Load Strategy..."), "Strategy (*.strategy)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if (fileName != "")
			browseStrategies(kOk)
		else
			fileName := false
	}
	else if (ownerOrCommand = "ChooseSimulator") {
		newSimulator := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if newSimulator
			newSimulator := sessionDB.getSimulatorName(newSimulator)

		if (force || (newSimulator != simulator)) {
			if (!newSimulator && (simulators.Length > 1))
				newSimulator := simulators[1]

			simulator := newSimulator

			if simulator {
				browserGui["simulatorDropDown"].Choose(inList(simulators, simulator))

				cars := sessionDB.getCars(simulator)
			}
			else {
				simulator := false

				cars := []
			}

			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			browserGui["carDropDown"].Delete()
			browserGui["carDropDown"].Add(carNames)

			browseStrategies("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseCar") {
		newCar := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newCar != car)) {
			if (!newCar && (cars.Length > 1))
				newCar := cars[1]

			car := newCar

			if car {
				tracks := sessionDB.getTracks(simulator, car)

				browserGui["carDropDown"].Choose(inList(cars, car))
			}
			else
				tracks := []

			browserGui["trackDropDown"].Delete()
			browserGui["trackDropDown"].Add(collect(tracks, ObjBindMethod(sessionDB, "getTrackName", simulator)))

			browseStrategies("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
		}
	}
	else if (ownerOrCommand = "ChooseTrack") {
		newTrack := arguments[1]
		force := ((arguments.Length > 1) ? arguments[2] : false)

		if (force || (newTrack != track)) {
			if (!newTrack && (tracks.Length > 1))
				newTrack := tracks[1]

			track := newTrack

			browserGui["strategyListView"].Delete()

			if track {
				browserGui["trackDropDown"].Choose(inList(tracks, track))

				sessionDB.getStrategyNames(simulator, car, track, &userStrategies := true
																, &communityStrategies := sessionDB.UseCommunity)

				names := userStrategies
				strategyTypes := []

				loop names.Length
					strategyTypes.Push("User")

				if sessionDB.UseCommunity
					for index, name in communityStrategies
						if !inList(names, name) {
							names.Push(name)
							strategyTypes.Push("Community")
						}

				for index, name in names
					browserGui["strategyListView"].Add("", name)

				if (names.Length > 1)
					browserGui["strategyListView"].Modify(1, "Select +Vis")

				browserGui["strategyListView"].ModifyCol()

				loop browserGui["strategyListView"].GetCount("Col")
					browserGui["strategyListView"].ModifyCol(A_Index, "AutoHdr")
			}
		}
	}
	else {
		sessionDB := SessionDatabase()
		simulators := sessionDB.getSimulators()

		fileName := false
		result := false

		browserGui := Window({Descriptor: "Strategy Browser", Options: "0x400000"}, translate("Load Strategy..."))

		if ownerOrCommand
			browserGui.Opt("+Owner" . ownerOrCommand.Hwnd)

		browserGui.Add("Text", "x8 yp+8 w70 h23 +0x200", translate("Simulator"))
		browserGui.Add("DropDownList", "x90 yp w275 vsimulatorDropDown", simulators).OnEvent("Change", selectSimulator)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Car"))
		browserGui.Add("DropDownList", "x90 yp w275 vcarDropDown").OnEvent("Change", selectCar)

		browserGui.Add("Text", "x8 yp+24 w70 h23 +0x200", translate("Track"))
		browserGui.Add("DropDownList", "x90 yp w275 vtrackDropDown").OnEvent("Change", selectTrack)

		browserGui.Add("ListView", "x8 yp+30 w357 h335 -Multi -LV0x10 AltSubmit vstrategyListView", collect(["Strategy"], translate))
		browserGui["strategyListView"].OnEvent("DoubleClick", browseStrategies.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browseStrategies.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browseStrategies.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browseStrategies.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browseStrategies("ChooseSimulator", %arguments[1]%, true)
		browseStrategies("ChooseCar", %arguments[2]%, true)
		browseStrategies("ChooseTrack", %arguments[3]%, true)

		if getWindowPosition("Strategy Browser", &x, &y)
			browserGui.Show("x" . x . " y" . y)
		else
			browserGui.Show()

		try {
			loop
				Sleep(100)
			until result

			if (result = kOk) {
				if fileName {
					%arguments[1]% := false
					%arguments[2]% := false
					%arguments[3]% := false

					return fileName
				}
				else {
					index := browserGui["strategyListView"].GetNext()

					if index {
						%arguments[1]% := simulator
						%arguments[2]% := car
						%arguments[3]% := track

						return (sessionDB.getStrategyDirectory(simulator, car, track, strategyTypes[index]) . browserGui["strategyListView"].GetText(index) . ".strategy")
					}
					else
						return false
				}
			}
			else
				return false
		}
		finally {
			browserGui.Destroy()
		}
	}
}