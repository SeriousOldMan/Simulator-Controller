;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Settings Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Race Settings.ico
;@Ahk2Exe-ExeName Race Settings.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\CLR.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLoad := "Load"
global kSave := "Save"
global kOk := "Ok"
global kCancel := "Cancel"
global kConnect := "Connect"
global kUpdate := "Update"

global kRaceSettingsFile := getFileName("Race.settings", kUserConfigDirectory)


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gSimulator := false
global gCar := false
global gTrack := false
global gWeather := "Dry"
global gAirTemperature := 23
global gTrackTemperature := 27

global gTyreCompounds := kTyreCompounds

global gTyreCompound := false
global gTyreCompoundColor := false

global gSilentMode := kSilentMode
global gTeamMode := true
global gTestMode := false


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isPositiveFloat(numbers*) {
	local ignore, value

	for ignore, value in numbers {
		value := internalValue("Float", value)

		if !isFloat(value)
			return false
		else if (value < 0)
			return false
	}

	return true
}

isPositiveNumber(numbers*) {
	local ignore, value

	for ignore, value in numbers
		if !isNumber(value) {
			value := internalValue("Float", value)

			if !isNumber(value)
				return false
			else if (value < 0)
				return false
		}
		else if (value < 0)
			return false

	return true
}

getDeprecatedValue(data, newSection, oldSection, key, default := false) {
	local value := getMultiMapValue(data, newSection, key, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getMultiMapValue(data, oldSection, key, default)
}

loginDialog(connectorOrCommand := false, teamServerURL := false, owner := false, *) {
	local loginGui

	static name := ""
	static password := ""

	static result := false
	static nameEdit
	static passwordEdit

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false

		loginGui := Window()

		loginGui.SetFont("Norm", "Arial")

		loginGui.Add("Text", "x16 y16 w90 h23 +0x200", translate("Server URL"))
		loginGui.Add("Text", "x110 yp w160 h23 +0x200", teamServerURL)

		loginGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Name"))
		nameEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21", name)

		loginGui.Add("Text", "x16 yp+23 w90 h23 +0x200", translate("Password"))
		passwordEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21 Password", password)

		loginGui.Add("Button", "x60 yp+35 w80 h23 Default", translate("Ok")).OnEvent("Click", loginDialog.Bind(kOk))
		loginGui.Add("Button", "x146 yp w80 h23", translate("&Cancel")).OnEvent("Click", loginDialog.Bind(kCancel))

		loginGui.Opt("+Owner" . owner.Hwnd)

		loginGui.Show("AutoSize Center")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				name := nameEdit.Text
				password := passwordEdit.Text

				try {
					connectorOrCommand.Initialize(teamServerURL)

					connectorOrCommand.Login(name, password)

					return connectorOrCommand.GetSessionToken()
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					MsgBox((translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return false
				}
			}
		}
		finally {
			loginGui.Destroy()
		}
	}
}

editRaceSettings(&settingsOrCommand, arguments*) {
	global kLoad, kSave, kOk, kCancel, kConnect, kUpdate

	local dllFile, names, exception, value, chosen, choices, tabs, import, simulator, ignore, option
	local dirName, simulatorCode, file, tyreCompound, tyreCompoundColor, fileName, token
	local x, y, e, directory, connection, settings, serverURLs, settingsTab

	local setupTyreCompound := "Dry"
	local setupTyreCompoundColor := "Black"
	local dryFrontLeft := 26.1, dryFrontRight := 26.1, dryRearLeft := 26.1, dryRearRight := 26.1
	local wetFrontLeft := 28.5, wetFrontRight := 28.5, wetRearLeft := 28.5, wetRearRight := 28.5

	static setupTyreSet := false
	static pitstopTyreSet := false

	static settingsGui

	static result
	static newSettings

	static connector
	static connected
	static keepAliveTask := false

	static serverURL, serverToken, teamName, theDriverName, sessionName, teamIdentifier, driverIdentifier, sessionIdentifier

	static teams := CaseInsenseMap()
	static drivers := CaseInsenseMap()
	static sessions := CaseInsenseMap()

	parseObject(properties) {
		local result := CaseInsenseMap()
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, "`n" {
			property := string2Values("=", A_LoopField)

			result[property[1]] := property[2]
		}

		return result
	}

	loadTeams(connector) {
		local teams := CaseInsenseMap()
		local identifiers, ignore, identifier, team

		try {
			identifiers := string2Values(";", connector.GetAllTeams())
		}
		catch Any as exception {
			identifiers := []
		}

		for ignore, identifier in identifiers {
			team := parseObject(connector.GetTeam(identifier))

			teams[team["Name"]] := team["Identifier"]
		}

		return teams
	}

	loadDrivers(connector, team) {
		local drivers := CaseInsenseMap()
		local identifiers, ignore, identifier, driver

		if team {
			try {
				identifiers := string2Values(";", connector.GetTeamDrivers(team))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				driver := parseObject(connector.GetDriver(identifier))

				drivers[driverName(driver["ForName"], driver["SurName"], driver["NickName"])] := driver["Identifier"]
			}
		}

		return drivers
	}

	loadSessions(connector, team) {
		local sessions := CaseInsenseMap()
		local identifiers, ignore, identifier, session

		if team {
			try {
				identifiers := string2Values(";", connector.GetTeamSessions(team))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					session := parseObject(connector.GetSession(identifier))

					sessions[session["Name"]] := session["Identifier"]
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		return sessions
	}

	updateRepairSuspensionState(*) {
		local repairSuspensionDropDown := settingsGui["repairSuspensionDropDown"].Value

		if ((repairSuspensionDropDown == 1) || (repairSuspensionDropDown == 2)) {
			settingsGui["repairSuspensionGreaterLabel"].Visible := false
			settingsGui["repairSuspensionThresholdEdit"].Visible := false
			settingsGui["repairSuspensionThresholdLabel"].Visible := false

			settingsGui["repairSuspensionThresholdEdit"].Text := 0
		}
		else if (repairSuspensionDropDown == 3) {
			settingsGui["repairSuspensionGreaterLabel"].Visible := true
			settingsGui["repairSuspensionThresholdEdit"].Visible := true
			settingsGui["repairSuspensionThresholdLabel"].Visible := true

			settingsGui["repairSuspensionThresholdLabel"].Text := translate("Seconds")
		}
		else if (repairSuspensionDropDown == 4) {
			settingsGui["repairSuspensionGreaterLabel"].Visible := true
			settingsGui["repairSuspensionThresholdEdit"].Visible := true
			settingsGui["repairSuspensionThresholdLabel"].Visible := true

			settingsGui["repairSuspensionThresholdLabel"].Text := translate("Sec. p. Lap")
		}
	}

	updateRepairBodyworkState(*) {
		local repairBodyworkDropDown := settingsGui["repairBodyworkDropDown"].Value

		if ((repairBodyworkDropDown == 1) || (repairBodyworkDropDown == 2)) {
			settingsGui["repairBodyworkGreaterLabel"].Visible := false
			settingsGui["repairBodyworkThresholdEdit"].Visible := false
			settingsGui["repairBodyworkThresholdLabel"].Visible := false

			settingsGui["repairBodyworkThresholdEdit"].Text := 0
		}
		else if (repairBodyworkDropDown == 3) {
			settingsGui["repairBodyworkGreaterLabel"].Visible := true
			settingsGui["repairBodyworkThresholdEdit"].Visible := true
			settingsGui["repairBodyworkThresholdLabel"].Visible := true

			settingsGui["repairBodyworkThresholdLabel"].Text := translate("Seconds")
		}
		else if (repairBodyworkDropDown == 4) {
			settingsGui["repairBodyworkGreaterLabel"].Visible := true
			settingsGui["repairBodyworkThresholdEdit"].Visible := true
			settingsGui["repairBodyworkThresholdLabel"].Visible := true

			settingsGui["repairBodyworkThresholdLabel"].Text := translate("Sec. p. Lap")
		}
	}

	updateRepairEngineState(*) {
		local repairEngineDropDown := settingsGui["repairEngineDropDown"].Value

		if ((repairEngineDropDown == 1) || (repairEngineDropDown == 2)) {
			settingsGui["repairEngineGreaterLabel"].Visible := false
			settingsGui["repairEngineThresholdEdit"].Visible := false
			settingsGui["repairEngineThresholdLabel"].Visible := false

			settingsGui["repairEngineThresholdEdit"].Text := 0
		}
		else if (repairEngineDropDown == 3) {
			settingsGui["repairEngineGreaterLabel"].Visible := true
			settingsGui["repairEngineThresholdEdit"].Visible := true
			settingsGui["repairEngineThresholdLabel"].Visible := true

			settingsGui["repairEngineThresholdLabel"].Text := translate("Seconds")
		}
		else if (repairEngineDropDown == 4) {
			settingsGui["repairEngineGreaterLabel"].Visible := true
			settingsGui["repairEngineThresholdEdit"].Visible := true
			settingsGui["repairEngineThresholdLabel"].Visible := true

			settingsGui["repairEngineThresholdLabel"].Text := translate("Sec. p. Lap")
		}
	}

	updateChangeTyreState(*) {
		local changeTyreDropDown := settingsGui["changeTyreDropDown"].Value

		if ((changeTyreDropDown == 1) || (changeTyreDropDown == 3)) {
			settingsGui["changeTyreGreaterLabel"].Visible := false
			settingsGui["changeTyreThresholdEdit"].Visible := false
			settingsGui["changeTyreThresholdLabel"].Visible := false

			settingsGui["changeTyreThresholdEdit"].Text := 0
		}
		else if (changeTyreDropDown == 2) {
			settingsGui["changeTyreGreaterLabel"].Visible := true
			settingsGui["changeTyreThresholdEdit"].Visible := true
			settingsGui["changeTyreThresholdLabel"].Visible := true

			settingsGui["changeTyreThresholdLabel"].Text := translate("Degrees")
		}
		else if (changeTyreDropDown == 4) {
			settingsGui["changeTyreGreaterLabel"].Visible := true
			settingsGui["changeTyreThresholdEdit"].Visible := true
			settingsGui["changeTyreThresholdLabel"].Visible := true

			settingsGui["changeTyreThresholdLabel"].Text := translate("Sec. p. Lap")
		}
	}

	openSessionDatabase(*) {
		local exePath := kBinariesDirectory . "Session Database.exe"
		local pid, options, ignore, arg

		try {
			options := []

			for ignore, arg in A_Args
				options.Push("`"" . arg . "`"")

			options.Push("-Setup")

			options.Push(ProcessExist())

			options := values2String(A_Space, options*)

			Run("`"" . exePath . "`" " . options, kBinariesDirectory, , &pid)
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Cannot start the Session Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	importFromSimulation(message := false, simulator := false, prefix := false, settings := false) {
		local result := false
		local candidate, ignore, data, tyreCompound, tyreCompoundColor

		if (message != "Import") {
			settings := false

			simulator := false

			for candidate, ignore in getMultiMapValues(getControllerState(), "Simulators")
				if Application(candidate, kSimulatorConfiguration).isRunning() {
					simulator := candidate

					break
				}

			prefix := SessionDatabase.getSimulatorCode(simulator)
		}

		data := readSimulatorData(prefix)

		if (getMultiMapValues(data, "Setup Data").Count > 0) {
			readTyreSetup(readMultiMap(kRaceSettingsFile))

			pitstopTyreSet := getMultiMapValue(data, "Setup Data", "TyreSet", pitstopTyreSet)
			setupTyreSet := getMultiMapValue(data, "Car Data", "TyreSet", setupTyreSet ? setupTyreSet : Max(0, pitstopTyreSet - 1))

			if settings {
				if (getMultiMapValue(settings, "Session Setup", "Tyre.Set.Fresh", 0) != 0)
					setMultiMapValue(settings, "Session Setup", "Tyre.Set.Fresh", pitstopTyreSet)

				if (getMultiMapValue(settings, "Session Setup", "Tyre.Set", 0) = 0)
					setMultiMapValue(settings, "Session Setup", "Tyre.Set", setupTyreSet)
			}

			tyreCompound := getMultiMapValue(data, "Setup Data", "TyreCompound", setupTyreCompound)
			tyreCompoundColor := getMultiMapValue(data, "Setup Data", "TyreCompoundColor", setupTyreCompoundColor)

			if (tyreCompound = "Dry") {
				dryFrontLeft := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureFL", dryFrontLeft)))
				dryFrontRight := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureFR", dryFrontRight)))
				dryRearLeft := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureRL", dryRearLeft)))
				dryRearRight := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureRR", dryRearRight)))

				if settings {
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound", tyreCompound)
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", tyreCompoundColor)

					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.FL", convertUnit("Pressure", internalValue("Float", dryFrontLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.FR", convertUnit("Pressure", internalValue("Float", dryFrontRight), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.RL", convertUnit("Pressure", internalValue("Float", dryRearLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.RR", convertUnit("Pressure", internalValue("Float", dryRearRight), false))

					if (!gSilentMode && !inList(["rFactor 2", "Automobilista 2", "Project CARS 2"], simulator)) {
						message := (translate("Tyre setup imported: ") . translate(compound(tyreCompound, tyreCompoundColor)))

						showMessage(message . translate(", Set ") . setupTyreSet . translate("; ")
										    . dryFrontLeft . translate(", ") . dryFrontRight . translate(", ")
											. dryRearLeft . translate(", ") . dryRearRight, false, "Information.png", 5000)
					}
				}

				result := tyreCompound
			}
			else if ((tyreCompound = "Wet") || (tyreCompound = "Intermediate")) {
				wetFrontLeft := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureFL", wetFrontLeft)))
				wetFrontRight := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureFR", wetFrontRight)))
				wetRearLeft := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureRL", wetRearLeft)))
				wetRearRight := displayValue("Float", convertUnit("Pressure", getMultiMapValue(data, "Setup Data", "TyrePressureRR", wetRearRight)))

				if settings {
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound", tyreCompound)
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", tyreCompoundColor)

					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.FL", convertUnit("Pressure", internalValue("Float", wetFrontLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.FR", convertUnit("Pressure", internalValue("Float", wetFrontRight), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.RL", convertUnit("Pressure", internalValue("Float", wetRearLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.RR", convertUnit("Pressure", internalValue("Float", wetRearRight), false))

					if (!gSilentMode && !inList(["rFactor 2", "Automobilista 2", "Project CARS 2"], simulator)) {
						message := (translate("Tyre setup imported: ") . compound(tyreCompound, tyreCompoundColor))

						showMessage(message . translate("; ")
											. wetFrontLeft . translate(", ") . wetFrontRight . translate(", ")
											. wetRearLeft . translate(", ") . wetRearRight, false, "Information.png", 5000)
					}
				}

				result := tyreCompound
			}

			setupTyreCompound := tyreCompound
			setupTyreCompoundColor := tyreCompoundColor
		}

		return result
	}

	chooseRefuelService(*) {
		settingsGui["pitstopRefuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][settingsGui["pitstopRefuelServiceRuleDropdown"].Value])
	}

	setTyrePressures(tyreCompound, tyreCompoundColor, flPressure, frPressure, rlPressure, rrPressure) {
		if (tyreCompound = "Wet") {
			settingsGui["spWetFrontLeftEdit"].Text := displayValue("Float", convertUnit("Pressure", flPressure))
			settingsGui["spWetFrontRightEdit"].Text := displayValue("Float", convertUnit("Pressure", frPressure))
			settingsGui["spWetRearLeftEdit"].Text := displayValue("Float", convertUnit("Pressure", rlPressure))
			settingsGui["spWetRearRightEdit"].Text := displayValue("Float", convertUnit("Pressure", rrPressure))
		}
		else {
			settingsGui["spDryFrontLeftEdit"].Text := displayValue("Float", convertUnit("Pressure", flPressure))
			settingsGui["spDryFrontRightEdit"].Text := displayValue("Float", convertUnit("Pressure", frPressure))
			settingsGui["spDryRearLeftEdit"].Text := displayValue("Float", convertUnit("Pressure", rlPressure))
			settingsGui["spDryRearRightEdit"].Text := displayValue("Float", convertUnit("Pressure", rrPressure))
		}

		return false
	}

	readTyreSetup(settings) {
		if (gTyreCompound && gTyreCompoundColor) {
			setupTyreCompound := gTyreCompound
			setupTyreCompoundColor := gTyreCompoundColor
		}
		else {
			setupTyreCompound := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
			setupTyreCompoundColor := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")
		}

		setupTyreSet := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Set", false)
		pitstopTyreSet := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Set.Fresh", false)

		dryFrontLeft := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)))
		dryFrontRight := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)))
		dryRearLeft := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)))
		dryRearRight := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)))
		wetFrontLeft := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FL", 28.5)))
		wetFrontRight := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FR", 28.5)))
		wetRearLeft := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RL", 28.5)))
		wetRearRight := displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RR", 28.5)))
	}

	validateNumber(field, *) {
		field := settingsGui[field]

		if !isNumber(internalValue("Float", field.Text)) {
			field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

			loop 10
				SendInput("{Right}")
		}
		else
			field.ValidText := field.Text
	}

	updateStrategyLaps(type, *) {
		if (type = "Check") {
			if settingsGui["strategyUpdateLapsCheck"].Value {
				settingsGui["strategyUpdateLapsEdit"].Enabled := true

				if (settingsGui["strategyUpdateLapsEdit"].Text = "0")
					settingsGui["strategyUpdateLapsEdit"].Text := 1
			}
			else {
				settingsGui["strategyUpdateLapsEdit"].Enabled := false
				settingsGui["strategyUpdateLapsEdit"].Text := 1
			}
		}
		else
			settingsGui["strategyUpdateLapsCheck"].Enabled := (settingsGui["strategyUpdateLapsEdit"].Text > 0)

	}

	updateStrategyPitstop(type, *) {
		if (type = "Check") {
			if settingsGui["strategyUpdatePitstopCheck"].Value {
				settingsGui["strategyUpdatePitstopEdit"].Enabled := true

				if (settingsGui["strategyUpdatePitstopEdit"].Text = "0")
					settingsGui["strategyUpdatePitstopEdit"].Text := 4
			}
			else {
				settingsGui["strategyUpdatePitstopEdit"].Enabled := false
				settingsGui["strategyUpdatePitstopEdit"].Text := 4
			}
		}
		else
			settingsGui["strategyUpdatePitstopCheck"].Enabled := (settingsGui["strategyUpdatePitstopEdit"].Text > 0)

	}

	updateTyreSet(field, *) {
		local value := settingsGui[field].Text

		if !isInteger(value)
			value := 0

		if (value = 0)
			settingsGui[field].Text := translate("Auto ")

		if (field = "spSetupTyreSetEdit")
			setupTyreSet := value
		else
			pitstopTyreSet := value
	}

	if (settingsOrCommand == kLoad) {
		if (gSimulator && gCar && gTrack) {
			directory := SessionDatabase.DatabasePath
			simulatorCode := SessionDatabase.getSimulatorCode(gSimulator)

			dirName := (directory . "User\" . simulatorCode . "\" . gCar . "\" . gTrack . "\Race Settings")

			DirCreate(dirName)
		}
		else
			dirName := kRaceSettingsFile

		settingsGui.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		file := FileSelect(1, dirName, translate("Load Race Settings..."), "Settings (*.settings)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if (file != "") {
			newSettings := readMultiMap(file)

			result := "Restart"
		}
	}
	else if (settingsOrCommand == kCancel)
		result := kCancel
	else if (settingsOrCommand == "Export")
		return importFromSimulation("Import", arguments*)
	else if (settingsOrCommand == "Import") {
		value := importFromSimulation("Editor")

		if value {
			settingsGui["spSetupTyreSetEdit"].Text := (setupTyreSet ? setupTyreSet : translate("Auto "))
			settingsGui["spPitstopTyreSetEdit"].Text := (pitstopTyreSet ? pitstopTyreSet : translate("Auto "))

			settingsGui["spSetupTyreCompoundDropDown"].Choose(inList(gTyreCompounds, compound(setupTyreCompound, setupTyreCompoundColor)))
		}

		if (value = "Dry") {
			settingsGui["spDryFrontLeftEdit"].Text := dryFrontLeft
			settingsGui["spDryFrontRightEdit"].Text := dryFrontRight
			settingsGui["spDryRearLeftEdit"].Text := dryRearLeft
			settingsGui["spDryRearRightEdit"].Text := dryRearRight
		}
		else if ((value = "Wet") || (value = "Intermediate")) {
			settingsGui["spWetFrontLeftEdit"].Text := wetFrontLeft
			settingsGui["spWetFrontRightEdit"].Text := wetFrontRight
			settingsGui["spWetRearLeftEdit"].Text := wetRearLeft
			settingsGui["spWetRearRightEdit"].Text := wetRearRight
		}
	}
	else if (settingsOrCommand == kUpdate) {
		if connected
			if (arguments[1] == "Team") {
				if ((teams.Count > 0) || (settingsGui["teamDropDownMenu"].Value = 0)) {
					teamName := getKeys(teams)[settingsGui["teamDropDownMenu"].Value]
					teamIdentifier := teams[teamName]

					exception := false

					try {
						drivers := loadDrivers(connector, teamIdentifier)
					}
					catch Any as e {
						drivers := CaseInsenseMap()

						exception := e
					}
				}
				else {
					teamName := ""
					teamIdentifier := false
					drivers := CaseInsenseMap()
				}

				names := getKeys(drivers)
				chosen := inList(getValues(drivers), driverIdentifier)

				if ((chosen == 0) && (names.Length > 0))
					chosen := 1

				if (chosen == 0) {
					theDriverName := ""
					driverIdentifier := false
				}
				else {
					theDriverName := names[chosen]
					driverIdentifier := drivers[theDriverName]
				}

				settingsGui["driverDropDownMenu"].Delete()
				settingsGui["driverDropDownMenu"].Add(names)
				settingsGui["driverDropDownMenu"].Choose(chosen)

				try {
					sessions := loadSessions(connector, teamIdentifier)
				}
				catch Any as e {
					sessions := CaseInsenseMap()

					exception := e
				}

				names := getKeys(sessions)
				chosen := inList(getValues(sessions), sessionIdentifier)

				if ((chosen == 0) && (names.Length > 0))
					chosen := 1

				if (chosen == 0) {
					sessionName := ""
					sessionIdentifier := false
				}
				else {
					sessionName := names[chosen]
					sessionIdentifier := sessions[sessionName]
				}

				settingsGui["sessionDropDownMenu"].Delete()
				settingsGui["sessionDropDownMenu"].Add(names)
				settingsGui["sessionDropDownMenu"].Choose(chosen)

				if exception
					throw exception
			}
			else if (arguments[1] == "Driver") {
				if ((drivers.Count > 0) || (settingsGui["driverDropDownMenu"].Value = 0)) {
					theDriverName := getKeys(drivers)[settingsGui["driverDropDownMenu"].Value]
					driverIdentifier := drivers[theDriverName]
				}
				else {
					theDriverName := ""
					driverIdentifier := false
				}
			}
			else if (arguments[1] == "Session") {
				if ((sessions.Count > 0) || (settingsGui["sessionDropDownMenu"].Value = 0)) {
					sessionName := getKeys(sessions)[settingsGui["sessionDropDownMenu"].Value]
					sessionIdentifier := sessions[sessionName]
				}
				else {
					sessionName := ""
					sessionIdentifier := false
				}
			}
	}
	else if (settingsOrCommand == kConnect) {
		serverURL := settingsGui["serverURLEdit"].Text
		serverToken := settingsGui["serverTokenEdit"].Text

		if connector {
			if GetKeyState("Ctrl", "P") {
				settingsGui.Block()

				try {
					token := loginDialog(connector, serverURL, settingsGui)

					if token {
						serverToken := token

						settingsGui["serverTokenEdit"].Text := token
					}
					else
						return
				}
				finally {
					settingsGui.Unblock()
				}
			}

			try {
				connector.Initialize(serverURL, serverToken)

				connection := connector.Connect(serverToken, SessionDatabase.ID
											  , gSimulator ? SessionDatabase.getDriverName(gSimulator, SessionDatabase.ID) : SessionDatabase.getUserName()
											  , "Driver")

				if (connection && (connection != "")) {
					settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

					serverURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

					if !inList(serverURLs, serverURL) {
						serverURLs.Push(serverURL)

						setMultiMapValue(settings, "Team Server", "Server URLs", values2String(";", serverURLs*))

						writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

						settingsGui["serverURLEdit"].Delete()
						settingsGui["serverURLEdit"].Add(serverURLs)
						settingsGui["serverURLEdit"].Choose(inList(serverURLs, serverURL))
					}

					connector.ValidateSessionToken()

					if keepAliveTask
						keepAliveTask.stop()

					keepAliveTask := PeriodicTask(ObjBindMethod(connector, "KeepAlive", connection), 120000, kLowPriority)

					keepAliveTask.start()

					teams := loadTeams(connector)

					names := getKeys(teams)
					chosen := inList(getValues(teams), teamIdentifier)

					if ((chosen == 0) && (names.Length > 0))
						chosen := 1

					if (chosen == 0) {
						teamName := ""
						teamIdentifier := false
					}
					else {
						teamName := names[chosen]
						teamIdentifier := teams[teamName]
					}

					settingsGui["teamDropDownMenu"].Delete()
					settingsGui["teamDropDownMenu"].Add(names)
					settingsGui["teamDropDownMenu"].Choose(chosen)

					connected := true

					editRaceSettings(&kUpdate, "Team")

					showMessage(translate("Successfully connected to the Team Server."))
				}
				else
					throw "Invalid or missing token..."
			}
			catch Any as exception {
				OnMessage(0x44, translateOkButton)
				MsgBox((translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
		}
	}
	else if (settingsOrCommand = "TyrePressures")
		setTyrePressures(arguments*)
	else if ((settingsOrCommand == kSave) || (settingsOrCommand == kOk)) {
		newSettings := newMultiMap()

		if (!isPositiveFloat(settingsGui["tyrePressureDeviationEdit"].Text
						   , settingsGui["tpDryFrontLeftEdit"].Text, settingsGui["tpDryFrontRightEdit"].Text
						   , settingsGui["tpDryRearLeftEdit"].Text, settingsGui["tpDryRearRightEdit"].Text
						   , settingsGui["tpWetFrontLeftEdit"].Text, settingsGui["tpWetFrontRightEdit"].Text
						   , settingsGui["tpWetRearLeftEdit"].Text, settingsGui["tpWetRearRightEdit"].Text
						   , settingsGui["spDryFrontLeftEdit"].Text, settingsGui["spDryFrontRightEdit"].Text
						   , settingsGui["spDryRearLeftEdit"].Text, settingsGui["spDryRearRightEdit"].Text
						   , settingsGui["spWetFrontLeftEdit"].Text, settingsGui["spWetFrontRightEdit"].Text
						   , settingsGui["spWetRearLeftEdit"].Text, settingsGui["spWetRearRightEdit"].Text)
		 || !isPositiveNumber(settingsGui["fuelConsumptionEdit"].Text, settingsGui["pitstopRefuelServiceEdit"].Text
							, settingsGui["repairSuspensionThresholdEdit"].Text, settingsGui["repairBodyworkThresholdEdit"].Text, settingsGui["repairEngineThresholdEdit"].Text)
		 || (!isInteger(settingsGui["trafficConsideredEdit"].Text) || (settingsGui["trafficConsideredEdit"].Text < 1) || (settingsGui["trafficConsideredEdit"].Text > 100))) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}

		setMultiMapValue(newSettings, "Session Settings", "Lap.PitstopWarning", settingsGui["pitstopWarningEdit"].Text)

		setMultiMapValue(newSettings, "Session Settings", "Damage.Suspension.Repair"
									, ["Never", "Always", "Threshold", "Impact"][settingsGui["repairSuspensionDropDown"].Value])
		setMultiMapValue(newSettings, "Session Settings", "Damage.Suspension.Repair.Threshold", internalValue("Float", settingsGui["repairSuspensionThresholdEdit"].Text, 1))

		setMultiMapValue(newSettings, "Session Settings", "Damage.Bodywork.Repair"
									, ["Never", "Always", "Threshold", "Impact"][settingsGui["repairBodyworkDropDown"].Value])
		setMultiMapValue(newSettings, "Session Settings", "Damage.Bodywork.Repair.Threshold", internalValue("Float", settingsGui["repairBodyworkThresholdEdit"].Text, 1))

		setMultiMapValue(newSettings, "Session Settings", "Damage.Engine.Repair"
									, ["Never", "Always", "Threshold", "Impact"][settingsGui["repairEngineDropDown"].Value])
		setMultiMapValue(newSettings, "Session Settings", "Damage.Engine.Repair.Threshold", internalValue("Float", settingsGui["repairEngineThresholdEdit"].Text, 1))

		setMultiMapValue(newSettings, "Session Settings", "Tyre.Compound.Change"
									, ["Never", "Temperature", "Weather"][settingsGui["changeTyreDropDown"].Value])
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Compound.Change.Threshold", internalValue("Float", settingsGui["changeTyreThresholdEdit"].Text, 1))

		setMultiMapValue(newSettings, "Session Settings", "Tyre.Pressure.Deviation", internalValue("Float", settingsGui["tyrePressureDeviationEdit"].Text, 1))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Temperature", settingsGui["temperatureCorrectionCheck"].Value)
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Setup", settingsGui["setupPressureCompareCheck"].Value)
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Pressure", settingsGui["pressureLossCorrectionCheck"].Value)

		setMultiMapValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.FL"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpDryFrontLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.FR"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpDryFrontRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.RL"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpDryRearLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.RR"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpDryRearRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.FL"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpWetFrontLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.FR"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpWetFrontRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.RL"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpWetRearLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.RR"
									, convertUnit("Pressure", internalValue("Float", settingsGui["tpWetRearRightEdit"].Text), false))

		setMultiMapValue(newSettings, "Session Settings", "Lap.AvgTime", settingsGui["avgLaptimeEdit"].Text)
		setMultiMapValue(newSettings, "Session Settings", "Fuel.AvgConsumption", convertUnit("Volume", internalValue("Float", settingsGui["fuelConsumptionEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Fuel.SafetyMargin", Round(convertUnit("Volume", internalValue("Float", settingsGui["safetyFuelEdit"].Text), false)))

		setMultiMapValue(newSettings, "Session Settings", "Lap.Formation", settingsGui["formationLapCheck"].Value)
		setMultiMapValue(newSettings, "Session Settings", "Lap.PostRace", settingsGui["postRaceLapCheck"].Value)

		splitCompound(gTyreCompounds[settingsGui["spSetupTyreCompoundDropDown"].Value], &tyreCompound, &tyreCompoundColor)

		setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound", tyreCompound)
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound.Color", tyreCompoundColor)

		setMultiMapValue(newSettings, "Session Setup", "Tyre.Set", isInteger(settingsGui["spSetupTyreSetEdit"].Text) ? settingsGui["spSetupTyreSetEdit"].Text : false)
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Set.Fresh", isInteger(settingsGui["spPitstopTyreSetEdit"].Text) ? settingsGui["spPitstopTyreSetEdit"].Text : false)

		setMultiMapValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.FL", convertUnit("Pressure", internalValue("Float", settingsGui["spDryFrontLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.FR", convertUnit("Pressure", internalValue("Float", settingsGui["spDryFrontRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.RL", convertUnit("Pressure", internalValue("Float", settingsGui["spDryRearLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.RR", convertUnit("Pressure", internalValue("Float", settingsGui["spDryRearRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.FL", convertUnit("Pressure", internalValue("Float", settingsGui["spWetFrontLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.FR", convertUnit("Pressure", internalValue("Float", settingsGui["spWetFrontRightEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.RL", convertUnit("Pressure", internalValue("Float", settingsGui["spWetRearLeftEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.RR", convertUnit("Pressure", internalValue("Float", settingsGui["spWetRearRightEdit"].Text), false))

		setMultiMapValue(newSettings, "Strategy Settings", "Pitstop.Delta", settingsGui["pitstopDeltaEdit"].Text)
		setMultiMapValue(newSettings, "Strategy Settings", "Service.Tyres", settingsGui["pitstopTyreServiceEdit"].Text)
		setMultiMapValue(newSettings, "Strategy Settings", "Service.Refuel.Rule", ["Fixed", "Dynamic"][settingsGui["pitstopRefuelServiceRuleDropDown"].Value])
		setMultiMapValue(newSettings, "Strategy Settings", "Service.Refuel", internalValue("Float", settingsGui["pitstopRefuelServiceEdit"].Text, 1))
		setMultiMapValue(newSettings, "Strategy Settings", "Service.Order", (settingsGui["pitstopServiceDropDown"].Value == 1) ? "Simultaneous" : "Sequential")
		setMultiMapValue(newSettings, "Strategy Settings", "Extrapolation.Laps", settingsGui["extrapolationLapsEdit"].Text)
		setMultiMapValue(newSettings, "Strategy Settings", "Overtake.Delta", settingsGui["overtakeDeltaEdit"].Text)
		setMultiMapValue(newSettings, "Strategy Settings", "Traffic.Considered", settingsGui["trafficConsideredEdit"].Text)
		setMultiMapValue(newSettings, "Strategy Settings", "Strategy.Window.Considered", settingsGui["pitstopStrategyWindowEdit"].Text)

		setMultiMapValue(newSettings, "Strategy Settings", "Strategy.Update.Laps"
									, settingsGui["strategyUpdateLapsCheck"].Value ? settingsGui["strategyUpdateLapsEdit"].Text : false)

		setMultiMapValue(newSettings, "Strategy Settings", "Strategy.Update.Pitstop"
									, settingsGui["strategyUpdatePitstopCheck"].Value ? settingsGui["strategyUpdatePitstopEdit"].Text : false)

		setMultiMapValue(newSettings, "Strategy Settings", "Traffic.Simulation", settingsGui["trafficSimulationCheck"].Value)

		if gTeamMode {
			setMultiMapValue(newSettings, "Team Settings", "Server.URL", settingsGui["serverURLEdit"].Text)
			setMultiMapValue(newSettings, "Team Settings", "Server.Token", settingsGui["serverTokenEdit"].Text)
			setMultiMapValue(newSettings, "Team Settings", "Team.Name", teamName)
			setMultiMapValue(newSettings, "Team Settings", "Driver.Name", theDriverName)
			setMultiMapValue(newSettings, "Team Settings", "Session.Name", sessionName)
			setMultiMapValue(newSettings, "Team Settings", "Team.Identifier", teamIdentifier)
			setMultiMapValue(newSettings, "Team Settings", "Driver.Identifier", driverIdentifier)
			setMultiMapValue(newSettings, "Team Settings", "Session.Identifier", sessionIdentifier)
		}

		if (settingsOrCommand == kOk)
			result := settingsOrCommand
		else {
			if (gSimulator && gCar && gTrack) {
				directory := SessionDatabase.DatabasePath
				simulatorCode := SessionDatabase.getSimulatorCode(gSimulator)

				dirName := (directory . "User\" . simulatorCode . "\" . gCar . "\" . gTrack . "\Race Settings")

				DirCreate(dirName)

				fileName := (dirName . "\Race.settings")
			}
			else
				fileName := kRaceSettingsFile

			settingsGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateSaveCancelButtons)
			file := FileSelect("S17", fileName, translate("Save Race Settings..."), "Settings (*.settings)")
			OnMessage(0x44, translateSaveCancelButtons, 0)

			if (file != "") {
				if !InStr(file, ".")
					file := (file . ".settings")

				writeMultiMap(file, newSettings)
			}
		}
	}
	else {
		connector := false
		connected := false

		if gTeamMode {
			dllFile := (kBinariesDirectory . "Connectors\Team Server Connector.dll")

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
				}

				connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

				showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		result := false

		settingsGui := Window({Descriptor: "Race Settings", Options: "0x400000"})

		settingsGui.SetFont("Bold", "Arial")

		settingsGui.Add("Text", "w388 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(settingsGui, "Race Settings"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Documentation", "x118 YP+20 w168 Center", translate("Race Settings")
					  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings")

		settingsGui.SetFont("Norm", "Arial")

		if !gTestMode {
			settingsGui.Add("Button", "x228 y499 w80 h23 Default", translate("Ok")).OnEvent("Click", editRaceSettings.Bind(&kOk))
			settingsGui.Add("Button", "x316 y499 w80 h23", translate("&Cancel")).OnEvent("Click", editRaceSettings.Bind(&kCancel))
		}
		else
			settingsGui.Add("Button", "x316 y499 w80 h23 Default", translate("Close")).OnEvent("Click", editRaceSettings.Bind(&kCancel))

		settingsGui.Add("Button", "x8 y499 w77 h23", translate("&Load...")).OnEvent("Click", editRaceSettings.Bind(&kLoad))
		settingsGui.Add("Button", "x90 y499 w77 h23", translate("&Save...")).OnEvent("Click", editRaceSettings.Bind(&kSave))

		if gTeamMode
			tabs := collect(["Race", "Pitstop", "Strategy", "Team"], translate)
		else
			tabs := collect(["Race", "Pitstop", "Strategy"], translate)

		settingsTab := settingsGui.Add("Tab3", "x8 y48 w388 h444", tabs)

		settingsTab.UseTab(2)

		settingsGui.Add("Text", "x16 y82 w105 h20 Section", translate("Pitstop Warning"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit1 Number VpitstopWarningEdit"
							  , getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PitstopWarning", 3))
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9"
								, getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PitstopWarning", 3))
		settingsGui.Add("Text", "x184 yp+2 w70 h20", translate("Laps"))

		settingsGui.Add("Text", "x16 yp+30 w105 h23 +0x200", translate("Repair Suspension"))

		choices := collect(["Never", "Always", "Threshold", "Impact"], translate)
		chosen := inList(["Never", "Always", "Threshold", "Impact"]
					   , getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Suspension.Repair", "Always"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VrepairSuspensionDropDown", choices).OnEvent("Change", updateRepairSuspensionState)
		settingsGui.Add("Text", "x245 yp+2 w20 h20 VrepairSuspensionGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0), 1)).OnEvent("Change", validateNumber.Bind("repairSuspensionThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w90 h20 VrepairSuspensionThresholdLabel", translate("Sec. p. Lap"))

		updateRepairSuspensionState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Repair Bodywork"))

		choices := collect(["Never", "Always", "Threshold", "Impact"], translate)
		chosen := inList(["Never", "Always", "Threshold", "Impact"]
					   , getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Impact"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VrepairBodyworkDropDown", choices).OnEvent("Change", updateRepairBodyworkState)
		settingsGui.Add("Text", "x245 yp+2 w20 h20 VrepairBodyworkGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 1), 1)).OnEvent("Change", validateNumber.Bind("repairBodyworkThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w90 h20 VrepairBodyworkThresholdLabel", translate("Sec. p. Lap"))

		updateRepairBodyworkState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Repair Engine"))

		choices := collect(["Never", "Always", "Threshold", "Impact"], translate)
		chosen := inList(["Never", "Always", "Threshold", "Impact"], getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair", "Impact"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VrepairEngineDropDown", choices).OnEvent("Change", updateRepairEngineState)
		settingsGui.Add("Text", "x245 yp+2 w20 h20 VrepairEngineGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairEngineThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair.Threshold", 1), 1)).OnEvent("Change", validateNumber.Bind("repairEngineThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w90 h20 VrepairEngineThresholdLabel", translate("Sec. p. Lap"))

		updateRepairEngineState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Change Compound"))

		choices := collect(["Never", "Tyre Temperature", "Weather"], translate)
		chosen := inList(["Never", "Temperature", "Weather"], getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VchangeTyreDropDown", choices).OnEvent("Change", updateChangeTyreState)
		settingsGui.Add("Text", "x245 yp+2 w20 h20 VchangeTyreGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VchangeTyreThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change.Threshold", 0), 1))
		settingsGui.Add("Text", "x318 yp+2 w90 h20 VchangeTyreThresholdLabel", translate("Degrees"))

		updateChangeTyreState()

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Bold Italic", "Arial")

		settingsGui.Add("Text", "x66 yp+30 w270 0x10")
		settingsGui.Add("Text", "x16 yp+10 w370 h20 Center BackgroundTrans", translate("Target Pressures"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x16 yp+30 w105 h20 Section", translate("Deviation Threshold"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 VtyrePressureDeviationEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2), 1)).OnEvent("Change", validateNumber.Bind("tyrePressureDeviationEdit"))
		settingsGui.Add("Text", "x184 yp+2 w70 h20", getUnit("Pressure"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Temperature", true)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h23 Checked" . chosen . " VtemperatureCorrectionCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w200 h20", translate("based on temperature trend"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Setup", false)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h23 Checked" . chosen . " VsetupPressureCompareCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w200 h20", translate("based on database values"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Pressure", false)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h23 Checked" . chosen . " VpressureLossCorrectionCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w200 h20", translate("based on pressure loss"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Italic", "Arial")

		settingsGui.Add("GroupBox", "x16 yp+30 w180 h120 Section", translate("Dry Tyres"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VtpDryFrontLeftEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FL", 26.5)))).OnEvent("Change", validateNumber.Bind("tpDryFrontLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VtpDryFrontRightEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FR", 26.5)))).OnEvent("Change", validateNumber.Bind("tpDryFrontRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VtpDryRearLeftEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RL", 26.5)))).OnEvent("Change", validateNumber.Bind("tpDryRearLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VtpDryRearRightEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RR", 26.5)))).OnEvent("Change", validateNumber.Bind("tpDryRearRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Italic", "Arial")

		settingsGui.Add("GroupBox", "x202 ys w180 h120", translate("Wet / Intermediate Tyres"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VtpWetFrontLeftEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)))).OnEvent("Change", validateNumber.Bind("tpWetFrontLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VtpWetFrontRightEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)))).OnEvent("Change", validateNumber.Bind("tpWetFrontRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VtpWetRearLeftEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)))).OnEvent("Change", validateNumber.Bind("tpWetRearLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VtpWetRearRightEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)))).OnEvent("Change", validateNumber.Bind("tpWetRearRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsTab.UseTab(1)

		value := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.AvgTime", 120)

		settingsGui.Add("Text", "x16 y82 w85 h23 +0x200 Section", translate("Avg. Lap Time"))
		settingsGui.Add("Edit", "x106 yp w50 h20 Limit3 Number VavgLaptimeEdit", value)
		settingsGui.Add("UpDown", "x138 yp-2 w18 h20 Range1-999 0x80", value)
		settingsGui.Add("Text", "x164 yp+4 w90 h20", translate("Sec."))

		settingsGui.Add("Text", "x16 yp+22 w85 h20 +0x200", translate("Fuel Consumption"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 VfuelConsumptionEdit", displayValue("Float", convertUnit("Volume", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 3.0)))).OnEvent("Change", validateNumber.Bind("fuelConsumptionEdit"))
		settingsGui.Add("Text", "x164 yp+4 w90 h20", getUnit("Volume", true))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.Formation", true)

		settingsGui.Add("Text", "x212 ys w85 h23 +0x200", translate("Formation"))
		settingsGui.Add("CheckBox", "x292 yp-1 w17 h23 Checked" . chosen . " VformationLapCheck", chosen)
		settingsGui.Add("Text", "x310 yp+4 w90 h20", translate("Lap"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PostRace", true)

		settingsGui.Add("Text", "x212 yp+22 w85 h23 +0x200", translate("Post Race"))
		settingsGui.Add("CheckBox", "x292 yp-1 w17 h23 Checked" . chosen . " VpostRaceLapCheck", chosen)
		settingsGui.Add("Text", "x310 yp+4 w90 h20", translate("Lap"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Bold Italic", "Arial")

		settingsGui.Add("Text", "x66 yp+28 w270 0x10")
		settingsGui.Add("Text", "x16 yp+10 w370 h20 Center BackgroundTrans", translate("Initial Setup"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x16 yp+30 w85 h23 +0x200", translate("Tyre Compound"))

		readTyreSetup(settingsOrCommand)

		choices := collect(gTyreCompounds, translate)
		chosen := inList(gTyreCompounds, compound(setupTyreCompound, setupTyreCompoundColor))

		if ((chosen == 0) && (choices.Length > 0))
			chosen := 1

		settingsGui.Add("DropDownList", "x106 yp w110 Choose" . chosen . " VspSetupTyreCompoundDropDown", choices)

		settingsGui.Add("Text", "x16 yp+26 w90 h20", translate("Start Tyre Set"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit2 VspSetupTyreSetEdit").OnEvent("Change", updateTyreSet.Bind("spSetupTyreSetEdit"))
		settingsGui.Add("UpDown", "x138 yp-2 w18 h20 Range0-99")

		settingsGui.Add("Text", "x16 yp+24 w95 h20", translate("Pitstop Tyre Set"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit2 VspPitstopTyreSetEdit").OnEvent("Change", updateTyreSet.Bind("spPitstopTyreSetEdit"))
		settingsGui.Add("UpDown", "x138 yp-2 w18 h20 Range0-99")

		settingsGui["spSetupTyreSetEdit"].Text := (setupTyreSet ? setupTyreSet : translate("Auto "))
		settingsGui["spPitstopTyreSetEdit"].Text := (pitstopTyreSet ? pitstopTyreSet : translate("Auto "))

		import := false

		for simulator, ignore in getMultiMapValues(getControllerState(), "Simulators")
			if Application(simulator, kSimulatorConfiguration).isRunning() {
				import := true

				break
			}

		option := (import ? "yp-25" : "yp")

		settingsGui.Add("Button", "x292 " . option . " w90 h23", translate("Setups...")).OnEvent("Click", openSessionDatabase)

		if import {
			local message := "Import"

			settingsGui.Add("Button", "x292 yp+25 w90 h23", translate("Import")).OnEvent("Click", editRaceSettings.Bind(&message))
		}

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Italic", "Arial")

		settingsGui.Add("GroupBox", "x16 yp+30 w180 h120 Section", translate("Dry Tyres"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryFrontLeftEdit", dryFrontLeft).OnEvent("Change", validateNumber.Bind("spDryFrontLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryFrontRightEdit", dryFrontRight).OnEvent("Change", validateNumber.Bind("spDryFrontRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryRearLeftEdit", dryRearLeft).OnEvent("Change", validateNumber.Bind("spDryRearLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w75 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryRearRightEdit", dryRearRight).OnEvent("Change", validateNumber.Bind("spDryRearRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Italic", "Arial")

		settingsGui.Add("GroupBox", "x202 ys w180 h120", translate("Wet / Intermediate Tyres"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetFrontLeftEdit", wetFrontLeft).OnEvent("Change", validateNumber.Bind("spWetFrontLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetFrontRightEdit", wetFrontRight).OnEvent("Change", validateNumber.Bind("spWetFrontRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetRearLeftEdit", wetRearLeft).OnEvent("Change", validateNumber.Bind("spWetRearLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w75 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetRearRightEdit", wetRearRight).OnEvent("Change", validateNumber.Bind("spWetRearRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsTab.UseTab(3)

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Extrapolation.Laps", 3)

		settingsGui.Add("Text", "x16 y82 w105 h20 Section", translate("Race positions"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit1 Number VextrapolationLapsEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9", value)
		settingsGui.Add("Text", "x184 yp+2 w290 h20", translate("simulated future laps"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Overtake.Delta", 1)

		settingsGui.Add("Text", "x16 yp+20 w85 h23 +0x200", translate("Overtake"))
		settingsGui.Add("Text", "x100 yp w28 h23 +0x200", translate("Abs("))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit2 Number VovertakeDeltaEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-99 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w290 h20", translate("/ laptime difference) Seconds"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Traffic.Considered", 5)

		settingsGui.Add("Text", "x16 yp+20 w85 h23 +0x200", translate("Traffic"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit3 Number VtrafficConsideredEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-100 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w290 h20", translate("% track length"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Update.Laps", false)

		settingsGui.Add("CheckBox", "x16 YP+30 w108 Checked" . (value > 0) . " VstrategyUpdateLapsCheck", translate("Revise every")).OnEvent("Click", updateStrategyLaps.Bind("Check"))
		settingsGui.Add("Edit", "x126 yp-3 w50 h20 Limit2 Number VstrategyUpdateLapsEdit", value ? value : 1).OnEvent("Change", updateStrategyLaps.Bind("Edit"))
		settingsGui.Add("UpDown", "x158 yp w18 h20 Range1-99 0x80", value ? value : 1)
		settingsGui.Add("Text", "x184 yp+2 w290 h20", translate("Laps"))

		if !value
			settingsGui["strategyUpdateLapsEdit"].Enabled := false

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Update.Pitstop", false)

		settingsGui.Add("CheckBox", "x16 YP+25 w108 Checked" . (value > 0) . " VstrategyUpdatePitstopCheck", translate("Revise if")).OnEvent("Click", updateStrategyPitstop.Bind("Check"))
		settingsGui.Add("Edit", "x126 yp-3 w50 h20 Limit1 Number VstrategyUpdatePitstopEdit", value ? value : 4).OnEvent("Change", updateStrategyPitstop.Bind("Edit"))
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9 0x80", value ? value : 4)
		settingsGui.Add("Text", "x184 yp+2 w290 h20", translate("Laps difference to Strategy"))

		if !value
			settingsGui["strategyUpdatePitstopEdit"].Enabled := false

		chosen := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Traffic.Simulation", false)

		settingsGui.Add("Text", "x16 yp+30 w105 h20", translate("Dynamic Traffic"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h23 Checked" . chosen . " VtrafficSimulationCheck", chosen)
		settingsGui.Add("Text", "x184 yp+2 w290 h20", translate("using Monte Carlo simulation"))

		settingsGui.Add("Text", "x66 yp+28 w270 0x10")

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Window.Considered", 3)

		settingsGui.Add("Text", "x16 yp+15 w105 h23 +0x200", translate("Pitstop Window"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit1 Number VpitstopStrategyWindowEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w290 h20", translate("Laps +/- around optimal lap"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Pitstop.Delta", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Pitstop.Delta", 60))

		settingsGui.Add("Text", "x16 yp+22 w105 h20 +0x200", translate("Pitlane Delta"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit2 Number VpitstopDeltaEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 0x80 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+4 w290 h20", translate("Seconds (Drive through - Drive by)"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Tyres", 30)

		settingsGui.Add("Text", "x16 yp+22 w85 h20 +0x200", translate("Tyre Service"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit2 Number VpitstopTyreServiceEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 0x80 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+4 w290 h20", translate("Seconds (Change four tyres)"))

		chosen := inList(["Fixed", "Dynamic"], getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Refuel.Rule", "Dynamic"))

		settingsGui.Add("DropDownList", "x12 yp+21 w110 Choose" . chosen . " VpitstopRefuelServiceRuleDropdown", collect(["Refuel Fixed", "Refuel Dynamic"], translate)).OnEvent("Change", chooseRefuelService)

		settingsGui.Add("Edit", "x126 yp w50 h20 VpitstopRefuelServiceEdit"
							  , displayValue("Float", getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Refuel", 1.8), 1)).OnEvent("Change", validateNumber.Bind("pitstopRefuelServiceEdit"))
		settingsGui.Add("Text", "x184 yp+4 w290 h20 VpitstopRefuelServiceLabel", translate(["Seconds", "Seconds (Refuel of 10 liters)"][settingsGui["pitstopRefuelServiceRuleDropdown"].Value]))

		chosen := ((getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2)

		settingsGui.Add("Text", "x16 yp+24 w85 h23", translate("Service"))
		settingsGui.Add("DropDownList", "x126 yp-3 w100 Choose" . chosen . " vpitstopServiceDropDown", collect(["Simultaneous", "Sequential"], translate))

		value := displayValue("Float", convertUnit("Volume", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 4)), 0)

		settingsGui.Add("Text", "x16 yp+27 w85 h23 +0x200", translate("Safety Fuel"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Number Limit2 VsafetyFuelEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+2 w90 h20", getUnit("Volume", true))

		if gTeamMode {
			settingsTab.UseTab(4)

			serverURL := getMultiMapValue(settingsOrCommand, "Team Settings", "Server.URL", "")
			serverToken := getMultiMapValue(settingsOrCommand, "Team Settings", "Server.Token", "")
			teamName := getMultiMapValue(settingsOrCommand, "Team Settings", "Team.Name", "")
			teamIdentifier := getMultiMapValue(settingsOrCommand, "Team Settings", "Team.Identifier", false)
			theDriverName := getMultiMapValue(settingsOrCommand, "Team Settings", "Driver.Name", "")
			driverIdentifier := getMultiMapValue(settingsOrCommand, "Team Settings", "Driver.Identifier", false)
			sessionName := getMultiMapValue(settingsOrCommand, "Team Settings", "Session.Name", "")
			sessionIdentifier := getMultiMapValue(settingsOrCommand, "Team Settings", "Session.Identifier", false)

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			serverURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

			settingsGui.Add("Text", "x16 y82 w90 h23 +0x200", translate("Server URL"))

			if (!inList(serverURLs, serverURL) && StrLen(serverURL) > 0)
				serverURLs.Push(serverURL)

			chosen := inList(serverURLs, serverURL)
			if (!chosen && (serverURLs.Length > 0))
				chosen := 1

			settingsGui.Add("ComboBox", "x126 yp+1 w256 Choose" . chosen . " vserverURLEdit", serverURLs)

			settingsGui.Add("Text", "x16 yp+23 w90 h23 +0x200", translate("Session Token"))
			settingsGui.Add("Edit", "x126 yp w256 h21 vserverTokenEdit", serverToken)
			button := settingsGui.Add("Button", "x102 yp-1 w23 h23 Center +0x200")
			button.OnEvent("Click", editRaceSettings.Bind(&kConnect))
			setButtonIcon(button, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

			settingsGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Team / Driver"))

			if teamIdentifier
				settingsGui.Add("DropDownList", "x126 yp w126 Choose1 vteamDropDownMenu", [teamName]).OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Team"))
			else
				settingsGui.Add("DropDownList", "x126 yp w126 vteamDropDownMenu").OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Team"))

			if driverIdentifier
				settingsGui.Add("DropDownList", "x256 yp w126 Choose1 vdriverDropDownMenu", [theDriverName]).OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Driver"))
			else
				settingsGui.Add("DropDownList", "x256 yp w126 vdriverDropDownMenu").OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Driver"))

			settingsGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Session"))

			if sessionIdentifier
				settingsGui.Add("DropDownList", "x126 yp w126 Choose1 vsessionDropDownMenu", [sessionName]).OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Session"))
			else
				settingsGui.Add("DropDownList", "x126 yp w126 vsessionDropDownMenu").OnEvent("Change", editRaceSettings.Bind(&kUpdate, "Session"))

			settingsGui.Add("Text", "x126 yp+30 r6 w256", translate("Note: These settings define the access data for a team session. In order to join this session, it is still necessary for you to activate the team mode within the first lap of the session. Please consult the documentation for more information and detailed instructions."))
		}

		if getWindowPosition("Race Settings", &x, &y)
			settingsGui.Show("x" . x . " y" . y)
		else
			settingsGui.Show()

		loop
			Sleep(1000)
		until result

		settingsGui.Destroy()

		if (result == kOk)
			settingsOrCommand := newSettings
		else if (result = "Restart")
			if (editRaceSettings(&newSettings) == kOk)
				settingsOrCommand := newSettings

		return result
	}
}

readSimulatorData(simulator) {
	local data := callSimulator(simulator, "Setup=true")
	local tyreCompound, tyreCompoundColor


	if (getMultiMapValue(data, "Car Data", "TyreCompound", kUndefined) = kUndefined) {
		tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

		if (tyreCompound && (tyreCompound != kUndefined)) {
			tyreCompound := SessionDatabase.getTyreCompoundName(simulator, gCar, gTrack, tyreCompound, false)

			if tyreCompound {
				tyreCompoundColor := false

				splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

				setMultiMapValue(data, "Car Data", "TyreCompound", tyreCompound)
				setMultiMapValue(data, "Car Data", "TyreCompoundColor", tyreCompoundColor)
			}
		}
	}

	return data
}

showRaceSettingsEditor() {
	global gSimulator, gCar, gTrack, gWeather, gAirTemperature, gTrackTemperature
	global gTyreCompound, gTyreCompoundColor, gTyreCompounds, gSilentMode, gTeamMode, gTestMode

	local message := "Export"
	local icon := kIconsDirectory . "Race Settings.ico"
	local index, fileName, settings

	TraySetIcon(icon, "1")
	A_IconTip := "Race Settings"

	startupApplication()

	gSimulator := false
	gCar := false
	gTrack := false
	gWeather := "Dry"
	gAirTemperature := 23
	gTrackTemperature := 27
	gTyreCompound := false
	gTyreCompoundColor := false

	index := 1

	while (index < A_Args.Length) {
		switch A_Args[index], false {
			case "-Simulator":
				gSimulator := A_Args[index + 1]
				index += 2
			case "-Car":
				gCar := A_Args[index + 1]
				index += 2
			case "-Track":
				gTrack := A_Args[index + 1]
				index += 2
			case "-Weather":
				gWeather := A_Args[index + 1]
				index += 2
			case "-AirTemperature":
				gAirTemperature := A_Args[index + 1]
				index += 2
			case "-TrackTemperature":
				gTrackTemperature := A_Args[index + 1]
				index += 2
			case "-Compound":
				gTyreCompound := A_Args[index + 1]
				index += 2
			case "-CompoundColor":
				gTyreCompoundColor := A_Args[index + 1]
				index += 2
			case "-Setup":
				vRequestorPID := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (gSimulator && gCar)
		gTyreCompounds := SessionDatabase.getTyreCompounds(gSimulator, gCar, gTrack ? gTrack : "*")

	if (gAirTemperature <= 0)
		gAirTemperature := 23

	if (gTrackTemperature <= 0)
		gTrackTemperature := 27

	fileName := kRaceSettingsFile

	index := inList(A_Args, "-File")

	if index
		fileName := A_Args[index + 1]

	settings := readMultiMap(fileName)

	if inList(A_Args, "-Silent")
		gSilentMode := true

	if inList(A_Args, "-NoTeam")
		gTeamMode := false

	if inList(A_Args, "-Test")
		gTestMode := true

	index := inList(A_Args, "-Import")

	if index {
		if editRaceSettings(&message, A_Args[index + 1], A_Args[index + 2], settings)
			writeMultiMap(fileName, settings)
	}
	else {
		registerMessageHandler("Setup", functionMessageHandler)

		result := editRaceSettings(&settings)

		if (result = kOk)
			writeMultiMap(fileName, settings)
	}

	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

setTyrePressures(tyreCompound, tyreCompoundColor, flPressure, frPressure, rlPressure, rrPressure) {
	local message := "TyrePressures"

	editRaceSettings(&message, tyreCompound, tyreCompoundColor, flPressure, frPressure, rlPressure, rrPressure)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceSettingsEditor()