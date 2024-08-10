;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Configuration Plugin ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Configuration\Libraries\ControllerEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerConfigurator extends ConfiguratorPanel {
	iControllerList := false
	iFunctionsList := false

	ControllerList {
		Get {
			return this.iControllerList
		}
	}

	FunctionsList {
		Get {
			return this.iFunctionsList
		}
	}

	__New(editor, configuration) {
		this.iEditor := editor

		this.iControllerList := ControllerList(this.Editor, configuration)
		this.iFunctionsList := FunctionsList(this.Editor, configuration)

		super.__New(configuration)

		ControllerConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		toggleTriggerDetector(*) {
			protectionOn()

			try {
				ConfigurationEditor.Instance.toggleTriggerDetector(false, ["Joy", "Key", "Multi"])
			}
			finally {
				protectionOff()
			}
		}

		this.ControllerList.createGui(editor, x, y, width, height)
		this.FunctionsList.createGui(editor, x, y, width, height)

		window.Add("Button", "x16 y530 w100 h23 Y:Move", translate("Trigger...")).OnEvent("Click", toggleTriggerDetector)
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		this.ControllerList.saveToConfiguration(configuration)
		this.FunctionsList.saveToConfiguration(configuration)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerList                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerList extends ConfigurationItemList {
	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		ControllerList.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local choices, chosen

		openControllerEditor(*) {
			this.openControllerEditor()
		}

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "x16 y80 w457 h115 W:Grow", translate("Controller"))

		window.SetFont("Norm", "Arial")
		window.Add("ListBox", "x24 y99 w194 h96 W:Grow(0.4) VcontrollerListBox")

		window.Add("Edit", "x224 y99 w104 h21 X:Move(0.4) W:Grow(0.3) VcontrollerEdit")

		choices := this.computeLayoutChoices()
		chosen := (choices.Length > 0)

		window.Add("DropDownList", "x330 y99 w108 X:Move(0.7) W:Grow(0.3) Choose" . chosen . " VcontrollerLayoutDropDown", choices)
		window.Add("Button", "x440 y98 w23 h23 X:Move VopenControllerEditorButton", translate("...")).OnEvent("Click", openControllerEditor)

		window.Add("Button", "x385 y124 w38 h23 X:Move Disabled VcontrollerUpButton", translate("Up"))
		window.Add("Button", "x425 y124 w38 h23 X:Move Disabled VcontrollerDownButton", translate("Down"))

		window.Add("Button", "x265 y164 w46 h23 X:Move VcontrollerAddButton", translate("Add"))
		window.Add("Button", "x313 y164 w50 h23 X:Move Disabled VcontrollerDeleteButton", translate("Delete"))
		window.Add("Button", "x409 y164 w55 h23 X:Move Disabled VcontrollerUpdateButton", translate("Save"))

		this.initializeList(editor, window["controllerListBox"], window["controllerAddButton"], window["controllerDeleteButton"], window["controllerUpdateButton"]
								  , window["controllerUpButton"], window["controllerDownButton"])
	}

	loadFromConfiguration(configuration) {
		local items := []
		local ignore, controller

		super.loadFromConfiguration(configuration)

		for ignore, controller in string2Values("|", getMultiMapValue(configuration, "Controller Layouts", "Button Boxes", ""))
			items.Push(string2Values(":", controller))

		for ignore, controller in string2Values("|", getMultiMapValue(configuration, "Controller Layouts", "Stream Decks", ""))
			items.Push(string2Values(":", controller))

		this.ItemList := items
	}

	saveToConfiguration(configuration) {
		local bbController := []
		local sdController := []
		local sdConfiguration := readMultiMap(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))
		local ignore, item

		super.saveToConfiguration(configuration)

		for ignore, item in this.ItemList
			if getMultiMapValue(sdConfiguration, "Layouts", item[2] . ".Layout", false)
				sdController.Push(values2String(":", item*))
			else
				bbController.Push(values2String(":", item*))

		setMultiMapValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", bbController*))
		setMultiMapValue(configuration, "Controller Layouts", "Stream Decks", values2String("|", sdController*))
	}

	loadList(items) {
		local controller := []
		local ignore, item

		for ignore, item in this.ItemList
			controller.Push(item[1])

		this.Control["controllerListBox"].Delete()
		this.Control["controllerListBox"].Add(controller)
	}

	loadEditor(item) {
		this.Control["controllerEdit"].Text := item[1]

		try {
			this.Control["controllerLayoutDropDown"].Choose(item[2])
		}
		catch Any as exception {
			this.Control["controllerLayoutDropDown"].Choose(0)
		}
	}

	clearEditor() {
		this.loadEditor(Array("", ""))
	}

	buildItemFromEditor(isNew := false) {
		if ((Trim(this.Control["controllerEdit"].Text) = "") || (this.Control["controllerLayoutDropDown"].Text = "") || !this.Control["controllerLayoutDropDown"].Value) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else
			return Array(this.Control["controllerEdit"].Text, this.Control["controllerLayoutDropDown"].Text)
	}

	computeLayoutChoices(bbConfiguration := false, sdConfiguration := false) {
		local layouts := []
		local descriptor, definition

		if !bbConfiguration
			bbConfiguration := readMultiMap(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))

		if !sdConfiguration
			sdConfiguration := readMultiMap(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))


		for descriptor, definition in getMultiMapValues(bbConfiguration, "Layouts") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if !inList(layouts, descriptor[1])
				layouts.Push(descriptor[1])
		}

		for descriptor, definition in getMultiMapValues(sdConfiguration, "Layouts") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if !inList(layouts, descriptor[1])
				layouts.Push(descriptor[1])
		}

		return layouts
	}

	openControllerEditor() {
		local window := this.Window
		local choices, layout

		window.Block()

		try {
			layout := this.Control["controllerLayoutDropDown"].Text

			ControllerEditor(layout, this.Configuration).editController(window)

			choices := this.computeLayoutChoices()

			this.Control["controllerLayoutDropDown"].Delete()
			this.Control["controllerLayoutDropDown"].Add(choices)
			this.Control["controllerLayoutDropDown"].Choose(inList(choices, layout))
		}
		finally {
			window.Unblock()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FunctionsList                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FunctionsList extends ConfigurationItemList {
	iFunctions := CaseInsenseMap()

	Functions[key?] {
		Get {
			return (isSet(key) ? this.iFunctions[key] : this.iFunctions)
		}

		Set {
			return (isSet(key) ? (this.iFunctions[key] := value) : (this.iFunctions := value))
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		FunctionsList.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		updateFunctionEditorState(*) {
			protectionOn()

			try {
				this.updateState()
			}
			finally {
				protectionOff()
			}
		}

		openHotkeysDocumentation(*) {
			Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys")
		}

		openActionsDocumentation(*) {
			Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions")
		}

		window.Add("ListView", "x16 y200 w457 h186 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VfunctionsListView", collect(["Function", "Number", "Hotkey(s) & Action(s)"], translate))

		window.Add("Text", "x16 y396 w105 h23 Y:Move +0x200", translate("Function"))
		window.Add("DropDownList", "x124 y396 w91 Y:Move Choose1 VfunctionTypeDropDown", collect(["1-way Toggle", "2-way Toggle", "Button", "Rotary", "Custom"], translate)).OnEvent("Change", updateFunctionEditorState)
		window.Add("Edit", "x220 y396 w40 h21 Y:Move Number Limit3 VfunctionNumberEdit")
		window.Add("UpDown", "Range1-999 x260 y396 w17 h21 Y:Move", 1)

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "x16 y428 w457 h95 Y:Move W:Grow", translate("Bindings"))

		window.SetFont("Norm", "Arial")

		window.Add("Text", "x124 y438 w160 h22 Y:Move X:Move(0.25) +0x200 +Center", translate("On or Increase"))
		window.Add("Text", "x303 y438 w160 h22 Y:Move X:Move(0.75) +0x200 +Center", translate("Off or Decrease"))

		window.SetFont("Underline", "Arial")

		window.Add("Text", "x24 y460 w97 h23 Y:Move +0x200 c" . window.Theme.LinkColor, translate("Hotkey(s)")).OnEvent("Click", openHotkeysDocumentation)

		window.SetFont("Norm", "Arial")

		window.Add("Edit", "x124 y460 w160 h21 Y:Move W:Grow(0.5) VfunctionOnHotkeysEdit")
		window.Add("Edit", "x303 y460 w160 h21 Y:Move X:Move(0.5) W:Grow(0.5) VfunctionOffHotkeysEdit")

		window.SetFont("Underline", "Arial")

		window.Add("Text", "x24 y488 w97 h27 Y:Move c" . window.Theme.LinkColor, translate("Action(s) (optional)")).OnEvent("Click", openActionsDocumentation)

		window.SetFont("Norm", "Arial")

		window.Add("Edit", "x124 y484 w160 h21 Y:Move W:Grow(0.5) VfunctionOnActionEdit")
		window.Add("Edit", "x303 y484 w160 h21 Y:Move X:Move(0.5) W:Grow(0.5) VfunctionOffActionEdit")

		window.Add("Button", "x264 y530 w46 h23 Y:Move X:Move VfunctionAddButton", translate("Add"))
		window.Add("Button", "x312 y530 w50 h23 Y:Move X:Move Disabled VfunctionDeleteButton", translate("Delete"))
		window.Add("Button", "x418 y530 w55 h23 Y:Move X:Move Disabled VfunctionUpdateButton", translate("&Save"))

		this.initializeList(editor, window["functionsListView"], window["functionAddButton"], window["functionDeleteButton"], window["functionUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local descriptor, ignore, func

		super.loadFromConfiguration(configuration)

		for descriptor, ignore in getMultiMapValues(configuration, "Controller Functions") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			descriptor := ConfigurationItem.descriptor(descriptor[1], descriptor[2])

			if !this.Functions.Has(descriptor) {
				func := Function.createFunction(descriptor, configuration)

				this.Functions[descriptor] := func

				this.ItemList.Push(func)
			}
		}
	}

	saveToConfiguration(configuration) {
		local ignore, theFunction

		super.saveToConfiguration(configuration)

		for ignore, theFunction in this.ItemList
			theFunction.saveToConfiguration(configuration)
	}

	updateState() {
		local functionType

		super.updateState()

		functionType := this.Control["functionTypeDropDown"].Value

		if (functionType = 5) {
			this.Control["functionOnActionEdit"].Enabled := true
			this.Control["functionOffHotkeysEdit"].Enabled := false
			this.Control["functionOffHotkeysEdit"].Text := ""
			this.Control["functionOffActionEdit"].Enabled := false
			this.Control["functionOffActionEdit"].Text := ""
		}
		else if ((functionType == 2) || (functionType == 4)) {
			this.Control["functionOffHotkeysEdit"].Enabled := true
			this.Control["functionOffActionEdit"].Enabled := true
		}
		else {
			this.Control["functionOffHotkeysEdit"].Enabled := false
			this.Control["functionOffActionEdit"].Enabled := false
			this.Control["functionOffHotkeysEdit"].Text := ""
			this.Control["functionOffActionEdit"].Text := ""
		}
	}

	computeFunctionType(functionType) {
		return kControlTypes[functionType]
	}

	computeHotkeysAndActionText(hotkeys, action) {
		if (hotKeys && (hotkeys != ""))
			return (hotkeys . ((action == "") ? "" : (" => " . action)))
		else if (action != "")
			return action
		else
			return ""
	}

	loadList(items) {
		local qualifier, theFunction, hotkeysAndActions, index, trigger, nextHKA, hotkeys, action, round

		static first := true

		this.ItemList := Array()

		this.Control["functionsListView"].Delete()

		round := 0

		loop {
			if (++round > 2)
				break

			for qualifier, theFunction in this.Functions
				if (((round == 1) && (theFunction.Type != kCustomType)) || ((round == 2) && (theFunction.Type == kCustomType))) {
					hotkeysAndActions := ""

					for index, trigger in theFunction.Trigger {
						hotkeys := theFunction.Hotkeys[trigger, true]
						action := theFunction.Actions[trigger, true]

						nextHKA := this.computeHotkeysAndActionText(hotkeys, action)

						if ((index > 1) && (hotkeysAndActions != "") && (nextHKA != ""))
							hotkeysAndActions := hotkeysAndActions . ", "

						hotkeysAndActions := hotkeysAndActions . nextHKA
					}

					this.Control["functionsListView"].Add("", translate(this.computeFunctionType(theFunction.Type)), theFunction.Number, hotkeysAndActions)

					this.ItemList.Push(theFunction)
				}
		}

		if first {
			this.Control["functionsListView"].ModifyCol()
			this.Control["functionsListView"].ModifyCol(2, "Center AutoHdr")

			first := false
		}
	}

	loadEditor(item) {
		local onKey := false
		local offKey := false
		local chosen

		switch item.Type, false {
			case k1WayToggleType:
				chosen := 1
				onKey := "On"
			case k2WayToggleType:
				chosen := 2
				onKey := "On"
				offKey := "Off"
			case kButtonType:
				chosen := 3
				onKey := "Push"
			case kDialType:
				chosen := 4
				onKey := "Increase"
				offKey := "Decrease"
			case kCustomType:
				chosen := 5
				onKey := "Call"
			default:
				throw "Unknown function type (" . item.Type . ") detected in FunctionsList.loadEditor..."
		}

		this.Control["functionTypeDropDown"].Choose(chosen)
		this.Control["functionNumberEdit"].Text := item.Number
		this.Control["functionOnHotkeysEdit"].Text := item.Hotkeys[onKey, true]
		this.Control["functionOnActionEdit"].Text := item.Actions[onKey, true]
		this.Control["functionOffHotkeysEdit"].Text := (offKey ? item.Hotkeys[offKey, true] : "")
		this.Control["functionOffActionEdit"].Text := (offKey ? item.Actions[offKey, true] : "")
	}

	clearEditor() {
		this.Control["functionTypeDropDown"].Choose(0)
		this.Control["functionNumberEdit"].Text := 0
		this.Control["functionOnHotkeysEdit"].Text := ""
		this.Control["functionOnActionEdit"].Text := ""
		this.Control["functionOffHotkeysEdit"].Text := ""
		this.Control["functionOffActionEdit"].Text := ""
	}

	buildItemFromEditor(isNew := false) {
		local functionType

		functionType := [false, k1WayToggleType, k2WayToggleType, kButtonType, kDialType, kCustomType][this.Control["functionTypeDropDown"].Value + 1]

		if (functionType && (this.Control["functionNumberEdit"].Text >= 0)) {
			if ((functionType != k2WayToggleType) && (functionType != kDialType)) {
				this.Control["functionOffHotkeysEdit"].Text := ""
				this.Control["functionOffActionEdit"].Text := ""
			}

			return Function.createFunction(ConfigurationItem.descriptor(functionType, this.Control["functionNumberEdit"].Text), false
										 , this.Control["functionOnHotkeysEdit"].Text, this.Control["functionOnActionEdit"].Text
										 , this.Control["functionOffHotkeysEdit"].Text, this.Control["functionOffActionEdit"].Text)
		}
		else {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
	}

	addItem() {
		local function := this.buildItemFromEditor(true)

		if function
			if this.Functions.Has(function.Descriptor) {
				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("This function already exists - please use different values..."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
			else {
				this.Functions[function.Descriptor] := function

				super.addItem()

				this.selectItem(inList(this.ItemList, function))
			}
	}

	deleteItem() {
		this.Functions.Delete(this.ItemList[this.CurrentItem].Descriptor)

		super.deleteItem()
	}

	updateItem() {
		local function := this.buildItemFromEditor()

		if function
			if (function.Descriptor != this.ItemList[this.CurrentItem].Descriptor) {
				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("The type and number of an existing function may not be changed..."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				return false
			}
			else {
				this.Functions[function.Descriptor] := function

				return super.updateItem()
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Controller"), ControllerConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerConfigurator()