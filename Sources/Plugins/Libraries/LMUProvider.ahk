;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU Provider                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "LMURestProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMUProvider extends Sector397Provider {
	iTeamData := false
	iTrackData := false
	iDriversData := false
	iGridData := false

	iCarInfos := false
	iCarInfosRefresh := 0

	iFuelRatio := false

	class CarInfos extends LMURestProvider.StandingsData {
		iCarIDs := false
		iCarPositions := false

		Position[carID] {
			Get {
				try {
					return this.iCarPositions[inList(this.iCarIDs, carID)]
				}
				catch Any as exception {
					logError(exception)

					return false
				}
			}
		}

		Driver[carID] {
			Get {
				try {
					return super.Driver[this.iCarPositions[inList(this.iCarIDs, carID)]]
				}
				catch Any as exception {
					logError(exception)

					return false
				}
			}
		}

		Class[carID] {
			Get {
				try {
					return super.Class[this.iCarPositions[inList(this.iCarIDs, carID)]]
				}
				catch Any as exception {
					logError(exception)

					return false
				}
			}
		}

		Laps[carID] {
			Get {
				try {
					return super.Laps[this.iCarPositions[inList(this.iCarIDs, carID)]]
				}
				catch Any as exception {
					logError(exception)

					return false
				}
			}
		}

		__New(standingsData) {
			local ids := []
			local positions := []

			loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
				ids.Push(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID"))
				positions.Push(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Position"))
			}

			this.iCarIDs := ids
			this.iCarPositions := positions

			super.__New()

			this.read()
		}
	}

	Simulator {
		Get {
			return "Le Mans Ultimate"
		}
	}

	GridData {
		Get {
			if !this.iGridData
				this.iGridData := LMURESTProvider.GridData()

			return this.iGridData
		}
	}

	DriversData {
		Get {
			if !this.iDriversData
				this.iDriversData := LMURESTProvider.DriversData()

			return this.iDriversData
		}
	}

	TeamData {
		Get {
			if !this.iTeamData
				this.iTeamData := LMURESTProvider.TeamData()

			return this.iTeamData
		}
	}

	TrackData {
		Get {
			if !this.iTrackData
				this.iTrackData := LMURESTProvider.TrackData()

			return this.iTrackData
		}
	}

	CarInfos {
		Get {
			return this.iCarInfos
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := true
		tyreService := "Wheel"
		brakeService := true
		repairService := ["Bodywork", "Suspension"]

		return true
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := "Wheel"
		tyreSets := false

		return true
	}

	prepareProvider(data) {
		local ignore

		super.prepareProvider(data)

		ignore := this.TeamData
		ignore := this.TrackData
		ignore := this.GridData
		ignore := this.DriversData
	}

	getRefuelAmount(setupData) {
		return setupData.getRefuelLevel()
	}

	parseCategory(candidate, &rest) {
		super.parseCategory(candidate, &rest)

		return false
	}

	parseCarName(carID, carName, &model?, &nr?, &category?, &team?) {
		local gridData := this.GridData

		model := gridData.Car[carName]
		team := gridData.Team[carName]

		if ((carName != "") && isNumber(SubStr(carName, 1, 1))) {
			nr := this.parseNr(carName, &carName)

			super.parseCarName(carID, carName, , , &category)
		}
		else
			super.parseCarName(carID, carName, , &nr, &category)
	}

	parseDriverName(carID, carName, forName, surName, nickName, &category?) {
		local drivers, carInfos

		getCategory(drivers, driver) {
			local ignore, candidate

			for ignore, candidate in drivers
				if (InStr(driver, candidate.Name) = 1)
					return candidate.Category

			return false
		}

		if isSet(category)
			try {
				drivers := this.DriversData.Drivers[carName]
				carInfos := (carID ? this.CarInfos : false)

				category := (carInfos ? getCategory(drivers, carInfos.Driver[carID]) : false)
			}
			catch Any {
				category := false
			}

		return super.parseDriverName(carID, carName, forName, surName, nickName)
	}

	acquireStandingsData(telemetryData, finished := false) {
		if (A_TickCount > this.iCarInfosRefresh)
			this.iCarInfos := false

		if !this.CarInfos {
			this.iCarInfos := LMUProvider.CarInfos(this.readStandingsData(telemetryData))

			this.iCarInfosRefresh := (A_TickCount + 30000)
		}

		return super.acquireStandingsData(telemetryData, finished)
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car, track, data, setupData, tyreCompound, tyreCompoundColor, key, postFix, fuelAmount
		local carData, weatherData, wheelData, lap, weather, time, session, remainingTime, fuelRatio
		local newPositions, position, energyData, virtualEnergy, tyreWear, brakeWear, suspensionDamage

		static keys := Map("All", "", "Front Left", "FrontLeft", "Front Right", "FrontRight"
									, "Rear Left", "RearLeft", "Rear Right", "RearRight")

		static wheels := Map("Front Left", "FrontLeft", "Front Right", "FrontRight"
						   , "Rear Left", "RearLeft", "Rear Right", "RearRight")

		static lastPositions := false

		static lastLap := 0
		static duration := 0
		static lastWeather := false
		static lastWeather10Min := false
		static lastWeather30Min := false

		if InStr(options, "Setup=true") {
			car := this.Car
			track := this.Track

			setupData := LMURESTProvider.PitstopData(simulator, car, track)
			data := newMultiMap()

			setMultiMapValue(data, "Setup Data", "FuelAmount", this.getRefuelAmount(setupData))

			for key, postFix in keys {
				tyreCompound := setupData.TyreCompound[key]

				if tyreCompound {
					tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

					if tyreCompound {
						splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

						setMultiMapValue(data, "Setup Data", "TyreCompound" . postFix, tyreCompound)
						setMultiMapValue(data, "Setup Data", "TyreCompoundColor" . postFix, tyreCompoundColor)
					}
				}
				else {
					setMultiMapValue(data, "Setup Data", "TyreCompound" . postFix, false)
					setMultiMapValue(data, "Setup Data", "TyreCompoundColor" . postFix, false)
				}
			}

			setMultiMapValue(data, "Setup Data", "TyrePressureFL", setupData.TyrePressure["Front Left"])
			setMultiMapValue(data, "Setup Data", "TyrePressureFR", setupData.TyrePressure["Front Right"])
			setMultiMapValue(data, "Setup Data", "TyrePressureRL", setupData.TyrePressure["Rear Left"])
			setMultiMapValue(data, "Setup Data", "TyrePressureRR", setupData.TyrePressure["Rear Right"])

			setMultiMapValue(data, "Setup Data", "ChangeBrakes", setupData.BrakeChange)

			setMultiMapValue(data, "Setup Data", "RepairBodywork", setupData.RepairBodywork)
			setMultiMapValue(data, "Setup Data", "RepairSuspension", setupData.RepairSuspension)
			setMultiMapValue(data, "Setup Data", "RepairEngine", setupData.RepairEngine)

			setMultiMapValue(data, "Setup Data", "Driver", setupData.Driver)

			fuelRatio := setupData.FuelRatio

			if (fuelRatio && isNumber(fuelRatio))
				this.iFuelRatio := fuelRatio

			setMultiMapValue(data, "Setup Data", "ServiceTime", LMURESTProvider.ServiceData().ServiceTime)
		}
		else {
			data := super.readSessionData(options, protocol?)

			car := (this.Car || this.TeamData.Car)
			track := (this.Track || this.TrackData.Track)

			if data.Has("Weather Data") {
				lap := getMultiMapValue(data, "Stint Data", "Laps", 0)

				if ((lap < lastLap) || (lap = 0) || (lap > (lastLap + 1)) || (duration = 0)) {
					lastLap := 0

					lastWeather := getMultiMapValue(data, "Weather Data", "Weather", "Dry")
					lastWeather10Min := getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry")
					lastWeather30Min := getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry")

					duration := (LMURESTProvider.SessionData().Duration[getMultiMapValue(data, "Session Data"
																							 , "Session", "Race")] * 1000)
				}

				if (lap != lastLap) {
					lastLap := lap

					session := getMultiMapValue(data, "Session Data", "Session", "Race")
					remainingTime := getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)
					weatherData := LMURestProvider.WeatherData()
					weather := weatherData.Weather["Now"]

					if weather
						lastWeather := weather

					time := ((duration > 0) ? Round(100 - (Max(0, remainingTime - 600000) / duration * 100)) : 0)
					weather := weatherData.Weather[session, time]

					if weather
						lastWeather10Min := weather

					time := ((duration > 0) ? Round(100 - (Max(0, remainingTime - 1800000) / duration * 100)) : 0)
					weather := weatherData.Weather[session, time]

					if weather
						lastWeather30Min := weather
				}

				setMultiMapValue(data, "Weather Data", "Weather", lastWeather)
				setMultiMapValue(data, "Weather Data", "Weather10Min", lastWeather10Min)
				setMultiMapValue(data, "Weather Data", "Weather30Min", lastWeather30Min)
			}

			if !InStr(options, "Standings=true") {
				newPositions := []

				loop {
					position := getMultiMapValue(data, "Track Data", "Car." . A_Index . ".Position", false)

					if position
						newPositions.Push(position)
					else
						break
				}

				paused := true

				if (lastPositions && (lastPositions.Length = newPositions.Length)) {
					loop lastPositions.Length
						if (lastPositions[A_Index] != newPositions[A_Index]) {
							paused := false

							break
						}

					if paused
						setMultiMapValue(data, "Session Data", "Paused", true)
				}

				lastPositions := newPositions

				if car
					setMultiMapValue(data, "Session Data", "Car", car)
				else
					car := this.Car

				if track
					setMultiMapValue(data, "Session Data", "Track", track)
				else
					track := this.Track

				if (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false)) {
					wheelData := LMURestProvider.WheelData()
					carData := LMURestProvider.CarData()

					if data.Has("Car Data") {
						energyData := LMURESTProvider.EnergyData(simulator, car, track)

						fuelAmount := getMultiMapValue(data, "Session Data", "FuelAmount", false)

						if !fuelAmount {
							fuelAmount := carData.FuelAmount

							if !fuelAmount
								fuelAmount := energyData.MaxFuelAmount

							if fuelAmount
								setMultiMapValue(data, "Session Data", "FuelAmount", fuelAmount)
						}

						if (fuelAmount && this.iFuelRatio)
							setMultiMapValue(data, "Session Data", "FuelAmount", Round(this.iFuelRatio * 100, 1))

						virtualEnergy := energyData.RemainingVirtualEnergy

						if virtualEnergy
							setMultiMapValue(data, "Car Data", "EnergyRemaining", virtualEnergy)

					}

					for key, postFix in wheels {
						tyreCompound := wheelData.TyreCompound[key]
						tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

						if tyreCompound {
							splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, "Car Data", "TyreCompound" . postFix, tyreCompound)
							setMultiMapValue(data, "Car Data", "TyreCompoundColor" . postFix, tyreCompoundColor)
						}
					}

					tyreWear := carData.TyreWear["All"]
					brakeWear := carData.BrakePadWear["All"]
					suspensionDamage := carData.SuspensionDamage["All"]

					if (isObject(tyreWear) && exist(tyreWear, (w) => (w != false)))
						setMultiMapValue(data, "Car Data", "TyreWear", values2String(",", tyreWear*))

					if (isObject(brakeWear) && exist(brakeWear, (w) => (w != false)))
						setMultiMapValue(data, "Car Data", "BrakeWear", values2String(",", brakeWear*))

					if (isObject(suspensionDamage) && exist(suspensionDamage, (d) => (d != false)))
						setMultiMapValue(data, "Car Data", "SuspensionDamage", values2String(",", suspensionDamage*))
				}
			}
		}

		return data
	}
}