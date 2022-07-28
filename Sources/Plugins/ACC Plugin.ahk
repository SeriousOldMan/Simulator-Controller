;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACC Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\JSON.ahk
#Include ..\Libraries\Math.ahk
#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACCApplication = "Assetto Corsa Competizione"

global kACCPlugin = "ACC"
global kChatMode = "Chat"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kPSMutatingOptions = ["Strategy", "Change Tyres", "Tyre Compound", "Change Brakes"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACCPlugin extends RaceAssistantSimulatorPlugin {
	iUDPClient := false
	iUDPConnection := false

	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false

	iImageSearch := kUndefined

	iNoImageSearch := false
	iNextPitstopMFDOptionsUpdate := false

	iPSOptions := ["Pit Limiter", "Strategy", "Refuel"
				 , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
				 , "Change Brakes", "Front Brake", "Rear Brake", "Repair Suspension", "Repair Bodywork"]

	iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
	iPSTyreOptions := 7
	iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")
	iPSBrakeOptions := 2

	iPSIsOpen := false
	iPSSelectedOption := 1
	iPSChangeTyres := false
	iPSChangeBrakes := false

	iPSImageSearchArea := false

	iChatMode := false
	iPitstopMode := false

	iRepairSuspensionChosen := true
	iRepairBodyworkChosen := true

	class ChatMode extends ControllerMode {
		Mode[] {
			Get {
				return kChatMode
			}
		}

		updateActions(sessionState) {
		}
	}

	class ChatAction extends ControllerAction {
		iMessage := ""

		Message[] {
			Get {
				return this.iMessage
			}
		}

		__New(function, label, message) {
			this.iMessage := message

			base.__New(function, label)
		}

		fireAction(function, trigger) {
			message := this.Message

			this.Controller.findPlugin(kACCPlugin).activateWindow()

			Send {Enter}
			Sleep 100
			Send %message%
			Sleep 100
			Send {Enter}
		}
	}

	Car[] {
		Set {
			this.iImageSearch := kUndefined

			return (base.Car := value)
		}
	}

	Track[] {
		Set {
			this.iImageSearch := kUndefined

			return (base.Track := value)
		}
	}

	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	ClosePitstopMFDHotkey[] {
		Get {
			return this.iClosePitstopMFDHotkey
		}
	}

	UDPConnection[] {
		Get {
			return this.iUDPConnection
		}
	}

	UDPClient[] {
		Get {
			return this.iUDPClient
		}
	}

	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)

		if (this.Active || isDebug()) {
			this.iPitstopMode := this.findMode(kPitstopMode)

			if this.iChatMode
				this.registerMode(this.iChatMode)

			this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

			this.iUDPConnection := this.getArgumentValue("udpConnection", false)

			controller.registerPlugin(this)

			OnExit(ObjBindMethod(this, "shutdownUDPClient"))
		}
	}

	loadFromConfiguration(configuration) {
		local function

		base.loadFromConfiguration(configuration)

		for descriptor, message in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
			function := this.Controller.findFunction(descriptor)

			if (function != false) {
				message := string2Values("|", message)

				if !this.iChatMode
					this.iChatMode := new this.ChatMode(this)

				this.iChatMode.registerAction(new this.ChatAction(function, message[1], message[2]))
			}
			else
				this.logFunctionNotFound(descriptor)
		}
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Strategy: "Strategy", Refuel: "Refuel"
					 , TyreChange: "Change Tyres", TyreSet: "Tyre Set", TyreCompound: "Tyre Compound", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , BrakeChange: "Change Brakes", FrontBrake: "Front Brake", RearBrake: "Rear Brake"
					 , DriverSelect: "Driver"
					 , SuspensionRepair: "Repair Suspension", BodyworkRepair: "Repair Bodywork"}
		selectActions := ["TyreChange", "BrakeChange", "SuspensionRepair", "BodyworkRepair"]
	}

	startupUDPClient(force := false) {
		if (!this.UDPClient || force) {
			this.shutdownUDPClient(force)

			exePath := kBinariesDirectory . "ACC UDP Provider.exe"

			try {
				if FileExist(kTempDirectory . "ACCUDP.cmd")
					FileDelete %kTempDirectory%ACCUDP.cmd

				if FileExist(kTempDirectory . "ACCUDP.out")
					FileDelete %kTempDirectory%ACCUDP.out

				options := ""

				if this.UDPConnection
					options := ("-Connect " . this.UDPConnection)

				Run "%exePath%" "%kTempDirectory%ACCUDP.cmd" "%kTempDirectory%ACCUDP.out" %options%, %kBinariesDirectory%, Hide, udpClient

				this.iUDPClient := udpClient
			}
			catch exception {
				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "ACC", protocol: "UDP"})
														   . exePath . translate(") - please rebuild the applications in the binaries folder (")
														   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: "ACC", protocol: "UDP"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				this.iUDPClient := false
			}
		}
	}

	shutdownUDPClient(force := false) {
		if (this.UDPClient || force) {
			FileAppend Exit, %kTempDirectory%ACCUDP.cmd

			Sleep 250

			Loop 5 {
				Process Exist, ACC UDP Provider.exe

				if ErrorLevel {
					Process Close, %ErrorLevel%

					Sleep 250
				}
				else
					break
			}

			this.iUDPClient := false
		}

		return false
	}

	requireUDPClient() {
		Process Exist, ACC UDP Provider.exe

		if !ErrorLevel
			this.iUDPClient := false

		if (this.SessionState == kSessionRace)
			this.startupUDPClient()
	}

	updateSessionState(sessionState) {
		lastSessionState := this.SessionState

		base.updateSessionState(sessionState)

		activeModes := this.Controller.ActiveModes

		if (inList(activeModes, this.iChatMode))
			this.iChatMode.updateActions(sessionState)

		if (inList(activeModes, this.iPitstopMode))
			this.iPitstopMode.updateActions(sessionState)

		if (sessionState == kSessionRace)
			this.startupUDPClient((lastSessionState != kSessionRace) && (lastSessionState != kSessionPaused))
		else {
			if (sessionState == kSessionFinished) {
				this.iRepairSuspensionChosen := true
				this.iRepairBodyworkChosen := true
			}

			if (sessionState != kSessionPaused)
				this.shutdownUDPClient()
		}
	}

	updatePositionsData(data) {
		base.updatePositionsData(data)

		static carIDs := false
		static lastDriverCar := false
		static lastRead := false
		static standings := false

		if (this.SessionState == kSessionRace)
			this.requireUDPClient()
		else if !this.UDPClient
			return

		if !carIDs
			carIDs := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini"), "Car IDs")

		if ((A_TickCount + 5000) > lastRead) {
			lastRead := (A_TickCount + 0)

			fileName := kTempDirectory . "ACCUDP.cmd"

			FileAppend Read, %fileName%

			tries := 10

			while FileExist(fileName) {
				Sleep 200

				if (--tries <= 0)
					break
			}

			if (tries > 0) {
				fileName := kTempDirectory . "ACCUDP.out"

				standings := readConfiguration(fileName)

				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}
			}
			else {
				standings := false

				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}

				this.iUDPClient := false
			}
		}

		if standings {
			if (getConfigurationValue(data, "Stint Data", "Laps", 0) <= 1)
				lastDriverCar := false

			driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
			driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

			lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)

			driverCar := false
			driverCarCandidate := false

			Loop {
				carID := getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", kUndefined)

				if (carID == kUndefined)
					break
				else {
					car := (carIDs.HasKey(carID) ? carIDs[carID] : "Unknown")

					if ((car = "Unknown") && isDebug())
						showMessage("Unknown car with ID " . carID . " detected...")

					setConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", car)

					if !driverCar
						if ((getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
						 && (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)) {
							driverCar := A_Index

							lastDriverCar := driverCar
						}
						else if (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Time") = lapTime)
							driverCarCandiate := A_Index
				}
			}

			if !driverCar
				driverCar := (lastDriverCar ? lastDriverCar : driverCarCandidate)

			setConfigurationValue(standings, "Position Data", "Driver.Car", driverCar)
			setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
		}
	}

	computeBrakePadWear(location, compound, thickness) {
		if (location = "Front")
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15) / 14 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 13) / 16 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
		else
			switch compound {
				case 1, 4:
					return Max(0, Min(100, 100 - ((thickness - 15.5) / 13.5 * 100)))
				case 2:
					return Max(0, Min(100, 100 - ((thickness - 12.5) / 16.5 * 100)))
				case 3:
					return Max(0, Min(100, 100 - ((thickness - 12) / 17 * 100)))
				default:
					return Max(0, Min(100, 100 - ((thickness - 14.5) / 14.5 * 100)))
			}
	}

	updateSessionData(data) {
		base.updateSessionData(data)

		if !getConfigurationValue(data, "Stint Data", "InPit", false)
			if (getConfigurationValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setConfigurationValue(data, "Session Data", "Paused", true)

		if (getConfigurationValue(data, "Session Data", "Active", false) && !getConfigurationValue(data, "Session Data", "Paused", false)) {
			brakePadThickness := string2Values(",", getConfigurationValue(data, "Car Data", "BrakePadLifeRaw"))
			frontBrakePadCompound := getConfigurationValue(data, "Car Data", "FrontBrakePadCompoundRaw")
			rearBrakePadCompound := getConfigurationValue(data, "Car Data", "RearBrakePadCompoundRaw")

			brakePadWear := [this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[1])
						   , this.computeBrakePadWear("Front", frontBrakePadCompound, brakePadThickness[2])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[3])
						   , this.computeBrakePadWear("Rear", frontBrakePadCompound, brakePadThickness[4])]

			setConfigurationValue(data, "Car Data", "BrakeWear", values2String(",", brakePadWear*))

			if !isDebug() {
				removeConfigurationValue(data, "Car Data", "BrakePadLifeRaw")
				removeConfigurationValue(data, "Car Data", "BrakeDiscLifeRaw")
				removeConfigurationValue(data, "Car Data", "FrontBrakePadCompoundRaw")
				removeConfigurationValue(data, "Car Data", "RearBrakePadCompoundRaw")
			}
		}
	}

	openPitstopMFD(descriptor := false, update := "__Undefined__") {
		static reported := false

		if (this.iImageSearch = kUndefined) {
			car := (this.Car ? this.Car : "*")
			track := (this.Track ? this.Track : "*")

			settings := new SettingsDatabase().loadSettings(this.Simulator[true], car, track, "*")

			this.iImageSearch := getConfigurationValue(settings, "Simulator.Assetto Corsa Competizione", "Pitstop.ImageSearch", false)
		}

		imgSearch := (this.iImageSearch && !this.iNoImageSearch)

		if (update = kUndefined)
			if imgSearch
				update := true
			else {
				if (A_TickCount > this.iNextPitstopMFDOptionsUpdate)
					update := true
				else
					update := false
			}

		this.iNextPitstopMFDOptionsUpdate := (A_TickCount + 60000)

		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.activateWindow()

				this.sendCommand(this.OpenPitstopMFDHotkey)

				if !imgSearch {
					if update {
						this.initializePitstopMFD()

						update := false
					}

					this.iPSIsOpen := true
				}

				wasOpen := this.iPSIsOpen

				this.iPSIsOpen := true
				this.iPSSelectedOption := 1

				if (imgSearch && (update || !wasOpen)) {
					if this.updatePitStopState()
						this.openPitstopMFD(false, false)

					if this.iPSIsOpen
						SetTimer updatePitstopState, 5000
				}
			}
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	resetPitstopMFD(descriptor := false) {
		this.iNextPitstopMFDOptionsUpdate := 0
	}

	closePitstopMFD() {
		static reported := false

		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				this.activateWindow()

				this.sendCommand(this.ClosePitstopMFDHotkey)

				this.iPSIsOpen := false

				SetTimer updatePitstopState, Off
			}
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	requirePitstopMFD(retry := false) {
		static reported := false

		if retry
			this.iNoImageSearch := false

		this.openPitstopMFD()

		if (this.OpenPitstopMFDHotkey = "Off")
			return false
		else if !this.iPSIsOpen {
			if !reported {
				reported := true

				logMessage(kLogCritical, translate("Cannot locate the Pitstop MFD - please consult the documentation for the ACC plugin"))

				Loop 2
					SoundPlay %kResourcesDirectory%Sounds\Critical.wav, Wait
			}

			SoundPlay %kResourcesDirectory%Sounds\Critical.wav

			this.iNoImageSearch := true

			SetTimer updatePitstopState, Off

			this.openPitstopMFD(false, true)

			return true
		}
		else
			return true
	}

	initializePitstopMFD() {
		this.sendCommand(this.OpenPitstopMFDHotkey)

		availableOptions := ["Pit Limiter", "Strategy", "Refuel"
						   , "Change Tyres", "Tyre Set", "Tyre Compound", "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right"
						   , "Change Brakes", "Front Brake", "Rear Brake", "Driver", "Repair Suspension", "Repair Bodywork"]

		currentPressures := this.getPitstopOptionValues("Tyre Pressures")

		if !this.isStrategyAvailable(availableOptions, currentPressures)
			availableOptions.RemoveAt(inList(availableOptions, "Strategy"))

		tyreChange := this.isTyreChangeSelected(availableOptions, currentPressures)

		if !tyreChange {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			Loop % inList(availableOptions, "Change Tyres") - 1
				this.sendCommand("{Down}")

			this.sendCommand("{Right}")
		}

		this.iPSChangeTyres := true

		if this.isWetTyreSelected(availableOptions, currentPressures) {
			this.iPSTyreOptions := 6

			availableOptions.RemoveAt(inList(availableOptions, "Tyre Set"))
		}
		else
			this.iPSTyreOptions := 7

		if this.isBrakeChangeSelected(availableOptions, currentPressures)
			this.iPSChangeBrakes := true
		else
			this.iPSChangeBrakes := false

		if !this.isDriverAvailable(availableOptions, currentPressures)
			availableOptions.RemoveAt(inList(availableOptions, "Driver"))

		if !tyreChange {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			Loop % inList(availableOptions, "Change Tyres") - 1
				this.sendCommand("{Down}")

			this.sendCommand("{Left}")

			this.iPSChangeTyres := false
		}

		this.iPSOptions := availableOptions

		this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
		this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

		this.sendCommand(this.OpenPitstopMFDHotkey)
	}

	isStrategyAvailable(options, currentPressures) {
		index := inList(options, "Change Tyres")

		this.sendCommand(this.OpenPitstopMFDHotkey)

		Loop % inList(options, "Change Tyres") - 1 + 3
			this.sendCommand("{Down}")

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		if listEqual(currentPressures, modifiedPressures) {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			Loop % inList(options, "Change Tyres") - 1
				this.sendCommand("{Down}")

			this.sendCommand("{Right}")

			Loop 3
				this.sendCommand("{Down}")

			this.sendCommand("{Right}")

			modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

			this.sendCommand("{Left}")

			Loop 3
				this.sendCommand("{Up}")

			this.sendCommand("{Left}")

			if listEqual(currentPressures, modifiedPressures)
				return := false
		}

		return true
	}

	isTyreChangeSelected(options, currentPressures) {
		index := inList(options, "Change Tyres")

		this.sendCommand(this.OpenPitstopMFDHotkey)

		Loop % inList(options, "Change Tyres") - 1 + 3
			this.sendCommand("{Down}")

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		return !listEqual(currentPressures, modifiedPressures)
	}

	isWetTyreSelected(options, currentPressures) {
		if this.iPSChangeTyres {
			index := inList(options, "Change Tyres")

			this.sendCommand(this.OpenPitstopMFDHotkey)

			Loop % inList(options, "Change Tyres") - 1 + 4
				this.sendCommand("{Down}")

			this.sendCommand("{Right}")

			modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

			this.sendCommand("{Left}")

			for index, pressure in currentPressures
				if (modifiedPressures[index] != pressure)
					return (index = 2)
		}
		else
			return false
	}

	isBrakeChangeSelected(options, currentPressures) {
		this.sendCommand(this.OpenPitstopMFDHotkey)

		Loop % inList(options, "Change Brakes") - 1
			this.sendCommand("{Down}")

		Loop % 13 - (inList(options, "Strategy") ? 0 : 1) - (7 - this.iPSTyreOptions)
			this.sendCommand("{Down}")

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		for index, pressure in currentPressures
			if (modifiedPressures[index] != pressure)
				if ((index = 1) || (index = 2))
					return true

		return false
	}

	isDriverAvailable(options, currentPressures) {
		this.sendCommand(this.OpenPitstopMFDHotkey)

		Loop % inList(options, "Change Brakes") - 1 + 12 + (this.iPSChangeBrakes ? this.iPSBrakeOptions : 0)
														 + (inList(options, "Strategy") ? 1 : 0)
														 - (7 - this.iPSTyreOptions)
			this.sendCommand("{Down}")

		this.sendCommand("{Right}")

		modifiedPressures := this.getPitstopOptionValues("Tyre Pressures")

		this.sendCommand("{Left}")

		return (currentPressures[3] != modifiedPressures[3])
	}

	selectPitstopOption(option, retry := true) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			targetSelectedOption := inList(this.iPSOptions, option)

			if targetSelectedOption {
				delta := 0

				if (targetSelectedOption > this.iPSTyreOptionPosition) {
					if (targetSelectedOption <= (this.iPSTyreOptionPosition + this.iPSTyreOptions)) {
						if !this.iPSChangeTyres {
							this.toggleActivity("Change Tyres")

							return (retry && this.selectPitstopOption(option, false))
						}
					}
					else
						if !this.iPSChangeTyres
							delta -= this.iPSTyreOptions
				}

				if (targetSelectedOption > this.iPSBrakeOptionPosition) {
					if (targetSelectedOption <= (this.iPSBrakeOptionPosition + this.iPSBrakeOptions)) {
						if !this.iPSChangeBrakes {
							this.toggleActivity("Change Brakes")

							return (retry && this.selectPitstopOption(option, false))
						}
					}
					else
						if !this.iPSChangeBrakes
							delta -= this.iPSBrakeOptions
				}

				targetSelectedOption += delta

				this.activateWindow()

				if (targetSelectedOption > this.iPSSelectedOption)
					Loop % targetSelectedOption - this.iPSSelectedOption
						this.sendCommand("{Down}")
				else
					Loop % this.iPSSelectedOption - targetSelectedOption
						this.sendCommand("{Up}")

				this.iPSSelectedOption := targetSelectedOption

				return true
			}
			else
				return false
		}
		else
			return false
	}

	changePitstopOption(option, direction, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch direction {
				case "Increase":
					this.activateWindow()

					Loop %steps%
						this.sendCommand("{Right}")
				case "Decrease":
					this.activateWindow()

					Loop %steps%
						this.sendCommand("{Left}")
				default:
					Throw "Unsupported change operation """ . direction . """ detected in ACCPlugin.changePitstopOption..."
			}

			if (option = "Repair Suspension")
				this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
			else if (option = "Repair Bodywork")
				this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen

			this.resetPitstopState(inList(kPSMutatingOptions, option))
		}
	}

	updatePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if inList(["Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension"], option)
				this.toggleActivity(option)
			else
				switch option {
					case "Strategy":
						this.changeStrategy(action, steps)
					case "Refuel":
						this.changeFuelAmount(action, steps)
					case "Tyre Compound":
						this.changeTyreCompound(action)
					case "Tyre Set":
						this.changeTyreSet(action, steps)
					case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
						this.changeTyrePressure(option, action, steps)
					case "Front Brake", "Rear Brake":
						this.changeBrakeType(option, action)
					case "Driver":
						this.changeDriver(action)
					default:
						base.updatePitstopOption(option, action, steps)
				}
		}
	}

	toggleActivity(activity) {
		if this.requirePitstopMFD()
			switch activity {
				case "Change Tyres", "Change Brakes", "Repair Bodywork", "Repair Suspension":
					if this.selectPitstopOption(activity)
						this.changePitstopOption(activity, "Increase")
				default:
					Throw "Unsupported activity """ . activity . """ detected in ACCPlugin.toggleActivity..."
			}
	}

	notifyPitstopChanged(option) {
		if this.RaceEngineer
			switch option {
				case "Change Tyres":
					newValues := this.getPitstopOptionValues("Tyre Compound")

					if newValues
						this.RaceEngineer.pitstopOptionChanged("Tyre Compound", newValues*)
				default:
					base.notifyPitstopChanged(option)
			}
	}

	changeStrategy(selection, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Strategy"))
			switch selection {
				case "Next":
					this.changePitstopOption("Strategy", "Increase")
				case "Previous":
					this.changePitstopOption("Strategy", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Strategy", selection)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeStrategy..."
			}
	}

	changeFuelAmount(direction, litres := 5) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Refuel"))
			this.changePitstopOption("Refuel", direction, litres)
	}

	changeTyreCompound(type) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre Compound"))
			switch type {
				case "Wet":
					this.changePitstopOption("Tyre Compound", "Increase")
				case "Dry":
					this.changePitstopOption("Tyre Compound", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Tyre Compound", type)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreCompound..."
			}
	}

	changeTyreSet(selection, steps := 1) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Tyre set"))
			switch selection {
				case "Next":
					this.changePitstopOption("Tyre set", "Increase", steps)
				case "Previous":
					this.changePitstopOption("Tyre set", "Decrease", steps)
				case "Increase", "Decrease":
					this.changePitstopOption("Tyre Set", selection, steps)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeTyreSet..."
			}
	}

	changeTyrePressure(tyre, direction, increments := 1) {
		if this.requirePitstopMFD() {
			found := false

			switch tyre {
				case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
					found := this.selectPitstopOption(tyre)
				default:
					Throw "Unsupported tyre position """ . tyre . """ detected in ACCPlugin.changeTyrePressure..."
			}

			if found
				this.changePitstopOption(tyre, direction, increments)
		}
	}

	changeBrakeType(brake, selection) {
		if this.requirePitstopMFD() {
			found := false

			switch brake {
				case "Front Brake", "Rear Brake":
					found := this.selectPitstopOption(brake)
				default:
					Throw "Unsupported brake """ . brake . """ detected in ACCPlugin.changeBrakeType..."
			}

			if found
				switch selection {
					case "Next":
						this.changePitstopOption(brake, "Increase")
					case "Previous":
						this.changePitstopOption(brake, "Decrease")
					case "Increase", "Decrease":
						this.changePitstopOption(brake, selection)
					default:
						Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeBrakeType..."
				}
		}
	}

	changeDriver(selection) {
		if (this.requirePitstopMFD() && this.selectPitstopOption("Driver"))
			switch selection {
				case "Next":
					this.changePitstopOption("Driver", "Increase")
				case "Previous":
					this.changePitstopOption("Driver", "Decrease")
				case "Increase", "Decrease":
					this.changePitstopOption("Driver", selection)
				default:
					Throw "Unsupported selection """ . selection . """ detected in ACCPlugin.changeDriver..."
			}
	}

	getLabelFileNames(labelNames*) {
		fileNames := []

		for ignore, labelName in labelNames {
			labelName := ("ACC\" . labelName)
			fileName := getFileName(labelName . ".png", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".jpg", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".png", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(labelName . ".jpg", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)
		}

		if (fileNames.Length() == 0) {
			if isDebug()
				showMessage("Unknown label '" . labelName . "' detected in ACCPlugin.getLabelFileName...")
		}
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", labelNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.png", 5000)

			return fileNames
		}
	}

	markFoundLabel(image, x, y) {
		if isDebug() {
			SplitPath image, fileName

			Gui LABEL:-Border -Caption +AlwaysOnTop
			Gui LABEL:Color, D0D0D0, D8D8D8
			Gui LABEL:Add, Text, x0 y0 w100 h23 +0x200 +0x1 BackgroundTrans, %fileName%

			Gui LABEL:Show, AutoSize x%x%, y%y%

			Sleep 1000

			Gui LABEL:Destroy
		}
	}

	searchPitstopLabel(images) {
		static kSearchAreaLeft := 350
		static kSearchAreaRight := 250
		static pitstopLabels := false

		if !pitstopLabels
			pitstopLabels := this.getLabelFileNames("PITSTOP")

		this.activateWindow()

		curTickCount := A_TickCount

		imageX := kUndefined
		imageY := kUndefined

		localLabels := false

		for ignore, fileName in pitstopLabels
			if InStr(fileName, kUserScreenImagesDirectory) {
				localLabels := true

				break
			}

		Loop % (localLabels ? 3 : 1)
		{
			Loop % pitstopLabels.Length()
			{
				pitstopLabel := pitstopLabels[A_Index]

				if !this.iPSImageSearchArea {
					ImageSearch imageX, imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, *100 %pitstopLabel%

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
				}
				else {
					ImageSearch imageX, imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitstopLabel%

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "PITSTOP", ticks: A_TickCount - curTickCount}))
				}

				if imageX is Integer
				{
					if isDebug() {
						images.Push(pitstopLabel)

						this.markFoundLabel(pitstopLabel, imageX, imageY)
					}

					break
				}
			}

			if imageX is Integer
				break
			else
				Sleep 500
		}

		lastY := false

		if imageX is Integer
		{
			lastY := imageY

			if !this.iPSImageSearchArea
				this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
		}
		else {
			this.iPSIsOpen := false

			SetTimer updatePitstopState, Off
		}

		return lastY
	}

	searchStrategyLabel(ByRef lastY, images) {
		static pitStrategyLabels := false
		curTickCount := A_TickCount
		reload := false

		if !pitStrategyLabels
			pitStrategyLabels := this.getLabelFileNames("Pit Strategy 1", "Pit Strategy 2")

		this.activateWindow()

		imageX := kUndefined
		imageY := kUndefined

		Loop % pitStrategyLabels.Length()
		{
			pitStrategyLabel := pitStrategyLabels[A_Index]

			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %pitStrategyLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %pitStrategyLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(pitStrategyLabel)

					this.markFoundLabel(pitStrategyLabel, imageX, imageY)
				}

				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Pit Strategy", ticks: A_TickCount - curTickCount}))

		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Strategy") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Pit Limiter") + 1, "Strategy")

				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}

			lastY := imageY

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Pit Strategy' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}
		else {
			position := inList(this.iPSOptions, "Strategy")

			if position {
				this.iPSOptions.RemoveAt(position)

				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Pit Strategy' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}

		return reload
	}

	searchNoRefuelLabel(ByRef lastY, images) {
		static noRefuelLabels := false
		curTickCount := A_TickCount
		reload := false

		if !noRefuelLabels
			noRefuelLabels := this.getLabelFileNames("No Refuel")

		this.activateWindow()

		imageX := kUndefined
		imageY := kUndefined

		Loop % noRefuelLabels.Length()
		{
			noRefuelLabel := noRefuelLabels[A_Index]

			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *25 %noRefuelLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *25 %noRefuelLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(noRefuelLabel)

					this.markFoundLabel(noRefuelLabel, imageX, imageY)
				}

				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Refuel", ticks: A_TickCount - curTickCount}))

		if imageX is Integer
		{
			position := inList(this.iPSOptions, "Refuel")

			if position {
				this.iPSOptions.RemoveAt(position)

				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}

			lastY := imageY

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Refuel' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}
		else {
			if !inList(this.iPSOptions, "Refuel") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Change Tyres"), "Refuel")

				this.iPSTyreOptionPosition := inList(this.iPSOptions, "Change Tyres")
				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Refuel' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}

		return reload
	}

	searchTyreLabel(ByRef lastY, images) {
		static wetLabels := false
		static compoundLabels := false
		curTickCount := A_TickCount
		reload := false

		if !wetLabels {
			wetLabels := this.getLabelFileNames("Wet 1", "Wet 2")
			compoundLabels := this.getLabelFileNames("Compound 1", "Compound 2")
		}

		this.activateWindow()

		imageX := kUndefined
		imageY := kUndefined

		Loop % wetLabels.Length()
		{
			wetLabel := wetLabels[A_Index]

			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %wetLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %wetLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(wetLabel)

					this.markFoundLabel(wetLabel, imageX, imageY)
				}

				break
			}
		}

		if imageX is Integer
		{
			position := inList(this.iPSOptions, "Tyre Set")

			if position {
				this.iPSOptions.RemoveAt(position)
				this.iPSTyreOptions := 6

				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}
		}
		else {
			if !inList(this.iPSOptions, "Tyre Set") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Tyre Compound"), "Tyre Set")
				this.iPSTyreOptions := 7

				this.iPSBrakeOptionPosition := inList(this.iPSOptions, "Change Brakes")

				reload := true
			}

			imageX := kUndefined
			imageY := kUndefined

			Loop % compoundLabels.Length()
			{
				compoundLabel := compoundLabels[A_Index]

				if !this.iPSImageSearchArea
					ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %compoundLabel%
				else
					ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %compoundLabel%

				if imageX is Integer
				{
					if isDebug() {
						images.Push(compoundLabel)

						this.markFoundLabel(compoundLabel, imageX, imageY)
					}

					break
				}
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Tyre Set", ticks: A_TickCount - curTickCount}))

		if imageX is Integer
		{
			this.iPSChangeTyres := true

			lastY := imageY

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Tyres are selected for change"))
		}
		else {
			this.iPSChangeTyres := false

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Tyres are not selected for change"))
		}

		return reload
	}

	searchBrakeLabel(ByRef lastY, images) {
		static frontBrakeLabels := false
		curTickCount := A_TickCount
		reload := false

		if !frontBrakeLabels
			frontBrakeLabels := this.getLabelFileNames("Front Brake 1", "Front Brake 2")

		this.activateWindow()

		imageX := kUndefined
		imageY := kUndefined

		Loop % frontBrakeLabels.Length()
		{
			frontBrakeLabel := frontBrakeLabels[A_Index]

			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %frontBrakeLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %frontBrakeLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(frontBrakeLabel)

					this.markFoundLabel(frontBrakeLabel, imageX, imageY)
				}

				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Front Brake", ticks: A_TickCount - curTickCount}))

		if imageX is Integer
		{
			this.iPSChangeBrakes := true

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Brakes are selected for change"))
		}
		else {
			this.iPSChangeBrakes := false

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("Pitstop: Brakes are not selected for change"))
		}

		return reload
	}

	searchDriverLabel(ByRef lastY, images) {
		static selectDriverLabels := false
		curTickCount := A_TickCount
		reload := false

		if !selectDriverLabels
			selectDriverLabels := this.getLabelFileNames("Select Driver 1", "Select Driver 2")

		this.activateWindow()

		imageX := kUndefined
		imageY := kUndefined

		Loop % selectDriverLabels.Length()
		{
			selectDriverLabel := selectDriverLabels[A_Index]

			if !this.iPSImageSearchArea
				ImageSearch imageX, imageY, 0, lastY ? lastY : 0, A_ScreenWidth, A_ScreenHeight, *100 %selectDriverLabel%
			else
				ImageSearch imageX, imageY, this.iPSImageSearchArea[1], lastY ? lastY : this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], *100 %selectDriverLabel%

			if imageX is Integer
			{
				if isDebug() {
					images.Push(selectDriverLabel)

					this.markFoundLabel(selectDriverLabel, imageX, imageY)
				}

				break
			}
		}

		if (getLogLevel() <= kLogInfo)
			if !this.iPSImageSearchArea
				logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))
			else
				logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: "Select Driver", ticks: A_TickCount - curTickCount}))

		if imageX is Integer
		{
			if !inList(this.iPSOptions, "Driver") {
				this.iPSOptions.InsertAt(inList(this.iPSOptions, "Repair Suspension"), "Driver")

				reload := true
			}

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Select Driver' detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}
		else {
			position := inList(this.iPSOptions, "Driver")

			if position {
				this.iPSOptions.RemoveAt(position)

				reload := true
			}

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, translate("'Select Driver' not detected, adjusting pitstop options: ") . values2String(", ", this.iPSOptions*))
		}

		return reload
	}

	updatePitstopState(fromTimer := false) {
		if isACCRunning() {
			beginTickCount := A_TickCount
			lastY := 0
			images := []

			try {
				if (fromTimer || !this.iPSImageSearchArea)
					lastY := this.searchPitstopLabel(images)

				if (!fromTimer && this.iPSIsOpen) {
					reload := this.searchStrategyLabel(lastY, images)

					; reload := (this.searchNoRefuelLabel(lastY, images) || reload)

					reload := (this.searchTyreLabel(lastY, images) || reload)

					reload := (this.searchBrakeLabel(lastY, images) || reload)

					reload := (this.searchDriverLabel(lastY, images) || reload)

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Complete update of pitstop state took ") . A_TickCount - beginTickCount . translate(" ms"))

					if isDebug()
						showMessage("Found images: " . values2String(", ", images*), "Pitstop MFD Image Search", "Information.png", 5000)

					return reload
				}
			}
			catch exception {
				this.iPSOpen := false
			}
		}

		return false
	}

	resetPitstopState(update := false) {
		this.openPitstopMFD(false, update)
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

	supportsRaceAssistant(assistantPlugin) {
		if ((assistantPlugin = kRaceStrategistPlugin) || (assistantPlugin = kRaceSpotterPlugin))
			return ((FileExist(kBinariesDirectory . "ACC UDP Provider.exe") != false) && base.supportsRaceAssistant(assistantPlugin))
		else
			return base.supportsRaceAssistant(assistantPlugin)
	}

	getPitstopOptionValues(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option {
				case "Pit Limiter":
					data := readSimulatorData(this.Code, "-Setup")

					return [getConfigurationValue(data, "Car Data", "PitLimiter", false)]
				case "Refuel":
					data := readSimulatorData(this.Code, "-Setup")

					return [getConfigurationValue(data, "Setup Data", "FuelAmount", 0)]
				case "Tyre Pressures":
					data := readSimulatorData(this.Code, "-Setup")

					return [getConfigurationValue(data, "Setup Data", "TyrePressureFL", 26.1), getConfigurationValue(data, "Setup Data", "TyrePressureFR", 26.1)
						  , getConfigurationValue(data, "Setup Data", "TyrePressureRL", 26.1), getConfigurationValue(data, "Setup Data", "TyrePressureRR", 26.1)]
				case "Tyre Set":
					data := readSimulatorData(this.Code, "-Setup")

					return [getConfigurationValue(data, "Setup Data", "TyreSet", 0)]
				case "Tyre Compound":
					if this.iPSChangeTyres {
						data := readSimulatorData(this.Code, "-Setup")

						return [getConfigurationValue(data, "Setup Data", "TyreCompound", false), getConfigurationValue(data, "Setup Data", "TyreCompoundColor", false)]
					}
					else
						return [false, false]
				case "Repair Suspension":
					return [this.iRepairSuspensionChosen]
				case "Repair Bodywork":
					return [this.iRepairBodyworkChosen]
				default:
					return base.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	startPitstopSetup(pitstopNumber) {
		base.startPitstopSetup()

		withProtection(ObjBindMethod(this, "requirePitstopMFD", this.iNoImageSearch))
	}

	finishPitstopSetup(pitstopNumber) {
		base.finishPitstopSetup()

		closePitstopMFD()
	}

	pitstopFinished(pitstopNumber, updateState := false) {
		static callback := false

		if !updateState {
			if callback
				SetTimer %callback%, Off

			base.pitstopFinished(pitstopNumber)
		}

		if this.RaceEngineer {
			if updateState {
				try {
					retry := false

					if FileExist(A_MyDocuments . "\Assetto Corsa Competizione\Debug\swap_dump_carjson.json") {
						FileGetTime updateTime, %A_MyDocuments%\Assetto Corsa Competizione\Debug\swap_dump_carjson.json, M

						EnvAdd updateTime, 5, Minutes

						if (updateTime < A_Now)
							retry := true
						else
							Sleep 5000
					}
					else
						retry := true

					if retry {
						callback := ObjBindMethod(this, "pitstopFinished", pitstopNumber, true)

						SetTimer %callback%, -10000
					}
					else {
						FileRead carState, %A_MyDocuments%\Assetto Corsa Competizione\Debug\swap_dump_carjson.json

						carState := JSON.parse(carState)
						pitstopState := carState["pitstopMFD"]

						currentDriver := pitstopState["driversNames"][pitstopState["currentDriverIndex"] + 1]

						currentTyreSet := carState["currentTyreSet"]
						tyreStates := []

						pitstopData := {Pitstop: pitstopNumber
									  , "Service.Time": pitstopState["timeRequired"]
									  , "Service.Lap": carState["lapCount"]
									  , "Service.Driver.Previous": currentDriver
									  , "Service.Driver.Next": pitstopState["newDriverNameToDisplay"]
									  , "Service.Refuel": pitstopState["fuelToAdd"]
									  , "Service.Bodywork.Repair": (pitstopState["repairBody"] ? true : false)
									  , "Service.Suspension.Repair": (pitstopState["repairSuspension"] ? true : false)
									  , "Service.Engine.Repair": false}

						if !listEqual(pitstopState["tyreToChange"], [false, false, false, false]) {
							pitstopData["Service.Tyre.Compound"] := ((pitstopState["newTyreCompound"] = 0) ? "Dry" : "Wet")
							pitstopData["Service.Tyre.Compound.Color"] := "Black"
							pitstopData["Service.Tyre.Set"] := ((pitstopState["newTyreCompound"] = 0) ? pitstopState["tyreSet"] : false)

							pressures := pitstopState["tyrePressures"]

							for index, pressure in pressures
								pressures[index] := Round(pressure, 1)

							pitstopData["Service.Tyre.Pressures"] := values2String(",", pressures*)
						}

						for ignore, tyreSet in carState["tyreSets"]
							if (tyreSet["tyreSet"] = currentTyreSet) {
								for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"] {
									wearState := tyreSet["wearStatus"][A_Index]
									tread := wearState["treadMM"].Clone()

									wear := Round(100 - ((Max(0, average(tread) - 1.5) / 1.5) * 100))

									for index, section in tread
										tread[index] := Round(section, 2)

									grain := Round(wearState["grain"], 2)
									blister := Round(wearState["blister"], 2)
									flatSpot := Round(wearState["flatSpot"], 2)

									tyreStates.Push({Tyre: tyre, Tread: tread, Wear: wear, Grain: grain, Blister: blister, FlatSpot: flatSpot})
								}

								pitstopData["Tyre.Driver"] := currentDriver
								pitstopData["Tyre.Laps"] := false
								pitstopData["Tyre.Compound"] := "Dry"
								pitstopData["Tyre.Compound.Color"] := "Black"
								pitstopData["Tyre.Set"] := (currentTyreSet + 1)

								break
							}

						data := newConfiguration()

						setConfigurationSectionValues(data, "Pitstop Data", pitstopData)

						for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"]
							for key, value in tyreStates[A_Index]
								setConfigurationValue(data, "Pitstop Data", "Tyre." . key . "." . tyre, IsObject(value) ? values2String(",", value*) : value)

						writeConfiguration(kTempDirectory . "Pitstop " . pitstopNumber . ".ini", data)

						this.RaceEngineer.updatePitstopState(data)
					}
				}
				catch exception {
					; ignore
				}
			}
			else {
				callback := ObjBindMethod(this, "pitstopFinished", pitstopNumber, true)

				SetTimer %callback%, -10000
			}
		}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		base.setPitstopRefuelAmount(pitstopNumber, litres)

		litresIncrement := Round(litres - this.getPitstopOptionValues("Refuel")[1])

		if (litresIncrement != 0)
			changePitstopFuelAmount((litresIncrement > 0) ? "Increase" : "Decrease", Abs(litresIncrement))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		base.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if compound {
			if (this.getPitstopOptionValues("Tyre Compound") != compound)
				changePitstopTyreCompound((compound = "Wet") ? "Increase" : "Decrease")

			if (set && (compound = "Dry")) {
				tyreSetIncrement := Round(set - this.getPitstopOptionValues("Tyre Set")[1])

				if (tyreSetIncrement != 0)
					changePitstopTyreSet((tyreSetIncrement > 0) ? "Next" : "Previous", Abs(tyreSetIncrement))
			}
		}
		else if this.iPSChangeTyres
			this.toggleActivity("Change Tyres")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		base.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		pressures := this.getPitstopOptionValues("Tyre Pressures")

		pressureFLIncrement := Round(pressureFL - pressures[1], 1)
		pressureFRIncrement := Round(pressureFR - pressures[2], 1)
		pressureRLIncrement := Round(pressureRL - pressures[3], 1)
		pressureRRIncrement := Round(pressureRR - pressures[4], 1)

		if (pressureFLIncrement != 0)
			changePitstopTyrePressure("Front Left", (pressureFLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFLIncrement * 10)))
		if (pressureFRIncrement != 0)
			changePitstopTyrePressure("Front Right", (pressureFRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureFRIncrement * 10)))
		if (pressureRLIncrement != 0)
			changePitstopTyrePressure("Rear Left", (pressureRLIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRLIncrement * 10)))
		if (pressureRRIncrement != 0)
			changePitstopTyrePressure("Rear Right", (pressureRRIncrement > 0) ? "Increase" : "Decrease", Abs(Round(pressureRRIncrement * 10)))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		base.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (repairSuspension != this.iRepairSuspensionChosen)
			this.toggleActivity("Repair Suspension")

		if (repairBodywork != this.iRepairBodyworkChosen)
			this.toggleActivity("Repair Bodywork")
	}

	requestPitstopDriver(pitstopNumber, driver) {
		base.requestPitstopDriver(pitstopNumber, driver)

		if driver {
			driver := string2Values("|", driver)

			delta := (string2Values(":", driver[2])[2] - string2Values(":", driver[1])[2])

			Loop % Abs(delta)
				this.changeDriver((delta < 0) ? "Previous" : "Next")
		}
	}

	restoreSessionState(sessionSettings, sessionState) {
		base.restoreSessionState(sessionSettings, sessionState)

		if sessionState {
			sessionState := getConfigurationSectionValues(sessionState, "Session State")

			if sessionState.HasKey("Pitstop.Last") {
				pitstop := sessionState["Pitstop.Last"]

				this.iRepairSuspensionChosen := sessionState["Pitstop." . pitstop . ".Repair.Suspension"]
				this.iRepairBodyworkChosen := sessionState["Pitstop." . pitstop . ".Repair.Bodywork"]

				if (this.iRepairSuspensionChosen = kTrue)
					this.iRepairSuspensionChosen := true
				else if (this.iRepairSuspensionChosen = kFalse)
					this.iRepairSuspensionChosen := false

				if (this.iRepairBodyworkChosen = kTrue)
					this.iRepairBodyworkChosen := true
				else if (this.iRepairBodyworkChosen = kFalse)
					this.iRepairBodyworkChosen := false
			}
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACCPlugin).Simulator
													 , "Simulator Splash Images\ACC Splash.jpg")
}

stopACC() {
	if isACCRunning() {
		SimulatorController.Instance.findPlugin(kACCPlugin).activateWindow()

		MouseClick Left,  2093,  1052
		Sleep 500
		MouseClick Left,  2614,  643
		Sleep 500
		MouseClick Left,  2625,  619
		Sleep 500
	}
}

isACCRunning() {
	Process Exist, acc.exe

	running := (ErrorLevel != 0)

	if !running {
		try {
			thePlugin := SimulatorController.Instance.findPlugin("ACC")

			thePlugin.iRepairSuspensionChosen := true
			thePlugin.iRepairBodyworkChosen := true
		}
		catch exception {
			; ignore
		}
	}

	return running
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updatePitstopState() {
	protectionOn()

	try {
		SimulatorController.Instance.findPlugin(kACCPlugin).updatePitstopState(true)
	}
	finally {
		protectionOff()
	}
}

initializeACCPlugin() {
	local controller := SimulatorController.Instance

	new ACCPlugin(controller, kACCPLugin, kACCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACCPlugin()