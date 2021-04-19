;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\Simulator Plugin.ahk
#Include ..\Libraries\JSON.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kR3EApplication = "RaceRoom Racing Experience"

global kR3EPlugin = "R3E"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kBinaryOptions = ["Repair Aero Front", "Repair Aero Rear", "Repair Suspension"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EPlugin extends RaceEngineerSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false
	iAcceptChoiceHotkey := false
	
	iPitstopMFDIsOpen := false
	
	iPitstopRefuelEntered := false
	
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
	
	PreviousOptionHotkey[] {
		Get {
			return this.iPreviousOptionHotkey
		}
	}
	
	NextOptionHotkey[] {
		Get {
			return this.iNextOptionHotkey
		}
	}
	
	PreviousChoiceHotkey[] {
		Get {
			return this.iPreviousChoiceHotkey
		}
	}
	
	NextChoiceHotkey[] {
		Get {
			return this.iNextChoiceHotkey
		}
	}
	
	AcceptChoiceHotkey[] {
		Get {
			return this.iAcceptChoiceHotkey
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iPitstopMode := this.findMode(kPitstopMode)
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		this.iPreviousOptionHotkey := this.getArgumentValue("previousOptionHotkey", "W")
		this.iNextOptionHotkey := this.getArgumentValue("nextOptionHotkey", "S")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoiceHotkey", "A")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoiceHotkey", "D")
		this.iAcceptChoiceHotkey := this.getArgumentValue("acceptChoiceHotkey", "{Enter}")
		
		controller.registerPlugin(this)
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", AeroFrontRepair: "Repair Aero Front", AeroFrontRepair: "Repair Aero Rear", SuspensionRepair: "Repair Suspension"}
		selectActions := ["AeroFrontRepair", "AeroRearRepair", "SuspensionRepair"]
	}
	
	updateSessionState(sessionState) {
		base.updateSessionState(sessionState)
		
		activeModes := this.Controller.ActiveModes
		
		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(sessionState)
		
		if (sessionState == kSessionFinished) {
			this.iPitstopRefuelEntered := false
			this.iPitstopMFDIsOpen := false
		}
	}
	
	activateR3EWindow() {
		window := this.Simulator.WindowTitle
		
		if !WinActive(window)
			WinActivate %window%
		
		WinWaitActive %window%, , 2
	}
		
	openPitstopMFD() {
		static reported := false
		
		if !this.iPitstopMFDIsOpen {
			this.activateR3EWindow()

			if this.OpenPitstopMFDHotkey {
				SendEvent % this.OpenPitstopMFDHotkey
			
				this.iPitstopMFDIsOpen := true
				
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
		else
			return true
	}
	
	closePitstopMFD() {
		static reported := false
		
		if this.iPitstopMFDIsOpen {
			this.activateR3EWindow()

			if this.ClosePitstopMFDHotkey {
				SendEvent % this.ClosePitstopMFDHotkey
			
				this.iPitstopMFDIsOpen := false
			}
			else if !reported {
				reported := true
			
				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
			
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
	
	requirePitstopMFD() {
		this.closePitstopMFD()
		
		return this.openPitstopMFD()
	}
	
	availableOptions() {
		return ["Refuel"]
	}
	
	optionChosen(option) {
		return false
	}
	
	dialPitstopOption(option, action, steps := 1) {
		switch action {
			case "Increase":
				hotKey := (inList(kBinaryOptions, option) ? this.AcceptChoiceHotkey : this.NextChoiceHotkey)
				
				Loop %steps% {
					this.activateR3EWindow()

					SendEvent %hotKey%

					Sleep 50
				}
			case "Decrease":
				hotKey := (inList(kBinaryOptions, option) ? this.AcceptChoiceHotkey : this.PreviousChoiceHotkey)
				
				Loop %steps% {
					this.activateR3EWindow()

					SendEvent %hotKey%
					
					Sleep 50
				}
			default:
				Throw "Unsupported change operation """ . action . """ detected in R3EPlugin.dialPitstopOption..."
		}
	}
	
	selectPitstopOption(option) {
		this.activateR3EWindow()
		
		index := inList(this.availableOptions(), option)
		
		if index {
			index -= 1
			
			hotkey := this.NextOptionHotkey
			
			Loop %index% {
				this.activateR3EWindow()

				SendEvent %hotKey%

				Sleep 50
			}
			
			return true
		}
		else
			return false
	}
	
	changePitstopOption(option, action, steps := 1) {
		if (option = "Refuel")
			this.changeFuelAmount(action, steps, true)
		else if inList(kBinaryOptions, option)
			this.toggleActivity(option, true)
		else
			Throw "Unsupported change operation """ . action . """ detected in RaceEngineerSimulatorPlugin.changePitstopOption..."
	}
	
	toggleActivity(activity, internal := false) {
		if (internal || this.requirePitstopMFD())
			if inList(kBinaryOptions, activity) {
				if  (internal || this.selectPitstopOption(activity))
					this.dialPitstopOption(activity, "Increase")
			}
			else
				Throw "Unsupported activity """ . activity . """ detected in R3EPlugin.toggleActivity..."
	}

	changeFuelAmount(direction, litres := 5, internal := false) {
		if (internal || (this.requirePitstopMFD() && this.selectPitstopOption("Refuel"))) {
			if this.iPitstopRefuelEntered
				SendEvent % this.AcceptChoiceHotkey

			this.dialPitstopOption("Refuel", direction, litres)

			SendEvent % this.AcceptChoiceHotkey
			
			this.iPitstopRefuelEntered := true
		}
	}
	
	supportsPitstop() {
		return true
	}
	
	pitstopFinished(pitstopNumber) {
		this.iPitstopMFDIsOpen := false
		this.iPitstopRefuelEntered := false
	}
	
	startPitstopSetup(pitstopNumber) {
		; Pitstop Dialog komplett zurücksetzen
	}

	finishPitstopSetup(pitstopNumber) {
		this.closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		if inList(this.availableOptions(), "Refuel")
			this.changeFuelAmount("Increase", litres + 2)
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if inList(this.availableOptions(), "Repair Suspension")
			if (repairSuspension != this.chosenOption("Repair Suspension"))
				this.toggleActivity("Repair Suspension")
		
		if inList(this.availableOptions(), "Repair Aero Front")
			if (repairBodywork != this.chosenOption("Repair Aero Front"))
				this.toggleActivity("Repair Aero Front")
		
		if inList(this.availableOptions(), "Repair Aero Rear")
			if (repairBodywork != this.chosenOption("Repair Aero Rear"))
				this.toggleActivity("Repair Aero Rear")
	}
	
	updateSimulatorData(data) {
		static carDB := false
		static lastCarID := false
		static lastCarName := false
		
		if !carDB {
			FileRead script, %kResourcesDirectory%Simulator Data\R3E\r3e-data.json
			
			carDB := JSON.parse(script)["cars"]
		}
		
		carID := getConfigurationValue(data, "Session Data", "Car", "")
		
		if (carID = lastCarID)
			setConfigurationValue(data, "Session Data", "Car", lastCarName)
		else {
			lastCarID := carID
			lastCarName := (carDB.HasKey(carID) ? carDB[carID]["Name"] : "Unknown")
			
			setConfigurationValue(data, "Session Data", "Car", lastCarName)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startR3E() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kR3EPlugin).Simulator, "Simulator Splash Images\R3E Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin() {
	local controller := SimulatorController.Instance
	
	new R3EPlugin(controller, kR3EPlugin, kR3EApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin()
