;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Themes && Splash                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Files.ahk
#Include ..\Framework\Strings.ahk
#Include ..\Framework\Collections.ahk
#Include ..\Framework\Localization.ahk
#Include ..\Framework\Configuration.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vSplashCounter := 0
global vLastImage
global vVideoPlayer
global vSongIsPlaying := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

playThemeSong(songFile) {
	songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)

	if FileExist(songFile)
		SoundPlay %songFile%
}

;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showSplash(image, alwaysOnTop := true, video := false) {
	local lastSplash := vSplashCounter
	local title, subTitle, extension, html, options

	image := getFileName(image, kUserSplashMediaDirectory, kSplashMediaDirectory)

	vSplashCounter += 1
	vLastImage := image

	if (vSplashCounter > 10)
		vSplashCounter := 1

	title := substituteVariables(translate(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", "")))
	subTitle := substituteVariables(translate(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Subtitle", "")))

	SplitPath image, , , extension

	Gui %vSplashCounter%:-Border -Caption
	Gui %vSplashCounter%:Color, D0D0D0, D8D8D8

	Gui %vSplashCounter%:Font, s10 Bold, Arial
	Gui %vSplashCounter%:Add, Text, x10 w780 Center, %title%

	if (extension = "GIF") {
		Gui %vSplashCounter%:Add, ActiveX, x10 y30 w780 h439 vvVideoPlayer, shell explorer

		vVideoPlayer.Navigate("about:blank")

		html := "<html><body style='background-color: #000000' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . image . "' width=780 height=438 border=0 padding=0></body></html>"

		vVideoPlayer.document.write(html)
	}
	else
		Gui %vSplashCounter%:Add, Picture, x10 y30 w780 h439, %image%

	Gui %vSplashCounter%:Font, s8 Norm, Arial
	Gui %vSplashCounter%:Add, Text, x10 y474 w780 Center, %subTitle%

	options := "x" . Round((A_ScreenWidth - 800) / 2) . " y" . Round(A_ScreenHeight / 4)

	if alwaysOnTop
		Gui %vSplashCounter%:+AlwaysOnTop

	Gui %vSplashCounter%:Show, %options% AutoSize NoActivate

	if (lastSplash > 0)
		hideSplash(lastSplash)
}

hideSplash(splashCounter := false) {
	if !splashCounter
		splashCounter := vSplashCounter

	Gui %splashCounter%:Destroy
}

rotateSplash(alwaysOnTop := true) {
	static number := 1
	static images := false
	static numImages := 0

	if !images {
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)

		numImages := images.Length()
	}

	if (number > numImages)
		number := 1

	if (number <= numImages)
		showSplash(images[number++], alwaysOnTop)
}

showSplashTheme(theme := "__Undefined__", songHandler := false, alwaysOnTop := true) {
	local song, video, duration, type

	static images := false
	static number := 1
	static numImages := 0
	static onTop := false

	vSongIsPlaying := false

	if !songHandler
		songHandler := "playThemeSong"

	if (theme == kUndefined) {
		if (number > numImages)
			number := 1

		if (number <= numImages)
			showSplash(images[number++], onTop)

		return
	}

	song := false
	duration := 3000
	type := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Type", false)

	if (type == "Video") {
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		video := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Video")

		showSplash(video, true)

		if song {
			vSongIsPlaying := true

			%songHandler%(song)
		}

		return
	}
	else if (type == "Picture Carousel") {
		duration := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Duration", 5000)
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		images := string2Values(",", getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Images", false))
	}
	else {
		logMessage(kLogCritical, translate("Theme """) . theme . translate(""" not found - please check the configuration"))

		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
	}

	numImages := images.Length()
	onTop := alwaysOnTop

	showSplashTheme()

	SetTimer showSplashTheme, %duration%

	if song {
		vSongIsPlaying := true

		%songHandler%(song)
	}
}

hideSplashTheme() {
	SetTimer showSplashTheme, Off

	if vSongIsPlaying
		try {
			SoundPlay NonExistent.avi
		}
		catch exception {
			logError(exception)
		}

	hideSplash()
}

getAllThemes(configuration := false) {
	local descriptor, value, theme
	local result := []

	if !configuration
		configuration := kSimulatorConfiguration

	for descriptor, value in getConfigurationSectionValues(configuration, "Splash Themes", Object()) {
		theme := StrSplit(descriptor, ".")[1]

		if !inList(result, theme)
			result.Push(theme)
	}

	return result
}