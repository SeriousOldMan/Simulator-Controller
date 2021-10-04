;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Configuration Plugin ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\ButtonBoxEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kEmptySpaceDescriptor = "Button;" . kButtonBoxImagesDirectory . "Empty.png;52 x 52"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerConfigurator                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerConfigurator extends ConfigurationItem {
	iEditor := false
	
	iButtonBoxesList := false
	iFunctionsist := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	__New(editor, configuration) {
		this.iEditor := editor
		
		this.iButtonBoxesList := new ButtonBoxesList(configuration)
		this.iFunctionsList := new FunctionsList(configuration)
		
		base.__New(configuration)
		
		ControllerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		this.iButtonBoxesList.createGui(editor, x, y, width, height)
		this.iFunctionsList.createGui(editor, x, y, width, height)
		
		Gui %window%:Add, Button, x16 y490 w100 h23 gtoggleTriggerDetector, % translate("Trigger...")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		this.iButtonBoxesList.saveToConfiguration(configuration)
		this.iFunctionsList.saveToConfiguration(configuration)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxesList                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global buttonBoxesListBox := "|"

global buttonBoxEdit = ""
global buttonBoxLayoutDropDown = 0
global openButtonBoxEditorButton

global buttonBoxUpButton
global buttonBoxDownButton

global buttonBoxAddButton
global buttonBoxDeleteButton
global buttonBoxUpdateButton
		
class ButtonBoxesList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		ButtonBoxesList.Instance := this
	}
					
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, -Theme x16 y80 w457 h115, % translate("Button Boxes")
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Add, ListBox, x24 y99 w194 h96 HwndbuttonBoxesListBoxHandle VbuttonBoxesListBox glistEvent, %buttonBoxesListBox%
		
		Gui %window%:Add, Edit, x224 y99 w104 h21 VbuttonBoxEdit, %buttonBoxEdit%
		Gui %window%:Add, DropDownList, x330 y99 w108 Choose%buttonBoxLayoutDropDown% VbuttonBoxLayoutDropDown, % values2String("|", this.computeLayoutChoices()*)
		Gui %window%:Add, Button, x440 y98 w23 h23 gopenButtonBoxEditor VopenButtonBoxEditorButton, % translate("...")
		
		Gui %window%:Add, Button, x385 y124 w38 h23 Disabled VbuttonBoxUpButton gupItem, % translate("Up")
		Gui %window%:Add, Button, x425 y124 w38 h23 Disabled VbuttonBoxDownButton gdownItem, % translate("Down")
		
		Gui %window%:Add, Button, x265 y164 w46 h23 VbuttonBoxAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x313 y164 w50 h23 Disabled VbuttonBoxDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x409 y164 w55 h23 Disabled VbuttonBoxUpdateButton gupdateItem, % translate("Save")
		
		this.initializeList(buttonBoxesListBoxHandle, "buttonBoxesListBox", "buttonBoxAddButton", "buttonBoxDeleteButton", "buttonBoxUpdateButton"
						  , "buttonBoxUpButton", "buttonBoxDownButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		items := []
		
		for ignore, controller in string2Values("|", getConfigurationValue(configuration, "Controller Layouts", "Button Boxes", ""))
			items.Push(string2Values(":", controller))
			
		this.ItemList := items
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		controller := []
		
		for ignore, item in this.ItemList
			controller.Push(values2String(":", item*))
		
		setConfigurationValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", controller*))	
	}
	
	clickEvent(line, count) {
		GuiControlGet buttonBoxesListBox
					
		index := false
		
		for ignore, candidate in this.ItemList
			if (buttonBoxesListBox = candidate[1]) {
				index := A_Index
			
				break
			}
		
		this.openEditor(index)
	}
	
	processListEvent() {
		return true
	}
	
	loadList(items) {
		controller := []
		
		for ignore, item in this.ItemList
			controller.Push(item[1])
		
		buttonBoxesListBox := values2String("|", controller*)
	
		GuiControl, , buttonBoxesListBox, % "|" . buttonBoxesListBox
	}
	
	selectItem(itemNumber) {
		this.CurrentItem := itemNumber
		
		if itemNumber
			GuiControl Choose, buttonBoxesListBox, %itemNumber%
		
		this.updateState()
	}
	
	loadEditor(item) {
		buttonBoxEdit := item[1]
		buttonBoxLayoutDropDown := item[2]
			
		GuiControl Text, buttonBoxEdit, %buttonBoxEdit%
		
		try {
			GuiControl Choose, buttonBoxLayoutDropDown, %buttonBoxLayoutDropDown%
		}
		catch exception {
			GuiControl Choose, buttonBoxLayoutDropDown, 0
		}
	}
	
	clearEditor() {
		this.loadEditor(Array("", ""))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet buttonBoxEdit
		GuiControlGet buttonBoxLayoutDropDown
		
		if ((buttonBoxEdit = "") || (buttonBoxLayoutDropDown = "") || !buttonBoxLayoutDropDown) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		else
			return Array(buttonBoxEdit, buttonBoxLayoutDropDown)
	}
	
	computeLayoutChoices(configuration := false) {
		if !configuration
			configuration := readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))
		
		layouts := []
		
		for descriptor, definition in getConfigurationSectionValues(configuration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			
			if !inList(layouts, descriptor[1])
				layouts.Push(descriptor[1])
		}
		
		return layouts
	}
	
	openButtonBoxEditor() {
		GuiControlGet buttonBoxEdit
		GuiControlGet buttonBoxLayoutDropDown
		
		; ConfigurationEditor.Instance.hide()
		
		window := ConfigurationEditor.Instance.Window
		
		Gui BBE:+Owner%window%
		Gui %window%:+Disabled
		
		result := (new ButtonBoxEditor(buttonBoxLayoutDropDown, readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)))).editButtonBox()
		
		if result
			writeConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory), result)
		
		window := ConfigurationEditor.Instance.Window
		
		Gui %window%:Default
		
		choices := this.computeLayoutChoices(result)
		
		GuiControl Text, buttonBoxLayoutDropDown, % "|" . values2String("|", choices*)
		
		if inList(choices, buttonBoxLayoutDropDown)
			GuiControl Choose, buttonBoxLayoutDropDown, %buttonBoxLayoutDropDown%
		else
			GuiControl Choose, buttonBoxLayoutDropDown, %A_Space%
		
		; ConfigurationEditor.Instance.show()
		Gui %window%:-Disabled
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
		window := editor.Window
		
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
		base.loadFromConfiguration(configuration)
	
		for descriptor, arguments in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
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
		base.saveToConfiguration(configuration)
		
		for ignore, theFunction in this.ItemList
			theFunction.saveToConfiguration(configuration)
	}
	
	updateState() {
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
			functionOffHotkeysEdit := ""
			functionOffActionEdit := ""
			
			GuiControl Text, functionOffHotkeysEdit, %functionOffHotkeysEdit%
			GuiControl Text, functionOffActionEdit, %functionOffActionEdit%
			
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
		static first := true
		
		Gui ListView, % this.ListHandle
	
		this.ItemList := Array()
		
		LV_Delete()
		
		round := 0
		
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
		functionType := item.Type
		onKey := false
		offKey := false
		
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
				Throw "Unknown function type (" . functionType . ") detected in FunctionsList.loadEditor..."
		}
		
		functionNumberEdit := item.Number
		functionOnHotkeysEdit := item.Hotkeys[onKey, true]
		functionOnActionEdit := item.Actions[onKey, true]
		
		if offKey {
			functionOffHotkeysEdit := item.Hotkeys[offKey, true]
			functionOffActionEdit := item.Actions[offKey, true]
		}
		
		GuiControl Choose, functionTypeDropDown, %functionTypeDropDown%
		GuiControl Text, functionNumberEdit, %functionNumberEdit%
		GuiControl Text, functionOnHotkeysEdit, %functionOnHotkeysEdit%
		GuiControl Text, functionOnActionEdit, %functionOnActionEdit%
		GuiControl Text, functionOffHotkeysEdit, %functionOffHotkeysEdit%
		GuiControl Text, functionOffActionEdit, %functionOffActionEdit%
	}
	
	clearEditor() {
		functionTypeDropDown := 0
		functionNumberEdit := 0
		functionOnHotkeysEdit := ""
		functionOnActionEdit := ""
		functionOffHotkeysEdit := ""
		functionOffActionEdit := ""
		
		GuiControl Choose, functionTypeDropDown, %functionTypeDropDown%
		GuiControl Text, functionNumberEdit, %functionNumberEdit%
		GuiControl Text, functionOnHotkeysEdit, %functionOnHotkeysEdit%
		GuiControl Text, functionOnActionEdit, %functionOnActionEdit%
		GuiControl Text, functionOffHotkeysEdit, %functionOffHotkeysEdit%
		GuiControl Text, functionOffActionEdit, %functionOffActionEdit%
	}
	
	buildItemFromEditor(isNew := false) {
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

openButtonBoxEditor() {
	ButtonBoxesList.Instance.openButtonBoxEditor()
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
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Controller"), new ControllerConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerConfigurator()