;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AC Plugin                       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACApplication = "Assetto Corsa"

global kACPlugin = "AC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACPlugin extends RaceAssistantSimulatorPlugin {
	iCommandMode := "Event"

	iOpenPitstopMFDHotkey := false

	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false

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

		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")

		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "{Down}")

		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "{Up}")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "{Down}")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "{Left}")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "{Right}")
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"}
		selectActions := []
	}

	supportsPitstop() {
		return true
	}

	sendPitstopCommand(command) {
		switch this.iCommandMode {
			case "Event":
				SendEvent %command%
			case "Input":
				SendInput %command%
			case "Play":
				SendPlay %command%
			case "Raw":
				SendRaw %command%
			default:
				Send %command%
		}

		Sleep 20
	}

	supportsRaceAssistant(assistantPlugin) {
		return ((assistantPlugin = kRaceEngineerPlugin) && base.supportsRaceAssistant(assistantPlugin))
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
			this.sendPitstopCommand(this.OpenPitstopMFDHotkey)

			return true
		}
		else
			return false
	}

	closePitstopMFD(option := false) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Change Tyres")
				this.sendPitstopCommand(this.PreviousOptionHotkey)
			else if (option = "Refuel") {
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendPitstopCommand(this.PreviousOptionHotkey)
			}

			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
		}
	}

	requirePitstopMFD() {
		return this.openPitstopMFD()
	}

	selectPitstopOption(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendPitstopCommand(this.PreviousOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextOptionHotkey)
			this.sendPitstopCommand(this.NextChoiceHotkey)

			if (option = "Change Tyres") {
				this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Refuel") {
				this.sendPitstopCommand(this.NextOptionHotkey)
				this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if ((option = "Repair Bodywork") || (option = "Repair Suspension")) {
				Loop 3
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else {
				this.sendPitstopCommand(this.NextChoiceHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.PreviousOptionHotkey)
				this.sendPitstopCommand(this.NextChoiceHotkey)
				this.sendPitstopCommand(this.NextOptionHotkey)
				this.sendPitstopCommand(this.NextChoiceHotkey)

				return false
			}
		}
		else
			return false
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Refuel") {
				this.dialPitstopOption("Refuel", action, steps)

				Sleep 2000

				this.closePitstopMFD("Refuel")
			}
			else if (option = "Change Tyres") {
				this.iChangeTyresChosen += 1

				if (this.iChangeTyresChosen > 2)
					this.iChangeTyresChosen := 0

				this.dialPitstopOption("Change Tyres", "Decrease", 10)

				if this.iChangeTyresChosen
					this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)

				Sleep 2000

				this.closePitstopMFD("Change Tyres")
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

				Sleep 2000

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

				Sleep 2000

				this.closePitstopMFD("Repair Suspension")
			}
			else
				Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.changePitstopOption..."
		}
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			switch action {
				case "Increase":
					Loop %steps%
						this.sendPitstopCommand(this.NextChoiceHotkey)
				case "Decrease":
					Loop %steps%
						this.sendPitstopCommand(this.PreviousChoiceHotkey)
				default:
					Throw "Unsupported change operation """ . action . """ detected in AMS2Plugin.dialPitstopOption..."
			}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		this.requirePitstopMFD()

		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(litres))

				Sleep 2000

				this.closePitstopMFD("Refuel")
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		this.requirePitstopMFD()

		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.selectPitstopOption("Change Tyres") {
				this.dialPitstopOption("Change Tyres", "Decrease", 10)

				if (compound = "Dry")
					this.iChangeTyresChosen := 1
				else if (compound = "Wet")
					this.iChangeTyresChosen := 2
				else
					this.iChangeTyresChosen := 0

				this.dialPitstopOption("Change Tyres", "Increase", this.iChangeTyresChosen)

				Sleep 2000

				this.closePitstopMFD("Change Tyres")
			}
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
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

	updateSessionData(data) {
		setConfigurationValue(data, "Car Data", "TC", Round((getConfigurationValue(data, "Car Data", "TCRaw", 0) / 0.2) * 10))
		setConfigurationValue(data, "Car Data", "ABS", Round((getConfigurationValue(data, "Car Data", "ABSRaw", 0) / 0.2) * 10))

		grip := getConfigurationValue(data, "Track Data", "GripRaw", 1)
		grip := Round(6 - (((1 - grip) / 0.15) * 6))
		grip := ["Dusty", "Old", "Slow", "Green", "Fast", "Optimum"][Max(1, grip)]

		setConfigurationValue(data, "Track Data", "Grip", grip)

		forName := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
		surName := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		nickName := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		if ((forName = surName) && (surName = nickName)) {
			name := string2Values(A_Space, forName, 2)

			setConfigurationValue(data, "Stint Data", "DriverForname", name[1])
			setConfigurationValue(data, "Stint Data", "DriverSurname", (name.Length() > 1) ? name[2] : "")
			setConfigurationValue(data, "Stint Data", "DriverNickname", "")
		}

		compound := getConfigurationValue(data, "Car Data", "TyreCompoundRaw", "Dry")

		if (InStr(compound, "Slick") = 1) {
			compoundColor := string2Values(A_Space, compound)

			if (compoundColor.Length() > 1) {
				compoundColor := compoundColor[2]

				if !inList(["Hard", "Medium", "Soft"], compoundColor)
					compoundColor := "Black"
			}
			else
				compoundColor := "Black"
		}
		else
			compoundColor := "Black"

		setConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		setConfigurationValue(data, "Car Data", "TyreCompoundColor", compoundColor)

		if !isDebug() {
			removeConfigurationValue(data, "Car Data", "TCRaw")
			removeConfigurationValue(data, "Car Data", "ABSRaw")
			removeConfigurationValue(data, "Car Data", "TyreCompoundRaw")
			removeConfigurationValue(data, "Track Data", "GripRaw")
		}

		if !getConfigurationValue(data, "Stint Data", "InPit", false)
			if (getConfigurationValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setConfigurationValue(data, "Session Data", "Paused", true)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACPlugin).Simulator, "Simulator Splash Images\AC Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin() {
	local controller := SimulatorController.Instance

	new ACPlugin(controller, kACPlugin, kACApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin()
