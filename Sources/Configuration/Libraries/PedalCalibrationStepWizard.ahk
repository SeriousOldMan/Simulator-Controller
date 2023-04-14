;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pedal Calibtazion Step Wizard   ;;;
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
;;; PedalCalibrationStepWizard                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PedalCalibrationStepWizard extends ActionsStepWizard {
	iCachedActions := false
	iPedalsCheck := CaseInsenseMap()

	Pages {
		Get {
			local wizard := this.SetupWizard

			if (wizard.isModuleSelected("Controller") && wizard.isModuleSelected("Pedal Calibration"))
				return 1
			else
				return 0
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local arguments := "controlApplication: Heusinkveld SmartControl"
		local calibrations := []
		local function, ignore, action

		super.saveToConfiguration(configuration)

		for ignore, action in this.getActions() {
			function := wizard.getModuleActionFunction("Pedal Calibration", "Pedal Calibration", action)

			if (function && (function != ""))
				calibrations.Push("`"" . action . "`" " . (isObject(function) ? function[1] : function))
		}

		if (calibrations.Length > 0) {
			if (arguments != "")
				arguments .= "; "

			arguments .= ("pedalCalibrations: " . values2String(", ", calibrations*))
		}

		Plugin("Pedal Calibration", false, wizard.isModuleSelected("Pedal Calibration"), "", arguments).saveToConfiguration(configuration)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local secondX := x + 80
		local secondWidth := 40
		local col1Width := (secondX - x) + secondWidth
		local listX := x + 150
		local listWidth := width - 150
		local pedalWidgets := []
		local allPedals, pedals, index, pedal, yOption, checked, info, html, widget

		updatePedals(*) {
			this.updatePedals()
		}

		pedalCalibrationActionFunctionSelect(listView, line, *) {
			this.actionFunctionSelect(line)
		}

		pedalCalibrationActionFunctionMenu(window, listView, line, *) {
			this.actionFunctionSelect(line)
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Brake.png")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Pedal Calibration Configuration"))

		window.SetFont("s8 Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w" . col1Width . " h23 +0x200 Hidden Section", translate("Pedals"))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		allPedals := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Pedals"))
		pedals := wizard.getModuleValue("Pedal Calibration", "Pedals", kUndefined)

		if (pedals == kUndefined)
			pedals := values2String("|", allPedals*)

		pedals := string2Values("|", pedals)

		for index, pedal in allPedals {
			if (index = 1)
				yOption := "yp+10"
			else
				yOption := "yp+24"

			checked := (inList(pedals, pedal) ? "Checked" : "")

			widget := window.Add("Text", "x" . x . " " . yOption . " w105 h23 +0x200 Hidden", translate(pedal))

			pedalWidgets.Push(widget)

			widget := window.Add("CheckBox", "x" . secondX . " yp w24 h23 +0x200 " . checked . " Hidden")
			widget.OnEvent("Click", updatePedals)

			pedalWidgets.Push(widget)

			this.iPedalsCheck[pedal] := widget
		}

		window.SetFont("Bold", "Arial")

		widget5 := window.Add("Text", "x" . listX . " ys w" . listWidth . " h23 +0x200 Hidden", translate("Actions"))
		widget6 := window.Add("Text", "yp+20 x" . listX . " w" . listWidth . " 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget7 := window.Add("ListView", "x" . listX . " yp+10 w" . listWidth . " h260 AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden", collect(["Mode", "Pedal", "Action", "Label", "Function"], translate))
		widget7.OnEvent("Click", pedalCalibrationActionFunctionSelect)
		widget7.OnEvent("DoubleClick", pedalCalibrationActionFunctionSelect)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		widget8 := window.Add("ActiveX", "x" . x . " yp+265 w" . width . " h80 VpedalCalibrationInfoText Hidden", "shell.explorer")

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget8.Value.navigate("about:blank")
		widget8.Value.document.write(html)

		this.setActionsListView(widget7)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, pedalWidgets*)
	}

	reset() {
		super.reset()

		this.iCachedActions := false
		this.iPedalsCheck := CaseInsenseMap()
	}

	hidePage(page) {
		local msgResult

		if !this.SetupWizard.isSoftwareInstalled("SmartControl") {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Heusinkveld SmartControl cannot be found. Do you really want to proceed?"), translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		return super.hidePage(page)
	}

	getModule() {
		return "Pedal Calibration"
	}

	getModes() {
		return ["Pedal Calibration"]
	}

	getActions() {
		local wizard, actions, pedals, ignore, pedal, curve

		if this.iCachedActions
			return this.iCachedActions
		else {
			wizard := this.SetupWizard

			actions := wizard.moduleAvailableActions("Pedal Calibration", "Pedal Calibration")

			if (actions.Length == 0) {
				actions := []

				pedals := wizard.getModuleValue("Pedal Calibration", "Pedals", kUndefined)

				if (pedals == kUndefined)
					pedals := values2String("|", string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Pedals"))*)

				for ignore, pedal in string2Values("|", pedals)
					for ignore, curve in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Curves"))
						actions.Push(pedal . "." . curve)

				wizard.setModuleAvailableActions("Pedal Calibration", "Pedal Calibration", actions)
			}

			this.iCachedActions := actions

			return actions
		}
	}

	loadActions(load := false) {
		local wizard := this.SetupWizard
		local function, action, count, lastPedal, ignore, subAction, label, pedal

		if load {
			this.iCachedActions := false

			this.clearActionFunctions()
		}

		this.clearActions()

		this.ActionsListView.Delete()

		count := 1
		lastPedal := false

		for ignore, action in this.getActions() {
			if wizard.moduleActionAvailable("Pedal Calibration", "Pedal Calibration", action) {
				if load {
					function := wizard.getModuleActionFunction("Pedal Calibration", "Pedal Calibration", action)

					if (function && (function != ""))
						this.setActionFunction("Pedal Calibration", action, (isObject(function) ? function : Array(function)))
				}

				subAction := ConfigurationItem.splitDescriptor(action)

				label := (translate(subAction[1]) . " " . subAction[2])

				this.setAction(count, "Pedal Calibration", action, [false, "Activate"], label)

				function := this.getActionFunction("Pedal Calibration", action)

				if (function && (function != ""))
					function := (isObject(function) ? function[1] : function)
				else
					function := ""

				action := ConfigurationItem.splitDescriptor(action)
				pedal := action[1]
				action := action[2]

				if (pedal != lastPedal) {
					lastPedal := pedal

					pedal := translate(pedal)
				}
				else
					pedal := ""

				this.ActionsListView.Add("", ((count = 1) ? translate("Pedal Calibration") : ""), pedal, action, StrReplace(label, "`n", A_Space), function)

				count += 1
			}
		}

		this.loadControllerLabels()

		this.ActionsListView.ModifyCol(1, "AutoHdr")
		this.ActionsListView.ModifyCol(2, "AutoHdr")
		this.ActionsListView.ModifyCol(3, "AutoHdr")
		this.ActionsListView.ModifyCol(4, "AutoHdr")
	}

	saveActions() {
		local wizard := this.SetupWizard
		local modeFunctions := CaseInsenseMap()
		local function, ignore, action

		for ignore, action in this.getActions() {
			if wizard.moduleActionAvailable("Pedal Calibration", "Pedal Calibration", action) {
				function := this.getActionFunction("Pedal Calibration", action)

				if (function && (function != ""))
					modeFunctions[action] := function
			}
		}

		wizard.setModuleActionFunctions("Pedal Calibration", "Pedal Calibration", modeFunctions)
	}

	updatePedals() {
		local wizard := this.SetupWizard
		local pedals := []
		local ignore, pedal

		this.saveActions()

		wizard.setModuleAvailableActions("Pedal Calibration", "Pedal Calibration", [])

		for ignore, pedal in string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Pedal Calibration", "Pedal Calibration.Pedals")) {
			if this.iPedalsCheck[pedal].Value
				pedals.Push(pedal)
		}

		wizard.setModuleValue("Pedal Calibration", "Pedals", values2String("|", pedals*), false)

		this.loadActions(true)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationStepWizard() {
	SetupWizard.Instance.registerStepWizard(PedalCalibrationStepWizard(SetupWizard.Instance, "Pedal Calibration", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationStepWizard()