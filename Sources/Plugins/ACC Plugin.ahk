;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

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
	kPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]
	kPSMutatingOptions := ["Strategy", "Change Tyres", "Compound", "Change Brakes"]
	
	kPSTyreOptionPosition := inList(this.kPSOptions, "Change Tyres")
	kPSTyreOptions := 7
	kPSBrakeOptionPosition := inList(this.kPSOptions, "Change Brakes")
	kPSBrakeOptions := 2
		
	iPSIsOpen := false
	iPSSelectedOption := 1
	iPSChangeTyres := false
	iPSChangeBrakes := false
	
	iPSImageSearchArea := false
	
	iChatMode := false
	iPitstopMode := false
	
	iOnTrack := false
	
	iRaceEngineerEnabled := false
	iRaceEngineerName := false
	iRaceEngineerLogo := false
	iRaceEngineerSpeaker := false
	iRaceEngineerListener := false
	
	iRaceEngineer := false
	iPitstopPending := false
	
	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true
	
	class RemoteRaceEngineer {
		iRemotePID := false
		
		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}
		
		__New(remotePID) {
			this.iRemotePID := remotePID
		}
		
		callRemote(function, arguments*) {
			raiseEvent(kFileMessage, "Race", function . ":" . values2String(";", arguments*), this.RemotePID)
		}
		
		shutdown(arguments*) {
			this.callRemote("shutdown", arguments*)
		}
		
		startRace(arguments*) {
			this.callRemote("startRace", arguments*)
		}
		
		finishRace(arguments*) {
			this.callRemote("finishRace", arguments*)
		}
		
		addLap(arguments*) {
			this.callRemote("addLap", arguments*)
		}
		
		updateLap(arguments*) {
			this.callRemote("updateLap", arguments*)
		}
		
		planPitstop(arguments*) {
			this.callRemote("planPitstop", arguments*)
		}
		
		preparePitstop(arguments*) {
			this.callRemote("preparePitstop", arguments*)
		}
		
		performPitstop(arguments*) {
			this.callRemote("performPitstop", arguments*)
		}
	}
	
	class ChatMode extends ControllerMode {
		Mode[] {
			Get {
				return kChatMode
			}
		}
		
		updateActions(onTrack) {
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
			
			this.updateActions(this.Plugin.OnTrack)
		}
		
		updateActions(onTrack) {
			this.updatePitstopActions(onTrack)
			this.updateRaceEngineerActions(onTrack && (this.Plugin.RaceEngineer != false))
		}			
			
		updatePitstopActions(onTrack) {	
			for ignore, theAction in this.Actions
				if isInstance(theAction, ACCPlugin.PitstopAction)
					if onTrack {
						theAction.Function.enable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label))
					}
					else {
						theAction.Function.disable(kAllTrigger)
						theAction.Function.setText(translate(theAction.Label), "Gray")
					}
		}
		
		updateRaceEngineerActions(activeRace) {
			for ignore, theAction in this.Actions
				if isInstance(theAction, ACCPlugin.RaceEngineerAction)
					if activeRace {
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

	class RaceEngineerSettingsAction extends ControllerAction {
		fireAction(function, trigger) {
			openRaceEngineerSettings()
		}
	}
	
	class RaceEngineerToggleAction extends ControllerAction {
		fireAction(function, trigger) {
			local plugin := this.Controller.findPlugin(kACCPlugin)
			
			if plugin.RaceEngineerName
				if (plugin.RaceEngineerEnabled && ((trigger = "Off") || (trigger == "Push"))) {
					plugin.disableRaceEngineer()
				
					trayMessage(translate(this.Label), translate("State: Off"))
				
					function.setText(translate(this.Label), "Black")
				}
				else if (!plugin.RaceEngineerEnabled && ((trigger = "On") || (trigger == "Push"))) {
					plugin.enableRaceEngineer()
				
					trayMessage(translate(this.Label), translate("State: On"))
				
					function.setText(translate(this.Label), "Green")
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
	
	RaceEngineerEnabled[] {
		Get {
			return this.iRaceEngineerEnabled
		}
	}
	
	RaceEngineerName[] {
		Get {
			return this.iRaceEngineerName
		}
	}
	
	RaceEngineerLogo[] {
		Get {
			return this.iRaceEngineerLogo
		}
	}
	
	RaceEngineerSpeaker[] {
		Get {
			return this.iRaceEngineerSpeaker
		}
	}
	
	RaceEngineerListener[] {
		Get {
			return this.iRaceEngineerListener
		}
	}
	
	OnTrack[] {
		Get {
			return this.iOnTrack
		}
	}
	
	PitstopPending[] {
		Get {
			return this.iPitstopPending
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
		
		this.iRaceEngineerName := this.getArgumentValue("raceEngineerName", false)
		this.iRaceEngineerLogo := this.getArgumentValue("raceEngineerLogo", false)
		
		raceEngineerToggle := this.getArgumentValue("raceEngineer", false)
		
		if raceEngineerToggle {
			arguments := string2Values(A_Space, raceEngineerToggle)
			
			this.iRaceEngineerEnabled := (arguments[1] = "On")
			
			this.createRaceEngineerAction(controller, "RaceEngineer", arguments[2])
		}
		else
			this.iRaceEngineerEnabled := (this.iRaceEngineerName != false)
		
		raceEngineerSettings := this.getArgumentValue("raceEngineerSettings", false)
		
		if raceEngineerSettings
			this.createRaceEngineerAction(controller, "RaceEngineerSettings", raceEngineerSettings)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("raceEngineerCommands", ""))
			this.createRaceEngineerAction(controller, string2Values(A_Space, theAction)*)
		
		engineerSpeaker := this.getArgumentValue("raceEngineerSpeaker", false)
		
		if ((engineerSpeaker != false) && (engineerSpeaker != kFalse)) {
			this.iRaceEngineerSpeaker := ((engineerSpeaker = kTrue) ? true : engineerSpeaker)
		
			engineerListener := this.getArgumentValue("raceEngineerListener", false)
			
			if ((engineerListener != false) && (engineerListener != kFalse))
				this.iRaceEngineerListener := ((engineerListener = kTrue) ? true : engineerListener)
		}
		
		controller.registerPlugin(this)
	
		if (this.RaceEngineerName)
			SetTimer collectRaceData, 10000
		else
			SetTimer updateOnTrackState, 5000
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
			else if (action = "RaceEngineer")
				this.registerAction(new this.RaceEngineerToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)))
			else if (action = "RaceEngineerSettings")
				this.registerAction(new this.RaceEngineerSettingsAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"))))
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
	
	activate() {
		base.activate()
		
		for ignore, theAction in this.Actions
			if isInstance(theAction, ACCPlugin.RaceEngineerToggleAction) {
				theAction.Function.setText(translate(theAction.Label), this.RaceEngineerName ? (this.RaceEngineerEnabled ? "Green" : "Black") : "Gray")
				
				if !this.RaceEngineerName
					theAction.Function.disable()
			}
	}
	
	runningSimulator() {
		return (isACCRunning() ? "Assetto Corsa Competizione" : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (inList(this.Simulators, simulator)) {
			this.Controller.setMode(this.iChatMode)
		}
	}
	
	updateOnTrackState(onTrack) {
		this.iOnTrack := onTrack
		
		if (this.Controller.ActiveMode == this.iChatMode)
			this.iChatMode.updateActions(onTrack)
		
		if (this.Controller.ActiveMode == this.iPitstopMode)
			this.iPitstopMode.updateActions(onTrack)
	}
		
	openPitstopMFD(update := true) {
		IfWinNotActive AC2, , WinActivate, AC2 
		WinWaitActive AC2, , 2

		if this.OpenPitstopMFDHotkey
			SendEvent % this.OpenPitstopMFDHotkey
		
		wasOpen := this.iPSIsOpen
		
		this.iPSIsOpen := true
		this.iPSSelectedOption := 1
		
		if (update || !wasOpen) {
			this.updatePitStopState()
			
			SetTimer updatePitstopState, 5000
		}
	}
	
	closePitstopMFD() {
		IfWinNotActive AC2, , WinActivate, AC2
		WinWaitActive AC2, , 2

		if this.ClosePitstopMFDHotkey
			SendEvent % this.ClosePitstopMFDHotkey
		
		this.iPSIsOpen := false
			
		SetTimer updatePitstopState, Off
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
		targetSelectedOption := inList(this.kPSOptions, option)
		
		if targetSelectedOption {
			delta := 0
			
			if (targetSelectedOption > this.kPSTyreOptionPosition) {
				if (targetSelectedOption <= (this.kPSTyreOptionPosition + this.kPSTyreOptions)) {
					if !this.iPSChangeTyres {
						this.toggleActivity("Change Tyres")
						
						return (retry && this.selectPitstopOption(option, false))
					}
				}
				else
					if !this.iPSChangeTyres
						delta -= this.kPSTyreOptions
			}
			
			if (targetSelectedOption > this.kPSBrakeOptionPosition) {
				if (targetSelectedOption <= (this.kPSBrakeOptionPosition + this.kPSBrakeOptions)) {
					if !this.iPSChangeBrakes {
						this.toggleActivity("Change Brakes")
						
						return (retry && this.selectPitstopOption(option, false))
					}
				}
				else
					if !this.iPSChangeBrakes
						delta -= this.kPSBrakeOptions
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
				ImageSearch x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %pitstopLabel%

				logMessage(kLogInfo, translate("Full search for 'PITSTOP' took ") . A_TickCount - curTickCount . translate(" ms"))
			}
			else {
				ImageSearch x, y, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %pitstopLabel%

				logMessage(kLogInfo, translate("Optimized search for 'PITSTOP' took ") . A_TickCount - curTickCount . translate(" ms"))
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
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *50 %pitStrategyLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %pitStrategyLabel%

			if x is Integer
			{
				images.Push(pitStrategyLabel)
			
				break
			}
		}

		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
		
		if x is Integer
		{
			if !inList(this.kPSOptions, "Strategy") {
				this.kPSOptions.InsertAt(inList(this.kPSOptions, "Refuel"), "Strategy")
				
				this.kPSTyreOptionPosition += 1
				this.kPSBrakeOptionPosition += 1
				
				reload := true
			}
			
			lastY := y
		
			logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
		}
		else {
			position := inList(this.kPSOptions, "Strategy")
			
			if position {
				this.kPSOptions.RemoveAt(position)
				
				this.kPSTyreOptionPosition -= 1
				this.kPSBrakeOptionPosition -= 1
				
				reload := true
			}
		
			logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
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
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *50 %wetLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %wetLabel%

			if x is Integer
			{
				images.Push(wetLabel)
			
				break
			}
		}
		
		if x is Integer
		{
			position := inList(this.kPSOptions, "Tyre Set")
			
			if position {
				this.kPSOptions.RemoveAt(position)
				this.kPSTyreOptions := 6
				
				reload := true
			}
		}
		else {
			if !inList(this.kPSOptions, "Tyre Set") {
				this.kPSOptions.InsertAt(inList(this.kPSOptions, "Compound"), "Tyre Set")
				this.kPSTyreOptions := 7
				
				reload := true
			}
		}
		
		x := kUndefined
		y := kUndefined
		
		Loop % compoundLabels.Length()
		{
			compoundLabel := compoundLabels[A_Index]
			
			if !this.iPSImageSearchArea
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *50 %compoundLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %compoundLabel%
			
			if x is Integer
			{
				images.Push(compoundLabel)
			
				break
			}
		}
			
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
	
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
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *50 %frontBrakeLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %frontBrakeLabel%
			
			if x is Integer
			{
				images.Push(frontBrakeLabel)
			
				break
			}
		}
		
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
		else 
			logMessage(kLogInfo, translate("Optimized search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
			
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
				ImageSearch x, y, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *50 %selectDriverLabel%
			else
				ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %selectDriverLabel%
		
			if x is Integer
			{
				images.Push(selectDriverLabel)
			
				break
			}
		}
		
		if !this.iPSImageSearchArea
			logMessage(kLogInfo, translate("Full search for 'Select Driver' took ") . A_TickCount - curTickCount . translate(" ms"))
		else
			logMessage(kLogInfo, translate("Optimized search for 'Select Driver' took ") . A_TickCount - curTickCount . translate(" ms"))
		
		if x is Integer
		{
			if !inList(this.kPSOptions, "Select Driver") {
				this.kPSOptions.InsertAt(inList(this.kPSOptions, "Repair Suspension"), "Select Driver")
				
				reload := true
			}
		
			logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
		}
		else {
			position := inList(this.kPSOptions, "Select Driver")
			
			if position {
				this.kPSOptions.RemoveAt(position)
				
				reload := true
			}
		
			logMessage(kLogInfo, translate("'Select Driver' not detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
		}
		
		return reload
	}
	
	updatePitstopState(fromTimer := false) {
		if isACCRunning() {
			beginTickCount := A_TickCount
			lastY := false
			images := []
			
			if (fromTimer || !this.iPSImageSearchArea)
				lastY := this.searchPitstopLabel(images)
			
			if (!fromTimer && this.iPSIsOpen) {
				reload := this.searchStrategyLabel(lastY, images)
				
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
	
	enableRaceEngineer() {
		this.iRaceEngineerEnabled := this.iRaceEngineerName
	}
	
	disableRaceEngineer() {
		this.iRaceEngineerEnabled := false
		
		if this.RaceEngineer
			this.finishRace()
	}
	
	startupRaceEngineer() {
		if (this.RaceEngineerEnabled) {
			Process Exist
			
			controllerPID := ErrorLevel
			raceEngineerPID := 0
								
			try {
				logMessage(kLogInfo, translate("Starting ") . translate("Race Engineer"))
				
				options := " -Remote " . controllerPID . " -Settings """ . getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory) . """"
				
				if this.RaceEngineerName
					options .= " -Name """ . this.RaceEngineerName . """"
				
				if this.RaceEngineerLogo
					options .= " -Logo """ . this.RaceEngineerLogo . """"
				
				if this.RaceEngineerSpeaker
					options .= " -Speaker """ . this.RaceEngineerSpeaker . """"
				
				if this.RaceEngineerListener
					options .= " -Listener """ . this.RaceEngineerListener . """"
				
				if this.Controller.VoiceServer
					options .= " -Voice """ . this.Controller.VoiceServer . """"
				
				exePath := kBinariesDirectory . "Race Engineer.exe" . options 
				
				Run %exePath%, %kBinariesDirectory%, , raceEngineerPID
				
				Sleep 5000
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot start Race Engineer (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
				showMessage(substituteVariables(translate("Cannot start Race Engineer (%kBinariesDirectory%Race Engineer.exe) - please rebuild the applications..."))
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				
				return false
			}
			
			this.iRaceEngineer := new this.RemoteRaceEngineer(raceEngineerPID)
		}
	}
	
	shutdownRaceEngineer() {
		local raceEngineer := this.RaceEngineer
		
		this.iRaceEngineer := false
		
		if raceEngineer
			raceEngineer.shutdown()
	}
	
	startRace(dataFile) {
		if this.RaceEngineer
			this.finishRace(false)
		else
			this.startupRaceEngineer()
	
		if this.RaceEngineer {
			this.RaceEngineer.startRace(dataFile)
			
			controller := SimulatorController.Instance
			mode := controller.findMode(kPitstopMode)
		
			if (controller.ActiveMode == mode)
				mode.updateRaceEngineerActions(true)
		}
	}
	
	finishRace(shutdown := true) {
		if this.RaceEngineer {
			this.RaceEngineer.finishRace()
			
			if shutdown
				this.shutdownRaceEngineer()
			
			this.iPitstopPending := false
			
			controller := SimulatorController.Instance
			mode := controller.findMode(kPitstopMode)
			
			if (controller.ActiveMode == mode)
				mode.updateRaceEngineerActions(false)
		}
	}
	
	addLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.addLap(lapNumber, dataFile)
	}
	
	updateLap(lapNumber, dataFile) {
		if this.RaceEngineer
			this.RaceEngineer.updateLap(lapNumber, dataFile)
	}
	
	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}
	
	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}
	
	performPitstop(lapNumber) {
		if this.RaceEngineer {
			this.RaceEngineer.performPitstop(lapNumber)
		
			this.iPitstopPending := false
					
			SetTimer collectRaceData, 10000
		}
	}
	
	pitstopPlanned(pitstopNumber) {
	}
	
	pitstopPrepared(pitstopNumber) {
		this.iPitstopPending := true
				
		SetTimer collectRaceData, 5000
	}
	
	pitstopFinished(pitstopNumber) {
		this.iPitstopPending := false
				
		SetTimer collectRaceData, 10000
	}
	
	startPitstopSetup(pitstopNumber) {
		openPitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		changePitstopFuelAmount("Increase", Round(litres))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, set := false) {
		changePitstopTyreCompound(compound)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement) {
		if (pressureFLIncrement != 0)
			changePitstopTyrePressure("Front Left", (pressureFLIncrement > 0) ? "Increase" : "Decrease", Round(pressureFLIncrement * 10))
		if (pressureFRIncrement != 0)
			changePitstopTyrePressure("Front Right", (pressureFRIncrement > 0) ? "Increase" : "Decrease", Round(pressureFRIncrement * 10))
		if (pressureRLIncrement != 0)
			changePitstopTyrePressure("Rear Left", (pressureRLIncrement > 0) ? "Increase" : "Decrease", Round(pressureRLIncrement * 10))
		if (pressureRRIncrement != 0)
			changePitstopTyrePressure("Rear Right", (pressureRRIncrement > 0) ? "Increase" : "Decrease", Round(pressureRRIncrement * 10))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (repairSuspension != this.iRepairSuspensionChosen) {
			togglePitstopActivity("Repair Suspension")
			
			this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
		}
			
		if (repairBodywork != this.iRepairBodyworkChosen) {
			togglePitstopActivity("Repair Bodywork")
			
			this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACC() {
	return SimulatorController.Instance.startSimulator(new Application("Assetto Corsa Competizione"
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
	
	return (ErrorLevel != 0)
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

planPitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).planPitstop()
	}
	finally {
		protectionOff()
	}
}

preparePitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).preparePitstop()
	}
	finally {
		protectionOff()
	}
}

openRaceEngineerSettings() {
	exePath := kBinariesDirectory . "Race Engineer Settings.exe"
	
	try {
		Run "%exePath%", %kBinariesDirectory%
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start the Race Engineers Settings tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start the Race Engineers Settings application (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

readSharedMemory(dataFile) {
	exePath := kBinariesDirectory . "ACC SHM Reader.exe"
		
	try {
		Run %ComSpec% /c ""%exePath%" > "%dataFile%"", , Hide
	}
	catch exception {
		logMessage(kLogCritical, translate("Cannot start ACC SHM Reader (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
		showMessage(substituteVariables(translate("Cannot start ACC SHM Reader (%exePath%) - please check the configuration..."), {exePath: exePath})
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
	
	return readConfiguration(dataFile)
}

updateOnTrackState() {
	static plugin := false
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kACCPlugin)
	
	if isACCRunning() {
		data := readSharedMemory(kUserHomeDirectory . "Temp\ACC Data\SHM.data")
		
		inRace := (getConfigurationValue(data, "Stint Data", "Active", false)
				&& (getConfigurationValue(data, "Stint Data", "Session", "OTHER") = "RACE")
				&& !getConfigurationValue(data, "Stint Data", "Paused", false))
				
		plugin.updateOnTrackState(inRace)
	}
	else
		plugin.updateOnTrackState(false)
}

collectRaceData() {
	static lastLap := 0
	static lastLapCounter := 0
	static inPit := false
	static plugin := false
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kACCPlugin)
	
	if isACCRunning() {
		dataFile := kUserHomeDirectory . "Temp\ACC Data\SHM.data"
		
		data := readSharedMemory(dataFile)
		
		dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
		
		/* Used for full setup offrace debugging...
		dataFile := kSourcesDirectory . "Tests\Test Data\Race 3\Lap " . lap . "." . counter . ".data"
		data := readConfiguration(dataFile)
		
		if (data.Count() == 0) {
			if (counter == 1) {	
				plugin.finishRace()
			
				msgbox Done...
				
				ExitApp
			}
			else {
				counter := 1
				lap += 1
				
				return
			}
		}
		else
			showMessage("Data " lap . "." . counter++ . " loaded...")
		
		dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
		*/
		
		protectionOn()
		
		try {
			if (!getConfigurationValue(data, "Stint Data", "Active", false)
			 || (getConfigurationValue(data, "Stint Data", "Session", "OTHER") != "RACE"))  {
				; Not on track
				
				plugin.updateOnTrackState(false)
				
				lastLap := 0
		
				if plugin.RaceEngineer
					plugin.finishRace()
				
				return
			}
			else if getConfigurationValue(data, "Stint Data", "Paused", false) {
				plugin.updateOnTrackState(false)
			
				return
			}
			else
				plugin.updateOnTrackState(true)
			
			if ((dataLastLap <= 1) && (dataLastLap < lastLap)) {
				; Start of new race without finishing previous race first
			
				lastLap := 0
		
				if plugin.RaceEngineer
					plugin.finishRace()
			}
			
			if plugin.RaceEngineerEnabled {
				if (plugin.PitstopPending && getConfigurationValue(data, "Stint Data", "InPit", false) && !inPit) {
					; Car is in the Pit
					
					plugin.performPitstop(dataLastLap)
					
					inPit := true
				}
				else if (dataLastLap > 0) {
					; Car is on the track
				
					if ((dataLastLap > 1) && (lastLap == 0))
						return
					
					firstLap := (lastLap == 0)
					newLap := (dataLastLap > lastLap)
				
					inPit := false
					
					if newLap {
						lastLap := dataLastLap
						lastLapCounter := 0
					}
					
					newDataFile := kUserHomeDirectory . "Temp\ACC Data\Lap " . lastLap . "." . ++lastLapCounter . ".data"
						
					FileCopy %dataFile%, %newDataFile%, 1
					
					if firstLap
						plugin.startRace(newDataFile)
					
					if newLap
						plugin.addLap(dataLastLap, newDataFile)
					else	
						plugin.updateLap(dataLastLap, newDataFile)
				}
			}
			else {
				lastLap := 0
				inPit := false
			}
		}
		finally {
			protectionOff()
		}
	}
	else {
		if plugin.RaceEngineer
			Loop 10 {
				if isACCRunning()
					return
				
				Sleep 500
			}
		
		lastLap := 0
	
		if plugin.RaceEngineer
			plugin.finishRace()
	}
}

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
	
	FileCreateDir %kUserHomeDirectory%Temp\ACC Data
	
	Loop Files, %kUserHomeDirectory%Temp\ACC Data\*.*
		FileDelete %A_LoopFilePath%
	
	new ACCPlugin(controller, kACCPLugin, controller.Configuration)
	
	registerEventHandler("Pitstop", "handlePitstopRemoteCalls")
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handlePitstopRemoteCalls(event, data) {
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kACCPlugin), data[1]), string2Values(";", data[2])*)
	}
	else
		return withProtection(ObjBindMethod(SimulatorController.Instance.findPlugin(kACCPlugin), data))
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()