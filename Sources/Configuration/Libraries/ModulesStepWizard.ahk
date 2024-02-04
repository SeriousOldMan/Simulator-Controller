;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Mudules Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\SpeechSynthesizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Preset(s)                                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NamedPreset extends Preset {
	iName := false

	Name {
		Get {
			return this.iName
		}
	}

	Installable {
		Get {
			return true
		}
	}

	__New(name) {
		this.iName := name
	}

	getArguments() {
		return Array(this.Name)
	}

	edit(wizard) {
	}
}

class SilentAssistant extends NamedPreset {
	iAssistant := false
	iDisabled := true

	Assistant {
		Get {
			return this.iAssistant
		}
	}

	__New(name, assistant, full := true) {
		this.iAssistant := assistant
		this.iDisabled := ((full = kTrue) ? true : ((full = kFalse) ? false : full))

		super.__New(name)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.Assistant, this.iDisabled))
	}

	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local assistant

		if wizard.isModuleSelected(this.Assistant)
			if (getMultiMapValue(simulatorConfiguration, "Plugins", this.Assistant, kUndefined) != kUndefined) {
				assistant := Plugin(this.Assistant, simulatorConfiguration)

				if this.iDisabled {
					assistant.setArgumentValue("raceAssistantSpeaker", "Off")
					assistant.setArgumentValue("raceAssistantListener", "Off")
				}
				else
					assistant.setArgumentValue("raceAssistantMuted", "true")

				assistant.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class PassiveEngineer extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local definition, name, assistant, ignore, descriptor

		if wizard.isModuleSelected("Race Engineer") {
			definition := wizard.Definition

			for ignore, descriptor in getMultiMapValues(definition, "Applications.Simulators") {
				name := string2Values("|", descriptor)[1]

				if (getMultiMapValue(simulatorConfiguration, "Plugins", name, kUndefined) != kUndefined) {
					assistant := Plugin(name, simulatorConfiguration)

					assistant.setArgumentValue("openPitstopMFD", "Off")

					assistant.saveToConfiguration(simulatorConfiguration)
				}
			}
		}
	}
}

class DifferentVoices extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local synthesizer, language, speaker, voices, ignore, voice, found, candidate, voice1, voice2, assistant

		if wizard.isModuleSelected("Voice Control") {
			synthesizer := getMultiMapValue(simulatorConfiguration, "Voice Control", "Synthesizer")
			language := getMultiMapValue(simulatorConfiguration, "Voice Control", "Language")
			speaker := getMultiMapValue(simulatorConfiguration, "Voice Control", "Speaker")

			voices := []

			if (speaker && (speaker != true))
				voices.Push(speaker)

			for ignore, voice in SpeechSynthesizer(synthesizer, true, language).Voices[language] {
				found := false

				for ignore, candidate in voices {
					voice1 := string2Values("(", voice)[1]
					voice2 := string2Values("(", candidate)[1]

					if ((InStr(voice1, voice2) == 1) || (InStr(voice2, voice1) == 1)) {
						found := true

						break
					}
				}

				if !found
					voices.Push(voice)
			}

			if (voices.Length > 0) {
				voices := reverse(voices)

				for ignore, assistant in string2Values("|", getMultiMapValue(wizard.Definition, "Setup.Modules", "Modules.Definition.Assistants")) {
					if wizard.isModuleSelected(assistant)
						if (getMultiMapValue(simulatorConfiguration, "Plugins", assistant, kUndefined) != kUndefined) {
							assistant := Plugin(assistant, simulatorConfiguration)

							assistant.setArgumentValue("raceAssistantSpeaker", voices.Pop())

							assistant.saveToConfiguration(simulatorConfiguration)

							if (voices.Length == 0)
								break
						}
				}
			}
		}
	}
}

class DefaultButtonBox extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	install(wizard, edit := true) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Button Box Configuration.ini") {
				config := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

				for section, values in readMultiMap(file)
					for key, value in values
						if (getMultiMapValue(config, section, key, kUndefined) == kUndefined)
							setMultiMapValue(config, section, key, value)

				writeMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini", config)
			}
			else
				FileCopy(file, kUserHomeDirectory . "Setup\Button Box Configuration.ini", 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}
}

