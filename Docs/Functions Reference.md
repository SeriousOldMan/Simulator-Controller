## Configurations ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Configurations are used to store a definition or the state of an object to the file system. Configurations are organized as maps divided by sections or topics. Inside a section, you may have an unlimited number of values referenced by keys. Configuration maps are typically stored in *.ini files, therefore the character "=" is not allowed in keys or values written to a configuration map. Keys themselves may have a complex, pathlike structure. See [ConfigurationItem.descriptor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Class-Reference#class-method-descriptorrest-values) for reference.

#### *newConfiguration()* 
Returns a new empty configuration map. The configuration map is not derived from a public class and may be accessed only through the functions given below. 

#### *getConfigurationValue(configuration :: ConfigurationMap, section :: String, key :: String, default := false)
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

#### *raiseEvent(target :: String, event :: String, data :: String)*
Raises the event in the supplied target process. If *target* is *false*, the event is raised in the current process. Otherwise, *target* must use the [*winTitle*](https://www.autohotkey.com/docs/misc/WinTitle.htm) syntax of AutoHotkey to identify a target process through one of its windows or using its process id.

***

## File Handling ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
A small collection of functions to deal with files and directories. Note: All the directory names used with these functions must contain a trailing backslash "\", since this is standard in the Simulator Controller code.

#### *getFileName*(fileName :: String, #rest directories :: String)*
If *fileName* contains an absolute path, itself will be returned. Otherwise, all directories will be checked, if a file with the (partial) path can be found, and this file path will be returned. If not found, a path consisting of the first supplied directory and *fileName* will be returned.

#### *getFileNames*(filePattern :: String, #rest directories :: String)*
Returns a list of absolute paths for all files in the given directories satisfying *filePattern*.

***

## Collection & String Helper Functions ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Often used collection functions, that are not part of the AutoHotkey language.

#### *substituteVariables(string :: String)*
Substitutes all variables enclosed by "%" with their values and returns the modified string.

#### *string2Values(delimiter :: String, string :: String, count :: Integer := false)*
Splits *string* apart using the supplied delimiter and returns the parts as an array. If *count* is supplied, only that much parts are splitted and all remaining ocurrencies of *delimiter* are ignored.

#### *values2String(delimiter :: String, #rest values)*
Joins the given unlimited number of values using *delimiter* into one string. *values* must have a string representation.

#### *inList(list :: Array, value)*
Returns the position of *value* in the given list or array, or *false*, if not found.

#### *concatenate(#rest lists :: Array)*
Returns a freshly allocated list containing all the elements contained in the supplied lists. The global order is preserved.

#### *bubbleSort(ByRef array :: Array, comparator :: Function Name)*
Sorts the given array in place, using *comparator* to define the order of the elements. This function will receive two objects and must return *true*, if the first one is considered larger or of the same order than the other. Stable sorting rules apply.

***

## Splash Screen Handling ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Several applications of Simulator Controller uses a splash window to entertain the user while performing their operations. The splash screen shows different pictures or even an animation using a GIF. All required resources, that are part of the Simulator Controller distribution, are loacated in the *Resources/Splash Media* folder. An additional location for user supplied media exists in the *Simulator Controller\Splash Media* folder in the user *Documents* folder. The user can switch between rotating pictures or a GIF animation using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration).

#### *showSplash(image :: String, alwaysOnTop :: Boolean := true)*
*showSplash* opens the splash screen showing a picture. *image* must either be a partial path for a JPG or GIF file relative to [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory), for example "Simulator Splash Images\ACC Splash.jpg", or a partial path relative to the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user, or an absolute path. 

#### *rotateSplash(alwaysOnTop :: Boolean := true)*
Uses all JPG files available in [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory) or in the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user, as a kind of picture carousel. Every call to *rotateSplash* will show the next picture.

#### *hideSplash()*
Closes the current splash window.

#### *showSplashAnimation(gif :: String)*
*gif* must be the name of a GIF file located in [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory) or in the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user. *showSplashAnimation* will show this animated GIF in the currently open splash screen window.

#### *hideSplashAnimation()*
Finishes the current animation, but the splash screen window stays open.

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
Enables or disables debug mode.

#### *getLogLevel()*
Return the current log level. May be one of: *kLogInfo*, *kLogWarn*, *kLogCritical* or *kLogOff*.

#### *setLogLevel(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff))*
Sets the current log level. If *logLevel* is *kLogOff*, logging will normally fully supressed.

#### *increaseLogLevel()*
Increases the current log level.

#### *decreaseLogLevel()*
Reduces the current log level.

#### *logMessage(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff), message :: String)*
Sends the given message to the log file, if the supplied log level is at the same or a more critical level than the current log level. If *logLevel* is *kLogOff*, the message will be written to the log file, even if logging has been disabled completely by *setLogLevel(kLogOff)* previously.