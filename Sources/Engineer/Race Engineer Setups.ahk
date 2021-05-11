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
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Engineer\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global vSettingsPID = false

global vSetupDatabase = false

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global airTemperatureEdit
global trackTemperatureEdit
global compoundDropDown

global transferPressuresButton
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

chooseSimulator() {
	GuiControlGet simulatorDropDown
	
	choices := vSetupDatabase.getCars(simulatorDropDown)
	chosen := ((choices.Length() > 0) ? 1 : 0)
	
	GuiControl, , carDropDown, % "|" . values2String("|", choices*)
	GuiControl Choose, carDropDown, %chosen%
	
	chooseCar()
}

chooseCar() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	
	choices := vSetupDatabase.getTracks(simulatorDropDown, carDropDown)
	chosen := ((choices.Length() > 0) ? 1 : 0)
	
	GuiControl, , trackDropDown, % "|" . values2String("|", choices*)
	GuiControl Choose, trackDropDown, %chosen%
	
	chooseTrack()
}

chooseTrack() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	conditions := vSetupDatabase.getConditions(simulatorDropDown, carDropDown, trackDropDown)
	
	if (conditions.Length() > 0) {
		GuiControl Choose, weatherDropDown, % inList(kWeatherOptions, conditions[1])
		GuiControl Text, airTemperatureEdit, % conditions[2]
		GuiControl Text, trackTemperatureEdit, % conditions[3]
		
		GuiControl Choose, compoundDropDown, % inList(kQualifiedTyreCompounds, conditions[4])
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
	static lastColor := "D0D0D0"
	
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet weatherDropDown
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	GuiControlGet compoundDropDown
	
	compound := string2Values(A_Space, kQualifiedTyreCompounds[compoundDropDown])
	
	if (compound.Length() == 1)
		compoundColor := "Black"
	else
		compoundColor := SubStr(compound[2], 2, StrLen(compound[2]) - 2)
	
	pressureInfos := vSetupDatabase.getPressures(simulatorDropDown, carDropDown, trackDropDown, kWeatherOptions[weatherDropDown]
											   , airTemperatureEdit, trackTemperatureEdit, compound[1], compoundColor)

	if (pressureInfos.Count() == 0) {
		for ignore, tyre in ["fl", "fr", "rl", "rr"]
			for ignore, postfix in ["1", "2", "3", "4", "5"] {
				GuiControl Text, %tyre%Pressure%postfix%, 0.0
				GuiControl +Background, %tyre%Pressure%postfix%
				GuiControl Disable, %tyre%Pressure%postfix%
			}

		GuiControl Disable, transferPressuresButton
	}
	else {
		for tyre, pressureInfo in pressureInfos {
			pressure := pressureInfo["Pressure"]
			trackDelta := pressureInfo["Delta Track"]
			airDelta := pressureInfo["Delta Air"] + Round(trackDelta * 0.49)
			
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
		
			GuiControl Enable, transferPressuresButton
		}
	}
}

updateQueryScope() {
	GuiControlGet queryScopeDropDown
	
	vSetupDatabase.setUseGlobalDatabase(queryScopeDropDown - 1)
		
	chooseSimulator()
}

transferPressures() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet weatherDropDown
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	GuiControlGet compoundDropDown
	
	tyrePressures := []
	compound := string2Values(A_Space, kQualifiedTyreCompounds[compoundDropDown])
	
	if (compound.Length() == 1)
		compoundColor := "Black"
	else
		compoundColor := SubStr(compound[2], 2, StrLen(compound[2]) - 2)
	
	for ignore, pressureInfo in vSetupDatabase.getPressures(simulatorDropDown, carDropDown, trackDropDown, kWeatherOptions[weatherDropDown]
														  , airTemperatureEdit, trackTemperatureEdit, compound[1], compoundColor)
		tyrePressures.Push(pressureInfo["Pressure"] + ((pressureInfo["Delta Air"] + Round(pressureInfo["Delta Track"] * 0.49)) * 0.1))
	
	raiseEvent(kFileMessage, "Setup", "setTyrePressures:" . values2String(";", compound, tyrePressures*), vSettingsPID)
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
		
		if vSettingsPID
			Gui RES:Add, Button, x220 y390 w80 h23 gtransferPressures vtransferPressuresButton, % translate("Load")
		
		Gui RES:Add, Text, x16 y60 w105 h23 +0x200, % translate("Simulator")
		
		choices := vSetupDatabase.getSimulators()
		chosen := inList(choices, simulator)
		if (!chosen && (choices.Length() > 0)) {
			simulator := choices[1]
			chosen := 1
		}
		
		Gui RES:Add, DropDownList, x106 y60 w276 Choose%chosen% gchooseSimulator vsimulatorDropDown, % values2String("|", choices*)
		
		Gui RES:Add, Text, x16 y83 w105 h23 +0x200, % translate("Car / Track")
		
		if (simulator && car) {
			choices := vSetupDatabase.getCars(simulator)
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
			choices := vSetupDatabase.getTracks(simulator, car)
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
		
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		Gui RES:Add, DropDownList, x106 yp w100 AltSubmit Choose%chosen% gloadPressures vcompoundDropDown, % values2String("|", choices*)

		Gui RES:Font, Norm, Arial
		Gui RES:Font, Bold Italic, Arial

		Gui RES:Add, Text, x62 yp+30 w262 0x10
		Gui RES:Add, Text, x16 yp+10 w370 h20 Center BackgroundTrans, % translate("Pressures (PSI)")

		Gui RES:Font, Norm, Arial
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Left")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vflPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vflPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vflPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vflPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vflPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Front Right")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vfrPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vfrPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vfrPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vfrPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vfrPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Left")
		Gui RES:Add, Edit, x106 yp w50 Disabled Center vrlPressure1, 0.0
		Gui RES:Add, Edit, x160 yp w50 Disabled Center vrlPressure2, 0.0
		Gui RES:Add, Edit, x214 yp w50 Center +Background vrlPressure3, 0.0
		Gui RES:Add, Edit, x268 yp w50 Disabled Center vrlPressure4, 0.0
		Gui RES:Add, Edit, x322 yp w50 Disabled Center vrlPressure5, 0.0
		
		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Rear Right")
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
			case "-Settings":
				vSettingsPID := A_Args[index + 1]
				index += 2
			default:
				index += 1
		}
	}
	
	vSetupDatabase := new SetupDatabase()
	
	showSetups(false, simulator, car, track, weather, airTemperature, trackTemperature, compound)
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showRaceEngineerSetups()