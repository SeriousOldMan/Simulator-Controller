;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - iRacing Plugin                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kIRCApplication = "iRacing"

global kIRCPlugin = "IRC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IRCPlugin extends RaceAssistantSimulatorPlugin {
	iCurrentPitstopMFD := false
	
	iPitstopFuelMFDHotkey := false
	iPitstopTyreMFDHotkey := false
	
	PitstopFuelMFDHotkey[] {
		Get {
			return this.iPitstopFuelMFDHotkey
		}
	}
	
	PitstopTyreMFDHotkey[] {
		Get {
			return this.iPitstopTyreMFDHotkey
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iPitstopFuelMFDHotkey := this.getArgumentValue("togglePitstopFuelMFD", false)
		this.iPitstopTyreMFDHotkey := this.getArgumentValue("togglePitstopTyreMFD", false)
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , RepairRequest: "Repair"}
		selectActions := []
	}
	
	sendPitstopCommand(command, operation := false, message := false, arguments*) {
		simulator := this.Code
		arguments := values2String(";", arguments*)
		
		exePath := kBinariesDirectory . simulator . " SHM Provider.exe"
	
		try {
			if operation
				RunWait %ComSpec% /c ""%exePath%" -%command% %operation% "%message%:%arguments%"", , Hide
			else
				RunWait %ComSpec% /c ""%exePath%" -%command%", , Hide
		}
		catch exception {
			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"})
													   . exePath . translate(") - please rebuild the applications in the binaries folder (")
													   . kBinariesDirectory . translate(")"))
				
			showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
										  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}
	
	openPitstopMFD(descriptor := false) {
		static reported := false
		key := false
		
		if !this.iCurrentPitstopMFD {
			if (!descriptor || (descriptor = "Fuel"))
				key := this.PitstopFuelMFDHotkey
			else if (descriptor = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else
				Throw "Unsupported Pitstop MFD detected in IRCPlugin.openPitstopMFD..."
			
			if key {
				SendEvent % key
				
				this.iCurrentPitstopMFD := descriptor
				
				return true
			}
			else if !reported {
				reported := true
			
				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
			
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
						  
				return false
			}
		}
	}
	
	closePitstopMFD() {
		key := false
		
		if this.iCurrentPitstopMFD {
			if (this.iCurrentPitstopMFD = "Fuel")
				key := this.PitstopFuelMFDHotkey
			else if (this.iCurrentPitstopMFD = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else {
				this.iCurrentPitstopMFD := false
			
				Throw "Unsupported Pitstop MFD detected in IRCPlugin.closePitstopMFD..."
			}
			
			SendEvent % key
			
			this.iCurrentPitstopMFD := false
		}
	}
	
	requirePitstopMFD() {
		return true
	}
	
	selectPitstopOption(option) {
		actions := false
		ignore := false
		
		this.getPitstopActions(actions, ignore)
		
		for ignore, candidate in actions
			if (candidate = option)
				return true
			
		return false
	}
	
	changePitstopOption(option, action, steps := 1) {
		switch option {
			case "Refuel":
				this.sendPitstopCommand("Pitstop", "Change", "Refuel", (action = "Increase") ? Round(steps) : Round(steps * -1))
			case "Change Tyres":
				this.sendPitstopCommand("Pitstop", "Change", "Tyre Change", (action = "Increase") ? "true" : "false")
			case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
				this.sendPitstopCommand("Pitstop", "Change", option, Round(steps * 0.1 * ((action = "Increase") ? 1 : -1), 1))
			case "Repair":
				this.sendPitstopCommand("Pitstop", "Change", "Repair", (action = "Increase") ? "true" : "false")
		}
	}
	
	supportsPitstop() {
		return true
	}
	
	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(litres))
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		this.sendPitstopCommand("Pitstop", "Set", "Tyre Change", compound ? "true" : "false")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure", Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		this.sendPitstopCommand("Pitstop", "Set", "Repair", (repairBodywork || repairSuspension) ? "true" : "false")
	}
	
	updateStandingsData(data) {
		standings := readSimulatorData(this.Code, "-Standings")
		
		setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
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
