# Latest stable release

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

# Upcoming release

Not yet planned...

# Release history

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

## 6.8.9.0

#### Date: 03/27/26

#### Fixes

  - Fixed a bug in "Session Database", that prevented the correct car and track to be selected when double clicking on an *Automation* in the "Administration" tab.
  - Fixed a crash when importing events and actions in the Assistant Booster editor, when the export was not created from the same category (Rules or GPT).
  - Fixed a bug relating to the configuration of the *Reasoning* booster. If you ever used the *Reasoning* booster take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-689) for instructions how to fix your configuration.
  
#### Changes

  - The calculation of tyre wear data can now also handle setups with different compounds on each wheel.
  - A Pangram sentence has been added for Polish language which is used when testing speech generation.
  - Obsolete hotkey specifiers for opening and closing the Pitstop MFD for *Le Mans Ultimate* have been removed in "Simulator Setup".
  - Additional data has been added to the post-session knowledge of the Driving Coach.
  - Added a News article about the Coach post-session review capability.
  - New settings for the steer ratio, track width and wheel base of a car have been integrated in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings#car-settings). They are used as default values in the "Setup Workbench" for cars for which this information is not available in the meta data or elsewhere.
  - Rearranged the documentation for all [session settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) for better structure and readability.
  - [Experts] It is now possible to move events and actions from a rule-based Assistant Booster to a GPT-based Assistant Booster and vice versa using the Export / Import functions.
  - [Internal] Migrated to AHK 2.1-alpha.23.
	  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-689) for instructions how resolve a wrong *Reasoning* booster configuration.

## 6.8.8.0

#### Date: 03/20/26

#### Fixes

  - Finally implemented a fix for the Spotter and the Strategist that could have sporadicilly reported cars to be in the pit which actually have been on the track.
  - Fixed the download link for *Real Head Motion* in "Simulator Setup".
  - Fixed the initial tyre choice in "Strategy Workbench" to be one of the compounds for which data is available.
  - Fixed sporadically missing click sounds in "Simulator Startup" (new feature added with the last release).
  - Fixed translation for French of several settings in the "Session Database".
  
#### Changes

  - Many applications now show a progress bar when startup of the application takes longer than a few seconds.
  - Tyre wear data collected in the session database can now be used for strategy development (either by the "Strategy Workbench" or dynamically using active race rules).
  - The setting "Engineer: Threshold value for tyre wear warning" of the "Session Database" has been renamed to ["Pitstop: Minimum tyre tread depth"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings). This setting has been used by the Engineer as the threshold for tyre wear warnings to the driver, but is now also used now for strategy calculations to derive the number of usable laps for a give tyre compound based on historical tyre wear data.
  - The setting "Engineer: Threshold value for brake wear warning" of the "Session Database" has been renamed to ["Pitstop: Minimum brake pad thickness"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings).
  - A [new button in the tyre set list](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#rules--settings) let you re-initialize the number of usable laps of the selected tyre compound once it has been changed manually.
  - The "Race Settings" application now offers [selecting simulator, car and track](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#tab-session) for an upcoming session. In most cases, this will be determined automatically based on context or running simulator.
  - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) will allow you to change the tyre compound of all four tyres with one click in the "Race Settings".
  - When tyre compounds have been deleted or marked as unavailable in the "Race Settings" or the "Strategy Workbench", they are also removed from the tyre compound selection menus.
  - The Windows Server language pack for Polish has been added to "Simulator Setup".
  
## 6.8.7.0

#### Date: 03/13/26

#### Fixes

  - None this time...
  
#### Changes

  - Thanks to @Przem Lis DTM we can introduce fully handcrafted support for the Polish language in Assistant speech interactions incl. language specific command reference sheets.
  - Clicking on icons in the launchpad of "Simulator Startup" will now give visual and acoustic feedback.
  - [Developer] A switch in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#development-settings) let you activate the controls designer modus independent of all other development settings.
  - [Internal] Optimized startup time of the controller background process after a configuration change.

## 6.8.6.1

#### Date: 03/07/26

#### Fixes

  - Fixed a crash in the "Integration" plugin for SimHub.
  - Fixed several critical bugs in the race reports.

## 6.8.6.0

#### Date: 03/06/26

#### Fixes

  - Added a couple of missing translations.
  - Once again a fix for the sector time calculation for *Assetto Corsa*.
  - A filter has been implemented that can handle registered but not participating cars in online races in *Le Mans Ultimate*. Previously it was possible, that gap times were reported for these cars.
  - The Spotter no longer gives wrong warnings for slower or faster cars of another class after a pitstop.
  - The Strategist no longer gives incorrect weather information in rare conditions during the first lap.
  - Fixed a parameter definition error for the "plan_pitstop" event of the *Reasoning* booster of the Race Engineer.
  - Fixed a parameter definition error for the "report_low_energy" action of the *Reasoning* booster of the Race Engineer.
  
#### Changes

  - All tyre compound choices in the "Strategy Workbench" will adjust to changes made to the configuration of available tyre sets.
  - If on-track coaching is active, the name of the corner (if defined in the map data) will be supplied to SimHub. Please note, that this requires an update to the SimHub plugin. Refer to the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-686) for instructions on how to update to the latest version.
  - The documentation regarding the information accuracy of the Strategist and the Spotter has been updated. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#how-it-works) and [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#simulator-integration) (especially Note #12). In short: Lap times, gap times and position data may be updated for the Strategist with each sector (if the data is provided by the simulator), whereas the situation for the Spotter is a bit more complex and depends on the data update frequency as defined in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) of the "Session Database" and it depends on the general configuration of the Spotter as defined in "Simulator Setup" or "Simulator Configuration".
	  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-686), if you are using the data supplied by "Integration" plugin and/or are using the SimHub plugin.

## 6.8.5.0

#### Date: 02/27/26

#### Fixes

  - Fixed track deletion in the "Session Database" when short and long track name are different.
  - Another fix for sector time calculation in *Assetto Corsa*.
  
#### Changes

  - More optimizations for the Assistants cool down handling: A restart of the Assistants is now prevented for sessions that are already finished, for example, when running the in-lap after a qualifiying session.
  - A complete new method for gap timings has been implemented, which uses a sampling method to create a 3-dimensional matrix defined by the distance into track, time into the track and the current speed of each car. This is used to derive an almost perfect estimation of how long it would take the drivers car to reach a specific point on the track. Please note, that this is not yet supported for *iRacing*, because the current time into the lap is not supplied by the API of this game. A workaround may be implemented for this deficit in a future release.
  - Changed the car class name from "LMP2 ELMS" to "LMP2 Plus" in *Le Mans Ultimate*.
  - Removed currently undefined values from the "System Monitor" in the first lap.
  - Removed currently undefined values from the "Session State.json" file created by the "Integration" plugin in the first lap.
  - The remaining fuel is now displayed in the Laps viewer of the "Session Database".
  - [Internal] Refactored voice continuations for more flexibility for future voice interactions with multiple steps of question / answer dialogs.

## 6.8.4.0

#### Date: 02/20/26

#### Fixes

  - Fixed a bug in "Simulator Setup" which prevented changing #Tokens and the instructions of an Assistant booster for the second time.
  - [Internal] Fixed a rare bug in the rule engine, where a full production cycle returned an empty result.
  
#### Changes

  - The handling of the post-session cooldown phase has been optimized. The startup sequence for the next session will now be triggered as soon as all post-session data processing of the Assistants is finished. This especially helps to reduce the effect of the initial stutter in *Le Mans Ultimate* sessions, because these will now happen immediately at the beginning of a session.
  - Cars that are in the entry list, but do not participate in the session, will now be shown as "DNS" in various reports.
  - Technical informations like steer lock and steer ratio have been added by @inthebagbud UK for all *Automobilista 2* cars. This information is used by the "Setup Workbench".
  - [Important] A new version of the local LLM Runtime is available. If you are using the local runtime, please follow the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-684).
  - [Experts] A new fact "Session.Settings.Assistant.Language" in the rule engine knowledge base specifies the configured language of the current Race Assistant, so that your own scripts can use this knowledge when using "Assistant.Speak", for example.
  - [Experts] When running a *Lua* script for an Assistant, for example in a *Reasoning* booster, you can now use the special function *Rules.Produce()* to run a full cycle of the Rule Engine.
  - [Experts] The *Lua* script function "Assistant.Call" now returns the result of the method call to the caller.
  - [Experts] New *Lua* script function "Assistant.Property" allows you to access any property of the current Race Assistant instance.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-684), if you are using the local LLM Runtime.

## 6.8.3.0

#### Date: 02/13/26

#### Fixes

  - Fixed a computation failure by the Strategist whe handling tyre sets for simulators which do not support tyre sets at all.
  - Fixed a race condition and several other bugs in the sector times sampling for *Assetto Corsa* which was introduced with the last release.
  - Fixed a bug in the "Database Synchronizer", which caused many files to be missing from the community database since the last release.
  - Fixed a field validation in the settings editor of the "Session Database".
  - Fixed a crash in the *iRacing* IBT file importer in the "Session Database".
  
#### Changes

  - Correct lap times and sector times for the last lap are now available for *Project Motor Racing*. The solution, which was created by @Awesome-XV, is an approximation with a 20 Hz resolution, since the data is not available in a useful format in the API. Please note, that the method only works when using the *Connector* data acquisition method, which actually is the default. If you have changed the *Simulator/Data Provider* setting in the core settings, you may reconsider it.
  - The optional *Team Server* which you can host and operate on your for team session with your mate, as well as the optional *Whisper Server* which can be used to run a Whisper voice recognition system on a separate PC, are no longer part of the standard distribution package to safe some space. Rather they are now downloadable components which can be installed on the "Presets" page of "Simulator Setup".
  - [Experts] The rule engine of the Race Assistants is now enabled in the first lap as well. This will allow for additional processing in the first lap using a *Reasoning* booster. See [the custom event for cold tyre warnings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-events) for an example on how to utilize that.
  - [Experts] Enabling "Debug Rules" in the tray menu of any Assistant enables tracing in the rule engine.
  - New car models for "Setup Workbench":
    - Automobilista 2 (by @inthebagbud UK; no setup editor support)
      - Aston Martin DBR9, Aston Martin Vantage GT3 Evo, Audi R8 LMS GT3 evo II
      - Audi R8 LMS GT3, Audi V8 quattro DTM, BMW M3 Sport Evo Group A
      - BMW M4 GT3, BMW M6 GT3, Brabham Alfa Romeo BT46B
      - Brabham BMW BT52, Brabham BT26A, Brabham BT44
      - Brabham Cosworth BT49, Chevrolet Corvette C5-R, Chevrolet Corvette GTP
      - Chevrolet Corvette Z06 GT3.R, Dodge Viper GTS-R, Formula Classic Gen4 Model1
      - Formula Classic Gen4 Model2, Formula Classic Gen4 Model3, Formula Dirt
      - Formula HiTech Gen1 Model1, Formula HiTech Gen1 Model2, Formula HiTech Gen1 Model3
      - Formula HiTech Gen1 Model4, Formula HiTech Gen2 Model1, Formula HiTech Gen2 Model2
      - Formula HiTech Gen2 Model3, Formula Inter MG-15, Formula Junior
      - Formula Retro Gen2, Formula Retro Gen3 DFY, Formula Retro Gen3 Turbo
      - Formula Retro V12, Formula Retro V8, Formula Trainer Advanced
      - Formula Trainer, Formula Ultimate Hybrid Gen2, Formula Ultimate Hybrid Gen3
      - Formula USA 2023, Formula V10 Gen1, Formula V10 Gen2
      - Formula V12, Formula V8 Gen3, Formula Vee Gen1 + Fin
      - Formula Vee Gen1, Formula Vee Gen2, Formula Vintage Gen1 Model1
      - Formula Vintage Gen1 Model2, Formula Vintage Gen2 Model1, Formula Vintage Gen2 Model2
      - Lamborghini Huracan GT3 EVO2, Lamborghini Murcielago R-GT, Lola B2K00 Ford-Cosworth
      - Lola B2K00 Mercedes-Benz, Lola B2K00 Toyota, Lola T9500 Ford-Cosworth
      - Lola T9500 Mercedes-Benz, Lola T9800 Ford-Cosworth, Lotus 49C
      - Lotus 72E, Lotus 79, Maserati MC12 GT1
      - McLaren 720S GT3 Evo, McLaren 720S GT3, McLaren Cosworth MP41C
      - McLaren Cosworth MP48, McLaren F1 GTR, McLaren Honda MP46
      - McLaren Honda MP47A, McLaren M23, McLaren Mercedes MP412
      - Mercedes-AMG GT3 Evo, Mercedes-AMG GT3, Mercedes-Benz 190E 2.5-16 Evo II DTM
      - Mercedes-Benz CLK LM, Milano GT36, Nissan GT-R Nismo GT3
      - Nissan R390 GT1, Nissan R89C, Porsche 911 GT8
      - Porsche 911 GT3 R, Porsche 962C, Porsche 992 GT3 R
      - Porsche 996 GT3 RSR, Reynard 2Ki Ford-Cosworth, Reynard 2Ki Honda
      - Reynard 2Ki Mercedes-Benz, Reynard 2Ki Toyota, Reynard 95i Ford-Cosworth
      - Reynard 95i Honda, Reynard 95i Mercedes-Benz, Reynard 98i Ford-Cosworth
      - Reynard 98i Honda, Reynard 98i Mercedes-Benz, Reynard 98i Toyota
      - Sauber Mercedes C9, Swift 009c Ford-Cosworth

## 6.8.2.0

#### Date: 02/06/26

#### Fixes

  - Fixed a critical bug for ACC, which prevented the full start sequence. This one was introduced with the last release.
  - Fixed temperature handling in the issue analyzer of "Setup Workbench", if a temperature unit other the "Celcius" is selected.
  - Fixed wrong scale of the progress bar when importing settings in the "Session Database".
  - Fixed uploading of car setups to the community database.
  - Finally found the reason, why the *Le Mans Ultimate* API signalled *Pause* at the very exact end of a session, therebey preventing the end of session processing by the Assistants.
  
#### Changes

  - Sector times are now available for *Assetto Corsa*. The solution, which was created by @Awesome-XV, is an approximation with a 20 Hz resolution, since the data is not available in a useful format in the API. Please note, that the method only works when using the *Connector* data acquisition method, which actually is the default. If you have changed the *Simulator/Data Provider* setting in the core settings, you may reconsider it.
  - If available, sector times will be shown in the lap reports in the "Solo Center" and "Team Center" applications.
  - All field value validation handlers have been rewritten, so that validation and possible range correction happens only on tab out.
  - Changed the startup sequence for *Le Mans Ultimate* a bit, so that the short stutter at the beginning of the session happens earlier.
  - The handling of the Service URL for the [Generic GPT service provider](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#generic) has been changed, so that OpenAI compatible services can be called, even if they don't follow the OpenAI naming scheme for the API URL.
  - New article for the *News* system.
  - [Expert] The new controller action function ["property"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions#runtime-and-host-language-interface) allows an embedded programming language like *Lua* to access properties of the main *Controller* object and all plugins.
  - [Expert] The existing controller action function ["invoke"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions#runtime-and-host-language-interface) has been changed to pass its return value to the caller. This allows an embedded programming language like *Lua* to access the function result, if a method of the main *Controller* object or any plugin had been called.

## 6.8.1.0

#### Date: 01/30/26

#### Fixes

  - The meta data for all *Automobilista 2* cars added in the last release contained an error, which crashed the "Setup Database". All cars have been fixed with this release.
  - Fixed the "Integration" plugin to accept language settings other than "English" / "EN".

#### Changes

  - The "Solo Center" now reloads all cars and tracks, if used for a session where a car or a track is used for the very first time.
  - Value ranges are now checked when changing settings in the "Session Database".
  - When "All" tracks had been selected in the settings of the "Session Database", all tracks that already had been driven (independent of car) will be available in the "Tracks" drop down menu. This information is collected while driving, so will only be updated starting from now.
  - Car names of all cars and tracks have been added for *Le Mans Ultimate*, so that they show up in the "Session Database", even if they have not been driven yet.
  - [Experts] The calling signature of the *Simulator.Read* function in the *Lua* script [module "Simulator"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules#module-simulator) has changed. You may need to adapt your script, if you are using this function.
  - [Important] The SimHub plugin had been updated. Refer to the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-681) for instructions on how to update to the latest version.
  - [Important] Data for all cars with the *old* composite names incl. team name, car number and so on from *Le Mans Ultimate* has been removed from the session database. All removed data has been moved the folder *Simulator Controller\Database\Archive\LMU* which is located in your user *Documents* folder.
  - New car models for "Setup Workbench":
    - Automobilista 2 (by @inthebagbud UK; no setup editor support)
      - Alpine A110 GT4 Evo, Aston Martin Vantage GT4 Evo, Aston Martin Vantage GTE
      - Audi R8 LMS GT4, Audi R8 V10 GT, BMW M4 GT4
      - BMW M8 GTE, CARNAME, Chevrolet Camaro GT4.R
      - Chevrolet Camaro SS, Chevrolet Corvette C3.R Convertible, Chevrolet Corvette C3.R
      - Chevrolet Corvette C8 Z06 (+Z07 Upgrade), Chevrolet Corvette C8.R, Chevrolet Cruze Stock Car 2019
      - Chevrolet Cruze Stock Car 2020, Chevrolet Cruze Stock Car 2021, Chevrolet Cruze Stock Car 2022
      - Chevrolet Cruze Stock Car 2023, Chevrolet Cruze Stock Car 2024, Chevrolet Omega Stock Car 1999
      - Citroen DS3 RX, Dodge Viper ACR, Ginetta G58
      - Lamborghini Huracan Super Trofeo EVO2, Lola B0540 Turbo, Lola B0540 V8
      - Maserati GT2 Stradale, McLaren 570S GT4, McLaren F1 LM
      - Mercedes-AMG GT4, MetalMoro AJR Chevrolet, MetalMoro AJR Honda
      - MetalMoro AJR Judd, MetalMoro AJR Nissan, MetalMoro MRX Duratec P4
      - MetalMoro MRX Duratec Turbo P2, MetalMoro MRX Duratec Turbo P3, MetalMoro MRX Honda P3
      - MINI Cooper JCW, MINI Countryman R60 RX, Mitsubishi Lancer Evo10 RX
      - Porsche 911 RSR 1974, Porsche 911 RSR GTE, Porsche Cayman GT4 Clubsport MR
      - Puma P052, Roco 001, Sigma P1
      - Sprint Race, Stock USA Gen1, Stock USA Gen2
      - Stock USA Gen3 LM, Stock USA Gen3, Super Trophy Trucks
      - Super V8, Superkart 250cc, Toyota Corolla Stock Car 2020
      - Toyota Corolla Stock Car 2021, Toyota Corolla Stock Car 2022, Toyota Corolla Stock Car 2023
      - Toyota Corolla Stock Car 2024, Ultima GTR, Volkswagen Polo RX
	  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-681), if you are using the data supplied by "Integration" plugin and/or are using the SimHub plugin.

## 6.8.0.0

#### Date: 01/23/26

#### Fixes

  - Fixed several missing unit and value format conversions.
  - Fixed a bug in "Session Database" introduced with the last release, that prevented the track drop down menu showing the selected track name.
  - Fixed a critical bug for *Assetto Corsa Competizione* which prevented to Assistants and all other components of Simulator Controller to start up correctly.
  - Several bugs have been fixed for the tyre laps calculation in sessions where tyres are used for more than two stints.
  - Fixed a bug in "Team Center" that prevented the pitstop settings preview window to be opened for *Le Mans Ultimate* sessions, when the pitstop update check had been set to a very long time.
  - Fixed display of the car class in various reports in cases where the official car class name if not supplied by the simulator. 

#### Changes

  - A new [audio route "Actions"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) for the controller action functions ["speak" and "play"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions#trigger-actions), which can be used from scripts or in track automations and so on, has been introduced.
  - The creation/upload date for telemetries, strategies and setups is now displayed in the "Session Database".
  - You now can attach notes to your telemetries, strategies and setups in the "Session Database".
  - All known cars will now be shown in "Setup Workbench", also those without setup editor support and even if they had not been driven yet.
  - The [SimHub plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#simhub-plugin) which had been maintained in the past by Jordan Moss (@Mossi) had been rewritten by our team member @Awesome-XV and is now an official part of Simulator Controller. It will be installed automatically by "Simulator Setup", but it must be enabled in SimHub and to use it, the "Integration" plugin in Simulator Controller must be enabled as well.
  - [Experts] The "Integration" plugin has been rewritten to support the new version of the SimHub plugin and the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) has been rewritten as well. A couple of incompatible changes has been made to streamline the data structure, therefore take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-680).
  - [Internal] The support for *Lua* 5.5 has been extended, but still not fully functional.
  - [Internal] Fixed usage statistics for translators.
  - New car models for "Setup Workbench":
    - Automobilista 2 (by @inthebagbud UK; no setup editor support)
      - Alpine A424, Aston Martin Valkyrie Hypercar, Aston Martin Valkyrie
      - Audi R8 LMP1, BMW 2002 Turbo, BMW M Hybrid V8
      - BMW M3 E46 GTR, Brabham BT62, Cadillac DPi-VR
      - Cadillac V-Series.R, Chevrolet Chevette, Chevrolet Corvette C3
      - Copa Fusca, Copa Montana, Courage C60 Hybrid
      - Dallara F301, Dallara F309, Dallara SP1
      - Fusca 1 Hot Cars, Fusca 2 Hot Cars, Fusca Classic FL
      - Gol Classic B, Gol Classic FL, Gol Hot Cars
      - Iveco Stralis, Kart 2-Stroke 125cc Direct, Kart 2-Stroke 125cc Shifter
      - Kart 4-Stroke Race, Kart 4-Stroke Rental, Kart Cross
      - Lamborghini Miura SV, Lamborghini Revuelto, Lamborghini SC63
      - Lamborghini Veneno Roadster, Lotus 23, MAN TGX
      - McLaren Senna, Mercedes-Benz Actros, MINI Cooper S 1965 B
      - MINI Cooper S 1965, Mitsubishi Lancer RS, Passat Classic B
      - Passat Classic FL, Passat Hot Cars, Porsche 963
      - Puma GTB, Puma GTE, Ultima GTR Race
      - Uno Classic B, Volkswagen Constellation, Volkswagen Polo GTS
      - Volkswagen Polo, Volkswagen Virtus GTS, Volkswagen Virtus
      - Vulkan Truck
	  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-680), if you are using the data supplied by "Integration" plugin and/or are using the SimHub plugin.

***

[Release Notes Archive](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes-Archive)