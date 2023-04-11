;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Themes Editor                   ;;;
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
;;; ThemesEditor                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ThemesEditor extends ConfiguratorPanel {
	iClosed := false
	iThemesList := false

	class ThemesWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Themes Editor", Closeable: true, Resizeable: true, Options: "ToolWindow -MaximizeBox"}, "")
		}

		Close(*) {
			this.iEditor.closeEditor(false)
		}
	}

	__New(configuration) {
		this.iThemesList := ThemesList(configuration)

		super.__New(configuration)

		ThemesEditor.Instance := this
	}

	createGui(configuration) {
		local themesGui

		saveThemesEditor(*) {
			protectionOn()

			try {
				this.closeEditor(true)
			}
			finally {
				protectionOff()
			}
		}

		cancelThemesEditor(*) {
			protectionOn()

			try {
				this.closeEditor(false)
			}
			finally {
				protectionOff()
			}
		}

		themesGui := ThemesEditor.ThemesWindow(this)

		this.Window := themesGui

		themesGui.SetFont("Bold", "Arial")

		themesGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(themesGui, "Themes Editor"))

		themesGui.SetFont("Norm", "Arial")
		themesGui.SetFont("Italic Underline", "Arial")

		themesGui.Add("Text", "x158 YP+20 w88 H:Center cBlue Center", translate("Themes")).OnEvent("Click", openDocumentation.Bind(themesGui, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor"))

		themesGui.SetFont("Norm", "Arial")

		themesGui.Add("Text", "x16 y48 w160 h23 +0x200", translate("Upper Title"))
		themesGui.Add("Edit", "x110 y48 w284 h21 W:Grow VwindowTitleEdit", this.Value["windowTitle"])

		themesGui.Add("Text", "x16 y72 w160 h23 +0x200", translate("Lower Title"))
		themesGui.Add("Edit", "x110 y72 w284 h21 W:Grow VwindowSubtitleEdit", this.Value["windowSubtitle"])

		themesGui.Add("Text", "x50 y106 w310 W:Grow 0x10")

		this.iThemesList.createGui(this, configuration)

		themesGui.Add("Text", "x50 y+10 w310 Y:Move W:Grow 0x10")

		themesGui.Add("Button", "x126 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Save")).OnEvent("Click", saveThemesEditor)
		themesGui.Add("Button", "x214 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", cancelThemesEditor)
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.Value["windowTitle"] := getMultiMapValue(configuration, "Splash Window", "Title", "")
		this.Value["windowSubtitle"] := getMultiMapValue(configuration, "Splash Window", "Subtitle", "")
	}

	saveToConfiguration(configuration) {
		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Splash Window", "Title", this.Control["windowTitleEdit"].Text)
		setMultiMapValue(configuration, "Splash Window", "Subtitle", this.Control["windowSubtitleEdit"].Text)

		this.iThemesList.saveToConfiguration(configuration)
	}

	editThemes(owner := false) {
		local x, y, configuration, window

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		this.iThemesList.clearEditor()

		if getWindowPosition("Themes Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Themes Editor", &w, &h)
			window.Resize("Initialize", w, h)

		loop
			Sleep(200)
		until this.iClosed

		try {
			if (this.iClosed == kOk) {
				configuration := newMultiMap()

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

	closeEditor(save) {
		this.iThemesList.togglePlaySoundFile(true)

		this.iClosed := (save ? kOk : kCancel)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ThemesList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ThemesList extends ConfigurationItemList {
	iSoundIsPlaying := false
	iPicturesList := false

	PicturesList {
		Get {
			return this.iPicturesList
		}
	}

	__New(configuration) {
		super.__New(configuration)

		ThemesList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window

		updateThemesEditorState(*) {
			protectionOn()

			try {
				this.updateState()
			}
			finally {
				protectionOff()
			}
		}

		togglePlaySoundFile(*) {
			protectionOn()

			try {
				this.togglePlaySoundFile()
			}
			finally {
				protectionOff()
			}
		}

		addThemePicture(*) {
			local pictureFile

			protectionOn()

			try {
				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSaveCancelButtons)
				pictureFile := FileSelect(1, "", translate("Select Image..."), "Image (*.jpg; *.gif)")
				OnMessage(0x44, translateSaveCancelButtons, 0)

				if (pictureFile != "") {
					IL_Add(this.PicturesList, LoadPicture(pictureFile, "W32 H32"), 0xFFFFFF, false)

					this.Control["picturesListView"].Add("Check Icon" . (this.Control["picturesListView"].GetCount() + 1)
													   , StrReplace(StrReplace(pictureFile, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))

					this.Control["picturesListView"].ModifyCol()
					this.Control["picturesListView"].Modify(this.Control["picturesListView"].GetCount(), "Vis")
				}
			}
			finally {
				protectionOff()
			}
		}

		chooseSoundFilePath(*) {
			local path, soundFile

			protectionOn()

			try {
				path := this.Control["soundFilePathEdit"].Text

				if (path && (path != ""))
					path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
				else
					path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)

				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSelectCancelButtons)
				soundFile := FileSelect(1, "*" . path, translate("Select Sound File..."), "Audio (*.wav; *.mp3)")
				OnMessage(0x44, translateSelectCancelButtons, 0)

				if (soundFile != "")
					this.Control["soundFilePathEdit"].Text := soundFile
			}
			finally {
				protectionOff()
			}
		}

		chooseVideoFilePath(*) {
			local path, videoFile

			protectionOn()

			try {
				path := this.Control["videoFilePathEdit"].Text

				if (path && (path != ""))
					path := getFileName(path, kUserSplashMediaDirectory, kSplashMediaDirectory)
				else
					path := SubStr(kUserSplashMediaDirectory, 1, StrLen(kUserSplashMediaDirectory) - 1)

				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSelectCancelButtons)
				videoFile := FileSelect(1, "*" . path, translate("Select Video (GIF) File..."), "Video (*.gif)")
				OnMessage(0x44, translateSelectCancelButtons, 0)

				if (videoFile != "")
					this.Control["videoFilePathEdit"].Text := videoFile
			}
			finally {
				protectionOff()
			}
		}

		window.Add("ListView", "x16 y120 w377 h140 W:Grow H:Grow BackgroundD8D8D8 -Multi -LV0x10 AltSubmit NoSort NoSortHdr VthemesListView", collect(["Theme", "Media", "Sound File"], translate))
		window.Add("Text", "x16 y270 w86 h23 +0x200 Y:Move", translate("Theme"))
		window.Add("Edit", "x110 y270 w140 h21 Y:Move W:Grow(0.5) VthemeNameEdit")

		window.Add("Text", "x16 y294 w86 h23 +0x200 Y:Move", translate("Type"))
		window.Add("DropDownList", "x110 y294 w140 Y:Move W:Grow(0.5) AltSubmit VthemeTypeDropDown", [translate("Picture Carousel"), translate("Video")]).OnEvent("Change", updateThemesEditorState)

		window.Add("Text", "x16 y318 w160 h23 Y:Move +0x200", translate("Sound File"))
		window.Add("Button", "x85 y317 w23 h23 Y:Move vplaySoundFileButton").OnEvent("Click", togglePlaySoundFile)
		setButtonIcon(window["playSoundFileButton"], kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
		window.Add("Edit", "x110 y318 w259 h21 Y:Move W:Grow VsoundFilePathEdit")
		window.Add("Button", "x371 y317 w23 h23 Y:Move X:Move", translate("...")).OnEvent("Click", chooseSoundFilePath)

		window.Add("Text", "x16 y342 w80 h23 +0x200 Y:Move VvideoFilePathLabel", translate("Video"))
		window.Add("Edit", "x110 y342 w259 h21 Y:Move W:Grow VvideoFilePathEdit")
		window.Add("Button", "x371 y341 w23 h23 Y:Move X:Move VvideoFilePathButton", translate("...")).OnEvent("Click", chooseVideoFilePath)

		window.Add("Text", "x16 y342 w80 h23 +0x200 Y:Move VpicturesListLabel", translate("Pictures"))
		window.Add("Button", "x85 y342 w23 h23 Y:Move VaddPictureButton").OnEvent("Click", addThemePicture)
		setButtonIcon(window["addPictureButton"], kIconsDirectory . "Plus.ico", 1)

		window.Add("ListView", "x110 y342 w284 h112 Y:Move W:Grow BackgroundD8D8D8 -Multi -LV0x10 Checked -Hdr NoSort NoSortHdr VpicturesListView", [translate("Picture")])

		window.Add("Text", "x16 y456 w80 h23 +0x200 Y:Move VpicturesDurationLabel", translate("Display Duration"))
		window.Add("Edit", "x110 y456 w40 h21 Y:Move Limit5 Number VpicturesDurationEdit")

		window.SetFont("Norm", "Arial")

		window.Add("Text", "x154 y459 w40 h23 Y:Move VpicturesDurationPostfix", translate("ms"))

		window.Add("Button", "x184 y490 w46 h23 Y:Move X:Move VthemeAddButton", translate("Add"))
		window.Add("Button", "x232 y490 w50 h23 Y:Move X:Move Disabled VthemeDeleteButton", translate("Delete"))
		window.Add("Button", "x340 y490 w55 h23 Y:Move X:Move Disabled VthemeUpdateButton", translate("&Save"))

		this.initializeList(editor, window["themesListView"], window["themeAddButton"], window["themeDeleteButton"], window["themeUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local splashThemes := getMultiMapValues(configuration, "Splash Themes")
		local themes := CaseInsenseMap()
		local descriptor, value, theme, type, media, duration, songFile

		super.loadFromConfiguration(configuration)

		for descriptor, value in splashThemes {
			theme := StrSplit(descriptor, ".")[1]

			if !themes.Has(theme) {
				type := splashThemes[theme . ".Type"]
				media := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Images"] : splashThemes[theme . ".Video"])
				duration := ((type == ("Picture Carousel")) ? splashThemes[theme . ".Duration"] : false)
				songFile := (splashThemes.Has(theme . ".Song") ? splashThemes[theme . ".Song"] : false)

				if !songFile
					songFile := ""

				themes[theme] := theme

				this.ItemList.Push([type, theme, media, songFile, duration])
			}
		}
	}

	saveToConfiguration(configuration) {
		local index, theme, name, type, songFile

		super.saveToConfiguration(configuration)

		for index, theme in this.ItemList {
			name := theme[2]
			type := theme[1]
			songFile := theme[4]

			setMultiMapValue(configuration, "Splash Themes", name . ".Type", type)

			if (songFile && (songFile != ""))
				setMultiMapValue(configuration, "Splash Themes", name . ".Song", songFile)

			if (type == "Picture Carousel") {
				setMultiMapValue(configuration, "Splash Themes", name . ".Images", theme[3])
				setMultiMapValue(configuration, "Splash Themes", name . ".Duration", theme[5])
			}
			else
				setMultiMapValue(configuration, "Splash Themes", name . ".Video", theme[3])
		}
	}

	loadList(items) {
		local ignore, theme, songFile, nameNoExt, mediaFiles, mediaFile

		static first := true

		if (first != this.Control["themesListView"])
			first := true

		this.Control["themesListView"].Delete()

		for ignore, theme in items {
			songFile := theme[4]

			if (songFile != "") {
				SplitPath(songFile, , , , &nameNoExt)

				songFile := nameNoExt
			}

			mediaFiles := []

			for ignore, mediaFile in string2Values(",", theme[3]) {
				SplitPath(mediaFile, , , , &nameNoExt)

				mediaFiles.Push(nameNoExt)
			}

			this.Control["themesListView"].Add("", theme[2], values2String(", ", mediaFiles*), songFile)
		}

		if first {
			this.Control["themesListView"].ModifyCol(1, 100)
			this.Control["themesListView"].ModifyCol(2, 180)
			this.Control["themesListView"].ModifyCol(3, 100)

			first := this.Control["themesListView"]
		}
	}

	updateState() {
		super.updateState()

		if (this.Control["themeTypeDropDown"].Value == 1) {
			this.Control["picturesListLabel"].Visible := true
			this.Control["addPictureButton"].Visible := true
			this.Control["picturesListView"].Visible := true
			this.Control["picturesDurationLabel"].Visible := true
			this.Control["picturesDurationEdit"].Visible := true
			this.Control["picturesDurationPostfix"].Visible := true
		}
		else {
			this.Control["picturesListLabel"].Visible := false
			this.Control["addPictureButton"].Visible := false
			this.Control["picturesListView"].Visible := false
			this.Control["picturesDurationLabel"].Visible := false
			this.Control["picturesDurationEdit"].Visible := false
			this.Control["picturesDurationPostfix"].Visible := false
		}

		if (this.Control["themeTypeDropDown"].Value == 2) {
			this.Control["videoFilePathLabel"].Visible := true
			this.Control["videoFilePathEdit"].Visible := true
			this.Control["videoFilePathButton"].Visible := true
		}
		else {
			this.Control["videoFilePathLabel"].Visible := false
			this.Control["videoFilePathEdit"].Visible := false
			this.Control["videoFilePathButton"].Visible := false
		}
	}

	initializePicturesList(pictures := "") {
		local ignore, picture

		this.Control["picturesListView"].Delete()

		pictures := string2Values(",", pictures)

		picturesListViewImages := IL_Create(pictures.Length)

		for ignore, picture in pictures
			IL_Add(picturesListViewImages, getFileName(picture, kUserSplashMediaDirectory, kSplashMediaDirectory))

		this.Control["picturesListView"].SetImageList(picturesListViewImages)

		loop pictures.Length
			this.Control["picturesListView"].Add("Check Icon" . A_Index, pictures[A_Index])

		this.Control["picturesListView"].ModifyCol()
	}

	loadEditor(item) {
		local chosen := ((item[1] == "Picture Carousel") ? 1 : 2)

		this.Control["themeTypeDropDown"].Choose(chosen)
		this.Control["themeNameEdit"].Text := item[2]
		this.Control["soundFilePathEdit"].Text := item[4]

		if (chosen == 2)
			this.Control["videoFilePathEdit"].Text := item[3]
		else
			this.Control["videoFilePathEdit"].Text := ""

		if (chosen == 1) {
			this.initializePicturesList(item[3])

			this.Control["picturesDurationEdit"].Text := item[5]
		}
		else
			this.initializePicturesList("")

		this.updateState()
	}

	clearEditor() {
		this.Control["themeTypeDropDown"].Choose(0)
		this.Control["themeNameEdit"].Text := ""
		this.Control["soundFilePathEdit"].Text := ""
		this.Control["videoFilePathEdit"].Text := ""
		this.Control["picturesDurationEdit"].Text := 3000

		this.initializePicturesList("")

		this.updateState()
	}

	buildItemFromEditor(isNew := false) {
		local type, media, pictures, rowNumber, fileName

		if (this.Control["themeTypeDropDown"].Value == 1) {
			type := "Picture Carousel"
			pictures := []

			rowNumber := 0

			loop {
				rowNumber := this.Control["picturesListView"].GetNext(rowNumber, "C")

				if !rowNumber
					break

				fileName := this.Control["picturesListView"].GetText(rowNumber, 1)

				pictures.Push(StrReplace(StrReplace(fileName, kUserSplashMediaDirectory, ""), kSplashMediaDirectory, ""))
			}

			media := values2String(", ", pictures*)
		}
		else if (this.Control["themeTypeDropDown"].Value == 2) {
			type := "Video"
			media := this.Control["videoFilePathEdit"].Text
		}
		else {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}

		return Array(type, this.Control["themeNameEdit"].Text, media, this.Control["soundFilePathEdit"].Text, this.Control["picturesDurationEdit"].Text)
	}

	togglePlaySoundFile(stop := false) {
		local songFile

		if (stop || this.iSoundIsPlaying) {
			try {
				SoundPlay("NonExistent.avi")
			}
			catch Any as exception {
			}

			setButtonIcon(this.Control["playSoundFileButton"], kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")

			this.iSoundIsPlaying := false
		}
		else if !this.iSoundIsPlaying {
			try {
				songFile := getFileName(this.Control["soundFilePathEdit"].Text, kUserSplashMediaDirectory, kSplashMediaDirectory)

				if FileExist(songFile) {
					SoundPlay(songFile)

					setButtonIcon(this.Control["playSoundFileButton"], kIconsDirectory . "Pause.ico", 1, "L2 T2 R2 B2")

					this.iSoundIsPlaying := true
				}
			}
			catch Any as exception {
				logError(exception)
			}
		}
	}
}