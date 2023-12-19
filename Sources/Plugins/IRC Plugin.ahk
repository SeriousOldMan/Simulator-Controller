;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - iRacing Plugin                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kIRCApplication := "iRacing"

global kIRCPlugin := "IRC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IRCPlugin extends RaceAssistantSimulatorPlugin {
	iCurrentPitstopMFD := false

	iPitstopFuelMFDHotkey := false
	iPitstopTyreMFDHotkey := false

	PitstopFuelMFDHotkey {
		Get {
			return this.iPitstopFuelMFDHotkey
		}
	}

	PitstopTyreMFDHotkey {
		Get {
			return this.iPitstopTyreMFDHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay") {
				this.iPitstopFuelMFDHotkey := this.getArgumentValue("togglePitstopFuelMFD", false)
				this.iPitstopTyreMFDHotkey := this.getArgumentValue("togglePitstopTyreMFD", false)
			}
			else {
				this.iPitstopFuelMFDHotkey := "Off"
				this.iPitstopTyreMFDHotkey := "Off"
			}
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel", "TyreChange", "Change Tyres", "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "RepairRequest", "Repair")

		selectActions := []
	}

	sendPitstopCommand(command, operation, message, arguments*) {
		local exePath := (kBinariesDirectory . "Connectors\" . "IRC SHM Connector.dll")

		if this.iCurrentPitstopMFD
			try {
				callSimulator(this.Code, command . "=" . operation . "=" . message . ":" . values2String(";", arguments*), "DLL")
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: this.Code, protocol: "SHM"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: this.Code, protocol: "SHM"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
	}

	openPitstopMFD(descriptor := false) {
		local key := false

		static reported := false

		if !descriptor
			descriptor := "Fuel"

		if (this.iCurrentPitstopMFD && (this.iCurrentPitstopMFD != descriptor))
			this.closePitstopMFD()

		if !this.iCurrentPitstopMFD {
			if (!descriptor || (descriptor = "Fuel"))
				key := this.PitstopFuelMFDHotkey
			else if (descriptor = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else
				throw "Unsupported Pitstop MFD detected in IRCPlugin.openPitstopMFD..."

			if key {
				if (key != "Off") {
					this.sendCommand(key)

					this.iCurrentPitstopMFD := descriptor

					return true
				}
				else
					return false
			}
			else if !reported {
				reported := true

				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				return false
			}
		}
		else
			return true
	}

	closePitstopMFD() {
		local key := false

		if this.iCurrentPitstopMFD {
			if (this.iCurrentPitstopMFD = "Fuel")
				key := this.PitstopFuelMFDHotkey
			else if (this.iCurrentPitstopMFD = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else {
				this.iCurrentPitstopMFD := false

				throw "Unsupported Pitstop MFD detected in IRCPlugin.closePitstopMFD..."
			}

			if (key != "Off")
				this.sendCommand(key)

			this.iCurrentPitstopMFD := false
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

	changePitstopOption(option, action, steps := 1) {
		switch option, false {
			case "Refuel":
				if ((steps == 1) && (getUnit("Volume") = "Liter"))
					steps := 4

				this.openPitstopMFD("Fuel")

				this.sendPitstopCommand("Pitstop", "Change", "Refuel", (action = kIncrease) ? Round(steps) : Round(steps * -1))
			case "No Refuel":
				if ((steps == 1) && (getUnit("Volume") = "Liter"))
					steps := 4

				this.openPitstopMFD("Fuel")

				this.sendPitstopCommand("Pitstop", "Change", "Refuel", -250)
			case "Change Tyres":
				this.openPitstopMFD("Tyre")

				this.sendPitstopCommand("Pitstop", "Change", "Tyre Change", (action = kIncrease) ? "true" : "false")
			case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
				this.openPitstopMFD("Tyre")

				this.sendPitstopCommand("Pitstop", "Change", option, Round(steps * 0.1 * ((action = kIncrease) ? 1 : -1), 1))
			case "Repair":
				this.openPitstopMFD("Fuel")

				this.sendPitstopCommand("Pitstop", "Change", "Repair", (action = kIncrease) ? "true" : "false")
		}
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

	prepareSession(settings, data) {
		SessionDatabase.registerTrack(getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
									, getMultiMapValue(data, "Session Data", "Car", "Unknown")
									, getMultiMapValue(data, "Session Data", "Track", "Unknown")
									, getMultiMapValue(data, "Session Data", "TrackShortName", "Unknown")
									, getMultiMapValue(data, "Session Data", "TrackLongName", "Unknown"))

		super.prepareSession(settings, data)
	}

	startPitstopSetup(pitstopNumber) {
		super.startPitstopSetup(pitstopNumber)

		openPitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if this.openPitstopMFD("Fuel")
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if this.openPitstopMFD("Tyre")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Change", compound ? "true" : "false")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if this.openPitstopMFD("Tyre")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if this.openPitstopMFD("Fuel")
			this.sendPitstopCommand("Pitstop", "Set", "Repair", (repairBodywork || repairSuspension) ? "true" : "false")
	}

	updatePositionsData(data) {
		local carClass

		super.updatePositionsData(data)

		loop {
			carClass := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUndefined)

			if (carClass == kUndefined)
				break
			else if (Trim(carClass) != "")
				setMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", Trim(carClass))
			else
				removeMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class")
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startIRC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kIRCPlugin).Simulator
													 , "Simulator Splash Images\IRC Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin() {
	local controller := SimulatorController.Instance

	IRCPlugin(controller, kIRCPlugin, kIRCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin()
