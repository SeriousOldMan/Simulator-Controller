;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACE Provider                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "ACEUDPProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACEProvider extends SimulatorProvider {
	static sCarData := false

	iCarMetaData := CaseInsenseMap()

	iUDPProvider := false

	iLastDriverCar := false

	static Simulator {
		Get {
			return "Assetto Corsa EVO"
		}
	}

	Simulator {
		Get {
			return ACEProvider.Simulator
		}
	}

	static Protocols {
		Get {
			local protocols := super.Protocols

			protocols.DeleteProp("Connector")

			return protocols
		}
	}

	UDPProvider {
		Get {
			return this.iUDPProvider
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("ACE", ACEProvider)
	}

	__New(car, track, provider := false) {
		this.iUDPProvider := (provider ? provider : ACEUDPProvider())

		super.__New(car, track)
	}

	static requireCarDatabase() {
		local data

		if !ACEProvider.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\ACE\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini"))

			ACEProvider.sCarData := data
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := false
		tyreService := false
		brakeService := false
		repairService := []

		return false
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := "Axle"
		tyreSets := false

		return true
	}

	supportsTrackMap() {
		return true
	}

	supportsSetupImport() {
		return true
	}

	computeBrakePadWear(location, compound, thickness) {
		if (location = "Front") {
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15) / 14 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 13) / 16 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
		}
		else
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15.5) / 13.5 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 12.5) / 16.5 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()
		local simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		local track := getMultiMapValue(data, "Session Data", "Track", "")
		local layout := getMultiMapValue(data, "Session Data", "Layout", "")
		local extension := ""
		local forname, surname, nickname, name
		local brakePadThickness, frontBrakePadCompound, rearBrakePadCompound, brakePadWear

		if ((getMultiMapValue(data, "Stint Data", "Laps", 0) == 0)
		 && (getMultiMapValue(data, "Session Data", "SessionFormat", "Laps") = "Time")) {
			setMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)
			setMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0)
		}

		if (track != "") {
			setMultiMapValue(data, "Session Data", "Track", track . "-" . layout)

			if (layout != "")
				extension := (" (" . layout . ")")

			setMultiMapValue(data, "Session Data", "TrackShortName"
								 , SessionDatabase.getTrackName(simulator, track, false) . extension)
			setMultiMapValue(data, "Session Data", "TrackLongName"
								 , SessionDatabase.getTrackName(simulator, track, true) . extension)
		}

		forname := getMultiMapValue(data, "Stint Data", "DriverForname", "John")
		surname := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		nickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")

		if ((forname = surname) && (surname = nickname)) {
			name := string2Values(A_Space, forname, 2)

			if (isObject(name) && (name.Length > 0)) {
				setMultiMapValue(data, "Stint Data", "DriverForname", name[1])
				setMultiMapValue(data, "Stint Data", "DriverSurname", (name.Length > 1) ? name[2] : "")
			}
			else
				setMultiMapValue(data, "Stint Data", "DriverSurname", "")

			setMultiMapValue(data, "Stint Data", "DriverNickname", "")
		}

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)

		if (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false)) {
			frontBrakePadCompound := getMultiMapValue(data, "Car Data", "FrontBrakePadCompoundRaw")
			rearBrakePadCompound := getMultiMapValue(data, "Car Data", "RearBrakePadCompoundRaw")

			/*
			brakePadThickness := string2Values(",", getMultiMapValue(data, "Car Data", "BrakePadLifeRaw"))
			brakePadWear := [this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[1])
						   , this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[2])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[3])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[4])]

			setMultiMapValue(data, "Car Data", "BrakeWear", values2String(",", brakePadWear*))

			if !isDebug() {
				removeMultiMapValue(data, "Car Data", "BrakePadLifeRaw")
				removeMultiMapValue(data, "Car Data", "BrakeDiscLifeRaw")
				removeMultiMapValue(data, "Car Data", "FrontBrakePadCompoundRaw")
				removeMultiMapValue(data, "Car Data", "RearBrakePadCompoundRaw")
			}
			*/
		}

		return data
	}

	acquireStandingsData(telemetryData, finished := false) {
		local standingsData, session
		local driverID, driverForname, driverSurname, driverNickname, lapTime, car, driverCar, driverCarCandidate

		ACEProvider.requireCarDatabase()

		try {
			standingsData := this.UDPProvider.acquire()
		}
		catch Any as exception {
			logError(exception, true)

			standingsData := false
		}

		if standingsData {
			session := getMultiMapValue(standingsData, "Session Data", "Session", kUndefined)

			if (session != kUndefined) {
				removeMultiMapValues(standingsData, "Session Data")

				setMultiMapValue(telemetryData, "Session Data", "Session", session)
			}

			if (getMultiMapValue(telemetryData, "Stint Data", "Laps", 0) <= 1)
				this.iLastDriverCar := false

			driverForname := getMultiMapValue(telemetryData, "Stint Data", "DriverForname", "John")
			driverSurname := getMultiMapValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getMultiMapValue(telemetryData, "Stint Data", "DriverNickname", "JD")
			driverID := getMultiMapValue(telemetryData, "Session Data", "ID", kUndefined)

			lapTime := getMultiMapValue(telemetryData, "Stint Data", "LapLastTime", 0)

			driverCar := false
			driverCarCandidate := false

			loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
				car := SessionDatabase.getCarCode(this.Simulator
												, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car"))

				setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Class"
							   , getMultiMapValue(ACEProvider.sCarData, "Car Classes", car, "Unknown"))

				if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID", false) = driverID) {
					driverCar := A_Index

					this.iLastDriverCar := driverCar
				}
				else if !driverCar
					if ((getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
					 && (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)) {
						driverCar := A_Index

						this.iLastDriverCar := driverCar
					}
			}

			if !driverCar
				loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0)
					if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Position")
					  = getMultiMapValue(telemetryData, "Stint Data", "Position", kUndefined)) {
						driverCar := A_Index

						this.iLastDriverCar := driverCar

						break
					}
					else if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Time") = lapTime)
						driverCarCandidate := A_Index

			if !driverCar
				driverCar := (this.iLastDriverCar ? this.iLastDriverCar : driverCarCandidate)

			setMultiMapValue(standingsData, "Position Data", "Driver.Car", driverCar)

			return (finished ? standingsData : this.correctStandingsData(standingsData))
		}
		else
			this.UDPProvider.shutdown(true)
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, postFix

		static tyres := ["Front", "Rear"]

		if !car
			car := getMultiMapValue(data, "Session Data", "Car", false)

		if !track
			track := getMultiMapValue(data, "Session Data", "Track", false)

		for ignore, section in ["Car Data", "Setup Data"]
			for ignore, postfix in tyres {
				tyreCompound := getMultiMapValue(data, section, "TyreCompound" . postFix, kUndefined)

				if (tyreCompound = kUndefined) {
					tyreCompound := getMultiMapValue(data, section, "TyreCompoundRaw" . postFix, kUndefined)

					if ((tyreCompound != kUndefined) && tyreCompound) {
						tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

						if tyreCompound {
							splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, section, "TyreCompound" . postFix, tyreCompound)
							setMultiMapValue(data, section, "TyreCompoundColor" . postFix, tyreCompoundColor)
						}
					}
				}
			}

		return data
	}
}