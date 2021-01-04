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


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends ControllerPlugin {
	kOpenPitstopAppHotkey := false
	kClosePitstopAppHotkey := false
	kPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]
	
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
		
		__New(function, label, pitstopOption) {
			this.iPitstopOption := pitstopOption
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			this.Controller.findPlugin(kACCPlugin).selectPitstopOption(this.iPitstopOption)
		}
	}

	class PitstopChangeAction extends ACCPlugin.PitstopAction {
		iDirection := false
		
		__New(function, label, pitstopOption, direction) {
			this.iDirection := direction
			
			base.__New(function, label, pitstopOption)
		}
		
		fireAction(function, trigger) {
			base.fireAction(function, trigger)
			
			this.Controller.findPlugin(kACCPlugin).changePitstopOption(this.iDirection)
		}
	}
	
	class PitstopSelectAction extends ACCPlugin.PitstopChangeAction {
		__New(function, label, pitstopOption) {
			base.__New(function, label, pitstopOption, "Increase")
		}
	}

	class PitstopToggleAction extends ACCPlugin.PitstopAction {		
		fireAction(function, trigger) {
			base.fireAction(function, trigger)
			
			if ((trigger == "On") || (trigger == "Increase") || (trigger == "Push") || (trigger == "Call"))
				this.Controller.findPlugin(kACCPlugin).changePitstopOption("Increase")
			else
				this.Controller.findPlugin(kACCPlugin).changePitstopOption("Decrease")
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
			
			Send {Enter}
			Sleep 100
			Send %message%
			Sleep 100
			Send {Enter}
		}
	}
	
	OpenPitstopAppHotkey[] {
		Get {
			return this.kOpenPitstopAppHotkey
		}
	}
	
	ClosePitstopAppHotkey[] {
		Get {
			return this.kClosePitstopAppHotkey
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iDriveMode := new this.DriveMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iDriveMode)
		
		this.kOpenPitstopAppHotkey := this.getArgumentValue("openPitstopApp", false)
		this.kClosePitstopAppHotkey := this.getArgumentValue("closePitstopApp", false)
		
		for ignore, action in string2Values(",", this.getArgumentValue("pitstopActions", ""))
			this.createPitstopAction(controller, string2Values(A_Space, action)*)
		
		controller.registerPlugin(this)
			
		SetTimer updatePitstopState, 10000
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
	
	runningSimulator() {
		return (isACCRunning() ? "Assetto Corsa Competizione" : false)
	}
	
	simulatorStartup(simulator) {
		base.simulatorStartup(simulator)
		
		if (inList(this.Simulators, simulator)) {
			this.Controller.setMode(this.iDriveMode)
		}
	}
	
	createPitstopAction(controller, action, increaseFunction, decreaseFunction := false) {
		static kActions := {Strategy: "Strategy", Refuel: "Refuel"
						  , TyreChange: "Change Tyres", TyreSet: "Tyre Set", TyreCompound: "Compound", TyreAllAround: "All Around"
						  , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
						  , BrakeChange: "Change Brakes", FrontBrake: "Front Brake", RearBrake: "Rear Brake"
						  , SuspensionRepair: "Repair Suspension", BodyworkRepair: "Repair Bodywork"}
		static kSelectActions := ["TyreChange", "BrakeChange", "SuspensionRepair", "BodyworkRepair"]
		static mode := false
		local function
		
		if kActions.HasKey(action) {
			function := this.Controller.findFunction(increaseFunction)
			
			if (mode == false)
				mode := new this.PitstopMode(this)
				
			if !decreaseFunction {
				if (function != false)
					if (inList(kSelectActions, action))
						mode.registerAction(new this.PitstopSelectAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action), this.kActions[action]))
					else
						mode.registerAction(new this.PitstopToggleAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action), this.kActions[action]))
				else
					this.logFunctionNotFound(increaseFunction)
			}
			else {
				if (function != false)
					mode.registerAction(new this.PitstopChangeAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Increase"), action), this.kActions[action], "Increase"))
				else
					this.logFunctionNotFound(increaseFunction)
					
				function := this.Controller.findFunction(decreaseFunction)
				
				if (function != false)
					mode.registerAction(new this.PitstopChangeAction(function, this.getLabel(ConfigurationItem.descriptor(action, "Decrease"), action), this.kActions[action], "Decrease"))
				else
					this.logFunctionNotFound(decreaseFunction)
			}
		}
		else
			logMessage(kLogWarn, translate("Pitstop action ") . action . translate(" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}
		
	openPitstopApp() {
		SendEvent % this.Plugin.OpenPitstopAppHotkey
		Sleep 500
		
		this.updatePitStopState(false)
			
		this.iPSIsOpen := true
		this.iPSSelectedOption := 1
	}
	
	closePitstopApp() {
		SendEvent % this.Plugin.ClosePitstopAppHotkey
		
		this.iPSIsOpen := false
	}
	
	requirePitstopApp() {
		if !this.iPSIsOpen
			this.openPitstopApp()
	}
	
	selectPitstopOption(option) {
		targetSelectedOption := inList(this.kPSOptions, option)
		delta := 0
		
		if (targetSelectedOption > this.kPSTyreOptionPosition) {
			if (targetSelectedOption <= (this.kPSTyreOptionPosition + this.kPSTyreOptions)) {
				if !this.iPSChangeTyres
					this.toggleActivity("Change Tyres")
			}
			else
				if !this.iPSChangeTyres
					delta -= this.kPSTyreOptions
		}
		
		if (targetSelectedOption > this.kPSBrakeOptionPosition) {
			if (targetSelectedOption <= (this.kPSBrakeOptionPosition + this.kPSBrakeOptions)) {
				if !this.iPSChangeBrakes
					this.toggleActivity("Change Brakes")
			}
			else
				if !this.iPSChangeBrakes
					delta -= this.kPSBrakeOptions
		}
		
		targetSelectedOption += delta
		
		if (targetSelectedOption > this.iPSSelectedOption)
			Loop % targetSelectedOption - this.iPSSelectedOption
			{
				SendEvent {Down}
				Sleep 50
			}
		else
			Loop % this.iPSSelectedOption - targetSelectedOption
			{
				SendEvent {Up}
				Sleep 50
			}
		
		this.iPSSelectedOption := targetSelectedOption
	}
	
	changePitstopOption(direction, steps := 1) {
		switch direction {
			case "Increase":
				Loop % steps {
					SendEvent {Right}
					Sleep 50
				}
			case "Decrease":
				Loop % steps {
					SendEvent {Left}
					Sleep 50
				}
			default:
				Throw "Unsupported change operation """ . direction . """ detected in ACCManager.changePitstopOption..."
		}
	}
	
	toggleActivity(activity) {
		this.requirePitstopApp()
			
		switch activity {
			case "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension":
				this.selectPitstopOption(activity)
				
				SendEvent {Right}
			default:
				Throw "Unsupported activity """ . activity . """ detected in ACCManager.toggleActivity..."
		}
		
		if (activity = "Change Tyres")
			this.iPSChangeTyres := !this.iPSChangeTyres
		else if (activity = "Change Brakes")
			this.iPSChangeBrakes := !this.iPSChangeBrakes
		
		Sleep 100
	}

	changeStrategy(selection, steps := 1) {
		this.requirePitstopApp()
			
		this.selectPitstopOption("Strategy")
		
		switch selection {
			case "Next":
				this.changePitstopOption("Increase")
			case "Previous":
				this.changePitstopOption("Decrease")
			default:
				Throw "Unsupported selection """ . selection . """ detected in ACCManager.changeStrategy..."
		}
		
		this.updatePitstopState(false)
	}

	changeFuelAmount(direction, liters := 5) {
		this.requirePitstopApp()
			
		this.selectPitstopOption("Refuel")
		
		this.changePitstopOption(direction, liters)
	}
	
	changeTyreSet(selection) {
		this.requirePitstopApp()
			
		this.selectPitstopOption("Tyre set")
		
		switch selection {
			case "Next":
				this.changePitstopOption("Increase")
			case "Previous":
				this.changePitstopOption("Decrease")
			default:
				Throw "Unsupported selection """ . selection . """ detected in ACCManager.changeTyreSet..."
		}
	}
	
	changeTyreCompound(type) {
		this.requirePitstopApp()
			
		this.selectPitstopOption("Compound")
		
		switch selection {
			case "Wet":
				this.changePitstopOption("Increase")
			case "Dry":
				this.changePitstopOption("Decrease")
			default:
				Throw "Unsupported selection """ . selection . """ detected in ACCManager.changeTyreCompound..."
		}
	}
	
	changeTyrePressure(tyre, direction, increments := 1) {
		this.requirePitstopApp()
			
		switch tyre {
			case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
				this.selectPitstopOption(tyre)
			default:
				Throw "Unsupported tyre position """ . tyre . """ detected in ACCManager.changeTyrePressure..."
		}
		
		this.changePitstopOption(direction, increments)
	}

	changeBrakeType(brake, selection) {
		this.requirePitstopApp()
			
		switch brake {
			case "Front Brake", "Rear Brake":
				this.selectPitstopOption(brake)
			default:
				Throw "Unsupported brake """ . brake . """ detected in ACCManager.changeBrakeType..."
		}
			
		switch selection {
			case "Next":
				this.changePitstopOption("Increase")
			case "Previous":
				this.changePitstopOption("Decrease")
			default:
				Throw "Unsupported selection """ . selection . """ detected in ACCManager.changeBrakeType..."
		}
	}
	
	updatePitstopState(checkPitstopApp := true) {
		static kSearchAreaLeft := 250
		static kSearchAreaRight := 150
		
		if isACCRunning() {
			lastY := false
			
			if checkPitstopApp {
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
					this.iPSIsOpen := true
					
					lastY := y
			
					if !this.iPSImageSearchArea
						this.iPSImageSearchArea := [Max(0, x - kSearchAreaLeft), 0, Min(x + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
				}
				else
					this.iPSIsOpen := false
			}
			
			if (!checkPitstopApp || this.iPSIsOpen) {
				pitStrategyLabel := getFileName("ACC\Pit Strategy.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
				curTickCount := A_TickCount
				
				if !this.iPSImageSearchArea {
					ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %pitStrategyLabel%
				
					logMessage(kLogInfo, translate("Full search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				else {
					ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %pitStrategyLabel%
				
					logMessage(kLogInfo, translate("Optimized search for 'Pit Strategy' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				
				if x is Integer
				{
					if !inList(this.kPSOptions, "Strategy")
						this.kPSOptions.InsertAt(inList(this.kPSOptions, "Refuel"), "Strategy")
				
					logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
				else {
					position := inList(this.kPSOptions, "Strategy")
					
					if position
						this.kPSOptions.RemoveAt(position)
				
					logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
				
				tyreSetLabel := getFileName("ACC\Tyre Set.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
				curTickCount := A_TickCount
				
				if !this.iPSImageSearchArea {
					ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %tyreSetLabel%
				
					logMessage(kLogInfo, translate("Full search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				else {
					ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %tyreSetLabel%
				
					logMessage(kLogInfo, translate("Optimized search for 'Tyre set' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				
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
				
				frontBrakeLabel := getFileName("ACC\Front Brake.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
				curTickCount := A_TickCount
				
				if !this.iPSImageSearchArea {
					ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %frontBrakeLabel%
				
					logMessage(kLogInfo, translate("Full search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				else {
					ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %frontBrakeLabel%
				
					logMessage(kLogInfo, translate("Optimized search for 'Front Brake' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				
				if x is Integer
				{
					this.iPSChangeBrakes := true
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Brakes are selected for change"))
				}
				else {
					this.iPSChangeBrakes := false
					
					logMessage(kLogInfo, translate("Assetto Corsa Competizione - Pitstop: Brakes are not selected for change"))
				}
				
				selectDriverLabel := getFileName("ACC\Select Driver.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
				curTickCount := A_TickCount
				
				if !this.iPSImageSearchArea {
					ImageSearch x, y, 0, lastY ? lastY : 0, Round(A_ScreenWidth / 2), A_ScreenHeight, *50 %selectDriverLabel%
				
					logMessage(kLogInfo, translate("Full search for 'Select Driver' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				else {
					ImageSearch x, y, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *50 %selectDriverLabel%
				
					logMessage(kLogInfo, translate("Optimized search for 'Select Driver' took ") . A_TickCount - curTickCount . translate(" ms"))
				}
				
				if x is Integer
				{
					if !inList(this.kPSOptions, "Select Driver")
						this.kPSOptions.InsertAt(inList(this.kPSOptions, "Repair Suspension"), "Select Driver")
				
					logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
				else {
					position := inList(this.kPSOptions, "Select Driver")
					
					if position
						this.kPSOptions.RemoveAt(position)
				
					logMessage(kLogInfo, translate("'Select Driver' not detected, adjusting pit stop options: " . values2String(", ", this.kPSOptions*)))
				}
			}
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

openPitstopApp() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).openPitstopApp()
	}
	finally {
		protectionOff()
	}
}

closePitstopApp() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).closePitstopApp()
	}
	finally {
		protectionOff()
	}
}

togglePitstopActivity(activity) {
	if !inList(["Change Tyres", "Change Brakes", "Repair Bodywork" "Repair Suspension"], activity)
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

changePitstopTyreSet(selection) {
	if !inList(["Next", "Previous"], selection)
		logMessage(kLogWarn, translate("Unsupported tyre set selection """) . selection . translate(""" detected in changePitstopTyreSet - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).changeTyreSet(selection)
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
	if !inList(["All Around", "Front Left", "Front Right" "Rear Left", "Rear Right"], tyre)
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updatePitstopState() {
	local plugin := false
	
	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kACCPlugin)
		
	protectionOn()
	
	try {
		plugin.updatePitstopState()
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
