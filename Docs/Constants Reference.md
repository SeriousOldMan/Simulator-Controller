## Installation Paths ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Constants.ahk))
The following constants may be used to refer to all the relevant locations of the Simulator Controller distribution.

#### *kHomeDirectory, kResourcesDirectory, kSourcesDirectory, kFrameworkDirectory, kExtensionsDirectory, kPluginsDirectory, kBinariesDirectory, kConfigDirectory*, *kRulesDirectory*, *kGrammarsDirectory*, *kTranslationsDirectory* 
All these constants define paths pointing to a specific folder in the Simulator Controller distribution. In deviation to Windows standards, the paths contain a trailing backslash, since in allmost all cases, a filename will be concatenated to one of these constants in order to access this file.

#### *kSplashMediaDirectory, kScreenImagesDirectory, kButtonBoxImagesDirectory, kStreamDeckImagesDirectory*
Paths for graphical and audio resources contained in the Simulator Controller distribution.

#### *kUserHomeDirectory, kUserConfigDirectory, *kUserRulesDirectory*, *kUserGrammarsDirectory*, *kUserTranslationsDirectory*, kUserSplashMediaDirectory, kUserScreenImagesDirectory, kUserPluginsDirectory, kLogsDirectory*, *kTempDirectory*, *kProgramsDirectory*, *kDatabaseDirectory*
A special folder *Simulator Controller* will be created in the user *Documents* folder. It will contain various subfolders for adding user-specific extensions or substitutions (media, plugins, ...), and for storing configuration and log files. Some of them ca be moved to other locations by configuration. Therefore always reference these folders using the given constants.

#### *kSimulatorConfigurationFile, kSimulatorSettingsFile*
Paths for the most important configuration files used by Simulator Controller.

***

## Global Configuration Map ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Constants.ahk))
One global configuration map exists for Simulator Controller, which define the capabilities, the controller mapping and the configuration of all active plugins.

#### *kSimulatorConfiguration*
The global configuration map, which is read from *kSimulatorConfigurationFile*. The content is fully maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

***

## Log Levels ([Debug.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Debug.ahk))
See the dcoumentation about [Debugging & Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-debugahk) for more information.

#### *kLogInfo, kLogWarn, kLogCritical, kLogOff*
Define the various log levels used by the logging functions. These are numerical values where *kLogInfo* < *kLogWarn* < *kLogCritical* < *kLogOff*.

***

## Controller Function Types ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Constants.ahk))
Used to identify the different types of hardware controller functions in a configuration map. See the subclasses of [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-configurationahk) for reference.

#### *k1WayToggleType, k2WayToggleType, kButtonType, kDialType, kCustomType*
All currently defined controller function types.

***

## Simulation Session Types ([SimulatorPlugin.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Libraries/SimulatorPlugin.ahk))
Thse constants define the different session types, a given simulation might support. See the class [SimulatorPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#simulator-plugin-implementation-classes) and its subclasses for more information about simulations and sessions.

#### *kSessionFinished, kSessionPaused, kSessionOther, kSessionPractice, kSessionQualification, kSessionRace*
All currently defined and supported simulator session types. *kSessionFinished = 0* is special in the sense, that there is no current session, as is *kSessionPaused = -1*, which means, there is a current session, but the simulation is paused at the moment.

***

## Messsaging Types ([Messages.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Extensions/Messages.ahk))
Delivery method types used to supply to [sendMessage](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#sendmessagemessagetype--oneofklocalmessage-kwindowmessage-kpipemessage-kfilemessage-category--string-data--string-target--false).

#### *kLocalMessage, kWindowMessage, kPipeMessage, kFileMessage*
These constants define the various delivery methods for messages send by the function [sendMessage](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#sendmessagemessagetype--oneofklocalmessage-kwindowmessage-kpipemessage-kfilemessage-category--string-data--string-target--false).

***

## Miscellaneous Constants ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Framework/Constants.ahk))
Additional constants used by Simulator Controller.

#### *kUndefined*
May be used by functions to denote a default value for optional parameters that might be boolean values.

#### *kNull*
Similar to *kUndefined*, denotes an undefined value. *kNull* typically is used for data contexts.

#### *kVersion*
The current version of Simulator Controller according to the VERSION document in the root folder.

#### *kSilentMode*
If this is *true*, most applications of Simulator Controller will adopt accordingly and will not use any splash screens or other visual or audio feedback.

#### *kTrue, kFalse, kActivate, kDeactivate, kIncrease, kDecrease*
Miscellaneous constants, which define string representations for often used code constants.

#### *kForegroundApps*, *kBackgroundApps*
The names of the different applications (without the ".exe" extension). Foreground applications can have an UI, background applications will normally execute without an UI.

#### *kRaceAssistants*
The names of all Race Assistants, for example ["Driving Coach", "Race Engineer", ...].