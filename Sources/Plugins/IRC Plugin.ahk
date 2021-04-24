;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - iRacing Plugin                  ;;;
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

global kIRCApplication = "iRacing"

global kIRCPlugin = "IRC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IRCPlugin extends RaceEngineerSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}
	
	ClosePitstopMFDHotkey[] {
		Get {
			return this.iClosePitstopMFDHotkey
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreCompound: "Tyre Compound", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , RepairRequest: "Repair"}
		selectActions := []
	}
	
	sendPitstopCommand(command, operation := false, message := false, arguments*) {
		simulator := this.Code
		arguments := values2String(";", arguments*)
		
		exePath := kBinariesDirectory . this.Code . " SHM Reader.exe"
	
		try {
			if operation
				RunWait %ComSpec% /c ""%exePath%" -%command% "%operation%:%message%:%arguments%"", , Hide
			else
				RunWait %ComSpec% /c ""%exePath%" -%command%", , Hide
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
		return false
	}
	
	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(litres))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if compound {
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", compound, compoundColor)
			
			if set
				this.sendPitstopCommand("Pitstop", "Set", "Tyre Set", Round(set))
		}
		else
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", "None")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure", Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (repairBodywork && repairSuspension)
			this.sendPitstopCommand("Pitstop", "Set", "Repair", "Both")
		else if repairSuspension
			this.sendPitstopCommand("Pitstop", "Set", "Repair", "Suspension")
		else if repairBodywork
			this.sendPitstopCommand("Pitstop", "Set", "Repair", "Bodywork")
		else
			this.sendPitstopCommand("Pitstop", "Set", "Repair", "Nothing")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startIRC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kIRCPlugin).Simulator, "Simulator Splash Images\IRC Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin() {
	local controller := SimulatorController.Instance
	
	new IRCPlugin(controller, kIRCPlugin, kIRCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin()
