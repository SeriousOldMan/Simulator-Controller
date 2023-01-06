;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugins Configuration Plugin    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\ControllerActionsEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginsConfigurator                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global pluginsListView := false

global pluginEdit := ""
global pluginActivatedCheck := false
global pluginActivatedCheckHandle
global pluginSimulatorsEdit := ""
global pluginArgumentsEdit := ""

global pluginAddButton
global pluginDeleteButton
global pluginUpdateButton

class PluginsConfigurator extends ConfigurationItemList {
	iEditor := false

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	Plugins[] {
		Get {
			local result := []
			local index, thePlugin

			for index, thePlugin in this.ItemList
				result.Push(thePlugin[2])

			return result
		}
	}

	__New(editor, configuration) {
		this.iEditor := editor

		base.__New(configuration)

		PluginsConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

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

		Gui %window%:Add, Button, x16 y490 w140 h23 gopenActionsEditor, % translate("Edit Labels && Icons...")

		Gui %window%:Add, Button, x264 y490 w46 h23 VpluginAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VpluginDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VpluginUpdateButton gupdateItem, % translate("&Save")

		this.initializeList(pluginsListViewHandle, "pluginsListView", "pluginAddButton", "pluginDeleteButton", "pluginUpdateButton")
	}

	loadFromConfiguration(configuration) {
		local name, arguments

		base.loadFromConfiguration(configuration)

		for name, arguments in getConfigurationSectionValues(configuration, "Plugins", Object())
			this.ItemList.Push(new Plugin(name, configuration))
	}

	saveToConfiguration(configuration) {
		local ignore, thePlugin

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
		local count, index, thePlugin, name, active

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
			loop % count - items.Length()
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
		GuiControl Text, pluginEdit, % item.Plugin

		if item.Active
			Control Check, , , ahk_id %pluginActivatedCheckHandle%
		else
			Control Uncheck, , , ahk_id %pluginActivatedCheckHandle%

		GuiControl, , pluginActivatedCheck, % item.Active

		GuiControl Text, pluginSimulatorsEdit, % values2String(", ", item.Simulators*)
		GuiControl Text, pluginArgumentsEdit, % item.Arguments[true]
	}

	clearEditor() {
		Control Uncheck, , , ahk_id %pluginActivatedCheckHandle%
		GuiControl Text, pluginEdit, % ""
		GuiControl Text, pluginSimulatorsEdit, % ""
		GuiControl Text, pluginArgumentsEdit, % ""
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

openActionsEditor() {
	local owner := PluginsConfigurator.Instance.Editor.Window

	GuiControlGet pluginEdit

	Gui %owner%:+Disabled
	Gui PAE:+Owner%owner%

	try {
		new ControllerActionsEditor(kSimulatorConfiguration).editPluginActions(pluginEdit)
	}
	finally {
		Gui %owner%:-Disabled
	}
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
		case "Race Engineer":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer
		case "Race Strategist":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist
		case "Race Spotter":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter
		case "Team Server":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server
		case "ACC":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-4
		case "AC":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-5
		case "IRC":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-6
		case "RF2":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-7
		case "R3E":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-8
		case "AMS2":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-9
		case "PCARS2":
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-10
		default:
			Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes
	}
}

initializePluginsConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Plugins"), new PluginsConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePluginsConfigurator()