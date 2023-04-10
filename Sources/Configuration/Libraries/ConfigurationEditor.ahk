;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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
	iJoysticks := []

	CallBack {
		Get {
			return this.iCallback
		}
	}

	Stopped {
		Set {
			if value
				ToolTip(, , 1)

			return (super.Stopped := value)
		}
	}

	Joysticks {
		Get {
			return this.iJoysticks
		}
	}

	__New(callback, arguments*) {
		this.iCallback := callback

		super.__New(false, arguments*)
	}

	run() {
		local joysticks := []
		local joyName

		loop 16 { ; Query each joystick number to find out which ones exist.
			joyName := (GetKeyState(A_Index . "JoyName") ? "D" : "U")

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
		local found, joysticks, joystickNumber, joy_buttons, joy_name, joy_state, buttons_down, joy_info
		local joy1, joy2, joy3, joy4, joy5, joy6, joy7, joy8, joy9, joy10, joy11, joy12, joy13, joy14, joy15, joy16
		local axis_info, buttonsDown, callback

		if !this.Task.Stopped {
			found := false

			if GetKeyState("Esc", "P") {
				this.stop()

				return false
			}

			joysticks := this.Task.Joysticks

			joystickNumber := joysticks[1]

			joysticks.RemoveAt(1)
			joysticks.Push(joystickNumber)

			; SetFormat Float, 03  ; Omit decimal point from axis position percentages.

			joy_buttons := (GetKeyState(joystickNumber . "JoyButtons", ) ? "D" : "U")
			joy_name := (GetKeyState(joystickNumber . "JoyName") ? "D" : "U")
			joy_info := (GetKeyState(joystickNumber . "JoyInfo") ? "D" : "U")

			buttons_down := ""

			loop joy_buttons {
				joy%A_Index% := (GetKeyState(joystickNumber . "joy" . A_Index) ? "D" : "U")

				if (joy%A_Index% = "D") {
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

			ToolTip(joy_name . " (#" joystickNumber "):`n" . axis_info . "`n" . buttonsDown . A_Space . buttons_down, , , 1)

			if found {
				if this.Task.Callback {
					this.Task.Callback.Call(joystickNumber . "Joy" . found)

					this.stop()

					return false
				}
				else
					return TriggerDetectorContinuation(this.Task, 2000)
			}

			return TriggerDetectorContinuation(this.Task, 750)
		}
		else {
			this.stop()

			return false
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfiguratorPanel                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConfiguratorPanel extends ConfigurationItem {
	iEditor := false
	iWindow := false

	iValues := CaseInsenseMap()

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

	__New(arguments*) {
		if !this.Editor
			this.Editor := this

		super.__New(arguments*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfiguratorPanel                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Configurator extends ConfiguratorPanel {
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
	iSaveMode := false

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
			return (isSet(key) ? this.iConfigurators[key] : this.iConfigurators)
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

		this.registerConfigurator(translate("General"), GeneralTab(development, configuration))

		ConfigurationEditor.Instance := this
	}

	registerConfigurator(label, configurator) {
		this.Configurators.Push(Array(label, configurator))
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
		}

		editorGui := Window({Descriptor: "Simulator Configuration", Options: "+SysMenu +Caption -MaximizeBox", Closeable: true, Resizeable: "Deferred"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w478 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Simulator Configuration"))

		editorGui.SetFont("Norm", "Arial")
		editorGui.SetFont("Italic Underline", "Arial")

		editorGui.Add("Text", "x178 YP+20 w138 H:Center cBlue Center", translate("Configuration")).OnEvent("Click", openDocumentation.Bind(editorGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Button", "x232 y528 w80 h23 Y:Move X:Move Default", translate("Save")).OnEvent("Click", saveAndExit)
		editorGui.Add("Button", "x320 y528 w80 h23 Y:Move X:Move", translate("&Cancel")).OnEvent("Click", cancelAndExit)
		editorGui.Add("Button", "x408 y528 w77 h23 Y:Move X:Move", translate("&Apply")).OnEvent("Click", saveAndStay)

		choices := ["Auto", "Manual"]
		chosen := inList(choices, this.iSaveMode)

		editorGui.Add("Text", "x8 y528 w55 h23 Y:Move +0x200", translate("Save"))
		editorGui.Add("DropDownList", "x63 y528 w75 Y:Move AltSubmit Choose" . chosen . "  vsaveModeDropDown", collect(choices, translate)).OnEvent("Change", updateSaveMode)

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

		this.iSaveMode := getMultiMapValue(configuration, "General", "Save", "Manual")
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

	toggleTriggerDetector(callback := false) {
		triggerDetector(callback)
	}

	getSimulators() {
		return this.GeneralTab.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

triggerDetector(callback := false) {
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
		else {
			detectorTask := TriggerDetectorTask(callback, 100)

			detectorTask.start()
		}
	}
}