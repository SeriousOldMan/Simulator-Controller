;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Editor               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\ConfigurationItemList.ahk
#Include ..\Configuration\Libraries\ButtonBoxPreview.ahk
#Include ..\Configuration\Libraries\StreamDeckPreview.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kControlTypes = {}

kControlTypes[k1WayToggleType] := "1-way Toggle"
kControlTypes[k2WayToggleType] := "2-way Toggle"
kControlTypes[kButtonType] := "Button"
kControlTypes[kDialType] := "Rotary"
kControlTypes[kCustomType] := "Custom"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vControllerPreviews = {}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerEditor extends ConfigurationItem {
	iControlsList := false
	iLabelsList := false
	iLayoutsList := false
	
	iName := ""
	iClosed := false
	
	iControllerPreview := false
	
	iButtonBoxConfiguration := false
	iButtonBoxConfigurationFile := false
	
	iStreamDeckConfiguration := false
	iStreamDeckConfigurationFile := false
	
	iPreviewCenterX := 0
	iPreviewCenterY := 0
	
	ControllerPreview[] {
		Get {
			return this.iControllerPreview
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
	
	ButtonBoxConfigurationFile[] {
		Get {
			return this.iButtonBoxConfigurationFile
		}
	}
	
	StreamDeckConfiguration[] {
		Get {
			return this.iStreamDeckConfiguration
		}
	}
	
	StreamDeckConfigurationFile[] {
		Get {
			return this.iStreamDeckConfigurationFile
		}
	}
	
	AutoSave[] {
		Get {
			try {
				if (ConfigurationEditor && ConfigurationEditor.Instance)
					return ConfigurationEditor.Instance.AutoSave
				else
					return false
			}
			catch exception {
				return false
			}
		}
	}
	
	__New(name, configuration, buttonBoxConfigurationFile := false, streamDeckConfigurationFile := false, saveAndCancel := true) {
		this.iName := name
		
		if !buttonBoxConfigurationFile
			buttonBoxConfigurationFile := getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)
		
		if !streamDeckConfigurationFile
			streamDeckConfigurationFile := getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory)
		
		this.iButtonBoxConfigurationFile := buttonBoxConfigurationFile
		this.iStreamDeckConfigurationFile := streamDeckConfigurationFile
		
		this.iButtonBoxConfiguration := readConfiguration(buttonBoxConfigurationFile)
		this.iStreamDeckConfiguration := readConfiguration(streamDeckConfigurationFile)
		
		this.iControlsList := new ControlsList(this.iButtonBoxConfiguration)
		this.iLabelsList := new LabelsList(this.iButtonBoxConfiguration)
		this.iLayoutsList := new LayoutsList(this.iButtonBoxConfiguration, this.iStreamDeckConfiguration)
		
		base.__New(configuration)
		
		ControllerEditor.Instance := this
		
		this.createGui(this.iButtonBoxConfiguration, this.iStreamDeckConfiguration, saveAndCancel)
	}
	
	createGui(buttonBoxConfiguration, streamDeckConfiguration, saveAndCancel) {
		Gui CTRLE:Default
	
		Gui CTRLE:-Border ; -Caption
		
		Gui CTRLE:Color, D0D0D0, D8D8D8
		Gui CTRLE:Font, Bold, Arial

		Gui CTRLE:Add, Text, x0 w432 Center gmoveControllerEditor, % translate("Modular Simulator Controller System") 
		
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic Underline, Arial

		Gui CTRLE:Add, Text, x0 YP+20 w432 cBlue Center gopenControllerDocumentation, % translate("Button Box Layouts")
		
		this.iControlsList.createGui(buttonBoxConfiguration)
		this.iLabelsList.createGui(buttonBoxConfiguration)
		this.iLayoutsList.createGui(buttonBoxConfiguration, streamDeckConfiguration)
		
		if saveAndCancel {
			Gui CTRLE:Add, Text, x50 y639 w332 0x10
			
			Gui CTRLE:Add, Button, x130 y654 w80 h23 Default GsaveControllerEditor, % translate("Save")
			Gui CTRLE:Add, Button, x230 y654 w80 h23 GcancelControllerEditor, % translate("Cancel")
		}
	}
	
	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		if save
			base.saveToConfiguration(buttonBoxConfiguration)
		
		this.iControlsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.iLabelsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.iLayoutsList.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save)
	}
		
	setPreviewCenter(centerX, centerY) {
		this.iPreviewCenterX := centerX
		this.iPreviewCenterY := centerY
	}
	
	getPreviewCenter(ByRef centerX, ByRef centerY) {
		centerX := this.iPreviewCenterX
		centerY := this.iPreviewCenterY
	}
	
	getPreviewMover() {
		return "moveControllerPreview"
	}
	
	open(x := "Center", y := "Center") {
		Gui CTRLE:Show, AutoSize x%x% y%y%
		
		name := this.Name
		
		if !this.AutoSave
			for index, item in this.iLayoutsList.ItemList
				if (item[1] = name) {
					this.iLayoutsList.openEditor(index)
					this.iLayoutsList.selectItem(index)
					
					break
				}
	}
	
	close(save := true) {
		if save {
			buttonBoxConfiguration := newConfiguration()
			streamDeckConfiguration := newConfiguration()
			
			this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration)
			
			writeConfiguration(this.ButtonBoxConfigurationFile, buttonBoxConfiguration)
			writeConfiguration(this.StreamDeckConfigurationFile, streamDeckConfiguration)
		}
			
		this.saveController()
		
		if this.ControllerPreview {
			this.ControllerPreview.close()
			
			this.iControllerPreview := false
		}
		
		Gui CTRLE:Destroy
		
		this.iClosed := true
	}
	
	editController() {
		this.open()
		
		Loop
			Sleep 200
		until this.iClosed
	}
	
	configurationChanged(type, name) {
		this.updateControllerPreview(type, name)
	}

	updateControllerPreview(type, name) {
		buttonBoxConfiguration := newConfiguration()
		streamDeckConfiguration := newConfiguration()
		
		this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, false)
		
		this.iButtonBoxConfiguration := buttonBoxConfiguration
		this.iStreamDeckConfiguration := streamDeckConfiguration
		
		oldPreview := this.ControllerPreview
		
		if name {
			if (type = "Button Box")
				this.iControllerPreview := new ButtonBoxPreview(this, name, buttonBoxConfiguration)
			else
				this.iControllerPreview := new StreamDeckPreview(this, name, streamDeckConfiguration)
		
			this.ControllerPreview.open()
		}
		else
			this.iControllerPreview := false
		
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
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic, Arial
		
		Gui CTRLE:Add, GroupBox, -Theme x8 y60 w424 h138, % translate("Controls")
		
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Add, ListView, x16 y79 w134 h108 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndcontrolsListViewHandle VcontrolsListView glistEvent
							 , % values2String("|", map(["Name", "Function", "Size"], "translate")*)
							
		Gui CTRLE:Add, Text, x164 y79 w80 h23 +0x200, % translate("Name")
		Gui CTRLE:Add, Edit, x214 y80 w101 h21 VcontrolNameEdit, %controlNameEdit%
		Gui CTRLE:Add, DropDownList, x321 y79 w105 AltSubmit Choose%controlTypeDropDown% VcontrolTypeDropDown, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Dial"], "translate")*)
		;426 400 
		Gui CTRLE:Add, Text, x164 y103 w80 h23 +0x200, % translate("Image")
		Gui CTRLE:Add, Edit, x214 y103 w186 h21 VimageFilePathEdit, %imageFilePathEdit%
		Gui CTRLE:Add, Button, x403 y103 w23 h23 gchooseImageFilePath, % translate("...")
		
		Gui CTRLE:Add, Text, x164 y127 w80 h23 +0x200, % translate("Size")
		Gui CTRLE:Add, Edit, x214 y127 w40 h21 Limit3 Number VimageWidthEdit, %imageWidthEdit%
		Gui CTRLE:Add, Text, x254 y127 w21 h23 +0x200 Center, % translate("x")
		Gui CTRLE:Add, Edit, x275 y127 w40 h21 Limit3 Number VimageHeightEdit, %imageHeightEdit%
		
		Gui CTRLE:Add, Button, x226 y164 w46 h23 VcontrolAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x275 y164 w50 h23 Disabled VcontrolDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x371 y164 w55 h23 Disabled VcontrolUpdateButton gupdateItem, % translate("Save")
		
		this.initializeList(controlsListViewHandle, "controlsListView", "controlAddButton", "controlDeleteButton", "controlUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		controls := []
		
		for name, definition in getConfigurationSectionValues(configuration, "Controls", Object())
			controls.Push(Array(name, string2Values(";", definition)*))
		
		this.ItemList := controls
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		controls := {}
		
		for ignore, control in this.ItemList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])
		
		setConfigurationSectionValues(configuration, "Controls", controls)	
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		this.ItemList := items
		
		for ignore, control in items
			LV_Add("", control[1], translate(kControlTypes[control[2]]), control[4])
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			
			first := false
		}
		
		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
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
		if ControllerEditor.Instance.AutoSave {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
		}
		
		controls := {}
		
		for ignore, control in this.ItemList
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
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic, Arial
		
		Gui CTRLE:Add, GroupBox, -Theme x8 y205 w424 h115, % translate("Labels")
		
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Add, ListView, x16 y224 w134 h84 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlabelsListViewHandle VlabelsListView glistEvent
							 , % values2String("|", map(["Name", "Size"], "translate")*)
							
		Gui CTRLE:Add, Text, x164 y224 w80 h23 +0x200, % translate("Name")
		Gui CTRLE:Add, Edit, x214 y225 w101 h21 VlabelNameEdit, %labelNameEdit%
		
		Gui CTRLE:Add, Text, x164 y248 w80 h23 +0x200, % translate("Size")
		Gui CTRLE:Add, Edit, x214 y248 w40 h21 Limit3 Number VlabelWidthEdit, %labelWidthEdit%
		Gui CTRLE:Add, Text, x254 y248 w21 h23 +0x200 Center, % translate("x")
		Gui CTRLE:Add, Edit, x275 y248 w40 h21 Limit3 Number VlabelHeightEdit, %labelHeightEdit%
		
		Gui CTRLE:Add, Button, x226 y285 w46 h23 VlabelAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x275 y285 w50 h23 Disabled VlabelDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x371 y285 w55 h23 Disabled VlabelUpdateButton gupdateItem, % translate("Save")
		
		this.initializeList(labelsListViewHandle, "labelsListView", "labelAddButton", "labelDeleteButton", "labelUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		labels := []
		
		for name, definition in getConfigurationSectionValues(configuration, "Labels", Object())
			labels.Push(Array(name, definition))
		
		this.ItemList := labels
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		labels := {}
		
		for ignore, label in this.ItemList
			labels[label[1]] := label[2]
		
		setConfigurationSectionValues(configuration, "Labels", labels)	
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		this.ItemList := items
		
		for ignore, label in items
			LV_Add("", label[1], label[2])
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			
			first := false
		}
		
		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
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
		if this.AutoSave {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
		}
		
		labels := {}
		
		for ignore, label in this.ItemList
			labels[label[1]] := label[2]
		
		return labels
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LayoutsList                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global layoutsListView := "|"

global layoutNameEdit = ""
global layoutTypeDropDown

global layoutRowsEdit = ""
global layoutColumnsEdit = ""
global layoutRowMarginEdit = ""
global layoutColumnMarginEdit = ""
global layoutSidesMarginEdit = ""
global layoutBottomMarginEdit = ""

global layoutRowDropDown = 0
global layoutRowEdit = ""

global layoutVisibleCheck = true

global layoutAddButton
global layoutDeleteButton
global layoutUpdateButton
		
class LayoutsList extends ConfigurationItemList {
	iRowDefinitions := []
	iSelectedRow := false
	
	iStreamDeckConfiguration := false
	
	ButtonBoxConfiguration[] {
		Get {
			return this.Configuration
		}
	}
	
	StreamDeckConfiguration[] {
		Get {
			return this.iStreamDeckConfiguration
		}
	}
	
	CurrentControllerType[] {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][2]["Type"] : "Button Box")
		}
	}
	
	CurrentController[] {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][1] : false)
		}
	}
	
	__New(buttonBoxConfiguration, streamDeckConfiguration) {
		this.iStreamDeckConfiguration := streamDeckConfiguration
		
		base.__New(buttonBoxConfiguration)
				 
		LayoutsList.Instance := this
	}

	createGui(buttonBoxConfiguration, streamDeckConfiguration) {
		Gui CTRLE:Add, ListView, x8 y330 w424 h105 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlayoutsListViewHandle VlayoutsListView glistEvent
							 , % values2String("|", map(["Name", "Grid", "Margins", "Definition"], "translate")*)
		
		Gui CTRLE:Add, Text, x8 y445 w86 h23 +0x200, % translate("Name && Type")
		Gui CTRLE:Add, Edit, x102 y445 w110 h21 VlayoutNameEdit, %layoutNameEdit%
		Gui CTRLE:Add, DropDownList, x215 y445 w110 AltSubmit Choose1 VlayoutTypeDropDown, % values2String("|", map(["ButtonBox", "Stream Deck"], "translate")*)
		
		Gui CTRLE:Add, Text, x8 y469 w86 h23 +0x200, % translate("Visible")
		if layoutVisibleCheck
			Gui CTRLE:Add, CheckBox, x102 y469 w110 h21 Checked VlayoutVisibleCheck
		else
			Gui CTRLE:Add, CheckBox, x102 y469 w110 h21 VlayoutVisibleCheck
		
		Gui CTRLE:Add, Text, x8 y493 w86 h23 +0x200, % translate("Layout")
		Gui CTRLE:Font, c505050 s7
		Gui CTRLE:Add, Text, x16 y517 w133 h21, % translate("(R x C, Margins)")
		Gui CTRLE:Font
		
		Gui CTRLE:Add, Edit, x102 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutRowsEdit, %layoutRowsEdit%
		Gui CTRLE:Add, UpDown, x125 y493 w17 h21, 1
		Gui CTRLE:Add, Text, x147 y493 w20 h23 +0x200 Center, % translate("x")
		Gui CTRLE:Add, Edit, x172 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutColumnsEdit, %layoutColumnsEdit%
		Gui CTRLE:Add, UpDown, x195 y493 w17 h21, 1
		
		Gui CTRLE:Font, c505050 s7
		
		Gui CTRLE:Add, Text, x242 y474 w40 h23 +0x200 Center, % translate("Row")
		Gui CTRLE:Add, Text, x292 y474 w40 h23 +0x200 Center, % translate("Column")
		Gui CTRLE:Add, Text, x342 y474 w40 h23 +0x200 Center, % translate("Sides")
		Gui CTRLE:Add, Text, x392 y474 w40 h23 +0x200 Center, % translate("Bottom")
		
		Gui CTRLE:Font
		
		Gui CTRLE:Add, Edit, x242 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutRowMarginEdit, %layoutRowMarginEdit%
		Gui CTRLE:Add, Edit, x292 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutColumnMarginEdit, %layoutColumnMarginEdit%
		Gui CTRLE:Add, Edit, x342 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutSidesMarginEdit, %layoutSidesMarginEdit%
		Gui CTRLE:Add, Edit, x392 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		Gui CTRLE:Add, DropDownList, x8 y534 w86 AltSubmit Choose0 gupdateLayoutRowEditor VlayoutRowDropDown, |
		
		Gui CTRLE:Add, Edit, x102 y534 w330 h50 Disabled VlayoutRowEdit, %layoutRowEdit%
		
		Gui CTRLE:Add, Button, x223 y589 w46 h23 VlayoutAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x271 y589 w50 h23 Disabled VlayoutDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x377 y589 w55 h23 Disabled VlayoutUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(layoutsListViewHandle, "layoutsListView", "layoutAddButton", "layoutDeleteButton", "layoutUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		layouts := {}
		
		for descriptor, definition in getConfigurationSectionValues(this.ButtonBoxConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]
			
			if !layouts.HasKey(name)
				layouts[name] := Object()
			
			layouts[name]["Type"] := "Button Box"
			layouts[name]["Visible"] := true
			
			if (descriptor[2] = "Layout") {
				definition := string2Values(",", definition)
	
				rowMargin := ((definition.Length() > 1) ? definition[2] : ButtonBoxPreview.kRowMargin)
				columnMargin := ((definition.Length() > 2) ? definition[3] : ButtonBoxPreview.kColumnMargin)
				sidesMargin := ((definition.Length() > 3) ? definition[4] : ButtonBoxPreview.kSidesMargin)
				bottomMargin := ((definition.Length() > 4) ? definition[5] : ButtonBoxPreview.kBottomMargin)
				
				layouts[name]["Grid"] := definition[1]
				layouts[name]["Margins"] := Array(rowMargin, columnMargin, sidesMargin, bottomMargin)
			}
			else if (descriptor[2] = "Visible")
				layouts[name]["Visible"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}
		
		for descriptor, definition in getConfigurationSectionValues(this.StreamDeckConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]
			
			if !layouts.HasKey(name)
				layouts[name] := Object()
			
			layouts[name]["Type"] := "Stream Deck"
			layouts[name]["Visible"] := false
			
			if (descriptor[2] = "Layout")
				layouts[name]["Grid"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}
		
		items := []
		
		for name, definition in layouts
			items.Push(Array(name, definition))
		
		this.ItemList := items
	}
	
	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		if save
			base.saveToConfiguration(buttonBoxConfiguration)
		
		for ignore, layout in this.ItemList {
			if (layout[2]["Type"] = "Button Box") {
				grid := layout[2]["Grid"]
				
				setConfigurationValue(buttonBoxConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout")
									, grid . ", " . values2String(", ", layout[2]["Margins"]*))
									
				Loop % string2Values("x", grid)[1]
					setConfigurationValue(buttonBoxConfiguration, "Layouts"
										, ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])
				
				setConfigurationValue(buttonBoxConfiguration, "Layouts"
									, ConfigurationItem.descriptor(layout[1], "Visible"), layout[2]["Visible"])
			}
			else {
				grid := layout[2]["Grid"]
				
				setConfigurationValue(streamDeckConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout"), grid)
									
				Loop % string2Values("x", grid)[1]
					setConfigurationValue(streamDeckConfiguration, "Layouts"
										, ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])
			}
		}
	}
	
	loadList(items) {
		static first := true
		static inCall := false
		
		Gui ListView, % this.ListHandle
		
		LV_Delete()
		
		this.ItemList := items
		
		for ignore, layout in items {
			grid := layout[2]["Grid"]
		
			definition := ""
			
			Loop % string2Values("x", grid)[1]
			{
				if (A_Index > 1)
					definition .= "; "
				
				definition .= (A_Index . ": " . layout[2][A_Index])
			}
			
			
			LV_Add("", layout[1], grid, (layout[2]["Type"] = "Button Box") ? values2String(", ", layout[2]["Margins"]*) : "", definition)
		}
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			LV_ModifyCol(4, "AutoHdr")
			
			first := false
		}
		
		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
	}
	
	loadEditor(item) {
		if !item
			MsgBox Oops
		
		layoutNameEdit := item[1]
		layoutTypeDropDown := item[2]["Type"]
		layoutVisibleCheck := item[2]["Visible"]
		
		size := string2Values("x", item[2]["Grid"])
		
		layoutRowsEdit := size[1]
		layoutColumnsEdit := size[2]
		
		if (item[2]["Type"] = "Button Box") {
			margins := item[2]["Margins"]
			
			layoutRowMarginEdit := margins[1]
			layoutColumnMarginEdit := margins[2]
			layoutSidesMarginEdit := margins[3]
			layoutBottomMarginEdit := margins[4]
		}
		else {
			layoutRowMarginEdit := ""
			layoutColumnMarginEdit := ""
			layoutSidesMarginEdit := ""
			layoutBottomMarginEdit := ""
		}
		
		Gui CTRLE:Default
		
		GuiControl Text, layoutNameEdit, %layoutNameEdit%
		GuiControl Choose, layoutTypeDropDown, % inList(["Button Box", "Stream Deck"], layoutTypeDropDown)
		GuiControl Text, layoutRowsEdit, %layoutRowsEdit%
		GuiControl Text, layoutColumnsEdit, %layoutColumnsEdit%
		GuiControl Text, layoutRowMarginEdit, %layoutRowMarginEdit%
		GuiControl Text, layoutColumnMarginEdit, %layoutColumnMarginEdit%
		GuiControl Text, layoutSidesMarginEdit, %layoutSidesMarginEdit%
		GuiControl Text, layoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		GuiControl, , layoutVisibleCheck, %layoutVisibleCheck%
		
		if (item[2]["Type"] = "Button Box") {
			GuiControl Enable, layoutRowMarginEdit
			GuiControl Enable, layoutColumnMarginEdit
			GuiControl Enable, layoutSidesMarginEdit
			GuiControl Enable, layoutBottomMarginEdit
			
			GuiControl Enable, layoutVisibleCheck
		}
		else {
			GuiControl Disable, layoutRowMarginEdit
			GuiControl Disable, layoutColumnMarginEdit
			GuiControl Disable, layoutSidesMarginEdit
			GuiControl Disable, layoutBottomMarginEdit
			
			GuiControl Disable, layoutVisibleCheck
		}
		
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
		
		preview := ControllerEditor.Instance.ControllerPreview
		
		if ((this.CurrentController != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ControllerEditor.Instance.configurationChanged(item[2]["Type"], layoutNameEdit)
	}
	
	addItem() {
		base.addItem()
		
		type := this.ItemList[this.CurrentItem][2]["Type"]
		
		GuiControl Text, layoutRowEdit, %layoutRowEdit%
		
		preview := ControllerEditor.Instance.ControllerPreview
		
		if ((this.CurrentController != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ControllerEditor.Instance.configurationChanged(type, this.CurrentController)
	}
	
	clearEditor() {
		this.loadEditor(Array("", {Type: "Button Box", Visible: true, Grid: "0x0", Margins: [0,0,0,0]}))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet layoutNameEdit
		GuiControlGet layoutTypeDropDown
		GuiControlGet layoutRowsEdit
		GuiControlGet layoutColumnsEdit
		GuiControlGet layoutRowMarginEdit
		GuiControlGet layoutColumnMarginEdit
		GuiControlGet layoutSidesMarginEdit
		GuiControlGet layoutBottomMarginEdit
		GuiControlGet layoutVisibleCheck
		
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
			
			if (["Button Box", "Stream Deck"][layoutTypeDropDown] = "Button Box")
				layout := {Type: "Button Box", Grid: layoutRowsEdit . " x " . layoutColumnsEdit
						 , Visible: layoutVisibleCheck
						 , Margins: Array(layoutRowMarginEdit, layoutColumnMarginEdit, layoutSidesMarginEdit, layoutBottomMarginEdit)}
			else
				layout := {Type: "Stream Deck", Grid: layoutRowsEdit . " x " . layoutColumnsEdit, Visible: false}
			
			Loop % this.iRowDefinitions.Length()
				layout[A_Index] := this.iRowDefinitions[A_Index]
				
			return Array(layoutNameEdit, layout)
		}
	}
	
	updateLayoutRowEditor(save := true) {
		Gui CTRLE:Default
		
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
		
		if (save && ControllerEditor.Instance.AutoSave) {
			if (this.CurrentItem != 0) {
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
		
		ControllerEditor.Instance.configurationChanged(this.CurrentControllerType, this.CurrentController)
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
;;; ControllerPreview                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerPreview extends ConfigurationItem {
	static sCurrentWindow := 0
	
	iPreviewManager := false
	iName := ""
	
	iWindow := false
	
	iWidth := 0
	iHeight := 0
	
	PreviewManager[] {
		Get {
			return this.iPreviewManager
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Type[] {
		Get {
			Throw "Virtual property ControllerPreview.Type must be implemented in a subclass..."
		}
	}
	
	Width[] {
		Get {
			return this.iWidth
		}
		
		Set {
			this.iWidth := value
		}
	}
	
	Height[] {
		Get {
			return this.iHeight
		}
		
		Set {
			this.iHeight := value
		}
	}
	
	Window[] {
		Get {
			return this.iWindow
		}
	}
	
	CurrentWindow[] {
		Get {
			return ("CTRLP" . ControllerPreview.sCurrentWindow)
		}
	}
	
	__New(previewManager, name, configuration) {
		this.iPreviewManager := previewManager
		this.iName := name
		
		ControllerPreview.sCurrentWindow += 1
		
		this.iWindow := this.CurrentWindow
		
		base.__New(configuration)
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Throw "Virtual method ControllerPreview.createGui must be implemented in a subclass..."
	}
	
	open() {
		width := this.Width
		height := this.Height
	
		centerX := 0
		centerY := 0
		
		this.PreviewManager.getPreviewCenter(centerX, centerY)
		
		SysGet mainScreen, MonitorWorkArea

		x := mainScreenRight - width
		y := mainScreenBottom - height
			
		if centerX
			x := centerX - Round(width / 2)
		
		if centerY
			y := centerY - Round(height / 2)
		
		window := this.Window
		
		vControllerPreviews[window] := this
		
		Gui %window%:Show, x%x% y%y% w%width% h%height% NoActivate
	}
	
	close() {
		window := this.Window
		
		vControllerPreviews.Delete(window)
		
		Gui %window%:Destroy
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

controlClick() {
	curCoordMode := A_CoordModeMouse
	
	CoordMode Mouse, Window
		
	try {	
		MouseGetPos clickX, clickY
		
		row := 0
		column := 0
		isEmpty := false
		
		element := vControllerPreviews[A_Gui].getControl(clickX, clickY, row, column, isEmpty)
		
		if element
			vControllerPreviews[A_Gui].controlClick(element, row, column, isEmpty)
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveControllerEditor() {
	protectionOn()
	
	try {
		ControllerEditor.Instance.close(true)
	}
	finally {
		protectionOff()
	}
}

cancelControllerEditor() {
	protectionOn()
	
	try {
		ControllerEditor.Instance.close(false)
	}
	finally {
		protectionOff()
	}
}

moveControllerEditor() {
	moveByMouse(A_Gui)
}

openControllerDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts
}

chooseImageFilePath() {
	GuiControlGet imageFilePathEdit
	
	path := imageFilePathEdit

	if (path && (path != ""))
		path := getFileName(path, kButtonBoxImagesDirectory)
	else
		path := SubStr(kButtonBoxImagesDirectory, 1, StrLen(kButtonBoxImagesDirectory) - 1)
	
	title := translate("Select Image...")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
	FileSelectFile pictureFile, 1, , %title%, Image (*.jpg; *.png; *.gif)
	OnMessage(0x44, "")
	
	if (pictureFile != "") {
		imageFilePathEdit := pictureFile
		
		GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
	}
}

updateLayoutRowEditor() {
	protectionOn()
	
	try {
		list := ConfigurationItemList.getList("layoutsListView")
		
		if list
			list.updateLayoutRowEditor()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

moveControllerPreview() {
	window := ControllerPreview.CurrentWindow
	
	moveByMouse(window)
	
	WinGetPos x, y, width, height, A
	
	vControllerPreviews[A_Gui].PreviewManager.setPreviewCenter(x + Round(width / 2), y + Round(height / 2))
}