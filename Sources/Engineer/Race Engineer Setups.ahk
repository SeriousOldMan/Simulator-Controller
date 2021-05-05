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

global kWeatherOptions = ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]
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

global queryScopeDropDown

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
	path := (getSimulatorCode(simulator) . "\" . car . "\" . track . "\")
	conditions := []
	
	for ignore, fileName in getEntries(path . "Tyre Setup*.data", "F") {
		condition := string2Values(A_Space, StrReplace(StrReplace(fileName, "Tyre Setup ", ""), ".data", ""))
	
		if (condition.Length() == 2) {
			compound := condition[1]
			weather := condition[2]
		}
		else {
			compound := condition[1] . " " . condition[2]
			weather := condition[3]
		}
		
		pressures := readConfiguration(kSetupDatabaseDirectory . "local\" . path . fileName)
		
		if (pressures.Count() == 0)
			pressures := readConfiguration(kSetupDatabaseDirectory . "global\" . path . fileName)
		
		for descriptor, ignore in getConfigurationSectionValues(pressures, "Pressures") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
		
			if descriptor[1] {
				conditions.Push(weather, descriptor[1], descriptor[2], compound)
			
				break
			}
		}
	}
	
	return conditions
}

readPressures(fileName, airTemperature, trackTemperature, pressures) {
	tyreSetup := getConfigurationValue(readConfiguration(fileName), "Pressures", ConfigurationItem.descriptor(airTemperature, trackTemperature), false)
	
	if tyreSetup {
		tyreSetup := string2Values(";", tyreSetup)
		
		for index, key in ["FL", "FR", "RL", "RR"]
			for ignore, pressure in string2Values(",", tyreSetup[index]) {
				pressure := string2Values(":", pressure)
			
				if pressures[key].HasKey(pressure[1])
					pressures[key][pressure[1]] := pressures[key][pressure[1]] + pressure[2]
				else
					pressures[key][pressure[1]] := pressure[2]
			}
	}		
}

getPressures(simulator, car, track, weather, airTemperature, trackTemperature, compound) {
	path := (getSimulatorCode(simulator) . "\" . car . "\" . track . "\Tyre Setup " . compound . " " . weather . ".data")
	
	for ignore, airDelta in [0, 1, -1, 2, -2] {
		for ignore, trackDelta in [0, 1, -1, 2, -2] {
			pressures := {FL: {}, FR: {}, RL: {}, RR: {}}
			
			readPressures(kSetupDatabaseDirectory . "local\" . path, airTemperature + airDelta, trackTemperature + trackDelta, pressures)
			
			if vIncludeGlobalDatabase
				readPressures(kSetupDatabaseDirectory . "global\" . path, airTemperature + airDelta, trackTemperature + trackDelta, pressures)
			
			if (pressures["FL"].Count() != 0) {
				thePressures := {}
				
				for index, tyre in ["FL", "FR", "RL", "RR"] {
					tyrePressures := pressures[tyre]
				
					bestPressure := false
					bestCount := 0
					
					for pressure, pressureCount in tyrePressures {
						if (pressureCount > bestCount) {
							bestCount := pressureCount
							bestPressure := pressure
						}
					}
						
					thePressures[tyre] := Array(bestPressure, airDelta, trackDelta)
				}
				
				return thePressures
			}
		}
	}
		
	return {FL: [0, 0], FR: [0, 0], RL: [0, 0], RR: [0, 0]}
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
		GuiControl Text, airTemperatureEdit, % conditions[2]
		GuiControl Text, trackTemperatureEdit, % conditions[3]
		
		GuiControl Choose, compoundDropDown, % inList(kTyreCompounds, conditions[4])
	}
	else {
		GuiControl Choose, weatherDropDown, 0
		GuiControl Text, airTemperatureEdit, 23
		GuiControl Text, trackTemperatureEdit, 27
		
		GuiControl Choose, compoundDropDown, 0
	}
	
	chooseTemperature()
}

chooseTemperature() {
	loadPressures()
}

loadPressures() {
	static lastColor := "Black"
	
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet weatherDropDown
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	GuiControlGet compoundDropDown
	
	for tyre, pressure in getPressures(simulatorDropDown, carDropDown, trackDropDown, kWeatherOptions[weatherDropDown]
									 , airTemperatureEdit, trackTemperatureEdit, kTyreCompounds[compoundDropDown]) {
		if pressure[1] {
			trackDelta := pressure[3]
			airDelta := pressure[2] + Round(trackDelta * 0.49)
			pressure := pressure[1]
			pressure -= 0.2
			
			if ((airDelta == 0) && (trackDelta == 0))
				color := "Green"
			else if (airDelta == 0)
				color := "Lime"
			else
				color := "Yellow"
			
			if (color != lastColor) {
				lastColor := color
				
				Gui RES:Color, D0D0D0, %color%
			}
			
			for index, postfix in ["1", "2", "3", "4", "5"] {
				pressure := Format("{:.1f}", pressure)
			
				GuiControl Text, %tyre%Pressure%postfix%, %pressure%
				
				if (index = (3 + airDelta)) {
					GuiControl +Background, %tyre%Pressure%postfix%
					GuiControl Enable, %tyre%Pressure%postfix%
				}
				else {
					GuiControl -Background, %tyre%Pressure%postfix%
					GuiControl Disable, %tyre%Pressure%postfix%
				}
			
				pressure += 0.1
			}
		}
		else
			for index, postfix in ["1", "2", "3", "4", "5"] {
				GuiControl Text, %tyre%Pressure%postfix%, 0.0
				GuiControl -Background, %tyre%Pressure%postfix%
				GuiControl Disable, %tyre%Pressure%postfix%
			}
	}
}

updateQueryScope() {
	GuiControlGet queryScopeDropDown
	
	vIncludeGlobalDatabase := (queryScopeDropDown - 1)
		
	chooseSimulator()
}

showSetups(command := false, simulator := false, car := false, track := false, weather := "Dry", airTemperature := 23, trackTemperature := 27, compound := "Dry") {
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

		Gui RES:Add, Text, YP+20 w380 cBlue Center gopenSetupsDocumentation, % translate("Setup Database")

		Gui RES:Font, Norm, Arial
				
		choices := ["Local", "Local & Global"]
		chosen := inList(choices, "Local")
		
		Gui RES:Add, Text, x8 y390 w55 h23 +0x200, % translate("Query")
		Gui RES:Add, DropDownList, x63 y390 w95 AltSubmit Choose%chosen% gupdateQueryScope vqueryScopeDropDown, % values2String("|", map(choices, "translate")*)
		
		Gui RES:Add, Button, x310 y390 w80 h23 Default gcloseSetups, % translate("Close")
		
		Gui RES:Add, Text, x16 y60 w105 h23 +0x200, % translate("Simulator")
		
		choices := getSimulators()
		chosen := inList(choices, simulator)
		if (!chosen && (choices.Length() > 0)) {
			simulator := choices[1]
			chosen := 1
		}
		
		Gui RES:Add, DropDownList, x106 y60 w276 Choose%chosen% gchooseSimulator vsimulatorDropDown, % values2String("|", choices*)
		
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
		
		Gui RES:Add, DropDownList, x106 y83 w144 Choose%chosen% gchooseCar vcarDropDown, % values2String("|", choices*)
		
		if (simulator && car && track) {
			choices := getTracks(simulator, car)
			chosen := inList(choices, track)
			if (!chosen && (choices.Length() > 0)) {
				track := choices[1]
				chosen := 1
			}
		}
		else {
			choices := []
			chosen := 0
		}
		
		Gui RES:Add, Text, x250 y83 w20 h23 +0x200 Center, % translate("/")
		Gui RES:Add, DropDownList, x270 y83 w112 Choose%chosen% gchooseTrack vtrackDropDown, % values2String("|", choices*)
		
		if (simulator && car && track)
			chooseTrack()
		
		Gui RES:Add, Text, x16 y106 w105 h23 +0x200, % translate("Conditions")
		choices := map(kWeatherOptions, "translate")
		chosen := inList(kWeatherOptions, weather)
		if (!chosen && (choices.Length() > 0)) {
			weather := choices[1]
			chosen := 1
		}
		Gui RES:Add, DropDownList, x106 y106 w100 AltSubmit Choose%chosen% gloadPressures vweatherDropDown, % values2String("|", choices*)
		
		Gui RES:Add, Edit, x210 y106 w40 -Background gloadPressures vairTemperatureEdit
		Gui RES:Add, UpDown, x242 yp-2 w18 h20, % airTemperature
		Gui RES:Add, Text, x252 y106 w140 h23 +0x200, % translate("Temp. Air (Celsius)")
		
		Gui RES:Add, Edit, x210 y130 w40 -Background gloadPressures vtrackTemperatureEdit
		Gui RES:Add, UpDown, x242 yp-2 w18 h20, % trackTemperature
		Gui RES:Add, Text, x252 y130 w140 h23 +0x200, % translate("Temp. Track (Celsius)")
		
		tabs := map(["Tyres"], "translate")

		Gui RES:Add, Tab3, x8 y159 w380 h224 -Wrap, % values2String("|", tabs*)

		Gui Tab, 1

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Compound")
		
		choices := map(kTyreCompounds, "translate")
		chosen := inList(kTyreCompounds, compound)
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		Gui RES:Add, DropDownList, x106 yp w100 AltSubmit Choose%chosen% gloadPressures vcompoundDropDown, % values2String("|", choices*)

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x62 yp+30 w262 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Pressures")

		Gui RES:Font, Norm, Arial
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Left (PSI)")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vflPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vflPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vflPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vflPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vflPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Right (PSI)")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vfrPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vfrPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vfrPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vfrPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vfrPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Left (PSI)")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vrlPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vrlPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vrlPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vrlPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vrlPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Right (PSI)")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vrrPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vrrPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vrrPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vrrPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vrrPressure5, 0.0

		Gui RES:Show, AutoSize Center
		
		if (simulator && car && track && weather && airTemperature && trackTemperature && compound)
			loadPressures()
		else if (!simulator || !car || !track)
			chooseSimulator()
		
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
	
	
	simulator := false
	car := false
	track := false
	weather := "Dry"
	airTemperature := 23
	trackTemperature:= 27
	compound := "Dry"
	
	index := 1
	
	while (index < A_Args.Length()) {
		switch A_Args[index] {
			case "-Simulator":
				simulator := A_Args[index + 1]
				index += 2
			case "-car":
				car := A_Args[index + 1]
				index += 2
			case "-Track":
				track := A_Args[index + 1]
				index += 2
			case "-Weather":
				weather := A_Args[index + 1]
				index += 2
			case "-AirT":
				airTemperature := A_Args[index + 1]
				index += 2
			case "-TrackT":
				trackTemperature := A_Args[index + 1]
				index += 2
			case "-Compound":
				compound := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}
	
	vControllerConfiguration := getControllerConfiguration()
	
	showSetups(false, simulator, car, track, weather, airTemperature, trackTemperature, compound)
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceEngineerSetups()