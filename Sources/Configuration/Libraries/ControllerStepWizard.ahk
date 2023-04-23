;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Step Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "ControllerEditor.ahk"


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
		iStepWizard := false

		__New(wizard) {
			this.iStepWizard := wizard

			super.__New("Default", wizard.SetupWizard.Configuration
					  , kUserHomeDirectory . "Setup\Button Box Configuration.ini"
					  , kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")
		}

		configurationChanged(type, name) {
			local bbConfiguration := newMultiMap()
			local sdConfiguration := newMultiMap()

			super.configurationChanged(type, name)

			this.saveToConfiguration(bbConfiguration, sdConfiguration)

			writeMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini", bbConfiguration)
			writeMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini", sdConfiguration)

			if this.iStepWizard.iFunctionTriggers {
				this.iStepWizard.saveFunctions(bbConfiguration, sdConfiguration)

				this.iStepWizard.loadFunctions(bbConfiguration, sdConfiguration)
			}
		}
	}

	Pages {
		Get {
			return (this.SetupWizard.isModuleSelected("Controller") ? 1 : 0)
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local buttonBoxConfiguration, streamDeckConfiguration, streamDeckControllers, controller, definition
		local ignore, theFunction, controls, buttonBoxControllers, control, descriptor, functionTriggers

		super.saveToConfiguration(configuration)

		buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

		if wizard.isModuleSelected("Controller") {
			streamDeckControllers := []

			for controller, definition in getMultiMapValues(streamDeckConfiguration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
					controller := controller[1]

					if !inList(streamDeckControllers, controller)
						streamDeckControllers.Push(controller)

					for ignore, theFunction in string2Values(";", definition)
						if (theFunction && (theFunction != ""))
							Function.createFunction(theFunction, false, "", "", "", "").saveToConfiguration(configuration)
				}
			}

			controls := CaseInsenseWeakMap()
			buttonBoxControllers := []

			for control, descriptor in getMultiMapValues(buttonBoxConfiguration, "Controls")
				controls[control] := string2Values(";", descriptor, false, WeakArray)[1]

			for controller, definition in getMultiMapValues(buttonBoxConfiguration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
					controller := controller[1]

					if !inList(buttonBoxControllers, controller)
						buttonBoxControllers.Push(controller)

					for ignore, control in string2Values(";", definition) {
						control := string2Values(",", control, false, WeakArray)[1]

						if (control != "") {
							control:= ConfigurationItem.splitDescriptor(control)
							theFunction := ConfigurationItem.descriptor(controls[control[1]], control[2])

							functionTriggers := wizard.getControllerFunctionTriggers(theFunction)

							if (functionTriggers.Length > 0)
								theFunction := Function.createFunction(theFunction, false, functionTriggers[1], "", ((functionTriggers.Length > 1) ? functionTriggers[2] : ""), "")
							else
								theFunction := Function.createFunction(theFunction, false, "", "", "", "")

							theFunction.saveToConfiguration(configuration)
						}
					}
				}
			}

			if (buttonBoxControllers.Length > 0) {
				loop buttonBoxControllers.Length
					buttonBoxControllers[A_Index] := (buttonBoxControllers[A_Index] . ":" . buttonBoxControllers[A_Index])

				setMultiMapValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", buttonBoxControllers*))
			}

			if (streamDeckControllers.Length > 0) {
				loop streamDeckControllers.Length
					streamDeckControllers[A_Index] := (streamDeckControllers[A_Index] . ":" . streamDeckControllers[A_Index])

				setMultiMapValue(configuration, "Controller Layouts", "Stream Decks", values2String("|", streamDeckControllers*))
			}
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local info, html

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		functionTriggersSelect(listView, line, *) {
			local function, row, curCoordMode, control, number, trigger, menuItem
			local multiple, menuItem, handler

			loop this.iFunctionsListView.GetCount()
				this.iFunctionsListView.Modify(A_Index, "-Select")

			if (line > 0)
				this.updateFunctionTriggers(line)
		}

		functionTriggersMenu(listView, line, *) {
			local function, row, curCoordMode, control, number, trigger, menuItem
			local multiple, menuItem, handler, contextMenu

			if (line > 0) {
				row := this.iFunctionsListView.GetNext()

				if !row
					row := line

				curCoordMode := A_CoordModeMouse

				control := this.iFunctionsListView.GetText(row, 2)
				function := this.iFunctionsListView.GetText(row, 3)
				number := this.iFunctionsListView.GetText(row, 4)
				trigger := this.iFunctionsListView.GetText(row, 5)

				menuItem := ConfigurationItem.descriptor(control, number)

				contextMenu := Menu()

				contextMenu.Add(menuItem, (*) => {})
				contextMenu.Disable(menuItem)

				if (trigger != translate("n/a")) {
					contextMenu.Add()

					multiple := ((function = translate(k2WayToggleType)) || (function = translate(kDialType)))

					contextMenu.Add(translate(multiple ? "Assign multiple Triggers" : "Assign Trigger")
								  , (*) => this.updateFunctionTriggers(row))

					multiple := ((function = translate(k2WayToggleType)) || (function = translate(kDialType)))

					contextMenu.Add(translate(multiple ? "Assign multiple Hotkeys" : "Assign Hotkey")
								  , (*) => this.updateFunctionHotkeys(row))

					contextMenu.Add()

					contextMenu.Add(translate("Clear Trigger && Hotkey"), (*) => this.clearFunctionTriggerAndHotkey(row))
				}

				contextMenu.Show()
			}

			loop this.iFunctionsListView.GetCount()
				this.iFunctionsListView.Modify(A_Index, "-Select")
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Controller.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Controller Configuration"))

		window.SetFont("s8 Norm", "Arial")

		widget3 := window.Add("ListView", "x" . x . " yp+30 w" . width . " h240 W:Grow H:Grow(0.66) AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden", collect(["Controller", "Control", "Function", "Number", "Trigger(s)", "Hints & Conflicts"], translate))
		widget3.OnEvent("Click", functionTriggersSelect)
		widget3.OnEvent("DoubleClick", functionTriggersSelect)
		widget3.OnEvent("ContextMenu", functionTriggersMenu)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Controller", "Controller.Functions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget4 := window.Add("HTMLViewer", "x" . x . " yp+245 w" . width . " h195 W:Grow Y:Move(0.66) H:Grow(0.33) VfunctionsInfoText Hidden")

		html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget4.navigate("about:blank")
		widget4.document.write(html)

		this.iFunctionsListView := widget3

		this.registerWidgets(1, widget1, widget2, widget3, widget4)
	}

	reset() {
		super.reset()

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
				buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

			if !streamDeckConfiguration
				streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			this.SetupWizard.setControllerFunctions(this.controllerFunctions(buttonBoxConfiguration, streamDeckConfiguration))
		}
	}

	showPage(page) {
		local editor

		super.showPage(page)

		editor := ControllerStepWizard.StepControllerEditor(this)

		this.iControllerEditor := editor

		editor.createGui(editor.ButtonBoxConfiguration, editor.StreamDeckConfiguration, false)

		editor.show(Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 225, A_ScreenWidth - 450), "Center")

		this.loadFunctions(readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
						 , readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini"), true)
	}

	hidePage(page) {
		local buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		local streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")
		local function, streamDeckFunctions, controller, definition, ignore, msgResult

		if (this.conflictingFunctions(buttonBoxConfiguration) || this.conflictingTriggers(buttonBoxConfiguration)) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("There are still duplicate functions or duplicate triggers - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}

		streamDeckFunctions := 0

		for controller, definition in getMultiMapValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition)
					if (function && (function != ""))
						streamDeckFunctions += 1
		}

		if ((this.iFunctionsListView.GetCount() - streamDeckFunctions) != this.iFunctionTriggers.Count) {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Not all functions have been assigned to physical controls. Do you really want to proceed?"), translate("Warning"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "No")
				return false
		}

		if super.hidePage(page) {
			this.iControllerEditor.close(true)

			this.iControllerEditor := false

			buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
			streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)

			this.iFunctionTriggers := false

			return true
		}
		else
			return false
	}

	controllerFunctions(buttonBoxConfiguration, streamDeckConfiguration) {
		local controls := CaseInsenseWeakMap()
		local functions := []
		local function, control, descriptor, controller, definition, ignore

		for control, descriptor in getMultiMapValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor, false, WeakArray)[1]

		for controller, definition in getMultiMapValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function, false, WeakArray)[1]
					function := ConfigurationItem.splitDescriptor(function)
					function := ConfigurationItem.descriptor(controls[function[1]], function[2])

					if (function && (function != ""))
						if this.iFunctionTriggers.Has(function)
							functions.Push(Array(function, this.iFunctionTriggers[function]*))
						else
							functions.Push(function)
				}
		}

		for controller, definition in getMultiMapValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible"))
				for ignore, function in string2Values(";", definition)
					if (function && (function != ""))
						functions.Push(function)
		}

		return functions
	}

	conflictingFunctions(buttonBoxConfiguration) {
		local controls := CaseInsenseWeakMap()
		local functions := CaseInsenseWeakMap()
		local conflict := false
		local function, control, descriptor, controller, definition, ignore

		for control, descriptor in getMultiMapValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor, false, WeakArray)[1]

		for controller, definition in getMultiMapValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function, false, WeakArray)[1]

					if (function && (function != "")) {
						function := ConfigurationItem.splitDescriptor(function)
						function := ConfigurationItem.descriptor(controls[function[1]], function[2])

						if !functions.Has(function)
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
		local triggers := CaseInsenseWeakMap()
		local conflict := false
		local function, functionTriggers, ignore, trigger

		for function, functionTriggers in this.iFunctionTriggers
			for ignore, trigger in functionTriggers
				if !triggers.Has(trigger)
					triggers[trigger] := [function]
				else {
					triggers[trigger].Push(function)

					conflict := true
				}

		return (conflict ? triggers : false)
	}

	loadFunctions(buttonBoxConfiguration, streamDeckConfiguration, load := false) {
		local wizard := this.SetupWizard
		local controls := CaseInsenseWeakMap()
		local lastController := false
		local function, ignore, control, descriptor, first, conflict, trigger, triggers
		local functionConflicts, triggerConflicts, controller, definition, functionTriggers

		for control, descriptor in getMultiMapValues(buttonBoxConfiguration, "Controls")
			controls[control] := string2Values(";", descriptor, false, WeakArray)[1]

		if (load || !this.iFunctionTriggers)
			this.iFunctionTriggers := CaseInsenseMap()

		this.iFunctionsListView.Delete()

		functionConflicts := this.conflictingFunctions(buttonBoxConfiguration)
		triggerConflicts := this.conflictingTriggers(buttonBoxConfiguration)

		for controller, definition in getMultiMapValues(buttonBoxConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, control in string2Values(";", definition) {
					control := string2Values(",", control, false, WeakArray)[1]

					if (control != "") {
						control := ConfigurationItem.splitDescriptor(control)
						function := ConfigurationItem.descriptor(controls[control[1]], control[2])

						first := (controller != lastController)
						lastController := controller

						if this.iFunctionTriggers.Has(function)
							functionTriggers := this.iFunctionTriggers[function]
						else
							functionTriggers := wizard.getControllerFunctionTriggers(function)

						conflict := 0

						if (functionConflicts && functionConflicts[function].Length > 1)
							conflict += 1

						if triggerConflicts
							for ignore, trigger in functionTriggers
								if (triggerConflicts[trigger].Length > 1) {
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

						if (functionTriggers.Length > 0) {
							triggers := values2String(" `; ", functionTriggers*)

							if load
								this.iFunctionTriggers[function] := functionTriggers
						}
						else
							triggers := ""

						this.iFunctionsListView.Add("", (first ? controller : ""), control[1], translate(controls[control[1]]), control[2], triggers, conflict)
					}
				}
			}
		}

		for controller, definition in getMultiMapValues(streamDeckConfiguration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)

			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]

				for ignore, function in string2Values(";", definition)
					if (function && (function != "")) {
						first := (controller != lastController)
						lastController := controller

						this.iFunctionsListView.Add("", (first ? controller : ""), translate("Key"), translate("Button"), ConfigurationItem.splitDescriptor(function)[2], translate("n/a"), "")
					}
			}
		}

		loop 6
			this.iFunctionsListView.ModifyCol(A_Index, "AutoHdr")

		this.iFunctionsListView.ModifyCol(4, "Integer")
		this.iFunctionsListView.ModifyCol(4, "Center")
	}

	updateFunctionTriggers(row) {
		local wizard := this.SetupWizard
		local function, trigger, type, number, callback

		if triggerDetector("Active")
			wizard.toggleTriggerDetector()

		trigger := this.iFunctionsListView.GetText(row, 5)

		if (trigger != translate("n/a")) {
			type := this.iFunctionsListView.GetText(row, 3)
			number := this.iFunctionsListView.GetText(row, 4)

			switch type, false {
				case translate(k2WayToggleType):
					callback := ObjBindMethod(this, "registerHotkey", k2WayToggleType . "." . number, row, true)
				case translate(kDialType):
					callback := ObjBindMethod(this, "registerHotkey", kDialType . "." . number, row, true)
				case translate(k1WayToggleType):
					callback := ObjBindMethod(this, "registerHotkey", k1WayToggleType . "." . number, row, false)
				case translate(kButtonType):
					callback := ObjBindMethod(this, "registerHotkey", kButtonType . "." . number, row, false)
				default:
					throw "Unknown function type detected in ControllerStepWizard.updateFunctionTriggers..."
			}

			wizard.toggleTriggerDetector(callback)
		}
	}

	updateFunctionHotkeys(row) {
		local function, trigger, type, number, double, result
		local key1, key2, buttonBoxConfiguration, streamDeckConfiguration

		trigger := this.iFunctionsListView.GetText(row, 5)

		if (trigger != translate("n/a")) {
			type := this.iFunctionsListView.GetText(row, 3)
			number := this.iFunctionsListView.GetText(row, 4)

			double := false

			switch type, false {
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
				default:
					throw "Unknown function type detected in ControllerStepWizard.updateFunctionHotkeys..."
			}

			function := (type . "." . number)

			trigger := (this.iFunctionTriggers.Has(function) ? this.iFunctionTriggers[function] : false)

			key1 := ""
			key2 := ""

			if trigger {
				if (trigger.Length > 0)
					key1 := trigger[1]

				if (trigger.Length > 1)
					key2 := trigger[2]
			}

			result := InputBox(translate(double ? "Please enter the first Hotkey:" : "Please enter a Hotkey:")
							 , translate("Modular Simulator Controller System"), "w200 h150", key1)

			if (result.Result = "Ok")
				key1 := result.Value
			else
				return

			if double {
				result := InputBox(translate("Please enter the second Hotkey:"), translate("Modular Simulator Controller System"), "w200 h150", key2)

				if (result.Result = "Ok")
					key2 := result.Value
				else
					return

				if ((key1 = "") && (key2 = ""))
					this.iFunctionTriggers.Delete(function)
				else
					this.iFunctionTriggers[function] := [key1, key2]
			}
			else
				this.iFunctionTriggers[function] := [key1]

			buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
			streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)
			this.loadFunctions(buttonBoxConfiguration, streamDeckConfiguration)

			this.iFunctionsListView.Modify(row, "Vis")
		}
	}

	clearFunctionTriggerAndHotkey(row) {
		local function, trigger, double, type, number

		trigger := this.iFunctionsListView.GetText(row, 5)

		if (trigger != translate("n/a")) {
			type := this.iFunctionsListView.GetText(row, 3)
			number := this.iFunctionsListView.GetText(row, 4)

			double := false

			switch type, false {
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
				default:
					throw "Unknown function type detected in ControllerStepWizard.clearFunctionTriggerAndHotkey..."
			}

			function := (type . "." . number)

			this.iFunctionTriggers.Delete(function)

			this.iFunctionTriggers.Modify(row, "Col5", "")

			this.saveFunctions()
		}
	}

	registerHotKey(function, row, firstHotkey, hotkey) {
		local wizard := this.SetupWizard
		local controller, number, buttonBoxConfiguration, streamDeckConfiguration, window

		SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

		if (firstHotkey == true) {
			wizard.toggleTriggerDetector()

			Sleep(2000)

			wizard.toggleTriggerDetector(ObjBindMethod(this, "registerHotkey", function, row, hotkey))

			return
		}
		else if (firstHotkey != false) {
			this.iFunctionTriggers[function] := [firstHotkey, hotkey]

			Hotkey(":= firstHotkey . `" | `" . hotkey")
		}
		else
			this.iFunctionTriggers[function] := [hotkey]

		wizard.toggleTriggerDetector()

		buttonBoxConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")
		streamDeckConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

		this.saveFunctions(buttonBoxConfiguration, streamDeckConfiguration)
		this.loadFunctions(buttonBoxConfiguration, streamDeckConfiguration)

		this.iFunctionsListView.Modify(row, "Vis")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerPreviewStepWizard                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerPreviewStepWizard extends StepWizard {
	static sControllerPreviewCenters := CaseInsenseMap()

	iControllerPreviews := []
	iControllerPreviewCenterY := 0

	ControllerPreviews {
		Get {
			return this.iControllerPreviews
		}
	}

	reset() {
		super.reset()

		this.closeControllerPreviews()
	}

	showPage(page) {
		super.showPage(page)

		if this.SetupWizard.isModuleSelected("Controller")
			this.openControllerPreviews()
	}

	hidePage(page) {
		if super.hidePage(page) {
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

	getPreviewCenter(descriptor, &centerX, &centerY) {
		local center

		if (descriptor && ControllerPreviewStepWizard.sControllerPreviewCenters.Has(descriptor)) {
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
		moveControllerPreview(window) {
			local preview, x, y, width, height

			moveByMouse(window)

			WinGetPos(&x, &y, &width, &height, window)
			
			x := screen2Window(x)
			y := screen2Window(y)

			this.setPreviewCenter(window, x + Round(width / 2), y + Round(height / 2))
		}

		return moveControllerPreview
	}

	createControllerPreview(type, controller, configuration) {
		if (type = "Button Box")
			return ButtonBoxPreview(this, controller, configuration)
		else
			return StreamDeckPreview(this, controller, configuration)
	}

	openControllerPreviews() {
		local function, index, controller, staticFunctions, controllers, found, configuration, definition
		local preview, mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

		if this.SetupWizard.isModuleSelected("Controller") {
			staticFunctions := this.SetupWizard.getModuleStaticFunctions()
			controllers := []
			found := []

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Button Box Configuration.ini")

			for controller, definition in getMultiMapValues(configuration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)

				if !inList(found, controller[1]) {
					found.Push(controller[1])
					controllers.Push(Array("Button Box", controller[1], configuration))
				}
			}

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Stream Deck Configuration.ini")

			for controller, definition in getMultiMapValues(configuration, "Layouts") {
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
					MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

					this.iControllerPreviewCenterY := (mainScreenBottom - Round(preview.Height / 2))
				}
				else
					this.iControllerPreviewCenterY -= Round(preview.Height / 2)

				preview.show()

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
				if preview.findFunction(function[1], &row, &column)
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

	iModes := CaseInsenseMap()
	iActions := CaseInsenseMap()
	iDescriptors := CaseInsenseMap()
	iLabels := CaseInsenseMap()
	iFunctions := CaseInsenseMap()
	iArguments := CaseInsenseMap()

	class ActionsButtonBoxPreview extends ButtonBoxPreview {
		iModeDropDown := false

		iModes := []

		Mode {
			Get {
				local mode, ignore, candidate

				mode := this.iModeDropDown.Text

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

			super.__New(previewManager, name, configuration)
		}

		createGui(configuration) {
			local modeDropDownHandle := false
			local modes := []
			local ignore, mode, window

			updateControllerLabels(*) {
				this.PreviewManager.loadControllerLabels()
			}

			super.createGui(configuration)

			window := this.Window

			for ignore, mode in this.iModes
				if mode
					modes.Push(translate(mode))
				else
					modes.Push(translate("Independent"))

			modes.InsertAt(1, translate("All Modes"))

			window.SetFont("s8 Norm", "Arial")

			this.iModeDropDown := window.Add("DropDownList", "x8 y8 w82 Choose1", modes)
			this.iModeDropDown.OnEvent("Change", updateControllerLabels)
		}
	}

	class ActionsStreamDeckPreview extends StreamDeckPreview {
		iModeDropDown := false

		iModes := []

		Mode {
			Get {
				local mode, ignore, candidate

				mode := this.iModeDropDown.Text

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

			super.__New(previewManager, name, configuration)
		}

		createGui(configuration) {
			local modeDropDownHandle := false
			local modes := []
			local ignore, mode, window

			updateControllerLabels(*) {
				this.PreviewManager.loadControllerLabels()
			}

			super.createGui(configuration)

			window := this.Window

			for ignore, mode in this.iModes
				if mode
					modes.Push(translate(mode))
				else
					modes.Push(translate("Independent"))

			modes.InsertAt(1, translate("All Modes"))

			window.SetFont("s8 Norm", "Arial")

			this.iModeDropDown := window.Add("DropDownList", "x8 y8 w82 Choose1", modes)
			this.iModeDropDown.OnEvent("Change", updateControllerLabels)
		}
	}

	ActionsListView {
		Get {
			return this.iActionsListView
		}
	}

	static CurrentActionsStep {
		Get {
			return ActionsStepWizard.sCurrentActionsStep
		}
	}

	reset() {
		super.reset()

		this.iActionsListView := false

		this.clearActions()
		this.clearActionFunctions()
		this.clearActionArguments()
	}

	showPage(page) {
		ActionsStepWizard.sCurrentActionsStep := this

		super.showPage(page)

		if this.SetupWizard.isModuleSelected("Controller")
			this.loadActions(true)
		else
			this.ActionsListView.Visible := false
	}

	hidePage(page) {
		if super.hidePage(page) {
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

			return this.iLabels[this.iLabels.Has(key) ? key : row]
		}
		else
			return this.iLabels[row]
	}

	clearActions() {
		this.iModes := CaseInsenseMap()
		this.iActions := CaseInsenseMap()
		this.iDescriptors := CaseInsenseMap()
		this.iLabels := CaseInsenseMap()
	}

	setActionFunction(mode, action, functionDescriptor) {
		local oldFunction := this.getActionFunction(mode, action)
		local changed, ignore, oldValue

		if (oldFunction && (oldFunction != "")) {
			changed := []

			if (isObject(oldfunction) && isObject(functionDescriptor)) {
				loop oldFunction.Length
					if (oldFunction[A_Index] != functionDescriptor[A_Index])
						changed.Push(oldFunction[A_Index])
			}
			else if (oldFunction != functionDescriptor)
				changed.Push(oldFunction)

			for ignore, oldValue in changed
				if (oldValue != "")
					this.clearActionFunction(mode, action, oldValue)
		}

		if !this.iFunctions.Has(mode)
			this.iFunctions[mode] := CaseInsenseMap()

		this.iFunctions[mode][action] := functionDescriptor
	}

	getActionFunction(mode, action) {
		local functions

		if this.iFunctions.Has(mode) {
			functions := this.iFunctions[mode]

			return (functions.Has(action) ? functions[action] : false)
		}
		else
			return false
	}

	clearActionFunction(mode, action, function) {
		local functions, actionFunctions, index, candidate

		if this.iFunctions.Has(mode) {
			functions := this.iFunctions[mode]

			if functions.Has(action) {
				actionFunctions := functions[action]

				for index, candidate in actionFunctions
					if (candidate = function)
						actionFunctions[index] := ""

				if (actionFunctions.Length == 1)
					functions.Delete(action)
				else if ((actionFunctions[1] = "") && (actionFunctions[2] = ""))
					functions.Delete(action)
			}
		}
	}

	clearActionFunctions() {
		this.iFunctions := CaseInsenseMap()
	}

	setActionArgument(row, argument) {
		this.iArguments[row] := argument
	}

	getActionArgument(rowOrMode, action := false) {
		if action
			rowOrMode := this.getActionRow(rowOrMode, action)

		return (this.iArguments.Has(rowOrMode) ? this.iArguments[rowOrMode] : false)
	}

	clearActionArguments() {
		this.iArguments := CaseInsenseMap()
	}

	createControllerPreview(type, controller, configuration) {
		if (type = "Button Box")
			return ActionsStepWizard.ActionsButtonBoxPreview(this, controller, configuration, this.getModes())
		else
			return ActionsStepWizard.ActionsStreamDeckPreview(this, controller, configuration, this.getModes())
	}

	openControllerPreviews() {
		super.openControllerPreviews()

		this.iPendingFunctionRegistration := false
		this.iPendingActionRegistration := false
	}

	loadControllerLabels() {
		local wizard := this.SetupWizard
		local function, action, module, row, column, ignore, preview, targetMode, mode, partFunction

		super.loadControllerLabels()

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

	setFunction(row) {
		local arguments

		if this.iPendingActionRegistration {
			arguments := this.iPendingActionRegistration

			this.iPendingActionRegistration := false
			this.iPendingFunctionRegistration := row

			SetTimer(showSelectorHint, 0)

			ToolTip( , , 1)

			this.controlClick(arguments*)
		}
		else {
			this.iPendingFunctionRegistration := row

			SetTimer(showSelectorHint, 100)
		}
	}

	clearFunction(row) {
		local action := this.getAction(row)
		local mode := this.getActionMode(row)
		local function := this.getActionFunction(mode, action)
		local ignore

		if (function && (function != "")) {
			SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

			if isObject(function) {
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

		SetTimer(showSelectorHint, 100)
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
							SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

							this.clearActionFunction(mode, action, function)

							found := true
							changed := true
						}
		}

		if changed
			this.loadActions()
	}

	createActionsMenu(title, row) {
		local function, menuItem, handler, count, contextMenu

		contextMenu := Menu()

		contextMenu.Add(title, (*) => {})
		contextMenu.Disable(title)
		contextMenu.Add()

		contextMenu.Add(translate("Set Function"), (*) => this.setFunction(row))

		function := this.getActionFunction(this.getActionMode(row), this.getAction(row))
		count := 0

		if isObject(function) {
			if ((function.Length > 1) && (function[1] != "") && (function[2] != ""))
				count := 2
			else if (function[1] != "")
				count := 1
		}
		else if (function && (function != ""))
			count := 1

		menuItem := translate((count > 1) ? "Clear Function(s)" : "Clear Function")

		contextMenu.Add(menuItem, (*) => this.clearFunction(row))

		this.getActionFunction(this.getActionMode(row), this.getAction(row))

		if (count == 0)
			contextMenu.Disable(menuItem)

		return contextMenu
	}

	createControlMenu(title, preview, element, function, row, column) {
		local action, menuItem, handler, count, mode, modeFunctions, action, functions, ignore, candidate, contextMenu

		contextMenu := Menu()

		contextMenu.Add(title, (*) => {})
		contextMenu.Disable(title)
		contextMenu.Add()

		contextMenu.Add(translate("Set Action"), (*) => this.setFunctionAction(Array(preview, element, function, row, column, false, true)))

		count := 0

		for mode, modeFunctions in this.iFunctions
			for action, functions in modeFunctions
				for ignore, candidate in functions
					if (candidate = function)
						count += 1

		menuItem := translate((count > 1) ? "Clear Action(s)" : "Clear Action")

		contextMenu.Add(menuItem, (*) => this.clearFunctionAction(preview, function, element[2], row, column))

		if (count = 0)
			contextMenu.Disable(menuItem)

		return contextMenu
	}

	setControlFunction(row, function) {
		local mode := this.getActionMode(row)
		local action := this.getAction(row)
		local actionDescriptor := this.getActionDescriptor(row)
		local functionType := ConfigurationItem.splitDescriptor(function)[1]
		local action, msgResult, translator, currentFunction

		if (((functionType == k2WayToggleType) || (functionType == kDialType)) && ((actionDescriptor[2] == "Toggle") || (actionDescriptor[2] == "Dial")))
			function := [function]
		else if (((functionType == k1WayToggleType) || (functionType == kButtonType)) && (actionDescriptor[2] == "Toggle") && !actionDescriptor[3])
			function := [function]
		else if (actionDescriptor[2] == "Activate")
			function := [function]
		else {
			if (actionDescriptor[2] == "Toggle")
				translator := translateMsgBoxButtons.Bind(["On/Off", "Off", "Cancel"])
			else
				translator := translateMsgBoxButtons.Bind(["Increase", "Decrease", "Cancel"])

			OnMessage(0x44, translator)
			msgResult := MsgBox(translate("Trigger for ") . action . translate("?"), translate("Trigger"), 262179)
			OnMessage(0x44, translator, 0)

			currentFunction := this.getActionFunction(mode, action)

			if currentFunction
				currentFunction := currentFunction.Clone()

			switch msgResult, false {
				case "Cancel":
					function := false
				case "Yes":
					if currentFunction {
						if (currentFunction.Length == 1)
							function := [function, ""]
						else {
							currentFunction[1] := function

							function := currentFunction
						}
					}
					else
						function := [function, ""]
				case "No":
					if currentFunction {
						if (currentFunction.Length == 1)
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
				title := (translate(element[1]) . translate(": ") . StrReplace(StrReplace(element[2], "`n", A_Space), "`r", "") . " (" . row . " x " . column . ")")

				this.createControlMenu(title, preview, element, function, row, column).Show()
			}
			else {
				SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

				SetTimer(showSelectorHint, 0)

				ToolTip( , , 1)

				actionRow := this.iPendingFunctionRegistration

				mode := this.getActionMode(actionRow)
				action := this.getAction(actionRow)
				function := this.setControlFunction(actionRow, function)

				if function {
					this.setActionFunction(mode, action, function)

					this.loadActions()

					this.ActionsListView.Modify(actionRow, "Vis")
				}

				this.iPendingFunctionRegistration := false
			}
		}
	}

	actionFunctionSelect(line) {
		local row

		if (line > 0) {
			row := this.ActionsListView.GetNext()

			if !row
				row := line

			if (this.SetupWizard.isModuleSelected("Controller"))
				if this.iPendingActionRegistration
					this.setFunction(row)
				else
					this.createActionsMenu(this.getAction(row) . ": " . StrReplace(StrReplace(this.getActionLabel(row), "`n", A_Space), "`r", ""), row).Show()
		}

		loop this.ActionsListView.GetCount()
			this.ActionsListView.Modify(A_Index, "-Select")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

showSelectorHint() {
	local hint

	if (GetKeyState("Esc", "P") || !ActionsStepWizard.CurrentActionsStep) {
		SetTimer(showSelectorHint, 0)

		ActionsStepWizard.CurrentActionsStep.iPendingFunctionRegistration := false
		ActionsStepWizard.CurrentActionsStep.iPendingActionRegistration := false

		ToolTip( , , 1)
	}
	else if ActionsStepWizard.CurrentActionsStep.iPendingFunctionRegistration
		ToolTip(translate("Click on a controller function..."), , , 1)
	else if ActionsStepWizard.CurrentActionsStep.iPendingActionRegistration
		ToolTip(translate("Click on an action..."), , , 1)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerStepWizard() {
	SetupWizard.Instance.registerStepWizard(ControllerStepWizard(SetupWizard.Instance, "Controller", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerStepWizard()