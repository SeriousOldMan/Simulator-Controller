;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RF2 Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\Simulator Plugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRF2Application = "rFactor 2"

global kRF2Plugin = "RF2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RF2Plugin extends RaceEngineerSimulatorPlugin {
	sendPitstopCommand(command, arguments*) {
		simulator := this.Code
		arguments := values2String(";", arguments*)
		
		exePath := kBinariesDirectory . this.Code . " SHM Reader.exe"
	
		try {
			RunWait %ComSpec% /c ""%exePath%" -Pitstop "%command%:%arguments%"", , Hide
		}
		catch exception {
			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% SHM Reader ("), {simulator: simulator})
													   . exePath . translate(") - please rebuild the applications in the binaries folder (")
													   . kBinariesDirectory . translate(")"))
				
			showMessage(substituteVariables(translate("Cannot start %simulator% SHM Reader (%exePath%) - please check the configuration...")
										  , {exePath: exePath, simulator: simulator})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}
	
	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.sendPitstopCommand("Refuel", Round(litres))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.sendPitstopCommand("Tyre Compound", compound, compoundColor)
		
		if set
			this.sendPitstopCommand("Tyre Set", Round(set))
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.sendPitstopCommand("Tyre Pressure", pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if repairSuspension
			this.sendPitstopCommand("Repair", "Suspension")
		
		if repairBodywork
			this.sendPitstopCommand("Repair", "Bodywork")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRF2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kRF2Plugin).Simulator, "Simulator Splash Images\RF2 Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin() {
	local controller := SimulatorController.Instance
	
	new RF2Plugin(controller, kRF2Plugin, kRF2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin()
