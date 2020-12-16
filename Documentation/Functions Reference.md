## Configurations ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Configurations are used to store a definition or the state of an object to the file system. Configurations are organized as maps divided by sections or topics. Inside a section, you may have an unlimited number of values referenced by keys. Keys may have Configuration maps are typically stored in *.ini files, therefore the character "=" is not allowed in keys or values written to a configuration map. Keys themselves may have a complex, pathlike structure. See [ConfigurationItem.descriptor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Class-Reference#class-method-descriptorrest-values) for reference.

#### *newConfiguration()* 
Returns a new empty configuration map. The configuration map is not derived from a public class and may be accessed only through the functions given below. 

#### *getConfigurationValue(configuration :: ConfigurationMap, section :: String, key :: String, default := false)
Returns the value defined for the given key or the *default*, if no such key has been defined.

#### *getConfigurationSectionValues(configuration :: ConfigurationMap, section :: String, default := false)*
Retrieves all key / value pairs for a given section as a map. Returns *default*, if the section does not exist.

#### *setConfigurationValue(configuration :: ConfigurationMap, section :: String, key :: String, value)*
Stores the given value for the given key in the configuration map. The value must be convertible to a String representation.

#### *removeConfigurationValue(configuration :: ConfigurationMao, section :: String, key :: String)*
Removes the given key and its value from the configuration map.

#### *readConfiguration(configFile :: String)*
Reads a configuration map from an *.ini file.

#### *writeConfiguration(configFile :: String, configuration :: ConfigurationMap)*
Stores a configuration map in the given file. All previous content of the file will be overwritten.

***

## Tray Messages ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Tray messages or TrayTips are small popup windows in the lower right corner of the screen used by applications or the Windows operating system to inform a user about an important event. Tray messages are used by the Simulator Controller for almost every change in the controller state.

#### *trayMessage(title :: String, message :: String, duration :: Integer := false)*
Popups a tray message. If *duration* is supplied, it must be an integer defining the number of milliseconds, the popup will be visible. If not given, a default period may apply (see below).

#### *disableTrayMessages()*
Diasables all tray messages from now on. Every following call to *trayMessage* will have no effect.

#### *enableTrayMessages(duration :: Integer := 1500)*
(Re-)enables tray messages, if previously been disabled by *disableTrayMessages*. A default for the number of milliseconds, the popups will be visible, may be supplied.

***

## Event Messages ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Event messages may be used to communicate between different processes. In Simulator Controller, the startup application sends events to the controller applicatio to start all components used by the simulator, to play and stop a startup song and so on.

#### *registerEventHandler(event :: String, handler :: Function Name)*
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

#### *raiseEvent(target :: String or false, event :: String, data :: String)*
Raises the event in the supplied target process. If *target* is *false*, the event is raised in the current process. Otherwise, *target* must use the [*winTitle*](https://www.autohotkey.com/docs/misc/WinTitle.htm) syntax of AutoHotkey to identify a target process through one of its windows or using its process id.

***

## Collection Helper Functions ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))

#### *string2Values(delimiter :: String, string :: String, count :: Integer := false)*
Splits *string* apart using the supplied delimiter and returns the parts as array. If *count* is supplied, only that much parts are splitted and all remaining ocurrencies of *delimiter* are ignored.

#### *values2String(delimiter :: String, #rest values)*
Joins the given values using *delimiter* into one string. *values* must have a string representation.

#### *inList(list, value)*
Returns the position of *value* in the given list or array, or *false*, if not found.

#### *bubbleSort(ByRef array :: Array, comparator :: Function Name)*
Sorts the given array in place, using *comparator*. This function will receive to objects and must return *true*, if the first one is considered larger or the same than the other. Stable sorting rules apply.

***

## Splash Screen Handling ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Several applications of Simulator Controller uses a splash window to entertain the user while performing their operations. The splash screen shows different pictures or even an animation using a GIF. All resources are loacated in the *Resources/Splash Images* folder of the Simulator Controller distribution. The user can switch between rotating pictures or a GIF animation using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration).

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

#### *withProtection(function :: Function Name, #rest params)*
Convinience function to call a given function with supplied parameters using protected mode.

***

## Debugging and Logging ([Functions.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Functions.ahk))
Essential support for tracking down coding errors. Since AutoHotkey is a weakly typed programming language, it is sometimes very difficult to get to the root cause of an error. Especially the tracing and logging capabilities may help here. All log files are located in the *Logs* folder of the Simulator Controller distribution.

#### *isDebug()*
Returns *true*, if debugging is currently enabled. The Simulator Controller uses debug mode to handle things differently, for example all plugins and modes will be active, even if they declare to be not.

#### *setDebug(debug :: Boolean)*
Enables or disables debug mode.

#### *getLogLevel()*
Return the current log level. May be one of: *kLogInfo*, *kLogWarn*, *kLogCritical*, *kLogOff*

#### *setLogLevel(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff))*
Sets the current log level. If *logLevel* is *kLogOff*, no logging takes place.

#### *increaseLogLevel()*
Increases the current log level.

#### *decreaseLogLevel()*
Reduces the current log level.

#### *logMessage(logLevel :: OneOf(kLogInfo, kLogWarn, kLogCritical, kLogOff), message :: String)*
Sends the given message to the log file, if the supplied log level is at the same or a more critical level than the current log level.