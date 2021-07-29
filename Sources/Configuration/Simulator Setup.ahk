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
#Include Libraries\ConfigurationEditor.ahk
#Include Libraries\ButtonBoxEditor.ahk


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

global vResult = false


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff = 0
global kDebugKnowledgeBase = 1


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
		this.iDebug := (isDebug() ? kDebugKnowledgeBase : kDebugOff)
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
		
		for descriptor, stepDefinition in getConfigurationSectionValues(definition, "Setup.Steps") {
			descriptor := string2Values(".", descriptor)
		
			step := descriptor[3]
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
		
			if step
				step.loadDefinition(definition, getConfigurationValue(definition, "Setup.Steps", "Step." . A_Index . "." . step.Step))
		}
		
		this.iCount := count

		if !this.loadKnowledgeBase()
			this.KnowledgeBase.addFact("Initialize", true)
			
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

		Gui %window%:Font, Norm, Arial
		
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
		
		Gui %window%:Add, Button, x535 y580 w80 h23 Disabled GsaveAndExit VfinishButton, % translate("Finish")
		Gui %window%:Add, Button, x620 y580 w80 h23 GcancelAndExit, % translate("Cancel")
		
		window := this.HelpWindow
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, E5E5E5

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w350 Center gmoveSetupHelp VstepTitle, % translate("Title")
		
		Gui %window%:Font, s9 Norm, Arial

		Gui %window%:Add, Text, YP+20 w350 Center VstepSubtitle, % translate("Subtitle")
		
		Gui %window%:Add, Text, yp+20 w350 0x10
		
		Gui %window%:Add, ActiveX, x12 yp+10 w350 h545 vinfoViewer, shell explorer
	
		infoViewer.Navigate("about:blank")
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

		infoViewer.Document.Write(html)
		
		this.createSteps()
	}
	
	createSteps() {
		local stepWizard
		
		x := 0
		y := 0
		width := 0
		height := 0
		
		this.getWorkArea(x, y, width, height)
		
		for step, stepWizard in this.StepWizards
			stepWizard.createGui(this, x, y, width, height)
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
		this.updateState()
		
		this.iStep := false
		this.iPage := false
		
		this.nextPage()
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
		
		if this.Step {
			if !this.Step.hidePage(this.Page) {
				this.updateState()
				
				return false
			}
			
			if (step != this.Step)
				hide := true
		}
		
		this.iStep := step
		
		if change
			this.Step.show()
		
		this.Step.showPage(page)
		
		this.iPage := page
		
		this.updateState()
		
		this.saveKnowledgeBase()
	}
	
	previousPage() {
		step := false
		page := false
		
		if this.getPreviousPage(step, page)
			this.showPage(step, page)
	}
	
	nextPage() {
		step := false
		page := false
		
		if this.getNextPage(step, page)
			this.showPage(step, page)
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
	
	locateApplication(application, executable := false) {
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
				
				this.updateState()
			}
		}
	}
	
	applicationPath(application) {
		return this.KnowledgeBase.getValue("Application." . application . ".Path", false)
	}
	
	setControllerFunctions(functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		
		Loop % knowledgeBase.getValue("Controller.Function.Count", 0) {
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
	
	setSimulatorCommandFunctions(simulator, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		
		Loop % knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Command.Count", 0) {
			command := knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Command." . A_Index, false)
		
			if command
				knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Command." . command . ".Function")
			
			knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Command." . A_Index)
		}
		
		count := 0
		
		for command, function in functions {
			if (function && ((IsObject(function) && (function.Length() > 0)) || (function != ""))) {
				if !IsObject(function)
					function := Array(function)
				
				count += 1
				
				knowledgeBase.addFact("Simulator." . simulator . ".Mode." . mode . ".Command." . count, command)
				knowledgeBase.addFact("Simulator." . simulator . ".Mode." . mode . ".Command." . command . ".Function", values2String(" | ", function*))
			}
		}
		
		knowledgeBase.setFact("Simulator." . simulator . ".Mode." . mode . ".Command.Count", count)
		
		this.updateState()
	}
	
	getSimulatorCommandFunction(simulator, mode, command) {
		local function := this.KnowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Command." . command . ".Function", false)
		
		if function {
			function := string2Values("|", function)
			
			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}
	
	simulatorCommandAvailable(simulator, mode, command) {
		local knowledgeBase := this.KnowledgeBase
		
		goal := new RuleCompiler().compileGoal("simulatorCommandAvailable(" . StrReplace(simulator, " ", "\ ") . ", " . StrReplace(mode, " ", "\ ") . ", " . StrReplace(command, " ", "\ ") . ")")
		
		return knowledgeBase.prove(goal)
	}
	
	setAssistantCommandFunctions(assistant, functions) {
		local knowledgeBase := this.KnowledgeBase
		local function
		
		Loop % knowledgeBase.getValue("Assistant." . assistant . ".Command.Count", 0) {
			command := knowledgeBase.getValue("Assistant." . assistant . ".Command." . A_Index, false)
		
			if command
				knowledgeBase.removeFact("Assistant." . assistant . ".Command." . command . ".Function")
			
			knowledgeBase.removeFact("Assistant." . assistant . ".Command." . A_Index)
		}
		
		count := 0
		
		for command, function in functions {
			if (function && ((IsObject(function) && (function.Length() > 0)) || (function != ""))) {
				if !IsObject(function)
					function := Array(function)
				
				count += 1
				
				knowledgeBase.addFact("Assistant." . assistant . ".Command." . count, command)
				knowledgeBase.addFact("Assistant." . assistant . ".Command." . command . ".Function", values2String(" | ", function*))
			}
		}
		
		knowledgeBase.setFact("Assistant." . assistant . ".Mode." . mode . ".Command.Count", count)
		
		this.updateState()
	}
	
	getAssistantCommandFunction(assistant, command) {
		local function := this.KnowledgeBase.getValue("Assistant." . assistant . ".Command." . command . ".Function", false)
		
		if function {
			function := string2Values("|", function)
			
			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}
	
	assistantCommandAvailable(assistant, command) {
		local knowledgeBase := this.KnowledgeBase
		
		goal := new RuleCompiler().compileGoal("assistantCommandAvailable(" . StrReplace(assistant, " ", "\ ") . ", " . StrReplace(command, " ", "\ ") . ")")
		
		return knowledgeBase.prove(goal)
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
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . html . "</body></html>"

		infoViewer.Document.Open()
		infoViewer.Document.Write(html)
		infoViewer.Document.Close()
	}
	
	saveKnowledgeBase() {
		savedKnowledgeBase := newConfiguration()
		
		setConfigurationSectionValues(savedKnowledgeBase, "Setup", this.KnowledgeBase.Facts.Facts)
		
		writeConfiguration(kUserHomeDirectory . "Install\Install.data", savedKnowledgeBase)
	}
	
	loadKnowledgeBase() {
		local knowledgeBase = this.KnowledgeBase
		
		if FileExist(kUserHomeDirectory . "Install\Install.data") {
			for key, value in getConfigurationSectionValues(readConfiguration(kUserHomeDirectory . "Install\Install.data"), "Setup")
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
			text := key . " = " . value . "`n"
		
			FileAppend %text%, %kTempDirectory%Simulator Setup.knowledge
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
	
	Definition[] {
		Get {
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
		count := 0
		
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
		if !this.iWidgets.HasKey(page)
			this.iWidgets[page] := []
		
		this.iWidgets[page].Push(widget)
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
		
		Gui %window%:Add, ActiveX, x%x% y%y% w%width% h%height% HWNDimageViewerHandle VimageViewer Hidden, shell explorer
	
		text := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Text." . getLanguage()))
		image := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Image"))
		
		text := "<div style='text-align: center' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . text . "</div>"
		
		height := Round(width / 16 * 9)
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><br>" . text . "<br><img src='" . image . "' width='" . width . "' height='" . height . "' border='0' padding='0'></body></html>"
		
		imageViewer.Navigate("about:blank")
			
		this.iImageViewer := imageViewer
		this.iImageViewerHTML := html
		
		this.registerWidget(1, imageViewerHandle)
		
		if !A_IsAdmin {
			labelWidth := width - 30
			labelX := x + 45
			labelY := y + 5
			
			iconHandle := false
			labelHandle := false
			infoTextHandle := false
			restartButtonHandle := false
			
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Unblocking.Info." . getLanguage()))
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
			
			Gui %window%:Font, s12 Bold, Arial
			
			Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Security.ico
			Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDlabelHandle Hidden, % translate("Unblocking of the applications and DLLs")
			
			Gui %window%:Font, s9 Norm, Arial
			
			Gui %window%:Add, ActiveX, x%x% yp+33 w%width% h350 HWNDinfoTextHandle VinfoText Hidden, shell explorer
			
			x := x + Round(width / 2) - 120
			
			Gui %window%:Font, s12 Bold, Arial
			
			Gui %window%:Add, Button, x%x% yp+380 w240 h30 HWNDrestartButtonHandle GelevateAndRestart Hidden, % translate("Restart as Administrator")

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			infoText.Navigate("about:blank")
			infoText.Document.Write(html)
			
			this.registerWidgets(2, iconHandle, labelHandle, infoTextHandle, restartButtonHandle)
		}
		else {
			currentDirectory := A_WorkingDir

			try {
				SetWorkingDir %kBinariesDirectory%
				
				if A_IsAdmin
					Run Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File
			}
			finally {
				SetWorkingDir %currentDirectory%
			}
		}
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
		if base.hidePage(page) {
			if (page == 1) {
				imageViewer := this.iImageViewer
			
				imageViewer.Document.Open()
				imageViewer.Document.Write("<html></html>")
				imageViewer.Document.Close()
				
				try {
					SoundPlay NonExistent.avi
				}
				catch exception {
					; ignore
				}
			}
			
			return true
		}
		else
			return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ModulesStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ModulesStepWizard extends StepWizard {
	iModuleSelectors := []
	
	Pages[] {
		Get {
			return Ceil(this.Definition.Length() / 3)
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
		
		if (definition.Length() > 12)
			Throw "Too many modules detected in ModulesStepWizard.createGui..."
		
		Loop % definition.Length()
		{
			window := this.Window
		
			iconHandle := false
			labelHandle := false
			checkBoxHandle := false
			infoTextHandle := false
		
			Gui %window%:Font, s12 Bold, Arial

			module := definition[A_Index]
			selected := this.SetupWizard.isModuleSelected(module)
			
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Info." . getLanguage()))
			module := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . "." . getLanguage()))
			
			label := (translate("Module: ") . module)
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
			
			checkX := x + width - 20
			labelWidth := width - 30
			labelX := x + 45
			labelY := y + 5
			
			Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Module.png
			Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDlabelHandle Hidden, % label
			Gui %window%:Add, CheckBox, Checked%selected% x%checkX% y%y% w23 h23 HWNDcheckBoxHandle VmoduleCheck%A_Index% Hidden gupdateSelectedModules
			Gui %window%:Add, ActiveX, x%x% yp+33 w%width% h120 HWNDinfoTextHandle VinfoText%A_Index% Hidden, shell explorer

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			infoText%A_Index%.Navigate("about:blank")
			infoText%A_Index%.Document.Write(html)
	
			y += 170
			
			this.iModuleSelectors.Push(checkBoxHandle)
			
			this.registerWidgets(Ceil(A_Index / 3), iconHandle, labelHandle, checkBoxHandle, infoTextHandle)
			
			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}
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

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; InstallationStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class InstallationStepWizard extends StepWizard {
	iPages := {}
	iSoftwareLocators := {}
	
	Pages[] {
		Get {
			return Ceil(this.Definition.Length() / 3)
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
		static infoText13
		static infoText14
		static infoText15
		static infoText16
		
		static installButton1
		static installButton2
		static installButton3
		static installButton4
		static installButton5
		static installButton6
		static installButton7
		static installButton8
		static installButton9
		static installButton10
		static installButton11
		static installButton12
		static installButton13
		static installButton14
		static installButton15
		static installButton16
		
		static locateButton1
		static locateButton2
		static locateButton3
		static locateButton4
		static locateButton5
		static locateButton6
		static locateButton7
		static locateButton8
		static locateButton9
		static locateButton10
		static locateButton11
		static locateButton12
		static locateButton13
		static locateButton14
		static locateButton15
		static locateButton16
		
		definition := this.Definition
		
		startY := y
		
		if (this.Definition.Count() > 16)
			Throw "Too many modules detected in InstallationStepWizard.createGui..."
		
		window := this.Window
	
		for ignore, software in this.Definition
		{
			iconHandle := false
			labelHandle := false
			installButtonHandle := false
			locateButtonHandle := false
			infoTextHandle := false
	
			installer := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software))
			locatable := getConfigurationValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Locatable", true)
			info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software . ".Info." . getLanguage()))
			
			label := (translate("Software: ") . software)
			info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
			
			installed := this.SetupWizard.isSoftwareInstalled(software)
			
			buttonX := x + width - 90
			
			if locatable
				buttonX -= 95
			
			labelWidth := width - 60 - 90 - (locatable * 95)
			labelX := x + 45
			labelY := y + 5
			
			Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDiconHandle Hidden, %kResourcesDirectory%Setup\Images\Install.png
			
			Gui %window%:Font, s12 Bold, Arial
			
			Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDlabelHandle Hidden, % label
			
			Gui %window%:Font, s9 Norm, Arial
			
			Gui %window%:Add, Button, x%buttonX% y%y% w90 h23 HWNDinstallButtonHandle VinstallButton%A_Index% GinstallSoftware Hidden, % (InStr(installer, "http") = 1) ? translate("Download...") : translate("Install...")
			
			if locatable {
				buttonX += 95
				
				Gui %window%:Add, Button, x%buttonX% y%y% w90 h23 HWNDlocateButtonHandle VlocateButton%A_Index% GlocateSoftware Hidden, % installed ? translate("Installed") : translate("Locate...")
			}
			
			Gui %window%:Add, ActiveX, x%x% yp+33 w%width% h120 HWNDinfoTextHandle VinfoText%A_Index% Hidden, shell explorer

			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			infoText%A_Index%.Navigate("about:blank")
			infoText%A_Index%.Document.Write(html)
	
			y += 170
			
			page := Ceil(A_Index / 3)
			
			this.registerWidgets(page, iconHandle, labelHandle, installButtonHandle, infoTextHandle)
			
			if locatable
				this.registerWidget(page, locateButtonHandle)
			
			this.iSoftwareLocators[software] := (locatable ? [installButtonHandle, locateButtonHandle] : [installButtonHandle])
	
			if !this.iPages.HasKey(page)
				this.iPages[page] := {}
			
			this.iPages[page][software] := [iconHandle, labelHandle, installButtonHandle, locateButtonHandle, infoTextHandle]
			
			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}
	}
	
	reset() {
		base.reset()
		
		this.iPages := {}
		this.iSoftwareLocators := {}
	}
	
	loadStepDefinition(definition) {
		base.loadStepDefinition(definition)
		
		for ignore, software in this.Definition
			this.SetupWizard.locateSoftware(software)
	}
	
	installSoftware(software) {
		Run % substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . software))
	}
	
	locateSoftware(software, executable) {
		this.SetupWizard.locateSoftware(software, executable)
		
		buttons := this.iSoftwareLocators[software]
			
		GuiControl Disable, % buttons[1]
		
		button := buttons[2]
		
		GuiControl Disable, %button% 
		GuiControl Text, %button%, % translate("Installed")
	}
	
	showPage(page) {
		base.showPage(page)
	
		for software, widgets in this.iPages[page]
			if !this.SetupWizard.isSoftwareRequested(software)
				for ignore, widget in widgets
					GuiControl Disable, %widget%
			else if (this.SetupWizard.isSoftwareInstalled(software) && this.iSoftwareLocators.HasKey(software)) {
				buttons := this.iSoftwareLocators[software]
			
				GuiControl Disable, % buttons[1]
				
				if (buttons.Length() > 1) {
					button := buttons[2]
					
					GuiControl Disable, %button% 
					GuiControl Text, %button%, % translate("Installed")
				}
				else {
					button := buttons[1]
				
					GuiControl Text, %button%, % translate("Installed")
				}
			}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ApplicationsStepWizard extends StepWizard {
	iModuleApplications := {}
	
	iSimulatorsListView := false
	iApplicationsListView := false
	
	Pages[] {
		Get {
			return 2
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static simulatorsInfoText
		
		labelY := y
		
		window := this.Window
		
		Gui %window%:Default
		
		simulatorsIconHandle := false
		simulatorsLabelHandle := false
		simulatorsListViewHandle := false
		simulatorsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 5
		
		Gui %window%:Font, s12 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDsimulatorsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Gaming Wheel.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDsimulatorsLabelHandle Hidden, % translate("Simulations")
		
		Gui %window%:Font, s9 Norm, Arial
		
		Gui Add, ListView, x%x% yp+33 w%width% h200 -Multi -LV0x10 Checked NoSort NoSortHdr HWNDsimulatorsListViewHandle Hidden, % values2String("|", map(["Simulation", "Path"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Simulators.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"

		Gui %window%:Add, ActiveX, x%x% yp+205 w%width% h180 HWNDsimulatorsInfoTextHandle VsimulatorsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		simulatorsInfoText.Navigate("about:blank")
		simulatorsInfoText.Document.Write(html)
		
		this.iSimulatorsListView := simulatorsListViewHandle
		
		this.registerWidgets(1, simulatorsIconHandle, simulatorsLabelHandle, simulatorsListViewHandle, simulatorsInfoTextHandle)
		
		applicationsIconHandle := false
		applicationsLabelHandle := false
		applicationsListViewHandle := false
		applicationsInfoTextHandle := false
		
		labelY := y + 5
		
		Gui %window%:Font, s12 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDapplicationsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Tool Chest.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDapplicationsLabelHandle Hidden, % translate("Applications && Tools")
		
		Gui %window%:Font, s9 Norm, Arial
		
		Gui Add, ListView, x%x% yp+33 w%width% h200 -Multi -LV0x10 AltSubmit Checked NoSort NoSortHdr HWNDapplicationsListViewHandle GupdateSelectedApplications Hidden, % values2String("|", map(["Category", "Application", "Path"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Applications", "Applications.Applications.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+205 w%width% h180 HWNDapplicationsInfoTextHandle VapplicationsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		applicationsInfoText.Navigate("about:blank")
		applicationsInfoText.Document.Write(html)
		
		this.iApplicationsListView := applicationsListViewHandle
		
		this.registerWidgets(2, applicationsIconHandle, applicationsLabelHandle, applicationsListViewHandle, applicationsInfoTextHandle)
	}
	
	loadStepDefinition(definition) {
		base.loadStepDefinition(definition)
		
		if !FileExist(kUserHomeDirectory . "Install\Simulator Setup.data")
			this.updateAvailableApplications(true)
	}
	
	reset() {
		base.reset()
		
		this.iSimulatorsListView := false
		this.iApplicationsListView := false
	}
	
	updateState() {
		base.updateState()
		
		if this.Definition
			this.updateAvailableApplications()
	}
	
	showPage(page) {
		local application
		
		base.showPage(page)
		
		static first1 := true
		static first2 := true
		
		icons := []
		rows := []
			
		if (page == 1) {
			Gui ListView, % this.iSimulatorsListView
			
			LV_Delete()
			
			wizard := this.SetupWizard
			definition := this.Definition
			
			for simulator, descriptor in getConfigurationSectionValues(wizard.Definition, definition[1]) {
				if wizard.isApplicationInstalled(simulator) {
					descriptor := string2Values("|", descriptor)
				
					executable := wizard.applicationPath(simulator)
					
					iconFile := findInstallProperty(simulator, "DisplayIcon")
					
					if iconFile
						icons.Push(iconFile)
					else if executable
						icons.Push(executable)
					else
						icons.Push("")
					
					rows.Push(Array((wizard.isApplicationSelected(simulator) ? "Check Icon" : "Icon") . (rows.Length() + 1), simulator, executable ? executable : translate("Not installed")))
				}
			}
			
			listViewIcons := IL_Create(icons.Length())
				
			for ignore, icon in icons
				IL_Add(listViewIcons, icon)
			
			LV_SetImageList(listViewIcons)
			
			for ignore, row in rows
				LV_Add(row*)
			
			if first1 {
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				
				first1 := false
			}
		}
		else if (page == 2) {
			Gui ListView, % this.iApplicationsListView
			
			icons := []
			
			LV_Delete()
			
			for ignore, section in string2Values(",", definition[2]) {
				category := ConfigurationItem.splitDescriptor(section)[2]
			
				for application, descriptor in getConfigurationSectionValues(wizard.Definition, section) {
					if (wizard.isApplicationInstalled(application) || !wizard.isApplicationOptional(application)) {
						descriptor := string2Values("|", descriptor)
					
						executable := wizard.applicationPath(application)
					
						LV_Add(wizard.isApplicationSelected(application) ? "Check" : "", category, application, executable ? executable : translate("Not installed"))
					}
				}
			}
			
			if first2 {
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(3, "AutoHdr")
				
				first2 := false
			}
		}
	}
	
	hidePage(page) {
		this.updateSelectedApplications(page)
		
		return base.hidePage(page)
	}
	
	updateAvailableApplications(initialize := false) {
		local application
		
		wizard := this.SetupWizard
		definition := this.Definition
		
		for ignore, section in concatenate([definition[1]], string2Values(",", definition[2])) {
			category := ConfigurationItem.splitDescriptor(section)[2]
		
			for application, ignore in getConfigurationSectionValues(wizard.Definition, section) {
				if !wizard.isApplicationInstalled(application) {
					wizard.locateApplication(application)
				
					if (initialize && wizard.isApplicationInstalled(application))
						wizard.selectApplication(application, true, false)
				}
				else if initialize
					wizard.selectApplication(application, true, false)
			}
		}
	}

	updateSelectedApplications(page) {
		wizard := this.SetupWizard
		
		Gui ListView, % ((page == 1) ? [this.iSimulatorsListView] : [this.iApplicationsListView])
		
		column := ((page == 1) ? 1 : 2)
		
		checked := {}
	
		row := 0
		
		Loop {
			row := LV_GetNext(row, "C")
		
			if row {
				LV_GetText(name, row, column)
				
				checked[name] := true
			}
			else
				break
		}
		
		Loop % LV_GetCount()
		{
			LV_GetText(name, A_Index, column)
	
			if wizard.isApplicationOptional(name)
				wizard.selectApplication(name, checked.HasKey(name) ? checked[name] : false, false)
			else 
				LV_Modify(A_Index, "Check")
		}
			
		wizard.updateState()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxStepWizard                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxStepWizard extends StepWizard {
	iButtonBoxEditor := false
	
	iFunctionsListView := false
	
	iFunctionTriggers := {}
		
	class StepButtonBoxEditor extends ButtonBoxEditor {
		configurationChanged(name) {
			base.configurationChanged(name)
			
			configuration := newConfiguration()
			
			this.saveToConfiguration(configuration)
			
			writeConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini", configuration)
			
			protectionOn()
	
			oldGui := A_DefaultGui
			
			try {
				SetupWizard.Instance.StepWizards["Button Box"].loadFunctions(configuration)
			}
			finally {
				protectionOff()
				
				Gui %oldGui%:Default
			}
		}
	}
	
	Pages[] {
		Get {
			definition := this.Definition
			
			return (this.SetupWizard.isModuleSelected(definition[1]) ? 1 : 0)
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static functionsInfoText
		
		labelY := y
		
		window := this.Window
		
		Gui %window%:Default
		
		functionsIconHandle := false
		functionsIconLabelHandle := false
		functionsListViewHandle := false
		functionsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 5
		
		Gui %window%:Font, s12 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDfunctionsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDfunctionsLabelHandle Hidden, % translate("Controller Layout && Triggers")
		
		Gui %window%:Font, s9 Norm, Arial
		
		Gui Add, ListView, x%x% yp+33 w%width% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDfunctionsListViewHandle gupdateFunctionTriggers Hidden, % values2String("|", map(["Controller / Button Box", "Control", "Function", "Number", "Trigger(s)", "Hints"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Button Box", "Button Box.Functions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h135 HWNDfunctionsInfoTextHandle VfunctionsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		functionsInfoText.Navigate("about:blank")
		functionsInfoText.Document.Write(html)
		
		this.ifunctionsListView := functionsListViewHandle
		
		this.registerWidgets(1, functionsIconHandle, functionsLabelHandle, functionsListViewHandle, functionsInfoTextHandle)
	}
	
	reset() {
		base.reset()
		
		this.iFunctionsListView := false
		this.iFunctionTriggers := {}
		
		if this.iButtonBoxEditor {
			this.iButtonBoxEditor.close(true)
			
			this.iButtonBoxEditor := false
		}		
	}
	
	showPage(page) {
		base.showPage(page)
		
		if !FileExist(kUserHomeDirectory . "Install\Button Box Configuration.ini")
			FileCopy %kResourcesDirectory%Setup\Button Box Configuration.ini, %kUserHomeDirectory%Install\Button Box Configuration.ini
			
		this.iButtonBoxEditor := new this.StepButtonBoxEditor("Default", this.SetupWizard.Configuration, kUserHomeDirectory . "Install\Button Box Configuration.ini", false)
		
		this.iButtonBoxEditor.open(Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 225, A_ScreenWidth - 450))
		
		this.loadFunctions(readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini"), true)
	}
	
	hidePage(page) {
		configuration := readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini")
		
		if (this.conflictingFunctions(configuration) || this.conflictingTriggers(configuration)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Functions")
			MsgBox 262160, %title%, % translate("There are still duplicate functions or duplicate triggers - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		if (LV_GetCount() != this.iFunctionTriggers.Length()) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Functions")
			MsgBox 262436, %title%, % translate("Not all functions have been assigned to physical controls. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		if base.hidePage(page) {
			this.iButtonBoxEditor.close(true)
			
			this.iButtonBoxEditor := false
		
			this.SetupWizard.setControllerFunctions(this.controllerFunctions(configuration))
			
			return true
		}
		else
			return false
	}
	
	controllerFunctions(configuration) {
		local function
		
		controls := {}
		functions := {}
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]
					function := ConfigurationItem.splitDescriptor(function)
					function := ConfigurationItem.descriptor(controls[function[1]], function[2])
				
					if (function != "")
						if this.iFunctionTriggers.HasKey(function)
							functions.Push(Array(function, this.iFunctionTriggers[function]*))
						else
							functions.Push(function)
				}
			}
		}
				
		return functions
	}
	
	conflictingFunctions(configuration) {
		local function
		
		controls := {}
		functions := {}
		conflict := false
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]
				
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]
				
					if (function != "") {
						function := ConfigurationItem.splitDescriptor(function)
						function := ConfigurationItem.descriptor(controls[function[1]], function[2])
						
						if !functions.HasKey(function)
							functions[function] := [controller]
						else {
							functions[function].Push(controller)
						
							conflict := true
						}
					}
				}
			}
		}
		
		return (conflict ? functions : false)
	}
	
	conflictingTriggers(configuration) {
		local function
		
		triggers := {}
		conflict := false
		
		for function, functionTriggers in this.iFunctionTriggers
			for ignore, trigger in functionTriggers
				if !triggers.HasKey(trigger)
					triggers[trigger] := [function]
				else {
					triggers[trigger].Push(function)
				
					conflict := true
				}
		
		return (conflict ? triggers : false)
	}
	
	loadFunctions(configuration, load := false) {
		local function
		
		controls := {}
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		window := this.Window
		wizard := this.SetupWizard
		
		Gui %window%:Default
		
		Gui ListView, % this.iFunctionsListView
		
		if load
			this.iFunctionTriggers := {}
		
		LV_Delete()
		
		lastController := false
		
		functionConflicts := this.conflictingFunctions(configuration)
		triggerConflicts := this.conflictingTriggers(configuration)
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]
			
				for ignore, control in string2Values(";", definition) {
					control := string2Values(",", control)[1]
				
					if (control != "") {
						control := ConfigurationItem.splitDescriptor(control)
						function := ConfigurationItem.descriptor(controls[control[1]], control[2])
						
						first := (controller != lastController)
						lastController := controller
				
						if this.iFunctionTriggers.HasKey(function)
							functionTriggers := this.iFunctionTriggers[function]
						else
							functionTriggers := wizard.getControllerFunctionTriggers(function)
						
						conflict := 0
						
						if (functionConflicts && functionConflicts[function].Length() > 1)
							conflict += 1
						
						if triggerConflicts
							for ignore, trigger in functionTriggers
								if (triggerConflicts[trigger].Length() > 1) {
									conflict += 2
									
									break
								}
							
						if (conflict == 1)
							conflict := translate("Duplicate function...")
						else if (conflict == 2)
							conflict := translate("Duplicate trigger(s)...")
						else if (conflict == 3)
							conflict := translate("Duplicate function and duplicate trigger(s)...")
						else
							conflict := ""
						
						if (functionTriggers.Length() > 0) {
							triggers := values2String(" | ", functionTriggers*)
							
							if load
								this.iFunctionTriggers[function] := functionTriggers
						}
						else
							triggers := ""
						
						LV_Add("", (first ? controller : ""), control[1], translate(controls[control[1]]), control[2], triggers, conflict)
					}
				}
			}
		}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr Integer Center")
		LV_ModifyCol(5, "AutoHdr")
		LV_ModifyCol(6, "AutoHdr")
	}
	
	updateFunctionTriggers(row) {
		local function
		
		wizard := this.SetupWizard
		
		if this.iTriggerModeActive
			wizard.toggleTriggerDetector()
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		LV_GetText(type, row, 3)
		LV_GetText(number, row, 4)
		
		switch type {
			case translate(k2WayToggleType):
				callback := ObjBindMethod(this, "registerHotkey", k2WayToggleType . "." . number, row, true)
			case translate(kDialType):
				callback := ObjBindMethod(this, "registerHotkey", kDialType . "." . number, row, true)
			case translate(k1WayToggleType):
				callback := ObjBindMethod(this, "registerHotkey", k1WayToggleType . "." . number, row, false)
			case translate(kButtonType):
				callback := ObjBindMethod(this, "registerHotkey", kButtonType . "." . number, row, false)
		}
		
		this.iTriggerModeActive := true
		
		wizard.toggleTriggerDetector(callback)
		
		SetTimer stopTriggerDetector, 100
	}
	
	registerHotKey(function, row, firstHotkey, hotkey) {
		local controller
		local number
		
		wizard := this.SetupWizard
			
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		if (firstHotkey == true) {
			callback := ObjBindMethod(this, "registerHotkey", function, row, hotkey)
		
			wizard.toggleTriggerDetector()
			
			Sleep 2000
			
			wizard.toggleTriggerDetector(callback)
			
			return
		}
		else if (firstHotkey != false) {
			this.iFunctionTriggers[function] := [firstHotkey, hotkey]
		
			hotkey := firstHotkey . " | " . hotkey
		}
		else
			this.iFunctionTriggers[function] := [hotkey]
		
		this.iTriggerModeActive := false
		
		wizard.toggleTriggerDetector()
		
		this.loadFunctions(readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini"))
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		LV_Modify(row, "Vis")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; CommandsStepWizard                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CommandsStepWizard extends StepWizard {
	iPendingFunctionRegistration := false
	iButtonBoxPreviews := []
	iButtonBoxPreviewCenterY := 0
	
	iCommandsListView := false
	
	iCommands := {}
	iFunctions := {}
	
	CommandsListView[] {
		Get {
			return this.iCommandsListView
		}
	}
	
	reset() {
		base.reset()
		
		this.iCommandsListView := false
		
		this.clearCommands()
		this.clearCommandFunctions()
		
		this.closeButtonBoxes()
	}
	
	showPage(page) {
		base.showPage(page)

		this.loadCommands(true)
		
		this.openButtonBoxes()
	}
	
	hidePage(page) {
		if base.hidePage(page) {
			this.closeButtonBoxes()
		
			this.saveCommands()
			
			return true
		}
		else
			return false
	}
	
	loadCommands(load := false) {
		Throw "Virtual method CommandsStepWizard.loadCommands must be implemented in a subclass..."
	}
	
	saveCommands() {
		Throw "Virtual method CommandsStepWizard.saveCommands must be implemented in a subclass..."
	}
	
	setCommandsListView(commandsListView) {
		this.iCommandsListView := commandsListView
	}
	
	setCommandFunction(command, functionDescriptor) {
		this.iFunctions[command] := functionDescriptor
	}
	
	getCommandFunction(command) {
		return (this.iFunctions.HasKey(command) ? this.iFunctions[command] : false)
	}
	
	clearCommandFunctions() {
		this.iFunctions := {}
	}
	
	setCommand(row, command, commandDescriptor) {
		this.iCommands[row] := command
		this.iCommands[command] := commandDescriptor
	}
	
	getCommand(row) {
		return this.iCommands[row]
	}
	
	getCommandDescriptor(row) {
		return this.iCommands[this.getCommand(row)]
	}
	
	clearCommands() {
		this.iCommands := {}
	}
	
	getPreviewCenter(ByRef centerX, ByRef centerY) {
		centerX := false
		centerY := this.iButtonBoxPreviewCenterY
	}
	
	getPreviewMover() {
		return false
	}
	
	openButtonBoxes() {
		configuration := readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini")
		
		controllers := []
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if !inList(controllers, controller[1])
				controllers.Push(controller[1])
		}
		
		for index, controller in controllers {
			preview := new ButtonBoxPreview(this, controller, configuration)
		
			preview.setControlClickHandler(ObjBindMethod(this, "controlClick"))
		
			if (index = 1) {
				SysGet mainScreen, MonitorWorkArea
				
				this.iButtonBoxPreviewCenterY := (mainScreenBottom - Round(preview.Height / 2))
			}
			else
				this.iButtonBoxPreviewCenterY -= Round(preview.Height / 2)
			
			preview.open()
			
			this.iButtonBoxPreviewCenterY -= Round(preview.Height / 2)
			this.iButtonBoxPreviews.Push(preview)
		}
		
		this.iPendingFunctionRegistration := false
	}
	
	closeButtonBoxes() {
		for ignore, preview in this.iButtonBoxPreviews
			preview.close()
		
		this.iButtonBoxPreviews := []
	}
	
	updateCommandFunction(row) {
		SetTimer showFunctionSelectorHint, 100
		
		this.iPendingFunctionRegistration := row
	}
	
	controlClick(element, function, row, column, isEmpty) {
		if this.iPendingFunctionRegistration {
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav
			
			SoundPlay *32
		
			command := this.getCommand(this.iPendingFunctionRegistration)
			commandDescriptor := this.getCommandDescriptor(this.iPendingFunctionRegistration)
			functionType := ConfigurationItem.splitDescriptor(function)[1]
			
			if (((functionType == k2WayToggleType) || (functionType == kDialType)) && (commandDescriptor[2] == "Toggle"))
				function := [function]
			else if (commandDescriptor[2] == "Activate")
				function := [function]
			else {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Increase", "Decrease", "Cancel"]))
				title := translate("Function")
				MsgBox 262179, %title%, % translate("What type of action do you want to trigger for ") . command . translate("?")
				OnMessage(0x44, "")
				
				currentFunction := this.getCommandFunction(command)
				
				IfMsgBox Cancel
					function := false
					
				IfMsgBox Yes
				{
					if currentFunction {
						if (currentFunction.Length() == 1)
							function := [function, ""]
						else {
							currentFunction[1] := function
							
							function := currentFunction
						}
					}
					else
						function := [function, ""]
				}
				
				IfMsgBox No
				{
					if currentFunction {
						if (currentFunction.Length() == 1)
							function := ["", function]
						else {
							currentFunction[2] := function
							
							function := currentFunction
						}
					}
					else
						function := ["", function]
				}
			}

			if function {
				this.setCommandFunction(command, function)
				
				this.loadCommands()
				
				window := this.Window
				
				Gui %window%:Default
				Gui ListView, % this.CommandsListView
		
				LV_Modify(this.iPendingFunctionRegistration, "Vis")
			}
		}

		SetTimer showFunctionSelectorHint, Off
		
		ToolTip, , , 1
		
		this.iPendingFunctionRegistration := false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SimulatorsStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorDropDown

class SimulatorsStepWizard extends CommandsStepWizard {
	iSimulators := []
	iCurrentSimulator := false
	
	Pages[] {
		Get {
			wizard := this.SetupWizard
			
			for ignore, simulator in this.Definition
				if wizard.isApplicationSelected(simulator)
					return 1
				
			return 0
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static commandsInfoText
		
		labelY := y
		
		window := this.Window
		
		Gui %window%:Default
		
		commandsIconHandle := false
		commandsIconLabelHandle := false
		commandsListViewHandle := false
		commandsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 5
		
		Gui %window%:Font, s12 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDcommandsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDcommandsLabelHandle Hidden Section, % translate("Controller Assignments for Simulators")
		
		Gui %window%:Font, s9 Norm, Arial
		
		secondX := x + 80
		secondWidth := 160
		
		simulatorLabelHandle := false
		simulatorDropDownHandle := false
		
		Gui %window%:Add, Text, x%x% yp+33 w105 h23 +0x200 HWNDsimulatorLabelHandle Hidden, % translate("Simulator")
		Gui %window%:Add, DropDownList, x%secondX% yp w%secondWidth% Choose%chosen% HWNDsimulatorDropDownHandle gchooseSimulator vsimulatorDropDown Hidden
		
		listX := x + 250
		listWidth := width - 250
		Gui Add, ListView, x%listX% ys+33 w%listWidth% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDcommandsListViewHandle gupdateSimulatorCommandFunction Hidden, % values2String("|", map(["Mode", "Command / Setting", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Simulators", "Simulators.Commands.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h135 HWNDcommandsInfoTextHandle VcommandsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		commandsInfoText.Navigate("about:blank")
		commandsInfoText.Document.Write(html)
		
		this.setCommandsListView(commandsListViewHandle)
		
		this.registerWidgets(1, commandsIconHandle, commandsLabelHandle, commandsListViewHandle, commandsInfoTextHandle, simulatorLabelHandle, simulatorDropDownHandle)
	}
	
	updateState() {
		base.updateState()
		
		wizard := this.SetupWizard
		simulators := []
		
		for ignore, simulator in this.Definition
			if wizard.isApplicationSelected(simulator)
				simulators.Push(simulator)
			
		this.iSimulators := simulators
	}
	
	showPage(page) {
		chosen := (this.iSimulators.Length() > 0) ? 1 : 0
		
		this.iCurrentSimulator := ((chosen > 0) ? this.iSimulators[chosen] : false)
		
		base.showPage(page)
		
		GuiControl, , simulatorDropDown, % "|" . values2String("|", this.iSimulators*)
		GuiControl Choose, simulatorDropDown, % chosen
	}
	
	chooseSimulator() {
		this.saveCommands()
		
		GuiControlGet simulatorDropDown
		
		this.iCurrentSimulator := simulatorDropDown
		
		this.loadCommands(simulatorDropDown, true)
	}
	
	loadCommands(load := false) {
		if this.iCurrentSimulator
			this.loadSimulatorCommands(this.iCurrentSimulator, load)
	}
	
	saveCommands() {
		if this.iCurrentSimulator
			this.saveSimulatorCommands(this.iCurrentSimulator)
	}
	
	loadSimulatorCommands(simulator, load := false) {
		local function
		
		window := this.Window
		wizard := this.SetupWizard
		
		if load
			this.clearCommandFunctions()
		
		this.clearCommands()
		
		Gui %window%:Default
		
		Gui ListView, % this.CommandsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
		
		LV_Delete()
		
		lastMode := false
		count := 1
		
		for ignore, mode in ["Pitstop", "Assistant"]
			for ignore, command in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Commands.Assistant" : ("Simulators.Settings.Pitstop." . code))) {
				first := (mode != lastMode)
				lastMode := mode
				
				if wizard.simulatorCommandAvailable(simulator, mode, command) {
					if load {
						function := wizard.getSimulatorCommandFunction(simulator, mode, command)
						
						if (function != "")
							this.setCommandFunction(command, (IsObject(function) ? function : Array(function)))
					}
					
					subCommand := ConfigurationItem.splitDescriptor(command)
				
					if (subCommand[1] = "InformationRequest") {
						subCommand := subCommand[2]
						
						isInformationRequest := true
					}
					else {
						subCommand := subCommand[1]
						
						isInformationRequest := false
					}
					
					label := getConfigurationValue(pluginLabels, code, subCommand . ".Toggle", kUndefined)
					
					if (label == kUndefined) {
						label := getConfigurationValue(pluginLabels, code, subCommand . ".Activate")
		
						this.setCommand(count, command, [isInformationRequest, "Activate"])
						
						isBinary := false
					}
					else {
						this.setCommand(count, command, [isInformationRequest, "Toggle", "Increase", "Decrease"])
						
						isBinary := true
					}
					
					function := this.getCommandFunction(command)
					
					if function {
						if (function.Length() == 1)
							function := (!isBinary ? function[1] : ("+/-: " . function[1]))
						else
							function := ("+: " . function[1] . " | -: " . function[2])
					}
					else
						function := ""
					
					LV_Add("", (first ? mode : ""), subCommand, label, function)
					
					count += 1
				}
			}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr")
	}
	
	saveSimulatorCommands(simulator) {
		local function
		
		wizard := this.SetupWizard
		code := string2Values("|", getConfigurationValue(wizard.Definition, "Applications.Simulators", simulator))[1]
		
		for ignore, mode in ["Pitstop", "Assistant"] {
			modeFunctions := {}
		
			for ignore, command in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Commands.Assistant" : ("Simulators.Settings.Pitstop." . code)))				
				if wizard.simulatorCommandAvailable(simulator, mode, command) {
					function := this.getCommandFunction(command)
					
					if function
						modeFunctions[command] := function
				}
			
			wizard.setSimulatorCommandFunctions(simulator, mode, modeFunctions)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; AssistantsStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global assistantDropDown

class AssistantsStepWizard extends CommandsStepWizard {
	iAssistants := []
	iCurrentAssistant := false
	
	Pages[] {
		Get {
			wizard := this.SetupWizard
			
			for ignore, assistant in this.Definition
				if wizard.isModuleSelected(assistant)
					return 1
				
			return 0
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static commandsInfoText
		
		labelY := y
		
		window := this.Window
		
		Gui %window%:Default
		
		commandsIconHandle := false
		commandsIconLabelHandle := false
		commandsListViewHandle := false
		commandsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 5
		
		Gui %window%:Font, s12 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDcommandsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h30 HWNDcommandsLabelHandle Hidden Section, % translate("Controller Assignments for Assistants")
		
		Gui %window%:Font, s9 Norm, Arial
		
		secondX := x + 80
		secondWidth := 160
		
		assistantLabelHandle := false
		assistantDropDownHandle := false
		
		Gui %window%:Add, Text, x%x% yp+33 w105 h23 +0x200 HWNDassistantLabelHandle Hidden, % translate("Assistant")
		Gui %window%:Add, DropDownList, x%secondX% yp w%secondWidth% Choose%chosen% HWNDassistantDropDownHandle gchooseAssistant vassistantDropDown Hidden
		
		listX := x + 250
		listWidth := width - 250
		Gui Add, ListView, x%listX% ys+33 w%listWidth% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDcommandsListViewHandle gupdateAssistantCommandFunction Hidden, % values2String("|", map(["Command", "Label", "Function"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Assistants", "Assistants.Commands.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h135 HWNDcommandsInfoTextHandle VcommandsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		commandsInfoText.Navigate("about:blank")
		commandsInfoText.Document.Write(html)
		
		this.setCommandsListView(commandsListViewHandle)
		
		this.registerWidgets(1, commandsIconHandle, commandsLabelHandle, commandsListViewHandle, commandsInfoTextHandle, assistantLabelHandle, assistantDropDownHandle)
	}
	
	updateState() {
		base.updateState()
		
		wizard := this.SetupWizard
		assistants := []
		
		for ignore, assistant in this.Definition
			if wizard.isModuleSelected(assistant)
				assistants.Push(assistant)
			
		this.iAssistants := assistants
	}
	
	showPage(page) {
		chosen := (this.iAssistants.Length() > 0) ? 1 : 0
		
		this.iCurrentAssistant := ((chosen > 0) ? this.iAssistants[chosen] : false)
		
		base.showPage(page)
		
		GuiControl, , assistantDropDown, % "|" . values2String("|", this.iAssistants*)
		GuiControl Choose, assistantDropDown, % chosen
	}
	
	chooseAssistant() {
		this.saveCommands()
		
		GuiControlGet assistantDropDown
		
		this.iCurrentAssistant := assistantDropDown
		
		this.loadCommands(assistantDropDown, true)
	}
	
	loadCommands(load := false) {
		if this.iCurrentAssistant
			this.loadAssistantCommands(this.iCurrentAssistant, load)
	}
	
	saveCommands() {
		if this.iCurrentAssistant
			this.saveAssistantCommands(this.iCurrentAssistant)
	}
	
	loadAssistantCommands(assistant, load := false) {
		local function
		
		window := this.Window
		wizard := this.SetupWizard
		
		if load
			this.clearCommandFunctions()
		
		this.clearCommands()
		
		Gui %window%:Default
		
		Gui ListView, % this.CommandsListView
		
		pluginLabels := readConfiguration(kUserTranslationsDirectory . "Controller Plugin Labels." . getLanguage())
		
		LV_Delete()
		
		count := 1
		
		for ignore, command in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Assistants", "Assistants.Commands")) {
			if wizard.assistantCommandAvailable(assistant, command) {
				if load {
					function := wizard.getAssistantCommandFunction(assistant, command)
					
					if (function != "")
						this.setCommandFunction(command, (IsObject(function) ? function : Array(function)))
				}
				
				subCommand := ConfigurationItem.splitDescriptor(command)
			
				if (subCommand[1] = "InformationRequest") {
					subCommand := subCommand[2]
					
					isInformationRequest := true
				}
				else {
					subCommand := subCommand[1]
					
					isInformationRequest := false
				}
				
				label := getConfigurationValue(pluginLabels, assistant, subCommand . ".Toggle", kUndefined)
				
				if (label == kUndefined) {
					label := getConfigurationValue(pluginLabels, assistant, subCommand . ".Activate")
	
					this.setCommand(count, command, [isInformationRequest, "Activate"])
					
					isBinary := false
				}
				else {
					this.setCommand(count, command, [isInformationRequest, "Toggle", "Increase", "Decrease"])
					
					isBinary := true
				}
				
				function := this.getCommandFunction(command)
				
				if function {
					if (function.Length() == 1)
						function := (!isBinary ? function[1] : ("+/-: " . function[1]))
					else
						function := ("+: " . function[1] . " | -: " . function[2])
				}
				else
					function := ""
				
				LV_Add("", subCommand, label, function)
				
				count += 1
			}
		}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
	}
	
	saveAssistantCommands(assistant) {
		local function
		
		wizard := this.SetupWizard
		functions := {}
		
		for ignore, command in string2Values(",", getConfigurationValue(wizard.Definition, "Setup.Assistants", "Assistants.Commands"))				
			if wizard.assistantCommandAvailable(assistant, command) {
				function := this.getCommandFunction(command)
				
				if function
					functions[command] := function
			}
		
		wizard.setAssistantCommandFunctions(assistant, functions)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

previousPage() {
	SetupWizard.Instance.previousPage()
}

nextPage() {
	SetupWizard.Instance.nextPage()
}

chooseLanguage() {
	GuiControlGet languageDropDown
	
	languages := string2Values("|", getConfigurationValue(SetupWizard.Instance.Definition, "Setup", "Languages"))
	
	for code, language in availableLanguages()
		if (language = languageDropDown) {
			setLanguage(code)
			
			vResult := kLanguage
			
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

updateSelectedModules() {
	SetupWizard.Instance.StepWizards["Modules"].updateSelectedModules()
}

updateSelectedApplications() {
	wizard := SetupWizard.Instance
	
	wizard.StepWizards["Applications"].updateSelectedApplications(wizard.Page)
}

installSoftware() {
	local stepWizard := SetupWizard.Instance.StepWizards["Installation"]
	
	definition := stepWizard.Definition
	
	stepWizard.installSoftware(definition[StrReplace(A_GuiControl, "installButton", "")])
}

locateSoftware() {
	wizard := SetupWizard.Instance.StepWizards["Installation"]
	
	definition := wizard.Definition
	name := definition[StrReplace(A_GuiControl, "locateButton", "")]
	
	protectionOn()
	
	try {
		title := substituteVariables(translate("Select %name% executable..."), {name: name})
		
		FileSelectFile file, 1, , %title%, Executable (*.exe)
		
		if (file != "")
			wizard.locateSoftware(name, file)
	}
	finally {
		protectionOff()
	}
}

updateFunctionTriggers() {
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
	
	if (A_GuiEvent = "DoubleClick") {
		if (A_EventInfo > 0) {
			wizard := SetupWizard.Instance.StepWizards["Button Box"]
		
			wizard.updateFunctionTriggers(A_EventInfo)
		}
	}
	else if (A_GuiEvent = "RightClick") {
		if (A_EventInfo > 0) {
			row := A_EventInfo
			
			wizard := SetupWizard.Instance.StepWizards["Button Box"]
		
			curCoordMode := A_CoordModeMouse

			LV_GetText(control, row, 2)
			LV_GetText(number, row, 4)
			
			menuItem := ConfigurationItem.descriptor(control, number)
			
			try {
				Menu ContextMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			window := SetupWizard.Instance.WizardWindow
			
			Gui %window%:Default
			
			Menu ContextMenu, Add, %menuItem%, menuIgnore
			Menu ContextMenu, Disable, %menuItem%
			Menu ContextMenu, Add
			
			menuItem := translate("Press the trigger(s)...")
			handler := ObjBindMethod(wizard, "updateFunctionTriggers", row)
			
			Menu ContextMenu, Add, %menuItem%, %handler%
			
			Menu ContextMenu, Show
		}
	}
	
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

stopTriggerDetector() {
	wizard := SetupWizard.Instance.StepWizards["Button Box"]
	
	if (!wizard.iTriggerModeActive || !vShowTriggerDetector) {
		SetTimer stopTriggerDetector, Off
	
		wizard.iTriggerModeActive := false
	}
	else if GetKeyState("Esc", "P") {
		wizard.SetupWizard.toggleTriggerDetector()
	
		wizard.iTriggerModeActive := false
		
		SetTimer stopTriggerDetector, Off
	}
}

updateSimulatorCommandFunction() {
	updateCommandFunction(SetupWizard.Instance.StepWizards["Simulators"])
}

updateAssistantCommandFunction() {
	updateCommandFunction(SetupWizard.Instance.StepWizards["Assistants"])
}

updateCommandFunction(wizard) {
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
	
	if (A_GuiEvent = "DoubleClick") {
		if (A_EventInfo > 0)
			wizard.updateCommandFunction(A_EventInfo)
	}
	else if (A_GuiEvent = "RightClick") {
		if (A_EventInfo > 0) {
			row := A_EventInfo
			
			curCoordMode := A_CoordModeMouse

			LV_GetText(command, row, 2)
			LV_GetText(label, row, 3)
			
			menuItem := (command . ": " . label)
			
			try {
				Menu ContextMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			window := wizard.Window
			
			Gui %window%:Default
			
			Menu ContextMenu, Add, %menuItem%, menuIgnore
			Menu ContextMenu, Disable, %menuItem%
			Menu ContextMenu, Add
			
			menuItem := translate("Please select a controller function...")
			handler := ObjBindMethod(wizard, "updateCommandFunction", row)
			
			Menu ContextMenu, Add, %menuItem%, %handler%
			
			Menu ContextMenu, Show
		}
	}
	
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

showFunctionSelectorHint() {
	if GetKeyState("Esc", "P") {
		SetTimer showFunctionSelectorHint, Off
		
		SetupWizard.Instance.StepWizards["Simulators"].iPendingFunctionRegistration := false
		
		ToolTip, , , 1
	}
	else {
		hint := translate("Please select a controller function...")
		
		ToolTip %hint%, , , 1
	}
}

chooseSimulator() {
	SetupWizard.Instance.StepWizards["Simulators"].chooseSimulator()
}

chooseAssistant() {
	SetupWizard.Instance.StepWizards["Assistants"].chooseAssistant()
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
	Loop Reg, %collection%, R
		if (A_LoopRegName = filterName) {
			RegRead candidate
		
			if (InStr(candidate, filterValue) = 1) {
				RegRead value, %A_LoopRegKey%\%A_LoopRegSubKey%, %valueName%
			
				return value
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
						RegRead value, % substituteVariables(StrReplace(locator, "RegistryExist:", ""))
					
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
						
						RegRead installPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam, InstallPath
						
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
		
		ExitApp
	}
}

saveConfiguration(configurationFile, wizard) {
	configuration := newConfiguration()

	wizard.saveToConfiguration(configuration)

	configFile := getFileName(configurationFile, kUserConfigDirectory)
	
	if FileExist(configFile)
		FileMove %configFile%, % configFile . ".bak"
	
	writeConfiguration(configurationFile, configuration)
}

initializeSimulatorSetup() {
	icon := kIconsDirectory . "Wand.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Setup
	
	FileCreateDir %kUserHomeDirectory%Install
	
	protectionOn()
	
	try {
		definition := readConfiguration(kResourcesDirectory . "Setup\Simulator Setup.ini")
		
		wizard := new SetupWizard(kSimulatorConfiguration, definition)
		
		wizard.registerStepWizard(new StartStepWizard(wizard, "Start", kSimulatorConfiguration))
		wizard.registerStepWizard(new ModulesStepWizard(wizard, "Modules", kSimulatorConfiguration))
		wizard.registerStepWizard(new InstallationStepWizard(wizard, "Installation", kSimulatorConfiguration))
		wizard.registerStepWizard(new ApplicationsStepWizard(wizard, "Applications", kSimulatorConfiguration))
		wizard.registerStepWizard(new ButtonBoxStepWizard(wizard, "Button Box", kSimulatorConfiguration))
		wizard.registerStepWizard(new SimulatorsStepWizard(wizard, "Simulators", kSimulatorConfiguration))
		wizard.registerStepWizard(new AssistantsStepWizard(wizard, "Assistants", kSimulatorConfiguration))
	}
	finally {
		protectionOff()
	}
}

startupSimulatorSetup() {
	wizard := SetupWizard.Instance
	
	wizard.loadDefinition()
	
restart:
	wizard.createGui(wizard.Configuration)
	
	wizard.startSetup()
	
	done := false
	saved := false

	wizard.show()
	
	try {
		Loop {
			Sleep 200
			
			if (vResult == kCancel)
				done := true
			else if (vResult == kOk) {
				saved := true
				done := true
				
				saveConfiguration(kSimulatorConfigurationFile, wizard)
			}
			else if (vResult == kLanguage) {
				done := true
			}
		} until done
	}
	finally {
		wizard.hide()
	}
	
	if (vResult == kLanguage) {
		vResult := false
		
		wizard.close()
		wizard.reset()
		
		Goto restart
	}
	else {
		if saved
			ExitApp 1
		else
			ExitApp 0
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorSetup()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

; #Include ..\Plugins\Setup Plugins.ahk
; #Include %A_MyDocuments%\Simulator Controller\Plugins\Setup Plugins.ahk


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorSetup()