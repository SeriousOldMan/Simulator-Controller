;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AMS2 Plugin                     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAMS2Application := "Automobilista 2"

global kAMS2Plugin := "AMS2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AMS2Plugin extends RaceAssistantSimulatorPlugin {
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

		if (this.Active || isDebug()) {
			this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "I")

			this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "Z")
			this.iNextOptionHotkey := this.getArgumentValue("nextOption", "H")
			this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "G")
			this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "J")
		}
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Strategy: "Strategy", Refuel: "Refuel", TyreCompound: "Tyre Compound"
					 , BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"
					 , DriverSwap: "Swap Driver"}
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
		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendCommand(this.PreviousChoiceHotkey)
	}

	requirePitstopMFD() {
		return this.openPitstopMFD()
	}

	selectPitstopOption(option) {
		local steps

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendCommand(this.NextChoiceHotkey)

			steps := false

			if (option = "Strategy")
				steps := 6
			else if (option = "Tyre Compound")
				steps := 5
			else if (option = "Refuel")
				steps := 4
			else if ((option = "Repair All") || (option = "Repair Bodywork") || (option = "Repair Suspension"))
				steps := 3
			else if (option = "Swap Driver")
				steps := 2
			else if (option = "Request Pitstop")
				steps := 1

			if steps {
				loop %steps%
					this.sendCommand(this.PreviousOptionHotkey)

				return true
			}
			else
				return false
		}
		else
			return false
	}

	deselectPitstopOption(option) {
		local steps

		if (this.OpenPitstopMFDHotkey != "Off") {
			steps := false

			if (option = "Strategy")
				steps := 6
			else if (option = "Tyre Compound")
				steps := 5
			else if (option = "Refuel")
				steps := 4
			else if ((option = "Repair All") || (option = "Repair Bodywork") || (option = "Repair Suspension"))
				steps := 3
			else if (option = "Swap Driver")
				steps := 2
			else if (option = "Request Pitstop")
				steps := 1

			loop %steps%
				this.sendCommand(this.NextOptionHotkey)

			this.sendCommand(this.NextChoiceHotkey)
		}
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			switch action {
				case "Increase":
					loop %steps%
						this.sendCommand(this.NextChoiceHotkey)
				case "Decrease":
					loop %steps%
						this.sendCommand(this.PreviousChoiceHotkey)
				default:
					throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if inList(["Strategy", "Refuel", "Swap Driver"], option) {
				this.dialPitstopOption(option, action, steps)

				this.deselectPitstopOption(option)
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

				this.deselectPitstopOption("Tyre Compound")
			}
			else if (option = "Repair Bodywork") {
				this.dialPitstopOption("Repair All", "Decrease", 4)

				this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen

				if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
					this.dialPitstopOption("Repair All", "Increase", 3)
				else if this.iRepairBodyworkChosen
					this.dialPitstopOption("Repair Bodywork", "Increase", 1)
				else if this.iRepairSuspensionChosen
					this.dialPitstopOption("Repair Suspension", "Increase", 2)

				this.deselectPitstopOption("Repair All")
			}
			else if (option = "Repair Suspension") {
				this.dialPitstopOption("Repair All", "Decrease", 4)

				this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen

				if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
					this.dialPitstopOption("Repair All", "Increase", 3)
				else if this.iRepairBodyworkChosen
					this.dialPitstopOption("Repair Bodywork", "Increase", 1)
				else if this.iRepairSuspensionChosen
					this.dialPitstopOption("Repair Suspension", "Increase", 2)

				this.deselectPitstopOption("Repair All")
			}
			else
				throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.changePitstopOption..."
		}
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		base.setPitstopRefuelAmount(pitstopNumber, liters)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(liters))

				this.deselectPitstopOption("Refuel")
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		local delta

		base.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off") {
			delta := this.tyreCompoundIndex(compound, compoundColor)

			if (!compound || delta) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Tyre Compound") {
					this.dialPitstopOption("Tyre Compound", "Decrease", 10)

					this.iTyreCompoundChosen := delta

					this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

					this.deselectPitstopOption("Tyre Compound")
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

	finishPitstopSetup(pitstopNumber) {
		base.finishPitstopSetup()

		this.requirePitstopMFD()

		if this.selectPitstopOption("Request Pitstop") {
			this.dialPitstopOption("Request Pitstop")

			this.deselectPitstopOption("Request Pitstop")
		}
	}

	updateSession(session) {
		base.updateSession(session)

		if (session == kSessionFinished) {
			this.iTyreCompoundChosen := 0
			this.iRepairSuspensionChosen := true
			this.iRepairBodyworkChosen := true
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAMS2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kAMS2Plugin).Simulator
													 , "Simulator Splash Images\AMS2 Splash.jpg")
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
