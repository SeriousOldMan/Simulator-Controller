;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RF2 Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "Libraries\Sector397Plugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRF2Application := "rFactor 2"

global kRF2Plugin := "RF2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RF2Plugin extends Sector397Plugin {
	iSelectedDriver := false

	iOpenChatHotkey := false

	class ChatMode extends Sector397Plugin.ChatMode {
		handleChatMessage(message) {
			if this.Plugin.activateWindow() {
				Send(this.Plugin.OpenChatHotkey)
				Sleep(100)
				SendText(message)
				Sleep(100)
				Send("{Entser}")
			}
		}
	}

	OpenChatHotkey {
		Get {
			return this.iOpenChatHotkey
		}
	}

	__New(controller, name, simulator, configuration := false, register := true) {
		super.__New(controller, name, simulator, configuration, true)

		if (this.Active || (isDebug() && isDevelopment()))
			this.iOpenChatHotkey := this.getArgumentValue("openChat", false)
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration
								  , getMultiMapValue(configuration, "Voice Control", "ChatActivation", false) ? this.createChatMode()
																											  : false)
	}

	createChatMode() {
		return RF2Plugin.ChatMode(this)
	}

	registerMode(mode) {
		if (mode.Mode = kChatMode) {
			if (this.OpenChatHotkey && (Trim(this.OpenChatHotkey) != ""))
				super.registerMode(mode)
		}
		else
			super.registerMode(mode)
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreCompoundFront", "Tyre Compound Front", "TyreCompoundRear", "Tyre Compound Rear"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right"
								   , "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "DriverSelect", "Driver", "RepairRequest", "Repair", "PitstopRequest", "RequestPitstop")

		selectActions := []
	}

	sendPitstopCommand(command, operation, message, arguments*) {
		local simulator, exePath

		if (this.OpenPitstopMFDHotkey != "Off") {
			simulator := this.Code
			exePath := (kBinariesDirectory . "Connectors\" . simulator . " SHM Connector.dll")

			try {
				callSimulator(simulator, command . "=" . operation . "=" . message . ":" . values2String(";", arguments*), "Connector")
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "RequestPitstop":
					if (this.RequestPitstopHotKey && (steps > 0)) {
						this.activateWindow()

						this.sendCommand(this.RequestPitstopHotKey)
					}
				case "Refuel":
					this.sendPitstopCommand("Pitstop", action, "Refuel", Round(steps))
				case "No Refuel":
					this.sendPitstopCommand("Pitstop", "Decrease", "Refuel", 250)
				case "Tyre Compound", "Tyre Compound Front", "Tyre Compound Rear":
					this.sendPitstopCommand("Pitstop", action, option, Round(steps))
				case "All Around":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", Round(steps * 0.1, 1), Round(steps * 0.1, 1), Round(steps * 0.1, 1), Round(steps * 0.1, 1))
				case "Front Left":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", Round(steps * 0.1, 1), 0.0, 0.0, 0.0)
				case "Front Right":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, Round(steps * 0.1, 1), 0.0, 0.0)
				case "Rear Left":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, 0.0, Round(steps * 0.1, 1), 0.0)
				case "Rear Right":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, 0.0, 0.0, Round(steps * 0.1, 1))
				case "Driver", "Repair":
					this.sendPitstopCommand("Pitstop", action, option, Round(steps))
				default:
					throw "Unsupported change operation `"" . action . "`" detected in RF2Plugin.changePitstopOption..."
			}
		}
	}

	getPitstopOptionValues(option) {
		local data, compound, compoundColor

		static lastData := false

		if (this.OpenPitstopMFDHotkey != "Off") {
			data := this.readSessionData()

			if (getMultiMapValue(data, "Stint Data", "InPitLane", false) || getMultiMapValue(data, "Stint Data", "InPit", false)) {
				if lastData
					data := lastData
				else
					return false
			}
			else {
				data := this.readSessionData("Setup=true")

				lastData := data
			}

			switch option, false {
				case "Refuel":
					return [getMultiMapValue(data, "Setup Data", "FuelAmount", 0)]
				case "Tyre Pressures":
					return [getMultiMapValue(data, "Setup Data", "TyrePressureFL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureFR", 26.1)
						  , getMultiMapValue(data, "Setup Data", "TyrePressureRL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureRR", 26.1)]
				case "Tyre Compound", "TyreCompound":
					return [getMultiMapValue(data, "Setup Data", "TyreCompound", false)
						  , getMultiMapValue(data, "Setup Data", "TyreCompoundColor", false)]
				case "Tyre Compound Front", "TyreCompoundFront":
					return [getMultiMapValue(data, "Setup Data", "TyreCompoundFront", false)
						  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorFront", false)]
				case "Tyre Compound Rear", "TyreCompoundRear":
					return [getMultiMapValue(data, "Setup Data", "TyreCompoundRear", false)
						  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorRear", false)]
				case "Repair Suspension":
					return [getMultiMapValue(data, "Setup Data", "RepairSuspension", false)]
				case "Repair Bodywork":
					return [getMultiMapValue(data, "Setup Data", "RepairBodywork", false)]
				default:
					return super.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	performPitstop(lap, options) {
		super.performPitstop(lap, options)

		this.iSelectedDriver := false
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
		this.requirePitstopMFD()

		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreCompound(pitstopNumber, compound, compoundColor := false, set := false) {
		local index, axle, tyreCompound

		this.requirePitstopMFD()

		super.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off") {
			if InStr(compound, ",") {
				compound := string2Values(",", compound)
				compoundColor := string2Values(",", compoundColor)
			}
			else {
				compound := [compound, compound]
				compoundColor := [compoundColor, compoundColor]
			}

			for index, axle in ["Front", "Rear"]
				if compound[index] {
					tyreCompound := this.tyreCompoundCode(compound[index], compoundColor[index])

					if tyreCompound
						this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound " . axle, tyreCompound)
				}
				else
					this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound " . axle, "None")
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		this.requirePitstopMFD()

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		this.requirePitstopMFD()

		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey != "Off")
			if (repairBodywork && repairSuspension)
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Both")
			else if repairSuspension
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Suspension")
			else if repairBodywork
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Bodywork")
			else
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Nothing")
	}

	requestPitstopDriver(pitstopNumber, driver) {
		local delta, currentDriver, nextDriver

		this.requirePitstopMFD()

		super.requestPitstopDriver(pitstopNumber, driver)

		if (this.OpenPitstopMFDHotkey != "Off")
			if driver {
				driver := string2Values("|", driver)

				nextDriver := string2Values(":", driver[2])
				currentDriver := string2Values(":", driver[1])

				if !this.iSelectedDriver
					this.iSelectedDriver := currentDriver[2]

				delta := (nextDriver[2] - this.iSelectedDriver)

				loop Abs(delta)
					this.changePitstopOption("Driver", (delta < 0) ? "Decrease" : "Increase")

				this.iSelectedDriver := nextDriver[2]
			}
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		if getMultiMapValue(this.Settings, "Simulator.rFactor 2", "Pitstop.Request", false) {
			this.requirePitstopMFD()

			this.changePitstopOption("RequestPitstop")
		}

		if this.ClosePitstopMFDHotkey
			this.closePitstopMFD()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRF2(executable := false) {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kRF2Plugin).Simulator
													 , "Simulator Splash Images\RF2 Splash.jpg"
													 , executable)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin() {
	local controller := SimulatorController.Instance

	RF2Plugin(controller, kRF2Plugin, kRF2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin()
