;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mudules Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
		if wizard.isModuleSelected(this.Assistant)
			if (getConfigurationValue(simulatorConfiguration, "Plugins", this.Assistant, kUndefined) != kUndefined) {
				assistant := new Plugin(this.Assistant, simulatorConfiguration)
				
				assistant.setArgumentValue("raceAssistantSpeaker", false)
				assistant.setArgumentValue("raceAssistantListener", false)
				
				assistant.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class PassiveEngineer extends NamedPreset {
	patchSimulatorConfiguration(wizard, configuration, settings) {
		local plugin
		
		if wizard.isModuleSelected("Race Engineer") {
			definition := wizard.Definition
	
			for ignore, descriptor in getConfigurationSectionValues(definition, "Applications.Simulators", Object()) {
				plugin := string2Values("|", descriptor)[1]
			
				if (getConfigurationValue(configuration, "Plugins", plugin, kUndefined) != kUndefined) {
					assistant := new Plugin(plugin, configuration)
					
					assistant.setArgumentValue("openPitstopMFD", "Off")
					
					assistant.saveToConfiguration(configuration)
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
		file := this.iFile
		
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
			; ignore
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
		file := this.iFile
		
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
			; ignore
		}
	}
	
	uninstall(wizard) {
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
		
		definition := this.Definition
		
		startY := y
		checkX := x + width - 20
		labelWidth := width - 30
		
		if (definition.Length() > 12)
			Throw "Too many modules detected in ModulesStepWizard.createGui..."
		
		Loop % definition.Length()
		{
			window := this.Window
		
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
		
		presetsIconHandle := false
		presetsLabelHandle := false
		availablePresetsLabelHandle := false
		availablePresetsListViewHandle := false
		selectedPresetsListViewHandle := false
		selectedPresetsLabelHandle := false
		moveLeftButtonHandle := false
		moveRightButtonHandle := false
		presetsInfoTextHandle := false
		
		y := startY
		labelX := x + 35
		labelY := y + 8
		
		listWidth := Round((width - 50) / 2)
		x2 := x + listWidth + 50
		
		buttonWidth := 40
		x3 := x + listWidth + 5
		
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
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"
			
		Sleep 200
		
		Gui %window%:Add, ActiveX, x%x% ys+229 w%width% h180 HWNDpresetsInfoTextHandle VpresetsInfoText Hidden, shell.explorer

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
		local variable
		
		base.updateState()
		
		window := this.Window
		
		Gui %window%:Default
		
		definition := this.Definition
		
		Loop % definition.Length()
		{
			variable := this.iModuleSelectors[A_Index]
			name := definition[A_Index]
			
			chosen := this.SetupWizard.isModuleSelected(name)
			
			GuiControl, , %variable%, %chosen%
		}
	}
	
	updateSelectedModules() {
		local variable
		
		window := this.Window
		
		Gui %window%:Default
		
		definition := this.Definition
		
		Loop % definition.Length()
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
		local preset
		
		window := this.Window
		
		Gui %window%:Default
		
		definition := this.Definition
		presets := []
		
		Gui, ListView, % this.AvailablePresetsListView
		
		LV_Delete()
		
		Loop % definition.Length()
		{
			module := definition[A_Index]
		
			if this.SetupWizard.isModuleSelected(module) {
				modulePresets := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))
				
				for ignore, preset in string2Values("|", modulePresets)
					LV_Add("", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . "." . getLanguage()))
			}
		}
		
		LV_ModifyCol()
		LV_ModifyCol(1, "AutoHdr")
	}
	
	loadSelectedPresets() {
		local preset
		
		window := this.Window
		
		Gui %window%:Default
		
		presets := []
		
		Gui, ListView, % this.SelectedPresetsListView
		
		LV_Delete()
		
		for ignore, preset in this.SetupWizard.loadPresets()
			LV_Add("", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset.Name . "." . getLanguage()))
		
		LV_ModifyCol()
		LV_ModifyCol(1, "AutoHdr")
	}
	
	presetName(label) {
		local preset
		
		definition := this.Definition
		
		Loop % definition.Length()
		{
			module := definition[A_Index]
		
			modulePresets := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))
				
			for ignore, preset in string2Values("|", modulePresets)
				if (label = getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . "." . getLanguage()))
					return preset
		}
		
		return false
	}
	
	updatePresetState() {
		local preset
		
		window := this.Window
		info := false
		
		Gui %window%:Default
		
		GuiControl Disable, installPresetButton
		GuiControl Disable, uninstallPresetButton
		
		Gui, ListView, % this.AvailablePresetsListView
		
		selected := LV_GetNext()
		
		if selected {
			LV_GetText(preset, selected)
		
			preset := this.presetName(preset)
			
			enable := true
			
			for ignore, candidate in this.SetupWizard.loadPresets()
				if (candidate.Name = preset) {
					enable := false
					
					break
				}
			
			if enable			
				GuiControl Enable, installPresetButton
			
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . ".Info." . getLanguage()))
		}
		
		Gui, ListView, % this.SelectedPresetsListView

		selected := LV_GetNext()
	
		if selected {
			GuiControl Enable, uninstallPresetButton

			if !info {
				LV_GetText(preset, selected)
			
				preset := this.presetName(preset)
				
				info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . ".Info." . getLanguage()))
			}
		}
		
		if !info
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets.Info." . getLanguage()))
		
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"
			
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		presetsInfoText.Document.Open()
		presetsInfoText.Document.Write(html)
		presetsInfoText.Document.Close()
	}
	
	installPreset() {
		local preset
		
		window := this.Window
		
		Gui %window%:Default
		
		Gui, ListView, % this.AvailablePresetsListView
		
		selected := LV_GetNext()
		
		if selected {
			LV_GetText(label, selected)
		
			preset := this.presetName(label)
			
			class := getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . ".Class")
			arguments := string2Values(",", getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Presets." . preset . ".Arguments"))
					
			this.SetupWizard.installPreset(new %class%(preset, arguments*))
			
			this.loadSelectedPresets()
			
			this.updatePresetState()
		}
	}
	
	uninstallPreset() {
		window := this.Window
		
		Gui %window%:Default
		
		Gui, ListView, % this.SelectedPresetsListView
		
		selected := LV_GetNext()
		
		if selected {
			this.SetupWizard.uninstallPreset(this.SetupWizard.loadPresets()[selected])
			
			LV_Delete(selected)
			
			this.updatePresetState()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

choosePreset(list1, list2) {
	step := SetupWizard.Instance.StepWizards["Modules"]
		
	window := step.Window
	
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
	if (A_GuiEvent = "Normal") {
		step := SetupWizard.Instance.StepWizards["Modules"]
		
		choosePreset(step.SelectedPresetsListView, step.AvailablePresetsListView)
	}
}

chooseSelectedPreset() {
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