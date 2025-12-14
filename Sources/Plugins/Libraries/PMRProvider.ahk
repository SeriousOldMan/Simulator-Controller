;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - PMR Provider                    ;;;
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

class PMRProvider extends SimulatorProvider {
	static sMultiCastGroup := false
	static sMultiCastPort := false
	static sMultiCast := true

	static Simulator {
		Get {
			return "Project Motor Racing"
		}
	}

	Simulator {
		Get {
			return PMRProvider.Simulator
		}
	}

	static Protocols {
		Get {
			local arguments := [PMRProvider.sMultiCastGroup, PMRProvider.sMultiCastPort, PMRProvider.sMultiCast]

			return {Connector: {Type: "CLR", Protocol: "UDP"
							  , File: kBinariesDirectory . "Connectors\PMR UDP Connector.dll"
							  , Instance: "PMRUDPConnector.PMRUDPConnector", Arguments: arguments}
				  , Provider: {Type: "EXE", Protocol: "UDP"
							 , File: kBinariesDirectory . "Providers\PMR UDP Provider.exe", Arguments: arguments}
				  , Spotter: {Type: "EXE", Protocol: "UDP"
							, File: kBinariesDirectory . "Providers\PMR UDP Spotter.exe", Arguments: arguments}
				  , Coach: {Type: "EXE", Protocol: "UDP"
						  , File: kBinariesDirectory . "Providers\PMR UDP Coach.exe", Arguments: arguments}}
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("PMR", PMRProvider)
	}

	__New(arguments*) {
		local configuration

		if !PMRProvider.sMultiCastGroup {
			configuration := readMultiMap(kUserConfigDirectory . "PMR Configuration.ini")

			PMRProvider.sMultiCastGroup := getMultiMapValue(configuration, "UDP", "MultiCastGroup", "224.0.0.150")
			PMRProvider.sMultiCastPort := getMultiMapValue(configuration, "UDP", "Port", 7576)
			PMRProvider.sMultiCast := getMultiMapValue(configuration, "UDP", "MultiCast", true)
		}

		super.__New(arguments*)
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