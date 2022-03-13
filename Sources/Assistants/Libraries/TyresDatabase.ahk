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


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTyresDataSchemas := {"Tyres.Pressures": ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
											   , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
											   , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
											   , "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
											   , "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"]
						   , "Tyres.Pressures.Distribution": ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"
															, "Type", "Tyre", "Pressure", "Count"]}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kTemperatureDeltas = [0, 1, -1, 2, -2]
global kMaxTemperatureDelta = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TyresDatabase extends SessionDatabase {
	iLastSimulator := false
	iLastCar := false
	iLastTrack := false
	
	iDatabase := false
	
	getTyresDatabase(simulator, car, track, type := "User") {
		path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\")
		
		return new Database(kDatabaseDirectory . type . "\" . path, kTyresDataSchemas)
	}

	getPressureDistributions(database, weather, airTemperature, trackTemperature, compound, compoundColor, ByRef distributions) {
		where := {"Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
				, Compound: compound, "Compound.Color": compoundColor, Type: "Cold"}
		
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
	
	getConditions(simulator, car, track) {
		local database
		local condition
		local compound
		
		path := (this.getSimulatorCode(simulator) . "\" . car . "\" . track . "\")
		
		conditions := {}

		database := this.getTyresDatabase(simulator, car, track, "User")
		
		for ignore, condition in database.query("Tyres.Pressures.Distribution"
											  , {By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]
											   , Where: {Type: "Cold"}})
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

	getTyreSetup(simulator, car, track, weather, airTemperature, trackTemperature, ByRef compound, ByRef compoundColor, ByRef pressures, ByRef certainty) {
		local condition
		
		simulator := this.getSimulatorName(simulator)
		
		if !compound {
			weatherIndex := inList(kWeatherOptions, weather)
			visited := []
			compounds := []
			
			for ignore, condition in this.getConditions(simulator, car, track) {
				theCompound := (condition[4] . "." . condition[5])
				
				conditionIndex := inList(kWeatherOptions, condition[1])
			
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
		
		thePressures := []
		theCertainty := 1.0
		
		for ignore, compoundInfo in compounds {
			theCompound := compoundInfo[1]
			theCompoundColor := compoundInfo[2]
			
			for ignore, pressureInfo in this.getPressures(simulator, car, track, weather, airTemperature, trackTemperature, theCompound, theCompoundColor) {
				deltaAir := pressureInfo["Delta Air"]
				deltaTrack := pressureInfo["Delta Track"]
				
				thePressures.Push(pressureInfo["Pressure"] + ((deltaAir + Round(deltaTrack * 0.49)) * 0.1))
				
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
	
	getPressureInfo(simulator, car, track, weather) {
		local database
		
		info := []
		
		database := this.getTyresDatabase(simulator, car, track, "User")
		
		for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", "count", "Count"]]
																		 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
			info.Push({Source: "User", Weather: row.Weather, AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
					 , Compound: this.qualifiedCompound(row.Compound, row["Compound.Color"]), Count: row.Count})
		
		database := this.getTyresDatabase(simulator, car, track, "Community")
		
		for ignore, row in database.query("Tyres.Pressures.Distribution", {Group: [["Count", "count", "Count"]]
																		 , By: ["Weather", "Temperature.Air", "Temperature.Track", "Compound", "Compound.Color"]})
			info.Push({Source: "Community", Weather: row.Weather, AirTemperature: row["Temperature.Air"], TrackTemperature: row["Temperature.Track"]
					 , Compound: this.qualifiedCompound(row.Compound, row.CompoundColor), Count: row.Count})
		
		return info
	}
	
	getPressures(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor) {
		if (weather != true) {
			weatherBaseIndex := inList(kWeatherOptions, weather)
			
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
		
		localTyresDatabase := this.getTyresDatabase(simulator, car, track, "User")
		globalTyresDatabase := (this.UseCommunity ? this.getTyresDatabase(simulator, car, track, "Global") : false)
			
		for ignore, weatherOffset in weatherCandidateOffsets {
			weather := kWeatherOptions[Max(0, Min(weatherBaseIndex + weatherOffset, kWeatherOptions.Length()))]
			
			for ignore, airDelta in kTemperatureDeltas {
				for ignore, trackDelta in kTemperatureDeltas {
					distributions := {FL: {}, FR: {}, RL: {}, RR: {}}
					
					this.getPressureDistributions(localTyresDatabase, weather, airTemperature + airDelta, trackTemperature + trackDelta, compound, compoundColor, distributions)
					
					if this.UseCommunity
						this.getPressureDistributions(globalTyresDatabase, weather, airTemperature + airDelta, trackTemperature + trackDelta, compound, compoundColor, distributions)
					
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
	
	requireDatabase(simulator, car, track) {
		simulatorCode := this.getSimulatorCode(simulator)
		simulator := this.getSimulatorName(simulatorCode)
		
		FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%
		
		if (this.iDatabase && ((this.iLastSimulator != simulator) || (this.iLastCar != car) || (this.iLastTrack != track)))
			this.flush()
		
		if !this.iDatabase
			this.iDatabase := this.getTyresDatabase(simulator, car, track, "User")
	}
	
	updatePressures(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor, coldPressures, hotPressures, flush := true) {
		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"
	
		this.requireDatabase(simulator, car, track)
		
		this.iDatabase.add("Tyres.Pressures", {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											 , Compound: compound, "Compound.Color": compoundColor
											 , "Tyre.Pressure.Cold.Front.Left": coldPressures[1], "Tyre.Pressure.Cold.Front.Right": coldPressures[2]
											 , "Tyre.Pressure.Cold.Rear.Left": coldPressures[3], "Tyre.Pressure.Cold.Rear.Right": coldPressures[4]
											 , "Tyre.Pressure.Hot.Front.Left": hotPressures[1], "Tyre.Pressure.Hot.Front.Right": hotPressures[2]
											 , "Tyre.Pressure.Hot.Rear.Left": hotPressures[3], "Tyre.Pressure.Hot.Rear.Right": hotPressures[4]}, flush)
		
		tyres := ["FL", "FR", "RL", "RR"]
		types := ["Cold", "Hot"]
		
		for typeIndex, tPressures in [coldPressures, hotPressures]
			for tyreIndex, pressure in tPressures
				this.updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
								  , types[typeIndex], tyres[tyreIndex], pressure, 1, flush, false)
	}
	
	updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
				 , type, tyre, pressure, count := 1, flush := true, require := true) {
		if (!compoundColor || (compoundColor = ""))
			compoundColor := "Black"
		
		if require
			this.requireDatabase(simulator, car, track)
		
		rows := this.iDatabase.query("Tyres.Pressures.Distribution"
								   , {Where: {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											, Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure}})
		
		if (rows.Length() > 0)
			rows[1].Count := rows[1].Count + count
		else
			this.iDatabase.add("Tyres.Pressures.Distribution"
							 , {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
							  , Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure, Count: count}, flush)
	}
	
	flush() {
		if this.iDatabase {
			this.iDatabase.flush()
			
			this.iDatabase := false
		}
	}
	
	qualifiedCompound(compound, compoundColor) {
		if (compound= "Dry") {
			if (compoundColor = "Black")
				return "Dry"
			else
				return ("Dry (" . compoundColor . ")")
		}
		else if (compoundColor = "Black")
			return "Wet"
		else
			return ("Wet (" . compoundColor . ")")
	}

	translateQualifiedCompound(compound, compoundColor) {
		if (compound= "Dry") {
			if (compoundColor = "Black")
				return translate("Dry")
			else
				return (translate("Dry") . translate(" (") . translate(compoundColor) . translate(")"))
		}
		else if (compoundColor = "Black")
			return translate("Wet")
		else
			return (translate("Wet") . translate(" (") . translate(compoundColor) . translate(")"))
	}

	splitQualifiedCompound(qualifiedCompound, ByRef compound, ByRef compoundColor) {
		compoundColor := "Black"
		
		index := inList(kQualifiedTyreCompounds, qualifiedCompound)
		
		if (index == 1)
			compound := "Wet"
		else
			compound := "Dry"
		
		compoundColor := kQualifiedTyreCompoundColors[index]
	}
}