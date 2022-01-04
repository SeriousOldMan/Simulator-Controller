;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACCApplication = "Assetto Corsa Competizione"

global kACCPlugin = "ACC"
global kChatMode = "Chat"

global kFront = 0
global kRear = 1
global kLeft = 2
global kRight = 3
global kCenter = 4


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kPSMutatingOptions = ["Strategy", "Change Tyres", "Tyre Compound", "Change Brakes"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends RaceAssistantSimulatorPlugin {
	iUDPClient := false
	iUDPConnection := false
	
	iCommandMode := "Event"
	
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]
	
	iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
	iPSTyreOptions := 7
	iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
	iPSBrakeOptions := 2
		
	iPSIsOpen := false
	iPSSelectedOption := 1
	iPSChangeTyres := false
	iPSChangeBrakes := false
	
	iPSImageSearchArea := false
	
	iChatMode := false
	iPitstopMode := false
	
	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true
	
	class ChatMode extends ControllerMode {
		Mode[] {
			Get {
				return kChatMode
			}
		}
		
		updateActions(sessionState) {
		}
	}
	
	class ChatAction extends ControllerAction {
		iMessage := ""
		
		Message[] {
			Get {
				return this.iMessage
			}
		}
		
		__New(function, label, message) {
			this.iMessage := message
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			message := this.Message
			
			this.Controller.findPlugin(kACCPlugin).activateACCWindow()
			
			Send {Enter}
			Sleep 100
			Send %message%
			Sleep 100
			Send {Enter}
		}
	}
	
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
	
	UDPConnection[] {
		Get {
			return this.iUDPConnection
		}
	}
	
	UDPClient[] {
		Get {
			return this.iUDPClient
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iPitstopMode := this.findMode(kPitstopMode)
		
		if this.iChatMode
			this.registerMode(this.iChatMode)
		
		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		this.iUDPConnection := this.getArgumentValue("udpConnection", false)
		
		controller.registerPlugin(this)
	}
	
	loadFromConfiguration(configuration) {
		local function
		
		base.loadFromConfiguration(configuration)
		
		for descriptor, message in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			function := this.Controller.findFunction(descriptor)
			
			if (function != false) {
				message := string2Values("|", message)
			
				if !this.iChatMode
					this.iChatMode := new this.ChatMode(this)
				
				this.iChatMode.registerAction(new this.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Strategy: "Strategy", Refuel: "Refuel"
					 , TyreChange: "Change Tyres", TyreSet: "Tyre Set", TyreCompound: "Tyre Compound", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , BrakeChange: "Change Brakes", FrontBrake: "Front Brake", RearBrake: "Rear Brake"
					 , DriverSelect: "Select Driver"
					 , SuspensionRepair: "Repair Suspension", BodyworkRepair: "Repair Bodywork"}
		selectActions := ["TyreChange", "BrakeChange", "SuspensionRepair", "BodyworkRepair"]
	}
	
	startupUDPClient() {
		if !this.UDPClient {
			exePath := kBinariesDirectory . "ACC UDP Provider.exe"
			
			try {
				Loop 6 {
					Process Exist, ACC UDP Provider.exe
					
					if ErrorLevel {
						Process Close, %ErrorLevel%
						
						Sleep 250
					}
					else
						break
				}
				
				if FileExist(kTempDirectory . "ACCUDP.cmd")
					FileDelete %kTempDirectory%ACCUDP.cmd
					
				if FileExist(kTempDirectory . "ACCUDP.out")
					FileDelete %kTempDirectory%ACCUDP.out
				
				options := ""
				
				if this.UDPConnection
					options := ("-Connect " . this.UDPConnection)
				
				Run %ComSpec% /c ""%exePath%" "%kTempDirectory%ACCUDP.cmd" "%kTempDirectory%ACCUDP.out" %options%", , Hide, pid
				
				this.iUDPClient := ObjBindMethod(this, "shutdownUDPClient")
				
				OnExit(this.iUDPClient)
			}
			catch exception {
				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "ACC", protocol: "UDP"})
														   . exePath . translate(") - please rebuild the applications in the binaries folder (")
														   . kBinariesDirectory . translate(")"))
					
				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: "ACC", protocol: "UDP"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
	
	shutdownUDPClient() {
		if this.UDPClient {
			FileAppend Exit, %kTempDirectory%ACCUDP.cmd
			
			OnExit(this.iUDPClient, 0)

			Sleep 250
			
			Loop 5 {
				Process Exist, ACC UDP Provider.exe
				
				if ErrorLevel {
					Process Close, %ErrorLevel%
					
					Sleep 250
				}
				else
					break
			}
			
			this.iUDPClient := false
		}
		
		return false
	}
	
	requireUDPClient() {
		if !this.UDPClient
			this.startupUDPClient()
	}
	
	updateSessionState(sessionState) {
		base.updateSessionState(sessionState)
		
		activeModes := this.Controller.ActiveModes
		
		if (inList(activeModes, this.iChatMode))
			this.iChatMode.updateActions(sessionState)
		
		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(sessionState)
		
		if (sessionState == kSessionRace)
			this.startupUDPClient()
		
		if (sessionState == kSessionFinished) {
			this.iRepairSuspensionChosen := true
			this.iRepairBodyworkChosen := true
			
			this.shutdownUDPClient()
		}
	}
	
	updatePositionsData(data) {
		static carNames := false
		static lastDriverCar := false
		
		if (this.SessionState == kSessionRace)
			this.requireUDPClient()
		else if !this.UDPClient
			return
		
		if !carNames
			carNames := readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Model.ini")
		
		fileName := kTempDirectory . "ACCUDP.cmd"
		
		FileAppend Read, %fileName%
		
		tries := 10
		
		while FileExist(fileName) {
			Sleep 200
		
			if (--tries <= 0)
				break
		}
		
		if (tries > 0) {
			fileName := kTempDirectory . "ACCUDP.out"
			
			standings := readConfiguration(fileName)
			
			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}
			
			if (getConfigurationValue(data, "Stint Data", "Laps", 0) <= 1)
				lastDriverCar := false
				
			driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
			driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")
			
			lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
			
			driverCar := false
			
			Loop {
				carID := getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", kUndefined)
			
				if (carID == kUndefined)
					break
				else {
					car := getConfigurationValue(carNames, "Car Model", carID, "Unknown")
					
					if ((car = "Unknown") && isDebug())
						showMessage("Unknown car with ID " . carID . " detected...")
					 	
					setConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", car)
				
					if !driverCar {
						if ((getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
						 && (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)
						 && (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Nickname") = driverNickname))
							driverCar := A_Index
						else if (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Time") = lapTime)
							driverCar := A_index
					}
				}
			}
			
			if !driverCar
				driverCar := lastDriverCar
			else
				lastDriverCar := driverCar
			
			setConfigurationValue(standings, "Position Data", "Driver.Car", driverCar)
			setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
		}
		else {
			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}
			
			this.iUDPClient := false
		}
	}
	
	activateACCWindow() {
		window := this.Simulator.WindowTitle
		
		if !WinExist(window)
			if isDebug()
				showMessage("ACC not found...")
		
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
				this.iPSSelectedOption := 1
				
				if (update || !wasOpen) {
					if this.updatePitStopState()
						this.openPitstopMFD(false, false)
					
					SetTimer updatePitstopState, 5000
				}
			}
		}
		else if !reported {
			reported := true
		
			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
		
			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}
						
	closePitstopMFD() {
		static reported := false
		
		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.activateACCWindow()

				this.sendPitstopCommand(this.ClosePitstopMFDHotkey)
			
				this.iPSIsOpen := false
					
				SetTimer updatePitstopState, Off
			}
		}
		else if !reported {
			reported := true
		
			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
		
			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}
	
	requirePitstopMFD() {
		static reported := false
		
		this.openPitstopMFD()
		
		if (!this.iPSIsOpen && !reported && (this.OpenPitstopMFDHotkey != "Off")) {
			reported := true
			
			showMessage(translate("Cannot locate the Pitstop MFD - please read the Update 2.0 documentation...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
						  
		return this.iPSIsOpen
	}
	
	selectPitstopOption(option, retry := true) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			targetSelectedOption := inList(this.iPSOptions, option)
		
			if targetSelectedOption {
				delta := 0
				
				if (targetSelectedOption > this.iPSTyreOptionPosition) {
					if (targetSelectedOption <= (this.iPSTyreOptionPosition + this.iPSTyreOptions)) {
						if !this.iPSChangeTyres {
							this.toggleActivity("Change Tyres")
							
							return (retry && this.selectPitstopOption(option, false))
						}
					}
					else
						if !this.iPSChangeTyres
							delta -= this.iPSTyreOptions
				}
				
				if (targetSelectedOption > this.iPSBrakeOptionPosition) {
					if (targetSelectedOption <= (this.iPSBrakeOptionPosition + this.iPSBrakeOptions)) {
						if !this.iPSChangeBrakes {
							this.toggleActivity("Change Brakes")
							
							return (retry && this.selectPitstopOption(option, false))
						}
					}
					else
						if !this.iPSChangeBrakes
							delta -= this.iPSBrakeOptions
				}
				
				targetSelectedOption += delta
				
				if (targetSelectedOption > this.iPSSelectedOption)
					Loop % targetSelectedOption - this.iPSSelectedOption
					{
						this.activateACCWindow()

						this.sendPitstopCommand("{Down}")
						
						Sleep 50
					}
				else
					Loop % this.iPSSelectedOption - targetSelectedOption
					{
						this.activateACCWindow()

						this.sendPitstopCommand("{Up}")
						
						Sleep 50
					}
				
				this.iPSSelectedOption := targetSelectedOption
			
				return true
			}
			else
				return false
		}
		else
			return false
	}
	
	changePitstopOption(option, direction, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch direction {
				case "Increase":
					Loop % steps {
						this.activateACCWindow()

						this.sendPitstopCommand("{Right}")

						Sleep 50
					}
				case "Decrease":
					Loop % steps {
						this.activateACCWindow()

						this.sendPitstopCommand("{Left}")
						
						Sleep 50
					}
				default:
					Throw "Unsupported change operation """ . direction . """ detected in ACCPlugin.changePitstopOption..."
			}
						
			if (option = "Repair Suspension")
				this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
			else if (option = "Repair Bodywork")
				this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
			
			this.resetPitstopState(inList(kPSMutatingOptions, option))
		}
	}
	
	updatePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if inList(["Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension"], option)
				this.toggleActivity(option)
			else
				switch option {
					case "Strategy":
						this.changeStrategy(action, steps)
					case "Refuel":
						this.changeFuelAmount(action, steps)
					case "Tyre Compound":
						this.changeTyreCompound(action)
					case "Tyre Set":
						this.changeTyreSet(action, steps)
					case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
						this.changeTyrePressure(option, action, steps)
					case "Front Brake", "Rear Brake":
						this.changeBrakeType(option, action)
					case "Driver":
						this.changeDriver(action)
					default:
						base.updatePitstopOption(option, action, steps)
				}
		}
	}
	
	toggleActivity(activity) {
		if this.requirePitstopMFD()
			switch activity {
				case "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension":
					if this.selectPitstopOption(activity)
						this.changePitstopOption(activity, "Increase")
				default:
					Throw "Unsupported activity """ . activity . """ detected in ACCPlugin.toggleActivity..."
			}
	}

	changeStrategy(selection, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Strategy"))
			switch selection {
				case "Next":
					this.changePitstopOption("Strategy", "Increase")
				case "Previous":
					this.changePitstopOption("Strategy", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Strategy", selection)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeStrategy..."
			}
	}

	changeFuelAmount(direction, litres := 5) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Refuel"))
			this.changePitstopOption("Refuel", direction, litres)
	}
	
	changeTyreCompound(type) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre Compound"))
			switch type {
				case "Wet":
					this.changePitstopOption("Tyre Compound", "Increase")
				case "Dry":
					this.changePitstopOption("Tyre Compound", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Tyre Compound", type)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreCompound..."
			}
	}
	
	changeTyreSet(selection, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre set"))
			switch selection {
				case "Next":
					this.changePitstopOption("Tyre set", "Increase", steps)
				case "Previous":
					this.changePitstopOption("Tyre set", "Decrease", steps)
				case "Increase", "Decrease":
					this.changePitstopOption("Tyre Set", selection, steps)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreSet..."
			}
	}
	
	changeTyrePressure(tyre, direction, increments := 1) {
		if this.requirePitstopMFD() {
			found := false
		
			switch tyre {
				case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					found := this.selectPitstopOption(tyre)
				default:
					Throw "Unsupported tyre position """ . tyre . """ detected in ACCPlugin.changeTyrePressure..."
			}
			
			if found
				this.changePitstopOption(tyre, direction, increments)
		}
	}

	changeBrakeType(brake, selection) {
		if this.requirePitstopMFD() {
			found := false
		
			switch brake {
				case "Front Brake", "Rear Brake":
					found := this.selectPitstopOption(brake)
				default:
					Throw "Unsupported brake """ . brake . """ detected in ACCPlugin.changeBrakeType..."
			}
				
			if found
				switch selection {
					case "Next":
						this.changePitstopOption(brake, "Increase")
					case "Previous":
						this.changePitstopOption(brake, "Decrease")
					case "Increase", "Decrease":
						this.changePitstopOption(brake, selection)
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeBrakeType..."
				}
		}
	}

	changeDriver(selection) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Select Driver"))
			switch selection {
				case "Next":
					this.changePitstopOption("Strategy", "Increase")
				case "Previous":
					this.changePitstopOption("Strategy", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Strategy", selection)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeDriver..."
			}
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
			Throw "Unknown label '" . labelName . "' detected in ACCPlugin.getLabelFileName..."
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", labelNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.png", 5000)
			
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

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
			}
			else {
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitstopLabel%

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
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
		else {
			this.iPSIsOpen := false
			
			SetTimer updatePitstopState, Off
		}
		
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
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Strategy") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Pit Limiter") + 1, "Strategy")
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
			
			lastY := imageY
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			position := inList(this.iPSOptions, "Strategy")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
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
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			position := inList(this.iPSOptions, "Refuel")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
			
			lastY := imageY
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Refuel' not detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			if !inList(this.iPSOptions, "Refuel") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Change Tyres"), "Refuel")
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Refuel' detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
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
				this.iPSTyreOptions := 6
				
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
		}
		else {
			if !inList(this.iPSOptions, "Tyre Set") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Tyre Compound"), "Tyre Set")
				this.iPSTyreOptions := 7
				
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
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
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
	
		if imageX is Integer
		{
			this.iPSChangeTyres := true
			
			lastY := imageY
			
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Tyres are selected for change"))
		}
		else {
			this.iPSChangeTyres := false
			
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Tyres are not selected for change"))
		}
		
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
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
			else 
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
			
		if imageX is Integer
		{
			this.iPSChangeBrakes := true
			
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Brakes are selected for change"))
		}
		else {
			this.iPSChangeBrakes := false
			
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Brakes are not selected for change"))
		}
		
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
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
		
		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Select Driver") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Repair Suspension"), "Select Driver")
				
				reload := true
			}
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			position := inList(this.iPSOptions, "Select Driver")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
		
			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Select Driver' not detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		
		return reload
	}
	
	updatePitstopState(fromTimer := false) {
		if isACCRunning() {
			beginTickCount := A_TickCount
			lastY := 0
			images := []
			
			if (fromTimer || !this.iPSImageSearchArea)
				lastY := this.searchPitstopLabel(images)
			
			if (!fromTimer && this.iPSIsOpen) {
				reload := this.searchStrategyLabel(lastY, images)
				
				; reload := (this.searchNoRefuelLabel(lastY, images) || reload)
				
				reload := (this.searchTyreLabel(lastY, images) || reload)
				
				reload := (this.searchBrakeLabel(lastY, images) || reload)
	
				reload := (this.searchDriverLabel(lastY, images) || reload)
				
				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Complete update of pitstop state took ") . A_TickCount - beginTickCount . translate(" ms"))
				
				if isDebug()
					showMessage("Found images: " . values2String(", ", images*), "Pitstop MFD Image Search", "Information.png", 5000)
				
				return reload
			}
		}
		
		return false
	}
	
	resetPitstopState(update := false) {
		this.openPitstopMFD(false, update)
	}
	
	supportsPitstop() {
		return true
	}
	
	supportsSetupImport() {
		return true
	}
	
	getPitstopOptionValues(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option {
				case "Refuel":
					data := readSimulatorData(this.Code, "-Setup")
					
					return [getConfigurationValue(data, "Setup Data", "FuelAmount", 0)]
				case "Tyre Pressures":
					data := readSimulatorData(this.Code, "-Setup")
					
					return [getConfigurationValue(data, "Setup Data", "TyrePressureFL", 26.1), getConfigurationValue(data, "Setup Data", "TyrePressureFR", 26.1)
						  , getConfigurationValue(data, "Setup Data", "TyrePressureRL", 26.1), getConfigurationValue(data, "Setup Data", "TyrePressureRR", 26.1)]
				case "Tyre Set":
					data := readSimulatorData(this.Code, "-Setup")
					
					return [getConfigurationValue(data, "Setup Data", "TyreSet", 0)]
				case "Tyre Compound":
					data := readSimulatorData(this.Code, "-Setup")
					
					return [getConfigurationValue(data, "Setup Data", "TyreCompound", 0), getConfigurationValue(data, "Setup Data", "TyreCompoundColor", 0)]
				case "Repair Suspension":
					return [this.iRepairSuspensionChosen]
				case "Repair Bodywork":
					return [this.iRepairBodyworkChosen]
				default:
					return base.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}
	
	startPitstopSetup(pitstopNumber) {
		openPitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		litresIncrement := Round(litres - this.getPitstopOptionValues("Refuel")[1])

		if (litresIncrement != 0)
			changePitstopFuelAmount((litresIncrement > 0) ? "Increase" : "Decrease", Abs(litresIncrement))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if compound {
			changePitstopTyreCompound((compound = "Wet") ? "Increase" : "Decrease")
			
			tyreSetIncrement := Round(set - this.getPitstopOptionValues("Tyre Set")[1])
			
			if (compound = "Dry")
				changePitstopTyreSet((tyreSetIncrement > 0) ? "Next" : "Previous", Abs(tyreSetIncrement))
		}
		else if this.iPSChangeTyres
			this.toggleActivity("Change Tyres")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		pressures := this.getPitstopOptionValues("Tyre Pressures")
			
		pressureFLIncrement := Round(pressureFL - pressures[1], 1)
		pressureFRIncrement := Round(pressureFR - pressures[2], 1)
		pressureRLIncrement := Round(pressureRL - pressures[3], 1)
		pressureRRIncrement := Round(pressureRR - pressures[4], 1)
		
		if (pressureFLIncrement != 0)
			changePitstopTyrePressure("Front Left", (pressureFLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFLIncrement * 10)))
		if (pressureFRIncrement != 0)
			changePitstopTyrePressure("Front Right", (pressureFRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFRIncrement * 10)))
		if (pressureRLIncrement != 0)
			changePitstopTyrePressure("Rear Left", (pressureRLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRLIncrement * 10)))
		if (pressureRRIncrement != 0)
			changePitstopTyrePressure("Rear Right", (pressureRRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRRIncrement * 10)))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (repairSuspension != this.iRepairSuspensionChosen)
			this.toggleActivity("Repair Suspension")
			
		if (repairBodywork != this.iRepairBodyworkChosen)
			this.toggleActivity("Repair Bodywork")
	}
	
	restoreSessionState(sessionSettings, sessionState) {
		base.restoreSessionState(sessionSettings, sessionState)
		
		if sessionState {
			sessionState := getConfigurationSectionValues(sessionState, "Session State")
			
			if sessionState.HasKey("Pitstop.Last") {
				pitstop := sessionState["Pitstop.Last"]
				
				this.iRepairSuspensionChosen := sessionState["Pitstop." . pitstop . ".Repair.Suspension"]
				this.iRepairBodyworkChosen := sessionState["Pitstop." . pitstop . ".Repair.Bodywork"]
				
				if (this.iRepairSuspensionChosen = kTrue)
					this.iRepairSuspensionChosen := true
				else if (this.iRepairSuspensionChosen = kFalse)
					this.iRepairSuspensionChosen := false
				
				if (this.iRepairBodyworkChosen = kTrue)
					this.iRepairBodyworkChosen := true
				else if (this.iRepairBodyworkChosen = kFalse)
					this.iRepairBodyworkChosen := false
			}
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACCPlugin).Simulator, "Simulator Splash Images\ACC Splash.jpg")
}

stopACC() {
	if isACCRunning() {
		SimulatorController.Instance.findPlugin(kACCPlugin).activateACCWindow()
		
		MouseClick Left,  2093,  1052
		Sleep 500
		MouseClick Left,  2614,  643
		Sleep 500
		MouseClick Left,  2625,  619
		Sleep 500
	}
}

isACCRunning() {
	Process Exist, acc.exe
	
	running := (ErrorLevel != 0)
	
	if !running {
		try {
			thePlugin := SimulatorController.Instance.findPlugin("ACC")
			
			thePlugin.iRepairSuspensionChosen := true
			thePlugin.iRepairBodyworkChosen := true
		}
		catch exception {
			; ignore
		}
	}
		
	return running
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updatePitstopState() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).updatePitstopState(true)
	}
	finally {
		protectionOff()
	}
}

initializeACCPlugin() {
	local controller := SimulatorController.Instance
	
	new ACCPlugin(controller, kACCPLugin, kACCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()