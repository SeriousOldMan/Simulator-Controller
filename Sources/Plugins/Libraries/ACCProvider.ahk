;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Provider                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "ACCUDPProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCProvider extends SimulatorProvider {
	static kUnknown := false

	static sCarData := false

	iUDPProvider := false

	iLastDriverCar := false

	Simulator {
		Get {
			return "Assetto Corsa Competizione"
		}
	}

	UDPProvider {
		Get {
			return this.iUDPProvider
		}
	}

	__New(car, track, provider := false) {
		this.iUDPProvider := (provider ? provider : ACCUDPProvider())

		super.__New(car, track)
	}

	static requireCarDatabase() {
		local data

		if !ACCProvider.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\ACC\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\ACC\Car Data.ini"))

			ACCProvider.sCarData := data
		}
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()
		local brakePadThickness, frontBrakePadCompound, rearBrakePadCompound, brakePadWear

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)

		if (getMultiMapValue(data, "Session Data", "Active", false) && !getMultiMapValue(data, "Session Data", "Paused", false)) {
			brakePadThickness := string2Values(",", getMultiMapValue(data, "Car Data", "BrakePadLifeRaw"))
			frontBrakePadCompound := getMultiMapValue(data, "Car Data", "FrontBrakePadCompoundRaw")
			rearBrakePadCompound := getMultiMapValue(data, "Car Data", "RearBrakePadCompoundRaw")

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
		}

		return data
	}

	acquireStandingsData(telemetryData, finished := false) {
		local standingsData, session
		local driverID, driverForname, driverSurname, driverNickname, lapTime, driverCar, driverCarCandidate, carID, car

		static carIDs := false

		if !carIDs {
			ACCProvider.requireCarDatabase()

			carIDs := getMultiMapValues(ACCProvider.sCarData, "Car IDs")
		}

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
				carID := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", kUndefined)

				if (carID != kUndefined) {
					car := (carIDs.Has(carID) ? carIDs[carID] : ACCProvider.kUnknown)

					if ((car = ACCProvider.kUnknown) && isDebug())
						showMessage("Unknown car with ID " . carID . " detected...")

					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", car)

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
			}

			if !driverCar
				loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
					carID := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", kUndefined)

					if (carID != kUndefined)
						if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Position")
						  = getMultiMapValue(telemetryData, "Stint Data", "Position", kUndefined)) {
						driverCar := A_Index

						this.iLastDriverCar := driverCar

						break
					}
					else if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Time") = lapTime)
						driverCarCandidate := A_Index
				}

			if !driverCar
				driverCar := (this.iLastDriverCar ? this.iLastDriverCar : driverCarCandidate)

			setMultiMapValue(standingsData, "Position Data", "Driver.Car", driverCar)

			return (finished ? standingsData : this.correctStandingsData(standingsData))
		}
		else {
			this.UDPProvider.shutdown(true)

			return newMultiMap()
		}
	}
}