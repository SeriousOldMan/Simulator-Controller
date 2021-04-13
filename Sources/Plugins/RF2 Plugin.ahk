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
	sendPitstopCommand(command, message := false, arguments*) {
		static counter := 1
		
		simulator := this.Code
		arguments := values2String(";", arguments*)
		
		exePath := kBinariesDirectory . this.Code . " SHM Reader.exe"
	
		try {
			if message
				RunWait %ComSpec% /c ""%exePath%" -%command% "%message%:%arguments%" > "%kTempDirectory%Pitstop%counter%.out"", , Hide
			else
				RunWait %ComSpec% /c ""%exePath%" -%command% > "%kTempDirectory%Pitstop%counter%.out"", , Hide
			
			counter += 1
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
	
	supportsPitstop() {
		return true
	}
	
	startPitstopSetup(pitstopNumber) {
		this.sendPitstopCommand("Setup")
	}

	finishPitstopSetup(pitstopNumber) {
		this.sendPitstopCommand("Setup")
	}
	
	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.sendPitstopCommand("Pitstop", "Refuel", Round(litres))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set := false) {
		this.sendPitstopCommand("Pitstop", "Tyre Compound", compound, compoundColor)
		
		if set
			this.sendPitstopCommand("Pitstop", "Tyre Set", Round(set))
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.sendPitstopCommand("Pitstop", "Tyre Pressure", Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (repairBodywork && repairSuspension)
			this.sendPitstopCommand("Pitstop", "Repair", "Both")
		else if repairSuspension
			this.sendPitstopCommand("Pitstop", "Repair", "Suspension")
		else if repairBodywork
			this.sendPitstopCommand("Pitstop", "Repair", "Bodywork")
		else
			this.sendPitstopCommand("Pitstop", "Repair", "Nothing")
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
