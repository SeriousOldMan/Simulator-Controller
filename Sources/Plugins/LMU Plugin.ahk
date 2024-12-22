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
#Include "Libraries\LMURESTProvider.ahk"
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
	iRequestPitstopHotkey := false

	RequestPitstopHotkey {
		Get {
			return this.iRequestPitstopHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

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
		return false ; ?????
	}

	getOptionHandler(option) {
		return (operation, value?) {
			local pitstop := LMURESTProvider.PitstopData()
			local compound, code, tyre

			switch option, false {
				case "Refuel":
					switch operation, false {
						case "Get":
							return pitstop.getRefuelAmount()
						case "Set":
							pitstop.setRefuelAmount(value)
						case "Change":
							pitstop.changeRefuelAmount(value)
					}
				case "Tyre Compound", "Tyre Compound Front Left", "Tyre Compound Front Right"
									, "Tyre Compound Rear Left", "Tyre Compound Rear Right":
					if (option = "Tyre Compound")
						tyre := "All"
					else
						tyre := StrReplace(option, "Tyre Compound ", "")

					switch operation, false {
						case "Get":
							compound := SessionDatabase.getTyreCompoundName(this.Simulator[true], this.Car, this.Track
																		  , pitstop.getTyreCompound(tyre), kUndefined)

							return ((compound = kUndefined) ? normalizeCompound("Dry") : compound)
						case "Set":
							if value {
								code := SessionDatabase.getTyreCompoundCode(this.Simulator[true], this.Car, this.Track, value, kUndefined)

								if (code = kUndefined)
									code := SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track, true)[1]

								pitstop.setTyreCompound(tyre, code)
							}
							else
								pitstop.setTyreCompound(tyre, false)
						case "Change":
							pitstop.changeTyreCompound(value)
					}
				case "Front Left", "Front Right", "Rear Left", "Rear Right":
					switch operation, false {
						case "Get":
							return pitstop.getTyrePressure(option)
						case "Set":
							pitstop.setTyrePressure(option)
						case "Change":
							pitstop.changeTyrePressure(option, value)
					}
				case "Repair Bodywork":
					switch operation, false {
						case "Get":
							pitstop.getRepairs(&value, &ignore, &ignore)

							return value
						case "Set":
							pitstop.setRepairs(value, pitstop.RepairSuspension, pitstop.RepairEngine)
						case "Change":
							if (value < 0)
								pitstop.setRepairs(false, pitstop.RepairSuspension, pitstop.RepairEngine)
							else if (value < 0)
								pitstop.setRepairs(true, pitstop.RepairSuspension, pitstop.RepairEngine)
					}
				case "Repair Bodywork":
					switch operation, false {
						case "Get":
							pitstop.getRepairs(&ignore, &value, &ignore)

							return value
						case "Set":
							pitstop.setRepairs(pitstop.RepairBodywork, value, pitstop.RepairEngine)
						case "Change":
							if (value < 0)
								pitstop.setRepairs(pitstop.RepairBodywork, false, pitstop.RepairEngine)
							else if (value < 0)
								pitstop.setRepairs(pitstop.RepairBodywork, true, pitstop.RepairEngine)
					}
				case "Repair Engine":
					if pitstop.supportsEngineRepair()
						switch operation, false {
							case "Get":
								pitstop.getRepairs(&ignore, &ignore, &value)

								return value
							case "Set":
								pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, value)
							case "Change":
								if (value < 0)
									pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, false)
								else if (value < 0)
									pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, true)
						}
					else
						return false
				case "Change Brakes":
					switch operation, false {
						case "Get":
							return pitstop.getBrakeChange()
						case "Set":
							pitstop.setBrakeChange(value)
						case "Change":
							if (value < 0)
								pitstop.setBrakeChange(false)
							else if (value > 0)
								pitstop.setBrakeChange(true)
					}
				case "Driver":
					if pitstop.supportsDriverSwap()
						switch operation, false {
							case "Get":
								return pitstop.getDriver()
							case "Set":
								pitstop.setDriver(value)
							case "Change":
								pitstop.changeDriver(value)
						}
					else
						return SessionDatabase.getDriverName(this.Simulator[true], SessionDatabase.ID)
			}

			pitstop.write()
		}
	}

	getPitstopOptionValues(option) {
		local data, compound, compoundColor

		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Refuel":
					return this.getOptionHandler(option).Call("Get")
				case "Tyre Pressures":
					return [this.getOptionHandler("Front Left").Call("Get"), this.getOptionHandler("Front Right").Call("Get")
						  , this.getOptionHandler("Rear Left").Call("Get"), this.getOptionHandler("Rear Right").Call("Get")]
				case "Tyre Compound", "TyreCompound":
					compound := this.getOptionHandler("Tyre Compound").Call("Get")

					if compound
						splitCompound(compound, &compound, &compoundColor := false)

					return [compound, compoundColor]
				case "Repair Suspension", "Repair Bodywork", "Repair Engine":
					return this.getOptionHandler(option).Call("Get")
				case "Change Brakes":
					return this.getOptionHandler(option).Call("Get")
				case "Driver":
					return this.getOptionHandler(option).Call("Get")
				default:
					return super.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			if ((action = "Increase") || (option = "Decrease"))
				this.getOptionHandler(option).Call("Change", steps)
			else
				throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.dialPitstopOption..."
	}

	setPitstopOption(option, value) {
		if (this.OpenPitstopMFDHotkey != "Off")
			this.getOptionHandler(option).Call("Set", value)
	}

	changePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Pitstop":
					if this.RequestPitstopHotKey
						this.sendCommand(this.RequestPitstopHotKey)
				case "Refuel":
					this.dialPitstopOption(option, action, steps)
				case "No Refuel":
					this.dialPitstopOption("Refuel", "Decrease", 250)
				case "Tyre Compound", "Tyre Compound Front Left", "Tyre Compound Front Right"
									, "Tyre Compound Rear Left", "Tyre Compound Rear Right":
					this.dialPitstopOption(option, action, steps)
				case "All Around":
					this.dialPitstopOption("Front Left", action, steps)
					this.dialPitstopOption("Front Right", action, steps)
					this.dialPitstopOption("Rear Left", action, steps)
					this.dialPitstopOption("Rear Right", action, steps)
				case "Front Left", "Front Right", "Rear Left", "Rear Right":
					this.dialPitstopOption(option, action, steps)
				case "Repair Bodywork", "Repair Suspension", "Repair Engine":
					this.dialPitstopOption(option, action, steps)
				case "Change Brakes":
					this.dialPitstopOption("Change Brakes", action, steps)
				case "Driver":
					this.dialPitstopOption("Driver", action, steps)
				default:
					throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.changePitstopOption..."
			}
		}
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Refuel", liters)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Tyre Compound", compound ? this.tyreCompoundCode(compound, compoundColor) : false)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local pressures, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement, finished

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.setPitstopOption("Front Left", pressureFL)
			this.setPitstopOption("Front Right", pressureFR)
			this.setPitstopOption("Rear Left", pressureRL)
			this.setPitstopOption("Rear Right", pressureRR)
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.setPitstopOption("Repair Suspension", repairSuspension)
			this.setPitstopOption("Repair Bodywork", repairBodywork)
			this.setPitstopOption("Repair Engine", repairEngine)
		}
	}

	requestPitstopDriver(pitstopNumber, driver) {
		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Driver", driver)
	}

	parseCategory(candidate, &rest) {
		super.parseCategory(candidate, &rest)

		return false
	}

	parseCarName(carName, &model?, &nr?, &category?, &team?) {
		static gridData := LMURESTProvider.GridData()

		model := gridData.Car[carName]

		if !model {
			gridData := LMURESTProvider.GridData()

			model := gridData.Car[carName]
		}

		team := gridData.Team[carName]

		if ((carName != "") && isNumber(SubStr(carName, 1, 1))) {
			nr := this.parseNr(carName, &carName)

			super.parseCarName(carName, , , &category)
		}
		else
			super.parseCarName(carName, , &nr, &category)


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
