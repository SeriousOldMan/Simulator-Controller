;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "ConfigurationItemList.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constant Section                          ;;;
;;;-------------------------------------------------------------------------;;;

global kConfigurationEditor := false

global kApply := "apply"
global kOk := "ok"
global kCancel := "cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TriggerDetectorTask                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TriggerDetectorTask extends Task {
	iCallback := false
	iOptions := []
	iJoysticks := []

	Options {
		Get {
			return this.iOptions
		}
	}

	CallBack {
		Get {
			return this.iCallback
		}
	}

	Stopped {
		Get {
			return super.Stopped
		}

		Set {
			if value
				ToolTip(, , 1)

			return (super.Stopped := value)
		}
	}

	Joysticks[key?] {
		Get {
			return (isSet(key) ? this.iJoysticks[key] : this.iJoysticks)
		}
	}

	__New(callback, options, arguments*) {
		this.iOptions := options
		this.iCallback := callback

		super.__New(false, arguments*)
	}

	run() {
		local joysticks := []
		local joyName

		loop 16 { ; Query each joystick number to find out which ones exist.
			joyName := (GetKeyState(A_Index . "JoyName") ? "D" : "")

			if (joyName != "")
				joysticks.Push(A_Index)
		}

		this.iJoysticks := joysticks

		return TriggerDetectorContinuation(Task.CurrentTask)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TriggerDetectorContinuation                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TriggerDetectorContinuation extends Continuation {
	__New(task, arguments*) {
		super.__New(task, false, arguments*)
	}

	run() {
		local key := false
		local found, joysticks, joystickNumber, joy_buttons, joy_name, joy_state, buttons_down, joy_info
		local axis_info, buttonsDown, callback

		if !this.Task.Stopped {
			found := false

			if GetKeyState("Esc", "P") {
				this.stop()

				return false
			}

			key := (inList(this.Task.Options, "Key") ? this.detectKey(inList(this.Task.Options, "Multi")) : false)

			if key {
				if InStr(key, "Esc") {
					this.stop()

					return false
				}

				found := true

				ToolTip(key, , , 1)
			}
			else if inList(this.Task.Options, "Joy") {
				joysticks := this.Task.Joysticks

				loop joysticks.Length {
					joystickNumber := joysticks[1]

					joysticks.RemoveAt(1)
					joysticks.Push(joystickNumber)

					; SetFormat Float, 03  ; Omit decimal point from axis position percentages.

					joy_buttons := GetKeyState(joystickNumber . "JoyButtons")
					joy_name := GetKeyState(joystickNumber . "JoyName")
					joy_info := GetKeyState(joystickNumber . "JoyInfo")

					buttons_down := ""
					buttons := []

					loop joy_buttons {
						if GetKeyState(joystickNumber . "joy" . A_Index) {
							buttons_down := (buttons_down . A_Space . A_Index)

							found := A_Index
						}
					}

					axis_info := ("X" . (GetKeyState(joystickNumber . "JoyX") ? "D" : "U"))

					axis_info := (axis_info . A_Space . A_Space . "Y" .  (GetKeyState(joystickNumber . "JoyY") ? "D" : "U"))

					if InStr(joy_info, "Z")
						axis_info := (axis_info . A_Space . A_Space . "Z" . (GetKeyState(joystickNumber . "JoyZ") ? "D" : "U"))

					if InStr(joy_info, "R")
						axis_info := (axis_info . A_Space . A_Space . "R" . (GetKeyState(joystickNumber . "JoyR") ? "D" : "U"))

					if InStr(joy_info, "U")
						axis_info := (axis_info . A_Space . A_Space . "U" . (GetKeyState(joystickNumber . "JoyU") ? "D" : "U"))

					if InStr(joy_info, "V")
						axis_info := (axis_info . "" . A_Space . "" . A_Space . "V" . (GetKeyState(joystickNumber "JoyV", ) ? "D" : "U"))

					if InStr(joy_info, "P")
						axis_info := (axis_info . A_Space . A_Space . "POV" . (GetKeyState(joystickNumber "JoyPOV") ? "D" : "U"))

					buttonsDown := translate("Buttons Down:")
				}
				until found

				if found
					ToolTip(joy_name . " (#" joystickNumber "):`n" . axis_info . "`n" . buttonsDown . A_Space . buttons_down, , , 1)
				else
					ToolTip(translate("Waiting..."), , , 1)
			}

			if found {
				if !key
					key := (joystickNumber . "Joy" . found)

				A_Clipboard := key

				if this.Task.Callback {
					this.Task.Callback.Call(key)

					this.stop()

					return false
				}
				else
					return TriggerDetectorContinuation(this.Task, 2000)
			}

			return TriggerDetectorContinuation(this.Task, 0)
		}
		else {
			this.stop()

			return false
		}
	}

	detectKey(multi) {
		local input := InputHook("T0.1")
		local key, expired

		static lastTicks := false
		static lastKeys := []

		expired := (lastTicks ? ((A_TickCount - lastTicks) > 500) : false)

		if !multi
			lastKeys := []

		input.KeyOpt("{All}", "IE")

		input.VisibleText := false
		input.VisibleNonText := false

		input.Start()

		input.Wait()

		key := input.EndKey

		input.Stop()

		if (key && (key != ""))
			if multi {
				if !expired {
					if (lastKeys.Length = 0)
						lastTicks := A_TickCount

					if !inList(lastKeys, key)
						lastKeys.Push(key)
				}
			}
			else
				return key

		if (multi && expired) {
			lastTicks := false

			if (lastKeys.Length > 0) {
				key := this.createHotkey(lastKeys)

				lastKeys := []

				return key
			}
			else
				return false
		}

		return false
	}

	createHotkey(keys) {
		local baseKeys := []
		local baseKey := kUndefined
		local ignore, key, modifiers

		loop 26
			baseKeys.Push(Chr(Ord("a") + A_Index - 1))

		loop 10 {
			baseKeys.Push(String(A_Index - 1))
			baseKeys.Push("Numpad" . (A_Index - 1))
		}

		loop 24
			baseKeys.Push("F" . A_Index)

		for ignore, key in ["Space", "BackSpace", "Tab", "Enter", "Up", "Down", "Left", "Right"
						  , "Home", "End", "Delete", "Insert", "PgUp", "PgDn"]
			baseKeys.Push(key)

		for ignore, key in keys.Clone()
			if inList(baseKeys, key) {
				if (baseKey == kUndefined)
					baseKey := key

				keys := remove(keys, key)
			}

		if (baseKey != kUndefined) {
			modifiers := ""

			for ignore, key in keys
				switch key, false {
					case "LShift":
						modifiers .= "<+"
					case "RShift":
						modifiers .= ">+"
					case "LControl":
						modifiers .= "<^"
					case "RControl":
						modifiers .= ">^"
					case "LAlt":
						modifiers .= "<!"
					case "RAlt":
						modifiers .= ">!"
					case "AltGr":
						modifiers .= "<^>!"
					case "Win":
						modifiers .= "#"
				}

			return (modifiers . baseKey)
		}
		else
			return values2String(" & ", keys*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfiguratorPanel                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfiguratorPanel extends ConfigurationItem {
	iEditor := false
	iWindow := false

	iValues := CaseInsenseWeakMap()

	Editor {
		Get {
			return this.iEditor
		}

		Set {
			return (this.iEditor := value)
		}
	}

	Window {
		Get {
			return (this.iWindow ? this.iWindow : ((this.Editor != this) ? this.Editor.Window : false))
		}

		Set {
			return (this.iWindow := value)
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Value[name] {
		Get {
			return this.iValues[name]
		}

		Set {
			return (this.iValues[name] := value)
		}
	}

	AutoSave {
		Get {
			return true
		}
	}

	__New(arguments*) {
		if !this.Editor
			this.Editor := this

		super.__New(arguments*)
	}

	show() {
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationEditor                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfigurationEditor extends ConfigurationItem {
	iWindow := false

	iResult := false

	iConfigurators := []

	iDevelopment := false
	iSaveMode := true

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Configurators[key?] {
		Get {
			local result, ignore, configurator

			if isSet(key) {
				if isNumber(key)
					return this.iConfigurators[key]
				else if (key = "OBJECT") {
					result := []

					for ignore, configurator in this.iConfigurators
						result.Push(configurator[2])

					return result
				}
				else
					throw "Unknown argument detected in ConfigurationEditor.Configurators..."
			}
			else
				return this.iConfigurators
		}
	}

	AutoSave {
		Get {
			return (this.iSaveMode = "Auto")
		}
	}

	GeneralTab {
		Get {
			return this.Configurators[1][2]
		}
	}

	Result {
		Get {
			return this.iResult
		}

		Set {
			return (this.iResult := value)
		}
	}

	__New(development, configuration) {
		this.iDevelopment := development

		super.__New(configuration)

		if isSet(GeneralTab)
			this.registerConfigurator(translate("General"), GeneralTab(development, configuration)
									, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general")

		ConfigurationEditor.Instance := this
	}

	registerConfigurator(label, configurator, documentation := false) {
		this.Configurators.Push(Array(label, configurator, documentation))
	}

	unregisterConfigurator(labelOrConfigurator) {
		local ignore, configurator

		for ignore, configurator in this.Configurators
			if ((configurator[1] = labelOrConfigurator) || (configurator[2] = labelOrConfigurator)) {
				this.Configurators.RemoveAt(A_Index)

				break
			}
	}

	createGui(configuration) {
		local choices, chosen, labels, ignore, configurator, tab
		local editorGui

		saveAndExit(*) {
			this.Result := kOk
		}

		cancelAndExit(*) {
			this.Result := kCancel
		}

		saveAndStay(*) {
			this.Result := kApply
		}

		updateSaveMode(*) {
			this.iSaveMode := ["Auto", "Manual"][editorGui["saveModeDropDown"].Value]
		}

		selectTab(*) {
			local configurator := ConfigurationEditor.Instance.Configurators[editorGui["configuratorTabView"].Value][2]

			if configurator.HasProp("activate")
				configurator.activate()

			this.toggleTriggerDetector("Stop")
		}

		openDocumentation(*) {
			local documentation := ConfigurationEditor.Instance.Configurators[editorGui["configuratorTabView"].Value][3]

			if documentation
				Run(documentation)
			else
				Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration")
		}

		editorGui := Window({Descriptor: "Simulator Configuration", Options: "+SysMenu +Caption -MaximizeBox", Closeable: true, Resizeable: "Deferred"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w478 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Simulator Configuration"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x178 YP+20 w138 H:Center Center", translate("Configuration"), openDocumentation)

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Button", "x232 y528 w80 h23 Y:Move X:Move Default", translate("Save")).OnEvent("Click", saveAndExit)
		editorGui.Add("Button", "x320 y528 w80 h23 Y:Move X:Move", translate("&Cancel")).OnEvent("Click", cancelAndExit)
		editorGui.Add("Button", "x408 y528 w77 h23 Y:Move X:Move", translate("&Apply")).OnEvent("Click", saveAndStay)

		choices := ["Auto", "Manual"]
		chosen := inList(choices, this.iSaveMode)

		editorGui.Add("Text", "x8 y528 w55 h23 Y:Move +0x200", translate("Save"))
		editorGui.Add("DropDownList", "x63 y528 w75 Y:Move Choose" . chosen . "  vsaveModeDropDown", collect(choices, translate)).OnEvent("Change", updateSaveMode)

		labels := []

		for ignore, configurator in this.Configurators
			labels.Push(configurator[1])

		editorGui.Add("Tab3", "x8 y48 w478 h472 W:Grow H:Grow AltSubmit -Wrap vconfiguratorTabView", labels).OnEvent("Change", selectTab)

		tab := 1

		for ignore, configurator in this.Configurators {
			editorGui["configuratorTabView"].UseTab(tab++)

			configurator[2].createGui(this, 16, 80, 458, 425)
		}
	}

	registerWidget(plugin, widget) {
		widget.Visible := true
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.iSaveMode := getMultiMapValue(configuration, "General", "Save", "Auto")
	}

	saveToConfiguration(configuration) {
		local ignore, configurator

		super.saveToConfiguration(configuration)

		this.iSaveMode := ["Auto", "Manual"][this.Control["saveModeDropDown"].Value]

		setMultiMapValue(configuration, "General", "Save", this.iSaveMode)

		for ignore, configurator in this.Configurators
			configurator[2].saveToConfiguration(configuration)
	}

	show() {
		local window := this.Window
		local x, y, w, h, ignore, configurator

		if getWindowPosition("Simulator Configuration", &x, &y)
			window.Show("x" . x . " y" . y . " AutoSize")
		else
			window.Show()

		for ignore, configurator in this.Configurators
			configurator[2].show()

		if getWindowSize("Simulator Configuration", &w, &h)
			window.Resize("Initialize", w, h)
	}

	hide() {
		this.Window.Hide()
	}

	close() {
		this.Window.Destroy()
	}

	toggleTriggerDetector(callback := false, options?) {
		triggerDetector(callback, options?)
	}

	getSimulators() {
		return this.GeneralTab.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

triggerDetector(callback := false, options := ["Joy", "Key"]) {
	static detectorTask := false

	if (callback = "Active")
		return (detectorTask && !detectorTask.Stopped)
	else {
		if (detectorTask && detectorTask.Stopped)
			detectorTask := false

		if detectorTask {
			detectorTask.stop()

			detectorTask := false
		}
		else if (callback != "Stop") {
			detectorTask := TriggerDetectorTask(callback, options, 100)

			detectorTask.start()
		}
	}
}