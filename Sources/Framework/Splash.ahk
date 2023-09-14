;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Splash Screens                  ;;;
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

playSplashScreenSong(songFile) {
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

		if FileExist(image) {
			if (++splashCounter > splashGuis.Length) {
				splashCounter := 1

				if splashGuis[splashCounter] {
					splashGuis[splashCounter].Destroy()

					splashGuis[splashCounter] := false
				}
			}

			title := substituteVariables(translate(getMultiMapValue(kSimulatorConfiguration, "Splash Window", "Title", "")))
			subTitle := substituteVariables(translate(getMultiMapValue(kSimulatorConfiguration, "Splash Window", "Subtitle", "")))

			SplitPath(image, , , &extension)

			splashGui := Window({Options: "+E0x02000000"})

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

			return true
		}
	}

	return false
}

hideSplash() {
	showSplash(false)
}

rotateSplash(alwaysOnTop := true) {
	local image

	static number := 1
	static images := false
	static numImages := 0

	if !images {
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)

		numImages := images.Length
	}

	if (number > numImages)
		number := 1

	if (number <= numImages) {
		image := images[number++]

		if FileExist(image)
			showSplash(image, alwaysOnTop)
	}
}

showSplashScreen(splashScreen := unset, songHandler := false, alwaysOnTop := true) {
	local song, video, duration, type

	static images := false
	static number := 1
	static numImages := 0
	static onTop := false

	if !songHandler
		songHandler := playSplashScreenSong

	if !isSet(splashScreen) {
		if (number > numImages)
			number := 1

		if (number <= numImages)
			return showSplash(images[number++], onTop)
		else
			return false
	}

	song := false
	duration := 3000
	type := getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Type", false)

	if (type == "Video") {
		song := getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Song", false)
		video := getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Video")

		if showSplash(video, true) {
			if (song && FileExist(song))
				songHandler(song)

			return true
		}
		else
			return false
	}
	else if (type == "Picture Carousel") {
		duration := getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Duration", 5000)
		song := getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Song", false)
		images := string2Values(",", getMultiMapValue(kSimulatorConfiguration, "Splash Screens", splashScreen . ".Images", false))
	}
	else {
		logMessage(kLogCritical, translate("SplashScreen `"") . splashScreen . translate("`" not found - please check the configuration"))

		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
	}

	numImages := images.Length
	onTop := alwaysOnTop

	if showSplashScreen() {
		SetTimer(showSplashScreen, duration)

		if (song && FileExist(song)) {
			vSongIsPlaying := true

			songHandler(song)
		}

		return true
	}
	else
		return false
}

hideSplashScreen() {
	SetTimer(showSplashScreen, 0)

	try
		SoundPlay("NonExistent.avi")

	hideSplash()
}

getAllSplashScreens(configuration := false) {
	local descriptor, value, splashScreen
	local result := []

	if !configuration
		configuration := kSimulatorConfiguration

	for descriptor, value in getMultiMapValues(configuration, "Splash Screens") {
		splashScreen := StrSplit(descriptor, ".")[1]

		if !inList(result, splashScreen)
			result.Push(splashScreen)
	}

	return result
}
