;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Database Tool             ;;;
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
;@Ahk2Exe-ExeName Setup Database.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global vSettingsPID = false

global vSetupDatabase = false

global vLocalSettings = {}
global vGlobalSettings = {}

global simulatorDropDown
global carDropDown
global trackDropDown
global weatherDropDown
global airTemperatureEdit
global trackTemperatureEdit
global tyreCompoundDropDown

global dryQualificationDropDown
global uploadDryQualificationButton
global downloadDryQualificationButton
global deleteDryQualificationButton
global dryRaceDropDown
global uploadDryRaceButton
global downloadDryRaceButton
global deleteDryRaceButton
global wetQualificationDropDown
global uploadWetQualificationButton
global downloadWetQualificationButton
global deleteWetQualificationButton
global wetRaceDropDown
global uploadWetRaceButton
global downloadWetRaceButton
global deleteWetRaceButton

global settingsListView
global settingsListViewHandle
global addSettingsButton
global editSettingsButton
global duplicateSettingsButton
global deleteSettingsButton
		
global notesEdit

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
	protectionOn()

	try {
		Gui RES:Default
				
		GuiControlGet simulatorDropDown
		
		choices := vSetupDatabase.getCars(simulatorDropDown)
		chosen := ((choices.Length() > 0) ? 1 : 0)
		
		GuiControl, , carDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, carDropDown, %chosen%
		
		chooseCar()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

chooseCar() {
	protectionOn()
	
	try {
		Gui RES:Default
				
		GuiControlGet simulatorDropDown
		GuiControlGet carDropDown
		
		choices := vSetupDatabase.getTracks(simulatorDropDown, carDropDown)
		chosen := ((choices.Length() > 0) ? 1 : 0)
		
		GuiControl, , trackDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, trackDropDown, %chosen%
		
		chooseTrack()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

chooseTrack() {
	protectionOn()
	
	try {
		Gui RES:Default
				
		GuiControlGet simulatorDropDown
		GuiControlGet carDropDown
		GuiControlGet trackDropDown
		
		conditions := vSetupDatabase.getConditions(simulatorDropDown, carDropDown, trackDropDown)
		
		if (conditions.Length() > 0) {
			conditions := conditions[1]
			
			weatherDropDown := inList(kWeatherOptions, conditions[1])
			airTemperatureEdit := conditions[2]
			trackTemperatureEdit := conditions[3]
			
			tyreCompoundDropDown := inList(kQualifiedTyreCompounds, conditions[4])
		}
		else {
			weatherDropDown := 0
			airTemperatureEdit := 23
			trackTemperatureEdit := 27
			
			tyreCompoundDropDown := 0
		}

		GuiControl Choose, weatherDropDown, %weatherDropDown%
		GuiControl Text, airTemperatureEdit, %airTemperatureEdit%
		GuiControl Text, trackTemperatureEdit, %trackTemperatureEdit%
		
		GuiControl Choose, tyreCompoundDropDown, %tyreCompoundDropDown%
		
		chooseTemperature()
		loadSetups()
		loadSettings()
		loadNotes()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

chooseTemperature() {
	withProtection("loadPressures")
}

loadSetups(asynchronous := true) {
	GuiControlGet dryQualificationDropDown
	GuiControlGet dryRaceDropDown
	GuiControlGet wetQualificationDropDown
	GuiControlGet wetRaceDropDown
	
	if !asynchronous {
		Gui RES:Default
		
		GuiControlGet simulatorDropDown
		GuiControlGet carDropDown
		GuiControlGet trackDropDown
		
		localSetups := false
		globalSetups := false
		
		vSetupDatabase.getSetupNames(simulatorDropDown, carDropDown, trackDropDown, localSetups, globalSetups)
		
		newDryQualificationDropDown := concatenate(localSetups[kDryQualificationSetup], globalSetups[kDryQualificationSetup])
		newDryRaceDropDown := concatenate(localSetups[kDryRaceSetup], globalSetups[kDryRaceSetup])
		newWetQualificationDropDown := concatenate(localSetups[kWetQualificationSetup], globalSetups[kWetQualificationSetup])
		newWetRaceDropDown := concatenate(localSetups[kWetRaceSetup], globalSetups[kWetRaceSetup])
		
		dryQualificationSelection := inList(newDryQualificationDropDown, dryQualificationDropDown)
		dryRaceSelection := inList(newDryRaceDropDown, dryRaceDropDown)
		wetQualificationSelection := inList(newWetQualificationDropDown, wetQualificationDropDown)
		wetRaceSelection := inList(newWetRaceDropDown, wetRaceDropDown)
		
		if !dryQualificationSelection
			dryQualificationSelection := ((newDryQualificationDropDown.Length() > 0) ? 1 : 0)
		if !dryRaceSelection
			dryRaceSelection := ((newDryRaceDropDown.Length() > 0) ? 1 : 0)
		if !wetQualificationSelection
			wetQualificationSelection := ((newWetQualificationDropDown.Length() > 0) ? 1 : 0)
		if !wetRaceSelection
			wetRaceSelection := ((newWetRaceDropDown.Length() > 0) ? 1 : 0)
		
		GuiControl Text, dryQualificationDropDown, % "|" . values2String("|", newDryQualificationDropDown*)
		GuiControl Text, dryRaceDropDown, % "|" . values2String("|", newDryRaceDropDown*)
		GuiControl Text, wetQualificationDropDown, % "|" . values2String("|", newWetQualificationDropDown*)
		GuiControl Text, wetRaceDropDown, % "|" . values2String("|", newWetRaceDropDown*)
		
		GuiControl Choose, dryQualificationDropDown, %dryQualificationSelection%
		GuiControl Choose, dryRaceDropDown, %dryRaceSelection%
		GuiControl Choose, wetQualificationDropDown, %wetQualificationSelection%
		GuiControl Choose, wetRaceDropDown, %wetRaceSelection%
	
		if ((simulatorDropDown = "") || (carDropDown = "") || (trackDropDown = "")) {
			GuiControl Disable, uploadDryQualificationButton
			GuiControl Disable, downloadDryQualificationButton
			GuiControl Disable, deleteDryQualificationButton
			GuiControl Disable, uploadDryRaceButton
			GuiControl Disable, downloadDryRaceButton
			GuiControl Disable, deleteDryRaceButton
			GuiControl Disable, uploadWetQualificationButton
			GuiControl Disable, downloadWetQualificationButton
			GuiControl Disable, deleteWetQualificationButton
			GuiControl Disable, uploadWetRaceButton
			GuiControl Disable, downloadWetRaceButton
			GuiControl Disable, deleteWetRaceButton
		}
		else {
			GuiControlGet dryQualificationDropDown
			GuiControlGet dryRaceDropDown
			GuiControlGet wetQualificationDropDown
			GuiControlGet wetRaceDropDown
			
			GuiControl Enable, uploadDryQualificationButton
			GuiControl Enable, uploadDryRaceButton
			GuiControl Enable, uploadWetQualificationButton
			GuiControl Enable, uploadWetRaceButton
			
			option := (dryQualificationSelection ? "Enable" : "Disable")
			
			GuiControl %option%, downloadDryQualificationButton
			
			option := ((dryQualificationSelection && inList(localSetups[kDryQualificationSetup], dryQualificationDropDown)) ? "Enable" : "Disable")
			
			GuiControl %option%, deleteDryQualificationButton
			
			option := (dryRaceSelection ? "Enable" : "Disable")
			
			GuiControl %option%, downloadDryRaceButton
			
			option := ((dryRaceSelection && inList(localSetups[kDryRaceSetup], dryRaceDropDown)) ? "Enable" : "Disable")
			
			GuiControl %option%, deleteDryRaceButton
			
			option := (wetQualificationSelection ? "Enable" : "Disable")
			
			GuiControl %option%, downloadWetQualificationButton
			
			option := ((wetQualificationSelection && inList(localSetups[kWetQualificationSetup], wetQualificationDropDown)) ? "Enable" : "Disable")
			
			GuiControl %option%, deleteWetQualificationButton
			
			option := (wetRaceSelection ? "Enable" : "Disable")
			
			GuiControl %option%, downloadWetRaceButton
			
			option := ((wetRaceSelection && inList(localSetups[kWetRaceSetup], wetRaceDropDown)) ? "Enable" : "Disable")
			
			GuiControl %option%, deleteWetRaceButton
		}
	}
	else {
		callback := Func("loadSetups").Bind(false)
	
		SetTimer %callback%, -100
	}
}

getSettings(index := false) {
	Gui ListView, % settingsListViewHandle
	
	if !index
		index := LV_GetNext()
	
	if index {
		if (index <= vLocalSettings.Length())
			return vLocalSettings[index]
		else
			return vGlobalSettings[index - vLocalSettings.Length()]
	}
	else
		return false
}

getIndex(settings) {
	index := inList(vLocalSettings, settings)
	
	if index
		return index
	else {
		index := inList(vGlobalSettings, settings)
	
		if index
			return (index + vLocalSettings.Length())
		else
			return false
	}
}

loadSettings(settings := false) {
	Gui RES:Default
	Gui ListView, % settingsListViewHandle
	
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
		
	if ((simulatorDropDown = "") || (carDropDown = "") || (trackDropDown = "")) {
		GuiControl Disable, addSettingsButton
		GuiControl Disable, editSettingsButton
		GuiControl Disable, duplicateSettingsButton
		GuiControl Disable, deleteSettingsButton
		
		GuiControl +Disabled, settingsListView
		
		LV_Delete()
	}
	else {
		GuiControl Enable, addSettingsButton
		
		if !settings
			settings := getSettings()
	
		vSetupDatabase.getSettingsNames(simulatorDropDown, carDropDown, trackDropDown, vLocalSettings, vGlobalSettings)
		
		LV_Delete()
		
		for ignore, name in vLocalSettings {
			LV_Add("", name)
		}
		
		for ignore, name in vGlobalSettings {
			LV_Add("", name)
		}
		
		if settings {
			index := getIndex(settings)
			
			if index {
				LV_Modify(index, "+Focus +Select Vis")
				
				GuiControl Enable, duplicateSettingsButton
				
				if (index <= vLocalSettings.Length()) {
					GuiControl Enable, editSettingsButton
					GuiControl Enable, deleteSettingsButton
				}
				else {
					GuiControl Disable, editSettingsButton
					GuiControl Disable, deleteSettingsButton
				}
			}
			else {
				GuiControl Disable, editSettingsButton
				GuiControl Disable, duplicateSettingsButton
				GuiControl Disable, deleteSettingsButton
			}
		}
		else {
			GuiControl Disable, editSettingsButton
			GuiControl Disable, duplicateSettingsButton
			GuiControl Disable, deleteSettingsButton
		}
		
		GuiControl -Disabled, settingsListView
	}
}

loadNotes() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	notesEdit := vSetupDatabase.readNotes(simulatorDropDown, carDropDown, trackDropDown)
	
	GuiControl Text, notesEdit, %notesEdit%
	
	if ((simulatorDropDown = "") || (carDropDown = "") || (trackDropDown = ""))
		GuiControl Disable, notesEdit
	else
		GuiControl Enable, notesEdit
}

loadPressures() {
	protectionOn()
	
	try {
		Gui RES:Default
				
		static lastColor := "D0D0D0"
		
		GuiControlGet simulatorDropDown
		GuiControlGet carDropDown
		GuiControlGet trackDropDown
		GuiControlGet weatherDropDown
		GuiControlGet airTemperatureEdit
		GuiControlGet trackTemperatureEdit
		GuiControlGet tyreCompoundDropDown
		
		compound := string2Values(A_Space, kQualifiedTyreCompounds[tyreCompoundDropDown])
		
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

			if vSettingsPID
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
			
				if vSettingsPID
					GuiControl Enable, transferPressuresButton
			}
		}
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

uploadSetup(setupType) {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown

	title := translate("Upload Setup File...")
				
	FileSelectFile fileName, 1, , %title%

	if (fileName != "") {
		FileRead setup, %fileName%
		SplitPath fileName, fileName
		
		vSetupDatabase.writeSetup(simulatorDropDown, carDropDown, trackDropDown, setupType, fileName, setup)
	
		loadSetups()
	}
}

downloadSetup(setupType, setupName) {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown

	title := translate("Download Setup File...")
				
	FileSelectFile fileName, S, %setupName%, %title%
	
	if (fileName != "") {
		setupData := vSetupDatabase.readSetup(simulatorDropDown, carDropDown, trackDropDown, setupType, setupName)
		
		try {
			FileDelete %fileName%
		}
		catch exception {
			; ignore
		}
		
		FileAppend %setupData%, %fileName%
	
		loadSetups()
	}
}

deleteSetup(setupType, setupName) {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	vSetupDatabase.deleteSetup(simulatorDropDown, carDropDown, trackDropDown, setupType, setupName)
	
	loadSetups()
}

uploadDryQualificationSetup() {
	uploadSetup(kDryQualificationSetup)
}

downloadDryQualificationSetup() {
	GuiControlGet dryQualificationDropDown
	
	downloadSetup(kDryQualificationSetup, dryQualificationDropDown)
}

deleteDryQualificationSetup() {
	GuiControlGet dryQualificationDropDown
	
	deleteSetup(kDryQualificationSetup, dryQualificationDropDown)
}

uploadDryRaceSetup() {
	uploadSetup(kDryRaceSetup)
}

downloadDryRaceSetup() {
	GuiControlGet dryRaceDropDown
	
	downloadSetup(kDryRaceSetup, dryRaceDropDown)
}

deleteDryRaceSetup() {
	GuiControlGet dryRaceDropDown
	
	deleteSetup(kDryRaceSetup, dryRaceDropDown)
}

uploadWetQualificationSetup() {
	uploadSetup(kWetQualificationSetup)
}

downloadWetQualificationSetup() {
	GuiControlGet wetQualificationDropDown
	
	downloadSetup(kWetQualificationSetup, wetQualificationDropDown)
}

deleteWetQualificationSetup() {
	GuiControlGet wetQualificationDropDown
	
	deleteSetup(kWetQualificationSetup, wetQualificationDropDown)
}

uploadWetRaceSetup() {
	uploadSetup(kWetRaceSetup)
}

downloadWetRaceSetup() {
	GuiControlGet wetRaceDropDown
	
	downloadSetup(kWetRaceSetup, wetRaceDropDown)
}

deleteWetRaceSetup() {
	GuiControlGet wetRaceDropDown
	
	deleteSetup(kWetRaceSetup, wetRaceDropDown)
}

openSettings(mode := "New", arguments*) {
	exePath := kBinariesDirectory . "Race Settings.exe"
	fileName := kTempDirectory . "Temp.settings"
				
	Gui RES:Hide
				
	try {
		options := ""
		
		switch mode {
			case "New":
				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}
			case "Edit":
				writeConfiguration(fileName, arguments[1])
		}
				
		options := "-File """ . fileName . """"
		
		RunWait "%exePath%" %options%, %kBinariesDirectory%, , pid
			
		if ErrorLevel
			return readConfiguration(fileName)
		else
			return false
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		
		return false
	}
	finally {
		Gui RES:Show
	}
}

openSettingsEditor(asynchronous := true) {
	if !asynchronous
		SendEvent {F2}
	else {
		callback := Func("openSettingsEditor").Bind(false)
	
		SetTimer %callback%, -500
	}
}

settingsListViewEvent() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	if (A_GuiEvent = "e") {
		oldName := getSettings(A_EventInfo)
		
		LV_GetText(newName, A_EventInfo)
		
		vSetupDatabase.renameSettings(simulatorDropDown, carDropDown, trackDropDown, oldName, newName)
	}
	else {
		index := LV_GetNext()
		
		if index {
			GuiControl Enable, duplicateSettingsButton
			
			if (index <= vLocalSettings.Length()) {
				GuiControl Enable, editSettingsButton
				GuiControl Enable, deleteSettingsButton
			}
			else {
				GuiControl Disable, editSettingsButton
				GuiControl Disable, deleteSettingsButton
			}
			
			if (A_GuiEvent = "DoubleClick")
				openSettingsEditor()
		}
		else {
			GuiControl Disable, editSettingsButton
			GuiControl Disable, duplicateSettingsButton
			GuiControl Disable, deleteSettingsButton
		}
	}
}

addSettings() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	settings := openSettings("New")
	
	if settings {
		settingsName := translate("New")
		
		vSetupDatabase.writeSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName, settings)
	
		loadSettings(settingsName)
		
		openSettingsEditor()
	}
}

editSettings() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	settingsName := getSettings()
	
	settings := openSettings("Edit", vSetupDatabase.readSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName))
	
	if settings
		vSetupDatabase.writeSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName, settings)
}

duplicateSettings() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	settingsName := getSettings()
	
	settings := openSettings("Edit", vSetupDatabase.readSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName))
	
	if settings {
		settingsName := (settingsName . translate(" Copy"))
		
		vSetupDatabase.writeSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName, settings)
	
		loadSettings(settingsName)
		
		openSettingsEditor()
	}
}

deleteSettings() {
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	
	settingsName := getSettings()
	
	vSetupDatabase.deleteSettings(simulatorDropDown, carDropDown, trackDropDown, settingsName)
	
	loadSettings()
}

updateQueryScope() {
	Gui RES:Default
			
	GuiControlGet queryScopeDropDown
	
	vSetupDatabase.setUseGlobalDatabase(queryScopeDropDown - 1)
		
	chooseSimulator()
}

writeNotes() {
	Gui RES:Default
			
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet notesEdit
	
	vSetupDatabase.writeNotes(simulatorDropDown, carDropDown, trackDropDown, notesEdit)
}

transferPressures() {
	Gui RES:Default
			
	GuiControlGet simulatorDropDown
	GuiControlGet carDropDown
	GuiControlGet trackDropDown
	GuiControlGet weatherDropDown
	GuiControlGet airTemperatureEdit
	GuiControlGet trackTemperatureEdit
	GuiControlGet tyreCompoundDropDown
	
	tyrePressures := []
	compound := string2Values(A_Space, kQualifiedTyreCompounds[tyreCompoundDropDown])
	
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
		
		tabs := map(["Tyres", "Setup", "Settings", "Notes"], "translate")

		Gui RES:Add, Tab3, x8 y159 w380 h224 -Wrap, % values2String("|", tabs*)

		Gui Tab, 1

		Gui RES:Add, Text, x16 yp+30 w85 h23 +0x200, % translate("Compound")
		
		choices := map(kQualifiedTyreCompounds, "translate")
		chosen := inList(kQualifiedTyreCompounds, compound)
		if (!chosen && (choices.Length() > 0)) {
			compound := choices[1]
			chosen := 1
		}
		Gui RES:Add, DropDownList, x106 yp w100 AltSubmit Choose%chosen% gloadPressures vtyreCompoundDropDown, % values2String("|", choices*)
		
		if vSettingsPID
			Gui RES:Add, Button, x292 yp w80 h23 gtransferPressures vtransferPressuresButton, % translate("Load")

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

		Gui Tab, 2

		Gui RES:Add, Text, x16 y189 w120 h23 +0x200, % translate("Qualification (Dry)")
		Gui RES:Add, DropDownList, x140 yp w163 vdryQualificationDropDown
		Gui RES:Add, Button, x306 yp-1 w23 h23 HwnduploadDryQualificationButtonHandle vuploadDryQualificationButton guploadDryQualificationSetup
		Gui RES:Add, Button, x331 yp w23 h23 HwnddownloadDryQualificationButtonHandle vdownloadDryQualificationButton gdownloadDryQualificationSetup
		Gui RES:Add, Button, x356 yp w23 h23 HwnddeleteDryQualificationButtonHandle VdeleteDryQualificationButton gdeleteDryQualificationSetup
		setButtonIcon(uploadDryQualificationButtonHandle, kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(downloadDryQualificationButtonHandle, kIconsDirectory . "Download.ico", 1)
		setButtonIcon(deleteDryQualificationButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui RES:Add, Text, x16 yp+24 w120 h23 +0x200, % translate("Qualification (Wet)")
		Gui RES:Add, DropDownList, x140 yp w163 vwetQualificationDropDown
		Gui RES:Add, Button, x306 yp-1 w23 h23 HwnduploadWetQualificationButtonHandle vuploadWetQualificationButton guploadWetQualificationSetup
		Gui RES:Add, Button, x331 yp w23 h23 HwnddownloadWetQualificationButtonHandle vdownloadWetQualificationButton gdownloadWetQualificationSetup
		Gui RES:Add, Button, x356 yp w23 h23 HwnddeleteWetQualificationButtonHandle VdeleteWetQualificationButton gdeleteWetQualificationSetup
		setButtonIcon(uploadWetQualificationButtonHandle, kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(downloadWetQualificationButtonHandle, kIconsDirectory . "Download.ico", 1)
		setButtonIcon(deleteWetQualificationButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui RES:Add, Text, x16 yp+30 w120 h23 +0x200, % translate("Race (Dry)")
		Gui RES:Add, DropDownList, x140 yp w163 vdryRaceDropDown
		Gui RES:Add, Button, x306 yp-1 w23 h23 HwnduploadDryRaceButtonHandle vuploadDryRaceButton guploadDryRaceSetup
		Gui RES:Add, Button, x331 yp w23 h23 HwnddownloadDryRaceButtonHandle vdownloadDryRaceButton gdownloadDryRaceSetup
		Gui RES:Add, Button, x356 yp w23 h23 HwnddeleteDryRaceButtonHandle VdeleteDryRaceButton gdeleteDryRaceSetup
		setButtonIcon(uploadDryRaceButtonHandle, kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(downloadDryRaceButtonHandle, kIconsDirectory . "Download.ico", 1)
		setButtonIcon(deleteDryRaceButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui RES:Add, Text, x16 yp+24 w120 h23 +0x200, % translate("Race (Wet)")
		Gui RES:Add, DropDownList, x140 yp w163 vwetRaceDropDown
		Gui RES:Add, Button, x306 yp-1 w23 h23 HwnduploadWetRaceButtonHandle vuploadWetRaceButton guploadWetRaceSetup
		Gui RES:Add, Button, x331 yp w23 h23 HwnddownloadWetRaceButtonHandle vdownloadWetRaceButton gdownloadWetRaceSetup
		Gui RES:Add, Button, x356 yp w23 h23 HwnddeleteWetRaceButtonHandle VdeleteWetRaceButton gdeleteWetRaceSetup
		setButtonIcon(uploadWetRaceButtonHandle, kIconsDirectory . "Upload.ico", 1)
		setButtonIcon(downloadWetRaceButtonHandle, kIconsDirectory . "Download.ico", 1)
		setButtonIcon(deleteWetRaceButtonHandle, kIconsDirectory . "Minus.ico", 1)

		Gui Tab, 3
		
		Gui RES:Add, ListView, x16 y189 w364 h160 Disabled AltSubmit -Multi -Hdr NoSort NoSortHdr -ReadOnly -LV0x10 -Background HwndsettingsListViewHandle VsettingsListView gsettingsListViewEvent, % translate("Setting")
		Gui RES:Add, Button, x281 yp+165 w23 h23 HwndaddSettingsButtonHandle gaddSettings vaddSettingsButton
		Gui RES:Add, Button, x306 yp w23 h23 HwndeditSettingsButtonHandle geditSettings veditSettingsButton
		Gui RES:Add, Button, x331 yp w23 h23 HwndduplicateSettingsButtonHandle VduplicateSettingsButton gduplicateSettings
		Gui RES:Add, Button, x356 yp w23 h23 HwnddeleteSettingsButtonHandle VdeleteSettingsButton gdeleteSettings
		setButtonIcon(addSettingsButtonHandle, kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(editSettingsButtonHandle, kIconsDirectory . "Pencil.ico", 1)
		setButtonIcon(duplicateSettingsButtonHandle, kIconsDirectory . "Copy.ico", 1)
		setButtonIcon(deleteSettingsButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui Tab, 4
		
		Gui RES:Add, Edit, x16 y189 w364 h184 -Background gwriteNotes vnotesEdit

		Gui RES:Show, AutoSize Center
		
		if (simulator && car && track && weather && airTemperature && trackTemperature && compound) {
			loadPressures()
			loadSetups()
			loadSettings()
			loadNotes()
		}
		else if (!simulator || !car || !track)
			chooseSimulator()
		else
			chooseTrack()
		
		Loop {
			Loop {
				Sleep 1000
			} until result

			if (result == kClose)
				break
		}
	}
}

showSetupDatabase() {
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
			case "-Car":
				car := A_Args[index + 1]
				index += 2
			case "-Track":
				track := A_Args[index + 1]
				index += 2
			case "-Weather":
				weather := A_Args[index + 1]
				index += 2
			case "-AirTemperature":
				airTemperature := A_Args[index + 1]
				index += 2
			case "-TrackTemperature":
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
	
	if ((airTemperature <= 0) || (trackTemperature <= 0)) {
		airTemperature := false
		trackTemperature := false
	}
		
	
	vSetupDatabase := new SetupDatabase()
	
	showSetups(false, simulator, car, track, weather, airTemperature, trackTemperature, compound)
	
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

showSetupDatabase()