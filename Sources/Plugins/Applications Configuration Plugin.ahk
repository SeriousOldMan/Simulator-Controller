;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Applications Configuration      ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global applicationsListView = false

global applicationNameEdit = ""
global applicationExePathEdit = ""
global applicationWorkingDirectoryPathEdit = ""
global applicationWindowTitleEdit = ""
global applicationStartupEdit = ""
global applicationShutdownEdit = ""
global applicationIsRunningEdit = ""

global applicationAddButton
global applicationDeleteButton
global applicationUpdateButton
		
class ApplicationsConfigurator extends ConfigurationItemList {
	iEditor := false
	
	Editor[] {
		Get {
			return this.iEditor
		}
	}
	
	Applications[types := false] {
		Get {
			result := []
			
			for index, theApplication in this.ItemList
				if !types
					result.Push(theApplication[2])
				else if inList(types, theApplication[1])
					result.Push(theApplication[2])
				
			return result
		}
	}
	
	__New(editor, configuration) {
		this.iEditor := editor
		
		base.__New(configuration)
				 
		ApplicationsConfigurator.Instance := this
	}
					
	createGui(editor, x, y, width, height) {
		window := editor.Window
		
		Gui %window%:Add, ListView, x16 y80 w457 h205 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndapplicationsListViewHandle VapplicationsListView glistEvent
						, % values2String("|", map(["Type", "Name", "Executable", "Window Title", "Working Directory"], "translate")*)
		
		Gui %window%:Add, Text, x16 y295 w141 h23 +0x200, % translate("Name")
		Gui %window%:Add, Edit, x180 y295 w268 h21 VapplicationNameEdit, %applicationNameEdit%
		
		Gui %window%:Add, Text, x16 y319 w138 h23 +0x200, % translate("Executable")
		Gui %window%:Add, Edit, x180 y319 w268 h21 VapplicationExePathEdit, %applicationExePathEdit%
		Gui %window%:Add, Button, x451 y318 w23 h23 gchooseApplicationExePath, % translate("...")
		
		Gui %window%:Add, Text, x16 y343 w138 h23 +0x200, % translate("Working Directory (optional)")
		Gui %window%:Add, Edit, x180 y343 w268 h21 VapplicationWorkingDirectoryPathEdit, %applicationWorkingDirectoryPathEdit%
		Gui %window%:Add, Button, x451 y342 w23 h23 gchooseApplicationWorkingDirectoryPath, % translate("...")
		
		Gui %window%:Add, Text, x16 y367 w140 h23 +0x200, % translate("Window Title (optional)")
		Gui %window%:Font, c505050 s8
		Gui %window%:Add, Text, x24 y385 w133 h23, % translate("(Use AHK WinTitle Syntax)")
		Gui %window%:Font
		Gui %window%:Add, Edit, x180 y367 w268 h21 VapplicationWindowTitleEdit, %applicationWindowTitleEdit%
		
		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial
		
		Gui %window%:Add, GroupBox, x16 y411 w458 h71, % translate("Function Hooks (optional)")
		
		Gui %window%:Font, Norm, Arial
		
		Gui %window%:Add, Text, x20 y427 w136 h23 +0x200 +Center, % translate("Startup")
		Gui %window%:Add, Edit, x20 y451 w136 h21 VapplicationStartupEdit, %applicationStartupEdit%
		
		Gui %window%:Add, Text, x177 y427 w136 h23 +0x200 +Center, % translate("Shutdown ")
		Gui %window%:Add, Edit, x177 y451 w136 h21 VapplicationShutdownEdit, %applicationShutdownEdit%
		
		Gui %window%:Add, Text, x334 y427 w136 h23 +0x200 +Center, % translate("Running?")
		Gui %window%:Add, Edit, x334 y451 w136 h21 VapplicationIsRunningEdit, %applicationIsRunningEdit%

		Gui %window%:Add, Button, x264 y490 w46 h23 VapplicationAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VapplicationDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VapplicationUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(applicationsListViewHandle, "applicationsListView", "applicationAddButton", "applicationDeleteButton", "applicationUpdateButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
	
		for descriptor, name in getConfigurationSectionValues(configuration, "Applications", Object())
			this.ItemList.Push(Array(translate(ConfigurationItem.splitDescriptor(descriptor)[1]), new Application(name, configuration)))
	}
		
	saveToConfiguration(configuration) {
		local count := 0
		
		base.saveToConfiguration(configuration)
		
		lastType := ""
		
		for index, theApplication in this.ItemList {
			type := theApplication[1]
			theApplication := theApplication[2]
			
			if (type != lastType) {
				count := 1
				lastType := type
			}
			else
				count += 1
		
			types := ["Core", "Feedback", "Other"]
			
			setConfigurationValue(configuration, "Applications"
								, ConfigurationItem.descriptor(types[inList(map(types, "translate"), type)], count), theApplication.Application)
		
			theApplication.saveToConfiguration(configuration)
		}
	}
	
	updateState() {
		base.updateState()
		
		if (this.CurrentItem != 0) {
			theApplication := this.ItemList[this.CurrentItem]
			
			type := theApplication[1]
			
			if (type != translate("Other")) {
				GuiControl Disable, applicationNameEdit
				GuiControl Disable, applicationDeleteButton
			}
			else {
				GuiControl Enable, applicationNameEdit
				GuiControl Enable, applicationDeleteButton
			}
			
			GuiControl Enable, applicationUpdateButton
		}
		else {
			GuiControl Enable, applicationNameEdit
			GuiControl Disable, applicationDeleteButton
			GuiControl Disable, applicationUpdateButton
		}
	
		if LaunchpadConfigurator.Instance
			LaunchpadConfigurator.Instance.loadApplicationChoices(true)
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		for index, theApplication in items {
			type := theApplication[1]
			theApplication := theApplication[2]
			
			LV_Add("", type, theApplication.Application, theApplication.ExePath, theApplication.WindowTitle, theApplication.WorkingDirectory)
		}
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "Center AutoHdr")
			LV_ModifyCol(2, 120)
			LV_ModifyCol(3, 80)
			LV_ModifyCol(4, 80)
			
			first := false
		}
	}
	
	loadEditor(item) {
		theApplication := item[2]
		
		applicationNameEdit := theApplication.Application
		applicationExePathEdit := theApplication.ExePath
		applicationWorkingDirectoryPathEdit := theApplication.WorkingDirectory
		applicationWindowTitleEdit := theApplication.WindowTitle
		applicationStartupEdit := (theApplication.SpecialStartup ? theApplication.SpecialStartup : "")
		applicationShutdownEdit := (theApplication.SpecialShutdown ? theApplication.SpecialShutdown : "")
		applicationIsRunningEdit := (theApplication.SpecialIsRunning ? theApplication.SpecialIsRunning : "")
		
		GuiControl Text, applicationNameEdit, %applicationNameEdit%
		GuiControl Text, applicationExePathEdit, %applicationExePathEdit%
		GuiControl Text, applicationWorkingDirectoryPathEdit, %applicationWorkingDirectoryPathEdit%
		GuiControl Text, applicationWindowTitleEdit, %applicationWindowTitleEdit%
		GuiControl Text, applicationStartupEdit, %applicationStartupEdit%
		GuiControl Text, applicationShutdownEdit, %applicationShutdownEdit%
		GuiControl Text, applicationIsRunningEdit, %applicationIsRunningEdit%
	}
	
	clearEditor() {
		applicationNameEdit := ""
		applicationExePathEdit := ""
		applicationWorkingDirectoryPathEdit := ""
		applicationWindowTitleEdit := ""
		applicationStartupEdit := ""
		applicationShutdownEdit := ""
		applicationIsRunningEdit := ""
		
		GuiControl Text, applicationNameEdit, %applicationNameEdit%
		GuiControl Text, applicationExePathEdit, %applicationExePathEdit%
		GuiControl Text, applicationWorkingDirectoryPathEdit, %applicationWorkingDirectoryPathEdit%
		GuiControl Text, applicationWindowTitleEdit, %applicationWindowTitleEdit%
		GuiControl Text, applicationStartupEdit, %applicationStartupEdit%
		GuiControl Text, applicationShutdownEdit, %applicationShutdownEdit%
		GuiControl Text, applicationIsRunningEdit, %applicationIsRunningEdit%
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet applicationNameEdit
		GuiControlGet applicationExePathEdit
		GuiControlGet applicationWorkingDirectoryPathEdit
		GuiControlGet applicationWindowTitleEdit
		GuiControlGet applicationStartupEdit
		GuiControlGet applicationShutdownEdit
		GuiControlGet applicationIsRunningEdit
		
		return Array(isNew ? translate("Other") : this.ItemList[this.CurrentItem][1]
				   , new Application(applicationNameEdit, false, applicationExePathEdit, applicationWorkingDirectoryPathEdit, applicationWindowTitleEdit
				   , applicationStartupEdit, applicationShutdownEdit, applicationIsRunningEdit))
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseApplicationExePath() {
	protectionOn()
	
	try {
		GuiControlGet applicationExePathEdit
		
		title := translate("Select application executable...")
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
		FileSelectFile file, 1, %applicationExePathEdit%, %title%, Executable (*.exe)
		OnMessage(0x44, "")
		
		if (file != "") {
			GuiControl Text, applicationExePathEdit, %file%
			
			applicationWorkingDirectoryPathEdit := ""
			
			GuiControl Text, applicationWorkingDirectoryPathEdit, %applicationWorkingDirectoryPathEdit%
		}
	}
	finally {
		protectionOff()
	}
}

chooseApplicationWorkingDirectoryPath() {
	protectionOn()
	
	try {
		GuiControlGet applicationWorkingDirectoryPathEdit
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder directory, *%applicationWorkingDirectoryPathEdit%, 0, % translate("Select working directory...")
		OnMessage(0x44, "")
		
		if (directory != "")
			GuiControl Text, applicationWorkingDirectoryPathEdit, %directory%
	}
	finally {
		protectionOff()
	}
}


initializeApplicationsConfigurator() {
	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance
		
		editor.registerConfigurator(translate("Applications"), new ApplicationsConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsConfigurator()