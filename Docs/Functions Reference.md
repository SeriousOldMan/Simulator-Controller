## Configurations ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Configurations are used to store a definition or the state of an object to the file system. Configurations are organized as maps divided by sections or topics. Inside a section, you may have an unlimited number of values referenced by keys. Configuration maps are typically stored in *.ini files, therefore the character "=" is not allowed in keys or values written to a configuration map. Keys themselves may have a complex, pathlike structure. See [ConfigurationItem.descriptor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Class-Reference#class-method-descriptorrest-values) for reference.

#### *newConfiguration()* 
Returns a new empty configuration map. The configuration map is not derived from a public class and may be accessed only through the functions given below. 

#### *getConfigurationValue(configuration :: ConfigurationMap, section :: String, key :: String, default := false)*
Returns the value defined for the given key or the *default*, if no such key has been defined.

#### *setConfigurationValue(configuration :: ConfigurationMap, section :: String, key :: String, value)*
Stores the given value for the given key in the configuration map. The value must be convertible to a String representation.

#### *getConfigurationSectionValues(configuration :: ConfigurationMap, section :: String, default := false)*
Retrieves all key / value pairs for a given section as a map. Returns *default*, if the section does not exist.

#### *setConfigurationValues(configuration, otherConfiguration)*
This function takes all key / value pairs from all sections in *otherConfiguration* and copies them to *configuration*.

#### *setConfigurationSectionValues(configuration :: ConfigurationMap, section :: String, values :: Object)*
Stores all the key / value pairs in the configuration map under the given section.

#### *removeConfigurationValue(configuration :: ConfigurationMao, section :: String, key :: String)*
Removes the given key and its value from the configuration map.

