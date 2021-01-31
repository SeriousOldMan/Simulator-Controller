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
global kDriveMode = "Drive"
global kPitstopMode = "Pitstop"

global kAlways = "Always"

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
	
	iDriveMode := false
	iPitstopMode := false
	
	iRaceEngineerName := false
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
			raiseEvent("Race", function . ":" . values2String(";", arguments*))
		}
		
		shutdown(arguments*) {
			return this.callRemote("shutdown", arguments*)
		}
		
		startRace(arguments*) {
			return this.callRemote("startRace", arguments*)
		}
		
		finishRace(arguments*) {
			return this.callRemote("finishRace", arguments*)
		}
		
		addLap(arguments*) {
			return this.callRemote("addLap", arguments*)
		}
		
		planPitstop(arguments*) {
			return this.callRemote("planPitstop", arguments*)
		}
		
		preparePitstop(arguments*) {
			return this.callRemote("preparePitstop", arguments*)
		}
		
		performPitstop(arguments*) {
			return this.callRemote("performPitstop", arguments*)
		}
	}
	
	class DriveMode extends ControllerMode {
		Mode[] {
			Get {
				return kDriveMode
			}
		}
	}
	
	class PitstopMode extends ControllerMode {
		Mode[] {
			Get {
				return kPitstopMode
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
			
			plugin.requirePitstopMFD()
			
			return plugin.selectPitstopOption(this.iPitstopOption)
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
			
			if plugin.ActiveRace
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
			
			IfWinNotActive AC2  , , WinActivate, AC2  , 
			WinWaitActive AC2  , , 2
			
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
	
	RaceEngineerName[] {
		Get {
			return this.iRaceEngineerName
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
	
	ActiveRace[] {
		Get {
			return (this.RaceEngineer != false)
		}
	}
	
	PitstopPending[] {
		Get {
			return this.iPitstopPending
		}
	}
	
	__New(controller, name, configuration := false) {
		useRaceEngineer := false
		
		this.iDriveMode := new this.DriveMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iDriveMode)
		
		this.kOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.kClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("pitstopSettings", ""))
			this.createPitstopAction(controller, string2Values(A_Space, theAction)*)
		
		this.iRaceEngineerName := this.getArgumentValue("raceEngineerName", false)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("raceEngineerCommands", "")) {
			useRaceEngineer := true
		
			this.createRaceEngineerAction(controller, string2Values(A_Space, theAction)*)
		}
		
		engineerSpeaker := this.getArgumentValue("raceEngineerSpeaker", false)
		
		if ((engineerSpeaker != false) && (engineerSpeaker != "false")) {
			this.iRaceEngineerSpeaker := ((engineerSpeaker = "true") ? true : engineerSpeaker)
		
			engineerListener := this.getArgumentValue("raceEngineerListener", false)
			
			if ((engineerListener != false) && (engineerListener != "false"))
				this.iRaceEngineerListener := ((engineerListener = "true") ? true : engineerListener)
		}
		
		controller.registerPlugin(this)
	
		if (useRaceEngineer || (engineerSpeaker != false))
			SetTimer collectRaceData, 1000
	}
	
	loadFromConfiguration(configuration) {
		local function
		
		base.loadFromConfiguration(configuration)
		
		for descriptor, message in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			function := this.Controller.findFunction(descriptor)
			
			if (function != false) {
				message := string2Values("|", message)
			
				this.iDriveMode.registerAction(new this.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}
	
	createRaceEngineerAction(controller, action, actionFunction) {
		local function := controller.findFunction(actionFunction)
		
		if (function != false)
			this.registerAction(new this.RaceEngineerAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Activate"), action), action))
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
		
		this.enableRaceEngineerActions(this.ActiveRace)
	}
	
	enableRaceEngineerActions(enabled) {
		for ignore, theAction in this.Actions {
			if isInstance(theAction, this.RaceEngineerAction)
				if enabled
					theAction.Function.enable(kAllTrigger)
				else
					theAction.Function.disable(kAllTrigger)
		}
	}
	
	runningSimulator() {
		return (isACCRunning() ? "Assetto Corsa Competizione" : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (inList(this.Simulators, simulator)) {
			this.Controller.setMode(this.iDriveMode)
		}
	}
		
	openPitstopMFD(update := true) {
		IfWinNotActive AC2  , , WinActivate, AC2  , 
		WinWaitActive AC2  , , 2

		SendEvent % this.OpenPitstopMFDHotkey
		
		this.iPSIsOpen := true
		this.iPSSelectedOption := 1
		
		if update {
			this.updatePitStopState()
			
			SetTimer updatePitstopState, 5000
		}
	}
	
	closePitstopMFD() {
		IfWinNotActive AC2  , , WinActivate, AC2  , 
		WinWaitActive AC2  , , 2

		SendEvent % this.ClosePitstopMFDHotkey
		
		this.iPSIsOpen := false
			
		SetTimer updatePitstopState, Off
	}
	
	requirePitstopMFD() {
		this.openPitstopMFD(!this.iPSIsOpen)
	}
	
	selectPitstopOption(option) {
		targetSelectedOption := inList(this.kPSOptions, option)
		
		if targetSelectedOption {
			delta := 0
			
			if (targetSelectedOption > this.kPSTyreOptionPosition) {
				if (targetSelectedOption <= (this.kPSTyreOptionPosition + this.kPSTyreOptions)) {
					if !this.iPSChangeTyres {
						this.toggleActivity("Change Tyres")
						
						return this.selectPitstopOption(option)
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
						
						return this.selectPitstopOption(option)
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
					IfWinNotActive AC2  , , WinActivate, AC2  , 
					WinWaitActive AC2  , , 2

					SendEvent {Down}
					
					Sleep 50
				}
			else
				Loop % this.iPSSelectedOption - targetSelectedOption
				{
					IfWinNotActive AC2  , , WinActivate, AC2  , 
					WinWaitActive AC2  , , 2

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
					IfWinNotActive AC2  , , WinActivate, AC2  , 
					WinWaitActive AC2  , , 2

					SendEvent {Right}

					Sleep 50
				}
			case "Decrease":
				Loop % steps {
					IfWinNotActive AC2  , , WinActivate, AC2  , 
					WinWaitActive AC2  , , 2

					SendEvent {Left}
					
					Sleep 50
				}
			default:
				Throw "Unsupported change operation """ . direction . """ detected in ACCPlugin.changePitstopOption..."
		}
		
		this.resetPitstopState(inList(this.kPSMutatingOptions, option))
	}
	
	toggleActivity(activity) {
		this.requirePitstopMFD()
			
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
		this.requirePitstopMFD()
			
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
		this.requirePitstopMFD()
			
		if this.selectPitstopOption("Refuel")
			this.changePitstopOption("Refuel", direction, liters)
	}
	
	changeTyreSet(selection, steps := 1) {
		this.requirePitstopMFD()
			
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
		this.requirePitstopMFD()
			
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
		this.requirePitstopMFD()
		
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

	changeBrakeType(brake, selection) {
		this.requirePitstopMFD()
		
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

	changeDriver(selection) {
		this.requirePitstopMFD()
			
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
	
	updatePitstopState(fromTimer := false) {
		static kSearchAreaLeft := 250
		static kSearchAreaRight := 150
		
		if isACCRunning() {
			beginTickCount := A_TickCount
			lastY := false
			
			if (fromTimer || !this.iPSImageSearchArea) {
				pitstopLabel := getFileName("ACC\PITSTOP.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
				curTickCount := A_TickCount
				
				if !this.iPSImageSearchArea {
					ImageSearch x, y, 0, 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %pitstopLabel%
		
					logMessage(kLogInfo, translate("Full search for 'PITSTOP' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				else {
					ImageSearch x, y, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %pitstopLabel%
		
					logMessage(kLogInfo, translate("Optimized search for 'PITSTOP' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				
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
			}
			
			if (!fromTimer && this.iPSIsOpen) {
				reload := false
				
				curTickCount := A_TickCount
				
				Loop 2 {
					pitStrategyLabel := getFileName("ACC\Pit Strategy " . A_Index . ".jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
					
					if !this.iPSImageSearchArea
						ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %pitStrategyLabel%
					else
						ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %pitStrategyLabel%

					if x is Integer
						break
				}

				if !this.iPSImageSearchArea
					logMessage(kLogInfo, translate("Full search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
				else
					logMessage(kLogInfo, translate("Optimized search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
				
				if x is Integer
				{
					if !inList(this.kPSOptions, "Strategy") {
						this.kPSOptions.InsertAt(inList(this.kPSOptions, "Refuel"), "Strategy")
						
						reload := true
					}
				
					logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
				else {
					position := inList(this.kPSOptions, "Strategy")
					
					if position {
						this.kPSOptions.RemoveAt(position)
						
						reload := true
					}
				
					logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
				
				curTickCount := A_TickCount
				
				Loop 2 {
					wetLabel := getFileName("ACC\Wet " . A_index . ".jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
						
					if !this.iPSImageSearchArea
						ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %wetLabel%
					else
						ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %wetLabel%

					if x is Integer
						break
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
				
				Loop 2 {
					compoundLabel := getFileName("ACC\Compound " . A_Index . ".jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
					
					if !this.iPSImageSearchArea
						ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %compoundLabel%
					else
						ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %compoundLabel%
					
					if x is Integer
						break
				}
					
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, translate("Full search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
				else
					logMessage(kLogInfo, translate("Optimized search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
			
				if x is Integer
				{
					this.iPSChangeTyres := true
					
					lastY := y
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Tyres are selected for change"))
				}
				else {
					this.iPSChangeTyres := false
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Tyres are not selected for change"))
				}

				curTickCount := A_TickCount
				
				Loop 2 {
					frontBrakeLabel := getFileName("ACC\Front Brake " . A_Index . ".jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
					
					if !this.iPSImageSearchArea
						ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %frontBrakeLabel%
					else
						ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %frontBrakeLabel%
					
					if x is Integer
						break
				}
				
				if !this.iPSImageSearchArea
					logMessage(kLogInfo, translate("Full search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
				else 
					logMessage(kLogInfo, translate("Optimized search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
					
				if x is Integer
				{
					this.iPSChangeBrakes := true
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Brakes are selected for change"))
				}
				else {
					this.iPSChangeBrakes := false
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Brakes are not selected for change"))
				}
				
				curTickCount := A_TickCount
				
				Loop 3 {
					selectDriverLabel := getFileName("ACC\Select Driver " . A_Index . ".jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
					
					if !this.iPSImageSearchArea
						ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %selectDriverLabel%
					else
						ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %selectDriverLabel%
				
					if x is Integer
						break
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
				
				logMessage(kLogInfo, translate("Complete update of pitstop state took ") . A_TickCount - beginTickCount . translate(" ms"))
				
				if reload
					this.openPitstopMFD()
			}
		}
	}
	
	resetPitstopState(update := false) {
		this.openPitstopMFD(update)
	}
	
	startupRaceEngineer() {
		Process Exist
		
		controllerPID := ErrorLevel
		raceEngineerPID := 0
							
		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Race Engineer"))
			
			options := " -Remote " . controllerPID . " -Settings """ . getFileName("Race Engineer.settings", kUserConfigDirectory, kConfigDirectory) . """"
			
			if this.RaceEngineerName
				options .= " -Name """ . this.RaceEngineerName . """"
			
			if this.RaceEngineerSpeaker
				options .= " -Speaker """ . this.RaceEngineerSpeaker . """"
			
			if this.RaceEngineerListener
				options .= " -Listener """ . this.RaceEngineerListener . """"
			
			exePath := kBinariesDirectory . "Race Engineer.exe" . options 
			
			Run %exePath%, %kBinariesDirectory%, , raceEngineerPID
			
			Sleep 5000
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Race Engineer (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
			title := translate("Modular Simulator Controller System - Controller (Plugin: ACC)")
			
			SplashTextOn 800, 60, %title%, % substituteVariables(translate("Cannot start Race Engineer (%kBinariesDirectory%Race Engineer.exe) - please rebuild the applications..."))
				
			Sleep 5000
				
			SplashTextOff
			
			return false
		}
		
		this.iRaceEngineer := new this.RemoteRaceEngineer(raceEngineerPID)
	}
	
	shutdownRaceEngineer() {
		this.RaceEngineer.shutdown()
		
		this.iRaceEngineer := false
	}
	
	startRace(dataFile) {
		if this.ActiveRace
			this.finishRace()
		
		this.startupRaceEngineer()
	
		this.RaceEngineer.startRace(dataFile)
		
		this.enableRaceEngineerActions(true)
	}
	
	finishRace() {
		if this.ActiveRace {
			this.RaceEngineer.finishRace()
			
			this.shutdownRaceEngineer()
			
			this.iPitstopPending := false
			
			this.enableRaceEngineerActions(false)
		}
		else
			Throw "No active race to be finished..."
	}
	
	addLap(lapNumber, dataFile) {
		if this.ActiveRace
			this.RaceEngineer.addLap(lapNumber, dataFile)
		else
			Throw "Lap data can only be added during an active race..."
	}
	
	planPitstop() {
		if this.ActiveRace
			this.RaceEngineer.planPitstop()
		else
			Throw "Pitstops may only be planned during an active race..."
	}
	
	preparePitstop(lap := false) {
		if this.ActiveRace
			this.RaceEngineer.preparePitstop(lap)
		else
			Throw "Pitstops may only be prepared during an active race..."
	}
	
	performPitstop(lapNumber) {
		if this.ActiveRace
			this.RaceEngineer.performPitstop(lapNumber)
		else
			Throw "Pitstops may only be performed during an active race..."
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
		IfWinNotActive AC2  , , WinActivate, AC2  , 
		WinWaitActive AC2  , , 2
		MouseClick left,  2093,  1052
		Sleep 500
		MouseClick left,  2614,  643
		Sleep 500
		MouseClick left,  2625,  619
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

collectRaceData() {
	static lastLap := 0
	static inPit := false
	static plugin := false
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kACCPlugin)
	
	if true || isACCRunning() {
		exePath := kBinariesDirectory . "ACC SHM Reader.exe"
		
		try {
			Run %ComSpec% /c ""%exePath%" > "%kUserHomeDirectory%Temp\ACC Data\SHM.data"", , Hide
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start ACC SHM Reader (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))
			
			title := translate("Modular Simulator Controller System - Controller (Plugin: ACC)")
		
			SplashTextOn 800, 60, %title%, % substituteVariables(translate("Cannot start ACC SHM Reader (%exePath%) - please check the configuration..."))
					
			Sleep 5000
					
			SplashTextOff
		}
		
		dataFile := kUserHomeDirectory . "Temp\ACC Data\SHM.data"
		data := readConfiguration(dataFile)
		
		dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
		
		/* Used for full setup offrace debugging...
		dataFile := kSourcesDirectory . "Tests\Test Data\Lap " . (lastLap + 1) . ".data"
		data := readConfiguration(dataFile)
		
		if (data.Count() == 0) {
			plugin.finishRace()
		
			msgbox Done...
			
			ExitApp
		}
		
		dataLastLap := getConfigurationValue(data, "Stint Data", "Laps", 0)
		*/
		
		protectionOn()
		
		try {
			if (plugin.PitstopPending && getConfigurationValue(data, "Stint Data", "InPit", false) && !inPit) {
				plugin.performPitstop(dataLastLap)
				
				inPit := true
			}
			else if (dataLastLap > lastLap) {
				if (lastLap == 0)
					plugin.startRace(dataFile)
				
				lastLap := dataLastLap

				plugin.addLap(dataLastLap, dataFile)
				
				if isDebug()
					writeConfiguration(kUserHomeDirectory . "Temp\ACC Data\Lap " . lastLap . ".data", data)
				
				inPit := false
			}
			
			if !getConfigurationValue(data, "Stint Data", "Active", false) {
				if (lastLap > 0) {
					if isDebug() {
						fileName := (kUserHomeDirectory . "Temp\ACC Data\Race.data")
						
						try {
							FileDelete %fileName%
						}
						catch exception {
							; ignore
						}
						
						curEncoding := A_FileEncoding
						
						FileEncoding UTF-16
						
						try {
							for theFact, theValue in plugin.RaceEngineer.KnowledgeBase.Facts.Facts {
								line := theFact . "=" . theValue . "`n"
								
								FileAppend %line%, %fileName%
							}
						}
						finally {
							FileEncoding %curEncoding%
						}
					}
			
					plugin.finishRace()
				}
				
				lastLap := 0
			}
		}
		finally {
			protectionOff()
		}
	}
	else {
		lastLap := 0
	
		if plugin.ActiveRace
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
	
	registerEventHandler("Pitstop", "handleRaceEngineerCalls")
	
	new ACCPlugin(controller, kACCPLugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

handleRaceEngineerCalls(event, data) {
	local function
	
	if InStr(data, ":") {
		data := StrSplit(data, ":", , 2)
		
		function := ObjBindMethod(SimulatorController.Instance.findPlugin(kACCPlugin), data[1], string2Values(";", data[2])*)
	}
	else
		function := ObjBindMethod(SimulatorController.Instance.findPlugin(kACCPlugin), data)
	
	withProtection(function)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()
