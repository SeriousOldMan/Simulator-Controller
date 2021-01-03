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


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends ControllerPlugin {
	kOpenPitstopHotkey := false
	kClosePitstopHotkey := false
	
	iACCManager := false
	iDriveMode := false
	
	class ACCManager {
		iPlugin := false
		
		kPSOptions := ["Pit Limiter", "Strategy", "Refuel"
					 , "Change Tires", "Tire Set", "Tire Compound", "Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
					 , "Change Brakes", "Front Brake", "Rear Brake", "Bodywork", "Suspension"]
		
		kPSTireOptionPosition := inList(kPSOptions, "Change Tires")
		kPSTireOptions := 7
		kPSBrakeOptionPosition := inList(kPSOptions, "Change Brakes")
		kPSBrakeOptions := 2
		
		iPSIsOpen := false
		iPSSelectedOption := 1
		iPSChangeTires := false
		iPSChangeBrakes := false
		
		__New(plugin) {
			this.iPlugin := plugin
		}
		
		openPitstop() {
			Send % this.Plugin.OpenPitstopHotkey
			
			tireSetLabel := getFileName("ACC\Tyre Set.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
			
			ImageSearch x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %tireSetLabel%
			
			if x is Integer
			{
				this.iPSChangeTires := true
				
				logMessage(kInfo, "Assetto Corsa Competizione - Pitstop: Tires are selected for change")
			}
			else {
				this.iPSChangeTires := false
				
				logMessage(kInfo, "Assetto Corsa Competizione - Pitstop: Tires are not selected for change")
			}
			
			frontBrakeLabel := getFileName("ACC\Front Brake.jpg", kUserScreenImagesDirectory, kScreenImagesDirectory)
			
			ImageSearch x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 %frontBrakeLabel%
			
			if x is Integer
			{
				this.iPSChangeBrakes := true
				
				logMessage(kInfo, "Assetto Corsa Competizione - Pitstop: Brakes are selected for change")
			}
			else {
				this.iPSChangeBrakes := false
				
				logMessage(kInfo, "Assetto Corsa Competizione - Pitstop: Brakes are not selected for change")
			}
				
			this.iPSIsOpen := true
			this.iPSSelectedOption := 1
		}
		
		closePitstop() {
			Send % this.Plugin.ClosePitstopHotkey
			
			this.iPSIsOpen := false
		}
		
		selectPitstopOption(option) {
			selection := inList(this.kPSOptions, option)
			delta := 0
			msgbox % this.kPSTireOptionPosition
			if (selection > this.kPSTireOptionPosition) {
				if (selection <= (this.kPSTireOptionPosition + this.kPSTireOptions)) {
					if !this.iPSChangeTires
						toggleActivity("Change Tires")
				}
				else
					if !this.iPSChangeTires
						delta -= this.kPSTireOptions
			}
			
			if (selection > this.kPSBrakeOptionPosition) {
				if (selection <= (this.kPSBrakeOptionPosition + this.kPSBrakeOptions)) {
					if !this.iPSChangeBrakes
						toggleActivity("Change Brakes")
				}
				else
					if !this.iPSChangeBrakes
						delta -= this.kPSBrakeOptions
			}
			
			selection += delta
			
			if (selection > this.iPSSelectedOption)
				Loop % selection - this.iPSSelectedOption {
					Send [Up}
					Sleep 50
				}
			else
				Loop % this.iPSSelectedOption - selection {
					Send [Down}
					Sleep 50
				}
			
			this.iPSSelectedOption := selection
		}
		
		changePitstopOption(direction, steps := 1) {
			switch direction {
				case "Increase":
					Loop % steps {
						Send {Right}
						Sleep 50
					}
				case "Decrease":
					Loop % steps {
						Send {Left}
						Sleep 50
					}
				default:
					Throw "Unsupported change operation """ . direction . """ detected in ACCManager.changePitstopOption..."
			}
		}
		
		toggleActivity(activity) {
			if !this.iPSIsOpen
				this.openPitstop()
				
			switch activity {
				case "Change Tires", "Change Brakes", "Repair Bodywork", "Repair Suspension":
					this.selectPitstopOption(activity)
					
					Send {Right}
				default:
					Throw "Unsupported activity """ . activity . """ detected in ACCManager.toggleActivity..."
			}
			
			if (activity = "Change Tires")
				his.iPSChangeTires := !this.iPSChangeTires
			else if activity = "Change Brakes")
				his.iPSChangeBrakes := !this.iPSChangeBrakes
			
			Sleep 100
		}

		changeStrategy(direction, steps := 1) {
			if !this.iPSIsOpen
				this.openPitstop()
				
			this.selectPitstopOption("Strategy")
			
			this.changePitstopOption(direction, steps)
		}

		changeFuelAmount(direction, liters := 5) {
			if !this.iPSIsOpen
				this.openPitstop()
				
			this.selectPitstopOption("Refuel")
			
			this.changePitstopOption(direction, liters)
		}

		changeTirePressure(tire, direction, increments := 1) {
			if !this.iPSIsOpen
				this.openPitstop()
				
			switch tire {
				case "Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					this.selectPitstopOption(tire)
				default:
					Throw "Unsupported tire position """ . tire . """ detected in ACCManager.changeTirePressure..."
			}
			
			this.changePitstopOption(direction, increments)
		}

		changeBrakeType(brake, direction) {
			if !this.iPSIsOpen
				this.openPitstop()
				
			switch brake {
				case "Front Brake", "Rear Brake":
					this.selectPitstopOption(brake)
				default:
					Throw "Unsupported brake """ . brake . """ detected in ACCManager.changeBrakeType..."
			}
				
			switch direction^ {
				case "Next":
					this.changePitstopOption("Increase")
				case "Previous":
					this.changePitstopOption("Decrease")
				default:
					Throw "Unsupported operation """ . direction . """ detected in ACCManager.changeBrakeType..."
			}
		}
	}
	
	class DriveMode extends ControllerMode {
		Mode[] {
			Get {
				return kDriveMode
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
			
			Send {Enter}
			Sleep 100
			Send %message%
			Sleep 100
			Send {Enter}
		}
	}
	
	Manager[] {
		Get {
			return this.getACCManager()
		}
	}
	
	OpenPitstopHotkey[] {
		Get {
			return this.kOpenPitstopHotkey
		}
	}
	
	ClosePitstopHotkey[] {
		Get {
			return this.kClosePitstopHotkey
		}
	}
	
	__New(controller, name, configuration := false) {
		this.iDriveMode := new this.DriveMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iDriveMode)
		
		this.kOpenPitstopHotkey := this.getArgumentValue("openPitstopApp", false)
		this.kClosePitstopHotkey := this.getArgumentValue("closePitstopApp", false)
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
				logMessage(kLogWarn, translate("Controller function ") . descriptor . translate(" not found in plugin ") . this.Plugin . translate(" - please check the configuration"))
		}
	}
	
	getACCManager() {
		return (this.iACCManager ? this.iACCManager : (this.iACCManager := new this.ACCManager(this)))
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

openPitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.openPitstop()
	}
	finally {
		protectionOff()
	}
}

closePitstop() {
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.closePitstop()
	}
	finally {
		protectionOff()
	}
}

toggleActivity(activity) {
	if !inList(["Tires", "Brakes", "Bodywork" "Suspension"], activity)
		logMessage(kLogWarn, translate("Unsupported pit stop activity """) . activity . translate(""" detected in toggleActivity - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.toggleActivity(activity)
	}
	finally {
		protectionOff()
	}
}

changeStrategy(direction, steps := 1) {
	if !inList(["Next", "Previous"], direction)
		logMessage(kLogWarn, translate("Unsupported strategy selection """) . direction . translate(""" detected in changeStrategy - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeStrategy(direction, steps)
	}
	finally {
		protectionOff()
	}
}

changeFuelAmount(direction, liters := 5) {
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported refuel change """) . direction . translate(""" detected in changeFuelAmount - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeFuelAmount(direction, liters)
	}
	finally {
		protectionOff()
	}
}

changeTirePressure(tire, direction, increments := 1) {
	if !inList(["Around", "Front Left", "Front Right" "Rear Left", "Rear Right"], tire)
		logMessage(kLogWarn, translate("Unsupported tire position """) . tire . translate(""" detected in changeTirePressure - please check the configuration"))
		
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported pressure change """) . direction . translate(""" detected in changeTirePressure - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeTirePressure(tire, direction, increments)
	}
	finally {
		protectionOff()
	}
}

changeBrakeType(brake, direction) {
	if !inList(["Front Brake", "Rear Brake"], direction)
		logMessage(kLogWarn, translate("Unsupported brake unit """) . brake . translate(""" detected in changeBrakeType - please check the configuration"))
	
	if !inList(["Next", "Previous"], direction)
		logMessage(kLogWarn, translate("Unsupported brake selection """) . direction . translate(""" detected in changeBrakeType - please check the configuration"))
	
	protectionOn()
	
	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeBrakeType(brake, direction)
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin() {
	local controller := SimulatorController.Instance
	
	new ACCPlugin(controller, kACCPLugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()
