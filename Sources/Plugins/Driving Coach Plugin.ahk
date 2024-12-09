;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
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

		finishTrackCoaching(arguments*) {
			this.callRemote("finishTrackCoaching", arguments*)
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
				plugin.finishTrackCoaching()
			else if (!plugin.TrackCoachingActive && ((trigger = "On") || (trigger == "Push")))
				plugin.startTrackCoaching()
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

		DirCreate(kTempDirectory . "Driving Coach")

		deleteFile(kTempDirectory . "Driving Coach\Coaching.state")

		PeriodicTask(() {
			local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
			local active := getMultiMapValue(state, "Coaching", "Active", false)
			local track := (active && getMultiMapValue(state, "Coaching", "Track", false))

			if (active != this.TelemetryCoachingActive) {
				this.iTelemetryCoachingActive := active

				this.updateActions(kSessionUnknown)
			}

			if (track != this.TrackCoachingActive) {
				this.iTrackCoachingActive := track

				this.updateActions(kSessionUnknown)
			}
		}, 5000, kLowPriority).start()
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
		else
			logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	createRaceAssistant(pid) {
		return DrivingCoachPlugin.RemoteDrivingCoach(this, pid)
	}

	loadSettings(simulator, car, track, data := false, settings := false) {
		local analyzePerformance, analyzeHandling, telemetryCoaching, ignore, session, instruction

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
					setMultiMapValue(settings, "Assistant.Coach", session . ".TelemetryCoaching", telemetryCoaching)
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
				theAction.Function.setLabel(this.actionLabel(theAction), this.TrackCoachingActive ? "Green" : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.TrackCoachingActive ? "Activated" : "Deactivated")

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

	startTelemetryCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.startTelemetryCoaching()
	}

	finishTelemetryCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.finishTelemetryCoaching()
	}

	startTrackCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.startTrackCoaching()
	}

	finishTrackCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.finishTrackCoaching()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startTelemetryCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startTelemetryCoaching()
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

startTrackCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startTrackCoaching()
	}
	finally {
		protectionOff()
	}
}

finishTrackCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.finishTrackCoaching()
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