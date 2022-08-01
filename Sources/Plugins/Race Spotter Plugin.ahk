;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Plugin             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
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
	iMapperPhase := false
	iHasTrackMap := false

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
				plugin.disableTrackAutomation(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TrackAutomationEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTrackAutomation(plugin.actionLabel(this))

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

		if (this.Active || isDebug()) {
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
				Task.startTask(new PeriodicTask("collectRaceSpotterSessionData", 10000, kLowPriority))
			else
				Task.startTask(new PeriodicTask("updateRaceSpotterSessionState", 5000, kLowPriority))

			OnExit(ObjBindMethod(this, "shutdownTrackAutomation", true))
			OnExit(ObjBindMethod(this, "shutdownTrackMapper", true))

			if this.iTrackAutomationEnabled
				this.enableTrackAutomation(false, true)
			else
				this.disableTrackAutomation(false, true)
		}
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

	toggleTrackAutomation() {
		if this.TrackAutomationEnabled
			this.disableTrackAutomation()
		else
			this.enableTrackAutomation()
	}

	updateAutomationTrayLabel(label, enabled) {
		static hasTrayMenu := false

		label := StrReplace(label, "`n", A_Space)

		if !hasTrayMenu {
			callback := ObjBindMethod(this, "toggleTrackAutomation")

			Menu Tray, Insert, 1&
			Menu Tray, Insert, 1&, %label%, %callback%

			hasTrayMenu := true
		}

		if enabled
			Menu Tray, Check, %label%
		else
			Menu Tray, Uncheck, %label%
	}

	enableTrackAutomation(label := false, force := false) {
		if (!this.TrackAutomationEnabled || force) {
			if !label
				label := this.getLabel("TrackAutomation.Toggle")

			trayMessage(label, translate("State: On"))

			this.iTrackAutomationEnabled := true

			this.updateAutomationTrayLabel(label, true)
		}
	}

	disableTrackAutomation(label := false, force := false) {
		if (this.TrackAutomationEnabled || force) {
			if !label
				label := this.getLabel("TrackAutomation.Toggle")

			trayMessage(label, translate("State: Off"))

			this.iTrackAutomationEnabled := false

			this.shutdownTrackAutomation()

			this.updateAutomationTrayLabel(label, false)
		}
	}

	selectTrackAutomation(name := false, label := false) {
		if this.Simulator {
			trackAutomations := new SessionDatabase().getTrackAutomations(this.Simulator.Simulator[true]
																		, this.Simulator.Car, this.Simulator.Track)

			for ignore, candidate in trackAutomations
				if ((name && (candidate.Name = name)) || candidate.Active) {
					enabled := this.TrackAutomationEnabled

					if enabled
						this.disableTrackAutomations()

					if !label
						label := this.getLabel("TrackAutomation.Toggle")

					trayMessage(label, translate("Select: ") . (name ? name : "Active"))

					this.Simulator.TrackAutomation := candidate

					if enabled
						this.enableTrackAutomation()

					return
				}
		}
	}

	startupTrackAutomation() {
		if !this.iAutomationPID && this.Simulator {
			trackAutomation := this.Simulator.TrackAutomation

			if trackAutomation {
				positions := ""

				for ignore, action in trackAutomation.Actions
					positions .= (A_Space . action.X . A_Space . action.Y)

				simulator := this.Simulator.Simulator[true]
				track := this.Simulator.Track

				sessionDB := new SessionDatabase()

				code := sessionDB.getSimulatorCode(simulator)
				data := sessionDB.getTrackData(simulator, track)

				exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

				if FileExist(exePath) {
					this.shutdownTrackAutomation()

					try {
						if data
							Run "%exePath%" -Trigger "%data%" %positions%, %kBinariesDirectory%, Hide, automationPID
						else
							Run "%exePath%" -Trigger %positions%, %kBinariesDirectory%, Hide, automationPID
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

	shutdownTrackAutomation(force := false) {
		automationPID := this.iAutomationPID

		if automationPID {
			Process Close, %automationPID%

			Sleep 500

			Process Exist, %automationPID%

			if (force && ErrorLevel) {
				processName := (new SessionDatabase().getSimulatorCode(this.Simulator.Simulator[true]) . " SHM Spotter.exe")

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

		return false
	}

	finishSession(arguments*) {
		this.iHasTrackMap := false

		this.shutdownTrackMapper(true)
		this.shutdownTrackAutomation(true)

		base.finishSession(arguments*)
	}

	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		static sessionDB := false

		if !sessionDB
			sessionDB := new SessionDatabase()

		base.addLap(lapNumber, dataFile, telemetryData, positionsData)

		if (this.RaceAssistant && this.Simulator) {
			simulator := this.Simulator.Simulator[true]

			if this.iHasTrackMap
				hasTrackMap := true
			else if this.iMapperPID
				hasTrackMap := false
			else {
				track := getConfigurationValue(telemetryData ? telemetryData : readConfiguration(dataFile), "Session Data", "Track", false)

				hasTrackMap := sessionDB.hasTrackMap(simulator, track)
			}

			if hasTrackMap {
				this.iHasTrackMap := true

				if (!this.iAutomationPID && this.TrackAutomationEnabled)
					this.startupTrackAutomation()
			}
			else if !this.iMapperPID {
				simulatorName := sessionDB.getSimulatorName(simulator)

				if (lapNumber > getConfigurationValue(this.Configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)) {
					track := getConfigurationValue(telemetryData ? telemetryData : readConfiguration(dataFile), "Session Data", "Track", false)

					code := sessionDB.getSimulatorCode(simulator)
					dataFile := (kTempDirectory . code . " Data\" . track . ".data")

					exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

					if FileExist(exePath) {
						try {
							this.iMapperPhase := "Collect"

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

						if ((ErrorLevel != "Error") && this.iMapperPID)
							Task.startTask(ObjBindMethod(this, "createTrackMap", simulatorName, track, dataFile), 120000, kLowPriority)
					}
				}
			}
		}
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

			if ErrorLevel
				Task.startTask(Task.CurrentTask, 10000)
			else {
				try {
					this.iMapperPhase := "Map"

					Run %ComSpec% /c ""%kBinariesDirectory%Track Mapper.exe" -Simulator "%simulator%" -Track "%track%" -Data "%datafile%"", %kBinariesDirectory%, UserErrorLevel Hide, mapperPID
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

					showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					mapperPID := false
				}

				if ((ErrorLevel != "Error") && mapperPID) {
					this.iMapperPID := mapperPID

					Task.startTask(ObjBindMethod(this, "finalizeTrackMap"), 120000, kLowPriority)
				}
			}
		}
	}

	finalizeTrackMap() {
		mapperPID := this.iMapperPID

		if mapperPID {
			Process Exist, %mapperPID%

			if ErrorLevel
				Task.startTask(Task.CurrentTask, 10000)
			else {
				this.iMapperPID := false
				this.iMapperPhase := false
			}
		}
	}

	shutdownTrackMapper(force := false) {
		if (this.iMapperPID && (this.iMapperPhase = "Collect")) {
			mapperPID := this.iMapperPID

			if mapperPID {
				Process Close, %mapperPID%

				Sleep 500

				Process Exist, %mapperPID%

				if (force && ErrorLevel) {
					processName := (new SessionDatabase().getSimulatorCode(this.Simulator) . " SHM Spotter.exe")

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

		return false
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
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

enableTrackAutomation() {
	local plugin

	controller := SimulatorController.Instance
	plugin := controller.findPlugin(kRaceSpotterPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.enableTrackAutomation()
	}
	finally {
		protectionOff()
	}
}

disableTrackAutomation() {
	local plugin

	controller := SimulatorController.Instance
	plugin := controller.findPlugin(kRaceSpotterPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.disableTrackAutomation()
	}
	finally {
		protectionOff()
	}
}

selectTrackAutomation(name := false) {
	local plugin

	controller := SimulatorController.Instance
	plugin := controller.findPlugin(kRaceSpotterPlugin)

	protectionOn()

	try {
		if (plugin && controller.isActive(plugin))
			plugin.selectTrackAutomation(name)
	}
	finally {
		protectionOff()
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceSpotterPlugin()