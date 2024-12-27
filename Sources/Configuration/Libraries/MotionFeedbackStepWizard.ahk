;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Motion Feedback Step Wizard     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ControllerStepWizard.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; MotionFeedbackStepWizard                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class MotionFeedbackStepWizard extends ActionsStepWizard {
	iMotionEffectsList := false

	iDisabledWidgets := []

	iCachedActions := CaseInsenseMap()

	Pages {
		Get {
			local wizard := this.SetupWizard

			if (wizard.isModuleSelected("Controller") && wizard.isModuleSelected("Motion Feedback") && !wizard.BasicSetup)
				return 1
			else
				return 0
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local function, action, connector, arguments, parameters, actionArguments, motionIntensity
		local effectSelector, effectIntensity, ignore, mode, actions

		super.saveToConfiguration(configuration)

		if wizard.isModuleSelected("Motion Feedback") {
			connector := wizard.softwarePath("StreamDeck Extension")

			arguments := ((connector && (connector != "")) ? ("connector: " . connector) : "")

			parameters := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Parameters", ""))

			function := wizard.getModuleActionFunction("Motion Feedback", false, "Motion")
			actionArguments := wizard.getModuleActionArgument("Motion Feedback", false, "Motion")
			motionIntensity := wizard.getModuleValue("Motion Feedback", "Motion Intensity")

			if (actionArguments && (actionArguments != "")) {
				actionArguments := string2Values("|", actionArguments)

				actionArguments[1] := (actionArguments[1] ? "On" : "Off")
			}
			else
				actionArguments := Array("On", 50)

			if !isObject(function)
				function := ((function && (function != "")) ? Array(function) : [])

			if (function.Length > 0) {
				if (arguments != "")
					arguments .= "; "

				if (motionIntensity != "")
					motionIntensity .= A_Space

				arguments .= ("motion: " . actionArguments[1] . A_Space . values2String(A_Space, function*) . A_Space . motionIntensity . actionArguments[2])
			}

			effectSelector := wizard.getModuleValue("Motion Feedback", "Effect Selector")
			effectIntensity := wizard.getModuleValue("Motion Feedback", "Effect Intensity")

			if ((effectSelector != "") && (effectIntensity != "")) {
				if (arguments != "")
					arguments .= "; "

				arguments .= ("motionEffectIntensity: " . effectSelector . A_Space . effectIntensity)
			}

			for ignore, mode in this.Definition {
				actions := ""

				for ignore, action in this.getActions(mode) {
					function := wizard.getModuleActionFunction("Motion Feedback", mode, action)
					actionArguments := wizard.getModuleActionArgument("Motion Feedback", mode, action)

					if (actionArguments && (actionArguments != "")) {
						actionArguments := string2Values("|", actionArguments)

						actionArguments[1] := (actionArguments[1] ? "On" : "Off")
					}
					else
						actionArguments := Array("On", 1.0)

					if !isObject(function)
						function := ((function && (function != "")) ? Array(function) : [])

					if (function.Length > 0) {
						if (actions != "")
							actions .= ", "

						actions .= ("`"" . action . "`" " . actionArguments[1] . A_Space . actionArguments[2] . A_Space . values2String(A_Space, function*))
					}
				}

				if (actions != "") {
					if (arguments != "")
						arguments .= "; "

					arguments .= ("motionEffects: " . actions)
				}
			}

			Plugin("Motion Feedback", false, true, "", arguments).saveToConfiguration(configuration, false)
		}
		else
			Plugin("Motion Feedback", false, false, "", "").saveToConfiguration(configuration, false)
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

		changeMotionEffects(*) {
			this.changeEffects("Motion")
		}

		motionFeedbackActionFunctionSelect(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		motionFeedbackActionFunctionMenu(listView, line, *) {
			if line
				this.actionFunctionSelect(line)
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", window.Theme.RecolorizeImage(kResourcesDirectory . "Setup\Images\Motion 1.ico"))
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Motion Feedback Configuration"))

		window.SetFont("s8 Norm", "Arial")

		window.SetFont("Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w" . colWidth . " h23 +0x200 Hidden Section", translate("Setup "))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . colWidth . " 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget5 := window.Add("Text", "x" . x . " yp+10 w125 h23 +0x200 Hidden", translate("Motion Effects"))

		widget6 := window.Add("Button", "x" . buttonX . " yp w23 h23  Hidden")
		widget6.OnEvent("Click", changeMotionEffects)
		setButtonIcon(widget6, kResourcesDirectory . "Setup\Images\Pencil.ico", 1, "L2 T2 R2 B2 H16 W16")
		widget7 := window.Add("ListBox", "x" . secondX . " yp w" . secondWidth . " h60 H:Grow(0.33) Disabled ReadOnly Hidden")

		widget8 := window.Add("Text", "x" . x . " yp+70 w150 h23 +0x200 Y:Move(0.33) Hidden", translate("Motion Intensity"))

		window.SetFont("s8 Bold", "Arial")

		widget9 := window.Add("Edit", "x" . secondX . " yp w" . secondWidth . " h23 Y:Move(0.33) +0x200 vmotionIntensityField Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget10 := window.Add("Text", "x" . x . " yp+24 w150 h23 Y:Move(0.33) +0x200 Hidden", translate("Effect Selector"))

		window.SetFont("s8 Bold", "Arial")

		widget11 := window.Add("Edit", "x" . secondX . " yp w" . secondWidth . " h23 Y:Move(0.33) +0x200 veffectSelectorField Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget12 := window.Add("Text", "x" . x . " yp+24 w150 h23 Y:Move(0.33) +0x200 Hidden", translate("Effect Intensity"))

		window.SetFont("s8 Bold", "Arial")

		widget13 := window.Add("Edit", "x" . secondX . " yp w" . secondWidth . " h23 Y:Move(0.33) +0x200 veffectIntensityField Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget14 := window.Add("Button", "x" . x . " yp+30 w" . colWidth . " h23 Y:Move(0.33) Hidden", translate("Edit Labels && Icons..."))
		widget14.OnEvent("Click", openLabelsAndIconsEditor)

		window.SetFont("s8 Bold", "Arial")

		widget15 := window.Add("Text", "x" . listX . " ys w" . listWidth . " h23 +0x200 Hidden Section", translate("Actions"))
		widget16 := window.Add("Text", "yp+20 x" . listX . " w" . listWidth . " W:Grow 0x10 Hidden")

		window.SetFont("s8 Norm", "Arial")

		widget17 := window.Add("ListView", "x" . listX . " yp+10 w" . listWidth . " h270 H:Grow(0.66) W:Grow AltSubmit -Multi -LV0x10 NoSort NoSortHdr  Hidden", collect(["Mode", "Action", "Label", "State", "Intensity", "Function"], translate))
		widget17.OnEvent("Click", motionFeedbackActionFunctionSelect)
		widget17.OnEvent("DoubleClick", motionFeedbackActionFunctionSelect)
		widget17.OnEvent("ContextMenu", motionFeedbackActionFunctionMenu)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Motion Feedback", "Motion Feedback.Actions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget18 := window.Add("HTMLViewer", "x" . x . " yp+275 w" . width . " h135 Y:Move(0.66) W:Grow H:Grow(0.33) VmotionFeedbackInfoText Hidden")

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, p, body { color: #" . window.Theme.TextColor . "}</style>" . info . "</body></html>"

		widget18.document.write(html)

		this.setActionsListView(widget17)

		this.iMotionEffectsList := widget7

		this.iDisabledWidgets := [widget9, widget11, widget13]

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget9, widget10
							  , widget11, widget12, widget13, widget14, widget15, widget16, widget17, widget18)
	}

	reset() {
		super.reset()

		this.iMotionEffectsList := false
		this.iDisabledWidgets := []
		this.iCachedActions := CaseInsenseMap()
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local ignore, widget, row, column, preview

		super.showPage(page)

		for ignore, widget in this.iDisabledWidgets
			widget.Enabled := false

		this.Control["motionIntensityField"].Text := wizard.getModuleValue("Motion Feedback", "Motion Intensity")
		this.Control["effectSelectorField"].Text := wizard.getModuleValue("Motion Feedback", "Effect Selector")
		this.Control["effectIntensityField"].Text := wizard.getModuleValue("Motion Feedback", "Effect Intensity")

		row := false
		column := false

		if (this.Control["motionIntensityField"].Text != "")
			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(this.Control["motionIntensityField"].Text, &row, &column) {
					preview.setLabel(row, column, translate("Motion Intensity"))

					break
				}

		if (this.Control["effectSelectorField"].Text != "")
			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(this.Control["effectSelectorField"].Text, &row, &column) {
					preview.setLabel(row, column, translate("Effect Selector"))

					break
				}

		if (this.Control["effectIntensityField"].Text != "")
			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(this.Control["effectIntensityField"].Text, &row, &column) {
					preview.setLabel(row, column, translate("Effect Intensity"))

					break
				}
	}

	hidePage(page) {
		local wizard := this.SetupWizard
		local function, action, msgResult, ignore, motionIntensityField, effectSelectorField, effectIntensityField

		if (!wizard.isSoftwareInstalled("SimFeedback") || !wizard.isSoftwareInstalled("StreamDeck Extension")) {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("SimFeedback cannot be found or the StreamDeck Extension was not installed. Do you really want to proceed?")
							  , translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		function := this.getActionFunction(false, "Motion")

		if !function {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("The function for the `"Motion`" action has not been set. You will not be able to activate or deactivate motion. Do you really want to proceed?"), translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		motionIntensityField := this.Control["motionIntensityField"].Text
		effectSelectorField := this.Control["effectSelectorField"].Text
		effectIntensityField := this.Control["effectIntensityField"].Text

		if (((effectSelectorField != "") && (effectIntensityField = "")) || ((effectSelectorField = "") && (effectIntensityField != ""))) {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("You must specify both `"Effect Selector`" and `"Effect Intensity`" functions, if you want to control effect intensities. Do you really want to proceed?"), translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		if super.hidePage(page) {
			wizard := this.SetupWizard

			if (motionIntensityField != "")
				wizard.setModuleValue("Motion Feedback", "Motion Intensity", motionIntensityField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Motion Intensity", false)

			if (effectSelectorField != "")
				wizard.setModuleValue("Motion Feedback", "Effect Selector", effectSelectorField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Effect Selector", false)

			if (effectIntensityField != "")
				wizard.setModuleValue("Motion Feedback", "Effect Intensity", effectIntensityField, false)
			else
				wizard.clearModuleValue("Motion Feedback", "Effect Intensity", false)

			return true
		}
		else
			return false
	}

	getModule() {
		return "Motion Feedback"
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

			actions := wizard.moduleAvailableActions("Motion Feedback", mode)

			if (actions.Length == 0) {
				if mode
					actions := string2Values(",", getMultiMapValue(wizard.Definition, "Setup.Motion Feedback", "Motion Feedback." . mode . ".Effects", ""))
				else
					actions := ["Motion"]

				wizard.setModuleAvailableActions("Motion Feedback", mode, actions)
			}

			this.iCachedActions[mode] := actions

			return actions
		}
	}

	setAction(row, mode, action, actionDescriptor, label, argument := false) {
		local wizard := this.SetupWizard
		local function, ignore, functions

		super.setAction(row, mode, action, actionDescriptor, label, argument)

		if inList(this.getActions(false), action) {
			functions := this.getActionFunction(this.getActionMode(row), action)

			if functions
				for ignore, function in functions
					if (function && (function != ""))
						wizard.addModuleStaticFunction("Motion Feedback", function, label)
		}
	}

	clearActionFunction(mode, action, function) {
		super.clearActionFunction(mode, action, function)

		if inList(this.getActions(false), action)
			this.SetupWizard.removeModuleStaticFunction("Motion Feedback", function)
	}

	loadControllerLabels() {
		local function, action, row, column, ignore, preview, mode, motionIntensityField, effectSelectorField, effectIntensityField

		super.loadControllerLabels()

		motionIntensityField := this.Control["motionIntensityField"].Text
		effectSelectorField := this.Control["effectSelectorField"].Text
		effectIntensityField := this.Control["effectIntensityField"].Text

		row := false
		column := false

		if (motionIntensityField != "")
			for ignore, preview in this.ControllerPreviews {
				mode := preview.Mode

				if (((mode == true) || (mode = "Motion")) && preview.findFunction(motionIntensityField, &row, &column)) {
					preview.setLabel(row, column, translate("Motion Intensity"))

					break
				}
			}

		if (effectSelectorField != "")
			for ignore, preview in this.ControllerPreviews {
				mode := preview.Mode

				if (((mode == true) || (mode = "Motion")) && preview.findFunction(effectSelectorField, &row, &column)) {
					preview.setLabel(row, column, translate("Effect Selector"))

					break
				}
			}

		if (effectIntensityField != "")
			for ignore, preview in this.ControllerPreviews {
				mode := preview.Mode

				if (((mode == true) || (mode = "Motion")) && preview.findFunction(effectIntensityField, &row, &column)) {
					preview.setLabel(row, column, translate("Effect Intensity"))

					break
				}
			}
	}

	loadActions(load := false) {
		local wizard := this.SetupWizard
		local function, action, count, list, pluginLabels, lastMode, count
		local ignore, mode, first, arguments, label, isBinary, state, intensity

		if load {
			this.iCachedActions := CaseInsenseMap()

			this.clearActionFunctions()
			this.clearActionArguments()

			this.iMotionEffectsList.Delete()
			this.iMotionEffectsList.Add(this.getActions("Motion"))
		}

		this.clearActions()

		pluginLabels := getControllerActionLabels()

		this.ActionsListView.Delete()

		lastMode := -1
		count := 1

		for ignore, mode in this.getModes() {
			for ignore, action in this.getActions(mode) {
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					first := (mode != lastMode)
					lastMode := mode

					if load {
						function := wizard.getModuleActionFunction("Motion Feedback", mode, action)

						if (function && (function != ""))
							this.setActionFunction(mode, action, (isObject(function) ? function : Array(function)))

						arguments := wizard.getModuleActionArgument("Motion Feedback", mode, action)

						if (arguments && (arguments != ""))
							this.setActionArgument(count, arguments)
					}

					label := getMultiMapValue(pluginLabels, "Motion Feedback", action . ".Toggle", kUndefined)

					if (label == kUndefined)
						label := getMultiMapValue(pluginLabels, "Motion Feedback", action . ".Activate", "")

					this.setAction(count, mode, action, [false, "Activate"], label)

					isBinary := false

					function := this.getActionFunction(mode, action)

					if function
						function := (mode ? function[1] : (translate("On/Off: ") . function[1]))
					else
						function := ""

					arguments := this.getActionArgument(count)

					if (arguments && (arguments != "")) {
						state := string2Values("|", arguments)
						intensity := ((state[2] != "") ? state[2] : (mode ? "1.0" : "50"))
						state := state[1]
					}
					else {
						state := true
						intensity := (mode ? "1.0" : "50")
					}

					this.ActionsListView.Add("", (first ? translate(mode ? mode : "Independent") : ""), action, StrReplace(StrReplace(label, "`n", A_Space), "`r", ""), translate(state ? "On" : "Off"), intensity, function)

					count += 1
				}
			}
		}

		this.loadControllerLabels()

		this.ActionsListView.ModifyCol(1, "AutoHdr")
		this.ActionsListView.ModifyCol(2, "AutoHdr")
		this.ActionsListView.ModifyCol(3, "AutoHdr")
		this.ActionsListView.ModifyCol(4, "AutoHdr")
		this.ActionsListView.ModifyCol(5, "AutoHdr")
		this.ActionsListView.ModifyCol(6, "AutoHdr")
	}

	validateActions() {
		local wizard := this.SetupWizard
		local ignore, mode, action, function, index

		for ignore, mode in this.Definition
			for ignore, action in this.getActions(mode) {
				function := wizard.getModuleActionFunction("Motion Feedback", mode, action)

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
		local function, action, ignore, mode, modeFunctions, modeArguments, arguments

		for ignore, mode in this.getModes() {
			modeFunctions := CaseInsenseMap()

			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					function := this.getActionFunction(mode, action)

					if (function && (function != ""))
						modeFunctions[action] := function
				}

			wizard.setModuleActionFunctions("Motion Feedback", mode, modeFunctions)

			modeArguments := CaseInsenseMap()

			for ignore, action in this.getActions(mode)
				if wizard.moduleActionAvailable("Motion Feedback", mode, action) {
					arguments := this.getActionArgument(mode, action)

					if (arguments && (arguments != ""))
						modeArguments[action] := arguments
				}

			wizard.setModuleActionArguments("Motion Feedback", mode, modeArguments)
		}
	}

	changeEffects(mode) {
		local actions := values2String(", ", this.getActions(mode)*)
		local result

		result := withBlockedWindows(InputBox, translate("Please input effect names (seperated by comma):"), translate("Modular Simulator Controller System"), "w450 h150", actions)

		if (result.Result = "Ok") {
			this.saveActions()

			this.SetupWizard.setModuleAvailableActions("Motion Feedback", mode, string2Values(",", result.Value))

			this.loadActions(true)
		}
	}

	setMotionIntensityDial(preview, function, control, row, column) {
		local motionIntensityField := this.Control["motionIntensityField"].Text
		local cRow, cColumn, ignore

		if (motionIntensityField != "") {
			cRow := false
			cColumn := false

			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(motionIntensityField, &cRow, &cColumn) {
					this.clearMotionIntensityDial(preview, motionIntensityField
												, ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(motionIntensityField)[2])
												, cRow, cColumn, false)

					break
				}
		}

		this.Control["motionIntensityField"].Text := function

		SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	clearMotionIntensityDial(preview, function, control, row, column, sound := true) {
		this.Control["motionIntensityField"].Value := ""

		if sound
			SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	setEffectSelector(preview, function, control, row, column) {
		local effectSelectorField := this.Control["effectSelectorField"].Text
		local cRow, cColumn, ignore

		if (effectSelectorField != "") {
			cRow := false
			cColumn := false

			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(effectSelectorField, &cRow, &cColumn) {
					this.clearEffectSelector(preview, effectSelectorField
										   , ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(effectSelectorField)[2])
										   , cRow, cColumn, false)

					break
				}
		}

		this.Control["effectSelectorField"].Text := function

		SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	clearEffectSelector(preview, function, control, row, column, sound := true) {
		this.Control["effectSelectorField"].Text := ""

		if sound
			SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	setEffectIntensityDial(preview, function, control, row, column) {
		local effectIntensityField := this.Control["effectIntensityField"].Text
		local cRow, cColumn, ignore

		if (effectIntensityField != "") {
			cRow := false
			cColumn := false

			for ignore, preview in this.ControllerPreviews
				if preview.findFunction(effectIntensityField, &cRow, &cColumn) {
					this.clearEffectIntensityDial(preview, effectIntensityField
												, ConfigurationItem.descriptor("Ignore", ConfigurationItem.splitDescriptor(effectIntensityField)[2])
												, cRow, cColumn, false)

					break
				}
		}

		this.Control["effectIntensityField"].Text := function

		SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	clearEffectIntensityDial(preview, function, control, row, column, sound := true) {
		this.Control["effectIntensityField"].Text := ""

		if sound
			SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadControllerLabels()
	}

	toggleState(row) {
		local action := this.getAction(row)
		local mode := this.getActionMode(row)
		local arguments := this.getActionArgument(row)

		if (arguments && (arguments != "")) {
			arguments := string2Values("|", arguments)
			arguments[1] := !arguments[1]
		}
		else
			arguments := Array(false, "")

		this.setActionArgument(row, values2String("|", arguments*))

		SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

		this.loadActions()
	}

	inputIntensity(row) {
		local action := this.getAction(row)
		local mode := this.getActionMode(row)
		local arguments := this.getActionArgument(row)
		local value, message, valid, result

		if (arguments && (arguments != "")) {
			arguments := string2Values("|", arguments)

			value := arguments[2]
		}
		else {
			arguments := Array(true, "")

			value := (mode ? "1.0" : "50")
		}

		result := withBlockedWindows(InputBox, translate(mode ? "Please input initial effect intensity (use dot as decimal point):" : "Please input initial motion intensity:"), translate("Modular Simulator Controller System"), "w300 h150", value)

		if (result.Result = "Ok") {
			value := result.Value
			valid := false

			if isNumber(value)
				if (!mode && (value >= 0) && (value <= 100)) {
					if isInteger(value)
						valid := true
				}
				else if (mode && (value >= 0.0) && (value <= 2.0)) {
					valid := true

					value := Round(value, 1)
				}

			if !valid {
				message := (mode ? "You must enter a valid number between 0.0 and 2.0..." : "You must enter a valid integer between 0 and 100...")

				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate(message), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				return
			}

			arguments[2] := value

			this.setActionArgument(row, values2String("|", arguments*))

			SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

			this.loadActions()
		}
	}

	createActionsMenu(title, row) {
		local contextMenu := super.createActionsMenu(title, row)

		contextMenu.Add(translate("Toggle Initial State"), (*) => this.toggleState(row))

		contextMenu.Add(translate("Set Initial Intensity..."), (*) => this.inputIntensity(row))

		return contextMenu
	}

	createControlMenu(title, preview, element, function, row, column) {
		local contextMenu := super.createControlMenu(title, preview, element, function, row, column)
		local functionType := ConfigurationItem.splitDescriptor(function)[1]
		local menuItem, motionIntensityField, effectSelectorField, effectIntensityField

		motionIntensityField := this.Control["motionIntensityField"].Text
		effectSelectorField := this.Control["effectSelectorField"].Text
		effectIntensityField := this.Control["effectIntensityField"].Text

		contextMenu.Add()

		menuItem := translate("Set Motion Intensity Dial")

		contextMenu.Add(menuItem, (*) => this.setMotionIntensityDial(preview, function, element[2], row, column))

		if ((functionType != k2WayToggleType) && (functionType != kDialType))
			contextMenu.Disable(menuItem)

		menuItem := translate("Clear Motion Intensity Dial")

		contextMenu.Add(menuItem, (*) => this.clearMotionIntensityDial(preview, function, element[2], row, column))

		if ((motionIntensityField = "") || (motionIntensityField != function))
			contextMenu.Disable(menuItem)

		contextMenu.Add()

		contextMenu.Add(translate("Set Effect Selector"), (*) => this.setEffectSelector(preview, function, element[2], row, column))

		menuItem := translate("Clear Effect Selector")

		contextMenu.Add(menuItem, (*) => this.clearEffectSelector(preview, function, element[2], row, column))

		if ((effectSelectorField = "") || (effectSelectorField != function))
			contextMenu.Disable(menuItem)

		contextMenu.Add()

		menuItem := translate("Set Effect Intensity Dial")

		contextMenu.Add(menuItem, (*) => this.setEffectIntensityDial(preview, function, element[2], row, column))

		if ((functionType != k2WayToggleType) && (functionType != kDialType))
			contextMenu.Disable(menuItem)

		menuItem := translate("Clear Effect Intensity Dial")

		contextMenu.Add(menuItem, (*) => this.clearEffectIntensityDial(preview, function, element[2], row, column))

		if ((effectIntensityField = "") || (effectIntensityField != function))
			contextMenu.Disable(menuItem)

		return contextMenu
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeMotionFeedbackStepWizard() {
	SetupWizard.Instance.registerStepWizard(MotionFeedbackStepWizard(SetupWizard.Instance, "Motion Feedback", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeMotionFeedbackStepWizard()