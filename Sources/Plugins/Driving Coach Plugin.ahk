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

	class RemoteDrivingCoach extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			super.__New(plugin, "Driving Coach", remotePID)
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

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		if (inList(["RaceAssistant", "Call", "SetupWorkbenchOpen"], action))
			super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
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
			if (MessageManager.isPaused() || !SimulatorController.Instance.Started)
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