#### *readConfiguration(configFile :: String)*
Reads a configuration map from an *.ini file. The Strings "true" and "false" will he converted to the literal values *true* and *false* when encountered as values in the configuration file. If *configFile* denotes an absolute path, this path will be used. Otherwise, the file will be looked up in the *kUserConfigDirectory* and in *kConfigDirectory* (see the [constants documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#installation-paths-constantsahk) for reference), in that order.

#### *writeConfiguration(configFile :: String, configuration :: ConfigurationMap)*
Stores a configuration map in the given file. All previous content of the file will be overwritten. The literal values *true* and *false* will be converted to "true" and "false", before being written to the configuration file. If *configFile* denotes an absolute path, the configuration will be saved in this file. Otherwise it will be saved relative to *kUserConfigDirectory* (see the [constants documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#installation-paths-constantsahk) for reference).

***

## Tray Messages ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Tray messages or TrayTips are small popup windows in the lower right corner of the main screen used by applications or the Windows operating system to inform the user about an important event. Tray messages can be displayed by the Simulator Controller for almost every change in the controller state.

#### *trayMessage(title :: String, message :: String, duration :: Integer := false)*
Popups a tray message. If *duration* is supplied, it must be an integer defining the number of milliseconds, the popup will be visible. If not given, a default period may apply (see below).

#### *disableTrayMessages()*
Diasables all tray messages from now on. Every following call to *trayMessage* will have no effect.

#### *enableTrayMessages(duration :: Integer := 1500)*
(Re-)enables tray messages, if previously been disabled by *disableTrayMessages*. A default for the number of milliseconds the popups will be visible, may be supplied.

***

## Event Messages ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Event messages may be used to communicate between different processes. In Simulator Controller, the startup application sends events to the controller application to start all components configured for the Simulator Controller, to play and stop a startup song and so on.

#### *registerEventHandler(event :: String, handler :: TypeUnion(String, FuncObj))*
Registers an event handler function for the given event type. An event handler is supplied the event and the transmitted message as arguments and typically looks like this:

	handleStartupEvents(event, data) {
		if InStr(data, ":") {
			data := StrSplit(data, ":")
			
			function := data[1]
			arguments := string2Values(",", data[2])
				
			withProtection(function, arguments*)
		}
		else	
			withProtection(data)
	}

#### *raiseEvent(messageType :: OneOf(kLocalMessage, kWindowMessage, kPipeMessage, kFileMessage), event :: String, data :: String, target := false)*
Raises the given event. The first parameter defines the delivery method, where *kFileMessage* is the most reliable, but also the slowest one. If the argument for *messageType* is *kLocalMessage*, the event is raised in the current process. Otherwise, the event is delivered to the process defined by target, which must have registered an event handler for the given event. For *kWindowMessage*, the target must be defined according to the [window title pattern](https://www.autohotkey.com/docs/misc/WinTitle.htm) of *AutoHotkey* and for *kFileMessage*, you must provide the process id of the target process. Last but not least, if message type is *kPipeMessage*, not target must be specified and multiple processes may register an event handler for the given event, but only one process will receive the message.

***

## File Handling ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
A small collection of functions to deal with files and directories. Note: All the directory names used with these functions must contain a trailing backslash "\", since this is standard in the Simulator Controller code.

#### *getFileName*(fileName :: String, #rest directories :: String)*
If *fileName* contains an absolute path, itself will be returned. Otherwise, all directories will be checked, if a file with the (partial) path can be found, and this file path will be returned. If not found, a path consisting of the first supplied directory and *fileName* will be returned.

#### *getFileNames*(filePattern :: String, #rest directories :: String)*
Returns a list of absolute paths for all files in the given directories satisfying *filePattern*.

#### *normalizeFilePath(filePath)*
Removes all "\\*directory*\\.." occurrencies from *filePath* and returns this simplified file path.

***

## Collection & String Helper Functions ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Often used collection functions, that are not part of the AutoHotkey language.

#### *substituteVariables(string :: String, values :: Map := {})*
Substitutes all variables enclosed by "%" with their values and returns the modified string. The values are lookedup from the supplied values map. If not found there, the global name space is used.

#### *string2Values(delimiter :: String, string :: String, count :: Integer := false)*
Splits *string* apart using the supplied delimiter and returns the parts as an array. If *count* is supplied, only that much parts are splitted and all remaining ocurrencies of *delimiter* are ignored.

#### *values2String(delimiter :: String, #rest values)*
Joins the given unlimited number of values using *delimiter* into one string. *values* must have a string representation.

#### *inList(list :: Array, value)*
Returns the position of *value* in the given list or array, or *false*, if not found.

#### *concatenate(#rest lists :: Array)*
Returns a freshly allocated list containing all the elements contained in the supplied lists. The global order is preserved.

#### *map(list :: Array, function :: TypeUnion(String, FuncObj))*
Returns a new list with the result of *function* applied to each element in *list*, while preserving the order of elements.

#### *bubbleSort(ByRef array :: Array, comparator :: Function Name)*
Sorts the given array in place, using *comparator* to define the order of the elements. This function will receive two objects and must return *true*, if the first one is considered larger or of the same order than the other. Stable sorting rules apply.

***

## Localization & Translation ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
A simple translation support is built into Simulator Controller. Every text, that appears in the different screens and system messages may translated to a different language than standard English. To support this, a single tranlation file (see the [translation file](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Templates/Translations.de) for German for an example) must exist for each target language in one of the *Config* folders.

#### *availableLanguages()*
Returns a map, where the key defines the [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) and the value the language name (example: *{en: English, de: Deutsch}*. The map is populated with all available translations.

#### *readTranslations(languageCode :: String)*
Returns a translation map for the given [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes). Keys are the original texts in English with the translated texts as their values. Normally, it is much more convinient to use the *translate* function below.

#### *writeTranslations(languageCode :: String, languageName :: String, translations :: Map)*
Saves a translation map for the given [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) and language name. The format of the *translations* map must be according to the description in *readTranslations*. The translation map is stored in the folder identified by *kUserConfigDirectory* in a file named "Translations.LC", where LC is the given ISO language code.

#### *setLanguage(languageCode :: String)*
The [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) for the target language, for example "de" for German.

#### *getLanguage()*
Returns the [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) for the active language.

#### *translate(string :: String)*
*string* is a text in English. *translate* reads the translations for the current target language and returns the translated text, or *string* itself, if no translation can be found.

#### *translateMsgBoxButtons(buttonLabels :: List)*
This function helps you to translate the button labels for standard dialogs like those of the AutoHotkey *MsgBox* command: A typical usage looks like this:

	OnMessage(0x44, Func("translateMsgBoxButtons").bind(["Yes", "No", "Never"]))
	title := translate("Modular Simulator Controller System")
	MsgBox 262179, %title%, % translate("The local configuration database needs an update. Do you want to run the update now?")
	OnMessage(0x44, "")

As you can see, this dialog will show three buttons which will be labeled "Yes", "No" and "Never" in the English language setting. *translateMsgBoxButtons* will call the *translate* function automatically for these labels, before they will be set as labels for the different buttons.
 
***

## Splash Screen Handling ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Several applications of Simulator Controller uses a splash window to entertain the user while performing their operations. The splash screen shows different pictures or even an animation using a GIF. All required resources, that are part of the Simulator Controller distribution, are normally loacated in the *Resources/Splash Media* folder. An additional location for user supplied media exists in the *Simulator Controller\Splash Media* folder in the user *Documents* folder. The user can define several themes with rotating pictures or a GIF animation with the help of the [themes editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor).

#### *showSplash(image :: String, alwaysOnTop :: Boolean := true)*
*showSplash* opens the splash screen showing a picture. *image* must either be a partial path for a JPG or GIF file relative to [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory), for example "Simulator Splash Images\ACC Splash.jpg", or a partial path relative to the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user, or an absolute path.

#### *rotateSplash(alwaysOnTop :: Boolean := true)*
Uses all JPG files available in [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory) and in the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user, as a kind of picture carousel. Every call to *rotateSplash* will show the next picture.

Important: This function is deprecated and will be removed in a future version of Simulator Controller. Use *showPlashTheme* instead.

#### *hideSplash()*
Closes the current splash window. Note: If the splash window had been opened using *showSplashTheme*, use *hideSplashTheme* instead.

#### *showSplashAnimation(gif :: String)*
*gif* must be the name of a GIF file located in [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory) or in the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user. *showSplashAnimation* will show this animated GIF in the currently open splash screen window.
Note: This is a building block function for *showSplashTheme* and will normally not be used on its own.

#### *hideSplashAnimation()*
Finishes the current animation, but the splash screen window stays open.
Note: This is a building block function for *hideSplashTheme* and will normally not be used on its own.

#### *showSplashTheme(theme :: String, songHandler :: TypeUnion(String, FuncObj) := false, alwaysOnTop :: Boolean := true)*
Themes are a collection of pictures or a GIF animation possibly combined with a sound file. Themes are maintained by the [themes editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor). *showSplashTheme* opens a splash window according to the themes definition. If *songHandler* is not provided, a default handler will be used, but the song will stop playing, if the current splash window is closed.

#### *hideSplashTheme()*
Closes the current theme based splash window.

***

## GUI Tools ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Miscellaneous helper functions for GUI programming.

#### *moveByMouse(guiPrefix :: String)*
You can call this function from a click handler of a GUI element. It will move the underlying window by following the mouse cursor. *guiPrefix* must be the [prefix](https://www.autohotkey.com/docs/commands/Gui.htm#MultiWin) used, while creating the GUI elements using the AutoHotkey [*GUI Add, ...*](https://www.autohotkey.com/docs/commands/Gui.htm#Add) command.
***

## Thread Protection ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
In AutoHotkey scripts, running threads may be interrupted by other events, such as keyboard events or timer functions. Using the functions below, it is possible to create protected sections of code, which may not be interrupted.

#### *protectionOn()*
Starts a protected section of code. Calls to protectionOn() may be nested.

#### *protectionOff()*
Finishes a protected section of code. Only if the outermost section has been finished, the current thread becomes interruptable again.

#### *withProtection(function :: TypeUnion(String, FuncObj), #rest params)*
Convinience function to call a given function with supplied parameters in a protected section.

***

## Debugging and Logging ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Essential support for tracking down coding errors. Since AutoHotkey is a weakly typed programming language, it is sometimes very difficult to get to the root cause of an error. Especially the tracing and logging capabilities may help here. All log files are located in the *Simulator Controller\Logs* folder found in your user *Documents* folder.

#### *isDebug()*
Returns *true*, if debugging is currently enabled. The Simulator Controller uses debug mode to handle things differently, for example all plugins and modes will be active, even if they declare to be not.

#### *setDebug(debug :: Boolean)*
Enables or disables debug mode. The default value for non compiled scripts is *ture*, but you can also define debug mode for compiled scripts using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *getLogLevel()*
Return the current log level. May be one of: *kLogInfo*, *kLogWarn*, *kLogCritical* or *kLogOff*.

#### *setLogLevel(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff))*
Sets the current log level. If *logLevel* is *kLogOff*, logging will normally be fully supressed.

#### *increaseLogLevel()*
Increases the current log level.

#### *decreaseLogLevel()*
Reduces the current log level.

#### *logMessage(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff), message :: String)*
Sends the given message to the log file, if the supplied log level is at the same or a more critical level than the current log level. If *logLevel* is *kLogOff*, the message will be written to the log file, even if logging has been disabled completely by *setLogLevel(kLogOff)* previously.

***

## Controller Actions
The functions in this section are a little bit special. Although they can be called from your code as well, they are meant to be used as [actions for controller functions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions). Therefore, they will be configured for controller functions using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *setDebug(debug :: Boolean)*
Enables or disables debugging. *debug* must be either *true* or *false*. Note: This function is identical to the one described above in the [Debugging and Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-functionsahk) section.

#### *setLogLevel(logLevel :: OneOf("Info", "Warn", "Critical", "Off"))*
Sets the log level. *logLevel* must be one of "Info", "Warn", "Critical" or "Off", where "Info" is the most verbose one. Note: This function is identical to the one described above in the [Debugging and Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-functionsahk) section.

#### *increaseLogLevel()*
Increases the log level, i.e. makes the log information more verbose. Note: This function is identical to the one described above in the [Debugging and Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-functionsahk) section.

#### *decreaseLogLevel()*
Decreases the log level, i.e. makes the log information less verbose. Note: This function is identical to the one described above in the [Debugging and Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-functionsahk) section.

#### *pushButton(number :: Integer)*
Virtually pushes the button with the given number.

#### *rotateDial(number :: Integer, direction :: OneOf("Increase", "Decrease"))*
Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease".

#### *switchToggle(type :: OneOf("1WayToggle", "2WayToggle"), number :: Integer, state :: OneOf("On", "Off"))*
Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle".

#### *setMode(mode :: String)*
Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes.

#### *startSimulation(simulator :: String := false)*
Starts a simulation game. If the simulator name is not provided, the first one in the list of configured simulators on the *General* tab in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) is used.

#### *stopSimulation()*
Stops the currently running simulation game.

#### *shutdownSystem()*
Displays a dialog and asks, whether the PC should be shutdown. Use with caution.

#### *enablePedalVibration()*
Enables the pedal vibration motors, that might be mounted to your pedals. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *disablePedalVibration()*
Disables the pedal vibration motors, that might be mounted to your pedals. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *enableFrontChassisVibration()*
Enables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *disableFrontChassisVibration()*
Disables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *enableRearChassisVibration()*
Enables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *disableRearChassisVibration()*
Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *disableRearChassisVibration()*
Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. This action function is provided by the "Tactile Feedback" plugin and is available depending on the concrete configuration.

#### *startMotion()*
Starts the motion feedback system of your simulation rig. This action function is provided by the "Motion Feedback" plugin and is available depending on the concrete configuration.

#### *stopMotion()*
Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. This action function is provided by the "Motion Feedback" plugin and is available depending on the concrete configuration.

#### *openPitstopMFD()*
Opens the pitstop settings dialog of *Assetto Corsa Competizione*. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *closePitstopMFD()*
Closes the pitstop settings dialog of *Assetto Corsa Competizione*. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *togglePitstopActivity(activity :: String)*
Enables or disables one of the activities performed by your pitstop crew. The supported activities are "Change Tyres", "Change Brakes", "Repair Bodywork" and "Repair Suspension". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopStrategy(selection :: String)*
Selects one of the pitstop strategies. *selection* must be either "Next" or "Previous". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopFuelAmount(direction :: String, liters :: Integer := 5)*
Changes the amount of fuel to add during the next pitstop. *direction* must be either "Increase" or "Decrease" and *liters* may define the amount of fuel to be changed in one step. This parameter has a default of 5. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopTyreSet(selection :: String)*
Selects the tyre sez to change to during  the next pitstop. *selection* must be either "Next" or "Previous". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopTyreCompound(compound :: String)*
Selects the tyre compound to change to during  the next pitstop. *compound* must be either "Wet" or "Dry". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopTyrePressure(tyre :: String, direction :: String, increments :: Integer := 1)*
Changes the tyre pressure during the next pitstop. *tyre* must be one of "All Around", "Front Left", "Front Right", "Rear Left" and "Rear Right", and *direction* must be either "Increase" or "Decrease". *increments* with a default of 1 define the change in 0.1 psi increments. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopBrakeType(brake :: String, selection :: String)*
Selects the brake pad compound to change to during the next pitstop. *brake* must be "Front Brake" or "Rear Brake" and *selection* must be "Next" or "Previous". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *changePitstopDriver(selection :: String)*
Selects the driver to take the car during the next pitstop. *selection* must be either "Next" or "Previous". This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *planPitstop()*
*planPitstop* triggers Jona, the virtual race engineer, to plan a pitstop. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *preparePitstop()*
*preparePitstop* triggers Jona, the virtual race engineer, to prepare a previously planned pitstop. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.

#### *openRaceEngineerSettings()*
Opens the settings tool, with which you can edit all the race specific settings, Jona needs for a given race. This action function is provided by the "ACC" plugin and is available depending on the concrete configuration.