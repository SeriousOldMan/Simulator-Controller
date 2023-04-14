;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mudules Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\SpeechSynthesizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Preset(s)                                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NamedPreset extends Preset {
	iName := false

	Name {
		Get {
			return this.iName
		}
	}

	__New(name) {
		this.iName := name
	}

	getArguments() {
		return Array(this.Name)
	}

	edit() {
	}
}

class SilentAssistant extends NamedPreset {
	iAssistant := false
	iDisabled := true

	Assistant {
		Get {
			return this.iAssistant
		}
	}

	__New(name, assistant, full := true) {
		this.iAssistant := assistant
		this.iDisabled := ((full = kTrue) ? true : ((full = kFalse) ? false : full))

		super.__New(name)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.Assistant, this.iDisabled))
	}

	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local assistant

		if wizard.isModuleSelected(this.Assistant)
			if (getMultiMapValue(simulatorConfiguration, "Plugins", this.Assistant, kUndefined) != kUndefined) {
				assistant := Plugin(this.Assistant, simulatorConfiguration)

				if this.iDisabled {
					assistant.setArgumentValue("raceAssistantSpeaker", "Off")
					assistant.setArgumentValue("raceAssistantListener", "Off")
				}
				else
					assistant.setArgumentValue("raceAssistantMuted", "true")

				assistant.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class PassiveEngineer extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local definition, name, assistant, ignore, descriptor

		if wizard.isModuleSelected("Race Engineer") {
			definition := wizard.Definition

			for ignore, descriptor in getMultiMapValues(definition, "Applications.Simulators") {
				name := string2Values("|", descriptor)[1]

				if (getMultiMapValue(simulatorConfiguration, "Plugins", name, kUndefined) != kUndefined) {
					assistant := Plugin(name, simulatorConfiguration)

					assistant.setArgumentValue("openPitstopMFD", "Off")

					assistant.saveToConfiguration(simulatorConfiguration)
				}
			}
		}
	}
}

class DifferentVoices extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local synthesizer, language, speaker, voices, ignore, voice, found, candidate, voice1, voice2, assistant

		if wizard.isModuleSelected("Voice Control") {
			synthesizer := getMultiMapValue(simulatorConfiguration, "Voice Control", "Synthesizer")
			language := getMultiMapValue(simulatorConfiguration, "Voice Control", "Language")
			speaker := getMultiMapValue(simulatorConfiguration, "Voice Control", "Speaker")

			voices := []

			if (speaker && (speaker != true))
				voices.Push(speaker)

			for ignore, voice in SpeechSynthesizer(synthesizer, true, language).Voices[language] {
				found := false

				for ignore, candidate in voices {
					voice1 := string2Values("(", voice)[1]
					voice2 := string2Values("(", candidate)[1]

					if ((InStr(voice1, voice2) == 1) || (InStr(voice2, voice1) == 1)) {
						found := true

						break
					}
				}

				if !found
					voices.Push(voice)
			}

			if (voices.Length > 0) {
				voices := reverse(voices)

				for ignore, assistant in string2Values("|", getMultiMapValue(wizard.Definition, "Setup.Modules", "Modules.Definition.Assistants")) {
					if wizard.isModuleSelected(assistant)
						if (getMultiMapValue(simulatorConfiguration, "Plugins", assistant, kUndefined) != kUndefined) {
							assistant := Plugin(assistant, simulatorConfiguration)

							assistant.setArgumentValue("raceAssistantSpeaker", voices.Pop())

							assistant.saveToConfiguration(simulatorConfiguration)

							if (voices.Length == 0)
								break
						}
				}
			}
		}
	}
}

class DefaultButtonBox extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	install(wizard) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Button Box Configuration.ini") {
				config := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

				for section, values in readMultiMap(file)
					for key, value in values
						if (getMultiMapValue(config, section, key, kUndefined) == kUndefined)
							setMultiMapValue(config, section, key, value)

				writeMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini", config)
			}
			else
				FileCopy(file, kUserHomeDirectory . "Setup\Button Box Configuration.ini", 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}
}

class DefaultStreamDeck extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	install(wizard) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini") {
				config := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

				for section, values in readMultiMap(file)
					for key, value in values
						if (getMultiMapValue(config, section, key, kUndefined) == kUndefined)
							setMultiMapValue(config, section, key, value)

				writeMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", config)
			}
			else
				FileCopy(file, kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}
}

class FilesPreset extends NamedPreset {
	iFiles := []

	Directory {
		Get {
			throw "Virtual property FilesPreset.Directory must be implemented in a subclass..."
		}
	}

	Files {
		Get {
			return this.iFiles
		}
	}

	__New(name, files*) {
		local index, file

		super.__New(name)

		for index, file in files
			files[index] := substituteVariables(file)

		this.iFiles := files
	}

	getArguments() {
		return concatenate(super.getArguments(), this.Files)
	}

	install(wizard) {
		local directory := this.Directory
		local ignore, file

		for ignore, file in this.Files
			try {
				FileCopy(file, directory, 1)
			}
			catch Any as exception {
				logError(exception)
			}
	}

	uninstall(wizard) {
		local directory := this.Directory
		local ignore, file, name

		for ignore, file in this.Files {
			SplitPath(file, &name)

			deleteFile(directory . name)
		}
	}
}

class StreamDeckIcons extends FilesPreset {
	Directory {
		Get {
			return kUserTranslationsDirectory
		}
	}
}

class P2TConfiguration extends FilesPreset {
	Directory {
		Get {
			return kUserConfigDirectory
		}
	}
}

class PitstopImages extends NamedPreset {
	iDirectory := false

	Directory {
		Get {
			return this.iDirectory
		}
	}

