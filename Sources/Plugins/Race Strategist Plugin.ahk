;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Plugin          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\RaceAssistantPlugin.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk
#Include ..\Assistants\Libraries\RaceReportReader.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRaceStrategistPlugin := "Race Strategist"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceStrategistPlugin extends RaceAssistantPlugin  {
	static kLapDataSchemas := {Telemetry: ["Lap", "Simulator", "Car", "Track", "Weather", "Temperature.Air", "Temperature.Track"
										 , "Fuel.Consumption", "Fuel.Remaining", "LapTime", "Pitstop", "Map", "TC", "ABS"
										 , "Compound", "Compound.Color", "Pressures", "Temperatures", "Wear"]}

	class RemoteRaceStrategist extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			base.__New(plugin, "Race Strategist", remotePID)
		}

		recommendPitstop(arguments*) {
			this.callRemote("callRecommendPitstop", arguments*)
		}

		updateStrategy(arguments*) {
			this.callRemote("updateStrategy", arguments*)
		}

		cancelStrategy(arguments*) {
			this.callRemote("cancelStrategy", arguments*)
		}

		recommendStrategy(arguments*) {
			this.callRemote("callRecommendStrategy", arguments*)
		}

		restoreRaceInfo(arguments*) {
			this.callRemote("restoreRaceInfo", arguments*)
		}

		reviewRace(arguments*) {
			this.callRemote("reviewRace", arguments*)
		}
	}

	class RaceStrategistAction extends RaceAssistantPlugin.RaceAssistantAction {
		fireAction(function, trigger) {
			if (this.Plugin.RaceStrategist && (this.Action = "PitstopRecommend"))
				this.Plugin.recommendPitstop()
			else if (this.Plugin.RaceStrategist && (this.Action = "StrategyCancel"))
				this.Plugin.cancelStrategy()
			else if (this.Plugin.RaceStrategist && (this.Action = "StrategyRecommend"))
				this.Plugin.recommendStrategy()
			else
				base.fireAction(function, trigger)
		}
	}

	RaceStrategist[] {
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

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, descriptor

		if inList(["PitstopRecommend", "StrategyCancel", "StrategyRecommend"], action) {
			function := controller.findFunction(actionFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(new this.RaceStrategistAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return base.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return new this.RemoteRaceStrategist(this, pid)
	}

	startSession(settings, data) {
		base.startSession(settings, data)

		this.iLapDatabase := false
	}

	checkStrategy() {
		local strategyUpdate

		if (this.TeamSession && this.RaceStrategist) {
			strategyUpdate := this.TeamServer.getSessionValue("Strategy Update", false)

			if (strategyUpdate && (strategyUpdate != "")) {
				this.TeamServer.setSessionValue("Strategy Update", "")

				strategyUpdate := this.TeamServer.getLapValue(strategyUpdate, "Strategy Update")

				if (strategyUpdate && (strategyUpdate != ""))
					if (strategyUpdate = "CANCEL")
						this.RaceStrategist.updateStrategy(false)
					else {
						try {
							if FileExist(kTempDirectory . "Race Strategy.update")
								deleteFile(kTempDirectory . "Race Strategy.update")

							FileAppend %strategyUpdate%, %kTempDirectory%Race Strategy.update
						}
						catch exception {
							logError(exception)
						}

						this.RaceStrategist.updateStrategy(kTempDirectory . "Race Strategy.update")
					}
			}
		}
	}

	updateStrategy(strategy) {
		local teamServer := this.TeamServer
		local text

		if (teamServer && teamServer.SessionActive) {
			if strategy {
				FileRead text, %strategy%

				deleteFile(strategy)

				teamServer.setSessionValue("Race Strategy", text)
				teamServer.setSessionValue("Race Strategy Version", "Force")
			}
			else {
				teamServer.setSessionValue("Race Strategy", "CANCEL")
				teamServer.setSessionValue("Race Strategy Version", "Force")
			}
		}
		else
			deleteFile(strategy)
	}

	addLap(lap, update, data) {
		base.addLap(lap, update, data)

		this.checkStrategy()
	}

	updateLap(lap, update, data) {
		base.updateLap(lap, update, data)

		this.checkStrategy()
	}

	requestInformation(arguments*) {
		if (this.RaceStrategist && inList(["Time", "LapsRemaining", "Weather", "Position", "LapTimes"
										 , "GapToAhead", "GapToFront", "GapToBehind", "GapToAheadStandings", "GapToFrontStandings"
										 , "GapToBehindStandings", "GapToAheadTrack", "GapToBehindTrack", "GapToLeader"
										 , "StrategyOverview", "NextPitstop"], arguments[1])) {
			this.RaceStrategist.requestInformation(arguments*)

			return true
		}
		else
			return false
	}

	recommendPitstop(lapNumber := false) {
		if this.RaceStrategist
			this.RaceStrategist.recommendPitstop(lapNumber)
	}

	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}

	activeSession(data) {
		local session := getDataSession(data)
		local simulator, car, track, weather, sessiom, default

		if (session == kSessionRace)
			return true
		else {
			simulator := getConfigurationValue(data, "Session Data", "Simulator")
			car := getConfigurationValue(data, "Session Data", "Car")
			track := getConfigurationValue(data, "Session Data", "Track")
			weather := getConfigurationValue(data, "Weather Data", "Weather", "Dry")

			session := "Other"
			default := false

			switch session {
				case kSessionPractice:
					session := "Practice"
					default := true
				case kSessionQualification:
					session := "Qualification"
			}

			return getConfigurationValue(new SettingsDatabase().loadSettings(simulator, car, track, weather)
									   , "Session Settings", "Telemetry." . session, default)
		}
	}

	saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
					, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
					, compound, compoundColor, pressures, temperatures, wear) {
		local teamServer := this.TeamServer

		if !wear
			wear := values2String(",", kNull, kNull, kNull, kNull)

		if (teamServer && teamServer.SessionActive)
			teamServer.setLapValue(lapNumber, this.Plugin . " Telemetry"
								 , values2String(";", simulator, car, track, weather, airTemperature, trackTemperature
													, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs,
													, compound, compoundColor, pressures, temperatures, wear))
		else
			this.LapDatabase.add("Telemetry", {Lap: lapNumber, Simulator: simulator, Car: car, Track: track
											 , Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											 , "Fuel.Consumption": fuelConsumption, "Fuel.Remaining": fuelRemaining, LapTime: lapTime
											 , Pitstop: pitstop, Map: map, TC: tc, ABS: abs
											 , "Compound": compound, "Compound.Color": compoundColor
											 , Pressures: pressures, Temperatures: temperatures, Wear: wear})
	}

	updateTelemetryDatabase() {
		local telemetryDB := false
		local teamServer := this.TeamServer
		local session := this.TeamSession
		local runningLap := 0
		local stint, newStint, lastStint, driverID, ignore, telemetryData, pitstop, pressures, temperatures, wear

		if (teamServer && teamServer.Active && session) {
			lastStint := false
			driverID := kNull

			loop % teamServer.getCurrentLap(session)
			{
				try {
					stint := teamServer.getLapStint(A_Index, session)
					newStint := (stint != lastStint)

					if newStint {
						lastStint := stint

						driverID := teamServer.getStintValue(stint, "ID", session)
					}

					telemetryData := teamServer.getLapValue(A_Index, this.Plugin . " Telemetry", session)

					if (!telemetryData || (telemetryData == ""))
						continue

					telemetryData := string2Values(";", telemetryData)

					if !telemetryDB
						telemetryDB := new TelemetryDatabase(telemetryData[1], telemetryData[2], telemetryData[3])

					if (newStint && driverID)
						telemetryDB.registerDriver(telemetryData[1], driverID, teamServer.getStintDriverName(stint))

					pitstop := telemetryData[10]

					if ((runningLap > 2) && pitstop)
						runningLap := 0

					runningLap += 1

					if !pitstop {
						pressures := string2Values(",", telemetryData[16])
						temperatures := string2Values(",", telemetryData[17])
						wear := string2Values(",", telemetryData[18])

						telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
													 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8]
													 , telemetryData[9], driverID)

						telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15], runningLap
											   , pressures[1], pressures[2], pressures[4], pressures[4]
											   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
											   , wear[1], wear[2], wear[3], wear[4]
											   , telemetryData[7], telemetryData[8], telemetryData[9], driverID)
					}
				}
				catch exception {
					break
				}
			}
		}
		else
			for ignore, telemetryData in this.LapDatabase.Tables["Telemetry"] {
				if !telemetryDB
					telemetryDB := new TelemetryDatabase(telemetryData.Simulator, telemetryData.Car, telemetryData.Track)

				if telemetryData.Pitstop
					runningLap := 0

				runningLap += 1

				telemetryDB.addElectronicEntry(telemetryData.Weather, telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
											 , telemetryData.Compound, telemetryData["Compound.Color"]
											 , telemetryData.Map, telemetryData.TC, telemetryData.ABS
											 , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData.LapTime)

				pressures := string2Values(",", telemetryData.Pressures)
				temperatures := string2Values(",", telemetryData.Temperatures)
				wear := string2Values(",", telemetryData.Wear)

				telemetryDB.addTyreEntry(telemetryData.Weather, telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
									   , telemetryData.Compound, telemetryData["Compound.Color"], runningLap
									   , pressures[1], pressures[2], pressures[4], pressures[4]
									   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
									   , wear[1], wear[2], wear[3], wear[4]
									   , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData.LapTime)
			}
	}

	setLapValue(lapNumber, name, fileName) {
		local teamServer := this.TeamServer
		local currentEncoding, lapData

		if (teamServer && teamServer.SessionActive) {
			currentEncoding := A_FileEncoding

			try {
				FileEncoding UTF-16
				FileRead lapData, %fileName%
			}
			finally {
				FileEncoding %currentEncoding%
			}

			teamServer.setLapValue(lapNumber, name, lapData)

			deleteFile(fileName)
		}
	}

	saveStandingsData(lapNumber, fileName) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive)
			this.setLapValue(lapNumber, this.Plugin . " Race Standings", fileName)

		deleteFile(fileName)
	}

	saveRaceInfo(lapNumber, fileName) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive) {
			this.setLapValue(lapNumber, this.Plugin . " Race Info", fileName)

			deleteFile(fileName)
		}
		else {
			deleteDirectory(kTempDirectory . "Race Report")

			FileCreateDir %kTempDirectory%Race Report

			FileMove %fileName%, %kTempDirectory%Race Report\Race.data
		}
	}

	saveRaceLap(lapNumber, fileName) {
		local teamServer := this.TeamServer

		if (teamServer && teamServer.SessionActive) {
			this.setLapValue(lapNumber, this.Plugin . " Race Lap", fileName)

			deleteFile(fileName)
		}
		else {
			FileMove %fileName%, %kTempDirectory%Race Report\Lap.%lapNumber%, 1

			loop {
				lapNumber += 1

				if FileExist(kTempDirectory . "Race Report\Lap." . lapNumber)
					deleteFile(kTempDirectory . "Race Report\Lap." . lapNumber)
				else
					break
			}
		}
	}

	restoreRaceInfo() {
		local teamServer := this.TeamServer
		local raceInfo, fileName

		if (teamServer && teamServer.Active) {
			try {
				raceInfo := teamServer.getLapValue(1, this.Plugin . " Race Info", this.TeamSession)

				if (!raceInfo || (raceInfo == ""))
					return

				fileName := temporaryFileName(this.Plugin . " Race", "info")

				FileAppend %raceInfo%, %fileName%

				this.RaceStrategist.restoreRaceInfo(fileName)
			}
			catch exception {
				return
			}
		}
	}

	restoreSessionState() {
		local teamServer := this.TeamServer

		if (this.RaceStrategist && teamServer && teamServer.Active)
			this.restoreRaceInfo()

		base.restoreSessionState()
	}

	createRaceReport(targetDirectory := false) {
		local reportsDirectory := getConfigurationValue(this.Configuration, "Race Strategist Reports", "Database", false)
		local teamServer, session, runningLap, raceInfo, count, pitstops, lapData, data, key, value
		local times, positions, laps, drivers, newLine, line, fileName, directory, simulatorCode

		if (targetDirectory || reportsDirectory) {
			teamServer := this.TeamServer
			session := this.TeamSession

			runningLap := 0

			if (teamServer && teamServer.Active && session) {
				deleteDirectory(kTempDirectory . "Race Report")

				FileCreateDir %kTempDirectory%Race Report

				try {
					raceInfo := teamServer.getLapValue(1, this.Plugin . " Race Info", session)

					if (!raceInfo || (raceInfo == ""))
						return

					FileAppend %raceInfo%, %kTempDirectory%Race Report\Race.data

					data := readConfiguration(kTempDirectory . "Race Report\Race.data")
				}
				catch exception {
					data := {}
				}

				count := 0
				pitstops := false

				loop % teamServer.getCurrentLap(session)
				{
					try {
						lapData := teamServer.getLapValue(A_Index, this.Plugin . " Race Lap", session)

						if (lapData && (lapData != "")) {
							lapData := parseConfiguration(lapData)

							count += 1

							for key, value in getConfigurationSectionValues(lapData, "Lap")
								setConfigurationValue(data, "Laps", key, value)

							pitstops := getConfigurationValue(lapData, "Pitstop", "Laps", "")

							times := getConfigurationValue(lapData, "Times", A_Index)
							positions := getConfigurationValue(lapData, "Positions", A_Index)
							laps := getConfigurationValue(lapData, "Laps", A_Index)
							drivers := getConfigurationValue(lapData, "Drivers", A_Index)

							newLine := ((count > 1) ? "`n" : "")

							line := (newLine . times)

							FileAppend %line%, % kTempDirectory . "Race Report\Times.CSV"

							line := (newLine . positions)

							FileAppend %line%, % kTempDirectory . "Race Report\Positions.CSV"

							line := (newLine . laps)

							FileAppend %line%, % kTempDirectory . "Race Report\Laps.CSV"

							line := (newLine . drivers)
							directory := (kTempDirectory . "Race Report\Drivers.CSV")

							FileAppend %line%, %directory%, UTF-16
						}
					}
					catch exception {
						break
					}
				}

				removeConfigurationValue(data, "Laps", "Lap")
				setConfigurationValue(data, "Laps", "Count", count)

				setConfigurationValue(data, "Laps", "Pitstops", pitstops)

				writeConfiguration(kTempDirectory . "Race Report\Race.data", data)

				simulatorCode := new SessionDatabase().getSimulatorCode(getConfigurationValue(data, "Session", "Simulator"))

				if !targetDirectory
					targetDirectory := (reportsDirectory . "\" . simulatorCode . "\" . getConfigurationValue(data, "Session", "Time"))

				FileCopyDir %kTempDirectory%Race Report, %targetDirectory%, 1
			}
			else {
				data := readConfiguration(kTempDirectory . "Race Report\Race.data")

				count := 0
				pitstops := false

				try {
					if FileExist(kTempDirectory . "Race Report\Output")
						deleteDirectory(kTempDirectory . "Race Report\Output")

					FileCreateDir %kTempDirectory%Race Report\Output
				}
				catch exception {
					logError(exception)
				}

				loop {
					fileName := (kTempDirectory . "Race Report\Lap." . A_Index)

					if !FileExist(fileName)
						break
					else {
						lapData := readConfiguration(fileName)

						count += 1

						for key, value in getConfigurationSectionValues(lapData, "Lap")
							setConfigurationValue(data, "Laps", key, value)

						pitstops := getConfigurationValue(lapData, "Pitstop", "Laps", "")

						times := getConfigurationValue(lapData, "Times", A_Index)
						positions := getConfigurationValue(lapData, "Positions", A_Index)
						laps := getConfigurationValue(lapData, "Laps", A_Index)
						drivers := getConfigurationValue(lapData, "Drivers", A_Index)

						newLine := ((count > 1) ? "`n" : "")

						line := (newLine . times)

						FileAppend %line%, % kTempDirectory . "Race Report\Output\Times.CSV"

						line := (newLine . positions)

						FileAppend %line%, % kTempDirectory . "Race Report\Output\Positions.CSV"

						line := (newLine . laps)

						FileAppend %line%, % kTempDirectory . "Race Report\Output\Laps.CSV"

						line := (newLine . drivers)
						fileName := (kTempDirectory . "Race Report\Output\Drivers.CSV")

						FileAppend %line%, %fileName%, UTF-16
					}
				}

				removeConfigurationValue(data, "Laps", "Lap")
				setConfigurationValue(data, "Laps", "Count", count)

				setConfigurationValue(data, "Laps", "Pitstops", pitstops)

				writeConfiguration(kTempDirectory . "Race Report\Output\Race.data", data)

				simulatorCode := new SessionDatabase().getSimulatorCode(getConfigurationValue(data, "Session", "Simulator"))

				if !targetDirectory
					targetDirectory := (reportsDirectory . "\" . simulatorCode . "\" . getConfigurationValue(data, "Session", "Time"))

				FileCopyDir %kTempDirectory%Race Report\Output, %targetDirectory%, 1
			}
		}
	}

	reviewRace() {
		local report, reader, raceData, drivers, positions, times, cars, driver, laps, position
		local leader, car, candidate, min, max, leaderAvgLapTime, stdDev
		local driverMinLapTime, driverMaxLapTime, driverAvgLapTime, driverLapTimeStdDev

		report := temporaryFileName(this.Plugin . " Race", "report")

		this.createRaceReport(report)

		try {
			try {
				reader := new RaceReportReader(report)

				raceData := true
				drivers := true
				positions := true
				times := true

				reader.loadData(false, raceData, drivers, positions, times)

				cars := getConfigurationValue(raceData, "Cars", "Count", 0)
				driver := getConfigurationValue(raceData, "Cars", "Driver", 0)
				laps := getConfigurationValue(raceData, "Laps", "Count", 0)

				if laps
					position := (positions[laps].HasKey(driver) ? positions[laps][driver] : cars)
				else
					position := cars

				leader := 0

				for car, candidate in positions[laps]
					if (candidate = 1) {
						leader := car

						break
					}

				min := false
				max := false
				leaderAvgLapTime := false
				stdDev := false

				reader.getDriverPace(raceData, times, leader, min, max, leaderAvgLapTime, stdDev)

				driverMinLapTime := false
				driverMaxLapTime := false
				driverAvgLapTime := false
				driverLapTimeStdDev := false

				reader.getDriverPace(raceData, times, driver, driverMinLapTime, driverMaxLapTime, driverAvgLapTime, driverLapTimeStdDev)

				this.RaceAssistant[true].reviewRace(cars, laps, position, leaderAvgLapTime
												  , driverAvgLapTime, driverMinLapTime, driverMaxLapTime, driverLapTimeStdDev)
			}
			catch exception {
				this.RaceAssistant[true].reviewRace(0, 0, 0, 0, 0, 0, 0, 0)
			}
		}
		finally {
			deleteDirectory(report)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistPlugin() {
	local controller := SimulatorController.Instance

	new RaceStrategistPlugin(controller, kRaceStrategistPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistPlugin()