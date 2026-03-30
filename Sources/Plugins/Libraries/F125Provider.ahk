;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - F125 Provider                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class F125Provider extends SimulatorProvider {
	static sMultiCastGroup := false
	static sMultiCastPort := false
	static sMultiCast := true

	static Simulator {
		Get {
			return "F1 25"
		}
	}

	Simulator {
		Get {
			return F125Provider.Simulator
		}
	}

	static Protocols {
		Get {
			local arguments

			if !F125Provider.sMultiCastGroup {
				configuration := readMultiMap(kUserConfigDirectory . "F125 Configuration.ini")

				F125Provider.sMultiCastGroup := getMultiMapValue(configuration, "UDP", "MultiCastGroup", "127.0.0.1")
				F125Provider.sMultiCastPort := getMultiMapValue(configuration, "UDP", "Port", 20777)
				F125Provider.sMultiCast := getMultiMapValue(configuration, "UDP", "MultiCast", true)
			}

			arguments := [F125Provider.sMultiCastGroup, F125Provider.sMultiCastPort, F125Provider.sMultiCast]

			return {Connector: {Type: "CLR", Protocol: "UDP"
							  , File: kBinariesDirectory . "Connectors\F125 UDP Connector.dll"
							  , Instance: "F125UDPConnector.F125UDPConnector", Arguments: arguments}
				  , Provider: {Type: "EXE", Protocol: "UDP"
							 , File: kBinariesDirectory . "Providers\F125 UDP Provider.exe", Arguments: arguments}
				  , Spotter: {Type: "EXE", Protocol: "UDP"
							, File: kBinariesDirectory . "Providers\F125 UDP Spotter.exe", Arguments: arguments}
				  , Coach: {Type: "EXE", Protocol: "UDP"
						  , File: kBinariesDirectory . "Providers\F125 UDP Coach.exe", Arguments: arguments}}
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("F125", F125Provider)
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := false
		tyreService := false
		brakeService := false
		repairService := []

		return false
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := false
		tyreSets := false

		return true
	}

	supportsTrackMap() {
		return true
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, section, postFix

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