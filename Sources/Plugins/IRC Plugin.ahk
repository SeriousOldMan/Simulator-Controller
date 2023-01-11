;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - iRacing Plugin                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


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

	PitstopFuelMFDHotkey[] {
		Get {
			return this.iPitstopFuelMFDHotkey
		}
	}

	PitstopTyreMFDHotkey[] {
		Get {
			return this.iPitstopTyreMFDHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)

		if (this.Active || isDebug()) {
			this.iPitstopFuelMFDHotkey := this.getArgumentValue("togglePitstopFuelMFD", false)
			this.iPitstopTyreMFDHotkey := this.getArgumentValue("togglePitstopTyreMFD", false)
		}
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , RepairRequest: "Repair"}
		selectActions := []
	}

	sendPitstopCommand(command, operation := false, message := false, arguments*) {
		local simulator, exePath

		if this.iCurrentPitstopMFD {
			simulator := this.Code
			arguments := values2String(";", arguments*)
			exePath := kBinariesDirectory . simulator . " SHM Provider.exe"

			try {
				if operation
					RunWait %ComSpec% /c ""%exePath%" -%command% %operation% "%message%:%arguments%"", , Hide
				else
					RunWait %ComSpec% /c ""%exePath%" -%command%", , Hide
			}
			catch exception {
				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"})
														   . exePath . translate(") - please rebuild the applications in the binaries folder (")
														   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
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

		this.getPitstopActions(actions, ignore)

		for ignore, candidate in actions
			if (candidate = option)
				return true

		return false
	}

	changePitstopOption(option, action, steps := 1) {
		switch option {
			case "Refuel":
				if (steps == 1)
					steps := 4

				this.openPitstopMFD("Fuel")

				this.sendPitstopCommand("Pitstop", "Change", "Refuel", (action = kIncrease) ? Round(steps) : Round(steps * -1))
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
		new SessionDatabase().registerTrack(getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
										  , getConfigurationValue(data, "Session Data", "Car", "Unknown")
										  , getConfigurationValue(data, "Session Data", "Track", "Unknown")
										  , getConfigurationValue(data, "Session Data", "TrackShortName", "Unknown")
										  , getConfigurationValue(data, "Session Data", "TrackLongName", "Unknown"))
	
		base.prepareSession(settings, data)
	}

	startPitstopSetup(pitstopNumber) {
		base.startPitstopSetup()

		openPitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		base.finishPitstopSetup()

		closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		base.setPitstopRefuelAmount(pitstopNumber, litres)

		this.openPitstopMFD("Fuel")

		this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(litres))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		base.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		this.openPitstopMFD("Tyre")

		this.sendPitstopCommand("Pitstop", "Set", "Tyre Change", compound ? "true" : "false")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		base.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		this.openPitstopMFD("Tyre")

		this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
							  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		base.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		this.openPitstopMFD("Fuel")

		this.sendPitstopCommand("Pitstop", "Set", "Repair", (repairBodywork || repairSuspension) ? "true" : "false")
	}

	updatePositionsData(data) {
		base.updatePositionsData(data)

		loop % getConfigurationValue(data, "Position Data", "Car.Count", 0)
			setConfigurationValue(data, "Position Data", "Car." . A_Index . ".Nr"
								, StrReplace(getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Nr", ""), """", ""))
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

	new IRCPlugin(controller, kIRCPlugin, kIRCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin()
