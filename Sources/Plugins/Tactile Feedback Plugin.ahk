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
	iVibrationApplication := false
	iPedalVibrationMode := false
	iChassisVibrationMode := false

	iPedalVibrationEnabled := false
	iFrontVibrationEnabled := false
	iRearVibrationEnabled := false

	class PedalVibrationMode extends ControllerMode {
		Mode[] {
			Get {
				return kPedalVibrationMode
			}
		}

		isActive() {
			return (base.isActive() && this.Plugin.Application.isRunning())
		}
	}

	class ChassisVibrationMode extends ControllerMode {
		Mode[] {
			Get {
				return kChassisVibrationMode
			}
		}

		isActive() {
			return (base.isActive() && this.Plugin.Application.isRunning())
		}
	}

	class SimHub1WayAction extends ControllerAction {
		iCommand := false

		Command[] {
			Get {
				return this.iCommand
			}
		}

		__New(function, label, icon, command) {
			this.iCommand := command

			base.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			callSimHub(this.Command)
		}
	}

	class SimHub2WayAction extends ControllerAction {
		iUpCommand := false
		iDownCommand := false

		UpCommand[] {
			Get {
				return this.iUpCommand
			}
		}

		DownCommand[] {
			Get {
				return this.iDownCommand
			}
		}

		__New(function, label, icon, upCommand, downCommand) {
			this.iUpCommand := upCommand
			this.iDownCommand := downCommand

			base.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			callSimHub(((trigger = "On") || (trigger = kIncrease) || (trigger == "Push")) ? this.UpCommand : this.DownCommand)
		}
	}

	class FXToggleAction extends TactileFeedbackPlugin.SimHub1WayAction {
		Active[] {
			Get {
				switch this.Command {
					case "togglePedalVibration":
						return this.Plugin.PedalVibrationEnabled
					case "toggleFrontChassisVibration":
						return this.Plugin.FrontVibrationEnabled
					case "toggleRearChassisVibration":
						return this.Plugin.RearVibrationEnabled
					default:
						Throw "Unsupported command detected in FXToggleAction.Active..."
				}
			}
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (this.Active && ((trigger = "Off") || (trigger == "Push")))
				plugin.disableFX(translate(this.Label), false, this.Command)
			else if (!this.iIsActive && ((trigger = "On") || (trigger == "Push")))
				plugin.enableFX(translate(this.Label), false, this.Command)
		}
	}

	class FXChangeAction extends TactileFeedbackPlugin.SimHub2WayAction {
		iEffect := ""
		iUpChange := ""
		iDownChange := false

		UpChange[] {
			Get {
				return this.iUpChange
			}
		}

		DownChange[] {
			Get {
				return this.iDownChange
			}
		}

		__New(function, label, icon, effect, upChange, downChange := false) {
			this.iEffect := effect
			this.iUpChange := upChange
			this.iDownChange := downChange

			StringLower upChange, upChange

			upChange := upChange . effect . "Vibration"

			if downChange {
				StringLower downChange, downChange

				downChange := downChange . effect . "Vibration"
			}

			base.__New(function, label, icon, upChange, downChange)
		}

		fireAction(function, trigger) {
			base.fireAction(function, trigger)

			change := (((trigger = "On") || (trigger = kIncrease) || (trigger == "Push")) ? this.UpChange : this.DownChange)

			StringUpper change, change, T

			trayMessage(translate(this.iEffect), translate(change) . translate(" Vibration"))

			this.Function.setLabel(((change = kIncrease) ? "+ " : "- ") . kVibrationIntensityIncrement . "%", "Black", true)

			Sleep 500

			this.Function.setLabel(translate(this.Label))
		}
	}

	Application[] {
		Get {
			return this.iVibrationApplication
		}
	}

	PedalVibrationEnabled[] {
		Get {
			return this.iPedalVibrationEnabled
		}
	}

	FrontVibrationEnabled[] {
		Get {
			return this.iFrontVibrationEnabled
		}
	}

	RearVibrationEnabled[] {
		Get {
			return this.iRearVibrationEnabled
		}
	}

	__New(controller, name, configuration := false, register := true) {
		base.__New(controller, name, configuration, false)

		if (this.Active || isDebug()) {
			simFeedbackApplication := new Application(this.getArgumentValue("controlApplication", kTactileFeedbackPlugin), configuration)

			kSimHub := simFeedbackApplication.ExePath

			if (!kSimHub || !FileExist(kSimHub)) {
				logMessage(kLogCritical, translate("Plugin Tactile Feedback deactivated, because the configured application path (") . kSimHub . translate(") cannot be found - please check the configuration"))

				if !isDebug()
					return
			}

			this.iVibrationApplication := new Application(kTactileFeedbackPlugin, configuration)

			pedalVibrationArguments := string2Values(A_Space, this.getArgumentValue("pedalVibration", ""))
			frontChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("frontChassisVibration", ""))
			rearChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("rearChassisVibration", ""))

			if (pedalVibrationArguments.Length() > 0)
				this.createToggleAction("PedalVibration", "togglePedalVibration", pedalVibrationArguments[2], (pedalVibrationArguments[1] = "On"))
			if (frontChassisVibrationArguments.Length() > 0)
				this.createToggleAction("FrontVibration", "toggleFrontChassisVibration", frontChassisVibrationArguments[2], (frontChassisVibrationArguments[1] = "On"))
			if (rearChassisVibrationArguments.Length() > 0)
				this.createToggleAction("RearVibration", "toggleRearChassisVibration", rearChassisVibrationArguments[2], (rearChassisVibrationArguments[1] = "On"))

			pedalMode := new this.PedalVibrationMode(this)

			this.iPedalVibrationMode := pedalMode

			if (pedalVibrationArguments.Length() > 2)
				this.createDialAction(pedalMode, "Pedal", pedalVibrationArguments[3])

			for ignore, effect in string2Values(",", this.getArgumentValue("pedalEffects", ""))
				this.createEffectAction(controller, pedalMode, string2Values(A_Space, effect)*)

			chassisMode := new this.ChassisVibrationMode(this)

			this.iChassisVibrationMode := chassisMode

			if (frontChassisVibrationArguments.Length() > 2)
				this.createDialAction(chassisMode, "FrontChassis", frontChassisVibrationArguments[3])

			if (rearChassisVibrationArguments.Length() > 2)
				this.createDialAction(chassisMode, "RearChassis", rearChassisVibrationArguments[3])

			for ignore, effect in string2Values(",", this.getArgumentValue("chassisEffects", ""))
				this.createEffectAction(controller, chassisMode, string2Values(A_Space, effect)*)

			if register
				controller.registerPlugin(this)

			if this.RearVibrationEnabled
				this.enableRearVibration(false, true, false)
			else
				this.disableRearVibration(false, true, false)

			if this.FrontVibrationEnabled
				this.enableFrontVibration(false, true, false)
			else
				this.disableFrontVibration(false, true, false)

			if this.PedalVibrationEnabled
				this.enablePedalVibration(false, true, false)
			else
				this.disablePedalVibration(false, true, false)
		}
	}

	createToggleAction(toggle, command, descriptor, initialState) {
		local function

		if (descriptor != false) {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(toggle, "Toggle")

				this.registerAction(new this.FXToggleAction(function, this.getLabel(descriptor, toggle), this.getIcon(descriptor), command))
			}
			else
				this.logFunctionNotFound(descriptor)
		}

		this["i" . toggle . "Enabled"] := initialState
	}

	createDialAction(mode, effect, descriptor) {
		local function := this.Controller.findFunction(descriptor)

		if (function != false) {
			descriptor := ConfigurationItem.descriptor(effect, "Dial")

			mode.registerAction(new this.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), effect, kIncrease, kDecrease))
		}
		else
			this.logFunctionNotFound(descriptor)
	}

	createEffectAction(controller, mode, effect, increaseFunction, decreaseFunction := false) {
		local function := this.Controller.findFunction(increaseFunction)

		if !decreaseFunction {
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Dial")

				mode.registerAction(new this.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), effect, kIncrease, kDecrease))
			}
			else
				this.logFunctionNotFound(increaseFunction)
		}
		else {
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Increase")

				mode.registerAction(new this.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), effect, kIncrease))
			}
			else
				this.logFunctionNotFound(increaseFunction)

			function := this.Controller.findFunction(decreaseFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Decrease")

				mode.registerAction(new this.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), effect, kDecrease))
			}
			else
				this.logFunctionNotFound(decreaseFunction)
		}
	}

	getLabel(descriptor, default := false) {
		label := translate(base.getLabel(descriptor, default))

		return StrReplace(StrReplace(label, "Increase", translate("Increase")), "Decrease", translate("Decrease"))
	}

	activate() {
		base.activate()

		isRunning := this.Application.isRunning()

		for ignore, theAction in this.Actions
			theAction.Function.setLabel(translate(theAction.Label), isRunning ? (theAction.Active ? "Green" : "Black") : "Olive")

		SetTimer updateVibrationState, -50
	}

	deactivate() {
		SetTimer updateVibrationState, Off

		base.deactivate()
	}

	requireSimHub() {
		if !this.Application.isRunning() {
			this.Application.startup()

			Loop 20 {
				Sleep 500
			} until this.Application.isRunning()

			this.deactivate()
			this.activate()
		}
	}

	togglePedalVibration() {
		if this.PedalVibrationEnabled
			this.disablePedalVibration()
		else
			this.enablePedalVibration()
	}

	toggleFrontChassisVibration() {
		if this.FrontVibrationEnabled
			this.disableFrontVibration()
		else
			this.enableFrontVibration()
	}

	toggleRearChassisVibration() {
		if this.RearVibrationEnabled
			this.disableRearVibration()
		else
			this.enableRearVibration()
	}

	updateTrayLabel(label, enabled, callback) {
		static hasTrayMenu := {}
		static first := true

		label := StrReplace(label, "`n", A_Space)

		if !hasTrayMenu.HasKey(callback) {
			handler := ObjBindMethod(this, callback)

			if first
				Menu Tray, Insert, 1&

			Menu Tray, Insert, 1&, %label%, %handler%

			hasTrayMenu[callback] := true
			first := false
		}

		if enabled
			Menu Tray, Check, %label%
		else
			Menu Tray, Uncheck, %label%
	}

	enableFX(label, action, command, call := true) {
		if (call && !this.Application.isRunning()) {
			this.requireSimHub()

			return false
		}

		actionLabel := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)

		if !label
			label := actionLabel

		trayMessage(label, translate("State: On"))

		this.findAction(actionLabel).Function.setLabel(label, "Green")

		if call
			callSimHub(command)

		this.updateTrayLabel(label, true, command)

		return true
	}

	disableFX(label, action, command, call := true) {
		if (call && !this.Application.isRunning()) {
			this.requireSimHub()

			return false
		}

		actionLabel := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)

		if !label
			label := actionLabel

		trayMessage(label, translate("State: Off"))

		this.findAction(actionLabel).Function.setLabel(label, "Black")

		if call
			callSimHub(command)

		this.updateTrayLabel(label, false, command)

		return true
	}

	enablePedalVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Pedal Vibration")

		if (!this.PedalVibrationEnabled || force)
			if this.enableFX(label, "PedalVibration", "togglePedalVibration", call)
				this.iPedalVibrationEnabled := true
	}

	disablePedalVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Pedal Vibration")

		if (this.PedalVibrationEnabled || force)
			if this.enableFX(label, "PedalVibration", "togglePedalVibration", call)
				this.iPedalVibrationEnabled := false
	}

	enableFrontVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Front Vibration")

		if (!this.FrontVibrationEnabled || force)
			if this.enableFX(label, "FrontVibration", "toggleFrontChassisVibration", call)
				this.iFrontVibrationEnabled := true
	}

	disableFrontVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Front Vibration")

		if (this.FrontVibrationEnabled || force)
			if this.enableFX(label, "FrontVibration", "toggleFrontChassisVibration", call)
				this.iFrontVibrationEnabled := false
	}

	enableRearVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Rear Vibration")

		if (!this.RearVibrationEnabled || force)
			if this.enableFX(label, "RearVibration", "toggleRearChassisVibration", call)
				this.iRearVibrationEnabled := true
	}

	disableRearVibration(label := false, force := false, call := true) {
		if !label
			label := translate("Rear Vibration")

		if (this.RearVibrationEnabled || force)
			if this.enableFX(label, "RearVibration", "toggleRearChassisVibration", call)
				this.iRearVibrationEnabled := false
	}

	updateVibrationState() {
		static isRunning := "__Undefined__"

		if (isRunning == kUndefined)
			isRunning := this.Application.isRunning()

		if (isRunning != this.Application.isRunning()) {
			protectionOn()

			try {
				if isRunning {
					controller := this.Controller
					activeModes := this.Controller.ActiveModes
					pedalMode := this.findMode(kPedalVibrationMode)
					chassisMode := this.findMode(kChassisVibrationMode)

					if inList(activeModes, pedalMode) {
						controller.rotateMode(1, pedalMode.FunctionController)

						if inList(controller.ActiveModes, pedalMode)
							pedalMode.deactivate()
					}

					if inList(activeModes, chassisMode) {
						this.Controller.rotateMode(1, chassisMode.FunctionController)

						if inList(controller.ActiveModes, chassisMode)
							chassisMode.deactivate()
					}
				}

				this.deactivate()
				this.activate()

				isRunning := !isRunning
			}
			finally {
				protectionOff()
			}
		}

		setTimer updateVibrationState, % isRunning ? 5000 : 1000
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateVibrationState() {
	static plugin := false

	if !plugin
		plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	plugin.updateVibrationState()
}

startSimHub() {
	simHub := new Application("Tactile Feedback", SimulatorController.Instance.Configuration)

	return (simHub.isRunning() ? simHub.CurrentPID : simHub.startup(false))
}

callSimHub(command) {
	try {
		logMessage(kLogInfo, translate("Sending command '") . command . translate("' to SimHub (") . kSimHub . translate(")"))

		RunWait "%kSimHub%" -triggerinput %command%, , Hide
	}
	catch exception {
		message := (IsObject(exception) ? exception.Message : exception)

		logMessage(kLogCritical, translate("Error while connecting to SimHub (") . kSimHub . translate("): ") . message . translate(" - please check the configuration"))

		showMessage(substituteVariables(translate("Cannot connect to SimHub (%kSimHub%) - please check the configuration..."))
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

		return 0
	}
}

activatePedalVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("PedalVibration", "Toggle"), "PedalVibration"))

		plugin.enablePedalVibration() ; action.fireAction(action.Function, "On")
	}
}

deactivatePedalVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("PedalVibration", "Toggle"), "PedalVibration"))

		plugin.disablePedalVibration() ; action.fireAction(action.Function, "Off")
	}
}

activateFrontChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("FrontVibration", "Toggle"), "FrontVibration"))

		plugin.enableFrontVibration() ; action.fireAction(action.Function, "On")
	}
}

deactivateFrontChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("FrontVibration", "Toggle"), "FrontVibration"))

		plugin.disableFrontVibration() ; action.fireAction(action.Function, "Off")
	}
}

activateRearChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("RearVibration", "Toggle"), "RearVibration"))

		plugin.enableRearVibration() ; action.fireAction(action.Function, "On")
	}
}

deactivateRearChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)
	local action

	if (plugin && SimulatorController.Instance.isActive(plugin)) {
		; action := plugin.findAction(plugin.getLabel(ConfigurationItem.descriptor("RearVibration", "Toggle"), "RearVibration"))

		plugin.disableFrontVibration() ; action.fireAction(action.Function, "Off")
	}
}

initializeTactileFeedbackPlugin() {
	controller := SimulatorController.Instance

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

initializeTactileFeedbackPlugin()
