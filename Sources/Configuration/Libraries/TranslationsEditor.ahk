;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translations Editor             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ConfigurationItemList.ahk"
#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TranslationsEditor extends ConfiguratorPanel {
	iWindow := false

	iLanguagesChanged := false
	iTranslationsList := false
	iClosed := false

	class TranslationsWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Translations Editor", Closeable: true, Resizeable: true, Options: "-MaximizeBox"})
		}

		Close(*) {
			this.iEditor.closeEditor()
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	TranslationsList {
		Get {
			return this.iTranslationsList
		}
	}

	__New(configuration) {
		this.iTranslationsList := TranslationsList(configuration)

		super.__New(configuration)

		TranslationsEditor.Instance := this
	}

	createGui(configuration) {
		local choices, chosen, code, language, languageName, isoCode

		static translationGui

		addLanguage(*) {
			protectionOn()

			try {
				this.addLanguage()
			}
			finally {
				protectionOff()
			}
		}

		deleteLanguage(*) {
			protectionOn()

			try {
				this.deleteLanguage()
			}
			finally {
				protectionOff()
			}
		}

		chooseTranslationLanguage(*) {
			protectionOn()

			try {
				this.chooseLanguage()
			}
			finally {
				protectionOff()
			}
		}

		translationGui := TranslationsEditor.TranslationsWindow(this)

		this.Window := translationGui

		translationGui.SetFont("Bold", "Arial")

		translationGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(translationGui, "Translations Editor"))

		translationGui.SetFont("Norm", "Arial")

		translationGui.Add("Documentation", "x158 YP+20 w88 H:Center Center", translate("Translations")
						 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor")

		translationGui.SetFont("Norm", "Arial")

		translationGui.Add("Text", "x50 y+10 w310 W:Grow 0x10")

		choices := []
		chosen := 0

		for code, language in availableLanguages() {
			choices.Push(language)

			if (code == getLanguage()) {
				chosen := A_Index

				isoCode := code
				languageName := language
			}
		}

		translationGui.Add("Text", "x16 w160 h23 +0x200", translate("Language"))
		translationGui.Add("DropDownList", "x184 yp w158 W:Grow(0.2) Choose" . chosen . " vtranslationLanguageDropDown", choices).OnEvent("Change", chooseTranslationLanguage)

		translationGui.Add("Button", "x343 yp-1 w23 h23 X:Move(0.2) vaddLanguageButton").OnEvent("Click", addLanguage)
		translationGui.Add("Button", "x368 yp w23 h23 X:Move(0.2) vdeleteLanguageButton").OnEvent("Click", deleteLanguage)

		setButtonIcon(translationGui["addLanguageButton"], kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(translationGui["deleteLanguageButton"], kIconsDirectory . "Minus.ico", 1)

		translationGui.Add("Text", "x16 w160 h23 +0x200", translate("ISO Code / Identifier"))
		translationGui.Add("Edit", "x184 yp w40 h21 Disabled visoCodeEdit", isoCode)
		translationGui.Add("Edit", "x236 yp w155 h21 W:Grow(0.2) Disabled vlanguageNameEdit", languageName)

		this.iTranslationsList.createGui(this, configuration)
	}

	editTranslations(owner := false) {
		local window, x, y, w, h

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Translations Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Translations Editor", &w, &h)
			window.Resize("Initialize", w, h)

		this.iTranslationsList.loadTranslations((this.Control["isoCodeEdit"].Text != "") ? this.Control["isoCodeEdit"].Text : "en")

		loop
			Sleep(200)
		until this.iClosed

		try {
			return this.iLanguagesChanged
		}
		finally {
			window.Destroy()
		}
	}

	saveTranslations() {
		local choices, chosen, found, code, language

		if this.iTranslationsList.saveTranslations() {
			choices := []
			chosen := 0
			found := false

			for code, language in availableLanguages() {
				choices.Push(language)

				if (code = this.Control["isoCodeEdit"].Text) {
					chosen := A_Index
					found := true
				}
			}

			if !found {
				choices.Push(this.Control["languageNameEdit"].Text)
				chosen := choices.Length
			}

			this.Control["translationLanguageDropDown"].Delete()
			this.Control["translationLanguageDropDown"].Add(choices)
			this.Control["translationLanguageDropDown"].Choose(chosen)
		}
	}

	closeEditor() {
		this.saveTranslations()

		this.iClosed := true
	}

	addLanguage() {
		local choices := []
		local ignore, language

		this.iLanguagesChanged := true

		this.saveTranslations()

		for ignore, language in availableLanguages()
			choices.Push(language)

		this.Control["isoCodeEdit"].Text := "XX"
		this.Control["languageNameEdit"].Text := translate("New Language")

		choices.Push(this.Control["languageNameEdit"].Text)

		this.Control["translationLanguageDropDown"].Delete()
		this.Control["translationLanguageDropDown"].Add(choices)
		this.Control["translationLanguageDropDown"].Choose(choices.Length)

		this.Control["isoCodeEdit"].Enabled := true
		this.Control["languageNameEdit"].Enabled := true

		this.iTranslationsList.newTranslations()
	}

	deleteLanguage() {
		local msgResult, languageCode, code, language, ignore, fileName

		SoundPlay("*32")

		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Do you really want to delete this translation?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			this.iLanguagesChanged := true

			languageCode := kUndefined

			for code, language in availableLanguages()
				if ((language = this.Control["translationLanguageDropDown"].Text) && (code != "en"))
					languageCode := code

			if (languageCode != kUndefined)
				for ignore, fileName in getFileNames("Translations." . languageCode, kUserTranslationsDirectory)
					deleteFile(fileName)

			this.chooseLanguage("en", false)
		}
	}

	chooseLanguage(languageCode := false, save := true) {
		local allLanguages, code, language, choices, chosen

		if save
			this.iTranslationsList.saveTranslations()

		allLanguages := availableLanguages()

		if !languageCode
			for code, language in allLanguages
				if (language = this.Control["translationLanguageDropDown"].Text) {
					languageCode := code

					break
				}

		choices := []
		chosen := 0

		for code, language in allLanguages {
			choices.Push(language)

			if (code = languageCode) {
				this.Control["isoCodeEdit"].Text := code
				this.Control["languageNameEdit"].Text := language

				chosen := A_Index
			}
		}

		this.Control["translationLanguageDropDown"].Delete()
		this.Control["translationLanguageDropDown"].Add(choices)
		this.Control["translationLanguageDropDown"].Choose(chosen)

		this.Control["isoCodeEdit"].Enabled := false
		this.Control["languageNameEdit"].Enabled := false

		this.iTranslationsList.loadTranslations(this.Control["isoCodeEdit"].Text)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsList                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class TranslationsList extends ConfigurationItemList {
	iChanged := false
	iLanguageCode := ""

	__New(configuration) {
		super.__New(configuration)

		TranslationsList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window
		local option

		nextUntranslated(*) {
			local untranslated

			protectionOn()

			try {
				untranslated := this.findNextUntranslated()

				if untranslated
					this.openEditor(untranslated)
			}
			finally {
				protectionOff()
			}
		}

		window.Add("ListView", "x16 y+10 w377 h140 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VtranslationsListView", collect(["Original", "Translation"], translate))

		window.Add("Text", "x16 w86 h23 Y:Move +0x200", translate("Original"))
		window.Add("Edit", "x110 yp w283 h80 Y:Move W:Grow Disabled voriginalTextEdit")

		window.Add("Text", "x16 w86 h23 Y:Move +0x200", translate("Translation"))

		option := (this.iLanguageCode = "en") ? "Disabled" : ""

		window.Add("Button", "x85 yp w23 h23 Y:Move " . option . " Default vnextUntranslatedButton").OnEvent("Click", nextUntranslated)
		setButtonIcon(window["nextUntranslatedButton"], kIconsDirectory . "Down Arrow.ico", 1)

		window.Add("Edit", "x110 yp w283 h80 Y:Move W:Grow VtranslationTextEdit")

		this.initializeList(editor, window["translationsListView"])
	}

	loadList(items) {
		local count, index, translation

		static first := true

		if (first != this.Control["translationsListView"])
			first := true

		count := this.Control["translationsListView"].GetCount()

		for index, translation in this.ItemList
			if (index <= count)
				this.Control["translationsListView"].Modify(index, "", translation[1], translation[2])
			else
				this.Control["translationsListView"].Add("", translation[1], translation[2])

		if (items.Length < count)
			loop count - items.Length
				this.Control["translationsListView"].Delete(count - A_Index + 1)

		if ((first == true) || (this.iLanguageCode = "en")) {
			this.Control["translationsListView"].ModifyCol()
			this.Control["translationsListView"].ModifyCol(1, 150)
			this.Control["translationsListView"].ModifyCol(2, 300)

			first := this.Control["translationsListView"]
		}
	}

	updateState() {
		super.updateState()
	}

	loadEditor(item) {
		local originalText := item[1]
		local translationText := item[2]

		if (translationText == "")
			translationText := originalText

		this.Control["originalTextEdit"].Text := originalText
		this.Control["translationTextEdit"].Text := translationText
	}

	clearEditor() {
		this.Control["originalTextEdit"].Text := ""
		this.Control["translationTextEdit"].Text := ""
	}

	buildItemFromEditor(isNew := false) {
		local originalText := this.Control["originalTextEdit"].Text
		local translationText := this.Control["translationTextEdit"].Text

		translationText := (translationText == originalText) ? "" : translationText

		if isNew
			this.iChanged := true
		else
			this.iChanged := this.iChanged || (this.ItemList[this.CurrentItem][2] != translationText)

		return Array(originalText, translationText)
	}

	openEditor(itemIndex) {
		if (this.CurrentItem != 0)
			if (this.ItemList[this.CurrentItem][2] != this.Control["translationTextEdit"].Text)
				this.updateItem()

		super.openEditor(itemIndex)
	}

	findNextUntranslated() {
		local index, translation

		for index, translation in this.ItemList
			if ((index > this.CurrentItem) && (translation[2] = ""))
				return index

		OnMessage(0x44, translateOkButton)
		MsgBox(translate("There is no missing translation..."), translate("Information"), 262192)
		OnMessage(0x44, translateOkButton, 0)

		return false
	}

	newTranslations() {
		this.loadTranslations("xx", true)

		this.iChanged := true
	}

	loadTranslations(languageCode, new := false) {
		local translations, original, translation

		this.iLanguageCode := languageCode

		this.Control["nextUntranslatedButton"].Enabled := (languageCode != "en")

		this.ItemList := []

		translations := readTranslations((this.iLanguageCode = "xx") ? "en" : this.iLanguageCode, true, true)

		if (this.iLanguageCode != "en")
			for original, translation in readTranslations("en")
				if !translations.Has(original)
					translations[original] := translation

		for original, translation in translations
			this.ItemList.Push(Array(original, translation))

		this.loadList(this.ItemList)
		this.clearEditor()

		this.CurrentItem := 0
		this.iChanged := false
	}

	saveTranslations() {
		local msgResult, translations, ignore, item, original, translated, title

		if (this.CurrentItem != 0)
			this.updateItem()

		if this.iChanged {
			SoundPlay("*32")

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox(translate("Do you want to save your changes? Any existing translations will be overwritten."), translate("Save"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes") {
				this.iChanged := false

				translations := CaseInsenseMap()

				this.iLanguageCode := this.Control["isoCodeEdit"].Text

				for ignore, item in this.ItemList {
					original := item[1]
					translated := item[2]

					if (translations.Has(original) && (translated != translations[original])) {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("Inconsistent translations detected - please correct..."), translate("Error"), 262160)
						OnMessage(0x44, translateOkButton, 0)

						return false
					}

					translations[original] := translated
				}

				this.Window.Block()

				try {
					writeTranslations(this.iLanguageCode , this.Control["languageNameEdit"].Text, translations)
				}
				finally {
					this.Window.Unblock()
				}

				return true
			}
		}

		return false
	}
}