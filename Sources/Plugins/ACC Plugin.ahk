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
	iACCManager := false
	iDriveMode := false
	
	class ACCManager {
		iChangeTires := false
		iChangeBreaks := false
		
		__New(plugin) {
			this.iPlugin := plugin
			
			base.__New()
		}
		
		openPitStop() {
		}
		
		closePitStop() {
		}
		
		toggleActivity(activity) {
			switch activity {
				case "Refuel":
				case "Tires":
				case "Brakes":
				case "Bodywork":
				case "Suspension":
				default:
					Throw "Unsupported activity """ . activity . """ detected in PitStopManager.toggleActivity..."
			}
		}

		changeStrategy(direction, steps := 1) {
		}

		changeFuelAmount(direction, liters := 5) {
		}

		changeTirePressure(tire, direction, increments := 1) {
			switch tire {
				case "Front Left":
				case "Front Right":
				case "Rear Left":
				case "Rear Right":
				default:
					Throw "Unsupported tire position """ . tire . """ detected in PitStopManager.changeTirePressure..."
			}
			
			switch direction {
				case "Increase":
				case "Decrease":
				default:
					Throw "Unsupported pressure change """ . direction . """ detected in PitStopManager.changeTirePressure..."
			}
		}

		changeBrakeType(direction) {
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
	
	__New(controller, name, configuration := false) {
		this.iDriveMode := new this.DriveMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iDriveMode)
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
	return SimulatorController.Instance.startSimulator(new Application("Assetto Corsa Competizione", SimulatorController.Instance.Configuration)
													 , "Simulator Splash Images\ACC Splash.jpg")
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

openPitStop() {
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.openPitStop()
}

closePitStop() {
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.closePitStop()
}

toggleActivity(activity) {
	if !inList(["Refuel", "Tires", "Brakes", "Bodywork" "Suspension"], activity)
		logMessage(kLogWarn, translate("Unsupported pit stop activity """) . activity . translate(""" detected in toggleActivity - please check the configuration"))
	
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.toggleActivity(activity)
}

changeStrategy(direction, steps := 1) {
	if !inList(["Next", "Previous"], direction)
		logMessage(kLogWarn, translate("Unsupported strategy selection """) . direction . translate(""" detected in changeStrategy - please check the configuration"))
	
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeStrategy(direction, steps)
}

changeFuelAmount(direction, liters := 5) {
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported refuel change """) . direction . translate(""" detected in changeFuelAmount - please check the configuration"))
	
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeFuelAmount(direction, liters)
}

changeTirePressure(tire, direction, increments := 1) {
	if !inList(["Front Left", "Front Right" "Rear Left", "Rear Right"], tire)
		logMessage(kLogWarn, translate("Unsupported tire position """) . tire . translate(""" detected in changeTirePressure - please check the configuration"))
		
	if !inList(["Increase", "Decrease"], direction)
		logMessage(kLogWarn, translate("Unsupported pressure change """) . direction . translate(""" detected in changeTirePressure - please check the configuration"))
	
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeTirePressure(tire, direction, increments)
}

changeBrakeType(direction) {
	if !inList(["Next", "Previous"], direction)
		logMessage(kLogWarn, translate("Unsupported brake selection """) . direction . translate(""" detected in changeBrakeType - please check the configuration"))
	
	SimulatorController.Instance.findPlugin(kACCPlugin).Manager.changeBrakeType(direction)
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
