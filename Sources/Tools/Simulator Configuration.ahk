;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Configuration Tool    ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Configuration.ico
;@Ahk2Exe-ExeName Simulator Configuration.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kApply = "apply"
global kOk = "ok"
global kCancel = "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vResult = false

global vShowKeyDetector = false
global vKeyDetectorCallback = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationItemList                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationItemList extends ConfigurationItem {
	static sListControls := {}
	
	iListHandle := false
	iAddButton := ""
	iDeleteButton := ""
	iUpdateButton := ""
	iUpButton := false
	iDownButton := false
	
	iItemsList := []
	iCurrentItemIndex := 0
	
	ListHandle[] {
		Get {
			return this.iListHandle
		}
	}
	
	initializeList(listHandle, listVariable, addButton := false, deleteButton := false, updateButton := false, upButton := false, downButton := false) {
		this.iListHandle := listHandle
		this.iAddButton := addButton
		this.iDeleteButton := deleteButton
		this.iUpdateButton := updateButton
		this.iUpButton := upButton
		this.iDownButton := downButton
		
		ConfigurationItemList.associateList(listVariable, this)
		
		if addButton
			ConfigurationItemList.associateList(addButton, this)
		
		if deleteButton
			ConfigurationItemList.associateList(deleteButton, this)
		
		if updateButton
			ConfigurationItemList.associateList(updateButton, this)
		
		if upButton
			ConfigurationItemList.associateList(upButton, this)
		
		if downButton
			ConfigurationItemList.associateList(downButton, this)
		
		this.loadList(this.iItemsList)
		this.updateState()
	}
	
	saveToConfiguration(configuration) {
		if ConfigurationEditor.Instance.AutoSave {
			if (this.iCurrentItemIndex != 0) {
				this.updateItem()
			}
		}
	}

	associateList(variable, itemList) {
		ConfigurationItemList.sListControls[variable] := itemList
	}
	
	getList(variable) {
		return ConfigurationItemList.sListControls[variable]
	}
	
	clickEvent(line, count) {
		this.openEditor(line)
	}
	
	selectEvent(line) {
		this.openEditor(line)
	}
	
	processListEvent() {
		local event
		
		static lastEvent := false
		static lastEditor := false
		
		event := (A_GuiEvent . " " . A_GuiControl . " " . A_EventInfo)
		
		if (event = lastEvent)
			return false
		else {
			lastEvent := event
		
			return true
		}
		
		editor := (A_GuiControl . "." . A_EventInfo)
		
		if (editor = lastEditor)
			return false
		else {
			lastEditor := editor
		
			return true
		}
	}
	
	listEvent() {
		info := ErrorLevel
		
		if this.processListEvent() {
			if (A_GuiEvent == "DoubleClick")
				this.clickEvent(A_EventInfo, 2)
			else if (A_GuiEvent == "Normal")
				this.clickEvent(A_EventInfo, 1)
			else if (A_GuiEvent == "I") {
				if InStr(info, "S", true)
					this.selectEvent(A_EventInfo)
			}
		}
	}
	
	loadList(items) {
		Throw "Virtual method ConfigurationItemList.loadList must be implemented in a subclass..."
	}
	
	updateState() {
		if (this.iCurrentItemIndex != 0) {
			if (this.iDeleteButton != false)
				GuiControl Enable, % this.iDeleteButton
			if (this.iUpdateButton != false)
				GuiControl Enable, % this.iUpdateButton
			
			if (this.iUpButton != false)
				if (this.iCurrentItemIndex > 1)
					GuiControl Enable, % this.iUpButton
				else
					GuiControl Disable, % this.iUpButton
			
			if (this.iDownButton != false)
				if (this.iCurrentItemIndex < this.iItemsList.Length())
					GuiControl Enable, % this.iDownButton
				else
					GuiControl Disable, % this.iDownButton
		}
		else {
			if (this.iUpButton != false)
				GuiControl Disable, % this.iUpButton
			
			if (this.iDownButton != false)
				GuiControl Disable, % this.iDownButton
			
			if (this.iDeleteButton != false)
				GuiControl Disable, % this.iDeleteButton
			if (this.iUpdateButton != false)
				GuiControl Disable, % this.iUpdateButton
		}
	}
	
	loadEditor(item) {
		Throw "Virtual method ConfigurationItemList.loadEditor must be implemented in a subclass..."
	}
	
	clearEditor() {
		Throw "Virtual method ConfigurationItemList.clearEditor must be implemented in a subclass..."
	}
	
	buildItemFromEditor(isNew := false) {
		Throw "Virtual method ConfigurationItemList.buildItemFromEditor must be implemented in a subclass..."
	}
	
	openEditor(itemNumber) {
		if (itemNumber != this.iCurrentItemIndex){
			if ConfigurationEditor.Instance.AutoSave {
				if (this.iCurrentItemIndex != 0)
					this.updateItem()
					
				this.selectItem(itemNumber)
			}
			
			this.iCurrentItemIndex := itemNumber
			
			this.loadEditor(this.iItemsList[this.iCurrentItemIndex])
			
			this.updateState()
		}
	}
	
	selectItem(itemNumber) {
		this.iCurrentItemIndex := itemNumber
		
		Gui ListView, % this.ListHandle
			
		if itemNumber
			LV_Modify(itemNumber, "Vis +Select +Focus")
		
		this.updateState()
	}
	
	addItem() {
		item := this.buildItemFromEditor(true)
		
		if item {
			this.iItemsList.Push(item)
		
			this.loadList(this.iItemsList)
			
			this.selectItem(inList(this.iItemsList, item))
		}
	}
	
	deleteItem() {
		this.iItemsList.RemoveAt(this.iCurrentItemIndex)
		
		this.loadList(this.iItemsList)
		
		this.clearEditor()
		
		this.iCurrentItemIndex := 0
		
		this.updateState()
	}

	updateItem() {
		static recurse := false
		
		if recurse
			return
		else {
			recurse := true
		
			try {
				item := this.buildItemFromEditor()
				
				if item {
					this.iItemsList[this.iCurrentItemIndex] := item
					
					this.loadList(this.iItemsList)
					
					this.selectItem(this.iCurrentItemIndex)
				}
			}
			finally {
				recurse := false
			}
		}
	}

	upItem() {
		item := this.iItemsList[this.iCurrentItemIndex]
		
		this.iItemsList[this.iCurrentItemIndex] := this.iItemsList[this.iCurrentItemIndex - 1]
		this.iItemsList[this.iCurrentItemIndex - 1] := item
		
		this.loadList(this.iItemsList)
			
		this.selectItem(this.iCurrentItemIndex - 1)
		
		this.updateState()
	}

	downItem() {
		item := this.iItemsList[this.iCurrentItemIndex]
		
		this.iItemsList[this.iCurrentItemIndex] := this.iItemsList[this.iCurrentItemIndex + 1]
		this.iItemsList[this.iCurrentItemIndex + 1] := item
		
		this.loadList(this.iItemsList)
			
		this.selectItem(this.iCurrentItemIndex + 1)
		
		this.updateState()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationEditor                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global saveModeDropDown

class ConfigurationEditor extends ConfigurationItem {
	iWindow := "SE"
	iGeneralTab := false
	
	iConfigurators := []
	
	iDevelopment := false
	iSaveMode := false
	
	Configurators[] {
		Get {
			return this.iConfigurators
		}
	}
	
	AutoSave[] {
		Get {
			return (this.iSaveMode = "Auto")
		}
	}
	
	Window[] {
		Get {
			return this.iWindow
		}
	}
	
	__New(development, configuration) {
		this.iDevelopment := development
		this.iGeneralTab := new GeneralTab(development, configuration)
		
		base.__New(configuration)
		
		ConfigurationEditor.Instance := this
	}
	
	registerConfigurator(label, configurator) {
		this.Configurators.Push(Array(label, configurator))
	}
	
	unregisterConfigurator(labelOrConfigurator) {
		for ignore, configurator in this.Configurators
			if ((configurator[1] = labelOrConfigurator) || (configurator[2] = labelOrConfigurator)) {
				this.Configurators.RemoveAt(A_Index)
			
				break
			}
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
	
		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, w478 Center gmoveConfigurationEditor, % translate("Modular Simulator Controller System") 
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, YP+20 w478 cBlue Center gopenConfigurationDocumentation, % translate("Configuration")

		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Button, x232 y528 w80 h23 Default gsaveAndExit, % translate("Save")
		Gui %window%:Add, Button, x320 y528 w80 h23 gcancelAndExit, % translate("&Cancel")
		Gui %window%:Add, Button, x408 y528 w77 h23 gsaveAndStay, % translate("&Apply")
		
		choices := ["Auto", "Manual"]
		chosen := inList(choices, saveModeDropDown)
		
		Gui %window%:Add, Text, x8 y528 w55 h23 +0x200, % translate("Save")
		Gui %window%:Add, DropDownList, x63 y528 w75 AltSubmit Choose%chosen% gupdateSaveMode VsaveModeDropDown, % values2String("|", map(choices, "translate")*)
		
		labels := []
		
		for ignore, configurator in this.Configurators
			labels.Push(configurator[1])

		Gui %window%:Add, Tab3, x8 y48 w478 h472 -Wrap, % values2String("|", concatenate(Array(translate("General")), labels)*)
		
		tab := 1
		
		Gui %window%:Tab, % tab++
		
		this.iGeneralTab.createGui(this, 16, 80, 458, 425)
		
		for ignore, configurator in this.Configurators {
			Gui %window%:Tab, % tab++
		
			configurator[2].createGui(this, 16, 80, 458, 425)
		}
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSaveMode := getConfigurationValue(configuration, "General", "Save", "Manual")
		
		saveModeDropDown := this.iSaveMode
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		GuiControlGet saveModeDropDown
		
		this.iSaveMode := ["Auto", "Manual"][saveModeDropDown]
		
		setConfigurationValue(configuration, "General", "Save", this.iSaveMode)
		
		this.iGeneralTab.saveToConfiguration(configuration)
		
		if this.iDevelopment
			this.iDevelopmentTab.saveToConfiguration(configuration)
		
		for ignore, configurator in this.Configurators
			configurator[2].saveToConfiguration(configuration)
	}
	
	show() {
		window := this.Window
		
		Gui %window%:Show, AutoSize Center
	}
	
	hide() {
		window := this.Window
		
		Gui %window%:Hide
	}
	
	close() {
		window := this.Window
		
		Gui %window%:Destroy
	}
	
	toggleKeyDetector(callback := false) {
		if callback {
			if !vShowKeyDetector
				vKeyDetectorCallback := callback
		}
		else
			vKeyDetectorCallback := false
	
		vShowKeyDetector := !vShowKeyDetector
		
		if vShowKeyDetector
			SetTimer showKeyDetector, -100
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; GeneralTab                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global nirCmdPathEdit
global homePathEdit

global languageDropDown
global startWithWindowsCheck
global silentModeCheck

global ahkPathEdit
global msBuildPathEdit
global debugEnabledCheck
global logLevelDropDown

class GeneralTab extends ConfigurationItem {
	iSimulatorsList := false
	iDevelopment := false
	iSplashThemesConfiguration := false
	
	__New(development, configuration) {
		this.iDevelopment := development
		this.iSimulatorsList := new SimulatorsList(configuration)
		
		base.__New(configuration)
		
		GeneralTab.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y80 w458 h70, % translate("Installation")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x24 y97 w160 h23 +0x200, % translate("Installation Folder (optional)")
		Gui %window%:Add, Edit, x224 y97 w214 h21 VhomePathEdit, %homePathEdit%
		Gui %window%:Add, Button, x440 y96 w23 h23 gchooseHomePath, % translate("...")
		
		Gui %window%:Add, Text, x24 y121 w160 h23 +0x200, % translate("NirCmd Folder (optional)")
		Gui %window%:Add, Edit, x224 y121 w214 h21 VnirCmdPathEdit, %nirCmdPathEdit%
		Gui %window%:Add, Button, x440 y120 w23 h23 gchooseNirCmdPath, % translate("...")
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y160 w458 h95, % translate("Settings")
		
		Gui %window%:Font, Norm, Arial
		
		choices := []
		chosen := 0
		enIndex := 0
		
		for code, language in availableLanguages() {
			choices.Push(language)
			
			if (language == languageDropDown)
				chosen := A_Index
				
			if (code = "en")
				enIndex := A_Index
		}
		
		if (chosen == 0)
			chosen := enIndex
			
		Gui %window%:Add, Text, x24 y176 w86 h23 +0x200, % translate("Language")
		Gui %window%:Add, DropDownList, x224 y176 w214 Choose%chosen% VlanguageDropDown, % values2String("|", choices*)
		Gui %window%:Add, Button, x440 y175 w23 h23 gopenTranslationsEditor, % translate("...")
		
		Gui %window%:Add, CheckBox, x24 y200 w242 h23 Checked%startWithWindowsCheck% VstartWithWindowsCheck, % translate("Start with Windows")
		Gui %window%:Add, CheckBox, x24 y224 w242 h23 Checked%silentModeCheck% VsilentModeCheck, % translate("Silent mode (no splash screen, no sound)")
		
		Gui %window%:Add, Button, x363 y224 w100 h23 GopenThemesEditor, % translate("Themes Editor...")
	
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y265 w458 h115, % translate("Simulators")
		
		Gui %window%:Font, Norm, Arial
		
		this.iSimulatorsList.createGui(editor, x, y, width, height)
		
		if this.iDevelopment {
			Gui %window%:Font, Norm, Arial
			Gui %window%:Font, Italic, Arial
			
			Gui %window%:Add, GroupBox, x16 y388 w458 h119, % translate("Development")
			
			Gui %window%:Font, Norm, Arial
			
			Gui %window%:Add, Text, x24 y405 w160 h23 +0x200, % translate("AutoHotkey Folder")
			Gui %window%:Add, Edit, x224 y406 w214 h21 VahkPathEdit, %ahkPathEdit%
			Gui %window%:Add, Button, x440 y404 w23 h23 gchooseAHKPath, % translate("...")
			
			Gui %window%:Add, Text, x24 y429 w160 h23 +0x200, % translate("MSBuild Bin Folder")
			Gui %window%:Add, Edit, x224 y429 w214 h21 VmsBuildPathEdit, %msBuildPathEdit%
			Gui %window%:Add, Button, x440 y428 w23 h23 gchooseMSBuildPath, % translate("...")
			
			Gui %window%:Add, Text, x24 y453 w160 h23 +0x200, % translate("Debug")
			Gui %window%:Add, CheckBox, x226 y451 w242 h23 Checked%debugEnabledCheck% VdebugEnabledCheck, % translate("Enabled?")
			
			Gui %window%:Add, Text, x24 y477 w160 h23 +0x200, % translate("Log Level")
			
			choices := ["Info", "Warn", "Critical", "Off"]
			
			chosen := inList(choices, logLevelDropDown)
			
			if !chosen
				chosem := 2
				
			Gui %window%:Add, DropDownList, x224 y477 w91 Choose%chosen% VlogLevelDropDown, % values2String("|", map(choices, "translate")*)
		}
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		nirCmdPathEdit := getConfigurationValue(configuration, "Configuration", "NirCmd Path", "")
		homePathEdit := getConfigurationValue(configuration, "Configuration", "Home Path", "")
		
		languageDropDown := availableLanguages()[getConfigurationValue(configuration, "Configuration", "Language", getLanguage())]
		startWithWindowsCheck := getConfigurationValue(configuration, "Configuration", "Start With Windows", true)
		silentModeCheck := getConfigurationValue(configuration, "Configuration", "Silent Mode", false)
		
		if this.iDevelopment {
			ahkPathEdit := getConfigurationValue(configuration, "Configuration", "AHK Path", "")
			msBuildPathEdit := getConfigurationValue(configuration, "Configuration", "MSBuild Path", "")
			debugEnabledCheck := getConfigurationValue(configuration, "Configuration", "Debug", false)
			logLevelDropDown := getConfigurationValue(configuration, "Configuration", "Log Level", "Warn")
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		GuiControlGet nirCmdPathEdit
		GuiControlGet homePathEdit
		
		GuiControlGet languageDropDown
		GuiControlGet startWithWindowsCheck
		GuiControlGet silentModeCheck
		
		setConfigurationValue(configuration, "Configuration", "NirCmd Path", nirCmdPathEdit)
		setConfigurationValue(configuration, "Configuration", "Home Path", homePathEdit)
		
		languageCode := "en"
		
		for code, language in availableLanguages()
			if (language = languageDropDown) {
				languageCode := code
				
				break
			}
			
		setConfigurationValue(configuration, "Configuration", "Language", languageCode)
		setConfigurationValue(configuration, "Configuration", "Start With Windows", startWithWindowsCheck)
		setConfigurationValue(configuration, "Configuration", "Silent Mode", silentModeCheck)
		
		if this.iSplashThemesConfiguration
			setConfigurationValues(configuration, this.iSplashThemesConfiguration)
		else {
			setConfigurationSectionValues(configuration, "Splash Window", getConfigurationSectionValues(this.Configuration, "Splash Window", Object()))
			setConfigurationSectionValues(configuration, "Splash Themes", getConfigurationSectionValues(this.Configuration, "Splash Themes", Object()))
		}
		
		if this.iDevelopment {
			GuiControlGet ahkPathEdit
			GuiControlGet msBuildPathEdit
			GuiControlGet debugEnabledCheck
			GuiControlGet logLevelDropDown
		
			setConfigurationValue(configuration, "Configuration", "AHK Path", ahkPathEdit)
			setConfigurationValue(configuration, "Configuration", "MSBuild Path", msBuildPathEdit)
			setConfigurationValue(configuration, "Configuration", "Debug", debugEnabledCheck)
			
			choices := ["Info", "Warn", "Critical", "Off"]
			
			setConfigurationValue(configuration, "Configuration", "Log Level", choices[inList(map(choices, "translate"), logLevelDropDown)])
		}
		
		this.iSimulatorsList.saveToConfiguration(configuration)
	}
	
	openTranslationsEditor() {
		GuiControlGet languageDropDown
		
		ConfigurationEditor.Instance.hide()
		
		if (new TranslationsEditor(this.Configuration)).editTranslations() {
			ConfigurationEditor.Instance.show()
			
			window := ConfigurationEditor.Instance.Window
			
			Gui %window%:Default
			
			choices := []
			chosen := 0
			enIndex := 1
			
			for code, language in availableLanguages() {
				choices.Push(language)
				
				if (language == languageDropDown)
					chosen := A_Index
				
				if (code = "en")
					enIndex := A_Index
			}
			
			if (chosen == 0) {
				chosen := enIndex
				languageDropDown := "English"
			}
			
			GuiControl, , languageDropDown, % "|" . values2String("|", choices*)
			GuiControl Choose, languageDropDown, %chosen%
		}
		else
			ConfigurationEditor.Instance.show()
	}
	
	openThemesEditor() {
		ConfigurationEditor.Instance.hide()
		
		this.iSplashThemesConfiguration := (new ThemesEditor(this.iSplashThemesConfiguration ? this.iSplashThemesConfiguration : this.Configuration)).editThemes()
		
		ConfigurationEditor.Instance.show()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SimulatorsList                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorsListBox := "|"

global simulatorEdit = ""

global simulatorUpButton
global simulatorDownButton

global simulatorAddButton
global simulatorDeleteButton
global simulatorUpdateButton
		
class SimulatorsList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		SimulatorsList.Instance := this
	}
					
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Add, ListBox, x24 y284 w194 h96 HwndsimulatorsListBoxHandle VsimulatorsListBox glistEvent, %simulatorsListBox%
		
		Gui %window%:Add, Edit, x224 y284 w239 h21 VsimulatorEdit, %simulatorEdit%
		
		Gui %window%:Add, Button, x385 y309 w38 h23 Disabled VsimulatorUpButton gupItem, % translate("Up")
		Gui %window%:Add, Button, x425 y309 w38 h23 Disabled VsimulatorDownButton gdownItem, % translate("Down")
		
		Gui %window%:Add, Button, x264 y349 w46 h23 VsimulatorAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y349 w50 h23 Disabled VsimulatorDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x408 y349 w55 h23 Disabled VsimulatorUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(simulatorsListBoxHandle, "simulatorsListBox", "simulatorAddButton", "simulatorDeleteButton", "simulatorUpdateButton"
						  , "simulatorUpButton", "simulatorDownButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iItemsList := string2Values("|", getConfigurationValue(configuration, "Configuration", "Simulators", ""))
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "Configuration", "Simulators", values2String("|", this.iItemsList*))	
	}
	
	clickEvent(line, count) {
		GuiControlGet simulatorsListBox
					
		this.openEditor(inList(this.iItemsList, simulatorsListBox))
	}
	
	processListEvent() {
		return true
	}
	
	loadList(items) {
		simulatorsListBox := values2String("|", this.iItemsList*)
	
		GuiControl, , simulatorsListBox, % "|" . simulatorsListBox
	}
	
	selectItem(itemNumber) {
		this.iCurrentItemIndex := itemNumber
		
		if itemNumber
			GuiControl Choose, simulatorsListBox, %itemNumber%
		
		this.updateState()
	}
	
	loadEditor(item) {
		simulatorEdit := item
			
		GuiControl Text, simulatorEdit, %simulatorEdit%
	}
	
	clearEditor() {
		this.loadEditor("")
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet simulatorEdit
		
		return simulatorEdit
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ThemesEditor                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global windowTitleEdit = ""
global windowSubtitleEdit = ""

class ThemesEditor extends ConfigurationItem {
	iClosed := false
	iThemesList := false
	
	__New(configuration) {
		this.iThemesList := new ThemesList(configuration)
		
		base.__New(configuration)
		
		ThemesEditor.Instance := this
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Gui TE:Default
	
		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0

		Gui TE:Font, Bold, Arial

		Gui TE:Add, Text, w388 Center gmoveThemesEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic Underline, Arial

		Gui TE:Add, Text, YP+20 w388 cBlue Center gopenThemesDocumentation, % translate("Themes")

		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x16 y48 w160 h23 +0x200, % translate("Upper Title")
		Gui TE:Add, Edit, x110 y48 w284 h21 VwindowTitleEdit, %windowTitleEdit%
		
		Gui TE:Add, Text, x16 y72 w160 h23 +0x200, % translate("Lower Title")
		Gui TE:Add, Edit, x110 y72 w284 h21 VwindowSubtitleEdit, %windowSubtitleEdit%
		
		Gui TE:Add, Text, x50 y106 w310 0x10
		
		this.iThemesList.createGui(configuration)
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		Gui TE:Add, Button, x126 yp+10 w80 h23 Default GsaveThemesEditor, % translate("Save")
		Gui TE:Add, Button, x214 yp w80 h23 GcancelThemesEditor, % translate("&Cancel")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		windowTitleEdit := getConfigurationValue(configuration, "Splash Window", "Title", "")
		windowSubtitleEdit := getConfigurationValue(configuration, "Splash Window", "Subtitle", "")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "Splash Window", "Title", windowTitleEdit)
		setConfigurationValue(configuration, "Splash Window", "Subtitle", windowSubtitleEdit)
		
		this.iThemesList.saveToConfiguration(configuration)
	}
	
	editThemes() {
		this.iThemesList.clearEditor()
		
		Gui TE:Show, AutoSize Center
		
		Loop
			Sleep 200
		until this.iClosed
		
		try {
			if (this.iClosed == kOk) {
				configuration := newConfiguration()
				
				this.saveToConfiguration(configuration)
			
				return configuration
			}
			else
				return false
		}
		finally {
			Gui TE:Destroy
		}
	}
	
	closeEditor(save) {
		if save
			Gui TE:Submit
		
		this.iThemesList.togglePlaySoundFile(true)
		
		this.iClosed := (save ? kOk : kCancel)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ThemesList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global themesListView = false
global themeNameEdit = ""
global themeTypeDropDown = 0

global playSoundButtonHandle
global soundFilePathEdit = ""

global videoFilePathLabel
global videoFilePathEdit = ""
global videoFilePathButton

global picturesListLabel
global addPictureButton
global picturesListView
global picturesListViewHandle
global picturesListViewImages
global picturesDurationLabel
global picturesDurationEdit = 3000
global picturesDurationPostfix

global themeAddButton
global themeDeleteButton
global themeUpdateButton
		
class ThemesList extends ConfigurationItemList {
	iSoundIsPlaying := false
	
	__New(configuration) {
		base.__New(configuration)
				 
		ThemesList.Instance := this
	}
					
	createGui(configuration) {
		Gui TE:Add, ListView, x16 y120 w377 h140 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndthemesListViewHandle VthemesListView glistEvent
							, % values2String("|", map(["Theme", "Media", "Sound File"], "translate")*)
		
		Gui TE:Add, Text, x16 y270 w86 h23 +0x200, % translate("Theme")
		Gui TE:Add, Edit, x110 y270 w140 h21 VthemeNameEdit, %themeNameEdit%
		
		Gui TE:Add, Text, x16 y294 w86 h23 +0x200, % translate("Type")
		Gui TE:Add, DropDownList, x110 y294 w140 AltSubmit VthemeTypeDropDown gupdateThemesEditorState, % translate("Picture Carousel") . "|" . translate("Video")
		
		Gui TE:Add, Text, x16 y318 w160 h23 +0x200, % translate("Sound File")
		Gui TE:Add, Button, x85 y317 w23 h23 HwndplaySoundButtonHandle gtogglePlaySoundFile
		setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
		Gui TE:Add, Edit, x110 y318 w259 h21 VsoundFilePathEdit, %soundFilePathEdit%
		Gui TE:Add, Button, x371 y317 w23 h23 gchooseSoundFilePath, % translate("...")
		
		Gui TE:Add, Text, x16 y342 w80 h23 +0x200 VvideoFilePathLabel, % translate("Video")
		Gui TE:Add, Edit, x110 y342 w259 h21 VvideoFilePathEdit, %videoFilePathEdit%
		Gui TE:Add, Button, x371 y341 w23 h23 VvideoFilePathButton gchooseVideoFilePath, % translate("...")
		
		Gui TE:Add, Text, x16 y342 w80 h23 +0x200 VpicturesListLabel, % translate("Pictures")
		Gui TE:Add, Button, x85 y342 w23 h23 HwndaddPictureButtonHandle VaddPictureButton gaddThemePicture
		setButtonIcon(addPictureButtonHandle, kIconsDirectory . "Plus.ico", 1)
		Gui TE:Add, ListView, x110 y342 w284 h112 -Multi -LV0x10 Checked -Hdr NoSort NoSortHdr HwndpicturesListViewHandle VpicturesListView, % translate("Picture")	
		
		Gui TE:Add, Text, x16 y456 w80 h23 +0x200 VpicturesDurationLabel, % translate("Display Duration")
		Gui TE:Add, Edit, x110 y456 w40 h21 Limit5 Number VpicturesDurationEdit, %picturesDurationEdit%
		
		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x154 y459 w40 h23 VpicturesDurationPostfix, % translate("ms")
	
		Gui TE:Add, Button, x184 y490 w46 h23 VthemeAddButton gaddItem, % translate("Add")
		Gui TE:Add, Button, x232 y490 w50 h23 Disabled VthemeDeleteButton gdeleteItem, % translate("Delete")
		Gui TE:Add, Button, x340 y490 w55 h23 Disabled VthemeUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(themesListViewHandle, "themesListView", "themeAddButton", "themeDeleteButton", "themeUpdateButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		splashThemes := getConfigurationSectionValues(configuration, "Splash Themes", Object())
		themes := {}
		
		for descriptor, value in splashThemes {
			theme := StrSplit(descriptor, ".")[1]
			
			if !themes.HasKey(theme) {
				type := splashThemes[theme . ".Type"]
				media := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Images"] : splashThemes[theme . ".Video"])
				duration := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Duration"] : false)
				songFile := (splashThemes.HasKey(theme . ".Song") ? splashThemes[theme . ".Song"] : false)
				
				if !songFile
					songFile := ""
					
				themes[theme] := theme
				
				this.iItemsList.Push(Array(type, theme, media, songFile, duration))
			}
		}
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		for index, theme in this.iItemsList {
			name := theme[2]
			type := theme[1]
			songFile := theme[4]
			
			setConfigurationValue(configuration, "Splash Themes", name . ".Type", type)
			
			if (songFile && (songFile != ""))
				setConfigurationValue(configuration, "Splash Themes", name . ".Song", songFile)
				
			if (type == "Picture Carousel") {
				setConfigurationValue(configuration, "Splash Themes", name . ".Images", theme[3])
				setConfigurationValue(configuration, "Splash Themes", name . ".Duration", theme[5])
			}
			else
				setConfigurationValue(configuration, "Splash Themes", name . ".Video", theme[3])
		}
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		for ignore, theme in items {
			songFile := theme[4]
			
			if (songFile != "") {
				SplitPath songFile, , , , nameNoExt

				songFile := nameNoExt
			}
			
			mediaFiles := []
			
			for ignore, mediaFile in string2Values(",", theme[3]) {
				SplitPath mediaFile, , , , nameNoExt

				mediaFiles.Push(nameNoExt)
			}
			
			LV_Add("", theme[2], values2String(", ", mediaFiles*), songFile)
		}
		
		if first {
			LV_ModifyCol(1, 100)
			LV_ModifyCol(2, 180)
			LV_ModifyCol(3, 100)
			
			first := false
		}
	}
	
	updateState() {
		base.updateState()
		
		GuiControlGet themeTypeDropDown
		
		if (themeTypeDropDown == 1) {
			GuiControl Show, picturesListLabel
			GuiControl Show, addPictureButton
			GuiControl Show, picturesListView
			GuiControl Show, picturesDurationLabel
			GuiControl Show, picturesDurationEdit
			GuiControl Show, picturesDurationPostfix
		}
		else {
			GuiControl Hide, picturesListLabel
			GuiControl Hide, addPictureButton
			GuiControl Hide, picturesListView
			GuiControl Hide, picturesDurationLabel
			GuiControl Hide, picturesDurationEdit
			GuiControl Hide, picturesDurationPostfix
		}
		
		if (themeTypeDropDown == 2) {
			GuiControl Show, videoFilePathLabel
			GuiControl Show, videoFilePathEdit
			GuiControl Show, videoFilePathButton
		}
		else {
			GuiControl Hide, videoFilePathLabel
			GuiControl Hide, videoFilePathEdit
			GuiControl Hide, videoFilePathButton
		}
	}
	
	initializePicturesList(pictures := "") {
		Gui ListView, % picturesListViewHandle
			
		LV_Delete()
		
		pictures := string2Values(",", pictures)
		
		picturesListViewImages := IL_Create(pictures.Length())
			
		for ignore, picture in pictures
			IL_Add(picturesListViewImages, LoadPicture(getFileName(picture, kUserSplashMediaDirectory, kSplashMediaDirectory), "W32 H32"), 0xFFFFFF, false)
		
		LV_SetImageList(picturesListViewImages)
		
		Loop % pictures.Length()
			LV_Add("Check Icon" . A_Index, pictures[A_Index])
			
		LV_ModifyCol()
	}
	
	loadEditor(item) {
		themeTypeDropDown := (item[1] == "Picture Carousel") ? 1 : 2
		themeNameEdit := item[2]
		soundFilePathEdit := item[4]
			
		GuiControl Choose, themeTypeDropDown, %themeTypeDropDown%
		GuiControl Text, themeNameEdit, %themeNameEdit%
		GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		
		if (themeTypeDropDown == 2)
			videoFilePathEdit := item[3]
		else
			videoFilePathEdit := ""
			
		GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		
		if (themeTypeDropDown == 1) {
			this.initializePicturesList(item[3])
			
			picturesDurationEdit := item[5]
			
			GuiControl Text, picturesDurationEdit, %picturesDurationEdit%
		}
		else
			this.initializePicturesList("")
		
		this.updateEditor()
	}
	
	clearEditor() {
		themeTypeDropDown := 0
		themeNameEdit := ""
		soundFilePathEdit := ""
		videoFilePathEdit := ""
		picturesDurationEdit := 3000
			
		GuiControl Choose, themeTypeDropDown, %themeTypeDropDown%
		GuiControl Text, themeNameEdit, %themeNameEdit%
		GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		GuiControl Text, picturesDurationEdit, %picturesDurationEdit%
		
		this.initializePicturesList("")
		
		this.updateEditor()
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet themeNameEdit
		GuiControlGet themeTypeDropDown
		GuiControlGet soundFilePathEdit
		GuiControlGet picturesDurationEdit
		
		type := ""
		media := ""
		
		if (themeTypeDropDown == 1) {
			type := "Picture Carousel"
			pictures := []
			
			Gui ListView, % picturesListViewHandle
			
			rowNumber := 0
			
			Loop {
				rowNumber := LV_GetNext(rowNumber, "C")
				
				if !rowNumber
					break
					
				LV_GetText(fileName, rowNumber)
				
				pictures.Push(StrReplace(StrReplace(fileName, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))
			}
			
			media := values2String(", ", pictures*)
		}
		else if (themeTypeDropDown == 2) {
			type := "Video"
			
			GuiControlGet videoFilePathEdit
		
			media := videoFilePathEdit
		}
		else
			Goto error
		
		return Array(type, themeNameEdit, media, soundFilePathEdit, picturesDurationEdit)
		
error:
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Error")
		MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
		OnMessage(0x44, "")
		
		return false
	}
	
	togglePlaySoundFile(stop := false) {
		if (stop || this.iSoundIsPlaying) {
			try {
				SoundPlay NonExistent.avi
			}
			catch ignore {
				; Ignore
			}
			
			setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
			
			this.iSoundIsPlaying := false
		}
		else if !this.iSoundIsPlaying {
			try {
				songFile := getFileName(soundFilePathEdit, kUserSplashMediaDirectory, kSplashMediaDirectory)
				
				if FileExist(songFile) {
					SoundPlay %songFile%
				
					setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Pause.ico", 1, "L7 T2 R2 B2")
					
					this.iSoundIsPlaying := true
				}
			}
			catch exception {
				; Ignore
			}
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global translationLanguageDropDown
global addLanguageButton
global deleteLanguageButton

global isoCodeEdit = ""
global languageNameEdit = ""

class TranslationsEditor extends ConfigurationItem {
	iLanguagesChanged := false
	iTranslationsList := false
	iClosed := false
	
	TranslationsList[] {
		Get {
			return this.iTranslationsList
		}
	}
	
	__New(configuration) {
		this.iTranslationsList := new TranslationsList(configuration)
		
		base.__New(configuration)
		
		TranslationsEditor.Instance := this
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Gui TE:Default
	
		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0

		Gui TE:Font, Bold, Arial

		Gui TE:Add, Text, w388 Center gmoveTranslationsEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic Underline, Arial

		Gui TE:Add, Text, YP+20 w388 cBlue Center gopenTranslationsDocumentation, % translate("Translations")

		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		choices := []
		chosen := 0
		
		for code, language in availableLanguages() {
			choices.Push(language)
			
			if (language == languageDropDown) {
				chosen := A_Index
				
				isoCodeEdit := code
				languageNameEdit := language
			}
		}
			
		Gui TE:Add, Text, x16 w160 h23 +0x200, % translate("Language")
		Gui TE:Add, DropDownList, x184 yp w158 Choose%chosen% VtranslationLanguageDropDown gchooseTranslationLanguage, % values2String("|", choices*)
		Gui TE:Add, Button, x343 yp-1 w23 h23 HwndaddLanguageButtonHandle VaddLanguageButton gaddLanguage
		Gui TE:Add, Button, x368 yp w23 h23 HwnddeleteLanguageButtonHandle VdeleteLanguageButton gdeleteLanguage
		setButtonIcon(addLanguageButtonHandle, kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(deleteLanguageButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui TE:Add, Text, x16 w160 h23 +0x200, % translate("ISO Code / Identifier")
		Gui TE:Add, Edit, x184 yp w40 h21 Disabled VisoCodeEdit, %isoCodeEdit%
		Gui TE:Add, Edit, x236 yp w155 h21 Disabled VlanguageNameEdit, %languageNameEdit%
	
		this.iTranslationsList.createGui(configuration)
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		Gui TE:Add, Button, x166 yp+10 w80 h23 Default GcloseTranslationsEditor, % translate("Close")
	}
	
	editTranslations() {
		Gui TE:Show, AutoSize Center
		
		GuiControlGet isoCodeEdit
		
		this.iTranslationsList.loadTranslations((isoCodeEdit != "") ? isoCodeEdit : "en")
		
		Loop
			Sleep 200
		until this.iClosed
		
		try {
			return this.iLanguagesChanged
		}
		finally {
			Gui TE:Destroy
		}
	}
	
	saveTranslations() {
		if this.iTranslationsList.saveTranslations() {
			GuiControlGet isoCodeEdit
			GuiControlGet languageNameEdit
			
			choices := []
			chosen := 0
			found := false
			
			for code, language in availableLanguages() {
				choices.Push(language)
				
				if (code = isoCodeEdit) {
					chosen := A_Index
					found := true
				}
			}
			
			if !found {
				choices.Push(languageNameEdit)
				chosen := choices.Length()
			}
			
			GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
			GuiControl Choose, translationLanguageDropDown, % chosen
		}
	}
	
	closeEditor() {
		this.saveTranslations()
		
		this.iClosed := true
	}
	
	addLanguage() {
		this.iLanguagesChanged := true
		this.saveTranslations()
		
		choices := []
		
		for ignore, language in availableLanguages()
			choices.Push(language)
		
		isoCodeEdit := "XX"
		languageNameEdit := translate("New Language")
		
		choices.Push(languageNameEdit)
			
		GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, translationLanguageDropDown, % choices.Length()
		
		GuiControl Text, isoCodeEdit, %isoCodeEdit%
		GuiControl Text, languageNameEdit, %languageNameEdit%
		
		GuiControl Enable, isoCodeEdit
		GuiControl Enable, languageNameEdit
		
		this.iTranslationsList.newTranslations()
	}
	
	deleteLanguage() {
		GuiControlGet translationLanguageDropDown
		
		SoundPlay *32
	
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Delete")
		MsgBox 262436, %title%, % translate("Do you really want to delete this translation?")
		OnMessage(0x44, "")

		IfMsgBox Yes
		{
			this.iLanguagesChanged := true
			
			languageCode := kUndefined

			for code, language in availableLanguages()
				if ((language = translationLanguageDropDown) && (code != "en"))
					languageCode := code
			
			if (languageCode != kUndefined)
				for ignore, fileName in getFileNames("Translations." . languageCode, kUserConfigDirectory, kConfigDirectory)
					try {
						FileDelete %fileName%
					}
					catch exception {
						; ignore
					}
			
			this.chooseLanguage("en")
		}
	}
	
	chooseLanguage(languageCode := false) {
		this.iTranslationsList.saveTranslations()
		
		availableLanguages := availableLanguages()
		
		if !languageCode {
			GuiControlGet translationLanguageDropDown
			
			for code, language in availableLanguages
				if (language = translationLanguageDropDown) {
					languageCode := code
					
					break
				}
		}
	
		choices := []
		
		for code, language in availableLanguages {
			choices.Push(language)
		
			if (code = languageCode) {
				isoCodeEdit := code
				languageNameEdit := language
		
				chosen := A_Index
			}
		}
				
		GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, translationLanguageDropDown, %chosen%
		
		GuiControl Text, isoCodeEdit, %isoCodeEdit%
		GuiControl Text, languageNameEdit, %languageNameEdit%
		
		GuiControl Disable, isoCodeEdit
		GuiControl Disable, languageNameEdit
		
		this.iTranslationsList.loadTranslations(isoCodeEdit)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsList                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global translationsListView

global originalTextEdit = ""
global translationTextEdit = ""

global nextUntranslatedButtonHandle
		
class TranslationsList extends ConfigurationItemList {
	iChanged := false
	iLanguageCode := ""
	
	__New(configuration) {
		base.__New(configuration)
				 
		TranslationsList.Instance := this
	}
					
	createGui(configuration) {
		Gui TE:Add, ListView, x16 y+10 w377 h140 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndtranslationsListViewHandle VtranslationsListView glistEvent
							, % values2String("|", map(["Original", "Translation"], "translate")*)
		
		Gui TE:Add, Text, x16 w86 h23 +0x200, % translate("Original")
		Gui TE:Add, Edit, x110 yp w283 h80 Disabled VoriginalTextEdit, %originalTextEdit%
	
		Gui TE:Add, Text, x16 w86 h23 +0x200, % translate("Translation")
		Gui TE:Add, Button, x85 yp w23 h23 Default HwndnextUntranslatedButtonHandle gnextUntranslated
		setButtonIcon(nextUntranslatedButtonHandle, kIconsDirectory . "Down Arrow.ico", 1)
		Gui TE:Add, Edit, x110 yp w283 h80 VtranslationTextEdit, %translationTextEdit%
		
		this.initializeList(translationsListViewHandle, "translationsListView")
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
		
		count := LV_GetCount()
		
		for index, translation in this.iItemsList
			if (index <= count)
				LV_Modify(index, "", translation[1], translation[2])
			else
				LV_Add("", translation[1], translation[2])
		
		if (items.Length() < count)
			Loop % count - items.Length()
				LV_Delete(count - A_Index - 1)
			
		if (first || (this.iLanguageCode = "en")) {
			LV_ModifyCol()
			LV_ModifyCol(1, 150)
			LV_ModifyCol(2, 300)
			
			first := false
		}
	}
	
	updateState() {
		base.updateState()
	}
	
	loadEditor(item) {
		originalTextEdit := item[1]
		translationTextEdit := item[2]
		
		if (translationTextEdit == "")
			translationTextEdit := originalTextEdit
		
		GuiControl Text, originalTextEdit, %originalTextEdit%
		GuiControl Text, translationTextEdit, %translationTextEdit%
	}
	
	clearEditor() {
		originalTextEdit := ""
		translationTextEdit := ""
		
		GuiControl Text, originalTextEdit, %originalTextEdit%
		GuiControl Text, translationTextEdit, %translationTextEdit%
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet originalTextEdit
		GuiControlGet translationTextEdit
		
		translationTextEdit := (translationTextEdit == originalTextEdit) ? "" : translationTextEdit
		
		if isNew
			this.iChanged := true
		else
			this.iChanged := this.iChanged || (this.iItemsList[this.iCurrentItemIndex][2] != translationTextEdit)
		
		return Array(originalTextEdit, translationTextEdit)
	}
	
	openEditor(itemIndex) {
		if (this.iCurrentItemIndex != 0) {
			GuiControlGet translationTextEdit
			
			if (this.iItemsList[this.iCurrentItemIndex][2] != translationTextEdit)
				this.updateItem()
		}
			
		base.openEditor(itemIndex)
	}
	
	findNextUntranslated() {
		for index, translation in this.iItemsList
			if ((index > this.iCurrentItemIndex) && (translation[2] = ""))
				return index
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Information")
		MsgBox 262192, %title%, % translate("There is no missing translation...")
		OnMessage(0x44, "")
		
		return false
	}
	
	newTranslations() {
		this.loadTranslations("en")
		
		this.iChanged := true
	}
	
	loadTranslations(languageCode) {
		this.iLanguageCode := languageCode
		
		this.iItemsList := []
		
		for original, translation in readTranslations(this.iLanguageCode)
			this.iItemsList.Push(Array(original, translation))
			
		this.loadList(this.iItemsList)
		this.clearEditor()
		
		this.iCurrentItemIndex := 0
		this.iChanged := false
	}
	
	saveTranslations() {
		if (this.iCurrentItemIndex != 0)
			this.updateItem()

		if this.iChanged {
			SoundPlay *32
		
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Save")
			MsgBox 262436, %title%, % translate("Do you want to save your changes? Any existing translations will be overwritten.")
			OnMessage(0x44, "")

			IfMsgBox Yes
			{
				this.iChanged := false
				
				translations := {}
				
				GuiControlGet isoCodeEdit
				GuiControlGet languageNameEdit
				
				this.iLanguageCode := isoCodeEdit
				
				for ignore, item in this.iItemsList {
					original := item[1]
					translated := item[2]
				
					if (translations.HasKey(original) && (translated != translations[original])) {
						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						title := translate("Error")
						MsgBox 262160, %title%, % translate("Inconsistent translations detected - please correct...")
						OnMessage(0x44, "")
						
						return false
					}
						
					translations[original] := translated
				}
				
				writeTranslations(isoCodeEdit, languageNameEdit, translations)
				
				return true
			}
		}
		
		return false
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

saveAndStay() {
	vResult := kApply
}

moveConfigurationEditor() {
	moveByMouse(ConfigurationEditor.Instance.Window)
}

updateSaveMode() {
	GuiControlGet saveModeDropDown
	
	ConfigurationEditor.Instance.iSaveMode := ["Auto", "Manual"][saveModeDropDown]
}

openConfigurationDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration
}

chooseHomePath() {
	protectionOn()
	
	try{
		FileSelectFolder directory, *%homePathEdit%, 0, % translate("Select Installation folder...")
	
		if (directory != "")
			GuiControl Text, homePathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseNirCmdPath() {
	protectionOn()
	
	try{
		FileSelectFolder directory, *%nirCmdPathEdit%, 0, % translate("Select NirCmd folder...")
	
		if (directory != "")
			GuiControl Text, nirCmdPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseAHKPath() {
	protectionOn()
	
	try{
		FileSelectFolder directory, *%ahkPathEdit%, 0, % translate("Select AutoHotkey folder...")
	
		if (directory != "")
			GuiControl Text, ahkPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseMSBuildPath() {
	protectionOn()
	
	try{
		FileSelectFolder directory, *%msBuildPathEdit%, 0, % translate("Select MSBuild Bin folder...")
	
		if (directory != "")
			GuiControl Text, msBuildPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

openTranslationsEditor() {
	GeneralTab.Instance.openTranslationsEditor()
}

openThemesEditor() {
	GeneralTab.Instance.openThemesEditor()
}

saveThemesEditor() {
	protectionOn()
	
	try {
		ThemesEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelThemesEditor() {
	protectionOn()
	
	try {
		ThemesEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

moveThemesEditor() {
	moveByMouse("TE")
}

openThemesDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor
}

updateThemesEditorState() {
	protectionOn()
	
	try {
		ConfigurationItemList.getList("themesListView").updateState()
	}
	finally {
		protectionOff()
	}
}

togglePlaySoundFile() {
	protectionOn()
	
	try {
		ThemesList.Instance.togglePlaySoundFile()
	}
	finally {
		protectionOff()
	}
}

addThemePicture() {
	protectionOn()
	
	try {
		title := translate("Select Image...")
	
		FileSelectFile pictureFile, 1, , %title%, Image (*.jpg; *.gif)
		
		if (pictureFile != "") {
			Gui ListView, % picturesListViewHandle
			
			IL_Add(picturesListViewImages, LoadPicture(pictureFile, "W32 H32"), 0xFFFFFF, false)
			
			LV_Add("Check Icon" . (LV_GetCount() + 1), StrReplace(StrReplace(pictureFile, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))
			
			LV_ModifyCol()
			LV_Modify(LV_GetCount(), "Vis")
		}
	}
	finally {
		protectionOff()
	}
}

chooseSoundFilePath() {
	protectionOn()
	
	try {
		GuiControlGet soundFilePathEdit
		
		path := soundFilePathEdit
	
		if (path && (path != ""))
			path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
		else
			path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)
		
		title := translate("Select Sound File...")
		
		FileSelectFile soundFile, 1, *%path%, %title%, Audio (*.wav; *.mp3)
		
		if (soundFile != "") {
			soundFilePathEdit := soundFile
			
			GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		}
	}
	finally {
		protectionOff()
	}
}

chooseVideoFilePath() {
	protectionOn()
	
	try {
		GuiControlGet videoFilePathEdit
		
		path := videoFilePathEdit
	
		if (path && (path != ""))
			path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
		else
			path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)
		
		title := translate("Select Video (GIF) File...")
		
		FileSelectFile videoFile, 1, *%path%, %title%, Video (*.gif)
		
		if (videoFile != "") {
			videoFilePathEdit := videoFile
			
			GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		}
	}
	finally {
		protectionOff()
	}
}

addLanguage(){
	protectionOn()
	
	try {
		TranslationsEditor.Instance.addLanguage()
	}
	finally {
		protectionOff()
	}
}

deleteLanguage() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.deleteLanguage()
	}
	finally {
		protectionOff()
	}
}

closeTranslationsEditor() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.closeEditor()
	}
	finally {
		protectionOff()
	}
}

moveTranslationsEditor() {
	moveByMouse("TE")
}

chooseTranslationLanguage() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.chooseLanguage()
	}
	finally {
		protectionOff()
	}
}

openTranslationsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor
}

nextUntranslated() {
	protectionOn()
	
	try {
		list := TranslationsEditor.Instance.TranslationsList
		untranslated := list.findNextUntranslated()
		
		if untranslated
			list.openEditor(untranslated)
	}
	finally {
		protectionOff()
	}
}

showKeyDetector() {
	returnHotKey := vKeyDetectorCallback
	joystickNumbers := []
	
	vKeyDetectorCallback := false

	Loop 16 { ; Query each joystick number to find out which ones exist.
		GetKeyState joyName, %A_Index%JoyName
		
		if (joyName != "")
			joystickNumbers.Push(A_Index)
	}

	if (joystickNumbers.Length() == 0) {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Warning")
		MsgBox 262192, %title%, % translate("No controller detected...")
		OnMessage(0x44, "")
		
		vShowKeyDetector := false
	}

	if vShowKeyDetector {
		found := false
		
		Loop {
			joystickNumber := joystickNumbers[1]
			
			joystickNumbers.RemoveAt(1)
			joystickNumbers.Push(joystickNumber)
		
			SetFormat Float, 03  ; Omit decimal point from axis position percentages.
		
			GetKeyState joy_buttons, %joystickNumber%JoyButtons
			GetKeyState joy_name, %joystickNumber%JoyName
			GetKeyState joy_info, %joystickNumber%JoyInfo

			if !vShowKeyDetector {
				ToolTip, , , 1
				
				break
			}
			
			buttons_down := ""
			
			Loop %joy_buttons%
			{
				GetKeyState joy%A_Index%, %joystickNumber%joy%A_Index%
		
				if (joy%A_Index% = "D") {
					buttons_down = %buttons_down%%A_Space%%A_Index%
					
					found := A_Index
				}
			}
	
			GetKeyState joyX, %joystickNumber%JoyX
			
			axis_info = X%joyX%
			
			GetKeyState joyY, %joystickNumber%JoyY
	
			axis_info = %axis_info%%A_Space%%A_Space%Y%joyY%
	
			IfInString joy_info, Z
			{
				GetKeyState joyZ, %joystickNumber%JoyZ

				axis_info = %axis_info%%A_Space%%A_Space%Z%joyZ%
			}
			
			IfInString joy_info, R
			{
				GetKeyState joyR, %joystickNumber%JoyR
		
				axis_info = %axis_info%%A_Space%%A_Space%R%joyR%
			}
			
			IfInString joy_info, U
			{
				GetKeyState joyU, %joystickNumber%JoyU
		
				axis_info = %axis_info%%A_Space%%A_Space%U%joyU%
			}
			
			IfInString joy_info, V
			{
				GetKeyState joyV, %joystickNumber%JoyV
		
				axis_info = %axis_info%%A_Space%%A_Space%V%joyV%
			}
			
			IfInString joy_info, P
			{
				GetKeyState joyp, %joystickNumber%JoyPOV
				
				axis_info = %axis_info%%A_Space%%A_Space%POV%joyp%
			}
			
			buttonsDown := translate("Buttons Down:")
			
			ToolTip %joy_name% (#%joystickNumber%):`n%axis_info%`n%buttonsDown% %buttons_down%, , , 1
						
			if found {
				if returnHotkey
					%returnHotkey%(joystickNumber . "Joy" . found)
				else
					Sleep 2000
				
				found := false
			}
			else				
				Sleep 400
			
			if vResult
				break
		}
	}
}

saveConfiguration(configurationFile, editor) {
	configuration := newConfiguration()

	editor.saveToConfiguration(configuration)

	writeConfiguration(configurationFile, configuration)
	
	startupLink := A_Startup . "\Simulator Startup.lnk"
	
	if getConfigurationValue(configuration, "Configuration", "Start With Windows", false) {
		startupExe := kBinariesDirectory . "Simulator Startup.exe"
		
		FileCreateShortCut %startupExe%, %startupLink%, %kBinariesDirectory%
	}
	else
		try {
			FileDelete %startupLink%
		}
		catch exception {
			; ignore
		}
}

initializeSimulatorConfiguration() {
	icon := kIconsDirectory . "Configuration.ico"
	
	Menu Tray, Icon, %icon%, , 1
	
	protectionOn()
	
	try {
		new ConfigurationEditor(FileExist("C:\Program Files\AutoHotkey") || GetKeyState("Ctrl")
							 || (getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path", "") != "")
							 , (GetKeyState("Ctrl") && GetKeyState("Shift")) ? newConfiguration() : kSimulatorConfiguration)
	}
	finally {
		protectionOff()
	}
}

startupSimulatorConfiguration() {
	editor := ConfigurationEditor.Instance
	
	editor.createGui(editor.Configuration)
	
	done := false
	saved := false

	editor.show()
	
	try {
		Loop {
			Sleep 200
			
			if (vResult == kApply) {
				saved := true
				vResult := false
				
				saveConfiguration(kSimulatorConfigurationFile, editor)
			}
			else if (vResult == kCancel)
				done := true
			else if (vResult == kOk) {
				saved := true
				done := true
				
				saveConfiguration(kSimulatorConfigurationFile, editor)
			}
		} until done
	}
	finally {
		editor.hide()
	}
	
	if saved
		ExitApp 1
	else
		ExitApp 0
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

listEvent() {
	protectionOn()
	
	try {
		ConfigurationItemList.getList(A_GuiControl).listEvent()
	}
	finally {
		protectionOff()
	}
}

addItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).addItem()
	}
	finally {
		protectionOff()
	}
}

deleteItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).deleteItem()
	}
	finally {
		protectionOff()
	}
}

updateItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).updateItem()
	}
	finally {
		protectionOff()
	}
}

upItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).upItem()
	}
	finally {
		protectionOff()
	}
}

downItem() {
	protectionOn()
	
	try{
		ConfigurationItemList.getList(A_GuiControl).downItem()
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorConfiguration()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Configuration Plugins.ahk
#Include %A_MyDocuments%\Simulator Controller\Plugins\Configuration Plugins.ahk


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorConfiguration()