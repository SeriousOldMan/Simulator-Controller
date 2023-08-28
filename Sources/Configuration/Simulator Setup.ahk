;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Setup Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Configuration Wand.ico
;@Ahk2Exe-ExeName Simulator Setup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\JSON.ahk"
#Include "..\Libraries\RuleEngine.ahk"
#Include "Libraries\SettingsEditor.ahk"
#Include "Libraries\ConfigurationEditor.ahk"
#Include "Libraries\ControllerActionsEditor.ahk"
#Include "Libraries\ControllerEditor.ahk"
#Include "..\Plugins\Voice Control Configuration Plugin.ahk"
#Include "..\Plugins\Race Engineer Configuration Plugin.ahk"
#Include "..\Plugins\Race Strategist Configuration Plugin.ahk"
#Include "..\Plugins\Race Spotter Configuration Plugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "ok"
global kCancel := "cancel"
global kNext := "next"
global kPrevious := "previous"
global kLanguage := "language"


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kDebugOff := 0
global kDebugKnowledgeBase := 1
global kDebugRules := 2


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Preset                                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Preset {
	iActive := true

	Active {
		Get {
			return this.iActive
		}

		Set {
			return (this.iActive := value)
		}
	}

	Name {
		Get {
			throw "Virtual property Preset.Name must be implemented in a subclass..."
		}
	}

	getArguments() {
		throw "Virtual method Preset.getArguments must be implemented in a subclass..."
	}

	install(wizard, edit := true) {
	}

	uninstall(wizard) {
	}

	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
	}

	patchSimulatorSettings(wizard, simulatorSettings) {
	}

	patchButtonBoxConfiguration(wizard, buttonBoxConfiguration) {
	}

	patchStreamDeckConfiguration(wizard, streamDeckConfiguration) {
	}

	finalizeConfiguration(wizard) {
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupWizard                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetupWizard extends ConfiguratorPanel {
	iDebug := kDebugOff

	iHelpWindow := false

	iProgressCount := false
	iWorking := false
	iPageSwitch := false
	iSettingsOpen := false
	iResult := false

	iStepWizards := CaseInsenseMap()
	iWizards := []

	iDefinition := false
	iKnowledgeBase := false

	iCount := 0

	iSteps := CaseInsenseWeakMap()
	iStep := 0
	iPage := 0

	iQuickSetup := true

	iPresets := false
	iInitialize := false

	iCachedActions := CaseInsenseMap()

	iHTMLResizer := false

	class SetupWindow extends Window {
		iSetupWizard := false
		iResizeEnabled := true

		SetupWizard {
			Get {
				return this.iSetupWizard
			}
		}

		Resizeable {
			Get {
				return (this.iResizeEnabled ? super.Resizeable : false)
			}

			Set {
				if value {
					this.iResizeEnabled := true

					return super.Resizeable
				}
				else
					return (this.iResizeEnabled := false)
			}
		}

		__New(wizard) {
			this.iSetupWizard := wizard

			super.__New({Descriptor: "Simulator Setup", Closeable: true, Resizeable: "Deferred"})
		}

		DefineResizeRule(control, rule) {
			if this.Resizeable
				super.DefineResizeRule(control, rule)
		}

		Close(*) {
			if this.SetupWizard.finishSetup(false)
				ExitApp(0)
			else
				return true
		}
	}

	class HTMLResizer extends Window.Resizer {
		iRedraw := false

		iHTMLViewer := []

		HTMLViewer {
			Get {
				return this.iHTMLViewer
			}

			Set {
				return (this.iHTMLViewer := value)
			}
		}

		__New(window, viewer*) {
			this.iHTMLViewer := viewer

			super.__New(window)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViewer"), 100, kInterruptPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RedrawHTMLViewer() {
			if this.iRedraw {
				local ignore, button, viewer

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button, "P")
						return Task.CurrentTask

				this.iRedraw := false

				for ignore, viewer in this.HTMLViewer
					if viewer.Visible
						if viewer.HasProp("Resized")
							viewer.Resized()
						else
							viewer.Value.document.location.reload()
			}

			return Task.CurrentTask
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	WizardWindow {
		Get {
			return this.Window
		}
	}

	HelpWindow {
		Get {
			return this.iHelpWindow
		}
	}

	Result {
		Get {
			return this.iResult
		}

		Set {
			return (this.iResult := value)
		}
	}

	ProgressCount {
		Get {
			return SetupWizard.sProgressCount
		}

		Set {
			return (SetupWizard.sProgressCount := value)
		}
	}

	Working {
		Get {
			return this.iWorking
		}

		Set {
			return (this.iWorking := value)
		}
	}

	PageSwitch {
		Get {
			return this.iPageSwitch
		}

		Set {
			return (this.iPageSwitch := value)
		}
	}

	SettingsOpen {
		Get {
			return this.iSettingsOpen
		}

		Set {
			return (this.iSettingsOpen := value)
		}
	}

	Definition {
		Get {
			return this.iDefinition
		}
	}

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	Count {
		Get {
			return this.iCount
		}
	}

	Steps[step?] {
		Get {
			if isSet(step)
				return (this.iSteps.Has(step) ? this.iSteps[step] : false)
			else
				return this.iSteps
		}

		Set {
			return (isSet(step) ? (this.iSteps[step] := value) : (this.iSteps := value))
		}
	}

	StepWizards[descriptor?] {
		Get {
			if isSet(descriptor)
				return (this.iStepWizards.Has(descriptor) ? this.iStepWizards[descriptor] : false)
			else
				return this.iStepWizards
		}

		Set {
			return this.iStepWizards[descriptor] := value
		}
	}

	Step {
		Get {
			return this.iStep
		}
	}

	Page {
		Get {
			return this.iPage
		}
	}

	QuickSetup {
		Get {
			return (this.iQuickSetup && (this.isQuickSetupAvailable() || (this.iQuickSetup = "Force")))
		}

		Set {
			return (this.iQuickSetup := value)
		}
	}

	Initialize {
		Get {
			return this.iInitialize
		}
	}

	Presets[index?] {
		Get {
			if !this.iPresets
				this.iPresets := this.loadPresets()

			return (isSet(index) ? this.iPresets[index] : this.iPresets)
		}
	}

	__New(configuration, definition) {
		this.iDefinition := definition

		super.__New(configuration)

		SetupWizard.Instance := this
	}

	createKnowledgeBase(facts := false) {
		local rules, productions, reductions, engine

		rules := FileRead(kResourcesDirectory . "Setup\Simulator Setup.rules")

		productions := false
		reductions := false

		RuleCompiler().compileRules(rules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, facts)

		return KnowledgeBase(engine, engine.createFacts(), engine.createRules())
	}

	addRule(rule) {
		this.KnowledgeBase.addRule(RuleCompiler().compileRule(rule))
	}

	loadDefinition(definition := false) {
		local knowledgeBase, stepWizard, count, descriptor, step, stepDefinition, msgResult, initialize
		local ignore, fileName, language, rootDirectory, section, keyValues, key, value

		if !definition
			definition := this.Definition

		this.iKnowledgeBase := this.createKnowledgeBase()

		this.iSteps := CaseInsenseWeakMap()
		this.iStep := 0
		this.iPage := 0

		count := 0

		for descriptor, step in getMultiMapValues(definition, "Setup.Steps") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			stepWizard := this.StepWizards[step]

			if stepWizard {
				this.Steps[step] := stepWizard
				this.Steps[descriptor[2]] := stepWizard
				this.Steps[stepWizard] := descriptor[2]

				count := Max(count, descriptor[2])
			}
		}

		loop count {
			step := this.Steps[A_Index]

			this.ProgressCount += 2

			showProgress({progress: this.ProgressCount})

			if step {
				stepDefinition := readMultiMap(kResourcesDirectory . "Setup\Definitions\" . step.Step . " Step.ini")

				setMultiMapValues(definition, "Setup." . step.Step, getMultiMapValues(stepDefinition, "Setup." . step.Step))

				for language, ignore in availableLanguages()
					for ignore, rootDirectory in [kResourcesDirectory . "Setup\Translations\", kUserTranslationsDirectory . "Setup\"]
						if FileExist(rootDirectory . step.Step . " Step." . language)
							for section, keyValues in readMultiMap(rootDirectory . step.Step . " Step." . language)
								for key, value in keyValues
									setMultiMapValue(definition, section, key, value)

				step.loadDefinition(definition, getMultiMapValue(definition, "Setup." . step.Step, step.Step . ".Definition", ""))
			}
		}

		this.iCount := count

		if (GetKeyState("Ctrl") && GetKeyState("Shift")) {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you really want to start with a fresh configuration?"), translate("Setup"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				initialize := true
			else
				initialize := false
		}
		else
			initialize  := false

		showProgress({progress: ++this.ProgressCount, message: translate("Initializing AI Kernel...")})

		if initialize {
			for ignore, fileName in ["Button Box Configuration.ini", "Stream Deck Configuration.ini", "Voice Control Configuration.ini"
								   , "Race Engineer Configuration.ini", "Race Strategist Configuration.ini", "Simulator Settings.ini"]
				deleteFile(kUserHomeDirectory . "Setup\" . fileName)

			this.KnowledgeBase.addFact("Initialize", true)
		}
		else if !this.loadKnowledgeBase() {
			this.KnowledgeBase.addFact("Initialize", true)

			initialize := true
		}

		this.iInitialize := initialize

		if initialize {
			this.addPatchFile("Settings", kUserHomeDirectory . "Setup\Settings Patch.ini")
			this.addPatchFile("Configuration", kUserHomeDirectory . "Setup\Configuration Patch.ini")
		}

		showProgress({progress: ++this.ProgressCount, message: translate("Starting AI Kernel...")})

		this.KnowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)
	}

	registerStepWizard(stepWizard) {
		this.iWizards.Push(stepWizard)

		this.StepWizards[stepWizard.Step] := stepWizard
	}

	unregisterStepWizard(descriptorOrWizard) {
		local stepWizard, descriptor

		for descriptor, stepWizard in this.StepWizards
			if ((descriptor = descriptorOrWizard) || (stepWizard = descriptorOrWizard)) {
				this.StepWizards.Delete(descriptor)

				break
			}
	}

	getWorkArea(&x, &y, &width, &height) {
		x := 16
		y := 60
		width := 684
		height := 470
	}

	createGui(configuration) {
		local stepWizard, languages, choices, chosen, code, language, html

		static wizardGui
		static helpGui

		cancelSetup(*) {
			if this.finishSetup(false)
				ExitApp(0)
		}

		firstPage(*) {
			this.firstPage()
		}

		previousPage(*) {
			this.previousPage()
		}

		nextPage(*) {
			this.nextPage()
		}

		lastPage(*) {
			this.lastPage()
		}

		chooseLanguage(*) {
			local code, language

			for code, language in availableLanguages()
				if (language = wizardGui["languageDropDown"].Text) {
					if this.finishSetup(false) {
						setLanguage(code)

						this.Result := kLanguage
					}
					else
						for code, language in availableLanguages()
							if (code = getLanguage()) {
								wizardGui["languageDropDown"].Choose(A_Index)

								break
							}

					return
				}
		}

		finishSetup(finish := false, save := false, *) {
			local msgResult

			if (finish = "Finish") {
				if !this.SettingsOpen
					Task.startTask(finishSetup.Bind("Finish", save), 200)
				else {
					; Wait for settings editor to be fully open...

					Task.yield()

					Sleep(1000)

					if this.finishSetup(save)
						ExitApp(0)
				}
			}
			else {
				this.WizardWindow.Show()

				OnMessage(0x44, translateYesNoButtons)
				msgResult := MsgBox((translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the `"Simulator Controller\Config`" folder in your user `"Documents`" folder.")), translate("Setup"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes")
					save := true
				else
					save := false

				Task.startTask(finishSetup.Bind("Finish", save), 200)
			}
		}

		wizardGui := SetupWizard.SetupWindow(this)

		this.Window := wizardGui

		wizardGui.SetFont("s10 Bold", "Arial")

		wizardGui.Add("Text", "w684 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(wizardGui, "Simulator Setup"))

		wizardGui.SetFont("s9 Norm", "Arial")

		wizardGui.Add("Documentation", "x258 YP+20 w184 H:Center Center", translate("Setup && Configuration")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#setup")

		wizardGui.Add("Text", "x8 yp+20 w700 0x10 W:Grow")

		wizardGui.SetFont("s8 Norm", "Arial")

		wizardGui.Add("Button", "x16 y540 w30 h30 Y:Move Disabled VfirstPageButton").OnEvent("Click", firstPage)
		setButtonIcon(wizardGui["firstPageButton"], kIconsDirectory . "First.ico", 1, "L2 T2 R2 B2 H24 W24")
		wizardGui.Add("Button", "x48 y540 w30 h30 Y:Move Disabled VpreviousPageButton").OnEvent("Click", previousPage)
		setButtonIcon(wizardGui["previousPageButton"], kIconsDirectory . "Previous.ico", 1, "L2 T2 R2 B2 H24 W24")
		wizardGui.Add("Button", "x638 y540 w30 h30 Y:Move X:Move Disabled VnextPageButton").OnEvent("Click", nextPage)
		setButtonIcon(wizardGui["nextPageButton"], kIconsDirectory . "Next.ico", 1, "L2 T2 R2 B2 H24 W24")
		wizardGui.Add("Button", "x670 y540 w30 h30 Y:Move X:Move Disabled VlastPageButton").OnEvent("Click", lastPage)
		setButtonIcon(wizardGui["lastPageButton"], kIconsDirectory . "Last.ico", 1, "L2 T2 R2 B2 H24 W24")

		languages := string2Values("|", getMultiMapValue(this.Definition, "Setup", "Languages"))

		choices := []
		chosen := false

		for code, language in availableLanguages()
			if inList(languages, code) {
				choices.Push(language)

				if (code = getLanguage())
					chosen := choices.Length
			}

		wizardGui.Add("Text", "x8 yp+34 w700 0x10 Y:Move W:Grow")

		wizardGui.Add("Text", "x16 y580 w85 h23 Y:Move +0x200", translate("Language"))
		wizardGui.Add("DropDownList", "x100 y580 w75 Y:Move Choose" . chosen . "  VlanguageDropDown", collect(choices, translate)).OnEvent("Change", chooseLanguage)

		wizardGui.Add("Button", "x535 y580 w80 h23 Y:Move X:Move Disabled VfinishButton", translate("Finish")).OnEvent("Click", finishSetup)
		wizardGui.Add("Button", "x620 y580 w80 h23 Y:Move X:Move", translate("Cancel")).OnEvent("Click", cancelSetup)

		this.iHTMLResizer := SetupWizard.HTMLResizer(wizardGui)

		wizardGui.Add(this.iHTMLResizer)

		helpGui := Window({Descriptor: "Simulator Setup.Help", Resizeable: true, Options: "-MaximizeBox 0x400000"})

		this.iHelpWindow := helpGui

		helpGui.SetFont("s10 Bold", "Arial")

		helpGui.Add("Text", "w350 H:Center Center VstepTitle", translate("Title")).OnEvent("Click", moveByMouse.Bind(helpGui, "Simulator Setup.Help"))

		helpGui.SetFont("s9 Norm", "Arial")

		helpGui.Add("Text", "YP+20 w350 H:Center Center VstepSubtitle", translate("Subtitle"))

		helpGui.Add("Text", "yp+20 w350 0x10 W:Grow")

		helpGui.Add("HTMLViewer", "x12 yp+10 w350 h545 W:Grow H:Grow vinfoViewer")

		html := "<html><head><meta http-equiv=`"X-UA-Compatible`" content=`"IE=Edge`"></head><body style='background-color: #" . helpGui.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

		helpGui["infoViewer"].document.write(html)

		helpGui.Add(SetupWizard.HTMLResizer(helpGui, helpGui["infoViewer"]))

		this.createStepsGui()
	}

	createStepsGui() {
		local x := 0
		local y := 0
		local width := 0
		local height := 0
		local ignore, stepWizard, step

		this.getWorkArea(&x, &y, &width, &height)

		for ignore, stepWizard in this.iWizards {
			step := stepWizard.Step

			this.ProgressCount += 2

			showProgress({progress: this.ProgressCount, message: translate("Creating UI for Step: ")
															   . getMultiMapValue(this.Definition, "Setup." . step, step . ".Name." . getLanguage())
															   . translate("...")})

			stepWizard.createGui(this, x, y, width, height)
		}
	}

	saveToConfiguration(configuration) {
		local stepWizard, ignore

		super.saveToConfiguration(configuration)

		for ignore, stepWizard in this.StepWizards
			stepWizard.saveToConfiguration(configuration)
	}

	reset(show := true) {
		if show
			this.show(true)

		loop this.Count
			if this.Steps.Has(A_Index)
				this.Steps[A_Index].reset()
	}

	setDebug(option, enabled, *) {
		local label := false

		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)

		switch option {
			case kDebugKnowledgeBase:
				label := translate("Debug Knowledgebase")

				if enabled
					this.dumpKnowledgeBase(this.KnowledgeBase)
			case kDebugRules:
				label := translate("Debug Rule System")

				if enabled
					this.dumpRules(this.KnowledgeBase)
		}

		if label
			if enabled
				SupportMenu.Check(label)
			else
				SupportMenu.Uncheck(label)
	}

	toggleDebug(option, *) {
		this.setDebug(option, !this.Debug[option])
	}

	show(reset := false) {
		local wizardWindow := this.WizardWindow
		local helpWindow := this.HelpWindow
		local x, y, w, h, posX

		if getWindowPosition("Simulator Setup.Help", &x, &y)
			helpWindow.Show("x" . x . " y" . y)
		else {
			posX := (Round((A_ScreenWidth - 720 - 400) / 2) + 750)

			helpWindow.Show("x800 x" . posX . " yCenter h610")
		}

		if getWindowSize("Simulator Setup.Help", &w, &h)
			helpWindow.Resize("Initialize", w, h)

		if getWindowPosition("Simulator Setup", &x, &y)
			wizardWindow.Show("x" . x . " y" . y)
		else {
			posX := Round((A_ScreenWidth - 720 - 400) / 2)

			wizardWindow.Show("x" . posX . " yCenter")
		}

		if getWindowSize("Simulator Setup", &w, &h) {
			wizardWindow.Resize("Initialize", w, h)

			Sleep(500)

			this.nextPage()
		}
		else
			this.nextPage()

		loop getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "Simulator Setup", "StartPage", 0)
			this.nextPage()
	}

	hide() {
		this.WizardWindow.Hide()
		this.HelpWindow.Hide()
	}

	close() {
		this.WizardWindow.Destroy()
		this.HelpWindow.Destroy()
	}

	startSetup() {
		local ignore, viewer, viewers

		showProgress({progress: ++this.ProgressCount, message: translate("Initializing Settings && Options...")})

		this.updateState(false)

		this.iStep := false
		this.iPage := false

		showProgress({progress: ++this.ProgressCount, color: "Green", title: translate("Starting Setup Wizard")
					, message: translate("Starting Configuration Engine...")})

		viewers := []

		for ignore, viewer in this.WizardWindow
			if viewer.HasProp("Resized")
				viewers.Push(viewer)

		this.iHTMLResizer.HTMLViewer := viewers
	}

	applyPatches(configuration, patches) {
		local section, values, key, substitution, currentValue, ignore, substitute, addition, deletion, value

		for section, values in patches
			if (InStr(section, "Replace:") == 1) {
				section := Trim(StrReplace(section, "Replace:", ""))

				for key, substitution in values {
					currentValue := getMultiMapValue(configuration, section, key, kUndefined)

					if (currentValue != kUndefined)
						for ignore, substitute in string2Values("|", substitution) {
							substitute := string2Values("->", substitute)
							currentValue := StrReplace(currentValue, substitute[1], substitute[2])

							setMultiMapValue(configuration, section, key, currentValue)
						}
				}
			}
			else if (InStr(section, "Add:") == 1) {
				section := Trim(StrReplace(section, "Add:", ""))

				for key, addition in values {
					currentValue := getMultiMapValue(configuration, section, key, "")

					if !InStr(currentValue, addition)
						setMultiMapValue(configuration, section, key, currentValue . addition)
				}
			}
			else if (InStr(section, "Delete:") == 1) {
				section := Trim(StrReplace(section, "Delete:", ""))

				for key, deletion in values {
					currentValue := getMultiMapValue(configuration, section, key, kUndefined)

					if (currentValue != kUndefined)
						setMultiMapValue(configuration, section, key, StrReplace(currentValue, deletion, ""))
				}
			}
			else
				for key, value in values
					setMultiMapValue(configuration, section, key, value)
	}

	finishSetup(save := true) {
		local preset, window, configuration, settings, ignore, file, startupLink, startupExe
		local buttonBoxConfiguration, streamDeckConfiguration

		if (this.Step && this.Step.hidePage(this.Page)) {
			while this.SettingsOpen {
				Task.yield()

				Sleep(100)
			}

			window := this.WizardWindow

			window.Block()

			this.Control["firstPageButton"].Enabled := false
			this.Control["previousPageButton"].Enabled := false
			this.Control["nextPageButton"].Enabled := false
			this.Control["lastPageButton"].Enabled := false
			this.Control["finishButton"].Enabled := false

			this.Working := true

			try {
				if save {
					configuration := this.getSimulatorConfiguration()

					if FileExist(kUserConfigDirectory . "Simulator Configuration.ini")
						FileMove(kUserConfigDirectory "Simulator Configuration.ini", kUserConfigDirectory "Simulator Configuration.ini.bak", 1)

					if FileExist(kUserConfigDirectory . "Simulator Settings.ini") {
						settings := readMultiMap(kUserConfigDirectory . "Simulator Settings.ini")

						FileMove(kUserConfigDirectory . "Simulator Settings.ini"
							   , kUserConfigDirectory . "Simulator Settings.ini.bak", 1)
					}
					else
						settings := newMultiMap()

					if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
						addMultiMapValues(settings, readMultiMap(kUserHomeDirectory . "Setup\Simulator Settings.ini"))

					for ignore, file in this.getPatchFiles("Configuration")
						if FileExist(file)
							this.applyPatches(configuration, readMultiMap(file))

					for ignore, file in this.getPatchFiles("Settings")
						if FileExist(file)
							this.applyPatches(settings, readMultiMap(file))

					for ignore, preset in this.Presets {
						if preset.Active {
							preset.patchSimulatorConfiguration(this, configuration)
							preset.patchSimulatorSettings(this, settings)
						}
					}

					if (settings.Count > 0)
						writeMultiMap(kUserConfigDirectory . "Simulator Settings.ini", settings)

					writeMultiMap(kUserConfigDirectory . "Simulator Configuration.ini", configuration)

					deleteFile(kTempDirectory . "Simulator Controller.state")

					startupLink := A_Startup . "\Simulator Startup.lnk"

					if getMultiMapValue(configuration, "Configuration", "Start With Windows", false) {
						startupExe := kBinariesDirectory . "Simulator Startup.exe"

						FileCreateShortcut(startupExe, startupLink, kBinariesDirectory)
					}
					else
						deleteFile(startupLink)

					deleteDirectory(kTempDirectory, false)

					if this.isModuleSelected("Controller") {
						if FileExist(kUserConfigDirectory . "Button Box Configuration.ini")
							FileMove(kUserConfigDirectory "Button Box Configuration.ini", kUserConfigDirectory "Button Box Configuration.ini.bak", 1)

						buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

						for ignore, file in this.getPatchFiles("Button Box")
							if FileExist(file)
								this.applyPatches(buttonBoxConfiguration, readMultiMap(file))

						for ignore, preset in this.Presets
							if preset.Active
								preset.patchButtonBoxConfiguration(this, buttonBoxConfiguration)

						writeMultiMap(kUserConfigDirectory . "Button Box Configuration.ini", buttonBoxConfiguration)

						if FileExist(kUserConfigDirectory . "Stream Deck Configuration.ini")
							FileMove(kUserConfigDirectory "Stream Deck Configuration.ini", kUserConfigDirectory "Stream Deck Configuration.ini.bak", 1)

						streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

						for ignore, file in this.getPatchFiles("Stream Deck")
							if FileExist(file)
								this.applyPatches(streamDeckConfiguration, readMultiMap(file))

						for ignore, preset in this.Presets
							if preset.Active
								preset.patchStreamDeckConfiguration(this, streamDeckConfiguration)

						writeMultiMap(kUserConfigDirectory . "Stream Deck Configuration.ini", streamDeckConfiguration)
					}

					for ignore, preset in this.Presets
						if preset.Active
							preset.finalizeConfiguration(this)
				}
			}
			finally {
				this.Working := false
			}

			return true
		}
		else
			return false
	}

	getSimulatorConfiguration() {
		local configuration := newMultiMap()

		this.saveToConfiguration(configuration)

		return configuration
	}

	getFirstPage(&step, &page) {
		step := this.Steps[1]
		page := 1

		return true
	}

	getPreviousPage(&step, &page) {
		local index, candidate

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
				loop {
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

	getNextPage(&step, &page) {
		local count, index, candidate

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

			loop {
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

	getLastPage(&step, &page) {
		step := this.Steps[this.Count]
		page := step.Pages

		return true
	}

	isFirstPage() {
		local step := false
		local page := false

		return !this.getPreviousPage(&step, &page)
	}

	isLastPage() {
		local step := false
		local page := false

		return !this.getNextPage(&step, &page)
	}

	showPage(step, page) {
		local change := (step != this.Step)
		local oldPageSwitch

		this.WizardWindow.Block()

		this.Control["firstPageButton"].Enabled := false
		this.Control["previousPageButton"].Enabled := false
		this.Control["nextPageButton"].Enabled := false
		this.Control["lastPageButton"].Enabled := false
		this.Control["finishButton"].Enabled := false

		oldPageSwitch := this.PageSwitch

		this.PageSwitch := true

		try {
			if this.Step {
				if !this.hidePage(this.Step, this.Page) {
					this.PageSwitch := oldPageSwitch

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
		catch Any as exception {
			logError(exception, true)
		}
		finally {
			this.PageSwitch := oldPageSwitch
		}

		this.updateState()
	}

	hidePage(step, page) {
		try {
			if step.hidePage(page) {
				this.saveKnowledgeBase()

				return true
			}
			else
				return false
		}
		catch Any as exception {
			logError(exception, true)

			return false
		}
	}

	firstPage() {
		local step, page

		try {
			this.Working := true

			try {
				step := false
				page := false

				if this.getFirstPage(&step, &page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	previousPage() {
		local step, page

		try {
			this.Working := true

			try {
				step := false
				page := false

				if this.getPreviousPage(&step, &page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	nextPage() {
		local step, page

		try {
			this.Working := true

			try {
				step := false
				page := false

				if this.getNextPage(&step, &page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	lastPage() {
		local step, page

		try {
			this.Working := true

			try {
				step := false
				page := false

				if this.getLastPage(&step, &page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	updateState(unlock := true) {
		this.KnowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		loop this.Count
			if this.Steps.Has(A_Index)
				this.Steps[A_Index].updateState()

		if (this.WizardWindow && !this.PageSwitch) {
			if this.isFirstPage() {
				this.Control["firstPageButton"].Enabled := false
				this.Control["previousPageButton"].Enabled := false
			}
			else {
				this.Control["firstPageButton"].Enabled := true
				this.Control["previousPageButton"].Enabled := true
			}

			if this.isLastPage() {
				this.Control["nextPageButton"].Enabled := false
				this.Control["lastPageButton"].Enabled := false
				this.Control["finishButton"].Enabled := true
			}
			else {
				this.Control["nextPageButton"].Enabled := true
				this.Control["lastPageButton"].Enabled := !this.QuickSetup
				this.Control["finishButton"].Enabled := false
			}

			if unlock
				this.WizardWindow.Unblock()
		}
	}

	installPreset(preset, edit := true) {
		local knowledgeBase := this.KnowledgeBase
		local count

		preset.install(this, edit)

		count := (knowledgeBase.getValue("Preset.Count", 0) + 1)

		knowledgeBase.addFact("Preset." . count . ".Class", preset.base.__Class)
		knowledgeBase.addFact("Preset." . count . ".Arguments", values2String("###", preset.getArguments()*))

		knowledgeBase.setFact("Preset.Count", count)

		this.iPresets := false

		this.updateState()
	}

	uninstallPreset(preset) {
		local knowledgeBase := this.KnowledgeBase
		local class, arguments, presets, found, cClass, cArguments, index, descriptor

		preset.uninstall(this)

		class := preset.base.__Class
		arguments := values2String("###", preset.getArguments()*)

		presets := []
		found := false

		loop knowledgeBase.getValue("Preset.Count", 0) {
			cClass := knowledgeBase.getValue("Preset." . A_Index . ".Class")
			cArguments := knowledgeBase.getValue("Preset." . A_Index . ".Arguments")

			if (!found && (class = cClass) && (arguments = cArguments))
				found := true
			else
				presets.Push(Array(cClass, cArguments))

			knowledgeBase.removeFact("Preset." . A_Index . ".Class")
			knowledgeBase.removeFact("Preset." . A_Index . ".Arguments")
		}

		for index, descriptor in presets {
			knowledgeBase.addFact("Preset." . index . ".Class", descriptor[1])
			knowledgeBase.addFact("Preset." . index . ".Arguments", descriptor[2])
		}

		knowledgeBase.setFact("Preset.Count", presets.Length)

		this.iPresets := false

		this.updateState()
	}

	loadPresets() {
		local knowledgeBase := this.KnowledgeBase
		local presets := []
		local class, arguments, outerclass

		loop knowledgeBase.getValue("Preset.Count", 0) {
			class := knowledgeBase.getValue("Preset." . A_Index . ".Class")
			arguments := string2Values("###", knowledgeBase.getValue("Preset." . A_Index . ".Arguments"))

			try {
				if InStr(class, ".") {
					class := StrSplit(class, ".")
					outerClass := class[1]

					presets.Push(%outerClass%[class[2]](arguments*))
				}
				else
					presets.Push(%class%(arguments*))
			}
			catch Any as exception {
				logError(exception)
			}
		}

		return presets
	}

	addPatchFile(type, file) {
		local value := this.KnowledgeBase.getValue("Patch." . type . ".Files", "")

		this.KnowledgeBase.setFact("Patch." . type . ".Files", (value = "") ? file : value . ";" . file)
	}

	removePatchFile(type, file) {
		local files := string2Values(";", this.KnowledgeBase.getValue("Patch." . type . ".Files", ""))
		local index := inList(files, file)

		if index {
			files.RemoveAt(index)

			this.KnowledgeBase.setValue("Patch." . type . ".Files", values2String(";", files*))
		}
	}

	getPatchFiles(type) {
		return collect(string2Values(";", this.KnowledgeBase.getValue("Patch." . type . ".Files", "")), substituteVariables)
	}

	selectModule(module, selected, update := true) {
		if (this.isModuleSelected(module) != (selected != false)) {
			this.iCachedActions := CaseInsenseMap()

			this.KnowledgeBase.setFact("Module." . module . ".Selected", selected != false)

			if update
				this.updateState()
			else {
				this.KnowledgeBase.produce()

				if this.Debug[kDebugKnowledgeBase]
					this.dumpKnowledgeBase(this.KnowledgeBase)
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
						this.dumpKnowledgeBase(this.KnowledgeBase)
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
		local ignore, section, descriptor, applications

		if (!this.isApplicationInstalled(application) && !executable)
			for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other"] {
				descriptor := getMultiMapValue(this.Definition, section, application, false)

				if descriptor {
					descriptor := string2Values("|", descriptor)

					executable := findSoftware(this.Definition, descriptor[1])

					break
				}
			}

		if executable {
			knowledgeBase.setFact("Application." . application . ".Installed", true)
			knowledgeBase.setFact("Application." . application . ".Path", executable)

			applications := string2Values("###", knowledgeBase.getValue("Application.Installed", ""))

			if !inList(applications, application)
				knowledgeBase.setFact("Application.Installed", values2String("###", concatenate(applications, [application])*))

			if update
				this.updateState()
		}
	}

	installedApplications() {
		return string2Values("###", this.KnowledgeBase.getValue("Application.Installed", ""))
	}

	applicationPath(application) {
		return this.KnowledgeBase.getValue("Application." . application . ".Path", false)
	}

	isQuickSetupAvailable() {
		return (this.isModuleSelected("Voice Control") && (this.loadPresets().Length = 0))
	}

	installSoftware() {
		local progressCount := 0

		detectSimulators() {
			local task := PeriodicTask((*) => showProgress({progress: progressCount++, message: translate("Detecting Simulators...")}), 100, kHighPriority)

			try {
				task.start()

				try {
					this.Steps["Applications"].updateAvailableApplications(true)

					Sleep(1000)
				}
				finally {
					task.stop()
				}
			}
			catch Any as exception {
				showProgress({color: "Red", message: translate("Error while detecting Simulators...")})

				Sleep(1000)

				logError(exception, true)
			}
		}

		installRuntimes() {
			local runtime, definition

			for runtime, definition in getMultiMapValues(this.Definition, "Software.Runtimes")
				if !this.isSoftwareInstalled(runtime)
					try {
						showProgress({progress: progressCount++, color: "Green", message: translate("Installing ") . runtime . translate("...")})

						definition := string2Values("|", definition)

						RunWait(kHomeDirectory . definition[2])

						this.locateSoftware(runtime, true)
					}
					catch Any as exception {
						showProgress({color: "Red", message: translate("Error while installing ") . runtime . translate("...")})

						Sleep(1000)

						logError(exception, true)
					}
		}

		installSoftware() {
			local software, definition

			for software, definition in getMultiMapValues(this.Definition, "Applications.Special")
				if !this.isSoftwareInstalled(software)
					try {
						showProgress({progress: progressCount++, color: "Green", message: translate("Installing ") . software . translate("...")})

						definition := string2Values(":", string2Values("|", definition)[4])

						this.locateSoftware(software, %definition[1]%.Call(string2Values(";", definition[2])*))
					}
					catch Any as exception {
						showProgress({color: "Red", message: translate("Error while installing ") . software . translate("...")})

						Sleep(1000)

						logError(exception, true)
					}
		}

		installPlugins() {
			local plugin, definition, ignore, target, root, path, skip, source

			for plugin, definition in getMultiMapValues(this.Definition, "Software.Plugins")
				if !this.isSoftwareInstalled(plugin)
					try {
						definition := string2Values("|", definition)
						skip := false
						root := ""

						for ignore, target in string2Values(";", definition[3]) {
							target := string2Values(":", target)

							if (target[1] = "Software") {
								this.locateSoftware(target[2])

								root := (this.isSoftwareInstalled(target[2]) && this.softwarePath(target[2]))

								if root
									SplitPath(root, , &root)
								else
									skip := true
							}
							else if (target[1] = "Path")
								path := target[2]
						}

						if (!skip && (root = ""))
							if !FileExist(substituteVariables(path))
								skip := true

						if !skip {
							showProgress({progress: progressCount++, color: "Green", message: translate("Installing ") . plugin . translate("...")})

							path := (root . substituteVariables(path))
							source := string2Values(":", definition[2])

							SplitPath(substituteVariables(source[2]), &name)

							if (source[1] = "Directory")
								DirCopy(substituteVariables(source[2]), path . "\" . name, 1)
							else if (source[1] = "File")
								FileCopy(substituteVariables(source[2]), path, 1)
							else
								throw "Unknown plugin source type detected in SetupWizard.installSoftware..."

							this.locateSoftware(plugin, path . "\" . name)
						}
					}
					catch Any as exception {
						showProgress({color: "Red", message: translate("Error while installing ") . plugin . translate("...")})

						Sleep(1000)

						logError(exception, true)
					}
		}

		this.Window.block()

		showProgress({color: "Blue", title: translate("Preparing Configuration")})

		try {
			showProgress({progress: ++progressCount, message: translate("Creating Configuration...")})

			Sleep(1000)

			showProgress({progress: ++progressCount, message: translate("Parsing Registry...")})

			loop 10 {
				Sleep(500)

				showProgress({progress: ++progressCount})
			}

			showProgress({progress: progressCount++, message: translate("Detecting Simulators...")})

			detectSimulators()

			showProgress({color: "Green", title: translate("Install Runtimes")})

			installRuntimes()

			showProgress({color: "Green", title: translate("Install Software")})

			installSoftware()

			showProgress({color: "Green", title: translate("Install Plugins")})

			installPlugins()

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep(1000)
		}
		finally {
			hideProgress()

			this.Window.unblock()

			this.updateState()
		}
	}

	setGeneralConfiguration(language, startWithWindows, silentMode) {
		local knowledgeBase := this.KnowledgeBase

		knowledgeBase.setFact("General.Language", language)
		knowledgeBase.setFact("General.Start With Windows", startWithWindows)
		knowledgeBase.setFact("General.Silent Mode", silentMode)
	}

	getGeneralConfiguration(&language, &startWithWindows, &silentMode) {
		local knowledgeBase := this.KnowledgeBase

		language := knowledgeBase.getValue("General.Language", getLanguage())
		startWithWindows := knowledgeBase.getValue("General.Start With Windows", true)
		silentMode := knowledgeBase.getValue("General.Silent Mode", false)
	}

	setModeSelectors(modeSelectors) {
		if (modeSelectors.Length > 0)
			this.KnowledgeBase.setFact("Controller.Mode.Selectors", values2String("|", modeSelectors*))
		else
			this.KnowledgeBase.removeFact("Controller.Mode.Selectors")
	}

	getModeSelectors() {
		return string2Values("|", this.KnowledgeBase.getValue("Controller.Mode.Selectors", ""))
	}

	setLaunchApplicationLabelsAndFunctions(labelsAndFunctions) {
		local knowledgeBase := this.KnowledgeBase
		local application, labelAndFunction, function, count

		loop knowledgeBase.getValue("System.Launch.Application.Count", 0) {
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
		local functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		local index, descriptor, parts

		for index, descriptor in functions {
			parts := string2Values("###", descriptor)

			if ((parts[1] = module) && (parts[2] = function)) {
				parts[3] := label
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
		local functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		local found := true
		local index, descriptor, parts

		while found {
			found := false

			for index, descriptor in functions {
				parts := string2Values("###", descriptor)

				if ((parts[1] = module) && (parts[2] = function)) {
					functions.RemoveAt(index)

					if (functions.Length == 0)
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
		local functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		local result := []
		local index, descriptor, parts

		for index, descriptor in functions {
			parts := string2Values("###", descriptor)

			if this.isModuleSelected(parts[1])
				result.Push(Array(parts[2], parts[3]))
		}

		return result
	}

	setControllerFunctions(functions) {
		local knowledgeBase := this.KnowledgeBase
		local ignore, function, name

		loop knowledgeBase.getValue("Controller.Function.Count", 0) {
			function := knowledgeBase.getValue("Controller.Function." . A_Index, false)

			if function
				knowledgeBase.removeFact("Controller.Function." . function . ".Triggers")

			knowledgeBase.removeFact("Controller.Function." . A_Index)
		}

		for ignore, function in functions {
			function := isObject(function) ? function.Clone() : Array(function)

			name := function.RemoveAt(1)

			knowledgeBase.setFact("Controller.Function." . A_Index, name)

			if (function.Length > 0)
				knowledgeBase.setFact("Controller.Function." . name . ".Triggers", values2String(" ### ", function*))
		}

		knowledgeBase.setFact("Controller.Function.Count", functions.Length)

		this.updateState()
	}

	getControllerFunctionTriggers(function) {
		return string2Values("###", this.KnowledgeBase.getValue("Controller.Function." . function . ".Triggers", ""))
	}

	setSimulatorActionFunctions(simulator, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local count := 0
		local function, action

		loop knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action.Count", 0) {
			action := knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action." . A_Index, false)

			if action
				knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Action." . action . ".Function")

			knowledgeBase.removeFact("Simulator." . simulator . ".Mode." . mode . ".Action." . A_Index)
		}

		for action, function in functions {
			if (function && ((isObject(function) && (function.Length > 0)) || (function != ""))) {
				if !isObject(function)
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

			return ((function.Length == 1) ? function[1] : function)
		}
		else
			return ""
	}

	simulatorActionAvailable(simulator, mode, action) {
		local goal, result

		if this.iCachedActions.Has(simulator . mode . action)
			return this.iCachedActions[simulator . mode . action]
		else {
			goal := RuleCompiler().compileGoal("simulatorActionAvailable?(" . StrReplace(simulator, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[simulator . mode . action] := result

			return result
		}
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
		local count := 0
		local function, action

		loop knowledgeBase.getValue("Assistant." . assistant . ".Action.Count", 0) {
			action := knowledgeBase.getValue("Assistant." . assistant . ".Action." . A_Index, false)

			if action
				knowledgeBase.removeFact("Assistant." . assistant . ".Action." . action . ".Function")

			knowledgeBase.removeFact("Assistant." . assistant . ".Action." . A_Index)
		}

		for action, function in functions {
			if (function && ((isObject(function) && (function.Length > 0)) || (function != ""))) {
				if !isObject(function)
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

			return ((function.Length == 1) ? function[1] : function)
		}
		else
			return ""
	}

	assistantActionAvailable(assistant, action) {
		local goal, result

		if this.iCachedActions.Has(assistant . action)
			return this.iCachedActions[assistant . action]
		else {
			goal := RuleCompiler().compileGoal("assistantActionAvailable?(" . StrReplace(assistant, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[assistant . action] := result

			return result
		}
	}

	assistantSimulators(assistant) {
		local knowledgeBase := this.KnowledgeBase
		local goal := RuleCompiler().compileGoal("assistantSupportedSimulator?(" . StrReplace(assistant, A_Space, "\ ") . ", ?simulator)")
		local variable := goal.Arguments[2]
		local resultSet := knowledgeBase.prove(goal)
		local simulators := []

		while resultSet {
			simulators.Push(resultSet.getValue(variable).toString())

			if !resultSet.nextResult() {
				resultSet.dispose()

				resultSet := false
			}
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
		this.KnowledgeBase.removeFact("Module." . module . ".Key." . key)

		if update
			this.updateState()
	}

	setModuleAvailableActions(module, mode, actions) {
		local knowledgeBase := this.KnowledgeBase
		local modeClause := (mode ? (".Mode." . mode) : "")
		local count := knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
		local index, action

		loop count {
			action := knowledgeBase.getValue("Module." . module . modeClause . ".Action." . A_Index, false)

			if (action && !inList(actions, action)) {
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Function")
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Argument")
			}

			knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . A_Index)
		}

		for index, action in actions
			knowledgeBase.addFact("Module." . module . modeClause . ".Action." . index, action)

		knowledgeBase.setFact("Module." . module . modeClause . ".Action.Count", actions.Length)

		if this.iCachedActions.Has(module . mode)
			this.iCachedActions.Delete(module . mode)

		this.updateState()
	}

	setModuleActionFunctions(module, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local modeClause := (mode ? (".Mode." . mode) : "")
		local function, action

		loop knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0) {
			action := knowledgeBase.getValue("Module." . module . modeClause . ".Action." . A_Index, false)

			if action
				knowledgeBase.removeFact("Module." . module . modeClause . ".Action." . action . ".Function")
		}

		for action, function in functions {
			if (function && ((isObject(function) && (function.Length > 0)) || (function != ""))) {
				if !isObject(function)
					function := Array(function)

				knowledgeBase.addFact("Module." . module . modeClause . ".Action." . action . ".Function", values2String("|", function*))
			}
		}

		this.updateState()
	}

	getModuleActionFunction(module, mode, action) {
		local modeClause := (mode ? (".Mode." . mode) : "")
		local function := this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Function", false)

		if function {
			function := string2Values("|", function)

			return ((function.Length == 1) ? function[1] : function)
		}
		else
			return ""
	}

	setModuleActionArguments(module, mode, arguments) {
		local knowledgeBase := this.KnowledgeBase
		local modeClause := (mode ? (".Mode." . mode) : "")
		local action, argument

		loop knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0) {
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
		local modeClause := (mode ? (".Mode." . mode) : "")

		return this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Argument", "")
	}

	moduleActionAvailable(module, mode, action) {
		local goal, result

		if this.iCachedActions.Has(module . mode . action)
			return this.iCachedActions[module . mode . action]
		else {
			if mode
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"
			else
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"

			goal := RuleCompiler().compileGoal(goal)

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[module . mode . action] := result

			return result
		}
	}

	moduleAvailableActions(module, mode) {
		local resultSet, variable, goal, actions

		if this.iCachedActions.Has(module . mode)
			return this.iCachedActions[module . mode]
		else {
			if mode
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", ?action)"
			else
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", ?action)"

			goal := RuleCompiler().compileGoal(goal)
			variable := goal.Arguments[mode ? 3 : 2]

			resultSet := this.KnowledgeBase.prove(goal)
			actions := []

			while resultSet {
				actions.Push(resultSet.getValue(variable).toString())

				if !resultSet.nextResult()
					resultSet := false
			}

			this.iCachedActions[module . mode] := actions

			return actions
		}
	}

	setTitle(title) {
		this.HelpWindow["stepTitle"].Text := title
	}

	setSubtitle(subtitle) {
		this.HelpWindow["stepSubtitle"].Text := translate("Step ") . this.Steps[this.Step] . translate(": ") . subtitle
	}

	setInfo(html) {
		html := "<html><body style='background-color: #" . this.HelpWindow.BackColor . "; overflow: auto; font-family: Arial, Helvetica, sans-serif; font-size: 11px; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'>" . html . "</body></html>"

		this.HelpWindow["infoViewer"].document.open()
		this.HelpWindow["infoViewer"].document.write(html)
		this.HelpWindow["infoViewer"].document.close()
	}

	saveKnowledgeBase() {
		local savedKnowledgeBase := newMultiMap()

		setMultiMapValues(savedKnowledgeBase, "Setup", this.KnowledgeBase.Facts.Facts)

		writeMultiMap(kUserHomeDirectory . "Setup\Setup.data", savedKnowledgeBase)
	}

	loadKnowledgeBase() {
		local knowledgeBase := this.KnowledgeBase
		local key, value

		if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
			for key, value in getMultiMapValues(readMultiMap(kUserHomeDirectory . "Setup\Setup.data"), "Setup")
				knowledgeBase.setFact(key, value)

			return true
		}
		else
			return false
	}

	dumpKnowledgeBase(knowledgeBase) {
		knowledgeBase.dumpFacts()
	}

	dumpRules(knowledgeBase) {
		knowledgeBase.dumpRules()
	}

	toggleTriggerDetector(callback := false) {
		triggerDetector(callback)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StepWizard                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StepWizard extends ConfiguratorPanel {
	iStep := false
	iDefinition := false

	iWidgets := CaseInsenseMap()

	SetupWizard {
		Get {
			return this.Editor
		}
	}

	Step {
		Get {
			return this.iStep
		}
	}

	Definition[key?] {
		Get {
			return (isSet(key) ? this.iDefinition[key] : this.iDefinition)
		}
	}

	Pages {
		Get {
			return 1
		}
	}

	Active {
		Get {
			return (this.Pages > 0)
		}
	}

	__New(wizard, step, configuration) {
		this.Editor := wizard

		this.iStep := step

		super.__New(configuration)
	}

	loadDefinition(definition, stepDefinition) {
		local rules := CaseInsenseWeakMap()
		local count := 0
		local descriptor, rule, index

		showProgress({message: translate("Step: ") . getMultiMapValue(definition, "Setup." . this.Step, this.Step . ".Subtitle." . getLanguage())})

		for descriptor, rule in getMultiMapValues(definition, "Setup." . this.Step)
			if (InStr(descriptor, this.Step . ".Rule") == 1) {
				index := string2Values(".", descriptor)[3]

				count := Max(count, index)

				rules[index] := rule
			}

		loop count
			if rules.Has(A_Index)
				this.SetupWizard.addRule(rules[A_Index])

		this.loadStepDefinition(stepDefinition)
	}

	loadStepDefinition(definition) {
		this.iDefinition := string2Values("|", definition)
	}

	getWorkArea(&x, &y, &width, &height) {
		this.SetupWizard.getWorkArea(&x, &y, &width, &height)
	}

	createGui(wizard, x, y, width, height) {
		throw "Virtual method StepWizard.createGui must be implemented in a subclass..."
	}

	registerWidget(page, widget) {
		if widget {
			if !this.iWidgets.Has(page)
				this.iWidgets[page] := []

			this.iWidgets[page].Push(widget)
		}
	}

	registerWidgets(page, widgets*) {
		local ignore, widget

		for ignore, widget in widgets
			this.registerWidget(page, widget)
	}

	deleteWidgets(page) {
		this.iWidgets.Delete(page)
	}

	reset() {
		this.iWidgets := CaseInsenseMap()
	}

	show() {
		local language := getLanguage()
		local definition := this.SetupWizard.Definition

		this.setTitle(getMultiMapValue(definition, "Setup." . this.Step, this.Step . ".Title." . language))
		this.setSubtitle(getMultiMapValue(definition, "Setup." . this.Step, this.Step . ".Subtitle." . language))
		this.setInfo(getMultiMapValue(definition, "Setup." . this.Step, this.Step . ".Info." . language))
	}

	hide() {
		this.setTitle("")
		this.setSubtitle("")
		this.setInfo("")
	}

	showPage(page) {
		local ignore, widget

		if this.iWidgets.Has(page)
			for ignore, widget in this.iWidgets[page] {
				if widget.HasProp("Show")
					widget.Show()
				else
					widget.Visible := true

				widget.Enabled := true
			}
	}

	hidePage(page) {
		local ignore, widget

		if this.iWidgets.Has(page)
			for ignore, widget in this.iWidgets[page] {
				widget.Enabled := false

				if widget.HasProp("Hide")
					widget.Hide()
				else
					widget.Visible := false
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

	class RestartVideoResizer extends Window.Resizer {
		iRedraw := false
		iWizard := false

		__New(wizard, window, arguments*) {
			this.iWizard := wizard
			this.iWindow := window

			super.__New(window, arguments*)

			Task.startTask(ObjBindMethod(this, "RestartVideo"), 100, kInterruptPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RestartVideo() {
			if this.iRedraw {
				local ignore, button, audio, volume

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button, "P")
						return Task.CurrentTask

				this.iRedraw := false

				if ((this.iWizard.SetupWizard.Step = this.iWizard) && (this.iWizard.SetupWizard.Page = 1)) {
					audio := substituteVariables(getMultiMapValue(this.iWizard.SetupWizard.Definition, "Setup.Start", "Start.Audio", false))

					if audio {
						volume := fadeOut(20)

						try {
							SoundPlay("NonExistent.avi")
						}
						catch Any as exception {
							logError(exception, false, false)
						}

						resetVolume(volume)

						SoundPlay(audio)
					}
				}
			}

			return Task.CurrentTask
		}
	}

	Pages {
		Get {
			return (A_IsAdmin ? 1 : 2)
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local text, image, html, ignore, directory, currentDirectory
		local labelWidth, labelX, labelY, info

		elevateAndRestart(*) {
			if !(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
				try {
					if this.SetupWizard.Initialize
						deleteFile(kUserHomeDirectory . "Setup\Setup.data")

					if A_IsCompiled
						Run("*RunAs `"" . A_ScriptFullPath . "`" /restart")
					else
						Run("*RunAs `"" . A_AhkPath . "`" /restart `"" . A_ScriptFullPath . "`"")
				}
				catch Any as exception {
					logError(exception)
				}

				ExitApp(0)
			}
		}

		widget1 := window.Add("HTMLViewer", "x" . (x - 10) . " y" . y . " w" . (width + 20) . " h" . height . " W:Grow H:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Start", "Start.Text." . getLanguage()))
		image := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Start", "Start.Image"))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		height := Round(width / 16 * 9)

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "<br><center><img src='" . image . "' width='" . width . "' height='" . height . "' border='0' padding='0'></center></body></html>"

		widget1.document.write(html)

		; window.Add(StartStepWizard.RestartVideoResizer(this, window))

		this.iImageViewer := widget1
		this.iImageViewerHTML := html

		this.registerWidget(1, widget1)

		if !A_IsAdmin {
			labelWidth := width - 30
			labelX := x + 35
			labelY := y + 8

			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Start", "Start.Unblocking.Info." . getLanguage()))
			info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'>" . info . "</div>"

			window.SetFont("s10 Bold", "Arial")

			widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Security.ico")
			widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Unblocking Applications and DLLs"))

			window.SetFont("s8 Norm", "Arial")

			Sleep(200)

			widget3 := window.Add("HTMLViewer", "x" . x . " yp+30 w" . width . " h350 W:Grow H:Grow Hidden")

			x := x + Round((width - 240) / 2)

			window.SetFont("s10 Bold", "Arial")

			widget4 := window.Add("Button", "x" . x . " yp+380 w240 h30 Y:Move H:Center Hidden", translate("Restart as Administrator"))
			widget4.OnEvent("Click", elevateAndRestart)

			html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			widget3.document.write(html)

			this.registerWidgets(2, widget1, widget2, widget3, widget4)
		}
		else
			for ignore, directory in [kBinariesDirectory, kResourcesDirectory . "Setup\Installer\"] {
				currentDirectory := A_WorkingDir

				try {
					SetWorkingDir(directory)

					Run("Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File", , "Hide")
				}
				catch Any as exception {
					logError(exception)
				}
				finally {
					SetWorkingDir(currentDirectory)
				}
			}
	}

	reset() {
		local volume

		super.reset()

		this.iImageViewer := false

		volume := fadeOut()

		try {
			SoundPlay("NonExistent.avi")
		}
		catch Any as exception {
			logError(exception, false, false)
		}

		resetVolume(volume)
	}

	showPage(page) {
		local imageViewer, audio

		if (page == 1) {
			imageViewer := this.iImageViewer

			imageViewer.document.open()
			imageViewer.document.write(this.iImageViewerHTML)
			imageViewer.document.close()

			audio := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Start", "Start.Audio", false))

			if audio
				SoundPlay(audio)
		}

		super.showPage(page)
	}

	hidePage(page) {
		local volume

		if (page == 1) {
			volume := fadeOut()

			try {
				SoundPlay("NonExistent.avi")
			}
			catch Any as exception {
				logError(exception, false, false)
			}

			resetVolume(volume)
		}

		if super.hidePage(page) {
			local imageViewer

			if (page == 1) {
				imageViewer := this.iImageViewer

				imageViewer.document.open()
				imageViewer.document.write("<html></html>")
				imageViewer.document.close()
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
	Pages {
		Get {
			return 1
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local image, text, html

		widget1 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h" . (height - 36) . " H:Center V:Center Hidden")

		image := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Finish", "Finish.Image"))
		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Finish", "Finish.Text." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		height := Round(width / 16 * 9)

		html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='auto' bottommargin='0'><img src='" . image . "' width='" . (width - 24) . "' height='" . (height - 50) . "' border='0' padding='0'><br><br><br>" . text . "</body></html>"

		widget1.document.write(html)

		this.registerWidget(1, widget1)
	}

	showPage(page) {
		Task.startTask(ObjBindMethod(this, "openSettingsEditor"), 200, kHighPriority)

		super.showPage(page)
	}

	hidePage(page) {
		if super.hidePage(page) {
			Task.startTask(ObjBindMethod(this, "closeSettingsEditor"), 1000, kHighPriority)

			return true
		}
		else
			return false
	}

	openSettingsEditor() {
		local settings, configuration

		if this.SetupWizard.Working
			Task.startTask(ObjBindMethod(this, "openSettingsEditor"), 200)
		else {
			if FileExist(kUserConfigDirectory . "Simulator Settings.ini")
				settings := readMultiMap(kUserConfigDirectory . "Simulator Settings.ini")
			else
				settings := newMultiMap()

			if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
				addMultiMapValues(settings, readMultiMap(kUserHomeDirectory . "Setup\Simulator Settings.ini"))

			configuration := this.SetupWizard.getSimulatorConfiguration()

			this.SetupWizard.SettingsOpen := true

			editSettings(&settings, this.SetupWizard.Window, false, configuration
					   , Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 180, A_ScreenWidth - 360)
					   , "Center")
		}

		return false
	}

	closeSettingsEditor() {
		global kSave

		if !this.SetupWizard.SettingsOpen
			Task.startTask(ObjBindMethod(this, "closeSettingsEditor"), 1000, kHighPriority)

		writeMultiMap(kUserHomeDirectory . "Setup\Simulator Settings.ini", editSettings(&kSave, false, false, true))

		this.SetupWizard.SettingsOpen := false

		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

/*
LV_ClickedColumn(listViewHandle) {
	local POINT, LVHITTESTINFO

	static LVM_SUBITEMHITTEST := 0x1039

	POINT := Buffer(8, 0) ; V1toV2: if 'POINT' is a UTF-16 string, use 'VarSetStrCapacity(&POINT, 8)'

	DllCall("User32.dll\GetCursorPos", "Ptr", POINT)
	DllCall("User32.dll\ScreenToClient", "Ptr", listViewHandle, "Ptr", POINT)

	LVHITTESTINFO := Buffer(24, 0) ; V1toV2: if 'LVHITTESTINFO' is a UTF-16 string, use 'VarSetStrCapacity(&LVHITTESTINFO, 24)'
	NumPut("Int", NumGet(POINT, 0, "Int"), LVHITTESTINFO, 0)
	NumPut("Int", NumGet(POINT, 4, "Int"), LVHITTESTINFO, 4)

	if (type(LVHITTESTINFO)="Buffer"){ ;V1toV2 If statement may be removed depending on type parameter
	   ErrorLevel := SendMessage(LVM_SUBITEMHITTEST, 0, LVHITTESTINFO, , "ahk_id " listViewHandle)
	} else{
	   ErrorLevel := SendMessage(LVM_SUBITEMHITTEST, 0, StrPtr(LVHITTESTINFO), , "ahk_id " listViewHandle)
	}

	return ((ErrorLevel = -1) ? 0 : (NumGet(LVHITTESTINFO, 16, "Int") + 1))
}
*/

convertVDF2JSON(vdf) {
	; encapsulate in braces
    vdf := "{`n" . vdf . "`n}"

    ; replace open braces
	vdf := RegExReplace(vdf, "`"([^`"]*)`"\s*{", "`"${1}`": {")

	; replace values
	vdf := RegExReplace(vdf, "`"([^`"]*)`"\s*`"([^`"]*)`"", "`"${1}`": `"${2}`",")

	; remove trailing commas
	vdf := RegExReplace(vdf, ",(\s*[}\]])", "${1}")

    ; add commas
    vdf := RegExReplace(vdf, "([}\]])(\s*)(`"[^`"]*`":\s*)?([{\[])/", "${1},${2}${3}${4}")

    ; object as value
    vdf := RegExReplace(vdf, "}(\s*`"[^`"]*`":)", "},${1}")

	return vdf
}

findInRegistry(collection, filterName, filterValue, valueName) {
	local exact, candidate, value

	loop 2 {
		exact := (A_Index = 1)

		loop Reg, collection, "R"
			if (A_LoopRegName = filterName) {
				candidate := RegRead()

				if ((exact && (candidate = filterValue)) || (!exact && InStr(candidate, filterValue) = 1)) {
					try {
						value := RegRead(A_LoopRegKey, valueName)
					}
					catch Any as exception {
						value := ""
					}

					return value
				}
			}
	}

	return ""
}

findInstallProperty(name, property) {
	local value := findInRegistry("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, property)

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
	local icon := kIconsDirectory . "Configuration Wand.ico"
	local definition, wizard, label, callback, ignore, languages, language, section, keyValues, key, value

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Setup"

	DirCreate(kUserHomeDirectory "Setup")

	definition := readMultiMap(kResourcesDirectory . "Setup\Simulator Setup.ini")

	languages := string2Values("|", getMultiMapValue(definition, "Setup", "Languages"))

	if FileExist(kUserTranslationsDirectory . "Setup\Simulator Setup.ini") {
		for ignore, language in string2Values("|", getMultiMapValue(readMultiMap(kUserTranslationsDirectory . "Setup\Simulator Setup.ini"), "Setup", "Languages"))
			if !inList(languages, language)
				languages.Push(language)
	}

	setMultiMapValue(definition, "Setup", "Languages", values2String("|", languages*))

	for language, ignore in languages
		for ignore, root in [kResourcesDirectory, kUserTranslationsDirectory]
			if FileExist(kUserHomeDirectory . "Setup\Simulator Setup." . language)
				for section, keyValues in readMultiMap(kUserHomeDirectory . "Setup\Simulator Setup." . language)
					for key, value in keyValues
						setMultiMapValue(definition, section, key, value)

	setMultiMapValues(kSimulatorConfiguration, "Splash Window", getMultiMapValues(definition, "Splash Window"))
	setMultiMapValues(kSimulatorConfiguration, "Splash Screens", getMultiMapValues(definition, "Splash Screens"))

	setMultiMapValue(kSimulatorConfiguration, "Splash Window", "Title"
											, translate("Modular Simulator Controller System") . translate(" - ") . translate("Setup && Configuration"))

	wizard := SetupWizard(kSimulatorConfiguration, definition)

	SupportMenu.Insert("1&")

	label := translate("Debug Rule System")

	SupportMenu.Insert("1&", label, (*) => wizard.toggleDebug(kDebugRules))

	if wizard.Debug[kDebugRules]
		SupportMenu.Check(label)

	label := translate("Debug Knowledgebase")
	callback :=

	SupportMenu.Insert("1&", label, (*) => wizard.toggleDebug(kDebugKnowledgeBase))

	if wizard.Debug[kDebugKnowledgeBase]
		SupportMenu.Check(label)

	if !isDebug()
		showSplashScreen("Rotating Brain")

	wizard.ProgressCount := 0

	showProgress({color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("Preparing Configuration Steps...")})

	wizard.registerStepWizard(StartStepWizard(wizard, "Start", kSimulatorConfiguration))
	wizard.registerStepWizard(FinishStepWizard(wizard, "Finish", kSimulatorConfiguration))

	return
}

startupSimulatorSetup() {
	local wizard := SetupWizard.Instance

	wizard.loadDefinition()

	if wizard.Debug[kDebugRules]
		wizard.dumpRules(wizard.KnowledgeBase)

	loop {
		wizard.createGui(wizard.Configuration)

		wizard.startSetup()

		while (wizard.ProgressCount < 100) {
			showProgress({progress: ++wizard.ProgressCount, message: translate("Starting UI...")})

			Sleep(5)
		}

		showProgress({progress: 100, message: translate("Finished...")})

		Sleep(1000)

		if !isDebug()
			hideSplashScreen()

		hideProgress()

		wizard.show()

		try {
			loop {
				wizard.Working := false

				Sleep(200)
			}
			until (wizard.Result == kLanguage)
		}
		finally {
			wizard.hide()
		}

		if (wizard.Result == kLanguage) {
			wizard.Result := false

			wizard.close()
			wizard.reset(false)

			setMultiMapValue(kSimulatorConfiguration, "Splash Window", "Title", translate("Modular Simulator Controller System") . translate(" - ") . translate("Setup && Configuration"))

			wizard.ProgressCount := 0

			if !isDebug()
				showSplashScreen("Rotating Brain")

			showProgress({color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("")})
		}
		else
			break
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

installMSI(command) {
	RunWait(kHomeDirectory . command)

	return false
}

installZIP(path, application) {
	deleteDirectory(A_Temp . "\Simulator Controller\Temp")

	DirCreate(A_Temp . "\Simulator Controller\Temp")
	DirCreate(kUserHomeDirectory . "Programs")

	RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kHomeDirectory . path . "' -DestinationPath '" . A_Temp . "\Simulator Controller\Temp'", , "Hide")

	FileCopy(A_Temp . "\Simulator Controller\Temp\" . application, kUserHomeDirectory . "Programs", 1)

	return (kUserHomeDirectory . "Programs\" . application)
}

installEXE(command) {
	RunWait(kHomeDirectory . command)

	return false
}

openLabelsAndIconsEditor(*) {
	local window := SetupWizard.Instance.WizardWindow

	window.Block()

	try {
		ControllerActionsEditor(kSimulatorConfiguration).editPluginActions(false, window)
	}
	finally {
		window.Unblock()
	}
}

standardApplication(definition, categories, executable) {
	local ignore, category, name, descriptor
	local software, candidate

	SplitPath(executable, &software)

	for ignore, category in categories
		for name, descriptor in getMultiMapValues(definition, category) {
			descriptor := string2Values("|", descriptor)

			SplitPath(descriptor[3], &candidate)

			if (software = candidate)
				return name
		}

	return false
}

findSoftware(definition, software) {
	local ignore, category, name, descriptor, ignore, locator, value, folder, installPath, folders
	local fileName, exePath, jsScript, script

	for ignore, category in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getMultiMapValues(definition, category) {
			descriptor := string2Values("|", descriptor)

			if (software = descriptor[1]) {
				for ignore, locator in string2Values(";", descriptor[2]) {
					if (InStr(locator, "File:") == 1) {
						locator := substituteVariables(Trim(StrReplace(locator, "File:", "")))

						if FileExist(locator)
							return locator
					}
					else if (InStr(locator, "RegistryExist:") == 1) {
						try {
							value := RegRead(substituteVariables(Trim(StrReplace(locator, "RegistryExist:", ""))))
						}
						catch Any as exception {
							value := ""
						}

						if (value != "")
							return true
					}
					else if (InStr(locator, "RegistryScan:") == 1) {
						folder := findInstallProperty(substituteVariables(Trim(StrReplace(locator, "RegistryScan:", ""))), "InstallLocation")

						if (folder != "")
							if FileExist(folder . descriptor[3])
								return (folder . descriptor[3])
							else if FileExist(folder . "\" . descriptor[3])
								return (folder . descriptor[3])
					}
					else if (InStr(locator, "Steam:") == 1) {
						locator := substituteVariables(Trim(StrReplace(locator, "Steam:", "")))

						try {
							installPath := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam", "InstallPath")
						}
						catch Any as exception {
							installPath := ""
						}

						if (installPath != "") {
							try {
								script := FileRead(installPath . "\steamapps\libraryfolders.vdf")

								jsScript := convertVDF2JSON(script)

								folders := JSON.parse(jsScript)
								folders := folders["LibraryFolders"]

								for ignore, folder in folders {
									if isObject(folder)
										folder := folder["path"]

									fileName := folder . "\steamapps\common\" . locator . "\" . descriptor[3]

									if FileExist(fileName)
										return fileName
								}
							}
							catch Any as exception {
								logError(exception)
							}
						}
					}
				}

				exePath := getMultiMapValue(kSimulatorConfiguration, name, "Exe Path", false)

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
	local definition := SetupWizard.Instance.Definition
	local ignore, category, name, descriptor

	for ignore, category in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getMultiMapValues(definition, category)
			if (name = application)
				return string2Values("|", descriptor)

	return false
}

fadeOut(delay := 200) {
	local masterVolume, currentVolume

	masterVolume := SoundGetVolume()

	if GetKeyState("Ctrl")
		SoundSetVolume(0)
	else {
		currentVolume := masterVolume

		loop {
			currentVolume -= 5

			if (currentVolume <= 0)
				break
			else {
				SoundSetVolume(currentVolume)

				Sleep(delay)
			}
		}
	}

	return masterVolume
}

resetVolume(masterVolume) {
	SoundSetVolume(masterVolume)
}


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 1                     ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorSetup()


;;;-------------------------------------------------------------------------;;;
;;;                          Wizard Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\QuickStepWizard.ahk"
#Include "Libraries\ModulesStepWizard.ahk"
#Include "Libraries\InstallationStepWizard.ahk"
#Include "Libraries\ApplicationsStepWizard.ahk"
#Include "Libraries\ControllerStepWizard.ahk"
#Include "Libraries\GeneralStepWizard.ahk"
#Include "Libraries\SimulatorsStepWizard.ahk"
#Include "Libraries\AssistantsStepWizard.ahk"
#Include "Libraries\MotionFeedbackStepWizard.ahk"
#Include "Libraries\TactileFeedbackStepWizard.ahk"
#Include "Libraries\PedalCalibrationStepWizard.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorSetup()