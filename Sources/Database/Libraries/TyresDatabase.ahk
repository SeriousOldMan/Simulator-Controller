﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tyres Database                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Database.ahk"
#Include "SessionDatabase.ahk"
#Include "SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTyresSchemas := CaseInsenseMap("Tyres.Pressures", ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
														 , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
														 , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
														 , "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
														 , "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right", "Driver"
														 , "Identifier", "Synchronized"]
									 , "Tyres.Pressures.Distribution", ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
																	  , "Type", "Tyre", "Pressure", "Count", "Driver"
																	  , "Identifier", "Synchronized"])


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTemperatureDeltas := [0, 1, -1, 2, -2]
global kMaxTemperatureDelta := 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TyresDatabase extends SessionDatabase {
	iDatabaseDirectory := this.DatabasePath

	iLastSimulator := false
	iLastCar := false
	iLastTrack := false
	iLastScope := false

	iDatabase := false
	iShared := true

	DatabaseDirectory {
		Get {
			return this.iDatabaseDirectory
		}

		Set {
			return (this.iDatabaseDirectory := value)
		}
	}

	Database {
		Get {
			return this.iDatabase
		}
	}

	Shared {
		Get {
			return this.iShared
		}

		Set {
			return (this.iShared := value)
		}
	}

	getTyresDatabase(simulator, car, track, scope := "User") {
		local directory

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if (simulator && car && track) {
			directory := (this.DatabaseDirectory . scope . "\" . this.getSimulatorCode(simulator) . "\" . car . "\" . track)

			DirCreate(directory)

			return Database(directory . "\", kTyresSchemas)
		}
		else
			return false
	}

	requireDatabase(simulator, car, track, scope := "User") {
		simulator := this.getSimulatorName(simulator)
		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if (!simulator || !car || !track || (simulator == true) || (car == true) || (track == true))
			throw "Unsupported database specification detected in TyresDatabase.requireDatabase..."

		if (this.iDatabase && ((this.iLastSimulator != simulator) || (this.iLastCar != car)
							|| (this.iLastTrack != track) || (this.iLastScope != scope))) {
			if this.Shared
				this.unlock()
			else
				this.flush()

			this.iDatabase := false
		}

		if !this.iDatabase {
			this.iLastSimulator := simulator
			this.iLastCar := car
			this.iLastTrack := track
			this.iLastScope := scope

			this.iDatabase := this.getTyresDatabase(simulator, car, track, scope)
		}

		return this.iDatabase
	}

	getPressureDistributions(database, weather, airTemperature, trackTemperature, compound, compoundColor
						   , distributions, driver := kUndefined) {
		local where := Map("Temperature.Air", Round(airTemperature), "Temperature.Track", Round(trackTemperature)
						 , "Compound", compound, "Compound.Color", compoundColor, "Type", "Cold")
		local ignore, pressureData, tyre, pressure

		if ((driver != kUndefined) && driver)
			where["Driver"] := driver

		if (weather != true)
			where["Weather"] := weather

		for ignore, pressureData in database.query("Tyres.Pressures.Distribution", {Where: where}) {
			tyre := pressureData["Tyre"]
			pressure := pressureData["Pressure"]

			if distributions[tyre].Has(pressure)
				distributions[tyre][pressure] += pressureData["Count"]
			else
				distributions[tyre][pressure] := pressureData["Count"]
		}
	}

	getConditions(simulator, car, track, driver := kUndefined) {
		local database, condition, compound, where, path, conditions, ignore, condition, result

		car := this.getCarCode(simulator, car)
		track := this.getCarCode(simulator, track)

		if ((driver = kUndefined) || !driver)
			where := {Type: "Cold"}
		else {
			if (driver == true)
				driver := this.ID

			where := {Driver: driver, Type: "Cold"}
		}

		path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\")

		conditions := CaseInsenseMap()

		database := this.requireDatabase(simulator, car, track)

		for ignore, condition in database.query("Tyres.Pressures.Distribution"
											  , {By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]
											   , Where: where})
			conditions[values2String("|", condition["Weather"], condition["Temperature.Air"], condition["Temperature.Track"]
										, condition["Compound"], condition["Compound.Color"])] := true

		if this.UseCommunity {
			database := this.getTyresDatabase(simulator, car, track, "Community")

			for ignore, condition in database.query("Tyres.Pressures.Distribution"
												  , {By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
				conditions[values2String("|", condition["Weather"], condition["Temperature.Air"], condition["Temperature.Track"]
										    , condition["Compound"], condition["Compound.Color"])] := true
		}

		result := []

		for condition, ignore in conditions
			result.Push(string2Values("|", condition))

		return result
	}

	getTyreSetup(simulator, car, track, weather, airTemperature, trackTemperature
			   , &compound, &compoundColor, &pressures, &certainty, driver := kUndefined) {
		local condition, weatherIndex, visited, compounds, theCompound, conditionIndex, valid
		local settings, correctionAir, correctionTrack, thePressures, theCertainty, compoundInfo
		local theCompound, theCompoundColor, ignore, pressureInfo, deltaAir, deltaTrack

		simulator := this.getSimulatorName(simulator)

		if !compound {
			weatherIndex := inList(kWeatherConditions, weather)
			visited := []
			compounds := []

			for ignore, condition in this.getConditions(simulator, car, track, driver) {
				theCompound := (condition[4] . "." . condition[5])

				conditionIndex := inList(kWeatherConditions, condition[1])

				valid := (weather == true)

				if !valid
					valid := (!inList(visited, theCompound) && ((Abs(weatherIndex - conditionIndex) <= 1) || ((weatherIndex >= 2) && (conditionIndex >= 2))))

				if valid {
					visited.Push(theCompound)

					compounds.Push(Array(condition[4], condition[5]))
				}
			}
		}
		else
			compounds := [Array(compound, compoundColor)]

		settings := SettingsDatabase().loadSettings(simulator, car, track, weather)

		correctionAir := getMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
		correctionTrack := getMultiMapValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

		thePressures := []
		theCertainty := 1.0

		for ignore, compoundInfo in compounds {
			theCompound := compoundInfo[1]
			theCompoundColor := compoundInfo[2]

			for ignore, pressureInfo in this.getPressures(simulator, car, track, weather, Round(airTemperature), Round(trackTemperature)
														, theCompound, theCompoundColor, (driver = kUndefined) ? false : driver) {
				deltaAir := pressureInfo["Delta Air"]
				deltaTrack := pressureInfo["Delta Track"]

				thePressures.Push(pressureInfo["Pressure"] + Round((deltaAir * (- correctionAir)) + (deltaTrack * (- correctionTrack)), 1))

				theCertainty := Min(theCertainty, 1.0 - (Abs(deltaAir + deltaTrack) / (kMaxTemperatureDelta + 1)))
			}

			if (thePressures.Length > 0) {
				compound := theCompound
				compoundColor := theCompoundColor
				certainty := theCertainty
				pressures := thePressures

				return true
			}
		}

		return false
	}

	getPressureInfo(simulator, car, track, weather, driver := kUndefined) {
		local database, where, info, ignore, row

		if ((driver = kUndefined) || !driver)
			where := {}
		else {
			if (driver == true)
				driver := this.ID

			where := {Driver: driver}
		}

		info := []

		database := this.requireDatabase(simulator, car, track)

		for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", count, "Count"]]
																		 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color", "Driver"]
																		 , Where: where})
			info.Push({Source: "User", Driver: row["Driver"]
					 , Weather: row["Weather"], AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
					 , Compound: compound(row["Compound"], row["Compound.Color"]), Count: row["Count"]})

		if this.UseCommunity {
			database := this.getTyresDatabase(simulator, car, track, "Community")

			for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", count, "Count"]]
																			 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
				info.Push({Source: "Community", Driver: false
						 , Weather: row["Weather"], AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
						 , Compound: compound(row["Compound"], row["Compound.Color"]), Count: row["Count"]})
		}

		return info
	}

	getPressures(simulator, car, track, weather, airTemperature, trackTemperature
			   , compound, compoundColor, driver := false) {
		local weatherBaseIndex, weatherCandidateOffsets, localTyresDatabase, globalTyresDatabase
		local ignore, weatherOffset, airDelta, trackDelta, distributions, thePressures, index, tyre
		local bestPressure, bestCount, pressure, pressureCount, tyrePressures, key

		if !driver
			driver := [this.ID]
		else if (driver == true)
			driver := []

		if (weather != true) {
			weatherBaseIndex := inList(kWeatherConditions, weather)

			if (weatherBaseIndex == 1)
				weatherCandidateOffsets := [0, 1]
			if (weatherBaseIndex == 2)
				weatherCandidateOffsets := [0, -1]
			else
				weatherCandidateOffsets := [0, 1, 2, 3]
		}
		else {
			weatherBaseIndex := 1

			weatherCandidateOffsets := [0, 1, 2, 3, 4, 5]
		}

		localTyresDatabase := this.requireDatabase(simulator, car, track)
		globalTyresDatabase := (this.UseCommunity ? this.getTyresDatabase(simulator, car, track, "Community") : false)

		for ignore, weatherOffset in weatherCandidateOffsets {
			weather := kWeatherConditions[Max(0, Min(weatherBaseIndex + weatherOffset, kWeatherConditions.Length))]

			for ignore, airDelta in kTemperatureDeltas {
				for ignore, trackDelta in kTemperatureDeltas {
					distributions := CaseInsenseMap()

					for index, tyre in ["FL", "FR", "RL", "RR"]
						distributions[tyre] := CaseInsenseMap()

					this.getPressureDistributions(localTyresDatabase, weather, Round(airTemperature) + airDelta, Round(trackTemperature) + trackDelta
											    , compound, compoundColor, distributions, driver*)

					if this.UseCommunity
						this.getPressureDistributions(globalTyresDatabase, weather, Round(airTemperature) + airDelta, Round(trackTemperature) + trackDelta
													, compound, compoundColor, distributions, false)

					if (distributions["FL"].Count != 0) {
						thePressures := CaseInsenseMap()

						for index, tyre in ["FL", "FR", "RL", "RR"] {
							thePressures[tyre] := CaseInsenseMap()

							tyrePressures := distributions[tyre]

							bestPressure := false
							bestCount := 0

							for pressure, pressureCount in tyrePressures {
								if (pressureCount > bestCount) {
									bestCount := pressureCount
									bestPressure := pressure
								}
							}

							thePressures[tyre]["Pressure"] := bestPressure
							thePressures[tyre]["Delta Air"] := airDelta
							thePressures[tyre]["Delta Track"] := trackDelta
						}

						return thePressures
					}
				}
			}
		}

		return Map()
	}

	lock(simulator, car, track, wait := true) {
		local database := this.requireDatabase(simulator, car, track)

		if wait {
			database.lock("Tyres.Pressures")
			database.lock("Tyres.Pressures.Distribution")
		}
		else {
			if database.lock("Tyres.Pressures", false)
				if !database.lock("Tyres.Pressures.Distribution", false) {
					database.unlock("Tyres.Pressures")

					return false
				}
		}

		return database
	}

	unlock() {
		db := this.Database

		if db {
			try {
				this.Database.unlock("Tyres.Pressures")
			}
			catch Any as exception {
				logError(exception)
			}

			try {
				this.Database.unlock("Tyres.Pressures.Distribution")
			}
			catch Any as exception {
				logError(exception)
			}
		}
	}

	updatePressures(simulator, car, track, weather, airTemperature, trackTemperature
				  , compound, compoundColor, coldPressures, hotPressures, flush := true, driver := false, retry := 100) {
		local db, tyres, types, typeIndex, tPressures, tyreIndex, pressure, compounds, compoundColors

		if !driver
			driver := this.ID

		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"

		db := ((this.Shared && flush) ? this.lock(simulator, car, track) : this.requireDatabase(simulator, car, track))

		try {
			db.add("Tyres.Pressures", Database.Row("Driver", driver, "Weather", weather
												 , "Temperature.Air", Round(airTemperature), "Temperature.Track", Round(trackTemperature)
												 , "Compound", compound, "Compound.Color", compoundColor
												 , "Tyre.Pressure.Cold.Front.Left", valueOrNull(coldPressures[1])
												 , "Tyre.Pressure.Cold.Front.Right", valueOrNull(coldPressures[2])
												 , "Tyre.Pressure.Cold.Rear.Left", valueOrNull(coldPressures[3])
												 , "Tyre.Pressure.Cold.Rear.Right", valueOrNull(coldPressures[4])
												 , "Tyre.Pressure.Hot.Front.Left", valueOrNull(hotPressures[1])
												 , "Tyre.Pressure.Hot.Front.Right", valueOrNull(hotPressures[2])
												 , "Tyre.Pressure.Hot.Rear.Left", valueOrNull(hotPressures[3])
												 , "Tyre.Pressure.Hot.Rear.Right", valueOrNull(hotPressures[4]))
									, flush, retry)

			tyres := ["FL", "FR", "RL", "RR"]
			types := ["Cold", "Hot"]

			if InStr(compound, ",") {
				compounds := string2Values(",", compound)
				compoundColors := string2Values(",", compoundColor)

				if (compounds.Length = 2) {
					compounds.InsertAt(1, compounds[1])
					compoundColors.InsertAt(1, compoundColors[1])
					compounds.Push(compounds[3])
					compoundColors.Push(compoundColors[3])
				}

				for typeIndex, tPressures in [coldPressures, hotPressures]
					for tyreIndex, pressure in tPressures
						this.updatePressure(simulator, car, track, weather, Round(airTemperature), Round(trackTemperature)
										  , compounds[tyreIndex], compoundColors[tyreIndex]
										  , types[typeIndex], tyres[tyreIndex], pressure, 1, false, false, "User", driver, retry)
			}
			else
				for typeIndex, tPressures in [coldPressures, hotPressures]
					for tyreIndex, pressure in tPressures
						this.updatePressure(simulator, car, track, weather, Round(airTemperature), Round(trackTemperature), compound, compoundColor
										  , types[typeIndex], tyres[tyreIndex], pressure, 1, false, false, "User", driver, retry)
		}
		catch Any as exception {
			if retry
				logError(exception, true)
			else
				throw exception
		}
		finally {
			if flush
				if this.Shared
					this.unlock()
				else
					this.flush()
		}
	}

	updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
				 , type, tyre, pressure, count := 1, flush := true, require := true, scope := "User", driver := false, retry := 100) {
		local db, rows, row

		if (isNull(valueOrNull(pressure)))
			return

		if !driver
			driver := this.ID

		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"

		if require
			db := ((this.Shared && flush && (scope = "User")) ? this.lock(simulator, car, track)
															  : this.requireDatabase(simulator, car, track, scope))
		else
			db := this.iDatabase

		pressure := Round(pressure, 1)

		rows := db.query("Tyres.Pressures.Distribution"
					   , {Where: Map("Driver", driver, "Weather", weather
								   , "Temperature.Air", Round(airTemperature), "Temperature.Track", Round(trackTemperature)
								   , "Compound", compound, "Compound.Color", compoundColor
								   , "Type", type, "Tyre", tyre, "Pressure", pressure)})

		if (rows.Length > 0) {
			row := rows[1]

			row["Count"] := row["Count"] + count
			row["Synchronized"] := kNull

			if flush {
				if (this.Shared && (scope = "User"))
					this.unlock()
				else
					this.flush()
			}
			else
				db.changed("Tyres.Pressures.Distribution")
		}
		else
			try {
				db.add("Tyres.Pressures.Distribution"
					 , Database.Row("Driver", driver, "Weather", weather
								  , "Temperature.Air", Round(airTemperature), "Temperature.Track", Round(trackTemperature)
								  , "Compound", compound, "Compound.Color", compoundColor
								  , "Type", type, "Tyre", tyre, "Pressure", pressure, "Count", count)
					 , false, retry)
			}
			catch Any as exception {
				if retry
					logError(exception, true)
				else
					throw exception
			}
	}

	flush() {
		if this.Database {
			this.Database.flush()

			this.iDatabase := false
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

synchronizeTyresPressures(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local lastSimulator := false
	local lastCar := false
	local lastTrack := false
	local ignore, simulator, car, track, db, modified, identifier, pressures, oldPressures, properties, count, pressuresLocked, wasNull

	if inList(groups, "Pressures")
		try {
			for ignore, identifier in string2Values(";", connector.QueryData("TyresPressures", "Modified > " . lastSynchronization)) {
				pressures := parseData(connector.GetData("TyresPressures", identifier))

				simulator := pressures["Simulator"]

				if inList(simulators, sessionDB.getSimulatorName(simulator)) {
					car := pressures["Car"]
					track := pressures["Track"]

					if ((simulator != lastSimulator) || (car != lastCar) || (track != lastTrack)) {
						db := Database(kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track, kTyresSchemas)

						lastSimulator := simulator
						lastCar := car
						lastTrack := track
					}

					if (db.query("Tyres.Pressures", {Where: {Identifier: identifier} }).Length = 0) {
						counter += 1

						try {
							db.add("Tyres.Pressures", Database.Row("Identifier", identifier, "Synchronized", timestamp
																 , "Driver", pressures["Driver"], "Weather", pressures["Weather"]
																 , "Temperature.Air", pressures["AirTemperature"]
																 , "Temperature.Track", pressures["TrackTemperature"]
																 , "Compound", pressures["TyreCompound"]
																 , "Compound.Color", pressures["TyreCompoundColor"]
																 , "Tyre.Pressure.Cold.Front.Left", pressures["ColdPressureFrontLeft"]
																 , "Tyre.Pressure.Cold.Front.Right", pressures["ColdPressureFrontRight"]
																 , "Tyre.Pressure.Cold.Rear.Left", pressures["ColdPressureRearLeft"]
																 , "Tyre.Pressure.Cold.Rear.Right", pressures["ColdPressureRearRight"]
																 , "Tyre.Pressure.Hot.Front.Left", pressures["HotPressureFrontLeft"]
																 , "Tyre.Pressure.Hot.Front.Right", pressures["HotPressureFrontRight"]
																 , "Tyre.Pressure.Hot.Rear.Left", pressures["HotPressureRearLeft"]
																 , "Tyre.Pressure.Hot.Rear.Right", pressures["HotPressureRearRight"])
													, true)
						}
						catch Any as exception {
							logError(exception)
						}
					}
				}
			}

			pressuresLocked := false

			try {
				for ignore, identifier in string2Values(";", connector.QueryData("TyresPressuresDistribution", "Modified > " . lastSynchronization)) {
					pressures := parseData(connector.GetData("TyresPressuresDistribution", identifier))

					simulator := pressures["Simulator"]

					if inList(simulators, sessionDB.getSimulatorName(simulator)) {
						car := pressures["Car"]
						track := pressures["Track"]

						count := pressures["Count"]

						if ((simulator != lastSimulator) || (car != lastCar) || (track != lastTrack)) {
							if pressuresLocked {
								db.flush("Tyres.Pressures.Distribution")

								db.unlock("Tyres.Pressures.Distribution")

								pressuresLocked := false
							}

							db := Database(kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track, kTyresSchemas)

							lastSimulator := simulator
							lastCar := car
							lastTrack := track
						}

						oldPressures := db.query("Tyres.Pressures.Distribution", {Where: {Identifier: identifier} })

						if (oldPressures.Length = 0) {
							try {
								db.add("Tyres.Pressures.Distribution", Database.Row("Identifier", pressures["Identifier"], "Synchronized", timestamp
																				  , "Driver", pressures["Driver"], "Weather", pressures["Weather"]
																				  , "Temperature.Air", pressures["AirTemperature"], "Temperature.Track", pressures["TrackTemperature"]
																				  , "Compound", pressures["TyreCompound"], "Compound.Color", pressures["TyreCompoundColor"]
																				  , "Type", pressures["Type"], "Tyre", pressures["Tyre"], "Pressure", pressures["Pressure"], "Count", count)
																	 , true)
								counter += 1
							}
							catch Any as exception {
								logError(exception)
							}
						}
						else if (oldPressures[1]["Count"] != count) {
							if !pressuresLocked
								if db.lock("Tyres.Pressures.Distribution", false)
									pressuresLocked := true

							if pressuresLocked {
								counter += 1

								db.changed("Tyres.Pressures.Distribution")

								oldPressures[1]["Count"] := Max(oldPressures[1]["Count"], count)
							}
						}
					}
				}
			}
			finally {
				if pressuresLocked {
					db.flush("Tyres.Pressures.Distribution")

					db.unlock("Tyres.Pressures.Distribution")
				}
			}

			for ignore, simulator in simulators {
				simulator := sessionDB.getSimulatorCode(simulator)

				for ignore, car in sessionDB.getCars(simulator)
					for ignore, track in sessionDB.getTracks(simulator, car) {
						db := Database(kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track, kTyresSchemas)

						if db.lock("Tyres.Pressures", false)
							try {
								modified := false

								for ignore, pressures in db.query("Tyres.Pressures", {Where: force ? {Driver: sessionDB.ID}
																								   : {Synchronized: kNull, Driver: sessionDB.ID} })
									try {
										if (pressures["Identifier"] = kNull) {
											pressures["Identifier"] := createGUID()

											wasNull := true
										}
										else
											wasNull := false

										if (connector.CountData("TyresPressures", "Identifier = '" . StrLower(pressures["Identifier"]) . "'") = 0) {
											connector.CreateData("TyresPressures"
															   , substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`n"
																				   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
																				   . "Weather=%Weather%`nAirTemperature=%AirTemperature%`n"
																				   . "TrackTemperature=%TrackTemperature%`n"
																				   . "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
																				   . "HotPressureFrontLeft=%HotPressureFrontLeft%`n"
																				   . "HotPressureFrontRight=%HotPressureFrontRight%`n"
																				   . "HotPressureRearLeft=%HotPressureRearLeft%`n"
																				   . "HotPressureRearRight=%HotPressureRearRight%`n"
																				   . "ColdPressureFrontLeft=%ColdPressureFrontLeft%`n"
																				   . "ColdPressureFrontRight=%ColdPressureFrontRight%`n"
																				   . "ColdPressureRearLeft=%ColdPressureRearLeft%`n"
																				   . "ColdPressureRearRight=%ColdPressureRearRight%"
																				   , {Identifier: StrLower(pressures["Identifier"]), Driver: pressures["Driver"]
																					, Simulator: simulator, Car: car, Track: track
																					, Weather: pressures["Weather"]
																					, AirTemperature: pressures["Temperature.Air"]
																					, TrackTemperature: pressures["Temperature.Track"]
																					, TyreCompound: pressures["Compound"], TyreCompoundColor: pressures["Compound.Color"]
																					, HotPressureFrontLeft: pressures["Tyre.Pressure.Hot.Front.Left"]
																					, HotPressureFrontRight: pressures["Tyre.Pressure.Hot.Front.Right"]
																					, HotPressureRearLeft: pressures["Tyre.Pressure.Hot.Rear.Left"]
																					, HotPressureRearRight: pressures["Tyre.Pressure.Hot.Rear.Right"]
																					, ColdPressureFrontLeft: pressures["Tyre.Pressure.Cold.Front.Left"]
																					, ColdPressureFrontRight: pressures["Tyre.Pressure.Cold.Front.Right"]
																					, ColdPressureRearLeft: pressures["Tyre.Pressure.Cold.Rear.Left"]
																					, ColdPressureRearRight: pressures["Tyre.Pressure.Cold.Rear.Right"]}))

											counter += 1
										}

										pressures["Synchronized"] := timestamp

										db.changed("Tyres.Pressures")
										modified := true
									}
									catch Any as exception {
										logError(exception)

										if wasNull
											pressures["Identifier"] := kNull
									}
							}
							finally {
								if modified
									db.flush("Tyres.Pressures")

								db.unlock("Tyres.Pressures")
							}

						if db.lock("Tyres.Pressures.Distribution", false)
							try {
								modified := false

								for ignore, pressures in db.query("Tyres.Pressures.Distribution", {Where: force ? {Driver: sessionDB.ID}
																												: {Synchronized: kNull, Driver: sessionDB.ID} })
									try {
										if (pressures["Identifier"] = kNull) {
											identifier := createGUID()

											pressures["Identifier"] := identifier

											wasNull := true
										}
										else {
											identifier := pressures["Identifier"]

											wasNull := false
										}

										properties := substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`nSimulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
																		. "Weather=%Weather%`nAirTemperature=%AirTemperature%`nTrackTemperature=%TrackTemperature%`n"
																		. "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
																		. "Type=%Type%`nTyre=%Tyre%`nPressure=%Pressure%`nCount=%Count%"
																		, {Identifier: StrLower(pressures["Identifier"]), Driver: pressures["Driver"]
																		 , Simulator: simulator, Car: car, Track: track
																		 , Weather: pressures["Weather"]
																		 , AirTemperature: pressures["Temperature.Air"], TrackTemperature: pressures["Temperature.Track"]
																		 , TyreCompound: pressures["Compound"], TyreCompoundColor: pressures["Compound.Color"]
																		 , Type: pressures["Type"], Tyre: pressures["Tyre"]
																		 , Pressure: pressures["Pressure"], Count: pressures["Count"]})

										if (connector.CountData("TyresPressuresDistribution", "Identifier = '" . StrLower(identifier) . "'") = 0)
											connector.CreateData("TyresPressuresDistribution", properties)
										else
											connector.UpdateData("TyresPressuresDistribution", identifier, properties)

										counter += 1

										pressures["Synchronized"] := timestamp

										db.changed("Tyres.Pressures.Distribution")
										modified := true
									}
									catch Any as exception {
										logError(exception)

										if wasNull
											pressures["Identifier"] := kNull
									}
							}
							finally {
								if modified
									db.flush("Tyres.Pressures.Distribution")

								db.unlock("Tyres.Pressures.Distribution")
							}
					}
			}
		}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

SessionDatabase.registerSynchronizer(synchronizeTyresPressures)