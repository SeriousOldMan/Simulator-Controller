;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulators Step Wizard          ;;;
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
;;; SimulatorsStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SimulatorsStepWizard extends ActionsStepWizard {
	iSimulators := []
	iCurrentSimulator := false

	iSimulatorMFDKeys := CaseInsenseMap()
	iControllerWidgets := []

	iCachedActions := CaseInsenseMap()
	iCachedSimulator := false

	Pages {
		Get {
			local wizard := this.SetupWizard
			local ignore, simulator

			if (wizard.isModuleSelected("Controller") || wizard.isModuleSelected("Race Engineer") || wizard.isModuleSelected("Race Strategist"))
				for ignore, simulator in this.Definition
					if wizard.isApplicationSelected(simulator)
						return 1

			return 0
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local simulators := []
		local function, action, ignore, simulator, code, arguments, descriptor, key, value, mode, actions

		super.saveToConfiguration(configuration)

		for ignore, simulator in this.Definition {
			code := getApplicationDescriptor(simulator)[1]

			if wizard.isApplicationSelected(simulator) {
				simulators.Push(simulator)

				arguments := ""

				for ignore, descriptor in this.iSimulatorMFDKeys[simulator] {
					key := descriptor[3]
					value := wizard.getSimulatorValue(simulator, key, descriptor[4])

					if (arguments != "")
						arguments .= "; "

					arguments .= (key . ": " . value)
				}

				for ignore, mode in ["Pitstop", "Assistant"] {
					actions := ""

					for ignore, action in this.getActions(mode, simulator)
						if wizard.simulatorActionAvailable(simulator, mode, action) {
							function := wizard.getSimulatorActionFunction(simulator, mode, action)

							if !isObject(function)
								function := ((function && (function != "")) ? Array(function) : [])

							if (function.Length > 0) {
								if (actions != "")
									actions .= ", "

								actions .= (StrReplace(action, "InformationRequest.", "InformationRequest ") . A_Space . values2String(A_Space, function*))
							}
						}

					if (actions != "") {
						if (arguments != "")
							arguments .= "; "

						arguments .= (((mode = "Pitstop") ? "pitstopCommands: " : "assistantCommands: ") . actions)
					}
				}

				Plugin(code, false, true, simulator, arguments).saveToConfiguration(configuration)
			}
			else
				Plugin(code, false, false, simulator, "").saveToConfiguration(configuration)
		}

		setMultiMapValue(configuration, "Configuration", "Simulators", values2String("|", simulators*))
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local secondX := x + 80
		local secondWidth := 160
		local col1Width := (secondX - x) + secondWidth
		local labelHandle := false
		local editHandle := false
		local listX := x + 250
		local listWidth := width - 250
		local ignore, simulator, code, keys, keyY, key, default, label, info, html

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		simulatorActionFunctionSelect(listView, line, *) {
			this.actionFunctionSelect(line)
		}

		simulatorActionFunctionMenu(listView, line, *) {
			this.actionFunctionSelect(line)
		}

		chooseSimulator(*) {
			this.chooseSimulator()
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gaming Wheel.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Simulator Configuration"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w105 h23 +0x200 Hidden", translate("Simulator"))
		widget4 := window.Add("DropDownList", "x" . secondX . " yp w" . secondWidth . "  vsimulatorDropDown Hidden")
		widget4.OnEvent("Change", chooseSimulator)

		window.SetFont("Bold", "Arial")

		widget5 := window.Add("Text", "x" . x . " yp+30 w" . col1Width . " h23 +0x200 Hidden Section", translate("Pitstop MFD"))
		widget6 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		secondX := x + 150

		for ignore, simulator in this.Definition {
			code := getApplicationDescriptor(simulator)[1]
			keys := getMultiMapValue(wizard.Definition, "Setup.Simulators", "Simulators.MFDKeys." . code, false)

			if keys {
				this.iSimulatorMFDKeys[simulator] := []
				keyY := labelY + 90

				for ignore, key in string2Values("|", keys) {
					key := string2Values(":", key)
					default := key[2]
					key := key[1]

					label := getMultiMapValue(wizard.Definition, "Setup.Simulators", "Simulators.MFDKeys." . key . "." . getLanguage(), key)

					labelHandle := window.Add("Text", "x" . x . " y" . keyY . " w148 h23 +0x200 Hidden", label)
					editHandle := window.Add("Edit", "x" . secondX . " yp w60 h23 +0x200 Hidden", default)

					this.iSimulatorMFDKeys[simulator].Push(Array(labelHandle, editHandle, key, default))
					this.registerWidgets(1, labelHandle, editHandle)

					keyY += 24
				}
			}
		}

		listX := x + 250
		listWidth := width - 250

		window.SetFont("Bold", "Arial")

		widget7 := window.Add("Text", "x" . listX . " ys w" . listWidth . " h23 +0x200 Hidden", translate("Actions"))
		widget8 := window.Add("Text", "yp+20 x" . listX . " w" . listWidth . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget9 := window.Add("ListView", "x" . listX . " yp+10 w" . listWidth . " h300 W:Grow H:Grow(0.66) AltSubmit -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Mode", "Action", "Label", "Function"], translate))
		widget9.OnEvent("Click", simulatorActionFunctionSelect)
		widget9.OnEvent("DoubleClick", simulatorActionFunctionSelect)
		widget9.OnEvent("ContextMenu", simulatorActionFunctionMenu)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Simulators", "Simulators.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget10 := window.Add("ActiveX", "x" . x . " yp+305 w" . width . " h76 Y:Move(0.66) H:Grow(0.33) W:Grow VactionsInfoText Hidden", "shell.explorer")

		html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget10.Value.navigate("about:blank")
		widget10.Value.document.write(html)

		this.iControllerWidgets := [widget7, widget8, widget9]

		this.setActionsListView(widget9)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9, widget10)
	}

	reset() {
		super.reset()

		this.iSimulatorMFDKeys := CaseInsenseMap()
		this.iControllerWidgets := []
		this.iCachedActions := CaseInsenseMap()
		this.iCachedSimulator := false
	}

	updateState() {
		local wizard := this.SetupWizard
		local simulators := []
		local ignore, simulator

		super.updateState()

		for ignore, simulator in this.Definition
			if wizard.isApplicationSelected(simulator)
				simulators.Push(simulator)

		this.iSimulators := simulators
	}

	showPage(page) {
		local chosen := (this.iSimulators.Length > 0) ? 1 : 0
		local ignore, widget

		this.iCurrentSimulator := ((chosen > 0) ? this.iSimulators[chosen] : false)

		super.showPage(page)

		if !this.SetupWizard.isModuleSelected("Controller")
			for ignore, widget in this.iControllerWidgets
				widget.Visible := false

		this.loadSimulatorMFDKeys(this.iCurrentSimulator)

		this.Control["simulatorDropDown"].Delete()
		this.Control["simulatorDropDown"].Add(this.iSimulators)
		this.Control["simulatorDropDown"].Choose(chosen)
	}

	hidePage(page) {
		if super.hidePage(page) {
			this.saveSimulatorMFDKeys(this.iCurrentSimulator)

			return true
		}
		else
			return false
	}

	getModes() {
		return ["Pitstop", "Assistant"]
	}

	getActions(mode, simulator := false) {
		local wizard, code, actions

		if !simulator
			simulator := this.iCurrentSimulator

		if (simulator != this.iCachedSimulator) {
			this.iCachedActions := CaseInsenseMap()

			this.iCachedSimulator := simulator
		}

		if this.iCachedActions.Has(mode)
			return this.iCachedActions[mode]
		else {
			wizard := this.SetupWizard

			code := getApplicationDescriptor(simulator)[1]
			actions := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Simulators", (mode = "Assistant") ? "Simulators.Actions.Assistant" : ("Simulators.Settings.Pitstop." . code)))

			this.iCachedActions[mode] := actions

			return actions
		}
	}

	chooseSimulator() {
		local simulatorDropDown := this.Control["simulatorDropDown"].Text

		this.saveActions()

		this.saveSimulatorMFDKeys(this.iCurrentSimulator)

		this.iCurrentSimulator := simulatorDropDown

		this.loadSimulatorMFDKeys(simulatorDropDown)

		this.loadActions(true)
	}

	loadActions(load := false) {
		if (this.iCurrentSimulator && this.SetupWizard.isModuleSelected("Controller"))
			this.loadSimulatorActions(this.iCurrentSimulator, load)
	}

	saveActions() {
		if (this.iCurrentSimulator && this.SetupWizard.isModuleSelected("Controller"))
			this.saveSimulatorActions(this.iCurrentSimulator)
	}

	loadSimulatorActions(simulator, load := false) {
		local window := this.Window
		local wizard := this.SetupWizard
		local function, action, count, pluginLabels, count, ignore, mode, first, lastMode, code
		local subAction, isInformationRequest, label, isToggle, isBinary, isDial, onLabel, offLabel

		if load {
			this.iCachedActions := CaseInsenseMap()

			this.clearActionFunctions()
		}

		this.clearActions()

		pluginLabels := getControllerActionLabels()

		code := getApplicationDescriptor(simulator)[1]

		this.ActionsListView.Delete()

		lastMode := false
		count := 1

		for ignore, mode in ["Pitstop", "Assistant"]
			for ignore, action in this.getActions(mode, simulator) {
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					first := (mode != lastMode)
					lastMode := mode

					if load {
						function := wizard.getSimulatorActionFunction(simulator, mode, action)

						if (function && (function != ""))
							this.setActionFunction(mode, action, (isObject(function) ? function : Array(function)))
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

					label := getMultiMapValue(pluginLabels, code, subAction . ".Toggle", kUndefined)

					if (label == kUndefined) {
						isToggle := false

						label := getMultiMapValue(pluginLabels, code, subAction . ".Dial", kUndefined)

						if (label != kUndefined) {
							this.setAction(count, mode, action, [isInformationRequest, "Dial", "Increase", "Decrease"], label)

							isBinary := true
							isDial := true
						}
						else {
							label := getMultiMapValue(pluginLabels, code, subAction . ".Activate", "")

							this.setAction(count, mode, action, [isInformationRequest, "Activate"], label)

							isBinary := false
							isDial := false
						}
					}
					else {
						isToggle := true

						if (getMultiMapValue(pluginLabels, code, subAction . ".Increase", kUndefined) != kUndefined)
							this.setAction(count, mode, action, [isInformationRequest, "Toggle", "Increase", "Decrease"], label)
						else
							this.setAction(count, mode, action, [isInformationRequest, "Toggle", false, false], label)

						isBinary := true
						isDial := false
					}

					function := this.getActionFunction(mode, action)

					if function {
						if (function.Length == 1)
							function := (!isBinary ? function[1] : ((isDial ? translate("+/-: ") : translate("On/Off: ")) . function[1]))
						else {
							onLabel := getMultiMapValue(pluginLabels, code, subAction . ".Increase", false)
							offLabel := getMultiMapValue(pluginLabels, code, subAction . ".Decrease", false)

							if (onLabel && (function[1] != ""))
								this.setActionLabel(count, function[1], onLabel)

							if (offLabel && (function[2] != ""))
								this.setActionLabel(count, function[2], offLabel)

							function := ((isDial ? translate("+: ") : (isToggle ? translate("On/Off: ") : translate("On: "))) . function[1] . (isDial ? translate(" | -: ") : translate(" | Off: ")) . function[2])
						}
					}
					else
						function := ""

					this.ActionsListView.Add("", (first ? translate(mode) : ""), subAction, StrReplace(StrReplace(label, "`n", A_Space), "`r", ""), function)

					count += 1
				}
			}

		this.loadControllerLabels()

		this.ActionsListView.ModifyCol(1, "AutoHdr")
		this.ActionsListView.ModifyCol(2, "AutoHdr")
		this.ActionsListView.ModifyCol(3, "AutoHdr")
		this.ActionsListView.ModifyCol(4, "AutoHdr")
	}

	saveSimulatorActions(simulator) {
		local wizard := this.SetupWizard
		local code := getApplicationDescriptor(simulator)[1]
		local function, action, mode, modeFunctions, ignore

		for ignore, mode in ["Pitstop", "Assistant"] {
			modeFunctions := CaseInsenseMap()

			for ignore, action in this.getActions(mode, simulator)
				if wizard.simulatorActionAvailable(simulator, mode, action) {
					function := this.getActionFunction(mode, action)

					if (function && (function != ""))
						modeFunctions[action] := function
				}

			wizard.setSimulatorActionFunctions(simulator, mode, modeFunctions)
		}
	}

	loadSimulatorMFDKeys(simulator) {
		local wizard := this.SetupWizard
		local ignore, descriptors, descriptor, value, widget

		for ignore, descriptors in this.iSimulatorMFDKeys
			for ignore, descriptor in descriptors {
				descriptor[1].Visible := false
				descriptor[2].Visible := false
			}

		if (wizard.isModuleSelected("Controller") || wizard.isModuleSelected("Race Engineer"))
			for ignore, descriptor in this.iSimulatorMFDKeys[simulator] {
				value := wizard.getSimulatorValue(simulator, descriptor[3], descriptor[4])

				widget := descriptor[2]

				widget.Value := value
				widget.Visible := true
				widget.Enabled := true

				widget := descriptor[1]

				widget.Visible := true
				widget.Enabled := true
			}
	}

	saveSimulatorMFDKeys(simulator) {
		local wizard := this.SetupWizard
		local ignore, descriptor, value

		for ignore, descriptor in this.iSimulatorMFDKeys[simulator]
			wizard.setSimulatorValue(simulator, descriptor[3], descriptor[2].Text, false)
	}

	loadControllerLabels() {
		local wizard := this.SetupWizard
		local simulator := this.iCurrentSimulator
		local function, action, ignore, preview, targetMode, mode, partFunction, row, column

		super.loadControllerLabels()

		for ignore, preview in this.ControllerPreviews {
			targetMode := preview.Mode

			for ignore, mode in this.getModes()
				if ((targetMode == true) || (mode = targetMode))
					for ignore, action in this.getActions(mode, simulator)
						if wizard.simulatorActionAvailable(simulator, mode, action) {
							function := this.getActionFunction(mode, action)

							if (function && (function != "")) {
								if !isObject(function)
									function := Array(function)

								for ignore, partFunction in function
									if (partFunction && (partFunction != ""))
										if preview.findFunction(partFunction, &row, &column)
											preview.setLabel(row, column, this.getActionLabel(this.getActionRow(mode, action), partFunction))
							}
						}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorsStepWizard() {
	SetupWizard.Instance.registerStepWizard(SimulatorsStepWizard(SetupWizard.Instance, "Simulators", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeSimulatorsStepWizard()