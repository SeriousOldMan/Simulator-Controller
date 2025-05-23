;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Settings Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
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
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\CLR.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Plugins\Libraries\SimulatorProvider.ahk"


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
global gWeather := "*"
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

		if (!isFloat(value) && !isInteger(value))
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

		loginGui := Window({Options: "0x400000"}, translate("Team Server"))

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
					withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
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

	local setupTyreCompound := "Dry"
	local setupTyreCompoundColor := "Black"
	local dryFrontLeft := 26.1, dryFrontRight := 26.1, dryRearLeft := 26.1, dryRearRight := 26.1
	local wetFrontLeft := 28.5, wetFrontRight := 28.5, wetRearLeft := 28.5, wetRearRight := 28.5

	local mixedCompounds, tyreService, index, tyre, axle, dropDown
	local dllFile, names, exception, value, chosen, choices, tabs, import, simulator, ignore, option
	local dirName, simulatorCode, file, tyreCompound, tyreCompoundColor, tc, tcc, fileName, token
	local x, y, e, directory, connection, settings, serverURLs, settingsTab, oldTChoice, oldFChoice
	local tyreSets, tyreSet, translatedCompounds, rulesActive, index

	static wheels := ["FL", "FR", "RL", "RR"]

	static updateState := "UpdateState"

	static setupTyreSet := false
	static pitstopTyreSet := false

	static tyreSetListView

	static settingsGui

	static result
	static oldSettings
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

			if !kSilentMode
				showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	importFromSimulation(message := false, simulator := false, prefix := false, settings := false) {
		local result := false
		local candidate, ignore, data, tyreCompound, tyreCompoundColor, tc, tcc
		local mixedCompounds, tyreSets, index, tyre, axle

		getSetupPressure(tyre, default) {
			return displayValue("Float"
							  , convertUnit("Pressure"
										  , getMultiMapValue(data, "Setup Data", "SetupTyrePressure" . tyre
																 , getMultiMapValue(data, "Setup Data", "TyrePressure" . tyre, default))))
		}

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

		data := readSimulator(prefix, gCar, gTrack)

		if (getMultiMapValues(data, "Setup Data").Count > 0) {
			SimulatorProvider.createSimulatorProvider(gSimulator, getMultiMapValue(data, "Session Data", "Car")
																, getMultiMapValue(data, "Session Data", "Track")).supportsTyreManagement(&mixedCompounds, &tyreSets)

			readTyreSetup(readMultiMap(kRaceSettingsFile))

			pitstopTyreSet := getMultiMapValue(data, "Setup Data", "TyreSet", pitstopTyreSet)
			setupTyreSet := getMultiMapValue(data, "Car Data", "TyreSet", setupTyreSet ? setupTyreSet : Max(0, pitstopTyreSet - 1))

			if (settings & tyreSets) {
				if (getMultiMapValue(settings, "Session Setup", "Tyre.Set.Fresh", 0) != 0)
					setMultiMapValue(settings, "Session Setup", "Tyre.Set.Fresh", pitstopTyreSet)

				if (getMultiMapValue(settings, "Session Setup", "Tyre.Set", 0) = 0)
					setMultiMapValue(settings, "Session Setup", "Tyre.Set", setupTyreSet)
			}

			if (mixedCompounds = "Wheel") {
				tc := []
				tcc := []

				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
					tc.Push(getMultiMapValue(data, "Setup Data", "TyreCompound" . tyre
										   , getMultiMapValue(data, "Car Data", "TyreCompound" . tyre)))
					tcc.Push(getMultiMapValue(data, "Setup Data", "TyreCompound" . tyre
											, getMultiMapValue(data, "Car Data", "TyreCompoundColor" . tyre)))

					if (index = 1) {
						tyreCompound := tc[1]
						tyreCompoundColor := tcc[1]
					}

					if settings {
						setMultiMapValue(settings, "Session Setup", "Tyre.Compound." . tyre, tc[tc.Length])
						setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color." . tyre, tcc[tcc.Length])
					}
				}

				tc := values2String("," tc*)
				tcc := values2String("," tcc*)
			}
			else if (mixedCompounds = "Axle") {
				tc := []
				tcc := []

				for index, axle in ["Front", "Rear"] {
					tc.Push(getMultiMapValue(data, "Setup Data", "TyreCompound" . axle
										   , getMultiMapValue(data, "Car Data", "TyreCompound" . axle)))
					tcc.Push(getMultiMapValue(data, "Setup Data", "TyreCompound" . axle
											, getMultiMapValue(data, "Car Data", "TyreCompoundColor" . axle)))

					if (index = 1) {
						tyreCompound := tc[1]
						tyreCompoundColor := tcc[1]
					}

					if settings {
						setMultiMapValue(settings, "Session Setup", "Tyre.Compound." . axle, tc[tc.Length])
						setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color." . axle, tcc[tcc.Length])
					}
				}

				tc := values2String("," tc*)
				tcc := values2String("," tcc*)
			}
			else {
				tyreCompound := getMultiMapValue(data, "Setup Data", "TyreCompound"
											   , getMultiMapValue(data, "Car Data", "TyreCompound"))
				tyreCompoundColor := getMultiMapValue(data, "Setup Data", "TyreCompoundColor"
													, getMultiMapValue(data, "Car Data", "TyreCompoundColor"))

				tc := [tyreCompound]
				tcc := [tyreCompoundColor]
			}

			setupTyreCompound := values2String(",", tc*)
			setupTyreCompoundColor := values2String(",", tcc*)

			if settings {
				setMultiMapValue(settings, "Session Setup", "Tyre.Compound", tyreCompound)
				setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", tyreCompoundColor)
			}

			if (tyreCompound = "Dry") {
				dryFrontLeft := getSetupPressure("FL", dryFrontLeft)
				dryFrontRight := getSetupPressure("FR", dryFrontRight)
				dryRearLeft := getSetupPressure("RL", dryRearLeft)
				dryRearRight := getSetupPressure("RR", dryRearRight)

				if settings {
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.FL", convertUnit("Pressure", internalValue("Float", dryFrontLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.FR", convertUnit("Pressure", internalValue("Float", dryFrontRight), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.RL", convertUnit("Pressure", internalValue("Float", dryRearLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Dry.Pressure.RR", convertUnit("Pressure", internalValue("Float", dryRearRight), false))

					if (!gSilentMode && !inList(["rFactor 2", "Le Mans Ultimate", "Automobilista 2", "Project CARS 2"], simulator)) {
						message := (translate("Tyre setup imported: ") . translate(compound(tyreCompound, tyreCompoundColor)))

						showMessage(message . translate(", Set ") . setupTyreSet . translate("; ")
										    . dryFrontLeft . translate(", ") . dryFrontRight . translate(", ")
											. dryRearLeft . translate(", ") . dryRearRight, false, "Information.ico", 5000)
					}
				}

				result := tyreCompound
			}
			else if ((tyreCompound = "Wet") || (tyreCompound = "Intermediate")) {
				wetFrontLeft := getSetupPressure("FL", wetFrontLeft)
				wetFrontRight := getSetupPressure("FR", wetFrontRight)
				wetRearLeft := getSetupPressure("RL", wetRearLeft)
				wetRearRight := getSetupPressure("RR", wetRearRight)

				if settings {
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.FL", convertUnit("Pressure", internalValue("Float", wetFrontLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.FR", convertUnit("Pressure", internalValue("Float", wetFrontRight), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.RL", convertUnit("Pressure", internalValue("Float", wetRearLeft), false))
					setMultiMapValue(settings, "Session Setup", "Tyre.Wet.Pressure.RR", convertUnit("Pressure", internalValue("Float", wetRearRight), false))

					if (!gSilentMode && !inList(["rFactor 2", "Le Mans Ultimate", "Automobilista 2", "Project CARS 2"], simulator)) {
						message := (translate("Tyre setup imported: ") . compound(tyreCompound, tyreCompoundColor))

						showMessage(message . translate("; ")
											. wetFrontLeft . translate(", ") . wetFrontRight . translate(", ")
											. wetRearLeft . translate(", ") . wetRearRight, false, "Information.ico", 5000)
					}
				}

				result := tyreCompound
			}
		}

		return result
	}

	choosePSRefuelService(*) {
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
		local tyreCompound, tyreCompoundColor, tc, tcc
		local mixedCompounds, tyreSets, index, tyre, axle

		SimulatorProvider.createSimulatorProvider(gSimulator, gCar, gTrack).supportsTyreManagement(&mixedCompounds, &tyreSets)

		if (gTyreCompound && gTyreCompoundColor) {
			if (mixedCompounds = "Wheel") {
				setupTyreCompound := values2String(",", gTyreCompound, gTyreCompound, gTyreCompound, gTyreCompound)
				setupTyreCompoundColor := values2String(",", gTyreCompoundColor, gTyreCompoundColor, gTyreCompoundColor, gTyreCompoundColor)
			}
			else if (mixedCompounds = "Axle") {
				setupTyreCompound := values2String(",", gTyreCompound, gTyreCompound)
				setupTyreCompoundColor := values2String(",", gTyreCompoundColor, gTyreCompoundColor)
			}
			else {
				setupTyreCompound := gTyreCompound
				setupTyreCompoundColor := gTyreCompoundColor
			}
		}
		else {
			setupTyreCompound := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
			setupTyreCompoundColor := getDeprecatedValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")

			if (mixedCompounds = "Wheel") {
				setupTyreCompound := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
										 return getDeprecatedValue(settings, "Session Setup", "Race Setup"
																		   , "Tyre.Compound." . tyre, setupTyreCompound)
									 })
				setupTyreCompoundColor := collect(["FrontLeft", "FrontRight", "RearLeft", "RearRight"], (tyre) {
											  return getDeprecatedValue(settings, "Session Setup", "Race Setup"
																				, "Tyre.Compound.Color." . tyre, setupTyreCompoundColor)
										  })

				setupTyreCompound := values2String(",", setupTyreCompound*)
				setupTyreCompoundColor := values2String(",", setupTyreCompoundColor*)
			}
			else if (mixedCompounds = "Axle") {
				setupTyreCompound := collect(["Front", "Rear"], (axle) {
										 return getDeprecatedValue(settings, "Session Setup", "Race Setup"
																		   , "Tyre.Compound." . axle, setupTyreCompound)
									 })
				setupTyreCompoundColor := collect(["Front", "Rear"], (axle) {
											  return getDeprecatedValue(settings, "Session Setup", "Race Setup"
																				, "Tyre.Compound.Color." . axle, setupTyreCompoundColor)
										  })

				setupTyreCompound := values2String(",", setupTyreCompound*)
				setupTyreCompoundColor := values2String(",", setupTyreCompoundColor*)
			}
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


	choosePitstopRule(*) {
		editRaceSettings(&updateState)
	}

	updatePitstopRule(*) {
		validatePitstopRule()
	}

	choosePitstopWindow(*) {
		editRaceSettings(&updateState)
	}

	updatePitstopWindow(*) {
		validatePitstopWindow()
	}

	chooseTyreCompound(*) {
		editRaceSettings(&updateState)
	}

	selectPSTyreSet(listView, line, selected) {
		if selected
			choosePSTyreSet(listView, line)
	}

	choosePSTyreSet(listView, line, *) {
		local compound := listView.GetText(line, 1)
		local laps := listView.GetText(line, 2)
		local count := listView.GetText(line, 3)

		if line {
			if compound
				compound := normalizeCompound(compound)

			settingsGui["tyreSetDropDown"].Choose(inList(collect(gTyreCompounds, translate), compound))
			settingsGui["tyreSetLapsEdit"].Text := laps
			settingsGui["tyreSetCountEdit"].Text := count
		}

		editRaceSettings(&updateState)
	}

	updatePSTyreSet(*) {
		local row := tyreSetListView.GetNext(0)
		local availableCompounds, compound, usedCompounds, index, candidate

		if (row > 0) {
			availableCompounds := collect(gTyreCompounds, translate)
			compound := availableCompounds[settingsGui["tyreSetDropDown"].Value]
			usedCompounds := []

			loop tyreSetListView.GetCount()
				if (A_Index != row)
					usedCompounds.Push(tyreSetListView.GetText(A_Index, 1))

			if inList(usedCompounds, compound)
				for index, candidate in availableCompounds
					if !inList(usedCompounds, candidate) {
						compound := candidate

						settingsGui["tyreSetDropDown"].Choose(index)

						break
					}

			tyreSetListView.Modify(row, "", compound, settingsGui["tyreSetLapsEdit"].Text, settingsGui["tyreSetCountEdit"].Text)
		}

		editRaceSettings(&updateState)
	}

	addPSTyreSet(*) {
		local availableCompounds := collect(gTyreCompounds, translate)
		local usedCompounds := []
		local index, ignore, candidate

		loop tyreSetListView.GetCount()
			usedCompounds.Push(tyreSetListView.GetText(A_Index, 1))

		for ignore, candidate in availableCompounds
			if !inList(usedCompounds, candidate) {
				index := A_Index

				break
			}

		tyreSetListView.Add("", collect(gTyreCompounds, translate)[index], 99)
		tyreSetListView.Modify(tyreSetListView.GetCount(), "Select Vis")

		settingsGui["tyreSetDropDown"].Choose(index)
		settingsGui["tyreSetLapsEdit"].Value := 50
		settingsGui["tyreSetCountEdit"].Value := 99

		editRaceSettings(&updateState)
	}

	deletePSTyreSet(*) {
		local index := tyreSetListView.GetNext(0)

		if (index > 0)
			tyreSetListView.Delete(index)

		editRaceSettings(&updateState)
	}

	chooseRefuelService(*) {
		settingsGui["pitstopFuelServiceLabel"].Text := translate(["Seconds", "Seconds (Refuel of 10 liters)"][settingsGui["pitstopFuelServiceRuleDropdown"].Value])
	}

	validatePitstopRule(full := false) {
		local pitstopRuleEdit := settingsGui["pitstopRuleEdit"].Text

		if (StrLen(Trim(pitstopRuleEdit)) > 0) {
			if (settingsGui["pitstopRuleDropDown"].Value == 2) {
				if isInteger(pitstopRuleEdit) {
					if (pitstopRuleEdit < 1)
						settingsGui["pitstopRuleEdit"].Text := 1
				}
				else
					settingsGui["pitstopRuleEdit"].Value := 1
			}
		}
	}

	validatePitstopWindow(full := false) {
		local reset, count, pitOpen, pitClose
		local pitstopWindowEdit := settingsGui["pitstopWindowEdit"].Text
		local pitstopWindowDropDown := settingsGui["pitstopWindowDropDown"].Value

		if (StrLen(Trim(pitstopWindowEdit)) > 0) {
			if (pitstopWindowDropDown == 1)
				settingsGui["pitstopWindowEdit"].Text := ""
			else if (pitstopWindowDropDown == 2) {
				reset := false

				StrReplace(pitstopWindowEdit, "-", "-", , &count)

				if (count > 1) {
					pitstopWindowEdit := StrReplace(pitstopWindowEdit, "-", "", , , count - 1)

					reset := true
				}

				if (reset || InStr(pitstopWindowEdit, "-")) {
					pitstopWindowEdit := string2Values("-", pitstopWindowEdit)
					pitOpen := pitstopWindowEdit[1]
					pitClose := pitstopWindowEdit[2]

					if (StrLen(Trim(pitOpen)) > 0)
						if isInteger(pitOpen) {
							if (pitOpen < 0) {
								pitOpen := 0

								reset := true
							}
						}
						else {
							pitOpen := 0

							reset := true
						}
					else if (full = "Full") {
						pitOpen := 0

						reset := true
					}

					if (StrLen(Trim(pitClose)) > 0)
						if isInteger(pitClose) {
							if ((full = "Full") && (pitClose <= pitOpen)) {
								pitClose := pitOpen + 10

								reset := true
							}
						}
						else {
							pitClose := (pitOpen + 10)

							reset := true
						}
					else if (full = "Full") {
						pitClose := (pitOpen + 10)

						reset := true
					}

					if reset
						settingsGui["pitstopWindowEdit"].Text := Round(pitOpen) . " - " . Round(pitClose)
				}
			}
		}
	}

	loadTyreCompounds() {
		local settings := (gSimulator ? SettingsDatabase().loadSettings(gSimulator, gCar, gTrack, gWeather) : newMultiMap())
		local translatedCompounds, ignore, compound, tyreLife

		translatedCompounds := collect(gTyreCompounds, translate)

		settingsGui["tyreSetDropDown"].Delete()
		settingsGui["tyreSetDropDown"].Add(translatedCompounds)

		tyreSetListView.Delete()

		for ignore, compound in gTyreCompounds
			tyreSetListView.Add("", translate(compound), 50, 99)

		if (getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage", kUndefined) != kUndefined)
			for compound, tyreLife in string2Map(";", "->", getMultiMapValue(settings, "Session Settings", "Tyre.Compound.Usage"))
				loop tyreSetListView.GetCount()
					if (translate(compound) = tyreSetListView.GetText(A_Index, 1))
						tyreSetListView.Modify(A_Index, "Col2", tyreLife)

		tyreSetListView.ModifyCol()
		tyreSetListView.ModifyCol(1, 75)
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
		file := withBlockedWindows(FileSelect, 1, dirName, translate("Load Race Settings..."), "Settings (*.settings)")
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

			SimulatorProvider.createSimulatorProvider(gSimulator, gCar, gTrack).supportsTyreManagement(&mixedCompounds)

			if (mixedCompounds = "Wheel") {
				tyreCompound := compounds(string2Values(",", setupTyreCompound), string2Values(",", setupTyreCompoundColor))

				for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]
					settingsGui["spSetupTyreCompound" . wheels[index] . "DropDown"].Choose(inList(gTyreCompounds, tyreCompound[index]))
			}
			else if (mixedCompounds = "Axle") {
				tyreCompound := compounds(string2Values(",", setupTyreCompound), string2Values(",", setupTyreCompoundColor))

				for index, axle in ["Front", "Rear"]
					settingsGui["spSetupTyreCompound" . wheels[index + (index - 1)] . "DropDown"].Choose(inList(gTyreCompounds, tyreCompound[index]))
			}
			else
				settingsGui["spSetupTyreCompoundFLDropDown"].Choose(inList(gTyreCompounds, compound(string2Values(",", setupTyreCompound)[1]
																								  , string2Values(",", setupTyreCompoundColor)[1])))
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

		editRaceSettings(&updateState)
	}
	else if (settingsOrCommand = "UpdateState") {
		SimulatorProvider.createSimulatorProvider(gSimulator, gCar, gTrack).supportsTyreManagement(&mixedCompounds, &tyreSets)

		if tyreSets {
			settingsGui["spSetupTyreSetEdit"].Enabled := true
			settingsGui["spPitstopTyreSetEdit"].Enabled := true
		}
		else {
			settingsGui["spSetupTyreSetEdit"].Enabled := false
			settingsGui["spPitstopTyreSetEdit"].Enabled := false

			settingsGui["spSetupTyreSetEdit"].Text := translate("Auto ")
			settingsGui["spPitstopTyreSetEdit"].Text := translate("Auto ")
		}

		if (mixedCompounds = "Wheel") {
			for index, dropDown in ["spSetupTyreCompoundFLDropDown", "spSetupTyreCompoundFRDropDown"
								  , "spSetupTyreCompoundRLDropDown", "spSetupTyreCompoundRRDropDown"] {
				settingsGui[dropDown].Enabled := true

				if (settingsGui[dropDown].Value = 0)
					if (index > 1)
						settingsGui[dropDown].Choose(settingsGui["spSetupTyreCompoundFLDropDown"].Value)
					else
						settingsGui[dropDown].Choose(1)
			}
		}
		else if (mixedCompounds = "Axle") {
			for index, dropDown in ["spSetupTyreCompoundFLDropDown", "spSetupTyreCompoundRLDropDown"] {
				settingsGui[dropDown].Enabled := true

				if (settingsGui[dropDown].Value = 0)
					if (index > 1)
						settingsGui[dropDown].Choose(settingsGui["spSetupTyreCompoundFLDropDown"].Value)
					else
						settingsGui[dropDown].Choose(1)
			}

			for index, dropDown in ["spSetupTyreCompoundFRDropDown", "spSetupTyreCompoundRRDropDown"]
				settingsGui[dropDown].Enabled := false

			settingsGui["spSetupTyreCompoundFRDropDown"].Choose(settingsGui["spSetupTyreCompoundFLDropDown"].Value)
			settingsGui["spSetupTyreCompoundRRDropDown"].Choose(settingsGui["spSetupTyreCompoundRLDropDown"].Value)
		}
		else {
			for index, dropDown in ["spSetupTyreCompoundFRDropDown"
								  , "spSetupTyreCompoundRLDropDown", "spSetupTyreCompoundRRDropDown"] {
				settingsGui[dropDown].Enabled := false

				settingsGui[dropDown].Choose(settingsGui["spSetupTyreCompoundFLDropDown"].Value)
			}
		}

		rulesActive := (settingsGui["rulesActiveDropDown"].Value = 1)

		settingsGui["tyreSetAddButton"].Enabled := (gTyreCompounds.Length > tyreSetListView.GetCount())

		if rulesActive {
			settingsGui["stintLengthEdit"].Enabled := true
			settingsGui["pitstopRuleDropDown"].Enabled := true
			settingsGui["pitstopWindowDropDown"].Enabled := true
			settingsGui["refuelRequirementsDropDown"].Enabled := true
			settingsGui["tyreChangeRequirementsDropDown"].Enabled := true

			if (settingsGui["stintLengthEdit"].Text = "")
				settingsGui["stintLengthEdit"].Text := 70

			tyreSetListView.Enabled := true
		}
		else {
			settingsGui["stintLengthEdit"].Enabled := false
			settingsGui["stintLengthEdit"].Text := ""
			settingsGui["pitstopRuleDropDown"].Enabled := false
			settingsGui["pitstopRuleDropDown"].Value := 1
			settingsGui["pitstopWindowDropDown"].Enabled := false
			settingsGui["pitstopWindowDropDown"].Value := 1
			settingsGui["refuelRequirementsDropDown"].Enabled := false
			settingsGui["refuelRequirementsDropDown"].Value := 1
			settingsGui["tyreChangeRequirementsDropDown"].Enabled := false
			settingsGui["tyreChangeRequirementsDropDown"].Value := 1

			tyreSetListView.Enabled := false

			loop tyreSetListView.GetCount()
				tyreSetListView.Modify(A_Index, "-Select")
		}

		if (rulesActive && (tyreSetListView.GetNext(0) > 0)) {
			settingsGui["tyreSetDropDown"].Enabled := true
			settingsGui["tyreSetLapsEdit"].Enabled := true
			settingsGui["tyreSetCountEdit"].Enabled := true
			settingsGui["tyreSetDeleteButton"].Enabled := true
		}
		else {
			settingsGui["tyreSetDropDown"].Enabled := false
			settingsGui["tyreSetLapsEdit"].Enabled := false
			settingsGui["tyreSetCountEdit"].Enabled := false
			settingsGui["tyreSetDeleteButton"].Enabled := false

			settingsGui["tyreSetDropDown"].Choose(0)
			settingsGui["tyreSetLapsEdit"].Text := ""
			settingsGui["tyreSetCountEdit"].Text := ""
		}

		if (settingsGui["pitstopRuleDropDown"].Value = 2) {
			settingsGui["pitstopRuleEdit"].Visible := true
			settingsGui["pitstopRuleUpDown"].Visible := true

			if ((Trim(settingsGui["pitstopRuleEdit"].Text) = "") || !settingsGui["pitstopRuleEdit"].Value)
				settingsGui["pitstopRuleEdit"].Text := 1

			oldTChoice := ["Always", "Window"][settingsGui["pitstopWindowDropDown"].Value]

			settingsGui["pitstopWindowDropDown"].Delete()
			settingsGui["pitstopWindowDropDown"].Add(collect(["Always", "Window"], translate))
			settingsGui["pitstopWindowDropDown"].Choose(inList(["Always", "Window"], oldTChoice))
		}
		else {
			settingsGui["pitstopRuleEdit"].Visible := false
			settingsGui["pitstopRuleUpDown"].Visible := false

			settingsGui["pitstopWindowDropDown"].Delete()
			settingsGui["pitstopWindowDropDown"].Add(collect(["Always"], translate))
			settingsGui["pitstopWindowDropDown"].Choose(1)
		}

		if (settingsGui["pitstopWindowDropDown"].Value = 2) {
			settingsGui["pitstopWindowEdit"].Visible := true
			settingsGui["pitstopWindowLabel"].Visible := true

			if !InStr(settingsGui["pitstopWindowEdit"].Text, "-")
				settingsGui["pitstopWindowEdit"].Text := "25 - 35"
		}
		else {
			settingsGui["pitstopWindowEdit"].Visible := false
			settingsGui["pitstopWindowLabel"].Visible := false
		}

		if settingsGui["tyreChangeRequirementsDropDown"].Value
			oldTChoice := ["Optional", "Required", "Always", "Disallowed"][settingsGui["tyreChangeRequirementsDropDown"].Value]
		else
			oldTChoice := false

		if settingsGui["refuelRequirementsDropDown"].Value
			oldFChoice := ["Optional", "Required", "Always", "Disallowed"][settingsGui["refuelRequirementsDropDown"].Value]
		else
			oldFChoice := false

		if (settingsGui["pitstopRuleDropDown"].Value = 1) {
			settingsGui["tyreChangeRequirementsDropDown"].Delete()
			settingsGui["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))
			settingsGui["refuelRequirementsDropDown"].Delete()
			settingsGui["refuelRequirementsDropDown"].Add(collect(["Optional", "Always", "Disallowed"], translate))

			oldTChoice := inList(["Optional", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Always", "Disallowed"], oldFChoice)
		}
		else {
			settingsGui["tyreChangeRequirementsDropDown"].Delete()
			settingsGui["tyreChangeRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))
			settingsGui["refuelRequirementsDropDown"].Delete()
			settingsGui["refuelRequirementsDropDown"].Add(collect(["Optional", "Required", "Always", "Disallowed"], translate))

			oldTChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldTChoice)
			oldFChoice := inList(["Optional", "Required", "Always", "Disallowed"], oldFChoice)
		}

		settingsGui["tyreChangeRequirementsDropDown"].Choose(oldTChoice ? oldTChoice : 1)
		settingsGui["refuelRequirementsDropDown"].Choose(oldFChoice ? oldFChoice : 1)
	}
	else if (settingsOrCommand == kUpdate) {
		if connected
			if (arguments[1] == "Team") {
				if ((teams.Count > 0) && (settingsGui["teamDropDownMenu"].Value != 0)) {
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
				if ((drivers.Count > 0) && (settingsGui["driverDropDownMenu"].Value != 0)) {
					theDriverName := getKeys(drivers)[settingsGui["driverDropDownMenu"].Value]
					driverIdentifier := drivers[theDriverName]
				}
				else {
					theDriverName := ""
					driverIdentifier := false
				}
			}
			else if (arguments[1] == "Session") {
				if ((sessions.Count > 0) && (settingsGui["sessionDropDownMenu"].Value != 0)) {
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
			if GetKeyState("Ctrl") {
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
				withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
		}
	}
	else if (settingsOrCommand = "TyrePressures")
		setTyrePressures(arguments*)
	else if ((settingsOrCommand == kSave) || (settingsOrCommand == kOk)) {
		if (!isPositiveFloat(settingsGui["tyrePressureDeviationEdit"].Text
						   , settingsGui["tyrePressureLossThresholdEdit"].Text
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
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}

		SimulatorProvider.createSimulatorProvider(gSimulator, gCar, gTrack).supportsTyreManagement(&mixedCompounds)

		newSettings := oldSettings.Clone()

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
		setMultiMapValue(newSettings, "Session Settings", "Tyre.Pressure.Loss.Threshold", internalValue("Float", settingsGui["tyrePressureLossThresholdEdit"].Text, 1))

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

		setMultiMapValue(newSettings, "Session Settings", "Lap.AvgTime", Max(settingsGui["avgLaptimeEdit"].Text, 10))
		setMultiMapValue(newSettings, "Session Settings", "Fuel.AvgConsumption", convertUnit("Volume", internalValue("Float", settingsGui["fuelConsumptionEdit"].Text), false))
		setMultiMapValue(newSettings, "Session Settings", "Fuel.SafetyMargin", Round(convertUnit("Volume", internalValue("Float", settingsGui["safetyFuelEdit"].Text), false)))

		setMultiMapValue(newSettings, "Session Settings", "Lap.Formation", settingsGui["formationLapCheck"].Value)
		setMultiMapValue(newSettings, "Session Settings", "Lap.PostRace", settingsGui["postRaceLapCheck"].Value)

		splitCompound(gTyreCompounds[settingsGui["spSetupTyreCompoundFLDropDown"].Value], &tyreCompound, &tyreCompoundColor)

		setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound", tyreCompound)
		setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound.Color", tyreCompoundColor)

		if (mixedCompounds = "Wheel") {
			for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
				splitCompound(gTyreCompounds[settingsGui["spSetupTyreCompound" . wheels[index] . "DropDown"].Value]
							, &tyreCompound, &tyreCompoundColor)

				setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound." . tyre, tyreCompound)
				setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound.Color." . tyre, tyreCompoundColor)
			}
		}
		else if (mixedCompounds = "Axle") {
			for index, axle in ["Front", "Rear"] {
				splitCompound(gTyreCompounds[settingsGui["spSetupTyreCompound" . wheels[index + (index - 1)] . "DropDown"].Value]
							, &tyreCompound, &tyreCompoundColor)

				setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound." . axle, tyreCompound)
				setMultiMapValue(newSettings, "Session Setup", "Tyre.Compound.Color." . axle, tyreCompoundColor)
			}
		}

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

		setMultiMapValue(newSettings, "Assistant", "Assistant.Autonomy"
									, ["Yes", "No", "Custom"][settingsGui["strategyAutonomyDropDown"].Value])

		setMultiMapValue(newSettings, "Strategy Settings", "Strategy.Update.Laps"
									, settingsGui["strategyUpdateLapsCheck"].Value ? settingsGui["strategyUpdateLapsEdit"].Text : false)

		setMultiMapValue(newSettings, "Strategy Settings", "Strategy.Update.Pitstop"
									, settingsGui["strategyUpdatePitstopCheck"].Value ? settingsGui["strategyUpdatePitstopEdit"].Text : false)

		setMultiMapValue(newSettings, "Strategy Settings", "Traffic.Simulation", settingsGui["trafficSimulationCheck"].Value)

		setMultiMapValue(newSettings, "Session Rules", "Strategy", ["Yes", "No"][settingsGui["rulesActiveDropDown"].Value])

		if (settingsGui["rulesActiveDropDown"].Value = 1) {
			setMultiMapValue(newSettings, "Session Rules", "Stint.Length", settingsGui["stintLengthEdit"].Text)

			if (settingsGui["pitstopRuleDropDown"].Value = 2) {
				setMultiMapValue(newSettings, "Session Rules", "Pitstop.Rule", settingsGui["pitstopRuleEdit"].Text)

				validatePitstopRule("Full")
				validatePitstopWindow("Full")

				if (settingsGui["pitstopWindowDropDown"].Value = 2)
					setMultiMapValue(newSettings, "Session Rules", "Pitstop.Window", settingsGui["pitstopWindowEdit"].Text)
				else
					setMultiMapValue(newSettings, "Session Rules", "Pitstop.Window", false)
			}
			else
				setMultiMapValue(newSettings, "Session Rules", "Pitstop.Rule", false)

			index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), settingsGui["refuelRequirementsDropDown"].Text)

			setMultiMapValue(newSettings, "Session Rules", "Pitstop.Refuel", ["Optional", "Required", "Always", "Disallowed"][index])

			index := inList(collect(["Optional", "Required", "Always", "Disallowed"], translate), settingsGui["tyreChangeRequirementsDropDown"].Text)

			setMultiMapValue(newSettings, "Session Rules", "Pitstop.Tyre", ["Optional", "Required", "Always", "Disallowed"][index])

			tyreSets := []
			translatedCompounds := collect(gTyreCompounds, translate)

			loop tyreSetListView.GetCount() {
				splitCompound(gTyreCompounds[inList(translatedCompounds, tyreSetListView.GetText(A_Index, 1))]
							, &tyreCompound, &tyreCompoundColor)

				tyreSets.Push(values2String("#", tyreCompound, tyreCompoundColor
											   , tyreSetListView.GetText(A_Index, 3), tyreSetListView.GetText(A_Index, 2)))
			}

			setMultiMapValue(newSettings, "Session Rules", "Tyre.Sets", values2String(";", tyreSets*))
		}

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

		editRaceSettings(&updateState)

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
			file := withBlockedWindows(FileSelect, "S17", fileName, translate("Save Race Settings..."), "Settings (*.settings)")
			OnMessage(0x44, translateSaveCancelButtons, 0)

			if (file != "") {
				if !InStr(file, ".")
					file := (file . ".settings")

				writeMultiMap(file, newSettings)
			}
		}
	}
	else {
		oldSettings := settingsOrCommand

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

				if !kSilentMode
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
					  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings")

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
			tabs := collect(["Session", "Rules", "Pitstop", "Strategy", "Team"], translate)
		else
			tabs := collect(["Session", "Rules", "Pitstop", "Strategy"], translate)

		settingsTab := settingsGui.Add("Tab3", "x8 y48 w388 h444", tabs)

		settingsTab.UseTab(2)

		x5 := 26
		x6 := x5 - 4
		x7 := x5 + 79
		x8 := x7 + 32
		x9 := x8 + 26
		x10 := x7 + 16

		x11 := x7 + 87
		x12 := x11 + 56

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x16 y82 w108 h23", translate("Active"))
		settingsGui.Add("DropDownList", "x" . x7 . " yp-3 w80 vrulesActiveDropDown", collect(["Yes", "No"], translate)).OnEvent("Change", (*) => editRaceSettings(&updateState))

		settingsGui.Add("Text", "x66 yp+32 w270 0x10")

		settingsGui.Add("Text", "x16 yp+10 w75 h23 +0x200", translate("Max. Stint"))
		settingsGui.Add("Edit", "x" . x7 . " yp w50 h20 Limit4 Number VstintLengthEdit", 70)
		settingsGui.Add("UpDown", "x" . (x7 + 40) . " yp-2 w18 h20 Range1-9999 0x80", 70)
		settingsGui.Add("Text", "x" . (x7 + 54) . " yp+2 w50 h20", translate("Minutes"))

		settingsGui.Add("Text", "x" . (x5 - 10) . " yp+30 w85 h20 +0x200", translate("Pitstop"))
		settingsGui.Add("DropDownList", "x" . x7 . " yp-2 w80 Choose1 VpitstopRuleDropDown", collect(["Optional", "Required"], translate)).OnEvent("Change", choosePitstopRule)
		settingsGui.Add("Edit", "x" . x11 . " yp+1 w50 h20 Number Limit2 VpitstopRuleEdit", 1).OnEvent("Change", updatePitstopRule)
		settingsGui.Add("UpDown", "x" . x11 . " yp+1 w50 h20 Range0-99 VpitstopRuleUpDown")

		settingsGui.Add("Text", "x" . (x5 - 10) . " yp+28 w85 h20 +0x200", translate("Regular"))
		settingsGui.Add("DropDownList", "x" . x7 . " yp-2 w80 Choose1  VpitstopWindowDropDown", collect(["Always", "Window"], translate)).OnEvent("Change", choosePitstopWindow)
		settingsGui.Add("Edit", "x" . x11 . " yp+1 w50 h20 VpitstopWindowEdit", "25 - 35").OnEvent("Change", updatePitstopWindow)
		settingsGui.Add("Text", "x" . x12 . " yp+3 w120 h20 VpitstopWindowLabel", translate("Minute (From - To)"))

		settingsGui.Add("Text", "x" . (x5 - 10) . " yp+23 w85 h23 +0x200 VrefuelRequirementsLabel", translate("Refuel"))
		settingsGui.Add("DropDownList", "x" . x7 . " yp w80 Choose1 VrefuelRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		settingsGui.Add("Text", "x" . (x5 - 10) . " yp+27 w85 h23 +0x200 VtyreChangeRequirementsLabel", translate("Tyre Change"))
		settingsGui.Add("DropDownList", "x" . x7 . " yp w80 Choose1 VtyreChangeRequirementsDropDown", collect(["Optional", "Required", "Always", "Disallowed"], translate))

		settingsGui.Add("Text", "x" . (x5 - 10) . " yp+30 w85 h23 +0x200", translate("Tyre Sets"))

		w12 := (x11 + 60 - x7)

		tyreSetListView := settingsGui.Add("ListView", "x" . x7 . " yp w" . w12 . " h220 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "O", "#"], translate))
		tyreSetListView.OnEvent("Click", choosePSTyreSet)
		tyreSetListView.OnEvent("DoubleClick", choosePSTyreSet)
		tyreSetListView.OnEvent("ItemSelect", selectPSTyreSet)

		x13 := (x7 + w12 + 5)

		settingsGui.Add("DropDownList", "x" . x13 . " yp w85 Choose0 vtyreSetDropDown", [translate(normalizeCompound("Dry"))]).OnEvent("Change", updatePSTyreSet)

		settingsGui.Add("Edit", "x" . (x13 + 86) . " yp w40 h20 Limit2 Number vtyreSetLapsEdit").OnEvent("Change", updatePSTyreSet)
		settingsGui.Add("UpDown", "x" . (x13 + 86) . " yp w18 h20 0x80 Range0-99")

		settingsGui.Add("Edit", "x" . x13 . " yp+24 w40 h20 Limit2 Number vtyreSetCountEdit").OnEvent("Change", updatePSTyreSet)
		settingsGui.Add("UpDown", "x" . x13 . " yp w18 h20 0x80 Range0-99")

		x13 := (x7 + w12 + 5 + 126 - 48)

		settingsGui.Add("Button", "x" . x13 . " yp+6 w23 h23 Center +0x200 vtyreSetAddButton").OnEvent("Click", addPSTyreSet)
		setButtonIcon(settingsGui["tyreSetAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		x13 += 25

		settingsGui.Add("Button", "x" . x13 . " yp w23 h23 Center +0x200 vtyreSetDeleteButton").OnEvent("Click", deletePSTyreSet)
		setButtonIcon(settingsGui["tyreSetDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		settingsTab.UseTab(3)

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
		settingsGui.Add("Text", "x245 yp+2 w14 h20 VrepairSuspensionGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0), 1)).OnEvent("Change", validateNumber.Bind("repairSuspensionThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w70 h20 VrepairSuspensionThresholdLabel", translate("Sec. p. Lap"))

		updateRepairSuspensionState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Repair Bodywork"))

		choices := collect(["Never", "Always", "Threshold", "Impact"], translate)
		chosen := inList(["Never", "Always", "Threshold", "Impact"]
					   , getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Impact"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VrepairBodyworkDropDown", choices).OnEvent("Change", updateRepairBodyworkState)
		settingsGui.Add("Text", "x245 yp+2 w14 h20 VrepairBodyworkGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 1), 1)).OnEvent("Change", validateNumber.Bind("repairBodyworkThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w70 h20 VrepairBodyworkThresholdLabel", translate("Sec. p. Lap"))

		updateRepairBodyworkState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Repair Engine"))

		choices := collect(["Never", "Always", "Threshold", "Impact"], translate)
		chosen := inList(["Never", "Always", "Threshold", "Impact"], getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair", "Impact"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VrepairEngineDropDown", choices).OnEvent("Change", updateRepairEngineState)
		settingsGui.Add("Text", "x245 yp+2 w14 h20 VrepairEngineGreaterLabel", translate(">"))
		settingsGui.Add("Edit", "x260 yp-2 w50 h20 VrepairEngineThresholdEdit"
							  , displayValue("Float", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair.Threshold", 1), 1)).OnEvent("Change", validateNumber.Bind("repairEngineThresholdEdit"))
		settingsGui.Add("Text", "x318 yp+2 w70 h20 VrepairEngineThresholdLabel", translate("Sec. p. Lap"))

		updateRepairEngineState()

		settingsGui.Add("Text", "x16 yp+24 w105 h23 +0x200", translate("Change Compound"))

		choices := collect(["Never", "Tyre Temperature", "Weather"], translate)
		chosen := inList(["Never", "Temperature", "Weather"], getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never"))

		settingsGui.Add("DropDownList", "x126 yp w110 Choose" . chosen . " VchangeTyreDropDown", choices).OnEvent("Change", updateChangeTyreState)
		settingsGui.Add("Text", "x245 yp+2 w14 h20 VchangeTyreGreaterLabel", translate(">"))
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
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2), 1))).OnEvent("Change", validateNumber.Bind("tyrePressureDeviationEdit"))
		settingsGui.Add("Text", "x184 yp+2 w70 h20", getUnit("Pressure"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Temperature", true)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h21 Checked" . chosen . " VtemperatureCorrectionCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w240 h20", translate("based on temperature trend"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Setup", false)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h21 Checked" . chosen . " VsetupPressureCompareCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w240 h20", translate("based on database values"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Pressure", false)

		settingsGui.Add("Text", "x16 yp+24 w105 h20 Section", translate("Correction"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h21 Checked" . chosen . " VpressureLossCorrectionCheck", chosen)
		settingsGui.Add("Text", "x147 yp+4 w145 h20", translate("based on pressure loss"))

		settingsGui.Add("Edit", "x292 yp-1 w50 h20 vtyrePressureLossThresholdEdit"
							  , displayValue("Float", convertUnit("Pressure", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Loss.Threshold", 0.2), 1))).OnEvent("Change", validateNumber.Bind("tyrePressureLossThresholdEdit"))
		settingsGui.Add("Text", "x350 yp+2 w60 h20", getUnit("Pressure"))

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

		settingsGui.Add("Text", "x16 y82 w88 h23 +0x200 Section", translate("Avg. Lap Time"))
		settingsGui.Add("Edit", "x106 yp w50 h20 Limit3 Number VavgLaptimeEdit", value)
		settingsGui.Add("UpDown", "x138 yp-2 w18 h20 Range1-999 0x80", value)
		settingsGui.Add("Text", "x164 yp+4 w45 h20", translate("Sec."))

		settingsGui.Add("Text", "x16 yp+22 w88 h20 +0x200", translate("Fuel Consumption"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 VfuelConsumptionEdit", displayValue("Float", convertUnit("Volume", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 3.0)))).OnEvent("Change", validateNumber.Bind("fuelConsumptionEdit"))
		settingsGui.Add("Text", "x164 yp+4 w45 h20", getUnit("Volume", true))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.Formation", true)

		settingsGui.Add("Text", "x212 ys w78 h23 +0x200", translate("Formation"))
		settingsGui.Add("CheckBox", "x292 yp-1 w17 h21 Checked" . chosen . " VformationLapCheck", chosen)
		settingsGui.Add("Text", "x310 yp+4 w80 h20", translate("Lap"))

		chosen := getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PostRace", true)

		settingsGui.Add("Text", "x212 yp+22 w78 h23 +0x200", translate("Post Race"))
		settingsGui.Add("CheckBox", "x292 yp-1 w17 h21 Checked" . chosen . " VpostRaceLapCheck", chosen)
		settingsGui.Add("Text", "x310 yp+4 w80 h20", translate("Lap"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Bold Italic", "Arial")

		settingsGui.Add("Text", "x66 yp+28 w270 0x10")
		settingsGui.Add("Text", "x16 yp+10 w370 h20 Center BackgroundTrans", translate("Initial Setup"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x16 yp+30 w88 h23 +0x200", translate("Tyre Compound"))

		SimulatorProvider.createSimulatorProvider(gSimulator, gCar, gTrack).supportsTyreManagement(&mixedCompounds, &tyreSets)

		readTyreSetup(settingsOrCommand)

		choices := collect(gTyreCompounds, translate)

		settingsGui.Add("DropDownList", "x106 yp w93 VspSetupTyreCompoundFLDropDown", choices).OnEvent("Change", chooseTyreCompound)
		settingsGui.Add("DropDownList", "x200 yp w93 Disabled VspSetupTyreCompoundFRDropDown", choices).OnEvent("Change", chooseTyreCompound)
		settingsGui.Add("DropDownList", "x106 yp+24 w93 Disabled VspSetupTyreCompoundRLDropDown", choices).OnEvent("Change", chooseTyreCompound)
		settingsGui.Add("DropDownList", "x200 yp w93 Disabled VspSetupTyreCompoundRRDropDown", choices).OnEvent("Change", chooseTyreCompound)

		if (mixedCompounds = "Wheel") {
			for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
				chosen := inList(gTyreCompounds, compound(string2Values(",", setupTyreCompound)[index]
											   , string2Values(",", setupTyreCompoundColor)[index]))

				if ((chosen == 0) && (choices.Length > 0))
					chosen := 1

				settingsGui["spSetupTyreCompound" . wheels[index] . "DropDown"].Choose(chosen)
			}
		}
		else if (mixedCompounds = "Axle") {
			for index, axle in ["Front", "Rear"] {
				chosen := inList(gTyreCompounds, compound(string2Values(",", setupTyreCompound)[index]
											   , string2Values(",", setupTyreCompoundColor)[index]))

				if ((chosen == 0) && (choices.Length > 0))
					chosen := 1

				settingsGui["spSetupTyreCompound" . wheels[index + (index - 1)] . "DropDown"].Choose(chosen)
			}
		}
		else {
			chosen := inList(gTyreCompounds, compound(string2Values(",", setupTyreCompound)[1], string2Values(",", setupTyreCompoundColor)[1]))

			if ((chosen == 0) && (choices.Length > 0))
				chosen := 1

			for index, dropDown in ["spSetupTyreCompoundFLDropDown", "spSetupTyreCompoundFRDropDown"
								  , "spSetupTyreCompoundRLDropDown", "spSetupTyreCompoundRRDropDown"]
				settingsGui[dropDown].Choose(chosen)
		}

		settingsGui.Add("Text", "x16 yp+26 w88 h20", translate("Start Tyre Set"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit2 VspSetupTyreSetEdit").OnEvent("Change", updateTyreSet.Bind("spSetupTyreSetEdit"))
		settingsGui.Add("UpDown", "x138 yp-2 w18 h20 Range0-99")

		settingsGui.Add("Text", "x16 yp+24 w88 h20", translate("Pitstop Tyre Set"))
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

		settingsGui.Add("Text", "x26 yp+24 w78 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryFrontLeftEdit", dryFrontLeft).OnEvent("Change", validateNumber.Bind("spDryFrontLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w78 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryFrontRightEdit", dryFrontRight).OnEvent("Change", validateNumber.Bind("spDryFrontRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w78 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryRearLeftEdit", dryRearLeft).OnEvent("Change", validateNumber.Bind("spDryRearLeftEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x26 yp+24 w78 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x106 yp-2 w50 h20 Limit4 VspDryRearRightEdit", dryRearRight).OnEvent("Change", validateNumber.Bind("spDryRearRightEdit"))
		settingsGui.Add("Text", "x164 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.SetFont("Norm", "Arial")
		settingsGui.SetFont("Italic", "Arial")

		settingsGui.Add("GroupBox", "x202 ys w180 h120", translate("Wet / Intermediate Tyres"))

		settingsGui.SetFont("Norm", "Arial")

		settingsGui.Add("Text", "x212 yp+24 w78 h20", translate("Front Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetFrontLeftEdit", wetFrontLeft).OnEvent("Change", validateNumber.Bind("spWetFrontLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w78 h20", translate("Front Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetFrontRightEdit", wetFrontRight).OnEvent("Change", validateNumber.Bind("spWetFrontRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w78 h20", translate("Rear Left"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetRearLeftEdit", wetRearLeft).OnEvent("Change", validateNumber.Bind("spWetRearLeftEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsGui.Add("Text", "x212 yp+24 w78 h20", translate("Rear Right"))
		settingsGui.Add("Edit", "x292 yp-2 w50 h20 Limit4 VspWetRearRightEdit", wetRearRight).OnEvent("Change", validateNumber.Bind("spWetRearRightEdit"))
		settingsGui.Add("Text", "x350 yp+2 w30 h20", getUnit("Pressure"))

		settingsTab.UseTab(4)

		chosen := inList(["Yes", "No", "Custom"], getMultiMapValue(settingsOrCommand, "Assistant", "Assistant.Autonomy", "Custom"))

		settingsGui.Add("Text", "x16 y82 w108 h23", translate("Autonomous Mode"))
		settingsGui.Add("DropDownList", "x126 yp-3 w100 Choose" . chosen . " vstrategyAutonomyDropDown", collect(["Yes", "No", "Custom"], translate))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Update.Laps", false)

		settingsGui.Add("CheckBox", "x16 YP+30 w108 Checked" . (value > 0) . " VstrategyUpdateLapsCheck", translate("Revise every")).OnEvent("Click", updateStrategyLaps.Bind("Check"))
		settingsGui.Add("Edit", "x126 yp-3 w50 h20 Limit2 Number VstrategyUpdateLapsEdit", value ? value : 1).OnEvent("Change", updateStrategyLaps.Bind("Edit"))
		settingsGui.Add("UpDown", "x158 yp w18 h20 Range1-99 0x80", value ? value : 1)
		settingsGui.Add("Text", "x184 yp+2 w205 h20", translate("Laps"))

		if !value
			settingsGui["strategyUpdateLapsEdit"].Enabled := false

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Update.Pitstop", false)

		settingsGui.Add("CheckBox", "x16 YP+25 w108 Checked" . (value > 0) . " VstrategyUpdatePitstopCheck", translate("Revise if")).OnEvent("Click", updateStrategyPitstop.Bind("Check"))
		settingsGui.Add("Edit", "x126 yp-3 w50 h20 Limit1 Number VstrategyUpdatePitstopEdit", value ? value : 4).OnEvent("Change", updateStrategyPitstop.Bind("Edit"))
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9 0x80", value ? value : 4)
		settingsGui.Add("Text", "x184 yp+2 w205 h20", translate("Laps difference to Strategy"))

		if !value
			settingsGui["strategyUpdatePitstopEdit"].Enabled := false

		chosen := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Traffic.Simulation", false)

		settingsGui.Add("Text", "x16 yp+30 w108 h20", translate("Dynamic Traffic"))
		settingsGui.Add("CheckBox", "x126 yp-4 w17 h21 Checked" . chosen . " VtrafficSimulationCheck", chosen)
		settingsGui.Add("Text", "x184 yp+2 w205 h20", translate("using Monte Carlo simulation"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Extrapolation.Laps", 3)

		settingsGui.Add("Text", "x16 yp+30 w108 h20 Section", translate("Race positions"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit1 Number VextrapolationLapsEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9", value)
		settingsGui.Add("Text", "x184 yp+2 w205 h20", translate("simulated future laps"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Overtake.Delta", 1)

		settingsGui.Add("Text", "x16 yp+20 w82 h23 +0x200", translate("Overtake"))
		settingsGui.Add("Text", "x100 yp w28 h23 +0x200", translate("Abs("))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit2 Number VovertakeDeltaEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-99 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w205 h20", translate("/ laptime difference) Seconds"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Traffic.Considered", 5)

		settingsGui.Add("Text", "x16 yp+20 w108 h23 +0x200", translate("Traffic"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit3 Number VtrafficConsideredEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-100 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w205 h20", translate("% track length"))

		settingsGui.Add("Text", "x66 yp+28 w270 0x10")

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Strategy.Window.Considered", 3)

		settingsGui.Add("Text", "x16 yp+15 w108 h23 +0x200", translate("Pitstop Window"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Limit1 Number VpitstopStrategyWindowEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range1-9 0x80", value)
		settingsGui.Add("Text", "x184 yp+4 w205 h20", translate("Laps +/- around optimal lap"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Pitstop.Delta", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Pitstop.Delta", 60))

		settingsGui.Add("Text", "x16 yp+22 w108 h20 +0x200", translate("Pitlane Delta"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit2 Number VpitstopDeltaEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 0x80 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+4 w205 h20", translate("Seconds (Drive through - Drive by)"))

		value := getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Tyres", 30)

		settingsGui.Add("Text", "x16 yp+22 w108 h20 +0x200", translate("Tyre Service"))
		settingsGui.Add("Edit", "x126 yp-2 w50 h20 Limit2 Number VpitstopTyreServiceEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 0x80 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+4 w205 h20", translate("Seconds (Change four tyres)"))

		chosen := inList(["Fixed", "Dynamic"], getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Refuel.Rule", "Dynamic"))

		settingsGui.Add("DropDownList", "x12 yp+21 w110 Choose" . chosen . " VpitstopRefuelServiceRuleDropdown", collect(["Refuel Fixed", "Refuel Dynamic"], translate)).OnEvent("Change", choosePSRefuelService)

		settingsGui.Add("Edit", "x126 yp w50 h20 VpitstopRefuelServiceEdit"
							  , displayValue("Float", getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Refuel", 1.8), 1)).OnEvent("Change", validateNumber.Bind("pitstopRefuelServiceEdit"))
		settingsGui.Add("Text", "x184 yp+4 w205 h20 VpitstopRefuelServiceLabel", translate(["Seconds", "Seconds (Refuel of 10 liters)"][settingsGui["pitstopRefuelServiceRuleDropdown"].Value]))

		chosen := ((getMultiMapValue(settingsOrCommand, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2)

		settingsGui.Add("Text", "x16 yp+24 w108 h23", translate("Service"))
		settingsGui.Add("DropDownList", "x126 yp-3 w100 Choose" . chosen . " vpitstopServiceDropDown", collect(["Simultaneous", "Sequential"], translate))

		value := displayValue("Float", convertUnit("Volume", getDeprecatedValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 4)), 0)

		settingsGui.Add("Text", "x16 yp+27 w108 h23 +0x200", translate("Safety Fuel"))
		settingsGui.Add("Edit", "x126 yp w50 h20 Number Limit2 VsafetyFuelEdit", value)
		settingsGui.Add("UpDown", "x158 yp-2 w18 h20 Range0-99", value)
		settingsGui.Add("Text", "x184 yp+2 w90 h20", getUnit("Volume", true))

		if gTeamMode {
			settingsTab.UseTab(5)

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

			if (gTeamMode = "Team")
				settingsTab.Value := 5
		}

		loadTyreCompounds()

		settingsGui["rulesActiveDropDown"].Choose(inList(["Yes", "No"], getMultiMapValue(settingsOrCommand, "Session Rules", "Strategy", "No")))
		settingsGui["stintLengthEdit"].Text := getMultiMapValue(settingsOrCommand, "Session Rules", "Stint.Length", 70)

		settingsGui["pitstopRuleEdit"].Text := getMultiMapValue(settingsOrCommand, "Session Rules", "Pitstop.Rule", 0)
		settingsGui["pitstopRuleDropDown"].Choose(1 + (settingsGui["pitstopRuleEdit"].Text > 0))

		settingsGui["pitstopWindowDropDown"].Choose(1 + !!getMultiMapValue(settingsOrCommand, "Session Rules", "Pitstop.Window", false))
		settingsGui["pitstopWindowEdit"].Text := getMultiMapValue(settingsOrCommand, "Session Rules", "Pitstop.Window")

		settingsGui["refuelRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"]
															  , getMultiMapValue(settingsOrCommand, "Session Rules"
																								  , "Pitstop.Refuel"
																								  , "Optional")))
		settingsGui["tyreChangeRequirementsDropDown"].Choose(inList(["Optional", "Required", "Always", "Disallowed"]
																  , getMultiMapValue(settingsOrCommand, "Session Rules"
																									  , "Pitstop.Tyre"
																									  , "Optional")))

		loop tyreSetListView.GetCount()
			tyreSetListView.Modify(A_Index, "-Select Col3", 99)

		for ignore, tyreCompound in string2Values(";", getMultiMapValue(settingsOrCommand, "Session Rules"
																						 , "Tyre.Sets", "")) {
			if InStr(tyreCompound, ":") {
				tyreCompound := string2Values(":", tyreCompound)

				loop tyreSetListView.GetCount()
					if (translate(compound(tyreCompound[1], tyreCompound[2])) = tyreSetListView.GetText(A_Index, 1)) {
						tyreSetListView.Modify(A_Index, "Col3", tyreCompound[3])

						if (tyreCompound.Length > 3)
							tyreSetListView.Modify(A_Index, "Col2", tyreCompound[4])
					}
			}
			else {
				tyreCompound := string2Values("#", tyreCompound)

				loop tyreSetListView.GetCount()
					if (translate(compound(tyreCompound[1], tyreCompound[2])) = tyreSetListView.GetText(A_Index, 1)) {
						tyreSetListView.Modify(A_Index, "Col3", tyreCompound[3])
						tyreSetListView.Modify(A_Index, "Col2", tyreCompound[4])
					}
			}
		}

		editRaceSettings(&updateState)

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

showRaceSettingsEditor() {
	global gSimulator, gCar, gTrack, gWeather, gAirTemperature, gTrackTemperature
	global gTyreCompound, gTyreCompoundColor, gTyreCompounds, gSilentMode, gTeamMode, gTestMode

	local message := "Export"
	local icon := kIconsDirectory . "Race Settings.ico"
	local index, fileName, settings, hasTeamServer

	TraySetIcon(icon, "1")
	A_IconTip := "Race Settings"

	gSimulator := false
	gCar := false
	gTrack := false
	gWeather := "*"
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

	if !gSimulator {
		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		gSimulator := getMultiMapValue(settings, "Simulator", "Simulator", false)

		if (gSimulator && Application(gSimulator, kSimulatorConfiguration).isRunning()) {
			gCar := getMultiMapValue(settings, "Simulator", "Car")
			gTrack := getMultiMapValue(settings, "Simulator", "Track")
		}
		else
			gSimulator := false
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
	else {
		hasTeamServer := getMultiMapValue(kSimulatorConfiguration, "Plugins", "Team Server", false)

		if hasTeamServer
			hasTeamServer := string2Values("|", hasTeamServer)[1]

		if (hasTeamServer = kTrue)
			hasTeamServer := true
		else if (hasTeamServer = kFalse)
			hasTeamServer := false

		if hasTeamServer {
			if inList(A_Args, "-Team")
				gTeamMode := "Team"
		}
		else
			gTeamMode := false
	}

	if inList(A_Args, "-Test")
		gTestMode := true

	index := inList(A_Args, "-Import")

	if index {
		if editRaceSettings(&message, A_Args[index + 1], A_Args[index + 2], settings)
			writeMultiMap(fileName, settings)
	}
	else {
		registerMessageHandler("Setup", functionMessageHandler)

		startupApplication()

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
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

if kLogStartup
	logMessage(kLogOff, "Loading plugins...")

#Include "..\Plugins\Simulator Providers.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceSettingsEditor()