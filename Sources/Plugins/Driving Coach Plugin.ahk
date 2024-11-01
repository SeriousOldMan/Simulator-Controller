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

	iCoachingActive := false
	iTrackCoachingActive := false

	class RemoteDrivingCoach extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			super.__New(plugin, "Driving Coach", remotePID)
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

			if (plugin.CoachingActive && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.finishCoaching()

				function.setLabel(plugin.actionLabel(this), "Black")
				function.setIcon(plugin.actionIcon(this), "Deactivated")
			}
			else if (!plugin.CoachingActive && ((trigger = "On") || (trigger == "Push"))) {
				plugin.startCoaching()

				function.setLabel(plugin.actionLabel(this), "Green")
				function.setIcon(plugin.actionIcon(this), "Activated")
			}
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

			if (plugin.TrackCoachingActive && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.finishTrackCoaching()

				function.setLabel(plugin.actionLabel(this), "Black")
				function.setIcon(plugin.actionIcon(this), "Deactivated")
			}
			else if (!plugin.TrackCoachingActive && ((trigger = "On") || (trigger == "Push"))) {
				plugin.startTrackCoaching()

				function.setLabel(plugin.actionLabel(this), "Green")
				function.setIcon(plugin.actionIcon(this), "Activated")
			}
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

	CoachingActive {
		Get {
			return this.iCoachingActive
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

		deleteFile(kTempDirectory . "Coaching.state")

		PeriodicTask(() {
			local state := readMultiMap(kTempDirectory . "Coaching.state")
			local active := getMultiMapValue(state, "Coaching", "Active", false)
			local track := (active && getMultiMapValue(state, "Coaching", "Track", false))

			if (active != this.CoachingActive) {
				this.iCoachingActive := active

				this.updateActions(kSessionUnknown)
			}

			if (track != this.TrackCoachingActive) {
				this.iTrackCoachingActive := active

				this.updateActions(kSessionUnknown)
			}
		}, 5000, kLowPriority).start()
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local descriptor

		if (inList(["RaceAssistant", "Call", "SetupWorkbenchOpen"], action))
			super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
		else if (action = "TelemetryCoaching") {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(DrivingCoachPlugin.CoachingToggleAction(this, actionFunction, this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else if (action = "TrackCoaching") {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(DrivingCoachPlugin.TrackCoachingToggleAction(this, actionFunction, this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else
			logMessage(kLogWarn, translate("Action `"") . action . translate("`" not found in plugin ") . translate(this.Plugin) . translate(" - please check the configuration"))
	}

	createRaceAssistant(pid) {
		return DrivingCoachPlugin.RemoteDrivingCoach(this, pid)
	}

	loadSettings(simulator, car, track, data := false, settings := false) {
		local analyzePerformance, analyzeHandling, ignore, session, instruction

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
		}

		return settings
	}

	updateActions(session) {
		local ignore, theAction

		super.updateActions(session)

		for ignore, theAction in this.Actions {
			if isInstance(theAction, DrivingCoachPlugin.CoachingToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.CoachingActive ? "Green" : "Black")
				theAction.Function.setIcon(this.actionIcon(theAction), this.CoachingActive ? "Activated" : "Deactivated")

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
		local problem

		if this.Active {
			if this.RaceAssistantEnabled {
				if this.RaceAssistant {
					setMultiMapValue(configuration, "Race Assistants", this.Plugin, (this.iServiceState = "Available") ? "Active" : "Critical")

					setMultiMapValue(configuration, this.Plugin, "State", (this.iServiceState = "Available") ? "Active" : "Critical")

					information := (translate("Started: ") . translate(this.RaceAssistant ? "Yes" : "No"))

					if (this.iServiceState = "Available") {
						if !this.RaceAssistantSpeaker
							information .= ("; " . translate("Silent: ") . translate("Yes"))

						if this.RaceAssistantMuted
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

	startCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.startCoaching()
	}

	finishCoaching() {
		if this.DrivingCoach
			this.DrivingCoach.finishCoaching()
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

startCoaching() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kDrivingCoachPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.startCoaching()
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