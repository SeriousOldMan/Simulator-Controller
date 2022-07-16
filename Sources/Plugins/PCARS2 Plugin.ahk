;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - PCARS2 Plugin                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPCARS2Application = "Project CARS 2"

global kPCARS2Plugin = "PCARS2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class PCARS2Plugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false

	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false

	iTyreCompoundChosen := 0
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

		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "I")

		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "Z")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "H")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "G")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "J")

		SetKeyDelay 5, 15
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreCompound: "Tyre Compound", BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"}
		selectActions := []
	}

	supportsPitstop() {
		return true
	}

	supportsTrackMap() {
		return true
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
			this.sendCommand(this.OpenPitstopMFDHotkey)

			return true
		}
		else
			return false
	}

	closePitstopMFD(option := false) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Tyre Compound")
				this.sendCommand(this.PreviousOptionHotkey)
			else if (option = "Refuel") {
				this.sendCommand(this.PreviousOptionHotkey)
				this.sendCommand(this.PreviousOptionHotkey)
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendCommand(this.PreviousOptionHotkey)
			}

			this.sendCommand(this.NextChoiceHotkey)
			this.sendCommand(this.PreviousOptionHotkey)
			this.sendCommand(this.PreviousOptionHotkey)
			this.sendCommand(this.NextChoiceHotkey)
			this.sendCommand(this.NextOptionHotkey)
			this.sendCommand(this.NextChoiceHotkey)
		}
	}

	requirePitstopMFD() {
		return this.openPitstopMFD()
	}

	selectPitstopOption(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendCommand(this.PreviousOptionHotkey)
			this.sendCommand(this.NextChoiceHotkey)
			this.sendCommand(this.NextOptionHotkey)
			this.sendCommand(this.NextOptionHotkey)
			this.sendCommand(this.NextChoiceHotkey)

			if (option = "Tyre Compound") {
				this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Refuel") {
				this.sendCommand(this.NextOptionHotkey)
				this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else {
				this.sendCommand(this.NextChoiceHotkey)
				this.sendCommand(this.PreviousOptionHotkey)
				this.sendCommand(this.PreviousOptionHotkey)
				this.sendCommand(this.NextChoiceHotkey)
				this.sendCommand(this.NextOptionHotkey)
				this.sendCommand(this.NextChoiceHotkey)

				return false
			}
		}
		else
			return false
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			switch action {
				case "Increase":
					Loop %steps%
						this.sendCommand(this.NextChoiceHotkey)
				case "Decrease":
					Loop %steps%
						this.sendCommand(this.PreviousChoiceHotkey)
				default:
					Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Refuel") {
				this.dialPitstopOption("Refuel", action, steps)

				this.closePitstopMFD("Refuel")
			}
			else if (option = "Tyre Compound") {
				this.iTyreCompoundChosen += 1

				if (this.iTyreCompoundChosen > new SessionDatabase().getTyreCompounds(this.Simulator[true]
																					, this.Car
																					, this.Track).Length())
					this.iTyreCompoundChosen := 0

				this.dialPitstopOption("Tyre Compound", "Decrease", 10)

				if this.iTyreCompoundChosen
					this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

				this.closePitstopMFD("Tyre Compound")
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
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		base.setPitstopRefuelAmount(pitstopNumber, litres)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(litres))

				this.closePitstopMFD("Refuel")
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		base.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off") {
			delta := this.tyreCompoundIndex(compound, compoundColor)

			if (!compound || delta) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Tyre Compound") {
					this.dialPitstopOption("Tyre Compound", "Decrease", 10)

					this.iTyreCompoundChosen := delta

					this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

					this.closePitstopMFD("Tyre Compound")
				}
			}
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		base.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

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
			this.iTyreCompoundChosen := 0
			this.iRepairSuspensionChosen := true
			this.iRepairBodyworkChosen := true
		}
	}

	updatePositionsData(data) {
		base.updatePositionsData(data)

		standings := readSimulatorData(this.Code, "-Standings")

		setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startPCARS2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kPCARS2Plugin).Simulator
													 , "Simulator Splash Images\PCARS2 Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePCARS2Plugin() {
	local controller := SimulatorController.Instance

	new PCARS2Plugin(controller, kPCARS2Plugin, kPCARS2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePCARS2Plugin()
