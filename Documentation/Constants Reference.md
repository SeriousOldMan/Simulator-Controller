## Installation Pathes ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Constants.ahk))
The following constants may be used to refer to all the relevant locations of the Simulator Controller distribution.

#### *kHomeDirectory, kResourcesDirectory, kSourcesDirectory, kIncludesDirectory, kBinariesDirectory, kConfigDirectory, kLogsDirectory*
All these constants define paths pointing to a specific folder in the Simulator Controller distribution. In deviation to Windows standards, the paths contain a trailing backslash, since in allmost all cases, a filename will be concatenated to one of these constants in order to access this file.

#### *kSplashImagesDirectory, kButtonBoxImagesDirectory, kIconsDirectory*
Paths for graphical resources.

#### *kSimulatorConfigurationFile, kControllerConfigurationFile*
Paths for the most important configuration files used by Simulator Controller.

***

## Global Configuration Map ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Constants.ahk))
One global configuration map exists for simulator controller, which define the capabilities, the controller mapping and the configuration of all active plugins.

#### *kSimulatorConfiguration*
The global configuration map. This map is read from *kSimulatorConfigurationFile* and the content is maintained by the setup tool (*)

***

## Log Levels ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Constants.ahk))

#### *kLogInfo, kLogWarn, kLogCritical, kLogOff*
Define the various log levels used by the logging functions. See [Debugging and Logging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#debugging-and-logging-functionsahk) for more information.

***

## Controller Function Types ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Constants.ahk))
Used to identify the different types of controller functions in a configuration map. See the subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#2waytogglefunction-extends-controllerfunction-classesahk) for reference.

#### *k1WayToggleType, k2WayToggleType, kButtonType, kDialType, kCustomType*
All currently defined controller function types.

***

## Miscellaneous Constants ([Constants.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Constants.ahk))
Additional constants used by Simulator Controller.

#### *kUndefined*
May be used by functions to denote a default value for optional parameters that might be boolean values.

#### *kVersion*
The current version of Simulator Controller according to the VERSION document in the root folder.

#### *kSilentMode*
If this is *true*, all applications of Simulator Controller adopt accordingly and woll not use any splash screens or other visual or audio feedback.

#### *kTrue, kFalse, kActivate, kDeactivate, kIncrease, kDecrease*
Miscellaneous constants, which define string representations for typical code elements.