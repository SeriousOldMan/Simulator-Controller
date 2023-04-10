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
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Configuration.ico
;@Ahk2Exe-ExeName Simulator Configuration.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\ConfigurationItemList.ahk"
#Include "Libraries\ConfigurationEditor.ahk"
#Include "Libraries\ThemesEditor.ahk"
#Include "Libraries\FormatsEditor.ahk"
#Include "Libraries\TranslationsEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; GeneralTab                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GeneralTab extends Configurator {
	iSimulatorsList := false
	iDevelopment := false
	iSplashThemesConfiguration := false
	iFormatsConfiguration := false

	__New(development, configuration) {
		this.iDevelopment := development
		this.iSimulatorsList := SimulatorsList(configuration)

		super.__New(configuration)

		GeneralTab.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local choices := []
		local chosen := 0
		local enIndex := 0
		local code, language, translator, button

		chooseHomePath(*) {
			local directory, translator

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				directory := DirSelect("*" . window["homePathEdit"].Text, 0, translate("Select Installation folder..."))
				OnMessage(0x44, translator, 0)

				if (directory != "")
					window["homePathEdit"].Text := directory
			}
			finally {
				protectionOff()
			}
		}

		chooseNirCmdPath(*) {
			local directory, translator

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				directory := DirSelect("*" . window["nirCmdPathEdit"].Text, 0, translate("Select NirCmd folder..."))
				OnMessage(0x44, translator, 0)

				if (directory != "")
					window["nirCmdPathEdit"].Text := directory
			}
			finally {
				protectionOff()
			}
		}

		chooseAHKPath(*) {
			local directory, translator

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				directory := DirSelect("*" . window["ahkPathEdit"].Text, 0, translate("Select AutoHotkey folder..."))
				OnMessage(0x44, translator, 0)

				if (directory != "")
					window["ahkPathEdit"].Text := directory
			}
			finally {
				protectionOff()
			}
		}

		chooseMSBuildPath(*) {
			local directory, translator

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				directory := DirSelect("*" . window["msBuildPathEdit"].Text, 0, translate("Select MSBuild Bin folder..."))
				OnMessage(0x44, translator, 0)

				if (directory != "")
					window["msBuildPathEdit"].Text := directory
			}
			finally {
				protectionOff()
			}
		}

		openTranslationsEditor(*) {
			this.openTranslationsEditor()
		}

		openFormatsEditor(*) {
			this.openFormatsEditor()
		}

		openThemesEditor(*) {
			this.openThemesEditor()
		}

		this.Editor := editor

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "-Theme x16 y80 w458 h70 W:Grow", translate("Installation"))

		window.SetFont("Norm", "Arial")

		window.Add("Text", "x24 y97 w160 h23 +0x200", translate("Installation Folder (optional)"))
		window.Add("Edit", "x224 y97 w214 h21 W:Grow vhomePathEdit", this.Value["homePath"])
		window.Add("Button", "x440 y96 w23 h23 X:Move", translate("...")).OnEvent("Click", chooseHomePath)

		window.Add("Text", "x24 y121 w160 h23 +0x200", translate("NirCmd Folder (optional)"))
		window.Add("Edit", "x224 y121 w214 h21 W:Grow VnirCmdPathEdit", this.Value["nirCmdPath"])
		window.Add("Button", "x440 y120 w23 h23 X:Move", translate("...")).OnEvent("Click", chooseNirCmdPath)

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "-Theme x16 y160 w458 h95 W:Grow", translate("Settings"))

		window.SetFont("Norm", "Arial")

		for code, language in availableLanguages() {
			choices.Push(language)

			if (language == this.Value["language"])
				chosen := A_Index

			if (code = "en")
				enIndex := A_Index
		}

		if (chosen == 0)
			chosen := enIndex

		window.Add("Text", "x24 y176 w86 h23 +0x200", translate("Localization"))
		window.Add("DropDownList", "x250 y176 w188 W:Grow Choose" . chosen . " vlanguageDropDown", choices)
		window.Add("Button", "x440 y175 w23 h23 X:Move", translate("...")).OnEvent("Click", openTranslationsEditor)
		button := window.Add("Button", "x224 y175 w23 h23")
		button.OnEvent("Click", openFormatsEditor)
		setButtonIcon(button, kIconsDirectory . "Locale.ico", 1, "L4 T4 R4 B4")

		window.Add("CheckBox", "x24 y200 w242 h23 Checked" . this.Value["startWithWindows"] . " VstartWithWindowsCheck", translate("Start with Windows"))
		window.Add("CheckBox", "x24 y224 w242 h23 Checked" . this.Value["silentMode"] . " VsilentModeCheck", translate("Silent mode (no splash screen, no sound)"))

		window.Add("Button", "x363 y224 w100 h23 X:Move", translate("Themes Editor...")).OnEvent("Click", openThemesEditor)

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "-Theme x16 y265 w458 h115 W:Grow", translate("Simulators"))

		window.SetFont("Norm", "Arial")

		this.iSimulatorsList.createGui(editor, x, y, width, height)

		if this.iDevelopment {
			window.SetFont("Norm", "Arial")
			window.SetFont("Italic", "Arial")

			window.Add("GroupBox", "-Theme x16 y388 w458 h119 W:Grow", translate("Development"))

			window.SetFont("Norm", "Arial")

			window.Add("Text", "x24 y405 w160 h23 +0x200", translate("AutoHotkey Folder"))
			window.Add("Edit", "x224 y406 w214 h21 W:Grow VahkPathEdit", this.Value["ahkPath"])
			window.Add("Button", "x440 y404 w23 h23 X:Move", translate("...")).OnEvent("Click", chooseAHKPath)

			window.Add("Text", "x24 y429 w160 h23 +0x200", translate("MSBuild Bin Folder"))
			window.Add("Edit", "x224 y429 w214 h21 W:Grow VmsBuildPathEdit", this.Value["msBuildPath"])
			window.Add("Button", "x440 y428 w23 h23 X:Move", translate("...")).OnEvent("Click", chooseMSBuildPath)

			window.Add("Text", "x24 y453 w160 h23 +0x200", translate("Debug"))
			window.Add("CheckBox", "x226 y451 w242 h23 Checked" . this.Value["debugEnabled"] . " vdebugEnabledCheck", translate("Enabled?"))

			window.Add("Text", "x24 y477 w160 h23 +0x200", translate("Log Level"))

			choices := ["Info", "Warn", "Critical", "Off"]

			chosen := inList(choices, this.Value["logLevel"])

			if !chosen
				chosen := 2

			window.Add("DropDownList", "x224 y477 w91 Choose" . chosen . " vlogLevelDropDown", collect(choices, translate))
		}
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.Value["nirCmdPath"] := getMultiMapValue(configuration, "Configuration", "NirCmd Path", "")
		this.Value["homePath"] := getMultiMapValue(configuration, "Configuration", "Home Path", "")

		this.Value["language"] := availableLanguages()[getMultiMapValue(configuration, "Configuration", "Language", getLanguage())]
		this.Value["startWithWindows"] := getMultiMapValue(configuration, "Configuration", "Start With Windows", true)
		this.Value["silentMode"] := getMultiMapValue(configuration, "Configuration", "Silent Mode", false)

		if this.iDevelopment {
			this.Value["ahkPath"] := getMultiMapValue(configuration, "Configuration", "AHK Path", "")
			this.Value["msBuildPath"] := getMultiMapValue(configuration, "Configuration", "MSBuild Path", "")
			this.Value["debugEnabled"] := getMultiMapValue(configuration, "Configuration", "Debug", false)
			this.Value["logLevel"] := getMultiMapValue(configuration, "Configuration", "Log Level", "Warn")
		}
	}

	saveToConfiguration(configuration) {
		local window := this.Window
		local languageCode := "en"
		local code, language, choices

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Configuration", "NirCmd Path", this.Control["nirCmdPathEdit"].Text)
		setMultiMapValue(configuration, "Configuration", "Home Path", this.Control["homePathEdit"].Text)

		for code, language in availableLanguages()
			if (language = this.Control["languageDropDown"].Text) {
				languageCode := code

				break
			}

		setMultiMapValue(configuration, "Configuration", "Language", languageCode)
		setMultiMapValue(configuration, "Configuration", "Start With Windows", this.Control["startWithWindowsCheck"].Value)
		setMultiMapValue(configuration, "Configuration", "Silent Mode", this.Control["silentModeCheck"].Value)

		if this.iSplashThemesConfiguration
			addMultiMapValues(configuration, this.iSplashThemesConfiguration)
		else {
			setMultiMapValues(configuration, "Splash Window", getMultiMapValues(this.Configuration, "Splash Window"))
			setMultiMapValues(configuration, "Splash Themes", getMultiMapValues(this.Configuration, "Splash Themes"))
		}

		if this.iFormatsConfiguration
			addMultiMapValues(configuration, this.iFormatsConfiguration)
		else
			setMultiMapValues(configuration, "Localization", getMultiMapValues(this.Configuration, "Localization"))

		if this.iDevelopment {
			setMultiMapValue(configuration, "Configuration", "AHK Path", this.Control["ahkPathEdit"].Text)
			setMultiMapValue(configuration, "Configuration", "MSBuild Path", this.Control["msBuildPathEdit"].Text)
			setMultiMapValue(configuration, "Configuration", "Debug", this.Control["debugEnabledCheck"].Value)

			choices := ["Info", "Warn", "Critical", "Off"]

			setMultiMapValue(configuration, "Configuration", "Log Level", choices[inList(collect(choices, translate), this.Control["logLevelDropDown"].Text)])
		}

		this.iSimulatorsList.saveToConfiguration(configuration)
	}

	getSimulators() {
		local simulators := []
		local simulator, ignore

		for simulator, ignore in getMultiMapValues(getControllerState(), "Simulators")
			simulators.Push(simulator)

		return simulators
	}

	openTranslationsEditor() {
		local window := this.Window
		local choices, chosen, enIndex, code, language

		window.Opt("+Disabled")

		try {
			if (TranslationsEditor(this.Configuration)).editTranslations(window) {
				window.Opt("-Disabled")

				choices := []
				chosen := 0
				enIndex := 1

				for code, language in availableLanguages() {
					choices.Push(language)

					if (language == window["languageDropDown"].Text)
						chosen := A_Index

					if (code = "en")
						enIndex := A_Index
				}

				if (chosen == 0) {
					chosen := enIndex
					languageDropDown := "English"
				}

				window["languageDropDown"].Delete()
				window["languageDropDown"].Add(choices)
				window["languageDropDown"].Choose(chosen)
			}
		}
		finally {
			window.Opt("-Disabled")
		}
	}

	openThemesEditor() {
		local window := this.Window
		local configuration

		window.Opt("+Disabled")

		try {
			configuration := (ThemesEditor(this.iSplashThemesConfiguration ? this.iSplashThemesConfiguration : this.Configuration)).editThemes(window)

			if configuration
				this.iSplashThemesConfiguration := configuration
		}
		finally {
			window.Opt("-Disabled")
		}
	}

	openFormatsEditor() {
		local window := this.Window
		local configuration

		window.Opt("+Disabled")

		try {
			configuration := FormatsEditor(this.iFormatsConfiguration ? this.iFormatsConfiguration : this.Configuration).editFormats(window)

			if configuration
				this.iFormatsConfiguration := configuration
		}
		finally {
			window.Opt("-Disabled")
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SimulatorsList                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SimulatorsList extends ConfigurationItemList {
	__New(configuration) {
		super.__New(configuration)

		SimulatorsList.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local control

		control := window.Add("ListBox", "x24 y284 w194 h96 BackGroundD8D8D8 vsimulatorsListBox")
		control.OnEvent("Change", listEvent.Bind("Click"))
		control.OnEvent("DoubleClick", listEvent.Bind("DoubleClick"))

		window.Add("Edit", "x224 y284 w239 h21 W:Grow VsimulatorEdit")

		window.Add("Button", "x385 y309 w38 h23 X:Move Disabled VsimulatorUpButton", translate("Up")).OnEvent("Click", upItem)
		window.Add("Button", "x425 y309 w38 h23 X:Move Disabled VsimulatorDownButton", translate("Down")).OnEvent("Click", downItem)

		window.Add("Button", "x264 y349 w46 h23 X:Move VsimulatorAddButton", translate("Add")).OnEvent("Click", addItem)
		window.Add("Button", "x312 y349 w50 h23 X:Move Disabled VsimulatorDeleteButton", translate("Delete")).OnEvent("Click", deleteItem)
		window.Add("Button", "x408 y349 w55 h23 X:Move Disabled VsimulatorUpdateButton", translate("&Save")).OnEvent("Click", updateItem)

		this.initializeList(editor, window["simulatorsListBox"], window["simulatorAddButton"], window["simulatorDeleteButton"], window["simulatorUpdateButton"]
								  , window["simulatorUpButton"], window["simulatorDownButton"])
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.ItemList := string2Values("|", getMultiMapValue(configuration, "Configuration", "Simulators", ""))
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Configuration", "Simulators", values2String("|", this.ItemList*))
	}

	clickEvent(line, count) {
		this.openEditor(inList(this.ItemList, this.Control["simulatorsListBox"].Text))
	}

	loadList(items) {
		this.Control["simulatorsListBox"].Delete()
		this.Control["simulatorsListBox"].Add(this.ItemList)
	}

	selectItem(itemNumber) {
		this.CurrentItem := itemNumber

		if itemNumber
			this.Control["simulatorsListBox"].Choose(itemNumber)

		this.updateState()
	}

	loadEditor(item) {
		this.Control["simulatorEdit"].Text := item
	}

	clearEditor() {
		this.loadEditor("")
	}

	buildItemFromEditor(isNew := false) {
		return this.Control["simulatorEdit"].Text
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorConfiguration() {
	global kConfigurationEditor

	local icon := kIconsDirectory . "Configuration.ico"
	local msgResult, initialize

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Configuration"

	kConfigurationEditor := true

	protectionOn()

	if (GetKeyState("Ctrl") && GetKeyState("Shift")) {
		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Do you really want to start with a fresh configuration?"), translate("Configuration"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			initialize := true
		else
			initialize := false
	}
	else
		initialize := false

	try {
		ConfigurationEditor(FileExist("C:\Program Files\AutoHotkey") || GetKeyState("Ctrl")
						 || (getMultiMapValue(kSimulatorConfiguration, "Configuration", "AHK Path", "") != "")
						  , initialize ? newMultiMap() : kSimulatorConfiguration)
	}
	finally {
		protectionOff()
	}

	return
}

startupSimulatorConfiguration() {
	local editor := ConfigurationEditor.Instance
	local done, saved, result

	saveConfiguration(configurationFile, editor) {
		local configuration := newMultiMap()
		local startupLink, startupExe

		editor.saveToConfiguration(configuration)

		writeMultiMap(configurationFile, configuration)

		deleteFile(kTempDirectory . "Simulator Controller.state")

		startupLink := A_Startup . "\Simulator Startup.lnk"

		if getMultiMapValue(configuration, "Configuration", "Start With Windows", false) {
			startupExe := kBinariesDirectory . "Simulator Startup.exe"

			FileCreateShortcut(startupExe, startupLink, kBinariesDirectory)
		}
		else
			deleteFile(startupLink)

		deleteDirectory(kTempDirectory, false)
	}

	editor.createGui(editor.Configuration)

	done := false
	saved := false

	editor.show()

	try {
		loop {
			Sleep(200)

			result := editor.Result

			if (result == kApply) {
				saved := true

				editor.Result := false

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
		ExitApp(1)
	else
		ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 1                     ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorConfiguration()


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Plugins\Configuration Plugins.ahk"
#Include "%A_MyDocuments%\Simulator Controller\Plugins\Configuration Plugins.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                       Initialization Section Part 2                     ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorConfiguration()