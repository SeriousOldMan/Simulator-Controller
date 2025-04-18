﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

	parseCategory(candidate, &rest) {
		local temp := ""
		local char

		loop StrLen(candidate) {
			char := SubStr(candidate, A_Index, 1)

			if (char != A_Space)
				temp .= char
			else {
				rest := SubStr(candidate, A_Index)

				return temp
			}
		}

		rest := ""

		return ((temp != "") ? temp : false)
	}

	parseCarName(carID, carName, &model?, &nr?, &category?, &team?) {
		local index

		model := false
		team := false
		nr := false
		category := false

		carName := Trim(carName)
		index := InStr(carName, "#")

		if (index = 1) {
			nr := this.parseNr(SubStr(carName, 2), &carName)

			if (InStr(carName, ":") = 1)
				category := this.parseCategory(SubStr(carName, 2), &carName)

			model := carName
		}
		else if index {
			carName := StrSplit(carName, "#", , 2)

			model := Trim(carName[1])

			if (model = "")
				model := false

			nr := this.parseNr(carName[2], &carName)

			if (InStr(carName, ":") = 1) {
				category := this.parseCategory(SubStr(carName, 2), &carName)

				if (category = "")
					category := false
			}
		}
		else if (carName != "")
			model := carName

		if (InStr(model, ":") && !category) {
			carName := StrSplit(model, ":", , 2)

			model := Trim(carName[1])
			category := Trim(carName[2])
		}

		model := normalizeFileName(model)
	}

	parseDriverName(carID, carName, forName, surName, nickName, &category?) {
		category := false

		return driverName(forName, surName, nickName)
	}

	acquireStandingsData(telemetryData, finished := false) {
		local debug := isDebug()
		local standingsData := super.acquireStandingsData(telemetryData, finished)
		local driver := getMultiMapValue(standingsData, "Position Data", "Driver.Car", 0)
		local numbers := Map()
		local duplicateNrs := false
		local carCategory := false
		local driverCategory := false
		local model := false
		local nr := false
		local carRaw, carID, forName, surName, nickName

		loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
			carRaw := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".CarRaw", kUndefined)

			if (carRaw != kUndefined) {
				this.parseCarName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID")
								, carRaw, &model, &nr, &carCategory)

				if model
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", model)

				if (A_Index != driver) {
					if debug
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Name"
									   , driverName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", "")
												  , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", "")
												  , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", "")))

					parseDriverName(this.parseDriverName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID")
													   , carRaw, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", "")
															   , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", "")
															   , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", "")
													   , &driverCategory)
								  , &forName, &surName, &nickName)

					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", forName)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", surName)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", nickName)

					if driverCategory
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Category", driverCategory)
				}

				nr := Integer(nr ? nr : getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID"))

				setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", nr)

				if carCategory
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Category", carCategory)

				if numbers.Has(nr)
					duplicateNrs := true
				else
					numbers[nr] := true
			}
		}

		if duplicateNrs
			loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
				carID := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID", kUndefined)

				if (carID != kUndefined)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", carID)
			}

		return standingsData
	}

	acquireTelemetryData() {
		local telemetryData := super.acquireTelemetryData()
		local model, forName, surName, nickName

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false

		static loadSetup := false
		static nextSetupUpdate := false

		if ((this.Simulator[true] != lastSimulator) || (this.Car != lastCar) || (this.Track != lastTrack)) {
			lastSimulator := this.Simulator[true]
			lastCar := this.Car
			lastTrack := this.Track

			loadSetup := SettingsDatabase().readSettingValue(lastSimulator, lastCar, lastTrack, "*"
														   , "Simulator." . this.Simulator[true], "Session.Data.Setup"
														   , (lastSimulator = "rFactor 2") ? 60 : 20)
		}

		this.parseCarName(false, getMultiMapValue(telemetryData, "Session Data", "CarRaw"), &model)

		if model
			setMultiMapValue(telemetryData, "Session Data", "Car", model)

		if (loadSetup == true)
			addMultiMapValues(telemetryData, this.readSessionData("Setup=true"))
		else if (loadSetup && (A_TickCount > nextSetupUpdate)) {
			addMultiMapValues(telemetryData, this.readSessionData("Setup=true"))

			nextSetupUpdate := (A_TickCount + (loadSetup * 1000))
		}

		return telemetryData
	}

	updateTelemetryData(data) {
		super.updateTelemetryData(data)

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator[true]
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, postFix

		static tyres := ["Front", "Rear"]

		for ignore, section in ["Car Data", "Setup Data"]
			for ignore, postfix in tyres {
				tyreCompound := getMultiMapValue(data, section, "TyreCompound" . postFix, kUndefined)

				if (tyreCompound = kUndefined) {
					tyreCompound := getMultiMapValue(data, section, "TyreCompoundRaw" . postFix, kUndefined)

					if (tyreCompound != kUndefined)
						if tyreCompound {
							tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

							if tyreCompound {
								splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

								setMultiMapValue(data, section, "TyreCompound" . postFix, tyreCompound)
								setMultiMapValue(data, section, "TyreCompoundColor" . postFix, tyreCompoundColor)
							}
						}
						else {
							setMultiMapValue(data, section, "TyreCompound" . postFix, false)
							setMultiMapValue(data, section, "TyreCompoundColor" . postFix, false)
						}
				}
			}

		return data
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
