;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Settings Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Artificial Intelligence Settings.ico
;@Ahk2Exe-ExeName Race Settings.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Public Constant Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

global kLoad = "Load"
global kSave = "Save"
global kOk = "Ok"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceSettingsFile = getFileName("Race.settings", kUserConfigDirectory)


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global vSilentMode := kSilentMode
global vEditMode := false

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

moveSettingsEditor() {
	moveByMouse("RES")
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

openSettingsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings
}

isFloat(numbers*) {
	for ignore, value in numbers
		if value is not float
			return false
		
	return true
}

isNumber(numbers*) {
	for ignore, value in numbers
		if value is not number
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
	spSetupTyreCompoundDropDown := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
	
	color := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")
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

editSettings(ByRef settingsOrCommand) {
	static result
	static newSettings
	
	static pitstopWarningEdit
	static extrapolationLapsEdit
	static overtakeDeltaEdit
	static trafficConsideredEdit
	static pitstopStrategyWindowEdit
	
	static tyrePressureDeviationEdit
	static temperatureCorrectionCheck
	static setupPressureCompareCheck
	
	static tpDryFrontLeftEdit
	static tpDryFrontRightEdit
	static tpDryRearLeftEdit
	static tpDryRearRightEdit
	static tpWetFrontLeftEdit
	static tpWetFrontRightEdit
	static tpWetRearLeftEdit
	static tpWetRearRightEdit
	
	static raceDurationEdit
	static avgLaptimeEdit
	static formationLapCheck
	static postRaceLapCheck
	static fuelConsumptionEdit
	static pitstopDeltaEdit
	static pitstopTyreServiceEdit
	static pitstopRefuelServiceEdit
	static safetyFuelEdit

restart:
	if (settingsOrCommand == kLoad)
		result := kLoad
	else if (settingsOrCommand == kCancel)
		result := kCancel
	else if ((settingsOrCommand == kSave) || (settingsOrCommand == kOk)) {
		Gui RES:Submit, NoHide
		
		newSettings := newConfiguration()
		
		if (!isFloat(tyrePressureDeviationEdit, fuelConsumptionEdit, pitstopRefuelServiceEdit
				   , tpDryFrontLeftEdit, tpDryFrontRightEdit, tpDryRearLeftEdit, tpDryRearRightEdit
				   , tpWetFrontLeftEdit, tpWetFrontRightEdit, tpWetRearLeftEdit, tpWetRearRightEdit)
		 || !isNumber(repairSuspensionThresholdEdit, repairBodyworkThresholdEdit)
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
		setConfigurationValue(newSettings, "Session Settings", "Fuel.AvgConsumption", Round(fuelConsumptionEdit, 1))
		setConfigurationValue(newSettings, "Session Settings", "Fuel.SafetyMargin", safetyFuelEdit)
		
		setConfigurationValue(newSettings, "Session Settings", "Lap.Formation", formationLapCheck)
		setConfigurationValue(newSettings, "Session Settings", "Lap.PostRace", postRaceLapCheck)
		
		if (spSetupTyreCompoundDropDown == 1)
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Wet")
		else {
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound", "Dry")
			setConfigurationValue(newSettings, "Session Setup", "Tyre.Compound.Color", ["Black", "Red", "White", "Blue"][spSetupTyreCompoundDropDown - 1])
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
		setConfigurationValue(newSettings, "Strategy Settings", "Extrapolation.Laps", extrapolationLapsEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Overtake.Delta", overtakeDeltaEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Traffic.Considered", trafficConsideredEdit)
		setConfigurationValue(newSettings, "Strategy Settings", "Strategy.Window.Considered", pitstopStrategyWindowEdit)
		
		if (settingsOrCommand == kOk)
			Gui RES:Destroy
		
		result := settingsOrCommand
	}
	else {
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
		extrapolationLapsEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Extrapolation.Laps", 3)
		overtakeDeltaEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Overtake.Delta", 1)
		trafficConsideredEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Traffic.Considered", 5)
		pitstopStrategyWindowEdit := getConfigurationValue(settingsOrCommand, "Strategy Settings", "Strategy.Window.Considered", 2)
		
		readTyreSetup(settingsOrCommand)
		
		Gui RES:Default
			
		Gui RES:-Border ; -Caption
		Gui RES:Color, D0D0D0

		Gui RES:Font, Bold, Arial

		Gui RES:Add, Text, w388 Center gmoveSettingsEditor, % translate("Modular Simulator Controller System") 

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic Underline, Arial

		Gui RES:Add, Text, YP+20 w388 cBlue Center gopenSettingsDocumentation, % translate("Race Settings")

		Gui RES:Font, Norm, Arial
				
		Gui RES:Add, Button, x228 y450 w80 h23 Default gacceptSettings, % translate("Ok")
		Gui RES:Add, Button, x316 y450 w80 h23 gcancelSettings, % translate("&Cancel")
		Gui RES:Add, Button, x8 y450 w77 h23 gloadSettings, % translate("&Load...")
		Gui RES:Add, Button, x90 y450 w77 h23 gsaveSettings, % translate("&Save...")
				
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
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit, %repairSuspensionThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairSuspensionThresholdLabel, % translate("Sec. p. Lap")

		updateRepairSuspensionState()
		
		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Repair Bodywork")
		
		choices := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairBodyworkDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairBodyworkDropDown)
		
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairBodyworkDropDown% VrepairBodyworkDropDown gupdateRepairBodyworkState, % values2String("|", choices*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairBodyworkGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit, %repairBodyworkThresholdEdit%
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
		Gui RES:Add, Edit, x126 yp-2 w50 h20 VtyrePressureDeviationEdit, %tyrePressureDeviationEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("PSI")
		
		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Correction")
		Gui RES:Add, CheckBox, x126 yp-4 w17 h23 Checked%temperatureCorrectionCheck% VtemperatureCorrectionCheck, %temperatureCorrectionCheck%
		Gui RES:Add, Text, x147 yp+4 w200 h20, % translate("based on temperature trend")
		
		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Correction")
		Gui RES:Add, CheckBox, x126 yp-4 w17 h23 Checked%setupPressureCompareCheck% VsetupPressureCompareCheck, %setupPressureCompareCheck%
		Gui RES:Add, Text, x147 yp+4 w200 h20, % translate("based on setup database values")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, x16 yp+30 w180 h120 Section, % translate("Dry Tyres")
				
		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontLeftEdit, %tpDryFrontLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryFrontRightEdit, %tpDryFrontRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearLeftEdit, %tpDryRearLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VtpDryRearRightEdit, %tpDryRearRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial
				
		Gui RES:Add, GroupBox, x202 ys w180 h120, % translate("Wet Tyres")
				
		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontLeftEdit, %tpWetFrontLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetFrontRightEdit, %tpWetFrontRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearLeftEdit, %tpWetRearLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VtpWetRearRightEdit, %tpWetRearRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui Tab, 1		
		
		Gui RES:Add, Text, x16 y82 w90 h20 Section, % translate("Race Duration")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 Number VraceDurationEdit, %raceDurationEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range1-9999 0x80, %raceDurationEdit%
		Gui RES:Add, Text, x164 yp+4 w70 h20, % translate("Min.")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Avg. Laptime")
		Gui RES:Add, Edit, x106 yp w50 h20 Limit3 Number VavgLaptimeEdit, %avgLaptimeEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 Range1-999 0x80, %avgLaptimeEdit%
		Gui RES:Add, Text, x164 yp+4 w90 h20, % translate("Sec.")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Fuel Consumption")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 VfuelConsumptionEdit, %fuelConsumptionEdit%
		Gui RES:Add, Text, x164 yp+4 w90 h20, % translate("Ltr.")

		Gui RES:Add, Text, x212 ys-2 w85 h23 +0x200, % translate("Formation")
		Gui RES:Add, CheckBox, x292 yp-1 w17 h23 Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")
				
		Gui RES:Add, Text, x212 yp+22 w85 h23 +0x200, % translate("Post Race")
		Gui RES:Add, CheckBox, x292 yp-1 w17 h23 Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")
				
		Gui RES:Add, Text, x212 yp+22 w85 h23 +0x200, % translate("Safety Fuel")
		Gui RES:Add, Edit, x292 yp w50 h20 VsafetyFuelEdit, %safetyFuelEdit%
		Gui RES:Add, UpDown, x324 yp-2 w18 h20, %safetyFuelEdit%
		Gui RES:Add, Text, x350 yp+2 w90 h20, % translate("Ltr.")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x66 yp+28 w270 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Initial Setup")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Tyre Compound")
		
		choices := map(["Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"], "translate")
		
		spSetupTyreCompoundDropDown := inList(["Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"], spSetupTyreCompoundDropDown)
		
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

		if !vEditMode
		Gui RES:Add, Button, x292 %option% w90 h23 gopenSetupDatabase, % translate("Setups...")
		
		if import
			Gui RES:Add, Button, x292 yp+25 w90 h23 gimportFromSimulation, % translate("Import")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, GroupBox, x16 yp+30 w180 h120 Section, % translate("Dry Tyres")
				
		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryFrontLeftEdit, %spDryFrontLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryFrontRightEdit, %spDryFrontRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearLeftEdit, %spDryRearLeftEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x26 yp+24 w75 h20 , % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit4 VspDryRearRightEdit, %spDryRearRightEdit%
		; Gui RES:Add, UpDown, x138 yp-2 w18 h20
		Gui RES:Add, Text, x164 yp+2 w30 h20, % translate("PSI")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial
				
		Gui RES:Add, GroupBox, x202 ys w180 h120 , % translate("Wet Tyres")
				
		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontLeftEdit, %spWetFrontLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Front Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetFrontRightEdit, %spWetFrontRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Left")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearLeftEdit, %spWetRearLeftEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui RES:Add, Text, x212 yp+24 w75 h20, % translate("Rear Right")
		Gui RES:Add, Edit, x292 yp-2 w50 h20 Limit4 VspWetRearRightEdit, %spWetRearRightEdit%
		; Gui RES:Add, UpDown, x324 yp-2 w18 h20
		Gui RES:Add, Text, x350 yp+2 w30 h20, % translate("PSI")

		Gui Tab, 3
		
		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Race positions")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VextrapolationLapsEdit, %extrapolationLapsEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %extrapolationLapsEdit%
		Gui RES:Add, Text, x184 yp+2 w290 h20, % translate("simulated future laps")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Overtake")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit3 Number VovertakeDeltaEdit, %overtakeDeltaEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-999 0x80, %overtakeDeltaEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("additional seconds for each passed car")

		Gui RES:Add, Text, x16 yp+20 w85 h23 +0x200, % translate("Traffic")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit3 Number VtrafficConsideredEdit, %trafficConsideredEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-100 0x80, %trafficConsideredEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("% track length")

		Gui RES:Add, Text, x66 yp+28 w270 0x10

		Gui RES:Add, Text, x16 yp+15 w105 h23 +0x200, % translate("Pitstop Window")
		Gui RES:Add, Edit, x126 yp w50 h20 Limit1 Number VpitstopStrategyWindowEdit, %pitstopStrategyWindowEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 Range1-9 0x80, %pitstopStrategyWindowEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Laps +/- around optimal lap")

		Gui RES:Add, Text, x16 yp+22 w105 h20 +0x200, % translate("Pitstop Delta")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80, %pitstopDeltaEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Drive through - Drive by)")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Tyre Service")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VpitstopTyreServiceEdit, %pitstopTyreServiceEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20 0x80, %pitstopTyreServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Change four tyres)")

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Refuel Service")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 VpitstopRefuelServiceEdit, %pitstopRefuelServiceEdit%
		Gui RES:Add, Text, x184 yp+4 w290 h20, % translate("Seconds (Refuel of 10 litres)")

		Gui RES:Show, AutoSize Center
		
		Loop {
			Loop {
				Sleep 1000
			} until result
			
			if (result == kLoad) {
				result := false
				
				title := translate("Load Race Settings...")
				
				FileSelectFile file, 1, %kRaceSettingsFile%, %title%, Settings (*.settings)
			
				if (file != "") {
					settingsOrCommand := readConfiguration(file)
				
					Gui RES:Destroy
					
					Goto restart
				}
			}
			else if (result == kSave) {
				result := false
			
				title := translate("Save Race Settings...")
				
				FileSelectFile file, S, %kRaceSettingsFile%, %title%, Settings (*.settings)
			
				if (file != "")
					writeConfiguration(file, newSettings)
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

readSimulatorData(simulator) {
	dataFile := kTempDirectory . simulator . " Data\Setup.data"
	exePath := kBinariesDirectory . simulator . " SHM Reader.exe"
	
	FileCreateDir %kTempDirectory%%simulator% Data
	
	try {
		RunWait %ComSpec% /c ""%exePath%" -Setup > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Reader ("), {simulator: simulator, protocol: "SHM"}) . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Reader (%exePath%) - please check the configuration..."), {simulator: simulator, protocol: "SHM", exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
	
	return readConfiguration(dataFile)
}

openSetupDatabase() {
	exePath := kBinariesDirectory . "Setup Database.exe"
	
	try {
		options := []
		
		for ignore, arg in A_Args
			options.Push("""" . arg . """")
		
		options.Push("-Settings")
		
		Process Exist
		
		options.Push(ErrorLevel)
		
		options := values2String(A_Space, options*)
		
		Run "%exePath%" %options%, %kBinariesDirectory%, , pid
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Setup Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Setup Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
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
		
		switch simulator {
			case "Assetto Corsa Competizione":
				prefix := "ACC"
			case "RaceRoom Racing Experience":
				prefix := "R3E"
			case "rFactor 2":
				prefix := "RF2"
			default:
				return
		}
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
		
		if (getConfigurationValue(data, "Setup Data", "TyreCompound", spSetupTyreCompoundDropDown) != "Wet") {
			spDryFrontLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFL", spDryFrontLeftEdit)
			spDryFrontRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFR", spDryFrontRightEdit)
			spDryRearLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRL", spDryRearLeftEdit)
			spDryRearRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRR", spDryRearRightEdit)
		
			if settings {
				color := getConfigurationValue(data, "Setup Data", "TyreCompoundColor", "Black")
				
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", "Dry")
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", color)
				
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))
				
				if (!vSilentMode && (simulator != "rFactor 2") && (simulator != "Automobilista 2")) {
					message := ((color = "Black") ? "Tyre setup imported: Dry" : "Tyre setup imported: Dry (" . color . ")")
					
					showMessage(message . ", Set " . spSetupTyreSetEdit . "; "
							  . Round(spDryFrontLeftEdit, 1) . ", " . Round(spDryFrontRightEdit, 1) . ", "
							  . Round(spDryRearLeftEdit, 1) . ", " . Round(spDryRearRightEdit, 1), false, "Information.png", 5000)
				}
			}
			else {
				choice := 2
			
				switch getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black") {
					case "Black":
						GuiControl Choose, spSetupTyreCompoundDropDown, 2
					case "Red":
						GuiControl Choose, spSetupTyreCompoundDropDown, 3
					case "White":
						GuiControl Choose, spSetupTyreCompoundDropDown, 4
					case "Blue":
						GuiControl Choose, spSetupTyreCompoundDropDown, 5
					default:
						Throw "Unknow tyre compound color detected in importFromSimulation..."
				}
				
				GuiControl Text, spDryFrontLeftEdit, %spDryFrontLeftEdit%
				GuiControl Text, spDryFrontRightEdit, %spDryFrontRightEdit%
				GuiControl Text, spDryRearLeftEdit, %spDryRearLeftEdit%
				GuiControl Text, spDryRearRightEdit, %spDryRearRightEdit%
			}
		}
		else {
			spWetFrontLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFL", spWetFrontLeftEdit)
			spWetFrontRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureFR", spWetFrontRightEdit)
			spWetRearLeftEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRL", spWetRearLeftEdit)
			spWetRearRightEdit := getConfigurationValue(data, "Setup Data", "TyrePressureRR", spWetRearRightEdit)
			
			if settings {
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", "Wet")
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black"))
				
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
				setConfigurationValue(settings, "Session Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))
				
				if (!vSilentMode && (simulator != "rFactor 2") && (simulator != "Automobilista 2"))
					showMessage("Tyre setup imported: Wet; "
							  . Round(spWetFrontLeftEdit, 1) . ", " . Round(spWetFrontRightEdit, 1) . ", "
							  . Round(spWetRearLeftEdit, 1) . ", " . Round(spWetRearRightEdit, 1), false, "Information.png", 5000)
			}
			else {
				GuiControl Choose, spSetupTyreCompoundDropDown, 1
				
				GuiControl Text, spWetFrontLeftEdit, %spWetFrontLeftEdit%
				GuiControl Text, spWetFrontRightEdit, %spWetFrontRightEdit%
				GuiControl Text, spWetRearLeftEdit, %spWetRearLeftEdit%
				GuiControl Text, spWetRearRightEdit, %spWetRearRightEdit%
			}
		}
	}
}

showRaceSettingsEditor() {
	icon := kIconsDirectory . "Artificial Intelligence Settings.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	fileName := kRaceSettingsFile
	
	index := inList(A_Args, "-File")
	
	if index {
		fileName := A_Args[index + 1]
		
		vEditMode := true
	}
	
	settings := readConfiguration(fileName)
	
	if inList(A_Args, "-Silent")
		vSilentMode := true
	
	index := inList(A_Args, "-Import")
	
	if index {
		importFromSimulation("Import", A_Args[index + 1], A_Args[index + 2], settings)
		
		writeConfiguration(fileName, settings)
	}
	else {
		registerEventHandler("Setup", "handleSetupRemoteCalls")
	
		if (editSettings(settings) = kOk) {
			writeConfiguration(fileName, settings)
	
			ExitApp %vEditMode%
		}
	}
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

setTyrePressures(compound, flPressure, frPressure, rlPressure, rrPressure) {
	Gui RES:Default
			
	if InStr(compound, "Wet") {
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
}

handleSetupRemoteCalls(event, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
	
		return withProtection(data[1], string2Values(";", data[2])*)
	}
	else
		return withProtection(data)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceSettingsEditor()