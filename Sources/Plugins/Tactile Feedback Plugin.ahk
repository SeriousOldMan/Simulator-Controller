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

#Include "..\Libraries\Task.ahk"


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
		Mode {
			Get {
				return kPedalVibrationMode
			}
		}

		isActive() {
			return (super.isActive() && this.Plugin.Application.isRunning())
		}
	}

	class ChassisVibrationMode extends ControllerMode {
		Mode {
			Get {
				return kChassisVibrationMode
			}
		}

		isActive() {
			return (super.isActive() && this.Plugin.Application.isRunning())
		}
	}

	class SimHubAction extends ControllerAction {
		Plugin {
			Get {
				return this.Controller.findPlugin(kTactileFeedbackPlugin)
			}
		}
	}

	class SimHub1WayAction extends TactileFeedbackPlugin.SimHubAction {
		iCommand := false

		Command {
			Get {
				return this.iCommand
			}
		}

		__New(function, label, icon, command) {
			this.iCommand := command

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			callSimHub(this.Command)
		}
	}

	class SimHub2WayAction extends TactileFeedbackPlugin.SimHubAction {
		iUpCommands := []
		iDownCommands := []

		UpCommands {
			Get {
				return this.iUpCommands
			}
		}

		DownCommands {
			Get {
				return this.iDownCommands
			}
		}

		__New(function, label, icon, upCommands, downCommands) {
			this.iUpCommands := upCommands
			this.iDownCommands := downCommands

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			do(((trigger = "On") || (trigger = kIncrease) || (trigger == "Push")) ? this.UpCommands : this.DownCommands, callSimHub)
		}
	}

	class FXToggleAction extends TactileFeedbackPlugin.SimHub1WayAction {
		Active {
			Get {
				local plugin := this.Plugin

				if plugin {
					switch this.Command, false {
						case "togglePedalVibration":
							return this.Plugin.PedalVibrationEnabled
						case "toggleFrontChassisVibration":
							return this.Plugin.FrontVibrationEnabled
						case "toggleRearChassisVibration":
							return this.Plugin.RearVibrationEnabled
						default:
							throw "Unsupported command detected in FXToggleAction.Active..."
					}
				}
				else
					return false
			}
		}

		Action {
			Get {
				local plugin := this.Plugin

				if plugin {
					switch this.Command, false {
						case "togglePedalVibration":
							return "PedalVibration"
						case "toggleFrontChassisVibration":
							return "FrontVibration"
						case "toggleRearChassisVibration":
							return "RearVibration"
						default:
							throw "Unsupported command detected in FXToggleAction.Action..."
					}
				}
				else
					throw "Inconsistent state detected in FXToggleAction.Action..."
			}
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (this.Active && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				switch this.Action, false {
					case "PedalVibration":
						plugin.disablePedalVibration()
					case "FrontVibration":
						plugin.disableFrontVibration()
					case "RearVibration":
						plugin.disableRearVibration()
					default:
						throw "Unsupported action detected in FXToggleAction.Action..."
				}
			}
			else if (!this.Active && ((trigger = "On") || (trigger == "Push")))
				switch this.Action, false {
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

		UpChange {
			Get {
				return this.iUpChange
			}
		}

		DownChange {
			Get {
				return this.iDownChange
			}
		}

		__New(function, label, icon, category, effect, upChange, downChange := false) {
			this.iUpChange := upChange
			this.iDownChange := downChange

			upChange := StrLower(upChange)

			if ((effect = "") || (category = effect)) {
				upChange := [upChange . category . "Vibration"]
				downChange := (downChange ? [StrLower(downChange) . category . "Vibration"] : [])

				effect := category
			}
			else if (category = "Pedal") {
				upChange := [upChange . category . effect . "Vibration"]
				downChange := (downChange ? [StrLower(downChange) . category . effect . "Vibration"] : [])
			}
			else if (category = "Chassis") {
				if ((effect = "FrontChassis") || (effect = "RearChassis")) {
					upChange := [upChange . effect . "Vibration"]
					downChange := (downChange ? [StrLower(downChange) . effect . "Vibration"] : [])
				}
				else {
					upChange := [upChange . "FrontChassis" . effect . "Vibration", upChange . "RearChassis" . effect . "Vibration"]
					downChange := (downChange ? [StrLower(downChange) . "FrontChassis" . effect . "Vibration"
											   , StrLower(downChange) . "RearChassis" . effect . "Vibration"] : [])
				}
			}

			this.iEffect := effect

			super.__New(function, label, icon, upChange, downChange)
		}

		fireAction(function, trigger) {
			local change

			super.fireAction(function, trigger)

			change := (((trigger = "On") || (trigger = kIncrease) || (trigger == "Push")) ? this.UpChange : this.DownChange)

			change := StrTitle(change)

			trayMessage(translate(this.iEffect), translate(change) . translate(" Vibration"))

			this.Function.setLabel(((change = kIncrease) ? "+ " : "- ") . kVibrationIntensityIncrement . "%", "Black", true)

			Sleep(500)

			this.Function.setLabel(translate(this.Label))
		}
	}

	Application {
		Get {
			return this.iVibrationApplication
		}
	}

	PedalVibrationEnabled {
		Get {
			return this.iPedalVibrationEnabled
		}
	}

	FrontVibrationEnabled {
		Get {
			return this.iFrontVibrationEnabled
		}
	}

	RearVibrationEnabled {
		Get {
			return this.iRearVibrationEnabled
		}
	}

	__New(controller, name, configuration := false, register := true) {
		global kSimHub

		local pedalVibrationEnabled := false
		local frontVibrationEnabled := false
		local rearVibrationEnabled := false
		local simFeedbackApplication, pedalVibrationArguments, frontChassisVibrationArguments, rearChassisVibrationArguments
		local pedalMode, chassisMode, ignore, effect, toggle

		super.__New(controller, name, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			simFeedbackApplication := Application(this.getArgumentValue("controlApplication", kTactileFeedbackPlugin), configuration)

			kSimHub := simFeedbackApplication.ExePath

			if (!kSimHub || !FileExist(kSimHub)) {
				logMessage(kLogCritical, translate("Plugin Tactile Feedback deactivated, because the configured application path (") . kSimHub . translate(") cannot be found - please check the configuration"))

				if !isDebug()
					return
			}

			this.iVibrationApplication := Application(kTactileFeedbackPlugin, configuration)

			pedalVibrationArguments := string2Values(A_Space, this.getArgumentValue("pedalVibration", ""))
			frontChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("frontChassisVibration", ""))
			rearChassisVibrationArguments := string2Values(A_Space, this.getArgumentValue("rearChassisVibration", ""))

			if (pedalVibrationArguments.Length > 0)
				this.createToggleAction("PedalVibration", "togglePedalVibration", pedalVibrationArguments[2], (pedalVibrationArguments[1] = "On"))
			if (frontChassisVibrationArguments.Length > 0)
				this.createToggleAction("FrontVibration", "toggleFrontChassisVibration", frontChassisVibrationArguments[2], (frontChassisVibrationArguments[1] = "On"))
			if (rearChassisVibrationArguments.Length > 0)
				this.createToggleAction("RearVibration", "toggleRearChassisVibration", rearChassisVibrationArguments[2], (rearChassisVibrationArguments[1] = "On"))

			pedalMode := TactileFeedbackPlugin.PedalVibrationMode(this)

			this.iPedalVibrationMode := pedalMode

			if (pedalVibrationArguments.Length > 2)
				this.createDialAction(pedalMode, "Pedal", pedalVibrationArguments[3])

			for ignore, effect in string2Values(",", this.getArgumentValue("pedalEffects", ""))
				this.createEffectAction(controller, pedalMode, "Pedal", string2Values(A_Space, effect)*)

			chassisMode := TactileFeedbackPlugin.ChassisVibrationMode(this)

			this.iChassisVibrationMode := chassisMode

			if (frontChassisVibrationArguments.Length > 2)
				this.createDialAction(chassisMode, "FrontChassis", frontChassisVibrationArguments[3])

			if (rearChassisVibrationArguments.Length > 2)
				this.createDialAction(chassisMode, "RearChassis", rearChassisVibrationArguments[3])

			for ignore, effect in string2Values(",", this.getArgumentValue("chassisEffects", ""))
				this.createEffectAction(controller, chassisMode, "Chassis", string2Values(A_Space, effect)*)

			if register
				controller.registerPlugin(this)

			for ignore, toggle in ["Pedal", "Front", "Rear"]
				if (this.StartupSettings && (getMultiMapValue(this.StartupSettings, "Functions", toggle . " Vibration", kUndefined) != kUndefined))
					%toggle . "VibrationEnabled"% := getMultiMapValue(this.StartupSettings, "Functions", toggle . " Vibration")
				else
					%toggle . "VibrationEnabled"% := this.%toggle . "VibrationEnabled"%

			if rearVibrationEnabled
				this.enableRearVibration(false, true, rearVibrationEnabled != this.RearVibrationEnabled)
			else
				this.disableRearVibration(false, true, rearVibrationEnabled != this.RearVibrationEnabled)

			if frontVibrationEnabled
				this.enableFrontVibration(false, true, frontVibrationEnabled != this.FrontVibrationEnabled)
			else
				this.disableFrontVibration(false, true, frontVibrationEnabled != this.FrontVibrationEnabled)

			if pedalVibrationEnabled
				this.enablePedalVibration(false, true, pedalVibrationEnabled != this.PedalVibrationEnabled)
			else
				this.disablePedalVibration(false, true, pedalVibrationEnabled != this.PedalVibrationEnabled)

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

				this.registerAction(TactileFeedbackPlugin.FXToggleAction(function, this.getLabel(descriptor, toggle), this.getIcon(descriptor), command))
			}
			else
				this.logFunctionNotFound(descriptor)
		}

		this.%"i" . toggle . "Enabled"% := initialState
	}

	createDialAction(mode, effect, descriptor) {
		local function := this.Controller.findFunction(descriptor)

		if (function != false) {
			descriptor := ConfigurationItem.descriptor(effect, "Dial")

			mode.registerAction(TactileFeedbackPlugin.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), effect, "", kIncrease, kDecrease))
		}
		else
			this.logFunctionNotFound(descriptor)
	}

	createEffectAction(controller, mode, category, effect, increaseFunction, decreaseFunction := false) {
		local function := this.Controller.findFunction(increaseFunction)
		local descriptor

		if !decreaseFunction {
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Dial")

				mode.registerAction(TactileFeedbackPlugin.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), category, effect, kIncrease, kDecrease))
			}
			else
				this.logFunctionNotFound(increaseFunction)
		}
		else {
			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Increase")

				mode.registerAction(TactileFeedbackPlugin.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), category, effect, kIncrease))
			}
			else
				this.logFunctionNotFound(increaseFunction)

			function := this.Controller.findFunction(decreaseFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(effect, "Decrease")

				mode.registerAction(TactileFeedbackPlugin.FXChangeAction(function, this.getLabel(descriptor, effect), this.getIcon(descriptor), category, effect, kDecrease))
			}
			else
				this.logFunctionNotFound(decreaseFunction)
		}
	}

	writePluginState(configuration) {
		if this.Active {
			setMultiMapValue(configuration, this.Plugin, "State", "Active")

			setMultiMapValue(configuration, this.Plugin, "Information"
										  , values2String("; ", translate("Pedal Vibration: ") . translate(this.PedalVibrationEnabled ? "On" : "Off")
															  , translate("Front Vibration: ") . translate(this.FrontVibrationEnabled ? "On" : "Off")
															  , translate("Rear Vibration: ") . translate(this.RearVibrationEnabled ? "On" : "Off")))
		}
		else
			super.writePluginState(configuration)
	}

	getLabel(descriptor, default := false) {
		local label := translate(super.getLabel(descriptor, default))

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
		super.activate()

		this.updateActions()

		if !this.iUpdateVibrationStateTask {
			this.iUpdateVibrationStateTask := PeriodicTask(ObjBindMethod(this, "updateVibrationState"), 50, kLowPriority)

			this.iUpdateVibrationStateTask.start()
		}
	}

	deactivate() {
		if this.iUpdateVibrationStateTask {
			this.iUpdateVibrationStateTask.stop()

			this.iUpdateVibrationStateTask := false
		}

		super.deactivate()
	}

	requireSimHub() {
		if !this.Application.isRunning() {
			this.Application.startup()

			loop 20
				Sleep(500)
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
		static hasTrayMenu := CaseInsenseMap()
		static first := true

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu.Has(callback) {
			if first
				A_TrayMenu.Insert("1&")

			A_TrayMenu.Insert("1&", label, (*) => ObjBindMethod(this, callback).Call())

			hasTrayMenu[callback] := true
			first := false
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
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

		this.%"i" . action . "Enabled"% := true

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

		this.%"i" . action . "Enabled"% := false

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

		static isRunning := kUndefined

		if (isRunning == kUndefined)
			isRunning := !this.Application.isRunning()

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
	local simHub := Application("Tactile Feedback", SimulatorController.Instance.Configuration)

	return (simHub.isRunning() ? simHub.CurrentPID : simHub.startup(false))
}

callSimHub(command) {
	local message

	try {
		logMessage(kLogInfo, translate("Sending command '") . command . translate("' to SimHub (") . kSimHub . translate(")"))

		RunWait("`"" . kSimHub . "`" -triggerinput " . command, , "Hide")
	}
	catch Any as exception {
		logError(exception, true)

		message := (isObject(exception) ? exception.Message : exception)

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

	TactileFeedbackPlugin(controller, kTactileFeedbackPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

enablePedalVibration() {
	withProtection(activatePedalVibration)
}

disablePedalVibration() {
	withProtection(deactivatePedalVibration)
}

enableFrontChassisVibration() {
	withProtection(activateFrontChassisVibration)
}

disableFrontChassisVibration() {
	withProtection(deactivateFrontChassisVibration)
}

enableRearChassisVibration() {
	withProtection(activateRearChassisVibration)
}

disableRearChassisVibration() {
	withProtection(deactivateRearChassisVibration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTactileFeedbackPlugin()
