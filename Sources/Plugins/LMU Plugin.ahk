;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "RF2 Plugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLMUApplication := "Le Mans Ultimate"

global kLMUPlugin := "LMU"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMUPlugin extends RF2Plugin {
	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false

	iRequestPitstopHotkey := false

	iTyreCompoundChosen := 0
	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true

	static sCarData := false

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

	RequestPitstopHotkey {
		Get {
			return this.iRequestPitstopHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "{Up}")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "{Down}")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "{Left}")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "{Right}")

		this.iRequestPitstopHotkey := this.getArgumentValue("requestPitstop", false)

		if this.RequestPitstopHotkey {
			this.iRequestPitstopHotkey := Trim(this.RequestPitstopHotkey)

			if (this.RequestPitstopHotkey = "")
				this.iRequestPitstopHotkey := false
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreCompoundFrontLeft", "Tyre Compound Front Left", "TyreCompoundFrontRight", "Tyre Compound Front Right"
								   , "TyreCompoundRearLeft", "Tyre Compound Rear Left", "TyreCompoundRearRight", "Tyre Compound Rear Right"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension"
								   , "BrakeChange", "Change Brakes", "DriverSelect", "Driver", "PitstopRequest", "Pitstop")

		selectActions := []
	}

	supportsSetupImport() {
		return false
	}

	static requireCarDatabase() {
		local data

		if !LMUPlugin.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\LMU\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\LMU\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\LMU\Car Data.ini"))

			LMUPlugin.sCarData := data
		}
	}

	requirePitstopMFD() {
		return this.openPitstopMFD()
	}

	selectPitstopOption(option) {
		local steps

		if (this.OpenPitstopMFDHotkey != "Off") {
			steps := false

			if ((option = "Refuel") || (option = "No Refuel"))
				steps := false
			else if (option = "Tyre Compound")
				steps := 2
			else if (option = "Tyre Compound Front Left")
				steps := 3
			else if (option = "Tyre Compound Front Right")
				steps := 4
			else if (option = "Tyre Compound Rear Left")
				steps := 5
			else if (option = "Tyre Compound Rear Right")
				steps := 6
			else if ((option = "All Around") || (option = "Front Left"))
				steps := 9
			else if (option = "Front Right")
				steps := 10
			else if (option = "Rear Left")
				steps := 11
			else if (option = "Rear Right")
				steps := 12
			else if ((option = "Repair All") || (option = "Repair Bodywork") || (option = "Repair Suspension"))
				steps := false
			else if (option = "Change Brakes")
				steps := 13

			if steps {
				loop steps
					this.sendCommand(this.NextOptionHotkey)

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

			if ((option = "Refuel") || (option = "No Refuel"))
				steps := false
			else if (option = "Tyre Compound")
				steps := 2
			else if (option = "Tyre Compound Front Left")
				steps := 3
			else if (option = "Tyre Compound Front Right")
				steps := 4
			else if (option = "Tyre Compound Rear Left")
				steps := 5
			else if (option = "Tyre Compound Rear Right")
				steps := 6
			else if ((option = "All Around") || (option = "Front Left"))
				steps := 9
			else if (option = "Front Right")
				steps := 10
			else if (option = "Rear Left")
				steps := 11
			else if (option = "Rear Right")
				steps := 12
			else if ((option = "Repair All") || (option = "Repair Bodywork") || (option = "Repair Suspension"))
				steps := false
			else if (option = "Change Brakes")
				steps := 13

			loop steps
				this.sendCommand(this.PreviousOptionHotkey)
		}
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
					throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Pitstop":
					if this.RequestPitstopHotKey
						this.sendCommand(this.RequestPitstopHotKey)
				case "Refuel":
					this.dialPitstopOption(option, action, steps)

					this.deselectPitstopOption(option)
				case "No Refuel":
					this.dialPitstopOption("Refuel", "Decrease", 250)

					this.deselectPitstopOption("Refuel")
				case "Tyre Compound":
					this.iTyreCompoundChosen += 1

					if (this.iTyreCompoundChosen > SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track).Length)
						this.iTyreCompoundChosen := 0

					this.dialPitstopOption("Tyre Compound", "Decrease", 10)

					if this.iTyreCompoundChosen
						this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

					this.deselectPitstopOption("Tyre Compound")
				case "All Around":
					this.dialPitstopOption("Front Left", action, 1)
					this.sendCommand(this.NextOptionHotkey)
					this.dialPitstopOption("Front Right", action, 1)
					this.sendCommand(this.NextOptionHotkey)
					this.dialPitstopOption("Rear Left", action, 1)
					this.sendCommand(this.NextOptionHotkey)
					this.dialPitstopOption("Rear Right", action, 1)

					this.sendCommand(this.PreviousOptionHotkey)
					this.sendCommand(this.PreviousOptionHotkey)
					this.sendCommand(this.PreviousOptionHotkey)

					this.deselectPitstopOption("Front Left")
				case "Front Left":
					this.dialPitstopOption("Front Left", action, 1)

					this.deselectPitstopOption("Front Left")
				case "Front Right":
					this.dialPitstopOption("Front Right", action, 1)

					this.deselectPitstopOption("Front Right")
				case "Rear Left":
					this.dialPitstopOption("Rear Left", action, 1)

					this.deselectPitstopOption("Rear Left")
				case "Rear Right":
					this.dialPitstopOption("Rear Right", action, 1)

					this.deselectPitstopOption("Rear Right")
				case "Repair Bodywork":
					this.dialPitstopOption("Repair All", "Decrease", 4)

					this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen

					if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
						this.dialPitstopOption("Repair All", "Increase", 3)
					else if this.iRepairBodyworkChosen
						this.dialPitstopOption("Repair Bodywork", "Increase", 1)
					else if this.iRepairSuspensionChosen
						this.dialPitstopOption("Repair Suspension", "Increase", 2)

					this.deselectPitstopOption("Repair All")
				case "Repair Suspension":
					this.dialPitstopOption("Repair All", "Decrease", 4)

					this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen

					if (this.iRepairBodyworkChosen && this.iRepairSuspensionChosen)
						this.dialPitstopOption("Repair All", "Increase", 3)
					else if this.iRepairBodyworkChosen
						this.dialPitstopOption("Repair Bodywork", "Increase", 1)
					else if this.iRepairSuspensionChosen
						this.dialPitstopOption("Repair Suspension", "Increase", 2)

					this.deselectPitstopOption("Repair All")
				case "Change Brakes":
					this.dialPitstopOption("Change Brakes", action, 1)

					this.deselectPitstopOption("Change Brakes")
				case "Tyre Compound Front Left":
				case "Tyre Compound Front Right":
				case "Tyre Compound Rear Left":
				case "Tyre Compound Rear Right":
				case "Driver":
				default:
					throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.changePitstopOption..."
			}
		}
	}

	tyrePressureSteps(pressure) {
		local compounds, index, candidate

		if tyreCompound {
			compounds := SessionDatabase().getTyreCompounds(this.Simulator[true], this.Car, this.Track)
			index := inList(compounds, compound(tyreCompound, tyreCompoundColor))

			if index
				return index
			else
				for index, candidate in compounds
					if (InStr(candidate, tyreCompound) == 1)
						return index

			return false
		}
		else
			return false
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if this.openPitstopMFD() {
			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 250)
				this.dialPitstopOption("Refuel", "Increase", Round(liters))

				this.deselectPitstopOption("Refuel")
			}

			this.closePitstopMFD()
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		local delta

		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		delta := this.tyreCompoundIndex(compound, compoundColor)

		if (!compound || delta) {
			if this.selectPitstopOption("Tyre Compound") {
				this.dialPitstopOption("Tyre Compound", "Decrease", 10)

				this.iTyreCompoundChosen := delta

				this.dialPitstopOption("Tyre Compound", "Increase", this.iTyreCompoundChosen)

				this.deselectPitstopOption("Tyre Compound")
			}

			this.closePitstopMFD()
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local pressures, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement, finished

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if this.openPitstopMFD() {
			if this.selectPitstopOption("Front Left") {
				this.dialPitstopOption("Front Left", "Decrease", 100)

				this.dialPitstopOption("Front Left", "Increase", this.tyrePressureSteps(pressureFL))

				this.deselectPitstopOption("Front Left")
			}

			if this.selectPitstopOption("Front Right") {
				this.dialPitstopOption("Front Right", "Decrease", 100)

				this.dialPitstopOption("Front Right", "Increase", this.tyrePressureSteps(pressureFR))

				this.deselectPitstopOption("Front Right")
			}

			if this.selectPitstopOption("Rear Left") {
				this.dialPitstopOption("Rear Left", "Decrease", 100)

				this.dialPitstopOption("Rear Left", "Increase", this.tyrePressureSteps(pressureRL))

				this.deselectPitstopOption("Rear Left")
			}

			if this.selectPitstopOption("Rear Right") {
				this.dialPitstopOption("Rear Right", "Decrease", 100)

				this.dialPitstopOption("Rear Right", "Increase", this.tyrePressureSteps(pressureRR))

				this.deselectPitstopOption("Rear Right")
			}

			this.closePitstopMFD()
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

	requestPitstopDriver(pitstopNumber, driver) {
	}

	updateSession(session, force := false) {
		super.updateSession(session, force)

		if (session == kSessionFinished) {
			this.iTyreCompoundChosen := 0
			this.iRepairSuspensionChosen := true
			this.iRepairBodyworkChosen := true
		}
	}

	parseCarName(carName, &model?, &nr?, &category?, &team?) {
		if ((carName != "") && isNumber(SubStr(carName, 1, 1))) {
			nr := this.parseNr(carName, &carName)

			super.parseCarName(carName, &model, , &category, &team)
		}
		else
			super.parseCarName(carName, &model, &nr, &category, &team)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startLMU() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kLMUPlugin).Simulator
													 , "Simulator Splash Images\LMU Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeLMUPlugin() {
	local controller := SimulatorController.Instance

	LMUPlugin(controller, kLMUPlugin, kLMUApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeLMUPlugin()
