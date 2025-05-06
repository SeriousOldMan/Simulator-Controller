;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - IRC Provider                    ;;;
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

class IRCProvider extends SimulatorProvider {
	Simulator {
		Get {
			return "iRacing"
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &repairService?) {
		refuelService := true
		tyreService := "Wheel"
		repairService := true

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

	supportsSetupImport() {
		return true
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()

		if (getMultiMapValue(data, "Stint Data", "Laps", 0) = 0) {
			setMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0)
			setMultiMapValue(data, "Session Data", "SessionLapsRemaining", 0)
		}

		return data
	}

	acquireStandingsData(telemetryData, finished := false) {
		local data := super.acquireStandingsData(telemetryData, finished)
		local carClass

		loop getMultiMapValue(data, "Position Data", "Car.Count", 0) {
			carClass := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUndefined)

			if (carClass != kUndefined) {
				carClass := Trim(carClass)

				if (carClass != "")
					setMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", carClass)
				else
					removeMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class")
			}
		}

		return data
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, section, postFix

		static tyres := ["FrontLeft", "FrontRight", "RearLeft", "RearRight"]

		for ignore, section in ["Car Data", "Setup Data"]
			for ignore, postfix in tyres {
				tyreCompound := getMultiMapValue(data, section, "TyreCompound" . postFix, kUndefined)

				if (tyreCompound = kUndefined) {
					tyreCompound := getMultiMapValue(data, section, "TyreCompoundRaw" . postFix, kUndefined)

					if (tyreCompound != kUndefined)
						if tyreCompound {
							tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

							if tyreCompound {
								splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

								setMultiMapValue(data, section, "TyreCompound" . postFix, tyreCompound)
								setMultiMapValue(data, section, "TyreCompoundColor" . postFix, tyreCompoundColor)
							}
						}
						else {
							setMultiMapValue(data, section, "TyreCompound" . postFix, false)
							setMultiMapValue(data, section, "TyreCompoundColor" . postFix, false)
						}
				}
			}

		return data
	}
}