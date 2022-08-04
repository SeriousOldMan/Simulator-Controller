;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Configuration Plugin ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\ControllerEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerConfigurator extends ConfigurationItem {
	iEditor := false

	iControllerList := false
	iFunctionsist := false

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	__New(editor, configuration) {
		this.iEditor := editor

		this.iControllerList := new ControllerList(configuration)
		this.iFunctionsList := new FunctionsList(configuration)

		base.__New(configuration)

		ControllerConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		this.iControllerList.createGui(editor, x, y, width, height)
		this.iFunctionsList.createGui(editor, x, y, width, height)

		Gui %window%:Add, Button, x16 y490 w100 h23 gtoggleTriggerDetector, % translate("Trigger...")
	}

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)

		this.iControllerList.saveToConfiguration(configuration)
		this.iFunctionsList.saveToConfiguration(configuration)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerList                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global controllerListBox := "|"

global controllerEdit = ""
global controllerLayoutDropDown = 0
global openControllerEditorButton

global controllerUpButton
global controllerDownButton

global controllerAddButton
global controllerDeleteButton
global controllerUpdateButton

class ControllerList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)

		ControllerList.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 y80 w457 h115, % translate("Controller")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Add, ListBox, x24 y99 w194 h96 HwndcontrollerListBoxHandle VcontrollerListBox glistEvent, %controllerListBox%

		Gui %window%:Add, Edit, x224 y99 w104 h21 VcontrollerEdit, %controllerEdit%
		Gui %window%:Add, DropDownList, x330 y99 w108 Choose%controllerLayoutDropDown% VcontrollerLayoutDropDown, % values2String("|", this.computeLayoutChoices()*)
		Gui %window%:Add, Button, x440 y98 w23 h23 gopenControllerEditor VopenControllerEditorButton, % translate("...")

		Gui %window%:Add, Button, x385 y124 w38 h23 Disabled VcontrollerUpButton gupItem, % translate("Up")
		Gui %window%:Add, Button, x425 y124 w38 h23 Disabled VcontrollerDownButton gdownItem, % translate("Down")

		Gui %window%:Add, Button, x265 y164 w46 h23 VcontrollerAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x313 y164 w50 h23 Disabled VcontrollerDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x409 y164 w55 h23 Disabled VcontrollerUpdateButton gupdateItem, % translate("Save")

		this.initializeList(controllerListBoxHandle, "controllerListBox", "controllerAddButton", "controllerDeleteButton", "controllerUpdateButton"
						  , "controllerUpButton", "controllerDownButton")
	}

	loadFromConfiguration(configuration) {
		local items := []
		local ignore, controller

		base.loadFromConfiguration(configuration)

		for ignore, controller in string2Values("|", getConfigurationValue(configuration, "Controller Layouts", "Button Boxes", ""))
			items.Push(string2Values(":", controller))

		for ignore, controller in string2Values("|", getConfigurationValue(configuration, "Controller Layouts", "Stream Decks", ""))
			items.Push(string2Values(":", controller))

		this.ItemList := items
	}

	saveToConfiguration(configuration) {
		local bbController := []
		local sdController := []
		local sdConfiguration := readConfiguration(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))
		local ignore, item

		base.saveToConfiguration(configuration)

		for ignore, item in this.ItemList
			if getConfigurationValue(sdConfiguration, "Layouts", item[2] . ".Layout", false)
				sdController.Push(values2String(":", item*))
			else
				bbController.Push(values2String(":", item*))

		setConfigurationValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", bbController*))
		setConfigurationValue(configuration, "Controller Layouts", "Stream Decks", values2String("|", sdController*))
	}

	clickEvent(line, count) {
		local index := false
		local ignore, candidate

		GuiControlGet controllerListBox

		for ignore, candidate in this.ItemList
			if (controllerListBox = candidate[1]) {
				index := A_Index

				break
			}

		this.openEditor(index)
	}

	processListEvent() {
		return true
	}

	loadList(items) {
		local controller := []
		local ignore, item

		for ignore, item in this.ItemList
			controller.Push(item[1])

		GuiControl, , controllerListBox, % "|" . values2String("|", controller*)
	}

	selectItem(itemNumber) {
		this.CurrentItem := itemNumber

		if itemNumber
			GuiControl Choose, controllerListBox, %itemNumber%

		this.updateState()
	}

	loadEditor(item) {
		GuiControl Text, controllerEdit, % item[1]

		try {
			GuiControl Choose, controllerLayoutDropDown, % item[2]
		}
		catch exception {
			GuiControl Choose, controllerLayoutDropDown, 0
		}
	}

	clearEditor() {
		this.loadEditor(Array("", ""))
	}

	buildItemFromEditor(isNew := false) {
		local title

		GuiControlGet controllerEdit
		GuiControlGet controllerLayoutDropDown

		if ((controllerEdit = "") || (controllerLayoutDropDown = "") || !controllerLayoutDropDown) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else
			return Array(controllerEdit, controllerLayoutDropDown)
	}

	computeLayoutChoices(bbConfiguration := false, sdConfiguration := false) {
		local layouts := []
		local descriptor, definition

		if !bbConfiguration
			bbConfiguration := readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))

		if !sdConfiguration
			sdConfiguration := readConfiguration(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))


		for descriptor, definition in getConfigurationSectionValues(bbConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if !inList(layouts, descriptor[1])
				layouts.Push(descriptor[1])
		}

		for descriptor, definition in getConfigurationSectionValues(sdConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if !inList(layouts, descriptor[1])
				layouts.Push(descriptor[1])
		}

		return layouts
	}

	openControllerEditor() {
		local window := ConfigurationEditor.Instance.Window
		local choices

		Gui %window%:Default

		GuiControlGet controllerEdit
		GuiControlGet controllerLayoutDropDown

		Gui CTRLE:+Owner%window%
		Gui %window%:+Disabled

		try {
			new ControllerEditor(controllerLayoutDropDown, ConfigurationEditor.Instance.Configuration).editController()

			Gui %window%:Default

			choices := this.computeLayoutChoices()

			GuiControl Text, controllerLayoutDropDown, % "|" . values2String("|", choices*)

			if inList(choices, controllerLayoutDropDown)
				GuiControl Choose, controllerLayoutDropDown, %controllerLayoutDropDown%
			else
				GuiControl Choose, controllerLayoutDropDown, %A_Space%
		}
		finally {
			Gui %window%:-Disabled
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; FunctionsList                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global functionsListView

global functionTypeDropDown = 0
global functionNumberEdit = ""
global functionOnHotkeysEdit = ""
global functionOnActionEdit = ""
global functionOffHotkeysEdit = ""
global functionOffActionEdit = ""

global functionAddButton
global functionDeleteButton
global functionUpdateButton

class FunctionsList extends ConfigurationItemList {
	iFunctions := {}

	__New(configuration) {
		base.__New(configuration)

		FunctionsList.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		Gui %window%:Add, ListView, x16 y200 w457 h150 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndfunctionsListViewHandle VfunctionsListView glistEvent
						, % values2String("|", map(["Function", "Number", "Hotkey(s) & Action(s)"], "translate")*)

		Gui %window%:Add, Text, x16 y360 w86 h23 +0x200, % translate("Function")
		Gui %window%:Add, DropDownList, x124 y360 w91 AltSubmit Choose%functionTypeDropDown% VfunctionTypeDropDown gupdateFunctionEditorState
								, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Rotary", "Custom"], "translate")*)
		Gui %window%:Add, Edit, x220 y360 w40 h21 Number VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x260 y360 w17 h21, 1

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x16 y392 w457 h91, % translate("Bindings")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x124 y401 w160 h22 +0x200 +Center, % translate("On or Increase")
		Gui %window%:Add, Text, x303 y401 w160 h22 +0x200 +Center, % translate("Off or Decrease")

		Gui %window%:Font, Underline, Arial

		Gui %window%:Add, Text, x24 y424 w83 h23 +0x200 cBlue gopenHotkeysDocumentation, % translate("Hotkey(s)")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Edit, x124 y424 w160 h21 VfunctionOnHotkeysEdit, %functionOnHotkeysEdit%
		Gui %window%:Add, Edit, x303 y424 w160 h21 VfunctionOffHotkeysEdit, %functionOffHotkeysEdit%

		Gui %window%:Font, Underline, Arial

		Gui %window%:Add, Text, x24 y450 w83 h23 cBlue gopenActionsDocumentation, % translate("Action (optional)")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Edit, x124 y448 w160 h21 VfunctionOnActionEdit, %functionOnActionEdit%
		Gui %window%:Add, Edit, x303 y448 w160 h21 VfunctionOffActionEdit, %functionOffActionEdit%

		Gui %window%:Add, Button, x264 y490 w46 h23 VfunctionAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VfunctionDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VfunctionUpdateButton gupdateItem, % translate("&Save")

		this.initializeList(functionsListViewHandle, "functionsListView", "functionAddButton", "functionDeleteButton", "functionUpdateButton")
	}

	loadFromConfiguration(configuration) {
		local descriptor, ignore, func

		base.loadFromConfiguration(configuration)

		for descriptor, ignore in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			descriptor := ConfigurationItem.descriptor(descriptor[1], descriptor[2])

			if !this.iFunctions.HasKey(descriptor) {
				func := Function.createFunction(descriptor, configuration)

				this.iFunctions[descriptor] := func
				this.ItemList.Push(func)
			}
		}
	}

	saveToConfiguration(configuration) {
		local ignore, theFunction

		base.saveToConfiguration(configuration)

		for ignore, theFunction in this.ItemList
			theFunction.saveToConfiguration(configuration)
	}

	updateState() {
		local functionType

		base.updateState()

		GuiControlGet functionType, , functionTypeDropDown

		if (functionType < 5) {
			GuiControl Disable, functionOnActionEdit
			GuiControl Disable, functionOffActionEdit
		}
		else {
			GuiControl Enable, functionOnActionEdit
			GuiControl Enable, functionOffActionEdit
		}

		if ((functionType == 2) || (functionType == 4))
			GuiControl Enable, functionOffHotkeysEdit
		else {
			GuiControl Text, functionOffHotkeysEdit, % ""
			GuiControl Text, functionOffActionEdit, % ""

			GuiControl Disable, functionOffHotkeysEdit
			GuiControl Disable, functionOffActionEdit
		}
	}

	computeFunctionType(functionType) {
		return kControlTypes[functionType]
	}

	computeHotkeysAndActionText(hotkeys, action) {
		if (hotKeys && (hotkeys != ""))
			return hotkeys . ((action == "") ? "" : (" => " . action))
		else
			return ""
	}

	loadList(items) {
		local round := 0
		local qualifier, theFunction, hotkeysAndActions, index, trigger, nextHKA

		static first := true

		Gui ListView, % this.ListHandle

		this.ItemList := Array()

		LV_Delete()

		Loop {
			if (++round > 2)
				break

			for qualifier, theFunction in this.iFunctions
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

					LV_Add("", translate(this.computeFunctionType(theFunction.Type)), theFunction.Number, hotkeysAndActions)

					this.ItemList.Push(theFunction)
				}
		}

		if first {
			LV_ModifyCol()
			LV_ModifyCol(2, "Center AutoHdr")

			first := false
		}
	}

	loadEditor(item) {
		local onKey := false
		local offKey := false

		switch item.Type {
			case k1WayToggleType:
				functionTypeDropDown := 1
				onKey := "On"
			case k2WayToggleType:
				functionTypeDropDown := 2
				onKey := "On"
				offKey := "Off"
			case kButtonType:
				functionTypeDropDown := 3
				onKey := "Push"
			case kDialType:
				functionTypeDropDown := 4
				onKey := "Increase"
				offKey := "Decrease"
			case kCustomType:
				functionTypeDropDown := 5
				onKey := "Call"
			default:
				Throw "Unknown function type (" . item.Type . ") detected in FunctionsList.loadEditor..."
		}

		GuiControl Choose, functionTypeDropDown, %functionTypeDropDown%
		GuiControl Text, functionNumberEdit, % item.Number
		GuiControl Text, functionOnHotkeysEdit, % item.Hotkeys[onKey, true]
		GuiControl Text, functionOnActionEdit, % item.Actions[onKey, true]
		GuiControl Text, functionOffHotkeysEdit, % (offKey ? item.Hotkeys[offKey, true] : "")
		GuiControl Text, functionOffActionEdit, % (offKey ? item.Actions[offKey, true] : "")
	}

	clearEditor() {
		GuiControl Choose, functionTypeDropDown, 0
		GuiControl Text, functionNumberEdit, 0
		GuiControl Text, functionOnHotkeysEdit, % ""
		GuiControl Text, functionOnActionEdit, % ""
		GuiControl Text, functionOffHotkeysEdit, % ""
		GuiControl Text, functionOffActionEdit, % ""
	}

	buildItemFromEditor(isNew := false) {
		local functionType, title

		GuiControlGet functionTypeDropDown
		GuiControlGet functionNumberEdit
		GuiControlGet functionOnHotkeysEdit
		GuiControlGet functionOnActionEdit
		GuiControlGet functionOffHotkeysEdit
		GuiControlGet functionOffActionEdit

		functionType := [false, k1WayToggleType, k2WayToggleType, kButtonType, kDialType, kCustomType][functionTypeDropDown + 1]

		if (functionType && (functionNumberEdit >= 0)) {
			if ((functionType != k2WayToggleType) && (functionType != kDialType)) {
				functionOffHotkeysEdit := ""
				functionOffActionEdit := ""
			}

			return Function.createFunction(ConfigurationItem.descriptor(functionType, functionNumberEdit), false, functionOnHotkeysEdit, functionOnActionEdit, functionOffHotkeysEdit, functionOffActionEdit)
		}
		else {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
	}

	addItem() {
		local function := this.buildItemFromEditor(true)
		local title

		if function
			if this.iFunctions.HasKey(function.Descriptor) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("This function already exists - please use different values...")
				OnMessage(0x44, "")
			}
			else {
				this.iFunctions[function.Descriptor] := function

				base.addItem()

				this.selectItem(inList(this.ItemList, function))
			}
	}

	deleteItem() {
		this.iFunctions.Delete(this.ItemList[this.CurrentItem].Descriptor)

		base.deleteItem()
	}

	updateItem() {
		local function := this.buildItemFromEditor()
		local title

		if function
			if (function.Descriptor != this.ItemList[this.CurrentItem].Descriptor) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("The type and number of an existing function may not be changed...")
				OnMessage(0x44, "")
			}
			else {
				this.iFunctions[function.Descriptor] := function

				base.updateItem()
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

toggleTriggerDetector(callback := false) {
	protectionOn()

	try {
		ConfigurationEditor.Instance.toggleTriggerDetector()
	}
	finally {
		protectionOff()
	}
}

openControllerEditor() {
	ControllerList.Instance.openControllerEditor()
}

updateFunctionEditorState() {
	protectionOn()

	try {
		ConfigurationItemList.getList("functionsListView").updateState()
	}
	finally {
		protectionOff()
	}
}

openHotkeysDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys
}

openActionsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions
}

initializeControllerConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Controller"), new ControllerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerConfigurator()