;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translations Editor             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ConfigurationItemList.ahk
#Include Libraries\ConfigurationEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global translationLanguageDropDown
global addLanguageButton
global deleteLanguageButton

global isoCodeEdit = ""
global languageNameEdit = ""

class TranslationsEditor extends ConfigurationItem {
	iLanguagesChanged := false
	iTranslationsList := false
	iClosed := false
	
	TranslationsList[] {
		Get {
			return this.iTranslationsList
		}
	}
	
	__New(configuration) {
		this.iTranslationsList := new TranslationsList(configuration)
		
		base.__New(configuration)
		
		TranslationsEditor.Instance := this
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Gui TE:Default
	
		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0, D8D8D8

		Gui TE:Font, Bold, Arial

		Gui TE:Add, Text, w388 Center gmoveTranslationsEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic Underline, Arial

		Gui TE:Add, Text, YP+20 w388 cBlue Center gopenTranslationsDocumentation, % translate("Translations")

		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		choices := []
		chosen := 0
		
		for code, language in availableLanguages() {
			choices.Push(language)
			
			if (language == languageDropDown) {
				chosen := A_Index
				
				isoCodeEdit := code
				languageNameEdit := language
			}
		}
			
		Gui TE:Add, Text, x16 w160 h23 +0x200, % translate("Language")
		Gui TE:Add, DropDownList, x184 yp w158 Choose%chosen% VtranslationLanguageDropDown gchooseTranslationLanguage, % values2String("|", choices*)
		Gui TE:Add, Button, x343 yp-1 w23 h23 HwndaddLanguageButtonHandle VaddLanguageButton gaddLanguage
		Gui TE:Add, Button, x368 yp w23 h23 HwnddeleteLanguageButtonHandle VdeleteLanguageButton gdeleteLanguage
		setButtonIcon(addLanguageButtonHandle, kIconsDirectory . "Plus.ico", 1)
		setButtonIcon(deleteLanguageButtonHandle, kIconsDirectory . "Minus.ico", 1)
		
		Gui TE:Add, Text, x16 w160 h23 +0x200, % translate("ISO Code / Identifier")
		Gui TE:Add, Edit, x184 yp w40 h21 Disabled VisoCodeEdit, %isoCodeEdit%
		Gui TE:Add, Edit, x236 yp w155 h21 Disabled VlanguageNameEdit, %languageNameEdit%
	
		this.iTranslationsList.createGui(configuration)
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		Gui TE:Add, Button, x166 yp+10 w80 h23 Default GcloseTranslationsEditor, % translate("Close")
	}
	
	editTranslations() {
		Gui TE:Show, AutoSize Center
		
		GuiControlGet isoCodeEdit
		
		this.iTranslationsList.loadTranslations((isoCodeEdit != "") ? isoCodeEdit : "en")
		
		Loop
			Sleep 200
		until this.iClosed
		
		try {
			return this.iLanguagesChanged
		}
		finally {
			Gui TE:Destroy
		}
	}
	
	saveTranslations() {
		if this.iTranslationsList.saveTranslations() {
			GuiControlGet isoCodeEdit
			GuiControlGet languageNameEdit
			
			choices := []
			chosen := 0
			found := false
			
			for code, language in availableLanguages() {
				choices.Push(language)
				
				if (code = isoCodeEdit) {
					chosen := A_Index
					found := true
				}
			}
			
			if !found {
				choices.Push(languageNameEdit)
				chosen := choices.Length()
			}
			
			GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
			GuiControl Choose, translationLanguageDropDown, % chosen
		}
	}
	
	closeEditor() {
		this.saveTranslations()
		
		this.iClosed := true
	}
	
	addLanguage() {
		this.iLanguagesChanged := true
		this.saveTranslations()
		
		choices := []
		
		for ignore, language in availableLanguages()
			choices.Push(language)
		
		isoCodeEdit := "XX"
		languageNameEdit := translate("New Language")
		
		choices.Push(languageNameEdit)
			
		GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, translationLanguageDropDown, % choices.Length()
		
		GuiControl Text, isoCodeEdit, %isoCodeEdit%
		GuiControl Text, languageNameEdit, %languageNameEdit%
		
		GuiControl Enable, isoCodeEdit
		GuiControl Enable, languageNameEdit
		
		this.iTranslationsList.newTranslations()
	}
	
	deleteLanguage() {
		GuiControlGet translationLanguageDropDown
		
		SoundPlay *32
	
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Delete")
		MsgBox 262436, %title%, % translate("Do you really want to delete this translation?")
		OnMessage(0x44, "")

		IfMsgBox Yes
		{
			this.iLanguagesChanged := true
			
			languageCode := kUndefined

			for code, language in availableLanguages()
				if ((language = translationLanguageDropDown) && (code != "en"))
					languageCode := code
			
			if (languageCode != kUndefined)
				for ignore, fileName in getFileNames("Translations." . languageCode, kUserTranslationsDirectory, kTranslationsDirectory)
					try {
						FileDelete %fileName%
					}
					catch exception {
						; ignore
					}
			
			this.chooseLanguage("en")
		}
	}
	
	chooseLanguage(languageCode := false) {
		this.iTranslationsList.saveTranslations()
		
		availableLanguages := availableLanguages()
		
		if !languageCode {
			GuiControlGet translationLanguageDropDown
			
			for code, language in availableLanguages
				if (language = translationLanguageDropDown) {
					languageCode := code
					
					break
				}
		}
	
		choices := []
		
		for code, language in availableLanguages {
			choices.Push(language)
		
			if (code = languageCode) {
				isoCodeEdit := code
				languageNameEdit := language
		
				chosen := A_Index
			}
		}
				
		GuiControl, , translationLanguageDropDown, % "|" . values2String("|", choices*)
		GuiControl Choose, translationLanguageDropDown, %chosen%
		
		GuiControl Text, isoCodeEdit, %isoCodeEdit%
		GuiControl Text, languageNameEdit, %languageNameEdit%
		
		GuiControl Disable, isoCodeEdit
		GuiControl Disable, languageNameEdit
		
		this.iTranslationsList.loadTranslations(isoCodeEdit)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; TranslationsList                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global translationsListView

global originalTextEdit = ""
global translationTextEdit = ""

global nextUntranslatedButtonHandle
		
class TranslationsList extends ConfigurationItemList {
	iChanged := false
	iLanguageCode := ""
	
	__New(configuration) {
		base.__New(configuration)
				 
		TranslationsList.Instance := this
	}
					
	createGui(configuration) {
		Gui TE:Add, ListView, x16 y+10 w377 h140 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndtranslationsListViewHandle VtranslationsListView glistEvent
							, % values2String("|", map(["Original", "Translation"], "translate")*)
		
		Gui TE:Add, Text, x16 w86 h23 +0x200, % translate("Original")
		Gui TE:Add, Edit, x110 yp w283 h80 Disabled VoriginalTextEdit, %originalTextEdit%
	
		Gui TE:Add, Text, x16 w86 h23 +0x200, % translate("Translation")
		
		option := (this.iLanguageCode = "en") ? "Disabled" : ""
		
		Gui TE:Add, Button, x85 yp w23 h23 %option% Default HwndnextUntranslatedButtonHandle gnextUntranslated
		setButtonIcon(nextUntranslatedButtonHandle, kIconsDirectory . "Down Arrow.ico", 1)
		Gui TE:Add, Edit, x110 yp w283 h80 VtranslationTextEdit, %translationTextEdit%
		
		this.initializeList(translationsListViewHandle, "translationsListView")
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
		
		count := LV_GetCount()
		
		for index, translation in this.ItemList
			if (index <= count)
				LV_Modify(index, "", translation[1], translation[2])
			else
				LV_Add("", translation[1], translation[2])
		
		if (items.Length() < count)
			Loop % count - items.Length()
				LV_Delete(count - A_Index - 1)
			
		if (first || (this.iLanguageCode = "en")) {
			LV_ModifyCol()
			LV_ModifyCol(1, 150)
			LV_ModifyCol(2, 300)
			
			first := false
		}
	}
	
	updateState() {
		base.updateState()
	}
	
	loadEditor(item) {
		originalTextEdit := item[1]
		translationTextEdit := item[2]
		
		if (translationTextEdit == "")
			translationTextEdit := originalTextEdit
		
		GuiControl Text, originalTextEdit, %originalTextEdit%
		GuiControl Text, translationTextEdit, %translationTextEdit%
	}
	
	clearEditor() {
		originalTextEdit := ""
		translationTextEdit := ""
		
		GuiControl Text, originalTextEdit, %originalTextEdit%
		GuiControl Text, translationTextEdit, %translationTextEdit%
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet originalTextEdit
		GuiControlGet translationTextEdit
		
		translationTextEdit := (translationTextEdit == originalTextEdit) ? "" : translationTextEdit
		
		if isNew
			this.iChanged := true
		else
			this.iChanged := this.iChanged || (this.ItemList[this.CurrentItem][2] != translationTextEdit)
		
		return Array(originalTextEdit, translationTextEdit)
	}
	
	openEditor(itemIndex) {
		if (this.CurrentItem != 0) {
			GuiControlGet translationTextEdit
			
			if (this.ItemList[this.CurrentItem][2] != translationTextEdit)
				this.updateItem()
		}
			
		base.openEditor(itemIndex)
	}
	
	findNextUntranslated() {
		for index, translation in this.ItemList
			if ((index > this.CurrentItem) && (translation[2] = ""))
				return index
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Information")
		MsgBox 262192, %title%, % translate("There is no missing translation...")
		OnMessage(0x44, "")
		
		return false
	}
	
	newTranslations() {
		this.loadTranslations("en")
		
		this.iChanged := true
	}
	
	loadTranslations(languageCode) {
		this.iLanguageCode := languageCode
		
		if (languageCode = "en")
			GuiControl Disable, %nextUntranslatedButtonHandle%
		else
			GuiControl Enable, %nextUntranslatedButtonHandle%
		
		this.ItemList := []
		
		translations := readTranslations(this.iLanguageCode)
		
		if (this.iLanguageCode != "en")
			for original, translation in readTranslations("en")
				if !translations.HasKey(original)
					translations[original] := translation
				
		for original, translation in translations
			this.ItemList.Push(Array(original, translation))
			
		this.loadList(this.ItemList)
		this.clearEditor()
		
		this.CurrentItem := 0
		this.iChanged := false
	}
	
	saveTranslations() {
		if (this.CurrentItem != 0)
			this.updateItem()

		if this.iChanged {
			SoundPlay *32
		
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			title := translate("Save")
			MsgBox 262436, %title%, % translate("Do you want to save your changes? Any existing translations will be overwritten.")
			OnMessage(0x44, "")

			IfMsgBox Yes
			{
				this.iChanged := false
				
				translations := {}
				
				GuiControlGet isoCodeEdit
				GuiControlGet languageNameEdit
				
				this.iLanguageCode := isoCodeEdit
				
				for ignore, item in this.ItemList {
					original := item[1]
					translated := item[2]
				
					if (translations.HasKey(original) && (translated != translations[original])) {
						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						title := translate("Error")
						MsgBox 262160, %title%, % translate("Inconsistent translations detected - please correct...")
						OnMessage(0x44, "")
						
						return false
					}
						
					translations[original] := translated
				}
				
				Gui TE:+Disabled
				
				try {
					writeTranslations(isoCodeEdit, languageNameEdit, translations)
				}
				finally {
					Gui TE:-Disabled
				}
				
				return true
			}
		}
		
		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

addLanguage(){
	protectionOn()
	
	try {
		TranslationsEditor.Instance.addLanguage()
	}
	finally {
		protectionOff()
	}
}

deleteLanguage() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.deleteLanguage()
	}
	finally {
		protectionOff()
	}
}

closeTranslationsEditor() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.closeEditor()
	}
	finally {
		protectionOff()
	}
}

moveTranslationsEditor() {
	moveByMouse("TE")
}

chooseTranslationLanguage() {
	protectionOn()
	
	try {
		TranslationsEditor.Instance.chooseLanguage()
	}
	finally {
		protectionOff()
	}
}

openTranslationsDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor
}

nextUntranslated() {
	protectionOn()
	
	try {
		list := TranslationsEditor.Instance.TranslationsList
		untranslated := list.findNextUntranslated()
		
		if untranslated
			list.openEditor(untranslated)
	}
	finally {
		protectionOff()
	}
}