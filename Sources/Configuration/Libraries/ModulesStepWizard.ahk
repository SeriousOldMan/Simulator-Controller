;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mudules Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\SpeechSynthesizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Preset(s)                                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NamedPreset extends Preset {
	iName := false

	Name[] {
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
}

class MutedAssistant extends NamedPreset {
	iAssistant := false

	Assistant[] {
		Get {
			return this.iAssistant
		}
	}

	__New(name, assistant) {
		base.__New(name)

		this.iAssistant := assistant
	}

	getArguments() {
		return concatenate(base.getArguments(), Array(this.Assistant))
	}

	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local assistant

		if wizard.isModuleSelected(this.Assistant)
			if (getConfigurationValue(simulatorConfiguration, "Plugins", this.Assistant, kUndefined) != kUndefined) {
				assistant := new Plugin(this.Assistant, simulatorConfiguration)

				assistant.setArgumentValue("raceAssistantSpeaker", "Off")
				assistant.setArgumentValue("raceAssistantListener", "Off")

				assistant.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class PassiveEngineer extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local definition, name, assistant, ignore, descriptor

		if wizard.isModuleSelected("Race Engineer") {
			definition := wizard.Definition

			for ignore, descriptor in getConfigurationSectionValues(definition, "Applications.Simulators", Object()) {
				name := string2Values("|", descriptor)[1]

				if (getConfigurationValue(simulatorConfiguration, "Plugins", name, kUndefined) != kUndefined) {
					assistant := new Plugin(name, simulatorConfiguration)

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
			synthesizer := getConfigurationValue(simulatorConfiguration, "Voice Control", "Synthesizer")
			language := getConfigurationValue(simulatorConfiguration, "Voice Control", "Language")
			speaker := getConfigurationValue(simulatorConfiguration, "Voice Control", "Speaker")

			voices := []

			if (speaker && (speaker != true))
				voices.Push(speaker)

			for ignore, voice in new SpeechSynthesizer(synthesizer, true, language).Voices[language] {
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

			if (voices.Length() > 0) {
				voices := reverse(voices)

				for ignore, assistant in string2Values("|", getConfigurationValue(wizard.Definition, "Setup.Modules", "Modules.Definition.Assistants")) {
					if wizard.isModuleSelected(assistant)
						if (getConfigurationValue(simulatorConfiguration, "Plugins", assistant, kUndefined) != kUndefined) {
							assistant := new Plugin(assistant, simulatorConfiguration)

							assistant.setArgumentValue("raceAssistantSpeaker", voices.Pop())

							assistant.saveToConfiguration(simulatorConfiguration)

							if (voices.Length() == 0)
								break
						}
				}
			}
		}
	}
}

class DefaultButtonBox extends NamedPreset {
	iFile := false

	File[] {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		base.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(base.getArguments(), Array(this.File))
	}

	install(wizard) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Button Box Configuration.ini") {
				config := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

				for section, values in readConfiguration(file)
					for key, value in values
						if (getConfigurationValue(config, section, key, kUndefined) == kUndefined)
							setConfigurationValue(config, section, key, value)

				writeConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini", config)
			}
			else
				FileCopy %file%, %kUserHomeDirectory%Setup\Button Box Configuration.ini, 1
		}
		catch exception {
			logError(exception)
		}
	}
}

class DefaultStreamDeck extends NamedPreset {
	iFile := false

	File[] {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		base.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(base.getArguments(), Array(this.File))
	}

	install(wizard) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini") {
				config := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

				for section, values in readConfiguration(file)
					for key, value in values
						if (getConfigurationValue(config, section, key, kUndefined) == kUndefined)
							setConfigurationValue(config, section, key, value)

				writeConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", config)
			}
			else
				FileCopy %file%, %kUserHomeDirectory%Setup\Stream Deck Configuration.ini, 1
		}
		catch exception {
			logError(exception)
		}
	}
}

class StreamDeckIcons extends NamedPreset {
	iFiles := []

	Files[] {
		Get {
			return this.iFiles
		}
	}

	__New(name, files*) {
		local index, file

		base.__New(name)

		for index, file in files
			files[index] := substituteVariables(file)

		this.iFiles := files
	}

	getArguments() {
		return concatenate(base.getArguments(), this.Files)
	}

	install(wizard) {
		local ignore, file

		for ignore, file in this.Files
			try {
				FileCopy %file%, %kUserTranslationsDirectory%, 1
			}
			catch exception {
				logError(exception)
			}
	}

	uninstall(wizard) {
		local ignore, file, name

		for ignore, file in this.Files {
			SplitPath file, name

			deleteFile(kUserTranslationsDirectory . name)
		}
	}
}

class PitstopImages extends NamedPreset {
	iDirectory := false

	Directory[] {
		Get {
			return this.iDirectory
		}
	}

	__New(name, directory) {
		base.__New(name)

		this.iDirectory := substituteVariables(directory)
	}

	getArguments() {
		return concatenate(base.getArguments(), Array(this.Directory))
	}

	install(wizard) {
		local directory := this.Directory
		local name

		SplitPath directory, , , , name

		FileCreateDir %kUserHomeDirectory%Screen Images\%name%

		try {
			FileCopy %directory%\*.*, %kUserHomeDirectory%Screen Images\%name%, 1
		}
		catch exception {
			logError(exception)
		}
	}

	uninstall(wizard) {
		local directory := this.Directory
		local name

		SplitPath directory, , , , name
		
		deleteDirectory(kUserHomeDirectory . "Screen Images\" . name)
	}
}

class TeamServerAlwaysOn extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local thePlugin

		if (wizard.isModuleSelected("Race Engineer") || wizard.isModuleSelected("Race Strategist"))
			if (getConfigurationValue(simulatorConfiguration, "Plugins", "Team Server", kUndefined) != kUndefined) {
				thePlugin := new Plugin("Team Server", simulatorConfiguration)

				thePlugin.setArgumentValue("teamServer", "On")

				thePlugin.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class SetupPatch extends NamedPreset {
	iFile := false

	File[] {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		base.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(base.getArguments(), Array(this.File))
	}

	install(wizard) {
		local file := this.File
		local name

		SplitPath file, name

		try {
			FileCopy %file%, %kUserHomeDirectory%Setup\%name%, 1

			Run notepad %kUserHomeDirectory%Setup\%name%
		}
		catch exception {
			logError(exception)
		}
	}

	uninstall(wizard) {
		local file := this.File
		local name

		SplitPath file, name

		deleteFile(kUserHomeDirectory . "Setup\" . name)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ModulesStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global installPresetButton
global uninstallPresetButton

global presetsInfoText

class ModulesStepWizard extends StepWizard {
	iModuleSelectors := []

	iAvailablePresetsListView := false
	iSelectedPresetsListView := false

	Pages[] {
		Get {
			return Ceil(this.Definition.Length() / 3) + 1
		}
	}

	AvailablePresetsListView[] {
		Get {
			return this.iAvailablePresetsListView
		}
	}

	SelectedPresetsListView[] {
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
		local presetsIconHandle := false
		local presetsLabelHandle := false
		local availablePresetsLabelHandle := false
		local availablePresetsListViewHandle := false
		local selectedPresetsListViewHandle := false
		local selectedPresetsLabelHandle := false
		local moveLeftButtonHandle := false
		local moveRightButtonHandle := false
		local presetsInfoTextHandle := false
		local listWidth := Round((width - 50) / 2)
		local x2 := x + listWidth + 50
		local buttonWidth := 40
		local x3 := x + listWidth + 5
		local iconHandle, labelHandle, checkBoxHandle, infoTextHandle
		local module, selected, info, label, labelX, labelY, html

		static infoText1
		static infoText2
		static infoText3
		static infoText4
		static infoText5
		static infoText6
		static infoText7
		static infoText8
		static infoText9
		static infoText10
		static infoText11
		static infoText12

		static moduleCheck1
		static moduleCheck2
		static moduleCheck3
		static moduleCheck4
		static moduleCheck5
		static moduleCheck6
		static moduleCheck7
		static moduleCheck8
		static moduleCheck9
		static moduleCheck10
		static moduleCheck11
		static moduleCheck12

		if (definition.Length() > 12)
			throw "Too many modules detected in ModulesStepWizard.createGui..."

		loop % definition.Length()
		{
			iconHandle := false
			labelHandle := false
			checkBoxHandle := false
			infoTextHandle := false

			Gui %window%:Font, s10 Bold, Arial

			module := definition[A_Index]
			selected := this.SetupWizard.isModuleSelected(module)

			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Info." . getLanguage()))
			module := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . "." . getLanguage()))

			label := substituteVariables(translate("Module: %module%"), {module: module})
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

			labelX := x + 35
			labelY := y + 8

			Sleep 200

			Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Module.png
			Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDlabelHandle Hidden, % label
			Gui %window%:Add, CheckBox, Checked%selected% x%checkX% y%labelY% w23 h23 HWNDcheckBoxHandle VmoduleCheck%A_Index% Hidden gupdateSelectedModules
			Gui %window%:Add, ActiveX, x%x% yp+26 w%width% h124 HWNDinfoTextHandle VinfoText%A_Index% Hidden, shell.explorer

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			infoText%A_Index%.Navigate("about:blank")
			infoText%A_Index%.Document.Write(html)

			y += 170

			this.iModuleSelectors.Push(checkBoxHandle)

			this.registerWidgets(Ceil(A_Index / 3), iconHandle, labelHandle, checkBoxHandle, infoTextHandle)

			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}

		y := startY
		labelX := x + 35
		labelY := y + 8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDpresetsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Module.png
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDpresetsLabelHandle Hidden, % translate("Presets && Special Configurations")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, ListView, x%x% yp+30 w%listWidth% h224 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDavailablePresetsListViewHandle gchooseAvailablePreset Hidden Section, % values2String("|", map(["Available Presets"], "translate")*)

		Gui %window%:Add, ListView, x%x2% ys w%listWidth% h224 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDselectedPresetsListViewHandle gchooseSelectedPreset Hidden, % values2String("|", map(["Selected Presets"], "translate")*)

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Button, x%x3% ys+95 w%buttonWidth% HWNDmoveRightButtonHandle vinstallPresetButton ginstallPreset Hidden, >
		Gui %window%:Add, Button, x%x3% yp+30 w%buttonWidth% HWNDmoveLeftButtonHandle vuninstallPresetButton guninstallPreset Hidden, <

		Gui %window%:Font, s8 Norm, Arial

		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200

		Gui %window%:Add, ActiveX, x%x% ys+229 w%width% h210 HWNDpresetsInfoTextHandle VpresetsInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		presetsInfoText.Navigate("about:blank")
		presetsInfoText.Document.Write(html)

		this.iAvailablePresetsListView := availablePresetsListViewHandle
		this.iSelectedPresetsListView := selectedPresetsListViewHandle

		this.registerWidgets(this.Pages, presetsIconHandle, presetsLabelHandle, availablePresetsLabelHandle, availablePresetsListViewHandle
									   , selectedPresetsLabelHandle, selectedPresetsListViewHandle, moveLeftButtonHandle, moveRightButtonHandle, presetsInfoTextHandle)
	}

	reset() {
		base.reset()

		this.iModuleSelectors := []
	}

	showPage(page) {
		base.showPage(page)

		if (page = this.Pages) {
			this.loadAvailablePresets()
			this.loadSelectedPresets()

			this.updatePresetState()
		}
	}

	updateState() {
		local window := this.Window
		local variable, definition, name, chosen

		base.updateState()

		Gui %window%:Default

		definition := this.Definition

		loop % definition.Length()
		{
			variable := this.iModuleSelectors[A_Index]
			name := definition[A_Index]

			chosen := this.SetupWizard.isModuleSelected(name)

			GuiControl, , %variable%, %chosen%
		}
	}

	updateSelectedModules() {
		local window := this.Window
		local variable, definition, name, checked

		Gui %window%:Default

		definition := this.Definition

		loop % definition.Length()
		{
			variable := this.iModuleSelectors[A_Index]
			name := definition[A_Index]

			GuiControlGet checked, , %variable%

			if (checked != this.SetupWizard.isModuleSelected(name)) {
				this.SetupWizard.selectModule(name, checked)

				return
			}
		}
	}

	loadAvailablePresets() {
		local window := this.Window
		local preset, definition, presets, module, modulePresets, ignore

		Gui %window%:Default

		definition := this.Definition
		presets := []

		Gui, ListView, % this.AvailablePresetsListView

		LV_Delete()

		loop % definition.Length()
		{
			module := definition[A_Index]

			if this.SetupWizard.isModuleSelected(module) {
				modulePresets := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

				for ignore, preset in string2Values("|", modulePresets)
					LV_Add("", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
			}
		}

		for ignore, preset in string2Values("|", substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			LV_Add("", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))

		LV_ModifyCol()
		LV_ModifyCol(1, "AutoHdr")
	}

	loadSelectedPresets() {
		local window := this.Window
		local presets := []
		local ignore, preset

		Gui %window%:Default

		Gui, ListView, % this.SelectedPresetsListView

		LV_Delete()

		for ignore, preset in this.SetupWizard.Presets
			LV_Add("", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset.Name . "." . getLanguage()))

		LV_ModifyCol()
		LV_ModifyCol(1, "AutoHdr")
	}

	presetName(label) {
		local definition := this.Definition
		local preset, module, modulePresets, ignore, preset

		loop % definition.Length()
		{
			module := definition[A_Index]

			modulePresets := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

			for ignore, preset in string2Values("|", modulePresets)
				if (label = getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
					return preset
		}

		for ignore, preset in string2Values("|", substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			if (label = getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
				return preset

		return false
	}

	updatePresetState() {
		local window := this.Window
		local info := false
		local preset, selected, enable, ignore, candidate, info, html

		Gui %window%:Default

		GuiControl Disable, installPresetButton
		GuiControl Disable, uninstallPresetButton

		Gui, ListView, % this.AvailablePresetsListView

		selected := LV_GetNext()

		if selected {
			LV_GetText(preset, selected)

			preset := this.presetName(preset)

			enable := true

			for ignore, candidate in this.SetupWizard.Presets
				if (candidate.Name = preset) {
					enable := false

					break
				}

			if enable
				GuiControl Enable, installPresetButton

			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Info." . getLanguage()))
		}

		Gui, ListView, % this.SelectedPresetsListView

		selected := LV_GetNext()

		if selected {
			GuiControl Enable, uninstallPresetButton

			if !info {
				LV_GetText(preset, selected)

				preset := this.presetName(preset)

				info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Info." . getLanguage()))
			}
		}

		if !info
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))

		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		presetsInfoText.Document.Open()
		presetsInfoText.Document.Write(html)
		presetsInfoText.Document.Close()
	}

	installPreset() {
		local window := this.Window
		local preset, selected, label, class, arguments

		Gui %window%:Default

		Gui, ListView, % this.AvailablePresetsListView

		selected := LV_GetNext()

		if selected {
			LV_GetText(label, selected)

			preset := this.presetName(label)

			class := getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Class")
			arguments := string2Values(",", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Arguments"))

			this.SetupWizard.installPreset(new %class%(preset, arguments*))

			this.loadSelectedPresets()

			this.updatePresetState()
		}
	}

	uninstallPreset() {
		local window := this.Window
		local selected

		Gui %window%:Default

		Gui, ListView, % this.SelectedPresetsListView

		selected := LV_GetNext()

		if selected {
			this.SetupWizard.uninstallPreset(this.SetupWizard.Presets[selected])

			LV_Delete(selected)

			this.updatePresetState()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

choosePreset(list1, list2) {
	local step := SetupWizard.Instance.StepWizards["Modules"]
	local window := step.Window
	local next, selected

	Gui %window%:Default

	selected := LV_GetNext()

	Gui ListView, %list1%

	selected := LV_GetNext()

	while selected {
		LV_Modify(selected, "-Select")

		selected := LV_GetNext()
	}

	Gui, ListView, %list2%

	if selected
		LV_Modify(selected, "+Select")

	SetupWizard.Instance.StepWizards["Modules"].updatePresetState()
}

chooseAvailablePreset() {
	local step

	if (A_GuiEvent = "Normal") {
		step := SetupWizard.Instance.StepWizards["Modules"]

		choosePreset(step.SelectedPresetsListView, step.AvailablePresetsListView)
	}
}

chooseSelectedPreset() {
	local step

	if (A_GuiEvent = "Normal") {
		step := SetupWizard.Instance.StepWizards["Modules"]

		choosePreset(step.AvailablePresetsListView, step.SelectedPresetsListView)
	}
}

installPreset() {
	SetupWizard.Instance.StepWizards["Modules"].installPreset()
}

uninstallPreset() {
	SetupWizard.Instance.StepWizards["Modules"].uninstallPreset()
}

updateSelectedModules() {
	SetupWizard.Instance.StepWizards["Modules"].updateSelectedModules()
}

initializeModulesStepWizard() {
	SetupWizard.Instance.registerStepWizard(new ModulesStepWizard(SetupWizard.Instance, "Modules", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeModulesStepWizard()