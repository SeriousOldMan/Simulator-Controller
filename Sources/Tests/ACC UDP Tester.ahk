;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC UDP Test Program            ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Engine.ico
;@Ahk2Exe-ExeName ACC UDP Tester.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vUDPClient = false


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

viewFile(fileName, title := "", x := "Center", y := "Center", width := 800, height := 400) {
	static dismissed := false
	
	dismissed := false
	
	if !fileName {
		dismissed := true
	
		return
	}
	
	FileRead text, %fileName%
	
	innerWidth := width - 16
	
	Gui FV:-Border -Caption
	Gui FV:Color, D0D0D0, D8D8D8
	Gui FV:Font, s10 Bold
	Gui FV:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveFileViewer, % translate("Modular Simulator Controller System")
	Gui FV:Font
	Gui FV:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%
	
	editHeight := height - 102
	
	Gui FV:Add, Edit, X8 YP+26 W%innerWidth% H%editHeight%, % text
	
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
	
	Gui FV:Add, Button, Default X%buttonX% y+10 w80 gdismissFileViewer, % translate("Continue")
	Gui FV:Add, Button, Default XP+90 yp w80 gexitACCUDPTester, % translate("Exit")
	
	Gui FV:+AlwaysOnTop
	Gui FV:Show, X%x% Y%y% W%width% H%height% NoActivate
	
	while !dismissed
		Sleep 100
	
	Gui FV:Destroy
}

moveFileViewer() {
	moveByMouse("FV")
}

dismissFileViewer() {
	viewFile(false)
}

exitACCUDPTester() {
	ExitApp 0
}

startUDPClient() {
	exePath := kBinariesDirectory . "ACC UDP Provider.exe"
			
	try {
		if FileExist(kTempDirectory . "ACCUDP.cmd")
			FileDelete %kTempDirectory%ACCUDP.cmd
			
		if FileExist(kTempDirectory . "ACCUDP.out")
			FileDelete %kTempDirectory%ACCUDP.out
		
		Run %ComSpec% /c ""%exePath%" "%kTempDirectory%ACCUDP.cmd" "%kTempDirectory%ACCUDP.out"", , Hide, pid
		
		vUDPClient := "shutdownUDPClient"
		
		OnExit(vUDPClient)
	}
}

shutdownUDPClient() {
	FileAppend Exit, %kTempDirectory%ACCUDP.cmd
			
	OnExit(vUDPClient, 0)
	
	vUDPClient := false
}

readUDPData() {
	fileName := kTempDirectory . "ACCUDP.cmd"
		
	FileAppend Read, %fileName%
	
	tries := 10
	
	while FileExist(fileName) {
		Sleep 200
	
		if (--tries <= 0)
			break
	}
	
	if (tries > 0) {
		if FileExist(kTempDirectory . "ACCUDP.out.Trace") {
			viewFile(kTempDirectory . "ACCUDP.out", "Invalid - Error Trace")
			
			try
				FileDelete %kTempDirectory%ACCUDP.out.Trace
		}
		else
			viewFile(kTempDirectory . "ACCUDP.out", "Valid - Car Positions")
		
		return true
	}
	else {
		Process Exist, ACC UDP Provider.exe
	
		if ErrorLevel
			MsgBox No data returned - UDP provider is frozen...
		else
			MsgBox No data returned - UDP provider has crashed...
	
		return false
	}
}

runACCUDPTester() {
	icon := kIconsDirectory . "Engine.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, ACC UDP Tester
	
	startUDPClient()

	Sleep 5000

	Loop
		if !readUDPData()
			break
}

runACCUDPTester()