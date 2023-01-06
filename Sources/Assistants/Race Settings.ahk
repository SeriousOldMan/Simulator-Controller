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
#Include ..\Framework\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Race Settings.ico
;@Ahk2Exe-ExeName Race Settings.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Process.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\CLR.ahk
#Include Libraries\SessionDatabase.ahk


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

global vSilentMode := kSilentMode
global vTeamMode := true
global vTestMode := false

global vSimulator := false
global vCar := false
global vTrack := false
global vWeather := "Dry"
global vAirTemperature := 23
global vTrackTemperature := 27

global vTyreCompounds := kTyreCompounds

global vCompound := false
global vCompoundColor := false

global repairSuspensionDropDown
global repairSuspensionThresholdEdit
global repairSuspensionGreaterLabel
global repairSuspensionThresholdLabel

global repairBodyworkDropDown
global repairBodyworkThresholdEdit
global repairBodyworkGreaterLabel
global repairBodyworkThresholdLabel

global repairEngineDropDown
global repairEngineThresholdEdit
global repairEngineGreaterLabel
global repairEngineThresholdLabel

global changeTyreDropDown
global changeTyreThresholdEdit
global changeTyreGreaterLabel
global changeTyreThresholdLabel

global spSetupTyreCompoundDropDown
global spSetupTyreSetEdit
global spPitstopTyreSetEdit

global fuelConsumptionEdit
global tyrePressureDeviationEdit
global pitstopRefuelServiceRuleDropDown
global pitstopRefuelServiceEdit
global pitstopRefuelServiceLabel

global tpDryFrontLeftEdit
global tpDryFrontRightEdit
global tpDryRearLeftEdit
global tpDryRearRightEdit
global tpWetFrontLeftEdit
global tpWetFrontRightEdit
global tpWetRearLeftEdit
global tpWetRearRightEdit

global spDryFrontLeftEdit
global spDryFrontRightEdit
global spDryRearLeftEdit
global spDryRearRightEdit
global spWetFrontLeftEdit
global spWetFrontRightEdit
global spWetRearLeftEdit
global spWetRearRightEdit


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

loginDialog(connectorOrCommand := false, teamServerURL := false) {
	local window := "TSL"
	local title

	static result := false
	static nameEdit := ""
	static passwordEdit := ""

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false

		Gui %window%:New

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x16 y16 w90 h23 +0x200, % translate("Server URL")
		Gui %window%:Add, Text, x110 yp w160 h23 +0x200, %teamServerURL%

		Gui %window%:Add, Text, x16 yp+30 w90 h23 +0x200, % translate("Name")
		Gui %window%:Add, Edit, x110 yp+1 w160 h21 VnameEdit, %nameEdit%
		Gui %window%:Add, Text, x16 yp+23 w90 h23 +0x200, % translate("Password")
		Gui %window%:Add, Edit, x110 yp+1 w160 h21 Password VpasswordEdit, %passwordEdit%

		Gui %window%:Add, Button, x60 yp+35 w80 h23 Default gacceptLogin, % translate("Ok")
		Gui %window%:Add, Button, x146 yp w80 h23 gcancelLogin, % translate("&Cancel")

		Gui %window%:Show, AutoSize Center

		while !result
			Sleep 100

		Gui %window%:Submit
		Gui %window%:Destroy

		if (result == kCancel)
			return false
		else if (result == kOk) {
			try {
				connectorOrCommand.Initialize(teamServerURL)

				connectorOrCommand.Login(nameEdit, passwordEdit)

				return connectorOrCommand.GetSessionToken()
			}
			catch exception {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")

				return false
			}
		}
	}
}

acceptLogin() {
	loginDialog(kOk)
}

cancelLogin() {
	loginDialog(kCancel)
}

moveRaceSettingsEditor() {
	moveByMouse("RES", "Race Settings")
}

loadRaceSettings() {
	editRaceSettings(kLoad)
}

saveRaceSettings() {
	editRaceSettings(kSave)
}

acceptRaceSettings() {
	editRaceSettings(kOk)
}

cancelRaceSettings() {
	editRaceSettings(kCancel)
}

connectServer() {
	editRaceSettings(kConnect)
}

chooseTeam() {
	editRaceSettings(kUpdate, "Team")
}

chooseDriver() {
	editRaceSettings(kUpdate, "Driver")
}

chooseSession() {
	editRaceSettings(kUpdate, "Session")
}

openSettingsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings
}

isPositiveFloat(numbers*) {
	local ignore, value

	for ignore, value in numbers
		if value is not Float
			return false
		else if (value < 0)
			return false

	return true
}

isPositiveNumber(numbers*) {
	local ignore, value

	for ignore, value in numbers
		if value is not Number
			return false
		else if (value < 0)
			return false

	return true
}

updateRepairSuspensionState() {
	GuiControlGet repairSuspensionDropDown

	if ((repairSuspensionDropDown == 1) || (repairSuspensionDropDown == 2)) {
		GuiControl Hide, repairSuspensionGreaterLabel
		GuiControl Hide, repairSuspensionThresholdEdit
		GuiControl Hide, repairSuspensionThresholdLabel

		repairSuspensionThresholdEdit := 0

		GuiControl, , repairSuspensionThresholdEdit, 0
	}
	else if (repairSuspensionDropDown == 3) {
		GuiControl Show, repairSuspensionGreaterLabel
		GuiControl Show, repairSuspensionThresholdEdit
		GuiControl Hide, repairSuspensionThresholdLabel
	}
	else if (repairSuspensionDropDown == 4) {
		GuiControl Show, repairSuspensionGreaterLabel
		GuiControl Show, repairSuspensionThresholdEdit
		GuiControl Show, repairSuspensionThresholdLabel
	}
}

updateRepairBodyworkState() {
	GuiControlGet repairBodyworkDropDown

	if ((repairBodyworkDropDown == 1) || (repairBodyworkDropDown == 2)) {
		GuiControl Hide, repairBodyworkGreaterLabel
		GuiControl Hide, repairBodyworkThresholdEdit
		GuiControl Hide, repairBodyworkThresholdLabel

		repairBodyworkThresholdEdit := 0

		GuiControl, , repairBodyworkThresholdEdit, 0
	}
	else if (repairBodyworkDropDown == 3) {
		GuiControl Show, repairBodyworkGreaterLabel
		GuiControl Show, repairBodyworkThresholdEdit
		GuiControl Hide, repairBodyworkThresholdLabel
	}
	else if (repairBodyworkDropDown == 4) {
		GuiControl Show, repairBodyworkGreaterLabel
		GuiControl Show, repairBodyworkThresholdEdit
		GuiControl Show, repairBodyworkThresholdLabel
	}
}

updateRepairEngineState() {
	GuiControlGet repairEngineDropDown

	if ((repairEngineDropDown == 1) || (repairEngineDropDown == 2)) {
		GuiControl Hide, repairEngineGreaterLabel
		GuiControl Hide, repairEngineThresholdEdit
		GuiControl Hide, repairEngineThresholdLabel

		repairEngineThresholdEdit := 0

		GuiControl, , repairEngineThresholdEdit, 0
	}
	else if (repairEngineDropDown == 3) {
		GuiControl Show, repairEngineGreaterLabel
		GuiControl Show, repairEngineThresholdEdit
		GuiControl Hide, repairEngineThresholdLabel
	}
	else if (repairEngineDropDown == 4) {
		GuiControl Show, repairEngineGreaterLabel
		GuiControl Show, repairEngineThresholdEdit
		GuiControl Show, repairEngineThresholdLabel
	}
}

updateChangeTyreState() {
	GuiControlGet changeTyreDropDown

	if ((changeTyreDropDown == 1) || (changeTyreDropDown == 3)) {
		GuiControl Hide, changeTyreGreaterLabel
		GuiControl Hide, changeTyreThresholdEdit
		GuiControl Hide, changeTyreThresholdLabel

		changeTyreThresholdEdit := 0

		GuiControl, , changeTyreThresholdEdit, 0
	}
	else if (changeTyreDropDown == 2) {
		GuiControl Show, changeTyreGreaterLabel
		GuiControl Show, changeTyreThresholdEdit
		GuiControl Show, changeTyreThresholdLabel

		GuiControl Text, changeTyreThresholdLabel, % translate("Degrees")
	}
	else if (changeTyreDropDown == 4) {
		GuiControl Show, changeTyreGreaterLabel
		GuiControl Show, changeTyreThresholdEdit
		GuiControl Show, changeTyreThresholdLabel

		GuiControl Text, changeTyreThresholdLabel, % translate("Sec. p. Lap")
	}
}

readTyreSetup(settings) {
	local color

	if (vCompound && vCompoundColor) {
		spSetupTyreCompoundDropDown := vCompound
		color := vCompoundColor
	}
	else {
		spSetupTyreCompoundDropDown := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
		color := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")
	}

	spSetupTyreCompoundDropDown := compound(spSetupTyreCompoundDropDown, color)

	spSetupTyreSetEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set", 1)
	spPitstopTyreSetEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set.Fresh", 2)

	spDryFrontLeftEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)
	spDryFrontRightEdit:= getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)
	spDryRearLeftEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)
	spDryRearRightEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)
	spWetFrontLeftEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FL", 28.5)
	spWetFrontRightEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FR", 28.5)
	spWetRearLeftEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RL", 28.5)
	spWetRearRightEdit := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RR", 28.5)
}

getDeprecatedConfigurationValue(data, newSection, oldSection, key, default := false) {
	local value := getConfigurationValue(data, newSection, key, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}

parseObject(properties) {
	local result := {}
	local property

	properties := StrReplace(properties, "`r", "")

	loop Parse, properties, `n
	{
		property := string2Values("=", A_LoopField)

		result[property[1]] := property[2]
	}

	return result
}

loadTeams(connector) {
	local teams := {}
	local identifiers, ignore, identifier, team

	try {
		identifiers := string2Values(";", connector.GetAllTeams())
	}
	catch exception {
		identifiers := []
	}

	for ignore, identifier in identifiers {
		team := parseObject(connector.GetTeam(identifier))

		teams[team.Name] := team.Identifier
	}

	return teams
}

loadDrivers(connector, team) {
	local drivers := {}
	local identifiers, ignore, identifier, driver, name

	if team {
		try {
			identifiers := string2Values(";", connector.GetTeamDrivers(team))
		}
		catch exception {
			identifiers := []
		}

		for ignore, identifier in identifiers {
			driver := parseObject(connector.GetDriver(identifier))

			name := computeDriverName(driver.ForName, driver.SurName, driver.NickName)

			drivers[name] := driver.Identifier
		}
	}

	return drivers
}

loadSessions(connector, team) {
	local sessions := {}
	local identifiers, ignore, identifier, session

	if team {
		try {
			identifiers := string2Values(";", connector.GetTeamSessions(team))
		}
		catch exception {
			identifiers := []
		}

		for ignore, identifier in identifiers {
			try {
				session := parseObject(connector.GetSession(identifier))

				sessions[session.Name] := session.Identifier
			}
			catch exception {
				logError(exception)
			}
		}
	}

	return sessions
}

editRaceSettings(ByRef settingsOrCommand, arguments*) {
	local dllFile, dllName, names, exception, chosen, choices, tabs, import, simulator, ignore, option
	local dirName, simulatorCode, title, file, compound, compoundColor, fileName, token
	local x, y, e, sessionDB, directory, connection, settings, serverURLs

	static result
	static newSettings

	static pitstopWarningEdit
	static extrapolationLapsEdit
	static overtakeDeltaEdit
	static trafficConsideredEdit
	static pitstopStrategyWindowEdit

	static temperatureCorrectionCheck
	static setupPressureCompareCheck
	static pressureLossCorrectionCheck

	static raceDurationEdit
	static avgLaptimeEdit
	static formationLapCheck
	static postRaceLapCheck
	static pitstopDeltaEdit
	static pitstopTyreServiceEdit
	static pitstopServiceDropDown
	static safetyFuelEdit

	static serverURLEdit
	static serverTokenEdit
	static teamDropDownMenu
	static teamName
	static teamIdentifier
	static driverDropDownMenu
	static driverName
	static driverIdentifier
	static sessionDropDownMenu
	static sessionName
	static sessionIdentifier

	static connector
	static connected
	static keepAliveTask := false

	static teams := {}
	static drivers := {}
	static sessions := {}

restart:
	if (settingsOrCommand == kLoad)
		result := kLoad
	else if (settingsOrCommand == kCancel)
		result := kCancel
	else if (settingsOrCommand == kUpdate) {
		if connected
			if (arguments[1] == "Team") {
				GuiControlGet teamDropDownMenu

				teamName := getKeys(teams)[teamDropDownMenu]
				teamIdentifier := teams[teamName]

				exception := false

				try {
					drivers := loadDrivers(connector, teamIdentifier)
				}
				catch e {
					drivers := {}

					exception := e
				}

				names := getKeys(drivers)
				chosen := inList(getValues(drivers), driverIdentifier)

				if ((chosen == 0) && (names.Length() > 0))
					chosen := 1

				if (chosen == 0) {
					driverName := ""
					driverIdentifier := false
				}
				else {
					driverName := names[chosen]
					driverIdentifier := drivers[driverName]
				}

				GuiControl, , driverDropDownMenu, % ("|" . values2String("|", names*))
				GuiControl Choose, driverDropDownMenu, % chosen

				try {
					sessions := loadSessions(connector, teamIdentifier)
				}
				catch e {
					sessions := {}

					exception := e
				}

				names := getKeys(sessions)
				chosen := inList(getValues(sessions), sessionIdentifier)

				if ((chosen == 0) && (names.Length() > 0))
					chosen := 1

				if (chosen == 0) {
					sessionName := ""
					sessionIdentifier := false
				}
				else {
					sessionName := names[chosen]
					sessionIdentifier := sessions[sessionName]
				}

				GuiControl, , sessionDropDownMenu, % ("|" . values2String("|", names*))
				GuiControl Choose, sessionDropDownMenu, % chosen

				if exception
					throw exception
			}
			else if (arguments[1] == "Driver") {
				GuiControlGet driverDropDownMenu

				driverName := getKeys(drivers)[driverDropDownMenu]
				driverIdentifier := drivers[driverName]
			}
			else if (arguments[1] == "Session") {
				GuiControlGet sessionDropDownMenu

				sessionName := getKeys(sessions)[sessionDropDownMenu]
				sessionIdentifier := sessions[sessionName]
			}
	}
	else if (settingsOrCommand == kConnect) {
		GuiControlGet serverURLEdit
		GuiControlGet serverTokenEdit

		if connector {
			if GetKeyState("Ctrl", "P") {
				Gui TSL:+OwnerRES
				Gui RES:+Disabled

				try {
					token := loginDialog(connector, serverURLEdit)

					if token {
						serverTokenEdit := token

						Gui RES:Default

						GuiControl Text, serverTokenEdit, %serverTokenEdit%
					}
					else
						return
				}
				finally {
					Gui RES:-Disabled
				}
			}

			try {
				connector.Initialize(serverURLEdit, serverTokenEdit)

				sessionDB := new SessionDatabase()

				connection := connector.Connect(serverTokenEdit, sessionDB.ID
											  , vSimulator ? sessionDB.getDriverName(vSimulator, sessionDB.ID) : sessionDB.getUserName()
											  , "Driver")

				if (connection && (connection != "")) {
					settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

					serverURLs := string2Values(";", getConfigurationValue(settings, "Team Server", "Server URLs", ""))

					if !inList(serverURLs, serverURLEdit) {
						serverURLs.Push(serverURLEdit)

						setConfigurationValue(settings, "Team Server", "Server URLs", values2String(";", serverURLs*))

						writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)

						GuiControl, , serverURLEdit, % ("|" . values2String("|", serverURLs*))
						GuiControl Choose, serverURLEdit, % inList(serverURLs, serverURLEdit)
					}

					connector.ValidateSessionToken()

					if keepAliveTask
						keepAliveTask.stop()

					keepAliveTask := new PeriodicTask(ObjBindMethod(connector, "KeepAlive", connection), 120000, kLowPriority)

					keepAliveTask.start()

					teams := loadTeams(connector)

					names := getKeys(teams)
					chosen := inList(getValues(teams), teamIdentifier)

					if ((chosen == 0) && (names.Length() > 0))
						chosen := 1

					if (chosen == 0) {
						teamName := ""
						teamIdentifier := false
					}
					else {
						teamName := names[chosen]
						teamIdentifier := teams[teamName]
					}

					GuiControl, , teamDropDownMenu, % ("|" . values2String("|", names*))
					GuiControl Choose, teamDropDownMenu, % chosen

					connected := true

					editRaceSettings(kUpdate, "Team")

					showMessage(translate("Successfully connected to the Team Server."))
				}
				else
					throw Exception("Invalid or missing token...")
			}
			catch exception {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")
			}
		}
	}
	else if ((settingsOrCommand == kSave) || (settingsOrCommand == kOk)) {
		Gui RES:Submit, NoHide

		newSettings := newConfiguration()

		if (!isPositiveFloat(tyrePressureDeviationEdit
						   , tpDryFrontLeftEdit, tpDryFrontRightEdit, tpDryRearLeftEdit, tpDryRearRightEdit
						   , tpWetFrontLeftEdit, tpWetFrontRightEdit, tpWetRearLeftEdit, tpWetRearRightEdit
						   , spDryFrontLeftEdit, spDryFrontRightEdit, spDryRearLeftEdit, spDryRearRightEdit
						   , spWetFrontLeftEdit, spWetFrontRightEdit, spWetRearLeftEdit, spWetRearRightEdit)
		 || !isPositiveNumber(fuelConsumptionEdit, repairSuspensionThresholdEdit, pitstopRefuelServiceEdit
							, repairBodyworkThresholdEdit, repairEngineThresholdEdit)
		 || (trafficConsideredEdit < 1) || (trafficConsideredEdit > 100)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}

		setConfigurationValue(newSettings, "Session Settings", "Lap.PitstopWarning", pitstopWarningEdit)

		setConfigurationValue(newSettings, "Session Settings", "Damage.Suspension.Repair"
							, ["Never", "Always", "Threshold", "Impact"][repairSuspensionDropDown])
		setConfigurationValue(newSettings, "Session Settings", "Damage.Suspension.Repair.Threshold", Round(repairSuspensionThresholdEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Damage.Bodywork.Repair"
							, ["Never", "Always", "Threshold", "Impact"][repairBodyworkDropDown])
		setConfigurationValue(newSettings, "Session Settings", "Damage.Bodywork.Repair.Threshold", Round(repairBodyworkThresholdEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Damage.Engine.Repair"
							, ["Never", "Always", "Threshold", "Impact"][repairEngineDropDown])
		setConfigurationValue(newSettings, "Session Settings", "Damage.Engine.Repair.Threshold", Round(repairEngineThresholdEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Tyre.Compound.Change"
							, ["Never", "Temperature", "Weather"][changeTyreDropDown])
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Compound.Change.Threshold", Round(changeTyreThresholdEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Deviation", tyrePressureDeviationEdit)
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Temperature", temperatureCorrectionCheck)
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Setup", setupPressureCompareCheck)
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Pressure", pressureLossCorrectionCheck)

		setConfigurationValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.FL", Round(tpDryFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.FR", Round(tpDryFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.RL", Round(tpDryRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Dry.Pressure.Target.RR", Round(tpDryRearRightEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.FL", Round(tpWetFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.FR", Round(tpWetFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.RL", Round(tpWetRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Wet.Pressure.Target.RR", Round(tpWetRearRightEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Duration", raceDurationEdit * 60)
		setConfigurationValue(newSettings, "Session Settings", "Lap.AvgTime", avgLaptimeEdit)
		setConfigurationValue(newSettings, "Session Settings", "Fuel.AvgConsumption", Round(fuelConsumptionEdit, 2))
		setConfigurationValue(newSettings, "Session Settings", "Fuel.SafetyMargin", safetyFuelEdit)

		setConfigurationValue(newSettings, "Session Settings", "Lap.Formation", formationLapCheck)
		setConfigurationValue(newSettings, "Session Settings", "Lap.PostRace", postRaceLapCheck)

		splitCompound(vTyreCompounds[spSetupTyreCompoundDropDown], compound, compoundColor)

		setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", compound)
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound.Color", compoundColor)

		setConfigurationValue(newSettings, "Session Setup", "Tyre.Set", spSetupTyreSetEdit)
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Set.Fresh", spPitstopTyreSetEdit)

		setConfigurationValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Session Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))

		setConfigurationValue(newSettings, "Strategy Settings", "Pitstop.Delta", pitstopDeltaEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Service.Tyres", pitstopTyreServiceEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Service.Refuel.Rule", ["Fixed", "Dynamic"][pitstopRefuelServiceRuleDropDown])
		setConfigurationValue(newSettings, "Strategy Settings", "Service.Refuel", pitstopRefuelServiceEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Service.Order", (pitstopServiceDropDown == 1) ? "Simultaneous" : "Sequential")
		setConfigurationValue(newSettings, "Strategy Settings", "Extrapolation.Laps", extrapolationLapsEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Overtake.Delta", overtakeDeltaEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Traffic.Considered", trafficConsideredEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Strategy.Window.Considered", pitstopStrategyWindowEdit)

		if vTeamMode {
			setConfigurationValue(newSettings, "Team Settings", "Server.URL", serverURLEdit)
			setConfigurationValue(newSettings, "Team Settings", "Server.Token", serverTokenEdit)
			setConfigurationValue(newSettings, "Team Settings", "Team.Name", teamName)
			setConfigurationValue(newSettings, "Team Settings", "Driver.Name", driverName)
			setConfigurationValue(newSettings, "Team Settings", "Session.Name", sessionName)
			setConfigurationValue(newSettings, "Team Settings", "Team.Identifier", teamIdentifier)
			setConfigurationValue(newSettings, "Team Settings", "Driver.Identifier", driverIdentifier)
			setConfigurationValue(newSettings, "Team Settings", "Session.Identifier", sessionIdentifier)
		}

		if (settingsOrCommand == kOk)
			Gui RES:Destroy

		result := settingsOrCommand
	}
	else {
		connector := false
		connected := false

		if vTeamMode {
			dllName := "Team Server Connector.dll"
			dllFile := kBinariesDirectory . dllName

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
				}

				connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
			}
			catch exception {
				logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

				showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		result := false

		pitstopWarningEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PitstopWarning", 3)

		repairSuspensionDropDown := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Suspension.Repair", "Always")
		repairSuspensionThresholdEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0)

		repairBodyworkDropDown := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Impact")
		repairBodyworkThresholdEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 1)

		repairEngineDropDown := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair", "Impact")
		repairEngineThresholdEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Damage.Engine.Repair.Threshold", 1)

		changeTyreDropDown := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never")
		changeTyreThresholdEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change.Threshold", 0)

		tyrePressureDeviationEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2)
		temperatureCorrectionCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Temperature", true)
		setupPressureCompareCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Setup", false)
		pressureLossCorrectionCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Pressure", false)

		tpDryFrontLeftEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
		tpDryFrontRightEdit:= getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
		tpDryRearLeftEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
		tpDryRearRightEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
		tpWetFrontLeftEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
		tpWetFrontRightEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
		tpWetRearLeftEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
		tpWetRearRightEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)

		raceDurationEdit := Round(getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Duration", 3600) / 60)
		avgLaptimeEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.AvgTime", 120)
		fuelConsumptionEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 3.0)
		safetyFuelEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 4)

		formationLapCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.Formation", true)
		postRaceLapCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Lap.PostRace", true)

		pitstopDeltaEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Pitstop.Delta", getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Pitstop.Delta", 60))
		pitstopTyreServiceEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Service.Tyres", 30)
		pitstopRefuelServiceRuleDropDown := inList(["Fixed", "Dynamic"], getConfigurationValue(settingsOrCommand, "Strategy Settings", "Service.Refuel.Rule", "Dynamic"))
		pitstopRefuelServiceEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Service.Refuel", 1.5)
		pitstopServiceDropDown := ((getConfigurationValue(settingsOrCommand, "Strategy Settings", "Service.Order", "Simultaneous") = "Simultaneous") ? 1 : 2)
		extrapolationLapsEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Extrapolation.Laps", 3)
		overtakeDeltaEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Overtake.Delta", 1)
		trafficConsideredEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Traffic.Considered", 5)
		pitstopStrategyWindowEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Strategy.Window.Considered", 2)

		readTyreSetup(settingsOrCommand)

		if vTeamMode {
			serverURLEdit := getConfigurationValue(settingsOrCommand, "Team Settings", "Server.URL", "")
			serverTokenEdit := getConfigurationValue(settingsOrCommand, "Team Settings", "Server.Token", "")
			teamName := getConfigurationValue(settingsOrCommand, "Team Settings", "Team.Name", "")
			teamIdentifier := getConfigurationValue(settingsOrCommand, "Team Settings", "Team.Identifier", false)
			driverName := getConfigurationValue(settingsOrCommand, "Team Settings", "Driver.Name", "")
			driverIdentifier := getConfigurationValue(settingsOrCommand, "Team Settings", "Driver.Identifier", false)
			sessionName := getConfigurationValue(settingsOrCommand, "Team Settings", "Session.Name", "")
			sessionIdentifier := getConfigurationValue(settingsOrCommand, "Team Settings", "Session.Identifier", false)

			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			serverURLs := string2Values(";", getConfigurationValue(settings, "Team Server", "Server URLs", ""))
		}

		Gui RES:Default

		Gui RES:-Border ; -Caption
		Gui RES:Color, D0D0D0, D8D8D8

		Gui RES:Font, Bold, Arial

		Gui RES:Add, Text, w388 Center gmoveRaceSettingsEditor, % translate("Modular Simulator Controller System")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic Underline, Arial

		Gui RES:Add, Text, x118 YP+20 w168 cBlue Center gopenSettingsDocumentation, % translate("Race Settings")

		Gui RES:Font, Norm, Arial

		if !vTestMode {
			Gui RES:Add, Button, x228 y499 w80 h23 Default gacceptRaceSettings, % translate("Ok")
			Gui RES:Add, Button, x316 y499 w80 h23 gcancelRaceSettings, % translate("&Cancel")
		}
		else
			Gui RES:Add, Button, x316 y499 w80 h23 Default gcancelRaceSettings, % translate("Close")

		Gui RES:Add, Button, x8 y499 w77 h23 gloadRaceSettings, % translate("&Load...")
		Gui RES:Add, Button, x90 y499 w77 h23 gsaveRaceSettings, % translate("&Save...")

		if vTeamMode
			tabs := map(["Race", "Pitstop", "Strategy", "Team"], "translate")
		else
			tabs := map(["Race", "Pitstop", "Strategy"], "translate")

		Gui RES:Add, Tab3, x8 y48 w388 h444 -Wrap, % values2String("|", tabs*)

		Gui Tab, 2

		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Pitstop Warning")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VpitstopWarningEdit, %pitstopWarningEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-9, %pitstopWarningEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("Laps")

		Gui RES:Add, Text, x16 yp+30 w105 h23 +0x200, % translate("Repair Suspension")

		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairSuspensionDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairSuspensionDropDown)

		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairSuspensionDropDown% VrepairSuspensionDropDown gupdateRepairSuspensionState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairSuspensionGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit gvalidateRepairSuspensionThreshold, %repairSuspensionThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairSuspensionThresholdLabel, % translate("Sec. p. Lap")

		updateRepairSuspensionState()

		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Repair Bodywork")

		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairBodyworkDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairBodyworkDropDown)

		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairBodyworkDropDown% VrepairBodyworkDropDown gupdateRepairBodyworkState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairBodyworkGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit gvalidateRepairBodyworkThreshold, %repairBodyworkThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairBodyworkThresholdLabel, % translate("Sec. p. Lap")

		updateRepairBodyworkState()

		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Repair Engine")

		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairEngineDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairEngineDropDown)

		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairEngineDropDown% VrepairEngineDropDown gupdateRepairEngineState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairEngineGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairEngineThresholdEdit gvalidateRepairEngineThreshold, %repairEngineThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairEngineThresholdLabel, % translate("Sec. p. Lap")

		updateRepairEngineState()

		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Change Compound")

		choices := map(["Never", "Tyre Temperature", "Weather"], "translate")

		changeTyreDropDown := inList(["Never", "Temperature", "Weather"], changeTyreDropDown)

		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%changeTyreDropDown% VchangeTyreDropDown gupdateChangeTyreState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VchangeTyreGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VchangeTyreThresholdEdit, %changeTyreThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VchangeTyreThresholdLabel, % translate("Degrees")

		updateChangeTyreState()

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x66 yp+30 w270 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Target Pressures")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x16 yp+30 w105 h20 Section, % translate("Deviation Threshold")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 VtyrePressureDeviationEdit gvalidateTyrePressureDeviation, %tyrePressureDeviationEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("PSI")

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Correction")
		Gui RES:Add, CheckBox, x126 yp-4 w17 h23 Checked%temperatureCorrectionCheck% VtemperatureCorrectionCheck, %temperatureCorrectionCheck%
		Gui RES:Add, Text, x147 yp+4 w200 h20, % translate("based on temperature trend")

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Correction")
		Gui RES:Add, CheckBox, x126 yp-4 w17 h23 Checked%setupPressureCompareCheck% VsetupPressureCompareCheck, %setupPressureCompareCheck%
		Gui RES:Add, Text, x147 yp+4 w200 h20, % translate("based on database values")

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Correction")
		Gui RES:Add, CheckBox, x126 yp-4 w17 h23 Checked%pressureLossCorrectionCheck% VpressureLossCorrectionCheck, %pressureLossCorrectionCheck%
		Gui RES:Add, Text, x147 yp+4 w200 h20, % translate("based on pressure loss")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x16 yp+30 w180 h120 Section, % translate("Dry Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontLeftEdit gvalidateTPDryFrontLeft, %tpDryFrontLeftEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontRightEdit gvalidateTPDryFrontRight, %tpDryFrontRightEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearLeftEdit gvalidateTPDryRearLeft, %tpDryRearLeftEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearRightEdit gvalidateTPDryRearRight, %tpDryRearRightEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x202 ys w180 h120, % translate("Wet / Intermediate Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontLeftEdit gvalidateTPWetFrontLeft, %tpWetFrontLeftEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontRightEdit gvalidateTPWetFrontRight, %tpWetFrontRightEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearLeftEdit gvalidateTPWetRearLeft, %tpWetRearLeftEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearRightEdit gvalidateTPWetRearRight, %tpWetRearRightEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui Tab, 1

		Gui RES:Add, Text, x16 y82 w90 h20 Section, % translate("Race Duration")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 Number VraceDurationEdit, %raceDurationEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range1-9999 0x80, %raceDurationEdit%
		Gui RES:Add, Text, x164 yp+4 w70 h20, % translate("Min.")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Avg. Lap Time")
		Gui RES:Add, Edit, x106 yp w50 h20 Limit3 Number VavgLaptimeEdit, %avgLaptimeEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range1-999 0x80, %avgLaptimeEdit%
		Gui RES:Add, Text, x164 yp+4 w90 h20, % translate("Sec.")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Fuel Consumption")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 VfuelConsumptionEdit gvalidateFuelConsumption, %fuelConsumptionEdit%
		Gui RES:Add, Text, x164 yp+4 w90 h20, % translate("Ltr.")

		Gui RES:Add, Text, x212 ys-2 w85 h23 +0x200, % translate("Formation")
		Gui RES:Add, CheckBox, x292 yp-1 w17 h23 Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")

		Gui RES:Add, Text, x212 yp+21 w85 h23 +0x200, % translate("Post Race")
		Gui RES:Add, CheckBox, x292 yp-1 w17 h23 Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x66 yp+52 w270 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Initial Setup")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Tyre Compound")

		choices := map(vTyreCompounds, "translate")

		spSetupTyreCompoundDropDown := inList(vTyreCompounds, spSetupTyreCompoundDropDown)

		if ((spSetupTyreCompoundDropDown == 0) && (choices.Length() > 0))
			spSetupTyreCompoundDropDown := 1

		Gui RES:Add, DropDownList, x106 yp w110 AltSubmit Choose%spSetupTyreCompoundDropDown% VspSetupTyreCompoundDropDown, % values2String("|", choices*)

		Gui RES:Add, Text, x16 yp+26 w90 h20, % translate("Start Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspSetupTyreSetEdit, %spSetupTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range0-99, %spSetupTyreSetEdit%

		Gui RES:Add, Text, x16 yp+24 w95 h20, % translate("Pitstop Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspPitstopTyreSetEdit, %spPitstopTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range0-99, %spPitstopTyreSetEdit%

		import := false

		for simulator, ignore in getConfigurationSectionValues(getControllerState(), "Simulators", Object())
			if new Application(simulator, kSimulatorConfiguration).isRunning() {
				import := true

				break
			}

		option := (import ? "yp-25" : "yp")

		Gui RES:Add, Button, x292 %option% w90 h23 gopenSessionDatabase, % translate("Setups...")

		if import
			Gui RES:Add, Button, x292 yp+25 w90 h23 gimportFromSimulation, % translate("Import")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x16 yp+30 w180 h120 Section, % translate("Dry Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryFrontLeftEdit gvalidateSPDryFrontLeft, %spDryFrontLeftEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryFrontRightEdit gvalidateSPDryFrontRight, %spDryFrontRightEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearLeftEdit gvalidateSPDryRearLeft, %spDryRearLeftEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearRightEdit gvalidateSPDryRearRight, %spDryRearRightEdit%
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x202 ys w180 h120 , % translate("Wet / Intermediate Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontLeftEdit gvalidateSPWetFrontLeft, %spWetFrontLeftEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontRightEdit gvalidateSPWetFrontRight, %spWetFrontRightEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearLeftEdit gvalidateSPWetRearLeft, %spWetRearLeftEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearRightEdit gvalidateSPWetRearRight, %spWetRearRightEdit%
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui Tab, 3

		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Race positions")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VextrapolationLapsEdit, %extrapolationLapsEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-9, %extrapolationLapsEdit%
		Gui RES:Add, Text, x184 yp+2 w290 h20, % translate("simulated future laps")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Overtake")
		Gui RES:Add, Text, x100 yp w28 h23 +0x200, % translate("Abs(")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit2 Number VovertakeDeltaEdit, %overtakeDeltaEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-99 0x80, %overtakeDeltaEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("/ laptime difference) Seconds")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Traffic")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit3 Number VtrafficConsideredEdit, %trafficConsideredEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-100 0x80, %trafficConsideredEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("% track length")

		Gui RES:Add, Text, x66 yp+28 w270 0x10

		Gui RES:Add, Text, x16 yp+15 w105 h23 +0x200, % translate("Pitstop Window")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit1 Number VpitstopStrategyWindowEdit, %pitstopStrategyWindowEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-9 0x80, %pitstopStrategyWindowEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Laps +/- around optimal lap")

		Gui RES:Add, Text, x16 yp+22 w105 h20 +0x200, % translate("Pitlane Delta")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80 Range0-99, %pitstopDeltaEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Drive through - Drive by)")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Tyre Service")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80 Range0-99, %pitstopTyreServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Change four tyres)")

		Gui RES:Add, DropDownList, x12 yp+21 w110 AltSubmit Choose%pitstopRefuelServiceRuleDropdown% VpitstopRefuelServiceRuleDropdown gchooseRefuelService, % values2String("|", map(["Refuel Fixed", "Refuel Dynamic"], "translate")*)

		Gui RES:Add, Edit, x126 yp w50 h20 VpitstopRefuelServiceEdit gvalidatePitstopRefuelService, %pitstopRefuelServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20 VpitstopRefuelServiceLabel, % translate(["Seconds", "Seconds (Refuel of 10 litres)"][pitstopRefuelServiceRuleDropdown])


		Gui RES:Add, Text, x16 yp+24 w85 h23, % translate("Service")
		Gui RES:Add, DropDownList, x126 yp-3 w100 AltSubmit Choose%pitstopServiceDropDown% vpitstopServiceDropDown, % values2String("|", map(["Simultaneous", "Sequential"], "translate")*)

		Gui RES:Add, Text, x16 yp+27 w85 h23 +0x200, % translate("Safety Fuel")
		Gui RES:Add, Edit, x126 yp w50 h20 Number Limit2 VsafetyFuelEdit, %safetyFuelEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range0-99, %safetyFuelEdit%
		Gui RES:Add, Text, x184 yp+2 w90 h20, % translate("Ltr.")

		if vTeamMode {
			Gui RES:Tab, 4

			Gui RES:Add, Text, x16 y82 w90 h23 +0x200, % translate("Server URL")

			if (!inList(serverURLs, serverURLEdit) && StrLen(serverURLEdit) > 0)
				serverURLs.Push(serverURLEdit)

			chosen := inList(serverURLs, serverURLEdit)
			if (!chosen && (serverURLs.Length() > 0))
				chosen := 1

			Gui RES:Add, ComboBox, x126 yp+1 w256 Choose%chosen% vserverURLEdit, % values2String("|", serverURLs*)

			Gui RES:Add, Text, x16 yp+23 w90 h23 +0x200, % translate("Session Token")
			Gui RES:Add, Edit, x126 yp w256 h21 vserverTokenEdit, %serverTokenEdit%
			Gui RES:Add, Button, x102 yp-1 w23 h23 Center +0x200 HWNDtokenButtonHandle gconnectServer
			setButtonIcon(tokenButtonHandle, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

			Gui RES:Add, Text, x16 yp+30 w90 h23 +0x200, % translate("Team / Driver")

			if teamIdentifier
				Gui RES:Add, DropDownList, x126 yp w126 AltSubmit Choose1 vteamDropDownMenu gchooseTeam, % teamName
			else
				Gui RES:Add, DropDownList, x126 yp w126 AltSubmit vteamDropDownMenu gchooseTeam

			if driverIdentifier
				Gui RES:Add, DropDownList, x256 yp w126 AltSubmit Choose1 vdriverDropDownMenu gchooseDriver, % driverName
			else
				Gui RES:Add, DropDownList, x256 yp w126 AltSubmit vdriverDropDownMenu gchooseDriver

			Gui RES:Add, Text, x16 yp+24 w90 h23 +0x200, % translate("Session")

			if sessionIdentifier
				Gui RES:Add, DropDownList, x126 yp w126 AltSubmit Choose1 vsessionDropDownMenu gchooseSession, % sessionName
			else
				Gui RES:Add, DropDownList, x126 yp w126 AltSubmit vsessionDropDownMenu gchooseSession

			Gui RES:Add, Text, x126 yp+30 r6 w256, % translate("Note: These settings define the access data for a team session. In order to join this session, it is still necessary for you to activate the team mode within the first lap of the session. Please consult the documentation for more information and detailed instructions.")
		}

		if getWindowPosition("Race Settings", x, y)
			Gui RES:Show, x%x% y%y%
		else
			Gui RES:Show

		loop {
			loop
				Sleep 1000
			until result

			if (result == kLoad) {
				result := false

				title := translate("Load Race Settings...")

				if (vSimulator && vCar && vTrack) {
					sessionDB := new SessionDatabase()

					directory := sessionDB.DatabasePath
					simulatorCode := sessionDB.getSimulatorCode(vSimulator)

					dirName = %directory%User\%simulatorCode%\%vCar%\%vTrack%\Race Settings

					FileCreateDir %dirName%
				}
				else
					dirName := kRaceSettingsFile

				Gui +OwnDialogs

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
				FileSelectFile file, 1, %dirName%, %title%, Settings (*.settings)
				OnMessage(0x44, "")

				if (file != "") {
					settingsOrCommand := readConfiguration(file)

					Gui RES:Destroy

					Goto restart
				}
			}
			else if (result == kSave) {
				result := false

				if (vSimulator && vCar && vTrack) {
					sessionDB := new SessionDatabase()

					directory := sessionDB.DatabasePath
					simulatorCode := sessionDB.getSimulatorCode(vSimulator)

					dirName = %directory%User\%simulatorCode%\%vCar%\%vTrack%\Race Settings

					FileCreateDir %dirName%

					fileName := (dirName . "\Race.settings")
				}
				else
					fileName := kRaceSettingsFile

				title := translate("Save Race Settings...")

				Gui +OwnDialogs

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
				FileSelectFile file, S17, %fileName%, %title%, Settings (*.settings)
				OnMessage(0x44, "")

				if (file != "") {
					if !InStr(file, ".")
						file := (file . ".settings")

					writeConfiguration(file, newSettings)
				}
			}
			else if (result == kOk) {
				settingsOrCommand := newSettings

				break
			}
			else if (result == kCancel)
				break
		}

		return result
	}
}

chooseRefuelService() {
	GuiControlGet pitstopRefuelServiceRuleDropdown

	GuiControl, , pitstopRefuelServiceLabel, % translate(["Seconds", "Seconds (Refuel of 10 litres)"][pitstopRefuelServiceRuleDropdown])
}

validateNumber(field) {
	local oldValue := %field%

	GuiControlGet %field%

	if %field% is not Number
	{
		%field% := oldValue

		GuiControl, , %field%, %oldValue%
	}
}

validateRepairSuspensionThreshold() {
	validateNumber("repairSuspensionThresholdEdit")
}

validateRepairBodyworkThreshold() {
	validateNumber("repairBodyworkThresholdEdit")
}

validateRepairEngineThreshold() {
	validateNumber("repairEngineThresholdEdit")
}

validateTPDryFrontLeft() {
	validateNumber("tpDryFrontLeftEdit")
}

validateTPDryFrontRight() {
	validateNumber("tpDryFrontRightEdit")
}

validateTPDryRearLeft() {
	validateNumber("tpDryRearLeftEdit")
}

validateTPDryRearRight() {
	validateNumber("tpDryRearRightEdit")
}

validateTPWetFrontLeft() {
	validateNumber("tpWetFrontLeftEdit")
}

validateTPWetFrontRight() {
	validateNumber("tpWetFrontRightEdit")
}

validateTPWetRearLeft() {
	validateNumber("tpWetRearLeftEdit")
}

validateTPWetRearRight() {
	validateNumber("tpWetRearRightEdit")
}

validateSPDryFrontLeft() {
	validateNumber("spDryFrontLeftEdit")
}

validateSPDryFrontRight() {
	validateNumber("spDryFrontRightEdit")
}

validateSPDryRearLeft() {
	validateNumber("spDryRearLeftEdit")
}

validateSPDryRearRight() {
	validateNumber("spDryRearRightEdit")
}

validateSPWetFrontLeft() {
	validateNumber("spWetFrontLeftEdit")
}

validateSPWetFrontRight() {
	validateNumber("spWetFrontRightEdit")
}

validateSPWetRearLeft() {
	validateNumber("spWetRearLeftEdit")
}

validateSPWetRearRight() {
	validateNumber("spWetRearRightEdit")
}

validateTyrePressureDeviation() {
	validateNumber("tyrePressureDeviationEdit")
}

validateFuelConsumption() {
	validateNumber("fuelConsumptionEdit")
}

validatePitstopRefuelService() {
	validateNumber("pitstopRefuelServiceEdit")
}

readSimulatorData(simulator) {
	local dataFile := kTempDirectory . simulator . " Data\Setup.data"
	local exePath := kBinariesDirectory . simulator . " SHM Provider.exe"
	local data, compound, compoundColor

	FileCreateDir %kTempDirectory%%simulator% Data

	try {
		RunWait %ComSpec% /c ""%exePath%" -Setup > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}

	data := readConfiguration(dataFile)

	deleteFile(dataFile)

	if (getConfigurationValue(data, "Car Data", "TyreCompound", kUndefined) = kUndefined) {
		compound := getConfigurationValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

		if (compound != kUndefined) {
			compound := new SessionDatabase().getTyreCompoundName(simulator, vCar, vTrack, compound, false)

			if compound {
				compoundColor := false

				splitCompound(compound, compound, compoundColor)

				setConfigurationValue(data, "Car Data", "TyreCompound", compound)
				setConfigurationValue(data, "Car Data", "TyreCompoundColor", compoundColor)
			}
		}
	}

	return data
}

openSessionDatabase() {
	local exePath := kBinariesDirectory . "Session Database.exe"
	local pid, options, ignore, arg

	try {
		options := []

		for ignore, arg in A_Args
			options.Push("""" . arg . """")

		options.Push("-Setup")

		Process Exist

		options.Push(ErrorLevel)

		options := values2String(A_Space, options*)

		Run "%exePath%" %options%, %kBinariesDirectory%, , pid
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Session Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

importFromSimulation(message := false, simulator := false, prefix := false, settings := false) {
	local candidate, ignore, data, compound, compoundColor

	if (message != "Import") {
		settings := false

		simulator := false

		for candidate, ignore in getConfigurationSectionValues(getControllerState(), "Simulators", Object())
			if new Application(candidate, kSimulatorConfiguration).isRunning() {
				simulator := candidate

				break
			}

		prefix := new SessionDatabase().getSimulatorCode(simulator)
	}

	data := readSimulatorData(prefix)

	if (getConfigurationSectionValues(data, "Setup Data", Object()).Count() > 0) {
		readTyreSetup(readConfiguration(kRaceSettingsFile))

		spPitstopTyreSetEdit := getConfigurationValue(data, "Setup Data", "TyreSet", spPitstopTyreSetEdit)
		spSetupTyreSetEdit := Max(1, spPitstopTyreSetEdit - 1)

		if settings {
			setConfigurationValue(settings, "Session Setup", "Tyre.Set", spSetupTyreSetEdit)
			setConfigurationValue(settings, "Session Setup", "Tyre.Set.Fresh", spPitstopTyreSetEdit)
		}
		else {
			GuiControl Text, spSetupTyreSetEdit, %spSetupTyreSetEdit%
			GuiControl Text, spPitstopTyreSetEdit, %spPitstopTyreSetEdit%
		}

		compound := getConfigurationValue(data, "Setup Data", "TyreCompound", spSetupTyreCompoundDropDown)

		if (compound = "Dry") {
			spDryFrontLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFL", spDryFrontLeftEdit)
			spDryFrontRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFR", spDryFrontRightEdit)
			spDryRearLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRL", spDryRearLeftEdit)
			spDryRearRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRR", spDryRearRightEdit)

			if settings {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", compoundColor)

				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))

				if (!vSilentMode && !inList(["rFactor 2", "Automobilista 2", "Project CARS 2"], simulator)) {
					message := (translate("Tyre setup imported: ") . translate(compound(compound, compoundColor)))

					showMessage(message . translate(", Set ") . spSetupTyreSetEdit . translate("; ")
							  . Round(spDryFrontLeftEdit, 1) . translate(", ") . Round(spDryFrontRightEdit, 1) . translate(", ")
							  . Round(spDryRearLeftEdit, 1) . translate(", ") . Round(spDryRearRightEdit, 1), false, "Information.png", 5000)
				}
			}
			else {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				GuiControl Choose, spSetupTyreCompoundDropDown, % inList(vTyreCompounds, compound(compound, compoundColor))

				GuiControl Text, spDryFrontLeftEdit, %spDryFrontLeftEdit%
				GuiControl Text, spDryFrontRightEdit, %spDryFrontRightEdit%
				GuiControl Text, spDryRearLeftEdit, %spDryRearLeftEdit%
				GuiControl Text, spDryRearRightEdit, %spDryRearRightEdit%
			}
		}
		else if ((compound = "Wet") || (compound = "Intermediate")) {
			spWetFrontLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFL", spWetFrontLeftEdit)
			spWetFrontRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFR", spWetFrontRightEdit)
			spWetRearLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRL", spWetRearLeftEdit)
			spWetRearRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRR", spWetRearRightEdit)

			if settings {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", compoundColor)

				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))

				if (!vSilentMode && !inList(["rFactor 2", "Automobilista 2", "Project CARS 2"], simulator)) {
					message := (translate("Tyre setup imported: ") . compound(compound, compoundColor))

					showMessage(message . translate("; ")
							  . Round(spWetFrontLeftEdit, 1) . translate(", ") . Round(spWetFrontRightEdit, 1) . translate(", ")
							  . Round(spWetRearLeftEdit, 1) . translate(", ") . Round(spWetRearRightEdit, 1), false, "Information.png", 5000)
				}
			}
			else {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				GuiControl Choose, spSetupTyreCompoundDropDown, % inList(vTyreCompounds, compound(compound, compoundColor))

				GuiControl Text, spWetFrontLeftEdit, %spWetFrontLeftEdit%
				GuiControl Text, spWetFrontRightEdit, %spWetFrontRightEdit%
				GuiControl Text, spWetRearLeftEdit, %spWetRearLeftEdit%
				GuiControl Text, spWetRearRightEdit, %spWetRearRightEdit%
			}
		}
	}
}

showRaceSettingsEditor() {
	local icon := kIconsDirectory . "Race Settings.ico"
	local index, fileName, settings

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Settings

	vSimulator := false
	vCar := false
	vTrack := false
	vWeather := "Dry"
	vAirTemperature := 23
	vTrackTemperature:= 27
	vCompound := false
	vCompoundColor := false

	index := 1

	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Simulator":
				vSimulator := A_Args[index + 1]
				index += 2
			case "-Car":
				vCar := A_Args[index + 1]
				index += 2
			case "-Track":
				vTrack := A_Args[index + 1]
				index += 2
			case "-Weather":
				vWeather := A_Args[index + 1]
				index += 2
			case "-AirTemperature":
				vAirTemperature := A_Args[index + 1]
				index += 2
			case "-TrackTemperature":
				vTrackTemperature := A_Args[index + 1]
				index += 2
			case "-Compound":
				vCompound := A_Args[index + 1]
				index += 2
			case "-CompoundColor":
				vCompoundColor := A_Args[index + 1]
				index += 2
			case "-Setup":
				vRequestorPID := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}

	if (vSimulator && vCar)
		vTyreCompounds := new SessionDatabase().getTyreCompounds(vSimulator, vCar, vTrack ? vTrack : "*")

	if (vAirTemperature <= 0)
		vAirTemperature := 23

	if (vTrackTemperature <= 0)
		vTrackTemperature := 27

	fileName := kRaceSettingsFile

	index := inList(A_Args, "-File")

	if index
		fileName := A_Args[index + 1]

	settings := readConfiguration(fileName)

	if inList(A_Args, "-Silent")
		vSilentMode := true

	if inList(A_Args, "-NoTeam")
		vTeamMode := false

	if inList(A_Args, "-Test")
		vTestMode := true

	index := inList(A_Args, "-Import")

	if index {
		importFromSimulation("Import", A_Args[index + 1], A_Args[index + 2], settings)

		writeConfiguration(fileName, settings)
	}
	else {
		registerMessageHandler("Setup", "functionMessageHandler")

		if (editRaceSettings(settings) = kOk) {
			writeConfiguration(fileName, settings)

			ExitApp 0
		}
	}

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

setTyrePressures(compound, compoundColor, flPressure, frPressure, rlPressure, rrPressure) {
	Gui RES:Default

	if (compound = "Wet") {
		spWetFrontLeftEdit := Round(flPressure, 1)
		spWetFrontRightEdit := Round(frPressure, 1)
		spWetRearLeftEdit := Round(rlPressure, 1)
		spWetRearRightEdit := Round(rrPressure, 1)

		GuiControl Text, spWetFrontLeftEdit, %spWetFrontLeftEdit%
		GuiControl Text, spWetFrontRightEdit, %spWetFrontRightEdit%
		GuiControl Text, spWetRearLeftEdit, %spWetRearLeftEdit%
		GuiControl Text, spWetRearRightEdit, %spWetRearRightEdit%
	}
	else {
		spDryFrontLeftEdit := Round(flPressure, 1)
		spDryFrontRightEdit := Round(frPressure, 1)
		spDryRearLeftEdit := Round(rlPressure, 1)
		spDryRearRightEdit := Round(rrPressure, 1)

		GuiControl Text, spDryFrontLeftEdit, %spDryFrontLeftEdit%
		GuiControl Text, spDryFrontRightEdit, %spDryFrontRightEdit%
		GuiControl Text, spDryRearLeftEdit, %spDryRearLeftEdit%
		GuiControl Text, spDryRearRightEdit, %spDryRearRightEdit%
	}

	return false
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceSettingsEditor()