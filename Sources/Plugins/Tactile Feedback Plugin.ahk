;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tactile Feedback Plugin         ;;;
;;;                                         (Powered by SimHub)             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    Creative Commons - BY-NC-SA                               ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kVibrationIntensityIncrement := 5

global kSimHub


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTactileFeedbackPlugin := "Tactile Feedback"

global kPedalVibrationMode := "Pedal Vibration"
global kChassisVibrationMode := "Chassis Vibration"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TactileFeedbackPlugin extends ControllerPlugin {
	iUpdateVibrationStateTask := false

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

	class SimHubAction extends ControllerAction {
		Plugin[] {
			Get {
				return this.Controller.findPlugin(kTactileFeedbackPlugin)
			}
		}
	}

	class SimHub1WayAction extends TactileFeedbackPlugin.SimHubAction {
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

	class SimHub2WayAction extends TactileFeedbackPlugin.SimHubAction {
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
				local plugin := this.Plugin

				if plugin
					switch this.Command {
						case "togglePedalVibration":
							return this.Plugin.PedalVibrationEnabled
						case "toggleFrontChassisVibration":
							return this.Plugin.FrontVibrationEnabled
						case "toggleRearChassisVibration":
							return this.Plugin.RearVibrationEnabled
						default:
							throw "Unsupported command detected in FXToggleAction.Active..."
					}
				else
					return false
			}
		}

		Action[] {
			Get {
				local plugin := this.Plugin

				if plugin
					switch this.Command {
						case "togglePedalVibration":
							return "PedalVibration"
						case "toggleFrontChassisVibration":
							return "FrontVibration"
						case "toggleRearChassisVibration":
							return "RearVibration"
						default:
							throw "Unsupported command detected in FXToggleAction.Action..."
					}
				else
					throw "Inconsistent state detected in FXToggleAction.Action..."
			}
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (this.Active && ((trigger = "Off") || (trigger == "Push")))
				switch this.Action {
					case "PedalVibration":
						plugin.disablePedalVibration()
					case "FrontVibration":
						plugin.disableFrontVibration()
					case "RearVibration":
						plugin.disableRearVibration()
					default:
						throw "Unsupported action detected in FXToggleAction.Action..."
				}
			else if (!this.Active && ((trigger = "On") || (trigger == "Push")))
				switch this.Action {
					case "PedalVibration":
						plugin.enablePedalVibration()
					case "FrontVibration":
						plugin.enableFrontVibration()
					case "RearVibration":
						plugin.enableRearVibration()
					default:
						throw "Unsupported action detected in FXToggleAction.Action..."
				}
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
			local change

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
		local simFeedbackApplication, pedalVibrationArguments, frontChassisVibrationArguments, rearChassisVibrationArguments
		local pedalMode, chassisMode, ignore, effect

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

			if register
				controller.registerPlugin(this)
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
		local descriptor

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
		local label := translate(base.getLabel(descriptor, default))

		return StrReplace(StrReplace(label, "Increase", translate("Increase")), "Decrease", translate("Decrease"))
	}

	updateActions() {
		local isRunning := this.Application.isRunning()
		local function, ignore, theAction

		for ignore, theAction in this.Actions {
			function := theAction.Function

			if function
				function.setLabel(translate(theAction.Label), isRunning ? (theAction.Active ? "Green" : "Black") : "Olive")
		}
	}

	activate() {
		base.activate()

		this.updateActions()

		if !this.iUpdateVibrationStateTask {
			this.iUpdateVibrationStateTask := new PeriodicTask(ObjBindMethod(this, "updateVibrationState"), 50, kLowPriority)

			Task.startTask(this.iUpdateVibrationStateTask)
		}
	}

	deactivate() {
		if this.iUpdateVibrationStateTask {
			Task.stopTask(this.iUpdateVibrationStateTask)

			this.iUpdateVibrationStateTask := false
		}

		base.deactivate()
	}

	requireSimHub() {
		if !this.Application.isRunning() {
			this.Application.startup()

			loop 20
				Sleep 500
			until this.Application.isRunning()

			this.deactivate()
			this.activate()
		}
	}

	togglePedalVibration() {
		if this.PedalVibrationEnabled
			this.disablePedalVibration(translate("Pedal Vibration"))
		else
			this.enablePedalVibration(translate("Pedal Vibration"))
	}

	toggleFrontChassisVibration() {
		if this.FrontVibrationEnabled
			this.disableFrontVibration(translate("Front Vibration"))
		else
			this.enableFrontVibration(translate("Front Vibration"))
	}

	toggleRearChassisVibration() {
		if this.RearVibrationEnabled
			this.disableRearVibration(translate("Rear Vibration"))
		else
			this.enableRearVibration(translate("Rear Vibration"))
	}

	updateTrayLabel(label, enabled, callback) {
		local handler

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
		local actionLabel, theAction

		if (call && !this.Application.isRunning()) {
			this.requireSimHub()

			return false
		}

		actionLabel := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)

		if !label
			label := actionLabel

		trayMessage(label, translate("State: On"))

		this.updateActions()

		theAction := this.findAction(actionLabel)

		if theAction
			theAction.Function.setLabel(actionLabel, "Green")

		this["i" . action . "Enabled"] := true

		if call
			callSimHub(command)

		this.updateTrayLabel(label, true, command)

		return true
	}

	disableFX(label, action, command, call := true) {
		local actionLabel, theAction

		if (call && !this.Application.isRunning()) {
			this.requireSimHub()

			return false
		}

		actionLabel := this.getLabel(ConfigurationItem.descriptor(action, "Toggle"), action)

		if !label
			label := actionLabel

		trayMessage(label, translate("State: Off"))

		theAction := this.findAction(actionLabel)

		if theAction
			theAction.Function.setLabel(actionLabel, "Black")

		this["i" . action . "Enabled"] := false

		this.updateActions()

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
			if this.disableFX(label, "PedalVibration", "togglePedalVibration", call)
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
			if this.disableFX(label, "FrontVibration", "toggleFrontChassisVibration", call)
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
			if this.disableFX(label, "RearVibration", "toggleRearChassisVibration", call)
				this.iRearVibrationEnabled := false
	}

	updateVibrationState() {
		local controller := this.Controller
		local activeModes, pedalMode, chassisMode

		static isRunning := "__Undefined__"

		if (isRunning == kUndefined)
			isRunning := this.Application.isRunning()

		if ((isRunning != this.Application.isRunning()) && controller.isActive(this)) {
			protectionOn()

			try {
				if isRunning {
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

		Task.CurrentTask.Sleep := (isRunning ? 5000 : 1000)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startSimHub() {
	local simHub := new Application("Tactile Feedback", SimulatorController.Instance.Configuration)

	return (simHub.isRunning() ? simHub.CurrentPID : simHub.startup(false))
}

callSimHub(command) {
	local message

	try {
		logMessage(kLogInfo, translate("Sending command '") . command . translate("' to SimHub (") . kSimHub . translate(")"))

		RunWait "%kSimHub%" -triggerinput %command%, , Hide
	}
	catch exception {
		message := (IsObject(exception) ? exception.Message : exception)

		logMessage(kLogCritical, translate("Error while connecting to SimHub (") . kSimHub . translate("): ") . message . translate(" - please check the configuration"))

		showMessage(substituteVariables(translate("Cannot connect to SimHub (%kSimHub%) - please check the configuration..."))
				  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
	}
}

activatePedalVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.enablePedalVibration()
}

deactivatePedalVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.disablePedalVibration()
}

activateFrontChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.enableFrontVibration()
}

deactivateFrontChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.disableFrontVibration()
}

activateRearChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.enableRearVibration()
}

deactivateRearChassisVibration() {
	local plugin := SimulatorController.Instance.findPlugin(kTactileFeedbackPlugin)

	if (plugin && SimulatorController.Instance.isActive(plugin))
		plugin.disableFrontVibration()
}

initializeTactileFeedbackPlugin() {
	local controller := SimulatorController.Instance

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
