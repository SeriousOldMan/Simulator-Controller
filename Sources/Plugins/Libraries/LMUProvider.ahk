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

	iLastDriver := false

	iStandingsData := false

	iFuelRatio := false

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

	StandingsData {
		Get {
			return this.iStandingsData
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

	prepareProvider() {
		local ignore

		super.prepareProvider()

		ignore := this.TeamData.Data
		ignore := this.TrackData.Data
		ignore := this.GridData.Data
		ignore := this.DriversData.Data
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

		static nextReload := 0

		model := gridData.Car[carName]
		team := gridData.Team[carName]

		if !model {
			if isDebug()
				logMessage(kLogDebug, "Car model not found for car " . carName . "...")

			if (A_TickCount > nextReload) {
				nextReload := (A_TickCount + 10000)

				gridData.reload()

				model := gridData.Car[carName]
				team := gridData.Team[carName]
			}
		}

		if ((carName != "") && isNumber(SubStr(carName, 1, 1))) {
			nr := this.parseNr(carName, &carName)

			super.parseCarName(carID, carName, , , &category)
		}
		else
			super.parseCarName(carID, carName, , &nr, &category)
	}

	parseDriverName(carID, carName, forName, surName, nickName, &category?) {
		local drivers, standingsData

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
				standingsData := (carID ? this.StandingsData : false)

				category := (standingsData ? getCategory(drivers, standingsData.Driver[carID]) : false)
			}
			catch Any {
				category := false
			}

		return super.parseDriverName(carID, carName, forName, surName, nickName)
	}

	acquireStandingsData(telemetryData, finished := false) {
		local teamSession := this.TeamData.TeamSession
		local standingsData, forName, surName, nickName, id, teamID

		this.iStandingsData := LMURESTProvider.StandingsData()

		standingsData := super.acquireStandingsData(telemetryData, finished)

		loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
			forName := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname")
			surName := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname")

			id := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID")

			if teamSession {
				teamID := this.TeamData.TeamID[forName . A_Space . surName]

				if teamID {
					nr := this.TeamData.Nr[teamID]

					if nr
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", nr)

					team := this.TeamData.Team[teamID]

					if team
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Team", team)
				}
			}

			parseDriverName(this.StandingsData.Driver[id], &forName, &surName, &nickName)

			setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", forName)
			setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", surName)
			setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", nickName)
		}

		return standingsData
	}

	acquireSessionData(&telemetryData, &standingsData, finished := false) {
		local driver, forName, surName, nickName

		super.acquireSessionData(&telemetryData, &standingsData, finished)

		driver := getMultiMapValue(standingsData, "Position Data", "Driver.Car", false)

		if !driver
			driver := this.iLastDriver

		if driver {
			this.iLastDriver := driver

			forName := getMultiMapValue(standingsData, "Position Data", "Car." . driver . ".Driver.Forname")
			surName := getMultiMapValue(standingsData, "Position Data", "Car." . driver . ".Driver.Surname")
			nickName := getMultiMapValue(standingsData, "Position Data", "Car." . driver . ".Driver.Nickname")

			if ((forName != getMultiMapValue(telemetryData, "Stint Data", "DriverForname"))
			 || (surName != getMultiMapValue(telemetryData, "Stint Data", "DriverSurname")))
				setMultiMapValue(telemetryData, "Session Data", "Paused", true)

			setMultiMapValue(telemetryData, "Stint Data", "DriverForname", forName)
			setMultiMapValue(telemetryData, "Stint Data", "DriverSurname", surName)
			setMultiMapValue(telemetryData, "Stint Data", "DriverNickname", nickName)
		}
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local carData := false
		local car, track, data, setupData, tyreCompound, tyreCompoundColor, key, postFix, fuelAmount
		local weatherData, lap, weather, time, session, remainingTime, fuelRatio
		local newPositions, position, energyData, virtualEnergy, tyreWear, brakeWear, suspensionDamage
		local sessionData, paused, fuelAmount

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
		static lastWheelData := false
		static lastTyreWear := false
		static lastBrakeWear := false

		static nextUpdate := 0
		static lastFuelAmount := 0

		if InStr(options, "Setup=true") {
			car := this.Car
			track := this.Track

			setupData := LMURESTProvider.PitstopData(simulator, car, track)
			data := super.readSessionData(options, protocol?)

			fuelAmount := this.getRefuelAmount(setupData)

			setMultiMapValue(data, "Setup Data", "FuelAmount.Silent", (fuelAmount = lastFuelAmount))
			setMultiMapValue(data, "Setup Data", "FuelAmount", fuelAmount)
			setMultiMapValue(data, "Setup Data", "RefuelAmount", setupData.getRefuelLevel() - getMultiMapValue(data, "Setup Data", "FuelRemaining", 0))

			lastFuelAmount := fuelAmount

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

			sessionData := LMURESTProvider.SessionData()

			car := (this.Car || this.TeamData.Car)
			track := (this.Track || this.TrackData.Track)

			if data.Has("Weather Data") {
				lap := getMultiMapValue(data, "Stint Data", "Laps", 0)

				if ((lap < lastLap) || (lap = 0) || (lap > (lastLap + 1)) || (duration = 0)) {
					lastLap := 0

					lastWeather := getMultiMapValue(data, "Weather Data", "Weather", "Dry")
					lastWeather10Min := getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry")
					lastWeather30Min := getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry")

					duration := (sessionData.Duration[getMultiMapValue(data, "Session Data"
																		   , "Session", "Race")] * 1000)
				}

				if (lap != lastLap) {
					lastLap := lap

					nextUpdate := (A_TickCount - 1)

					session := getMultiMapValue(data, "Session Data", "Session", "Race")
					remainingTime := getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)
					weatherData := LMURestProvider.WeatherData()

					if false
						weather := weatherData.Weather["Now"]
					else {
						time := ((duration > 0) ? Round(100 - (Max(0, remainingTime) / duration * 100)) : 0)
						weather := weatherData.Weather[session, time]
					}

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
			}

			switch sessionData.State, false {
				case "Driving":
					setMultiMapValue(data, "Session Data", "Active", true)
					setMultiMapValue(data, "Session Data", "Paused", false)
				case "Not Driving", "Paused":
					setMultiMapValue(data, "Session Data", "Active", true)
					setMultiMapValue(data, "Session Data", "Paused", true)
				case "Disabled":
					setMultiMapValue(data, "Session Data", "Paused", false)
				default:
					throw "Unknown session state detected in LMUProvider.readSessionData..."
			}

			if !InStr(options, "Standings=true") {
				if car
					setMultiMapValue(data, "Session Data", "Car", car)
				else
					car := this.Car

				if track
					setMultiMapValue(data, "Session Data", "Track", track)
				else
					track := this.Track

				setMultiMapValue(data, "Weather Data", "Weather", lastWeather)
				setMultiMapValue(data, "Weather Data", "Weather10Min", lastWeather10Min)
				setMultiMapValue(data, "Weather Data", "Weather30Min", lastWeather30Min)

				if (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false)) {
					if data.Has("Car Data") {
						energyData := LMURESTProvider.EnergyData(simulator, car, track)

						fuelAmount := getMultiMapValue(data, "Session Data", "FuelAmount", false)

						if !fuelAmount {
							if !carData
								carData := LMURestProvider.CarData()

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

					if !carData
						carData := LMURestProvider.CarData()

					if (A_TickCount > nextUpdate) {
						nextUpdate := (A_TickCount + 60000)

						lastWheelData := LMURestProvider.WheelData()

						lastTyreWear := carData.TyreWear["All"]
						lastBrakeWear := carData.BrakePadWear["All"]
					}

					for key, postFix in wheels {
						tyreCompound := lastWheelData.TyreCompound[key]
						tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

						if tyreCompound {
							splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, "Car Data", "TyreCompound" . postFix, tyreCompound)
							setMultiMapValue(data, "Car Data", "TyreCompoundColor" . postFix, tyreCompoundColor)
						}
					}

					if (isObject(lastTyreWear) && exist(lastTyreWear, (w) => (w != false)))
						setMultiMapValue(data, "Car Data", "TyreWear", values2String(",", lastTyreWear*))

					if (isObject(lastBrakeWear) && exist(lastBrakeWear, (w) => (w != false)))
						setMultiMapValue(data, "Car Data", "BrakeWear", values2String(",", lastBrakeWear*))

					suspensionDamage := carData.SuspensionDamage["All"]

					if (isObject(suspensionDamage) && exist(suspensionDamage, (d) => (d != false)))
						setMultiMapValue(data, "Car Data", "SuspensionDamage", values2String(",", suspensionDamage*))
				}
			}
		}

		return data
	}
}