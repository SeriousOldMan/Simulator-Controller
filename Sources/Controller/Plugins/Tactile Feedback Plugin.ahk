;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tactile Feedback Plugin         ;;;
;;;                                         (Powered by SimHub)             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    Creative Commons - BY-NC-SA                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;


global kVibrationIntensityIncrement = 5

global kEffectMappings = {TC: ["TC", "Increase TC", "Decrease TC"]
						, ABS: ["ABS", "Increase ABS", "Decrease ABS"]
						, RPMS: ["RPMS", "Increase RPMS", "Decrease RPMS"]
						, GearShift: ["Gear Shift", "Increase Shift", "Decrease Shift"]
						, WheelsLock: ["Wheels Lock", "Increase Whls Lck", "Decrease Whls Lck"]
						, WheelsSlip: ["Wheels Slip", "Increase Whls Slip", "Decrease Whls Slip"]}

global kSimHub

						
;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTactileFeedbackPlugin = "Tactile Feedback"

global kPedalVibrationMode = "Pedal Vibration"
global kChassisVibrationMode = "Chassis Vibration"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;
	
class TactileFeedbackPlugin extends ControllerPlugin {
	iPedalVibrationMode := false
	iChassisVibrationMode := false

	class PedalVibrationMode extends ControllerMode {
		Mode[] {
			Get {
				return kPedalVibrationMode
			}
		}
	}

	class ChassisVibrationMode extends ControllerMode {
		Mode[] {
			Get {
				return kChassisVibrationMode
			}
		}
	}
	
	class SimHub1WayAction extends ControllerAction {
		iCommand := false
		
		__New(function, label, command) {
			this.iCommand := command
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			callSimHub(this.iCommand)
		}
	}

	class SimHub2WayAction extends ControllerAction {
		iUpCommand := false
		iDownCommand := false
		
		__New(function, label, upCommand, downCommand) {
			this.iUpCommand := upCommand
			this.iDownCommand := downCommand
			
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			callSimHub(((trigger = "On") || (trigger = "Increase") || (trigger == "Push")) ? this.iUpCommand : this.iDownCommand)
		}
	}

	class FXToggleAction extends TactileFeedbackPlugin.SimHub1WayAction {
		iIsActive := true
		
		Active[] {
			Get {
				return this.iIsActive
			}
		}
		
		__New(function, label, command, initialActive) {
			this.iIsActive := initialActive
			
			base.__New(function, label, command)
		}
		
		fireAction(function, trigger) {
			if (this.iIsActive && ((trigger = "Off") || (trigger == "Push"))) {
				base.fireAction(function, trigger)
				this.iIsActive := false
				
				trayMessage(this.Label, "State: Off")
			
				function.setText(this.Label, "Gray")
			}
			else if (!this.iIsActive && ((trigger = "On") || (trigger == "Push"))) {
				base.fireAction(function, trigger)
				this.iIsActive := true
				
				trayMessage(this.Label, "State: On")
			
				function.setText(this.Label, "Green")
			}
		}
	}

	class FXChangeAction extends TactileFeedbackPlugin.SimHub2WayAction {
		iEffect := ""
		iUpChange := ""
		iDownChange := false
		
		__New(function, label, effect, upChange, downChange := false) {
			this.iEffect := effect
			this.iUpChange := upChange
			this.iDownChange := downChange
			
			StringLower upChange, upChange
			
			upChange := upChange . effect . "Vibration"
			
			if downChange {
				StringLower downChange, downChange
				
				downChange := downChange . effect . "Vibration"
			}
			
			base.__New(function, label, upChange, downChange)
		}
		
		fireAction(function, trigger) {
			base.fireAction(function, trigger)
		
			change := (((trigger = "On") || (trigger = "Increase") || (trigger == "Push")) ? this.iUpChange : this.iDownChange)
				
			StringUpper change, change, T
		
			trayMessage(this.Label, change . " " . this.iEffect . " Vibration")
			
			this.Function.setText(((change = kIncrease) ? "+ " : "- ") . kVibrationIntensityIncrement . "%")
		
			Sleep 500
			
			this.Function.setText(this.Label)
		}
	}

	Plugin[] {
		Get {
			return kTactileFeedbackPlugin
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)
		
		pedalVibrationArguments := string2Values(A_Space, this.getArgumentValue("pedalVibration", ""))
		frontChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("frontChassisVibration", ""))
		rearChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("rearChassisVibration", ""))
		
		this.createPluginToggleAction("Pedal Vibration", "togglePedalVibration", pedalVibrationArguments[2], (pedalVibrationArguments[1] = "On"))
		this.createPluginToggleAction("Front Vibration", "toggleFrontChassisVibration", frontChassisVibrationArguments[2], (frontChassisVibrationArguments[1] = "On"))
		this.createPluginToggleAction("Rear Vibration", "toggleRearChassisVibration", rearChassisVibrationArguments[2], (rearChassisVibrationArguments[1] = "On"))
		
		pedalMode := new this.PedalVibrationMode(this)
		
		this.iPedalVibrationMode := pedalMode
		
		this.createPluginDialAction(pedalMode, "Pedal Vibration", "Pedal", pedalVibrationArguments[3])
		
		for ignore, effect in string2Values(",", this.getArgumentValue("pedalEffects", ""))
			this.createModeAction(controller, pedalMode, string2Values(A_Space, effect)*)
		
		chassisMode := new this.ChassisVibrationMode(this)
		
		this.iChassisVibrationMode := chassisMode
		
		this.createPluginDialAction(chassisMode, "Front Vibration", "FrontChassis", frontChassisVibrationArguments[3])
		this.createPluginDialAction(chassisMode, "Rear Vibration", "RearChassis", rearChassisVibrationArguments[3])
	
		for ignore, effect in string2Values(",", this.getArgumentValue("chassisEffects", ""))
			this.createModeAction(controller, chassisMode, string2Values(A_Space, effect)*)
		
		controller.registerPlugin(this)
	}

	createPluginToggleAction(label, command, descriptor, initialState) {
		if (descriptor != false) {
			function := this.Controller.findFunction(descriptor)
			
			if (function != false)
				this.registerAction(new this.FXToggleAction(function, label, command, initialState))
			else
				logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
		}
	}

	createPluginDialAction(mode, label, effect, descriptor) {
		function := this.Controller.findFunction(descriptor)
		
		if (function != false)
			mode.registerAction(new this.FXChangeAction(function, label, effect, kIncrease, kDecrease))
		else
			logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
	}
	
	createModeAction(controller, mode, effect, increaseFunction, decreaseFunction := false) {
		function := this.Controller.findFunction(increaseFunction)
		
		if !decreaseFunction {
			if (function != false)
				mode.registerAction(new this.FXChangeAction(function, kEffectMappings[effect][1], effect, kIncrease, kDecrease))
			else
				logMessage(kLogWarn, "Controller function " . increaseFunction . " not found in plugin " . this.Plugin . " - please check the setup")
		}
		else {
			if (function != false)
				mode.registerAction(new this.FXChangeAction(function, kEffectMappings[effect][2], effect, kIncrease))
			else
				logMessage(kLogWarn, "Controller function " . increaseFunction . " not found in plugin " . this.Plugin . " - please check the setup")
				
			function := this.Controller.findFunction(decreaseFunction)
			
			if (function != false)
				mode.registerAction(new this.FXChangeAction(function, kEffectMappings[effect][3], effect, kDecrease))
			else
				logMessage(kLogWarn, "Controller function " . decreaseFunction . " not found in plugin " . this.Plugin . " - please check the setup")
		}
	}
	
	activate() {
		base.activate()
	
		for ignore, action in this.Actions
			action.Function.setText(action.Label, action.Active ? "Green" : "Black")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

callSimHub(command) {
	try {
		logMessage(kLogInfo, "Sending command '" . command . "' to SimHub (" . kSimHub . ")")
		
		RunWait "%kSimHub%" -triggerinput %command%, , Hide
	}
	catch exception {
		logMessage(kLogCritical, "Error while connecting to SimHub (" . kSimHub . "): " . exception.Message . " - please check the setup")
		
		SplashTextOn 800, 60, Modular Simulator Controller System, Cannot connect to SimHub (%kSimHub%) `n`nPlease run the setup tool...
				
		Sleep 5000
					
		SplashTextOff
			
		return 0
	}
}

activatePedalVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Pedal Vibration")
	
	action.fireAction(action.Function, "On")
}

deactivatePedalVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Pedal Vibration")
	
	action.fireAction(action.Function, "Off")
}

activateFrontChassisVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Front Vibration")
	
	action.fireAction(action.Function, "On")
}

deactivateFrontChassisVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Front Vibration")
	
	action.fireAction(action.Function, "Off")
}

activateRearChassisVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Rear Vibration")
	
	action.fireAction(action.Function, "On")
}

deactivateRearChassisVibration() {
	action := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin).findAction("Rear Vibration")
	
	action.fireAction(action.Function, "Off")
}

initializeSimHubPlugin() {
	controller := SimulatorController.Instance
	
	kSimHub := getConfigurationValue(controller.Configuration, kTactileFeedbackPlugin, "Exe Path", false)
	
	if (!kSimHub || !FileExist(kSimHub)) {
		logMessage(kLogCritical, "Plugin Tactile Feedback deactivated, because the configured application path (" . kSimHub . ") cannot be found - please check the setup...")
		
		return
	}

	new TactileFeedbackPlugin(controller, kTactileFeedbackPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

enablePedalVibration() {
	withProtection("activatePedalVibration")
}

disablePedalVibration() {
	withProtection("deactivatePedalVibration")
}

enableFrontChassisVibration() {
	withProtection("activateFrontChassisVibration")
}

disableFrontChassisVibration() {
	withProtection("deactivateFrontChassisVibration")
}

enableRearChassisVibration() {
	withProtection("activateRearChassisVibration")
}

disableRearChassisVibration() {
	withProtection("deactivateRearChassisVibration")
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimHubPlugin()
