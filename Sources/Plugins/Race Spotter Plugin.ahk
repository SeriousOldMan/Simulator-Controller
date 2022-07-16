;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Plugin             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceSpotterPlugin = "Race Spotter"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceSpotterPlugin extends RaceAssistantPlugin  {
	iTrackAutomationEnabled := false
	iAutomationPID := false

	iMapperPID := false
	iMapped := []

	class RemoteRaceSpotter extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			base.__New(plugin, "Race Spotter", remotePID)
		}
	}

	class TrackAutomationToggleAction extends ControllerAction {
		iPlugin := false

		Plugin[] {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin, function, label, icon) {
			this.iPlugin := plugin

			base.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local plugin := this.Plugin

			if (plugin.TrackAutomationEnabled && ((trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTrackAutomation()

				trayMessage(plugin.actionLabel(this), translate("State: Off"))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TrackAutomationEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTrackAutomation()

				trayMessage(plugin.actionLabel(this), translate("State: On"))

				function.setLabel(plugin.actionLabel(this), "Green")
			}
		}
	}

	RaceSpotter[] {
		Get {
			return this.RaceAssistant
		}
	}

	TrackAutomationEnabled[] {
		Get {
			return this.iTrackAutomationEnabled
		}
	}

	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration)

		if (!this.Active && !isDebug())
			return

		trackAutomation := this.getArgumentValue("trackAutomation", false)

		if trackAutomation {
			arguments := string2Values(A_Space, trackAutomation)

			if (arguments.Length() == 0)
				arguments := ["On"]

			if ((arguments.Length() == 1) && !inList(["On", "Off"], arguments[1]))
				arguments.InsertAt(1, "Off")

			this.iTrackAutomationEnabled := (arguments[1] = "On")

			if (arguments.Length() > 1)
				this.createRaceAssistantAction(controller, "TrackAutomation", arguments[2])
		}
		else
			this.iTrackAutomationEnabled := false

		if (this.RaceAssistantName)
			SetTimer collectRaceSpotterSessionData, 10000
		else
			SetTimer updateRaceSpotterSessionState, 5000
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function

		function := controller.findFunction(actionFunction)

		if ((function != false) && (action = "TrackAutomation")) {
			descriptor := ConfigurationItem.descriptor(action, "Toggle")

			this.registerAction(new this.TrackAutomationToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else
			base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return new this.RemoteRaceSpotter(this, pid)
	}

	updateActions(sessionState) {
		base.updateActions(sessionState)

		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceSpotterPlugin.TrackAutomationToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.TrackAutomationEnabled ? "Green" : "Black")

				theAction.Function.enable(kAllTrigger, theAction)
			}
	}

	requestInformation(arguments*) {
		if (this.RaceSpotter && inList(["Time", "Position", "LapTimes", "GapToAhead", "GapToFront", "GapToBehind"
									  , "GapToAheadStandings", "GapToFrontStandings", "GapToBehindStandings", "GapToAheadTrack"
									  , "GapToBehindTrack", "GapToLeader"], arguments[1])) {
			this.RaceSpotter.requestInformation(arguments*)

			return true
		}
		else
			return false
	}

	acquireSessionData(ByRef telemetryData, ByRef positionsData) {
		if !telemetryData
			telemetryData := true

		data := base.acquireSessionData(telemetryData, positionsData)

		this.updatePositionsData(data)

		if positionsData
			setConfigurationSectionValues(positionsData, "Position Data", getConfigurationSectionValues(data, "Position Data", Object()))

		return data
	}

	enableTrackAutomation() {
		this.iTrackAutomationEnabled := true
	}

	disableTrackAutomation() {
		this.iTrackAutomationEnabled := false
	}

	startupAutomation() {
		if !this.iAutomationPID && this.Simulator {
			trackAutomation := this.Simulator.TrackAutomation

			if trackAutomation {
				positions := ""

				for ignore, action in trackAutomation.Actions
					positions .= (A_Space . action.X . A_Space . action.Y)

				code := this.SettingsDatabase.getSimulatorCode(this.Simulator)

				exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

				if FileExist(exePath) {
					this.shutdownAutomation()

					try {
						Run %ComSpec% /c ""%exePath%" -Trigger %positions%", %kBinariesDirectory%, Hide UseErrorLevel, automationPID
					}
					catch exception {
						logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
																   , {simulator: code, protocol: "SHM"})
											   . exePath . translate(") - please rebuild the applications in the binaries folder (")
											   . kBinariesDirectory . translate(")"))

						showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
													  , {exePath: exePath, simulator: code, protocol: "SHM"})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					}

					if ((ErrorLevel != "Error") && automationPID)
						this.iAutomationPID := automationPID
				}
			}
		}
	}

	shutdownAutomation(force := false) {
		automationPID := this.iAutomationPID

		if automationPID {
			Process Close, %automationPID%

			Sleep 500

			Process Exist, %automationPID%

			if (force && ErrorLevel) {
				processName := (this.SettingsDatabase.getSimulatorCode(this.Simulator) . " SHM Spotter.exe")

				tries := 5

				while (tries-- > 0) {
					Process Exist, %processName%

					if ErrorLevel {
						Process Close, %ErrorLevel%

						Sleep 500
					}
					else
						break
				}
			}
		}
	}

	finishSession(arguments*) {
		base.finishSession(arguments*)

		this.shutdownAutomation(true)
	}

	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		static sessionDB := false

		base.addLap(lapNumber, dataFile, telemetryData, positionsData)

		if (this.RaceAssistant && !this.iMapperPID && this.Simulator && this.Simulator.supportsTrackMap()) {
			if !sessionDB
				sessionDB := new SessionDatabase()

			simulator := this.Simulator.Simulator[true]
			simulatorName := sessionDB.getSimulatorName(simulator)

			learning := getConfigurationValue(this.Configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)

			if (lapNumber > getConfigurationValue(this.Configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)) {
				track := getConfigurationValue(telemetryData ? telemetryData : readConfiguration(dataFile), "Session Data", "Track", false)

				if (!sessionDB.hasTrackMap(simulator, track) && !inList(this.iMapped, track)) {
					code := sessionDB.getSimulatorCode(simulator)
					dataFile := (kTempDirectory . code . " Data\" . track . ".data")

					this.iMapped.Push(track)

					exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

					if FileExist(exePath) {
						try {
							Run %ComSpec% /c ""%exePath%" -Map > "%dataFile%"", %kBinariesDirectory%, Hide UseErrorLevel, mapperPID

							this.iMapperPID := mapperPID
						}
						catch exception {
							logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
																	   , {simulator: code, protocol: "SHM"})
												   . exePath . translate(") - please rebuild the applications in the binaries folder (")
												   . kBinariesDirectory . translate(")"))

							showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
														  , {exePath: exePath, simulator: code, protocol: "SHM"})
									  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

							this.iMapperPID := false
						}

						if ((ErrorLevel != "Error") && this.iMapperPID) {
							callback := ObjBindMethod(this, "createTrackMap", simulatorName, track, dataFile)

							SetTimer %callback%, -120000
						}
					}
				}
			}
		}
		else if !this.iAutomationPID
			this.startupAutomation()
	}

	updateLap(lapNumber, dataFile) {
		base.updateLap(lapNumber, dataFile)

		if this.TeamSessionActive {
			FileRead data, %dataFile%

			this.TeamServer.setLapValue(lapNumber, "Track Data", data)
		}
	}

	createTrackMap(simulator, track, dataFile) {
		mapperPID := this.iMapperPID

		if mapperPID {
			Process Exist, %mapperPID%

			if ErrorLevel {
				callback := ObjBindMethod(this, "createTrackMap", simulator, track, dataFile)

				SetTimer %callback%, -10000
			}
			else {
				try {
					Run %ComSpec% /c ""%kBinariesDirectory%Track Mapper.exe" -Simulator "%simulator%" -Track "%track%" -Data "%datafile%"", %kBinariesDirectory%, Hide

					this.iMapperPID := false
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

					showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}

	positionTrigger(actionNr, positionX, positionY) {
		if (this.TrackAutomationEnabled && this.Simulator)
			this.Simulator.triggerAction(actionNr, positionX, positionY)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateRaceSpotterSessionState() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceSpotterPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

collectRaceSpotterSessionData() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceSpotterPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

initializeRaceSpotterPlugin() {
	local controller := SimulatorController.Instance

	new RaceSpotterPlugin(controller, kRaceSpotterPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterPlugin()