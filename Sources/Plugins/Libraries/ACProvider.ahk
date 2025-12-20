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
	iCarMetaData := CaseInsenseMap()

	static sCarData := false

	static Simulator {
		Get {
			return "Assetto Corsa"
		}
	}

	Simulator {
		Get {
			return ACProvider.Simulator
		}
	}

	static Protocols {
		Get {
			local protocols := super.Protocols

			protocols.Connector := {Type: "CLR", Protocol: "SHM"
								  , File: kBinariesDirectory . "Connectors\AC SHM Connector.dll"
								  , Instance: "SHMConnector.SHMConnector"}

			return protocols
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("AC", ACProvider)
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

	__New(car, track) {
		super.__New(car, track)

		if !ACProvider.sCarData
			Task.startTask(ObjBindMethod(ACProvider, "requireCarDatabase"), 1000, kLowPriority)
	}

	static requireCarDatabase() {
		if !ACProvider.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\AC\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini"))

			ACProvider.sCarData := data
		}
	}

	acquireStandingsData(telemetryData, finished := false) {
		local simulator := this.Simulator
		local standingsData := super.acquireStandingsData(telemetryData, finished)
		local car

		ACProvider.requireCarDatabase()

		loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
			car := SessionDatabase.getCarCode(simulator
											, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car"))

			setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Class"
						   , getMultiMapValue(ACProvider.sCarData, "Car Classes", car, "Unknown"))
		}

		return standingsData
	}

	acquireTelemetryData() {
		local data := super.acquireTelemetryData()
		local simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		local track := getMultiMapValue(data, "Session Data", "Track", "")
		local layout := getMultiMapValue(data, "Session Data", "Layout", "")
		local extension := ""
		local forName, surName, nickName, name

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