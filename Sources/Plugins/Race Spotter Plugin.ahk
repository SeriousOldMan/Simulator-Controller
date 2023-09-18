;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Spotter Plugin             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "Libraries\RaceAssistantPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


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
			super.__New(plugin, "Race Spotter", remotePID)
		}
	}

	class TrackAutomationToggleAction extends ControllerAction {
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

			if (plugin.TrackAutomationEnabled && ((trigger = "On") || (trigger = "Off") || (trigger == "Push"))) {
				plugin.disableTrackAutomation(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Black")
			}
			else if (!plugin.TrackAutomationEnabled && ((trigger = "On") || (trigger == "Push"))) {
				plugin.enableTrackAutomation(plugin.actionLabel(this))

				function.setLabel(plugin.actionLabel(this), "Green")
			}
		}
	}

	RaceSpotter {
		Get {
			return this.RaceAssistant
		}
	}

	TrackAutomationEnabled {
		Get {
			return this.iTrackAutomationEnabled
		}
	}

	__New(controller, name, configuration := false) {
		local trackAutomation, arguments

		super.__New(controller, name, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			trackAutomation := this.getArgumentValue("trackAutomation", false)

			if trackAutomation {
				arguments := string2Values(A_Space, trackAutomation)

				if (arguments.Length == 0)
					arguments := ["On"]

				if ((arguments.Length == 1) && !inList(["On", "Off"], arguments[1]))
					arguments.InsertAt(1, "Off")

				this.iTrackAutomationEnabled := (arguments[1] = "On")

				if (arguments.Length > 1)
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

			this.registerAction(RaceSpotterPlugin.TrackAutomationToggleAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor)))
		}
		else
			super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return RaceSpotterPlugin.RemoteRaceSpotter(this, pid)
	}

	writePluginState(configuration) {
		local sessionDB, simulator, simulatorName, trackAutomation

		super.writePluginState(configuration)

		if this.Active {
			if this.RaceAssistant
				setMultiMapValue(configuration, "Race Assistants", this.Plugin, "Active")

			if this.TrackAutomationEnabled {
				simulator := this.Simulator

				if (simulator && simulator.Track) {
					sessionDB := SessionDatabase()

					simulatorName := simulator.runningSimulator()

					setMultiMapValue(configuration, "Track Automation", "Simulator", simulatorName)
					setMultiMapValue(configuration, "Track Automation", "Car", sessionDB.getCarName(simulatorName, simulator.Car))
					setMultiMapValue(configuration, "Track Automation", "Track", sessionDB.getTrackName(simulatorName, simulator.Track))

					trackAutomation := simulator.TrackAutomation

					if trackAutomation {
						setMultiMapValue(configuration, "Track Automation", "State", "Active")

						setMultiMapValue(configuration, "Track Automation", "Automation", trackAutomation.Name)
					}
					else {
						setMultiMapValue(configuration, "Track Automation", "State", "Warning")

						setMultiMapValue(configuration, "Track Automation", "Information"
													  , translate("Message: ") . translate("No track automation available..."))
					}
				}
				else {
					setMultiMapValue(configuration, "Track Automation", "State", "Passive")

					setMultiMapValue(configuration, "Track Automation", "Information"
												  , translate("Message: ") . translate("Waiting for simulation..."))
				}
			}
			else
				setMultiMapValue(configuration, "Track Automation", "State", "Disabled")
		}
	}

	updateActions(session) {
		local ignore, theAction

		super.updateActions(session)

		for ignore, theAction in this.Actions
			if isInstance(theAction, RaceSpotterPlugin.TrackAutomationToggleAction) {
				theAction.Function.setLabel(this.actionLabel(theAction), this.TrackAutomationEnabled ? "Green" : "Black")

				theAction.Function.enable(kAllTrigger, theAction)
			}
	}

	requestInformation(arguments*) {
		if (this.RaceSpotter && inList(["Time", "Position", "LapTime", "LapTimes", "ActiveCars", "GapToAhead", "GapToFront", "GapToBehind"
									  , "GapToAheadStandings", "GapToFrontStandings", "GapToBehindStandings", "GapToAheadTrack"
									  , "GapToBehindTrack", "GapToLeader"
									  , "DriverNameAhead", "DriverNameBehind"
									  , "CarClassAhead", "CarClassBehind"
									  , "CarCupAhead", "CarCupBehind"], arguments[1])) {
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
		static hasTrayMenu := false

		label := StrReplace(StrReplace(label, "`n", A_Space), "`r", "")

		if !hasTrayMenu {
			A_TrayMenu.Insert("1&")
			A_TrayMenu.Insert("1&", label, (*) => this.toggleTrackAutomation())

			hasTrayMenu := true
		}

		if enabled
			A_TrayMenu.Check(label)
		else
			A_TrayMenu.Uncheck(label)
	}

	enableTrackAutomation(label := false, force := false) {
		if (!this.TrackAutomationEnabled || force) {
			if !label
				label := this.getLabel("TrackAutomation.Toggle")

			trayMessage(label, translate("State: On"))

			if this.Simulator
				this.Simulator.resetTrackAutomation()

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

			if this.Simulator
				this.Simulator.resetTrackAutomation()
		}
	}

	selectTrackAutomation(name := false, label := false) {
		local trackAutomation, ignore, candidate, enabled, trackAutomations

		if this.Simulator {
			trackAutomations := SessionDatabase().getTrackAutomations(this.Simulator.Simulator[true]
																	, this.Simulator.Car, this.Simulator.Track)

			for ignore, candidate in trackAutomations
				if ((name && (candidate.Name = name)) || (!name && candidate.Active)) {
					enabled := this.TrackAutomationEnabled

					if enabled
						this.disableTrackAutomation()

					if !label
						label := this.getLabel("TrackAutomation.Toggle")

					trayMessage(label, translate("Select: ") . (name ? name : "Active"))

					if enabled
						this.enableTrackAutomation()

					this.Simulator.TrackAutomation := candidate

					return
				}
		}
	}

	startupTrackAutomation() {
		local trackAutomation, ignore, action, positions, simulator, track, sessionDB, code, data, exePath, pid

		if (!this.iAutomationPID && this.Simulator) {
			trackAutomation := this.Simulator.TrackAutomation

			if trackAutomation {
				positions := ""

				for ignore, action in trackAutomation.Actions
					positions .= (A_Space . action.X . A_Space . action.Y)

				simulator := this.Simulator.Simulator[true]
				track := this.Simulator.Track

				sessionDB := SessionDatabase()

				code := sessionDB.getSimulatorCode(simulator)
				data := sessionDB.getTrackData(simulator, track)

				exePath := (kBinariesDirectory . code . " SHM Spotter.exe")
				pid := false

				try {
					if !FileExist(exePath)
						throw "File not found..."

					this.shutdownTrackAutomation()

					if data
						Run("`"" . exePath . "`" -Trigger `"" . data . "`" " . positions, kBinariesDirectory, "Hide", &pid)
					else
						Run("`"" . exePath . "`" -Trigger " . positions, kBinariesDirectory, "Hide", &pid)
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
															   , {simulator: code, protocol: "SHM"})
										   . exePath . translate(") - please rebuild the applications in the binaries folder (")
										   . kBinariesDirectory . translate(")"))

					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: code, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

				if pid
					this.iAutomationPID := pid
			}
		}
	}

	shutdownTrackAutomation(force := false, *) {
		local pid := this.iAutomationPID
		local processName, tries

		if pid {
			ProcessClose(pid)

			Sleep(500)

			if (force && ProcessExist(pid)) {
				processName := (SessionDatabase().getSimulatorCode(this.Simulator.Simulator[true]) . " SHM Spotter.exe")

				tries := 5

				while (tries-- > 0) {
					pid := ProcessExist(processName)

					if pid {
						ProcessClose(pid)

						Sleep(500)
					}
					else
						break
				}
			}

			this.iAutomationPID := false
		}

		return false
	}

	joinSession(settings, data) {
		if getMultiMapValue(settings, "Assistant.Spotter", "Join.Late", true)
			this.startSession(settings, data)
	}

	finishSession(arguments*) {
		this.iHasTrackMap := false

		this.shutdownTrackMapper(true)
		this.shutdownTrackAutomation(true)

		super.finishSession(arguments*)
	}

	addLap(lap, running, data) {
		local simulator, simulatorName, hasTrackMap, track, code, exePath, pid, dataFile, mapperState

		static sessionDB := false

		createTrackMap() {
			local pid := this.iMapperPID
			local fileSize

			finalizeTrackMap() {
				deleteFile(kTempDirectory . "Track Mapper.state")

				this.iMapperPID := false
				this.iMapperPhase := false
			}

			if pid {
				if ProcessExist(pid) {
					try {
						fileSize := FileGetSize(dataFile)

						setMultiMapValue(mapperState, "Track Mapper", "Size", fileSize)
					}
					catch Any {
						fileSize := false
					}

					setMultiMapValue(mapperState, "Track Mapper", "Information"
								   , translate("Message: ") . (fileSize ? substituteVariables(translate("Scanning track (%size% bytes)..."), {size: Round(fileSize)})
																		: translate("Scanning track...")))

					writeMultiMap(kTempDirectory . "Track Mapper.state", mapperState)

					Task.startTask(Task.CurrentTask, 10000, kLowPriority)
				}
				else {
					pid := SessionDatabase.mapTrack(simulator, track, dataFile, finalizeTrackMap)

					if pid {
						this.iMapperPID := pid
						this.iMapperPhase := "Map"
					}
					else {
						this.iMapperPhase := false
						this.iMapperPID := false
					}
				}
			}
		}

		if !sessionDB
			sessionDB := SessionDatabase()

		super.addLap(lap, running, data)

		if (this.RaceAssistant && this.Simulator) {
			simulator := this.Simulator.Simulator[true]

			if this.iHasTrackMap
				hasTrackMap := true
			else if this.iMapperPID
				hasTrackMap := false
			else {
				track := getMultiMapValue(data, "Session Data", "Track", false)

				hasTrackMap := sessionDB.hasTrackMap(simulator, track)
			}

			if hasTrackMap {
				this.iHasTrackMap := true

				if (!this.iAutomationPID && this.TrackAutomationEnabled)
					this.startupTrackAutomation()
			}
			else if !this.iMapperPID {
				simulatorName := sessionDB.getSimulatorName(simulator)

				if (lap > getMultiMapValue(this.Configuration, "Race Spotter Analysis", simulatorName . ".LearningLaps", 1)) {
					track := getMultiMapValue(data, "Session Data", "Track", false)

					code := sessionDB.getSimulatorCode(simulator)
					dataFile := temporaryFileName(code . " Track Mapper", "data")

					exePath := (kBinariesDirectory . code . " SHM Spotter.exe")

					try {
						if !FileExist(exePath)
							throw "File not found..."

						this.iMapperPhase := "Collect"

						Run(A_ComSpec . " /c `"`"" . exePath . "`" -Map > `"" . dataFile . "`"`"", kBinariesDirectory, "Hide", &pid)

						this.iMapperPID := pid
					}
					catch Any as exception {
						logError(exception, true)

						logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
																   , {simulator: code, protocol: "SHM"})
											   . exePath . translate(") - please rebuild the applications in the binaries folder (")
											   . kBinariesDirectory . translate(")"))

						showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
													  , {exePath: exePath, simulator: code, protocol: "SHM"})
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					}

					if this.iMapperPID {
						mapperState := newMultiMap()

						setMultiMapValue(mapperState, "Track Mapper", "State", "Active")
						setMultiMapValue(mapperState, "Track Mapper", "Simulator", simulatorName)
						setMultiMapValue(mapperState, "Track Mapper", "Track", sessionDB.getTrackName(simulator, track))
						setMultiMapValue(mapperState, "Track Mapper", "Action", "Scanning")
						setMultiMapValue(mapperState, "Track Mapper", "Information", translate("Message: ") . translate("Scanning track..."))

						writeMultiMap(kTempDirectory . "Track Mapper.state", mapperState)

						Task.startTask(createTrackMap, 0, kLowPriority)
					}
				}
				else {
					this.iMapperPhase := "Wait"

					mapperState := newMultiMap()

					setMultiMapValue(mapperState, "Track Mapper", "State", "Passive")
					setMultiMapValue(mapperState, "Track Mapper", "Simulator", simulatorName)
					setMultiMapValue(mapperState, "Track Mapper", "Track", sessionDB.getTrackName(simulator, track))
					setMultiMapValue(mapperState, "Track Mapper", "Action", "Waiting")
					setMultiMapValue(mapperState, "Track Mapper", "Information", translate("Message: ") . translate("Waiting for track scanner..."))

					writeMultiMap(kTempDirectory . "Track Mapper.state", mapperState)
				}
			}
		}
	}

	updateLap(lap, update, data) {
		local simulator, mapperState

		super.updateLap(lap, update, data)

		if (this.iMapperPhase = "Wait") {
			simulator := this.Simulator.Simulator[true]
			mapperState := newMultiMap()

			setMultiMapValue(mapperState, "Track Mapper", "State", "Passive")
			setMultiMapValue(mapperState, "Track Mapper", "Simulator", SessionDatabase.getSimulatorName(this.Simulator.Simulator[true]))
			setMultiMapValue(mapperState, "Track Mapper", "Track", SessionDatabase.getTrackName(simulator, getMultiMapValue(data, "Session Data", "Track", false)))
			setMultiMapValue(mapperState, "Track Mapper", "Action", "Waiting")
			setMultiMapValue(mapperState, "Track Mapper", "Information", translate("Message: ") . translate("Waiting for track scanner..."))

			writeMultiMap(kTempDirectory . "Track Mapper.state", mapperState)
		}
	}

	shutdownTrackMapper(force := false, *) {
		local pid, processName, tries

		if (force || (this.iMapperPID && (this.iMapperPhase = "Collect"))) {
			pid := this.iMapperPID

			if (force || pid) {
				ProcessClose(pid)

				Sleep(500)

				if (force && ProcessExist(pid)) {
					processName := (SessionDatabase().getSimulatorCode(this.Simulator) . " SHM Spotter.exe")

					tries := 5

					while (tries-- > 0) {
						pid := ProcessExist(processName)

						if pid {
							ProcessClose(pid)

							Sleep(500)
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

	RaceSpotterPlugin(controller, kRaceSpotterPlugin, controller.Configuration)
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