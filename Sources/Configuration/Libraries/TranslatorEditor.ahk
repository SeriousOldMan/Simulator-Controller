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

#Include "..\..\Framework\Extensions\TranslationPipeline.ahk"
#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslatorEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global kSaveEditor := "Save"
global kCloseEditor := "Close"

class TranslatorEditor extends ConfiguratorPanel {
	iResult := false
	iAssistant := false
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

	__New(assistant, configuration := false) {
		this.iAssistant := assistant
		super.__New(configuration)

		TranslatorEditor.Instance := this

		this.createGui(this.Configuration)
	}

	createGui(configuration) {
		local editorGui, x, y, w, h, translationLanguages, translatorServices

		updateTranslatorFields(*) {
			this.updateTranslatorFields()
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

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "x8 yp+10 w400", translate("Translation Settings") . " - " . this.Assistant)

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+24 w100 h23 +0x200", translate("Enable"))
		editorGui.Add("CheckBox", "x120 yp w200 h23 VtranslatorEnabledCheck", translate("Enable Translation"))

		translationLanguages := ["Spanish", "French", "German", "Italian", "Portuguese", "Japanese", "Chinese", "Korean"
							   , "Russian", "Arabic", "Dutch", "Polish", "Swedish", "Turkish", "Hindi", "Thai"
							   , "Vietnamese", "Czech", "Danish", "Finnish", "Norwegian", "Hungarian", "Romanian"]

		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200", translate("Target Language"))
		editorGui.Add("DropDownList", "x120 yp w280 Choose1 VtranslatorTargetLanguageDropDown", collect(translationLanguages, translate))

		translatorServices := ["Google", "Azure", "DeepL", "OpenRouter"]

		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200", translate("Translator"))
		editorGui.Add("DropDownList", "x120 yp w280 Choose1 VtranslatorServiceDropDown", translatorServices)
		editorGui["translatorServiceDropDown"].OnEvent("Change", updateTranslatorFields)

		; URL/Endpoint field (visibility depends on service)
		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200 VtranslatorEndpointLabel", translate("Endpoint"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorEndpointEdit")

		; API Key field (always visible)
		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200", translate("API Key"))
		editorGui.Add("Edit", "x120 yp w280 h21 Password VtranslatorAPIKeyEdit")

		; Additional field (visibility depends on service)
		editorGui.Add("Text", "x8 yp+30 w100 h23 +0x200 VtranslatorAdditionalLabel", translate("Region"))
		editorGui.Add("Edit", "x120 yp w280 h21 VtranslatorAdditionalEdit")

		editorGui.Add("Text", "x8 yp+35 w400 0x10")

		editorGui.Add("Button", "x120 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.saveEditor())
		editorGui.Add("Button", "x208 yp w80 h23", translate("Cancel")).OnEvent("Click", (*) => this.closeEditor())

		return editorGui
	}

	updateTranslatorFields() {
		local service := this.Control["translatorServiceDropDown"].Text
		local endpointLabel := this.Control["translatorEndpointLabel"]
		local endpointEdit := this.Control["translatorEndpointEdit"]
		local additionalLabel := this.Control["translatorAdditionalLabel"]
		local additionalEdit := this.Control["translatorAdditionalEdit"]

		; Hide all optional fields by default
		endpointLabel.Visible := false
		endpointEdit.Visible := false
		additionalLabel.Visible := false
		additionalEdit.Visible := false

		; Show fields based on selected service
		if (service = "Azure") {
			; Azure needs endpoint and region
			endpointLabel.Text := translate("Endpoint")
			endpointLabel.Visible := true
			endpointEdit.Visible := true
			additionalLabel.Text := translate("Region")
			additionalLabel.Visible := true
			additionalEdit.Visible := true
		}
		else if (service = "DeepL") {
			; DeepL has optional custom endpoint
			endpointLabel.Text := translate("API URL")
			endpointLabel.Visible := true
			endpointEdit.Visible := true
		}
		else if (service = "OpenRouter") {
			; OpenRouter needs model selection
			endpointLabel.Visible := false
			endpointEdit.Visible := false
			additionalLabel.Text := translate("Model")
			additionalLabel.Visible := true
			additionalEdit.Visible := true
		}
		; Google needs nothing extra
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		; Load translation settings for this assistant
		this.Value["translatorEnabled"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "Enabled", false)
		this.Value["translatorTargetLanguage"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "TargetLanguage", "Spanish")
		this.Value["translatorService"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "Service", "Google")
		this.Value["translatorEndpoint"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "Endpoint", "")
		this.Value["translatorAPIKey"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "APIKey", "")
		this.Value["translatorAdditional"] := getMultiMapValue(configuration, this.Assistant . ".Translation", "Additional", "")

		if this.Window
			this.updateTranslatorFields()
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		; Save translation settings for this assistant
		setMultiMapValue(configuration, this.Assistant . ".Translation", "Enabled", this.Control["translatorEnabledCheck"].Value)
		setMultiMapValue(configuration, this.Assistant . ".Translation", "TargetLanguage", this.Control["translatorTargetLanguageDropDown"].Text)
		setMultiMapValue(configuration, this.Assistant . ".Translation", "Service", this.Control["translatorServiceDropDown"].Text)
		setMultiMapValue(configuration, this.Assistant . ".Translation", "Endpoint", this.Control["translatorEndpointEdit"].Text)
		setMultiMapValue(configuration, this.Assistant . ".Translation", "APIKey", this.Control["translatorAPIKeyEdit"].Text)
		setMultiMapValue(configuration, this.Assistant . ".Translation", "Additional", this.Control["translatorAdditionalEdit"].Text)
	}

	editTranslator(assistant := false) {
		local window, result

		if !assistant
			assistant := this.Assistant

		window := this.Window

		this.loadFromConfiguration(this.Configuration)

		window.Show("AutoSize Center")

		loop {
			Sleep(100)
		}
		until this.iResult

		result := this.iResult

		window.Hide()

		; Return configuration if saved, false if cancelled
		return (result = kSaveEditor) ? this.Configuration : false
	}

	saveEditor() {
		this.saveToConfiguration(this.Configuration)

		this.iResult := kSaveEditor
	}

	closeEditor() {
		this.iResult := kCloseEditor
	}
}
