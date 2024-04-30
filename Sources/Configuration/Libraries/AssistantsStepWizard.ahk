;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Assistants Step Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ControllerStepWizard.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; AssistantsStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class AssistantsStepWizard extends ActionsStepWizard {
	iCurrentAssistant := false

	iControllerWidgets := []

	iActionsListViews := []
	iAssistantConfigurators := []

	iCachedActions := false

	Pages {
		Get {
			local wizard := this.SetupWizard
			local count, ignore, assistant

			if wizard.BasicSetup
				return 0
			else {
				count := 0

				for ignore, assistant in this.Definition
					if wizard.isModuleSelected(assistant)
						count += 1

				return count
			}
		}
	}

	TransposePage[page] {
		Get {
			local wizard := this.SetupWizard
			local count := 0
			local index, assistant

			for index, assistant in this.Definition
				if (wizard.isModuleSelected(assistant) && (++count == page))
					return index

			return 0
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local assistantActive := false
		local function, action, ignore, assistant, assistantConfiguration, section, subConfiguration, arguments, voice, improver
		local actions

		super.saveToConfiguration(configuration)

		for ignore, assistant in this.Definition
			if wizard.isModuleSelected(assistant) {
				assistantActive := true

				assistantConfiguration := readMultiMap(kUserHomeDirectory . "Setup\" . assistant . " Configuration.ini")

				for ignore, section in ["Race Assistant Startup", "Race Assistant Shutdown", "Race Engineer Startup", "Race Engineer Shutdown"
									  , "Race Strategist Startup", "Race Strategist Shutdown"
									  , "Race Engineer Analysis", "Race Strategist Analysis", "Race Strategist Reports"
									  , "Race Spotter Analysis", "Race Spotter Announcements"
									  , "Driving Coach Conversations", "Driving Coach Service", "Driving Coach Personality"] {
					subConfiguration := getMultiMapValues(assistantConfiguration, section, false)

					if subConfiguration
						setMultiMapValues(configuration, section, subConfiguration)
				}

				if (assistant = "Race Engineer")
					arguments := ("raceAssistantName: " . wizard.getModuleValue(assistant, "Name", "Jona"))
				else if (assistant = "Race Strategist")
					arguments := ("raceAssistantName: " . wizard.getModuleValue(assistant, "Name", "Khato"))
				else if (assistant = "Race Spotter")
					arguments := ("raceAssistantName: " . wizard.getModuleValue(assistant, "Name", "Elisa"))
				else if (assistant = "Driving Coach")
					arguments := ("raceAssistantName: " . wizard.getModuleValue(assistant, "Name", "Aiden"))
				else
					throw "Unsupported race assistant detected in AssistantsStepWizard.saveToConfiguration..."

				actions := ""

				for ignore, action in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Assistants", "Assistants.Actions"))
					if wizard.assistantActionAvailable(assistant, action) {
						function := wizard.getAssistantActionFunction(assistant, action)

						if !isObject(function)
							function := ((function && (function != "")) ? Array(function) : [])

						if (function.Length > 0) {
							if (actions != "")
								actions .= ", "

							actions .= (StrReplace(action, "InformationRequest.", "InformationRequest ") . A_Space . values2String(A_Space, function*))
						}
					}

				if (actions != "")
					arguments .= ("; assistantCommands: " . actions)

				if wizard.isModuleSelected("Voice Control") {
					if (wizard.getModuleValue(assistant, "Language", kUndefined) != kUndefined)
						arguments .= ("; raceAssistantLanguage: " . wizard.getModuleValue(assistant, "Language"))

					if (wizard.getModuleValue(assistant, "Synthesizer", kUndefined) != kUndefined)
						arguments .= ("; raceAssistantSynthesizer: " . wizard.getModuleValue(assistant, "Synthesizer"))

					voice := wizard.getModuleValue(assistant, "Voice", true)

					if (voice == true)
						voice := "On"
					else if (voice == false)
						voice := "Off"

					arguments .= ("; raceAssistantSpeaker: " . voice . "; raceAssistantListener: On")

					if ((wizard.getModuleValue(assistant, "Volume", "*") != "*") || (wizard.getModuleValue(assistant, "Pitch", "*") != "*")
																				 || (wizard.getModuleValue(assistant, "Speed", "*") != "*"))
						arguments .= ("; raceAssistantSpeakerVocalics: " . values2String(",", wizard.getModuleValue(assistant, "Volume", "*")
																							, wizard.getModuleValue(assistant, "Pitch", "*")
																							, wizard.getModuleValue(assistant, "Speed", "*")))

					improver := wizard.getModuleValue(assistant, "Improver", false)

					if improver {
						improver := string2Map("|||", "--->>>", improver)

						arguments .= ("; raceAssistantSpeakerImprover: " . assistant)

						setMultiMapValue(configuration, "Voice Improver", assistant . ".Service", improver["Service"])
						setMultiMapValue(configuration, "Voice Improver", assistant . ".Model", improver["Model"])
						setMultiMapValue(configuration, "Voice Improver", assistant . ".Temperature", improver["Temperature"])
					}
				}
				else
					arguments .= "; raceAssistantSpeaker: Off"

				for ignore, action in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Assistants", "Assistants.Actions.Special"))
					if wizard.assistantActionAvailable(assistant, action) {
						function := wizard.getAssistantActionFunction(assistant, action)

						if !isObject(function)
							function := ((function && (function != "")) ? Array(function) : [])

						if (function.Length > 0)
							switch action, false {
								case "RaceAssistant":
									arguments .= ("; raceAssistant: On " . values2String(A_Space, function*))
								case "TeamServer":
									arguments .= ("; teamServer: Off " . values2String(A_Space, function*))
								case "SessionDatabaseOpen", "SetupDatabaseOpen":
									arguments .= ("; openSessionDatabase: " . values2String(A_Space, function*))
								case "RaceSettingsOpen":
									arguments .= ("; openRaceSettings: " . values2String(A_Space, function*))
								case "RaceReportsOpen":
									arguments .= ("; openRaceReports: " . values2String(A_Space, function*))
								case "StrategyWorkbenchOpen":
									arguments .= ("; openStrategyWorkbench: " . values2String(A_Space, function*))
								case "PracticeCenterOpen":
									arguments .= ("; openPracticeCenter: " . values2String(A_Space, function*))
								case "RaceCenterOpen":
									arguments .= ("; openRaceCenter: " . values2String(A_Space, function*))
								case "SetupWorkbenchOpen":
									arguments .= ("; openSetupWorkbench: " . values2String(A_Space, function*))
								case "SetupImport":
									arguments .= ("; importSetup: " . values2String(A_Space, function*))
								default:
									throw "Unsupported special action detected in AssistantsStepWizard.saveToConfiguration..."
							}
					}

				Plugin(assistant, false, true, "", arguments).saveToConfiguration(configuration, false)
			}
			else
				Plugin(assistant, false, false, "", "").saveToConfiguration(configuration, false)

		Plugin("Team Server", false, assistantActive, "", "").saveToConfiguration(configuration, false)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local widgets
		local page, assistant, labelWidth, labelX, labelY, label
		local listX, listY, listWidth, info, html, configurator, colWidth, wddget

		resizeAllowed(control, &rule) {
			if (control.Name = "dcInstructionsEdit") {
				rule := "H:Grow(0.66)"

				return true
			}
			else
				return false
		}

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		assistantActionFunctionSelect(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		assistantActionFunctionMenu(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		for page, assistant in this.Definition {
			widgets := []

			labelWidth := width - 30
			labelX := x + 35
			labelY := y + 8

			window.SetFont("s10 Bold", "Arial")

			label := substituteVariables(translate("%assistant% Configuration"), {assistant: translate(assistant)})

			widgets.Push(window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Artificial Intelligence.ico"))
			widgets.Push(window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden Section", label))

			window.SetFont("s8 Norm", "Arial")

			listX := x + 375
			listY := labelY + 30
			listWidth := width - 375

			window.SetFont("Bold", "Arial")

			widgets.Push(window.Add("Text", "x" . listX . " yp+30 w" . listWidth . " h23 +0x200 Hidden Section", translate("Actions")))
			widgets.Push(window.Add("Text", "yp+20 x" . listX . " w" . listWidth . " W:Grow 0x10 Hidden"))

			window.SetFont("Norm", "Arial")

			widget := window.Add("ListView", "x" . listX . " yp+10 w" . listWidth . " h347 H:Grow(0.66) W:Grow AltSubmit -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Action", "Label", "Function"], translate))
			widget.OnEvent("Click", assistantActionFunctionSelect)
			widget.OnEvent("DoubleClick", assistantActionFunctionSelect)
			widget.OnEvent("ContextMenu", assistantActionFunctionMenu)

			widgets.Push(widget)

			this.iActionsListViews.Push(widget)

			info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Assistants", "Assistants.Actions.Info." . getLanguage()))
			info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

			widget := window.Add("HTMLViewer", "x" . x . " yp+352 w" . width . " h58 Y:Move(0.66) W:Grow H:Grow(0.33) VactionsInfoText" . page . " Hidden")

			html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

			widget.document.write(html)

			widgets.Push(widget)

			if (assistant = "Race Engineer")
				configurator := RaceEngineerConfigurator(this)
			else if (assistant = "Race Strategist")
				configurator := RaceStrategistConfigurator(this)
			else if (assistant = "Race Spotter")
				configurator := RaceSpotterConfigurator(this)
			else if (assistant = "Driving Coach")
				configurator := DrivingCoachConfigurator(this)
			else
				configurator := false

			colWidth := 375 - x

			window.SetFont("Bold", "Arial")

			widget := window.Add("Text", "x" . x . " ys w" . colWidth . " h23 +0x200 Hidden Section", translate("Configuration"))
			widgets.Push(widget)
			this.iControllerWidgets.Push(widget)

			widget := window.Add("Text", "yp+20 x" . x . " w" . colWidth . " 0x10 Hidden")
			widgets.Push(widget)
			this.iControllerWidgets.Push(widget)

			window.SetFont("Norm", "Arial")

			if configurator {
				this.iAssistantConfigurators.Push(configurator)

				window.Resizeable := resizeAllowed

				configurator.createGui(this, x, listY + 30, colWidth, height)

				window.Resizeable := true
			}

			this.registerWidgets(page, widgets*)
		}
	}

	registerWidget(page, widget) {
		local index := inList(this.iAssistantConfigurators, page)

		if index
			super.registerWidget(index, widget)
		else
			super.registerWidget(page, widget)
	}

	startSetup(new) {
		local configuration, ignore, section

		if !new {
			configuration := readMultiMap(kUserHomeDirectory . "Setup\Driving Coach Configuration.ini")

			for ignore, section in ["Driving Coach Conversations", "Driving Coach Service", "Driving Coach Personality"]
				setMultiMapValues(configuration, section, getMultiMapValues(kSimulatorConfiguration, section), false)

			writeMultiMap(kUserHomeDirectory . "Setup\Driving Coach Configuration.ini", configuration)

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Race Engineer Configuration.ini")

			for ignore, section in ["Race Assistant Startup", "Race Assistant Shutdown", "Race Engineer Startup", "Race Engineer Shutdown", "Race Engineer Analysis"]
				setMultiMapValues(configuration, section, getMultiMapValues(kSimulatorConfiguration, section), false)

			writeMultiMap(kUserHomeDirectory . "Setup\Race Engineer Configuration.ini", configuration)

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Race Strategist Configuration.ini")

			for ignore, section in ["Race Strategist Startup", "Race Strategist Shutdown", "Race Strategist Analysis", "Race Strategist Reports"]
				setMultiMapValues(configuration, section, getMultiMapValues(kSimulatorConfiguration, section), false)

			writeMultiMap(kUserHomeDirectory . "Setup\Race Strategist Configuration.ini", configuration)

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Race Spotter Configuration.ini")

			for ignore, section in ["Race Spotter Analysis", "Race Spotter Announcements"]
				setMultiMapValues(configuration, section, getMultiMapValues(kSimulatorConfiguration, section), false)

			writeMultiMap(kUserHomeDirectory . "Setup\Race Spotter Configuration.ini", configuration)
		}
	}

	reset() {
		super.reset()

		this.iControllerWidgets := []

		this.iAssistantConfigurators := []
		this.iActionsListViews := []
		this.iCachedActions := false
	}

	showPage(page) {
		local ignore, widget, configuration, assistantConfiguration, section, subConfiguration

		page := this.TransposePage[page]

		this.iCurrentAssistant := this.Definition[page]

		this.setActionsListView(this.iActionsListViews[page])

		super.showPage(page)

		if !this.SetupWizard.isModuleSelected("Controller")
			for ignore, widget in this.iControllerWidgets
				widget.Visible := false

		configuration := this.SetupWizard.getSimulatorConfiguration()
		assistantConfiguration := readMultiMap(kUserHomeDirectory . "Setup\" . this.iCurrentAssistant . " Configuration.ini")

		for ignore, section in ["Race Assistant Startup", "Race Assistant Shutdown", "Race Engineer Startup", "Race Engineer Shutdown"
							  , "Race Strategist Startup", "Race Strategist Shutdown"
							  , "Race Engineer Analysis", "Race Strategist Analysis", "Race Strategist Reports"
							  , "Race Spotter Analysis", "Race Spotter Announcements"
							  , "Driving Coach Conversations", "Driving Coach Service", "Driving Coach Personality"] {
			subConfiguration := getMultiMapValues(assistantConfiguration, section, false)

			if subConfiguration
				setMultiMapValues(configuration, section, subConfiguration)
		}

		this.iAssistantConfigurators[page].loadConfigurator(configuration, this.getSimulators())
	}

	hidePage(page) {
		local ignore, configurator, configuration, assistantConfiguration, section, subConfiguration

		page := this.TransposePage[page]

		if super.hidePage(page) {
			configurator := this.iAssistantConfigurators[page]

			configuration := newMultiMap()

			configurator.saveToConfiguration(configuration)

			assistantConfiguration := newMultiMap()

			for ignore, section in ["Race Assistant Startup", "Race Assistant Shutdown", "Race Engineer Startup", "Race Engineer Shutdown"
								  , "Race Strategist Startup", "Race Strategist Shutdown"
								  , "Race Engineer Analysis", "Race Strategist Analysis", "Race Strategist Reports"
								  , "Race Spotter Analysis", "Race Spotter Announcements"
								  , "Driving Coach Conversations", "Driving Coach Service", "Driving Coach Personality"] {
				subConfiguration := getMultiMapValues(configuration, section, false)

				if subConfiguration
					setMultiMapValues(assistantConfiguration, section, subConfiguration)
			}

			writeMultiMap(kUserHomeDirectory . "Setup\" . this.iCurrentAssistant . " Configuration.ini", assistantConfiguration)

			return true
		}
		else
			return false
	}

	getSimulators() {
		if this.iCurrentAssistant
			return this.SetupWizard.assistantSimulators(this.iCurrentAssistant)
		else
			return []
	}

	getModule() {
		return this.iCurrentAssistant
	}

	getModes() {
		return [false]
	}

	getActions(mode := false) {
		local wizard, actions

		if this.iCachedActions
			return this.iCachedActions
		else {
			wizard := this.SetupWizard

			actions := concatenate(string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Assistants", "Assistants.Actions"))
													, string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Assistants", "Assistants.Actions.Special")))

			wizard.setModuleAvailableActions(this.iCurrentAssistant, false, actions)

			this.iCachedActions := actions

			return actions
		}
	}

	setAction(row, mode, action, actionDescriptor, label, argument := false) {
		local wizard := this.SetupWizard
		local function, functions, ignore

		super.setAction(row, mode, action, actionDescriptor, label, argument)

		functions := this.getActionFunction(false, action)

		if functions
			for ignore, function in functions
				if (function && (function != ""))
					wizard.addModuleStaticFunction(this.iCurrentAssistant, function, label)
	}

	clearActionFunction(mode, action, function) {
		super.clearActionFunction(mode, action, function)

		this.SetupWizard.removeModuleStaticFunction(this.iCurrentAssistant, function)
	}

	loadActions(load := false) {
		if (this.iCurrentAssistant && this.SetupWizard.isModuleSelected(this.iCurrentAssistant))
			this.loadAssistantActions(this.iCurrentAssistant, load)
	}

	validateActions() {
		local wizard := this.SetupWizard
		local ignore, assistant, action, function, index

		for ignore, assistant in this.Definition
			if wizard.isModuleSelected(assistant)
				for ignore, action in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Assistants", "Assistants.Actions"))
					if wizard.assistantActionAvailable(assistant, action) {
						function := wizard.getAssistantActionFunction(assistant, action)

						if isObject(function) {
							index := inList(function, "")

							if (index && (index < function.Length))
								return false
						}
					}

		return true
	}

	saveActions() {
		if (this.iCurrentAssistant && this.SetupWizard.isModuleSelected(this.iCurrentAssistant))
			this.saveAssistantActions(this.iCurrentAssistant)
	}

	loadAssistantActions(assistant, load := false) {
		local window := this.Window
		local wizard := this.SetupWizard
		local function, ignore, action, subAction, count, pluginLabels, count, isInformationRequest, isBinary, label

		if load {
			this.iCachedActions := false

			this.clearActionFunctions()
		}

		this.clearActions()

		pluginLabels := getControllerActionLabels()

		this.ActionsListView.Delete()

		count := 1

		for ignore, action in this.getActions() {
			if wizard.assistantActionAvailable(assistant, action) {
				if load {
					function := wizard.getAssistantActionFunction(assistant, action)

					if (function && (function != ""))
						this.setActionFunction(false, action, (isObject(function) ? function : Array(function)))
				}

				subAction := ConfigurationItem.splitDescriptor(action)

				if (subAction[1] = "InformationRequest") {
					subAction := subAction[2]

					isInformationRequest := true
				}
				else {
					subAction := subAction[1]

					isInformationRequest := false
				}

				label := getMultiMapValue(pluginLabels, assistant, subAction . ".Toggle", kUndefined)

				if (label == kUndefined) {
					label := getMultiMapValue(pluginLabels, assistant, subAction . ".Activate", "")

					this.setAction(count, false, action, [isInformationRequest, "Activate"], label)

					isBinary := false
				}
				else {
					if (getMultiMapValue(pluginLabels, assistant, subAction . ".Increase", kUndefined) != kUndefined)
						this.setAction(count, false, action, [isInformationRequest, "Toggle", "Increase", "Decrease"], label)
					else
						this.setAction(count, false, action, [isInformationRequest, "Toggle", false, false], label)

					isBinary := true
				}

				function := this.getActionFunction(false, action)

				if function {
					if (function.Length == 1)
						function := (!isBinary ? function[1] : (translate("On/Off: ") . function[1]))
					else
						function := (translate("On: ") . function[1] . translate(" | Off: ") . function[2])
				}
				else
					function := ""

				this.ActionsListView.Add("", subAction, StrReplace(StrReplace(label, "`n", A_Space), "`r", ""), function)

				count += 1
			}
		}

		this.loadControllerLabels()

		this.ActionsListView.ModifyCol(1, "AutoHdr")
		this.ActionsListView.ModifyCol(2, "AutoHdr")
		this.ActionsListView.ModifyCol(3, "AutoHdr")
	}

	saveAssistantActions(assistant) {
		local wizard := this.SetupWizard
		local functions := CaseInsenseMap()
		local function, ignore, action

		for ignore, action in this.getActions()
			if wizard.assistantActionAvailable(assistant, action) {
				function := this.getActionFunction(false, action)

				if (function && (function != ""))
					functions[action] := function
			}

		wizard.setAssistantActionFunctions(assistant, functions)
		wizard.setModuleActionFunctions(assistant, false, functions)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeAssistantsStepWizard() {
	SetupWizard.Instance.registerStepWizard(AssistantsStepWizard(SetupWizard.Instance, "Assistants", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeAssistantsStepWizard()