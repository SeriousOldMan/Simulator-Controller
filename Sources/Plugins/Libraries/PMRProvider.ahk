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
				   }
			/*
				  , Spotter: {Type: "EXE", Protocol: "UDP"
							, File: kBinariesDirectory . "Providers\PMR UDP Spotter.exe", Arguments: arguments}
				  , Coach: {Type: "EXE", Protocol: "UDP"
						  , File: kBinariesDirectory . "Providers\PMR UDP Coach.exe"}, Arguments: arguments}
			*/
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
}