;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk
#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceEngineerPlugin = "Race Engineer"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineerPlugin extends RaceAssistantPlugin  {
	static kLapDataSchemas := {Pressures: ["Lap", "Simulator", "Car", "Track", "Weather", "Temperature.Air", "Temperature.Track"
										 , "Compound", "Compound.Color", "Pressures.Cold", "Pressures.Hot"]}

	iPitstopPending := false

	iLapDatabase := false

	class RemoteRaceEngineer extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			base.__New(plugin, "Race Engineer", remotePID)
		}

		planPitstop(arguments*) {
			this.callRemote("callPlanPitstop", arguments*)
		}

		preparePitstop(arguments*) {
			this.callRemote("callPreparePitstop", arguments*)
		}

		pitstopOptionChanged(arguments*) {
			this.callRemote("pitstopOptionChanged", arguments*)
		}
	}

	class RaceEngineerAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceEngineer && (this.Action = "PitstopPlan"))
				this.Plugin.planPitstop()
			else if (this.Plugin.RaceEngineer && (this.Action = "PitstopPrepare"))
				this.Plugin.preparePitstop()
			else
				base.fireAction(function, trigger)
		}
	}

	RaceEngineer[] {
		Get {
			return this.RaceAssistant
		}
	}

	LapDatabase[] {
		Get {
			if !this.iLapDatabase
				this.iLapDatabase := new Database(false, this.kLapDataSchemas)

			return this.iLapDatabase
		}
	}

	PitstopPending[] {
		Get {
			return this.iPitstopPending
		}
	}

	__New(controller, name, configuration := false) {
		if base.__New(controller, name, configuration) {
			if (this.RaceAssistantName)
				SetTimer collectRaceEngineerSessionData, 10000
			else
				SetTimer updateRaceEngineerSessionState, 5000

			return true
		}
		else
			return false
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function

		if inList(["PitstopPlan", "PitstopPrepare"], action) {
			function := controller.findFunction(actionFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				action := new this.RaceEngineerAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action)

				this.registerAction(action)
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return new this.RemoteRaceEngineer(this, pid)
	}

	prepareSettings(data) {
		settings := base.prepareSettings(data)

		tyresDB := new TyresDatabase()

		simulator := getConfigurationValue(data, "Session Data", "Simulator")
		car := getConfigurationValue(data, "Session Data", "Car")
		track := getConfigurationValue(data, "Session Data", "Track")

		simulatorName := tyresDB.getSimulatorName(simulator)

		duration := Round((getConfigurationValue(data, "Stint Data", "LapLastTime") - getConfigurationValue(data, "Session Data", "SessionTimeRemaining")) / 1000)
		weather := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
		compound := getConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		compoundColor := getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black")

		tpSetting := getConfigurationValue(this.Configuration, "Race Engineer Startup", simulatorName . ".LoadTyrePressures", "Default")

		if ((tpSetting = "TyresDatabase") || (tpSetting = "SetupDatabase")) {
			trackTemperature := getConfigurationValue(data, "Track Data", "Temperature", 23)
			airTemperature := getConfigurationValue(data, "Weather Data", "Temperature", 27)

			compound := false
			compoundColor := false
			pressures := {}
			certainty := 1.0

			if tyresDB.getTyreSetup(simulatorName, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, pressures, certainty) {
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound", compound)
				setConfigurationValue(settings, "Session Setup", "Tyre.Compound.Color", compoundColor)

				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FL", Round(pressures[1], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FR", Round(pressures[2], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RL", Round(pressures[3], 1))
				setConfigurationValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RR", Round(pressures[4], 1))
			}
		}
		else if (tpSetting = "Import") {
			writeConfiguration(kTempDirectory . "Race Engineer.settings", settings)

			openRaceSettings(true, true, false, kTempDirectory . "Race Engineer.settings")

			settings := readConfiguration(kTempDirectory . "Race Engineer.settings")
		}

		return settings
	}

	startSession(settings, data, teamSession) {
		base.startSession(settings, data, teamSession)

		this.iLapDatabase := false
	}

	checkPitstopPlan() {
		if (this.TeamSession && this.RaceEngineer) {
			pitstopSettings := this.TeamServer.getSessionValue("Pitstop Plan", false)

			if (pitstopSettings && (pitstopSettings != "")) {
				this.TeamServer.setSessionValue("Pitstop Plan", "")

				pitstopSettings := this.TeamServer.getLapValue(pitstopSettings, "Pitstop Plan")

				if (pitstopSettings && (pitstopSettings != "")) {
					pitstopSettings := parseConfiguration(pitstopSettings)

					requestDriver := getConfigurationValue(pitstopSettings, "Pitstop", "Driver", false)
					requestDriver := (requestDriver ? [requestDriver] : [])

					this.RaceEngineer.planPitstop(getConfigurationValue(pitstopSettings, "Pitstop", "Lap", 0)
												, getConfigurationValue(pitstopSettings, "Pitstop", "Refuel", 0)
												, getConfigurationValue(pitstopSettings, "Pitstop", "Tyre.Change", false)
												, getConfigurationValue(pitstopSettings, "Pitstop", "Tyre.Set", 0)
												, getConfigurationValue(pitstopSettings, "Pitstop", "Tyre.Compound", "Dry")
												, getConfigurationValue(pitstopSettings, "Pitstop", "Tyre.Compound.Color", "Black")
												, getConfigurationValue(pitstopSettings, "Pitstop", "Tyre.Pressures", "26.1,26.1,26.1,26.1")
												, getConfigurationValue(pitstopSettings, "Pitstop", "Repair.Bodywork", false)
												, getConfigurationValue(pitstopSettings, "Pitstop", "Repair.Suspension", false)
												, requestDriver*)
				}
			}
		}
	}

	addLap(lapNumber, dataFile, telemetryData, positionsData) {
		base.addLap(lapNumber, dataFile, telemetryData, positionsData)

		this.checkPitstopPlan()
	}

	updateLap(lapNumber, dataFile) {
		base.updateLap(lapNumber, dataFile)

		this.checkPitstopPlan()
	}

	requestInformation(arguments*) {
		if (this.RaceEngineer && inList(["Time", "LapsRemaining", "FuelRemaining", "Weather"
									   , "TyrePressures", "TyreTemperatures", "TyreWear"], arguments[1])) {
			this.RaceEngineer.requestInformation(arguments*)

			return true
		}
		else
			return false
	}

	planPitstop() {
		if this.RaceEngineer
			this.RaceEngineer.planPitstop()
	}

	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}

	performPitstop(lapNumber) {
		base.performPitstop(lapNumber)

		this.iPitstopPending := false

		SetTimer collectRaceEngineerSessionData, 10000
	}

	pitstopOptionChanged(option, values*) {
		if this.RaceEngineer
			this.RaceEngineer.pitstopOptionChanged(option, values*)
	}

	pitstopPlanned(pitstopNumber, plannedLap := false) {
		this.Simulator.pitstopPlanned(pitstopNumber, plannedLap := false)
	}

	pitstopPrepared(pitstopNumber) {
		this.iPitstopPending := true

		this.Simulator.pitstopPrepared(pitstopNumber)

		SetTimer collectRaceEngineerSessionData, 5000
	}

	pitstopFinished(pitstopNumber) {
		this.iPitstopPending := false

		this.Simulator.pitstopFinished(pitstopNumber)

		SetTimer collectRaceEngineerSessionData, 10000
	}

	updateTyreSet(pitstopNumber, driver, laps, compound, compoundColor, set, flWear, frWear, rlWear, rrWear) {
		data := newConfiguration()

		setConfigurationValue(data, "Pitstop Data", "Pitstop", pitstopNumber)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Driver", driver)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Laps", laps)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Compound", compound)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Compound.Color", compoundColor)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Set", set)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Wear.Front.Left", flWear)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Wear.Front.Right", frWear)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Wear.Rear.Left", rlWear)
		setConfigurationValue(data, "Pitstop Data", "Tyre.Wear.Rear.Right", rrWear)

		writeConfiguration(kTempDirectory . "Pitstop " . pitstopNumber . ".ini", data)

		this.updatePitstopState(data)
	}

	startPitstopSetup(pitstopNumber) {
		this.Simulator.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		this.Simulator.finishPitstopSetup(pitstopNumber)
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.Simulator.setPitstopRefuelAmount(pitstopNumber, litres)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.Simulator.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.Simulator.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		this.Simulator.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork)
	}

	requestPitstopDriver(pitstopNumber, driver) {
		this.Simulator.requestPitstopDriver(pitstopNumber, driver)
	}

	updatePitstopState(data) {
		teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive) {
			teamServer.setLapValue(this.LastLap, this.Plugin . " Pitstop State", printConfiguration(data))

			teamServer.setSessionValue(this.Plugin . " Pitstop State", this.LastLap)
		}
	}

	savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				   , compound, compoundColor, coldPressures, hotPressures) {
		teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive)
			teamServer.setLapValue(lapNumber, this.Plugin . " Pressures"
								 , values2String(";", simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, coldPressures, hotPressures))
		else
			this.LapDatabase.add("Pressures", {Lap: lapNumber, Simulator: simulator, Car: car, Track: track
											 , Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											 , "Compound": compound, "Compound.Color": compoundColor
											 , "Pressures.Cold": coldPressures, "Pressures.Hot": hotPressures})
	}

	updateTyresDatabase() {
		tyresDB := new TyresDatabase()
		teamServer := this.TeamServer
		session := this.TeamSession

		if (teamServer && teamServer.Active && session) {
			lastStint := false
			driverID := kNull

			Loop % teamServer.getCurrentLap(session)
			{
				try {
					stint := teamServer.getLapStint(A_Index, session)
					newStint := (stint != lastStint)

					if newStint {
						lastStint := stint

						driverID := teamServer.getStintValue(stint, "ID", session)
					}

					lapPressures := teamServer.getLapValue(A_Index, this.Plugin . " Pressures", session)

					if (!lapPressures || (lapPressures == ""))
						continue

					lapPressures := string2Values(";", lapPressures)

					if (newStint && driverID)
						tyresDB.registerDriver(lapPressures[1], driverID, teamServer.getStintDriverName(stint))

					tyresDB.updatePressures(lapPressures[1], lapPressures[2], lapPressures[3], lapPressures[4], lapPressures[5], lapPressures[6]
										  , lapPressures[7], lapPressures[8], string2Values(",", lapPressures[9])
										  , string2Values(",", lapPressures[10]), false, driverID)
				}
				catch exception {
					break
				}
				finally {
					tyresDB.flush()
				}
			}
		}
		else
			try {
				for ignore, lapData in this.LapDatabase.Tables["Pressures"]
					tyresDB.updatePressures(lapData.Simulator, lapData.Car, lapData.Track, lapData.Weather
										  , lapData["Temperature.Air"], lapData["Temperature.Track"]
										  , lapData.Compound, lapData["Compound.Color"]
										  , string2Values(",", lapData["Pressures.Cold"]), string2Values(",", lapData["Pressures.Hot"]), false)
			}
			finally {
				tyresDB.flush()
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

planPitstop() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).planPitstop()
	}
	finally {
		protectionOff()
	}
}

preparePitstop() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).preparePitstop()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateRaceEngineerSessionState() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).updateSessionState()
	}
	finally {
		protectionOff()
	}
}

collectRaceEngineerSessionData() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kRaceEngineerPlugin).collectSessionData()
	}
	finally {
		protectionOff()
	}
}

initializeRaceEngineerPlugin() {
	local controller := SimulatorController.Instance

	new RaceEngineerPlugin(controller, kRaceEngineerPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin()