# Latest stable release

## 6.9.9.0

#### Date: 06/05/26

#### Fixes

  - Fixed a critical bug in the community database synchronization process, which was broken since two releases.
  - Fixed a critical bug for *iRacing*, which prevented some of the pitstop settings (for example tyre pressure) to be changed correctly from a controller or by voice command.
  - Fixed a bug for *RaceRoom Racing Experience*, which caused the readout of the current selection of pitstop settings to fail sometimes.
  - Fixed some translations in the session settings for Chinese.
  - Fixed a bug, that caused the Spotter to inform about a potential problem of an opponent who actually pitted in the last lap.
  - Fixed the background color to be transparent for the icons in the new modal dialogs introduced with Release 6.9.4.
  
#### Changes

  - Pitstops of all cars are no longer registered during the first few laps for two reasons:
    1. Some sims report a car being in the pit during the initial grid formation, if that car has not entered the grid formation yet.
	2. A car which pits so early (for examople for repairs), will have no benefit later in the race at all. So the pitstop does not count for strategy decisions.
  - The Engineer will now avoid tyre configurations with a too high difference in tyre wear, when only some of the tyres have to be swapped at a pitstop.
	- Two new settings "Max. tyre wear difference (axle)" and "Max. tyre wear difference (front/rear)" have been integrated in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings#pitstop-settings), which let you specify the maximum imbalance in tyre wear you are willing to accept (with a default of 30%).
    - See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#how-it-works) for more information.
  - Added the new car "ADESS AD25" for *Le Mans Ultimate*. Support for "Setup Workbench" will follow with the next release.
  - [Developer] The support for using composite variables in the different rule types has been extended. Here are some examples:

		[?Compose] => (Set: L = Object)
		{All: [?Compose], [?L]} => (Set: ?L.prop1 = Yes)
		{All: [?Compose], [?L]} => (Prove: setProp2(?L, No))
		{All: [?Compose], [?L]} => (Prove: Set(?L.prop3, Maybe))

		setProp2(?object, ?value) <= Set(?object.prop2, ?value)

# Upcoming release

## 7.0.0.0

#### Date: 06/12/26 (planned)

#### Fixes

  - Fixed a problem in the internal represenation of the settings for minimum tyre tread depth and the minimum brakepad thickness in the "Session Database". See the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-700), if you have used this settings.
  
#### Changes

  - The storage and synchronization process of the community database has changed. The new process will be used at the very first next synchronization.
  - [Important] Tyre wear data can now be shared in the community database. The consent dialog will be shown automatically the next time you use one of the applications of Simulator Controller. If you share your tyre wear data, you will be rewarded with tyre wear data of all other community members, of course.
    - A new setting "Use tyre wear data from community" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings#session-settings) lets you choose, whether you want to use the wear data of the community beside your own collected data for any tyre wear related decisions (for example see next item).
  - The Engineer can now decide based on tyre wear data which will be the best tyre compound mixture when changing tyres for the next stint.
    - A new setting "Choose Compound Mixture" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings#pitstop-settings) allows you to enable this decision for the Engineer (it is disabled by default).

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-700), if you are using the settings for minimum tyre tread depth and the minimum brakepad thickness.

# Release history

## 6.9.8.0

#### Date: 05/29/26

#### Fixes

  - None this time...
  
#### Changes

  - Around 10 % performance improvement of the rule engine, which will reduce the CPU load of all Assistants a bit.
  - [Developer] More useful extensions to the rule engine.
    - General expressions can now be used in the production rule predicate for list containment. Example:
  
			{All: {Is: ?L1 = [1, 2]}, {Is: ?L2 = [3]},
				  {Prove: concat(?L1, ?L2, ?L)}, {None: [?L contains 4]}} => (Set: Success = true)
				  
			concat([], ?L, ?L)
			concat([?H | ?T], ?L, [?H | ?R]) <= concat(?T, ?L, ?R)
	- Fact names in *Set* and *Clear* actions of production rules can now also be represented by dotted variables.
    - The rule engine supports a new call method for external functions, which does not pass the special first argument to this function. Using this method which is available for [actions in production rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#actions) and also for [predicates in reduction rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates), any global function in the host programming language can be called.
	- External functions called by the rule engine can now return values of any type supported by the rule engine. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates) for more information.
	- External functions called by the rule engine can now actually be methods identified by a qualified name like *Singleton.Instance.myMethod*, as long as the name before the first dot identifies a valid object or class in the global name space.
	- [Important] The behavior of the *ProveAll* action has changed in a way, which can brake current production rules that use the *ProveAll* action. You can now use *ProveAll* to create powerful loops in the action part of a reduction rule. Please see the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#actions) for more information.
	- *Rules* and *Terms* can now be serialized to and from JSON on the implementation level of the rule engine.
	- The [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#literals) on using dotted names for *Variables* and *Facts* has been extended and clarified.

## 6.9.7.0

#### Date: 05/22/26

#### Fixes

  - Fixed a rare race condition, which caused the FCY simulation by the Race Strategist to fail.
  
#### Changes

  - [Experts] Clarified the behavior of *Assistant.Property* and *Assistant.Call* in the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions) for rules and scripts running in an Assistant process.
  - [Experts] Added new predicates *Assistant.Call=* and *Assistant.Property=* for the rule engine running in an Assistant process as well as the equally named functions for the Lua script engine. They allow to acquire the return value of the called method or property.
  - [Developer] Some very useful features have been added to the rule engine.
    - Added support for foreign functions called by the rule engine to return a value, which then is unified with the last argument to the function call. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates) for more information.
	- Added support for using foreign function aliases (with or without return values) in production rule conditions and actions. Example:
	
			{Is: :foreignCall=(Foo, ?Result)} => (Set: CallResult = ?Result)
    - General terms (compounds, lists and so on) are now supported in *Let* actions in production rules. Example:
	
			[?FuelSavingLaps > 0] => (Let: ?target = Laps(?FuelSavingLaps)), (Prove: calculateSaveAmount(?target))
			[?FuelSavingPct > 0]  => (Let: ?target = Pct(?FuelSavingPct)), (Prove: calculateSaveAmount(?target))
    - The [*Set* and *Clear* actions of production rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#actions) now accept pseudo object notation to compose fact names dynamically during runtime.
    - Added two new [builtin predicates "parse" and "print"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates) for reduction rules.
	- Added two new [builtin predicates "productions" and "reductions"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates), which generate a list of all rules for the corresponding category.
	- Added two new [builtin predicates "addRule" and "removeRule"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#builtin-predicates) for the rule engine. Using these predicates, the rule engine is now capable of adding and removing rules during runtime, thereby supporting learning through feedback loops.
  - [Internal] Migrated to AHK 2.1-alpha.30.

## 6.9.6.0

#### Date: 05/15/26

#### Fixes

  - Fixed a bug in the new themed dialog boxes, which caused a crash when a message box overlays another message box.
  
#### Changes

  - Optimized and standardized the naming of the data folders of loaded sessions in "Solo Center" and "Team Center".
  - Standardized folder paths for stored telemetry data for Driving Coach, "Solo Center", "Team Center" and "Setup Workbench". Documentation updated accordingly.
  - The "Setup Workbench" can now analyze telemetry data from a session after it already ended, as long as the telemetry data is still available. The Issue Analyzer can then create handling issues based on the telemetry data. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#Analyzing-handling-issues-based-on-saved-lep-telemetry-files) for more information.
  - The automatic installation of Windows runtimes and language specific speech recognition libraries can now be rejected on the "Basic" configuration page in "Simulator Setup". Once rejected, they can still be installed later on using the extended configuration mode.
  - [Internal] The background processes for the Race Engineer, the Race Strategist and the Race Spotter got new icons. You can see them in the tray menu of Windows. The old colors have been preserved for a recognition effect.
  
## 6.9.5.0

#### Date: 05/08/26

#### Fixes

  - Fixed a bug for *Le Mans Ultimate* in mixed weather conditions, which caused the Spotter to announce the wrong weather at the sessions start when the last weather node of the session had a different weather than the second to last weather node.
  
#### Changes

  - Support for the new shared memory API of *Le Mans Ultimate* has been added.
    - No more short stutter at the start of a session, because the data which was acquired using several HTTP requests against the REST/JSON API of *Le Mans Ultimate* is now available in the shared memory.
	- More important, information about TC and ABS activations is now available in the telemetry data, thereby enabling the Driving Coach to give you more precise hints for cornering and ca handling.
	- Please note, that the information about brake wear has been removed for the time being, because this information is for the brake disc and not for the brake pads anyway.
	- A few data items are still acquired using the REST/JSON API, for example information about any suspension damage. It is possible to disable this API using a core setting [core setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#simulator-settings), if it becomes necessary due to performance issues.
    - For safety reasons, the old style API can be reactivated using a new [core setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#simulator-settings).
  - Many performance optimizations in the handling of the data API of *Le Mans Ultimate*.
  - The API for *Assetto Corsa EVO* has been updated to the latest game version.
  - [Developer] A new [core setting "LogSimulator"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#development-settings) let you track down performance issues in the simulator API control flow.

## 6.9.4.0

#### Date: 05/01/26

#### Fixes

  - Fixed a bug in the handling issue analyzer (used by the Driving Coach and the "Setup Workbench"), which caused a crash, when custom sound files have been created by the user.
  - Fixed on-track and brake coaching for *Assetto Corsa* which had been broken since two releases.
  
#### Changes

  - The meta data for *RaceRoom Racing Experience* has been updated to the latest version.
  - The tyre decision of the Race Engineer has been optimized for the last pitstop in a multi-stint race.
  - [Important] A new version of the local LLM Runtime is available. If you are using the local runtime, please follow the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-684).
  - [Internal] All modal dialogs (alert boxes, question dialogs, input boxes and so on) have been re-implemented for better theming support. There are hundreds of them. If you find a problem, let us know immediately.
  - [Internal] Migrated to AHK 2.1-alpha.28.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-694), if you are using the local LLM Runtime.

## 6.9.3.1

#### Date: 04/26/26

#### Fixes

  - Fixed a critical bug in the timing calculations of the telemetry analyzer, which caused startup problems of on-track coaching and brake coaching in many cases.

## 6.9.3.0

#### Date: 04/24/26

#### Fixes

  - Fixed calculation of remaining session time in timed sessions for *Assetto Corsa*.
  - Fixed a bug introduced with the last release which prevented uninstalling Simulator Controller, when the data folder was not located in the user *Documents* folder.
  - Fixed a bug which prevented in rare cases that coaching instrutions was passed to SimHub using the "Session State.json" file (by the "Integration" plugin).
  - Fixed a couple of smaller issues in the Portuguese grammar files for the Assistants.
  
#### Changes

  - Complete rework of the Portuguese voice command recognition patterns by @Jimmy Sant'ana. If you are using the Portuguese language to interact with the Assistants, make sure that you understand all the changes to the different commands.
  - Support for the new shared memory API of *Assetto Corsa EVO* version 0.6 has been added, thereby introducing full integration for this great game.
    - The *Assetto Corsa EVO* API is not yet complete - participant information is missing, no weather information is available, and so on.
    - Tyre compound information for all current cars has been added by @neophyte.
	- Configuration support is available in "Simulator Setup".
	- The current implementation is far from being complete, as is the current state of implementation of the API of *Assetto Corsa EVO*.

## 6.9.2.0

#### Date: 04/17/26

#### Fixes

  - Fixed the session end detection for *Le Mans Ultimate* when leaving the server or a session. This was broken with the latest update of *Le Mans Ultimate*.
  
#### Changes

  - The native interface of Anthropic (for the experts: the *Messages* API) is now supported as [GPT provider](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#anthropic).
  - The installer of Simulator Controller now allows new users to specify the location of the local data folder, which is normally located in the user *Documents* folder. There will still be a small folder in the *Documents* folder, though, to point to the *real* data folder, if a different location is chosen.
  - [Experts] A new version of the Lua 5.5 runtime is included. Default is still version 5.4 for compatibility reasons.
  - [Developer] The class tree of "LLMConnector" is no longer *sealed*, i.e. it is now possible to create own connector classes in custom plugins.
  - [Internal] Migrated to AHK 2.1-alpha.24.
  
## 6.9.1.0

#### Date: 04/10/26

#### Fixes

  - Fixed a critical bug in the download process, when one of the download mirrors is unavailable.
  - Added several missing translations.
  - Fixed a bug in "Race Settings", which caused the tyre compound drop downs to be empty when this application is run for the very first time.
  - Fixed a so called race condition when a new car/track is recognized, which caused the car and or track drop down menus in "Solo Center" to be empty.
  
#### Changes

  - Changed session finish detection for races based on a fixed number of laps.
  - Support has been added to run Simulator Controller in a virtualized environment like [VirtualBox](https://www.virtualbox.org/).
  - Support has been added to connect to simulators running on a remote machine, which can also be consoles. See the [added documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#Connecting-to-remote-simulators) for more information.
    - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers#simulator-startup) has been added to "Simulator Startup", which let's you start Simulator Controller for games running on a remote machine.
    - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers#simulator-setup) has been added to "Simulator Setup", which let's you configure simulators not running on the PC, where Simulator Controller is installed.
  - Full documentation and an installation video have been added for the [*F1 25* integration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-f125), especially the [important notes on operation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#Special-notes-for-F1-25).
    - As the *F1 25* integration is now considered stable and is officially supported, I want to thank @Awesome-XV for the great base implementation of the "F125" plugin.
	- With the special requirement to run Simulator Controller remotely to the *F1 25* game, problems may still lurk around the corner. Therefore, please report any issues you encounter.
  - The car meta data for *Automobilista 2* has been updated by @inthebagbud UK.
  - New car models for "Setup Workbench":
    - Automobilista 2 (by @inthebagbud UK; no setup editor support)
	  - Formula V12 (removed, replacement see below)
	  - Formula Edge Model1
	  - Formula Edge Model2
	  - Formula Edge Model3
	  - Formula Ultimate Hybrid Gen1

## 6.9.0.0

#### Date: 04/03/26

#### Fixes

  - A bug has been fixed in the *Reasoning* booster configuration used in "Simulator Configuration", that could cause the booster to be partially active, after it had been disabled by the user in the configuration.
  - Fixed a bug in the handling of the voice drop down in "Simulator Setup". This bug caused the menu to jump back to "Random", if only one voice was available for the selected speech synthesizer method.
  - Fixed some internal problems related to extracting ZIP archives, which could lead to failure of downloading the community database. Side effect: Big performance improvements in some areas. See also the changes section below.
  - Fixed a bug in tyre wear calculation after a pitstop where not all tyres had been changed.
  - Fixed a bug that prevented the "News, tips and tricks" menu to open after the window theme had been changed in the settings in "Simulator Startup".
  - Fixed a bug in "Solo Center" which prevented the list of used tyre sets to be updated when saved sessions are being loaded from a file.
  
#### Changes

  - Initial support for EA F1 25 has been added with this release. Please note, that it is currently required to run Simulator Controller on a separate PC, because the EA AntiCheat software "Javelin" flags Simulator Controller as cheating software. Beside that, the current state of implementation is to be considered *Alpha*, does not include any documentation yet and requires a manual configuration. In case, you want to try the F1 support in its current stage of development, contact me on our Discord.
  - "Simulator Setup" now supports different configuration modes to hide more complex and seldomly used stuff from new users. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool) for more information.
  - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) has been introduced that allows you to change the new configuration mode to *Extended* in "Simulator Setup", when switching between pages.
  - Rearranged the documentation for all [keyboard modifiers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) for better structure and readability.
  - Update track names for *Le Mans Ultimate*.
  - [Expert] Handling of ZIP archives can now now be configured to either use the *PowerShell* or the Windows builtin *tar* command. *Tar*, which is now the default method, is much faster and reliable, but cannot handle directories which contain symbolic links. If you have moved your user *Documents* folder to a different drive, you need to change the *Expander* method in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#archive-settings).
  - New car models for "Setup Workbench":
    - Le Mans Ultimate
	  - Genesis GMR001
	  - Duqueine D09 P3
      - Ginetta G61-LT-P325 Evo (fixed engine mixture and some unit labels)
	  - Ligier JS P325 (fixed engine mixture and some unit labels)
		  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-690) for instructions how configure the new handling of ZIP archives.

***

[Release Notes Archive](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes-Archive)