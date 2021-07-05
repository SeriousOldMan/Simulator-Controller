;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AMS2 Plugin                     ;;;
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

global kAMS2Application = "Automobilista 2"

global kAMS2Plugin = "AMS2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AMS2Plugin extends RaceAssistantSimulatorPlugin {
	iOpenICMHotkey := false
	
	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false
	
	iChangeTyresChosen := 0
	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true
	
	OpenICMHotkey[] {
		Get {
			return this.iOpenICMHotkey
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
		
		this.iOpenICMHotkey := this.getArgumentValue("openICMHotkey", "I")
		
		this.iPreviousOptionHotkey := this.getArgumentValue("previousOptionHotkey", "Z")
		this.iNextOptionHotkey := this.getArgumentValue("nextOptionHotkey", "H")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoiceHotkey", "G")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoiceHotkey", "J")
		
		SetKeyDelay 5, 15
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"}
		selectActions := []
	}
	
	supportsPitstop() {
		return true
	}
	
	openPitstopMFD(descriptor := false) {
		static reported := false
		
		if !this.OpenICMHotkey {
			if !reported {
				reported := true
			
				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
			
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
			
			return false
		}
		
		SendEvent % this.OpenICMHotkey
		
		return true
	}
	
	closePitstopMFD(option := false) {
		if (option = "Change Tyres") {
			SendEvent % this.PreviousOptionHotkey
		}
		else if (option = "Refuel") {
			SendEvent % this.PreviousOptionHotkey
			SendEvent % this.PreviousOptionHotkey
		}
		else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
			Loop 3
				SendEvent % this.PreviousOptionHotkey
		}
		
		SendEvent % this.NextChoiceHotkey
		SendEvent % this.PreviousOptionHotkey
		SendEvent % this.PreviousOptionHotkey
		SendEvent % this.NextChoiceHotkey
		SendEvent % this.NextOptionHotkey
		SendEvent % this.NextChoiceHotkey
	}
	
	requirePitstopMFD() {
		return this.openPitstopMFD()
	}
	
	selectPitstopOption(option) {
		SendEvent % this.PreviousOptionHotkey
		SendEvent % this.NextChoiceHotkey
		SendEvent % this.NextOptionHotkey
		SendEvent % this.NextOptionHotkey
		SendEvent % this.NextChoiceHotkey
		
		if (option = "Change Tyres") {
			SendEvent % this.NextOptionHotkey
			
			return true
		}
		else if (option = "Refuel") {
			SendEvent % this.NextOptionHotkey
			SendEvent % this.NextOptionHotkey
			
			return true
		}
		else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
			Loop 3
				SendEvent % this.NextOptionHotkey
			
			return true
		}
		else {
			SendEvent % this.NextChoiceHotkey
			SendEvent % this.PreviousOptionHotkey
			SendEvent % this.PreviousOptionHotkey
			SendEvent % this.NextChoiceHotkey
			SendEvent % this.NextOptionHotkey
			SendEvent % this.NextChoiceHotkey
			
			return false
		}
	}
	
	changePitstopOption(option, action := "Increase", steps := 1) {
		if (option = "Refuel") {
			this.dialPitstopOption("Refuel", action, steps)
			
			this.closePitstopMFD("Refuel")
		}
		else if (option = "Change Tyres") {
			this.iChangeTyresChosen += 1
		
			if (this.iChangeTyresChosen > 2)
				this.iChangeTyresChosen := 0
			
			this.dialPitstopOption("Change Tyres", "Decrease", 4)
			
			if this.iChangeTyresChosen
				this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)
			
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
			
			this.closePitstopMFD("Repair Suspension")
		}
		else
			Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.changePitstopOption..."
	}
	
	dialPitstopOption(option, action, steps := 1) {
		switch action {
			case "Increase":
				Loop %steps%
					SendEvent % this.NextChoiceHotkey
			case "Decrease":
				Loop %steps%
					SendEvent % this.PreviousChoiceHotkey
			default:
				Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.dialPitstopOption..."
		}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		if this.selectPitstopOption("Refuel") {
			changePitstopOption("Refuel", "Decrease", 200)
			changePitstopOption("Refuel", "Increase", Round(litres))
		}
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if this.selectPitstopOption("Change Tyres") {
			this.dialPitstopOption("Change Tyres", "Decrease", 4)
			
			if (compound = "Dry")
				this.iChangeTyresChosen := 1
			else if (compound = "Wet")
				this.iChangeTyresChosen := 2
			
			this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)
				
			this.closePitstopMFD("Change Tyres")
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if (this.iRepairSuspensionChosen != repairSuspension) {
			if this.selectPitstopOption("Repair Suspension")
				this.changePitstopOption("Repair Suspension")
		}
		else if (this.iRepairBodyworkChosen != repairBodywork) {
			if this.selectPitstopOption("Repair Bodywork")
				this.changePitstopOption("Repair Bodywork")
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
	
	updateStandingsData(data) {
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
