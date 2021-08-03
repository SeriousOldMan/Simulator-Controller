;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Step Wizard          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxStepWizard                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxStepWizard extends StepWizard {
	iButtonBoxEditor := false
	
	iFunctionsListView := false
	
	iFunctionTriggers := {}
		
	class StepButtonBoxEditor extends ButtonBoxEditor {
		configurationChanged(name) {
			base.configurationChanged(name)
			
			configuration := newConfiguration()
			
			this.saveToConfiguration(configuration)
			
			writeConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini", configuration)
			
			protectionOn()
	
			oldGui := A_DefaultGui
			
			try {
				SetupWizard.Instance.StepWizards["Button Box"].loadFunctions(configuration)
			}
			finally {
				protectionOff()
				
				Gui %oldGui%:Default
			}
		}
	}
	
	Pages[] {
		Get {
			definition := this.Definition
			
			return (this.SetupWizard.isModuleSelected(definition[1]) ? 1 : 0)
		}
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		controllerConfiguration := readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini")
		wizard := this.SetupWizard
		
		if wizard.isModuleSelected("Button Box") {
			controls := {}
			
			for control, descriptor in getConfigurationSectionValues(controllerConfiguration, "Controls")
				controls[control] := string2Values(";", descriptor)[1]
			
			for controller, definition in getConfigurationSectionValues(controllerConfiguration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)
			
				if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
					controller := controller[1]
				
					for ignore, control in string2Values(";", definition) {
						control := string2Values(",", control)[1]
					
						if (control != "") {
							control := ConfigurationItem.splitDescriptor(control)
							theFunction := ConfigurationItem.descriptor(controls[control[1]], control[2])
							
							functionTriggers := wizard.getControllerFunctionTriggers(theFunction)
							
							if (functionTriggers.Length() > 0) {
								theFunction := Function.createFunction(theFunction, false, functionTriggers[1], "", functionTriggers[2], "")
								
								theFunction.saveToConfiguration(configuration)
							}
						}
					}
				}
			}
		}
	}
	
	createGui(wizard, x, y, width, height) {
		local application
		
		static functionsInfoText
		
		window := this.Window
		
		Gui %window%:Default
		
		functionsIconHandle := false
		functionsIconLabelHandle := false
		functionsListViewHandle := false
		functionsInfoTextHandle := false
		
		labelWidth := width - 30
		labelX := x + 45
		labelY := y + 8
		
		Gui %window%:Font, s10 Bold, Arial
		
		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDfunctionsIconHandle Hidden, %kResourcesDirectory%Setup\Images\Controller.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDfunctionsLabelHandle Hidden, % translate("Controller Layout && Triggers")
		
		Gui %window%:Font, s8 Norm, Arial
		
		Gui Add, ListView, x%x% yp+30 w%width% h300 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDfunctionsListViewHandle gupdateFunctionTriggers Hidden, % values2String("|", map(["Controller / Button Box", "Control", "Function", "Number", "Trigger(s)", "Hints & Conflicts"], "translate")*)
		
		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.Button Box", "Button Box.Functions.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'>" . info . "</div>"
		
		Gui %window%:Add, ActiveX, x%x% yp+305 w%width% h135 HWNDfunctionsInfoTextHandle VfunctionsInfoText Hidden, shell explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		functionsInfoText.Navigate("about:blank")
		functionsInfoText.Document.Write(html)
		
		this.ifunctionsListView := functionsListViewHandle
		
		this.registerWidgets(1, functionsIconHandle, functionsLabelHandle, functionsListViewHandle, functionsInfoTextHandle)
	}
	
	reset() {
		base.reset()
		
		this.iFunctionsListView := false
		this.iFunctionTriggers := {}
		
		if this.iButtonBoxEditor {
			this.iButtonBoxEditor.close(true)
			
			this.iButtonBoxEditor := false
		}		
	}
	
	showPage(page) {
		base.showPage(page)
		
		if !FileExist(kUserHomeDirectory . "Install\Button Box Configuration.ini")
			FileCopy %kResourcesDirectory%Setup\Button Box Configuration.ini, %kUserHomeDirectory%Install\Button Box Configuration.ini
			
		this.iButtonBoxEditor := new this.StepButtonBoxEditor("Default", this.SetupWizard.Configuration, kUserHomeDirectory . "Install\Button Box Configuration.ini", false)
		
		this.iButtonBoxEditor.open(Min(A_ScreenWidth - Round(A_ScreenWidth / 3) + Round(A_ScreenWidth / 3 / 2) - 225, A_ScreenWidth - 450))
		
		this.loadFunctions(readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini"), true)
	}
	
	hidePage(page) {
		configuration := readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini")
		
		if (this.conflictingFunctions(configuration) || this.conflictingTriggers(configuration)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Setup")
			MsgBox 262160, %title%, % translate("There are still duplicate functions or duplicate triggers - please correct...")
			OnMessage(0x44, "")
			
			return false
		}
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		if (LV_GetCount() != this.iFunctionTriggers.Length()) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Setup")
			MsgBox 262436, %title%, % translate("Not all functions have been assigned to physical controls. Do you really want to proceed?")
			OnMessage(0x44, "")
			
			IfMsgBox No
				return false
		}
		
		if base.hidePage(page) {
			this.iButtonBoxEditor.close(true)
			
			this.iButtonBoxEditor := false
		
			this.SetupWizard.setControllerFunctions(this.controllerFunctions(configuration))
			
			return true
		}
		else
			return false
	}
	
	controllerFunctions(configuration) {
		local function
		
		controls := {}
		functions := {}
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]
					function := ConfigurationItem.splitDescriptor(function)
					function := ConfigurationItem.descriptor(controls[function[1]], function[2])
				
					if (function != "")
						if this.iFunctionTriggers.HasKey(function)
							functions.Push(Array(function, this.iFunctionTriggers[function]*))
						else
							functions.Push(function)
				}
			}
		}
				
		return functions
	}
	
	conflictingFunctions(configuration) {
		local function
		
		controls := {}
		functions := {}
		conflict := false
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]
				
				for ignore, function in string2Values(";", definition) {
					function := string2Values(",", function)[1]
				
					if (function != "") {
						function := ConfigurationItem.splitDescriptor(function)
						function := ConfigurationItem.descriptor(controls[function[1]], function[2])
						
						if !functions.HasKey(function)
							functions[function] := [controller]
						else {
							functions[function].Push(controller)
						
							conflict := true
						}
					}
				}
			}
		}
		
		return (conflict ? functions : false)
	}
	
	conflictingTriggers(configuration) {
		local function
		
		triggers := {}
		conflict := false
		
		for function, functionTriggers in this.iFunctionTriggers
			for ignore, trigger in functionTriggers
				if !triggers.HasKey(trigger)
					triggers[trigger] := [function]
				else {
					triggers[trigger].Push(function)
				
					conflict := true
				}
		
		return (conflict ? triggers : false)
	}
	
	loadFunctions(configuration, load := false) {
		local function
		
		controls := {}
		
		for control, descriptor in getConfigurationSectionValues(configuration, "Controls")
			controls[control] := string2Values(";", descriptor)[1]
		
		window := this.Window
		wizard := this.SetupWizard
		
		Gui %window%:Default
		
		Gui ListView, % this.iFunctionsListView
		
		if load
			this.iFunctionTriggers := {}
		
		LV_Delete()
		
		lastController := false
		
		functionConflicts := this.conflictingFunctions(configuration)
		triggerConflicts := this.conflictingTriggers(configuration)
		
		for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
			controller := ConfigurationItem.splitDescriptor(controller)
		
			if ((controller[2] != "Layout") && (controller[2] != "Visible")) {
				controller := controller[1]
			
				for ignore, control in string2Values(";", definition) {
					control := string2Values(",", control)[1]
				
					if (control != "") {
						control := ConfigurationItem.splitDescriptor(control)
						function := ConfigurationItem.descriptor(controls[control[1]], control[2])
						
						first := (controller != lastController)
						lastController := controller
				
						if this.iFunctionTriggers.HasKey(function)
							functionTriggers := this.iFunctionTriggers[function]
						else
							functionTriggers := wizard.getControllerFunctionTriggers(function)
						
						conflict := 0
						
						if (functionConflicts && functionConflicts[function].Length() > 1)
							conflict += 1
						
						if triggerConflicts
							for ignore, trigger in functionTriggers
								if (triggerConflicts[trigger].Length() > 1) {
									conflict += 2
									
									break
								}
							
						if (conflict == 1)
							conflict := translate("Duplicate function...")
						else if (conflict == 2)
							conflict := translate("Duplicate trigger(s)...")
						else if (conflict == 3)
							conflict := translate("Duplicate function and duplicate trigger(s)...")
						else
							conflict := ""
						
						if (functionTriggers.Length() > 0) {
							triggers := values2String(" | ", functionTriggers*)
							
							if load
								this.iFunctionTriggers[function] := functionTriggers
						}
						else
							triggers := ""
						
						LV_Add("", (first ? controller : ""), control[1], translate(controls[control[1]]), control[2], triggers, conflict)
					}
				}
			}
		}
			
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
		LV_ModifyCol(4, "AutoHdr Integer Center")
		LV_ModifyCol(5, "AutoHdr")
		LV_ModifyCol(6, "AutoHdr")
	}
	
	updateFunctionTriggers(row) {
		local function
		
		wizard := this.SetupWizard
		
		if this.iTriggerModeActive
			wizard.toggleTriggerDetector()
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		LV_GetText(type, row, 3)
		LV_GetText(number, row, 4)
		
		switch type {
			case translate(k2WayToggleType):
				callback := ObjBindMethod(this, "registerHotkey", k2WayToggleType . "." . number, row, true)
			case translate(kDialType):
				callback := ObjBindMethod(this, "registerHotkey", kDialType . "." . number, row, true)
			case translate(k1WayToggleType):
				callback := ObjBindMethod(this, "registerHotkey", k1WayToggleType . "." . number, row, false)
			case translate(kButtonType):
				callback := ObjBindMethod(this, "registerHotkey", kButtonType . "." . number, row, false)
		}
		
		this.iTriggerModeActive := true
		
		wizard.toggleTriggerDetector(callback)
		
		SetTimer stopTriggerDetector, 100
	}
	
	registerHotKey(function, row, firstHotkey, hotkey) {
		local controller
		local number
		
		wizard := this.SetupWizard
			
		SoundPlay %kResourcesDirectory%Sounds\Activated.wav
		
		if (firstHotkey == true) {
			callback := ObjBindMethod(this, "registerHotkey", function, row, hotkey)
		
			wizard.toggleTriggerDetector()
			
			Sleep 2000
			
			wizard.toggleTriggerDetector(callback)
			
			return
		}
		else if (firstHotkey != false) {
			this.iFunctionTriggers[function] := [firstHotkey, hotkey]
		
			hotkey := firstHotkey . " | " . hotkey
		}
		else
			this.iFunctionTriggers[function] := [hotkey]
		
		this.iTriggerModeActive := false
		
		wizard.toggleTriggerDetector()
		
		this.loadFunctions(readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini"))
		
		window := this.Window
		
		Gui %window%:Default
		Gui ListView, % this.iFunctionsListView
		
		LV_Modify(row, "Vis")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonoxPreviewStepWizard                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxPreviewStepWizard extends StepWizard {
	iButtonBoxPreviews := []
	iButtonBoxPreviewCenterY := 0
	
	reset() {
		base.reset()
		
		this.closeButtonBoxes()
	}
	
	showPage(page) {
		base.showPage(page)
		
		if this.SetupWizard.isModuleSelected("Button Box")
			this.openButtonBoxes()
	}
	
	hidePage(page) {
		if base.hidePage(page) {
			if this.SetupWizard.isModuleSelected("Button Box")
				this.closeButtonBoxes()
			
			return true
		}
		else
			return false
	}
	
	getPreviewCenter(ByRef centerX, ByRef centerY) {
		centerX := false
		centerY := this.iButtonBoxPreviewCenterY
	}
	
	getPreviewMover() {
		return false
	}
	
	openButtonBoxes() {
		local function
		
		if this.SetupWizard.isModuleSelected("Button Box") {
			configuration := readConfiguration(kUserHomeDirectory . "Install\Button Box Configuration.ini")
			
			staticFunctions := this.SetupWizard.getControllerStaticFunctions()
			controllers := []
			
			for controller, definition in getConfigurationSectionValues(configuration, "Layouts") {
				controller := ConfigurationItem.splitDescriptor(controller)
			
				if !inList(controllers, controller[1])
					controllers.Push(controller[1])
			}
			
			for index, controller in controllers {
				preview := new ButtonBoxPreview(this, controller, configuration)
			
				preview.setControlClickHandler(ObjBindMethod(this, "controlClick"))
			
				if (index = 1) {
					SysGet mainScreen, MonitorWorkArea
					
					this.iButtonBoxPreviewCenterY := (mainScreenBottom - Round(preview.Height / 2))
				}
				else
					this.iButtonBoxPreviewCenterY -= Round(preview.Height / 2)
				
				preview.open()
				
				row := false
				column := false
				
				for ignore, function in staticFunctions
					if preview.findFunction(function[1], row, column)
						preview.setLabel(row, column, function[2])
				
				this.iButtonBoxPreviewCenterY -= Round(preview.Height / 2)
				this.iButtonBoxPreviews.Push(preview)
			}
		}
		else
			this.iButtonBoxPreviews := []
	}
	
	closeButtonBoxes() {
		for ignore, preview in this.iButtonBoxPreviews
			preview.close()
		
		this.iButtonBoxPreviews := []
		this.iButtonBoxPreviewCenterY := 0
	}
	
	controlClick(preview, element, function, row, column, isEmpty) {
		Throw "Virtual method ButtonBoxPreviewStepWizard.controlClick must be implemented by a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ActionsStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ActionsStepWizard extends ButtonBoxPreviewStepWizard {
	iPendingFunctionRegistration := false
	iPendingActionRegistration := false
	
	iActionsListView := false
	
	iActions := {}
	iLabels := {}
	iFunctions := {}
	
	ActionsListView[] {
		Get {
			return this.iActionsListView
		}
	}
	
	reset() {
		base.reset()
		
		this.iActionsListView := false
		
		this.clearActions()
		this.clearActionFunctions()
	}
	
	showPage(page) {
		vCurrentRegistrationWizard := this
		
		base.showPage(page)
		
		if this.SetupWizard.isModuleSelected("Button Box")
			this.loadActions(true)
		else
			GuiControl Hide, % this.ActionsListView
	}
	
	hidePage(page) {
		if base.hidePage(page) {
			vCurrentRegistrationWizard := false
			
			if this.SetupWizard.isModuleSelected("Button Box")
				this.saveActions()
			
			return true
		}
		else
			return false
	}
	
	loadActions(load := false) {
		Throw "Virtual method ActionsStepWizard.loadActions must be implemented in a subclass..."
	}
	
	saveActions() {
		Throw "Virtual method ActionsStepWizard.saveActions must be implemented in a subclass..."
	}
	
	setActionsListView(actionsListView) {
		this.iActionsListView := actionsListView
	}
	
	setActionFunction(action, functionDescriptor) {
		this.iFunctions[action] := functionDescriptor
	}
	
	getActionFunction(action) {
		return (this.iFunctions.HasKey(action) ? this.iFunctions[action] : false)
	}
	
	clearActionFunction(action, function) {
		if this.iFunctions.HasKey(action) {
			functions := this.iFunctions[action]
			
			for index, candidate in functions
				if (candidate = function)
					functions[index] := ""
			
			if (functions.Length() == 1)
				this.iFunctions.Delete(action)
		}
	}
	
	clearActionFunctions() {
		this.iFunctions := {}
	}
	
	setAction(row, action, actionDescriptor, label) {
		this.iActions[row] := action
		this.iActions[action] := actionDescriptor
		this.iLabels[row] := label
	}
	
	getAction(row) {
		return this.iActions[row]
	}
	
	getActionLabel(row) {
		return this.iLabels[row]
	}
	
	getActionDescriptor(row) {
		return this.iActions[this.getAction(row)]
	}
	
	clearActions() {
		this.iActions := {}
		this.iLabels := {}
	}
	
	openButtonBoxes() {
		base.openButtonBoxes()
		
		this.iPendingFunctionRegistration := false
		this.iPendingActionRegistration := false
	}
	
	resetButtonBoxes() {
		for ignore, preview in this.iButtonBoxPreviews
			preview.resetLabels()
	}
	
	updateActionFunction(row) {
		if this.iPendingActionRegistration {
			arguments := this.iPendingActionRegistration
		
			this.iPendingActionRegistration := false
			this.iPendingFunctionRegistration := row
			
			this.controlClick(arguments*)
		}
		else {
			this.iPendingFunctionRegistration := row
			
			SetTimer showSelectorHint, 100
		}
	}
	
	setFunctionAction(arguments) {
		this.iPendingActionRegistration := arguments
		
		SetTimer showSelectorHint, 100
	}
	
	clearFunctionAction(preview, function, control, row, column) {
		local action
		
		for action, functions in this.iFunctions
			for ignore, candidate in functions
				if (candidate = function) {
					SoundPlay %kResourcesDirectory%Sounds\Activated.wav
					
					this.clearActionFunction(action, function)
					
					preview.setLabel(row, column, ConfigurationItem.splitDescriptor(control)[2])
			
					for ignore, function in this.SetupWizard.getControllerStaticFunctions()
						if preview.findFunction(function[1], row, column)
							preview.setLabel(row, column, function[2])
					
					this.loadActions()
					
					break
				}
	}
	
	controlClick(preview, element, function, row, column, isEmpty, actionRegistration := false) {
		local action
		
		if ((element[1] = "Control") && !isEmpty) {
			if this.iPendingActionRegistration
				return
			
			if (!this.iPendingFunctionRegistration && !actionRegistration) {
				menuItem := (translate(element[1] . ": ") . element[2] . " (" . row . " x " . column . ")")
				
				try {
					Menu ContextMenu, DeleteAll
				}
				catch exception {
					; ignore
				}
				
				window := SetupWizard.Instance.WizardWindow
				
				Gui %window%:Default
				
				Menu ContextMenu, Add, %menuItem%, menuIgnore
				Menu ContextMenu, Disable, %menuItem%
				Menu ContextMenu, Add
				
				menuItem := translate("Set Action")
				handler := ObjBindMethod(this, "setFunctionAction", Array(preview, element, function, row, column, false, true))
				
				Menu ContextMenu, Add, %menuItem%, %handler%
				
				menuItem := translate("Clear Action")
				handler := ObjBindMethod(this, "clearFunctionAction", preview, function, element[2], row, column)
				
				Menu ContextMenu, Add, %menuItem%, %handler%
				
				Menu ContextMenu, Show
			}
			else {
				SoundPlay %kResourcesDirectory%Sounds\Activated.wav
			
				action := this.getAction(this.iPendingFunctionRegistration)
				actionDescriptor := this.getActionDescriptor(this.iPendingFunctionRegistration)
				functionType := ConfigurationItem.splitDescriptor(function)[1]
				
				if (((functionType == k2WayToggleType) || (functionType == kDialType)) && (actionDescriptor[2] == "Toggle"))
					function := [function]
				else if (actionDescriptor[2] == "Activate")
					function := [function]
				else {
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Increase", "Decrease", "Cancel"]))
					title := translate("Setup")
					MsgBox 262179, %title%, % translate("What type of action do you want to trigger for ") . action . translate("?")
					OnMessage(0x44, "")
					
					currentFunction := this.getActionFunction(action)
					
					IfMsgBox Cancel
						function := false
				
					IfMsgBox Yes
					{
						if currentFunction {
							if (currentFunction.Length() == 1)
								function := [function, ""]
							else {
								currentFunction[1] := function
								
								function := currentFunction
							}
						}
						else
							function := [function, ""]
					}
					
					IfMsgBox No
					{
						if currentFunction {
							if (currentFunction.Length() == 1)
								function := ["", function]
							else {
								currentFunction[2] := function
								
								function := currentFunction
							}
						}
						else
							function := ["", function]
					}
				}

				if function {
					this.setActionFunction(action, function)
					
					preview.setLabel(row, column, this.getActionLabel(this.iPendingFunctionRegistration))
					
					this.loadActions()
					
					window := this.Window
					
					Gui %window%:Default
					Gui ListView, % this.ActionsListView
			
					LV_Modify(this.iPendingFunctionRegistration, "Vis")
				}

				SetTimer showSelectorHint, Off
				
				ToolTip, , , 1
				
				this.iPendingFunctionRegistration := false
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

updateActionFunction(wizard) {
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
	
	if wizard.SetupWizard.isModuleSelected("Button Box") {
		if ((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) {
			if (A_EventInfo > 0) {
				row := A_EventInfo
				
				if wizard.iPendingActionRegistration
					wizard.updateActionFunction(row)
				else {
					curCoordMode := A_CoordModeMouse

					LV_GetText(action, row, 2)
					LV_GetText(label, row, 3)
					
					menuItem := (action . ": " . label)
					
					try {
						Menu ContextMenu, DeleteAll
					}
					catch exception {
						; ignore
					}
					
					window := wizard.Window
					
					Gui %window%:Default
					
					Menu ContextMenu, Add, %menuItem%, menuIgnore
					Menu ContextMenu, Disable, %menuItem%
					Menu ContextMenu, Add
					
					menuItem := translate("Set Function")
					handler := ObjBindMethod(wizard, "updateActionFunction", row)
					
					Menu ContextMenu, Add, %menuItem%, %handler%
					
					Menu ContextMenu, Show
				}
			}
		}
		
		Loop % LV_GetCount()
			LV_Modify(A_Index, "-Select")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showSelectorHint() {
	if (GetKeyState("Esc", "P") || !vCurrentRegistrationWizard) {
		SetTimer showSelectorHint, Off
		
		vCurrentRegistrationWizard.iPendingFunctionRegistration := false
		vCurrentRegistrationWizard.iPendingActionRegistration := false
		
		ToolTip, , , 1
	}
	else if vCurrentRegistrationWizard.iPendingFunctionRegistration {
		hint := translate("Click on a controller function...")
		
		ToolTip %hint%, , , 1
	}
	else if vCurrentRegistrationWizard.iPendingActionRegistration {
		hint := translate("Click on an action...")
		
		ToolTip %hint%, , , 1
	}
}

updateFunctionTriggers() {
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
	
	if (A_GuiEvent = "Normal") {
		if (A_EventInfo > 0)
			SetupWizard.Instance.StepWizards["Button Box"].updateFunctionTriggers(A_EventInfo)
	}
	else if (A_GuiEvent = "RightClick") {
		if (A_EventInfo > 0) {
			row := A_EventInfo
			
			curCoordMode := A_CoordModeMouse

			LV_GetText(control, row, 2)
			LV_GetText(number, row, 4)
			
			menuItem := ConfigurationItem.descriptor(control, number)
			
			try {
				Menu ContextMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			window := SetupWizard.Instance.WizardWindow
			
			Gui %window%:Default
			
			Menu ContextMenu, Add, %menuItem%, menuIgnore
			Menu ContextMenu, Disable, %menuItem%
			Menu ContextMenu, Add
			
			menuItem := translate("Press Trigger(s)")
			handler := ObjBindMethod(SetupWizard.Instance.StepWizards["Button Box"], "updateFunctionTriggers", row)
			
			Menu ContextMenu, Add, %menuItem%, %handler%
			
			Menu ContextMenu, Show
		}
	}
	
	Loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

stopTriggerDetector() {
	wizard := SetupWizard.Instance.StepWizards["Button Box"]
	
	if (!wizard.iTriggerModeActive || !vShowTriggerDetector) {
		SetTimer stopTriggerDetector, Off
	
		wizard.iTriggerModeActive := false
	}
	else if GetKeyState("Esc", "P") {
		wizard.SetupWizard.toggleTriggerDetector()
	
		wizard.iTriggerModeActive := false
		
		SetTimer stopTriggerDetector, Off
	}
}

initializeButtonBoxStepWizard() {
	SetupWizard.Instance.registerStepWizard(new ButtonBoxStepWizard(SetupWizard.Instance, "Button Box", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxStepWizard()