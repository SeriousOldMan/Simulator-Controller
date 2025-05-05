;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Provider                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EProvider extends SimulatorProvider {
	static sCarDB := false
	static sClassDB := false

	Simulator {
		Get {
			return "RaceRoom Racing Experience"
		}
	}

	__New(arguments*) {
		if isSet(R3EPlugin)
			Task.startTask(ObjBindMethod(R3EProvider, "loadDatabase"), 1000, kLowPriority)

		super.__New(arguments*)
	}

	static loadDatabase() {
		local data

		if !R3EProvider.sCarDB {
			data := JSON.parse(FileRead(kResourcesDirectory . "Simulator Data\R3E\r3e-data.json", "UTF-8"))

			R3EProvider.sClassDB := data["classes"]
			R3EProvider.sCarDB := data["cars"]
		}
	}

	supportsPitstop(&refuelService?, &tyreService?, &mixedCompounds?, &tyreSets?, &repairService?) {
		refuelService := true
		tyreService := "Axle"
		mixedCompounds := false
		tyreSets := false
		repairService := ["Bodywork", "Suspension"]

		return true
	}

	supportsTrackMap() {
		return true
	}

	getCarName(carID) {
		local carDB

		static lastCarID := false
		static lastCarName := false

		if !R3EProvider.sCarDB
			R3EProvider.loadDatabase()

		if (carID != lastCarID) {
			carDB := R3EProvider.sCarDB

			lastCarID := carID
			lastCarName := (carDB.Has(carID) ? carDB[carID]["Name"] : "Unknown")
		}

		return lastCarName
	}

	getClassName(classID) {
		local classDB

		static lastClassID := false
		static lastClassName := false

		if !R3EProvider.sClassDB
			R3EProvider.loadDatabase()

		if (classID != lastClassID) {
			classDB := R3EProvider.sClassDB

			lastClassID := classID
			lastClassName := (classDB.Has(classID) ? classDB[classID]["Name"] : "Unknown")
		}

		return lastClassName
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()

		setMultiMapValue(data, "Session Data", "Car", this.getCarName(getMultiMapValue(data, "Session Data", "Car", "")))

		return data
	}

	acquireStandingsData(telemetryData, finished := false) {
		local data := super.acquireStandingsData(telemetryData, finished)
		local carID

		loop getMultiMapValue(data, "Position Data", "Car.Count", 0) {
			carID := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Car", kUndefined)

			if (carID != kUndefined) {
				setMultiMapValue(data, "Position Data", "Car." . A_Index . ".Car", this.getCarName(carID))

				setMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class"
									 , this.getClassName(getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class")))
			}
		}

		return data
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, postFix

		static tyres := ["Front", "Rear"]

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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EProvider() {
	if !isSet(R3EPlugin)
		Task.startTask(ObjBindMethod(R3EProvider, "loadDatabase"), 1000, kLowPriority)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EProvider()