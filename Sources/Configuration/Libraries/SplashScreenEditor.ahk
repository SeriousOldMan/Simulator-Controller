;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Splash Screen Editor            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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
;;; SplashScreenEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SplashScreenEditor extends ConfiguratorPanel {
	iClosed := false
	iSplashScreensList := false

	class SplashScreenEditorWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Splash Screens Editor", Closeable: true, Resizeable: true, Options: "-MaximizeBox -MinimizeBox"})
		}

		Close(*) {
			this.iEditor.closeEditor(false)
		}
	}

	__New(configuration) {
		this.iSplashScreensList := SplashScreensList(configuration)

		super.__New(configuration)

		SplashScreenEditor.Instance := this
	}

	createGui() {
		local splashScreensGui, chosen

		saveSplashScreenEditor(*) {
			protectionOn()

			try {
				this.closeEditor(true)
			}
			finally {
				protectionOff()
			}
		}

		cancelSplashScreenEditor(*) {
			protectionOn()

			try {
				this.closeEditor(false)
			}
			finally {
				protectionOff()
			}
		}

		splashScreensGui := SplashScreenEditor.SplashScreenEditorWindow(this)

		this.Window := splashScreensGui

		splashScreensGui.SetFont("Bold", "Arial")

		splashScreensGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(splashScreensGui, "Splash Screens"))

		splashScreensGui.SetFont("Norm", "Arial")

		splashScreensGui.Add("Documentation", "x138 YP+20 w128 H:Center Center", translate("Splash Screens")
						   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#splash-screen-editor")

		splashScreensGui.Add("Text", "x50 yp+30 w310 W:Grow 0x10")

		splashScreensGui.SetFont("Norm", "Arial")

		splashScreensGui.Add("Text", "x16 yp+10 w90 h23 +0x200", translate("Upper Title"))
		splashScreensGui.Add("Edit", "x110 yp w284 h21 W:Grow VwindowTitleEdit", this.Value["windowTitle"])

		splashScreensGui.Add("Text", "x16 yp+24 w90 h23 +0x200", translate("Lower Title"))
		splashScreensGui.Add("Edit", "x110 yp w284 h21 W:Grow VwindowSubtitleEdit", this.Value["windowSubtitle"])

		splashScreensGui.Add("Text", "x50 yp+30 w310 W:Grow 0x10")

		this.iSplashScreensList.createGui(this)

		splashScreensGui.Add("Text", "x50 y+10 w310 Y:Move W:Grow 0x10")

		splashScreensGui.Add("Button", "x126 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Save")).OnEvent("Click", saveSplashScreenEditor)
		splashScreensGui.Add("Button", "x214 yp w80 h23 Y:Move X:Move(0.5)", translate("&Cancel")).OnEvent("Click", cancelSplashScreenEditor)
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

		this.iSplashScreensList.saveToConfiguration(configuration)
	}

	editSplashScreens(owner := false) {
		local x, y, configuration, window

		this.createGui()

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		this.iSplashScreensList.clearEditor()

		if getWindowPosition("Splash Screens Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Splash Screens Editor", &w, &h)
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
		this.iSplashScreensList.togglePlaySoundFile(true)

		this.iClosed := (save ? kOk : kCancel)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; SplashScreensList                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SplashScreensList extends ConfigurationItemList {
	iSoundIsPlaying := false
	iPicturesList := false

	PicturesList {
		Get {
			return this.iPicturesList
		}
	}

	__New(configuration) {
		super.__New(configuration)

		SplashScreensList.Instance := this
	}

	createGui(editor) {
		local window := editor.Window

		updateSplashScreenEditorState(*) {
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

		addSplashScreenPicture(*) {
			local pictureFile

			protectionOn()

			try {
				this.Window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSaveCancelButtons)
				pictureFile := withBlockedWindows(FileSelect, 1, "", translate("Select Image..."), "Image (*.jpg; *.gif)")
				OnMessage(0x44, translateSaveCancelButtons, 0)

				if (pictureFile != "") {
					IL_Add(this.PicturesList, pictureFile) ; LoadPicture(pictureFile, "W32 H32"), 0xFFFFFF, false)

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
				soundFile := withBlockedWindows(FileSelect, 1, path, translate("Select Sound File..."), "Audio (*.wav; *.mp3)")
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
				videoFile := withBlockedWindows(FileSelect, 1, path, translate("Select Video (GIF) File..."), "Video (*.gif)")
				OnMessage(0x44, translateSelectCancelButtons, 0)

				if (videoFile != "")
					this.Control["videoFilePathEdit"].Text := videoFile
			}
			finally {
				protectionOff()
			}
		}

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		window.Add("ListView", "x16 yp+24 w377 h140 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VsplashScreensListView", collect(["Splash Screen", "Media", "Sound File"], translate))
		window.Add("Text", "x16 yp+150 w90 h23 +0x200 Y:Move", translate("Splash Screen"))
		window.Add("Edit", "x110 yp w140 h21 Y:Move W:Grow(0.5) VsplashScreenNameEdit")

		window.Add("Text", "x16 yp+24 w90 h23 +0x200 Y:Move", translate("Type"))
		window.Add("DropDownList", "x110 yp w140 Y:Move W:Grow(0.5) VsplashScreenTypeDropDown", [translate("Picture Carousel"), translate("Video")]).OnEvent("Change", updateSplashScreenEditorState)

		window.Add("Text", "x16 yp+24 w65 h23 Y:Move +0x200", translate("Sound File"))
		window.Add("Button", "x85 yp-1 w23 h23 Y:Move vplaySoundFileButton").OnEvent("Click", togglePlaySoundFile)
		setButtonIcon(window["playSoundFileButton"], kIconsDirectory . "Start.ico", 1, "L2 T2 R2 B2")
		window.Add("Edit", "x110 yp+1 w259 h21 Y:Move W:Grow VsoundFilePathEdit")
		window.Add("Button", "x371 yp-1 w23 h23 Y:Move X:Move", translate("...")).OnEvent("Click", chooseSoundFilePath)

		window.Add("Text", "x16 yp+25 w65 h23 +0x200 Y:Move VvideoFilePathLabel", translate("Video"))
		window.Add("Edit", "x110 yp w259 h21 Y:Move W:Grow VvideoFilePathEdit")
		window.Add("Button", "x371 yp-1 w23 h23 Y:Move X:Move VvideoFilePathButton", translate("...")).OnEvent("Click", chooseVideoFilePath)

		window.Add("Text", "x16 yp+1 w75 h23 +0x200 Y:Move VpicturesListLabel", translate("Pictures"))
		window.Add("Button", "x85 yp w23 h23 Y:Move VaddPictureButton").OnEvent("Click", addSplashScreenPicture)
		setButtonIcon(window["addPictureButton"], kIconsDirectory . "Plus.ico", 1)

		window.Add("ListView", "x110 yp w284 h112 Y:Move W:Grow -Multi -LV0x10 Checked -Hdr NoSort NoSortHdr VpicturesListView", [translate("Picture")])
		window["picturesListView"].OnEvent("Click", noSelect)
		window["picturesListView"].OnEvent("DoubleClick", noSelect)

		window.Add("Text", "x16 yp+114 w90 h23 +0x200 Y:Move VpicturesDurationLabel", translate("Display Duration"))
		window.Add("Edit", "x110 yp w40 h21 Y:Move Limit5 Number VpicturesDurationEdit")

		window.SetFont("Norm", "Arial")

		window.Add("Text", "x154 yp+3 w40 h23 Y:Move VpicturesDurationPostfix", translate("ms"))

		/*
		window.Add("Button", "x184 yp+31 w46 h23 Y:Move X:Move VsplashScreenAddButton", translate("Add"))
		window.Add("Button", "x232 yp w50 h23 Y:Move X:Move Disabled VsplashScreenDeleteButton", translate("Delete"))
		window.Add("Button", "x340 yp w55 h23 Y:Move X:Move Disabled VsplashScreenUpdateButton", translate("&Save"))
		*/

		window.Add("Button", "x318 y530 w23 h23 X:Move Y:Move VsplashScreenAddButton")
		setButtonIcon(window["splashScreenAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		window.Add("Button", "x342 y530 w23 h23 X:Move Y:Move Disabled VsplashScreenDeleteButton")
		setButtonIcon(window["splashScreenDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")
		window.Add("Button", "x372 y530 w23 h23 X:Move Y:Move Disabled VsplashScreenUpdateButton")
		setButtonIcon(window["splashScreenUpdateButton"], kIconsDirectory . "Save.ico", 1, "L4 T4 R4 B4")

		this.initializeList(editor, window["splashScreensListView"], window["splashScreenAddButton"], window["splashScreenDeleteButton"], window["splashScreenUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local definition := getMultiMapValues(configuration, "Splash Screens")
		local splashScreens := CaseInsenseMap()
		local descriptor, value, splashScreen, type, media, duration, songFile, builtin

		super.loadFromConfiguration(configuration)

		for descriptor, value in definition {
			splashScreen := StrSplit(descriptor, ".")[1]

			if !splashScreens.Has(splashScreen) {
				type := definition[splashScreen . ".Type"]
				media := ((type == ("Picture Carousel")) ? definition[splashScreen . ".Images"] : definition[splashScreen . ".Video"])
				duration := ((type == ("Picture Carousel")) ? definition[splashScreen . ".Duration"] : false)
				songFile := (definition.Has(splashScreen . ".Song") ? definition[splashScreen . ".Song"] : false)
				builtin := (definition.Has(splashScreen . ".Builtin") ? definition[splashScreen . ".Builtin"] : false)

				if !songFile
					songFile := ""

				splashScreens[splashScreen] := true

				this.ItemList.Push(Array(type, splashScreen, media, songFile, duration, builtin))
			}
		}
	}

	saveToConfiguration(configuration) {
		local index, splashScreen, name, type, songFile

		super.saveToConfiguration(configuration)

		for index, splashScreen in this.ItemList {
			name := splashScreen[2]
			type := splashScreen[1]
			songFile := splashScreen[4]

			setMultiMapValue(configuration, "Splash Screens", name . ".Type", type)

			if (songFile && (songFile != ""))
				setMultiMapValue(configuration, "Splash Screens", name . ".Song", songFile)

			if (type == "Picture Carousel") {
				setMultiMapValue(configuration, "Splash Screens", name . ".Images", splashScreen[3])
				setMultiMapValue(configuration, "Splash Screens", name . ".Duration", splashScreen[5])
			}
			else
				setMultiMapValue(configuration, "Splash Screens", name . ".Video", splashScreen[3])
		}
	}

	loadList(items) {
		local ignore, splashScreen, songFile, nameNoExt, mediaFiles, mediaFile

		static first := true

		if (first != this.Control["splashScreensListView"])
			first := true

		this.Control["splashScreensListView"].Delete()

		for ignore, splashScreen in items {
			songFile := splashScreen[4]

			if (songFile != "") {
				SplitPath(songFile, , , , &nameNoExt)

				songFile := nameNoExt
			}

			mediaFiles := []

			for ignore, mediaFile in string2Values(",", splashScreen[3]) {
				SplitPath(mediaFile, , , , &nameNoExt)

				mediaFiles.Push(nameNoExt)
			}

			this.Control["splashScreensListView"].Add("", splashScreen[2], values2String(", ", mediaFiles*), songFile)
		}

		if first {
			this.Control["splashScreensListView"].ModifyCol(1, 100)
			this.Control["splashScreensListView"].ModifyCol(2, 180)
			this.Control["splashScreensListView"].ModifyCol(3, 100)

			first := this.Control["splashScreensListView"]
		}
	}

	updateState() {
		super.updateState()

		if (this.Control["splashScreenTypeDropDown"].Value == 1) {
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

		if (this.Control["splashScreenTypeDropDown"].Value == 2) {
			this.Control["videoFilePathLabel"].Visible := true
			this.Control["videoFilePathEdit"].Visible := true
			this.Control["videoFilePathButton"].Visible := true
		}
		else {
			this.Control["videoFilePathLabel"].Visible := false
			this.Control["videoFilePathEdit"].Visible := false
			this.Control["videoFilePathButton"].Visible := false
		}

		if (this.CurrentItem && (this.ItemList[this.CurrentItem][6])) {
			this.Control["soundFilePathEdit"].Enabled := false
			this.Control["splashScreenNameEdit"].Enabled := false
			this.Control["splashScreenNameEdit"].Enabled := false
			this.Control["splashScreenDeleteButton"].Enabled := false
			this.Control["splashScreenUpdateButton"].Enabled := false
			this.Control["splashScreenTypeDropDown"].Enabled := false
			this.Control["addPictureButton"].Enabled := false
			this.Control["picturesListView"].Enabled := false
			this.Control["picturesDurationEdit"].Enabled := false
			this.Control["picturesDurationPostfix"].Enabled := false
			this.Control["videoFilePathEdit"].Enabled := false
			this.Control["videoFilePathButton"].Enabled := false
		}
		else {
			this.Control["soundFilePathEdit"].Enabled := true
			this.Control["splashScreenNameEdit"].Enabled := true
			this.Control["splashScreenNameEdit"].Enabled := true
			this.Control["splashScreenTypeDropDown"].Enabled := true
			this.Control["addPictureButton"].Enabled := true
			this.Control["picturesListView"].Enabled := true
			this.Control["picturesDurationEdit"].Enabled := true
			this.Control["picturesDurationPostfix"].Enabled := true
			this.Control["videoFilePathEdit"].Enabled := true
			this.Control["videoFilePathButton"].Enabled := true
		}
	}

	initializePicturesList(pictures := "") {
		local ignore, picture

		this.Control["picturesListView"].Delete()

		pictures := string2Values(",", pictures)

		picturesListViewImages := IL_Create(pictures.Length)

		this.iPicturesList := picturesListViewImages

		for ignore, picture in pictures
			IL_Add(picturesListViewImages, getFileName(picture, kUserSplashMediaDirectory, kSplashMediaDirectory))

		picturesListViewImages := this.Control["picturesListView"].SetImageList(picturesListViewImages)

		if picturesListViewImages
			IL_Destroy(picturesListViewImages)

		loop pictures.Length
			this.Control["picturesListView"].Add("Check Icon" . A_Index, pictures[A_Index])

		this.Control["picturesListView"].ModifyCol()
	}

	loadEditor(item) {
		local chosen := ((item[1] == "Picture Carousel") ? 1 : 2)

		this.Control["splashScreenTypeDropDown"].Choose(chosen)
		this.Control["splashScreenNameEdit"].Text := item[2]
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
		this.Control["splashScreenTypeDropDown"].Choose(0)
		this.Control["splashScreenNameEdit"].Text := ""
		this.Control["soundFilePathEdit"].Text := ""
		this.Control["videoFilePathEdit"].Text := ""
		this.Control["picturesDurationEdit"].Text := 3000

		this.initializePicturesList("")

		this.updateState()
	}

	buildItemFromEditor(isNew := false) {
		local type, media, pictures, rowNumber, fileName

		if (this.Control["splashScreenTypeDropDown"].Value == 1) {
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
		else if (this.Control["splashScreenTypeDropDown"].Value == 2) {
			type := "Video"
			media := this.Control["videoFilePathEdit"].Text
		}
		else {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}

		return Array(type, this.Control["splashScreenNameEdit"].Text, media, this.Control["soundFilePathEdit"].Text, this.Control["picturesDurationEdit"].Text
				   , isNew ? false : this.ItemList[this.CurrentItem][6])
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