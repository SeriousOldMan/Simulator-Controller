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

global kRaceSpotterPlugin := "Race Spotter"


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
		local trackAutomation, arguments

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

			OnExit(ObjBindMethod(this, "shutdownTrackAutomation", true))
			OnExit(ObjBindMethod(this, "shutdownTrackMapper", true))

			if this.iTrackAutomationEnabled
				this.enableTrackAutomation(false, true)
			else
				this.disableTrackAutomation(false, true)
		}
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, descriptor

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

	updateActions(session) {
		local ignore, theAction

		base.updateActions(session)

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

	toggleTrackAutomation() {
		if this.TrackAutomationEnabled
			this.disableTrackAutomation()
		else
			this.enableTrackAutomation()
	}

	updateAutomationTrayLabel(label, enabled) {
		local callback

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
		local trackAutomation, ignore, candidate, enabled, trackAutomations

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
		local trackAutomation, ignore, action, positions, simulator, track, sessionDB, code, data, exePath, pid

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
							Run "%exePath%" -Trigger "%data%" %positions%, %kBinariesDirectory%, Hide, pid
						else
							Run "%exePath%" -Trigger %positions%, %kBinariesDirectory%, Hide, pid
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

					if ((ErrorLevel != "Error") && pid)
						this.iAutomationPID := pid
				}
			}
		}
	}

	shutdownTrackAutomation(force := false) {
		local pid := this.iAutomationPID
		local processName, tries

		if pid {
			Process Close, %pid%

			Sleep 500

			Process Exist, %pid%

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

	addLap(lap, running, data) {
		local simulator, simulatorName, hasTrackMap, track, code, exePath, pid, dataFile

		static sessionDB := false

		if !sessionDB
			sessionDB := new SessionDatabase()

		base.addLap(lap, running, data)

		if (this.RaceAssistant && this.Simulator) {
			simulator := this.Simulator.Simulator[true]

			if this.iHasTrackMap
				hasTrackMap := true
			else if this.iMapperPID
				hasTrackMap := false
			else {
				track := getConfigurationValue(data, "Session Data", "Track", false)

				hasTrackMap := sessionDB.hasTrackMap(simulator, track)
			}

			if hasTrackMap {
				this.iHasTrackMap := true

				if (!this.iAutomationPID && this.TrackAutomationEnabled)
					this.startupTrackAutomation()
			}
			else if !this.iMapperPID {
				simulatorName := sessionDB.getSimulatorName(simulator)

				if (lap > getConfigurationValue(this.Configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)) {
					track := getConfigurationValue(data, "Session Data", "Track", false)

					code := sessionDB.getSimulatorCode(simulator)
					dataFile := (kTempDirectory . code . " Data\" . track . ".data")

					exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

					if FileExist(exePath) {
						try {
							this.iMapperPhase := "Collect"

							Run %ComSpec% /c ""%exePath%" -Map > "%dataFile%"", %kBinariesDirectory%, Hide UseErrorLevel, pid

							this.iMapperPID := pid
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

	updateLap(lap, running, data) {
		base.updateLap(lap, running, data)

		if this.TeamSessionActive
			this.TeamServer.setLapValue(lap, "Telemetry Update", printConfiguration(data))
	}

	createTrackMap(simulator, track, dataFile) {
		local pid := this.iMapperPID

		if pid {
			Process Exist, %pid%

			if ErrorLevel
				Task.startTask(Task.CurrentTask, 10000)
			else {
				try {
					this.iMapperPhase := "Map"

					Run %ComSpec% /c ""%kBinariesDirectory%Track Mapper.exe" -Simulator "%simulator%" -Track "%track%" -Data "%datafile%"", %kBinariesDirectory%, UserErrorLevel Hide, pid
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

					showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					pid := false
				}

				if ((ErrorLevel != "Error") && pid) {
					this.iMapperPID := pid

					Task.startTask(ObjBindMethod(this, "finalizeTrackMap"), 120000, kLowPriority)
				}
			}
		}
	}

	finalizeTrackMap() {
		local pid := this.iMapperPID

		if pid {
			Process Exist, %pid%

			if ErrorLevel
				Task.startTask(Task.CurrentTask, 10000)
			else {
				this.iMapperPID := false
				this.iMapperPhase := false
			}
		}
	}

	shutdownTrackMapper(force := false) {
		local pid, processName, tries

		if (this.iMapperPID && (this.iMapperPhase = "Collect")) {
			pid := this.iMapperPID

			if pid {
				Process Close, %pid%

				Sleep 500

				Process Exist, %pid%

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

initializeRaceSpotterPlugin() {
	local controller := SimulatorController.Instance

	new RaceSpotterPlugin(controller, kRaceSpotterPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

enableTrackAutomation() {
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kRaceSpotterPlugin)

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
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kRaceSpotterPlugin)

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
	local controller := SimulatorController.Instance
	local plugin := controller.findPlugin(kRaceSpotterPlugin)

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