	__New(name, directory) {
		super.__New(name)

		this.iDirectory := substituteVariables(directory)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.Directory))
	}

	install(wizard) {
		local directory := this.Directory
		local name

		SplitPath(directory, , , , &name)

		DirCreate(kUserHomeDirectory . "Screen Images\" . name)

		try {
			FileCopy(directory . "\*.*", kUserHomeDirectory . "Screen Images\" . name, 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	uninstall(wizard) {
		local directory := this.Directory
		local name

		SplitPath(directory, , , , &name)

		deleteDirectory(kUserHomeDirectory . "Screen Images\" . name)
	}
}

class TeamServerAlwaysOn extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local thePlugin

		if (wizard.isModuleSelected("Race Engineer") || wizard.isModuleSelected("Race Strategist"))
			if (getMultiMapValue(simulatorConfiguration, "Plugins", "Team Server", kUndefined) != kUndefined) {
				thePlugin := Plugin("Team Server", simulatorConfiguration)

				thePlugin.setArgumentValue("teamServer", "On")

				thePlugin.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class SetupPatch extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	edit() {
		local file := this.File
		local name

		SplitPath(file, &name)

		try {
			Run("notepad " . kUserHomeDirectory . "Setup\" . name)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	install(wizard) {
		local file := this.File
		local name

		SplitPath(file, &name)

		try {
			FileCopy(file, kUserHomeDirectory . "Setup\" . name, 1)
		}
		catch Any as exception {
			logError(exception)
		}

		this.edit()
	}

	uninstall(wizard) {
		local file := this.File
		local name

		SplitPath(file, &name)

		deleteFile(kUserHomeDirectory . "Setup\" . name)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ModulesStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ModulesStepWizard extends StepWizard {
	iModuleSelectors := []

	iAvailablePresetsListView := false
	iSelectedPresetsListView := false

	Pages {
		Get {
			return Ceil(this.Definition.Length / 3) + 1
		}
	}

	AvailablePresetsListView {
		Get {
			return this.iAvailablePresetsListView
		}
	}

	SelectedPresetsListView {
		Get {
			return this.iSelectedPresetsListView
		}
	}

	createGui(wizard, x, y, width, height) {
		local definition := this.Definition
		local window := this.Window
		local startY := y
		local checkX := x + width - 20
		local labelWidth := width - 30
		local listWidth := Round((width - 50) / 2)
		local x2 := x + listWidth + 50
		local buttonWidth := 40
		local x3 := x + listWidth + 5
		local module, selected, info, label, labelX, labelY, html

		compose(functions*) {
			callFunctions(functions, arguments*) {
				local ignore, function

				for ignore, function in functions
					function.Call(arguments*)
			}

			return callFunctions.Bind(functions)
		}

		choosePreset(list1, list2) {
			local next, selected

			selected := list1.GetNext()

			while selected {
				list1.Modify(selected, "-Select")

				selected := list1.GetNext()
			}

			if selected
				list2.Modify(selected, "+Select")

			this.updatePresetState()
		}

		chooseAvailablePreset(*) {
			choosePreset(this.SelectedPresetsListView, this.AvailablePresetsListView)
		}

		chooseSelectedPreset(*) {
			choosePreset(this.AvailablePresetsListView, this.SelectedPresetsListView)
		}

		editSelectedPreset(*) {
			choosePreset(this.AvailablePresetsListView, this.SelectedPresetsListView)

			this.editPreset()
		}

		installPreset(*) {
			this.installPreset()
		}

		uninstallPreset(*) {
			this.uninstallPreset()
		}

		updateSelectedModules(*) {
			this.updateSelectedModules()
		}

		loop definition.Length {
			window.SetFont("s10 Bold", "Arial")

			module := definition[A_Index]
			selected := this.SetupWizard.isModuleSelected(module)

			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Info." . getLanguage()))
			module := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . "." . getLanguage()))

			label := substituteVariables(translate("Module: %module%"), {module: module})
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

			labelX := x + 35
			labelY := y + 8

			widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Module.png")
			widget2:= window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", label)
			widget3:= window.Add("CheckBox", "Checked" . selected . " x" . checkX . " y" . labelY . " w23 h23 VmoduleCheck" . A_Index . " Hidden")
			widget3.OnEvent("Click", updateSelectedModules)
			widget4 := window.Add("ActiveX", "x" . x . " yp+26 w" . width . " h124 VinfoText" . A_Index . " Hidden", "shell.explorer")

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			widget4.Value.navigate("about:blank")
			widget4.Value.document.write(html)

			y += 170

			this.iModuleSelectors.Push(widget3)

			this.registerWidgets(Ceil(A_Index / 3), widget1, widget2, widget3, widget4)

			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}

		y := startY
		labelX := x + 35
		labelY := y + 8

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Module.png")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Presets && Special Configurations"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("ListView", "x" . x . " yp+30 w" . listWidth . " h224 AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden Section", collect(["Available Presets"], translate))
		widget3.OnEvent("Click", chooseAvailablePreset)
		widget3.OnEvent("DoubleClick", compose(chooseAvailablePreset, installPreset))

		this.iAvailablePresetsListView := widget3

		widget4 := window.Add("ListView", "x" . x2 . " ys w" . listWidth . " h224 AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden", collect(["Selected Presets"], translate))
		widget4.OnEvent("Click", chooseSelectedPreset)
		widget4.OnEvent("DoubleClick", compose(chooseSelectedPreset, editSelectedPreset))

		this.iSelectedPresetsListView := widget4

		window.SetFont("s10 Bold", "Arial")

		widget5 := window.Add("Button", "x" . x3 . " ys+95 w" . buttonWidth . " vinstallPresetButton  Hidden", ">")
		widget5.OnEvent("Click", installPreset)
		widget6 := window.Add("Button", "x" . x3 . " yp+30 w" . buttonWidth . " vuninstallPresetButton  Hidden", "<")
		widget6.OnEvent("Click", uninstallPreset)

		window.SetFont("s8 Norm", "Arial")

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		widget7 := window.Add("ActiveX", "x" . x . " ys+229 w" . width . " h210 VpresetsInfoText Hidden", "shell.explorer")

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget7.Value.navigate("about:blank")
		widget7.Value.document.write(html)

		this.registerWidgets(this.Pages, widget1, widget2, widget3, widget4, widget5, widget6, widget7)
	}

	reset() {
		super.reset()

		this.iModuleSelectors := []
	}

	showPage(page) {
		super.showPage(page)

		if (page = this.Pages) {
			this.loadAvailablePresets()
			this.loadSelectedPresets()

			this.updatePresetState()
		}
	}

	updateState() {
		local definition := this.Definition

		super.updateState()

		loop definition.Length
			this.iModuleSelectors[A_Index].Value := this.SetupWizard.isModuleSelected(definition[A_Index])
	}

	updateSelectedModules() {
		local definition := this.Definition
		local selector, name, checked

		loop definition.Length {
			selector := this.iModuleSelectors[A_Index]
			name := definition[A_Index]

			checked := selector.Value

			if (checked != this.SetupWizard.isModuleSelected(name)) {
				this.SetupWizard.selectModule(name, checked)

				return
			}
		}
	}

	loadAvailablePresets() {
		local definition := this.Definition
		local presets := []
		local preset, module, modulePresets, ignore

		this.AvailablePresetsListView.Delete()

		loop definition.Length {
			module := definition[A_Index]

			if this.SetupWizard.isModuleSelected(module) {
				modulePresets := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

				for ignore, preset in string2Values("|", modulePresets)
					this.AvailablePresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
			}
		}

		for ignore, preset in string2Values("|", substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			this.AvailablePresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))

		this.AvailablePresetsListView.ModifyCol()
		this.AvailablePresetsListView.ModifyCol(1, "AutoHdr")
	}

	loadSelectedPresets() {
		local presets := []
		local ignore, preset

		this.SelectedPresetsListView.Delete()

		for ignore, preset in this.SetupWizard.Presets
			this.SelectedPresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset.Name . "." . getLanguage()))

		this.SelectedPresetsListView.ModifyCol()
		this.SelectedPresetsListView.ModifyCol(1, "AutoHdr")
	}

	presetName(label) {
		local definition := this.Definition
		local preset, module, modulePresets, ignore, preset

		loop definition.Length {
			module := definition[A_Index]

			modulePresets := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

			for ignore, preset in string2Values("|", modulePresets)
				if (label = getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
					return preset
		}

		for ignore, preset in string2Values("|", substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			if (label = getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
				return preset

		return false
	}

	updatePresetState() {
		local info := false
		local preset, selected, enable, ignore, candidate, info, html

		this.Control["installPresetButton"].Enabled := false
		this.Control["uninstallPresetButton"].Enabled := false

		selected := this.AvailablePresetsListView.GetNext()

		if selected {
			preset := this.AvailablePresetsListView.GetText(selected, 1)

			preset := this.presetName(preset)

			enable := true

			for ignore, candidate in this.SetupWizard.Presets
				if (candidate.Name = preset) {
					enable := false

					break
				}

			if enable
				this.Control["installPresetButton"].Enabled := true

			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Info." . getLanguage()))
		}

		selected := this.SelectedPresetsListView.GetNext()

		if selected {
			this.Control["uninstallPresetButton"].Enabled := true

			if !info {
				preset := this.SelectedPresetsListView.GetText(selected, 1)

				preset := this.presetName(preset)

				info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Info." . getLanguage()))
			}
		}

		if !info
			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))

		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		this.Control["presetsInfoText"].Value.document.open()
		this.Control["presetsInfoText"].Value.document.write(html)
		this.Control["presetsInfoText"].Value.document.close()
	}

	installPreset() {
		local preset, selected, label, class, arguments

		selected := this.AvailablePresetsListView.GetNext()

		if selected {
			label := this.AvailablePresetsListView.GetText(selected, 1)

			preset := this.presetName(label)

			class := getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Class")
			arguments := string2Values(",", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Arguments"))

			this.SetupWizard.installPreset(%class%(preset, arguments*))

			this.loadSelectedPresets()

			this.updatePresetState()
		}
	}

	uninstallPreset() {
		local selected

		selected := this.SelectedPresetsListView.GetNext()

		if selected {
			this.SetupWizard.uninstallPreset(this.SetupWizard.Presets[selected])

			this.SelectedPresetsListView.Delete(selected)

			this.updatePresetState()
		}
	}

	editPreset() {
		local selected

		selected := this.SelectedPresetsListView.GetNext()

		if selected
			this.SetupWizard.Presets[selected].edit()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeModulesStepWizard() {
	SetupWizard.Instance.registerStepWizard(ModulesStepWizard(SetupWizard.Instance, "Modules", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeModulesStepWizard()