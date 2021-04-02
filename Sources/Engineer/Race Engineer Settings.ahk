;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Settings Editor   ;;;
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
;@Ahk2Exe-ExeName Race Engineer Settings.exe


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

global kRaceEngineerSettingsFile = getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory)


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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

editSettings(ByRef settingsOrCommand) {
	static result
	static newSettings
	
	static lapsConsideredEdit
	static dampingFactorEdit
	static pitstopWarningEdit
	
	static tyrePressureDeviationEdit
	
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
	static safetyFuelEdit

restart:
	if (settingsOrCommand == kLoad)
		result := kLoad
	else if (settingsOrCommand == kCancel)
		result := kCancel
	else if ((settingsOrCommand == kSave) || (settingsOrCommand == kOk)) {
		Gui RES:Submit, NoHide
		
		newSettings := newConfiguration()
		
		if (!isFloat(tyrePressureDeviationEdit, dampingFactorEdit, fuelConsumptionEdit
				   , tpDryFrontLeftEdit, tpDryFrontRightEdit, tpDryRearLeftEdit, tpDryRearRightEdit
				   , tpWetFrontLeftEdit, tpWetFrontRightEdit, tpWetRearLeftEdit, tpWetRearRightEdit)
		 || !isNumber(repairSuspensionThresholdEdit, repairBodyworkThresholdEdit)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		
		setConfigurationValue(newSettings, "Race Settings", "Lap.History.Considered", lapsConsideredEdit)
		setConfigurationValue(newSettings, "Race Settings", "Lap.History.Damping", Round(dampingFactorEdit, 2))
		setConfigurationValue(newSettings, "Race Settings", "Lap.PitstopWarning", pitstopWarningEdit)
		
		setConfigurationValue(newSettings, "Race Settings", "Damage.Suspension.Repair"
							, ["Never", "Always", "Threshold", "Impact"][repairSuspensionDropDown])
		setConfigurationValue(newSettings, "Race Settings", "Damage.Suspension.Repair.Threshold", Round(repairSuspensionThresholdEdit, 1))
		
		setConfigurationValue(newSettings, "Race Settings", "Damage.Bodywork.Repair"
							, ["Never", "Always", "Threshold", "Impact"][repairBodyworkDropDown])
		setConfigurationValue(newSettings, "Race Settings", "Damage.Bodywork.Repair.Threshold", Round(repairBodyworkThresholdEdit, 1))
		
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Compound.Change"
							, ["Never", "Temperature", "Weather"][changeTyreDropDown])
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Compound.Change.Threshold", Round(changeTyreThresholdEdit, 1))
		
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Pressure.Deviation", tyrePressureDeviationEdit)
	
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Dry.Pressure.Target.FL", Round(tpDryFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Dry.Pressure.Target.FR", Round(tpDryFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Dry.Pressure.Target.RL", Round(tpDryRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Dry.Pressure.Target.RR", Round(tpDryRearRightEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Wet.Pressure.Target.FL", Round(tpWetFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Wet.Pressure.Target.FR", Round(tpWetFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Wet.Pressure.Target.RL", Round(tpWetRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Tyre.Wet.Pressure.Target.RR", Round(tpWetRearRightEdit, 1))
		
		setConfigurationValue(newSettings, "Race Settings", "Duration", raceDurationEdit * 60)
		setConfigurationValue(newSettings, "Race Settings", "Lap.AvgTime", avgLaptimeEdit)
		setConfigurationValue(newSettings, "Race Settings", "Fuel.AvgConsumption", Round(fuelConsumptionEdit, 1))
		setConfigurationValue(newSettings, "Race Settings", "Pitstop.Delta", pitstopDeltaEdit)
		setConfigurationValue(newSettings, "Race Settings", "Fuel.SafetyMargin", safetyFuelEdit)
		
		setConfigurationValue(newSettings, "Race Settings", "Lap.Formation", formationLapCheck)
		setConfigurationValue(newSettings, "Race Settings", "Lap.PostRace", postRaceLapCheck)
		
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Compound", ["Wet", "Dry"][spSetupTyreCompoundDropDown])
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Set", spSetupTyreSetEdit)
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Set.Fresh", spPitstopTyreSetEdit)
		
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
		setConfigurationValue(newSettings, "Race Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))
		
		if (settingsOrCommand == kOk)
			Gui RES:Destroy
		
		result := settingsOrCommand
	}
	else {
		result := false
	
		lapsConsideredEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.History.Considered", 5)
		dampingFactorEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.History.Damping", 0.2)
		pitstopWarningEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.PitstopWarning", 3)
		
		repairSuspensionDropDown := getConfigurationValue(settingsOrCommand, "Race Settings", "Damage.Suspension.Repair", "Always")
		repairSuspensionThresholdEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
		
		repairBodyworkDropDown := getConfigurationValue(settingsOrCommand, "Race Settings", "Damage.Bodywork.Repair", "Threshold")
		repairBodyworkThresholdEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Damage.Bodywork.Repair.Threshold", 0)
		
		changeTyreDropDown := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Compound.Change", "Never")
		changeTyreThresholdEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Compound.Change.Threshold", 0)
							
		tyrePressureDeviationEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Pressure.Deviation", 0.2)
		
		tpDryFrontLeftEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
		tpDryFrontRightEdit:= getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
		tpDryRearLeftEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
		tpDryRearRightEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
		tpWetFrontLeftEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
		tpWetFrontRightEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
		tpWetRearLeftEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
		tpWetRearRightEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)
		
		raceDurationEdit := Round(getConfigurationValue(settingsOrCommand, "Race Settings", "Duration", 0) / 60)
		avgLaptimeEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.AvgTime", 0)
		fuelConsumptionEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Fuel.AvgConsumption", 0.0)
		pitstopDeltaEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Pitstop.Delta", 0)
		safetyFuelEdit := getConfigurationValue(settingsOrCommand, "Race Settings", "Fuel.SafetyMargin", 4)
		
		formationLapCheck := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.Formation", true)
		postRaceLapCheck := getConfigurationValue(settingsOrCommand, "Race Settings", "Lap.PostRace", true)
		
		spSetupTyreCompoundDropDown := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Compound", "Dry")
		spSetupTyreSetEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Set", 1)
		spPitstopTyreSetEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Set.Fresh", 2)
		
		spDryFrontLeftEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)
		spDryFrontRightEdit:= getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)
		spDryRearLeftEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)
		spDryRearRightEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)
		spWetFrontLeftEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Wet.Pressure.FL", 28.5)
		spWetFrontRightEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Wet.Pressure.FR", 28.5)
		spWetRearLeftEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Wet.Pressure.RL", 28.5)
		spWetRearRightEdit := getConfigurationValue(settingsOrCommand, "Race Setup", "Tyre.Wet.Pressure.RR", 28.5)
		
		Gui RES:Default
			
		Gui RES:-Border ; -Caption
		Gui RES:Color, D0D0D0

		Gui RES:Font, Bold, Arial

		Gui RES:Add, Text, w388 Center gmoveSettingsEditor, % translate("Modular Simulator Controller System") 

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic, Arial

		Gui RES:Add, Text, YP+20 w388 Center, % translate("Race Engineer Settings")

		Gui RES:Font, Norm, Arial
				
		Gui RES:Add, Button, x228 y450 w80 h23 Default gacceptSettings, % translate("Ok")
		Gui RES:Add, Button, x316 y450 w80 h23 gcancelSettings, % translate("&Cancel")
		Gui RES:Add, Button, x8 y450 w77 h23 gloadSettings, % translate("&Load...")
		Gui RES:Add, Button, x90 y450 w77 h23 gsaveSettings, % translate("&Save...")
				
		tabs := map(["Settings", "Race"], "translate")

		Gui RES:Add, Tab3, x8 y48 w388 h395 -Wrap, % values2String("|", tabs*)

		Gui Tab, 1
		
		Gui RES:Add, Text, x16 y82 w105 h20 Section, % translate("Statistical Window")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit2 Number VlapsConsideredEdit, %lapsConsideredEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %lapsConsideredEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("Laps")

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Damping Factor")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 VdampingFactorEdit, %dampingFactorEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("p. Lap")

		Gui RES:Add, Text, x16 yp+24 w105 h20 Section, % translate("Pitstop Warning")
		Gui RES:Add, Edit, x126 yp-2 w50 h20 Limit1 Number VpitstopWarningEdit, %pitstopWarningEdit%
		Gui RES:Add, UpDown, x158 yp-2 w18 h20, %pitstopWarningEdit%
		Gui RES:Add, Text, x184 yp+2 w70 h20, % translate("Laps")

		Gui RES:Add, Text, x16 yp+30 w105 h23 +0x200, % translate("Repair Suspension")
		
		tabs := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairSuspensionDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairSuspensionDropDown)
	
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairSuspensionDropDown% VrepairSuspensionDropDown gupdateRepairSuspensionState, % values2String("|", tabs*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairSuspensionGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairSuspensionThresholdEdit, %repairSuspensionThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairSuspensionThresholdLabel, % translate("Sec. p. Lap")

		updateRepairSuspensionState()
		
		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Repair Bodywork")
		
		tabs := map(["Never", "Always", "Threshold", "Impact"], "translate")

		repairBodyworkDropDown := inList(["Never", "Always", "Threshold", "Impact"], repairBodyworkDropDown)
		
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%repairBodyworkDropDown% VrepairBodyworkDropDown gupdateRepairBodyworkState, % values2String("|", tabs*)
		Gui RES:Add, Text, x245 yp+2 w20 h20 VrepairBodyworkGreaterLabel, % translate(">")
		Gui RES:Add, Edit, x260 yp-2 w50 h20 VrepairBodyworkThresholdEdit, %repairBodyworkThresholdEdit%
		Gui RES:Add, Text, x318 yp+2 w90 h20 VrepairBodyworkThresholdLabel, % translate("Sec. p. Lap")

		updateRepairBodyworkState()
		
		Gui RES:Add, Text, x16 yp+24 w105 h23 +0x200, % translate("Change Compound")
		
		tabs := map(["Never", "Tyre Temperature", "Weather"], "translate")

		changeTyreDropDown := inList(["Never", "Temperature", "Weather"], changeTyreDropDown)
		
		Gui RES:Add, DropDownList, x126 yp w110 AltSubmit Choose%changeTyreDropDown% VchangeTyreDropDown gupdateChangeTyreState, % values2String("|", tabs*)
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

		Gui Tab, 2		
		
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

		Gui RES:Add, Text, x16 yp+22 w85 h20 +0x200, % translate("Pitstop Delta")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VpitstopDeltaEdit, %pitstopDeltaEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20 0x80, %pitstopDeltaEdit%
		Gui RES:Add, Text, x164 yp+4 w90 h20, % translate("Sec.")

		Gui RES:Add, Text, x212 ys-2 w85 h23 +0x200, % translate("Formation")
		Gui RES:Add, CheckBox, x292 yp-2 w17 h23 Checked%formationLapCheck% VformationLapCheck, %formationLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")
				
		Gui RES:Add, Text, x212 yp+22 w85 h23 +0x200, % translate("Post Race")
		Gui RES:Add, CheckBox, x292 yp-2 w17 h23 Checked%postRaceLapCheck% VpostRaceLapCheck, %postRaceLapCheck%
		Gui RES:Add, Text, x310 yp+4 w90 h20, % translate("Lap")
				
		Gui RES:Add, Text, x212 yp+22 w85 h23 +0x200, % translate("Safety Fuel")
		Gui RES:Add, Edit, x292 yp w50 h20 VsafetyFuelEdit, %safetyFuelEdit%
		Gui RES:Add, UpDown, x324 yp-2 w18 h20, %safetyFuelEdit%
		Gui RES:Add, Text, x350 yp+2 w90 h20, % translate("Ltr.")

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x66 yp+52 w270 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Initial Setup")

		Gui RES:Font, Norm, Arial

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Tyre Compound")
		
		tabs := map(["Wet", "Dry"], "translate")
		
		spSetupTyreCompoundDropDown := inList(["Wet", "Dry"], spSetupTyreCompoundDropDown)
		
		Gui RES:Add, DropDownList, x106 yp w80 AltSubmit Choose%spSetupTyreCompoundDropDown% VspSetupTyreCompoundDropDown, % values2String("|", tabs*)

		Gui RES:Add, Text, x16 yp+26 w90 h20, % translate("Start Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspSetupTyreSetEdit, %spSetupTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20, %spSetupTyreSetEdit%

		Gui RES:Add, Text, x16 yp+24 w95 h20, % translate("Pitstop Tyre Set")
		Gui RES:Add, Edit, x106 yp-2 w50 h20 Limit2 Number VspPitstopTyreSetEdit, %spPitstopTyreSetEdit%
		Gui RES:Add, UpDown, x138 yp-2 w18 h20, %spPitstopTyreSetEdit%
		
		Gui RES:Add, Button, x292 yp w90 h23 gimportFromSimulation, % translate("Import")

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

		Gui RES:Show, AutoSize Center
		
		Loop {
			Loop {
				Sleep 1000
			} until result
			
			if (result == kLoad) {
				result := false
				
				title := translate("Load Race Engineer Settings...")
				
				FileSelectFile file, 1, %kRaceEngineerSettingsFile%, %title%, Settings (*.settings)
			
				if (file != "") {
					settingsOrCommand := readConfiguration(file)
				
					Gui RES:Destroy
					
					Goto restart
				}
			}
			else if (result == kSave) {
				result := false
			
				title := translate("Save Race Engineer Settings...")
				
				FileSelectFile file, S, %kRaceEngineerSettingsFile%, %title%, Settings (*.settings)
			
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

readSharedMemory(dataFile) {
	exePath := kBinariesDirectory . "ACC SHM Reader.exe"
		
	try {
		RunWait %ComSpec% /c ""%exePath%" > "%dataFile%"", , Hide
		
		IniWrite ACC, %dataFile%, Race Data, Simulator
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start ACC SHM Reader (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start ACC SHM Reader (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
	
	return readConfiguration(dataFile)
}

importFromSimulation(message := false, code := false, settings := false) {
	accApplication := new Application("Assetto Corsa Competizione", kSimulatorConfiguration)
	
	if (message != "Import")
		settings := false
	
	if accApplication.isRunning() {
		data := readSharedMemory(kUserHomeDirectory . "Temp\" . code . " Data\Settings.data")
			
		spPitstopTyreSetEdit := getConfigurationValue(data, "Pitstop Data", "TyreSet", 0)
		spSetupTyreSetEdit := Max(1, spPitstopTyreSetEdit - 1)
		
		if settings {
			setConfigurationValue(settings, "Race Setup", "Tyre.Set", spSetupTyreSetEdit)
			setConfigurationValue(settings, "Race Setup", "Tyre.Set.Fresh", spPitstopTyreSetEdit)
		}
		else {
			GuiControl Text, spSetupTyreSetEdit, %spSetupTyreSetEdit%
			GuiControl Text, spPitstopTyreSetEdit, %spPitstopTyreSetEdit%
		}
		
		if (getConfigurationValue(data, "Car Data", "TyreCompound", "Dry") = "Dry") {
			spDryFrontLeftEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureFL", 26.1)
			spDryFrontRightEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureFR", 26.1)
			spDryRearLeftEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureRL", 26.1)
			spDryRearRightEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureRR", 26.1)
		
			if settings {
				setConfigurationValue(settings, "Race Setup", "Tyre.Compound", "Dry")
				
				setConfigurationValue(settings, "Race Setup", "Tyre.Dry.Pressure.FL", Round(spDryFrontLeftEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Dry.Pressure.FR", Round(spDryFrontRightEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Dry.Pressure.RL", Round(spDryRearLeftEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Dry.Pressure.RR", Round(spDryRearRightEdit, 1))
				
				showMessage("Tyre setup imported: Dry, Set " . spSetupTyreSetEdit . "; "
						  . Round(spDryFrontLeftEdit, 1) . ", " . Round(spDryFrontRightEdit, 1) . ", "
						  . Round(spDryRearLeftEdit, 1) . ", " . Round(spDryRearRightEdit, 1), false, "Information.png", 5000)
			}
			else {
				GuiControl Choose, spSetupTyreCompoundDropDown, 2
				
				GuiControl Text, spDryFrontLeftEdit, %spDryFrontLeftEdit%
				GuiControl Text, spDryFrontRightEdit, %spDryFrontRightEdit%
				GuiControl Text, spDryRearLeftEdit, %spDryRearLeftEdit%
				GuiControl Text, spDryRearRightEdit, %spDryRearRightEdit%
			}
		}
		else {
			spWetFrontLeftEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureFL", 28.5)
			spWetFrontRightEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureFR", 28.5)
			spWetRearLeftEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureRL", 28.5)
			spWetRearRightEdit := getConfigurationValue(data, "Pitstop Data", "TyrePressureRR", 28.5)
			
			if settings {
				setConfigurationValue(settings, "Race Setup", "Tyre.Compound", "Wet")
				
				setConfigurationValue(settings, "Race Setup", "Tyre.Wet.Pressure.FL", Round(spWetFrontLeftEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Wet.Pressure.FR", Round(spWetFrontRightEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Wet.Pressure.RL", Round(spWetRearLeftEdit, 1))
				setConfigurationValue(settings, "Race Setup", "Tyre.Wet.Pressure.RR", Round(spWetRearRightEdit, 1))
				
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

showRaceEngineerSettingsEditor() {
	icon := kIconsDirectory . "Artificial Intelligence Settings.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	settings := readConfiguration(kRaceEngineerSettingsFile)
	
	if ((A_Args.Length() > 0) && (A_Args[1] = "-Import")) {
		importFromSimulation("Import", A_Args[3], settings)
		
		writeConfiguration(kRaceEngineerSettingsFile, settings)
	}
	else if (editSettings(settings) == kOk)
		writeConfiguration(kRaceEngineerSettingsFile, settings)
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceEngineerSettingsEditor()