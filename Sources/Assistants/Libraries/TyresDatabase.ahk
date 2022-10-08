;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tyres Database                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Database.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTyresSchemas := {"Tyres.Pressures": ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
										   , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
										   , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
										   , "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
										   , "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right", "Driver"
										   , "Identifier", "Synchronized"]
					   , "Tyres.Pressures.Distribution": ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
														, "Type", "Tyre", "Pressure", "Count", "Driver"
														, "Identifier", "Synchronized"]}


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

	DatabaseDirectory[] {
		Get {
			return this.iDatabaseDirectory
		}

		Set {
			return (this.iDatabaseDirectory := value)
		}
	}

	getTyresDatabase(simulator, car, track, scope := "User") {
		local directory

		car := this.getCarCode(simulator, car)
		track := this.getCarCode(simulator, track)

		directory := (this.DatabaseDirectory . scope . "\" . this.getSimulatorCode(simulator) . "\" . car . "\" . track)

		FileCreateDir %directory%

		return new Database(directory . "\", kTyresSchemas)
	}

	requireDatabase(simulator, car, track, scope := "User") {
		simulator := this.getSimulatorName(simulator)
		car := this.getCarCode(simulator, car)
		track := this.getCarCode(simulator, track)

		if ((simulator == true) || (car == true) || (track == true))
			throw "Unsupported database specification detected in TyresDatabase.requireDatabase..."

		if (this.iDatabase && ((this.iLastSimulator != simulator) || (this.iLastCar != car)
							|| (this.iLastTrack != track) || (this.iLastScope != scope))) {
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
						   , ByRef distributions, driver := "__Undefined__") {
		local where := {"Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
					  , Compound: compound, "Compound.Color": compoundColor, Type: "Cold"}
		local ignore, pressureData, tyre, pressure

		if ((driver != kUndefined) && driver)
			where["Driver"] := driver

		if (weather != true)
			where["Weather"] := weather

		for ignore, pressureData in database.query("Tyres.Pressures.Distribution", {Where: where}) {
			tyre := pressureData.Tyre
			pressure := pressureData.Pressure

			if distributions[tyre].HasKey(pressure)
				distributions[tyre][pressure] += pressureData.Count
			else
				distributions[tyre][pressure] := pressureData.Count
		}
	}

	getConditions(simulator, car, track, driver := "__Undefined__") {
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

		conditions := {}

		database := this.requireDatabase(simulator, car, track)

		for ignore, condition in database.query("Tyres.Pressures.Distribution"
											  , {By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]
											   , Where: where})
			conditions[values2String("|", condition.Weather, condition["Temperature.Air"], condition["Temperature.Track"]
										, condition.Compound, condition["Compound.Color"])] := true

		if this.UseCommunity {
			database := this.getTyresDatabase(simulator, car, track, "Community")

			for ignore, condition in database.query("Tyres.Pressures", {Group: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]
																	  , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
				conditions[values2String("|", condition*)] := true
		}

		result := []

		for condition, ignore in conditions
			result.Push(string2Values("|", condition))

		return result
	}

	getTyreSetup(simulator, car, track, weather, airTemperature, trackTemperature
			   , ByRef compound, ByRef compoundColor, ByRef pressures, ByRef certainty, driver := "__Undefined__") {
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

		settings := new SettingsDatabase().loadSettings(simulator, car, track, weather)

		correctionAir := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
		correctionTrack := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

		thePressures := []
		theCertainty := 1.0

		for ignore, compoundInfo in compounds {
			theCompound := compoundInfo[1]
			theCompoundColor := compoundInfo[2]

			for ignore, pressureInfo in this.getPressures(simulator, car, track, weather, airTemperature, trackTemperature
														, theCompound, theCompoundColor, driver) {
				deltaAir := pressureInfo["Delta Air"]
				deltaTrack := pressureInfo["Delta Track"]

				thePressures.Push(pressureInfo["Pressure"] + Round((deltaAir * (- correctionAir)) + (deltaTrack * (- correctionTrack)), 1))

				theCertainty := Min(theCertainty, 1.0 - (Abs(deltaAir + deltaTrack) / (kMaxTemperatureDelta + 1)))
			}

			if (thePressures.Length() > 0) {
				compound := theCompound
				compoundColor := theCompoundColor
				certainty := theCertainty
				pressures := thePressures

				return true
			}
		}

		return false
	}

	getPressureInfo(simulator, car, track, weather, driver := "__Undefined__") {
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

		for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", "count", "Count"]]
																		 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]
																		 , Where: where})
			info.Push({Source: "User", Weather: row.Weather, AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
					 , Compound: compound(row.Compound, row["Compound.Color"]), Count: row.Count})

		if this.UseCommunity {
			database := this.getTyresDatabase(simulator, car, track, "Community")

			for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", "count", "Count"]]
																			 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
				info.Push({Source: "Community", Weather: row.Weather, AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
						 , Compound: compound(row.Compound, row["Compound.Color"]), Count: row.Count})
		}

		return info
	}

	getPressures(simulator, car, track, weather, airTemperature, trackTemperature
			   , compound, compoundColor, driver := false) {
		local weatherBaseIndex, weatherCandidateOffsets, localTyresDatabase, globalTyresDatabase
		local ignore, weatherOffset, airDelta, trackDelta, distributions, thePressures, index, tyre
		local bestPressure, bestCount, pressure, pressureCount, tyrePressures

		if !driver
			driver := this.ID

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
			weather := kWeatherConditions[Max(0, Min(weatherBaseIndex + weatherOffset, kWeatherConditions.Length()))]

			for ignore, airDelta in kTemperatureDeltas {
				for ignore, trackDelta in kTemperatureDeltas {
					distributions := {FL: {}, FR: {}, RL: {}, RR: {}}

					this.getPressureDistributions(localTyresDatabase, weather, airTemperature + airDelta, trackTemperature + trackDelta
												, compound, compoundColor, distributions, driver)

					if this.UseCommunity
						this.getPressureDistributions(globalTyresDatabase, weather, airTemperature + airDelta, trackTemperature + trackDelta
													, compound, compoundColor, distributions, false)

					if (distributions["FL"].Count() != 0) {
						thePressures := {}

						for index, tyre in ["FL", "FR", "RL", "RR"] {
							thePressures[tyre] := {}
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

		return {}
	}

	updatePressures(simulator, car, track, weather, airTemperature, trackTemperature
				  , compound, compoundColor, coldPressures, hotPressures, flush := true, driver := false) {
		local database, tyres, types, typeIndex, tPressures, tyreIndex, pressure

		if !driver
			driver := this.ID

		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"

		database := this.requireDatabase(simulator, car, track)

		database.add("Tyres.Pressures", {Driver: driver, Weather: weather
									   , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
									   , Compound: compound, "Compound.Color": compoundColor
									   , "Tyre.Pressure.Cold.Front.Left": coldPressures[1]
									   , "Tyre.Pressure.Cold.Front.Right": coldPressures[2]
									   , "Tyre.Pressure.Cold.Rear.Left": coldPressures[3]
									   , "Tyre.Pressure.Cold.Rear.Right": coldPressures[4]
									   , "Tyre.Pressure.Hot.Front.Left": hotPressures[1]
									   , "Tyre.Pressure.Hot.Front.Right": hotPressures[2]
									   , "Tyre.Pressure.Hot.Rear.Left": hotPressures[3]
									   , "Tyre.Pressure.Hot.Rear.Right": hotPressures[4]}, flush)

		tyres := ["FL", "FR", "RL", "RR"]
		types := ["Cold", "Hot"]

		for typeIndex, tPressures in [coldPressures, hotPressures]
			for tyreIndex, pressure in tPressures
				this.updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
								  , types[typeIndex], tyres[tyreIndex], pressure, 1, false, false, "User", driver)

		if flush
			this.flush()
	}

	updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
				 , type, tyre, pressure, count := 1, flush := true, require := true, scope := "User", driver := false) {
		local database, rows

		if !driver
			driver := this.ID

		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"

		if require
			database := this.requireDatabase(simulator, car, track, scope)
		else
			database := this.iDatabase

		rows := database.query("Tyres.Pressures.Distribution"
							 , {Where: {Driver: driver, Weather: weather
									  , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
									  , Compound: compound, "Compound.Color": compoundColor
									  , Type: type, Tyre: tyre, "Pressure": pressure}})

		if (rows.Length() > 0) {
			rows[1].Count := rows[1].Count + count
			rows.Synchronized := kNull

			if flush
				this.flush()
			else
				database.changed("Tyres.Pressures.Distribution")
		}
		else
			database.add("Tyres.Pressures.Distribution"
					   , {Driver: driver, Weather: weather
					    , "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
					    , Compound: compound, "Compound.Color": compoundColor
						, Type: type, Tyre: tyre, "Pressure": pressure, Count: count}
					   , flush)
	}

	flush() {
		if this.iDatabase {
			this.iDatabase.flush()

			this.iDatabase := false
		}
	}
}

synchronizeTyresPressures(connector, simulators, timestamp, lastSynchronization) {
	local sessionDB := new SessionDatabase()
	local ignore, simulator, car, track, db, modified, identifier, pressures, properties

	try {
		for ignore, simulator in simulators {
			simulator := this.getSimulatorCode(simulator)

			for ignore, car in sessionDB.getCars(simulator)
				for ignore, track in sessionDB.getTracks(simulator, car) {
					db := new Database(kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track, kTyresSchemas)

					modified := false

					for ignore, identifier in string2Values(";"
														  , connector.QueryData("TyresPressures", "Simulator = '" . simulator . "' And "
																								. "Car = '" . car . "' And "
																								. "Track = '" . track . "' And "
																								. "Modified > " . lastSynchronization . " And "
																								. "Driver <> '" . sessionDB.ID . "'")) {
						if (db.query("Tyres.Pressures", {Where: {Identifier: identifier} }).Length() = 0) {
							modified := true

							pressures := parseData(connector.GetData("TyresPressures", identifier))

							db.add("Tyres.Pressures", {Identifier: identifier, Synchronized: timestamp
													 , Driver: driver, Weather: weather
												     , "Temperature.Air": pressures.AirTemperature
													 , "Temperature.Track": pressures.TrackTemperature
												     , Compound: pressures.TyreCompound
													 , "Compound.Color": pressures.TyreCompoundColor
												     , "Tyre.Pressure.Cold.Front.Left": pressures.ColdPressureFrontLeft
												     , "Tyre.Pressure.Cold.Front.Right": pressures.ColdPressureFrontRight
												     , "Tyre.Pressure.Cold.Rear.Left": pressures.ColdPressureRearLeft
												     , "Tyre.Pressure.Cold.Rear.Right": pressures.ColdPressureRearRight
												     , "Tyre.Pressure.Hot.Front.Left": pressures.HotPressureFrontLeft
												     , "Tyre.Pressure.Hot.Front.Right": pressures.HotPressureFrontRight
												     , "Tyre.Pressure.Hot.Rear.Left": pressures.HotPressureRearLeft
												     , "Tyre.Pressure.Hot.Rear.Right": pressures.HotPressureRearRight})
						}
					}

					for ignore, pressures in db.query("Tyres.Pressures", {Where: {Synchronized: kNull, Driver: sessionDB.ID} }) {
						if (pressures.Identifier = kNull)
							pressures.Identifier := createGUID()

						pressures.Synchronized := timestamp

						modified := true

						if (connector.CountData("TyresPressures", "Identifier = '" . pressures.Identifier . "'") = 0)
							connector.CreateData("TyresPressures",
											   , substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`nSimulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
																   . "Weather=%Weather%`nAirTemperature=%AirTemperature%`nTrackTemperature=%TrackTemperature%`n"
																   . "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
																   . "HotPressureFrontLeft=%HotPressureFrontLeft%`nHotPressureFrontRight=%HotPressureFrontRight%`n"
																   . "HotPressureRearLeft=%HotPressureRearLeft%`nHotPressureRearRight=%HotPressureRearRight%`n"
																   . "ColdPressureFrontLeft=%ColdPressureFrontLeft%`nColdPressureFrontRight=%ColdPressureFrontRight%`n"
																   . "ColdPressureRearLeft=%ColdPressureRearLeft%`nColdPressureRearRight=%ColdPressureRearRight%"
																   , {Identifier: pressures.Identifier, Driver: pressures.Driver, Simulator: simulator, Car: car, Track: track
																    , Weather: pressures.Weather
																	, AirTemperature: pressures["Temperature.Air"], TrackTemperature: pressures["Temperature.Track"]
																	, TyreCompound: pressures.Compound, TyreCompoundColor: pressures["Compound.Color"]
																	, HotPressureFrontLeft: pressures["Tyre.Pressure.Hot.Front.Left"]
																	, HotPressureFrontRight: pressures["Tyre.Pressure.Hot.Front.Right"]
																	, HotPressureRearLeft: pressures["Tyre.Pressure.Hot.Rear.Left"]
																	, HotPressureRearRight: pressures["Tyre.Pressure.Hot.Rear.Right"]
																	, ColdPressureFrontLeft: pressures["Tyre.Pressure.Cold.Front.Left"]
																	, ColdPressureFrontRight: pressures["Tyre.Pressure.Cold.Front.Right"]
																	, ColdPressureRearLeft: pressures["Tyre.Pressure.Cold.Rear.Left"]
																	, ColdPressureRearRight: pressures["Tyre.Pressure.Cold.Rear.Right"]}))
					}

					if modified {
						db.flush("Tyres.Pressures")

						modified := false
					}

					for ignore, identifier in string2Values(";"
														  , connector.QueryData("TyresPressuresDistribution", "Simulator = '" . simulator . "' And "
																											. "Car = '" . car . "' And "
																											. "Track = '" . track . "' And "
																											. "Modified > " . lastSynchronization . " And "
																											. "Driver <> '" . sessionDB.ID . "'")) {
						modified := true

						pressures := parseData(connector.GetData("TyresPressuresDistribution", identifier))

						properties := {Identifier: pressures.Identifier, Synchronized: timestamp
									 , Driver: pressures.Driver, Weather: pressures.Weather
									 , "Temperature.Air": pressures.AirTemperature, "Temperature.Track": pressures.TrackTemperature
									 , Compound: pressures.TyreCompound, "Compound.Color": pressures.TyreCompoundColor
									 , Type: pressures.Type, Tyre: pressures.Tyre, Pressure: pressures.Pressure, Count: pressures.Count}

						pressures := db.query("Tyres.Pressures.Distribution", {Where: {Identifier: identifier} })

						if (pressures.Length() = 0)
							db.add("Tyres.Pressures.Distribution", properties)
						else {
							pressures := pressures[1]

							for property, value in properties
								pressures[property] := value
						}
					}

					for ignore, pressures in db.query("Tyres.Pressures.Distribution", {Where: {Synchronized: kNull, Driver: sessionDB.ID} }) {
						if (pressures.Identifier = kNull) {
							identifier := createGUID()

							pressures.Identifier := identifier
						}
						else
							identifier := pressures.Identifier

						pressures.Synchronized := timestamp

						modified := true

						if (connector.CountData("TyresPressuresDistribution", "Identifier = '" . identifier . "'") = 0)
							identifier := false

						properties := substituteVariables("Identifier=%Identifier%`nDriver=%Driver%`nSimulator=%Simulator%`nCar=%Car%`nTrack=%Track%`n"
														. "Weather=%Weather%`nAirTemperature=%AirTemperature%`nTrackTemperature=%TrackTemperature%`n"
														. "TyreCompound=%TyreCompound%`nTyreCompoundColor=%TyreCompoundColor%`n"
														. "Type=%Type%`nTyre=%Tyre%`nPressure=%Pressure%`nCount=%Count%"
														, {Identifier: pressures.Identifier, Driver: pressures.Driver, Simulator: simulator, Car: car, Track: track
														 , Weather: pressures.Weather
														 , AirTemperature: pressures["Temperature.Air"], TrackTemperature: pressures["Temperature.Track"]
														 , TyreCompound: pressures.Compound, TyreCompoundColor: pressures["Compound.Color"]
														 , Type: pressures.Type, Tyre: pressures.Tyre, Pressure: pressures.Pressure, Count: pressures.Count})

						if identifier
							connector.UpdateData("TyresPressuresDistribution", identifier, properties)
						else
							connector.CreateData("TyresPressuresDistribution", properties)
					}

					if modified
						db.flush("Tyres.Pressures.Distribution")
				}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

SessionDatabase.registerSynchronizer("synchronizeTyresPressures")