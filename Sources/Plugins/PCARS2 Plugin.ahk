﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - PCARS2 Plugin                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPCARS2Application := "Project CARS 2"

global kPCARS2Plugin := "PCARS2"


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

	OpenPitstopMFDHotkey {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	PreviousOptionHotkey {
		Get {
			return this.iPreviousOptionHotkey
		}
	}

	NextOptionHotkey {
		Get {
			return this.iNextOptionHotkey
		}
	}

	PreviousChoiceHotkey {
		Get {
			return this.iPreviousChoiceHotkey
		}
	}

	NextChoiceHotkey {
		Get {
			return this.iNextChoiceHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "I")
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "Z")
			this.iNextOptionHotkey := this.getArgumentValue("nextOption", "H")
			this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "G")
			this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "J")
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "NoRefuel", "Refuel", "Refuel", "TyreCompound", "Tyre Compound"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension")
		selectActions := []
	}

	openPitstopMFD(descriptor := false) {
		static reported := false

		if !this.OpenPitstopMFDHotkey {
			if !reported {
				reported := true

				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

				if !kSilentMode
					showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

			return false
		}

		if this.activateWindow() {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.sendCommand(this.OpenPitstopMFDHotkey)

				return true
			}
			else
				return false
		}
		else
			return false
	}

	closePitstopMFD(option := false) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Tyre Compound")
				this.sendCommand(this.PreviousOptionHotkey)
			else if ((option = "Refuel") || (option = "No Refuel")) {
				this.sendCommand(this.PreviousOptionHotkey)
				this.sendCommand(this.PreviousOptionHotkey)
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				loop 3
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
			else if ((option = "Refuel") || (option = "No Refuel")) {
				this.sendCommand(this.NextOptionHotkey)
				this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				loop 3
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
			switch action, false {
				case "Increase":
					loop steps
						this.sendCommand(this.NextChoiceHotkey)
				case "Decrease":
					loop steps
						this.sendCommand(this.PreviousChoiceHotkey)
				default:
					throw "Unsupported change operation `"" . action . "`" detected in AMS2Plugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Refuel") {
				this.dialPitstopOption("Refuel", action, steps)

				this.closePitstopMFD("Refuel")
			}
			else if (option = "No Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 250)

				this.closePitstopMFD("Refuel")
			}
			else if (option = "Tyre Compound") {
				this.iTyreCompoundChosen += 1

				if (this.iTyreCompoundChosen > SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track).Length)
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
				throw "Unsupported change operation `"" . action . "`" detected in AMS2Plugin.changePitstopOption..."
		}
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if this.requirePitstopMFD()
			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 250)
				this.dialPitstopOption("Refuel", "Increase", Round(liters))

				this.closePitstopMFD("Refuel")
			}
	}

	setPitstopTyreCompound(pitstopNumber, compound, compoundColor := false, set := false) {
		local delta

		super.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)

		delta := this.tyreCompoundIndex(compound, compoundColor)

		if (!compound || delta)
			if this.requirePitstopMFD()
				if this.selectPitstopOption("Tyre Compound") {
					this.dialPitstopOption("Tyre Compound", "Decrease", 10)

					this.iTyreCompoundChosen := delta

					this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

					this.closePitstopMFD("Tyre Compound")
				}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.iRepairSuspensionChosen != repairSuspension)
			if this.requirePitstopMFD()
				if this.selectPitstopOption("Repair Suspension")
					this.changePitstopOption("Repair Suspension")

		if (this.iRepairBodyworkChosen != repairBodywork)
			if this.requirePitstopMFD()
				if this.selectPitstopOption("Repair Bodywork")
					this.changePitstopOption("Repair Bodywork")
	}

	prepareSettings(settings, data) {
		settings := super.prepareSettings(settings, data)

		if (getMultiMapValue(settings, "Simulator.Project CARS 2", "Pitstop.Service.Tyres", kUndefined) == kUndefined)
			setMultiMapValue(settings, "Simulator.Project CARS 2", "Pitstop.Service.Tyres", "Change")

		return settings
	}

	updateSession(session, force := false) {
		super.updateSession(session, force)

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

startPCARS2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kPCARS2Plugin).Simulator
													 , "Simulator Splash Images\PCARS2 Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePCARS2Plugin() {
	local controller := SimulatorController.Instance

	PCARS2Plugin(controller, kPCARS2Plugin, kPCARS2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePCARS2Plugin()
