;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\JSON.ahk"
#Include "..\Framework\Extensions\Task.ahk"
#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kR3EApplication := "RaceRoom Racing Experience"

global kR3EPlugin := "R3E"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kBinaryOptions := ["Serve Penalty", "Change Front Tyres", "Change Rear Tyres", "Repair Bodywork", "Repair Front Aero", "Repair Rear Aero", "Repair Suspension", "Request Pitstop"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EPlugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false

	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false
	iAcceptChoiceHotkey := false

	iPSImageSearchArea := false
	iPitstopOptions := []
	iPitstopOptionStates := []

	iImageSearch := kUndefined

	Car {
		Set {
			if (this.Car != value)
				this.iImageSearch := kUndefined

			return (super.Car := value)
		}
	}

	Track {
		Set {
			if (this.Track != value)
				this.iImageSearch := kUndefined

			return (super.Track := value)
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

	AcceptChoiceHotkey {
		Get {
			return this.iAcceptChoiceHotkey
		}
	}

	__New(controller, name, simulator, configuration := false, register := true) {
		super.__New(controller, name, simulator, configuration, register)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off")) {
				this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

				this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "W")
				this.iNextOptionHotkey := this.getArgumentValue("nextOption", "S")
				this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "A")
				this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "D")
				this.iAcceptChoiceHotkey := this.getArgumentValue("acceptChoice", "{Enter}")
			}
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("Strategy", "Strategy", "NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreChange", "Tyre Change"
								   , "TyreChangeFront", "Tyre Change Front", "TyreChangeRear", "Tyre Change Rear"
								   , "TyreCompound", "Tyre Compound"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension")

		selectActions := []
	}

	simulatorStartup(simulator) {
		if (simulator = kR3EApplication)
			Task.startTask(ObjBindMethod(R3EProvider, "loadDatabase"), 1000, kLowPriority)

		super.simulatorStartup(simulator)
	}

	pitstopMFDIsOpen() {
		local pitMenuState

		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.iImageSearch {
				if this.activateWindow() {
					if this.searchMFDImage("PITSTOP 1", "PITSTOP 2") {
						this.sendCommand(this.NextOptionHotkey)

						return true
					}
					else
						return false
				}
				else
					return false
			}
			else {
				pitMenuState := getMultiMapValues(callSimulator(this.Code), "Pit Menu State")

				if ((pitMenuState["Selected"] != "Unavailable") || (pitMenuState["Strategy"] != "Unavailable") || (pitMenuState["Refuel"] != "Unavailable")) {
					this.sendCommand(this.NextOptionHotkey)

					return true
				}
				else
					return false
			}
		}
		else
			return false
	}

	openPitstopMFD(descriptor := false) {
		local isOpen := false
		local secondTry, car, track, settings

		static first := true
		static reported := false

		if (this.iImageSearch = kUndefined) {
			car := (this.Car ? this.Car : "*")
			track := (this.Track ? this.Track : "*")

			settings := SettingsDatabase().loadSettings(this.Simulator[true], car, track, "*", "*")

			this.iImageSearch := getMultiMapValue(settings, "Simulator.RaceRoom Racing Experience", "Pitstop.ImageSearch", false)
		}

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

		if (this.OpenPitstopMFDHotkey != "Off") {
			if this.activateWindow() {
				secondTry := false

				if first
					this.sendCommand(this.OpenPitstopMFDHotkey)

				if !this.pitstopMFDIsOpen() {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					secondTry := true
				}

				if (first && secondTry)
					isOpen := this.pitstopMFDIsOpen()

				first := false

				return isOpen
			}
			else
				return false
		}
		else
			return false
	}

	closePitstopMFD() {
		if this.activateWindow()
			if this.pitstopMFDIsOpen() {
				if this.ClosePitstopMFDHotkey {
					this.sendCommand(this.ClosePitstopMFDHotkey)

					Sleep(50)
				}
			}
	}

	requirePitstopMFD() {
		if this.openPitstopMFD() {
			this.analyzePitstopMFD()

			return true
		}
		else
			return false
	}

	analyzePitstopMFD() {
		local pitMenuState

		if (this.OpenPitstopMFDHotkey = "Off")
			return

		this.iPitstopOptions := []
		this.iPitstopOptionStates := []

		if this.activateWindow() {
			loop 15
				this.sendCommand(this.NextOptionHotkey)

			if this.iImageSearch {
				if this.searchMFDImage("Strategy") {
					this.iPitstopOptions.Push("Strategy")
					this.iPitstopOptionStates.Push(true)
				}

				if this.searchMFDImage("Refuel") {
					this.iPitstopOptions.Push("Refuel")
					this.iPitstopOptionStates.Push(true)
				}
				else if (this.searchMFDImage("No Refuel")) {
					this.iPitstopOptions.Push("Refuel")
					this.iPitstopOptionStates.Push(false)
				}

				if this.searchMFDImage("Front Tyre Change") {
					this.iPitstopOptions.Push("Change Front Tyres")
					this.iPitstopOptionStates.Push(true)
				}
				else { ; if this.searchMFDImage("No Front Tyre Change") {
					this.iPitstopOptions.Push("Change Front Tyres")
					this.iPitstopOptionStates.Push(false)
				}

				if this.searchMFDImage("Rear Tyre Change") {
					this.iPitstopOptions.Push("Change Rear Tyres")
					this.iPitstopOptionStates.Push(true)
				}
				else { ; if this.searchMFDImage("No Rear Tyre Change") {
					this.iPitstopOptions.Push("Change Rear Tyres")
					this.iPitstopOptionStates.Push(false)
				}

				if this.searchMFDImage("Bodywork Damage") {
					this.iPitstopOptions.Push("Repair Bodywork")
					this.iPitstopOptionStates.Push(this.searchMFDImage("Bodywork Damage Selected") != false)
				}

				if this.searchMFDImage("Front Damage") {
					this.iPitstopOptions.Push("Repair Front Aero")
					this.iPitstopOptionStates.Push(this.searchMFDImage("Front Damage Selected") != false)
				}

				if this.searchMFDImage("Rear Damage") {
					this.iPitstopOptions.Push("Repair Rear Aero")
					this.iPitstopOptionStates.Push(this.searchMFDImage("Rear Damage Selected") != false)
				}

				if this.searchMFDImage("Suspension Damage") {
					this.iPitstopOptions.Push("Repair Suspension")
					this.iPitstopOptionStates.Push(this.searchMFDImage("Suspension Damage Selected") != false)
				}

				if this.searchMFDImage("PIT REQUEST") {
					this.iPitstopOptions.Push("Request Pitstop")
					this.iPitstopOptionStates.Push(true)
				}
				else {
					this.iPitstopOptions.Push("Request Pitstop")
					this.iPitstopOptionStates.Push(false)
				}
			}
			else {
				pitMenuState := getMultiMapValues(callSimulator(this.Code), "Pit Menu State")

				if (pitMenuState["Strategy"] != "Unavailable") {
					this.iPitstopOptions.Push("Strategy")
					this.iPitstopOptionStates.Push(pitMenuState["Strategy"])
				}

				if (pitMenuState["Serve Penalty"] != "Unavailable") {
					this.iPitstopOptions.Push("Serve Penalty")
					this.iPitstopOptionStates.Push(pitMenuState["Serve Penalty"])
				}

				if (pitMenuState["Driver"] != "Unavailable") {
					this.iPitstopOptions.Push("Driver")
					this.iPitstopOptionStates.Push(pitMenuState["Driver"])
				}

				if (pitMenuState["Refuel"] != "Unavailable") {
					this.iPitstopOptions.Push("Refuel")
					this.iPitstopOptionStates.Push(pitMenuState["Refuel"])
				}

				if (pitMenuState["Change Front Tyres"] != "Unavailable") {
					this.iPitstopOptions.Push("Change Front Tyres")
					this.iPitstopOptionStates.Push(pitMenuState["Change Front Tyres"])
				}

				if (pitMenuState["Change Rear Tyres"] != "Unavailable") {
					this.iPitstopOptions.Push("Change Rear Tyres")
					this.iPitstopOptionStates.Push(pitMenuState["Change Rear Tyres"])
				}

				if (pitMenuState["Repair Bodywork"] != "Unavailable") {
					this.iPitstopOptions.Push("Repair Bodywork")
					this.iPitstopOptionStates.Push(pitMenuState["Repair Bodywork"])
				}

				if (pitMenuState["Repair Front Aero"] != "Unavailable") {
					this.iPitstopOptions.Push("Repair Front Aero")
					this.iPitstopOptionStates.Push(pitMenuState["Repair Front Aero"])
				}

				if (pitMenuState["Repair Rear Aero"] != "Unavailable") {
					this.iPitstopOptions.Push("Repair Rear Aero")
					this.iPitstopOptionStates.Push(pitMenuState["Repair Rear Aero"])
				}

				if (pitMenuState["Repair Suspension"] != "Unavailable") {
					this.iPitstopOptions.Push("Repair Suspension")
					this.iPitstopOptionStates.Push(pitMenuState["Repair Suspension"])
				}

				if (pitMenuState["Bottom Button"] != "Unavailable") {
					this.iPitstopOptions.Push("Request Pitstop")
					this.iPitstopOptionStates.Push(pitMenuState["Bottom Button"])
				}
			}
		}
	}

	optionAvailable(option) {
		return (this.optionIndex(option) != 0)
	}

	optionChosen(option) {
		local index := this.optionIndex(option)

		return (index ? this.iPitstopOptionStates[index] : false)
	}

	optionIndex(option) {
		return inList(this.iPitstopOptions, option)
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			if this.activateWindow()
				switch action, false {
					case "Accept":
						this.sendCommand(this.AcceptChoiceHotkey)
					case "Increase":
						loop steps
							this.sendCommand(this.NextChoiceHotkey)
					case "Decrease":
						loop steps
							this.sendCommand(this.PreviousChoiceHotkey)
					default:
						throw "Unsupported change operation `"" . action . "`" detected in R3EPlugin.dialPitstopOption..."
				}
	}

	selectPitstopOption(option) {
		local index

		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Repair Bodywork")
				return (this.optionAvailable("Repair Bodywork") || this.optionAvailable("Repair Front Aero") || this.optionAvailable("Repair Rear Aero"))
			else if ((option = "Tyre Change") || (option = "Tyre Compound"))
				return (this.optionAvailable("Change Front Tyres") || this.optionAvailable("Change Rear Tyres"))
			else if (option = "Tyre Change Front")
				return this.optionAvailable("Change Front Tyres")
			else if (option = "Tyre Change Rear")
				return this.optionAvailable("Change Rear Tyres")
			else if this.activateWindow() {
				index := this.optionIndex(option)

				if index {
					loop 15
						this.sendCommand(this.PreviousOptionHotkey)

					index -= 1

					if index
						loop index
							this.sendCommand(this.NextOptionHotkey)

					return true
				}
				else
					return false
			}
			else
				return false
		}
	}

	changePitstopOption(option, action, steps := 1) {
		local changed

		if (this.OpenPitstopMFDHotkey != "Off") {
			if (option = "Strategy")
				this.dialPitstopOption(option, action, steps)
			else if (option = "Refuel")
				this.changeFuelAmount(action, steps, false, false)
			else if (option = "No Refuel")
				this.changeFuelAmount("Decrease", 250, false, false)
			else if (option = "Tyre Change") {
				this.toggleActivity("Change Front Tyres", false, true)
				this.toggleActivity("Change Rear Tyres", false, true)
			}
			else if (option = "Tyre Change Front")
				this.toggleActivity("Change Front Tyres", false, true)
			else if (option = "Tyre Change Rear")
				this.toggleActivity("Change Rear Tyres", false, true)
			else if (option = "Tyre Compound") {
				changed := false

				if !this.optionChosen("Change Front Tyres") {
					this.toggleActivity("Change Front Tyres", false, true)

					changed := true
				}

				if !this.optionChosen("Change Rear Tyres") {
					this.toggleActivity("Change Rear Tyres", false, true)

					changed := true
				}

				if changed
					this.analyzePitstopMFD()

				this.changeTyreCompound(action, steps, false)
			}
			else if (option = "Repair Bodywork") {
				this.toggleActivity("Repair Bodywork", false, true)
				this.toggleActivity("Repair Front Aero", false, true)
				this.toggleActivity("Repair Rear Aero", false, true)
			}
			else if (option = "Repair Suspension")
				this.toggleActivity("Repair Suspension", false, false)
			else
				throw "Unsupported change operation `"" . action . "`" detected in R3EPlugin.changePitstopOption..."
		}
	}

	toggleActivity(activity, require := true, select := true) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if inList(kBinaryOptions, activity) {
				if (!require || this.requirePitstopMFD())
					if (!select || this.selectPitstopOption(activity))
						this.dialPitstopOption(activity, "Accept")
			}
			else
				throw "Unsupported activity `"" . activity . "`" detected in R3EPlugin.toggleActivity..."
		}
	}

	changeFuelAmount(direction, liters := 5, require := true, select := true, accept := true) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (!require || this.requirePitstopMFD())
				if (!select || this.selectPitstopOption("Refuel")) {
					if (accept && this.optionChosen("Refuel"))
						this.sendCommand(this.AcceptChoiceHotkey)

					this.dialPitstopOption("Refuel", direction, liters)

					if accept
						this.sendCommand(this.AcceptChoiceHotkey)
				}
		}
	}

	changeTyreCompound(direction, steps := 1, require := true, accept := true) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			if (!require || this.requirePitstopMFD()) {
				if (accept && this.selectPitstopOption("Change Front Tyres") && this.optionChosen("Change Front Tyres"))
					this.sendCommand(this.AcceptChoiceHotkey)

				if (accept && this.selectPitstopOption("Change Rear Tyres") && this.optionChosen("Change Rear Tyres"))
					this.sendCommand(this.AcceptChoiceHotkey)

				if this.selectPitstopOption("Change Front Tyres")
					this.dialPitstopOption("Change Front Tyres", direction, steps)

				if this.selectPitstopOption("Change Rear Tyres") {
					this.dialPitstopOption("Change Rear Tyres", direction, steps)

					if accept
						this.sendCommand(this.AcceptChoiceHotkey)
				}

				if (accept && this.selectPitstopOption("Change Front Tyres"))
					this.sendCommand(this.AcceptChoiceHotkey)
			}
		}
	}

	startPitstopSetup(pitstopNumber) {
		super.startPitstopSetup(pitstopNumber)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
			if this.requirePitstopMFD()
				if this.optionChosen("Request Pitstop")
					this.toggleActivity("Request Pitstop", false, true)
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
			if this.activateWindow() {
				loop 10
					this.sendCommand(this.NextOptionHotkey)

				this.sendCommand(this.AcceptChoiceHotkey)
			}
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off")) {
			if this.optionAvailable("Refuel") {
				if this.optionChosen("Refuel")
					this.sendCommand(this.AcceptChoiceHotkey)

				this.changeFuelAmount("Decrease", 250, false, true, false)

				this.changeFuelAmount("Increase", liters + 3, false, false, false)

				this.sendCommand(this.AcceptChoiceHotkey)
			}
		}
	}

	setPitstopTyreCompound(pitstopNumber, compound, compoundColor := false, set := false) {
		local index, axle

		super.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off")) {
			if InStr(compound, ",") {
				compound := string2Values(",", compound)
				compoundColor := string2Values(",", compoundColor)
			}
			else {
				compound := [compound, compound]
				compoundColor := [compoundColor, compoundColor]
			}

			for index, axle in ["Front", "Rear"]
				if this.optionAvailable("Change " . axle . " Tyres")
					if compound[index] {
						if !this.optionChosen("Change " . axle . " Tyres") {
							this.toggleActivity("Change " . axle . " Tyres", false, true)

							this.analyzePitstopMFD()
						}

						this.changeTyreCompound("Decrease", 10, false)

						this.changeTyreCompound("Increase", this.tyreCompoundIndex(compound[index], compoundColor[index]), false)
					}
					else if this.optionChosen("Change " . axle . " Tyres")
						this.toggleActivity("Change " . axle . " Tyres", false, true)
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off")) {
			if (this.optionAvailable("Repair Suspension") && (repairSuspension != this.optionChosen("Repair Suspension")))
				this.toggleActivity("Repair Suspension", false, true)

			if (this.optionAvailable("Repair Bodywork") && (repairBodywork != this.optionChosen("Repair Bodywork")))
				this.toggleActivity("Repair Bodywork", false, true)

			if (this.optionAvailable("Repair Front Aero") && (repairBodywork != this.optionChosen("Repair Front Aero")))
				this.toggleActivity("Repair Front Aero", false, true)

			if (this.optionAvailable("Repair Rear Aero") && (repairBodywork != this.optionChosen("Repair Rear Aero")))
				this.toggleActivity("Repair Rear Aero", false, true)
		}
	}

	getImageFileNames(imageNames*) {
		local fileNames := []
		local ignore, imageName, fileName

		for ignore, imageName in imageNames {
			imageName := ("R3E\" . imageName)
			fileName := getFileName(imageName . ".png", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(imageName . ".jpg", kUserScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(imageName . ".png", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)

			fileName := getFileName(imageName . ".jpg", kScreenImagesDirectory)

			if FileExist(fileName)
				fileNames.Push(fileName)
		}

		if (fileNames.Length == 0)
			throw "Unknown image '" . imageName . "' detected in R3EPlugin.getLabelFileName..."
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", imageNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.ico", 5000)

			return fileNames
		}
	}

	searchMFDImage(imageNames*) {
		local imageName, pitstopImages, curTickCount, imageX, imageY, pitstopImage

		static kSearchAreaLeft := 0
		static kSearchAreaRight := 400

		loop imageNames.Length {
			imageName := imageNames[A_Index]
			pitstopImages := this.getImageFileNames(imageName)

			if this.activateWindow() {
				curTickCount := A_TickCount

				imageX := kUndefined
				imageY := kUndefined

				loop pitstopImages.Length {
					pitstopImage := pitstopImages[A_Index]

					if !this.iPSImageSearchArea {
						ImageSearch(&imageX, &imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " . pitstopImage)

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: imageName, ticks: A_TickCount - curTickCount}))

						if isInteger(imageX)
							if ((imageName = "PITSTOP 1") || (imageName = "PITSTOP 2"))
								this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
					}
					else {
						ImageSearch(&imageX, &imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], "*100 " . pitstopImage)

						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: imageName, ticks: A_TickCount - curTickCount}))
					}

					if isInteger(imageX) {
						if isLogLevel(kLogInfo)
							logMessage(kLogInfo, substituteVariables(translate("'%image%' found at %x%, %y%"), {image: imageName, x: imageX, y: imageY}))

						return true
					}
				}
			}
		}

		if isLogLevel(kLogInfo)
			logMessage(kLogInfo, substituteVariables(translate("'%image%' not found"), {image: imageName}))

		return false
	}

	prepareSettings(settings, data) {
		settings := super.prepareSettings(settings, data)

		if (getMultiMapValue(settings, "Simulator.RaceRoom Racing Experience", "Pitstop.Service.Tyres", kUndefined) == kUndefined)
			setMultiMapValue(settings, "Simulator.RaceRoom Racing Experience", "Pitstop.Service.Tyres", "Change")

		return settings
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startR3E() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kR3EPlugin).Simulator
													 , "Simulator Splash Images\R3E Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin() {
	local controller := SimulatorController.Instance

	R3EPlugin(controller, kR3EPlugin, kR3EApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin()
