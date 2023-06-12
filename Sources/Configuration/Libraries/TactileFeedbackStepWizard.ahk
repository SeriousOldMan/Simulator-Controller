;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Tactile Feedback Step Wizard    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ControllerStepWizard.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TactileFeedbackStepWizard                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TactileFeedbackStepWizard extends ActionsStepWizard {
	iPedalEffectsList := false
	iChassisEffectsList := false

	iCachedActions := CaseInsenseMap()

	Pages {
		Get {
			local wizard := this.SetupWizard

			if (wizard.isModuleSelected("Controller") && wizard.isModuleSelected("Tactile Feedback"))
				return 1
			else
				return 0
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local arguments := ""
		local function, action, parameters, ignore, mode, actions

		super.saveToConfiguration(configuration)

		if wizard.isModuleSelected("Tactile Feedback") {
			parameters := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Parameters", ""))

			for ignore, action in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Toggles", "")) {
				function := wizard.getModuleActionFunction("Tactile Feedback", false, action)

				if !isObject(function)
					function := ((function && (function != "")) ? Array(function) : [])

				if (function.Length > 0) {
					if (arguments != "")
						arguments .= "; "

					arguments .= (parameters[A_Index] . " On " . values2String(A_Space, function*))
				}
			}

			for ignore, mode in this.Definition {
				actions := ""

				for ignore, action in this.getActions(mode) {
					function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)

					if !isObject(function)
						function := ((function && (function != "")) ? Array(function) : [])

					if (function.Length > 0) {
						if (actions != "")
							actions .= ", "

						actions .= (action . A_Space . values2String(A_Space, function*))
					}
				}

				if (actions != "") {
					if (arguments != "")
						arguments .= "; "

					arguments .= (((mode = "Pedal Vibration") ? "pedalEffects: " : "chassisEffects: ") . actions)
				}
			}

			Plugin("Tactile Feedback", false, true, "", arguments).saveToConfiguration(configuration)
		}
		else
			Plugin("Tactile Feedback", false, false, "", "").saveToConfiguration(configuration)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local listX := x + 300
		local listWidth := width - 300
		local colWidth := width - listWidth - x
		local secondX := x + 155
		local buttonX := secondX - 26
		local secondWidth := colWidth - 155
		local info, html

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		changePedalEffects(*) {
			this.changeEffects("Pedal Vibration")
		}

		changeChassisEffects(*) {
			this.changeEffects("Chassis Vibration")
		}

		tactileFeedbackActionFunctionSelect(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		tactileFeedbackActionFunctionMenu(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Vibration 1.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Tactile Feedback Configuration"))

		window.SetFont("s8 Norm", "Arial")

		window.SetFont("Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w" . colWidth . " h23 +0x200 Hidden Section", translate("Setup "))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . colWidth . " 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget5 := window.Add("Text", "x" . x . " yp+10 w105 h23 +0x200 Hidden", translate("Pedal Effects"))

		widget6 := window.Add("Button", "x" . buttonX . " yp w23 h23  Hidden")
		widget6.OnEvent("Click", changePedalEffects)
		setButtonIcon(widget6, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		widget7 := window.Add("ListBox", "x" . secondX . " yp w" . secondWidth . " h60 ReadOnly Disabled Hidden")

		widget8 := window.Add("Text", "x" . x . " yp+65 w105 h23 +0x200 Hidden", translate("Chassis Effects"))

		widget9 := window.Add("Button", "x" . buttonX . " yp w23 h23  Hidden")
		widget9.OnEvent("Click", changeChassisEffects)
		setButtonIcon(widget9, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		widget10 := window.Add("ListBox", "x" . secondX . " yp w" . secondWidth . " h60 H:Grow(0.33) ReadOnly Disabled Hidden")

		widget11 := window.Add("Button", "x" . x . " yp+70 w" . colWidth . " h23 Y:Move(0.33) Hidden", translate("Edit Labels && Icons..."))
		widget11.OnEvent("Click", openLabelsAndIconsEditor)

		window.SetFont("s8 Bold", "Arial")

		widget12 := window.Add("Text", "x" . listX . " ys w" . listWidth . " h23 +0x200 Hidden Section", translate("Actions"))
		widget13 := window.Add("Text", "yp+20 x" . listX . " w" . listWidth . " W:Grow 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget14 := window.Add("ListView", "x" . listX . " yp+10 w" . listWidth . " h270 H:Grow(0.66) W:Grow AltSubmit -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Mode", "Action", "Label", "Function"], translate))
		widget14.OnEvent("Click", tactileFeedbackActionFunctionSelect)
		widget14.OnEvent("DoubleClick", tactileFeedbackActionFunctionSelect)
		widget14.OnEvent("ContextMenu", tactileFeedbackActionFunctionMenu)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget15 := window.Add("HTMLViewer", "x" . x . " yp+275 w" . width . " h135 Y:Move(0.66) W:Grow H:Grow(0.33) VtactileFeedbackInfoText Hidden")

		html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget15.document.write(html)

		this.setActionsListView(widget14)

		this.iPedalEffectsList := widget7
		this.iChassisEffectsList := widget10

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9, widget10
							  , widget11, widget12, widget13, widget14, widget15)
	}

	reset() {
		super.reset()

		this.iPedalEffectsList := CaseInsenseMap()
		this.iChassisEffectsList := CaseInsenseMap()
		this.iCachedActions := CaseInsenseMap()
	}

	hidePage(page) {
		local msgResult

		if !this.SetupWizard.isSoftwareInstalled("SimHub") {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("SimHub cannot be found. Do you really want to proceed?"), translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		return super.hidePage(page)
	}

	getModule() {
		return "Tactile Feedback"
	}

	getModes() {
		return Array(false, this.Definition*)
	}

	getActions(mode := false) {
		local wizard, actions

		if this.iCachedActions.Has(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard

			actions := wizard.moduleAvailableActions("Tactile Feedback", mode)

			if (actions.Length == 0) {
				if mode
					actions := concatenate(string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback." . mode . ".Effects", ""))
										 , string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback." . mode . ".Intensity", "")))
				else
					actions := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Tactile Feedback", "Tactile Feedback.Toggles", ""))

				wizard.setModuleAvailableActions("Tactile Feedback", mode, actions)
			}

			this.iCachedActions[mode] := actions

			return actions
		}
	}

	setAction(row, mode, action, actionDescriptor, label, argument := false) {
		local wizard := this.SetupWizard
		local function, functions, ignore

		super.setAction(row, mode, action, actionDescriptor, label, argument)

		if inList(this.getActions(false), action) {
			functions := this.getActionFunction(this.getActionMode(row), action)

			if functions
				for ignore, function in functions
					if (function && (function != ""))
						wizard.addModuleStaticFunction("Tactile Feedback", function, label)
		}
	}

	clearActionFunction(mode, action, function) {
		super.clearActionFunction(mode, action, function)

		if inList(this.getActions(false), action)
			this.SetupWizard.removeModuleStaticFunction("Tactile Feedback", function)
	}

	loadActions(load := false) {
		local wizard := this.SetupWizard
		local function, action, count, list, pluginLabels, lastMode, count, ignore, mode, first, lastMode
		local label, isBinary, onLabel, offLabel

		if load {
			this.iCachedActions := CaseInsenseMap()

			this.clearActionFunctions()

			this.iPedalEffectsList.Delete()
			this.iPedalEffectsList.Add(this.getActions("Pedal Vibration"))

			this.iChassisEffectsList.Delete()
			this.iChassisEffectsList.Add(this.getActions("Chassis Vibration"))
		}

		this.clearActions()

		pluginLabels := getControllerActionLabels()

		this.ActionsListView.Delete()

		lastMode := -1
		count := 1

		for ignore, mode in this.getModes() {
			for ignore, action in this.getActions(mode) {
				if wizard.moduleActionAvailable("Tactile Feedback", mode, action) {
					first := (mode != lastMode)
					lastMode := mode

					if load {
						function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)

						if (function && (function != ""))
							this.setActionFunction(mode, action, (isObject(function) ? function : Array(function)))
					}

					label := getMultiMapValue(pluginLabels, "Tactile Feedback", action . (mode ? ".Dial" : ".Toggle"), kUndefined)

					if (label == kUndefined) {
						label := getMultiMapValue(pluginLabels, "Tactile Feednack", action . ".Activate", kUndefined)

						if (label == kUndefined) {
							label := ""

							this.setAction(count, mode, action, [false, (mode ? "Dial" : "Toggle"), "Increase", "Decrease"], label)

							isBinary := true
						}
						else {
							this.setAction(count, mode, action, [false, "Activate"], label)

							isBinary := false
						}
					}
					else {
						if mode
							this.setAction(count, mode, action, [false, "Dial", "Increase", "Decrease"], label)
						else
							this.setAction(count, mode, action, [false, "Activate"], label)

						isBinary := true
					}

					function := this.getActionFunction(mode, action)

					if function {
						if (function.Length == 1)
							function := (!isBinary ? function[1] : ((mode ? translate("+/-: ") : translate("On/Off: ")) . function[1]))
						else {
							onLabel := getMultiMapValue(pluginLabels, "Tactile Feedback", action . ".Increase", false)
							offLabel := getMultiMapValue(pluginLabels, "Tactile Feedback", action . ".Decrease", false)

							if (onLabel && (function[1] != ""))
								this.setActionLabel(count, function[1], onLabel)

							if (offLabel && (function[2] != ""))
								this.setActionLabel(count, function[2], offLabel)

							function := ((mode ? translate("+: ") : translate("On: ")) . function[1] . (mode ? translate(" | -: ") : translate(" | Off: ")) . function[2])
						}
					}
					else
						function := ""

					this.ActionsListView.Add("", (first ? translate(mode ? mode : "Independent") : ""), action, StrReplace(StrReplace(label, "`n", A_Space), "`r", ""), function)

					count += 1
				}
			}
		}

		this.loadControllerLabels()

		this.ActionsListView.ModifyCol(1, "AutoHdr")
		this.ActionsListView.ModifyCol(2, "AutoHdr")
		this.ActionsListView.ModifyCol(3, "AutoHdr")
		this.ActionsListView.ModifyCol(4, "AutoHdr")
	}

	validateActions() {
		local wizard := this.SetupWizard
		local ignore, mode, action, function, index

		for ignore, mode in this.Definition
			for ignore, action in this.getActions(mode) {
				function := wizard.getModuleActionFunction("Tactile Feedback", mode, action)

				if isObject(function) {
					index := inList(function, "")

					if (index && (index < function.Length))
						return false
				}
			}

		return true
	}

	saveActions() {
		local wizard := this.SetupWizard
		local function, action, ignore, mode, modeFunctions

		for ignore, mode in this.getModes() {
			modeFunctions := CaseInsenseMap()

			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Tactile Feedback", mode, action) {
					function := this.getActionFunction(mode, action)

					if (function && (function != ""))
						modeFunctions[action] := function
				}

			wizard.setModuleActionFunctions("Tactile Feedback", mode, modeFunctions)
		}
	}

	changeEffects(mode) {
		local actions := values2String(", ", this.getActions(mode)*)
		local result := InputBox(translate("Please input effect names (seperated by comma):"), translate("Modular Simulator Controller System"), "w450 h150", actions)

		if (result.Result = "Ok") {
			this.saveActions()

			this.SetupWizard.setModuleAvailableActions("Tactile Feedback", mode, string2Values(",", result.Value))

			this.loadActions(true)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTactileFeedbackStepWizard() {
	SetupWizard.Instance.registerStepWizard(TactileFeedbackStepWizard(SetupWizard.Instance, "Tactile Feedback", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeTactileFeedbackStepWizard()