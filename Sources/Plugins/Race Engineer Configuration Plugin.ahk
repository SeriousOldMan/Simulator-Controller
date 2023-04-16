;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Engineer Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; RaceEngineerConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RaceEngineerConfigurator extends ConfiguratorPanel {
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

		RaceEngineerConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, x2, x3, x4, w1, w2, w3, choices, chosen

		replicateRESettings(*) {
			this.replicateSettings()
		}

		validateREDampingFactor(*) {
			local field := this.Control["reDampingFactorEdit"]

			if !isNumber(internalValue("Float", field.Text))
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")
			else
				field.ValidText := field.Text
		}

		chooseRaceEngineerSimulator(*) {
			this.saveSimulatorConfiguration()
			this.loadSimulatorConfiguration()
		}

		window.SetFont("Norm", "Arial")

		x0 := x + 8
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176

		w1 := width - (x1 - x + 8)
		w2 := w1 - 24
		x4 := x1 + w2 + 1
		w3 := width - (x3 - x + 16) + 10

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w105 h23 +0x200 Hidden", translate("Simulator"))

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

 		choices := this.iSimulators
		chosen := (choices.Length > 0) ? 1 : 0

		widget2 := window.Add("DropDownList", "x" . x1 . " y" . y . " w" . w2 . " W:Grow Choose" . chosen . " vreSimulatorDropDown Hidden", choices)
		widget2.OnEvent("Change", chooseRaceEngineerSimulator)

		widget3 := window.Add("Button", "x" . x4 . " yp w23 h23 X:Move Center +0x200 Hidden")
		widget3.OnEvent("Click", replicateRESettings)
		setButtonIcon(widget3, kIconsDirectory . "Renew.ico", 1, "L4 T4 R4 B4")

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget4 := window.Add("GroupBox", "x" . x . " yp+40 w" . width . " h70 W:Grow Hidden", translate("Settings (for all Race Assistants)"))

		window.SetFont("Norm", "Arial")

		widget5 := window.Add("Text", "x" . x0 . " yp+17 w120 h23 +0x200 Hidden", translate("@ Session Begin"))
		choices := collect(["Load from previous Session", "Load from Database"], translate)
		widget6 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " W:Grow AltSubmit vreLoadSettingsDropDown Hidden", choices)

		widget7 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Hidden", translate("@ Session End"))
		choices := collect(["Ask", "Always save", "No action"], translate)
		widget8 := window.Add("DropDownList", "x" . x1 . " yp w140 W:Grow(0.3) AltSubmit vreSaveSettingsDropDown Hidden", choices)

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget9 := window.Add("GroupBox", "x" . x . " yp+35 w" . width . " h70 W:Grow Hidden", translate("Tyre Pressures"))

		window.SetFont("Norm", "Arial")

		widget10 := window.Add("Text", "x" . x0 . " yp+17 w120 h23 +0x200 Hidden", translate("@ Session Begin"))
		choices := collect(["Load from Settings", "Load from Database", "Import from Simulator", "Use initial pressures"], translate)
		widget11 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " W:Grow AltSubmit Choose1 vreLoadTyrePressuresDropDown Hidden", choices)

		widget12 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Hidden", translate("@ Session End"))
		choices := collect(["Ask", "Always save", "No action"], translate)
		widget13 := window.Add("DropDownList", "x" . x1 . " yp w140 W:Grow(0.3) AltSubmit vreSaveTyrePressuresDropDown Hidden", choices)

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		widget14 := window.Add("GroupBox", "x" . x . " yp+35 w" . width . " h156 W:Grow Hidden", translate("Data Analysis"))

		window.SetFont("Norm", "Arial")

		widget15 := window.Add("Text", "x" . x0 . " yp+17 w80 h23 +0x200 Hidden", translate("Learn for"))
		widget16 := window.Add("Edit", "x" . x1 . " yp w40 h21 Number Limit1 vreLearningLapsEdit Hidden")
		widget17 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 2)
		widget18 := window.Add("Text", "x" . x3 . " yp w" . w3 . " h23 +0x200 Hidden", translate("Laps after Start or Pitstop"))

		widget19 := window.Add("Text", "x" . x0 . " yp+26 w105 h20 Section Hidden", translate("Statistical Window"))
		widget20 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 Number Limit1 vreLapsConsideredEdit Hidden", 5)
		widget21 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", 5)
		widget22 := window.Add("Text", "x" . x3 . " yp+2 w" . w3 . " h20 Hidden", translate("Laps"))

		widget23 := window.Add("Text", "x" . x0 . " ys+24 w105 h20 Section Hidden", translate("Damping Factor"))
		widget24 := window.Add("Edit", "x" . x1 . " yp-2 w40 h21 vreDampingFactorEdit  Hidden", displayValue("Float", 0.2, 1))
		widget24.OnEvent("Change", validateREDampingFactor)

		widget25 := window.Add("Text", "x" . x3 . " yp+2 w" . w3 . " h20 Hidden", translate("p. Lap"))

		widget26 := window.Add("Text", "x" . x0 . " ys+30 w160 h23 +0x200 Section Hidden", translate("Adjust Lap Time"))
		widget27 := window.Add("CheckBox", "x" . x1 . " yp w" . w1 . " h23 VreAdjustLapTimeCheck Hidden", translate("for Start, Pitstop or incomplete Laps (use from Settings)"))

		widget28 := window.Add("Text", "x" . x0 . " ys+30 w120 h23 +0x200 Section Hidden", translate("Damage Analysis for"))
		widget29 := window.Add("Edit", "x" . x1 . " yp w40 h21 Number Limit1 VreDamageAnalysisLapsEdit Hidden")
		widget30 := window.Add("UpDown", "x" . x2 . " yp w17 h21 Range1-9 Hidden", "1")
		widget31 := window.Add("Text", "x" . x3 . " yp-2 w" . w3 . " h23 +0x200 Hidden", translate("Laps after Incident"))

		loop 31
			editor.registerWidget(this, widget%A_Index%)

		this.loadSimulatorConfiguration()
	}

	loadFromConfiguration(configuration) {
		local ignore, simulator, simulatorConfiguration

		super.loadFromConfiguration(configuration)

		if (this.Simulators.Length = 0)
			this.iSimulators := this.getSimulators()

		for ignore, simulator in this.Simulators {
			simulatorConfiguration := CaseInsenseMap()

			simulatorConfiguration["LoadSettings"] := getMultiMapValue(configuration, "Race Assistant Startup", simulator . ".LoadSettings", getMultiMapValue(configuration, "Race Engineer Startup", simulator . ".LoadSettings", "SettingsDatabase"))

			simulatorConfiguration["LoadTyrePressures"] := getMultiMapValue(configuration, "Race Engineer Startup", simulator . ".LoadTyrePressures", "Setup")

			simulatorConfiguration["SaveSettings"] := getMultiMapValue(configuration, "Race Assistant Shutdown", simulator . ".SaveSettings", getMultiMapValue(configuration, "Race Engineer Shutdown", simulator . ".SaveSettings", "Always"))
			simulatorConfiguration["SaveTyrePressures"] := getMultiMapValue(configuration, "Race Engineer Shutdown", simulator . ".SaveTyrePressures", "Ask")

			simulatorConfiguration["LearningLaps"] := getMultiMapValue(configuration, "Race Engineer Analysis", simulator . ".LearningLaps", 1)
			simulatorConfiguration["ConsideredHistoryLaps"] := getMultiMapValue(configuration, "Race Engineer Analysis", simulator . ".ConsideredHistoryLaps", 5)
			simulatorConfiguration["HistoryLapsDamping"] := getMultiMapValue(configuration, "Race Engineer Analysis", simulator . ".HistoryLapsDamping", 0.2)
			simulatorConfiguration["AdjustLapTime"] := getMultiMapValue(configuration, "Race Engineer Analysis", simulator . ".AdjustLapTime", true)
			simulatorConfiguration["DamageAnalysisLaps"] := getMultiMapValue(configuration, "Race Engineer Analysis", simulator . ".DamageAnalysisLaps", 1)

			this.iSimulatorConfigurations[simulator] := simulatorConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local simulator, simulatorConfiguration, ignore, key

		super.saveToConfiguration(configuration)

		this.saveSimulatorConfiguration()

		for simulator, simulatorConfiguration in this.iSimulatorConfigurations {
			setMultiMapValue(configuration, "Race Assistant Startup", simulator . ".LoadSettings", simulatorConfiguration["LoadSettings"])
			setMultiMapValue(configuration, "Race Assistant Shutdown", simulator . ".SaveSettings", simulatorConfiguration["SaveSettings"])

			setMultiMapValue(configuration, "Race Engineer Startup", simulator . ".LoadTyrePressures", simulatorConfiguration["LoadTyrePressures"])
			setMultiMapValue(configuration, "Race Engineer Shutdown", simulator . ".SaveTyrePressures", simulatorConfiguration["SaveTyrePressures"])

			for ignore, key in ["LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "AdjustLapTime", "DamageAnalysisLaps"]
				setMultiMapValue(configuration, "Race Engineer Analysis", simulator . "." . key, simulatorConfiguration[key])
		}
	}

	loadConfigurator(configuration, simulators) {
		this.loadFromConfiguration(configuration)

		this.setSimulators(simulators)
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration, this.getSimulators())
	}

	loadSimulatorConfiguration(simulator := false) {
		local configuration, value

		if simulator
			this.Control["reSimulatorDropDown"].Choose(inList(this.iSimulators, simulator))

		this.iCurrentSimulator := this.Control["reSimulatorDropDown"].Text

		if this.iSimulatorConfigurations.Has(this.iCurrentSimulator) {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			value := configuration["LoadSettings"]

			if (value = "SetupDatabase")
				value := "SettingsDatabase"

			this.Control["reLoadSettingsDropDown"].Choose(inList(["Default", "SettingsDatabase"], configuration["LoadSettings"]))

			value := configuration["LoadTyrePressures"]

			if (value = "SetupDatabase")
				value := "TyresDatabase"

			this.Control["reLoadTyrePressuresDropDown"].Choose(inList(["Default", "TyresDatabase", "Import", "Setup"], configuration["LoadTyrePressures"]))

			this.Control["reSaveSettingsDropDown"].Choose(inList(["Ask", "Always", "Never"], configuration["SaveSettings"]))
			this.Control["reSaveTyrePressuresDropDown"].Choose(inList(["Ask", "Always", "Never"], configuration["SaveTyrePressures"]))

			this.Control["reLearningLapsEdit"].Text := configuration["LearningLaps"]
			this.Control["reLapsConsideredEdit"].Text := configuration["ConsideredHistoryLaps"]

			this.Control["reDampingFactorEdit"].Text := displayValue("Float", configuration["HistoryLapsDamping"], 1)
			this.Control["reDampingFactorEdit"].ValidText := this.Control["reDampingFactorEdit"].Text

			this.Control["reAdjustLapTimeCheck"].Value := configuration["AdjustLapTime"]

			this.Control["reDamageAnalysisLapsEdit"].Text := configuration["DamageAnalysisLaps"]
		}
	}

	saveSimulatorConfiguration() {
		local configuration

		if this.iCurrentSimulator {
			configuration := this.iSimulatorConfigurations[this.iCurrentSimulator]

			configuration["LoadSettings"] := ["Default", "SettingsDatabase"][this.Control["reLoadSettingsDropDown"].Value]
			configuration["LoadTyrePressures"] := ["Default", "TyresDatabase", "Import", "Setup"][this.Control["reLoadTyrePressuresDropDown"].Value]

			configuration["SaveSettings"] := ["Ask", "Always", "Never"][this.Control["reSaveSettingsDropDown"].Value]
			configuration["SaveTyrePressures"] := ["Ask", "Always", "Never"][this.Control["reSaveTyrePressuresDropDown"].Value]

			configuration["LearningLaps"] := this.Control["reLearningLapsEdit"].Text
			configuration["ConsideredHistoryLaps"] := this.Control["reLapsConsideredEdit"].Text
			configuration["HistoryLapsDamping"] := internalValue("Float", this.Control["reDampingFactorEdit"].Text)

			configuration["AdjustLapTime"] := this.Control["reAdjustLapTimeCheck"].Value

			configuration["DamageAnalysisLaps"] := this.Control["reDamageAnalysisLapsEdit"].Text
		}
	}

	setSimulators(simulators) {
		this.iSimulators := simulators

		this.Control["reSimulatorDropDown"].Delete()
		this.Control["reSimulatorDropDown"].Add(simulators)

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
				for ignore, key in ["LoadSettings", "SaveSettings", "LoadTyrePressures", "SaveTyrePressures"
								  , "LearningLaps", "ConsideredHistoryLaps", "HistoryLapsDamping", "AdjustLapTime", "DamageAnalysisLaps"]
					simulatorConfiguration[key] := configuration[key]
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Race Engineer"), RaceEngineerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRaceEngineerConfigurator()