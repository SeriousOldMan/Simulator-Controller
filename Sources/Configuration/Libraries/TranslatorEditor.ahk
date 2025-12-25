;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translator Editor               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Translator.ahk"
#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kSaveEditor := "Save"
global kCancelEditor := "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslatorEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TranslatorEditor extends ConfiguratorPanel {
	iAssistant := false

	iSelectedService := false

	iResult := false
	iWindow := false

	Assistant {
		Get {
			return this.iAssistant
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	SelectedService {
		Get {
			return this.iSelectedService
		}
	}

	__New(assistant, configuration := false) {
		this.iAssistant := assistant

		super.__New(configuration)

		TranslatorEditor.Instance := this

		this.createGui(this.Configuration)
	}

	createGui(configuration) {
		local editorGui, x, y, w, h, translationLanguages, translatorServices

		updateTranslatorFields(*) {
			local service := editorGui["translatorServiceDropDown"].Text

			this.saveConfigurator(this.SelectedService)

			this.loadConfigurator((service = translate("None")) ? false : service)
		}

		editorGui := Window({Descriptor: "Translator Editor", Options: "0x400000"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Translator Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x138 YP+20 w128 H:Center Center", translate("Translator Configuration")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w400 0x10")

		translatorServices := [translate("None"), "Google", "Azure", "DeepL", "OpenAI"]

		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200", translate("Translator"))
		editorGui.Add("DropDownList", "x120 yp w280 Choose1 VtranslatorServiceDropDown", translatorServices)
		editorGui["translatorServiceDropDown"].OnEvent("Change", updateTranslatorFields)

		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200 VtranslatorLanguageLabel", translate("Target Language"))
		editorGui.Add("DropDownList", "x120 yp w280 Choose1 VtranslatorLanguageDropDown", collect(kTranslatorLanguages, (l) => l.Name))

		; API Key field (always visible)
		editorGui.Add("Text", "x8 yp+30 w100 h23 Section +0x200 VtranslatorAPIKeyLabel", translate("API Key"))
		editorGui.Add("Edit", "x120 yp w280 h21 Password VtranslatorAPIKeyEdit")

		; Endpoint/Region field (visible for Azure)
		editorGui.Add("Text", "x8 ys+30 w100 h23 +0x200 VtranslatorEndpointLabel", translate("Endpoint"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorEndpointEdit")
		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200 VtranslatorRegionLabel", translate("Region"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorRegionEdit")

		; URL (visible for DeepL and OpenAI)
		editorGui.Add("Text", "x8 ys+30 w100 h23 +0x200 VtranslatorServiceURLLabel", translate("Service URL"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorServiceURLEdit")

		; Model (visible for OpenAI)
		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200 VtranslatorModelLabel", translate("Model"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorModelEdit")

		editorGui.Add("Text", "x8 yp+35 w400 0x10")

		editorGui.Add("Button", "x120 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => (this.iResult := kSaveEditor))
		editorGui.Add("Button", "x208 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => (this.iResult := kCancelEditor))

		return editorGui
	}

	loadConfigurator(service) {
		local endpointLabel := this.Control["translatorEndpointLabel"]
		local endpointEdit := this.Control["translatorEndpointEdit"]
		local regionLabel := this.Control["translatorRegionLabel"]
		local regionEdit := this.Control["translatorRegionEdit"]
		local serviceURLLabel := this.Control["translatorServiceURLLabel"]
		local serviceURLEdit := this.Control["translatorServiceURLEdit"]
		local modelLabel := this.Control["translatorModelLabel"]
		local modelEdit := this.Control["translatorModelEdit"]

		this.iSelectedService := service

		; Hide all optional fields by default
		endpointLabel.Visible := false
		endpointEdit.Visible := false
		regionLabel.Visible := false
		regionEdit.Visible := false
		serviceURLLabel.Visible := false
		serviceURLEdit.Visible := false
		modelLabel.Visible := false
		modelEdit.Visible := false

		if service {
			this.Control["translatorLanguageLabel"].Visible := true
			this.Control["translatorLanguageDropDown"].Visible := true
			this.Control["translatorAPIKeyLabel"].Visible := true
			this.Control["translatorAPIKeyEdit"].Visible := true

			this.Control["translatorLanguageDropDown"].Choose(inList(getKeys(kTranslatorLanguages)
																   , this.Value["translatorLanguage"]))
			this.Control["translatorAPIKeyEdit"].Text := this.Value["translatorAPIKey"]
		}
		else {
			this.Control["translatorLanguageLabel"].Visible := false
			this.Control["translatorLanguageDropDown"].Visible := false
			this.Control["translatorAPIKeyLabel"].Visible := false
			this.Control["translatorAPIKeyEdit"].Visible := false
		}

		; Update and show fields based on selected service
		if (service = "Google") {
			; Nothing to do here
		}
		else if (service = "Azure") {
			; Azure needs endpoint and region
			endpointLabel.Visible := true
			endpointEdit.Visible := true
			regionLabel.Visible := true
			regionEdit.Visible := true

			try {
				this.Control["translatorEndpointEdit"].Text := this.Value["translatorArguments"][1]
				this.Control["translatorRegionEdit"].Text := this.Value["translatorArguments"][2]
			}
		}
		else if (service = "DeepL") {
			; DeepL has optional custom endpoint
			serviceURLLabel.Visible := true
			serviceURLEdit.Visible := true

			try
				this.Control["serviceURLEdit"].Text := this.Value["translatorArguments"][1]
		}
		else if (service = "OpenAI") {
			; OpenAI needs model selection
			serviceURLLabel.Visible := true
			serviceURLEdit.Visible := true
			modelLabel.Visible := true
			modelEdit.Visible := true

			try {
				this.Control["serviceURLEdit"].Text := this.Value["translatorArguments"][1]
				this.Control["modelEdit"].Text := this.Value["translatorArguments"][2]
			}
		}
	}

	saveConfigurator(service) {
		this.Value["translatorService"] := service

		if service {
			this.Value["translatorLanguage"] := getKeys(kTranslatorLanguages)[this.Control["translatorLanguageDropDown"].Value]
			this.Value["translatorAPIKey"] := this.Control["translatorAPIKeyEdit"].Text

			if (service = "Google")
				this.Value["translatorArguments"] := []
			else if (service = "Azure")
				this.Value["translatorArguments"] := [this.Control["translatorEndpointEdit"]
													, this.Control["translatorRegionEdit"]]
			else if (service = "DeepL")
				this.Value["translatorArguments"] := [this.Control["translatorServiceURLEdit"]]
			else if (service = "OpenAI")
				this.Value["translatorArguments"] := [this.Control["translatorServiceURLEdit"]
													, this.Control["translatorModelEdit"]]
		}
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		; Load translation settings for this assistant
		this.Value["translatorService"] := getMultiMapValue(configuration, this.Assistant . ".Translator", "Service", false)
		this.Value["translatorLanguage"] := getMultiMapValue(configuration, this.Assistant . ".Translator", "Language", "English")
		this.Value["translatorAPIKey"] := getMultiMapValue(configuration, this.Assistant . ".Translator", "API Key", "")
		this.Value["translatorArguments"] := string2Values(",", getMultiMapValue(configuration, this.Assistant . ".Translator", "Arguments", ""))

		if this.Window
			this.loadConfigurator(this.Value["translatorService"])
	}

	saveToConfiguration(configuration) {
		local service := this.Value["translatorService"]

		super.saveToConfiguration(configuration)

		; Save translation settings for this assistant
		removeMultiMapValues(configuration, this.Assistant . ".Translator")

		setMultiMapValue(configuration, this.Assistant . ".Translator", "Service", service)

		if service {
			setMultiMapValue(configuration, this.Assistant . ".Translator", "Language", this.Value["translatorLanguage"])
			setMultiMapValue(configuration, this.Assistant . ".Translator", "API Key", this.Value["translatorAPIKey"])
			setMultiMapValue(configuration, this.Assistant . ".Translator", "Arguments"
										  , values2String(",", this.Value["translatorArguments"]*))
		}
	}

	editTranslator(assistant := false) {
		local window

		if !assistant
			assistant := this.Assistant

		window := this.Window

		this.loadFromConfiguration(this.Configuration)

		window.Show("AutoSize Center")

		loop {
			Sleep(100)
		}
		until this.iResult

		try {
			if (this.iResult = kSaveEditor) {
				configuration := this.Configuration.Clone()

				this.saveToConfiguration(configuration)

				return configuration
			}
			else
				return false
		}
		finally {
			window.Destroy()
		}
	}
}
