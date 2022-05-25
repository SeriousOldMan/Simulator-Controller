;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Settings Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Race Settings.ico
;@Ahk2Exe-ExeName Race Settings.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk
#Include Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLoad = "Load"
global kSave = "Save"
global kOk = "Ok"
global kCancel = "Cancel"
global kConnect = "Connect"
global kUpdate = "Update"

global kRaceSettingsFile = getFileName("Race.settings", kUserConfigDirectory)


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

global changeTyreDropDown
global changeTyreThresholdEdit
global changeTyreGreaterLabel
global changeTyreThresholdLabel

global spSetupTyreCompoundDropDown
global spSetupTyreSetEdit
global spPitstopTyreSetEdit

global fuelConsumptionEdit
global tyrePressureDeviationEdit
global pitstopRefuelServiceEdit

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

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
}

loginDialog(connectorOrCommand := false, teamServerURL := false) {
	static result := false

	static nameEdit := ""
	static passwordEdit := ""

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false
		window := "TSL"

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
				connectorOrCommand.Connect(teamServerURL)

				return connectorOrCommand.Login(nameEdit, passwordEdit)
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

moveSettingsEditor() {
	moveByMouse("RES")
}

computeDriverName(forName, surName, nickName) {
	name := ""

	if (forName != "")
		name .= (forName . A_Space)

	if (surName != "")
		name .= (surName . A_Space)

	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))

	return Trim(name)
}

loadSettings() {
	editSettings(kLoad)
}

saveSettings() {
	editSettings(kSave)
}

acceptSettings() {
	editSettings(kOk)
}

cancelSettings() {
	editSettings(kCancel)
}

connectServer() {
	editSettings(kConnect)
}

chooseTeam() {
	editSettings(kUpdate, "Team")
}

chooseDriver() {
	editSettings(kUpdate, "Driver")
}

chooseSession() {
	editSettings(kUpdate, "Session")
}

openSettingsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings
}

isPositiveFloat(numbers*) {
	for ignore, value in numbers
		if value is not float
			return false
		else if (value < 0)
			return false

	return true
}

isPositiveNumber(numbers*) {
	for ignore, value in numbers
		if value is not number
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
	if (vCompound && vCompoundColor) {
		spSetupTyreCompoundDropDown := vCompound
		color := vCompoundColor
	}
	else {
		spSetupTyreCompoundDropDown := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
		color := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")
	}

	if (color != "Black")
		spSetupTyreCompoundDropDown := spSetupTyreCompoundDropDown . " (" . color . ")"

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
	value := getConfigurationValue(data, newSection, key, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}

parseObject(properties) {
	result := {}

	properties := StrReplace(properties, "`r", "")

	Loop Parse, properties, `n
	{
		property := string2Values("=", A_LoopField)

		result[property[1]] := property[2]
	}

	return result
}

loadTeams(connector) {
	teams := {}

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
	drivers := {}

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
	sessions := {}

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
				; ignore
			}
		}
	}

	return sessions
}

getKeys(map) {
	keys := []

	for key, ignore in map
		keys.Push(key)

	return keys
}

getValues(map) {
	values := []

	for ignore, value in map
		values.Push(value)

	return values
}

editSettings(ByRef settingsOrCommand, arguments*) {
	static result
	static newSettings

	static pitstopWarningEdit
	static extrapolationLapsEdit
	static overtakeDeltaEdit
	static trafficConsideredEdit
	static pitstopStrategyWindowEdit

	static temperatureCorrectionCheck
	static setupPressureCompareCheck

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
					Throw exception
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
				if (connector.Connect(serverURLEdit, serverTokenEdit) > 0) {
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

					editSettings(kUpdate, "Team")

					showMessage(translate("Successfully connected to the team server."))
				}
				else
					Throw Exception("Invalid or missing token...")
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

		if (!isPositiveFloat(tyrePressureDeviationEdit, pitstopRefuelServiceEdit
						   , tpDryFrontLeftEdit, tpDryFrontRightEdit, tpDryRearLeftEdit, tpDryRearRightEdit
						   , tpWetFrontLeftEdit, tpWetFrontRightEdit, tpWetRearLeftEdit, tpWetRearRightEdit
						   , spDryFrontLeftEdit, spDryFrontRightEdit, spDryRearLeftEdit, spDryRearRightEdit
						   , spWetFrontLeftEdit, spWetFrontRightEdit, spWetRearLeftEdit, spWetRearRightEdit)
		 || !isPositiveNumber(fuelConsumptionEdit, repairSuspensionThresholdEdit, repairBodyworkThresholdEdit)
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

		setConfigurationValue(newSettings, "Session Settings", "Tyre.Compound.Change"
							, ["Never", "Temperature", "Weather"][changeTyreDropDown])
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Compound.Change.Threshold", Round(changeTyreThresholdEdit, 1))

		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Deviation", tyrePressureDeviationEdit)
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Temperature", temperatureCorrectionCheck)
		setConfigurationValue(newSettings, "Session Settings", "Tyre.Pressure.Correction.Setup", setupPressureCompareCheck)

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

		if (spSetupTyreCompoundDropDown == 1) {
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Wet")
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound.Color", "Black")
		}
		else {
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Dry")
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound.Color", kQualifiedTyreCompoundColors[spSetupTyreCompoundDropDown])
		}

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

					Throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
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

		changeTyreDropDown := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never")
		changeTyreThresholdEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Compound.Change.Threshold", 0)

		tyrePressureDeviationEdit := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2)
		temperatureCorrectionCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Temperature", true)
		setupPressureCompareCheck := getDeprecatedConfigurationValue(settingsOrCommand, "Session Settings", "Race Settings", "Tyre.Pressure.Correction.Setup", true)

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
		}

		Gui RES:Default

		Gui RES:-Border ; -Caption
		Gui RES:Color, D0D0D0, D8D8D8

		Gui RES:Font, Bold, Arial

		Gui RES:Add, Text, w388 Center gmoveSettingsEditor, % translate("Modular Simulator Controller System")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic Underline, Arial

		Gui RES:Add, Text, YP+20 w388 cBlue Center gopenSettingsDocumentation, % translate("Race Settings")

		Gui RES:Font, Norm, Arial

		if !vTestMode {
			Gui RES:Add, Button, x228 y450 w80 h23 Default gacceptSettings, % translate("Ok")
			Gui RES:Add, Button, x316 y450 w80 h23 gcancelSettings, % translate("&Cancel")
		}
		else
			Gui RES:Add, Button, x316 y450 w80 h23 Default gcancelSettings, % translate("Close")

		Gui RES:Add, Button, x8 y450 w77 h23 gloadSettings, % translate("&Load...")
		Gui RES:Add, Button, x90 y450 w77 h23 gsaveSettings, % translate("&Save...")

		if vTeamMode
			tabs := map(["Race", "Pitstop", "Strategy", "Team"], "translate")
		else
			tabs := map(["Race", "Pitstop", "Strategy"], "translate")

		Gui RES:Add, Tab3, x8 y48 w388 h395 -Wrap, % values2String("|", tabs*)

		Gui Tab, 2

		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Pitstop Warning")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VpitstopWarningEdit, %pitstopWarningEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %pitstopWarningEdit%
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

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x16 yp+30 w180 h120 Section, % translate("Dry Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontLeftEdit gvalidateTPDryFrontLeft, %tpDryFrontLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontRightEdit gvalidateTPDryFrontRight, %tpDryFrontRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearLeftEdit gvalidateTPDryRearLeft, %tpDryRearLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearRightEdit gvalidateTPDryRearRight, %tpDryRearRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x202 ys w180 h120, % translate("Wet Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontLeftEdit gvalidateTPWetFrontLeft, %tpWetFrontLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontRightEdit gvalidateTPWetFrontRight, %tpWetFrontRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearLeftEdit gvalidateTPWetRearLeft, %tpWetRearLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearRightEdit gvalidateTPWetRearRight, %tpWetRearRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
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

		choices := map(kQualifiedTyreCompounds, "translate")

		spSetupTyreCompoundDropDown := inList(kQualifiedTyreCompounds, spSetupTyreCompoundDropDown)

		Gui RES:Add, DropDownList, x106 yp w100 AltSubmit Choose%spSetupTyreCompoundDropDown% VspSetupTyreCompoundDropDown, % values2String("|", choices*)

		Gui RES:Add, Text, x16 yp+26 w90 h20, % translate("Start Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspSetupTyreSetEdit, %spSetupTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20, %spSetupTyreSetEdit%

		Gui RES:Add, Text, x16 yp+24 w95 h20, % translate("Pitstop Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspPitstopTyreSetEdit, %spPitstopTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20, %spPitstopTyreSetEdit%

		import := false

		for simulator, ignore in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object())
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
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryFrontRightEdit gvalidateSPDryFrontRight, %spDryFrontRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearLeftEdit gvalidateSPDryRearLeft, %spDryRearLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearRightEdit gvalidateSPDryRearRight, %spDryRearRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, -Theme x202 ys w180 h120 , % translate("Wet Tyres")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontLeftEdit gvalidateSPWetFrontLeft, %spWetFrontLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontRightEdit gvalidateSPWetFrontRight, %spWetFrontRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearLeftEdit gvalidateSPWetRearLeft, %spWetRearLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearRightEdit gvalidateSPWetRearRight, %spWetRearRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui Tab, 3

		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Race positions")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VextrapolationLapsEdit, %extrapolationLapsEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %extrapolationLapsEdit%
		Gui RES:Add, Text, x184 yp+2 w290 h20, % translate("simulated future laps")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Overtake")
		Gui RES:Add, Text, x100 yp w28 h23 +0x200, % translate("Abs(")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit3 Number VovertakeDeltaEdit, %overtakeDeltaEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-999 0x80, %overtakeDeltaEdit%
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
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80, %pitstopDeltaEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Drive through - Drive by)")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Tyre Service")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80, %pitstopTyreServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Change four tyres)")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Refuel Service")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 VpitstopRefuelServiceEdit gvalidatePitstopRefuelService, %pitstopRefuelServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Refuel of 10 litres)")

		Gui RES:Add, Text, x16 yp+24 w85 h23, % translate("Service")
		Gui RES:Add, DropDownList, x126 yp-3 w100 AltSubmit Choose1 vpitstopServiceDropDown, % values2String("|", map(["Simultaneous", "Sequential"], "translate")*)

		Gui RES:Add, Text, x16 yp+27 w85 h23 +0x200, % translate("Safety Fuel")
		Gui RES:Add, Edit, x126 yp w50 h20 VsafetyFuelEdit, %safetyFuelEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %safetyFuelEdit%
		Gui RES:Add, Text, x184 yp+2 w90 h20, % translate("Ltr.")

		if vTeamMode {
			Gui RES:Tab, 4

			Gui RES:Add, Text, x16 y82 w90 h23 +0x200, % translate("Server URL")
			Gui RES:Add, Edit, x126 yp+1 w256 vserverURLEdit, %serverURLEdit%

			Gui RES:Add, Text, x16 yp+23 w90 h23 +0x200, % translate("Access Token")
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

		Gui RES:Show, AutoSize Center

		Loop {
			Loop {
				Sleep 1000
			} until result

			if (result == kLoad) {
				result := false

				title := translate("Load Race Settings...")

				if (vSimulator && vCar && vTrack) {
					simulatorCode := new SessionDatabase().getSimulatorCode(vSimulator)

					dirName = %kDatabaseDirectory%User\%simulatorCode%\%vCar%\%vTrack%\Race Settings

					FileCreateDir %dirName%
				}
				else
					dirName := kRaceSettingsFile

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
					simulatorCode := new SessionDatabase().getSimulatorCode(vSimulator)

					dirName = %kDatabaseDirectory%User\%simulatorCode%\%vCar%\%vTrack%\Race Settings

					FileCreateDir %dirName%

					fileName := (dirName . "\Race.settings")
				}
				else
					fileName := kRaceSettingsFile

				title := translate("Save Race Settings...")

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

validateNumber(field) {
	oldValue := %field%

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
	dataFile := kTempDirectory . simulator . " Data\Setup.data"
	exePath := kBinariesDirectory . simulator . " SHM Provider.exe"

	FileCreateDir %kTempDirectory%%simulator% Data

	try {
		RunWait %ComSpec% /c ""%exePath%" -Setup > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}

	return readConfiguration(dataFile)
}

openSessionDatabase() {
	exePath := kBinariesDirectory . "Session Database.exe"

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
	if (message != "Import") {
		settings := false

		simulator := false

		for candidate, ignore in getConfigurationSectionValues(getControllerConfiguration(), "Simulators", Object())
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
				color := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", color)

				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))

				if (!vSilentMode && (simulator != "rFactor 2") && (simulator != "Automobilista 2")) {
					message := (translate("Tyre setup imported: ") . translate(((color = "Black") ? compound : " (" . color . ")")))

					showMessage(message . translate(", Set ") . spSetupTyreSetEdit . translate("; ")
							  . Round(spDryFrontLeftEdit, 1) . translate(", ") . Round(spDryFrontRightEdit, 1) . translate(", ")
							  . Round(spDryRearLeftEdit, 1) . translate(", ") . Round(spDryRearRightEdit, 1), false, "Information.png", 5000)
				}
			}
			else {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				if (compoundColor = "Black")
					GuiControl Choose, spSetupTyreCompoundDropDown, % inList(kQualifiedTyreCompounds, compound)
				else
					GuiControl Choose, spSetupTyreCompoundDropDown, % inList(kQualifiedTyreCompounds, compound . " (" . compoundColor . ")")

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
				color := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", compound)

				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))

				if (!vSilentMode && (simulator != "rFactor 2") && (simulator != "Automobilista 2")) {
					message := (translate("Tyre setup imported: ") . translate(((color = "Black") ? compound : " (" . color . ")")))

					showMessage(message . translate("; ")
							  . Round(spWetFrontLeftEdit, 1) . translate(", ") . Round(spWetFrontRightEdit, 1) . translate(", ")
							  . Round(spWetRearLeftEdit, 1) . translate(", ") . Round(spWetRearRightEdit, 1), false, "Information.png", 5000)
				}
			}
			else {
				compoundColor := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")

				if (compoundColor = "Black")
					GuiControl Choose, spSetupTyreCompoundDropDown, % inList(kQualifiedTyreCompounds, compound)
				else
					GuiControl Choose, spSetupTyreCompoundDropDown, % inList(kQualifiedTyreCompounds, compound . " (" . compoundColor . ")")

				GuiControl Text, spWetFrontLeftEdit, %spWetFrontLeftEdit%
				GuiControl Text, spWetFrontRightEdit, %spWetFrontRightEdit%
				GuiControl Text, spWetRearLeftEdit, %spWetRearLeftEdit%
				GuiControl Text, spWetRearRightEdit, %spWetRearRightEdit%
			}
		}
	}
}

showRaceSettingsEditor() {
	icon := kIconsDirectory . "Race Settings.ico"

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
		registerEventHandler("Setup", "functionEventHandler")

		if (editSettings(settings) = kOk) {
			writeConfiguration(fileName, settings)

			ExitApp 0
		}
	}

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
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