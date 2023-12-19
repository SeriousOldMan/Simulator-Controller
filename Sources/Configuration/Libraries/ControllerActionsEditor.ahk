;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Actions Editor       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ConfigurationEditor.ahk"
#Include "ConfigurationItemList.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerActionsEditor                                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerActionsEditor extends ConfiguratorPanel {
	iClosed := false

	iPlugins := []

	iSelectedLanguage := false
	iSelectedPlugin := false

	iActionsList := false

	iChanged := CaseInsenseMap()

	iActionLabels := CaseInsenseMap()
	iActionIcons := CaseInsenseMap()

	class ActionsWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Plugin Actions Editor", Closeable: true, Resizeable: true, Options: "-MaximizeBox"})
		}

		Close(*) {
			this.iEditor.closeEditor(false)
		}
	}

	Plugins[index?] {
		Get {
			return (isSet(index) ? this.iPlugins[index] : this.iPlugins)
		}
	}

	SelectedLanguage {
		Get {
			return this.iSelectedLanguage
		}
	}

	SelectedPlugin {
		Get {
			return this.iSelectedPlugin
		}
	}

	ActionsList {
		Get {
			return this.iActionsList
		}
	}

	ActionLabels[language := false] {
		Get {
			if !language
				language := this.SelectedLanguage

			return (language ? this.iActionLabels[language] : false)
		}
	}

	ActionIcons[language := false] {
		Get {
			if !language
				language := this.SelectedLanguage

			return (language ? this.iActionIcons[language] : false)
		}
	}

	Changed[language := false] {
		Get {
			if !language
				language := this.SelectedLanguage

			return (this.iChanged.Has(language) ? this.iChanged[language] : false)
		}
	}

	__New(configuration) {
		super.__New(configuration)

		ControllerActionsEditor.Instance := this
	}

	createGui(configuration) {
		local choices, chosen, code, language, ignore, thePlugin

		static actionsGui

		saveControllerActionsEditor(*) {
			this.closeEditor(true)
		}

		cancelControllerActionsEditor(*) {
			this.closeEditor(false)
		}

		chooseCALanguage(*) {
			local code, language

			for code, language in availableLanguages()
				if (language = actionsGui["caLanguageDropDown"]) {
					this.selectLanguage(code)

					break
				}
		}

		chooseCAPlugin(*) {
			this.selectPlugin(actionsGui["caPluginDropDown"].Text)
		}

		actionsGui := ControllerActionsEditor.ActionsWindow(this)

		this.Window := actionsGui

		actionsGui.SetFont("Bold", "Arial")

		actionsGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(actionsGui, "Plugin Actions Editor"))

		actionsGui.SetFont("Norm", "Arial")

		actionsGui.Add("Documentation", "x128 YP+20 w148 H:Center Center", translate("Labels && Icons")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#plugin-actions-editor")

		actionsGui.SetFont("Norm", "Arial")

		actionsGui.Add("Text", "x50 yp+30 w310 0x10 W:Grow")

		choices := []
		chosen := 1

		for code, language in availableLanguages() {
			if (code = this.SelectedLanguage)
				chosen := A_Index

			choices.Push(language)
		}

		actionsGui.Add("Text", "x16 yp+10 w86 h23 +0x200", translate("Language"))
		actionsGui.Add("DropDownList", "x110 yp w120 W:Grow Choose" . chosen . " VcaLanguageDropDown", choices).OnEvent("Change", chooseCALanguage)

		choices := []

		for ignore, thePlugin in this.Plugins
			choices.Push(thePlugin)

		actionsGui.Add("Text", "x16 yp+24 w86 h23 +0x200", translate("Plugin"))
		actionsGui.Add("DropDownList", "x110 yp w120 Choose1 VcaPluginDropDown", choices).OnEvent("Change", chooseCAPlugin)

		this.iActionsList := PluginActionsList(this, configuration)
		this.ActionsList.createGui(this, configuration)

		actionsGui.Add("Text", "x50 yp+50 w310 0x10 Y:Move W:Grow")

		actionsGui.Add("Button", "x106 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Save")).OnEvent("Click", saveControllerActionsEditor)
		actionsGui.Add("Button", "x214 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", cancelControllerActionsEditor)
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.iSelectedLanguage := getMultiMapValue(configuration, "Configuration", "Language")

		this.loadPluginActions()
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		return this.savePluginActions()
	}

	loadPluginActions() {
		local plugins := []
		local language, ignore, fileName, labels, section, values, key, value, icons, thePlugin

		for language, ignore in availableLanguages() {
			fileName := ("Controller Action Labels." . language)

			if !FileExist(getFileName(fileName, kUserTranslationsDirectory, kTranslationsDirectory, kResourcesDirectory . "Templates\"))
				fileName := "Controller Action Labels.EN"

			labels := readMultiMap(getFileName(fileName, kTranslationsDirectory, kResourcesDirectory . "Templates\"))

			for section, values in readMultiMap(kUserTranslationsDirectory . fileName)
				for key, value in values
					setMultiMapValue(labels, section, key, value)

			this.iActionLabels[language] := labels

			fileName := ("Controller Action Icons." . language)

			if !FileExist(getFileName(fileName, kUserTranslationsDirectory, kTranslationsDirectory, kResourcesDirectory . "Templates\"))
				fileName := "Controller Action Icons.EN"

			icons := readMultiMap(getFileName(fileName, kTranslationsDirectory, kResourcesDirectory . "Templates\"))

			for section, values in readMultiMap(kUserTranslationsDirectory . fileName)
				for key, value in values
					setMultiMapValue(icons, section, key, value)

			this.iActionIcons[language] := icons

			for thePlugin, ignore in this.ActionLabels[language]
				if !inList(plugins, thePlugin)
					plugins.Push(thePlugin)

			for thePlugin, ignore in this.ActionIcons[language]
				if !inList(plugins, thePlugin)
					plugins.Push(thePlugin)
		}

		this.iPlugins := plugins
	}

	saveModifiedPluginActions(actions, type, language) {
		local fileName := ("Controller Action " . type "." . language)
		local configuration, stdConfiguration, section, values, key, value

		if FileExist(kTranslationsDirectory . fileName) {
			configuration := newMultiMap()
			stdConfiguration := readMultiMap(kTranslationsDirectory . fileName)

			for section, values in actions
				for key, value in values
					if (type = "Labels") {
						if (getMultiMapValue(stdConfiguration, section, key, kUndefined) != value)
							setMultiMapValue(configuration, section, key, value)
					}
					else {
						if (value == false)
							value := ""
						else if (InStr(value, kResourcesDirectory) == 1)
							value := StrReplace(value, kResourcesDirectory, "%kResourcesDirectory%")

						if (value != getMultiMapValue(stdConfiguration, section, key, ""))
							setMultiMapValue(configuration, section, key, value)
					}
		}
		else
			configuration := actions

		writeMultiMap(kUserTranslationsDirectory . "Controller Action " . type "." . language, configuration)
	}

	savePluginActions() {
		local language, ignore

		if !this.ActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin)
			return false

		for language, ignore in availableLanguages()
			if this.Changed[language] {
				if this.ActionLabels[language]
					this.saveModifiedPluginActions(this.ActionLabels[language], "Labels", language)

				if this.ActionIcons[language]
					this.saveModifiedPluginActions(this.ActionIcons[language], "Icons", language)
			}

		return true
	}

	setChanged(language, changed) {
		this.iChanged[language] := changed
	}

	editPluginActions(plugin := false, owner := false) {
		local window, x, y, w, h

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		this.selectLanguage(this.SelectedLanguage, true, plugin)

		if getWindowPosition("Plugin Actions Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Plugin Actions Editor", &w, &h)
			window.Resize("Initialize", w, h)

		try {
			loop {
				loop
					Sleep(200)
				until this.iClosed

				if (this.iClosed == kOk) {
					if this.saveToConfiguration(this.Configuration)
						return true
					else
						this.iClosed := false
				}
				else
					return false
			}
		}
		finally {
			window.Destroy()
		}
	}

	closeEditor(save) {
		this.iClosed := (save ? kOk : kCancel)
	}

	selectLanguage(language, force := false, plugin := false) {
		local languages, code, ignore

		if ((language != this.SelectedLanguage) || force) {
			languages := []

			for code, ignore in availableLanguages()
				languages.Push(code)

			if !force
				if !this.ActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin) {
					this.Control["caLanguageDropDown"].Choose(inList(languages, this.SelectedLanguage))

					return
				}

			this.Control["caLanguageDropDown"].Choose(inList(languages, language))

			this.iSelectedLanguage := language

			this.selectPlugin(plugin ? plugin : this.Plugins[1], true)
		}
	}

	selectPlugin(plugin, force := false) {
		if ((plugin != this.SelectedPlugin) || force) {
			if !force
				if !this.ActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin) {
					this.Control["caPluginDropDown"].Choose(inList(this.Plugins, this.SelectedPlugin))

					return
				}

			this.Control["caPluginDropDown"].Choose(inList(this.Plugins, plugin))

			this.iSelectedPlugin := plugin

			this.ActionsList.loadPluginActions(this.SelectedPlugin)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginActionsList                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PluginActionsList extends ConfigurationItemList {
	iCurrentIcon := false

	AutoSave {
		Get {
			return false
		}
	}

	CurrentIcon {
		Get {
			return this.iCurrentIcon
		}

		Set {
			local icon := (value ? value : (kIconsDirectory . "Empty.png"))

			try {
				this.Control["iconEdit"].Value := ("*w43 *h43 " . icon)
			}
			catch Any as exception {
				this.Control["iconEdit"].Value := ("*w43 *h43 " . kIconsDirectory . "Empty.png")
			}

			return (this.iCurrentIcon := value)
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		PluginActionsList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window

		deleteIcon(*) {
			if this.CurrentItem {
				this.CurrentIcon := false

				window["iconEdit"].Value := ("*w43 *h43 " . kIconsDirectory . "Empty.png")
			}
		}

		clickIcon(*) {
			local pictureFile

			if this.CurrentItem
				if GetKeyState("Ctrl", "P")
					deleteIcon()
				else {
					pictureFile := (this.CurrentIcon ? substituteVariables(this.CurrentIcon) : "")

					window.Opt("+OwnDialogs")

					OnMessage(0x44, translateSelectCancelButtons)
					pictureFile := FileSelect(1, pictureFile, translate("Select Image..."), "Image (*.ico; *.png; *.jpg; *.gif)")
					OnMessage(0x44, translateSelectCancelButtons, 0)

					if (pictureFile != "")
						this.CurrentIcon := pictureFile
				}
		}

		window.Add("ListView", "x16 y120 w377 h240 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VpluginActionsListView", collect(["Action", "Trigger", "Label", "Icon"], translate))

		window.Add("Text", "x16 y370 w76 Y:Move", translate("Label && Icon"))
		window.Add("Edit", "x106 yp w110 h45 Y:Move W:Grow(0.2) VlabelEdit")
		window.Add("Picture", "Border x221 yp w45 h45 Y:Move X:Move(0.2) ViconEdit").OnEvent("Click", clickIcon)

		window.Add("Text", "x269 yp w120 r2 Y:Move X:Move(0.2) c" . window.Theme.TextColor["Disabled"], translate("1. Click = Edit`n2. Ctrl-Click = Clear"))

		window.SetFont()

		this.initializeList(editor, window["pluginActionsListView"])
	}

	loadPluginActions(plugin) {
		local actions := CaseInsenseMap()
		local action, theAction, label, trigger, icon, items, ignore

		for theAction, label in getMultiMapValues(this.Editor.ActionLabels, plugin) {
			action := ConfigurationItem.splitDescriptor(theAction)
			trigger := action[action.Length]

			action.RemoveAt(action.Length)

			action := ((action.Length = 1) ? action[1]: ConfigurationItem.descriptor(action*))

			actions[theAction] := Array(false, action, trigger, label)
		}

		for theAction, icon in getMultiMapValues(this.Editor.ActionIcons, plugin) {
			action := ConfigurationItem.splitDescriptor(theAction)
			trigger := action[action.Length]

			action.RemoveAt(action.Length)

			action := ConfigurationItem.descriptor(action*)

			if (icon && (icon != ""))
				if actions.Has(theAction)
					actions[theAction][1] := icon
				else
					actions[theAction] := Array(icon, action, trigger, "")
		}

		items := []

		for ignore, action in actions
			items.Push(action)

		this.ItemList := items

		this.loadList(items)
	}

	savePluginActions(language, plugin) {
		local actionLabels, actionIcons, changed, ignore, action, descriptor

		this.selectEvent(false)

		this.clearEditor()
		this.selectItem(false)

		actionLabels := getMultiMapValues(this.Editor.ActionLabels, plugin)
		actionIcons := getMultiMapValues(this.Editor.ActionIcons, plugin)

		changed := false

		for ignore, action in this.ItemList {
			descriptor := ConfigurationItem.descriptor(action[2], action[3])

			if actionLabels.Has(descriptor) {
				if (actionLabels[descriptor] != action[4]) {
					actionLabels[descriptor] := action[4]

					changed := true
				}
			}
			else if (action[4] && (action[4] != "")) {
				actionLabels[descriptor] := action[4]

				changed := true
			}

			if actionIcons.Has(descriptor) {
				if (actionIcons[descriptor] != action[1]) {
					actionIcons[descriptor] := action[1]

					changed := true
				}
			}
			else if (action[1] && (action[1] != "")) {
				actionIcons[descriptor] := action[1]

				changed := true
			}
		}

		if changed {
			this.Editor.setChanged(language, true)

			setMultiMapValues(this.Editor.ActionLabels, plugin, actionLabels)
			setMultiMapValues(this.Editor.ActionIcons, plugin, actionIcons)
		}

		return true
	}

	selectEvent(line) {
		local action

		if (this.CurrentItem && (line != this.CurrentItem)) {
			action := this.buildItemFromEditor()

			if action {
				this.ItemList[this.CurrentItem] := action

				this.Control["pluginActionsListView"].Modify(this.CurrentItem, "", action[2], action[3], StrReplace(StrReplace(action[4], "`n", A_Space), "`r", ""), action[1] ? action[1] : "")
			}
		}

		if line
			super.selectEvent(line)
	}

	loadList(items) {
		local action, length, picturesListViewImages, ignore, item, picture

		this.Control["pluginActionsListView"].Delete()

		if false {
			length := items.Length

			picturesListViewImages := IL_Create(length)

			for ignore, item in items {
				picture := LoadPicture(item[1] ? item[1] : (kIconsDirectory . "Empty.png"),"W43 H43")

				IL_Add(picturesListViewImages, picture)
			}

			this.Control["pluginActionsListView"].SetImageList(picturesListViewImages)
		}

		for ignore, action in items
			this.Control["pluginActionsListView"].Add("", action[2], action[3], StrReplace(StrReplace(action[4], "`n", A_Space), "`r", ""), action[1] ? action[1] : "")

		this.Control["pluginActionsListView"].ModifyCol(1, 100)
		this.Control["pluginActionsListView"].ModifyCol(2, "AutoHdr")
		this.Control["pluginActionsListView"].ModifyCol(3, "AutoHdr")
		this.Control["pluginActionsListView"].ModifyCol(4, "AutoHdr")
	}

	updateState() {
		super.updateState()

		if this.CurrentItem {
			this.Control["labelEdit"].Enabled := true

			try
				this.Control["íconEdit"].Enabled := true
		}
		else {
			this.Control["labelEdit"].Enabled := false

			try
				this.Control["íconEdit"].Enabled := false
		}
	}

	loadEditor(item) {
		local icon

		this.Control["labelEdit"].Value := item[4]

		this.CurrentIcon := (item[1] ? substituteVariables(item[1]) : (kIconsDirectory . "Empty.png"))

		this.updateState()
	}

	clearEditor() {
		this.Control["labelEdit"].Value := ""
		this.Control["iconEdit"].Value := ("*w43 *h43 " . kIconsDirectory . "Empty.png")

		this.updateState()
	}

	buildItemFromEditor(isNew := false) {
		local action := this.ItemList[this.CurrentItem].Clone()

		action[4] := this.Control["labelEdit"].Text
		action[1] := this.CurrentIcon

		return action
	}
}