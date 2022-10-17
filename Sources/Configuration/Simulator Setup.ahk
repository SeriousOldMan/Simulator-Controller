;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Setup Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Configuration Wand.ico
;@Ahk2Exe-ExeName Simulator Setup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\JSON.ahk
#Include ..\Libraries\RuleEngine.ahk
#Include Libraries\SettingsEditor.ahk
#Include Libraries\ConfigurationEditor.ahk
#Include Libraries\ControllerActionsEditor.ahk
#Include Libraries\ControllerEditor.ahk
#Include ..\Plugins\Voice Control Configuration Plugin.ahk
#Include ..\Plugins\Race Engineer Configuration Plugin.ahk
#Include ..\Plugins\Race Strategist Configuration Plugin.ahk
#Include ..\Plugins\Race Spotter Configuration Plugin.ahk


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
	Name[] {
		Get {
			throw "Virtual property Preset.Name must be implemented in a subclass..."
		}
	}

	getArguments() {
		throw "Virtual method Preset.getArguments must be implemented in a subclass..."
	}

	install(wizard) {
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
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SetupWizard                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global infoViewer
global stepTitle
global stepSubtitle

global languageDropDown

global firstPageButton
global previousPageButton
global nextPageButton
global lastPageButton
global finishButton

class SetupWizard extends ConfigurationItem {
	iDebug := kDebugOff

	iWizardWindow := "SW"
	iHelpWindow := "SH"

	iProgressCount := false
	iWorking := false
	iPageSwitch := false
	iSettingsOpen := false
	iResult := false

	iStepWizards := {}

	iDefinition := false
	iKnowledgeBase := false

	iCount := 0

	iSteps := {}
	iStep := 0
	iPage := 0

	iPresets := false
	iInitialize := false

	iCachedActions := {}

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

	Result[] {
		Get {
			return this.iResult
		}

		Set {
			return (this.iResult := value)
		}
	}

	ProgressCount[] {
		Get {
			return SetupWizard.sProgressCount
		}

		Set {
			return (SetupWizard.sProgressCount := value)
		}
	}

	Working[] {
		Get {
			return this.iWorking
		}

		Set {
			return (this.iWorking := value)
		}
	}

	PageSwitch[] {
		Get {
			return this.iPageSwitch
		}

		Set {
			return (this.iPageSwitch := value)
		}
	}

	SettingsOpen[] {
		Get {
			return this.iSettingsOpen
		}

		Set {
			return (this.iSettingsOpen := value)
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

	Initialize[] {
		Get {
			return this.iInitialize
		}
	}

	Presets[index := false] {
		Get {
			if !this.iPresets
				this.iPresets := this.loadPresets()

			return (index ? this.iPresets[index] : this.iPresets)
		}
	}

	__New(configuration, definition) {
		this.iDebug := (isDebug() ? (kDebugKnowledgeBase + kDebugRules) : kDebugOff)
		this.iDefinition := definition

		base.__New(configuration)

		SetupWizard.Instance := this
	}

	createKnowledgeBase(facts) {
		local rules, productions, reductions, engine

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
		local knowledgeBase, stepWizard, count, descriptor, step, stepDefinition, title, initialize
		local ignore, fileName, language, rootDirectory, section, keyValues, key, value

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

		loop %count% {
			step := this.Steps[A_Index]

			this.ProgressCount += 2

			showProgress({progress: this.ProgressCount})

			if step {
				stepDefinition := readConfiguration(kResourcesDirectory . "Setup\Definitions\" . step.Step . " Step.ini")

				setConfigurationSectionValues(definition, "Setup." . step.Step, getConfigurationSectionValues(stepDefinition, "Setup." . step.Step, Object()))

				for language, ignore in availableLanguages()
					for ignore, rootDirectory in [kResourcesDirectory, kUserHomeDirectory . "Translations\"]
						if FileExist(rootDirectory . "Setup\Definitions\" . step.Step . " Step." . language)
							for section, keyValues in readConfiguration(rootDirectory . "Setup\Definitions\" . step.Step . " Step." . language)
								for key, value in keyValues
									setConfigurationValue(definition, section, key, value)

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

		if isDebug()
			Sleep 1000

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

	getWorkArea(ByRef x, ByRef y, ByRef width, ByRef height) {
		x := 16
		y := 60
		width := 684
		height := 470
	}

	createGui(configuration) {
		local window := this.WizardWindow
		local stepWizard, languages, choices, chosen, code, language, html

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w684 Center gmoveSetupWizard, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x258 YP+20 w184 cBlue Center gopenSetupDocumentation, % translate("Setup && Configuration")

		Gui %window%:Add, Text, x8 yp+20 w700 0x10

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, Button, x16 y540 w30 h30 HwndfirstButtonHandle Disabled VfirstPageButton GfirstPage
		setButtonIcon(firstButtonHandle, kIconsDirectory . "First.ico", 1, "L2 T2 R2 B2 H24 W24")
		Gui %window%:Add, Button, x48 y540 w30 h30 HwndpreviousButtonHandle Disabled VpreviousPageButton GpreviousPage
		setButtonIcon(previousButtonHandle, kIconsDirectory . "Previous.ico", 1, "L2 T2 R2 B2 H24 W24")
		Gui %window%:Add, Button, x638 y540 w30 h30 HwndnextButtonHandle Disabled VnextPageButton GnextPage
		setButtonIcon(nextButtonHandle, kIconsDirectory . "Next.ico", 1, "L2 T2 R2 B2 H24 W24")
		Gui %window%:Add, Button, x670 y540 w30 h30 HwndlastButtonHandle Disabled VlastPageButton GlastPage
		setButtonIcon(lastButtonHandle, kIconsDirectory . "Last.ico", 1, "L2 T2 R2 B2 H24 W24")

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
		Gui %window%:Color, D0D0D0, D8D8D8

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
		local x := 0
		local y := 0
		local width := 0
		local height := 0
		local stepWizard, step

		this.getWorkArea(x, y, width, height)

		for step, stepWizard in this.StepWizards {
			this.ProgressCount += 2

			showProgress({progress: this.ProgressCount, message: translate("Creating UI for Step: ") . translate(step) . translate("...")})

			stepWizard.createGui(this, x, y, width, height)
		}
	}

	saveToConfiguration(configuration) {
		local stepWizard, ignore

		base.saveToConfiguration(configuration)

		for ignore, stepWizard in this.StepWizards
			stepWizard.saveToConfiguration(configuration)
	}

	reset(show := true) {
		if show
			this.show(true)

		loop % this.Count
			if this.Steps.HasKey(A_Index)
				this.Steps[A_Index].reset()
	}

	setDebug(option, enabled) {
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
				Menu SupportMenu, Check, %label%
			else
				Menu SupportMenu, Uncheck, %label%
	}

	toggleDebug(option) {
		this.setDebug(option, !this.Debug[option])
	}

	show(reset := false) {
		local wizardWindow := this.WizardWindow
		local helpWindow := this.HelpWindow
		local x, y, posX

		if getWindowPosition("Simulator Setup", x, y)
			Gui %wizardWindow%:Show, x%x% y%y%
		else {
			posX := Round((A_ScreenWidth - 720 - 400) / 2)

			Gui %wizardWindow%:Show, x%posX% yCenter h610
		}

		if getWindowPosition("Simulator Setup.Help", x, y)
			Gui %helpWindow%:Show, x%x% y%y%
		else {
			posX := (Round((A_ScreenWidth - 720 - 400) / 2) + 750)

			Gui %helpWindow%:Show, x800 x%posX% yCenter h610
		}
	}

	hide() {
		local wizardWindow := this.WizardWindow
		local helpWindow := this.HelpWindow

		Gui %wizardWindow%:Hide
		Gui %helpWindow%:Hide
	}

	close() {
		local wizardWindow := this.WizardWindow
		local helpWindow := this.HelpWindow

		Gui %wizardWindow%:Destroy
		Gui %helpWindow%:Destroy
	}

	startSetup() {
		showProgress({progress: ++this.ProgressCount, message: translate("Initializing Settings && Options...")})

		this.updateState()

		this.iStep := false
		this.iPage := false

		showProgress({progress: ++this.ProgressCount, color: "Green", title: translate("Starting Setup Wizard"), message: translate("Starting Configuration Engine...")})

		this.nextPage()
	}

	applyPatches(configuration, patches) {
		local section, values, key, substitution, currentValue, ignore, substitute, addition, deletion, value

		for section, values in patches
			if (InStr(section, "Replace:") == 1) {
				section := Trim(StrReplace(section, "Replace:", ""))

				for key, substitution in values {
					currentValue := getConfigurationValue(configuration, section, key, kUndefined)

					if (currentValue != kUndefined)
						for ignore, substitute in string2Values("|", substitution) {
							substitute := string2Values("->", substitute)
							currentValue := StrReplace(currentValue, substitute[1], substitute[2])

							setConfigurationValue(configuration, section, key, currentValue)
						}
				}
			}
			else if (InStr(section, "Add:") == 1) {
				section := Trim(StrReplace(section, "Add:", ""))

				for key, addition in values {
					currentValue := getConfigurationValue(configuration, section, key, "")

					if !InStr(currentValue, addition)
						setConfigurationValue(configuration, section, key, currentValue . addition)
				}
			}
			else if (InStr(section, "Delete:") == 1) {
				section := Trim(StrReplace(section, "Delete:", ""))

				for key, deletion in values {
					currentValue := getConfigurationValue(configuration, section, key, kUndefined)

					if (currentValue != kUndefined)
						setConfigurationValue(configuration, section, key, StrReplace(currentValue, deletion, ""))
				}
			}
			else
				for key, value in values
					setConfigurationValue(configuration, section, key, value)
	}

	finishSetup(save := true) {
		local preset, window, configuration, settings, ignore, file, startupLink, startupExe
		local buttonBoxConfiguration, streamDeckConfiguration

		if (this.Step && this.Step.hidePage(this.Page)) {
			window := this.WizardWindow

			Gui %window%:Default

			Gui %window%:+Disabled

			GuiControl Disable, firstPageButton
			GuiControl Disable, previousPageButton
			GuiControl Disable, nextPageButton
			GuiControl Disable, lastPageButton
			GuiControl Disable, finishButton

			this.Working := true

			try {
				if save {
					if FileExist(kUserConfigDirectory . "Simulator Configuration.ini")
						FileMove %kUserConfigDirectory%Simulator Configuration.ini, %kUserConfigDirectory%Simulator Configuration.ini.bak, 1

					if (FileExist(kUserConfigDirectory . "Simulator Settings.ini") && FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini"))
						FileMove %kUserConfigDirectory%Simulator Settings.ini, %kUserConfigDirectory%Simulator Settings.ini.bak, 1

					configuration := this.getSimulatorConfiguration()

					if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
						settings := readConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini")
					else
						settings := newConfiguration()

					for ignore, file in this.getPatchFiles("Configuration")
						if FileExist(file)
							this.applyPatches(configuration, readConfiguration(file))

					for ignore, file in this.getPatchFiles("Settings")
						if FileExist(file)
							this.applyPatches(settings, readConfiguration(file))

					for ignore, preset in this.Presets {
						preset.patchSimulatorConfiguration(this, configuration)
						preset.patchSimulatorSettings(this, settings)
					}

					if (settings.Count() > 0)
						writeConfiguration(kUserConfigDirectory . "Simulator Settings.ini", settings)

					writeConfiguration(kUserConfigDirectory . "Simulator Configuration.ini", configuration)

					deleteFile(kUserConfigDirectory . "Simulator Controller.config")

					startupLink := A_Startup . "\Simulator Startup.lnk"

					if getConfigurationValue(configuration, "Configuration", "Start With Windows", false) {
						startupExe := kBinariesDirectory . "Simulator Startup.exe"

						FileCreateShortCut %startupExe%, %startupLink%, %kBinariesDirectory%
					}
					else
						deleteFile(startupLink)

					deleteDirectory(kTempDirectory, false)

					if this.isModuleSelected("Controller") {
						if FileExist(kUserConfigDirectory . "Button Box Configuration.ini")
							FileMove %kUserConfigDirectory%Button Box Configuration.ini, %kUserConfigDirectory%Button Box Configuration.ini.bak, 1

						buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

						for ignore, file in this.getPatchFiles("Button Box")
							if FileExist(file)
								this.applyPatches(buttonBoxConfiguration, readConfiguration(file))

						for ignore, preset in this.Presets
							preset.patchButtonBoxConfiguration(this, buttonBoxConfiguration)

						writeConfiguration(kUserConfigDirectory . "Button Box Configuration.ini", buttonBoxConfiguration)

						if FileExist(kUserConfigDirectory . "Stream Deck Configuration.ini")
							FileMove %kUserConfigDirectory%Stream Deck Configuration.ini, %kUserConfigDirectory%Stream Deck Configuration.ini.bak, 1

						streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

						for ignore, file in this.getPatchFiles("Stream Deck")
							if FileExist(file)
								this.applyPatches(streamDeckConfiguration, readConfiguration(file))

						for ignore, preset in this.Presets
							preset.patchStreamDeckConfiguration(this, streamDeckConfiguration)

						writeConfiguration(kUserConfigDirectory . "Stream Deck Configuration.ini", streamDeckConfiguration)
					}
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
		local configuration := newConfiguration()

		this.saveToConfiguration(configuration)

		return configuration
	}

	getFirstPage(ByRef step, ByRef page) {
		step := this.Steps[1]
		page := 1

		return true
	}

	getPreviousPage(ByRef step, ByRef page) {
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

	getNextPage(ByRef step, ByRef page) {
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

	getLastPage(ByRef step, ByRef page) {
		step := this.Steps[this.Count]
		page := step.Pages

		return true
	}

	isFirstPage() {
		local step := false
		local page := false

		return !this.getPreviousPage(step, page)
	}

	isLastPage() {
		local step := false
		local page := false

		return !this.getNextPage(step, page)
	}

	showPage(step, page) {
		local window := this.WizardWindow
		local change := (step != this.Step)
		local oldPageSwitch

		Gui %window%:Default

		Gui %window%:+Disabled

		GuiControl Disable, firstPageButton
		GuiControl Disable, previousPageButton
		GuiControl Disable, nextPageButton
		GuiControl Disable, lastPageButton
		GuiControl Disable, finishButton

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
		finally {
			this.PageSwitch := oldPageSwitch
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

	firstPage() {
		local step, page

		try {
			this.Working := true

			try {
				step := false
				page := false

				if this.getFirstPage(step, page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch exception {
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

				if this.getPreviousPage(step, page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch exception {
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

				if this.getNextPage(step, page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch exception {
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

				if this.getLastPage(step, page)
					this.showPage(step, page)
			}
			finally {
				this.Working := false
			}
		}
		catch exception {
			logError(exception)
		}
	}

	updateState() {
		local window := this.WizardWindow

		this.KnowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		loop % this.Count
			if this.Steps.HasKey(A_Index)
				this.Steps[A_Index].updateState()

		Gui %window%:Default

		if !this.PageSwitch {
			if this.isFirstPage() {
				GuiControl Disable, firstPageButton
				GuiControl Disable, previousPageButton
			}
			else {
				GuiControl Enable, firstPageButton
				GuiControl Enable, previousPageButton
			}

			if this.isLastPage() {
				GuiControl Disable, nextPageButton
				GuiControl Disable, lastPageButton
				GuiControl Enable, finishButton
			}
			else {
				GuiControl Enable, nextPageButton
				GuiControl Enable, lastPageButton
				GuiControl Disable, finishButton
			}

			Gui %window%:-Disabled
		}
	}

	installPreset(preset) {
		local knowledgeBase := this.KnowledgeBase
		local count

		preset.install(this)

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

		loop % knowledgeBase.getValue("Preset.Count", 0)
		{
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

		knowledgeBase.setFact("Preset.Count", presets.Length())

		this.iPresets := false

		this.updateState()
	}

	loadPresets() {
		local knowledgeBase := this.KnowledgeBase
		local presets := []
		local class, arguments, outerclass

		loop % knowledgeBase.getValue("Preset.Count", 0)
		{
			class := knowledgeBase.getValue("Preset." . A_Index . ".Class")
			arguments := string2Values("###", knowledgeBase.getValue("Preset." . A_Index . ".Arguments"))

			if InStr(class, ".") {
				class := StrSplit(class, ".")
				outerClass := class[1]

				presets.Push(new %outerClass%[class[2]](arguments*))
			}
			else
				presets.Push(new %class%(arguments*))
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
		return map(string2Values(";", this.KnowledgeBase.getValue("Patch." . type . ".Files", "")), "substituteVariables")
	}

	selectModule(module, selected, update := true) {
		if (this.isModuleSelected(module) != (selected != false)) {
			this.iCachedActions := {}

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
		local ignore, section, descriptor

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

		language := knowledgeBase.getValue("General.Language", getLanguage())
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
		local application, labelAndFunction, function, count

		loop % knowledgeBase.getValue("System.Launch.Application.Count", 0)
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
		local functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		local index, descriptor, parts

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
		local functions := string2Values("|", knowledgeBase.getValue("Controller.Function.Static", ""))
		local found := true
		local index, descriptor, parts

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

		loop % knowledgeBase.getValue("Controller.Function.Count", 0)
		{
			function := knowledgeBase.getValue("Controller.Function." . A_Index, false)

			if function
				knowledgeBase.removeFact("Controller.Function." . function . ".Triggers")

			knowledgeBase.removeFact("Controller.Function." . A_Index)
		}

		for ignore, function in functions {
			function := IsObject(function) ? function.Clone() : Array(function)

			name := function.RemoveAt(1)

			knowledgeBase.addFact("Controller.Function." . A_Index, name)

			if (function.Length() > 0)
				knowledgeBase.addFact("Controller.Function." . name . ".Triggers", values2String(" ### ", function*))
		}

		knowledgeBase.setFact("Controller.Function.Count", functions.Length())

		this.updateState()
	}

	getControllerFunctionTriggers(function) {
		return string2Values("###", this.KnowledgeBase.getValue("Controller.Function." . function . ".Triggers", ""))
	}

	setSimulatorActionFunctions(simulator, mode, functions) {
		local knowledgeBase := this.KnowledgeBase
		local count := 0
		local function, action

		loop % knowledgeBase.getValue("Simulator." . simulator . ".Mode." . mode . ".Action.Count", 0)
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
		local goal, result

		if this.iCachedActions.HasKey(simulator . mode . action)
			return this.iCachedActions[simulator . mode . action]
		else {
			goal := new RuleCompiler().compileGoal("simulatorActionAvailable?(" . StrReplace(simulator, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[simulator . mode . action] := result

			return result
		}
	}

	setSimulatorValue(simulator, key, value, update := true) {
		local oldCaseSense := A_StringCaseSense

		try {
			StringCaseSense On

			this.KnowledgeBase.setFact("Simulator." . simulator . ".Key." . key, value)
		}
		finally {
			StringCaseSense %oldCaseSense%
		}

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

		loop % knowledgeBase.getValue("Assistant." . assistant . ".Action.Count", 0)
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
		local goal, result

		if this.iCachedActions.HasKey(assistant . action)
			return this.iCachedActions[assistant . action]
		else {
			goal := new RuleCompiler().compileGoal("assistantActionAvailable?(" . StrReplace(assistant, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")")

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[assistant . action] := result

			return result
		}
	}

	assistantSimulators(assistant) {
		local knowledgeBase := this.KnowledgeBase
		local goal := new RuleCompiler().compileGoal("assistantSupportedSimulator?(" . StrReplace(assistant, A_Space, "\ ") . ", ?simulator)")
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
		this.KnowledgeBase.removeFact("Module." . module . ".Key." . key, "")

		if update
			this.updateState()
	}

	setModuleAvailableActions(module, mode, actions) {
		local knowledgeBase := this.KnowledgeBase
		local modeClause := (mode ? (".Mode." . mode) : "")
		local count := knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
		local index, action

		loop % count
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
		local modeClause := (mode ? (".Mode." . mode) : "")
		local function, action

		loop % knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
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
		local modeClause := (mode ? (".Mode." . mode) : "")
		local function := this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Function", false)

		if function {
			function := string2Values("|", function)

			return ((function.Length() == 1) ? function[1] : function)
		}
		else
			return ""
	}

	setModuleActionArguments(module, mode, arguments) {
		local knowledgeBase := this.KnowledgeBase
		local modeClause := (mode ? (".Mode." . mode) : "")
		local action, argument

		loop % knowledgeBase.getValue("Module." . module . modeClause . ".Action.Count", 0)
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
		local modeClause := (mode ? (".Mode." . mode) : "")

		return this.KnowledgeBase.getValue("Module." . module . modeClause . ".Action." . action . ".Argument", "")
	}

	moduleActionAvailable(module, mode, action) {
		local goal, result

		if this.iCachedActions.HasKey(module . mode . action)
			return this.iCachedActions[module . mode . action]
		else {
			if mode
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"
			else
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(action, A_Space, "\ ") . ")"

			goal := new RuleCompiler().compileGoal(goal)

			result := (this.KnowledgeBase.prove(goal) != false)

			this.iCachedActions[module . mode . action] := result

			return result
		}
	}

	moduleAvailableActions(module, mode) {
		local resultSet, variable, goal, actions

		if this.iCachedActions.HasKey(module . mode)
			return this.iCachedActions[module . mode]
		else {
			if mode
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", " . StrReplace(mode, A_Space, "\ ") . ", ?action)"
			else
				goal := "moduleActionAvailable?(" . StrReplace(module, A_Space, "\ ") . ", ?action)"

			goal := new RuleCompiler().compileGoal(goal)
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
		local window := this.HelpWindow

		Gui %window%:Default

		GuiControl Text, stepTitle, % title
	}

	setSubtitle(subtitle) {
		local window := this.HelpWindow

		Gui %window%:Default

		GuiControl Text, stepSubtitle, % translate("Step ") . this.Steps[this.Step] . translate(": ") . subtitle
	}

	setInfo(html) {
		local window := this.HelpWindow

		Gui %window%:Default

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . html . "</body></html>"

		infoViewer.Document.Open()
		infoViewer.Document.Write(html)
		infoViewer.Document.Close()
	}

	saveKnowledgeBase() {
		local savedKnowledgeBase := newConfiguration()

		setConfigurationSectionValues(savedKnowledgeBase, "Setup", this.KnowledgeBase.Facts.Facts)

		writeConfiguration(kUserHomeDirectory . "Setup\Setup.data", savedKnowledgeBase)
	}

	loadKnowledgeBase() {
		local knowledgeBase = this.KnowledgeBase
		local key, value

		if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
			for key, value in getConfigurationSectionValues(readConfiguration(kUserHomeDirectory . "Setup\Setup.data"), "Setup")
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
		local rules := {}
		local count := 0
		local descriptor, rule, index

		showProgress({message: translate("Step: ") . getConfigurationValue(definition, "Setup." . this.Step, this.Step . ".Subtitle." . getLanguage())})

		if isDebug()
			Sleep 250

		for descriptor, rule in getConfigurationSectionValues(definition, "Setup." . this.Step, Object())
			if (InStr(descriptor, this.Step . ".Rule") == 1) {
				index := string2Values(".", descriptor)[3]

				count := Max(count, index)

				rules[index] := rule
			}

		loop %count%
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
		throw "Virtual method StepWizard.createGui must be implemented in a subclass..."
	}

	registerWidget(page, widget) {
		if widget {
			if !this.iWidgets.HasKey(page)
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
		this.iWidgets := {}
	}

	show() {
		local language := getLanguage()
		local definition := this.SetupWizard.Definition

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
		local window := this.Window
		local ignore, widget

		Gui %window%:Default

		for ignore, widget in this.iWidgets[page] {
			GuiControl Show, %widget%
			GuiControl Enable, %widget%
		}
	}

	hidePage(page) {
		local window := this.Window
		local ignore, widget

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
		local window := this.Window
		local text, image, html, ignore, directory, currentDirectory
		local labelWidth, labelX, labelY, iconHandle, labelHandle, infoTextHandle, restartButtonHandle, info

		static imageViewer
		static imageViewerHandle
		static infoText

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

			x := x + Round((width - 240) / 2)

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

					Run Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File, , Hide
				}
				finally {
					SetWorkingDir %currentDirectory%
				}
			}
	}

	reset() {
		local volume

		base.reset()

		this.iImageViewer := false

		volume := fadeOut()

		try {
			SoundPlay NonExistent.avi
		}
		catch exception {
			logError(exception)
		}

		resetVolume(volume)
	}

	showPage(page) {
		local imageViewer, audio

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
		local volume

		if (page == 1) {
			volume := fadeOut()

			try {
				SoundPlay NonExistent.avi
			}
			catch exception {
				logError(exception)
			}

			resetVolume(volume)
		}

		if base.hidePage(page) {
			local imageViewer

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
		local window := this.Window
		local imageViewerHandle := false
		local image, text, html

		static imageViewer

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
		this.SetupWizard.SettingsOpen := true

		base.showPage(page)

		Task.startTask(ObjBindMethod(this, "openSettingsEditor"), 200, kLowPriority)
	}

	hidePage(page) {
		if base.hidePage(page) {
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
			if FileExist(kUserHomeDirectory . "Setup\Simulator Settings.ini")
				settings := readConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini")
			else
				settings := newConfiguration()

			configuration := this.SetupWizard.getSimulatorConfiguration()

			editSettings(settings, false, configuration
					   , Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 180, A_ScreenWidth - 360)
					   , "Center")

			this.SetupWizard.SettingsOpen := false
		}
	}

	closeSettingsEditor() {
		local settings := editSettings(kSave, false, true)

		writeConfiguration(kUserHomeDirectory . "Setup\Simulator Settings.ini", settings)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

finishSetup(finish := false, save := false) {
	local window, title, message

	if (finish = "Finish") {
		if (SetupWizard.Instance.SettingsOpen || SetupWizard.Instance.Working) {
			; Let other threads finish...

			Task.startTask(Func("finishSetup").Bind("Finish", save), 200)
		}
		else if SetupWizard.Instance.finishSetup(save)
			ExitApp 0
	}
	else {
		window := SetupWizard.Instance.WizardWindow

		Gui %window%:Show

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Setup")
		message := (translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the ""Simulator Controller\Config"" folder in your user ""Documents"" folder."))
		MsgBox 262436, %title%, %message%
		OnMessage(0x44, "")

		IfMsgBox Yes
			save := true
		else
			save := false

		Task.startTask(Func("finishSetup").Bind("Finish", save), 200)
	}
}

cancelSetup() {
	if SetupWizard.Instance.finishSetup(false)
		ExitApp 0
}

firstPage() {
	SetupWizard.Instance.firstPage()
}

previousPage() {
	SetupWizard.Instance.previousPage()
}

nextPage() {
	SetupWizard.Instance.nextPage()
}

lastPage() {
	SetupWizard.Instance.lastPage()
}

chooseLanguage() {
	local wizard := SetupWizard.Instance
	local code, language

	GuiControlGet languageDropDown

	for code, language in availableLanguages()
		if (language = languageDropDown) {
			if wizard.finishSetup(false) {
				setLanguage(code)

				wizard.Result := kLanguage
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
	moveByMouse(SetupWizard.Instance.WizardWindow, "Simulator Setup")
}

moveSetupHelp() {
	moveByMouse(SetupWizard.Instance.HelpWindow, "Simulator Setup.Help")
}

openSetupDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#setup
}

elevateAndRestart() {
	if !(A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)")) {
		try {
			if SetupWizard.Instance.Initialize
				deleteFile(kUserHomeDirectory . "Setup\Setup.data")

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

LV_ClickedColumn(listViewHandle) {
	local POINT, LVHITTESTINFO

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
	vdf := RegExReplace(vdf, """([^""]*)""\s*{", """${1}"": {")

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
	local exact, candidate, value

	loop 2 {
		exact := (A_Index = 1)

		loop Reg, %collection%, R
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

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Setup

	FileCreateDir %kUserHomeDirectory%Setup

	definition := readConfiguration(kResourcesDirectory . "Setup\Simulator Setup.ini")

	languages := string2Values("|", getConfigurationValue(definition, "Setup", "Languages"))

	if FileExist(kUserHomeDirectory . "Translations\Setup\Simulator Setup.ini") {
		for ignore, language in string2Values("|", getConfigurationValue(readConfiguration(kUserHomeDirectory . "Translations\Setup\Simulator Setup.ini")
																	   , "Setup", "Languages"))
			if !inList(languages, language)
				languages.Push(language)
	}

	setConfigurationValue(definition, "Setup", "Languages", values2String("|", languages*))

	for language, ignore in languages
		for ignore, root in [kResourcesDirectory, kUserHomeDirectory . "Translations\"]
			if FileExist(kUserHomeDirectory . "Setup\Simulator Setup." . language)
				for section, keyValues in readConfiguration(kUserHomeDirectory . "Setup\Simulator Setup." . language)
					for key, value in keyValues
						setConfigurationValue(definition, section, key, value)

	setConfigurationSectionValues(kSimulatorConfiguration, "Splash Window", getConfigurationSectionValues(definition, "Splash Window"))
	setConfigurationSectionValues(kSimulatorConfiguration, "Splash Themes", getConfigurationSectionValues(definition, "Splash Themes"))

	setConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", translate("Modular Simulator Controller System") . translate(" - ") . translate("Setup && Configuration"))

	wizard := new SetupWizard(kSimulatorConfiguration, definition)

	Menu SupportMenu, Insert, 1&

	label := translate("Debug Rule System")
	callback := ObjBindMethod(wizard, "toggleDebug", kDebugRules)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if wizard.Debug[kDebugRules]
		Menu SupportMenu, Check, %label%

	label := translate("Debug Knowledgebase")
	callback := ObjBindMethod(wizard, "toggleDebug", kDebugKnowledgeBase)

	Menu SupportMenu, Insert, 1&, %label%, %callback%

	if wizard.Debug[kDebugKnowledgeBase]
		Menu SupportMenu, Check, %label%

	showSplashTheme("Rotating Brain")

	wizard.ProgressCount := 0

	showProgress({color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("Preparing Configuration Steps...")})

	if isDebug()
		Sleep 500

	wizard.registerStepWizard(new StartStepWizard(wizard, "Start", kSimulatorConfiguration))
	wizard.registerStepWizard(new FinishStepWizard(wizard, "Finish", kSimulatorConfiguration))

	return
}

startupSimulatorSetup() {
	local wizard := SetupWizard.Instance
	local preset, previous

	wizard.loadDefinition()

	if wizard.Debug[kDebugRules]
		wizard.dumpRules(wizard.KnowledgeBase)

restartSetup:
	fixIE(10)

	wizard.createGui(wizard.Configuration)

	wizard.startSetup()

	while (wizard.ProgressCount < 100) {
		showProgress({progress: ++wizard.ProgressCount, message: translate("Starting UI...")})

		Sleep 5
	}

	showProgress({progress: 100, message: translate("Finished...")})

	Sleep 1000

	hideSplashTheme()
	hideProgress()

	wizard.show()

	try {
		loop {
			wizard.Working := false

			Sleep 200
		} until (wizard.Result == kLanguage)
	}
	finally {
		wizard.hide()
	}

	if (wizard.Result == kLanguage) {
		wizard.Result := false

		wizard.close()
		wizard.reset(false)

		setConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", translate("Modular Simulator Controller System") . translate(" - ") . translate("Setup && Configuration"))

		wizard.ProgressCount := 0

		showSplashTheme("Rotating Brain")
		showProgress({color: "Blue", title: translate("Initializing Setup Wizard"), message: translate("")})

		Goto restartSetup
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

openLabelsAndIconsEditor() {
	local owner := SetupWizard.Instance.WizardWindow

	Gui %owner%:+Disabled

	Gui PAE:+Owner%owner%

	new ControllerActionsEditor(kSimulatorConfiguration).editPluginActions()

	Gui %owner%:-Disabled
}

findSoftware(definition, software) {
	local ignore, section, name, descriptor, ignore, locator, value, folder, installPath, folders
	local fileName, exePath, jsScript, script

	for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getConfigurationSectionValues(definition, section, Object()) {
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
							RegRead value, % substituteVariables(Trim(StrReplace(locator, "RegistryExist:", "")))
						}
						catch exception {
							value := ""
						}

						if (value != "")
							return true
					}
					else if (InStr(locator, "RegistryScan:") == 1) {
						folder := findInstallProperty(substituteVariables(Trim(StrReplace(locator, "RegistryScan:", ""))), "InstallLocation")

						if ((folder != "") && FileExist(folder . descriptor[3]))
							return (folder . descriptor[3])
					}
					else if (InStr(locator, "Steam:") == 1) {
						locator := substituteVariables(Trim(StrReplace(locator, "Steam:", "")))

						try {
							RegRead installPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam, InstallPath
						}
						catch exception {
							installPath := ""
						}

						if (installPath != "") {
							try {
								FileRead script, %installPath%\steamapps\libraryfolders.vdf

								jsScript := convertVDF2JSON(script)

								folders := JSON.parse(jsScript)
								folders := folders["LibraryFolders"]

								for ignore, folder in folders {
									if IsObject(folder)
										folder := folder["path"]

									fileName := folder . "\steamapps\common\" . locator . "\" . descriptor[3]

									if FileExist(fileName)
										return fileName
								}
							}
							catch exception {
								;
							}
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
	local definition := SetupWizard.Instance.Definition
	local ignore, section, name, descriptor

	for ignore, section in ["Applications.Simulators", "Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getConfigurationSectionValues(definition, section, Object())
			if (name = application)
				return string2Values("|", descriptor)

	return false
}

fadeOut() {
	local masterVolume, currentVolume

	SoundGet masterVolume, MASTER

	if GetKeyState("Ctrl")
		SoundSet 0, MASTER
	else {
		currentVolume := masterVolume

		loop {
			currentVolume -= 5

			if (currentVolume <= 0)
				break
			else {
				SoundSet %currentVolume%, MASTER

				Sleep 200
			}
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
#Include Libraries\ControllerStepWizard.ahk
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