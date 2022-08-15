;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include Libraries\ConfigurationItemList.ahk


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

	CallBack[] {
		Get {
			return this.iCallback
		}
	}

	Stopped[] {
		Set {
			if value
				ToolTip, , , 1

			return (base.Stopped := value)
		}
	}

	Joysticks[] {
		Get {
			return this.iJoysticks
		}
	}

	__New(callback, arguments*) {
		this.iCallback := callback

		base.__New(false, arguments*)
	}

	run() {
		local joysticks := []
		local joyName

		loop 16 { ; Query each joystick number to find out which ones exist.
			GetKeyState joyName, %A_Index%JoyName

			if (joyName != "")
				joysticks.Push(A_Index)
		}

		this.iJoysticks := joysticks

		return new TriggerDetectorContinuation(Task.CurrentTask)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TriggerDetectorContinuation                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TriggerDetectorContinuation extends Continuation {
	__New(task, arguments*) {
		base.__New(task, false, arguments*)
	}

	run() {
		local found, joysticks, joystickNumber, joy_buttons, joy_name, joy_state, buttons_down
		local joy1, joy2, joy3, joy4, joy5, joy6, joy7, joy8, joy9, joy10, joy11, joy12, joy13, joy14, joy15, joy16
		local joyX, joyY, joyZ, joyU, joyV, joyP, joyR, axis_info
		local buttonsDown, callback

		if !this.Task.Stopped {
			found := false

			if GetKeyState("Esc", "P") {
				Task.stopTask(Task.CurrentTask.Task)

				return false
			}

			joysticks := this.Task.Joysticks

			joystickNumber := joysticks[1]

			joysticks.RemoveAt(1)
			joysticks.Push(joystickNumber)

			SetFormat Float, 03  ; Omit decimal point from axis position percentages.

			GetKeyState joy_buttons, %joystickNumber%JoyButtons
			GetKeyState joy_name, %joystickNumber%JoyName
			GetKeyState joy_info, %joystickNumber%JoyInfo

			buttons_down := ""

			loop %joy_buttons%
			{
				GetKeyState joy%A_Index%, %joystickNumber%joy%A_Index%

				if (joy%A_Index% = "D") {
					buttons_down = %buttons_down%%A_Space%%A_Index%

					found := A_Index
				}
			}

			GetKeyState joyX, %joystickNumber%JoyX

			axis_info = X%joyX%

			GetKeyState joyY, %joystickNumber%JoyY

			axis_info = %axis_info%%A_Space%%A_Space%Y%joyY%

			IfInString joy_info, Z
			{
				GetKeyState joyZ, %joystickNumber%JoyZ

				axis_info = %axis_info%%A_Space%%A_Space%Z%joyZ%
			}

			IfInString joy_info, R
			{
				GetKeyState joyR, %joystickNumber%JoyR

				axis_info = %axis_info%%A_Space%%A_Space%R%joyR%
			}

			IfInString joy_info, U
			{
				GetKeyState joyU, %joystickNumber%JoyU

				axis_info = %axis_info%%A_Space%%A_Space%U%joyU%
			}

			IfInString joy_info, V
			{
				GetKeyState joyV, %joystickNumber%JoyV

				axis_info = %axis_info%%A_Space%%A_Space%V%joyV%
			}

			IfInString joy_info, P
			{
				GetKeyState joyP, %joystickNumber%JoyPOV

				axis_info = %axis_info%%A_Space%%A_Space%POV%joyP%
			}

			buttonsDown := translate("Buttons Down:")

			ToolTip %joy_name% (#%joystickNumber%):`n%axis_info%`n%buttonsDown% %buttons_down%, , , 1

			if found {
				if this.Task.Callback {
					callback := this.Task.Callback

					%callback%(joystickNumber . "Joy" . found)
				}
				else
					return new TriggerDetectorContinuation(this.Task, 2000)
			}

			return new TriggerDetectorContinuation(this.Task, 750)
		}
		else {
			this.Task.stop()

			return false
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConfigurationEditor                                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global saveModeDropDown
global configuratorTabView

class ConfigurationEditor extends ConfigurationItem {
	iWindow := "CFGE"
	iResult := false

	iGeneralTab := false

	iConfigurators := []

	iDevelopment := false
	iSaveMode := false

	Configurators[key := false] {
		Get {
			return (key ? this.iConfigurators[key] : this.iConfigurators)
		}
	}

	AutoSave[] {
		Get {
			return (this.iSaveMode = "Auto")
		}
	}

	Window[] {
		Get {
			return this.iWindow
		}
	}

	Result[] {
		Get {
			return this.iResult
		}

		Set {
			return (this.iResult := value)
		}
	}

	__New(development, configuration) {
		this.iDevelopment := development
		this.iGeneralTab := new GeneralTab(development, configuration)

		base.__New(configuration)

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
		local window := this.Window
		local choices, chosen, labels, ignore, configurator, tab

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, w478 Center gmoveConfigurationEditor, % translate("Modular Simulator Controller System")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x178 YP+20 w138 cBlue Center gopenConfigurationDocumentation, % translate("Configuration")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Button, x232 y528 w80 h23 Default gsaveAndExit, % translate("Save")
		Gui %window%:Add, Button, x320 y528 w80 h23 gcancelAndExit, % translate("&Cancel")
		Gui %window%:Add, Button, x408 y528 w77 h23 gsaveAndStay, % translate("&Apply")

		choices := ["Auto", "Manual"]
		chosen := inList(choices, saveModeDropDown)

		Gui %window%:Add, Text, x8 y528 w55 h23 +0x200, % translate("Save")
		Gui %window%:Add, DropDownList, x63 y528 w75 AltSubmit Choose%chosen% gupdateSaveMode VsaveModeDropDown, % values2String("|", map(choices, "translate")*)

		labels := []

		for ignore, configurator in this.Configurators
			labels.Push(configurator[1])

		Gui %window%:Add, Tab3, x8 y48 w478 h472 AltSubmit -Wrap vconfiguratorTabView gselectTab, % values2String("|", concatenate(Array(translate("General")), labels)*)

		tab := 1

		Gui %window%:Tab, % tab++

		this.iGeneralTab.createGui(this, 16, 80, 458, 425)

		for ignore, configurator in this.Configurators {
			Gui %window%:Tab, % tab++

			configurator[2].createGui(this, 16, 80, 458, 425)
		}
	}

	registerWidget(plugin, widget) {
		GuiControl Show, %widget%
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		this.iSaveMode := getConfigurationValue(configuration, "General", "Save", "Manual")

		saveModeDropDown := this.iSaveMode
	}

	saveToConfiguration(configuration) {
		local ignore, configurator

		base.saveToConfiguration(configuration)

		GuiControlGet saveModeDropDown

		this.iSaveMode := ["Auto", "Manual"][saveModeDropDown]

		setConfigurationValue(configuration, "General", "Save", this.iSaveMode)

		this.iGeneralTab.saveToConfiguration(configuration)

		for ignore, configurator in this.Configurators
			configurator[2].saveToConfiguration(configuration)
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Simulator Configuration", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show
	}

	hide() {
		local window := this.Window

		Gui %window%:Hide
	}

	close() {
		local window := this.Window

		Gui %window%:Destroy
	}

	toggleTriggerDetector(callback := false) {
		triggerDetector(callback)
	}

	getSimulators() {
		return this.iGeneralTab.getSimulators()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveAndExit() {
	ConfigurationEditor.Instance.Result := kOk
}

cancelAndExit() {
	ConfigurationEditor.Instance.Result := kCancel
}

saveAndStay() {
	ConfigurationEditor.Instance.Result := kApply
}

moveConfigurationEditor() {
	moveByMouse(ConfigurationEditor.Instance.Window, "Simulator Configuration")
}

updateSaveMode() {
	GuiControlGet saveModeDropDown

	ConfigurationEditor.Instance.iSaveMode := ["Auto", "Manual"][saveModeDropDown]
}

openConfigurationDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration
}

selectTab() {
	local configurator

	GuiControlGet configuratorTabView

	configurator := ((configuratorTabView == 1) ? ConfigurationEditor.Instance.iGeneralTab : ConfigurationEditor.Instance.Configurators[configuratorTabView - 1][2])

	if configurator.base.HasKey("activate")
		configurator.activate()
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
			Task.stopTask(detectorTask)

			detectorTask := false
		}
		else {
			detectorTask := new TriggerDetectorTask(callback, 100)

			Task.startTask(detectorTask)
		}
	}
}