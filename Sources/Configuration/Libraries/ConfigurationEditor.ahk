;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Configuration Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

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

	getSimulatorConfiguration() {
		if this.Window {
			local configuration := newMultiMap()

			this.saveToConfiguration(configuration)

			return configuration
		}
		else
			return this.Configuration
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

		editorGui.Add("Button", "x232 y573 w80 h23 Y:Move X:Move Default", translate("Save")).OnEvent("Click", saveAndExit)
		editorGui.Add("Button", "x320 y573 w80 h23 Y:Move X:Move", translate("&Cancel")).OnEvent("Click", cancelAndExit)
		editorGui.Add("Button", "x408 y573 w77 h23 Y:Move X:Move", translate("&Apply")).OnEvent("Click", saveAndStay)

		choices := ["Auto", "Manual"]
		chosen := inList(choices, this.iSaveMode)

		editorGui.Add("Text", "x8 y573 w55 h23 Y:Move +0x200", translate("Save"))
		editorGui.Add("DropDownList", "x65 y573 w75 Y:Move Choose" . chosen . "  vsaveModeDropDown", collect(choices, translate)).OnEvent("Change", updateSaveMode)

		labels := []

		for ignore, configurator in this.Configurators
			labels.Push(configurator[1])

		editorGui.Add("Tab3", "x8 y48 w478 h517 W:Grow H:Grow AltSubmit -Wrap vconfiguratorTabView", labels).OnEvent("Change", selectTab)

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