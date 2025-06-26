;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AC Provider                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACProvider extends SimulatorProvider {
	Simulator {
		Get {
			return "Assetto Corsa"
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := true
		tyreService := "All"
		brakeService := false
		repairService := ["Bodywork", "Suspension", "Engine"]

		return true
	}
	
	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := false
		tyreSets := false
		
		return true
	}

	supportsTrackMap() {
		return true
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()
		local forName, surName, nickName, name

		setMultiMapValue(data, "Car Data", "TC", Round((getMultiMapValue(data, "Car Data", "TCRaw", 0) / 0.2) * 10))
		setMultiMapValue(data, "Car Data", "ABS", Round((getMultiMapValue(data, "Car Data", "ABSRaw", 0) / 0.2) * 10))

		forName := getMultiMapValue(data, "Stint Data", "DriverForname", "John")
		surName := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		nickName := getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")

		if ((forName = surName) && (surName = nickName)) {
			name := string2Values(A_Space, forName, 2)

			if (isObject(name) && (name.Length > 0)) {
				setMultiMapValue(data, "Stint Data", "DriverForname", name[1])
				setMultiMapValue(data, "Stint Data", "DriverSurname", (name.Length > 1) ? name[2] : "")
			}
			else
				setMultiMapValue(data, "Stint Data", "DriverSurname", "")

			setMultiMapValue(data, "Stint Data", "DriverNickname", "")
		}

		if !isDebug() {
			removeMultiMapValue(data, "Car Data", "TCRaw")
			removeMultiMapValue(data, "Car Data", "ABSRaw")
			removeMultiMapValue(data, "Track Data", "GripRaw")
		}

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)

		return data
	}
}