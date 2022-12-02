;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Step Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include Libraries\ControllerEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerStepWizard                                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerStepWizard extends StepWizard {
	iControllerEditor := false

	iFunctionsListView := false

	iFunctionTriggers := false

	class StepControllerEditor extends ControllerEditor {
		configurationChanged(type, name) {
			local bbConfiguration := newConfiguration()
			local sdConfiguration := newConfiguration()
			local oldGui, controllerWizard

			base.configurationChanged(type, name)

			this.saveToConfiguration(bbConfiguration, sdConfiguration)

			writeConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini", bbConfiguration)
			writeConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", sdConfiguration)

			oldGui := A_DefaultGui

			try {
				controllerWizard := SetupWizard.Instance.StepWizards["Controller"]

				if controllerWizard.iFunctionTriggers {
					SetupWizard.Instance.StepWizards["Controller"].saveFunctions(bbConfiguration, sdConfiguration)

					SetupWizard.Instance.StepWizards["Controller"].loadFunctions(bbConfiguration, sdConfiguration)
				}
			}
			finally {
				Gui %oldGui%:Default
			}
		}
	}

	Pages[] {
		Get {
			return (this.SetupWizard.isModuleSelected("Controller") ? 1 : 0)
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local buttonBoxConfiguration, streamDeckConfiguration, streamDeckControllers, controller, definition
		local ignore, theFunction, controls, buttonBoxControllers, control, descriptor, functionTriggers

		base.saveToConfiguration(configuration)

		buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

		if wizard.isModuleSelected("Controller") {
			streamDeckControllers := []

			for controller, definition in getConfigurationSectionValues(streamDeckConfiguration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
					controller := controller[1]

					if !inList(streamDeckControllers, controller)
						streamDeckControllers.Push(controller)

					for ignore, theFunction in string2Values(";", definition)
						if (theFunction != "")
							Function.createFunction(theFunction, false, "", "", "", "").saveToConfiguration(configuration)
				}
			}

			controls := {}
			buttonBoxControllers := []

			for control, descriptor in getConfigurationSectionValues(buttonBoxConfiguration, "Controls")
				controls[control] := string2Values(";", descriptor)[1]

			for controller, definition in getConfigurationSectionValues(buttonBoxConfiguration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
					controller := controller[1]

					if !inList(buttonBoxControllers, controller)
						buttonBoxControllers.Push(controller)

					for ignore, control in string2Values(";", definition) {
						control := string2Values(",", control)[1]

						if (control != "") {
							control := ConfigurationItem.splitDescriptor(control)
							theFunction := ConfigurationItem.descriptor(controls[control[1]], control[2])

							functionTriggers := wizard.getControllerFunctionTriggers(theFunction)

							if (functionTriggers.Length() > 0)
								theFunction := Function.createFunction(theFunction, false, functionTriggers[1], "", functionTriggers[2], "")
							else
								theFunction := Function.createFunction(theFunction, false, "", "", "", "")

							theFunction.saveToConfiguration(configuration)
						}
					}
				}
			}

			if (buttonBoxControllers.Length() > 0) {
				loop % buttonBoxControllers.Length()
				{
					buttonBoxControllers[A_Index] := (buttonBoxControllers[A_Index] . ":" . buttonBoxControllers[A_Index])
				}

				setConfigurationValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", buttonBoxControllers*))
			}

			if (streamDeckControllers.Length() > 0) {
				loop % streamDeckControllers.Length()
				{
					streamDeckControllers[A_Index] := (streamDeckControllers[A_Index] . ":" . streamDeckControllers[A_Index])
				}

				setConfigurationValue(configuration, "Controller Layouts", "Stream Decks", values2String("|", streamDeckControllers*))
			}
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local functionsIconHandle := false
		local functionsIconLabelHandle := false
		local functionsListViewHandle := false
		local functionsInfoTextHandle := false
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local info, html

		static functionsInfoText

		Gui %window%:Default

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDfunctionsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDfunctionsLabelHandle Hidden, % translate("Controller Configuration")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Add, ListView, x%x% yp+30 w%width% h240 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDfunctionsListViewHandle gupdateFunctionTriggers Hidden, % values2String("|", map(["Controller", "Control", "Function", "Number", "Trigger(s)", "Hints & Conflicts"], "translate")*)

		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Controller", "Controller.Functions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200

		Gui %window%:Add, ActiveX, x%x% yp+245 w%width% h195 HWNDfunctionsInfoTextHandle VfunctionsInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		functionsInfoText.Navigate("about:blank")
		functionsInfoText.Document.Write(html)

		this.iFunctionsListView := functionsListViewHandle

		this.registerWidgets(1, functionsIconHandle, functionsLabelHandle, functionsListViewHandle, functionsInfoTextHandle)
	}

	reset() {
		base.reset()

		this.iFunctionsListView := false
		this.iFunctionTriggers := false

		if this.iControllerEditor {
			this.iControllerEditor.close(true)

			this.iControllerEditor := false
		}
	}

	saveFunctions(buttonBoxConfiguration := false, streamDeckConfiguration := false) {
		if this.iFunctionTriggers {
			if !buttonBoxConfiguration
				buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

			if !streamDeckConfiguration
				streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			this.SetupWizard.setControllerFunctions(this.controllerFunctions(buttonBoxConfiguration, streamDeckConfiguration))
		}
	}

	showPage(page) {
		base.showPage(page)

		this.iControllerEditor := new this.StepControllerEditor("Default", this.SetupWizard.Configuration
															  , kUserHomeDirectory . "Setup\Button Box Configuration.ini"
															  , kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", false)

		this.iControllerEditor.open(Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 225, A_ScreenWidth - 450), "Center")

		this.loadFunctions(readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
						 , readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini"), true)
	}

	hidePage(page) {
		local buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		local streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")
		local function, title, window, streamDeckFunctions, controller, definition, ignore

		if (this.conflictingFunctions(buttonBoxConfiguration) || this.conflictingTriggers(buttonBoxConfiguration)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("There are still duplicate functions or duplicate triggers - please correct...")
			OnMessage(0x44, "")

			return false
		}

		window := this.Window

		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView

		streamDeckFunctions := 0

		for controller, definition in getConfigurationSectionValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition)
					if (function != "")
						streamDeckFunctions += 1
		}

		if ((LV_GetCount() - streamDeckFunctions) != this.iFunctionTriggers.Count()) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Warning")
			MsgBox 262436, %title%, % translate("Not all functions have been assigned to physical controls. Do you really want to proceed?")
			OnMessage(0x44, "")

			IfMsgBox No
				return false
		}

		if base.hidePage(page) {
			this.iControllerEditor.close(true)

			this.iControllerEditor := false

			this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)

			this.iFunctionTriggers := false

			return true
		}
		else
			return false
	}

	controllerFunctions(buttonBoxConfiguration, streamDeckConfiguration) {
		local controls := {}
		local functions := {}
		local function, control, descriptor, controller, definition, ignore

		for control, descriptor in getConfigurationSectionValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]

		for controller, definition in getConfigurationSectionValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]
					function := ConfigurationItem.splitDescriptor(function)
					function := ConfigurationItem.descriptor(controls[function[1]], function[2])

					if (function != "")
						if this.iFunctionTriggers.HasKey(function)
							functions.Push(Array(function, this.iFunctionTriggers[function]*))
						else
							functions.Push(function)
				}
		}

		for controller, definition in getConfigurationSectionValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition)
					if (function != "")
						functions.Push(function)
		}

		return functions
	}

	conflictingFunctions(buttonBoxConfiguration) {
		local controls := {}
		local functions := {}
		local conflict := false
		local function, control, descriptor, controller, definition, ignore

		for control, descriptor in getConfigurationSectionValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]

		for controller, definition in getConfigurationSectionValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]

					if (function != "") {
						function := ConfigurationItem.splitDescriptor(function)
						function := ConfigurationItem.descriptor(controls[function[1]], function[2])

						if !functions.HasKey(function)
							functions[function] := [controller]
						else {
							functions[function].Push(controller)

							conflict := true
						}
					}
				}
			}
		}

		return (conflict ? functions : false)
	}

	conflictingTriggers(buttonBoxConfiguration) {
		local triggers := {}
		local conflict := false
		local function, functionTriggers, ignore, trigger

		for function, functionTriggers in this.iFunctionTriggers
			for ignore, trigger in functionTriggers
				if !triggers.HasKey(trigger)
					triggers[trigger] := [function]
				else {
					triggers[trigger].Push(function)

					conflict := true
				}

		return (conflict ? triggers : false)
	}

	loadFunctions(buttonBoxConfiguration, streamDeckConfiguration, load := false) {
		local wizard := this.SetupWizard
		local window := this.Window
		local controls := {}
		local lastController := false
		local function, ignore, control, descriptor, first, conflict, trigger, triggers
		local functionConflicts, triggerConflicts, controller, definition, functionTriggers

		for control, descriptor in getConfigurationSectionValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]

		Gui %window%:Default

		Gui ListView, % this.iFunctionsListView

		if (load || !this.iFunctionTriggers)
			this.iFunctionTriggers := {}

		LV_Delete()

		functionConflicts := this.conflictingFunctions(buttonBoxConfiguration)
		triggerConflicts := this.conflictingTriggers(buttonBoxConfiguration)

		for controller, definition in getConfigurationSectionValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, control in string2Values(";", definition) {
					control := string2Values(",", control)[1]

					if (control != "") {
						control := ConfigurationItem.splitDescriptor(control)
						function := ConfigurationItem.descriptor(controls[control[1]], control[2])

						first := (controller != lastController)
						lastController := controller

						if this.iFunctionTriggers.HasKey(function)
							functionTriggers := this.iFunctionTriggers[function]
						else
							functionTriggers := wizard.getControllerFunctionTriggers(function)

						conflict := 0

						if (functionConflicts && functionConflicts[function].Length() > 1)
							conflict += 1

						if triggerConflicts
							for ignore, trigger in functionTriggers
								if (triggerConflicts[trigger].Length() > 1) {
									conflict += 2

									break
								}

						if (conflict == 1)
							conflict := translate("Duplicate function...")
						else if (conflict == 2)
							conflict := translate("Duplicate trigger(s)...")
						else if (conflict == 3)
							conflict := translate("Duplicate function and duplicate trigger(s)...")
						else
							conflict := ""

						if (functionTriggers.Length() > 0) {
							triggers := values2String(" `; ", functionTriggers*)

							if load
								this.iFunctionTriggers[function] := functionTriggers
						}
						else
							triggers := ""

						LV_Add("", (first ? controller : ""), control[1], translate(controls[control[1]]), control[2], triggers, conflict)
					}
				}
			}
		}

		for controller, definition in getConfigurationSectionValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, function in string2Values(";", definition)
					if (function != "") {
						first := (controller != lastController)
						lastController := controller

						LV_Add("", (first ? controller : ""), translate("Key"), translate("Button"), ConfigurationItem.splitDescriptor(function)[2], translate("n/a"), "")
					}
			}
		}

		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr Integer Center")
		LV_ModifyCol(5, "AutoHdr")
		LV_ModifyCol(6, "AutoHdr")
	}

	updateFunctionTriggers(row) {
		local wizard := this.SetupWizard
		local window := this.Window
		local function, trigger, type, number, callback

		if triggerDetector("Active")
			wizard.toggleTriggerDetector()

		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView

		LV_GetText(trigger, row, 5)

		if (trigger != translate("n/a")) {
			LV_GetText(type, row, 3)
			LV_GetText(number, row, 4)

			switch type {
				case translate(k2WayToggleType):
					callback := ObjBindMethod(this, "registerHotkey", k2WayToggleType . "." . number, row, true)
				case translate(kDialType):
					callback := ObjBindMethod(this, "registerHotkey", kDialType . "." . number, row, true)
				case translate(k1WayToggleType):
					callback := ObjBindMethod(this, "registerHotkey", k1WayToggleType . "." . number, row, false)
				case translate(kButtonType):
					callback := ObjBindMethod(this, "registerHotkey", kButtonType . "." . number, row, false)
			}

			wizard.toggleTriggerDetector(callback)
		}
	}

	updateFunctionHotkeys(row) {
		local window := this.Window
		local function, trigger, type, number, double, title, prompt, locale
		local key1, key2, buttonBoxConfiguration, streamDeckConfiguration

		Gui %window%:Default

		Gui ListView, % this.iFunctionsListView

		LV_GetText(trigger, row, 5)

		if (trigger != translate("n/a")) {
			LV_GetText(type, row, 3)
			LV_GetText(number, row, 4)

			double := false

			switch type {
				case translate(k2WayToggleType):
					type := k2WayToggleType
					double := true
				case translate(kDialType):
					type := kDialType
					double := true
				case translate(k1WayToggleType):
					type := k1WayToggleType
				case translate(kButtonType):
					type := kButtonType
			}

			function := (type . "." . number)

			trigger := (this.iFunctionTriggers.HasKey(function) ? this.iFunctionTriggers[function] : false)

			title := translate("Modular Simulator Controller System")
			prompt := translate(double ? "Please enter the first Hotkey:" : "Please enter a Hotkey:")
			locale := ((getLanguage() = "en") ? "" : "Locale")

			key1 := ""
			key2 := ""

			if trigger {
				if (trigger.Length() > 0)
					key1 := trigger[1]

				if (trigger.Length() > 1)
					key2 := trigger[2]
			}

			InputBox key1, %title%, %prompt%, , 200, 150, , , %locale%, , %key1%

			if ErrorLevel
				return

			if double {
				prompt := translate("Please enter the second Hotkey:")

				InputBox key2, %title%, %prompt%, , 200, 150, , , %locale%, , %key2%

				if ErrorLevel
					return

				if ((key1 = "") && (key2 = ""))
					this.iFunctionTriggers.Delete(function)
				else
					this.iFunctionTriggers[function] := [key1, key2]
			}
			else
				this.iFunctionTriggers[function] := [key1]

			buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
			streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)
			this.loadFunctions(buttonBoxConfiguration, streamDeckConfiguration)

			window := this.Window

			Gui %window%:Default
			Gui ListView, % this.iFunctionsListView

			LV_Modify(row, "Vis")
		}
	}

	clearFunctionTriggerAndHotkey(row) {
		local window := this.Window
		local function, trigger, double, type, number

		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView

		LV_GetText(trigger, row, 5)

		if (trigger != translate("n/a")) {
			LV_GetText(type, row, 3)
			LV_GetText(number, row, 4)

			double := false

			switch type {
				case translate(k2WayToggleType):
					type := k2WayToggleType
					double := true
				case translate(kDialType):
					type := kDialType
					double := true
				case translate(k1WayToggleType):
					type := k1WayToggleType
				case translate(kButtonType):
					type := kButtonType
			}

			function := (type . "." . number)

			this.iFunctionTriggers.Delete(function)

			LV_Modify(row, "Col5", "")

			this.saveFunctions()
		}
	}

	registerHotKey(function, row, firstHotkey, hotkey) {
		local wizard := this.SetupWizard
		local controller, number, callback, buttonBoxConfiguration, streamDeckConfiguration, window

		SoundPlay %kResourcesDirectory%Sounds\Activated.wav

		if (firstHotkey == true) {
			callback := ObjBindMethod(this, "registerHotkey", function, row, hotkey)

			wizard.toggleTriggerDetector()

			Sleep 2000

			wizard.toggleTriggerDetector(callback)

			return
		}
		else if (firstHotkey != false) {
			this.iFunctionTriggers[function] := [firstHotkey, hotkey]

			hotkey := firstHotkey . " | " . hotkey
		}
		else
			this.iFunctionTriggers[function] := [hotkey]

		wizard.toggleTriggerDetector()

		buttonBoxConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		streamDeckConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

		this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)
		this.loadFunctions(buttonBoxConfiguration, streamDeckConfiguration)

		window := this.Window

		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView

		LV_Modify(row, "Vis")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerPreviewStepWizard                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerPreviewStepWizard extends StepWizard {
	static sControllerPreviewCenters := {}

	iControllerPreviews := []
	iControllerPreviewCenterY := 0

	ControllerPreviews[] {
		Get {
			return this.iControllerPreviews
		}
	}

	reset() {
		base.reset()

		this.closeControllerPreviews()
	}

	showPage(page) {
		base.showPage(page)

		if this.SetupWizard.isModuleSelected("Controller")
			this.openControllerPreviews()
	}

	hidePage(page) {
		if base.hidePage(page) {
			if this.SetupWizard.isModuleSelected("Controller")
				this.closeControllerPreviews()

			return true
		}
		else
			return false
	}

	setPreviewCenter(descriptor, centerX, centerY) {
		if descriptor
			ControllerPreviewStepWizard.sControllerPreviewCenters[descriptor] := [centerX, centerY]
	}

	getPreviewCenter(descriptor, ByRef centerX, ByRef centerY) {
		local center

		if (descriptor && ControllerPreviewStepWizard.sControllerPreviewCenters.HasKey(descriptor)) {
			center := ControllerPreviewStepWizard.sControllerPreviewCenters[descriptor]

			centerX := center[1]
			centerY := center[2]
		}
		else {
			centerX := false
			centerY := this.iControllerPreviewCenterY
		}
	}

	getPreviewMover() {
		return "moveControllerPreview"
	}

	createControllerPreview(type, controller, configuration) {
		if (type = "Button Box")
			return new ButtonBoxPreview(this, controller, configuration)
		else
			return new StreamDeckPreview(this, controller, configuration)
	}

	openControllerPreviews() {
		local function, index, controller, staticFunctions, controllers, found, configuration, definition
		local preview, mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

		if this.SetupWizard.isModuleSelected("Controller") {
			staticFunctions := this.SetupWizard.getModuleStaticFunctions()
			controllers := []
			found := []

			configuration := readConfiguration(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

			for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if !inList(found, controller[1]) {
					found.Push(controller[1])
					controllers.Push(Array("Button Box", controller[1], configuration))
				}
			}

			configuration := readConfiguration(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if !inList(found, controller[1]) {
					found.Push(controller[1])
					controllers.Push(Array("Stream Deck", controller[1], configuration))
				}
			}

			for index, controller in controllers {
				preview := this.createControllerPreview(controller[1], controller[2], controller[3])

				preview.setControlClickHandler(ObjBindMethod(this, "controlClick"))

				if (index = 1) {
					SysGet mainScreen, MonitorWorkArea

					this.iControllerPreviewCenterY := (mainScreenBottom - Round(preview.Height / 2))
				}
				else
					this.iControllerPreviewCenterY -= Round(preview.Height / 2)

				preview.open()

				this.iControllerPreviewCenterY -= Round(preview.Height / 2)
				this.ControllerPreviews.Push(preview)
			}

			this.loadControllerLabels()
		}
		else
			this.iControllerPreviews := []
	}

	closeControllerPreviews() {
		local ignore, preview

		for ignore, preview in this.ControllerPreviews
			preview.close()

		this.iControllerPreviews := []
		this.iControllerPreviewCenterY := 0
	}

	loadControllerLabels() {
		local row := false
		local column := false
		local function, ignore, preview

		for ignore, preview in this.ControllerPreviews {
			preview.resetLabels()

			for ignore, function in this.SetupWizard.getModuleStaticFunctions()
				if preview.findFunction(function[1], row, column)
					preview.setLabel(row, column, function[2])
		}
	}

	controlClick(preview, element, function, row, column, isEmpty) {
		throw "Virtual method ControllerPreviewStepWizard.controlClick must be implemented by a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ActionsStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ActionsStepWizard extends ControllerPreviewStepWizard {
	static sCurrentActionsStep := false

	iPendingFunctionRegistration := false
	iPendingActionRegistration := false

	iActionsListView := false

	iModes := {}
	iActions := {}
	iDescriptors := {}
	iLabels := {}
	iFunctions := {}
	iArguments := {}

	class ActionsButtonBoxPreview extends ButtonBoxPreview {
		iModeDropDownHandle := false

		iModes := []

		Mode[] {
			Get {
				local mode, ignore, candidate

				GuiControlGet mode, , % this.iModeDropDownHandle

				if (mode == translate("All Modes"))
					return true
				else if (mode == translate("Independent"))
					return false
				else
					for ignore, candidate in this.iModes
						if (mode = translate(candidate))
							return candidate

				return true
			}
		}

		__New(previewManager, name, configuration, modes) {
			this.iModes := modes

			base.__New(previewManager, name, configuration)
		}

		createGui(configuration) {
			local window := this.Window
			local modeDropDownHandle := false
			local modes := []
			local ignore, mode

			base.createGui(configuration)

			for ignore, mode in this.iModes
				if mode
					modes.Push(translate(mode))
				else
					modes.Push(translate("Independent"))

			modes.InsertAt(1, translate("All Modes"))

			Gui %window%:Font, s8 Norm Arial

			Gui %window%:Add, DropDownList, x8 y8 w82 Choose1 HWNDmodeDropDownHandle gupdateControllerLabels, % values2String("|", modes*)

			this.iModeDropDownHandle := modeDropDownHandle
		}
	}

	class ActionsStreamDeckPreview extends StreamDeckPreview {
		iModeDropDownHandle := false

		iModes := []

		Mode[] {
			Get {
				local mode, ignore, candidate

				GuiControlGet mode, , % this.iModeDropDownHandle

				if (mode == translate("All Modes"))
					return true
				else if (mode == translate("Independent"))
					return false
				else
					for ignore, candidate in this.iModes
						if (mode = translate(candidate))
							return candidate

				return true
			}
		}

		__New(previewManager, name, configuration, modes) {
			this.iModes := modes

			base.__New(previewManager, name, configuration)
		}

		createGui(configuration) {
			local window := this.Window
			local modeDropDownHandle := false
			local modes := []
			local ignore, mode

			base.createGui(configuration)

			for ignore, mode in this.iModes
				if mode
					modes.Push(translate(mode))
				else
					modes.Push(translate("Independent"))

			modes.InsertAt(1, translate("All Modes"))

			Gui %window%:Font, s8 Norm Arial

			Gui %window%:Add, DropDownList, x8 y8 w82 Choose1 HWNDmodeDropDownHandle gupdateControllerLabels, % values2String("|", modes*)

			this.iModeDropDownHandle := modeDropDownHandle
		}
	}

	ActionsListView[] {
		Get {
			return this.iActionsListView
		}
	}

	CurrentActionsStep[] {
		Get {
			return ActionsStepWizard.sCurrentActionsStep
		}
	}

	reset() {
		base.reset()

		this.iActionsListView := false

		this.clearActions()
		this.clearActionFunctions()
		this.clearActionArguments()
	}

	showPage(page) {
		ActionsStepWizard.sCurrentActionsStep := this

		base.showPage(page)

		if this.SetupWizard.isModuleSelected("Controller")
			this.loadActions(true)
		else
			GuiControl Hide, % this.ActionsListView
	}

	hidePage(page) {
		if base.hidePage(page) {
			ActionsStepWizard.sCurrentActionsStep := false

			if this.SetupWizard.isModuleSelected("Controller")
				this.saveActions()

			this.iPendingFunctionRegistration := false
			this.iPendingActionRegistration := false

			return true
		}
		else
			return false
	}

	loadActions(load := false) {
		throw "Virtual method ActionsStepWizard.loadActions must be implemented in a subclass..."
	}

	saveActions() {
		throw "Virtual method ActionsStepWizard.saveActions must be implemented in a subclass..."
	}

	setActionsListView(actionsListView) {
		this.iActionsListView := actionsListView
	}

	getModule() {
		return false
	}

	getModes() {
		throw "Virtual method ActionsStepWizard.getModes must be implemented in a subclass..."
	}

	getActions(mode) {
		throw "Virtual method ActionsStepWizard.getActions must be implemented in a subclass..."
	}

	setAction(row, mode, action, actionDescriptor, label, argument := false) {
		this.iModes[row] := mode
		this.iModes[mode . "." . action] := row
		this.iActions[row] := action
		this.iDescriptors[row] := actionDescriptor
		this.iLabels[row] := label

		if argument
			this.iArguments[row] := argument
	}

	getAction(row) {
		return this.iActions[row]
	}

	getActionRow(mode, action) {
		return this.iModes[mode . "." . action]
	}

	getActionMode(row) {
		return this.iModes[row]
	}

	getActionDescriptor(row) {
		return this.iDescriptors[row]
	}

	setActionLabel(row, function, label) {
		this.iLabels[row . "." . function] := label
	}

	getActionLabel(row, function := false) {
		local key

		if function {
			key := (row . "." . function)

			return this.iLabels[this.iLabels.HasKey(key) ? key : row]
		}
		else
			return this.iLabels[row]
	}

	clearActions() {
		this.iModes := {}
		this.iActions := {}
		this.iDescriptors := {}
		this.iLabels := {}
	}

	setActionFunction(mode, action, functionDescriptor) {
		local oldFunction := this.getActionFunction(mode, action)
		local changed, ignore, oldValue

		if (oldFunction && (oldFunction != "")) {
			changed := []

			if (IsObject(oldfunction) && IsObject(functionDescriptor)) {
				loop % oldFunction.Length()
					if (oldFunction[A_Index] != functionDescriptor[A_Index])
						changed.Push(oldFunction[A_Index])
			}
			else if (oldFunction != functionDescriptor)
				changed.Push(oldFunction)

			for ignore, oldValue in changed
				if (oldValue != "")
					this.clearActionFunction(mode, action, oldValue)
		}

		if !this.iFunctions.HasKey(mode)
			this.iFunctions[mode] := {}

		this.iFunctions[mode][action] := functionDescriptor

		this.saveFunctions()
	}

	getActionFunction(mode, action) {
		local functions

		if this.iFunctions.HasKey(mode) {
			functions := this.iFunctions[mode]

			return (functions.HasKey(action) ? functions[action] : false)
		}
		else
			return false
	}

	clearActionFunction(mode, action, function) {
		local functions, actionFunctions, index, candidate

		if this.iFunctions.HasKey(mode) {
			functions := this.iFunctions[mode]

			if functions.HasKey(action) {
				actionFunctions := functions[action]

				for index, candidate in actionFunctions
					if (candidate = function)
						actionFunctions[index] := ""

				if (actionFunctions.Length() == 1)
					functions.Delete(action)
				else if ((actionFunctions[1] = "") && (actionFunctions[2] = ""))
					functions.Delete(action)
			}
		}
	}

	clearActionFunctions() {
		this.iFunctions := {}
	}

	setActionArgument(row, argument) {
		this.iArguments[row] := argument
	}

	getActionArgument(rowOrMode, action := false) {
		if action
			rowOrMode := this.getActionRow(rowOrMode, action)

		return (this.iArguments.HasKey(rowOrMode) ? this.iArguments[rowOrMode] : false)
	}

	clearActionArguments() {
		this.iArguments := {}
	}

	createControllerPreview(type, controller, configuration) {
		if (type = "Button Box")
			return new this.ActionsButtonBoxPreview(this, controller, configuration, this.getModes())
		else
			return new this.ActionsStreamDeckPreview(this, controller, configuration, this.getModes())
	}

	openControllerPreviews() {
		base.openControllerPreviews()

		this.iPendingFunctionRegistration := false
		this.iPendingActionRegistration := false
	}

	loadControllerLabels() {
		local wizard := this.SetupWizard
		local function, action, module, row, column, ignore, preview, targetMode, mode, partFunction

		base.loadControllerLabels()

		module := this.getModule()

		if module {
			row := false
			column := false

			for ignore, preview in this.ControllerPreviews {
				targetMode := preview.Mode

				for ignore, mode in this.getModes()
					if ((targetMode == true) || (mode = targetMode))
						for ignore, action in this.getActions(mode)
							if wizard.moduleActionAvailable(module, mode, action) {
								function := this.getActionFunction(mode, action)

								if (function && (function != "")) {
									if !IsObject(function)
										function := Array(function)

									for ignore, partFunction in function
										if (partFunction && (partFunction != ""))
											if preview.findFunction(partFunction, row, column)
												preview.setLabel(row, column, this.getActionLabel(this.getActionRow(mode, action), partFunction))
								}
							}
			}
		}
	}

	setFunction(row) {
		local arguments

		if this.iPendingActionRegistration {
			arguments := this.iPendingActionRegistration

			this.iPendingActionRegistration := false
			this.iPendingFunctionRegistration := row

			SetTimer showSelectorHint, Off

			ToolTip, , , 1

			this.controlClick(arguments*)
		}
		else {
			this.iPendingFunctionRegistration := row

			SetTimer showSelectorHint, 100
		}
	}

	clearFunction(row) {
		local action := this.getAction(row)
		local mode := this.getActionMode(row)
		local function := this.getActionFunction(mode, action)
		local ignore

		if (function && (function != "")) {
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav

			if IsObject(function) {
				for ignore, function in function
					this.clearActionFunction(mode, action, function)
			}
			else
				this.clearActionFunction(mode, action, function)

			this.loadActions()
		}
	}

	setFunctionAction(arguments) {
		this.iPendingActionRegistration := arguments

		SetTimer showSelectorHint, 100
	}

	clearFunctionAction(preview, function, control, row, column) {
		local changed := false
		local found := true
		local action, mode, modeFunctions, action, functions, ignore, candidate

		while found {
			found := false

			for mode, modeFunctions in this.iFunctions
				for action, functions in modeFunctions
					for ignore, candidate in functions
						if (candidate = function) {
							SoundPlay %kResourcesDirectory%Sounds\Activated.wav

							this.clearActionFunction(mode, action, function)

							found := true
							changed := true
						}
		}

		if changed
			this.loadActions()
	}

	createActionsMenu(title, row) {
		local window := this.Window
		local function, menuItem, handler, count

		Gui %window%:Default

		try {
			Menu ContextMenu, DeleteAll
		}
		catch exception {
			logError(exception)
		}

		Menu ContextMenu, Add, %title%, controlMenuIgnore
		Menu ContextMenu, Disable, %title%
		Menu ContextMenu, Add

		menuItem := translate("Set Function")
		handler := ObjBindMethod(this, "setFunction", row)

		Menu ContextMenu, Add, %menuItem%, %handler%

		function := this.getActionFunction(this.getActionMode(row), this.getAction(row))
		count := 0

		if IsObject(function) {
			if ((function.Length() > 1) && (function[1] != "") && (function[2] != ""))
				count := 2
			else if (function[1] != "")
				count := 1
		}
		else if (function != "")
			count := 1

		menuItem := translate((count > 1) ? "Clear Function(s)" : "Clear Function")
		handler := ObjBindMethod(this, "clearFunction", row)

		Menu ContextMenu, Add, %menuItem%, %handler%

		function := this.getActionFunction(this.getActionMode(row), this.getAction(row))

		if (count == 0)
			Menu ContextMenu, Disable, %menuItem%

		return "ContextMenu"
	}

	createControlMenu(title, preview, element, function, row, column) {
		local window := this.Window
		local action, menuItem, handler, count, mode, modeFunctions, action, functions, ignore, candidate

		Gui %window%:Default

		try {
			Menu ContextMenu, DeleteAll
		}
		catch exception {
			logError(exception)
		}

		Menu ContextMenu, Add, %title%, controlMenuIgnore
		Menu ContextMenu, Disable, %title%
		Menu ContextMenu, Add

		menuItem := translate("Set Action")
		handler := ObjBindMethod(this, "setFunctionAction", Array(preview, element, function, row, column, false, true))

		Menu ContextMenu, Add, %menuItem%, %handler%

		count := 0

		for mode, modeFunctions in this.iFunctions
			for action, functions in modeFunctions
				for ignore, candidate in functions
					if (candidate = function)
						count += 1

		menuItem := translate((count > 1) ? "Clear Action(s)" : "Clear Action")
		handler := ObjBindMethod(this, "clearFunctionAction", preview, function, element[2], row, column)

		Menu ContextMenu, Add, %menuItem%, %handler%

		if (count = 0)
			Menu ContextMenu, Disable, %menuItem%

		return "ContextMenu"
	}

	setControlFunction(row, function) {
		local mode := this.getActionMode(row)
		local action := this.getAction(row)
		local actionDescriptor := this.getActionDescriptor(row)
		local functionType := ConfigurationItem.splitDescriptor(function)[1]
		local action, title, currentFunction

		if (((functionType == k2WayToggleType) || (functionType == kDialType)) && ((actionDescriptor[2] == "Toggle") || (actionDescriptor[2] == "Dial")))
			function := [function]
		else if (((functionType == k1WayToggleType) || (functionType == kButtonType)) && (actionDescriptor[2] == "Toggle") && !actionDescriptor[3])
			function := [function]
		else if (actionDescriptor[2] == "Activate")
			function := [function]
		else {
			if (actionDescriptor[2] == "Toggle")
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["On/Off", "Off", "Cancel"]))
			else
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Increase", "Decrease", "Cancel"]))

			title := translate("Trigger")

			MsgBox 262179, %title%, % translate("Trigger for ") . action . translate("?")
			OnMessage(0x44, "")

			currentFunction := this.getActionFunction(mode, action)

			if currentFunction
				currentFunction := currentFunction.Clone()

			IfMsgBox Cancel
				function := false

			IfMsgBox Yes
			{
				if currentFunction {
					if (currentFunction.Length() == 1)
						function := [function, ""]
					else {
						currentFunction[1] := function

						function := currentFunction
					}
				}
				else
					function := [function, ""]
			}

			IfMsgBox No
			{
				if currentFunction {
					if (currentFunction.Length() == 1)
						function := ["", function]
					else {
						currentFunction[2] := function

						function := currentFunction
					}
				}
				else
					function := ["", function]
			}
		}

		return function
	}

	controlClick(preview, element, function, row, column, isEmpty, actionRegistration := false) {
		local action, title, controlMenu, actionRow, mode, window

		if ((element[1] = "Control") && !isEmpty) {
			if this.iPendingActionRegistration
				return

			if (!this.iPendingFunctionRegistration && !actionRegistration) {
				title := (translate(element[1]) . translate(": ") . StrReplace(element[2], "`n", A_Space) . " (" . row . " x " . column . ")")

				controlMenu := this.createControlMenu(title, preview, element, function, row, column)

				Menu %controlMenu%, Show
			}
			else {
				SoundPlay %kResourcesDirectory%Sounds\Activated.wav

				SetTimer showSelectorHint, Off

				ToolTip, , , 1

				actionRow := this.iPendingFunctionRegistration

				mode := this.getActionMode(actionRow)
				action := this.getAction(actionRow)
				function := this.setControlFunction(actionRow, function)

				if function {
					this.setActionFunction(mode, action, function)

					this.loadActions()

					window := this.Window

					Gui %window%:Default
					Gui ListView, % this.ActionsListView

					LV_Modify(actionRow, "Vis")
				}

				this.iPendingFunctionRegistration := false
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

updateActionFunction(wizard) {
	local action, row, label, contextMenu

	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")

	if wizard.SetupWizard.isModuleSelected("Controller") {
		if ((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) {
			if (A_EventInfo > 0) {
				row := A_EventInfo

				if wizard.iPendingActionRegistration
					wizard.setFunction(row)
				else {
					action := wizard.getAction(row)
					label := wizard.getActionLabel(row)

					contextMenu := wizard.createActionsMenu(action . ": " . StrReplace(label, "`n", A_Space), row)

					Menu %contextMenu%, Show
				}
			}
		}
	}
}

showSelectorHint() {
	local hint

	if (GetKeyState("Esc", "P") || !ActionsStepWizard.CurrentActionsStep) {
		SetTimer showSelectorHint, Off

		ActionsStepWizard.CurrentActionsStep.iPendingFunctionRegistration := false
		ActionsStepWizard.CurrentActionsStep.iPendingActionRegistration := false

		ToolTip, , , 1
	}
	else if ActionsStepWizard.CurrentActionsStep.iPendingFunctionRegistration {
		hint := translate("Click on a controller function...")

		ToolTip %hint%, , , 1
	}
	else if ActionsStepWizard.CurrentActionsStep.iPendingActionRegistration {
		hint := translate("Click on an action...")

		ToolTip %hint%, , , 1
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateControllerLabels() {
	SetupWizard.Instance.Step.loadControllerLabels()
}

updateFunctionTriggers() {
	local function, row, curCoordMode, control, number, trigger, menuItem
	local window, multiple, menuItem, handler

	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")

	if (A_GuiEvent = "Normal") {
		if (A_EventInfo > 0)
			SetupWizard.Instance.StepWizards["Controller"].updateFunctionTriggers(A_EventInfo)
	}
	else if (A_GuiEvent = "RightClick") {
		if (A_EventInfo > 0) {
			row := A_EventInfo

			curCoordMode := A_CoordModeMouse

			LV_GetText(control, row, 2)
			LV_GetText(function, row, 3)
			LV_GetText(number, row, 4)
			LV_GetText(trigger, row, 5)

			menuItem := ConfigurationItem.descriptor(control, number)

			try {
				Menu ContextMenu, DeleteAll
			}
			catch exception {
				logError(exception)
			}

			window := SetupWizard.Instance.WizardWindow

			Gui %window%:Default

			Menu ContextMenu, Add, %menuItem%, controlMenuIgnore
			Menu ContextMenu, Disable, %menuItem%

			if (trigger != translate("n/a")) {
				Menu ContextMenu, Add

				multiple := ((function = translate(k2WayToggleType)) || (function = translate(kDialType)))

				menuItem := translate(multiple ? "Assign multiple Triggers" : "Assign Trigger")
				handler := ObjBindMethod(SetupWizard.Instance.StepWizards["Controller"], "updateFunctionTriggers", row)

				Menu ContextMenu, Add, %menuItem%, %handler%

				multiple := ((function = translate(k2WayToggleType)) || (function = translate(kDialType)))

				menuItem := translate(multiple ? "Assign multiple Hotkeys" : "Assign Hotkey")
				handler := ObjBindMethod(SetupWizard.Instance.StepWizards["Controller"], "updateFunctionHotkeys", row)

				Menu ContextMenu, Add, %menuItem%, %handler%

				Menu ContextMenu, Add

				menuItem := translate("Clear Trigger && Hotkey")
				handler := ObjBindMethod(SetupWizard.Instance.StepWizards["Controller"], "clearFunctionTriggerAndHotkey", row)

				Menu ContextMenu, Add, %menuItem%, %handler%
			}

			Menu ContextMenu, Show
		}
	}

	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

initializeControllerStepWizard() {
	SetupWizard.Instance.registerStepWizard(new ControllerStepWizard(SetupWizard.Instance, "Controller", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerStepWizard()