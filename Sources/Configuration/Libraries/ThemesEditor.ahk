;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Themes Editor                   ;;;
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
;;; ThemesEditor                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global windowTitleEdit = ""
global windowSubtitleEdit = ""

class ThemesEditor extends ConfigurationItem {
	iClosed := false
	iThemesList := false
	
	__New(configuration) {
		this.iThemesList := new ThemesList(configuration)
		
		base.__New(configuration)
		
		ThemesEditor.Instance := this
		
		this.createGui(configuration)
	}
	
	createGui(configuration) {
		Gui TE:Default
	
		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0, D8D8D8

		Gui TE:Font, Bold, Arial

		Gui TE:Add, Text, w388 Center gmoveThemesEditor, % translate("Modular Simulator Controller System") 
		
		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic Underline, Arial

		Gui TE:Add, Text, x158 YP+20 w88 cBlue Center gopenThemesDocumentation, % translate("Themes")

		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x16 y48 w160 h23 +0x200, % translate("Upper Title")
		Gui TE:Add, Edit, x110 y48 w284 h21 VwindowTitleEdit, %windowTitleEdit%
		
		Gui TE:Add, Text, x16 y72 w160 h23 +0x200, % translate("Lower Title")
		Gui TE:Add, Edit, x110 y72 w284 h21 VwindowSubtitleEdit, %windowSubtitleEdit%
		
		Gui TE:Add, Text, x50 y106 w310 0x10
		
		this.iThemesList.createGui(configuration)
		
		Gui TE:Add, Text, x50 y+10 w310 0x10
		
		Gui TE:Add, Button, x126 yp+10 w80 h23 Default GsaveThemesEditor, % translate("Save")
		Gui TE:Add, Button, x214 yp w80 h23 GcancelThemesEditor, % translate("&Cancel")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		windowTitleEdit := getConfigurationValue(configuration, "Splash Window", "Title", "")
		windowSubtitleEdit := getConfigurationValue(configuration, "Splash Window", "Subtitle", "")
	}
	
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		setConfigurationValue(configuration, "Splash Window", "Title", windowTitleEdit)
		setConfigurationValue(configuration, "Splash Window", "Subtitle", windowSubtitleEdit)
		
		this.iThemesList.saveToConfiguration(configuration)
	}
	
	editThemes() {
		local x, y
		
		this.iThemesList.clearEditor()
		
		if getWindowPosition("Themes Editor", x, y)
			Gui TE:Show, x%x% y%y%
		else
			Gui TE:Show
		
		loop
			Sleep 200
		until this.iClosed
		
		try {
			if (this.iClosed == kOk) {
				configuration := newConfiguration()
				
				this.saveToConfiguration(configuration)
			
				return configuration
			}
			else
				return false
		}
		finally {
			Gui TE:Destroy
		}
	}
	
	closeEditor(save) {
		if save
			Gui TE:Submit
		
		this.iThemesList.togglePlaySoundFile(true)
		
		this.iClosed := (save ? kOk : kCancel)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ThemesList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global themesListView = false
global themeNameEdit = ""
global themeTypeDropDown = 0

global playSoundButtonHandle
global soundFilePathEdit = ""

global videoFilePathLabel
global videoFilePathEdit = ""
global videoFilePathButton

global picturesListLabel
global addPictureButton
global picturesListView
global picturesListViewHandle
global picturesListViewImages
global picturesDurationLabel
global picturesDurationEdit = 3000
global picturesDurationPostfix

global themeAddButton
global themeDeleteButton
global themeUpdateButton
		
class ThemesList extends ConfigurationItemList {
	iSoundIsPlaying := false
	
	__New(configuration) {
		base.__New(configuration)
				 
		ThemesList.Instance := this
	}
					
	createGui(configuration) {
		Gui TE:Add, ListView, x16 y120 w377 h140 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndthemesListViewHandle VthemesListView glistEvent
							, % values2String("|", map(["Theme", "Media", "Sound File"], "translate")*)
		
		Gui TE:Add, Text, x16 y270 w86 h23 +0x200, % translate("Theme")
		Gui TE:Add, Edit, x110 y270 w140 h21 VthemeNameEdit, %themeNameEdit%
		
		Gui TE:Add, Text, x16 y294 w86 h23 +0x200, % translate("Type")
		Gui TE:Add, DropDownList, x110 y294 w140 AltSubmit VthemeTypeDropDown gupdateThemesEditorState, % translate("Picture Carousel") . "|" . translate("Video")
		
		Gui TE:Add, Text, x16 y318 w160 h23 +0x200, % translate("Sound File")
		Gui TE:Add, Button, x85 y317 w23 h23 HwndplaySoundButtonHandle gtogglePlaySoundFile
		setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
		Gui TE:Add, Edit, x110 y318 w259 h21 VsoundFilePathEdit, %soundFilePathEdit%
		Gui TE:Add, Button, x371 y317 w23 h23 gchooseSoundFilePath, % translate("...")
		
		Gui TE:Add, Text, x16 y342 w80 h23 +0x200 VvideoFilePathLabel, % translate("Video")
		Gui TE:Add, Edit, x110 y342 w259 h21 VvideoFilePathEdit, %videoFilePathEdit%
		Gui TE:Add, Button, x371 y341 w23 h23 VvideoFilePathButton gchooseVideoFilePath, % translate("...")
		
		Gui TE:Add, Text, x16 y342 w80 h23 +0x200 VpicturesListLabel, % translate("Pictures")
		Gui TE:Add, Button, x85 y342 w23 h23 HwndaddPictureButtonHandle VaddPictureButton gaddThemePicture
		setButtonIcon(addPictureButtonHandle, kIconsDirectory . "Plus.ico", 1)
		Gui TE:Add, ListView, x110 y342 w284 h112 -Multi -LV0x10 Checked -Hdr NoSort NoSortHdr HwndpicturesListViewHandle VpicturesListView, % translate("Picture")	
		
		Gui TE:Add, Text, x16 y456 w80 h23 +0x200 VpicturesDurationLabel, % translate("Display Duration")
		Gui TE:Add, Edit, x110 y456 w40 h21 Limit5 Number VpicturesDurationEdit, %picturesDurationEdit%
		
		Gui TE:Font, Norm, Arial
		
		Gui TE:Add, Text, x154 y459 w40 h23 VpicturesDurationPostfix, % translate("ms")
	
		Gui TE:Add, Button, x184 y490 w46 h23 VthemeAddButton gaddItem, % translate("Add")
		Gui TE:Add, Button, x232 y490 w50 h23 Disabled VthemeDeleteButton gdeleteItem, % translate("Delete")
		Gui TE:Add, Button, x340 y490 w55 h23 Disabled VthemeUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(themesListViewHandle, "themesListView", "themeAddButton", "themeDeleteButton", "themeUpdateButton")
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		splashThemes := getConfigurationSectionValues(configuration, "Splash Themes", Object())
		themes := {}
		
		for descriptor, value in splashThemes {
			theme := StrSplit(descriptor, ".")[1]
			
			if !themes.HasKey(theme) {
				type := splashThemes[theme . ".Type"]
				media := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Images"] : splashThemes[theme . ".Video"])
				duration := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Duration"] : false)
				songFile := (splashThemes.HasKey(theme . ".Song") ? splashThemes[theme . ".Song"] : false)
				
				if !songFile
					songFile := ""
					
				themes[theme] := theme
				
				this.ItemList.Push(Array(type, theme, media, songFile, duration))
			}
		}
	}
		
	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		for index, theme in this.ItemList {
			name := theme[2]
			type := theme[1]
			songFile := theme[4]
			
			setConfigurationValue(configuration, "Splash Themes", name . ".Type", type)
			
			if (songFile && (songFile != ""))
				setConfigurationValue(configuration, "Splash Themes", name . ".Song", songFile)
				
			if (type == "Picture Carousel") {
				setConfigurationValue(configuration, "Splash Themes", name . ".Images", theme[3])
				setConfigurationValue(configuration, "Splash Themes", name . ".Duration", theme[5])
			}
			else
				setConfigurationValue(configuration, "Splash Themes", name . ".Video", theme[3])
		}
	}
	
	loadList(items) {
		static first := true
		
		Gui ListView, % this.ListHandle
	
		LV_Delete()
		
		for ignore, theme in items {
			songFile := theme[4]
			
			if (songFile != "") {
				SplitPath songFile, , , , nameNoExt

				songFile := nameNoExt
			}
			
			mediaFiles := []
			
			for ignore, mediaFile in string2Values(",", theme[3]) {
				SplitPath mediaFile, , , , nameNoExt

				mediaFiles.Push(nameNoExt)
			}
			
			LV_Add("", theme[2], values2String(", ", mediaFiles*), songFile)
		}
		
		if first {
			LV_ModifyCol(1, 100)
			LV_ModifyCol(2, 180)
			LV_ModifyCol(3, 100)
			
			first := false
		}
	}
	
	updateState() {
		base.updateState()
		
		GuiControlGet themeTypeDropDown
		
		if (themeTypeDropDown == 1) {
			GuiControl Show, picturesListLabel
			GuiControl Show, addPictureButton
			GuiControl Show, picturesListView
			GuiControl Show, picturesDurationLabel
			GuiControl Show, picturesDurationEdit
			GuiControl Show, picturesDurationPostfix
		}
		else {
			GuiControl Hide, picturesListLabel
			GuiControl Hide, addPictureButton
			GuiControl Hide, picturesListView
			GuiControl Hide, picturesDurationLabel
			GuiControl Hide, picturesDurationEdit
			GuiControl Hide, picturesDurationPostfix
		}
		
		if (themeTypeDropDown == 2) {
			GuiControl Show, videoFilePathLabel
			GuiControl Show, videoFilePathEdit
			GuiControl Show, videoFilePathButton
		}
		else {
			GuiControl Hide, videoFilePathLabel
			GuiControl Hide, videoFilePathEdit
			GuiControl Hide, videoFilePathButton
		}
	}
	
	initializePicturesList(pictures := "") {
		Gui ListView, % picturesListViewHandle
			
		LV_Delete()
		
		pictures := string2Values(",", pictures)
		
		picturesListViewImages := IL_Create(pictures.Length())
			
		for ignore, picture in pictures
			IL_Add(picturesListViewImages, getFileName(picture, kUserSplashMediaDirectory, kSplashMediaDirectory))
		
		LV_SetImageList(picturesListViewImages)
		
		loop % pictures.Length()
			LV_Add("Check Icon" . A_Index, pictures[A_Index])
			
		LV_ModifyCol()
	}
	
	loadEditor(item) {
		themeTypeDropDown := (item[1] == "Picture Carousel") ? 1 : 2
		themeNameEdit := item[2]
		soundFilePathEdit := item[4]
			
		GuiControl Choose, themeTypeDropDown, %themeTypeDropDown%
		GuiControl Text, themeNameEdit, %themeNameEdit%
		GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		
		if (themeTypeDropDown == 2)
			videoFilePathEdit := item[3]
		else
			videoFilePathEdit := ""
			
		GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		
		if (themeTypeDropDown == 1) {
			this.initializePicturesList(item[3])
			
			picturesDurationEdit := item[5]
			
			GuiControl Text, picturesDurationEdit, %picturesDurationEdit%
		}
		else
			this.initializePicturesList("")
		
		this.updateEditor()
	}
	
	clearEditor() {
		themeTypeDropDown := 0
		themeNameEdit := ""
		soundFilePathEdit := ""
		videoFilePathEdit := ""
		picturesDurationEdit := 3000
			
		GuiControl Choose, themeTypeDropDown, %themeTypeDropDown%
		GuiControl Text, themeNameEdit, %themeNameEdit%
		GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		GuiControl Text, picturesDurationEdit, %picturesDurationEdit%
		
		this.initializePicturesList("")
		
		this.updateEditor()
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet themeNameEdit
		GuiControlGet themeTypeDropDown
		GuiControlGet soundFilePathEdit
		GuiControlGet picturesDurationEdit
		
		type := ""
		media := ""
		
		if (themeTypeDropDown == 1) {
			type := "Picture Carousel"
			pictures := []
			
			Gui ListView, % picturesListViewHandle
			
			rowNumber := 0
			
			loop {
				rowNumber := LV_GetNext(rowNumber, "C")
				
				if !rowNumber
					break
					
				LV_GetText(fileName, rowNumber)
				
				pictures.Push(StrReplace(StrReplace(fileName, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))
			}
			
			media := values2String(", ", pictures*)
		}
		else if (themeTypeDropDown == 2) {
			type := "Video"
			
			GuiControlGet videoFilePathEdit
		
			media := videoFilePathEdit
		}
		else
			Goto error
		
		return Array(type, themeNameEdit, media, soundFilePathEdit, picturesDurationEdit)
		
error:
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		title := translate("Error")
		MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
		OnMessage(0x44, "")
		
		return false
	}
	
	togglePlaySoundFile(stop := false) {
		if (stop || this.iSoundIsPlaying) {
			try {
				SoundPlay NonExistent.avi
			}
			catch ignore {
				; Ignore
			}
			
			setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
			
			this.iSoundIsPlaying := false
		}
		else if !this.iSoundIsPlaying {
			try {
				songFile := getFileName(soundFilePathEdit, kUserSplashMediaDirectory, kSplashMediaDirectory)
				
				if FileExist(songFile) {
					SoundPlay %songFile%
				
					setButtonIcon(playSoundButtonHandle, kIconsDirectory . "Pause.ico", 1, "L2 T2 R2 B2")
					
					this.iSoundIsPlaying := true
				}
			}
			catch exception {
				; Ignore
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveThemesEditor() {
	protectionOn()
	
	try {
		ThemesEditor.Instance.closeEditor(true)
	}
	finally {
		protectionOff()
	}
}

cancelThemesEditor() {
	protectionOn()
	
	try {
		ThemesEditor.Instance.closeEditor(false)
	}
	finally {
		protectionOff()
	}
}

moveThemesEditor() {
	moveByMouse("TE", "Themes Editor")
}

openThemesDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor
}

updateThemesEditorState() {
	protectionOn()
	
	try {
		ConfigurationItemList.getList("themesListView").updateState()
	}
	finally {
		protectionOff()
	}
}

togglePlaySoundFile() {
	protectionOn()
	
	try {
		ThemesList.Instance.togglePlaySoundFile()
	}
	finally {
		protectionOff()
	}
}

addThemePicture() {
	protectionOn()
	
	try {
		title := translate("Select Image...")
	
		Gui +OwnDialogs
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
		FileSelectFile pictureFile, 1, , %title%, Image (*.jpg; *.gif)
		OnMessage(0x44, "")
		
		if (pictureFile != "") {
			Gui ListView, % picturesListViewHandle
			
			IL_Add(picturesListViewImages, LoadPicture(pictureFile, "W32 H32"), 0xFFFFFF, false)
			
			LV_Add("Check Icon" . (LV_GetCount() + 1), StrReplace(StrReplace(pictureFile, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))
			
			LV_ModifyCol()
			LV_Modify(LV_GetCount(), "Vis")
		}
	}
	finally {
		protectionOff()
	}
}

chooseSoundFilePath() {
	protectionOn()
	
	try {
		GuiControlGet soundFilePathEdit
		
		path := soundFilePathEdit
	
		if (path && (path != ""))
			path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
		else
			path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)
		
		title := translate("Select Sound File...")
		
		Gui +OwnDialogs
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
		FileSelectFile soundFile, 1, *%path%, %title%, Audio (*.wav; *.mp3)
		OnMessage(0x44, "")
		
		if (soundFile != "") {
			soundFilePathEdit := soundFile
			
			GuiControl Text, soundFilePathEdit, %soundFilePathEdit%
		}
	}
	finally {
		protectionOff()
	}
}

chooseVideoFilePath() {
	protectionOn()
	
	try {
		GuiControlGet videoFilePathEdit
		
		path := videoFilePathEdit
	
		if (path && (path != ""))
			path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
		else
			path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)
		
		title := translate("Select Video (GIF) File...")
		
		Gui +OwnDialogs
		
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
		FileSelectFile videoFile, 1, *%path%, %title%, Video (*.gif)
		OnMessage(0x44, "")
		
		if (videoFile != "") {
			videoFilePathEdit := videoFile
			
			GuiControl Text, videoFilePathEdit, %videoFilePathEdit%
		}
	}
	finally {
		protectionOff()
	}
}