class DefaultStreamDeck extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	install(wizard, edit := true) {
		local file := this.iFile
		local config, section, values, key, value

		try {
			if FileExist(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini") {
				config := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

				for section, values in readMultiMap(file)
					for key, value in values
						if (getMultiMapValue(config, section, key, kUndefined) == kUndefined)
							setMultiMapValue(config, section, key, value)

				writeMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", config)
			}
			else
				FileCopy(file, kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}
}

class FilesPreset extends NamedPreset {
	iFiles := []

	Directory {
		Get {
			throw "Virtual property FilesPreset.Directory must be implemented in a subclass..."
		}
	}

	Files {
		Get {
			return this.iFiles
		}
	}

	__New(name, files*) {
		local index, file

		super.__New(name)

		for index, file in files
			files[index] := substituteVariables(file)

		this.iFiles := files
	}

	getArguments() {
		return concatenate(super.getArguments(), this.Files)
	}

	install(wizard, edit := true) {
		local directory := this.Directory
		local ignore, file

		for ignore, file in this.Files
			try {
				FileCopy(file, directory, 1)
			}
			catch Any as exception {
				logError(exception)
			}
	}

	uninstall(wizard) {
		local directory := this.Directory
		local ignore, file, name

		for ignore, file in this.Files {
			SplitPath(file, &name)

			deleteFile(directory . name)
		}
	}
}

class StreamDeckIcons extends FilesPreset {
	Directory {
		Get {
			return kUserTranslationsDirectory
		}
	}
}

class PitstopImages extends NamedPreset {
	iDirectory := false

	Directory {
		Get {
			return this.iDirectory
		}
	}

