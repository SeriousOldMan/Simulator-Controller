;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACE Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACEApplication := "Rennsport"

global kACEPlugin := "ACE"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACEPlugin extends SimulatorPlugin {
	static sCarData := false

	static requireCarDatabase() {
		local data

		if !ACEPlugin.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\ACE\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini"))

			ACEPlugin.sCarData := data
		}
	}

	simulatorStartup(simulator) {
		if (simulator = kACEApplication)
			Task.startTask(ObjBindMethod(ACEPlugin, "requireCarDatabase"), 1000, kLowPriority)

		super.simulatorStartup(simulator)
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

	updateTelemetryData(data) {
		local brakePadThickness, frontBrakePadCompound, rearBrakePadCompound, brakePadWear

		super.updateTelemetryData(data)

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
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACE() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACEPlugin).Simulator
													 , "Simulator Splash Images\ACE Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACEPlugin() {
	local controller := SimulatorController.Instance

	ACEPlugin(controller, kACEPlugin, kACEApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACEPlugin()