;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Event Buffer Test Program       ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Event Buffer Tester.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
global selectedSimulator
global eventMode
global hotkey

global dismissed


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

selectCommand(title := "Event Buffer Tester", x := "Center", y := "Center", width := 300, height := 200) {
	static hasWindow := false
	
	static titleField
	
	dismissed := false
	
	Gui EBT:Default
	
	if hasWindow {
		GuiControl Text, titleField, %title%
		
		Gui EBT:Show
	}
	else {
		hasWindow := true
	
		innerWidth := width - 16
		
		Gui EBT:-Border -Caption
		Gui EBT:Color, D0D0D0, D8D8D8
		Gui EBT:Font, s10 Bold
		Gui EBT:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveEventBufferTester, % translate("Modular Simulator Controller System")
		Gui EBT:Font
		Gui EBT:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans vtitleField, %title%
		
		Gui EBT:Add, Text, x16 yp+40 w70 h23 +0x200, % translate("Simulator")
		
		simulators := new SessionDatabase().getSimulators()
		simulator := 0
		
		if (simulators.Length() > 0)
			simulator := 1
	
		Gui EBT:Add, DropDownList, x100 yp w191 Choose%simulator% vselectedSimulator, % values2String("|", simulators*)
		
		Gui EBT:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Event Mode")
		Gui EBT:Add, DropDownList, x100 yp w191 AltSubmit Choose1 veventMode, Event|Input|Play|Raw|Default
		
		Gui EBT:Add, Text, x16 yp+24 w70 h23 +0x200, % translate("Hotkey")
		Gui EBT:Add, Edit, x100 yp w50 vhotKey
		
		SysGet mainScreen, MonitorWorkArea

		if x is not integer
			switch x {
				case "Left":
					x := 25
				case "Right":
					x := mainScreenRight - width - 25
				default:
					x := "Center"
			}

		if y is not integer
			switch y {
				case "Top":
					y := 25
				case "Bottom":
					y := mainScreenBottom - height - 25
				default:
					y := "Center"
			}
		
		buttonX := Round(width / 2) - 90
		
		Gui EBT:Add, Button, Default X%buttonX% y+20 w80 gsendCommand, % translate("Send")
		Gui EBT:Add, Button, Default XP+90 yp w80 gexitEventBufferTester, % translate("Exit")
		
		Gui EBT:+AlwaysOnTop
		Gui EBT:Show, X%x% Y%y% W%width% H%height% NoActivate
	}
	
	while !dismissed
		Sleep 100
	
	GUI EBT:Hide
	
	Sleep 2500
	
	selectCommand()
}

activateSimulatorWindow(selectedSimulator) {
	window := new Application(selectedSimulator, kSimulatorConfiguration).WindowTitle
		
	if !WinExist(window) {
		showMessage(selectedSimulator . " not found...")
		
		return false
	}
	
	if !WinActive(window)
		WinActivate %window%
	
	return true
}

sendSimulatorCommand(eventMode, command) {
	switch eventMode {
		case "Event":
			SendEvent %command%
		case "Input":
			SendInput %command%
		case "Play":
			SendPlay %command%
		case "Raw":
			SendRaw %command%
		default:
			Send %command%
	}
}

sendCommand() {
	Gui EBT:Default
	
	GuiControlGet selectedSimulator
	GuiControlGet eventMode
	GuiControlGet hotkey
	
	dismissed := true
	
	if activateSimulatorWindow(selectedSimulator)
		sendSimulatorCommand(["Event", "Input", "Play", "Raw", "Default"][eventMode], hotkey)
}

moveEventBufferTester() {
	moveByMouse("EBT")
}

exitEventBufferTester() {
	ExitApp 0
}

runEventBufferTester() {
	icon := kIconsDirectory . "Tools.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Event Buffer Tester

	Menu Tray, NoStandard
	Menu Tray, Add, Exit, Exit
	
	selectCommand()

	return

Exit:
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runEventBufferTester()