;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Configurator         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	iButtonBoxesList := false
	iFunctionsist := false
	
	__New(configuration) {
		this.iButtonBoxesList := new ButtonBoxesList(configuration)
		this.iFunctionsList := new FunctionsList(configuration)
		
		base.__New(configuration)
		
		ControllerConfigurator.Instance := this
	}
	
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		this.iButtonBoxesList.createGui(editor, x, y, width, height)
		this.iFunctionsList.createGui(editor, x, y, width, height)
		
		Gui %window%:Add, Button, x16 y490 w100 h23 gtoggleKeyDetector, % translate("Key Detector...")
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
		
		Gui %window%:Add, GroupBox, x16 y80 w457 h115, % translate("Button Boxes")
		
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
			
		this.iItemsList := items
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		controller := []
		
		for ignore, item in this.iItemsList
			controller.Push(values2String(":", item*))
		
		setConfigurationValue(configuration, "Controller Layouts", "Button Boxes", values2String("|", controller*))	
	}
	
	loadList(items) {
		controller := []
		
		for ignore, item in this.iItemsList
			controller.Push(item[1])
		
		buttonBoxesListBox := values2String("|", controller*)
	
		GuiControl, , buttonBoxesListBox, % "|" . buttonBoxesListBox
	}
	
	selectItem(itemNumber) {
		this.iCurrentItemIndex := itemNumber
		
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
		
		ConfigurationEditor.Instance.hide()
		
		result := (new ButtonBoxesEditor(buttonBoxEdit, readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)))).editButtonBox()
		
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
		
		ConfigurationEditor.Instance.show()
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
								, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Dial", "Custom"], "translate")*)
		Gui %window%:Add, Edit, x220 y360 w40 h21 Number VfunctionNumberEdit, %functionNumberEdit%
		Gui %window%:Add, UpDown, x260 y360 w17 h21, 1
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y392 w457 h91, % translate("Bindings")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x124 y400 w160 h23 +0x200 +Center, % translate("On or Increase")
		Gui %window%:Add, Text, x303 y400 w160 h23 +0x200 +Center, % translate("Off or Decrease")
		
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
				this.iItemsList.Push(func)
			}
		}
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		for ignore, theFunction in this.iItemsList
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
		if (functionType == k1WayToggleType)
			return "1-way Toggle"
		else if (functionType == k2WayToggleType)
			return "2-way Toggle"
		else
			return functionType
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
	
		this.iItemsList := Array()
		
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
					
					this.iItemsList.Push(theFunction)
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
				
				this.selectItem(inList(this.iItemsList, function))
			}
	}
	
	deleteItem() {
		this.iFunctions.Delete(this.iItemsList[this.iCurrentItemIndex].Descriptor)
		
		base.deleteItem()
	}
	
	updateItem() {
		local function := this.buildItemFromEditor()
	
		if function
			if (function.Descriptor != this.iItemsList[this.iCurrentItemIndex].Descriptor) {
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

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxesEditor                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxesEditor extends ConfigurationItem {
	iControlsList := false
	iLabelsList := false
	iLayoutsList := false
	
	iName := ""
	iClosed := false
	
	iButtonBoxPreview := false
	iButtonBoxConfiguration := false
	
	iButtonBoxPreviewCenterX := 0
	iButtonBoxPreviewCenterY := 0
	
	ButtonBoxPreview[] {
		Get {
			return this.iButtonBoxPreview
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	ButtonBoxConfiguration[] {
		Get {
			return this.iButtonBoxConfiguration
		}
	}
	
	ButtonBoxPreviewCenterX[] {
		Get {
			return this.iButtonBoxPreviewCenterX
		}
	}
	
	ButtonBoxPreviewCenterY[] {
		Get {
			return this.iButtonBoxPreviewCenterY
		}
	}
	
	__New(name, configuration) {
		this.iName := name
		
		this.iButtonBoxConfiguration := readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))
		
		this.iControlsList := new ControlsList(this.iButtonBoxConfiguration)
		this.iLabelsList := new LabelsList(this.iButtonBoxConfiguration)
		this.iLayoutsList := new LayoutsList(this.iButtonBoxConfiguration)
		
		base.__New(configuration)
		
		ButtonBoxesEditor.Instance := this
		
		this.createGui(this.iButtonBoxConfiguration)
	}
	
	createGui(configuration) {
		Gui BBE:Default
	
		Gui BBE:-Border ; -Caption
		
		Gui BBE:Color, D0D0D0
		Gui BBE:Font, Bold, Arial

		Gui BBE:Add, Text, x0 w432 Center gmoveButtonBoxesEditor, % translate("Modular Simulator Controller System") 
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic Underline, Arial

		Gui BBE:Add, Text, x0 YP+20 w432 cBlue Center gopenButtonBoxesDocumentation, % translate("Button Box Layouts")
		
		this.iControlsList.createGui(configuration)
		this.iLabelsList.createGui(configuration)
		this.iLayoutsList.createGui(configuration)
		
		Gui BBE:Add, Text, x50 y615 w332 0x10
		
		Gui BBE:Add, Button, x130 y630 w80 h23 Default GsaveButtonBoxesEditor, % translate("Save")
		Gui BBE:Add, Button, x230 y630 w80 h23 GcancelButtonBoxesEditor, % translate("Cancel")
	}
	
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		this.iControlsList.saveToConfiguration(configuration, save)
		this.iLabelsList.saveToConfiguration(configuration, save)
		this.iLayoutsList.saveToConfiguration(configuration, save)
	}
		
	setButtonBoxPreviewPosition(centerX, centerY) {
		this.iButtonBoxPreviewCenterX := centerX
		this.iButtonBoxPreviewCenterY := centerY
	}
	
	editButtonBox() {
		Gui BBE:Show, AutoSize Center
		
		Loop
			Sleep 200
		until this.iClosed
		
		Gui BBE:Destroy
	}
	
	closeEditor(save) {
		if save {
			configuration := newConfiguration()
		
			this.saveToConfiguration(configuration)
			
			writeConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory), configuration)
		}
			
		this.saveButtonBox()
		
		if this.ButtonBoxPreview {
			this.ButtonBoxPreview.close()
			
			this.iButtonBoxPreview := false
		}
		
		this.iClosed := true
	}
	
	updateButtonBoxPreview(name) {
		configuration := newConfiguration()
		
		this.saveToConfiguration(configuration, false)
		
		this.iButtonBoxConfiguration := configuration
		
		oldPreview := this.ButtonBoxPreview
		
		if name {
			this.iButtonBoxPreview := new ButtonBoxPreview(this, name, configuration)
		
			this.ButtonBoxPreview.open()
		}
		else
			this.iButtonBoxPreview := false
		
		if oldPreview
			oldPreview.close()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControlsList                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global controlsListView := "|"

global controlNameEdit = ""
global controlTypeDropDown = 0
global imageFilePathEdit = ""
global imageWidthEdit = 0
global imageHeightEdit = 0

global controlAddButton
global controlDeleteButton
global controlUpdateButton
		
class ControlsList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		ControlsList.Instance := this
	}
					
	createGui(configuration) {
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic, Arial
		
		Gui BBE:Add, GroupBox, x8 y60 w424 h138, % translate("Controls")
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Add, ListView, x16 y79 w134 h108 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndcontrolsListViewHandle VcontrolsListView glistEvent
							 , % values2String("|", map(["Name", "Function", "Size"], "translate")*)
							
		Gui BBE:Add, Text, x164 y79 w80 h23 +0x200, % translate("Name")
		Gui BBE:Add, Edit, x214 y80 w101 h21 VcontrolNameEdit, %controlNameEdit%
		Gui BBE:Add, DropDownList, x321 y79 w105 AltSubmit Choose%controlTypeDropDown% VcontrolTypeDropDown, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Dial"], "translate")*)
		;426 400 
		Gui BBE:Add, Text, x164 y103 w80 h23 +0x200, % translate("Image")
		Gui BBE:Add, Edit, x214 y103 w186 h21 VimageFilePathEdit, %imageFilePathEdit%
		Gui BBE:Add, Button, x403 y103 w23 h23 gchooseImageFilePath, % translate("...")
		
		Gui BBE:Add, Text, x164 y127 w80 h23 +0x200, % translate("Size")
		Gui BBE:Add, Edit, x214 y127 w40 h21 Limit3 Number VimageWidthEdit, %imageWidthEdit%
		Gui BBE:Add, Text, x254 y127 w21 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x275 y127 w40 h21 Limit3 Number VimageHeightEdit, %imageHeightEdit%
		
		Gui BBE:Add, Button, x226 y164 w46 h23 VcontrolAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x275 y164 w50 h23 Disabled VcontrolDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x371 y164 w55 h23 Disabled VcontrolUpdateButton gupdateItem, % translate("Save")
		
		this.initializeList(controlsListViewHandle, "controlsListView", "controlAddButton", "controlDeleteButton", "controlUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		controls := []
		
		for name, definition in getConfigurationSectionValues(configuration, "Controls", Object())
			controls.Push(Array(name, string2Values(";", definition)*))
		
		this.iItemsList := controls
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		controls := {}
		
		for ignore, control in this.iItemsList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])
		
		setConfigurationSectionValues(configuration, "Controls", controls)	
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		this.iItemsList := items
		
		for ignore, control in items
			LV_Add("", control[1], control[2], control[4])
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			
			first := false
		}
		
		ButtonBoxesEditor.Instance.updateButtonBoxPreview(LayoutsList.Instance.CurrentButtonBox)
	}
	
	loadEditor(item) {
		controlNameEdit := item[1]
		imageFilePathEdit := item[3]
		
		size := string2Values("x", item[4])
		
		imageWidthEdit := size[1]
		imageHeightEdit := size[2]
			
		controlTypeDropDown := inList([k1WayToggleType, k2WayToggleType, kButtonType, kDialType], item[2])
		
		GuiControl Text, controlNameEdit, %controlNameEdit%
		GuiControl Choose, controlTypeDropDown, %controlTypeDropDown%
		GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
		GuiControl Text, imageWidthEdit, %imageWidthEdit%
		GuiControl Text, imageHeightEdit, %imageHeightEdit%
	}
	
	clearEditor() {
		this.loadEditor(Array("", "", "", ""))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet controlNameEdit
		GuiControlGet controlTypeDropDown
		GuiControlGet imageFilePathEdit
		GuiControlGet imageWidthEdit
		GuiControlGet imageHeightEdit
		
		if ((controlNameEdit = "") || !inList([1, 2, 3, 4], controlTypeDropDown) || (imageFilePathEdit = "")  || (imageWidthEdit = 0) || (imageHeightEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		else
			return Array(controlNameEdit, [k1WayToggleType, k2WayToggleType, kButtonType, kDialType][controlTypeDropDown], imageFilePathEdit, imageWidthEdit . " x " . imageHeightEdit)
	}
	
	getControls() {
		if ConfigurationEditor.Instance.AutoSave {
			if (this.iCurrentItemIndex != 0) {
				this.updateItem()
			}
		}
		
		controls := {}
		
		for ignore, control in this.iItemsList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])
		
		return controls
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LabelsList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global labelsListView := "|"

global labelNameEdit = ""
global labelWidthEdit = 0
global labelHeightEdit = 0

global labelAddButton
global labelDeleteButton
global labelUpdateButton
		
class LabelsList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		LabelsList.Instance := this
	}
					
	createGui(configuration) {
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic, Arial
		
		Gui BBE:Add, GroupBox, x8 y205 w424 h115, % translate("Labels")
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Add, ListView, x16 y224 w134 h84 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlabelsListViewHandle VlabelsListView glistEvent
							 , % values2String("|", map(["Name", "Size"], "translate")*)
							
		Gui BBE:Add, Text, x164 y224 w80 h23 +0x200, % translate("Name")
		Gui BBE:Add, Edit, x214 y225 w101 h21 VlabelNameEdit, %labelNameEdit%
		
		Gui BBE:Add, Text, x164 y248 w80 h23 +0x200, % translate("Size")
		Gui BBE:Add, Edit, x214 y248 w40 h21 Limit3 Number VlabelWidthEdit, %labelWidthEdit%
		Gui BBE:Add, Text, x254 y248 w21 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x275 y248 w40 h21 Limit3 Number VlabelHeightEdit, %labelHeightEdit%
		
		Gui BBE:Add, Button, x226 y285 w46 h23 VlabelAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x275 y285 w50 h23 Disabled VlabelDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x371 y285 w55 h23 Disabled VlabelUpdateButton gupdateItem, % translate("Save")
		
		this.initializeList(labelsListViewHandle, "labelsListView", "labelAddButton", "labelDeleteButton", "labelUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		labels := []
		
		for name, definition in getConfigurationSectionValues(configuration, "Labels", Object())
			labels.Push(Array(name, definition))
		
		this.iItemsList := labels
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		labels := {}
		
		for ignore, label in this.iItemsList
			labels[label[1]] := label[2]
		
		setConfigurationSectionValues(configuration, "Labels", labels)	
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		this.iItemsList := items
		
		for ignore, label in items
			LV_Add("", label[1], label[2])
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			
			first := false
		}
		
		ButtonBoxesEditor.Instance.updateButtonBoxPreview(LayoutsList.Instance.CurrentButtonBox)
	}
	
	loadEditor(item) {
		labelNameEdit := item[1]
		
		size := string2Values("x", item[2])
		
		labelWidthEdit := size[1]
		labelHeightEdit := size[2]
		
		GuiControl Text, labelNameEdit, %labelNameEdit%
		GuiControl Text, labelWidthEdit, %labelWidthEdit%
		GuiControl Text, labelHeightEdit, %labelHeightEdit%
	}
	
	clearEditor() {
		this.loadEditor(Array("", ""))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet labelNameEdit
		GuiControlGet labelWidthEdit
		GuiControlGet labelHeightEdit
		
		if ((labelNameEdit = "") || (labelWidthEdit = 0) || (labelHeightEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		else
			return Array(labelNameEdit, labelWidthEdit . " x " . labelHeightEdit)
	}
	
	getLabels() {
		if ConfigurationEditor.Instance.AutoSave {
			if (this.iCurrentItemIndex != 0) {
				this.updateItem()
			}
		}
		
		labels := {}
		
		for ignore, label in this.iItemsList
			labels[label[1]] := label[2]
		
		return labels
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LayoutsList                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global layoutsListView := "|"

global layoutNameEdit = ""

global layoutRowsEdit = ""
global layoutColumnsEdit = ""
global layoutRowMarginEdit = ""
global layoutColumnMarginEdit = ""
global layoutSidesMarginEdit = ""
global layoutBottomMarginEdit = ""

global layoutRowDropDown = 0
global layoutRowEdit = ""

global layoutAddButton
global layoutDeleteButton
global layoutUpdateButton
		
class LayoutsList extends ConfigurationItemList {
	iRowDefinitions := []
	iSelectedRow := false
	
	CurrentButtonBox[] {
		Get {
			return ((this.iCurrentItemIndex != 0) ? this.iItemsList[this.iCurrentItemIndex][1] : false)
		}
	}
	
	__New(configuration) {
		base.__New(configuration)
				 
		LayoutsList.Instance := this
	}

	createGui(configuration) {
		Gui BBE:Add, ListView, x8 y330 w424 h105 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlayoutsListViewHandle VlayoutsListView glistEvent
							 , % values2String("|", map(["Name", "Grid", "Margins", "Definition"], "translate")*)
		
		Gui BBE:Add, Text, x8 y445 w86 h23 +0x200, % translate("Name")
		Gui BBE:Add, Edit, x102 y445 w110 h21 VlayoutNameEdit, %layoutNameEdit%
		
		Gui BBE:Add, Text, x8 y469 w86 h23 +0x200, % translate("Layout")
		Gui BBE:Font, c505050 s7
		Gui BBE:Add, Text, x16 y490 w133 h21, % translate("(R x C, Margins)")
		Gui BBE:Font
		
		Gui BBE:Add, Edit, x102 y469 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutRowsEdit, %layoutRowsEdit%
		Gui BBE:Add, UpDown, x125 y469 w17 h21, 1
		Gui BBE:Add, Text, x147 y469 w20 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x172 y469 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutColumnsEdit, %layoutColumnsEdit%
		Gui BBE:Add, UpDown, x195 y469 w17 h21, 1
		
		Gui BBE:Font, c505050 s7
		
		Gui BBE:Add, Text, x242 y450 w40 h23 +0x200 Center, % translate("Row")
		Gui BBE:Add, Text, x292 y450 w40 h23 +0x200 Center, % translate("Column")
		Gui BBE:Add, Text, x342 y450 w40 h23 +0x200 Center, % translate("Sides")
		Gui BBE:Add, Text, x392 y450 w40 h23 +0x200 Center, % translate("Bottom")
		
		Gui BBE:Font
		
		Gui BBE:Add, Edit, x242 y469 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutRowMarginEdit, %layoutRowMarginEdit%
		Gui BBE:Add, Edit, x292 y469 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutColumnMarginEdit, %layoutColumnMarginEdit%
		Gui BBE:Add, Edit, x342 y469 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutSidesMarginEdit, %layoutSidesMarginEdit%
		Gui BBE:Add, Edit, x392 y469 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		Gui BBE:Add, DropDownList, x8 y510 w86 AltSubmit Choose0 gupdateLayoutRowEditor VlayoutRowDropDown, |
		
		Gui BBE:Add, Edit, x102 y510 w330 h50 Disabled VlayoutRowEdit, %layoutRowEdit%
		
		Gui BBE:Add, Button, x223 y575 w46 h23 VlayoutAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x271 y575 w50 h23 Disabled VlayoutDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x377 y575 w55 h23 Disabled VlayoutUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(layoutsListViewHandle, "layoutsListView", "layoutAddButton", "layoutDeleteButton", "layoutUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		layouts := {}
		
		for descriptor, definition in getConfigurationSectionValues(configuration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]
			
			if !layouts.HasKey(name)
				layouts[name] := Object()
			
			if (descriptor[2] = "Layout") {
				definition := string2Values(",", definition)
	
				rowMargin := ((definition.Length() > 1) ? definition[2] : ButtonBoxPreview.kRowMargin)
				columnMargin := ((definition.Length() > 2) ? definition[3] : ButtonBoxPreview.kColumnMargin)
				sidesMargin := ((definition.Length() > 3) ? definition[4] : ButtonBoxPreview.kSidesMargin)
				bottomMargin := ((definition.Length() > 4) ? definition[5] : ButtonBoxPreview.kBottomMargin)
				
				layouts[name]["Grid"] := definition[1]
				layouts[name]["Margins"] := Array(rowMargin, columnMargin, sidesMargin, bottomMargin)
			}
			else
				layouts[name][descriptor[2]] := definition
		}
		
		items := []
		
		for name, definition in layouts
			items.Push(Array(name, definition))
		
		this.iItemsList := items
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		for ignore, layout in this.iItemsList {
			grid := layout[2]["Grid"]
			
			setConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout")
								, grid . ", " . values2String(", ", layout[2]["Margins"]*))
								
			Loop % string2Values("x", grid)[1]
				setConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])
		}
	}
	
	loadList(items) {
		static first := true
		static inCall := false
		
		Gui ListView, % this.ListHandle
		
		LV_Delete()
		
		this.iItemsList := items
		
		for ignore, layout in items {
			grid := layout[2]["Grid"]
		
			definition := ""
			
			Loop % string2Values("x", grid)[1]
			{
				if (A_Index > 1)
					definition .= "; "
				
				definition .= (A_Index . ": " . layout[2][A_Index])
			}
			
			LV_Add("", layout[1], grid, values2String(", ", layout[2]["Margins"]*), definition)
		}
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			LV_ModifyCol(4, "AutoHdr")
			
			first := false
		}
		
		ButtonBoxesEditor.Instance.updateButtonBoxPreview(LayoutsList.Instance.CurrentButtonBox)
	}
	
	loadEditor(item) {
		layoutNameEdit := item[1]
		
		size := string2Values("x", item[2]["Grid"])
		
		layoutRowsEdit := size[1]
		layoutColumnsEdit := size[2]
		
		margins := item[2]["Margins"]
		
		layoutRowMarginEdit := margins[1]
		layoutColumnMarginEdit := margins[2]
		layoutSidesMarginEdit := margins[3]
		layoutBottomMarginEdit := margins[4]
		
		GuiControl Text, layoutNameEdit, %layoutNameEdit%
		GuiControl Text, layoutRowsEdit, %layoutRowsEdit%
		GuiControl Text, layoutColumnsEdit, %layoutColumnsEdit%
		GuiControl Text, layoutRowMarginEdit, %layoutRowMarginEdit%
		GuiControl Text, layoutColumnMarginEdit, %layoutColumnMarginEdit%
		GuiControl Text, layoutSidesMarginEdit, %layoutSidesMarginEdit%
		GuiControl Text, layoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		choices := []
		rowDefinitions := []
		
		Loop %layoutRowsEdit% {
			choices.Push(translate("Row ") . A_Index)
		
			rowDefinitions.Push(item[2][A_Index])
		}
		
		this.iRowDefinitions := rowDefinitions
		
		GuiControl Text, layoutRowDropDown, % "|" . values2String("|", choices*)
		
		if (choices.Length() > 0) {
			GuiControl Choose, layoutRowDropDown, 1
			
			layoutRowEdit := (rowDefinitions.HasKey(1) ? rowDefinitions[1] : "")
			
			this.iSelectedRow := 1
		}
		else {
			GuiControl Choose, layoutRowDropDown, 0
		
			layoutRowEdit := ""
			
			this.iSelectedRow := false
		}
			
		GuiControl Text, layoutRowEdit, %layoutRowEdit%
		
		preview := ButtonBoxesEditor.Instance.ButtonBoxPreview
		
		if ((this.CurrentButtonBox != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ButtonBoxesEditor.Instance.updateButtonBoxPreview(layoutNameEdit)
	}
	
	addItem() {
		base.addItem()
		
		GuiControl Text, layoutRowEdit, %layoutRowEdit%
		
		preview := ButtonBoxesEditor.Instance.ButtonBoxPreview
		
		if ((this.CurrentButtonBox != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ButtonBoxesEditor.Instance.updateButtonBoxPreview(this.CurrentButtonBox)
	}
	
	clearEditor() {
		this.loadEditor(Array("", {Grid: "0x0", Margins: [0,0,0,0]}))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet layoutNameEdit
		GuiControlGet layoutRowsEdit
		GuiControlGet layoutColumnsEdit
		GuiControlGet layoutRowMarginEdit
		GuiControlGet layoutColumnMarginEdit
		GuiControlGet layoutSidesMarginEdit
		GuiControlGet layoutBottomMarginEdit
		
		GuiControlGet layoutRowDropDown
		GuiControlGet layoutRowEdit
		
		if ((layoutNameEdit = "") || (layoutRowsEdit = 0) || (layoutColumnsEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		else {
			if (layoutRowDropDown > 0)
				this.iRowDefinitions[layoutRowDropDown] := layoutRowEdit
			
			layout := {Grid: layoutRowsEdit . " x " . layoutColumnsEdit
					 , Margins: Array(layoutRowMarginEdit, layoutColumnMarginEdit, layoutSidesMarginEdit, layoutBottomMarginEdit)}
			
			Loop % this.iRowDefinitions.Length()
				layout[A_Index] := this.iRowDefinitions[A_Index]
				
			return Array(layoutNameEdit, layout)
		}
	}
	
	updateLayoutRowEditor(save := true) {
		Gui BBE:Default
		
		GuiControlGet layoutRowsEdit
		GuiControlGet layoutRowDropDown
		GuiControlGet layoutRowEdit
		
		if (save && (this.iSelectedRow > 0))
			this.iRowDefinitions[this.iSelectedRow] := layoutRowEdit
			
		rows := this.iRowDefinitions.Length()
		changed := false
		
		if (layoutRowsEdit > rows) {
			Loop % layoutRowsEdit - rows
				this.iRowDefinitions.Push("")
			
			changed := true
		}
		else if (layoutRowsEdit < rows) {
			this.iRowDefinitions.RemoveAt(layoutRowsEdit + 1, rows - layoutRowsEdit)
			
			changed := true
		}
		
		Loop %layoutRowsEdit%
			this.iRowDefinitions[A_Index] := values2String(";", this.getRowDefinition(A_Index)*)
		
		if (layoutRowDropDown > 0) {
			layoutRowEdit := ((this.iRowDefinitions.Length() >= layoutRowDropDown) ? this.iRowDefinitions[layoutRowDropDown] : "")
			
			this.iSelectedRow := layoutRowDropDown
			
			GuiControl Text, layoutRowEdit, %layoutRowEdit%
		}

		if changed {
			choices := []
		
			Loop %layoutRowsEdit%
				choices.Push(translate("Row ") . A_Index)
		
			GuiControl Text, layoutRowDropDown, % "|" . values2String("|", choices*)
			
			if (layoutRowsEdit > 0) {
				layoutRowDropDown := 1
				
				GuiControl Choose, layoutRowDropDown, 1
				
				layoutRowEdit := this.iRowDefinitions[1]
			}
			else {
				layoutRowDropDown := 0
				
				GuiControl Choose, layoutRowDropDown, 0
				
				layoutRowEdit := ""
			}

			this.iSelectedRow := layoutRowDropDown
			
			GuiControl Text, layoutRowEdit, %layoutRowEdit%
		}
		
		if (save && ConfigurationEditor.Instance.AutoSave) {
			if (this.iCurrentItemIndex != 0) {
				this.updateItem()
			}
		}
	}
	
	getRowDefinition(row) {
		rowDefinition := string2Values(";", this.iRowDefinitions[row])
		
		GuiControlGet layoutColumnsEdit
		
		if (rowDefinition.Length() > layoutColumnsEdit)
			rowDefinition.RemoveAt(layoutColumnsEdit + 1, rowDefinition.Length() - layoutColumnsEdit)
		else
			Loop % layoutColumnsEdit - rowDefinition.Length()
				rowDefinition.Push("")
		
		return rowDefinition
	}
	
	setRowDefinition(row, rowDefinition) {
		this.iRowDefinitions[row] := values2String(";", rowDefinition*)
		
		this.updateLayoutRowEditor(false)
		
		this.updateItem()
		
		ButtonBoxesEditor.Instance.updateButtonBoxPreview(this.CurrentButtonBox)
	}
	
	changeControl(row, column, control, number := false) {
		rowDefinition := this.getRowDefinition(row)
		
		definition := string2Values(",", rowDefinition[column])
		
		if (control = "__Number__") {
			if !number {
				title := translate("Function Number")
				prompt := translate("Please enter a controller function number:")
				number := ConfigurationItem.splitDescriptor(definition[1])[2]
				locale := ((getLanguage() = "en") ? "" : "Locale")
				
				InputBox number, %title%, %prompt%, , 200, 150, , , %locale%, , %number%
			
				if ErrorLevel
					return
			}
			
			if (definition.Length() = 1)
				definition := ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number)
			else
				definition := (ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number) . "," . definition[2])
		}
		else if control {
			if (definition.Length() = 0)
				definition := ConfigurationItem.descriptor(control, 1)
			else if (definition.Length() = 1)
				definition := ConfigurationItem.descriptor(control, ConfigurationItem.splitDescriptor(definition[1])[2])
			else
				definition := (ConfigurationItem.descriptor(control, ConfigurationItem.splitDescriptor(definition[1])[2]) . "," . definition[2])
		}
		else
			definition := ""
		
		rowDefinition[column] := definition
		
		this.setRowDefinition(row, rowDefinition)
	}
	
	changeLabel(row, column, label) {
		rowDefinition := this.getRowDefinition(row)
		
		definition := string2Values(",", rowDefinition[column])
		
		if (definition.Length() = 0)
			definition := (label ? ("," . label) : "")
		else if (definition.Length() >= 1)
			definition := (definition[1] . (label ? ("," . label) : ""))
		
		rowDefinition[column] := definition
		
		this.setRowDefinition(row, rowDefinition)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxPreview                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxPreview extends ConfigurationItem {
	static kHeaderHeight := 70
	static kLabelMargin := 5
	
	static kRowMargin := 20
	static kColumnMargin := 40
	
	static kSidesMargin := 20
	static kBottomMargin := 15
	
	static sCurrentWindow := 0
	
	iEditor := false
	iName := ""
	
	iWindow := false
	
	iWidth := 0
	iHeight := 0
	
	iRows := 0
	iColumns := 0
	iRowMargin := this.kRowMargin
	iColumnMargin := this.kColumnMargin
	iSidesMargin := this.kSidesMargin
	iBottomMargin := this.kBottomMargin
	
	iRowDefinitions := []
	iControls := {}
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Window[] {
		Get {
			return this.iWindow
		}
	}
	
	CurrentWindow[] {
		Get {
			return ("BBP" . ButtonBoxPreview.sCurrentWindow)
		}
	}
	
	Width[] {
		Get {
			return this.iWidth
		}
	}
	
	Height[] {
		Get {
			return this.iHeight
		}
	}
	
	Rows[] {
		Get {
			return this.iRows
		}
	}
	
	Columns[] {
		Get {
			return this.iColumns
		}
	}
	
	RowMargin[] {
		Get {
			return this.iRowMargin
		}
	}
	
	ColumnMargin[] {
		Get {
			return this.iColumnMargin
		}
	}
	
	SidesMargin[] {
		Get {
			return this.iSidesMargin
		}
	}
	
	BottomMargin[] {
		Get {
			return this.iBottomMargin
		}
	}
	
	RowDefinitions[row := false] {
		Get {
			if row
				return this.iRowDefinitions[row]
			else
				return this.iRowDefinitions
		}
	}
	
	__New(editor, name, configuration) {
		this.iEditor := editor
		this.iName := name
		
		ButtonBoxPreview.sCurrentWindow += 1
		
		this.iWindow := this.CurrentWindow
		
		base.__New(configuration)
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		local function
		
		rowHeights := false
		columnWidths := false
		
		this.computeLayout(rowHeights, columnWidths)
		
		height := 0
		Loop % rowHeights.Length()
			height += rowHeights[A_Index]
		
		width := 0
		Loop % columnWidths.Length()
			width += columnWidths[A_Index]
		
		height += ((rowHeights.Length() - 1) * this.RowMargin) + this.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length() - 1) * this.ColumnMargin) + (2 * this.SidesMargin)
		
		window := this.Window
		
		Gui %window%:-Border -Caption
		
		Gui %window%:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui %window%:Font, s12 Bold cSilver
		Gui %window%:Add, Text, x0 y8 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBoxPreview, % translate("Modular Simulator Controller System")
		Gui %window%:Font, s10 cSilver
		Gui %window%:Add, Text, x0 y28 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBoxPreview, % translate(this.Name)
		Gui %window%:Color, 0x000000
		Gui %window%:Font, s8 Norm, Arial
		
		vertical := this.kHeaderHeight
		
		Loop % this.Rows
		{
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]
		
			horizontal := this.SidesMargin
			
			Loop % this.Columns
			{
				columnWidth := columnWidths[A_Index]
			
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"
				
				descriptor := string2Values(",", descriptor)
			
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}
				
				if (descriptor[1] = "Empty.0") {
					descriptor := kEmptySpaceDescriptor
					number := 0
				}
				else {
					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					number := descriptor[2]
					
					descriptor := getConfigurationValue(this.Configuration, "Controls", descriptor[1], "")
				}
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])
					
					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
					
					function := ConfigurationItem.descriptor(function, number)

					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageHeight) / 2)
					
					Gui %window%:Add, Picture, x%x% y%y% w%imageWidth% h%imageHeight% BackgroundTrans gopenControlMenu, %image%

					if ((labelWidth > 0) && (labelHeight > 0)) {
						Gui %window%:Font, s8 Norm cBlack
				
						x := horizontal + Round((columnWidth - labelWidth) / 2)
						y := vertical + rowHeight - labelHeight
						
						Gui %window%:Add, Text, x%x% y%y% w%labelWidth% h%labelHeight% +Border -Background  +0x1000 +0x1 gopenControlMenu, %number%
					}
				}
				
				horizontal += (columnWidth + this.ColumnMargin)
			}
		
			vertical += (rowHeight + this.RowMargin)
		}

		Gui %window%:Add, Picture, x-10 y-10 gmoveButtonBoxPreview 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		this.iWidth := width
		this.iHeight := height
	}
	
	loadFromConfiguration(configuration) {
		layout := string2Values(",", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, "Layout"), ""))
		
		if (layout.Length() > 1)
			this.iRowMargin := layout[2]
		
		if (layout.Length() > 2)
			this.iColumnMargin := layout[3]
		
		if (layout.Length() > 3)
			this.iSidesMargin := layout[4]
		
		if (layout.Length() > 4)
			this.iBottomMargin := layout[5]
		
		layout := string2Values("x", layout[1])
		
		this.iRows := layout[1]
		this.iColumns := layout[2]
		
		rows := []
		
		Loop % this.Rows
			rows.Push(string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, A_Index), "")))
		
		this.iRowDefinitions := rows
	}
	
	computeLayout(ByRef rowHeights, ByRef columnWidths) {
		columnWidths := []
		rowHeights := []
		
		Loop % this.Columns
			columnWidths.Push(0)
		
		Loop % this.Rows
		{
			rowHeight := 0
		
			rowDefinition := this.RowDefinitions[A_Index]
			
			Loop % this.Columns
			{
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"
				
				descriptor := string2Values(",", descriptor)
				
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}

				if (descriptor[1] = "Empty.0")
					descriptor := kEmptySpaceDescriptor
				else
					descriptor := getConfigurationValue(this.Configuration, "Controls"
													  , ConfigurationItem.splitDescriptor(descriptor[1])[1], "")
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					descriptor := string2Values("x", descriptor[3])
					
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
				}
				else {
					imageWidth := 0
					imageHeight := 0
				}
				
				rowHeight := Max(rowHeight, imageHeight + ((labelHeight > 0) ? (this.kLabelMargin + labelHeight) : 0))
				
				columnWidths[A_Index] := Max(columnWidths[A_Index], Max(imageWidth, labelWidth))
			}
			
			rowHeights.Push(rowHeight)
		}
	}
	
	getControl(clickX, clickY, ByRef row, ByRef column, ByRef isEmpty) {
		local function
		
		rowHeights := false
		columnWidths := false
		
		this.computeLayout(rowHeights, columnWidths)
		
		height := 0
		Loop % rowHeights.Length()
			height += rowHeights[A_Index]
		
		width := 0
		Loop % columnWidths.Length()
			width += columnWidths[A_Index]
		
		height += ((rowHeights.Length() - 1) * this.RowMargin) + this.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length() - 1) * this.ColumnMargin) + (2 * this.SidesMargin)
		
		vertical := this.kHeaderHeight
		
		Loop % this.Rows
		{
			row := A_Index
			
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]
		
			horizontal := this.SidesMargin
			
			Loop % this.Columns
			{
				column := A_Index
				
				columnWidth := columnWidths[A_Index]
			
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0) {
					descriptor := "Empty.0"
					
					isEmpty := true
				}
				else
					isEmpty := false
				
				descriptor := string2Values(",", descriptor)
				
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}
				
				if (descriptor[1] = "Empty.0") {
					descriptor := kEmptySpaceDescriptor
					name := "Empty"
					number := 0
				}
				else {
					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					name := descriptor[1]
					number := descriptor[2]
				
					descriptor := getConfigurationValue(this.Configuration, "Controls", descriptor[1], "")
				}
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])
					
					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
					
					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageHeight) / 2)
					
					if ((clickX >= x) && (clickX <= (x + imageWidth)) && (clickY >= y) && (clickY <= (y + imageHeight)))
						return ["Control", ConfigurationItem.descriptor(name, number)]
					
					if ((labelWidth > 0) && (labelHeight > 0)) {
						Gui %window%:Font, s8 Norm
				
						x := horizontal + Round((columnWidth - labelWidth) / 2)
						y := vertical + rowHeight - labelHeight
						
						if ((clickX >= x) && (clickX <= (x + labelWidth)) && (clickY >= y) && (clickY <= (y + labelHeight)))
							return ["Label", ConfigurationItem.descriptor(name, number)]
					}
				}
				
				horizontal += (columnWidth + this.ColumnMargin)
			}
		
			vertical += (rowHeight + this.RowMargin)
		}

		return false
	}
	
	open() {
		width := this.Width
		height := this.Height
		
		centerX := this.Editor.ButtonBoxPreviewCenterX
		centerY := this.Editor.ButtonBoxPreviewCenterY
		
		if (centerX && centerY) {
			x := centerX - Round(width / 2)
			y := centerY - Round(height / 2)
		}
		else {
			SysGet mainScreen, MonitorWorkArea

			x := mainScreenRight - width
			y := mainScreenBottom - height
		}
		
		window := this.Window
		
		Gui %window%:Show, x%x% y%y% w%width% h%height% NoActivate
	}
	
	close() {
		window := this.Window
		
		Gui %window%:Destroy
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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

saveButtonBoxesEditor() {
	protectionOn()
	
	try {
		ButtonBoxesEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelButtonBoxesEditor() {
	protectionOn()
	
	try {
		ButtonBoxesEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

moveButtonBoxesEditor() {
	moveByMouse("BBE")
}

openButtonBoxesDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts
}

chooseImageFilePath() {
	protectionOn()
	
	try {
		GuiControlGet imageFilePathEdit
		
		path := imageFilePathEdit
	
		if (path && (path != ""))
			path := getFileName(path, kButtonBoxImagesDirectory)
		else
			path := SubStr(kButtonBoxImagesDirectory, 1, StrLen(kButtonBoxImagesDirectory) - 1)
		
		title := translate("Select Image...")
	
		FileSelectFile pictureFile, 1, , %title%, Image (*.jpg; *.png; *.gif)
		
		if (pictureFile != "") {
			imageFilePathEdit := pictureFile
			
			GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
		}
	}
	finally {
		protectionOff()
	}
}

updateLayoutRowEditor() {
	protectionOn()
	
	try {
		ConfigurationItemList.getList("layoutsListView").updateLayoutRowEditor()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

moveButtonBoxPreview() {
	window := ButtonBoxPreview.CurrentWindow
	
	moveByMouse(window)
	
	WinGetPos x, y, width, height, A
	
	ButtonBoxesEditor.Instance.setButtonBoxPreviewPosition(x + Round(width / 2), y + Round(height / 2))
}

openControlMenu() {
	curCoordMode := A_CoordModeMouse
	
	CoordMode Mouse, Window
		
	try {	
		MouseGetPos clickX, clickY
		
		row := 0
		column := 0
		isEmpty := false
		
		element := ButtonBoxesEditor.Instance.ButtonBoxPreview.getControl(clickX, clickY, row, column, isEmpty)
		
		if element {
			menuItem := (translate(element[1] . ": ") . element[2] . " (" . row . " x " . column . ")")
			
			try {
				Menu GridElement, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			Gui BBE:Default
			
			Menu GridElement, Add, %menuItem%, menuIgnore
			Menu GridElement, Disable, %menuItem%
			Menu GridElement, Add
			
			try {
				Menu ControlMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			label := translate("Empty")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, false)
			
			Menu ControlMenu, Add, %label%, %handler%
			Menu ControlMenu, Add
			
			for control, definition in ControlsList.Instance.getControls() {
				handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, control)
			
				Menu ControlMenu, Add, %control%, %handler%
			}
			
			if !isEmpty {
				Menu ControlMenu, Add
			
				try {
					Menu NumberMenu, DeleteAll
				}
				catch exception {
					; ignore
				}
				
				label := translate("Input...")
				handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Number__", false)
				
				Menu NumberMenu, Add, %label%, %handler%
				Menu NumberMenu, Add
				
				count := 1
				
				Loop 4 {
					label := (count . " - " . (count + 9))
					
					menu := ("NumSubMenu" . A_Index)
				
					try {
						Menu %menu%, DeleteAll
					}
					catch exception {
						; ignore
					}
					
					Loop 10 {
						handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Number__", count)
						Menu %menu%, Add, %count%, %handler%
						
						count += 1
					}
				
					Menu NumberMenu, Add, %label%, :%menu%
				}
				
				label := translate("Number")
				Menu ControlMenu, Add, %label%, :NumberMenu
			}
			
			label := translate("Control")
			
			Menu GridElement, Add, %label%, :ControlMenu
			
			if !isEmpty {
				try {
					Menu LabelMenu, DeleteAll
				}
				catch exception {
					; ignore
				}
				
				label := translate("Empty")
				handler := ObjBindMethod(LayoutsList.Instance, "changeLabel", row, column, false)
				
				Menu LabelMenu, Add, %label%, %handler%
				Menu LabelMenu, Add
				
				for label, definition in LabelsList.Instance.getLabels() {
					handler := ObjBindMethod(LayoutsList.Instance, "changeLabel", row, column, label)
				
					Menu LabelMenu, Add, %label%, %handler%
				}
				
				label := translate("Label")
				
				Menu GridElement, Add, %label%, :LabelMenu
			}

			Menu GridElement, Show
		}
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}

menuIgnore() {
}

initializeControllerConfigurator() {
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Controller"), new ControllerConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeControllerConfigurator()