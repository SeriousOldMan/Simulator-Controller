;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "Libraries\RaceAssistantPlugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kDrivingCoachPlugin := "Driving Coach"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DrivingCoachPlugin extends RaceAssistantPlugin {
	iServiceState := "Available"

	iTelemetryCoachingActive := false
	iTrackCoachingActive := false
	iBrakeCoachingActive := false

	class RemoteDrivingCoach extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			super.__New(plugin, "Driving Coach", remotePID)
		}

		startTelemetryCoaching(arguments*) {
			this.callRemote("startTelemetryCoaching", arguments*)
		}

		finishTelemetryCoaching(arguments*) {
			this.callRemote("finishTelemetryCoaching", arguments*)
		}

		startTrackCoaching(arguments*) {
			this.callRemote("startTrackCoaching", arguments*)
		}

		startBrakeCoaching(arguments*) {
			this.callRemote("startBrakeCoaching", arguments*)
		}

		finishCoaching(arguments*) {
			this.callRemote("finishCoaching", arguments*)
		}
	}

	class CoachingToggleAction extends ControllerAction {
		iPlugin := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (plugin.TelemetryCoachingActive && ((trigger = "On") || (trigger = "Off") || (trigger == "Push")))
				plugin.finishTelemetryCoaching()
			else if (!plugin.TelemetryCoachingActive && ((trigger = "On") || (trigger == "Push")))
				plugin.startTelemetryCoaching()
		}
	}

	class TrackCoachingToggleAction extends ControllerAction {
		iPlugin := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (plugin.TrackCoachingActive && ((trigger = "On") || (trigger = "Off") || (trigger == "Push")))
				plugin.finishCoaching()
			else if (!plugin.TrackCoachingActive && ((trigger = "On") || (trigger == "Push")))
				plugin.startTrackCoaching()
		}
	}

	class BrakeCoachingToggleAction extends ControllerAction {
		iPlugin := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			super.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (plugin.BrakeCoachingActive && ((trigger = "On") || (trigger = "Off") || (trigger == "Push")))
				plugin.finishCoaching()
			else if (!plugin.BrakeCoachingActive && ((trigger = "On") || (trigger == "Push")))
				plugin.startBrakeCoaching()
		}
	}

	DrivingCoach {
		Get {
			return this.RaceAssistant
		}
	}

	RaceAssistantPersistent {
		Get {
			return true
		}
	}

	TelemetryCoachingActive {
		Get {
			return this.iTelemetryCoachingActive
		}
	}

	TrackCoachingActive {
		Get {
			return this.iTrackCoachingActive
		}
	}

	BrakeCoachingActive {
		Get {
			return this.iBrakeCoachingActive
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local coaching

		super.__New(controller, name, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			coaching := this.getArgumentValue("telemetryCoaching", false)

			if coaching
				this.createRaceAssistantAction(controller, "TelemetryCoaching", coaching)
		}

		if (this.Active || (isDebug() && isDevelopment())) {
			coaching := this.getArgumentValue("trackCoaching", false)

			if coaching
				this.createRaceAssistantAction(controller, "TrackCoaching", coaching)
		}

		if (this.Active || (isDebug() && isDevelopment())) {
			coaching := this.getArgumentValue("brakeCoaching", false)

			if coaching
				this.createRaceAssistantAction(controller, "BrakeCoaching", coaching)
		}

		DirCreate(kTempDirectory . "Driving Coach")

		deleteFile(kTempDirectory . "Driving Coach\Coaching.state")

		PeriodicTask(() {
			local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
			local active := getMultiMapValue(state, "Coaching", "Active", false)
			local track := (active && getMultiMapValue(state, "Coaching", "Track", false))
			local brake := (active && getMultiMapValue(state, "Coaching", "Brake", false))

			if (active != this.TelemetryCoachingActive) {
				this.iTelemetryCoachingActive := active

				this.updateTrackCoachingTrayLabel(translate("On-track Coaching"), track)
				this.updateBrakeCoachingTrayLabel(translate("Brake Coaching"), brake)

				this.updateActions(kSessionUnknown)
			}

			if (track != this.TrackCoachingActive) {
				this.iTrackCoachingActive := track

				this.updateActions(kSessionUnknown)
			}

			if (brake != this.BrakeCoachingActive) {
				this.iBrakeCoachingActive := brake

				this.updateActions(kSessionUnknown)
			}
		}, 5000, kLowPriority).start()

		Task.startTask(() {
			if this.Controller.Started {
				this.updateBrakeCoachingTrayLabel(translate("Brake Coaching"), false)
				this.updateTrackCoachingTrayLabel(translate("On-track Coaching"), false)
			}
			else
				return Task.CurrentTask
		}, 500, kHighPriority)
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local descriptor

		if (inList(["RaceAssistant", "Call", "SetupWorkbenchOpen", "Interrupt"], action))
			super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
		else if (action = "TelemetryCoaching") {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(DrivingCoachPlugin.CoachingToggleAction(this, controller.findFunction(actionFunction)
																	  , this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else if (action = "TrackCoaching") {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(DrivingCoachPlugin.TrackCoachingToggleAction(this, controller.findFunction(actionFunction)
																		   , this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else if (action = "BrakeCoaching") {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(DrivingCoachPlugin.BrakeCoachingToggleAction(this, controller.findFunction(actionFunction)
																		   , this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else
			logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	createRaceAssistant(pid) {
		return DrivingCoachPlugin.RemoteDrivingCoach(this, pid)
	}

	loadSettings(simulator, car, track, data := false, settings := false) {
		local analyzePerformance, analyzeHandling, telemetryCoaching, ignore, session, instruction, privateSession

		settings := super.loadSettings(simulator, car, track, data, settings)

		if this.StartupSettings {
			analyzePerformance := getMultiMapValue(this.StartupSettings, "Functions", "Performance Analysis", kUndefined)

			if (analyzePerformance != kUndefined)
				for ignore, instruction in ["Session", "Stint"]
					for ignore, session in ["Practice", "Qualification", "Race"]
						setMultiMapValue(settings, "Assistant.Coach", "Data." . session . "." . instruction, analyzePerformance)

			analyzeHandling := getMultiMapValue(this.StartupSettings, "Functions", "Handling Analysis", kUndefined)

			if (analyzeHandling != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					for ignore, instruction in ["Session", "Handling"]
						setMultiMapValue(settings, "Assistant.Coach", "Data." . session . "." . instruction, analyzeHandling)

			telemetryCoaching := getMultiMapValue(this.StartupSettings, "Functions", "On-track Coaching", kUndefined)

			if (telemetryCoaching != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Assistant.Coach", session . ".OnTrackCoaching", telemetryCoaching)

			telemetryCoaching := getMultiMapValue(this.StartupSettings, "Functions", "Brake Coaching", kUndefined)

			if (telemetryCoaching != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Assistant.Coach", session . ".BrakeCoaching", telemetryCoaching)

			privateSession := getMultiMapValue(this.StartupSettings, "Functions", "Private Practice", kUndefined)

			if (privateSession != kUndefined)
				setMultiMapValue(settings, "Assistant.Coach", "Practice.Private", privateSession)

			privateSession := getMultiMapValue(this.StartupSettings, "Functions", "Private Qualifying", kUndefined)

			if (privateSession != kUndefined)
				setMultiMapValue(settings, "Assistant.Coach", "Qualification.Private", privateSession)
		}

		return settings
	}

	updateActions(session) {
		local ignore, theAction

		super.updateActions(session)

		for ignore, theAction in this.Actions {
			if isInstance(theAction, DrivingCoachPlugin.CoachingToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.TelemetryCoachingActive ? "Green" : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.TelemetryCoachingActive ? "Activated" : "Deactivated")

				theAction.Function.enable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, DrivingCoachPlugin.TrackCoachingToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.TrackCoachingActive ? ((this.TrackCoachingActive = "Starting") ? "Gray" : "Green")
																								  : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.TrackCoachingActive ? "Activated" : "Deactivated")

				theAction.Function.enable(kAllTrigger, theAction)
			}
			else if isInstance(theAction, DrivingCoachPlugin.BrakeCoachingToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.BrakeCoachingActive ? ((this.BrakeCoachingActive = "Starting") ? "Gray" : "Green")
																								  : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.BrakeCoachingActive ? "Activated" : "Deactivated")

				theAction.Function.enable(kAllTrigger, theAction)
			}
		}
	}

	serviceState(health) {
		this.iServiceState := health
	}

	writePluginState(configuration) {
		local problem, state

		if this.Active {
			if this.Enabled {
				if this.RaceAssistant {
					if (this.iServiceState != "Available") {
						setMultiMapValue(configuration, this.Plugin, "State", "Critical")

						if ((InStr(this.iServiceState, "Error") = 1)
						 && ((string2Values(":", this.iServiceState)[2] = "Configuration")
						  || (string2Values(":", this.iServiceState)[2] = "Connection"))) {
							setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Active")

							setMultiMapValue(configuration, this.Plugin, "Restricted", true)
						}
						else
							setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Critical")
					}
					else {
						setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Active")
						setMultiMapValue(configuration, this.Plugin, "State", "Active")
					}

					information := (translate("Started: ") . translate(this.RaceAssistant ? "Yes" : "No"))

					if (this.iServiceState = "Available") {
						if !this.Speaker
							information .= ("; " . translate("Silent: ") . translate("Yes"))

						if this.Muted
							information .= ("; " . translate("Muted: ") . translate("Yes"))
					}
					else if (InStr(this.iServiceState, "Error") = 1)
						information .= ("; " . translate("Problem: ") . translate(string2Values(":", this.iServiceState)[2]))

					setMultiMapValue(configuration, this.Plugin, "Information", information)
				}
				else {
					setMultiMapValue(configuration, "Assistants", this.Plugin, "Passive")
					setMultiMapValue(configuration, this.Plugin, "State", "Passive")
				}
			}
			else
				setMultiMapValue(configuration, this.Plugin, "State", "Disabled")
		}
		else
			super.writePluginState(configuration, false)
	}

	enableRaceAssistant(label := false, startup := false) {
		startCoach() {
			if !SimulatorController.Instance.Started
				return Task.CurrentTask
			else
				this.requireRaceAssistant()
		}

		super.enableRaceAssistant(label, startup)

		Task.startTask(startCoach, 1000, kLowPriority)
	}

	disableRaceAssistant(label := false, startup := false) {
		super.disableRaceAssistant(label, startup)

		this.shutdownRaceAssistant(true)
	}

	shutdownRaceAssistant(force := false) {
		if force
			super.shutdownRaceAssistant()
	}

	joinSession(settings, data) {
		this.startSession(settings, data)
	}

	updateTrackCoachingTrayLabel(label, enabled) {
		static hasTrayMenu := false

		toggleTelemetryCoaching(*) {
			if this.TelemetryCoachingActive
				this.finishTelemetryCoaching()
			else
				this.startTelemetryCoaching(true, "Track")
		}

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu {
			A_TrayMenu.Insert("1&", label, toggleTelemetryCoaching)

			hasTrayMenu := true
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	updateBrakeCoachingTrayLabel(label, enabled) {
		static hasTrayMenu := false

		toggleTelemetryCoaching(*) {
			if this.BrakeCoachingActive
				this.finishTelemetryCoaching()
			else
				this.startTelemetryCoaching(true, "Brake")
		}

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu {
			A_TrayMenu.Insert("1&")
			A_TrayMenu.Insert("1&", label, toggleTelemetryCoaching)

			hasTrayMenu := true
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	startTelemetryCoaching(confirm := true, auto := false) {
		if this.DrivingCoach
			this.DrivingCoach.startTelemetryCoaching(confirm, auto)
	}

	finishTelemetryCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.finishTelemetryCoaching()
	}

	startTrackCoaching(confirm := true) {
		if this.DrivingCoach
			this.DrivingCoach.startTrackCoaching(confirm)
	}

	startBrakeCoaching(confirm := true) {
		if this.DrivingCoach
			this.DrivingCoach.startBrakeCoaching(confirm)
	}

	finishCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.finishCoaching()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startTelemetryCoaching(confirm := true, auto := false) {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startTelemetryCoaching(confirm, auto)
	}
	finally {
		protectionOff()
	}
}

finishTelemetryCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.finishTelemetryCoaching()
	}
	finally {
		protectionOff()
	}
}

startTrackCoaching(confirm := true) {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startTrackCoaching(confirm)
	}
	finally {
		protectionOff()
	}
}

startBrakeCoaching(confirm := true) {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startBrakeCoaching(confirm)
	}
	finally {
		protectionOff()
	}
}

finishCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.finishCoaching()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachPlugin() {
	local controller := SimulatorController.Instance

	DrivingCoachPlugin(controller, kDrivingCoachPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachPlugin()