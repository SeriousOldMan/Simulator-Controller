;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Plugin          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\RaceAssistantPlugin.ahk"
#Include "..\Database\Libraries\TelemetryDatabase.ahk"
#Include "..\Assistants\Libraries\RaceReportReader.ahk"


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
	static kLapDataSchemas := CaseInsenseMap("Telemetry", ["Lap", "Simulator", "Car", "Track", "Weather", "Temperature.Air", "Temperature.Track"
														 , "Fuel.Consumption", "Fuel.Remaining", "LapTime", "Pitstop", "Map", "TC", "ABS"
														 , "Compound", "Compound.Color", "Pressures", "Temperatures", "Wear"])

	iRaceStrategist := false

	iLastStrategyVersion := false

	class RemoteRaceStrategist extends RaceAssistantPlugin.RemoteRaceAssistant {
		__New(plugin, remotePID) {
			super.__New(plugin, "Race Strategist", remotePID)
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

		updateCarStatistics(arguments*) {
			this.callRemote("updateCarStatistics", arguments*)
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
				super.fireAction(function, trigger)
		}
	}

	RaceAssistant[zombie := false] {
		Get {
			if (zombie = "Ghost")
				return this.iRaceStrategist
			else
				return super.RaceAssistant[zombie]
		}

		Set {
			if value
				this.iRaceStrategist := value

			return (super.RaceAssistant := value)
		}
	}

	RaceStrategist {
		Get {
			return this.RaceAssistant
		}
	}

	LapDatabase {
		Get {
			if !this.iLapDatabase
				this.iLapDatabase := Database(false, RaceStrategistPlugin.kLapDataSchemas)

			return this.iLapDatabase
		}
	}

	createRaceAssistantAction(controller, action, actionFunction, arguments*) {
		local function, descriptor

		if inList(["PitstopRecommend", "StrategyCancel", "StrategyRecommend"], action) {
			function := controller.findFunction(actionFunction)

			if (function != false) {
				descriptor := ConfigurationItem.descriptor(action, "Activate")

				this.registerAction(RaceStrategistPlugin.RaceStrategistAction(this, function, this.getLabel(descriptor, action), this.getIcon(descriptor), action))
			}
			else
				this.logFunctionNotFound(actionFunction)
		}
		else
			return super.createRaceAssistantAction(controller, action, actionFunction, arguments*)
	}

	createRaceAssistant(pid) {
		return RaceStrategistPlugin.RemoteRaceStrategist(this, pid)
	}

	startSession(settings, data) {
		super.startSession(settings, data)

		this.iLapDatabase := false
	}

	checkStrategy(lap := false) {
		local strategyUpdate, strategyVersion, origin

		static lastLap := 0

		if (this.TeamSession && this.RaceStrategist) {
			if lap {
				if ((lap = 1) || (Abs(lap - lastLap) > 1))
					this.iLastStrategyVersion := false

				lastLap := lap
			}

			strategyVersion := this.TeamServer.getSessionValue("Race Strategy Update Version", false)

			if (strategyVersion && (strategyVersion != "") && (this.iLastStrategyVersion != strategyVersion)) {
				this.iLastStrategyVersion := strategyVersion

				strategyUpdate := this.TeamServer.getSessionValue("Race Strategy Update", false)

				if (strategyUpdate && (strategyUpdate != "")) {
					origin := this.TeamServer.getSessionValue("Race Strategy Update Origin", "Assistant")

					if (strategyUpdate = "CANCEL")
						this.RaceStrategist.updateStrategy(false, true
														 , origin != "Assistant", strategyVersion, origin, false)
					else {
						try {
							if FileExist(kTempDirectory . "Race Strategy.update")
								deleteFile(kTempDirectory . "Race Strategy.update")

							FileAppend(strategyUpdate, kTempDirectory . "Race Strategy.update")

							this.RaceStrategist.updateStrategy(kTempDirectory . "Race Strategy.update", true
															 , origin != "Assistant", strategyVersion, origin, false)
						}
						catch Any as exception {
							logError(exception)
						}
					}
				}
			}
		}
	}

	updateStrategy(strategy, version) {
		local teamServer := this.TeamServer
		local text

		if (teamServer && teamServer.SessionActive) {
			if strategy {
				text := FileRead(strategy)

				deleteFile(strategy)
			}
			else
				text := "CANCEL"

			teamServer.setSessionValue("Race Strategy Update", text)
			teamServer.setSessionValue("Race Strategy Update Version", version)
			teamServer.setSessionValue("Race Strategy Update Origin", "Assistant")

			teamServer.setSessionValue("Race Strategy", text)
			teamServer.setSessionValue("Race Strategy Version", version)

			this.iLastStrategyVersion := version
		}
		else
			deleteFile(strategy)
	}

	joinSession(settings, data) {
		if getMultiMapValue(settings, "Assistant.Strategist", "Join.Late", false)
			this.startSession(settings, data)
	}

	addLap(lap, running, data) {
		super.addLap(lap, running, data)

		this.checkStrategy(lap)
	}

	updateLap(lap, running, data) {
		super.updateLap(lap, running, data)

		this.checkStrategy()
	}

	requestInformation(arguments*) {
		if (this.RaceStrategist && inList(["Time", "LapsRemaining", "Weather", "Position", "LapTimes", "ActiveCars"
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

	recommendStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.recommendStrategy()
	}

	cancelStrategy() {
		if this.RaceStrategist
			this.RaceStrategist.cancelStrategy()
	}

	saveTelemetryData(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
					, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
					, compound, compoundColor, pressures, temperatures, wear) {
		local teamServer := this.TeamServer
		local pid

		if !wear
			wear := values2String(",", kNull, kNull, kNull, kNull)

		if (teamServer && teamServer.SessionActive)
			teamServer.setLapValue(lapNumber, this.Plugin . " Telemetry"
								 , values2String(";", simulator, car, track, weather, airTemperature, trackTemperature
												    , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
												    , compound, compoundColor, pressures, temperatures, wear, createGUID(), createGUID()))
		else {
			pid := ProcessExist("Practice Center")

			if pid
				messageSend(kFileMessage, "Practice", "addTelemetry:" . values2String(";", lapNumber, simulator, car, track, weather
																						 , airTemperature, trackTemperature
																						 , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
																						 , compound, compoundColor, pressures, temperatures, wear), pid)
			else
				this.LapDatabase.add("Telemetry", Database.Row("Lap", lapNumber, "Simulator", simulator, "Car", car, "Track", track
															 , "Weather", weather, "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
															 , "Fuel.Consumption", fuelConsumption, "Fuel.Remaining", fuelRemaining, "LapTime", lapTime
															 , "Pitstop", pitstop, "Map", map, "TC", tc, "ABS", abs
															 , "Compound", compound, "Compound.Color", compoundColor
															 , "Pressures", pressures, "Temperatures", temperatures, "Wear", wear))
		}
	}

	updateTelemetryDatabase() {
		local telemetryDB := false
		local teamServer := this.TeamServer
		local session := this.TeamSession
		local runningLap := 0
		local stint, newStint, lastStint, driverID, driverName, ignore, telemetryData, pitstop, pressures, temperatures, wear

		if (teamServer && teamServer.Active && session) {
			lastStint := false
			driverID := kNull

			loop teamServer.getCurrentLap(session) {
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
						telemetryDB := TelemetryDatabase(telemetryData[1], telemetryData[2], telemetryData[3])

					if (newStint && driverID) {
						driverName := teamServer.getStintDriverName(stint)

						if driverName
							telemetryDB.registerDriver(telemetryData[1], driverID, driverName)
					}

					pitstop := telemetryData[10]

					if ((runningLap > 2) && pitstop)
						runningLap := 0

					runningLap += 1

					if !pitstop {
						pressures := string2Values(",", telemetryData[16])
						temperatures := string2Values(",", telemetryData[17])
						wear := string2Values(",", telemetryData[18])

						try {
							telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
														 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8]
														 , telemetryData[9], driverID, telemetryData.Has(19) ? telemetryData[19] : false)

							telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15], runningLap
												   , pressures[1], pressures[2], pressures[4], pressures[4]
												   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
												   , wear[1], wear[2], wear[3], wear[4]
												   , telemetryData[7], telemetryData[8], telemetryData[9], driverID
												   , telemetryData.Has(20) ? telemetryData[20] : false)
						}
						catch Any as exception {
							logError(exception)
						}
					}
				}
				catch Any as exception {
					break
				}
			}
		}
		else
			for ignore, telemetryData in this.LapDatabase.Tables["Telemetry"] {
				if !telemetryDB
					telemetryDB := TelemetryDatabase(telemetryData["Simulator"], telemetryData["Car"], telemetryData["Track"])

				if telemetryData["Pitstop"]
					runningLap := 0

				runningLap += 1

				try {
					telemetryDB.addElectronicEntry(telemetryData["Weather"], telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
												 , telemetryData["Compound"], telemetryData["Compound.Color"]
												 , telemetryData["Map"], telemetryData["TC"], telemetryData["ABS"]
												 , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData["LapTime"])

					pressures := string2Values(",", telemetryData["Pressures"])
					temperatures := string2Values(",", telemetryData["Temperatures"])
					wear := string2Values(",", telemetryData["Wear"])

					telemetryDB.addTyreEntry(telemetryData["Weather"], telemetryData["Temperature.Air"], telemetryData["Temperature.Track"]
										   , telemetryData["Compound"], telemetryData["Compound.Color"], runningLap
										   , pressures[1], pressures[2], pressures[4], pressures[4]
										   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
										   , wear[1], wear[2], wear[3], wear[4]
										   , telemetryData["Fuel.Consumption"], telemetryData["Fuel.Remaining"], telemetryData["LapTime"])
				}
				catch Any as exception {
					logError(exception)
				}
			}
	}

	setLapValue(lapNumber, name, fileName) {
		local teamServer := this.TeamServer
		local currentEncoding, lapData

		if (teamServer && teamServer.SessionActive) {
			currentEncoding := A_FileEncoding

			try {
				FileEncoding("UTF-16")

				lapData := FileRead(fileName)
			}
			finally {
				FileEncoding(currentEncoding)
			}

			teamServer.setLapValue(lapNumber, name, lapData)

			deleteFile(fileName)
		}
	}

	saveStandingsData(lapNumber, fileName) {
		local teamServer := this.TeamServer
		local pid

		if (teamServer && teamServer.SessionActive) {
			this.setLapValue(lapNumber, this.Plugin . " Race Standings", fileName)

			deleteFile(fileName)
		}
		else {
			pid := ProcessExist("Practice Center")

			if pid
				messageSend(kFileMessage, "Practice", "updateStandings:" . values2String(";", lapNumber, fileName), pid)
			else
				deleteFile(fileName)
		}
	}

	saveRaceLap(lapNumber, fileName) {
		local teamServer := this.TeamServer
		local pid

		if (teamServer && teamServer.SessionActive) {
			this.setLapValue(lapNumber, this.Plugin . " Race Lap", fileName)

			deleteFile(fileName)
		}
		else {
			pid := ProcessExist("Practice Center")

			if pid
				messageSend(kFileMessage, "Practice", "addLap:" . values2String(";", lapNumber, fileName), pid)
			else {
				DirCreate(kTempDirectory . "Race Report")

				FileMove(fileName, kTempDirectory . "Race Report\Lap." lapNumber, 1)

				loop {
					lapNumber += 1

					if FileExist(kTempDirectory . "Race Report\Lap." . lapNumber)
						deleteFile(kTempDirectory . "Race Report\Lap." . lapNumber)
					else
						break
				}
			}
		}
	}

	saveRaceInfo(lapNumber, fileName) {
		local teamServer := this.TeamServer
		local pid

		if (teamServer && teamServer.SessionActive) {
			this.setLapValue(lapNumber, this.Plugin . " Race Info", fileName)

			deleteFile(fileName)
		}
		else {
			pid := ProcessExist("Practice Center")

			if pid
				messageSend(kFileMessage, "Practice", "startSession:" . values2String(";", lapNumber, fileName), pid)
			else {
				deleteDirectory(kTempDirectory . "Race Report")

				DirCreate(kTempDirectory . "Race Report")

				FileMove(fileName, kTempDirectory . "Race Report\Race.data")
			}
		}
	}

	restoreRaceInfo(data) {
		local teamServer := this.TeamServer
		local raceInfo, fileName

		if (teamServer && teamServer.Active) {
			try {
				raceInfo := teamServer.getLapValue(1, this.Plugin . " Race Info", this.TeamSession)

				if (!raceInfo || (raceInfo == ""))
					return

				fileName := temporaryFileName(this.Plugin . " Race", "info")

				FileAppend(raceInfo, fileName)

				this.RaceStrategist.restoreRaceInfo(fileName)
			}
			catch Any as exception {
				return
			}
		}
	}

	restoreSessionState(data) {
		local teamServer := this.TeamServer

		if (this.RaceStrategist && teamServer && teamServer.Active)
			this.restoreRaceInfo(data)

		super.restoreSessionState(data)
	}

	createRaceReport(targetDirectory := false) {
		local reportsDirectory := getMultiMapValue(this.Configuration, "Race Strategist Reports", "Database", false)
		local teamServer, session, runningLap, raceInfo, count, pitstops, lapData, data, key, value
		local times, positions, laps, drivers, newLine, line, fileName, directory
		local simulatorCode, carCode, trackCode

		if (targetDirectory || reportsDirectory) {
			teamServer := this.TeamServer
			session := this.TeamSession

			runningLap := 0

			if (teamServer && session) {
				deleteDirectory(kTempDirectory . "Race Report")

				DirCreate(kTempDirectory . "Race Report")

				try {
					raceInfo := teamServer.getLapValue(1, this.Plugin . " Race Info", session)

					if (!raceInfo || (raceInfo == ""))
						return

					FileAppend(raceInfo, kTempDirectory . "Race Report\Race.data")

					data := readMultiMap(kTempDirectory . "Race Report\Race.data")
				}
				catch Any as exception {
					data := newMultiMap()
				}

				count := 0
				pitstops := false

				loop teamServer.getCurrentLap(session) {
					try {
						lapData := teamServer.getLapValue(A_Index, this.Plugin . " Race Lap", session)

						if (lapData && (lapData != "")) {
							lapData := parseMultiMap(lapData)

							count += 1

							for key, value in getMultiMapValues(lapData, "Lap")
								setMultiMapValue(data, "Laps", key, value)

							pitstops := getMultiMapValue(lapData, "Pitstop", "Laps", "")

							times := getMultiMapValue(lapData, "Times", A_Index)
							positions := getMultiMapValue(lapData, "Positions", A_Index)
							laps := getMultiMapValue(lapData, "Laps", A_Index)
							drivers := getMultiMapValue(lapData, "Drivers", A_Index)

							newLine := ((count > 1) ? "`n" : "")

							line := (newLine . times)

							FileAppend(line, kTempDirectory . "Race Report\Times.CSV")

							line := (newLine . positions)

							FileAppend(line, kTempDirectory . "Race Report\Positions.CSV")

							line := (newLine . laps)

							FileAppend(line, kTempDirectory . "Race Report\Laps.CSV")

							line := (newLine . drivers)
							directory := (kTempDirectory . "Race Report\Drivers.CSV")

							FileAppend(line, directory, "UTF-16")
						}
					}
					catch Any as exception {
						break
					}
				}

				removeMultiMapValue(data, "Laps", "Lap")
				setMultiMapValue(data, "Laps", "Count", count)

				setMultiMapValue(data, "Laps", "Pitstops", pitstops)

				writeMultiMap(kTempDirectory . "Race Report\Race.data", data)

				if !targetDirectory {
					simulatorCode := SessionDatabase.getSimulatorCode(getMultiMapValue(data, "Session", "Simulator"))
					carCode := SessionDatabase.getCarCode(simulatorCode, getMultiMapValue(data, "Session", "Car"))
					trackCode := SessionDatabase.getTrackCode(simulatorCode, getMultiMapValue(data, "Session", "Track"))

					targetDirectory := (reportsDirectory . "\" . simulatorCode . "\" . carCode . "\" . trackCode . "\" . getMultiMapValue(data, "Session", "Time"))
				}

				DirCopy(kTempDirectory . "Race Report", targetDirectory, 1)
			}
			else {
				data := readMultiMap(kTempDirectory . "Race Report\Race.data")

				count := 0
				pitstops := false

				try {
					if FileExist(kTempDirectory . "Race Report\Output")
						deleteDirectory(kTempDirectory . "Race Report\Output")

					DirCreate(kTempDirectory . "Race Report\Output")
				}
				catch Any as exception {
					logError(exception)
				}

				loop {
					fileName := (kTempDirectory . "Race Report\Lap." . A_Index)

					if !FileExist(fileName)
						break
					else {
						lapData := readMultiMap(fileName)

						count += 1

						for key, value in getMultiMapValues(lapData, "Lap")
							setMultiMapValue(data, "Laps", key, value)

						pitstops := getMultiMapValue(lapData, "Pitstop", "Laps", "")

						times := getMultiMapValue(lapData, "Times", A_Index)
						positions := getMultiMapValue(lapData, "Positions", A_Index)
						laps := getMultiMapValue(lapData, "Laps", A_Index)
						drivers := getMultiMapValue(lapData, "Drivers", A_Index)

						newLine := ((count > 1) ? "`n" : "")

						line := (newLine . times)

						FileAppend(line, kTempDirectory . "Race Report\Output\Times.CSV")

						line := (newLine . positions)

						FileAppend(line, kTempDirectory . "Race Report\Output\Positions.CSV")

						line := (newLine . laps)

						FileAppend(line, kTempDirectory . "Race Report\Output\Laps.CSV")

						line := (newLine . drivers)
						fileName := (kTempDirectory . "Race Report\Output\Drivers.CSV")

						FileAppend(line, fileName, "UTF-16")
					}
				}

				removeMultiMapValue(data, "Laps", "Lap")
				setMultiMapValue(data, "Laps", "Count", count)

				setMultiMapValue(data, "Laps", "Pitstops", pitstops)

				writeMultiMap(kTempDirectory . "Race Report\Output\Race.data", data)

				if !targetDirectory {
					simulatorCode := SessionDatabase.getSimulatorCode(getMultiMapValue(data, "Session", "Simulator"))
					carCode := SessionDatabase.getCarCode(simulatorCode, getMultiMapValue(data, "Session", "Car"))
					trackCode := SessionDatabase.getTrackCode(simulatorCode, getMultiMapValue(data, "Session", "Track"))

					targetDirectory := (reportsDirectory . "\" . simulatorCode . "\" . carCode . "\" . trackCode . "\" . getMultiMapValue(data, "Session", "Time"))
				}

				DirCopy(kTempDirectory . "Race Report\Output", targetDirectory, 1)
			}
		}
	}

	reviewRace(categories) {
		local multiClass := false
		local report, reader, raceData, drivers, positions, times, cars, driver, laps, position
		local class, classCars, classPositions
		local leader, car, candidate, min, max, leaderAvgLapTime, stdDev
		local driverMinLapTime, driverMaxLapTime, driverAvgLapTime, driverLapTimeStdDev

		categories := string2Values("|", categories)
		report := temporaryFileName(this.Plugin . " Race", "report")

		this.createRaceReport(report)

		comparePositions(c1, c2) {
			local pos1 := c1[2]
			local pos2 := c2[2]

			if !isNumber(pos1)
				pos1 := 999

			if !isNumber(pos2)
				pos2 := 999

			return (pos1 > pos2)
		}

		try {
			try {
				reader := RaceReportReader(report)

				raceData := true
				drivers := true
				positions := true
				times := true

				reader.loadData(false, &raceData, &drivers, &positions, &times)

				cars := getMultiMapValue(raceData, "Cars", "Count", 0)
				driver := getMultiMapValue(raceData, "Cars", "Driver", 0)
				laps := getMultiMapValue(raceData, "Laps", "Count", 0)

				if (reader.getClasses(raceData, categories).Length > 1) {
					class := reader.getClass(raceData, driver, categories)

					if class {
						classCars := 0
						classPositions := []

						loop cars
							if (reader.getClass(raceData, A_Index, categories) = class) {
								classCars += 1

								if laps
									position := (positions[laps].Has(A_Index) ? positions[laps][A_Index] : cars)
								else
									position := cars

								classPositions.Push(Array(A_Index, position))
							}

						bubbleSort(&classPositions, comparePositions)

						for car, candidate in classPositions {
							if (car = 1)
								leader := candidate[1]

							if (candidate[1] = driver) {
								position := car

								break
							}
						}

						if (position = cars)
							position := classCars

						cars := classCars
						multiClass := true
					}
				}

				if !multiClass {
					if laps
						position := (positions[laps].Has(driver) ? positions[laps][driver] : cars)
					else
						position := cars

					leader := 0

					for car, candidate in positions[laps]
						if (candidate = 1) {
							leader := car

							break
						}
				}

				min := false
				max := false
				leaderAvgLapTime := false
				stdDev := false

				reader.getDriverPace(raceData, times, leader, &min, &max, &leaderAvgLapTime, &stdDev)

				driverMinLapTime := false
				driverMaxLapTime := false
				driverAvgLapTime := false
				driverLapTimeStdDev := false

				reader.getDriverPace(raceData, times, driver, &driverMinLapTime, &driverMaxLapTime, &driverAvgLapTime, &driverLapTimeStdDev)

				this.RaceAssistant["Ghost"].reviewRace(multiclass, cars, laps, position, leaderAvgLapTime
													 , driverAvgLapTime, driverMinLapTime, driverMaxLapTime, driverLapTimeStdDev)
			}
			catch Any as exception {
				logError(exception)

				this.RaceAssistant["Ghost"].reviewRace(false, 0, 0, 0, 0, 0, 0, 0, 0)
			}
		}
		finally {
			deleteDirectory(report)
		}
	}

	computeCarStatistics(startLap, endLap) {
		local raceData := true
		local drivers := false
		local positions := true
		local times := true
		local laps := [startLap]
		local cars := []
		local statistics := newMultiMap()
		local potentials, raceCrafts, speeds, consistencies, carControls
		local car, lapTime, count, report, fileName

		report := temporaryFileName(this.Plugin . " Race", "report")

		this.createRaceReport(report)

		try {
			try {
				reader := RaceReportReader(report)

				loop (endLap - startLap)
					laps.Push(startLap + A_Index)

				reader.loadData(laps, &raceData, &drivers, &positions, &times)

				loop getMultiMapValue(raceData, "Cars", "Count")
					cars.Push(A_Index)

				reader.getDriverStatistics(raceData, cars, positions, times, &potentials, &raceCrafts, &speeds, &consistencies, &carControls)

				loop getMultiMapValue(raceData, "Cars", "Count") {
					car := A_Index
					lapTime := 0
					count := 0

					loop laps.Length
						if times[A_Index].Has(car) {
							lapTime += times[A_Index][car]
							count += 1
						}

					if (count > 0)
						lapTime := ((lapTime / count) / 1000)

					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".LapTime", lapTime)
					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Potential", Round(potentials[car], 2))
					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".RaceCraft", Round(raceCrafts[car], 2))
					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Speed", Round(speeds[car], 2))
					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".Consistency", Round(consistencies[car], 2))
					setMultiMapValue(statistics, "Statistics", "Car." . A_Index . ".CarControl", Round(carControls[car], 2))
				}

				setMultiMapValue(statistics, "Statistics", "Car.Count", getMultiMapValue(raceData, "Cars", "Count"))

				fileName := temporaryFileName(this.Plugin . " Race", "statistics")

				writeMultiMap(fileName, statistics)

				this.RaceAssistant["Ghost"].updateCarStatistics(fileName)
			}
			catch Any as exception {
				logError(exception)

				this.RaceAssistant["Ghost"].updateCarStatistics(false)
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

	RaceStrategistPlugin(controller, kRaceStrategistPlugin, controller.Configuration)
}

;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistPlugin()