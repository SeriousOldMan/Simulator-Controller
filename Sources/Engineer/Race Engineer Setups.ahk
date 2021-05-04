;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Setups Tool       ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Wrench.ico
;@Ahk2Exe-ExeName Race Engineer Setups.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"

global kWeatherOptions = ["Dry", "Drizzle", "Light Rain", "Medium Rain", "Heavy Rain", "Thunderstorm"]
global kTyreCompounds = ["Wet", "Dry", "Dry (Red)", "Dry (White)", "Dry (Blue)"]


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global vControllerConfiguration = false
global vIncludeGlobalDatabase = false

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global airTemperatureEdit
global trackTemperatureEdit
global compoundDropDown

global flPressure1
global flPressure2
global flPressure3
global flPressure4
global flPressure5

global frPressure1
global frPressure2
global frPressure3
global frPressure4
global frPressure5

global rlPressure1
global rlPressure2
global rlPressure3
global rlPressure4
global rlPressure5

global rrPressure1
global rrPressure2
global rrPressure3
global rrPressure4
global rrPressure5


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

moveSetupsEditor() {
	moveByMouse("RES")
}

closeSetups() {
	showSetups(kClose)
}

openSetupsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database
}

getSimulatorName(simulatorCode) {
	for name, description in getConfigurationSectionValues(vControllerConfiguration, "Simulators", Object())
		if (simulatorCode = string2Values("|", description)[1])
			return name
		
	return false
}

getSimulatorCode(simulatorName) {
	return string2Values("|", getConfigurationValue(vControllerConfiguration, "Simulators", simulatorName))[1]
}

getEntries(filter := "*.*", option := "D") {
	result := []
	
	Loop Files, %kSetupDatabaseDirectory%local\%filter%, %option%
		result.Push(A_LoopFileName)
	
	if vIncludeGlobalDatabase
		Loop Files, %kSetupDatabaseDirectory%Global\%filter%, %option%
			if !inList(result, A_LoopFileName)
				result.Push(A_LoopFileName)
	
	return result
}

getSimulators() {
	simulators := []
	
	for simulator, ignore in getConfigurationSectionValues(vControllerConfiguration, "Simulators", Object())
		simulators.Push(simulator)
			
	return simulators
}

getCars(simulator) {
	code := getSimulatorCode(simulator)
	
	if code {
		return getEntries(code . "\*.*")
	}
	else
		return []
}

getTracks(simulator, car) {
	code := getSimulatorCode(simulator)
	
	if code {
		return getEntries(code . "\" . car . "\*.*")
	}
	else
		return []
}

getConditions(simulator, car, track) {
	return []
}

getPressures(simulator, car, track, weather, airTemperature, trackTemperature, compound) {
	return {FL: [], FR: [], RL: [], RR: []}
}

chooseSimulator() {
	GuiControlGet simulatorDropDown
	
	choices := getCars(simulatorDropDown)
	chosen := ((choices.Length() > 0) ? 1 : 0)
	
	GuiControl, , carDropDown, % "|" . values2String("|", choices*)
	GuiControl Choose, carDropDown, %chosen%
	
	chooseCar()
}

chooseCar() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	
	choices := getTracks(simulatorDropDown, carDropDown)
	chosen := ((choices.Length() > 0) ? 1 : 0)
	
	GuiControl, , trackDropDown, % "|" . values2String("|", choices*)
	GuiControl Choose, trackDropDown, %chosen%
	
	chooseTrack()
}

chooseTrack() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	conditions := getConditions(simulatorDropDown, carDropDown, trackDropDown)
	
	if (conditions.Length() > 0) {
		GuiControl Choose, weatherDropDown, % inList(kWeatherOptions, conditions[1])
		GuiControl Text, airTemperatureEdit, % conditions[1]
		GuiControl Text, trackTemperatureEdit, % conditions[2]
		
		GuiControl Choose, compoundDropDown, % inList(kTyreCompounds, conditions[3])
	}
	else {
		GuiControl Choose, weatherDropDown, 0
		GuiControl Text, airTemperatureEdit, 23
		GuiControl Text, trackTemperatureEdit, 27
		
		GuiControl Choose, compoundDropDown, 0
	}
	
	loadPressures()
}

loadPressures() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet weatherDropDown
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	GuiControlGet compoundDropDown
	
	for tyrePosition, pressures in getPressures(simulatorDropDown, carDropDown, trackDropDown, weatherDropDown, airTemperatureEdit, trackTemperatureEdit, compoundDropDown)
		for ignore, postfix in ["1", "2", "3", "4", "5"] {
			GuiControl Text, %tyrePosition%Pressure%postfix%, 0.0
		}
}

showSetups(command := false, simulator := false, car := false, track := false) {
	static result

	if (command == kClose) {
		Gui RES:Destroy
		
		result := command
	}
	else {
		result := false
		
		Gui RES:Default
			
		Gui RES:-Border ; -Caption
		Gui RES:Color, D0D0D0, Green

		Gui RES:Font, Bold, Arial

		Gui RES:Add, Text, w380 Center gmoveSetupsEditor, % translate("Modular Simulator Controller System") 

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Italic Underline, Arial

		Gui RES:Add, Text, YP+20 w380 cBlue Center gopenSetupsDocumentation, % translate("Race Engineer Setups")

		Gui RES:Font, Norm, Arial
				
		Gui RES:Add, Button, x160 y450 w80 h23 Default gcloseSetups, % translate("Close")
		
		Gui RES:Add, Text, x16 y60 w105 h23 +0x200, % translate("Simulator")
		
		choices := getSimulators()
		chosen := inList(choices, simulator)
		if (!chosen && (choices.Length() > 0)) {
			simulator := choices[1]
			chosen := 1
		}
		
		Gui RES:Add, DropDownList, x106 y60 w204 Choose%chosen% gchooseSimulator vsimulatorDropDown, % values2String("|", choices*)
		
		Gui RES:Add, Text, x16 y83 w105 h23 +0x200, % translate("Car / Track")
		
		if (simulator && car) {
			choices := getCars(simulator)
			chosen := inList(choices, car)
			if (!chosen && (choices.Length() > 0)) {
				car := choices[1]
				chosen := 1
			}
		}
		else {
			choices := []
			chosen := 0
		}
		
		Gui RES:Add, DropDownList, x106 y83 w100 Choose%chosen% gchooseCar vcarDropDown, % values2String("|", ["McL 720"]*)
		
		if (simulator && car && track) {
			choices := getTracks(simulator, car)
			chosen := inList(tracks, track)
			if (!chosen && (choices.Length() > 0)) {
				track := choices[1]
				chosen := 1
			}
		}
		else {
			choices := []
			chosen := 0
		}
		
		Gui RES:Add, DropDownList, x210 y83 w100 Choose%chosen% gchooseTrack vtrackDropDown, % values2String("|", ["Barcelona"]*)
		
		Gui RES:Add, Text, x16 y106 w105 h23 +0x200, % translate("Conditions")
		choices := map(kWeatherOptions, "translate")
		Gui RES:Add, DropDownList, x106 y106 w100 gloadPressures vweatherDropDown, % values2String("|", choices*)
		
		Gui RES:Add, Edit, x210 y106 w40 -Background gloadPressures vairTemperatureEdit, % "19"
		Gui RES:Add, UpDown, x242 yp-2 w18 h20, % "20"
		Gui RES:Font, c505050 s8
		Gui RES:Add, Text, x210 y126 w40 h23, % translate("Air")
		Gui RES:Font, Norm cBlack, Arial
		Gui RES:Add, Text, x250 y106 w20 h23 +0x200 Center, % translate("/")
		
		Gui RES:Add, Edit, x270 y106 w40 -Background gloadPressures vtrackTemperatureEdit, % "20"
		Gui RES:Add, UpDown, x302 yp-2 w18 h20, % "20"
		Gui RES:Add, Text, x318 y106 w60 h23 +0x200, % translate("Deg. Celsius")
		Gui RES:Font, c505050 s8
		Gui RES:Add, Text, x270 y126 w40 h23, % translate("Track")
		Gui RES:Font, Norm cBlack, Arial
		
		tabs := map(["Tyres"], "translate")

		Gui RES:Add, Tab3, x8 y139 w380 h304 -Wrap, % values2String("|", tabs*)

		Gui Tab, 1

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Compound")
		
		choices := map(kTyreCompounds, "translate")
		
		Gui RES:Add, DropDownList, x106 yp w100 gloadPressures vcompoundDropDown, % values2String("|", choices*)

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x62 yp+30 w262 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Pressures")

		Gui RES:Font, Norm, Arial
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vflPressure1, % "26.1"
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vflPressure2, % "26.2"
		Gui RES:Add, Edit, x214 yp w50 Center +Background cWhite vflPressure3, % "26.3"
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vflPressure4, % "26.4"
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vflPressure5, % "26.5"
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vfrPressure1, % "26.1"
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vfrPressure2, % "26.2"
		Gui RES:Add, Edit, x214 yp w50 Center +Background cWhite vfrPressure3, % "26.3"
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vfrPressure4, % "26.4"
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vfrPressure5, % "26.5"
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vrlPressure1, % "26.1"
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vrlPressure2, % "26.2"
		Gui RES:Add, Edit, x214 yp w50 Center +Background cWhite vrlPressure3, % "26.3"
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vrlPressure4, % "26.4"
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vrlPressure5, % "26.5"
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Right")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vrrPressure1, % "26.1"
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vrrPressure2, % "26.2"
		Gui RES:Add, Edit, x214 yp w50 Center +Background cWhite vrrPressure3, % "26.3"
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vrrPressure4, % "26.4"
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vrrPressure5, % "26.5"

		Gui RES:Show, AutoSize Center
		
		Loop {
			Loop {
				Sleep 1000
			} until result

			if (result == kClose)
				break
		}
	}
}

showRaceEngineerSetups() {
	icon := kIconsDirectory . "Wrench.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	vControllerConfiguration := getControllerConfiguration()
	
	showSetups(false, "Assetto Corsa Competizione")
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceEngineerSetups()