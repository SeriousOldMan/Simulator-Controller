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
		if (getConfigurationValue(simulatorConfiguration, "Plugins", this.iAssistant, kUndefined) != kUndefined) {
			assistant := new Plugin(this.iAssistant, simulatorConfiguration)
			
			assistant.setArgumentValue("raceAssistantSpeaker", false)
			assistant.setArgumentValue("raceAssistantListener", false)
			
			assistant.saveToConfiguration(simulatorConfiguration)
		}
	}
}

class PassiveEngineer extends NamedPreset {
	patchSimulatorConfiguration(wizard, configuration, settings) {
		if (getConfigurationValue(configuration, "Plugins", "Race Engineer", kUndefined) != kUndefined) {
			assistant := new Plugin("Race Engineer", configuration)
			
			assistant.setArgumentValue("openPitstopMFD", "Off")
			
			assistant.saveToConfiguration(configuration)
		}
	}
}

class DefaultButtonBox extends Preset {
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
			FileCopy %file%, %kUserHomeDirectory%Setup\Button Box Configuration.ini, 1
		}
		catch exception {
			; ignore
		}
	}
}

class DefaultStreamDeck extends Preset {
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

class ModulesStepWizard extends StepWizard {
	iModuleSelectors := []
	
	Pages[] {
		Get {
			return Ceil(this.Definition.Length() / 3) + 1
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
		
		y := startY
		labelX := x + 35
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
			
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Module.png
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDlabelHandle Hidden, % translate("Presets && Special Configurations")
		
		Gui %window%:Font, s8 Norm, Arial
	
		Sleep 200
		
		this.registerWidgets(this.Pages, iconHandle, labelHandle)
	}
	
	reset() {
		base.reset()
		
		this.iModuleSelectors := []
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
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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