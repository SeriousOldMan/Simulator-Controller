;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RF2 Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRF2Application := "rFactor 2"

global kRF2Plugin := "RF2"
global kChatMode := "Chat"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Sector397Plugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	iRequestPitstopHotkey := false

	iOpenChatHotkey := false

	iPitstopMode := false
	iChatMode := false

	class ChatMode extends ControllerMode {
		Mode {
			Get {
				return kChatMode
			}
		}

		updateActions(session) {
		}
	}

	class ChatAction extends ControllerAction {
		iMessage := ""

		Message {
			Get {
				return this.iMessage
			}
		}

		__New(function, label, message) {
			this.iMessage := message

			super.__New(function, label)
		}

		fireAction(function, trigger) {
			local message := this.Message

			if this.Controller.findPlugin(kACCPlugin).activateWindow() {
				Send("{Enter}")
				Sleep(100)
				Send(message)
				Sleep(100)
				Send("{Enter}")
			}
		}
	}

	OpenPitstopMFDHotkey {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	ClosePitstopMFDHotkey {
		Get {
			return this.iClosePitstopMFDHotkey
		}
	}

	RequestPitstopHotkey {
		Get {
			return this.iRequestPitstopHotkey
		}
	}

	OpenChatHotkey {
		Get {
			return this.iOpenChatHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iPitstopMode := this.findMode(kPitstopMode)

			this.iOpenChatHotkey := this.getArgumentValue("openChat", false)

			if (this.iChatMode && this.OpenChatHotkey && (Trim(this.OpenChatHotkey) != ""))
				this.registerMode(this.iChatMode)
			else
				this.iChatMode := false

			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

			this.iRequestPitstopHotkey := this.getArgumentValue("requestPitstop", false)

			if this.RequestPitstopHotkey {
				this.iRequestPitstopHotkey := Trim(this.RequestPitstopHotkey)

				if (this.RequestPitstopHotkey = "")
					this.iRequestPitstopHotkey := false
			}
		}
	}

	loadFromConfiguration(configuration) {
		local function, descriptor, message

		super.loadFromConfiguration(configuration)

		for descriptor, message in getMultiMapValues(configuration, "Chat Messages") {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				message := string2Values("|", message)

				if !this.iChatMode
					this.iChatMode := RF2Plugin.ChatMode(this)

				this.iChatMode.registerAction(RF2Plugin.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}

	updateSession(session, force := false) {
		local lastSession := this.Session
		local activeModes

		super.updateSession(session, force)

		activeModes := this.Controller.ActiveModes

		if (inList(activeModes, this.iChatMode))
			this.iChatMode.updateActions(session)

		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(session)
	}

	openPitstopMFD(descriptor := false) {
		static reported := false

		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if this.activateWindow() {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					return true
				}
				else
					return false
			}
			else
				return false
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			if !kSilentMode
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return false
		}
	}

	closePitstopMFD() {
		static reported := false

		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off")
				if this.activateWindow()
					this.sendCommand(this.ClosePitstopMFDHotkey)
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			if !kSilentMode
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	requirePitstopMFD() {
		return true
	}

	selectPitstopOption(option) {
		local actions := false
		local ignore := false
		local candidate

		this.getPitstopActions(&actions, &ignore)

		for ignore, candidate in actions
			if (candidate = option)
				return true

		return false
	}

	supportsPitstop() {
		return true
	}

	supportsTrackMap() {
		return true
	}

	supportsSetupImport() {
		return true
	}

	parseNr(candidate, &rest) {
		local temp, char

		candidate := Trim(candidate)

		if isNumber(candidate) {
			rest := ""

			return candidate
		}
		else {
			temp := ""

			loop StrLen(candidate) {
				char := SubStr(candidate, A_Index, 1)

				if isNumber(char)
					temp .= char
				else if (char != A_Space) {
					rest := SubStr(candidate, A_Index)

					return temp
				}
			}

			rest := ""

			return ((temp != "") ? temp : false)
		}
	}
}

class RF2Plugin extends Sector397Plugin {
	iSelectedDriver := false

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreCompoundFront", "Tyre Compound Front", "TyreCompoundRear", "Tyre Compound Rear"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "DriverSelect", "Driver", "RepairRequest", "Repair", "PitstopRequest", "RequestPitstop")

		selectActions := []
	}

	sendPitstopCommand(command, operation, message, arguments*) {
		local simulator, exePath

		if (this.OpenPitstopMFDHotkey != "Off") {
			simulator := this.Code
			exePath := (kBinariesDirectory . "Connectors\" . simulator . " SHM Connector.dll")

			try {
				callSimulator(simulator, command . "=" . operation . "=" . message . ":" . values2String(";", arguments*), "CLR")
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
		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off")
			if compound {
				compound := this.tyreCompoundCode(compound, compoundColor)

				if compound {
					this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", compound)

					if set
						this.sendPitstopCommand("Pitstop", "Set", "Tyre Set", Round(set))
				}
			}
			else
				this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", "None")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
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

		if getMultiMapValue(this.Settings, "Simulator.rFactor 2", "Pitstop.Request", false)
			this.changePitstopOption("RequestPitstop")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRF2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kRF2Plugin).Simulator
													 , "Simulator Splash Images\RF2 Splash.jpg")
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
