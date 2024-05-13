;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugins Configuration Plugin    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Configuration\Libraries\ControllerActionsEditor.ahk"
#Include "..\Configuration\Libraries\ConversationBoosterEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginsConfigurator                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PluginsConfigurator extends ConfigurationItemList {
	iConversationBoosterConfiguration := false

	Plugins {
		Get {
			local result := []
			local index, thePlugin

			for index, thePlugin in this.ItemList
				result.Push(thePlugin[2])

			return result
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		PluginsConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		openActionsEditor(*) {
			window.Block()

			try {
				ControllerActionsEditor(kSimulatorConfiguration).editPluginActions(window["pluginEdit"].Text, window)
			}
			finally {
				window.Unblock()
			}
		}

		openPluginsModesDocumentation(*) {
			switch window["pluginEdit"].Text, false {
				case "System":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration")
				case "Tactile Feedback":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-1")
				case "Motion Feedback":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-2")
				case "Pedal Calibration":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-3")
				case "Driving Coach":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-driving-coach")
				case "Race Engineer":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer")
				case "Race Strategist":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist")
				case "Race Spotter":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter")
				case "Team Server":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server")
				case "ACC":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-4")
				case "AC":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-5")
				case "IRC":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-6")
				case "RF2":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-7")
				case "R3E":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-8")
				case "AMS2":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-9")
				case "PCARS2":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-10")
				case "LMU":
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-11")
				default:
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes")
			}
		}

		window.Add("ListView", "x16 y80 w457 h245 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VpluginsListView", collect(["Active?", "Plugin", "Simulator(s)", "Arguments"], translate))

		window.Add("Text", "x16 y335 w86 h23 Y:Move +0x200", translate("Plugin"))
		window.Add("Edit", "x110 y335 w154 h21 Y:Move W:Grow(0.2) VpluginEdit").OnEvent("Change", (*) => this.updateState())

		window.Add("CheckBox", "x110 y359 w120 h23 Y:Move VpluginActivatedCheck", translate("Activated?"))

		window.Add("Text", "x16 y383 w89 h23 Y:Move +0x200", translate("Simulator(s)"))
		window.Add("Edit", "x110 y383 w339 h21 Y:Move W:Grow(0.2) VpluginSimulatorsEdit")

		widget1 := window.Add("Button", "x450 y383 w23 h23 X:Move Y:Move vpluginBoosterButton")
		widget1.OnEvent("Click", (*) => this.editBooster())
		setButtonIcon(widget1, kIconsDirectory . "Booster.ico", 1, "L4 T4 R4 B4")

		window.SetFont("Underline", "Arial")

		window.Add("Text", "x16 y408 w80 h23 +0x200 Y:Move c" . window.Theme.LinkColor, translate("Arguments")).OnEvent("Click", openPluginsModesDocumentation)

		window.SetFont("Norm", "Arial")

		window.Add("Edit", "x110 y408 w363 h113 Y:Move W:Grow VpluginArgumentsEdit")

		window.Add("Button", "x16 y530 w140 h23 Y:Move ", translate("Edit Labels && Icons...")).OnEvent("Click", openActionsEditor)

		window.Add("Button", "x264 y530 w46 h23 Y:Move X:Move VpluginAddButton", translate("Add"))
		window.Add("Button", "x312 y530 w50 h23 Y:Move X:Move Disabled VpluginDeleteButton", translate("Delete"))
		window.Add("Button", "x418 y530 w55 h23 Y:Move X:Move Disabled VpluginUpdateButton", translate("&Save"))

		this.initializeList(editor, window["pluginsListView"], window["pluginAddButton"], window["pluginDeleteButton"], window["pluginUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local name, arguments

		super.loadFromConfiguration(configuration)

		for name, arguments in getMultiMapValues(configuration, "Plugins")
			this.ItemList.Push(Plugin(name, configuration))

		this.iConversationBoosterConfiguration := newMultiMap()

		setMultiMapValues(this.iConversationBoosterConfiguration, "Conversation Booster", getMultiMapValues(configuration, "Conversation Booster"))
	}

	saveToConfiguration(configuration) {
		local ignore, thePlugin

		super.saveToConfiguration(configuration)

		for ignore, thePlugin in this.ItemList
			thePlugin.saveToConfiguration(configuration)

		addMultiMapValues(configuration, this.iConversationBoosterConfiguration)
	}

	updateState() {
		super.updateState()

		if (this.CurrentItem != 0) {
			if (this.Control["pluginEdit"].Text = "System") {
				this.Control["pluginEdit"].Enabled := false
				this.Control["pluginActivatedCheck"].Enabled := false
				this.Control["pluginSimulatorsEdit"].Enabled := false

				this.Control["pluginDeleteButton"].Enabled := false
			}
			else {
				this.Control["pluginEdit"].Enabled := true
				this.Control["pluginActivatedCheck"].Enabled := true
				this.Control["pluginSimulatorsEdit"].Enabled := true

				this.Control["pluginDeleteButton"].Enabled := true
			}
		}
		else {
			this.Control["pluginEdit"].Enabled := true
			this.Control["pluginActivatedCheck"].Enabled := true
			this.Control["pluginSimulatorsEdit"].Enabled := true
		}

		if inList(remove(kRaceAssistants, "Driving Coach"), this.Control["pluginEdit"].Text)
			this.Control["pluginBoosterButton"].Enabled := true
		else
			this.Control["pluginBoosterButton"].Enabled := false
	}

	loadList(items) {
		local count, index, thePlugin, name, active

		static first := true

		comparePlugins(p1, p2) {
			if (p1.Plugin = translate("System"))
				return false
			else if (p2.Plugin = translate("System"))
				return true
			else
				return ((StrCompare(p1.Plugin, p2.Plugin) <= 0) ? false : true)
		}

		bubbleSort(&items, comparePlugins)

		this.ItemList := items

		/*
		count := this.Control["pluginsListView"].GetCount()

		for index, thePlugin in items {
			name := thePlugin.Plugin
			active := thePlugin.Active

			if (index <= count)
				this.Control["pluginsListView"].Modify(index, "", thePlugin.Active ? ((name = translate("System")) ? translate("Always") : translate("Yes")) : translate("No")
																, name, values2String(", ", thePlugin.Simulators*), thePlugin.Arguments[true])
			else
				this.Control["pluginsListView"].Add("", thePlugin.Active ? ((name = translate("System")) ? translate("Always") : translate("Yes")) : translate("No")
													  , name, values2String(", ", thePlugin.Simulators*), thePlugin.Arguments[true])
		}

		if (items.Length < count)
			loop count - items.Length
				this.Control["pluginsListView"].Delete(count - A_Index - 1)
		*/

		this.Control["pluginsListView"].Delete()

		for index, thePlugin in items {
			name := thePlugin.Plugin

			this.Control["pluginsListView"].Add("", thePlugin.Active ? ((name = translate("System")) ? translate("Always") : translate("Yes")) : translate("No")
												  , name, values2String(", ", thePlugin.Simulators*), thePlugin.Arguments[true])
		}

		if first {
			this.Control["pluginsListView"].ModifyCol()
			this.Control["pluginsListView"].ModifyCol(1, "Center AutoHdr")
			this.Control["pluginsListView"].ModifyCol(2, 100)
			this.Control["pluginsListView"].ModifyCol(3, 120)

			first := false
		}
	}

	loadEditor(item) {
		this.Control["pluginEdit"].Text := item.Plugin
		this.Control["pluginActivatedCheck"].Value := !!item.Active
		this.Control["pluginSimulatorsEdit"].Text := values2String(", ", item.Simulators*)
		this.Control["pluginArgumentsEdit"].Text := item.Arguments[true]
	}

	clearEditor() {
		this.Control["pluginActivatedCheck"].Value := 0
		this.Control["pluginEdit"].Text := ""
		this.Control["pluginSimulatorsEdit"].Text := ""
		this.Control["pluginArgumentsEdit"].Text := ""
	}

	buildItemFromEditor(isNew := false) {
		try {
			return Plugin(this.Control["pluginEdit"].Text, false, this.Control["pluginActivatedCheck"].Value
						, this.Control["pluginSimulatorsEdit"].Text, this.Control["pluginArgumentsEdit"].Text)
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
	}

	editBooster() {
		local assistant := this.Control["pluginEdit"].Text
		local window := this.Window
		local configuration, speakerBooster, listenerBooster, conversationBooster, thePlugin
		local ignore, otherAssistant, key, value

		if !inList(kRaceAssistants, assistant)
			return

		window.Block()

		try {
			configuration := ConversationBoosterEditor(assistant, this.iConversationBoosterConfiguration).editBooster(window)

			if configuration {
				thePlugin := this.buildItemFromEditor()

				if thePlugin {
					thePlugin.removeArgument("raceAssistantSpeakerBooster")
					thePlugin.removeArgument("raceAssistantListenerBooster")
					thePlugin.removeArgument("raceAssistantConversationBooster")

					for ignore, otherAssistant in kRaceAssistants
						if (otherAssistant != assistant)
							for key, value in getMultiMapValues(this.iConversationBoosterConfiguration, "Conversation Booster")
								if (InStr(key, otherAssistant) = 1)
									setMultiMapValue(configuration, "Conversation Booster", key, value)

					this.iConversationBoosterConfiguration := configuration

					if getMultiMapValue(configuration, "Conversation Booster", assistant . ".Speaker", false)
						thePlugin.setArgumentValue("raceAssistantSpeakerBooster", assistant)

					if getMultiMapValue(configuration, "Conversation Booster", assistant . ".Listener", false)
						thePlugin.setArgumentValue("raceAssistantListenerBooster", assistant)

					if getMultiMapValue(configuration, "Conversation Booster", assistant . ".Conversation", false)
						thePlugin.setArgumentValue("raceAssistantConversationBooster", assistant)

					this.loadEditor(thePlugin)
				}
			}
		}
		finally {
			window.Unblock()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePluginsConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Plugins"), PluginsConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePluginsConfigurator()





