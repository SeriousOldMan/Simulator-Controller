;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Pitstop Test Program        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Engine.ico
;@Ahk2Exe-ExeName R3E Pitstop Tester.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EPitstopTester extends Plugin {
	iMessages := []
	
	iCommandMode := "Event"
	
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	iNextOptionHotkey := false
	
	iPSImageSearchArea := false
	iPitstopOptions := []
	iPitstopOptionStates := []
	
	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}
	
	ClosePitstopMFDHotkey[] {
		Get {
			return this.iClosePitstopMFDHotkey
		}
	}
	
	NextOptionHotkey[] {
		Get {
			return this.iNextOptionHotkey
		}
	}
	
	Messages[] {
		Get {
			return this.iMessages
		}
	}
	
	__New() {
		base.__New("R3E", kSimulatorConfiguration)
		
		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "S")
		
		SetKeyDelay 5, 15
	}
	
	logMessage(message) {
		this.Messages.Push(message)
	}
	
	activateR3EWindow() {
		window := "ahk_exe RRRE64.exe"
		
		if !WinActive(window)
			WinActivate %window%
		
		Sleep 2000
	}
	
	sendPitstopCommand(command) {
		switch this.iCommandMode {
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
		
		Sleep 20
	}
	
	pitstopMFDIsOpen() {
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.activateR3EWindow()
			
			return this.searchMFDImage("PITSTOP 1", "PITSTOP 2")
		}
		else
			return false
	}
		
	openPitstopMFD(descriptor := false) {
		static first := true
		static reported := false
		
		if !this.OpenPitstopMFDHotkey {
			if !reported {
				reported := true
			
				this.logMessage("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration")
			}
			
			return false
		}

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.activateR3EWindow()

			secondTry := false
			
			if first
				this.sendPitstopCommand(this.OpenPitstopMFDHotkey)
				
			if !this.pitstopMFDIsOpen() {
				this.activateR3EWindow()
				
				this.sendPitstopCommand(this.OpenPitstopMFDHotkey)
				
				secondTry := true
			}
			
			if (first && secondTry)
				this.pitstopMFDIsOpen()
			
			first := false
			
			return true
		}
		else
			return false
	}
	
	closePitstopMFD() {
		static reported := false
		
		this.activateR3EWindow()

		if this.pitstopMFDIsOpen() {
			if this.ClosePitstopMFDHotkey {
				this.sendPitstopCommand(this.ClosePitstopMFDHotkey)
				
				Sleep 50
			}
			else if !reported {
				reported := true
			
				this.logMessage("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration")
			}
		}
	}
	
	requirePitstopMFD() {
		if this.openPitstopMFD() {
			this.analyzePitstopMFD()
		
			return true
		}
		else
			return false
	}
	
	analyzePitstopMFD() {
		if (this.OpenPitstopMFDHotkey = "Off")
			return
		
		this.iPitstopOptions := []
		this.iPitstopOptionStates := []
		
		this.activateR3EWindow()

		loop 15
			this.sendPitstopCommand(this.NextOptionHotkey)
			
		if this.searchMFDImage("Strategy") {
			this.iPitstopOptions.Push("Strategy")
			this.iPitstopOptionStates.Push(true)
		}
		
		if this.searchMFDImage("Refuel") {
			this.iPitstopOptions.Push("Refuel")
			this.iPitstopOptionStates.Push(true)
		}
		else if (this.searchMFDImage("No Refuel")) {
			this.iPitstopOptions.Push("Refuel")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Front Tyre Change") {
			this.iPitstopOptions.Push("Change Front Tyres")
			this.iPitstopOptionStates.Push(true)
		}
		else { ; if this.searchMFDImage("No Front Tyre Change") {
			this.iPitstopOptions.Push("Change Front Tyres")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Rear Tyre Change") {
			this.iPitstopOptions.Push("Change Rear Tyres")
			this.iPitstopOptionStates.Push(true)
		}
		else { ; if this.searchMFDImage("No Rear Tyre Change") {
			this.iPitstopOptions.Push("Change Rear Tyres")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Bodywork Damage") {
			this.iPitstopOptions.Push("Repair Bodywork")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Bodywork Damage Selected") != false)
		}
		
		if this.searchMFDImage("Front Damage") {
			this.iPitstopOptions.Push("Repair Front Aero")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Front Damage Selected") != false)
		}
		
		if this.searchMFDImage("Rear Damage") {
			this.iPitstopOptions.Push("Repair Rear Aero")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Rear Damage Selected") != false)
		}
		
		if this.searchMFDImage("Suspension Damage") {
			this.iPitstopOptions.Push("Repair Suspension")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Suspension Damage Selected") != false)
		}
		
		if this.searchMFDImage("PIT REQUEST") {
			this.iPitstopOptions.Push("Request Pitstop")
			this.iPitstopOptionStates.Push(true)
		}
		else {
			this.iPitstopOptions.Push("Request Pitstop")
			this.iPitstopOptionStates.Push(false)
		}
		
		this.logMessage("Pit Menu State:")
		
		for index, option in this.iPitstopOptions
			this.logMessage("    " . option . " = " . (this.iPitstopOptionStates ? kTrue : kFalse))
	}
	
	getImageFileNames(imageNames*) {
		fileNames := []
		
		for ignore, imageName in imageNames {
			imageName := ("R3E\" . imageName)
			fileName := getFileName(imageName . ".png", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".jpg", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".png", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".jpg", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
		}
		
		if (fileNames.Length() == 0)
			this.logMessage("Unknown image '" . imageName . "' detected...")
		else {
			this.logMessage("Labels: " . values2String(", ", imageNames*) . "`nImages:`n    " . values2String("`n    ", fileNames*))
			
			return fileNames
		}
	}
	
	searchMFDImage(imageNames*) {
		static kSearchAreaLeft := 0
		static kSearchAreaRight := 400
		
		loop % imageNames.Length()
		{
			imageName := imageNames[A_Index]
			pitstopImages := this.getImageFileNames(imageName)
			
			this.activateR3EWindow()
			
			curTickCount := A_TickCount
			
			imageX := kUndefined
			imageY := kUndefined
			
			loop % pitstopImages.Length()
			{
				pitstopImage := pitstopImages[A_Index]
				
				if !this.iPSImageSearchArea {
					ImageSearch imageX, imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %pitstopImage%

					this.logMessage(substituteVariables("Full search for '%image%' took %ticks% ms", {image: imageName, ticks: A_TickCount - curTickCount}))
					
					if imageX is Integer
						if ((imageName = "PITSTOP 1") || (imageName = "PITSTOP 2"))
							this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
				}
				else {
					ImageSearch imageX, imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitstopImage%

					this.logMessage(substituteVariables("Fast search for '%image%' took %ticks% ms", {image: imageName, ticks: A_TickCount - curTickCount}))
				}
				
				if imageX is Integer
				{
					this.logMessage(substituteVariables("'%image%' found at %x%, %y%", {image: imageName, x: imageX, y: imageY}))
					
					return true
				}
			}
		}
		
		this.logMessage(substituteVariables("'%image%' not found", {image: imageName}))
		
		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Function Section                         ;;;
;;;-------------------------------------------------------------------------;;;

viewMessages(messages, title := "Search Result", x := "Center", y := "Center", width := 800, height := 400) {
	static hasWindow := false
	static dismissed := false
	
	static titleField
	static textField
	
	dismissed := false
	
	if !messages {
		dismissed := true
	
		return
	}
	
	text := values2String("`n", messages*)
	
	Gui MV:Default
	
	if hasWindow {
		GuiControl Text, titleField, %title%
		GuiControl Text, textField, %text%
		
		Gui MV:Show
	}
	else {
		hasWindow := true
	
		innerWidth := width - 16
		
		Gui MV:-Border -Caption
		Gui MV:Color, D0D0D0, D8D8D8
		Gui MV:Font, s10 Bold
		Gui MV:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveFileViewer, % translate("Modular Simulator Controller System")
		Gui MV:Font
		Gui MV:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans vtitleField, %title%
		
		editHeight := height - 102
		
		Gui MV:Add, Edit, X8 YP+26 W%innerWidth% H%editHeight% vtextField, % text
		
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
		
		Gui MV:Add, Button, Default X%buttonX% y+10 w80 gdismissFileViewer, % translate("Continue")
		Gui MV:Add, Button, Default XP+90 yp w80 gexitACCPitstopTester, % translate("Exit")
		
		Gui MV:+AlwaysOnTop
		Gui MV:Show, X%x% Y%y% W%width% H%height% NoActivate
	}
	
	while !dismissed
		Sleep 100
	
	Gui MV:Hide
}

moveFileViewer() {
	moveByMouse("MV")
}

dismissFileViewer() {
	viewMessages(false)
}

exitACCPitstopTester() {
	ExitApp 0
}

runR3EPitstopTester() {
	icon := kIconsDirectory . "Engine.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, R3E Pitstop Tester
	
	while true {
		pitstopTester := new R3EPitstopTester()
	
		pitstopTester.logMessage("Pass #1: Learning MFD position and labels...`n`n")
	
		pitstopTester.requirePitstopMFD()
		
		Sleep 1000
		
		pitstopTester.closePitstopMFD()
		
		viewMessages(pitstopTester.Messages, translate("Search - Pass #1"))
		
		pitstopTester.logMessage("`n`nPass #2: Fast label search...`n`n")
		
		pitstopTester.requirePitstopMFD()
		
		Sleep 1000
		
		pitstopTester.closePitstopMFD()
		
		viewMessages(pitstopTester.Messages, translate("Search - Pass #2"))
	}

	return
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runR3EPitstopTester()