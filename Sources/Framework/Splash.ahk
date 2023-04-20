;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Themes && Splash                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Files.ahk"
#Include "Strings.ahk"
#Include "Collections.ahk"
#Include "Localization.ahk"
#Include "MultiMap.ahk"
#Include "GUI.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\GIFViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

playThemeSong(songFile) {
	songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)

	if FileExist(songFile)
		SoundPlay(songFile)
}

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showSplash(image, alwaysOnTop := true, video := false) {
	local videoPlayer := false
	local lastSplash, title, subTitle, extension, html, splashGui

	static splashCounter := 0
	static splashGuis := [false, false, false, false, false, false, false, false, false, false]

	lastSplash := splashCounter

	if !image {
		if ((splashCounter > 0) && splashGuis[splashCounter]) {
			splashGui := splashGuis[splashCounter]

			try
				splashGui["videoPlayer"].Stop()

			splashGui.Destroy()

			splashGuis[splashCounter] := false
		}
	}
	else {
		image := getFileName(image, kUserSplashMediaDirectory, kSplashMediaDirectory)

		if (++splashCounter > 10) {
			splashCounter := 1

			if splashGuis[splashCounter] {
				splashGuis[splashCounter].Destroy()

				splashGuis[splashCounter] := false
			}
		}

		title := substituteVariables(translate(getMultiMapValue(kSimulatorConfiguration, "Splash Window", "Title", "")))
		subTitle := substituteVariables(translate(getMultiMapValue(kSimulatorConfiguration, "Splash Window", "Subtitle", "")))

		SplitPath(image, , , &extension)

		splashGui := Window()

		splashGuis[splashCounter] := splashGui

		splashGui.SetFont("s10 Bold", "Arial")

		splashGui.Add("Text", "x10 w780 Center", title)

		if (extension = "GIF")
			videoPlayer := splashGui.Add("GIFViewer", "x10 y30 w780 h439 vvideoPlayer", image)
		else
			splashGui.Add("Picture", "x10 y30 w780 h439", image)

		splashGui.SetFont("s8 Norm", "Arial")

		splashGui.Add("Text", "x10 y474 w780 Center", subTitle)

		if alwaysOnTop
			splashGui.Opt("+AlwaysOnTop")

		splashGui.Show("x" . Round((A_ScreenWidth - 800) / 2) . " y" . Round(A_ScreenHeight / 4) . " AutoSize NoActivate")

		if videoPlayer
			videoPlayer.Start()

		if ((lastSplash > 0) && splashGuis[lastSplash]) {
			splashGuis[lastSplash].Destroy()

			splashGuis[lastSplash] := false
		}
	}
}

hideSplash() {
	showSplash(false)
}

rotateSplash(alwaysOnTop := true) {
	static number := 1
	static images := false
	static numImages := 0

	if !images {
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)

		numImages := images.Length
	}

	if (number > numImages)
		number := 1

	if (number <= numImages)
		showSplash(images[number++], alwaysOnTop)
}

showSplashTheme(theme := unset, songHandler := false, alwaysOnTop := true) {
	local song, video, duration, type

	static images := false
	static number := 1
	static numImages := 0
	static onTop := false

	if !songHandler
		songHandler := playThemeSong

	if !isSet(theme) {
		if (number > numImages)
			number := 1

		if (number <= numImages)
			showSplash(images[number++], onTop)

		return
	}

	song := false
	duration := 3000
	type := getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Type", false)

	if (type == "Video") {
		song := getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		video := getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Video")

		showSplash(video, true)

		if song
			songHandler(song)

		return
	}
	else if (type == "Picture Carousel") {
		duration := getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Duration", 5000)
		song := getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		images := string2Values(",", getMultiMapValue(kSimulatorConfiguration, "Splash Themes", theme . ".Images", false))
	}
	else {
		logMessage(kLogCritical, translate("Theme `"") . theme . translate("`" not found - please check the configuration"))

		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
	}

	numImages := images.Length
	onTop := alwaysOnTop

	showSplashTheme()

	SetTimer(showSplashTheme, duration)

	if song {
		vSongIsPlaying := true

		songHandler(song)
	}
}

hideSplashTheme() {
	SetTimer(showSplashTheme, 0)

	try
		SoundPlay("NonExistent.avi")

	hideSplash()
}

getAllThemes(configuration := false) {
	local descriptor, value, theme
	local result := []

	if !configuration
		configuration := kSimulatorConfiguration

	for descriptor, value in getMultiMapValues(configuration, "Splash Themes") {
		theme := StrSplit(descriptor, ".")[1]

		if !inList(result, theme)
			result.Push(theme)
	}

	return result
}
