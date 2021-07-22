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
	iWizardWindow := "SW"
	iHelpWindow := "SH"
	
	iDefinition := false
	
	iSteps := {}
	iStepWizards := {}
	
	iStep := 0
	iPage := 0
	
	iSelectedModules := {}
	iInstalledSoftware := {}
	
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
	
	Steps[step := false] {
		Get {
			if step
				return this.iSteps[step]
			else
				return this.iSteps
		}
	}
	
	StepWizards[descriptor := false] {
		Get {
			if descriptor
				return this.iStepWizards[descriptor]
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
	
	Selected[module] {
		Get {
			return (this.iSelectedModules.HasKey(module) ? this.iSelectedModules[module] : false)
		}
	}
	
	Installed[software] {
		Get {
			return (this.iInstalledSoftware.HasKey(software) ? this.iInstalledSoftware[software] : false)
		}
	}
	
	__New(configuration, definition) {
		this.iDefinition := definition
		
		base.__New(configuration)
		
		SetupWizard.Instance := this
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
		Gui %window%:Color, D0D0D0

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w700 Center gmoveSetupWizard, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w700 cBlue Center gopenSetupDocumentation, % translate("Setup && Configuration")
		
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
		Gui %window%:Color, D0D0D0

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w350 Center gmoveSetupHelp VstepTitle, % translate("Title")
		
		Gui %window%:Font, s9 Norm, Arial

		Gui %window%:Add, Text, YP+20 w350 Center VstepSubtitle, % translate("Subtitle")
		
		Gui %window%:Add, Text, yp+20 w350 0x10
		
		Gui %window%:Add, ActiveX, x12 yp+10 w350 h545 vinfoViewer, shell explorer
	
		infoViewer.Navigate("about:blank")
		
		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

		infoViewer.Document.Write(html)
		
		this.createStepGuis()
	}
	
	createStepGuis(restart := false) {
		local stepWizard
		
		x := 0
		y := 0
		width := 0
		height := 0
		
		this.getWorkArea(x, y, width, height)
		
		for step, stepWizard in this.StepWizards
			if restart
				stepWizard.createGui(this)
			else
				stepWizard.createGui(this, x, y, width, height)
	}
	
	saveToConfiguration(configuration) {
		local stepWizard
		
		base.saveToConfiguration(configuration)
		
		for ignore, stepWizard in this.StepWizards
			stepWizard.saveToConfiguration(configuration)
	}

	restart() {
		this.show(true)
		
		Loop % this.StepWizards.Count()
			this.Steps[A_Index].restart()
	}
	
	show(restart := false) {
		static first := true
		
		if restart
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
		local stepWizard
		
		if (this.Steps.Count() == 0)
			for descriptor, definition in getConfigurationSectionValues(this.Definition, "Setup.Steps") {
				descriptor := string2Values(".", descriptor)
			
				step := descriptor[3]
				stepWizard := this.StepWizards[step]
				
				stepWizard.setDefinition(definition)
				
				this.Steps[step] := stepWizard
				this.Steps[descriptor[2]] := stepWizard
				this.Steps[stepWizard] := descriptor[2]
			}
		
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
					
						if (candidate.Active && (candidate.Pages > 0)) {
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
			count := this.StepWizards.Count()
		
			if !this.Step
				index := 1
			else
				index := this.Steps[this.Step] + 1
			
			Loop {
				if (index > count)
					return false
				else {
					candidate := this.Steps[index++]
				
					if (candidate.Active && (candidate.Pages > 0)) {
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
		
		if this.Step {
			this.Step.hidePage(this.Page)
			
			if (step != this.Step)
				hide := true
		}
		
		this.iStep := step
		this.iPage := page
		
		if change
			this.Step.show()
		
		this.Step.showPage(page)
		
		this.updateState()
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
		
		Loop % this.StepWizards.Count()
			this.Steps[A_Index].updateState()
	}
	
	selectModule(module, selected) {
		this.iSelectedModules[module] := selected
		
		this.updateState()
	}
	
	locateSoftware(software, executable) {
		this.iInstalledSoftware[software] := executable
		
		this.updateState()
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
	
	setDefinition(definition) {
		this.iDefinition := definition
	}
	
	restart() {
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
	createGui(wizard, x := false, y := false, width := false, height := false) {
		static imageViewer
		static imageViewerHandle
		
		if x {
			window := this.Window
			
			Gui %window%:Add, ActiveX, x%x% y%y% w%width% h%height% HWNDimageViewerHandle VimageViewer Hidden, shell explorer
		
			text := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Text." . getLanguage()))
			image := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Start", "Start.Image"))
			
			text := "<div style='text-align: center' style='font-family: Arial, Helvetica, sans-serif' style='font-size: 12px'>" . text . "</div>"
			
			height := Round(width / 16 * 9)
			
			html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><br>" . text . "<br><img src='" . image . "' width='" . width . "' height='" . height . "' border='0' padding='0'></body></html>"

			imageViewer.Navigate("about:blank")
			imageViewer.document.write(html)
			
			this.registerWidget(1, imageViewerHandle)
		}
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
	
	createGui(wizard, x := false, y := false, width := false, height := false) {
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
		
		if !x {
			definition := this.Definition
			
			this.getWorkArea(x, y, width, height)
			
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
				selected := this.SetupWizard.Selected(module)
				
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
				Gui %window%:Add, CheckBox, Checked%selected% x%checkX% y%y% w23 h23 HWNDcheckBoxHandle Hidden gupdateSelectedModules
				Gui %window%:Add, ActiveX, x%x% yp+33 w%width% h120 HWNDinfoTextHandle VinfoText%A_Index% Hidden, shell explorer
	
				html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

				infoText%A_Index%.Navigate("about:blank")
				infoText%A_Index%.document.write(html)
		
				y += 170
				
				this.iModuleSelectors.Push(checkBoxHandle)
				
				this.registerWidgets(Ceil(A_Index / 3), iconHandle, labelHandle, checkBoxHandle, infoTextHandle)
				
				if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
					y := startY
			}
		}
	}
	
	restart() {
		base.restart()
		
		this.iModuleSelectors := []
	}
	
	setDefinition(definition) {
		definition := string2Values("|", definition)
		
		base.setDefinition(definition)
		
		for ignore, module in definition
			this.SetupWizard.selectModule(module, true)
		
		this.createGui(this.SetupWizard)
	}
	
	updateSelectedModules() {
		definition := this.Definition
		
		Loop % definition.Length()
		{
			variable := this.iModuleSelectors[A_Index]
			
			GuiControlGet %variable%
			
			this.SetupWizard.selectModule(definition[A_Index], %variable%)
		}
	}
}


;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; InstallationStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class InstallationStepWizard extends StepWizard {
	iSoftware := []
	iRules := {}
	iPages := {}
	
	iSoftwareLocators := {}
	
	Pages[] {
		Get {
			return Ceil(this.iSoftware.Length() / 3)
		}
	}
	
	createGui(wizard, x := false, y := false, width := false, height := false) {
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
		
		if !x {
			definition := this.Definition
		
			this.getWorkArea(x, y, width, height)
			
			startY := y
			
			if (this.iSoftware.Count() > 16)
				Throw "Too many modules detected in InstallationStepWizard.createGui..."
			
			window := this.Window
		
			for ignore, software in this.iSoftware
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
				
				installed := this.SetupWizard.Installed[software]
				
				buttonX := x + width - 90
				
				if locatable
					buttonX -= 95
				
				labelWidth := width - 30 - 90 - (locatable * 95)
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
				infoText%A_Index%.document.write(html)
		
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
	}
	
	restart() {
		base.restart()
		
		this.iPages := {}
		this.iSoftwareLocators := {}
	}
	
	setDefinition(definition) {
		definition := string2Values("|", definition)
		
		base.setDefinition(definition)
		
		for ignore, rule in definition {
			name := this.softwareName(rule)
		
			this.iSoftware.Push(name)
			this.iRules[name] := rule
		
			executable := findExecutable(this.SetupWizard.Definition, name)
			
			if (executable != "")
				this.SetupWizard.locateSoftware(name, executable)
		}
		
		this.createGui(this.SetupWizard)
	}
	
	softwareName(rule) {
		if (InStr(rule, "[") == 1)
			return string2Values("=>", StrReplace(StrReplace(rule, "[", ""), "]", ""))[2]
		else
			return rule
	}
			
	softwareActive(rule) {
		if (InStr(rule, "[") == 1)
			return this.SetupWizard.Selected[string2Values("=>", StrReplace(StrReplace(rule, "[", ""), "]", ""))[1]]
		else
			return true
	}
	
	softwareInstall(rule) {
		Run % substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Installation", "Installation." . this.softwareName(rule)))
	}
	
	softwareLocate(rule, executable) {
		software := this.softwareName(rule)
		
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
			if !this.softwareActive(this.iRules[software])
				for ignore, widget in widgets
					GuiControl Disable, %widget%
			else if (this.SetupWizard.Installed[software] && this.iSoftwareLocators.HasKey(software)) {
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
	
	updateState() {
		for ignore, rule in this.Definition
			this.iActiveSoftware[this.SoftwareName(rule)] := this.softwareActive(rule)
	}
}


;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsStepWizard                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ApplicationsStepWizard extends StepWizard {
	Pages[] {
		Get {
			return 1
		}
	}
	
	createGui(wizard, x := false, y := false, width := false, height := false) {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveAndExit() {
	vResult := kOk
}

cancelAndExit() {
	vResult := kCancel
}

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

updateSelectedModules() {
	SetupWizard.Instance.StepWizards["Modules"].updateSelectedModules()
}

installSoftware() {
	local stepWizard := SetupWizard.Instance.StepWizards["Installation"]
	
	definition := stepWizard.Definition
	
	stepWizard.softwareInstall(definition[StrReplace(A_GuiControl, "installButton", "")])
}

locateSoftware() {
	local stepWizard := SetupWizard.Instance.StepWizards["Installation"]
	
	definition := stepWizard.Definition
	definition := definition[StrReplace(A_GuiControl, "locateButton", "")]
	
	name := stepWizard.softwareName(definition)
	executable := findExecutable(this.SetupWizard.Definition, name)
	
	if executable
		stepWizard.softwareLocate(definition, executable)
	else {
		protectionOn()
		
		try {
			title := substituteVariables(translate("Select %name% executable..."), {name: name})
			
			FileSelectFile file, 1, , %title%, Executable (*.exe)
			
			if (file != "")
				stepWizard.softwareLocate(definition, file)
		}
		finally {
			protectionOff()
		}
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

findApplicationInstallPath(name) {
	value := findInRegistry("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, "InstallLocation")
	
	if (value != "")
		return value
	
	value := findInRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, "InstallLocation")
	
	if (value != "")
		return value
	
	value := findInRegistry("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", name, "InstallLocation")
	
	if (value != "")
		return value
}

findExecutable(definition, software) {
	for ignore, section in ["Applications.Core", "Applications.Feedback", "Applications.Other", "Applications.Special"]
		for name, descriptor in getConfigurationSectionValues(definition, section, Object()) {
			descriptor := string2Values("|", descriptor)
		
			if (software = descriptor[1]) {
				locator := descriptor[2]
				
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
					folder := findApplicationInstallPath(substituteVariables(StrReplace(locator, "RegistryScan:", "")))
			
					if ((folder != "") && FileExist(folder . descriptor[3]))
						return (folder . descriptor[3])
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
	
	protectionOn()
	
	try {
		definition := readConfiguration(kResourcesDirectory . "Setup\Simulator Setup.ini")
		
		wizard := new SetupWizard(kSimulatorConfiguration, definition)
		
		wizard.registerStepWizard(new StartStepWizard(wizard, "Start", kSimulatorConfiguration))
		wizard.registerStepWizard(new ModulesStepWizard(wizard, "Modules", kSimulatorConfiguration))
		wizard.registerStepWizard(new InstallationStepWizard(wizard, "Installation", kSimulatorConfiguration))
		wizard.registerStepWizard(new ApplicationsStepWizard(wizard, "Applications", kSimulatorConfiguration))
	}
	finally {
		protectionOff()
	}
}

startupSimulatorSetup() {
	static restart := false
	
restart:
	wizard := SetupWizard.Instance
	
	wizard.createGui(wizard.Configuration)
	
	if restart
		wizard.createStepGuis(true)
	
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
		wizard.restart()
		
		restart := true
		
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
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin	
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
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