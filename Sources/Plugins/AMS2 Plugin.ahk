;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AMS2 Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAMS2Application = "Automobilista 2"

global kAMS2Plugin = "AMS2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AMS2Plugin extends RaceAssistantSimulatorPlugin {
	iCommandMode := "Event"
	
	iOpenPitstopMFDHotkey := false
	
	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false
	
	iChangeTyresChosen := 0
	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true
	
	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
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
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "I")
		
		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "Z")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "H")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "G")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "J")
		
		SetKeyDelay 5, 15
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"}
		selectActions := []
	}
	
	supportsPitstop() {
		return true
	}
	
	sendPitstopCommand(command) {
		switch this.iCommandMode {
			case "Event":
				SendEvent %command%
			case "Input":
				SendInput %command%
			case "Play":
				SendPlay %command%
			case "Raw":
				SendRaw %command%
			default:
				Send %command%
		}
		
		Sleep 20
	}
	
	openPitstopMFD(descriptor := false) {
		static reported := false
		
		if !this.OpenPitstopMFDHotkey {
			if !reported {
				reported := true
			
				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
			
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			return false
		}
		
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendPitstopCommand(this.OpenPitstopMFDHotkey)
			
			return true
		}
		else
			return false
	}
	
	closePitstopMFD(option := false) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Change Tyres")
				this.sendPitstopCommand(this.PreviousOptionHotkey)
			else if (option = "Refuel") {
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendPitstopCommand(this.PreviousOptionHotkey)
			}
			
			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
		}
	}
	
	requirePitstopMFD() {
		return this.openPitstopMFD()
	}
	
	selectPitstopOption(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
			
			if (option = "Change Tyres") {
				this.sendPitstopCommand(this.NextOptionHotkey)
				
				return true
			}
			else if (option = "Refuel") {
				this.sendPitstopCommand(this.NextOptionHotkey)
				this.sendPitstopCommand(this.NextOptionHotkey)
				
				return true
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendPitstopCommand(this.NextOptionHotkey)
				
				return true
			}
			else {
				this.sendPitstopCommand(this.NextChoiceHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.NextChoiceHotkey)
				this.sendPitstopCommand(this.NextOptionHotkey)
				this.sendPitstopCommand(this.NextChoiceHotkey)
				
				return false
			}
		}
		else
			return false
	}
	
	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Refuel") {
				this.dialPitstopOption("Refuel", action, steps)
				
				Sleep 2000
				
				this.closePitstopMFD("Refuel")
			}
			else if (option = "Change Tyres") {
				this.iChangeTyresChosen += 1
			
				if (this.iChangeTyresChosen > 2)
					this.iChangeTyresChosen := 0
				
				this.dialPitstopOption("Change Tyres", "Decrease", 10)
				
				if this.iChangeTyresChosen
					this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)
				
				Sleep 2000
				
				this.closePitstopMFD("Change Tyres")
			}
			else if (option = "Repair Bodywork") {
				this.dialPitstopOption("Repair Bodywork", "Decrease", 4)
			
				this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
				
				if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
					this.dialPitstopOption("Repair All", "Increase", 3)
				else if this.iRepairBodyworkChosen
					this.dialPitstopOption("Repair Bodywork", "Increase", 1)
				else if this.iRepairSuspensionChosen
					this.dialPitstopOption("Repair Suspension", "Increase", 2)
				
				Sleep 2000
				
				this.closePitstopMFD("Repair Bodywork")
			}
			else if (option = "Repair Suspension") {
				this.dialPitstopOption("Repair Suspension", "Decrease", 4)
			
				this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
				
				if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
					this.dialPitstopOption("Repair All", "Increase", 3)
				else if this.iRepairBodyworkChosen
					this.dialPitstopOption("Repair Bodywork", "Increase", 1)
				else if this.iRepairSuspensionChosen
					this.dialPitstopOption("Repair Suspension", "Increase", 2)
				
				Sleep 2000
				
				this.closePitstopMFD("Repair Suspension")
			}
			else
				Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.changePitstopOption..."
		}
	}
	
	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			switch action {
				case "Increase":
					Loop %steps%
						this.sendPitstopCommand(this.NextChoiceHotkey)
				case "Decrease":
					Loop %steps%
						this.sendPitstopCommand(this.PreviousChoiceHotkey)
				default:
					Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.dialPitstopOption..."
			}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.requirePitstopMFD()
		
		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(litres))
				
				Sleep 2000
				
				this.closePitstopMFD("Refuel")
			}
		}
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		this.requirePitstopMFD()
		
		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.selectPitstopOption("Change Tyres") {
				this.dialPitstopOption("Change Tyres", "Decrease", 10)
				
				if (compound = "Dry")
					this.iChangeTyresChosen := 1
				else if (compound = "Wet")
					this.iChangeTyresChosen := 2
				else
					this.iChangeTyresChosen := 0
				
				this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)
					
				Sleep 2000
				
				this.closePitstopMFD("Change Tyres")
			}
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (this.iRepairSuspensionChosen != repairSuspension) {
				this.requirePitstopMFD()
			
				if this.selectPitstopOption("Repair Suspension")
					this.changePitstopOption("Repair Suspension")
			}
			
			if (this.iRepairBodyworkChosen != repairBodywork) {
				this.requirePitstopMFD()
			
				if this.selectPitstopOption("Repair Bodywork")
					this.changePitstopOption("Repair Bodywork")
			}
		}
	}
	
	updateSessionState(sessionState) {
		base.updateSessionState(sessionState)
		
		if (sessionState == kSessionFinished) {
			this.iChangeTyresChosen := 0
			this.iRepairSuspensionChosen := true
			this.iRepairBodyworkChosen := true
		}
	}
	
	updatePositionsData(data) {
		standings := readSimulatorData(this.Code, "-Standings")
		
		setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAMS2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kAMS2Plugin).Simulator, "Simulator Splash Images\AMS2 Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeAMS2Plugin() {
	local controller := SimulatorController.Instance
	
	new AMS2Plugin(controller, kAMS2Plugin, kAMS2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeAMS2Plugin()
