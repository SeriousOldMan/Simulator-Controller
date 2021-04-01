;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACCApplication = "Assetto Corsa Competizione"

global kACCPlugin = "ACC"
global kChatMode = "Chat"
global kPitstopMode = "Pitstop"

global kFront = 0
global kRear = 1
global kLeft = 2
global kRight = 3
global kCenter = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends ControllerPlugin {
	kOpenPitstopMFDHotkey := false
	kClosePitstopMFDHotkey := false
	kPSMutatingOptions := ["Strategy", "Change Tyres", "Compound", "Change Brakes"]
	
	iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
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
	
	iRaceEngineer := false
	
	iSessionState := kSessionFinished
	
	class ChatMode extends ControllerMode {
		Mode[] {
			Get {
				return kChatMode
			}
		}
		
		updateActions(sessionState) {
		}
	}
	
	class PitstopMode extends ControllerMode {
		Mode[] {
			Get {
				return kPitstopMode
			}
		}
	
		activate() {
			base.activate()
			
			this.updateActions(this.Plugin.SessionState)
		}
		
		updateActions(sessionState) {
			this.updatePitstopActions(sessionState)
			this.updateRaceEngineerActions(sessionState)
		}			
			
		updatePitstopActions(sessionState) {	
			for ignore, theAction in this.Actions
				if isInstance(theAction, ACCPlugin.PitstopAction)
					if ((sessionState != kSessionFinished) && (sessionState != kSessionPaused)) {
						theAction.Function.enable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label))
					}
					else {
						theAction.Function.disable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label), "Gray")
					}
		}
		
		updateRaceEngineerActions(sessionState) {
			if !this.RaceEngineer
				sessionState := kSessionFinished
			
			for ignore, theAction in this.Actions
				if isInstance(theAction, ACCPlugin.RaceEngineerAction)
					if ((sessionState != kSessionFinished) && (sessionState != kSessionPaused)) {
						theAction.Function.enable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label))
					}
					else {
						theAction.Function.disable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label), "Gray")
					}
		}
	}
	
	class PitstopAction extends ControllerAction {
		iPitstopOption := false
		iSteps := 1
		
		Option[] {
			Get {
				return this.iPitstopOption
			}
		}
		
		Steps[] {
			Get {
				return this.iSteps
			}
		}
		
		__New(function, label, pitstopOption, steps := 1, moreArguments*) {
			this.iPitstopOption := pitstopOption
			this.iSteps := steps
			
			if (moreArguments.Length() > 0)
				Throw "Unsupported arguments (" . values2String(", ", moreArguments*) . ") detected in PitstopAction.__New"
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kACCPlugin)
			
			return (plugin.requirePitstopMFD() && plugin.selectPitstopOption(this.iPitstopOption))
		}
	}

	class PitstopChangeAction extends ACCPlugin.PitstopAction {
		iDirection := false
		
		__New(function, label, pitstopOption, direction, moreArguments*) {
			this.iDirection := direction
			
			base.__New(function, label, pitstopOption, moreArguments*)
		}
		
		fireAction(function, trigger) {
			if base.fireAction(function, trigger)
				this.Controller.findPlugin(kACCPlugin).changePitstopOption(this.Option, this.iDirection, this.Steps)
		}
	}
	
	class PitstopSelectAction extends ACCPlugin.PitstopChangeAction {
		__New(function, label, pitstopOption, moreArguments*) {
			base.__New(function, label, pitstopOption, "Increase", moreArguments*)
		}
	}

	class PitstopToggleAction extends ACCPlugin.PitstopAction {		
		fireAction(function, trigger) {
			if base.fireAction(function, trigger)
				if ((trigger == "On") || (trigger == "Increase") || (trigger == "Push") || (trigger == "Call"))
					this.Controller.findPlugin(kACCPlugin).changePitstopOption(this.Option, "Increase", this.Steps)
				else
					this.Controller.findPlugin(kACCPlugin).changePitstopOption(this.Option, "Decrease", this.Steps)
		}
	}

	class RaceEngineerAction extends ControllerAction {
		iAction := false
		
		Action[] {
			Get {
				return this.iAction
			}
		}
		
		__New(function, label, action) {
			this.iAction := action
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kACCPlugin)
			
			if plugin.RaceEngineer
				switch this.Action {
					case "PitstopPlan":
						plugin.planPitstop()
					case "PitstopPrepare":
						plugin.preparePitstop()
					default:
						Throw "Invalid action """ . this.Action . """ detected in RaceEngineerAction.fireAction...."
				}
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
			
			IfWinNotActive AC2, , WinActivate, AC2
			WinWaitActive AC2, , 2
			
			Send {Enter}
			Sleep 100
			Send %message%
			Sleep 100
			Send {Enter}
		}
	}
	
	Code[] {
		Get {
			return "ACC"
		}
	}
	
	OpenPitstopMFDHotkey[] {
		Get {
			return this.kOpenPitstopMFDHotkey
		}
	}
	
	ClosePitstopMFDHotkey[] {
		Get {
			return this.kClosePitstopMFDHotkey
		}
	}
	
	RaceEngineer[] {
		Get {
			return this.iRaceEngineer
		}
	}
	
	SessionState[] {
		Get {
			return this.iSessionState
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iChatMode := new this.ChatMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iChatMode)
		
		this.kOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.kClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("pitstopSettings", ""))
			this.createPitstopAction(controller, string2Values(A_Space, theAction)*)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("raceEngineerCommands", ""))
			this.createRaceEngineerAction(controller, string2Values(A_Space, theAction)*)
		
		controller.registerPlugin(this)
	}
	
	loadFromConfiguration(configuration) {
		local function
		
		base.loadFromConfiguration(configuration)
		
		for descriptor, message in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			function := this.Controller.findFunction(descriptor)
			
			if (function != false) {
				message := string2Values("|", message)
			
				this.iChatMode.registerAction(new this.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}
	
	createRaceEngineerAction(controller, action, actionFunction) {
		local function := controller.findFunction(actionFunction)
		static mode := false
			
		if (mode == false) {
			mode := this.iPitstopMode
		
			if (mode == false) {
				mode := new this.PitstopMode(this)
				
				this.iPitstopMode := mode
			}
		}
		
		if (function != false) {
			if ((action = "PitstopPlan") || (action = "PitstopPrepare"))
				mode.registerAction(new this.RaceEngineerAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
			else
				logMessage(kLogWarn, translate("Action """) . action . translate(""" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
		}
		else
			this.logFunctionNotFound(actionFunction)
	}
	
	createPitstopAction(controller, action, increaseFunction, moreArguments*) {
		static kActions := {Strategy: "Strategy", Refuel: "Refuel"
						  , TyreChange: "Change Tyres", TyreSet: "Tyre Set", TyreCompound: "Compound", TyreAllAround: "All Around"
						  , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
						  , BrakeChange: "Change Brakes", FrontBrake: "Front Brake", RearBrake: "Rear Brake"
						  , DriverSelect: "Select Driver"
						  , SuspensionRepair: "Repair Suspension", BodyworkRepair: "Repair Bodywork"}
		static kSelectActions := ["TyreChange", "BrakeChange", "SuspensionRepair", "BodyworkRepair"]
		static mode := false
		local function
		
		if kActions.HasKey(action) {
			decreaseFunction := false
			
			if (moreArguments.Length() > 0) {
				decreaseFunction := moreArguments[1]
				
				if (controller.findFunction(decreaseFunction) != false)
					moreArguments.RemoveAt(1)
				else
					decreaseFunction := false
			}
			
			function := controller.findFunction(increaseFunction)
			
			if (mode == false) {
				mode := this.iPitstopMode
			
				if (mode == false) {
					mode := new this.PitstopMode(this)
					
					this.iPitstopMode := mode
				}
			}
			
			if !decreaseFunction {
				if (function != false)
					if (inList(kSelectActions, action))
						mode.registerAction(new this.PitstopSelectAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action), kActions[action], moreArguments*))
					else
						mode.registerAction(new this.PitstopToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action), kActions[action], moreArguments*))
				else
					this.logFunctionNotFound(increaseFunction)
			}
			else {
				if (function != false)
					mode.registerAction(new this.PitstopChangeAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Increase"), action), kActions[action], "Increase", moreArguments*))
				else
					this.logFunctionNotFound(increaseFunction)
					
				function := controller.findFunction(decreaseFunction)
				
				if (function != false)
					mode.registerAction(new this.PitstopChangeAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Decrease"), action), kActions[action], "Decrease", moreArguments*))
				else
					this.logFunctionNotFound(decreaseFunction)
			}
		}
		else
			logMessage(kLogWarn, translate("Pitstop action ") . action . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}
	
	runningSimulator() {
		return (isACCRunning() ? kACCApplication : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (simulator = kACCApplication) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
		
			if (raceEngineer && raceEngineer.isActive())
				raceEngineer.startSimulation(this)
			
			if (inList(this.Simulators, simulator)) {
				this.Controller.setMode(this.iChatMode)
			}
		}
	}
	
	simulatorShutdown(simulator) {
		base.simulatorShutdown()
		
		if (simulator = kACCApplication) {
			raceEngineer := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)
			
			if (raceEngineer && raceEngineer.isActive() && (raceEngineer.Simulator == this))
				raceEngineer.stopSimulation(this)
			
			this.updateSessionState(kSessionFinished)
			
			activeModes := this.Controller.ActiveModes
			
			if inList(activeModes, this.iChatMode)
				this.iChatMode.deactivate()
			else if inList(activeModes, this.iPitstopMode)
				this.iPitstopMode.deactivate()
		}
	}
	
	updateSessionState(sessionState) {
		this.iSessionState := sessionState
		
		activeModes := this.Controller.ActiveModes
		
		if (inList(activeModes, this.iChatMode))
			this.iChatMode.updateActions(sessionState)
		
		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(sessionState)
	}
		
	openPitstopMFD(update := true) {
		static reported := false
		
		IfWinNotActive AC2, , WinActivate, AC2 
		WinWaitActive AC2, , 2

		if this.OpenPitstopMFDHotkey {
			SendEvent % this.OpenPitstopMFDHotkey
					
			wasOpen := this.iPSIsOpen
			
			this.iPSIsOpen := true
			this.iPSSelectedOption := 1
			
			if (update || !wasOpen) {
				if this.updatePitStopState()
					this.openPitstopMFD(false)
				
				SetTimer updatePitstopState, 5000
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
		
		IfWinNotActive AC2, , WinActivate, AC2
		WinWaitActive AC2, , 2

		if this.ClosePitstopMFDHotkey {
			SendEvent % this.ClosePitstopMFDHotkey
		
			this.iPSIsOpen := false
				
			SetTimer updatePitstopState, Off
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
		
		if (!this.iPSIsOpen && !reported) {
			reported := true
			
			showMessage(translate("Cannot locate the Pitstop MFD - please read the Update 2.0 documentation...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
						  
		return this.iPSIsOpen
	}
	
	selectPitstopOption(option, retry := true) {
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
					IfWinNotActive AC2, , WinActivate, AC2
					WinWaitActive AC2, , 2

					SendEvent {Down}
					
					Sleep 50
				}
			else
				Loop % this.iPSSelectedOption - targetSelectedOption
				{
					IfWinNotActive AC2, , WinActivate, AC2
					WinWaitActive AC2, , 2

					SendEvent {Up}
					
					Sleep 50
				}
			
			this.iPSSelectedOption := targetSelectedOption
		
			return true
		}
		else
			return false
	}
	
	changePitstopOption(option, direction, steps := 1) {
		switch direction {
			case "Increase":
				Loop % steps {
					IfWinNotActive AC2, , WinActivate, AC2
					WinWaitActive AC2, , 2

					SendEvent {Right}

					Sleep 50
				}
			case "Decrease":
				Loop % steps {
					IfWinNotActive AC2, , WinActivate, AC2
					WinWaitActive AC2, , 2

					SendEvent {Left}
					
					Sleep 50
				}
			default:
				Throw "Unsupported change operation """ . direction . """ detected in ACCPlugin.changePitstopOption..."
		}
		
		this.resetPitstopState(inList(this.kPSMutatingOptions, option))
	}
	
	toggleActivity(activity) {
		if this.requirePitstopMFD()
			switch activity {
				case "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension":
					if this.selectPitstopOption(activity) {
						this.changePitstopOption(activity, "Increase")
						
						if (activity = "Repair Suspension")
							this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
						else if (activity = "Repair Bodywork")
							this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
					}
				default:
					Throw "Unsupported activity """ . activity . """ detected in ACCPlugin.toggleActivity..."
			}
	}

	changeStrategy(selection, steps := 1) {
		if this.requirePitstopMFD()
			if this.selectPitstopOption("Strategy")
				switch selection {
					case "Next":
						this.changePitstopOption("Strategy", "Increase")
					case "Previous":
						this.changePitstopOption("Strategy", "Decrease")
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeStrategy..."
				}
	}

	changeFuelAmount(direction, liters := 5) {
		if this.requirePitstopMFD()
			if this.selectPitstopOption("Refuel")
				this.changePitstopOption("Refuel", direction, liters)
	}
	
	changeTyreSet(selection, steps := 1) {
		if this.requirePitstopMFD()
			if this.selectPitstopOption("Tyre set")
				switch selection {
					case "Next":
						this.changePitstopOption("Tyre set", "Increase", steps)
					case "Previous":
						this.changePitstopOption("Tyre set", "Decrease", steps)
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreSet..."
				}
	}
	
	changeTyreCompound(type) {
		if this.requirePitstopMFD()
			if this.selectPitstopOption("Compound")
				switch type {
					case "Wet":
						this.changePitstopOption("Compound", "Increase")
					case "Dry":
						this.changePitstopOption("Compound", "Decrease")
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreCompound..."
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
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeBrakeType..."
				}
		}
	}

	changeDriver(selection) {
		if this.requirePitstopMFD()
			if this.selectPitstopOption("Select Driver")
				switch selection {
					case "Next":
						this.changePitstopOption("Strategy", "Increase")
					case "Previous":
						this.changePitstopOption("Strategy", "Decrease")
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
			Throw "Unknonw label '" . labelName . "' detected in ACCPlugin.getLabelFileName..."
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", labelNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.png", 5000)
			
			return fileNames
		}
	}
	
	searchPitstopLabel(images) {
		static kSearchAreaLeft := 350
		static kSearchAreaRight := 250
		static pitstopLabels := false
		
		if !pitstopLabels
			pitstopLabels := this.getLabelFileNames("PITSTOP")
		
		curTickCount := A_TickCount
		
		x := kUndefined
		y := kUndefined
		
		Loop % pitstopLabels.Length()
		{
			pitstopLabel := pitstopLabels[A_Index]
			
			if !this.iPSImageSearchArea {
				ImageSearch x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %pitstopLabel%

				logMessage(kLogInfo, translate("Full search for 'PITSTOP' took ") . (A_TickCount - curTickCount) . translate(" ms"))
			}
			else {
				ImageSearch x, y, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitstopLabel%

				logMessage(kLogInfo, translate("Optimized search for 'PITSTOP' took ") . (A_TickCount - curTickCount) . translate(" ms"))
			}
			
			if x is Integer
			{
				images.Push(pitstopLabel)
			
				break
			}

		}
		
		lastY := false
		
		if x is Integer
		{
			lastY := y
			
			if !this.iPSImageSearchArea
				this.iPSImageSearchArea := [Max(0, x - kSearchAreaLeft), 0, Min(x + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
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

		x := kUndefined
		y := kUndefined
		
		Loop % pitStrategyLabels.Length()
		{
			pitStrategyLabel := pitStrategyLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %pitStrategyLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitStrategyLabel%

			if x is Integer
			{
				images.Push(pitStrategyLabel)
			
				break
			}
		}

		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Pit Strategy' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Pit Strategy' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		
		if x is Integer
		{
			if !inList(this.iPSOptions, "Strategy") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Pit Limiter") + 1, "Strategy")
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
			
			lastY := y
		
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

		x := kUndefined
		y := kUndefined
		
		Loop % noRefuelLabels.Length()
		{
			noRefuelLabel := noRefuelLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *25 %noRefuelLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *25 %noRefuelLabel%

			if x is Integer
			{
				images.Push(noRefuelLabel)
			
				break
			}
		}

		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Refuel' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Refuel' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		
		if x is Integer
		{
			position := inList(this.iPSOptions, "Refuel")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
			
			lastY := y
		
			logMessage(kLogInfo, translate("'Refuel' not detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			if !inList(this.iPSOptions, "Refuel") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Change Tyres"), "Refuel")
				
				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
		
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
		
		x := kUndefined
		y := kUndefined
		
		Loop % wetLabels.Length()
		{
			wetLabel := wetLabels[A_Index]
				
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %wetLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %wetLabel%

			if x is Integer
			{
				images.Push(wetLabel)
			
				break
			}
		}
		
		if x is Integer
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
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Compound"), "Tyre Set")
				this.iPSTyreOptions := 7
				
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
				
				reload := true
			}
			
			x := kUndefined
			y := kUndefined
			
			Loop % compoundLabels.Length()
			{
				compoundLabel := compoundLabels[A_Index]
				
				if !this.iPSImageSearchArea
					ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %compoundLabel%
				else
					ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %compoundLabel%
				
				if x is Integer
				{
					images.Push(compoundLabel)
				
					break
				}
			}
		}
		
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Tyre set' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Tyre set' took ") . (A_TickCount - curTickCount) . translate(" ms"))
	
		if x is Integer
		{
			this.iPSChangeTyres := true
			
			lastY := y
			
			logMessage(kLogInfo, translate("Pitstop: Tyres are selected for change"))
		}
		else {
			this.iPSChangeTyres := false
			
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
		
		x := kUndefined
		y := kUndefined
		
		Loop % frontBrakeLabels.Length()
		{
			frontBrakeLabel := frontBrakeLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %frontBrakeLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %frontBrakeLabel%
			
			if x is Integer
			{
				images.Push(frontBrakeLabel)
			
				break
			}
		}
		
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Front Brake' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		else 
			logMessage(kLogInfo, translate("Optimized search for 'Front Brake' took ") . (A_TickCount - curTickCount) . translate(" ms"))
			
		if x is Integer
		{
			this.iPSChangeBrakes := true
			
			logMessage(kLogInfo, translate("Pitstop: Brakes are selected for change"))
		}
		else {
			this.iPSChangeBrakes := false
			
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
		
		x := kUndefined
		y := kUndefined
		
		Loop % selectDriverLabels.Length()
		{
			selectDriverLabel := selectDriverLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %selectDriverLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %selectDriverLabel%
		
			if x is Integer
			{
				images.Push(selectDriverLabel)
			
				break
			}
		}
		
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Select Driver' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Select Driver' took ") . (A_TickCount - curTickCount) . translate(" ms"))
		
		if x is Integer
		{
			if !inList(this.iPSOptions, "Select Driver") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Repair Suspension"), "Select Driver")
				
				reload := true
			}
		
			logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pit stop options: " . values2String(", ", this.iPSOptions*)))
		}
		else {
			position := inList(this.iPSOptions, "Select Driver")
			
			if position {
				this.iPSOptions.RemoveAt(position)
				
				reload := true
			}
		
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
				
				reload := (this.searchNoRefuelLabel(lastY, images) || reload)
				
				reload := (this.searchTyreLabel(lastY, images) || reload)
				
				reload := (this.searchBrakeLabel(lastY, images) || reload)
	
				reload := (this.searchDriverLabel(lastY, images) || reload)
				
				logMessage(kLogInfo, translate("Complete update of pitstop state took ") . A_TickCount - beginTickCount . translate(" ms"))
				
				if isDebug()
					showMessage("Found images: " . values2String(", ", images*), "Pitstop MFD Image Search", "Information.png", 5000)
				
				return reload
			}
		}
		
		return false
	}
	
	resetPitstopState(update := false) {
		this.openPitstopMFD(update)
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	pitstopPlanned(pitstopNumber) {
	}
	
	pitstopPrepared(pitstopNumber) {
	}
	
	pitstopFinished(pitstopNumber) {
	}
	
	startPitstopSetup(pitstopNumber) {
		openPitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		data := readSharedMemory(this.Code, kUserHomeDirectory . "Temp\ACC Data\Pitstop Setup.data")
		
		litresIncrement := Round(litres - getConfigurationValue(data, "Pitstop Data", "FuelAmount", 0))
		
		changePitstopFuelAmount((litresIncrement > 0) ? "Increase" : "Decrease", Abs(litresIncrement))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, set := false) {
		changePitstopTyreCompound(compound)
		
		data := readSharedMemory(this.Code, kUserHomeDirectory . "Temp\ACC Data\Pitstop Setup.data")
		
		tyreSetIncrement := Round(set - getConfigurationValue(data, "Pitstop Data", "TyreSet", 0))
		
		if (compound = "Dry")
			changePitstopTyreSet((tyreSetIncrement > 0) ? "Next" : "Previous", Abs(tyreSetIncrement))
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		data := readSharedMemory(this.Code, kUserHomeDirectory . "Temp\ACC Data\Pitstop Setup.data")
			
		pressureFLIncrement := Round(pressureFL - getConfigurationValue(data, "Pitstop Data", "TyrePressureFL", 26.1), 1)
		pressureFRIncrement := Round(pressureFR - getConfigurationValue(data, "Pitstop Data", "TyrePressureFR", 26.1), 1)
		pressureRLIncrement := Round(pressureRL - getConfigurationValue(data, "Pitstop Data", "TyrePressureRL", 26.1), 1)
		pressureRRIncrement := Round(pressureRR - getConfigurationValue(data, "Pitstop Data", "TyrePressureRR", 26.1), 1)
		
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
			togglePitstopActivity("Repair Suspension")
			
		if (repairBodywork != this.iRepairBodyworkChosen)
			togglePitstopActivity("Repair Bodywork")
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACC() {
	return SimulatorController.Instance.startSimulator(new Application(kACCApplication
													 , SimulatorController.Instance.Configuration), "Simulator Splash Images\ACC Splash.jpg")
}

stopACC() {
	if isACCRunning() {
		IfWinNotActive AC2, , WinActivate, AC2
		WinWaitActive AC2, , 2
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
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

openPitstopMFD() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).openPitstopMFD()
	}
	finally {
		protectionOff()
	}
}

closePitstopMFD() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).closePitstopMFD()
	}
	finally {
		protectionOff()
	}
}

togglePitstopActivity(activity) {
	if !inList(["Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension"], activity)
		logMessage(kLogWarn, translate("Unsupported pit stop activity """) . activity . translate(""" detected in togglePitstopActivity - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).toggleActivity(activity)
	}
	finally {
		protectionOff()
	}
}

changePitstopStrategy(selection, steps := 1) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported strategy selection """) . selection . translate(""" detected in changePitstopStrategy - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeStrategy(selection, steps)
	}
	finally {
		protectionOff()
	}
}

changePitstopFuelAmount(direction, liters := 5) {
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported refuel change """) . direction . translate(""" detected in changePitstopFuelAmount - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeFuelAmount(direction, liters)
	}
	finally {
		protectionOff()
	}
}

changePitstopTyreSet(selection, steps := 1) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre set selection """) . selection . translate(""" detected in changePitstopTyreSet - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeTyreSet(selection, steps)
	}
	finally {
		protectionOff()
	}
}

changePitstopTyreCompound(compound) {
	if !inList(["Wet", "Dry"], compound)
		logMessage(kLogWarn, translate("Unsupported tyre compound """) . compound . translate(""" detected in changePitstopTyreCompound - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeTyreCompound(compound)
	}
	finally {
		protectionOff()
	}
}

changePitstopTyrePressure(tyre, direction, increments := 1) {
	if !inList(["All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"], tyre)
		logMessage(kLogWarn, translate("Unsupported tyre position """) . tyre . translate(""" detected in changePitstopTyrePressure - please check the configuration"))
		
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported pressure change """) . direction . translate(""" detected in changePitstopTyrePressure - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeTyrePressure(tyre, direction, increments)
	}
	finally {
		protectionOff()
	}
}

changePitstopBrakeType(brake, selection) {
	if !inList(["Front Brake", "Rear Brake"], selection)
		logMessage(kLogWarn, translate("Unsupported brake unit """) . brake . translate(""" detected in changePitstopBrakeType - please check the configuration"))
	
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported brake selection """) . selection . translate(""" detected in changePitstopBrakeType - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeBrakeType(brake, selection)
	}
	finally {
		protectionOff()
	}
}

changePitstopDriver(selection) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported driver selection """) . selection . translate(""" detected in changePitstopDriver - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeDriver(selection)
	}
	finally {
		protectionOff()
	}
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
	
	new ACCPlugin(controller, kACCPLugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()