	__New(name, directory) {
		super.__New(name)

		this.iDirectory := substituteVariables(directory)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.Directory))
	}

	install(wizard, edit := true) {
		local directory := this.Directory
		local name

		SplitPath(directory, , , , &name)

		DirCreate(kUserHomeDirectory . "Screen Images\" . name)

		try {
			FileCopy(directory . "\*.*", kUserHomeDirectory . "Screen Images\" . name, 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	uninstall(wizard) {
		local directory := this.Directory
		local name

		SplitPath(directory, , , , &name)

		deleteDirectory(kUserHomeDirectory . "Screen Images\" . name)
	}
}

class TeamServerAlwaysOn extends NamedPreset {
	patchSimulatorConfiguration(wizard, simulatorConfiguration) {
		local thePlugin

		if (wizard.isModuleSelected("Race Engineer") || wizard.isModuleSelected("Race Strategist"))
			if (getMultiMapValue(simulatorConfiguration, "Plugins", "Team Server", kUndefined) != kUndefined) {
				thePlugin := Plugin("Team Server", simulatorConfiguration)

				thePlugin.setArgumentValue("teamServer", "On")

				thePlugin.saveToConfiguration(simulatorConfiguration)
			}
	}
}

class ConfigurationPatch extends NamedPreset {
	edit(wizard) {
		try {
			Run("notepad " . kUserHomeDirectory . "Setup\Configuration Patch.ini")
		}
		catch Any as exception {
			logError(exception)
		}
	}

	install(wizard, edit := true) {
		local configuration

		try {
			if !FileExist(kUserHomeDirectory . "Setup\Configuration Patch.ini")
				FileCopy(kResourcesDirectory . "Setup\Presets\Configuration Patch.ini", kUserHomeDirectory . "Setup", 1)
			else {
				configuration := FileRead(kUserHomeDirectory . "Setup\Configuration Patch.ini")

				if (InStr(configuration, "// Using this file ") != 1) {
					FileMove(kUserHomeDirectory . "Setup\Configuration Patch.ini", kUserHomeDirectory . "Setup\Configuration Patch.ini.bak", 1)
					FileCopy(kResourcesDirectory . "Setup\Presets\Configuration Patch.ini", kUserHomeDirectory . "Setup", 1)
					FileAppend("`n" . configuration, kUserHomeDirectory . "Setup\Configuration Patch.ini")
				}
			}
		}
		catch Any as exception {
			logError(exception)
		}

		if edit
			this.edit(wizard)
	}

	uninstall(wizard) {
		deleteFile(kUserHomeDirectory . "Setup\Configuration Patch.ini")
	}
}

class P2TConfiguration extends NamedPreset {
	__New(name, *) {
		super.__New(name)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(kResourcesDirectory . "Setup\Presets\P2T Configuration.ini"))
	}

	install(wizard, edit := true) {
	}

	uninstall(wizard) {
		deleteFile(kUserConfigDirectory . "P2T Configuration.ini")
	}
}

class StartupProfiles extends NamedPreset {
	__New(name, *) {
		super.__New(name)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(kResourcesDirectory . "Setup\Presets\Startup.settings"))
	}

	install(wizard, edit := true) {
		try {
			FileCopy(kResourcesDirectory . "Setup\Presets\Startup.settings", kUserConfigDirectory . "Startup.settings", 1)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	uninstall(wizard) {
		deleteFile(kUserConfigDirectory . "Startup.settings")
	}
}

class SetupPatch extends NamedPreset {
	iFile := false

	File {
		Get {
			return this.iFile
		}
	}

	__New(name, file) {
		super.__New(name)

		this.iFile := substituteVariables(file)
	}

	getArguments() {
		return concatenate(super.getArguments(), Array(this.File))
	}

	edit(wizard) {
		local file := this.File
		local name

		SplitPath(file, &name)

		try {
			Run("notepad " . kUserHomeDirectory . "Setup\" . name)
		}
		catch Any as exception {
			logError(exception)
		}
	}

	install(wizard, edit := true) {
		local file := this.File
		local name

		SplitPath(file, &name)

		try {
			FileCopy(file, kUserHomeDirectory . "Setup\" . name, 1)
		}
		catch Any as exception {
			logError(exception)
		}

		if edit
			this.edit(wizard)
	}

	uninstall(wizard) {
		local name, configuration

		SplitPath(this.File, &name)

		if ((name = "Configuration Patch.ini") && FileExist(kUserHomeDirectory . "Setup\Configuration Patch.ini")) {
			configuration := FileRead(kUserHomeDirectory . "Setup\Configuration Patch.ini")

			if (InStr(configuration, "// Using this file ") = 1)
				return
		}

		deleteFile(kUserHomeDirectory . "Setup\" . name)
	}
}

class DownloadablePreset extends NamedPreset {
	iURL := false
	iDefnition := false

	iWindow := false
	iClosed := false

	iObjectsListView := false

	Installable {
		Get {
			return false
		}
	}

	URL {
		Get {
			return this.iURL
		}
	}

	Definition {
		Get {
			return this.iDefinition
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	ObjectsListView {
		Get {
			return this.iObjectsListView
		}

		Set {
			return (this.iObjectsListView := value)
		}
	}

	__New(name, url) {
		this.iURL := url

		super.__New(name)
	}

	createGui(definition) {
		local choices, chosen, code, language, languageName, isoCode
		local dlcGui

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		close(*) {
			this.iClosed := true
		}

		chooseObject(listView, line, checked) {
			if checked
				this.install(listView.GetText(line))
			else
				this.uninstall(listView.GetText(line))
		}

		dlcGui := Window({Descriptor: "DLC Manager", Options: "0x400000"}, "")

		this.iWindow := dlcGui

		dlcGui.SetFont("Bold", "Arial")

		dlcGui.Add("Text", "w288 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(dlcGui, "DLC Manager"))

		dlcGui.SetFont("Norm", "Arial")

		dlcGui.Add("Documentation", "x58 YP+20 w188 H:Center Center", translate("Downloadable Components")
						 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#presets--special-configurations")

		dlcGui.SetFont("Norm", "Arial")

		dlcGui.Add("Text", "x8 y+10 w294 W:Grow 0x10")

		this.iObjectsListView := dlcGui.Add("ListView", "x16 y+10 w277 h340 W:Grow H:Grow -Multi -LV0x10 Checked AltSubmit NoSort NoSortHdr", collect([this.className()], translate))
		this.iObjectsListView.OnEvent("Click", noSelect)
		this.iObjectsListView.OnEvent("DoubleClick", noSelect)
		this.iObjectsListView.OnEvent("ItemCheck", chooseObject)

		dlcGui.Add("Text", "x8 y+10 w294 W:Grow 0x10")

		dlcGui.Add("Button", "x118 yp+10 w80 h23 Default", translate("Close")).OnEvent("Click", close)

		this.loadObjects()
	}

	edit(wizard) {
		local window := false
		local x, y, w, h

		try {
			this.iClosed := false
			this.iDefinition := this.loadDefinition(this.URL)

			this.createGui(this.Definition)

			window := this.Window

			wizard.Window.Block()

			try {
				window.Opt("+Owner" . wizard.Window.Hwnd)

				if getWindowPosition("DLC Manager", &x, &y)
					window.Show("x" . x . " y" . y)
				else
					window.Show()

				loop
					Sleep(200)
				until this.iClosed
			}
			finally {
				window.Destroy()

				wizard.Window.Unblock()
			}
		}
		catch Any as exception {
			logError(exception, true)

			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("The download repository is currently unavailable. Please try again later."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	loadDefinition(url) {
		throw "Virtual method DownloadablePreset.loadDefinition must be implemented in a subclass..."
	}

	loadObjects() {
		local installed := this.installedObjects()
		local ignore, object

		this.ObjectsListView.Delete()

		for ignore, object in this.availableObjects()
			this.ObjectsListView.Add(inList(installed, this.objectName(object)) ? "Check" : "", this.objectName(object))
	}

	install(name) {
		local installed := this.installedObjects()
		local ignore, object

		for ignore, object in this.availableObjects()
			if ((name = this.objectName(object)) && !inList(installed, object))
				this.installObject(object)
	}

	uninstall(name) {
		local installed := this.installedObjects()
		local ignore, object

		for ignore, object in this.availableObjects()
			if ((name = this.objectName(object)) && inList(installed, object))
				this.uninstallObject(object)
	}

	className() {
		return translate("Object")
	}

	objectName(object) {
		if this.Definition
			return getMultiMapValue(this.Definition, object, "Name", object)
		else
			return Object
	}

	availableObjects() {
		throw "Virtual method DownloadablePreset.availableObjects must be implemented in a subclass..."
	}

	installedObjects() {
		throw "Virtual method DownloadablePreset.installedObjects must be implemented in a subclass..."
	}

	installObject(object) {
		throw "Virtual method DownloadablePreset.installObject must be implemented in a subclass..."
	}

	uninstallObject(object) {
		throw "Virtual method DownloadablePreset.uninstallObject must be implemented in a subclass..."
	}
}

class AssettoCorsaCarMetas extends DownloadablePreset {
	loadDefinition(url) {
		if (Trim(url) != "") {
			deleteFile(A_Temp . "\Simulator Controller.zip")

			Download(url, A_Temp . "\Simulator Controller DLC.zip")

			deleteDirectory(A_Temp . "\Simulator Controller DLC")

			DirCreate(A_Temp . "\Simulator Controller DLC")

			RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . A_Temp . "\Simulator Controller DLC.zip' -DestinationPath '" . A_Temp . "\Simulator Controller DLC' -Force", , "Hide")
		}

		return readMultiMap(A_Temp . "\Simulator Controller DLC\Cars.ini")
	}

	className() {
		return translate("Car")
	}

	availableObjects() {
		return getKeys(this.Definition)
	}

	installedObjects() {
		return getKeys(getMultiMapValues(readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini"), "Car Codes"))
	}

	installObject(car) {
		local carName := getMultiMapValue(this.Definition, car, "Name")
		local carCode := getMultiMapValue(this.Definition, car, "Code")
		local carData := readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini")
		local tyreData := readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Tyre Data.ini")
		local setting

		setMultiMapValue(carData, "Car Codes", carName, carCode)
		setMultiMapValue(carData, "Car Names", carCode, carName)

		loop {
			setting := getMultiMapValue(this.Definition, car, "Pitstop Settings." . A_Index, kUndefined)

			if (setting = kUndefined)
				break
			else {
				setting := string2Values("=", setting)

				setMultiMapValue(carData, "Pitstop Settings", carCode . "." . setting[1], setting[2])
			}
		}

		writeMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini", carData)

		setMultiMapValue(tyreData, "Cars", carCode . ";*", getMultiMapValue(this.Definition, car, "Tyres"))

		writeMultiMap(kUserHomeDirectory . "Simulator Data\AC\Tyre Data.ini", tyreData)

		FileCopy(A_Temp . "\Simulator Controller DLC\" . getMultiMapValue(this.Definition, car, "Definition")
			   , kUserHomeDirectory . "Garage\Definitions\Cars", 1)

		FileCopy(A_Temp . "\Simulator Controller DLC\" . getMultiMapValue(this.Definition, car, "Rules")
			   , kUserHomeDirectory . "Garage\Rules\Cars", 1)
	}

	uninstallObject(car) {
		local carName := getMultiMapValue(this.Definition, car, "Name")
		local carCode := getMultiMapValue(this.Definition, car, "Code")
		local carData := readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini")
		local tyreData := readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Tyre Data.ini")
		local setting

		removeMultiMapValue(carData, "Car Codes", carName)
		removeMultiMapValue(carData, "Car Names", carCode)

		writeMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini", carData)

		removeMultiMapValue(tyreData, "Cars", carCode . ";*")

		writeMultiMap(kUserHomeDirectory . "Simulator Data\AC\Tyre Data.ini", tyreData)

		deleteFile(kUserHomeDirectory . "Garage\Definitions\Cars\" . getMultiMapValue(this.Definition, car, "Definition"))
		deleteFile(kUserHomeDirectory . "Garage\Rules\Cars\" . getMultiMapValue(this.Definition, car, "Rules"))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ModulesStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ModulesStepWizard extends StepWizard {
	iModuleSelectors := []

	iAvailablePresetsListView := false
	iSelectedPresetsListView := false

	iPresetsPage := false

	Pages {
		Get {
			return (this.SetupWizard.BasicSetup ? 0 : (Ceil(this.Definition.Length / 3) + 1))
		}
	}

	AvailablePresetsListView {
		Get {
			return this.iAvailablePresetsListView
		}
	}

	SelectedPresetsListView {
		Get {
			return this.iSelectedPresetsListView
		}
	}

	createGui(wizard, x, y, width, height) {
		local definition := this.Definition
		local window := this.Window
		local startY := y
		local checkX := x + width - 20
		local labelWidth := width - 30
		local listWidth := Round((width - 50) / 2)
		local x2 := x + listWidth + 50
		local buttonWidth := 40
		local x3 := x + listWidth + 5
		local module, selected, info, label, labelX, labelY, html, factor

		compose(functions*) {
			callFunctions(functions, arguments*) {
				local ignore, function

				for ignore, function in functions
					function.Call(arguments*)
			}

			return callFunctions.Bind(functions)
		}

		choosePreset(list1, list2) {
			local next, selected

			selected := list1.GetNext()

			while selected {
				list1.Modify(selected, "-Select")

				selected := list1.GetNext()
			}

			if selected
				list2.Modify(selected, "+Select")

			this.updatePresetState()
		}

		selectAvailablePreset(listView, line, selected) {
			if selected
				chooseAvailablePreset()
		}

		chooseAvailablePreset(*) {
			choosePreset(this.SelectedPresetsListView, this.AvailablePresetsListView)
		}

		selectSelectedPreset(listView, line, selected) {
			if selected
				chooseSelectedPreset()
		}

		chooseSelectedPreset(*) {
			choosePreset(this.AvailablePresetsListView, this.SelectedPresetsListView)
		}

		editSelectedPreset(*) {
			choosePreset(this.AvailablePresetsListView, this.SelectedPresetsListView)

			this.editPreset()
		}

		installPreset(*) {
			this.installPreset()
		}

		uninstallPreset(*) {
			this.uninstallPreset()
		}

		updateSelectedModules(*) {
			this.updateSelectedModules()
		}

		this.iPresetsPage := (Ceil(definition.Length / 3) + 1)

		loop definition.Length {
			window.SetFont("s10 Bold", "Arial")

			module := definition[A_Index]
			selected := this.SetupWizard.isModuleSelected(module)

			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Info." . getLanguage()))
			module := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . "." . getLanguage()))

			label := substituteVariables(translate("Module: %module%"), {module: module})
			info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

			labelX := x + 35
			labelY := y + 8

			factor := (Mod(A_Index - 1, 3) * 0.33)

			widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Y:Move(" . factor . ") Hidden", kResourcesDirectory . "Setup\Images\Module.png")
			widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Y:Move(" . factor . ") Hidden", label)
			widget3 := window.Add("CheckBox", "Checked" . selected . " x" . checkX . " y" . labelY . " w23 h23 X:Move Y:Move(" . factor . ") Hidden")
			widget3.OnEvent("Click", updateSelectedModules)
			widget4 := window.Add("HTMLViewer", "x" . x . " yp+26 w" . width . " h120 Y:Move(" . factor . ") W:Grow H:Grow(0.33) Hidden")

			html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			widget4.document.write(html)

			y += 163

			this.iModuleSelectors.Push(widget3)

			this.registerWidgets(Ceil(A_Index / 3), widget1, widget2, widget3, widget4)

			if (((A_Index / 3) - Floor(A_Index / 3)) == 0)
				y := startY
		}

		y := startY
		labelX := x + 35
		labelY := y + 8

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Module.png")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Presets && Special Configurations"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("ListView", "x" . x . " yp+30 w" . listWidth . " h224 X:Move(0.5) H:Grow(0.7) AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden Section", collect(["Available Presets"], translate))
		widget3.OnEvent("Click", chooseAvailablePreset)
		widget3.OnEvent("DoubleClick", compose(chooseAvailablePreset, installPreset))
		widget3.OnEvent("ItemSelect", selectAvailablePreset)

		this.iAvailablePresetsListView := widget3

		widget4 := window.Add("ListView", "x" . x2 . " ys w" . listWidth . " h224 X:Move(0.5) H:Grow(0.7) AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden", collect(["Selected Presets"], translate))
		widget4.OnEvent("Click", chooseSelectedPreset)
		widget4.OnEvent("DoubleClick", compose(chooseSelectedPreset, editSelectedPreset))
		widget4.OnEvent("ItemSelect", selectSelectedPreset)

		this.iSelectedPresetsListView := widget4

		window.SetFont("s10 Bold", "Arial")

		widget5 := window.Add("Button", "x" . x3 . " ys+95 w" . buttonWidth . " X:Move(0.5) Y:Move(0.35) vinstallPresetButton  Hidden", ">")
		widget5.OnEvent("Click", installPreset)
		widget6 := window.Add("Button", "x" . x3 . " yp+30 w" . buttonWidth . " X:Move(0.5) Y:Move(0.35) vuninstallPresetButton  Hidden", "<")
		widget6.OnEvent("Click", uninstallPreset)

		window.SetFont("s8 Norm", "Arial")

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget7 := window.Add("HTMLViewer", "x" . x . " ys+229 w" . width . " h210 Y:Move(0.7) W:Grow H:Grow(0.3) VpresetsInfoText Hidden")

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget7.document.write(html)

		this.registerWidgets(this.iPresetsPage, widget1, widget2, widget3, widget4, widget5, widget6, widget7)
	}

	reset() {
		super.reset()

		this.iModuleSelectors := []
	}

	showPage(page) {
		super.showPage(page)

		if (page = this.iPresetsPage) {
			this.loadAvailablePresets()
			this.loadSelectedPresets()

			this.updatePresetState()
		}
	}

	updateState() {
		local definition := this.Definition

		super.updateState()

		loop definition.Length
			this.iModuleSelectors[A_Index].Value := this.SetupWizard.isModuleSelected(definition[A_Index])
	}

	updateSelectedModules() {
		local definition := this.Definition
		local selector, name, checked

		loop definition.Length {
			selector := this.iModuleSelectors[A_Index]
			name := definition[A_Index]

			checked := selector.Value

			if (checked != this.SetupWizard.isModuleSelected(name)) {
				this.SetupWizard.selectModule(name, checked)

				return
			}
		}
	}

	loadAvailablePresets() {
		local definition := this.Definition
		local presets := []
		local preset, module, modulePresets, ignore

		this.AvailablePresetsListView.Delete()

		loop definition.Length {
			module := definition[A_Index]

			if this.SetupWizard.isModuleSelected(module) {
				modulePresets := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

				for ignore, preset in string2Values("|", modulePresets)
					if (isDevelopment() ||
						(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Active", true)
					  && !getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Deprecated", false)))
						this.AvailablePresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
			}
		}

		for ignore, preset in string2Values("|", substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			if (isDevelopment() ||
				(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Active", true)
			  && !getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Deprecated", false)))
				this.AvailablePresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))

		this.AvailablePresetsListView.ModifyCol()
		this.AvailablePresetsListView.ModifyCol(1, "AutoHdr")
	}

	loadSelectedPresets() {
		local presets := []
		local ignore, preset

		this.SelectedPresetsListView.Delete()

		for ignore, preset in this.SetupWizard.Presets
			this.SelectedPresetsListView.Add("", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset.Name . "." . getLanguage()))

		this.SelectedPresetsListView.ModifyCol()
		this.SelectedPresetsListView.ModifyCol(1, "AutoHdr")
	}

	presetName(label) {
		local definition := this.Definition
		local preset, module, modulePresets, ignore, preset

		loop definition.Length {
			module := definition[A_Index]

			modulePresets := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules." . module . ".Presets", ""))

			for ignore, preset in string2Values("|", modulePresets)
				if (label = getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
					return preset
		}

		for ignore, preset in string2Values("|", substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets", "")))
			if (label = getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . "." . getLanguage()))
				return preset

		return false
	}

	presetInfo(name) {
		local entries := getMultiMapValues(this.SetupWizard.Definition, "Setup.Modules")
		local keys := getKeys(entries)
		local index := inList(keys, "Modules.Presets." . name . ".Info." . getLanguage())

		if !index
			if (name = "ACCDualQHDSingleNoHDRDE")
				index := inList(keys, "Buggy1")
			else if (name = "R3EFullHDTripleNoHDREN")
				index := inList(keys, "Buggy2")

		return (index ? substituteVariables(getValues(entries)[index]) : false)
	}

	updatePresetState() {
		local info := false
		local preset, selected, enable, ignore, candidate, info, html, class, arguments

		this.Control["installPresetButton"].Enabled := false
		this.Control["uninstallPresetButton"].Enabled := false

		selected := this.AvailablePresetsListView.GetNext()

		if selected {
			preset := this.AvailablePresetsListView.GetText(selected, 1)

			preset := this.presetName(preset)

			class := getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Class")
			arguments := string2Values(",", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Arguments", ""))

			preset := %class%(preset, arguments*)

			if preset.Installable {
				enable := true

				for ignore, candidate in this.SetupWizard.Presets
					if (candidate.Name = preset.Name) {
						enable := false

						break
					}

				if enable
					this.Control["installPresetButton"].Enabled := true
			}

			info := this.presetInfo(preset.Name)
		}

		selected := this.SelectedPresetsListView.GetNext()

		if selected {
			this.Control["uninstallPresetButton"].Enabled := true

			if !info {
				preset := this.SelectedPresetsListView.GetText(selected, 1)

				preset := this.presetName(preset)

				info := this.presetInfo(preset)
			}
		}

		if !info
			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets.Info." . getLanguage()))

		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		html := "<html><body style='background-color: #" . this.Window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		this.Control["presetsInfoText"].document.open()
		this.Control["presetsInfoText"].document.write(html)
		this.Control["presetsInfoText"].document.close()
	}

	installPreset() {
		local preset, selected, label, class, arguments

		selected := this.AvailablePresetsListView.GetNext()

		if selected {
			label := this.AvailablePresetsListView.GetText(selected, 1)

			preset := this.presetName(label)

			class := getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Class")
			arguments := string2Values(",", getMultiMapValue(this.SetupWizard.Definition, "Setup.Modules", "Modules.Presets." . preset . ".Arguments", ""))

			preset := %class%(preset, arguments*)

			if preset.Installable {
				this.SetupWizard.installPreset(preset)

				this.loadSelectedPresets()
			}
			else
				preset.edit(this.SetupWizard)

			this.updatePresetState()
		}
	}

	uninstallPreset() {
		local selected := this.SelectedPresetsListView.GetNext()

		if selected {
			this.SetupWizard.uninstallPreset(this.SetupWizard.Presets[selected])

			this.SelectedPresetsListView.Delete(selected)

			this.updatePresetState()
		}
	}

	editPreset() {
		local selected := this.SelectedPresetsListView.GetNext()

		if selected
			this.SetupWizard.Presets[selected].edit(this.SetupWizard)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeModulesStepWizard() {
	SetupWizard.Instance.registerStepWizard(ModulesStepWizard(SetupWizard.Instance, "Modules", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeModulesStepWizard()