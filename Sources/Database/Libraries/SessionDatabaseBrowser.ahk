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

browsePracticeSessions(ownerOrCommand := false, arguments*) {
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
			browsePracticeSessions("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browsePracticeSessions("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browsePracticeSessions("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
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
			browsePracticeSessions(kOk)
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

			browsePracticeSessions("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
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

			browsePracticeSessions("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
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

				sessionDB.getSessions(simulator, car, track, "Practice", &names, &infos := true)

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
		browserGui["sessionListView"].OnEvent("DoubleClick", browsePracticeSessions.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browsePracticeSessions.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browsePracticeSessions.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browsePracticeSessions.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browsePracticeSessions("ChooseSimulator", %arguments[1]%, true)
		browsePracticeSessions("ChooseCar", %arguments[2]%, true)
		browsePracticeSessions("ChooseTrack", %arguments[3]%, true)

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

						return (sessionDB.getSessionDirectory(simulator, car, track, "Practice")
							  . browserGui["sessionListView"].GetText(index) . ".practice")
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

browseRaceSessions(ownerOrCommand := false, arguments*) {
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
			browseRaceSessions("ChooseSimulator", simulators[browserGui["simulatorDropDown"].Value])
	}

	selectCar(*) {
		try
			browseRaceSessions("ChooseCar", cars[browserGui["carDropDown"].Value])
	}

	selectTrack(*) {
		try
			browseRaceSessions("ChooseTrack", tracks[browserGui["trackDropDown"].Value])
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
			browseRaceSessions(kOk)
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

			browseRaceSessions("ChooseCar", (cars.Length > 0) ? cars[1] : false, true)
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

			browseRaceSessions("ChooseTrack", (tracks.Length > 0) ? tracks[1] : false, true)
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

				sessionDB.getSessions(simulator, car, track, "Race", &names, &infos := true)

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
		browserGui["sessionListView"].OnEvent("DoubleClick", browseRaceSessions.Bind(kOk))

		browserGui.Add("Button", "x8 yp+345 w80 h23 vopenButton", translate("Open...")).OnEvent("Click", browseRaceSessions.Bind("Load"))

		browserGui.Add("Button", "x197 yp w80 h23 Default", translate("Load")).OnEvent("Click", browseRaceSessions.Bind(kOk))
		browserGui.Add("Button", "x285 yp w80 h23", translate("&Cancel")).OnEvent("Click", browseRaceSessions.Bind(kCancel))

		browserGui.Show("AutoSize Center")

		browseRaceSessions("ChooseSimulator", %arguments[1]%, true)
		browseRaceSessions("ChooseCar", %arguments[2]%, true)
		browseRaceSessions("ChooseTrack", %arguments[3]%, true)

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

						return (sessionDB.getSessionDirectory(simulator, car, track, "Race") . browserGui["sessionListView"].GetText(index) . ".race")
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