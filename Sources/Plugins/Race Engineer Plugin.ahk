;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "Libraries\RaceAssistantPlugin.ahk"
#Include "..\Database\Libraries\TyresDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceEngineerPlugin := "Race Engineer"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineerPlugin extends RaceAssistantPlugin {
	static kLapDataSchemas := CaseInsenseMap("Pressures", ["Lap", "Simulator", "Car", "Track", "Weather", "Temperature.Air", "Temperature.Track"
														 , "Compound", "Compound.Color", "Pressures.Cold", "Pressures.Hot", "Pressures.Losses"])

	iPitstopPending := false

	iLapDatabase := false

	class DriverSwapTask extends Task {
		iPlugin := false

		iStartTime := false

		Plugin {
			Get {
				return this.iPlugin
			}
		}

		__New(plugin) {
			this.iPlugin := plugin

			this.iStartTime := A_TickCount

			super.__New(false, 1000, kLowPriority)
		}

		run() {
			local teamServer := this.Plugin.TeamServer
			local driverSwapPlan, requestDriver

			if (teamServer && teamServer.SessionActive) {
				try {
					driverSwapPlan := teamServer.getSessionValue(this.Plugin.Plugin . " Driver Swap Plan")

					if (driverSwapPlan && (driverSwapPlan != "")) {
						teamServer.setSessionValue(this.Plugin.Plugin . " Driver Swap Plan", "")

						driverSwapPlan := parseMultiMap(driverSwapPlan)

						requestDriver := getMultiMapValue(driverSwapPlan, "Pitstop", "Driver", false)
						requestDriver := (requestDriver ? [requestDriver] : [])

						this.Plugin.RaceEngineer.planDriverSwap(getMultiMapValue(driverSwapPlan, "Pitstop", "Lap", 0)
															  , "!" . getMultiMapValue(driverSwapPlan, "Pitstop", "Refuel", 0)
															  , "!" . getMultiMapValue(driverSwapPlan, "Pitstop", "Tyre.Change", false)
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Tyre.Set", 0)
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Tyre.Compound", "Dry")
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Tyre.Compound.Color", "Black")
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Tyre.Pressures", "26.1,26.1,26.1,26.1")
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Repair.Bodywork", false)
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Repair.Suspension", false)
															  , getMultiMapValue(driverSwapPlan, "Pitstop", "Repair.Engine", false)
															  , requestDriver*)

						return false
					}
				}
				catch Any as exception {
					logError(exception)
				}

				if (A_TickCount > (this.iStartTime + 20000)) {
					this.Plugin.RaceEngineer.planDriverSwap(false)

					return false
				}
				else
					return this
			}
			else {
				this.Plugin.RaceEngineer.planDriverSwap(false)

				return false
			}
		}
	}

	class RemoteRaceEngineer extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			super.__New(plugin, "Race Engineer", remotePID)
		}

		planPitstop(arguments*) {
			this.callRemote("callPlanPitstop", arguments*)
		}

		planDriverSwap(arguments*) {
			this.callRemote("callPlanDriverSwap", arguments*)
		}

		preparePitstop(arguments*) {
			this.callRemote("callPreparePitstop", arguments*)
		}

		pitstopOptionChanged(arguments*) {
			this.callRemote("pitstopOptionChanged", arguments*)
		}

		pitstopPrepared(arguments*) {
			this.callRemote("pitstopPrepared", arguments*)
		}
	}

	class RaceEngineerAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceEngineer && (this.Action = "PitstopPlan"))
				this.Plugin.planPitstop()
			else if (this.Plugin.RaceEngineer && (this.Action = "DriverSwapPlan"))
				this.Plugin.planDriverSwap()
			else if (this.Plugin.RaceEngineer && (this.Action = "PitstopPrepare"))
				this.Plugin.preparePitstop()
			else
				super.fireAction(function, trigger)
		}
	}

	RaceEngineer {
		Get {
			return this.RaceAssistant
		}
	}

	LapDatabase {
		Get {
			if !this.iLapDatabase
				this.iLapDatabase := Database(false, RaceEngineerPlugin.kLapDataSchemas)

			return this.iLapDatabase
		}
	}

	PitstopPending {
		Get {
			return this.iPitstopPending
		}
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, descriptor

		if inList(["PitstopPlan", "DriverSwapPlan", "PitstopPrepare"], action) {
			function := controller.findFunction(actionFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				action := RaceEngineerPlugin.RaceEngineerAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action)

				this.registerAction(action)
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return RaceEngineerPlugin.RemoteRaceEngineer(this, pid)
	}

	loadSettings(simulator, car, track, data := false, settings := false) {
		local tyresDB, simulatorName, compound, compoundColor
		local tpSettings, pressures, certainty, collectPressure, pitstopService, ignore, session
		local fuelWarning, damageWarning, pressureWarning, correctByTemperatures, correctByDatabase, correctForPressureLoss

		settings := super.loadSettings(simulator, car, track, data, settings)

		if data {
			local weather := getMultiMapValue(data, "Weather Data", "Weather", "Dry")
			local airTemperature := getMultiMapValue(data, "Weather Data", "Temperature", 27)
			local trackTemperature := getMultiMapValue(data, "Track Data", "Temperature", 23)

			tyresDB := TyresDatabase()

			simulatorName := tyresDB.getSimulatorName(simulator)

			tpSetting := getMultiMapValue(this.Configuration, "Race Engineer Startup", simulatorName . ".LoadTyrePressures", "Default")

			if ((tpSetting = "TyresDatabase") || (tpSetting = "SetupDatabase")) {
				compound := false
				compoundColor := false

				pressures := []
				certainty := 1.0

				if tyresDB.getTyreSetup(simulatorName, car, track
									  , getMultiMapValue(data, "Weather Data", "Weather", "Dry")
									  , getMultiMapValue(data, "Weather Data", "Temperature", 23)
									  , getMultiMapValue(data, "Track Data", "Temperature", 27)
									  , &compound, &compoundColor, &pressures, &certainty, true) {
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound", compound)
					setMultiMapValue(settings, "Session Setup", "Tyre.Compound.Color", compoundColor)

					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FL", Round(pressures[1], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FR", Round(pressures[2], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RL", Round(pressures[3], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RR", Round(pressures[4], 1))
				}
			}
			else if (tpSetting = "Import") {
				writeMultiMap(kTempDirectory . "Race Engineer.settings", settings)

				openRaceSettings(true, true, false, kTempDirectory . "Race Engineer.settings")

				settings := readMultiMap(kTempDirectory . "Race Engineer.settings")
			}
			else if (data && (tpSetting = "Setup")) {
				compound := getMultiMapValue(data, "Car Data", "TyreCompound", "Dry")
				compoundColor := getMultiMapValue(data, "Car Data", "TyreCompoundColor", "Black")
				pressures := string2Values(",", getMultiMapValue(data, "Car Data", "TyrePressure", ""))

				if (pressures.Length >= 4) {
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FL", Round(pressures[1], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.FR", Round(pressures[2], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RL", Round(pressures[3], 1))
					setMultiMapValue(settings, "Session Setup", "Tyre." . compound . ".Pressure.RR", Round(pressures[4], 1))
				}
			}
		}

		if this.StartupSettings {
			collectPressure := getMultiMapValue(this.StartupSettings, "Functions", "Pressure Collection", kUndefined)

			if (collectPressure != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Session Settings", "Telemetry." . session, collectPressure)

			pitstopService := getMultiMapValue(this.StartupSettings, "Functions", "Pitstop Service", kUndefined)

			if (pitstopService != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Session Settings", "Pitstop." . session, pitstopService)

			fuelWarning := getMultiMapValue(this.StartupSettings, "Functions", "Fuel Warning", kUndefined)

			if (fuelWarning != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Assistant.Engineer", "Announcement." . session . ".LowFuel", fuelWarning)

			damageWarning := getMultiMapValue(this.StartupSettings, "Functions", "Damage Warning", kUndefined)

			if (damageWarning != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Assistant.Engineer", "Announcement." . session . ".Damage", damageWarning)

			pressureWarning := getMultiMapValue(this.StartupSettings, "Functions", "Pressure Warning", kUndefined)

			if (pressureWarning != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Assistant.Engineer", "Announcement." . session . ".Pressure", pressureWarning)

			correctByTemperatures := getMultiMapValue(this.StartupSettings, "Functions", "Pressure Correction by Temperature", kUndefined)

			if (correctByTemperatures != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature", correctByTemperatures)

			correctByDatabase := getMultiMapValue(this.StartupSettings, "Functions", "Pressure Correction from Database", kUndefined)

			if (correctByDatabase != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Setup", correctByDatabase)

			correctForPressureLoss := getMultiMapValue(this.StartupSettings, "Functions", "Pressure Correction for Pressure Loss", kUndefined)

			if (correctForPressureLoss != kUndefined)
				for ignore, session in ["Practice", "Qualification", "Race"]
					setMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Pressure", correctForPressureLoss)
		}

		return settings
	}

	startSession(settings, data) {
		super.startSession(settings, data)

		this.iLapDatabase := false
	}

	joinSession(settings, data) {
		if getMultiMapValue(settings, "Assistant.Engineer", "Join.Late", false)
			this.startSession(settings, data)
	}

	checkPitstopPlan() {
		local pitstopSettings, requestDriver

		if (this.TeamSession && this.RaceEngineer) {
			pitstopSettings := this.TeamServer.getSessionValue("Pitstop Plan", false)

			if (pitstopSettings && (pitstopSettings != "")) {
				if isDevelopment()
					logMessage(kLogInfo, "Engineer instructions found - Lap: " . pitstopSettings)

				this.TeamServer.setSessionValue("Pitstop Plan", "")

				pitstopSettings := this.TeamServer.getLapValue(pitstopSettings, "Pitstop Plan")

				if (pitstopSettings && (pitstopSettings != "")) {
					if isDevelopment()
						logMessage(kLogInfo, "Instructions:`n" . pitstopSettings)

					pitstopSettings := parseMultiMap(pitstopSettings)

					requestDriver := getMultiMapValue(pitstopSettings, "Pitstop", "Driver", false)
					requestDriver := (requestDriver ? [requestDriver] : [])

					this.RaceEngineer.planPitstop(getMultiMapValue(pitstopSettings, "Pitstop", "Lap", 0)
												, "!" . getMultiMapValue(pitstopSettings, "Pitstop", "Refuel", 0)
												, "!" . getMultiMapValue(pitstopSettings, "Pitstop", "Tyre.Change", false)
												, getMultiMapValue(pitstopSettings, "Pitstop", "Tyre.Set", 0)
												, getMultiMapValue(pitstopSettings, "Pitstop", "Tyre.Compound", "Dry")
												, getMultiMapValue(pitstopSettings, "Pitstop", "Tyre.Compound.Color", "Black")
												, getMultiMapValue(pitstopSettings, "Pitstop", "Tyre.Pressures", "26.1,26.1,26.1,26.1")
												, getMultiMapValue(pitstopSettings, "Pitstop", "Repair.Bodywork", false)
												, getMultiMapValue(pitstopSettings, "Pitstop", "Repair.Suspension", false)
												, getMultiMapValue(pitstopSettings, "Pitstop", "Repair.Engine", false)
												, requestDriver*)
				}
			}
		}
	}

	addLap(lap, running, data) {
		super.addLap(lap, running, data)

		this.checkPitstopPlan()
	}

	updateLap(lap, running, data) {
		super.updateLap(lap, running, data)

		this.checkPitstopPlan()
	}

	requestInformation(arguments*) {
		if (this.RaceEngineer && inList(["Time", "LapsRemaining", "FuelRemaining", "Weather"
									   , "TyrePressures", "TyrePressuresCold", "TyrePressuresSetup", "TyreTemperatures", "TyreWear"
									   , "BrakeTemperatures", "BrakeWear"], arguments[1])) {
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

	planDriverSwap(arguments*) {
		local teamServer

		if this.RaceEngineer {
			if (arguments.Length = 0)
				this.RaceEngineer.planDriverSwap()
			else {
				teamServer := this.TeamServer

				if (teamServer && teamServer.SessionActive) {
					teamServer.setSessionValue(this.Plugin . " Driver Swap Plan", "")
					teamServer.setSessionValue(this.Plugin . " Driver Swap Request", values2String(";", arguments*))

					RaceEngineerPlugin.DriverSwapTask(this).start()
				}
				else
					this.RaceEngineer.planDriverSwap(false)
			}
		}
	}

	preparePitstop(lap := false) {
		if this.RaceEngineer
			this.RaceEngineer.preparePitstop(lap)
	}

	pitstopSetupFinished() {
		if this.RaceEngineer
			this.RaceEngineer.pitstopPrepared()
	}

	performPitstop(lapNumber, options) {
		super.performPitstop(lapNumber, options)

		this.iPitstopPending := false
	}

	pitstopOptionChanged(option, verbose, values*) {
		if this.RaceEngineer
			this.RaceEngineer.pitstopOptionChanged(option, verbose, values*)
	}

	pitstopPlanned(pitstopNumber, plannedLap := false) {
		this.Simulator.pitstopPlanned(pitstopNumber, plannedLap := false)
	}

	pitstopPrepared(pitstopNumber) {
		this.iPitstopPending := true

		this.Simulator.pitstopPrepared(pitstopNumber)
	}

	pitstopFinished(pitstopNumber) {
		this.iPitstopPending := false

		this.Simulator.pitstopFinished(pitstopNumber)
	}

	updateTyreSet(pitstopNumber, driver, laps, compound, compoundColor, set, flWear, frWear, rlWear, rrWear) {
		local data := newMultiMap()

		setMultiMapValue(data, "Pitstop Data", "Pitstop", pitstopNumber)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Driver", driver)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Laps", laps)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Compound", compound)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Compound.Color", compoundColor)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Set", set)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Wear.Front.Left", flWear)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Wear.Front.Right", frWear)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Wear.Rear.Left", rlWear)
		setMultiMapValue(data, "Pitstop Data", "Tyre.Wear.Rear.Right", rrWear)

		writeMultiMap(kTempDirectory . "Pitstop " . pitstopNumber . ".ini", data)

		this.updatePitstopState(data)
	}

	startPitstopSetup(pitstopNumber) {
		this.Simulator.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		this.Simulator.finishPitstopSetup(pitstopNumber)
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		this.Simulator.setPitstopRefuelAmount(pitstopNumber, liters)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.Simulator.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.Simulator.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine) {
		this.Simulator.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)
	}

	requestPitstopDriver(pitstopNumber, driver) {
		this.Simulator.requestPitstopDriver(pitstopNumber, driver)
	}

	updatePitstopState(data) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive) {
			teamServer.setLapValue(this.LastLap, this.Plugin . " Pitstop State", printMultiMap(data))

			teamServer.setSessionValue(this.Plugin . " Pitstop State", this.LastLap)
		}
	}

	savePressureData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				   , compound, compoundColor, coldPressures, hotPressures, pressuresLosses) {
		local teamServer := this.TeamServer
		local pid

		if (teamServer && teamServer.SessionActive)
			teamServer.setLapValue(lapNumber, this.Plugin . " Pressures"
								 , values2String(";", simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
								 , coldPressures, hotPressures, pressuresLosses))
		else {
			pid := ProcessExist("Practice Center.exe")

			if pid
				messageSend(kFileMessage, "Practice", "updatePressures:" . values2String(";", lapNumber, simulator, car, track, weather
																							, airTemperature, trackTemperature
																							, compound, compoundColor
																							, coldPressures, hotPressures, pressuresLosses), pid)

			this.LapDatabase.add("Pressures", Database.Row("Lap", lapNumber, "Simulator", simulator, "Car", car, "Track", track
														 , "Weather", weather, "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
														 , "Compound", compound, "Compound.Color", compoundColor
														 , "Pressures.Cold", coldPressures, "Pressures.Hot", hotPressures, "Pressures.Losses", pressuresLosses))
		}
	}

	updateTyresDatabase() {
		local tyresDB := TyresDatabase()
		local teamServer := this.TeamServer
		local session := this.TeamSession
		local first := true
		local tries := 10
		local stint, lastStint, newStint, driverID, lapPressures, ignore, lapData, driverName
		local coldPressures, hotPressures, pressureLosses

		if Task.CurrentTask
			Task.CurrentTask.Critical := true

		try {
			if (teamServer && teamServer.Active && session) {
				lastStint := false
				driverID := kNull

				loop teamServer.getCurrentLap(session, 1)
					try {
						stint := teamServer.getLapStint(A_Index, session, 1)
						newStint := (stint != lastStint)

						if newStint {
							driverID := teamServer.getStintValue(stint, "ID", session, 1)

							if !driverID
								continue

							lastStint := stint
						}

						lapPressures := teamServer.getLapValue(A_Index, this.Plugin . " Pressures", session, 1)

						if (!lapPressures || (lapPressures == ""))
							continue

						lapPressures := string2Values(";", lapPressures)

						if (newStint && driverID) {
							driverName := teamServer.getStintDriverName(stint)

							if driverName
								tyresDB.registerDriver(lapPressures[1], driverID, driverName)
						}

						if first {
							if !tyresDB.lock(lapPressures[1], lapPressures[2], lapPressures[3], false) {
								Sleep(200)

								if (tries-- <= 0)
									return
								else
									continue
							}

							first := false
						}

						coldPressures := string2Values(",", lapPressures[9])
						hotPressures := string2Values(",", lapPressures[10])

						if (isNumber(coldPressures[1]) && isNumber(hotPressures[1])) {
							pressureLosses := string2Values(",", lapPressures[11])

							if isNumber(pressureLosses[1])
								loop 4
									coldPressures[A_Index] -= pressureLosses[A_Index]

							tyresDB.updatePressures(lapPressures[1], lapPressures[2], lapPressures[3], lapPressures[4], lapPressures[5], lapPressures[6]
												  , lapPressures[7], lapPressures[8], coldPressures, hotPressures, false, driverID)
						}
					}
					catch Any as exception {
						logError(exception)

						break
					}
			}
			else
				try {
					for ignore, lapData in this.LapDatabase.Tables["Pressures"] {
						if first {
							if !tyresDB.lock(lapData["Simulator"], lapData["Car"], lapData["Track"], false) {
								Sleep(200)

								if (tries-- <= 0)
									return
								else
									continue
							}

							first := false
						}

						coldPressures := string2Values(",", lapData["Pressures.Cold"])
						hotPressures := string2Values(",", lapData["Pressures.Hot"])

						if (isNumber(coldPressures[1]) && isNumber(hotPressures[1])) {
							pressureLosses := string2Values(",", lapData["Pressures.Losses"])

							if isNumber(pressureLosses[1])
								loop 4
									coldPressures[A_Index] -= pressureLosses[A_Index]

							tyresDB.updatePressures(lapData["Simulator"], lapData["Car"], lapData["Track"], lapData["Weather"]
												  , lapData["Temperature.Air"], lapData["Temperature.Track"]
												  , lapData["Compound"], lapData["Compound.Color"]
												  , coldPressures, hotPressures, false)
						}
					}
				}
				catch Any as exception {
					logError(exception)
				}
		}
		finally {
			try {
				tyresDB.unlock()
			}
			catch Any as exception {
				logError(exception)
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Controller Action Section                       ;;;
;;;-------------------------------------------------------------------------;;;

planPitstop() {
	local plugin := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)

	protectionOn()

	try {
		if SimulatorController.Instance.isActive(plugin)
			plugin.planPitstop()
	}
	finally {
		protectionOff()
	}
}

planDriverSwap() {
	local plugin := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)

	protectionOn()

	try {
		if SimulatorController.Instance.isActive(plugin)
			plugin.planDriverSwap()
	}
	finally {
		protectionOff()
	}
}

preparePitstop() {
	local plugin := SimulatorController.Instance.findPlugin(kRaceEngineerPlugin)

	protectionOn()

	try {
		if SimulatorController.Instance.isActive(plugin)
			plugin.preparePitstop()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin() {
	local controller := SimulatorController.Instance

	RaceEngineerPlugin(controller, kRaceEngineerPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerPlugin()