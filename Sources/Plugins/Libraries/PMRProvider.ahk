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
			return {Connector: {Type: "CLR", Protocol: "UDP"
							  , File: kBinariesDirectory . "Connectors\PMR UDP Connector.dll"
							  , Instance: "PMRUDPConnector.PMRUDPConnector"}
				  , Provider: {Type: "EXE", Protocol: "UDP"
							 , File: kBinariesDirectory . "Providers\PMR UDP Provider.exe"}}
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("PMR", PMRProvider)
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