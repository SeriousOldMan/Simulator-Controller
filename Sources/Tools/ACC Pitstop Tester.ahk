;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Pitstop Test Program        ;;;
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
;@Ahk2Exe-ExeName ACC Pitstop Tester.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vUDPClient = false


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPitstopTester extends Plugin {
	iMessages := []
	
	iCommandMode := "Event"
	
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	iImageMode := true
	
	iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]
	
	iPSIsOpen := false
	
	iPSImageSearchArea := false
	
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
	
	Messages[] {
		Get {
			return this.iMessages
		}
	}
	
	__New() {
		base.__New("ACC", kSimulatorConfiguration)
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
	}
	
	logMessage(message) {
		this.Messages.Push(message)
	}
	
	activateACCWindow() {
		window := "AC2"
		
		if !WinExist(window)
			if isDebug()
				this.logMessage("ACC not found...")
		
		if !WinActive(window)
			WinActivate %window%
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
	}
	
	openPitstopMFD(descriptor := false, update := true) {
		static reported := false
		
		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.activateACCWindow()

				this.sendPitstopCommand(this.OpenPitstopMFDHotkey)
				
				wasOpen := this.iPSIsOpen
				
				this.iPSIsOpen := true
				
				if this.iImageMode
					if (update || !wasOpen) {
						if this.updatePitStopState()
							this.openPitstopMFD(false, false)
					}
			}
		}
		else if !reported {
			reported := true
		
			this.logMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
		}
	}
						
	closePitstopMFD() {
		static reported := false
		
		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.activateACCWindow()

				this.sendPitstopCommand(this.ClosePitstopMFDHotkey)
			
				this.iPSIsOpen := false
			}
		}
		else if !reported {
			reported := true
		
			this.logMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
		}
	}
	
	requirePitstopMFD() {
		static reported := false
		
		this.openPitstopMFD()
		
		if (!this.iPSIsOpen && !reported && (this.OpenPitstopMFDHotkey != "Off")) {
			reported := true
			
			this.logMessage(translate("Cannot locate the Pitstop MFD - please consult the documentation for the ACC plugin"))
			
			SoundPlay %kResourcesDirectory%Sounds\Critical.wav
			
			this.iImageMode := false
			
			this.activateACCWindow()
			
			this.iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
							  , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
							  , "Change Brakes", "Front Brake", "Rear Brake", "Select Driver", "Repair Suspension", "Repair Bodywork"]
				
			return true
		}
		else if reported
			return true
		else if (this.OpenPitstopMFDHotkey == "Off")
			return false
		else
			return this.iPSIsOpen
	}
	
	getLabelFileNames(labelNames*) {
		fileNames := []
		
		for ignore, labelName in labelNames {
			labelName := ("ACC\" . labelName)
			fileName := getFileName(labelName . ".png", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(labelName . ".jpg", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(labelName . ".png", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(labelName . ".jpg", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
		}
		
		if (fileNames.Length() == 0)
			this.logMessage("Label file '" . labelName . "' not found...")
		else {
			this.logMessage("Labels: " . values2String(", ", labelNames*) . "; Images: " . values2String(", ", fileNames*))
			
			return fileNames
		}
	}
	
	markFoundLabel(image, x, y) {
		if isDebug() {
			SplitPath image, fileName
			
			Gui LABEL:-Border -Caption +AlwaysOnTop
			Gui LABEL:Color, D0D0D0, D8D8D8
			Gui LABEL:Add, Text, x0 y0 w100 h23 +0x200 +0x1 BackgroundTrans, %fileName%
			
			Gui LABEL:Show, AutoSize x%x%, y%y%
			
			Sleep 1000
			
			Gui LABEL:Destroy
		}
	}
	
	searchPitstopLabel(images) {
		static kSearchAreaLeft := 350
		static kSearchAreaRight := 250
		static pitstopLabels := false
		
		if !pitstopLabels
			pitstopLabels := this.getLabelFileNames("PITSTOP")
		
		this.activateACCWindow()
		
		curTickCount := A_TickCount
		
		imageX := kUndefined
		imageY := kUndefined
		
		Loop % pitstopLabels.Length()
		{
			pitstopLabel := pitstopLabels[A_Index]
			
			if !this.iPSImageSearchArea {
				ImageSearch imageX, imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %pitstopLabel%

				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
			}
			else {
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitstopLabel%

				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
			}
			
			if imageX is Integer
			{
				if isDebug() {
					images.Push(pitstopLabel)
					
					this.markFoundLabel(pitstopLabel, imageX, imageY)
				}
			
				break
			}
		}
		
		lastY := false
		
		if imageX is Integer
		{
			lastY := imageY
			
			if !this.iPSImageSearchArea
				this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
		}
		else
			this.iPSIsOpen := false
		
		return lastY
	}
	
	searchStrategyLabel(ByRef lastY, images) {
		static pitStrategyLabels := false
		curTickCount := A_TickCount
		reload := false
		
		if !pitStrategyLabels
			pitStrategyLabels := this.getLabelFileNames("Pit Strategy 1", "Pit Strategy 2")
		
		this.activateACCWindow()

		imageX := kUndefined
		imageY := kUndefined
		
		Loop % pitStrategyLabels.Length()
		{
			pitStrategyLabel := pitStrategyLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %pitStrategyLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitStrategyLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(pitStrategyLabel)
					
					this.markFoundLabel(pitStrategyLabel, imageX, imageY)
				}
			
				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
			else
				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Strategy") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Pit Limiter") + 1, "Strategy")
				
				reload := true
			}
			
			lastY := imageY
		
			this.logMessage(translate("'Pit Strategy' detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			position := inList(this.iPSOptions, "Strategy")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
		
			this.logMessage(translate("'Pit Strategy' not detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		
		return reload
	}
	
	searchNoRefuelLabel(ByRef lastY, images) {
		static noRefuelLabels := false
		curTickCount := A_TickCount
		reload := false
		
		if !noRefuelLabels
			noRefuelLabels := this.getLabelFileNames("No Refuel")
		
		this.activateACCWindow()

		imageX := kUndefined
		imageY := kUndefined
		
		Loop % noRefuelLabels.Length()
		{
			noRefuelLabel := noRefuelLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *25 %noRefuelLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *25 %noRefuelLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(noRefuelLabel)
					
					this.markFoundLabel(noRefuelLabel, imageX, imageY)
				}
			
				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
			else
				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			position := inList(this.iPSOptions, "Refuel")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
			
			lastY := imageY
		
			this.logMessage(translate("'Refuel' not detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			if !inList(this.iPSOptions, "Refuel") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Change Tyres"), "Refuel")
				
				reload := true
			}
		
			this.logMessage(translate("'Refuel' detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		
		return reload
	}
	
	searchTyreLabel(ByRef lastY, images) {
		static wetLabels := false
		static compoundLabels := false
		curTickCount := A_TickCount
		reload := false
		
		if !wetLabels {
			wetLabels := this.getLabelFileNames("Wet 1", "Wet 2")
			compoundLabels := this.getLabelFileNames("Compound 1", "Compound 2")
		}
		
		this.activateACCWindow()
		
		imageX := kUndefined
		imageY := kUndefined
		
		Loop % wetLabels.Length()
		{
			wetLabel := wetLabels[A_Index]
				
			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %wetLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %wetLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(wetLabel)
					
					this.markFoundLabel(wetLabel, imageX, imageY)
				}
			
				break
			}
		}
		
		if imageX is Integer
		{
			position := inList(this.iPSOptions, "Tyre Set")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
		}
		else {
			if !inList(this.iPSOptions, "Tyre Set") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Tyre Compound"), "Tyre Set")
				
				reload := true
			}
			
			imageX := kUndefined
			imageY := kUndefined
			
			Loop % compoundLabels.Length()
			{
				compoundLabel := compoundLabels[A_Index]
				
				if !this.iPSImageSearchArea
					ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %compoundLabel%
				else
					ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %compoundLabel%
				
				if imageX is Integer
				{
					if isDebug() {
						images.Push(compoundLabel)
						
						this.markFoundLabel(compoundLabel, imageX, imageY)
					}
				
					break
				}
			}
		}
		
		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
			else
				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
	
		if imageX is Integer
		{
			lastY := imageY
			
			this.logMessage(translate("Pitstop: Tyres are selected for change"))
		}
		else
			this.logMessage(translate("Pitstop: Tyres are not selected for change"))
		
		return reload
	}
	
	searchBrakeLabel(ByRef lastY, images) {
		static frontBrakeLabels := false
		curTickCount := A_TickCount
		reload := false
		
		if !frontBrakeLabels
			frontBrakeLabels := this.getLabelFileNames("Front Brake 1", "Front Brake 2")
		
		this.activateACCWindow()
		
		imageX := kUndefined
		imageY := kUndefined
		
		Loop % frontBrakeLabels.Length()
		{
			frontBrakeLabel := frontBrakeLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %frontBrakeLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %frontBrakeLabel%
			
			if imageX is Integer
			{
				if isDebug() {
					images.Push(frontBrakeLabel)
					
					this.markFoundLabel(frontBrakeLabel, imageX, imageY)
				}
			
				break
			}
		}
		
		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
			else 
				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
			this.logMessage(translate("Pitstop: Brakes are selected for change"))
		else
			this.logMessage(translate("Pitstop: Brakes are not selected for change"))
		
		return reload
	}
	
	searchDriverLabel(ByRef lastY, images) {
		static selectDriverLabels := false
		curTickCount := A_TickCount
		reload := false
		
		if !selectDriverLabels
			selectDriverLabels := this.getLabelFileNames("Select Driver 1", "Select Driver 2")
		
		this.activateACCWindow()
		
		imageX := kUndefined
		imageY := kUndefined
		
		Loop % selectDriverLabels.Length()
		{
			selectDriverLabel := selectDriverLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %selectDriverLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %selectDriverLabel%
		
			if imageX is Integer
			{
				if isDebug() {
					images.Push(selectDriverLabel)
					
					this.markFoundLabel(selectDriverLabel, imageX, imageY)
				}
			
				break
			}
		}
		
		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				this.logMessage(substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
			else
				this.logMessage(substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Select Driver") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Repair Suspension"), "Select Driver")
				
				reload := true
			}
		
			this.logMessage(translate("'Select Driver' detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			position := inList(this.iPSOptions, "Select Driver")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
		
			this.logMessage(translate("'Select Driver' not detected, adjusting pitstop options: " . values2String(", ", this.iPSOptions*)))
		}
		
		return reload
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

runACCPitstopTester() {
	icon := kIconsDirectory . "Engine.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, ACC Pitstop Tester
	
	while true {
		pitstopTester := new ACCPitstopTester()
	
		pitstopTester.requirePitstopMFD()
		
		Sleep 1000
		
		pitstopTester.closePitstopMFD()
		
		viewMessages(pitstopTester.Messages, "Search - First Run")
		
		pitstopTester.requirePitstopMFD()
		
		Sleep 1000
		
		pitstopTester.closePitstopMFD()
		
		viewMessages(pitstopTester.Messages, "Search - Second Run")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

runACCPitstopTester()