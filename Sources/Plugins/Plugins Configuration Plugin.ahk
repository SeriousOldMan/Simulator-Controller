;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugins Configuration Plugin    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginsConfigurator                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global pluginsListView = false

global pluginEdit = ""
global pluginActivatedCheck = false
global pluginActivatedCheckHandle
global pluginSimulatorsEdit = ""
global pluginArgumentsEdit = ""

global pluginAddButton
global pluginDeleteButton
global pluginUpdateButton
		
class PluginsConfigurator extends ConfigurationItemList {
	Plugins[] {
		Get {
			result := []
			
			for index, thePlugin in this.ItemList
				result.Push(thePlugin[2])
				
			return result
		}
	}
	
	__New(configuration) {
		base.__New(configuration)
				 
		PluginsConfigurator.Instance := this
	}
					
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Add, ListView, x16 y80 w457 h205 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndpluginsListViewHandle VpluginsListView glistEvent
						, % values2String("|", map(["Active?", "Plugin", "Simulator(s)", "Arguments"], "translate")*)
		
		Gui %window%:Add, Text, x16 y295 w86 h23 +0x200, % translate("Plugin")
		Gui %window%:Add, Edit, x110 y295 w154 h21 VpluginEdit, %pluginEdit%
		
		Gui %window%:Add, CheckBox, x110 y319 w120 h23 VpluginActivatedCheck HwndpluginActivatedCheckHandle, % translate("Activated?")
		
		Gui %window%:Add, Text, x16 y343 w89 h23 +0x200, % translate("Simulator(s)")
		Gui %window%:Add, Edit, x110 y343 w363 h21 VpluginSimulatorsEdit, %pluginSimulatorsEdit%
		
		Gui %window%:Font, Underline, Arial
		
		Gui %window%:Add, Text, x16 y368 w86 h23 +0x200 cBlue gopenPluginsModesDocumentation, % translate("Arguments")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Edit, x110 y368 w363 h113 VpluginArgumentsEdit, %pluginArgumentsEdit%
		
		Gui %window%:Add, Button, x16 y490 w92 h23 gopenLabelsEditor, % translate("Edit Labels...")
		
		Gui %window%:Add, Button, x264 y490 w46 h23 VpluginAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VpluginDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VpluginUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(pluginsListViewHandle, "pluginsListView", "pluginAddButton", "pluginDeleteButton", "pluginUpdateButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
	
		for name, arguments in getConfigurationSectionValues(configuration, "Plugins", Object())
			this.ItemList.Push(new Plugin(name, configuration))
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		for ignore, thePlugin in this.ItemList
			thePlugin.saveToConfiguration(configuration)
	}
	
	updateState() {
		base.updateState()
		
		if (this.CurrentItem != 0) {
			if (pluginEdit = "System") {
				GuiControl Disable, pluginEdit
				GuiControl Disable, pluginActivatedCheck
				GuiControl Disable, pluginSimulatorsEdit
		
				GuiControl Disable, pluginDeleteButton
			}
			else {
				GuiControl Enable, pluginEdit
				GuiControl Enable, pluginActivatedCheck
				GuiControl Enable, pluginSimulatorsEdit
			
				GuiControl Enable, pluginDeleteButton
			}
		}
		else {
			GuiControl Enable, pluginEdit
			GuiControl Enable, pluginActivatedCheck
			GuiControl Enable, pluginSimulatorsEdit
		}
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		bubbleSort(items, "comparePlugins")
		
		this.ItemList := items
	
		count := LV_GetCount()
		
		for index, thePlugin in items {
			name := thePlugin.Plugin
			active := thePlugin.Active
		
			if (index <= count)
				LV_Modify(index, "", thePlugin.Active ? ((name = translate("System")) ? translate("Always") : translate("Yes")) : translate("No")
						, name, values2String(", ", thePlugin.Simulators*), thePlugin.Arguments[true])
			else
				LV_Add("", thePlugin.Active ? ((name = translate("System")) ? translate("Always") : translate("Yes")) : translate("No")
					 , name, values2String(", ", thePlugin.Simulators*), thePlugin.Arguments[true])
		}
		
		if (items.Length() < count)
			Loop % count - items.Length()
				LV_Delete(count - A_Index - 1)
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "Center AutoHdr")
			LV_ModifyCol(2, 100)
			LV_ModifyCol(3, 120)
			
			first := false
		}
	}
	
	selectItem(itemNumber) {
		Gui ListView, % this.ListHandle
		
		if (itemNumber && (itemNumber != this.CurrentItem))
			LV_Modify(itemNumber, "Vis +Select +Focus")
		
		this.CurrentItem := itemNumber
			
		this.updateState()
	}
	
	loadEditor(item) {
		pluginEdit := item.Plugin
		pluginSimulatorsEdit := values2String(", ", item.Simulators*)
		pluginArgumentsEdit := item.Arguments[true]
		pluginActivatedCheck := item.Active
		
		GuiControl Text, pluginEdit, %pluginEdit%

		if pluginActivatedCheck
			Control Check, , , ahk_id %pluginActivatedCheckHandle%
		else
			Control Uncheck, , , ahk_id %pluginActivatedCheckHandle%
		
		GuiControl, , pluginActivatedCheck, %pluginActivatedCheck%
			
		GuiControl Text, pluginSimulatorsEdit, %pluginSimulatorsEdit%
		GuiControl Text, pluginArgumentsEdit, %pluginArgumentsEdit%
	}
	
	clearEditor() {
		pluginEdit := ""
		pluginSimulatorsEdit := ""
		pluginArgumentsEdit := ""
		pluginActivatedCheck := false
		
		Control Uncheck, , , ahk_id %pluginActivatedCheckHandle%
		GuiControl Text, pluginEdit, %pluginEdit%
		GuiControl Text, pluginSimulatorsEdit, %pluginSimulatorsEdit%
		GuiControl Text, pluginArgumentsEdit, %pluginArgumentsEdit%
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet pluginEdit
		GuiControlGet pluginSimulatorsEdit
		GuiControlGet pluginArgumentsEdit
		GuiControlGet pluginActivatedCheck
		
		return new Plugin(pluginEdit, false, pluginActivatedCheck != 0, pluginSimulatorsEdit, pluginArgumentsEdit)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

comparePlugins(p1, p2) {
	if (p1.Plugin = translate("System"))
		return false
	else if (p2.Plugin = translate("System"))
		return true
	else
		return (p1.Plugin >= p2.Plugin)
}

openLabelsEditor() {
	Run % "notepad.exe " . """" . kUserConfigDirectory . "Controller Plugin Labels.ini"""
}

openPluginsModesDocumentation() {
	GuiControlGet pluginEdit
	
	switch pluginEdit {
		case "System":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration
		case "Tactile Feedback":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-1
		case "Motion Feedback":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-2
		case "Pedal Calibration":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-3
		case "ACC":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-4
		default:
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes
	}
}

initializePluginsConfigurator() {
	editor := ConfigurationEditor.Instance
	
	editor.registerConfigurator(translate("Plugins"), new PluginsConfigurator(editor.Configuration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePluginsConfigurator()