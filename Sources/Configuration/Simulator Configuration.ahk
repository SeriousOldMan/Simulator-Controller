;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Configuration Editor  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Framework\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Configuration.ico
;@Ahk2Exe-ExeName Simulator Configuration.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Application.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ConfigurationItemList.ahk
#Include Libraries\ConfigurationEditor.ahk
#Include Libraries\ThemesEditor.ahk
#Include Libraries\TranslationsEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

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
		local window := editor.Window
		local choices := []
		local chosen := 0
		local enIndex := 0
		local code, language

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 y80 w458 h70, % translate("Installation")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x24 y97 w160 h23 +0x200, % translate("Installation Folder (optional)")
		Gui %window%:Add, Edit, x224 y97 w214 h21 VhomePathEdit, %homePathEdit%
		Gui %window%:Add, Button, x440 y96 w23 h23 gchooseHomePath, % translate("...")

		Gui %window%:Add, Text, x24 y121 w160 h23 +0x200, % translate("NirCmd Folder (optional)")
		Gui %window%:Add, Edit, x224 y121 w214 h21 VnirCmdPathEdit, %nirCmdPathEdit%
		Gui %window%:Add, Button, x440 y120 w23 h23 gchooseNirCmdPath, % translate("...")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 y160 w458 h95, % translate("Settings")

		Gui %window%:Font, Norm, Arial

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

		Gui %window%:Add, GroupBox, -Theme x16 y265 w458 h115, % translate("Simulators")

		Gui %window%:Font, Norm, Arial

		this.iSimulatorsList.createGui(editor, x, y, width, height)

		if this.iDevelopment {
			Gui %window%:Font, Norm, Arial
			Gui %window%:Font, Italic, Arial

			Gui %window%:Add, GroupBox, -Theme x16 y388 w458 h119, % translate("Development")

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
				chosen := 2

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
		local languageCode := "en"
		local code, language, choices

		base.saveToConfiguration(configuration)

		GuiControlGet nirCmdPathEdit
		GuiControlGet homePathEdit

		GuiControlGet languageDropDown
		GuiControlGet startWithWindowsCheck
		GuiControlGet silentModeCheck

		setConfigurationValue(configuration, "Configuration", "NirCmd Path", nirCmdPathEdit)
		setConfigurationValue(configuration, "Configuration", "Home Path", homePathEdit)

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

	getSimulators() {
		local simulators := []
		local simulator, ignore

		for simulator, ignore in getConfigurationSectionValues(getControllerState(), "Simulators", Object())
			simulators.Push(simulator)

		return simulators
	}

	openTranslationsEditor() {
		local window := ConfigurationEditor.Instance.Window
		local choices, chosen, enIndex, code, language

		GuiControlGet languageDropDown

		Gui TE:+Owner%window%
		Gui %window%:+Disabled

		if (new TranslationsEditor(this.Configuration)).editTranslations() {
			Gui %window%:-Disabled

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
			Gui %window%:-Disabled
	}

	openThemesEditor() {
		local window := ConfigurationEditor.Instance.Window

		Gui TE:+Owner%window%
		Gui %window%:+Disabled

		this.iSplashThemesConfiguration := (new ThemesEditor(this.iSplashThemesConfiguration ? this.iSplashThemesConfiguration : this.Configuration)).editThemes()

		Gui %window%:-Disabled
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SimulatorsList                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global simulatorsListBox := "|"

global simulatorEdit := ""

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
		local window := editor.Window

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

		this.ItemList := string2Values("|", getConfigurationValue(configuration, "Configuration", "Simulators", ""))
	}

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		setConfigurationValue(configuration, "Configuration", "Simulators", values2String("|", this.ItemList*))
	}

	clickEvent(line, count) {
		GuiControlGet simulatorsListBox

		this.openEditor(inList(this.ItemList, simulatorsListBox))
	}

	processListEvent() {
		return true
	}

	loadList(items) {
		simulatorsListBox := values2String("|", this.ItemList*)

		GuiControl, , simulatorsListBox, % "|" . simulatorsListBox
	}

	selectItem(itemNumber) {
		this.CurrentItem := itemNumber

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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseHomePath() {
	local directory

	protectionOn()

	try {
		GuiControlGet homePathEdit

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder directory, *%homePathEdit%, 0, % translate("Select Installation folder...")
		OnMessage(0x44, "")

		if (directory != "")
			GuiControl Text, homePathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseNirCmdPath() {
	local directory

	protectionOn()

	try {
		GuiControlGet nirCmdPathEdit

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder directory, *%nirCmdPathEdit%, 0, % translate("Select NirCmd folder...")
		OnMessage(0x44, "")

		if (directory != "")
			GuiControl Text, nirCmdPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseAHKPath() {
	local directory

	protectionOn()

	try {
		GuiControlGet ahkPathEdit

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder directory, *%ahkPathEdit%, 0, % translate("Select AutoHotkey folder...")
		OnMessage(0x44, "")

		if (directory != "")
			GuiControl Text, ahkPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}

chooseMSBuildPath() {
	local directory

	protectionOn()

	try {
		GuiControlGet msBuildPathEdit

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder directory, *%msBuildPathEdit%, 0, % translate("Select MSBuild Bin folder...")
		OnMessage(0x44, "")

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

saveConfiguration(configurationFile, editor) {
	local configuration := newConfiguration()
	local startupLink, startupExe

	editor.saveToConfiguration(configuration)

	writeConfiguration(configurationFile, configuration)

	deleteFile(kTempDirectory . "Simulator Controller.state")

	startupLink := A_Startup . "\Simulator Startup.lnk"

	if getConfigurationValue(configuration, "Configuration", "Start With Windows", false) {
		startupExe := kBinariesDirectory . "Simulator Startup.exe"

		FileCreateShortCut %startupExe%, %startupLink%, %kBinariesDirectory%
	}
	else
		deleteFile(startupLink)

	deleteDirectory(kTempDirectory, false)
}

initializeSimulatorConfiguration() {
	local icon := kIconsDirectory . "Configuration.ico"
	local title, initialize

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Configuration

	kConfigurationEditor := true

	protectionOn()

	if (GetKeyState("Ctrl") && GetKeyState("Shift")) {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Configuration")
		MsgBox 262436, %title%, % translate("Do you really want to start with a fresh configuration?")
		OnMessage(0x44, "")

		IfMsgBox Yes
			initialize := true
		else
			initialize := false
	}
	else
		initialize := false

	try {
		new ConfigurationEditor(FileExist("C:\Program Files\AutoHotkey") || GetKeyState("Ctrl")
							 || (getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path", "") != "")
							 , initialize ? newConfiguration() : kSimulatorConfiguration)
	}
	finally {
		protectionOff()
	}

	return
}

startupSimulatorConfiguration() {
	local editor := ConfigurationEditor.Instance
	local done, saved, result

	editor.createGui(editor.Configuration)

	done := false
	saved := false

	editor.show()

	try {
		loop {
			Sleep 200

			result := ConfigurationEditor.Instance.Result

			if (result == kApply) {
				saved := true

				ConfigurationEditor.Instance.Result := false

				saveConfiguration(kSimulatorConfigurationFile, editor)
			}
			else if (result == kCancel)
				done := true
			else if (result == kOk) {
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
;;;                       Initialization Section Part 1                     ;;;
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