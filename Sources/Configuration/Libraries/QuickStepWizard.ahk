;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Quick Step Wizard               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; QuickStepWizard                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class QuickStepWizard extends StepWizard {
	Pages {
		Get {
			if this.SetupWizard.isQuickSetupAvailable()
				return (1 + (this.SetupWizard.QuickSetup ? 1 : 0))
			else
				return 0
		}
	}

	saveToConfiguration(configuration) {

	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local button1X := x + (Round(width / 3) - 32)
		local button2X := x + (Round(width / 3 * 2) - 32)
		local labelX := x + 35
		local labelY := y + 8
		local w, h

		chooseMethod(method, *) {
			if (method = "Quick") {
				window["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup.ico")
				window["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup Gray.ico")

				wizard.QuickSetup := true
			}
			else {
				window["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup Gray.ico")
				window["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup.ico")

				wizard.QuickSetup := false
			}
		}

		widget1 := window.Add("HTMLViewer", "x" . (x - 10) . " y" . y . " w" . (width + 20) . " h140 W:Grow H:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.Header." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget1.document.write(html)

		y += 150

		widget2 := window.Add("Picture", "x" . button1X . " y" . y . " w64 h64 vquickSetupButton Hidden X:Move(0.33)", kResourcesDirectory . (wizard.QuickSetup ? "Setup\Images\Quick Setup.ico" : "Setup\Images\Quick Setup Gray.ico"))
		widget2.OnEvent("Click", chooseMethod.Bind("Quick"))
		widget3 := window.Add("Text", "x" . button1X . " yp+68 w64 Hidden Center X:Move(0.33)", translate("Quick"))

		widget4 := window.Add("Picture", "x" . button2X . " y" . y . " w64 h64 vcustomSetupButton Hidden X:Move(0.66)", kResourcesDirectory . (!wizard.QuickSetup ? "Setup\Images\Full Setup.ico" : "Setup\Images\Full Setup Gray.ico"))
		widget4.OnEvent("Click", chooseMethod.Bind("Custom"))
		widget5 := window.Add("Text", "x" . button2X . " yp+68 w64 Hidden Center X:Move(0.66)", translate("Custom"))

		y += 100

		widget6 := window.Add("HTMLViewer", "x" . (x - 10) . " y" . y . " w" . (width + 20) . " h140 W:Grow H:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.Footer." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget6.document.write(html)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6)
	}

	showPage(page) {
		return super.showPage(page)
	}

	hidePage(page) {
		return super.hidePage(page)
	}

	startSetup() {
		local wizard := this.SetupWizard
		local ignore, module

		wizard.deselectModules(false)

		for ignore, module in string2Values("|", wizard.Setps["Modules"].Definition)
			wizard.selectModule(module, false, false)

		wizard.selectModule("Voice Control", true, false)
		wizard.selectModule("Race Engineer", true, false)
		wizard.selectModule("Race Strategist", true, false)
		wizard.selectModule("Race Spotter", true, false)
	}

	finishSetup() {
		local voiceConfiguration := readMultiMap(kResourcesDirectory . "Setup\Presets\Voice Control Configuration.ini")
		local voiceSetup := this.Setup["Voice"]
		local patch := substituteVariables(FileRead(kResourcesDirectory . "Setup\Presets\Configuration Patch.template")
										 , {engineerLanguage: this.Setup["Engineer"].Language, engineerSpeed: this.Setup["Engineer"].Speed
										  , engineerName: this.Setup["Engineer"].Name, engineerVoice: this.Setup["Engineer"].Voice
										  , strategistLanguage: this.Setup["Strategist"].Language, strategistSpeed: this.Setup["Strategist"].Speed
										  , strategistName: this.Setup["Strategist"].Name, strategistVoice: this.Setup["Strategist"].Voice
										  , spotterLanguage: this.Setup["Spotter"].Language, spotterSpeed: this.Setup["Spotter"].Speed
										  , spotterName: this.Setup["Spotter"].Name, spotterVoice: this.Setup["Spotter"].Voice})
		local languageCode := "en"
		local code, language

		deleteFile(kUserHomeDirectory . "Setup\Configuration Patch.ini", true)

		FileAppend(patch, kUserHomeDirectory . "Setup\Configuration Patch.ini")

		setMultiMapValue(voiceConfiguration, "Voice Control", "Language", getLanguage())
		setMultiMapValue(voiceConfiguration, "Voice Control", "PushToTalk", this.Control["quickPush2TalkEdit"].Text)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Synthesizer", "dotNet")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Speaker", true)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Recognizer", "Desktop")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Listener", true)

		writeMultiMap(kResourcesDirectory . "Setup\Presets\Voice Control Configuration.ini", voiceConfiguration)

		for code, language in availableLanguages()
			if (language = this.Control["quickUILanguageDropDown"].Text) {
				languageCode := code

				break
			}

		this.SetupWizard.setGeneralConfiguration(languageCode, true, false)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickStepWizard() {
	SetupWizard.Instance.registerStepWizard(QuickStepWizard(SetupWizard.Instance, "Quick", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickStepWizard()