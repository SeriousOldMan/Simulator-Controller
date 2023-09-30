;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Strategist Configuration   ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceStrategistConfigurator                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RaceStrategistConfigurator extends ConfiguratorPanel {
	iSimulators := []
	iSimulatorConfigurations := CaseInsenseMap()
	iCurrentSimulator := false

	Simulators {
		Get {
			return this.iSimulators
		}
	}

	__New(editor, configuration := false) {
		this.Editor := editor

		super.__New(configuration)

		RaceStrategistConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, choices, chosen, lineX, lineW

		replicateRSSettings(*) {
			this.replicateSettings()
		}

		validateRSDampingFactor(*) {
			local field := this.Control["rsDampingFactorEdit"]

			if !isNumber(internalValue("Float", field.Text)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")
				
				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseRaceReportsPath(*) {
			local directory, translator

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			directory := DirSelect("*" . window["raceReportsPathEdit"].Text, 0, translate("Select Race Reports Folder..."))
			OnMessage(0x44, translator, 0)

			if (directory != "")
				window["raceReportsPathEdit"].Text := directory
		}

		chooseRaceStrategistSimulator(*) {
			this.saveSimulatorConfiguration()
			this.loadSimulatorConfiguration()
		}

		window.SetFont("Norm", "Arial")

		x0 := x + 8
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176

		w1 := width - (x1 - x + 8)
		w3 := width - (x3 - x + 16) + 10

		w2 := w1 - 24
		x4 := x1 + w2 + 1

		w4 := w1 - 24
		x6 := x1 + w4 + 1

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w160 h23 +0x200 Hidden", translate("Race Reports Folder"))
		widget2 := window.Add("Edit", "x" . x1 . " yp w" . w2 . " h21 W:Grow VraceReportsPathEdit Hidden", this.Value["raceReportsPath"])
		widget3 := window.Add("Button", "x" . x4 . " yp-1 w23 h23 X:Move Hidden", translate("..."))
		widget3.OnEvent("Click", chooseRaceReportsPath)

		lineX := x + 20
		lineW := width - 40

		widget4 := window.Add("Text", "x" . lineX . " yp+30 w" . lineW . " 0x10 W:Grow Hidden")

		widget5 := window.Add("Text", "x" . x0 . " yp+10 w105 h23 +0x200 Hidden", translate("Simulator"))

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

 		choices := this.iSimulators
		chosen := (choices.Length > 0) ? 1 : 0

		widget6 := window.Add("DropDownList", "x" . x1 . " yp w" . w4 . " W:Grow Choose" . chosen . " vrsSimulatorDropDown Hidden", choices)
		widget6.OnEvent("Change", chooseRaceStrategistSimulator)

		widget7 := window.Add("Button", "x" . x6 . " yp w23 h23 X:Move Center +0x200  Hidden")
		widget7.OnEvent("Click", replicateRSSettings)
		setButtonIcon(widget7, kIconsDirectory . "Renew.ico", 1, "L4 T4 R4 B4")

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget8 := window.Add("GroupBox", "x" . x . " yp+40 w" . width . " h96 W:Grow Hidden", translate("Data Analysis"))

		window.SetFont("Norm", "Arial")

		widget9 := window.Add("Text", "x" . x0 . " yp+17 w80 h23 +0x200 Hidden", translate("Learn for"))
		widget10 := window.Add("Edit", "x" . x1 . " yp w40 h21 Number Limit1 vrsLearningLapsEdit Hidden")
		widget11 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 2)
		widget12 := window.Add("Text", "x" . x3 . " yp w" . w3 . " h23 +0x200 Hidden", translate("Laps after Start or Pitstop"))

		widget13 := window.Add("Text", "x" . x0 . " yp+26 w105 h20 Section Hidden", translate("Statistical Window"))
		widget14 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 Number Limit1 vrsLapsConsideredEdit Hidden", 5)
		widget15 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 5)
		widget16 := window.Add("Text", "x" . x3 . " yp+2 w80 h20 Hidden", translate("Laps"))

		widget17 := window.Add("Text", "x" . x0 . " ys+24 w105 h20 Section Hidden", translate("Damping Factor"))
		widget18 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 vrsDampingFactorEdit Hidden", displayValue("Float", 0.2, 1))
		widget18.OnEvent("Change", validateRSDampingFactor)
		widget19 := window.Add("Text", "x" . x3 . " yp+2 w80 h20 Hidden", translate("p. Lap"))

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget20 := window.Add("GroupBox", "x" . x . " yp+40 w" . width . " h96 W:Grow Hidden", translate("Actions"))

		window.SetFont("Norm", "Arial")

		choices := collect(["Ask", "Always save", "No action"], translate)
		widget21 := window.Add("Text", "x" . x0 . " yp+17 w105 h23 +0x200 Hidden", translate("Save Race Report"))
		widget22 := window.Add("DropDownList", "x" . x1 . " yp w110 W:Grow(0.3) vrsSaveRaceReportDropDown Hidden", choices)

		x5 := x1 + 114

		widget23 := window.Add("Text", "x" . x5 . " yp+3 w110 h20 X:Move(0.3) Hidden", translate("@ Session End"))

		choices := collect(["Ask", "Always save", "No action"], translate)
		widget24 := window.Add("Text", "x" . x0 . " yp+21 w105 h23 +0x200 Hidden", translate("Save Telemetry"))
		widget25 := window.Add("DropDownList", "x" . x1 . " yp w110 W:Grow(0.3) vrsSaveTelemetryDropDown Hidden", choices)

		widget26 := window.Add("Text", "x" . x5 . " yp+3 w110 h20 X:Move(0.3) Hidden", translate("@ Session End"))

		choices := collect(["No", "Yes"], translate)
		widget27 := window.Add("Text", "x" . x0 . " yp+21 w105 h23 +0x200 Hidden", translate("Race Review"))
		widget28 := window.Add("DropDownList", "x" . x1 . " yp w110 W:Grow(0.3) vrsRaceReviewDropDown Hidden", choices)

		widget29 := window.Add("Text", "x" . x5 . " yp+3 w110 h20 X:Move(0.3) Hidden", translate("@ Session End"))

		loop 29
			editor.registerWidget(this, widget%A_Index%)

		this.loadSimulatorConfiguration()
	}

	loadFromConfiguration(configuration) {
		local ignore, simulator, simulatorConfiguration

		super.loadFromConfiguration(configuration)

		this.Value["raceReportsPath"] := getMultiMapValue(configuration, "Race Strategist Reports", "Database", false)

		if !this.Value["raceReportsPath"]
			this.Value["raceReportsPath"] := ""

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

		for ignore, simulator in this.Simulators {
			simulatorConfiguration := CaseInsenseMap()

			simulatorConfiguration["LearningLaps"] := getMultiMapValue(configuration, "Race Strategist Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getMultiMapValue(configuration, "Race Strategist Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getMultiMapValue(configuration, "Race Strategist Analysis", simulator . ".HistoryLapsDamping", 0.2)
			simulatorConfiguration["SaveRaceReport"] := getMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".SaveRaceReport", "Never")
			simulatorConfiguration["SaveTelemetry"] := getMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".SaveTelemetry", "Always")
			simulatorConfiguration["RaceReview"] := getMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".RaceReview", "Yes")

			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local simulator, simulatorConfiguration, ignore, key

		super.saveToConfiguration(configuration)

		this.saveSimulatorConfiguration()

		setMultiMapValue(configuration, "Race Strategist Reports", "Database"
									  , (Trim(this.Control["raceReportsPathEdit"].Text) != "") ? Trim(this.Control["raceReportsPathEdit"].Text) : false)

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping"]
				setMultiMapValue(configuration, "Race Strategist Analysis", simulator . "." . key, simulatorConfiguration[key])

			setMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".SaveRaceReport", simulatorConfiguration["SaveRaceReport"])
			setMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".SaveTelemetry", simulatorConfiguration["SaveTelemetry"])
			setMultiMapValue(configuration, "Race Strategist Shutdown", simulator . ".RaceReview", simulatorConfiguration["RaceReview"])
		}
	}

	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)

		this.Control["raceReportsPathEdit"].Text := this.Value["raceReportsPath"]

		this.setSimulators(simulators)
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration, this.getSimulators())
	}

	loadSimulatorConfiguration(simulator := false) {
		local configuration

		if simulator
			this.Control["rsSimulatorDropDown"].Choose(inList(this.iSimulators, simulator))

		this.iCurrentSimulator := this.Control["rsSimulatorDropDown"].Text

		if this.iSimulatorConfigurations.Has(this.iCurrentSimulator) {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			this.Control["rsSaveRaceReportDropDown"].Choose(inList(["Ask", "Always", "Never"], configuration["SaveRaceReport"]))
			this.Control["rsSaveTelemetryDropDown"].Choose(inList(["Ask", "Always", "Never"], configuration["SaveTelemetry"]))
			this.Control["rsRaceReviewDropDown"].Choose(inList(["No", "Yes"], configuration["RaceReview"]))
			this.Control["rsLearningLapsEdit"].Text := configuration["LearningLaps"]
			this.Control["rsLapsConsideredEdit"].Text := configuration["ConsideredHistoryLaps"]

			this.Control["rsDampingFactorEdit"].Text := displayValue("Float", configuration["HistoryLapsDamping"], 1)
			this.Control["rsDampingFactorEdit"].ValidText := this.Control["rsDampingFactorEdit"].Text
		}
	}

	saveSimulatorConfiguration() {
		local configuration

		if this.iCurrentSimulator {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			configuration["LearningLaps"] := this.Control["rsLearningLapsEdit"].Text
			configuration["ConsideredHistoryLaps"] := this.Control["rsLapsConsideredEdit"].Text
			configuration["HistoryLapsDamping"] := internalValue("Float", this.Control["rsDampingFactorEdit"].Text)
			configuration["SaveRaceReport"] := ["Ask", "Always", "Never"][this.Control["rsSaveRaceReportDropDown"].Value]
			configuration["SaveTelemetry"] := ["Ask", "Always", "Never"][this.Control["rsSaveTelemetryDropDown"].Value]
			configuration["RaceReview"] := ["No", "Yes"][this.Control["rsRaceReviewDropDown"].Value]
		}
	}

	setSimulators(simulators) {
		this.iSimulators := simulators

		this.Control["rsSimulatorDropDown"].Delete()
		this.Control["rsSimulatorDropDown"].Add(simulators)

		if (simulators.Length > 0) {
			this.loadFromConfiguration(this.Configuration)

			this.loadSimulatorConfiguration(simulators[1])
		}
	}

	getSimulators() {
		return this.Editor.getSimulators()
	}

	replicateSettings() {
		local configuration, simulator, simulatorConfiguration

		this.saveSimulatorConfiguration()

		configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations
			if (simulator != this.iCurrentSimulator)
				for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "SaveRaceReport", "SaveTelemetry", "RaceReview"]
					simulatorConfiguration[key] := configuration[key]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Race Strategist"), RaceStrategistConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceStrategistConfigurator()