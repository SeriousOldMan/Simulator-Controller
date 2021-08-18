;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Setup Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Wand.ico
;@Ahk2Exe-ExeName Simulator Setup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\JSON.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include ..\Controller\Libraries\SettingsEditor.ahk
#Include Libraries\ConfigurationEditor.ahk
#Include Libraries\ButtonBoxEditor.ahk
#Include ..\Plugins\Voice Control Configuration Plugin.ahk
#Include ..\Plugins\Race Engineer Configuration Plugin.ahk
#Include ..\Plugins\Race Strategist Configuration Plugin.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk = "ok"
global kCancel = "cancel"
global kNext = "next"
global kPrevious = "previous"
global kLanguage = "language"

global vInstallerLanguage = false


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vProgressCount = 0

global vResult = false
global vWorking = false

global vPageSwitch = false


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff = 0
global kDebugKnowledgeBase = 1
global kDebugRules = 2


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupWizard                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global infoViewer
global stepTitle
global stepSubtitle

global languageDropDown

global previousPageButton
global nextPageButton
global finishButton

class SetupWizard extends ConfigurationItem {
	iDebug := kDebugOff
	
	iWizardWindow := "SW"
	iHelpWindow := "SH"
	
	iStepWizards := {}
	
	iDefinition := false
	iKnowledgeBase := false
	
	iCount := 0
	
	iSteps := {}
	iStep := 0
	iPage := 0
	
	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}
	
	WizardWindow[] {
		Get {
			return this.iWizardWindow
		}
	}
	
	HelpWindow[] {
		Get {
			return this.iHelpWindow
		}
	}
	
	Definition[] {
		Get {
			return this.iDefinition
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	Count[] {
		Get {
			return this.iCount
		}
	}
	
	Steps[step := false] {
		Get {
			if step
				return (this.iSteps.HasKey(step) ? this.iSteps[step] : false)
			else
				return this.iSteps
		}
	}
	
	StepWizards[descriptor := false] {
		Get {
			if descriptor
				return (this.iStepWizards.HasKey(descriptor) ? this.iStepWizards[descriptor] : false)
			else
				return this.iStepWizards
		}
		
		Set {
			return this.iStepWizards[descriptor] := value
		}
	}
	
	Step[] {
		Get {
			return this.iStep
		}
	}
	
	Page[] {
		Get {
			return this.iPage
		}
	}
	
	__New(configuration, definition) {
		this.iDebug := (isDebug() ? (kDebugKnowledgeBase + kDebugRules) : kDebugOff)
		this.iDefinition := definition
		
		base.__New(configuration)
		
		SetupWizard.Instance := this
	}
	
	createKnowledgeBase(facts) {
		local rules
		
		FileRead rules, % kResourcesDirectory . "Setup\Simulator Setup.rules"
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(rules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, facts)
		
		return new KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}
	
	addRule(rule) {
		this.KnowledgeBase.addRule(new RuleCompiler().compileRule(rule))
	}
	
	loadDefinition(definition := false) {
		local knowledgeBase
		local stepWizard
		local count
		
		if !definition
			definition := this.Definition
		
		this.iKnowledgeBase := this.createKnowledgeBase({})
		
		this.iSteps := {}
		this.iStep := 0
		this.iPage := 0
		
		count := 0
		
		for descriptor, step in getConfigurationSectionValues(definition, "Setup.Steps") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
		
			stepWizard := this.StepWizards[step]
			
			if stepWizard {
				this.Steps[step] := stepWizard
				this.Steps[descriptor[2]] := stepWizard
				this.Steps[stepWizard] := descriptor[2]
			
				count := Max(count, descriptor[2])
			}
		}
		
		Loop %count% {
			step := this.Steps[A_Index]
		
			vProgressCount += 2
			
			showProgress({progress: vProgressCount})
		
			if step {
				stepDefinition := readConfiguration(kResourcesDirectory . "Setup\Definitions\" . step.Step . " Step.ini")
				
				setConfigurationSectionValues(definition, "Setup." . step.Step, getConfigurationSectionValues(stepDefinition, "Setup." . step.Step, Object()))
				
				step.loadDefinition(definition, getConfigurationValue(definition, "Setup." . step.Step, step.Step . ".Definition", Object()))
			}
		}
		
		this.iCount := count
		
		if (GetKeyState("Ctrl") && GetKeyState("Shift")) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup")
			MsgBox 262436, %title%, % translate("Do you really want to start with a fresh configuration?")
			OnMessage(0x44, "")
			
			IfMsgBox Yes
				initialize := true
			else
				initialize := false
		}
		else
			initialize  := false

		showProgress({progress: ++vProgressCount, message: translate("Initializing AI kernel...")})
		
		if initialize {
			try {
				FileDelete %kUserHomeDirectory%Setup\Button Box Configuration.ini
			}
			catch exception {
				; ignore
			}
			
			try {
				FileDelete %kUserHomeDirectory%Setup\Voice Control Configuration.ini
			}
			catch exception {
				; ignore
			}
			
			this.KnowledgeBase.addFact("Initialize", true)
		}
		else if !this.loadKnowledgeBase()
			this.KnowledgeBase.addFact("Initialize", true)
		
		if isDebug()
			Sleep 1000

		showProgress({progress: ++vProgressCount, message: translate("Starting AI kernel...")})
			
		this.KnowledgeBase.produce()
					
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
	}
	
	registerStepWizard(stepWizard) {
		this.StepWizards[stepWizard.Step] := stepWizard
	}
	
	unregisterStepWizard(descriptorOrWizard) {
		local stepWizard
		
		for descriptor, stepWizard in this.StepWizards
			if ((descriptor = descriptorOrWizard) || (stepWizard = descriptorOrWizard)) {
				this.StepWizards.Delete(descriptor)
			
				break
			}
	}
	
	getWorkArea(ByRef x, ByRef y, ByRef width, ByRef height) {
		x := 16
		y := 60
		width := 684
		height := 470
	}
	
	createGui(configuration) {
		local stepWizard
		
		window := this.WizardWindow
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, F2F2F2

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w684 Center gmoveSetupWizard, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w684 cBlue Center gopenSetupDocumentation, % translate("Setup && Configuration")
		
		Gui %window%:Add, Text, yp+20 w700 0x10

		Gui %window%:Font, s8 Norm, Arial
		
		Gui %window%:Add, Button, x16 y540 w30 h30 HwndpreviousButtonHandle Disabled VpreviousPageButton GpreviousPage
		setButtonIcon(previousButtonHandle, kIconsDirectory . "Previous.ico", 1, "L2 T2 R2 B2 H24 W24")
		Gui %window%:Add, Button, x670 y540 w30 h30 HwndnextButtonHandle Disabled VnextPageButton GnextPage
		setButtonIcon(nextButtonHandle, kIconsDirectory . "Next.ico", 1, "L2 T2 R2 B2 H24 W24")
		
		languages := string2Values("|", getConfigurationValue(this.Definition, "Setup", "Languages"))
		
		choices := []
		chosen := false
		
		for code, language in availableLanguages()
			if inList(languages, code) {
				choices.Push(language)
				
				if (code = getLanguage())
					chosen := choices.Length()
			}
		
		Gui %window%:Add, Text, x8 yp+34 w700 0x10
		
		Gui %window%:Add, Text, x16 y580 w85 h23 +0x200, % translate("Language")
		Gui %window%:Add, DropDownList, x100 y580 w75 Choose%chosen% gchooseLanguage VlanguageDropDown, % values2String("|", map(choices, "translate")*)
		
		Gui %window%:Add, Button, x535 y580 w80 h23 Disabled GfinishSetup VfinishButton, % translate("Finish")
		Gui %window%:Add, Button, x620 y580 w80 h23 GcancelSetup, % translate("Cancel")
		
		window := this.HelpWindow
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, E5E5E5

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w350 Center gmoveSetupHelp VstepTitle, % translate("Title")
		
		Gui %window%:Font, s9 Norm, Arial

		Gui %window%:Add, Text, YP+20 w350 Center VstepSubtitle, % translate("Subtitle")
		
		Gui %window%:Add, Text, yp+20 w350 0x10
		
		Sleep 200
		
		Gui %window%:Add, ActiveX, x12 yp+10 w350 h545 vinfoViewer, shell.explorer
	
		infoViewer.Navigate("about:blank")
		
		html := "<html><head><meta http-equiv=""X-UA-Compatible"" content=""IE=Edge""></head><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

		infoViewer.Document.Write(html)
		
		this.createStepsGui()
	}
	
	createStepsGui() {
		local stepWizard
		
		x := 0
		y := 0
		width := 0
		height := 0
		
		this.getWorkArea(x, y, width, height)
		
		for step, stepWizard in this.StepWizards {
			vProgressCount += 2
			
			showProgress({progress: vProgressCount, message: translate("Creating UI for Step: ") . translate(step) . translate("...")})
		
			stepWizard.createGui(this, x, y, width, height)
		}
	}
	
	saveToConfiguration(configuration) {
		local stepWizard
		
		base.saveToConfiguration(configuration)
		
		for ignore, stepWizard in this.StepWizards
			stepWizard.saveToConfiguration(configuration)
	}

	reset() {
		this.show(true)
		
		Loop % this.Count
			if this.Steps.HasKey(A_Index)
				this.Steps[A_Index].reset()
	}
	
	setDebug(option, enabled) {
		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}
	
	show(reset := false) {
		static first := true
		
		if reset
			first := true
		else {
			wizardWindow := this.WizardWindow
			helpWindow := this.HelpWindow
			
			if first {
				posX := Round((A_ScreenWidth - 720 - 400) / 2)
							
				first := false
				
				Gui %wizardWindow%:Show, x%posX% yCenter h610
				
				posX := posX + 750
				
				Gui %helpWindow%:Show, x800 x%posX% yCenter h610
			}
			else {
				Gui %wizardWindow%:Show
				Gui %helpWindow%:Show
			}
		}
	}
	
	hide() {
		wizardWindow := this.WizardWindow
		helpWindow := this.HelpWindow
		
		Gui %wizardWindow%:Hide
		Gui %helpWindow%:Hide
	}
	
	close() {
		wizardWindow := this.WizardWindow
		helpWindow := this.HelpWindow
		
		Gui %wizardWindow%:Destroy
		Gui %helpWindow%:Destroy
	}
	
	startSetup() {
		showProgress({progress: ++vProgressCount, message: translate("Initializing Settings && Options...")})
		
		this.updateState()
		
		this.iStep := false
		this.iPage := false
		
		showProgress({progress: ++vProgressCount, color: "Green", title: translate("Starting Setup Wizard"), message: translate("Starting Configuration Engine...")})
		
		this.nextPage()
	}
	
	finishSetup(save := true) {
		if (this.Step && this.Step.hidePage(this.Page)) {
			window := this.WizardWindow
	
			Gui %window%:Default
			
			GuiControl Disable, previousPageButton
			GuiControl Disable, nextPageButton
			GuiControl Disable, finishButton
			
			vWorking := true
			
			if save {
				if FileExist(kUserConfigDirectory . "Simulator Configuration.ini")
					FileMove %kUserConfigDirectory%Simulator Configuration.ini, %kUserConfigDirectory%Simulator Configuration.ini.bak, 1
				
				if (FileExist(kUserConfigDirectory . "Simulator Settings.ini") && FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini"))
					FileMove %kUserConfigDirectory%Simulator Settings.ini, %kUserConfigDirectory%Simulator Settings.ini.bak, 1
				
				if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
					settings := readConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini")
				else
					settings := newConfiguration()
				
				if FileExist(kUserHomeDirectory . "Setup\Settings Patch.ini")
					for section, values in readConfiguration(kUserHomeDirectory . "Setup\Settings Patch.ini")
						for key, value in values
							setConfigurationValue(settings, section, key, value)
				
				if (settings.Count() > 0)
					writeConfiguration(kUserConfigDirectory . "Simulator Settings.ini", settings)
				
				configuration := this.getSimulatorConfiguration()
				
				if FileExist(kUserHomeDirectory . "Setup\Configuration Patch.ini")
					for section, values in readConfiguration(kUserHomeDirectory . "Setup\Configuration Patch.ini")
						for key, value in values
							setConfigurationValue(configuration, section, key, value)
					
				writeConfiguration(kUserConfigDirectory . "Simulator Configuration.ini", configuration)
				
				if this.isModuleSelected("Button Box") {
					if FileExist(kUserConfigDirectory . "Button Box Configuration.ini")
						FileMove %kUserConfigDirectory%Button Box Configuration.ini, %kUserConfigDirectory%Button Box Configuration.ini.bak, 1
					
					FileCopy %kUserHomeDirectory%Setup\Button Box Configuration.ini, %kUserConfigDirectory%Button Box Configuration.ini
				}
	
				for ignore, name in ["Simulator Startup", "Simulator Settings", "Race Settings", "Setup Database"]
					if ((A_Index < 3) || this.isModuleSelected("Race Engineer") || this.isModuleSelected("Race Strategist"))
						FileCreateShortCut %kBinariesDirectory%%name%.exe, %A_StartMenu%\%name%.lnk, %kBinariesDirectory%
			}
			
			vWorking := false
			
			return true
		}
		else
			return false
	}
	
	getSimulatorConfiguration() {
		configuration := newConfiguration()
		
		this.saveToConfiguration(configuration)
		
		return configuration
	}
	
	getPreviousPage(ByRef step, ByRef page) {
		if !this.Step
			return false
		else if this.Page > 1 {
			step := this.Step
			page := this.Page - 1
			
			return true
		}
		else {
			index := this.Steps[this.Step]
		
			if (index == 1)
				return false
			else
				Loop {
					if (index == 0)
						return false
					else {
						candidate := this.Steps[--index]
					
						if (candidate && candidate.Active && (candidate.Pages > 0)) {
							step := candidate
							page := candidate.Pages
							
							return true
						}
					}
				}
		}
	}
	
	getNextPage(ByRef step, ByRef page) {
		if (this.Step && (this.Page < this.Step.Pages)) {
			step := this.Step
			page := this.Page + 1
			
			return true
		}
		else {
			count := this.Count
		
			if !this.Step
				index := 1
			else
				index := this.Steps[this.Step] + 1
			
			Loop {
				if (index > this.Count)
					return false
				else {
					candidate := this.Steps[index++]
				
					if (candidate && candidate.Active && (candidate.Pages > 0)) {
						step := candidate
						page := 1
						
						return true
					}
				}
			}
		}
	}
	
	isFirstPage() {
		step := false
		page := false
		
		return !this.getPreviousPage(step, page)
	}
	
	isLastPage() {
		step := false
		page := false
		
		return !this.getNextPage(step, page)
	}
	
	showPage(step, page) {
		change := (step != this.Step)
		
		window := this.WizardWindow
	
		Gui %window%:Default
			
		GuiControl Disable, previousPageButton
		GuiControl Disable, nextPageButton
		GuiControl Disable, finishButton
		
		oldPageSwitch := vPageSwitch
		vPageSwitch := true
		
		try {
			if this.Step {
				if !this.hidePage(this.Step, this.Page) {
					vPageSwitch := oldPageSwitch
					
					this.updateState()
					
					return false
				}
			}
			
			this.iStep := step
			
			if change
				this.Step.show()
			
			this.Step.showPage(page)
		
			this.iPage := page
		}
		finally {
			vPageSwitch := oldPageSwitch
		}
		
		this.updateState()
	}
	
	hidePage(step, page) {
		if step.hidePage(page) {
			this.saveKnowledgeBase()
			
			return true
		}
		else
			return false
	}
	
	previousPage() {
		vWorking := true
		
		step := false
		page := false
		
		if this.getPreviousPage(step, page)
			this.showPage(step, page)
	
		vWorking := false
	}
	
	nextPage() {
		vWorking := true
		
		step := false
		page := false
		
		if this.getNextPage(step, page)
			this.showPage(step, page)
		
		vWorking := false
	}

	updateState() {
		this.KnowledgeBase.produce()			

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		Loop % this.Count
			if this.Steps.HasKey(A_Index)
				this.Steps[A_Index].updateState()
		
		window := this.WizardWindow
	
		Gui %window%:Default
		
		if !vPageSwitch {
			if this.isFirstPage()
				GuiControl Disable, previousPageButton
			else
				GuiControl Enable, previousPageButton
			
			if this.isLastPage() {
				GuiControl Disable, nextPageButton
				GuiControl Enable, finishButton
			}
			else {
				GuiControl Enable, nextPageButton
				GuiControl Disable, finishButton
			}
		}
	}
	
	selectModule(module, selected, update := true) {
		if (this.isModuleSelected(module) != (selected != false)) {
			this.KnowledgeBase.setFact("Module." . module . ".Selected", selected != false)
			
			if update
				this.updateState()
			else {
				this.KnowledgeBase.produce()
			
				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledge(this.KnowledgeBase)
			}
		}
	}
	
	isModuleSelected(module) {
		return this.KnowledgeBase.getValue("Module." . module . ".Selected", false)
	}
	
	isSoftwareRequested(software) {
		return (this.KnowledgeBase.getValue("Software." . software . ".Requested", false) != false)
	}
	
	isSoftwareOptional(software) {
		return (this.KnowledgeBase.getValue("Software." . software . ".Requested", "OPTIONAL") = "OPTIONAL")
	}
	
	isSoftwareInstalled(software) {
		return this.KnowledgeBase.getValue("Software." . software . ".Installed", false)
	}
	
	locateSoftware(software, executable := false) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.isSoftwareInstalled(software) {
			if !executable {
				executable := findSoftware(this.Definition, software)
				
				if (executable == "")
					executable := false
			}
				
			knowledgeBase.setFact("Software." . software . ".Installed", executable != false)
			
			if (executable == true)
				knowledgeBase.removeFact("Software." . software . ".Path")
			else
				knowledgeBase.setFact("Software." . software . ".Path", executable)
			
			this.updateState()
		}
	}
	
	softwarePath(software) {
		return this.KnowledgeBase.getValue("Software." . software . ".Path", false)
	}
	
	selectApplication(application, selected, update := true) {
		if (this.isApplicationSelected(application) != (selected != false)) {
			if this.isApplicationOptional(application) {
				this.KnowledgeBase.setFact("Application." . application . ".Selected", selected != false)
				
				if update
					this.updateState()
				else {
					this.KnowledgeBase.produce()
					
					if this.Debug[kDebugKnowledgeBase]
						this.dumpKnowledge(this.KnowledgeBase)
				}
			}
		}
	}
	
	isApplicationOptional(application) {
		return (this.KnowledgeBase.getValue("Application." . application . ".Requested", "OPTIONAL") = "OPTIONAL")
	}
	
	isApplicationInstalled(application) {
		return this.KnowledgeBase.getValue("Application." . application . ".Installed", false)
	}
	
	isApplicationSelected(application) {
		return this.KnowledgeBase.getValue("Application." . application . ".Selected", false)
	}
	
	locateApplication(application, executable := false, update := true) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.isApplicationInstalled(application) {
			if !executable
				for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other"] {
					descriptor := getConfigurationValue(this.Definition, section, application, false)
				
					if descriptor {
						descriptor := string2Values("|", descriptor)
						
						executable := findSoftware(this.Definition, descriptor[1])
						
						break
					}
				}
			
			if executable {
				knowledgeBase.setFact("Application." . application . ".Installed", true)
				knowledgeBase.setFact("Application." . application . ".Path", executable)
				
				if update
					this.updateState()
			}
		}
	}
	
	applicationPath(application) {
		return this.KnowledgeBase.getValue("Application." . application . ".Path", false)
	}
	
	setGeneralConfiguration(language, startWithWindows, silentMode) {
		local knowledgeBase := this.KnowledgeBase
		
		knowledgeBase.setFact("General.Language", language)
		knowledgeBase.setFact("General.Start With Windows", startWithWindows)
		knowledgeBase.setFact("General.Silent Mode", silentMode)
	}
	
	getGeneralConfiguration(ByRef language, ByRef startWithWindows, ByRef silentMode) {
		local knowledgeBase := this.KnowledgeBase
		
		language := knowledgeBase.getValue("General.Language", "EN")
		startWithWindows := knowledgeBase.getValue("General.Start With Windows", true)
		silentMode := knowledgeBase.getValue("General.Silent Mode", false)
	}
	
	setModeSelectors(modeSelectors) {
		if (modeSelectors.Length() > 0)
			this.KnowledgeBase.setFact("Controller.Mode.Selectors", values2String("|", modeSelectors*))
		else
			this.KnowledgeBase.removeFact("Controller.Mode.Selectors")
	}
	
	getModeSelectors() {
		return string2Values("|", this.KnowledgeBase.getValue("Controller.Mode.Selectors", ""))
	}
	
	setLaunchApplicationLabelsAndFunctions(labelsAndFunctions) {
		local knowledgeBase := this.KnowledgeBase
		local application
		local function
		
		Loop % knowledgeBase.getValue("System.Launch.Application.Count", 0)
		{
			application := knowledgeBase.getValue("System.Launch.Application." . A_Index, false)
		
			if application {
				knowledgeBase.removeFact("System.Launch.Application." . application . ".Label")
				knowledgeBase.removeFact("System.Launch.Application." . application . ".Function")
			}
			
			knowledgeBase.removeFact("System.Launch.Application." . A_Index)
		}
		
		count := 0
		
		for application, labelAndFunction in labelsAndFunctions {
			function := labelAndFunction[2]
			
			if (function && (function != "")) {
				count += 1
			
				knowledgeBase.addFact("System.Launch.Application." . count, application)
				knowledgeBase.addFact("System.Launch.Application." . application . ".Label", labelAndFunction[1])
				knowledgeBase.addFact("System.Launch.Application." . application . ".Function", function)
			}
		}
		
		knowledgeBase.setFact("System.Launch.Application.Count", count)
		
		this.updateState()
	}
	
	getLaunchApplicationLabel(application) {
		return this.KnowledgeBase.getValue("System.Launch.Application." application . ".Label", "")
	}
	
	getLaunchApplicationFunction(application) {
		return this.KnowledgeBase.getValue("System.Launch.Application." application . ".Function", "")
	}
	
	addModuleStaticFunction(module, function, label) {
		local knowledgeBase := this.KnowledgeBase
		
		functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		
		for index, descriptor in functions {
			parts := string2Values("###", descriptor)
		
			if ((parts[1] = module) && (parts[2] = function)) {
				parts[3] := Label
				functions[index] := values2String("###", parts*)
				
				knowledgeBase.setValue("Controller.Function.Static", values2String("|", functions*))
				
				return
			}
		}
		
		functions.Push(values2String("###", module, function, label))
		
		knowledgeBase.setFact("Controller.Function.Static", values2String("|", functions*))
	}
	
	removeModuleStaticFunction(module, function) {
		local knowledgeBase := this.KnowledgeBase
		
		functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		
		found := true
		
		while found {
			found := false
		
			for index, descriptor in functions {
				parts := string2Values("###", descriptor)
			
				if ((parts[1] = module) && (parts[2] = function)) {
					functions.RemoveAt(index)
					
					if (functions.Length() == 0)
						knowledgeBase.removeFact("Controller.Function.Static")
					else
						knowledgeBase.setValue("Controller.Function.Static", values2String("|", functions*))
					
					found := true
					
					break
				}
			}
		}
	}
	
	getModuleStaticFunctions() {
		local knowledgeBase := this.KnowledgeBase
		
		functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		result := []
		
		for index, descriptor in functions {
			parts := string2Values("###", descriptor)
		
			if wizard.isModuleSelected(parts[1])
				result.Push(Array(parts[2], parts[3]))
		}
		
		return result
	}
	
	setControllerFunctions(functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		
		Loop % knowledgeBase.getValue("Controller.Function.Count", 0)
		{
			function := knowledgeBase.getValue("Controller.Function." . A_Index, false)
		
			if function
				knowledgeBase.removeFact("Controller.Function." . function . ".Triggers")
			
			knowledgeBase.removeFact("Controller.Function." . A_Index)
		}
		
		for ignore, function in functions {
			function := IsObject(function) ? function.Clone() : Array(function)
			
			name := function[1]
			
			function.RemoveAt(1)
			
			knowledgeBase.addFact("Controller.Function." . A_Index, name)
			
			if (function.Length() > 0)
				knowledgeBase.addFact("Controller.Function." . name . ".Triggers", values2String(" | ", function*))
		}
		
		knowledgeBase.setFact("Controller.Function.Count", functions.Length())
		
		this.updateState()
	}
	
	getControllerFunctionTriggers(function) {
		return string2Values("|", this.KnowledgeBase.getValue("Controller.Function." . function . ".Triggers", ""))
	}
	
	setSimulatorActionFunctions(simulator, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		local action
		local count := 0
		
		Loop % knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action.Count", 0)
		{
			action := knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action." . A_Index, false)
		
			if action
				knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Action." . action . ".Function")
			
			knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Action." . A_Index)
		}
		
		for action, function in functions {
			if (function && ((IsObject(function) && (function.Length() > 0)) || (function != ""))) {
				if !IsObject(function)
					function := Array(function)
				
				count += 1
				
				knowledgeBase.addFact("Simulator." . simulator . ".Mode." . mode . ".Action." . count, action)
				knowledgeBase.addFact("Simulator." . simulator . ".Mode." . mode . ".Action." . action . ".Function", values2String(" | ", function*))
			}
		}
		
		knowledgeBase.setFact("Simulator." . simulator . ".Mode." . mode . ".Action.Count", count)
		
		this.updateState()
	}
	
	getSimulatorActionFunction(simulator, mode, action) {
		local function := this.KnowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action." . action . ".Function", false)
		
		if function {
			function := string2Values("|", function)
			
			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}
	
	simulatorActionAvailable(simulator, mode, action) {
		local knowledgeBase := this.KnowledgeBase
		
		goal := new RuleCompiler().compileGoal("simulatorActionAvailable?(" . StrReplace(simulator, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")
		
		return (knowledgeBase.prove(goal) != false)
	}
	
	setSimulatorValue(simulator, key, value, update := true) {
		this.KnowledgeBase.setFact("Simulator." . simulator . ".Key." . key, value)
		
		if update
			this.updateState()
	}
	
	getSimulatorValue(simulator, key, default := "") {
		return this.KnowledgeBase.getValue("Simulator." . simulator . ".Key." . key, default)
	}
	
	clearSimulatorValue(simulator, key, update := true) {
		this.KnowledgeBase.removeFact("Simulator." . simulator . ".Key." . key, "")
		
		if update
			this.updateState()
	}
	
	setAssistantActionFunctions(assistant, functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		local action
		local count := 0
		
		Loop % knowledgeBase.getValue("Assistant." . assistant . ".Action.Count", 0)
		{
			action := knowledgeBase.getValue("Assistant." . assistant . ".Action." . A_Index, false)
		
			if action
				knowledgeBase.removeFact("Assistant." . assistant . ".Action." . action . ".Function")
			
			knowledgeBase.removeFact("Assistant." . assistant . ".Action." . A_Index)
		}
		
		for action, function in functions {
			if (function && ((IsObject(function) && (function.Length() > 0)) || (function != ""))) {
				if !IsObject(function)
					function := Array(function)
				
				count += 1
				
				knowledgeBase.addFact("Assistant." . assistant . ".Action." . count, action)
				knowledgeBase.addFact("Assistant." . assistant . ".Action." . action . ".Function", values2String(" | ", function*))
			}
		}
		
		knowledgeBase.setFact("Assistant." . assistant . ".Action.Count", count)
		
		this.updateState()
	}
	
	getAssistantActionFunction(assistant, action) {
		local function := this.KnowledgeBase.getValue("Assistant." . assistant . ".Action." . action . ".Function", false)
		
		if function {
			function := string2Values("|", function)
			
			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}
	
	assistantActionAvailable(assistant, action) {
		local knowledgeBase := this.KnowledgeBase
		
		goal := new RuleCompiler().compileGoal("assistantActionAvailable?(" . StrReplace(assistant, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")
		
		return (knowledgeBase.prove(goal) != false)
	}
	
	assistantSimulators(assistant) {
		local knowledgeBase := this.KnowledgeBase
		local resultSet
		local variable
		
		goal := new RuleCompiler().compileGoal("assistantSupportedSimulator?(" . StrReplace(assistant, A_Space, "\ ") . ", ?simulator)")
		variable := goal.Arguments[2]
		
		resultSet := knowledgeBase.prove(goal)
		simulators := []
		
		while resultSet {
			simulators.Push(resultSet.getValue(variable).toString())
		
			if !resultSet.nextResult()
				resultSet := false
		}
		
		return simulators
	}
	
	setModuleValue(module, key, value, update := true) {
		this.KnowledgeBase.setFact("Module." . module . ".Key." . key, value)
		
		if update
			this.updateState()
	}
	
	getModuleValue(module, key, default := "") {
		return this.KnowledgeBase.getValue("Module." . module . ".Key." . key, default)
	}
	
	clearModuleValue(module, key, update := true) {
		this.KnowledgeBase.removeFact("Module." . module . ".Key." . key, "")
		
		if update
			this.updateState()
	}
	
	setModuleAvailableActions(module, mode, actions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		local action
		local count
		
		modeClause := (mode ? (".Mode." . mode) : "")
		
		count := knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
		
		Loop % count
		{
			action := knowledgeBase.getValue("Module." . module . modeClause . ".Action." . A_Index, false)
		
			if (action && !inList(actions, action)) {
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Function")
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Argument")
			}
			
			knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . A_Index)
		}
		
		for index, action in actions
			knowledgeBase.addFact("Module." . module . modeClause . ".Action." . index, action)
		
		knowledgeBase.setFact("Module." . module . modeClause . ".Action.Count", count + 1)
		knowledgeBase.setFact("Module." . module . modeClause . ".Action.Count", actions.Length())
		
		this.updateState()
	}
	
	setModuleActionFunctions(module, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		local action
		
		modeClause := (mode ? (".Mode." . mode) : "")
		
		Loop % knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
		{
			action := knowledgeBase.getValue("Module." . module . modeClause . ".Action." . A_Index, false)
		
			if action
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Function")
		}
		
		for action, function in functions {
			if (function && ((IsObject(function) && (function.Length() > 0)) || (function != ""))) {
				if !IsObject(function)
					function := Array(function)
				
				knowledgeBase.addFact("Module." . module . modeClause . ".Action." . action . ".Function", values2String("|", function*))
			}
		}
		
		this.updateState()
	}
	
	getModuleActionFunction(module, mode, action) {
		local function
		
		modeClause := (mode ? (".Mode." . mode) : "")
		
		function := this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Function", false)
		
		if function {
			function := string2Values("|", function)
			
			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}
	
	setModuleActionArguments(module, mode, arguments) {
		local knowledgeBase := this.KnowledgeBase
		local action
		
		modeClause := (mode ? (".Mode." . mode) : "")
		
		Loop % knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
		{
			action := knowledgeBase.getValue("Module." . module . modeClause . ".Action." . A_Index, false)
		
			if action
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Argument")
		}
		
		for action, argument in arguments
			if (argument && (argument != ""))
				knowledgeBase.addFact("Module." . module . modeClause . ".Action." . action . ".Argument", argument)
		
		this.updateState()
	}
	
	getModuleActionArgument(module, mode, action) {
		modeClause := (mode ? (".Mode." . mode) : "")
		
		return this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Argument", "")
	}
	
	moduleActionAvailable(module, mode, action) {
		local knowledgeBase := this.KnowledgeBase
		
		if mode
			goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"
		else
			goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"
		
		goal := new RuleCompiler().compileGoal(goal)
		
		return knowledgeBase.prove(goal)
	}
	
	moduleAvailableActions(module, mode) {
		local knowledgeBase := this.KnowledgeBase
		local resultSet
		local variable
		
		if mode
			goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", ?action)"
		else
			goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", ?action)"
		
		goal := new RuleCompiler().compileGoal(goal)
		variable := goal.Arguments[mode ? 3 : 2]
		
		resultSet := knowledgeBase.prove(goal)
		actions := []
		
		while resultSet {
			actions.Push(resultSet.getValue(variable).toString())
		
			if !resultSet.nextResult()
				resultSet := false
		}
		
		return actions
	}
	
	setTitle(title) {
		window := this.HelpWindow
		
		Gui %window%:Default
		
		GuiControl Text, stepTitle, % title
	}
	
	setSubtitle(subtitle) {
		window := this.HelpWindow
		
		Gui %window%:Default
		
		GuiControl Text, stepSubtitle, % translate("Step ") . this.Steps[this.Step] . translate(": ") . subtitle
	}
	
	setInfo(html) {
		window := this.HelpWindow
		
		Gui %window%:Default
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . html . "</body></html>"

		infoViewer.Document.Open()
		infoViewer.Document.Write(html)
		infoViewer.Document.Close()
	}
	
	saveKnowledgeBase() {
		savedKnowledgeBase := newConfiguration()
		
		setConfigurationSectionValues(savedKnowledgeBase, "Setup", this.KnowledgeBase.Facts.Facts)
		
		writeConfiguration(kUserHomeDirectory . "Setup\Setup.data", savedKnowledgeBase)
	}
	
	loadKnowledgeBase() {
		local knowledgeBase = this.KnowledgeBase
		
		if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
			for key, value in getConfigurationSectionValues(readConfiguration(kUserHomeDirectory . "Setup\Setup.data"), "Setup")
				knowledgeBase.setFact(key, value)
			
			return true
		}
		else
			return false
	}
	
	dumpKnowledge(knowledgeBase) {
		try {
			FileDelete %kTempDirectory%Simulator Setup.knowledge
		}
		catch exception {
			; ignore
		}

		for key, value in knowledgeBase.Facts.Facts {
			text := (key . " = " . value . "`n")
		
			FileAppend %text%, %kTempDirectory%Simulator Setup.knowledge
		}
	}
	
	dumpRules(knowledgeBase) {
		local rules
		local rule
		
		try {
			FileDelete %kTempDirectory%Simulator Setup.rules
		}
		catch exception {
			; ignore
		}

		production := knowledgeBase.Rules.Productions[false]
		
		Loop {
			if !production
				break
			
			text := (production.Rule.toString() . "`n")
		
			FileAppend %text%, %kTempDirectory%Simulator Setup.rules
			
			production := production.Next[false]
		}

		for ignore, rules in knowledgeBase.Rules.Reductions
			for ignore, rule in rules {
				text := (rule.toString() . "`n")
			
				FileAppend %text%, %kTempDirectory%Simulator Setup.rules
			}
	}
	
	toggleTriggerDetector(callback := false) {
		if callback {
			if !vShowTriggerDetector
				vTriggerDetectorCallback := callback
		}
		else
			vTriggerDetectorCallback := false
	
		vShowTriggerDetector := !vShowTriggerDetector
		
		if vShowTriggerDetector
			SetTimer showTriggerDetector, -100
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StepWizard                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StepWizard extends ConfigurationItem {
	iSetupWizard := false
	iStep := false
	iDefinition := false
		
	iWidgets := {}
	
	SetupWizard[] {
		Get {
			return this.iSetupWizard
		}
	}
	
	Window[] {
		Get {
			return this.SetupWizard.WizardWindow
		}
	}
	
	Step[] {
		Get {
			return this.iStep
		}
	}
	
	Definition[key := false] {
		Get {
			if key
				return this.iDefinition[key]
			else
				return this.iDefinition
		}
	}
	
	Pages[] {
		Get {
			return 1
		}
	}
	
	Active[] {
		Get {
			return (this.Pages > 0)
		}
	}
	
	__New(wizard, step, configuration) {
		this.iSetupWizard := wizard
		this.iStep := step
		
		base.__New(configuration)
	}
	
	loadDefinition(definition, stepDefinition) {
		local rule
		local rules := {}
		local count := 0
		
		showProgress({message: translate("Step: ") . getConfigurationValue(definition, "Setup." . this.Step, this.Step . ".Subtitle." . getLanguage())})
		
		if isDebug()
			Sleep 250
		
		for descriptor, rule in getConfigurationSectionValues(definition, "Setup." . this.Step, Object())
			if (InStr(descriptor, this.Step . ".Rule") == 1) {
				index := string2Values(".", descriptor)[3]
			
				count := Max(count, index)
				rules[index] := rule
			}
		
		Loop %count%
			if rules.HasKey(A_Index)
				this.SetupWizard.addRule(rules[A_Index])
		
		this.loadStepDefinition(stepDefinition)
	}
	
	loadStepDefinition(definition) {
		this.iDefinition := string2Values("|", definition)
	}
	
	getWorkArea(ByRef x, ByRef y, ByRef width, ByRef height) {
		this.SetupWizard.getWorkArea(x, y, width, height)
	}
	
	createGui(wizard, x, y, width, height) {
		Throw "Virtual method StepWizard.createGui must be implemented in a subclass..."
	}
	
	registerWidget(page, widget) {
		if widget {
			if !this.iWidgets.HasKey(page)
				this.iWidgets[page] := []
			
			this.iWidgets[page].Push(widget)
		}
	}
	
	registerWidgets(page, widgets*) {
		for ignore, widget in widgets
			this.registerWidget(page, widget)
	}
	
	deleteWidgets(page) {
		this.iWidgets.Delete(page)
	}
	
	reset() {
		this.iWidgets := {}
	}
	
	show() {
		language := getLanguage()
		definition := this.SetupWizard.Definition
		
		this.setTitle(getConfigurationValue(definition, "Setup." . this.Step, this.Step . ".Title." . language))
		this.setSubtitle(getConfigurationValue(definition, "Setup." . this.Step, this.Step . ".Subtitle." . language))
		this.setInfo(getConfigurationValue(definition, "Setup." . this.Step, this.Step . ".Info." . language))
	}
	
	hide() {
		this.setTitle("")
		this.setSubtitle("")
		this.setInfo("")
	}
	
	showPage(page) {
		window := this.Window
		
		Gui %window%:Default
	
		for ignore, widget in this.iWidgets[page] {
			GuiControl Show, %widget%
			GuiControl Enable, %widget%
		}
	}
	
	hidePage(page) {
		window := this.SetupWizard.HelpWindow
		
		Gui %window%:Default
	
		for ignore, widget in this.iWidgets[page] {
			GuiControl Disable, %widget%
			GuiControl Hide, %widget%
		}
		
		return true
	}
	
	updateState() {
	}
	
	setTitle(title) {
		this.SetupWizard.setTitle(title)
	}
	
	setSubtitle(subtitle) {
		this.SetupWizard.setSubtitle(subtitle)
	}
	
	setInfo(html) {
		this.SetupWizard.setInfo(substituteVariables(html))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StartStepWizard                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StartStepWizard extends StepWizard {
	iImageViewer := false
	iImageViewerHTML := false
	
	Pages[] {
		Get {
			return (A_IsAdmin ? 1 : 2)
		}
	}
	
	createGui(wizard, x, y, width, height) {
		static imageViewer
		static imageViewerHandle
		static infoText
		
		window := this.Window
		
		Sleep 200
		
		Gui %window%:Add, ActiveX, x%x% y%y% w%width% h%height% HWNDimageViewerHandle VimageViewer Hidden, shell.explorer
	
		text := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Text." . getLanguage()))
		image := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Image"))
		
		text := "<div style='text-align: center' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px' style='font-weight: 600'>" . text . "</div>"
		
		height := Round(width / 16 * 9)
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><br>" . text . "<br><img src='" . image . "' width='" . width . "' height='" . height . "' border='0' padding='0'></body></html>"
		
		imageViewer.Navigate("about:blank")
			
		this.iImageViewer := imageViewer
		this.iImageViewerHTML := html
		
		this.registerWidget(1, imageViewerHandle)
		
		if !A_IsAdmin {
			labelWidth := width - 30
			labelX := x + 35
			labelY := y + 8
			
			iconHandle := false
			labelHandle := false
			infoTextHandle := false
			restartButtonHandle := false
			
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Unblocking.Info." . getLanguage()))
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'>" . info . "</div>"
			
			Gui %window%:Font, s10 Bold, Arial
			
			Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Security.ico
			Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDlabelHandle Hidden, % translate("Unblocking Applications and DLLs")
			
			Gui %window%:Font, s8 Norm, Arial
		
			Sleep 200
			
			Gui %window%:Add, ActiveX, x%x% yp+30 w%width% h350 HWNDinfoTextHandle VinfoText Hidden, shell.explorer
			
			x := x + Round(width / 2) - 120
			
			Gui %window%:Font, s10 Bold, Arial
			
			Gui %window%:Add, Button, x%x% yp+380 w240 h30 HWNDrestartButtonHandle GelevateAndRestart Hidden, % translate("Restart as Administrator")

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			infoText.Navigate("about:blank")
			infoText.Document.Write(html)
			
			this.registerWidgets(2, iconHandle, labelHandle, infoTextHandle, restartButtonHandle)
		}
		else if A_IsAdmin
			for ignore, directory in [kBinariesDirectory, kResourcesDirectory . "Setup\Installer\"] {
				currentDirectory := A_WorkingDir

				try {
					SetWorkingDir %directory%
					
					Run Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File
				}
				finally {
					SetWorkingDir %currentDirectory%
				}
			}
	}
	
	reset() {
		base.reset()
		
		this.iImageViewer := false
		
		volume := fadeOut()
			
		try {
			SoundPlay NonExistent.avi
		}
		catch exception {
			; ignore
		}
	
		resetVolume(volume)
	}
	
	showPage(page) {
		if (page == 1) {
			imageViewer := this.iImageViewer
			
			imageViewer.Document.Open()
			imageViewer.Document.Write(this.iImageViewerHTML)
			imageViewer.Document.Close()
			
			audio := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Audio", false))			
			
			if audio
				SoundPlay %audio%
		}
		
		base.showPage(page)
	}
	
	hidePage(page) {
		if (page == 1) {
			volume := fadeOut()
			
			try {
				SoundPlay NonExistent.avi
			}
			catch exception {
				; ignore
			}
			
			resetVolume(volume)
		}
		
		if base.hidePage(page) {
			if (page == 1) {
				imageViewer := this.iImageViewer
			
				imageViewer.Document.Open()
				imageViewer.Document.Write("<html></html>")
				imageViewer.Document.Close()
			}
			
			return true
		}
		else
			return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FinishStepWizard                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FinishStepWizard extends StepWizard {
	Pages[] {
		Get {
			return 1
		}
	}
	
	createGui(wizard, x, y, width, height) {
		static imageViewer
		
		window := this.Window
		
		imageViewerHandle := false
		
		Gui %window%:Add, ActiveX, x%x% y%y% w%width% h%height% HWNDimageViewerHandle VimageViewer Hidden, shell.explorer
	
		image := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Finish", "Finish.Image"))
		text := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Finish", "Finish.Text." . getLanguage()))
		
		text := "<div style='text-align: center' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px' style='font-weight: 600'>" . text . "</div>"
		
		height := Round(width / 16 * 9)
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='auto' bottommargin='0'><img src='" . image . "' width='" . width . "' height='" . height . "' border='0' padding='0'><br><br><br>" . text . "</body></html>"
		
		imageViewer.Navigate("about:blank")
		imageViewer.Document.Write(html)
			
		this.registerWidget(1, imageViewerHandle)
	}
	
	showPage(page) {
		base.showPage(page)
		
		settingsEditor := ObjBindMethod(this, "settingsEditor")
		
		SetTimer %settingsEditor%, -200
	}
	
	hidePage(page) {
		if base.hidePage(page) {
			settings := editSettings(kSave, false, true)
			
			writeConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini", settings)
			
			return true
		}
		else
			return false
	}
	
	settingsEditor() {
		if vWorking {
			settingsEditor := ObjBindMethod(this, "settingsEditor")
					
			SetTimer %settingsEditor%, -200
			
			return
		}
	
		if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
			settings := readConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini")
		else
			settings := newConfiguration()
		
		configuration := this.SetupWizard.getSimulatorConfiguration()
		
		editSettings(settings, false, configuration, Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 180, A_ScreenWidth - 360))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

finishSetup(finish := false, save := false) {
	protectionOn()
	
	try {
		if (finish = "Finish") {
			if SetupWizard.Instance.finishSetup(save)
				ExitApp 0
		}
		else {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup ")
			MsgBox 262436, %title%, % translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the ""Simulator Controller\Config"" folder in your user ""Documents"" folder.")
			OnMessage(0x44, "")
			
			IfMsgBox Yes
				save := true
			else
				save := false
			
			SetupWizard.Instance.hidePage(SetupWizard.Instance.Step, SetupWizard.Instance.Page)
			
			callback := Func("finishSetup").Bind("Finish", save)
			
			; Let other threads finish...
				
			SetTimer %callback%, % isDebug() ? -5000 : -2000
		}
	}
	finally {
		protectionOff()
	}
}

cancelSetup() {
	if SetupWizard.Instance.finishSetup(false)
		ExitApp 0
}

previousPage() {
	SetupWizard.Instance.previousPage()
	
	vWorking := false
}

nextPage() {
	SetupWizard.Instance.nextPage()
	
	vWorking := false
}

chooseLanguage() {
	local code
	
	GuiControlGet languageDropDown
	
	languages := string2Values("|", getConfigurationValue(SetupWizard.Instance.Definition, "Setup", "Languages"))
	
	for code, language in availableLanguages()
		if (language = languageDropDown) {
			if SetupWizard.Instance.finishSetup(false) {
				setLanguage(code)
			
				vResult := kLanguage
			}
			else
				for code, language in availableLanguages()
					if (code = getLanguage()) {
						GuiControl Choose, languageDropDown, %A_Index%
						
						break
					}
			
			return
		}
}

moveSetupWizard() {
	moveByMouse(SetupWizard.Instance.WizardWindow)
}

moveSetupHelp() {
	moveByMouse(SetupWizard.Instance.HelpWindow)
}

openSetupDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#setup
}

elevateAndRestart() {
	if !(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
		try {
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		catch exception {
			;ignore
		}
		
		ExitApp 0
	}
}

fixIE(version := 0, exeName := "") {
	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7: 7000, 8: 8888, 9: 9999, 10: 10001, 11: 11001}
	
	if versions.HasKey(version)
		version := versions[version]
	
	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath A_AhkPath, exeName
	}
	
	RegRead PreviousValue, HKCU, %key%, %exeName%

	if (version = "")
		RegDelete, HKCU, %key%, %exeName%
	else
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
	
	return previousValue
}


LV_ClickedColumn(listViewHandle) {
	static LVM_SUBITEMHITTEST := 0x1039

	VarSetCapacity(POINT, 8, 0)

	DllCall("User32.dll\GetCursorPos", "Ptr", &POINT)
	DllCall("User32.dll\ScreenToClient", "Ptr", listViewHandle, "Ptr", &POINT)

	VarSetCapacity(LVHITTESTINFO, 24, 0)
	NumPut(NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0, "Int")
	NumPut(NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4, "Int")

	SendMessage, LVM_SUBITEMHITTEST, 0, &LVHITTESTINFO, , ahk_id %listViewHandle%

	return ((ErrorLevel = -1) ? 0 : (NumGet(LVHITTESTINFO, 16, "Int") + 1))
}

convertVDF2JSON(vdf) {
	; encapsulate in braces
    vdf := "{`n" . vdf . "`n}"

    ; replace open braces
	vdf := RegExReplace(vdf, """(.*)""\s*{", """${1}"": {")
	
	; replace values
	vdf := RegExReplace(vdf, """([^""]*)""\s*""([^""]*)""", """${1}"": ""${2}"",")

	; remove trailing commas
	vdf := RegExReplace(vdf, ",(\s*[}\]])", "${1}")

    ; add commas
    vdf := RegExReplace(vdf, "([}\]])(\s*)(""[^""]*"":\s*)?([{\[])/", "${1},${2}${3}${4}")

    ; object as value
    vdf := RegExReplace(vdf, "}(\s*""[^""]*"":)", "},${1}")

	return vdf
}

findInRegistry(collection, filterName, filterValue, valueName) {
	Loop 2 {
		exact := (A_Index = 1)
	
		Loop Reg, %collection%, R
			if (A_LoopRegName = filterName) {
				RegRead candidate
			
				if ((exact && (candidate = filterValue)) || (!exact && InStr(candidate, filterValue) = 1)) {
					try {
						RegRead value, %A_LoopRegKey%\%A_LoopRegSubKey%, %valueName%
					}
					catch exception {
						value := ""
					}
				
					return value
				}
			}
	}
	
	return ""
}

findInstallProperty(name, property) {
	value := findInRegistry("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, property)
	
	if (value != "")
		return value
	
	value := findInRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, property)
	
	if (value != "")
		return value
	
	value := findInRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, property)
	
	if (value != "")
		return value
}

initializeSimulatorSetup() {
	icon := kIconsDirectory . "Wand.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Setup
	
	FileCreateDir %kUserHomeDirectory%Setup
	
	protectionOn()
	
	try {
		definition := readConfiguration(kResourcesDirectory . "Setup\Simulator Setup.ini")
	
		setConfigurationSectionValues(kSimulatorConfiguration, "Splash Window", getConfigurationSectionValues(definition, "Splash Window"))
		setConfigurationSectionValues(kSimulatorConfiguration, "Splash Themes", getConfigurationSectionValues(definition, "Splash Themes"))
	
		setConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", translate("Modular Simulator Controller System") . translate(" - ") . translate("Setup && Configuration"))
		
		showSplashTheme("Rotating Brain")
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		vProgressCount := 0
		
		showProgress({x: x, y: y, color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("Preparing Configuration Steps...")})
		
		if isDebug()
			Sleep 500
	
		wizard := new SetupWizard(kSimulatorConfiguration, definition)
		
		wizard.registerStepWizard(new StartStepWizard(wizard, "Start", kSimulatorConfiguration))
		wizard.registerStepWizard(new FinishStepWizard(wizard, "Finish", kSimulatorConfiguration))
	}
	finally {
		protectionOff()
	}
}

startupSimulatorSetup() {
	static first := true
	
	wizard := SetupWizard.Instance
	
	wizard.loadDefinition()
	
	if wizard.Debug[kDebugRules]
		wizard.dumpRules(wizard.KnowledgeBase)
	
restartSetup:
	previous := fixIE()
	
	if (previous = "")
		previous := "9"
	
	try {
		wizard.createGui(wizard.Configuration)
	}
	finally {
		fixIE(previous)
	}
	
	wizard.startSetup()
	
	while (vProgressCount < 100) {
		showProgress({progress: ++vProgressCount, message: translate("Starting UI...")})
	
		Sleep 5
	}
	
	if first {
		first := false
		
		hideSplashTheme()
	}
		
	hideProgress()
	
	done := false

	wizard.show()
	
	try {
		Loop {
			vWorking := false
		
			Sleep 200
			
			if (vResult == kLanguage)
				done := true
		} until done
	}
	finally {
		wizard.hide()
	}
	
	if (vResult == kLanguage) {
		vResult := false
		
		wizard.close()
		wizard.reset()
		
		vProgressCount := 0
		
		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150
		
		vProgressCount := 0
		
		showProgress({x: x, y: y, color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("")})
		
		Goto restartSetup
	}
	else {
		; Let finish all threads
	
		SetTimer exitApp, % isDebug() ? -5000 : -2000
	}
}

exitApp() {
	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

openLabelsEditor() {
	fileName := ("Controller Plugin Labels." . getLanguage())
	
	if !FileExist(kUserTranslationsDirectory . fileName)
		FileCopy %kResourcesDirectory%Templates\%fileName%, %kUserTranslationsDirectory%%fileName%
	
	Run % "notepad.exe " . """" . kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage() . """"
}

findSoftware(definition, software) {
	for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getConfigurationSectionValues(definition, section, Object()) {
			descriptor := string2Values("|", descriptor)
		
			if (software = descriptor[1]) {
				for ignore, locator in string2Values(";", descriptor[2]) {
					if (InStr(locator, "File:") == 1) {
						locator := substituteVariables(StrReplace(locator, "File:", ""))
						
						if FileExist(locator)
							return locator
					}
					else if (InStr(locator, "RegistryExist:") == 1) {
						try {
							RegRead value, % substituteVariables(StrReplace(locator, "RegistryExist:", ""))
						}
						catch exception {
							value := ""
						}
					
						if (value != "")
							return true
					}
					else if (InStr(locator, "RegistryScan:") == 1) {
						folder := findInstallProperty(substituteVariables(StrReplace(locator, "RegistryScan:", "")), "InstallLocation")
				
						if ((folder != "") && FileExist(folder . descriptor[3]))
							return (folder . descriptor[3])
					}
					else if (InStr(locator, "Steam:") == 1) {
						locator := substituteVariables(StrReplace(locator, "Steam:", ""))
						
						try {
							RegRead installPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam, InstallPath
						}
						catch exception {
							installPath := ""
						}
						
						if (installPath != "") {
							FileRead script, %installPath%\steamapps\libraryfolders.vdf
							
							folders := JSON.parse(convertVDF2JSON(script))
							folders := folders["LibraryFolders"]
							fileName := folders[1] . "\steamapps\common\" . locator . "\" . descriptor[3]
							
							if FileExist(fileName)
								return fileName
						}
					}
				}
			
				exePath := getConfigurationValue(kSimulatorConfiguration, name, "Exe Path", false)
				
				if (exePath && FileExist(exePath))
					return exePath
			}
		}
		
	if ((software = "NirCmd") && kNirCmd && FileExist(kNirCmd))
		return kNirCmd
		
	if ((software = "Sox") && kSoX && FileExist(kSox))
		return kSoX
	
	return false
}
	
getApplicationDescriptor(application) {
	definition := SetupWizard.Instance.Definition
	
	for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getConfigurationSectionValues(definition, section, Object())
			if (name = application)
				return string2Values("|", descriptor)
	
	return false
}

fadeOut() {
	SoundGet masterVolume, MASTER

	currentVolume := masterVolume

	Loop {
		currentVolume -= 5

		if (currentVolume <= 0)
			break
		else {
			SoundSet %currentVolume%, MASTER

			Sleep 200
		}
	}
	
	return masterVolume
}

resetVolume(masterVolume) {
	SoundSet %masterVolume%, MASTER
}


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 1                     ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorSetup()


;;;-------------------------------------------------------------------------;;;
;;;                          Wizard Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ModulesStepWizard.ahk
#Include Libraries\InstallationStepWizard.ahk
#Include Libraries\ApplicationsStepWizard.ahk
#Include Libraries\ButtonBoxStepWizard.ahk
#Include Libraries\GeneralStepWizard.ahk
#Include Libraries\SimulatorsStepWizard.ahk
#Include Libraries\AssistantsStepWizard.ahk
#Include Libraries\MotionFeedbackStepWizard.ahk
#Include Libraries\TactileFeedbackStepWizard.ahk
#Include Libraries\PedalCalibrationStepWizard.ahk


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorSetup()