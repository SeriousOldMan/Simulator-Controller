;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Plugin Actions Editor           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ConfigurationItemList.ahk
#Include Libraries\ConfigurationEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginActionsEditor                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global paLanguageDropDown
global paPluginDropDown

class PluginActionsEditor extends ConfigurationItem {
	iClosed := false
	
	iPluginActionsList := false
	
	iPlugins := []
	
	iSelectedLanguage := false
	iSelectedPlugin := false
	
	iChanged := {}
	
	iActionLabels := {}
	iActionIcons := {}
	
	Plugins[index := false] {
		Get {
			return (index ? this.iPlugins[index] : this.iPlugins)
		}
	}
	
	SelectedLanguage[] {
		Get {
			return this.iSelectedLanguage
		}
	}
	
	SelectedPlugin[] {
		Get {
			return this.iSelectedPlugin
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
			
			return (this.iChanged.HasKey(language) ? this.iChanged[language] : false)
		}
	}
	
	__New(configuration) {
		this.iPluginActionsList := new PluginActionsList(configuration)
		
		base.__New(configuration)
		
		PluginActionsEditor.Instance := this
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Gui PAE:Default
	
		Gui PAE:-Border ; -Caption
		Gui PAE:Color, D0D0D0, D8D8D8

		Gui PAE:Font, Bold, Arial

		Gui PAE:Add, Text, w388 Center gmovePluginActionsEditor, % translate("Modular Simulator Controller System") 
		
		Gui PAE:Font, Norm, Arial
		Gui PAE:Font, Italic Underline, Arial

		Gui PAE:Add, Text, YP+20 w388 cBlue Center gopenPluginActionsDocumentation, % translate("Labels && Icons")

		Gui PAE:Font, Norm, Arial
		
		Gui PAE:Add, Text, x50 yp+30 w310 0x10
		
		choices := []
		chosen := 1
		
		for code, language in availableLanguages() {
			if (code = this.SelectedLanguage)
				chosen := A_Index
			
			choices.Push(language)
		}
		
		Gui PAE:Add, Text, x16 yp+10 w86 h23 +0x200, % translate("Language")
		Gui PAE:Add, DropDownList, x110 yp w120 Choose%chosen% VpaLanguageDropDown gchoosePALanguage, % values2String("|", choices*)
		
		choices := []
		
		for ignore, thePlugin in this.Plugins {
			choices.Push(thePlugin)
		}
		
		Gui PAE:Add, Text, x16 yp+24 w86 h23 +0x200, % translate("Plugin")
		Gui PAE:Add, DropDownList, x110 yp w120 Choose1 VpaPluginDropDown gchoosePAPlugin, % values2String("|", choices*)
		
		this.iPluginActionsList.createGui(configuration)
		
		Gui PAE:Add, Text, x50 yp+50 w310 0x10
		
		Gui PAE:Add, Button, x106 yp+10 w80 h23 Default GsavePluginActionsEditor, % translate("Save")
		Gui PAE:Add, Button, x214 yp w80 h23 GcancelPluginActionsEditor, % translate("&Cancel")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iSelectedLanguage := getConfigurationValue(configuration, "Configuration", "Language")
		
		this.loadPluginActions()
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		return this.savePluginActions()
	}
	
	loadPluginActions() {
		plugins := []
			
		for language, ignore in availableLanguages() {
			fileName := getFileName("Controller Action Labels." . language
								  , kUserTranslationsDirectory, kTranslationsDirectory, kResourcesDirectory . "Templates\")
			
			if FileExist(fileName)
				this.iActionLabels[language] := readConfiguration(fileName)
			else
				this.iActionLabels[language] := readConfiguration(getFileName("Controller Action Labels.EN", kUserTranslationsDirectory, kTranslationsDirectory))
			
			fileName := getFileName("Controller Action Icons." . language
								  , kUserTranslationsDirectory, kTranslationsDirectory, kResourcesDirectory . "Templates\")
			
			if FileExist(fileName)
				this.iActionIcons[language] := readConfiguration(fileName)
			else
				this.iActionIcons[language] := readConfiguration(getFileName("Controller Action Icons.EN", kUserTranslationsDirectory, kTranslationsDirectory))
			
			for thePlugin, ignore in this.ActionLabels[language]
				if !inList(plugins, thePlugin)
					plugins.Push(thePlugin)
			
			for thePlugin, ignore in this.ActionIcons[language]
				if !inList(plugins, thePlugin)
					plugins.Push(thePlugin)
		}
			
		this.iPlugins := plugins
	}
	
	savePluginActions() {
		if !this.iPluginActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin)
			return false
		
		for language, ignore in availableLanguages() {
			if this.Changed[language] {
				if this.ActionLabels[language]
					writeConfiguration(kUserTranslationsDirectory . "Controller Action Labels." . language, this.ActionLabels[language])
				
				if this.ActionIcons[language]
					writeConfiguration(kUserTranslationsDirectory . "Controller Action Icons." . language, this.ActionIcons[language])
			}
		}
		
		return true
	}
	
	setChanged(language, changed) {
		this.iChanged[language] := changed
	}
	
	editPluginActions(plugin) {
		this.selectLanguage(this.SelectedLanguage, true, plugin)
		
		Gui PAE:Show, AutoSize Center

restart:
		Loop
			Sleep 200
		until this.iClosed
		
		try {
			if (this.iClosed == kOk) {
				if !this.saveToConfiguration(this.Configuration) {
					this.iClosed := false
					
					Goto restart
				}
					
			
				return true
			}
			else
				return false
		}
		finally {
			Gui PAE:Destroy
		}
	}
	
	closeEditor(save) {
		if save
			Gui PAE:Submit
		
		this.iClosed := (save ? kOk : kCancel)
	}
	
	selectLanguage(language, force := false, plugin := false) {
		if ((language != this.SelectedLanguage) || force) {
			languages := []
			
			for code, ignore in availableLanguages()
				languages.Push(code)
			
			if !force
				if !this.iPluginActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin) {
					GuiControl Choose, paLanguageDropDown, % inList(languages, this.SelectedLanguage)
					
					return
				}
				
			GuiControl Choose, paLanguageDropDown, % inList(languages, language)
			
			this.iSelectedLanguage := language
			
			this.selectPlugin(plugin ? plugin : this.Plugins[1], true)
		}
	}
	
	selectPlugin(plugin, force := false) {
		if ((plugin != this.SelectedPlugin) || force) {
			if !force
				if !this.iPluginActionsList.savePluginActions(this.SelectedLanguage, this.SelectedPlugin) {
					GuiControl Choose, paPluginDropDown, % inList(this.Plugins, this.SelectedPlugin)
					
					return
				}
				
			GuiControl Choose, paPluginDropDown, % inList(this.Plugins, plugin)
			
			this.iSelectedPlugin := plugin
			
			this.iPluginActionsList.loadPluginActions(this.SelectedPlugin)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; PluginActionsList                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global pluginActionsListView = false
global labelEdit = ""
global iconEdit
global deleteIconButton
		
class PluginActionsList extends ConfigurationItemList {
	iCurrentIcon := false
	
	AutoSave[] {
		Get {
			return false
		}
	}
	
	__New(configuration) {
		base.__New(configuration)
				 
		PluginActionsList.Instance := this
	}
					
	createGui(configuration) {
		Gui PAE:Add, ListView, x16 y120 w377 h240 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndpluginActionsListViewHandle VpluginActionsListView glistEvent
							 , % values2String("|", map(["Action", "Trigger", "Label", "Icon"], "translate")*)
		
		Gui PAE:Add, Text, x16 y370 w76 h23 +0x200, % translate("Label && Icon")
		Gui PAE:Add, Edit, x100 yp w110 h45 VlabelEdit, %labelEdit%
		Gui PAE:Add, Picture, Border x215 yp w45 h45 ViconEdit gclickIcon
		
		Gui PAE:Font, c505050 s8
		Gui PAE:Add, Text, x263 yp w120 r2, % translate("1. Click = Set`n2. Ctrl-Click = Clear")
		Gui PAE:Font
		
		; Gui PAE:Add, Button, x283 yp w23 h23 HwnddeleteIconButtonHandle VdeleteIconButton gdeleteIcon
		; setButtonIcon(deleteIconButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		
		this.initializeList(pluginActionsListViewHandle, "pluginActionsListView")
	}
	
	loadPluginActions(plugin) {
		editor := PluginActionsEditor.Instance
		actions := {}
		
		for theAction, label in getConfigurationSectionValues(editor.ActionLabels, plugin, Object()) {
			action := ConfigurationItem.splitDescriptor(theAction)
			trigger := action[action.Length()]
			
			action.RemoveAt(action.Length())
			
			action := ((action.Length() = 1) ? action[1]: ConfigurationItem.descriptor(action*))
			
			actions[theAction] := Array(false, action, trigger, label)
		}
		
		for theAction, icon in getConfigurationSectionValues(editor.ActionIcons, plugin, Object()) {
			action := ConfigurationItem.splitDescriptor(theAction)
			trigger := action[action.Length()]
			
			action.RemoveAt(action.Length())
			
			action := ConfigurationItem.descriptor(action*)
			
			if (icon && (icon != ""))
				if actions.HasKey(theAction)
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
		this.selectEvent(false)
		
		this.clearEditor()
		this.selectItem(false)
		
		editor := PluginActionsEditor.Instance
		
		actionLabels := getConfigurationSectionValues(editor.ActionLabels, plugin)
		actionIcons := getConfigurationSectionValues(editor.ActionIcons, plugin)
		
		changed := false
			
		for ignore, action in this.ItemList {
			descriptor := ConfigurationItem.descriptor(action[2], action[3])
			
			if actionLabels.HasKey(descriptor) {
				if (actionLabels[descriptor] != action[4]) {
					actionLabels[descriptor] := action[4]
					
					changed := true
				}
			}
			else if (action[4] && (action[4] != "")) {
				actionLabels[descriptor] := action[4]
					
				changed := true
			}
		
			if actionIcons.HasKey(descriptor) {
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
			editor.setChanged(language, true)
			
			setConfigurationSectionValues(editor.ActionLabels, plugin, actionLabels)
			setConfigurationSectionValues(editor.ActionIcons, plugin, actionIcons)
		}
		
		return true
	}
	
	selectEvent(line) {
		if (this.CurrentItem && (line != this.CurrentItem)) {
			action := this.buildItemFromEditor()
				
			if action {
				this.ItemList[this.CurrentItem] := action
				
				Gui ListView, % this.ListHandle
				
				LV_Modify(this.CurrentItem, "", action[2], action[3], StrReplace(action[4], "`n", A_Space), action[1] ? action[1] : "")
			}
		}
		
		if (line)
			base.selectEvent(line)
	}
	
	loadList(items) {
		Gui PAE:Default
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		if false {
			length := items.Length()
			
			picturesListViewImages := IL_Create(length)
			
			for ignore, item in items {
				picture := LoadPicture(item[1] ? item[1] : (kIconsDirectory . "Empty.png"), "W43 H43")
				
				IL_Add(picturesListViewImages, picture)
			}
			
			LV_SetImageList(picturesListViewImages)
		}
		
		for ignore, action in items
			LV_Add("", action[2], action[3], StrReplace(action[4], "`n", A_Space), action[1] ? action[1] : "")
		
		LV_ModifyCol()
		LV_ModifyCol(1, 100)
	}
	
	updateState() {
		Gui PAE:Default
		
		base.updateState()
		
		if this.CurrentItem {
			GuiControl Enable, labelEdit
			
			try
				GuiControl Enable, íconEdit
	
			try
				GuiControl Enable, deleteIconButton
		}
		else {
			GuiControl Disable, labelEdit
			
			try
				GuiControl Disable, íconEdit
			
			try
				GuiControl Disable, deleteIconButton
		}
	}
	
	loadEditor(item) {
		GuiControl, , labelEdit, % item[4]
		
		icon := (item[1] ? item[1] : (kIconsDirectory . "Empty.png"))
		
		try {
			GuiControl, , iconEdit, % ("*w43 *h43 " . icon)
		}
		catch exception {
			item[1] := false
			
			GuiControl, , iconEdit, % ("*w43 *h43 " . kIconsDirectory . "Empty.png")
		}
		
		this.iCurrentIcon := item[1]
		
		this.updateEditor()
	}
	
	clearEditor() {
		GuiControl, , labelEdit, % ""
		GuiControl, , iconEdit, % ("*w43 *h43 " . kIconsDirectory . "Empty.png")
		
		this.updateEditor()
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet labelEdit
		
		action := this.ItemList[this.CurrentItem].Clone()
		
		action[4] := labelEdit
		action[1] := this.iCurrentIcon
		
		return action
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

savePluginActionsEditor() {
	PluginActionsEditor.Instance.closeEditor(true)
}

cancelPluginActionsEditor() {
	PluginActionsEditor.Instance.closeEditor(false)
}

movePluginActionsEditor() {
	moveByMouse("PAE")
}

openPluginActionsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#plugin-actions-editor
}

choosePALanguage() {
	GuiControlGet paLanguageDropDown
	
	for code, language in availableLanguages()
		if (language = paLanguageDropDown) {
			PluginActionsEditor.Instance.selectLanguage(code)
			
			break
		}
}

choosePAPlugin() {
	GuiControlGet paPluginDropDown
	
	PluginActionsEditor.Instance.selectPlugin(paPluginDropDown)
}

deleteIcon() {
	actionsList := PluginActionsList.Instance

	if actionsList.CurrentItem {
		actionsList.iCurrentIcon := false
		
		GuiControl, , iconEdit, % ("*w43 *h43 " . kIconsDirectory . "Empty.png")
	}
}

clickIcon() {
	actionsList := PluginActionsList.Instance
	
	if actionsList.CurrentItem
		if GetKeyState("Ctrl", "P")
			deleteIcon()
		else {
			title := translate("Select Image...")
	
			pictureFile := (actionsList.iCurrentIcon ? actionsList.iCurrentIcon : "")
			
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
			FileSelectFile pictureFile, 1, %pictureFile%, %title%, Image (*.ico; *.png; *.jpg; *.gif)
			OnMessage(0x44, "")
			
			if (pictureFile != "") {
				actionsList.iCurrentIcon := pictureFile
				
				icon := (pictureFile ? pictureFile : (kIconsDirectory . "Empty.png"))
		
				try {
					GuiControl, , iconEdit, % ("*w43 *h43 " . icon)
				}
				catch exception {
					pictureFile := false
					
					GuiControl, , iconEdit, % ("*w43 *h43 " . kIconsDirectory . "Empty.png")
				}
				
				actionsList.iCurrentIcon := pictureFile
			}
		}
}