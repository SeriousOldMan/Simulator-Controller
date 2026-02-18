# Latest stable release

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

# Upcoming release

## 6.8.4.0

#### Date: 02/20/26 (planned)

#### Fixes

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
	  
# Release history

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

## 6.7.9.0

#### Date: 01/16/26

#### Fixes

  - A bug has been fixed for *iRacing* when cars are towed to the pit or are otherwise absent. This bug caused the Monte Carlo strategy simulation to crash.
  - Fixed handling of language specific instructions for the Driving Coach and the Assistant boosters, when a machine translated language is used.
  - Fixed a misbehaviour of a Race Asistant, when no language specification had been provided to the plugin. This cannot happen, when the configuration was created by "Simulator Setup", but it could happen in synthetic testing scenarios.
  - Fixed a rare bug introduced with one of the recent releases, which caused the "Telemetry" and the "Analyzer" item to be unavailable in the "Issues" selector menu of "Setup Workbench".
  - Fixed a bug in "Simulator Setup" which prevented pre-listening a voice in a translated language.
  - [Experts] Fixed a bug in the "Simualators" script module, which accessed a non-existent global function.
  - [Experts] Fixed parameter extraction in the "execute" controller action function, when a path to the executable is provided, which contains a space character.

#### Changes

  - The user name can now be changed in the [profile dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#User-profile) and it can be specified where this name will be used throughout the Simulator Controller applications and tools. Using this it is now possible, for example, to let the Assistants call you by a different name than the driver name provided in the data.
  - Information about the currently chosen TC and ABS settings is now available for *Automobilista 2*, if provided by the simulator (and available for the current car, of course).
  - The urgency of low fuel and low energy warnings of the Race Engineer has been reduced, if more than one lap can still be run on the remaining fuel/energy.
  - Information about the current setting of the brake balance is now available for most simulators.
    - The current setting will be available as "BB" series in many reports in all applications of Simulator Controller.
    - [Experts] This information is provided to the rule engine and is also available in *Lua* scripts, for example to automate changes of the brake balance.
  - It is now possible to display all known cars and all known tracks in the "Session Database" and not only the ones, that had been used so far. Use the extended [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#settings-1) to choose your preference.
  - [Experts] Additional meta data can now be supplied for cars in the [configuration files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#introducing-a-new-car). This meta data includes the *Steer Lock*, *Steer Ratio*, *Wheelbase* and *TrackWidth* of a given car and will be used in the "Setup Workbench" issue analyzer as default values. Alternatively, this information can also be provided in the [car definition file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#introducing-new-car-specifications) for the "Setup Workbench".
  - [Internal] Extended usage statistics with information about used speech technologies.
  - [Internal] Integrated latest *Lua* version 5.5, but not fully tested yet. You can activate it with a switch in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#script-settings) at your own risk.
  - New car models for "Setup Workbench":
    - Le Mans Ultimate
      - Ginetta G61-LT-P325 Evo
	  - Ligier JS P325 (fixed brake balance and some other settings)
	- Automobilista 2 (by @inthebagbud UK; no setup editor support)
	  - ARC Camaro, BMW M1 Procar, Caterham 620R
	  - Caterham Academy, Caterham Superlight, Caterham Supersport
	  - Chevrolet Opala Old Stock Race, Chevrolet Opala Stock Cars 1979, Chevrolet Opala Stock Cars 1986
	  - Copa Uno, Formula Classic Gen1 Model1, Formula Classic Gen1 Model2
	  - Formula Classic Gen2 Model1, Formula Classic Gen2 Model2, Formula Classic Gen2 Model3
	  - Formula Classic Gen3 Model1, Formula Classic Gen3 Model2, Formula Classic Gen3 Model3
	  - Formula Classic Gen3 Model4, Ginetta G40 Cup, Ginetta G40
	  - Ginetta G55 GT3, Ginetta G55 GT4 Supercup, Ginetta G55 GT4
	  - Ginetta G58 Gen2, Lamborghini Diablo SV-R, Ligier JS P217
	  - Ligier JS P320, Ligier JS P4, Ligier JS2 R
	  - Lotus Renault 98T, McLaren Honda MP44, McLaren Honda MP45B
	  - MCR S2000, MetalMoro AJR Gen2 Chevrolet, MetalMoro AJR Gen2 Honda
	  - MetalMoro AJR Gen2 Nissan, Mitsubishi Lancer R, Oreca 07
	  - Porsche 911 GT3 Cup 3.8, Porsche 911 GT3 Cup 4.0, Sigma P1 G5

## 6.7.8.0

#### Date: 01/09/26

#### Fixes

  - Fixed a bug for *iRacing*, which crashed the Spotter when cars are leaving and re-appearing later in a practice or qualifying session.
  - Fixed the preview of the current pitstop settings in "Team Center" for *Le Mans Ultimate*. The amount of fuel to be added will now adapt each lap to the amount of virtual energy to be added.

#### Changes

  - Some additional improvements for the dark mode, incl. improved coloring of the application icons to blend perfectly with the Windows task bar color.
  - The new application icon in the progress window got a little bit more spacing.
  - The activation listener for Assistant calling phrases like "Hi Jona" now supports also the machine translation step. The translator can be configured in the *Language* drop down menu on the general voice control configuration page in "Simulator Setup" and "Simulator Configuration".
  - The same translator is used for all speeches generated by parts of Simulator Controller that are not controlled by the Assistants, for example when generating pace notes based on track positions in a rally stage.
  - Thanks again to @inthebagbud UK, who compiled a complete file of all current track names for *Automobilista 2* this time.
  - Also many thanks to @rysimabd, who provided a full update of the Chinese translation files.
  - The strength of relative toe reduction / increase due to tyre temperatures has been reduced in "Setup Workbench".
  - New article for *News, tips and tricks* about the recently added automatic language translation.
  - [Experts] A new [module "Environment"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules#module-enviroment) has been defined for the *Lua* script engine, which supports global state handling.
  - [Experts] Two new controller action functions ["ask" and "command"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions#Assistant-interface) let you generate synthetical voice input by any external trigger, for example a press of a button on your Stream Deck. This allows you to use the Assistants without voice control for even the most exotic cases.
    - The same functionality is available in the "Interaction" topic in the *Lua* [script module "Assistants"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules#module-assistants).
    - Lastly, "Assistant.Command" has been added as predefined function/predicate in all rule sets and *Lua* enviromments that are executed in an Assistant process, for example in a *Reasoning* booster. (Note: "Assistant.Ask" was already available, but an additional optional parameter has been added.)
  - [Experts] The [integrated HTML engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#html-engine-settings) can now be configured individually for each application.
  - [Internal] Extensive preparation for running the charts engine offline without a network connection to Google. See the new [core setting "HTML" -> "Charts"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#html-engine-settings) for more information.
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-678), for information how to delete the Windows task bar icon cache and also how to activate the new track names for *Automobilista 2*. 

## 6.7.7.1

#### Date: 01/05/26

#### Fixes

  - Fixed an endless loop introduced with the last release, that crashed "Simulator Setup" while scanning the Steam library for new applications.
  
## 6.7.7.0

#### Date: 01/02/26

#### Fixes

  - None this time...

#### Changes

  - Message dialog boxes and input boxes now also use a dark theme, if activated.
  - Tool tips now also adapt to the chosen theme.
  - A new button in the top left corner of the "Simulator Startup" window opens the documentation for the keyboard modifiers.
  - The function of the Control key has been reverted when running the Assistant test mode from "Simulator Setup" and "Simulator Configuration". By default configured boosters and all translators (see below) are now active and can be disabled by holding down the Control key when clicking the "Play" button.
  - The speech processing pipeline now supports a translation process. Using this translator, which can be configured to use translation services by Azure, Google, DeepL and OpenAI compatible GPT service providers, it is possible to support any language, not only the builtin ones. The results are not perfect, but good enough. And the best, Azure, Google and DeepL all have a really huge free contingent.
  
    See [the updated quick start guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Quick-Start-Guide) for more information on how to setup a translator. Also read [this](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#Supported-languages-and-commands) and [this](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#activation-listener) part of the documentaion, to understand all the consequences of using translated languages.
  - More in-place editors are available on the *Plugins* tab when a Race Assistant plugin is selected in "Simulator Configuration". See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) for more information.
  - [Internal] Updated all copyright notes to 2026.

## 6.7.6.0

#### Date: 12/26/25

#### Fixes

  - Fixed an error, when reporting unknown car numbers given in voice commands.
  - The CSV importer has been fixed, when telemetry data for *iRacing* was imported. 
  - Several grammar files have been fixed where duplicate keys occluded some of the phrases.
  - Fixed a crash in "Solo Center" when a fixed tyre compound for the next stint was selected.
  - Fixed import of exported settings into the session database for "All" selections.

#### Changes

  - OpenAI compatible GPT service providers can now be referenced using theie base UDL. The extension "v1/chat/completions" is no longer required, but still supported for backward compatibility.
  - Missing TC and ABS settings are now reported as "n/a" in various applications and no longer as **0**.
  - Steam IDs are now used when starting a simulator and the startup process is handled by Steam. This is necessary, when additional software is started, for example an Anti-Cheat system. To use this new process, you have to re-generate yur configuration using "Simulator Setup".
  - "Simulator Setup" now provides context sensitive help on the *Basic* configuration page.
  - "Simulator Setup" no longer allows the *Basic* configuration page to be skipped during the first run.
  - [Imporant] The tyre compound mappings for *Automobilista 2* have completely overhauled by @inthebagbud UK to match the latest additions and revisions by the game. We tried to preserve all previously available mappings where possible, so that no recorded data will be inaccessible due to a new tyre compound name. But that was not possible in all cases, especially when car names have change as well.
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-676), if you have created your own tyre compound mappings for *Automobilista 2* in the past.

## 6.7.5.1

#### Date: 12/22/25

#### Fixes

  - Fixed a critical bug that prevented "Simulator Setup" to detect *Projct Motor Racing* correctly.
  
## 6.7.5.0

#### Date: 12/19/25

#### Fixes

  - The Spotter no longer raises errors when set to muted or silent in a [startup profile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles).
  - Fixed several errors in the grammars of the Spotter.
  - Temporary files created while importing into the "Session Database" are now removed correctly.
  - The low level Spotter process no longer crashes when cars join a session after the session has been started already.

#### Changes

  - When a call to a GPT service provider fails due to rate limiting, the system will retry the call several times with an exponentially increasing waiting time between the calls.
  - All windows are forced to have rounded corners when running on Windows 11.
  - With a great contribution of @Awesome-XV we added support for *Project Motor Racing*. However, the API provided by the game is far from being complete, so many restrictions apply. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#special-notes-for-project-motor-racing) for more information.
  - Generic handling issues have been added in the "Setup Workbench" for *Assetto Corsa EVO*. Still no telemetry support in the API.
  - New article for *News, tips and tricks* about coaching sessions.
  - [Internal] The logging of HTTP errors when calling GPT services has been extended.
  - [Developer] The API protocol for simulator integration has been extended. API connectors and providers can have additional protocol specific arguments, in the case of *Project Motor Racing* the UDP connection settings.

## 6.7.1.0

#### Date: 12/12/25

#### Fixes

  - None this time...

#### Changes

  - It is now possible to specifically activate/deactivate sections on the track map, that are used by the Driving Coach for the coaching sessions. This allows you to define sections for each corner, thereby having the correct corner numbers all the time, but only have those section active, for which you want to get instructions. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#track--automation) for more information.
  - [Experts] The documentation for all internal controller action functions, which can be used for scripting, defining your own voice commands, etc. have been rearranged for more clarity. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions) the new documentation for all these functions.

## 6.7.0.0

#### Date: 12/05/25

#### Fixes

  - Fixed the voice command reference sheet for Japanese.
  - Added some missing translations.
  - Fixed a condition that caused the telemetry data for the first lap to be incomplete, if the collection is started mid-lap.
  - Fixed a bug for *iRacing* which caused the last trigger of track automations to be ignored.
  - Fixed the "Time" channel in telemetry for invalid laps collected in *RaceRoom Racing Experience*.
  - Fixed "Distance" channel in telemetry for *RaceRoom Racing Experience*, which was a value between 0 and 1, but must be multiplied by track length.
  - Fixed invalid *MaxTokens* value in Drving Coach and Assistant Booster configurations.

#### Changes

  - The starting fuel capacity for the strategy simulation in "Setup Workbench" is now limited to teh fuel capacity of the car.
  - A very special tweak for *Le Mans Ultimate*: If you are running a team race with Simulator Controller in Solo mode, the Assistants will no longer inform about cars around and other stuff, if you are not driving.
  - The "Time" channel is now supported in *iRacing* telemetry collection.
  - Updated many voice commands for the Driving Coach in Japanese.
  - The label in a Button Box visual representation now shows starting coaching modes of the Driving Coach in light gray color.
  - The Driving Coach informs now more precisely about the start of the coaching.
  - The Driving Coach provides a new coaching mode that helps you to learn braking points and effective braking techniques. When this coaching mode is active, the Coach will tell you how to brake and also will tell you exactly where to brake and where to release the brake again. This coaching mode is based on telemetry data, therefore using a reference lap from a fast and experienced driver is the key for success.
    - See the [added documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#Practicing-braking-points) for more information about this new coching mode.
    - A [new voice command for the Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(EN)) lets you activate brake coaching.
	- New "Brake Coaching" function in the [startup profile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles), which automatically starts telemetry based coaching and brake coaching by the Driving Coach when this startup profile is active.
	- Brake coaching can also be started by choosing the corresponding item in the tray menu of the Simulator Controller process.
	- A new action "BrakeCoaching" has been defined for the Driving Coach plugin, which let you activate brake coaching using a button on your wheel, your Button Box or your Stream Deck.
	- A new icon in the Stream Deck icon set is provided for the new "BrakeCoaching" action.
	- A new controller action function ["startBrakeCoaching"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions) lets you start brake coaching from scripts, rules or any other programmatic source.
	- An optional *confirm* parameter has been added to the controller action functions "startTrackCoaching" and "startBrakeCoaching".
	- The existing controller action function ["startTelemetryCoaching"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions) has been extended to additionally support immediate start of the brake coaching mode.
	- Many new [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) in the "Session Database" gives you fine-grained control over the interpretation of braking zones by the Driving Coach.
	- All command reference sheets have been updated.

## 6.6.7.0

#### Date: 11/28/25

#### Fixes

  - Fixed a crash in the MoTec telemetry importer, if the "Distance" field is *not* included.
  - Fixed a bug for *Assetto Corsa*, which caused the Spotter to give information about disconnected cars.

#### Changes

  - Using "Hello instead of "Hey" is now supported in Assistant activation phrases in English.
  - Using "Hallo" instead of "Hi" is now supported in Assistant activation phrases in German.
  - It is now possible to define global default choices for community sharing in the settings of the "Session Database" for the different object types. This value is used whenever a new object (a strategy, for example) is created in the session database. If this default is not set, the corresponding choice from the consent will be used as default sharing setting.
  - A generic CSV importer has been added to the "Session Database". It allow you to import telemetry data from any location. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#importing-telemetry-data) from more information.

## 6.6.6.0

#### Date: 11/21/25

#### Fixes

  - Fixed a bug in the Handling Analyzer of the "Setup WOrkbench", that prevented issues to be collected if the acoustic feedback for over-/understeer was enabled at the same time.
  - Fixed the continuous update of the refuel amount for a planned pitstop in all apps for *Le Mans Ultimate*.
  - Fixed a bug, that caused the Google API for voice configuration to be lost when a configuration created by "Simulator Setup" or "Simulator Configuration" was opened next time.
  - *iRacing* now reports the distance into the track as **-1** for cars, that are standing at the pit or have left the session. This caused some miscalculations, that have been fixed.
  - Fixed the display of lap times in race reports for sessions with just one lap. A rare case, of course, but can happen in hill climbs or Rallye stages, for example.

#### Changes

  - Rearranged the order of data acquisition from the different Race Assistants for display in "System Monitor" and/or the Integration plugin. This will result in more accuracy in those cases, when one Assistant, for example the Engineer, has more detailed knowledge about a given topic than the other Assistants.
  - [Internal] More restructuring of the Driving Coach internals for the upcoming anniversary release.
  - New car models for "Setup Workbench" (by @neophyte):
    - Assetto Corsa
	  - Porsche 911 GT3 Cup 2017
      - ACF GT3 - BMW M4 GT3 2021 (as part of the DLC for modded cars)

## 6.6.5.0

#### Date: 11/14/25 (planned)

#### Fixes

  - Fixed a critical bug introduced with the last release, which prevented proper configuration of Azure speech synthesis.
  - Fixed a critical bug **not fixed** with the last release 6.6.4 (actually, fix code was removed accidently in the final merge process), which prevented the *Reasoning* booster to work in non-English configurations.
  - Reduced probability of premature session end in timed races for *Assetto Corsa*.
  - Fixed a couple translations in the "Setup Workbench".

#### Changes

  - Very important messages by the Assistants will now be repeated until completed, when interrupted by urgent shout outs of the Spotter. For *normal* messages, this is only attempted five times.
  - The threshold between greasy and damp track conditions has been tweaked for *Le Mans Ultimate* and *rFactor 2*. This will result in more precise tyre change information (see next topic).
  - The tyre compound recommendation rule set based upon weather information has been extended by a component which takes the track grip into account. These rules are used by the Strategist and the Engineer, when preparing a pitstop and when to call you to the pit. All this results in almost perfect pitstop timing.
  - The Engineer now calls you to the pit after a pitstop has been planned for a tyre change to handle an upcoming weather change, and the grip has become too worse to continue the race on the current tyre compound. See the [added documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#performing-a-pitstop) for more information.
  - A [new event and a new action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-engineer) have been defined for the *Reasoning* booster of the Race Engineer. The event "Grip Low" is triggered, when a pitstop has been planned for tyre compound change and it is now time to carry out the tyre change. The corresponding action "Low Grip Reporting" will inform the driver that it is time to change the tyres and will tell the pit crew to prepare the pitstop.
  - The Spotter now informs about the current track grip additionally to the current and upcoming weather at the start of a session.
  - Sounds used by the acoustic feedback of the issue analyzer in the "Setup Workbench" can now be customized.
  - Increased the number of corners, that the Coach can handle during on-track coaching from 30 to 128.
  - [Developer] Foreign function calls in the rule engine can also be written like *:function(a1, a2, ...)* rather than *call(function, a1, a2, ...)*.
  - [Internal] Refactored the simulator provider processes for the Spotter and the Coach.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-665), if you have configured a *Reasoning* booster for the Race Engineer.

## 6.6.4.0

#### Date: 11/07/25

#### Fixes

  - Fixed header color in Consistency reports when using the dark UI mode.
  - Fixed export and import of sessions in the "Session Database".
  - Fixed export and import of car/track specific settings in the "Session Database".
  - Fixed several minor bugs in the speech synthesizer.
  - Fixed a bug in the *Reasoning* booster when a language other than English is used and a booster action tries to interact with the user by voice.

#### Changes

  - Reduced the frequency of multiclass specific warnings in multiclass races to give other information shout outs a chance.
  - Changed the file format of settings and data export in the "Session Database" for better handling.
    - The team manager package supports the new file formats, but the old *directory* package type is still supported for backward compatibility.
  - A re-sync button has been added to the zoomable track map editor introduced with the last release, which can be used in rare cases, when zooming and scrolling get out of sync.
  - Changes to the audio post processing settings will be reflected live, when using the speech output test mode.
  - A new speech synthesizer as well as a new voice recognition engine has been added, which can work with all OpenAI compatible speech APIs. This allows also for local neural network based speech generation and recognition, when using [Speaches.ai](https://speaches.ai), for example. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#openai-api) for more information.
  - [Internal] Refactored all LLM instructions into a separate *Instructions* folder.
  
## 6.6.3.0

#### Date: 10/31/25

#### Fixes

  - *Fixed* sporadic initialization problems with the "Windows (Server)" speech recognition by implementing a retry mechanism.
  - Non-active cars, which are part of the entry list, but are virtually in the garage, are now ignored by the Race Spotter for *Le Mans Ultimate*.
  - Fixed the handling of the ACC UDP configuration file ("broadcasting.json") after the latest updates by *SimHub* and *Assetto Corsa Competizione* itself.
  - Triggered a redraw of the complete window of "Solo Center" on tab changes to work around the redraw problems of the data lists in the fourth tab.
  - Potentially fixed premature end of the session in team races in *Le Mans Ultimate* when jumping back to the "Standings" screen after watching a replay.
  - Fixed many corrupted entries in the session database, where the byte order mark in UTF-16 files was interpreted as a valid part of the first field of the first entry.
  - Added some missing translations.
  
#### Changes

  - Increased default max memory limit for all applications from 1024 MB to 2048 MB to allow for complex data situations, for example, browsing telemetry data for the *Nordschleife*.
  - The track map window in the Telemetry Viewer now supports zooming in and out of the track map, which is very helpful for tracks like the Nordschleife.
    - The zoom factor can be controlled by entering a zoom factor between 100% and 400% and it can be cntrolled by turning the mouse wheel.
	- The track map can be moved by holding down the middle mouse button.
  - It is now possible to open the track map in "Session Database" in an external, zoomable window, when editing tack sections.
  - [Developer] Added support for scrollable windows in GUI base library.
  
## 6.6.2.0

#### Date: 10/24/25

#### Fixes

  - The detection of a Steam installation of *Rennsport* is now detected correctly by "Simulator Setup".
  - The latest update of *RaceRoom Racing Experience* prevented the detection of the game executable by "Simulator Setup". This has been fixed.
  - Also, the internal data acquisition of the Spotter has been broken by the latest update of *RaceRoom Racing Experience*. This has been fixed as well and the Spotter is working again.
  
#### Changes

  - The layout of the [settings dialog of "Simulator Startup"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings) has been changed a bit, so that the audio routing settings are more easily accessible.
  - The Spotter announcements for cars in other classes have been reworked, so that irrelevant information is no longer given.
  - Additional warnings for multiclass events have been implemented for the Spotter. For example, the Spotter will tell you now, that two GT3s are in a position fight, if you come up from behind in your Hypercar.
    - Two new settings ["Spotter: Forward traffic observation" and "Spotter: Rearward traffic observation"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) in the "Session Database" let you specify the part of the track relative to your lap time, where the Spooter looks for traffic of faster or slower cars of other classes. Default for both settings is 6 seconds. 
    - Important: To make the most out of this new information shout outs, check the ["Data: Update Frequency"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) in the "Session Database" and set it to the lowest possible value, which can be handled by your sytem. Something like 2 seconds will be possible for most current Gaming PCs.
  - More non-critical shout outs of the Spotter will now be processed by the *Rephrasing* booster, if configured.
  - The concurrency handling of the different types of Spotter shout outs has been optimized.
  - Changed the behavior of the "Configuration..." button in the settings editor of "Simulator Startup". It will now open "Simulator Setup" by default or "Simulator Configuration", if the Control key is pressed.
  - [Internal] Added an auto correction for the Azure Speech services endpoint, so that it is no longer necessary to add "/sts/v1.0/issuetoken" to the official endpoint.
  
## 6.6.1.0

#### Date: 10/17/25

#### Fixes

  - Fixed standings in the LLM knowledge of the Race Strategist after the first car pitted.
  - Fixed Google voice recognition for French language.
  - Another fix for the ACC UDP configuration.
  - Fixed the pitstop history in team races. This bug caused the calculation of driven laps for a given tyre to be wrong in team races und control of the Team Server.
  - Fixed a rare bug which prevented a driver change in team races in *Le Mans Ultimate*.
  - The Spotter no longer announces the race length in *Assetto Corsa*. This is a *fix*, cause *Assetto Corsa* does not report the session format (Time vs. Laps) correctly.
  
#### Changes

  - Thanks to a contribution by @neophyte many cars in *Assetto Corsa* now provide information about their car classes in the meta data.
    - The cars in the DLC for modded cars of *Assetto Corsa* has also been updated to include class information. Take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-661) for information, how to include the updated information into your database.
  - Additonally many more car names have been added to the car meta data file for *Assetto Corsa* by @neophyte.
  - The Spotter no longer gives you information about pitstops of cars in other classes.
  - The LLM knowledge of the Race Strategist about the state of the tyres has been extended.
  - Thanks to some additions in the *Le Mans Ultimate* API, car numbers are now displayed correctly in almost all session categories.
  - Race rules are now included in the LLM knowledge of the Race Engineer and the Race Strategist, when running a session under strategy control.
  - Using audio routing it is now possible to control the sound volume of all audio ouput depending on the different audio configurations. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) for more information.
  - [Important] Removed all automatic update procedures before version 6.0. Updates from versions older than this are not supported anymore.
  - [Experts] The new controller action functions [*raiseEvent* and *triggerAction*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions) let you raise events and trigger actions in the *Reasoning* booster of any Assistant using your Stream Deck, Button Box or any other hardware controller.
  - [Experts] A new action type "Action" is supplid in the track automation. This allows you to trigger any [controller action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Action-Functions) depending on the current position on the track. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-automation) for more information.
  - [Experts] A new *Lua* [script module "Assistants"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules#module-assistants) let you raise events or trigger actions in the *Reasoning* booster of an Assistant from scripts which are *executed* from a controller action function or have been triggered by an active track automation.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-661), if you are using the DLC for modded cars in *Assetto Corsa*.

## 6.6.0.0

#### Date: 10/10/25

#### Fixes

  - Fixed some additional problems for team races in *Le Mans Ultimate*.
  - Fixed many DPI scaling issues when using different scaling factors for different monitors.
  - Fixed a bug causing the Push-To-Talk method "Press & Talk" to not work properly when speech interruption was enabled at the same time.
  - Added some missing translations.
  - Fixed a bug in the wear- or lap-based tyre change decision by the Engineer introduced with the last rrelease, which prevented a change in compound, for example from dry to wet tyres, if the wear was good on the old tyres.
  
#### Changes

  - Car numbers should now be displayed correctly in team races for *Le Mans Ultimate*.
  - Integrated team names in data for *Asseto Corsa Competizione* and *Le Mans Ultimate*. However, no display in the UI yet.
  - The Engineer now announces a tyre change incl. compound and color.
  - The calculation of lap count of used tyre sets as shown in the list on the first page of "Solo Center" has been optimized for simulators where no tyre set information is available or when single tyres have been chenged at the last pitstop.
  - The number of usable laps per tyre compound is now included in the knowledge for the LLM for the Race Engineer and the Race Strategist. Either the active strategy or the active race rules from "Race Settings" are used. If these are not activated, the value of the [setting "Pitstop: Tyre Compound Usage"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) from the "Session Database" is used.
  - The Race Strategist now tries several times to create a strategy based on active race rules as configured in "Race Settings" before giving up in lap 10.
  - The value of the stint timer is now included in the LLM knowledge for the Race Strategist.
  - The *Reasoning* booster for the Race Strategist supports a new [event for strategy simulation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-strategist). Together with the also new counterpart action "Strategy Update", this event, if enabled, will route the request to simulate a strategy and possibly updating the existing strategy to the LLM together with all available data about the session and car state, as well as a complete description of the currently active strategy. The LLM, acting as a LAM (aka large action model) in this case, may come up with a better strategy than the internal rule engine. But please note, that strategy simulation is the most thinkable complex reasoning task and running a strategy simulation therefore requires a very capable reasoning model like GPT-5 or Claude Sonnet 4.5. And even with these models, the request fails in some cases.
  - The ELMS LMP2 car is now identified as "Oreca 07 ELMS" to distinguish it from the normal "Oreca 07" car in *Le Mans Ultimate*. If you already have recorded some data with this splendid fast car, take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-660).
  - The editor for Controller Automation is now resizeable.
  - The editor for LLM instructions is now resizeable.
  - When using the Push-To-Talk mode "Press & Talk", two different silent sounds will signal start of listening and end of listening. The corresponding sound files are located in *Resources\Sounds* in the installation folder and are named "Talk On.wav" and "Talk Off.wav".
  - If a LLM is called when processing a *Conversation* booster or *Reasoning* booster, two silent sounds will signal the start and the end of the LLM processing. Especially when using the *higher* LAM events and actions introduced in the last and in this release, which can take some time to process, this is very helpful. The sounds are now called "Conversation Begin.wav", "Conversation End.wav", "Reasoning Begin.wav" and "Reasoning End.wav". As always, you can replace those sounds with your own ones and even mute them altogether.
  - It is now possible to configure multiple different audio routes depending on the currently running simulator and/or the current session type (race, qualifying and so on). See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) for more information.
  - Additionally, a *null* audio device is now supported in the audio routings, which effectively mutes the given sound category.
  - When choosing a tyre compound on a specific wheel for the next pitstop in "Team Center", holding down the [Control key](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) will choose the same compound on the other wheels as well.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-660), if you already have driven the faster Oreca 07 in the ELMS series and you want to remove the wrong data from the Oreca 07 data set.

## 6.5.6.1

#### Date: 10/03/25

#### Fixes

  - Fixed a critical bug in the session state handling of the Race Engineer.

## 6.5.6.0

#### Date: 10/03/25

#### Fixes

  - Fixed brake duct handling in "Setup Workbench" for all cars in *Le Mans Ultimate* and *rFactor 2*.
  - Fixed a bug, that caused data used by the Driving Coach to be translated to the language chosen for the UI and not for the language configured for the Coach.
  
#### Changes

  - The Race Engineer can now handled partial tyre changes based on tyre wear or based on the number of laps already driven for this tyre.
    - A new setting "Change Tyres" has been added to "Race Settings".
	- The same [setting "Pitstop: Change Tyres"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) is available in the "Session Database", of course.
    - Please read the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#how-it-works) (item 2.) for more information.
	- The current implementation is solely based on tyre wear or driven laps and will be extended using a machine learning model to be more intelligent in the next releases.
  - Extensive internal preparations for GPT-based strategy planning. A first usable version will be released next week with version 6.5.7.
  - Updated car meta data for *RaceRoom Racing Experience* to the latest version.

## 6.5.5.0

#### Date: 09/26/25

#### Fixes

  - Fixed a couple of missing translations.
  - Fixed several unnecessary language specific LLM instructions cluttering the main configuration file, which could have slowed things down a bit. See the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-655) for information, how to fix this in your configuration.
  - Fixed a layout error in "Session Database" in the *Track & Automation* tab introduced with the last release.
  - Fixed several rare bugs which prevented knowledge to be passed to a LLM by the Race Strategist.
  - Fixed the default Service URL for OpenRouter.
  
#### Changes

  - Integrated the latest version of the API for *RaceRoom Racing Experience*, which was released on 24th September.
    - This version of the API now exports information about the current state and selections of the Pitstop MFD. Therefore the image recognition method has been disabled and the small search images are no longer needed. If you still want to use the image recognition method for whatever reason, use the new setting ["Pitstop: Image Search"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) in the "Session Database" for *RaceRoom Racing Experience*.
	- Information about the remaining virtual energy is supported for all applications when running a hypercar.
  - Thanks to a contribution of @EightOfFour, time based races are now supported from *Assetto Corsa*.
  - A new [event for pitstop planning](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-engineer) has been defined for the Race Engineer for the *Reasoning* booster. This event, if enabled, will route the request to plan an upcoming pitstop to the LLM together with all available data about the session and car state. The LLM, acting as a LAM (aka large action model) in this case, may come up with a better pitstop plan, especially for tyre changes, than the internal rule engine. But this depends on the capabilities of the configured LLM, so be careful and enable this event at your own risk. Make sure to use a high end thinking model for the *Reasoning* booster, if you want to give this a try.
    - Please note, that this approach will not be used in all cases, for example, if the request was created remotely in the "Team Center".
    - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) let you inspect and modify the internal instructions for the Race Engineer, when holding down the Control key while clicking on the "Instructions..." button of the *Reasoning* booster.
  - The *Reasoning* booster for the Race Strategist supports a new [event for pitstop recommendation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-strategist). Together with the also new counterpart action "Pitstop Recommend", this event, if enabled, will route the request to recommend the lap for an upcoming pitstop to the LLM together with all available data about the session and car state. The LLM, acting as a LAM (aka large action model) in this case, may come up with a better lap for a pitstop with regards to undercut or overcut chances than the internal rule engine. But this depends on the capabilities of the configured LLM, so be careful and enable this event at your own risk. Make sure to use a high end thinking model for the *Reasoning* booster, if you want to give this a try.
    - A new [keyboard modifier](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) let you inspect and modify the internal instructions for the Race Engineer, when holding down the Control key while clicking on the "Instructions..." button of the *Reasoning* booster.
  - OpenAIs new high end model family *GPT 5* is now supported. *GPT 5* is the perfect candidate for the new LAM-based pitstop planning method mentioned above. From now on, I recommend *GPT 5 mini* as the best model in terms of price / performance ratio when you are using OpenAI. *GPT 5 mini* even masters the pitstop planning mentioned above quite well, but the precision of *GPT 5* is much better, of course.
  - [Experts] A new [core setting "GPT" -> "ExplainReasoning"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#development-settings) asks a connected LLM to provide an explanation of its thoughts and conclusions, whenever an action in the *Conversation* and/or *Reasoning* booster is invoked. Whether the LLM will indeed provide an explanation depends on its capabilities. The explanation will be written to the transcript in the *Logs* directory.
  - [Experts] A new [core setting "Rules" -> "TraceLevel"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#development-settings) let you enable special trace output for the integrated rule engine, that will be written to the standard log file.
  - New and updated car models for "Setup Workbench":
    - Le Mans Ultimate
      - Ligier JS P325
      - Oreca 07 (added front and rear heave travel settings)
      - All hypercars (added differential coast and differential power settings)

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-655), if you want to get rid of all potential unnecessary instructions in the main configuration file.

## 6.5.4.0

#### Date: 09/19/25

#### Fixes

  - Fixed a critical bug introduced with the last release, when the Spotter wants to reference an opponent car by the name of the driver.
  - Fixed internal car class descriptor for the active driver.
  - Fixed calculation of driven laps per tyre in some rare cases in team races.
  
#### Changes

  - Introduced more speech variations for the Spotter shout outs which are cached for performance reasons.
  - Completely rewritten the handling of track names and track layouts for *Assetto Corsa*. Track names and layouts are now much more human readable. The current "Track Data.ini" file in the *Simulator Controller\Simulator Data\AC* which is located in your user *Documents* folder has been renamed as a backup in case you have edited or extended it already.
  - When a strategy has been defined or if race rules has been actived in the "Race Settings", the number of typical usable laps of a tyre compound will be available in the knowledge passed to a LLM for the Race Strategist.
  - [Important] It is now possible to select the session mode (either *Solo* or *Team*) as a discriminator for settings in the "Session Database". For example, if you want that the Engineer do **not** handle tyres in pitstop preparation in *Solo* races, but tyres should be managed by instructions given by the "Team Center" of course in *Team* races, this discriminator is your friend. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#settings) for more information.
  - [Experts] The Pitstop Planning action for the *Conversation* and *Reasoning* booster of the Engineer has been changed in preparation of the LAM integration. Individual tyre compounds for each wheel are now supported.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-654), if you have edited the "Track Data.ini" file for *Assetto Corsa*.

## 6.5.3.0

#### Date: 09/12/25

#### Fixes

  - LLM instructions for the Driving Coach will not be used anymore, if the corresponding data is not available at that exact moment.
  - Fixed a bug, which prevented the pitstop history to be passed to a LLM in the *Conversation* and *Reasoning* boosters.
  - Fixed another bug in the knowledge passed to a LLM in the *Conversation* and *Reasoning* boosters, where brake wear was confused with brake temperatures.
  - Fixed several rounding errors in the knowledge passed to a LLM in the *Conversation* and in the *Reasoning* booster.
  - Fixed a bug in the *Reasoning* booster, which prevented loading of instructions in a rare situation.
  - Fixed a bug, which caused modified LLM instructions to get lost when a GPT Provider is changed for an Assistant booster.
  - Fixed a bug for *iRacing*, which caused wrong positions to be calculated and reported for all cars in some situations.
  - Fixed a bug for *iRacing*, which prevented pitstop reporting for oppenent cars in some situations.
  - Fixed handling of brake duct blanking in the "Setup Workbench" for *Le Mans Ultimate*, where the duct blanking was changed in the wrong direction.
  - Fixed several minor bugs for team races with driver swap for *Le Mans Ultimate*. A problem with a premature end of the Simulator Controller session for the driver who leaves the car remains, but this causes no problem for the team session itself.
  - Fixed a critical bug, which caused non-processed pitstop settings in *Le Mans Ultimate*, if a UI language was chosen, which was not English.
  
#### Changes

  - [Important] The collection of telemetry data can now be enabled in the "Solo Center" without having the Telemetry Viewer open. Additionally, the Telemetry Viewer will no longer be opened by the *Auto Telemetry* setting. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#Telemetry-Viewer) for more information.
  - A new [setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) in the "Session Database" instructs the Coach during on-track coaching to automatically write the telemetry of the fastest lap of the current session to the session database, if that lap was faster as any lap already stored in the database.
  - A lot of optimizations and enhancements for the Spotter:
    - Driver names are now sometimes mentioned in information shout outs by the Strategist and the Spotter. For example, if you ask for the gap to the car ahead, you may occasionally also be told the name of the driver, who is actually driving the car ahead.
    - Also, the Spotter may mention the name of the driver who caused an accident.
    - The processing of many Spotter shout outs has been optimized, so that they come more in line with the actual situation on the track. The price for this is, that a configured *Rephrasing* booster is not used in those cases.
    - The Spotter no longer tells you about a car directly behind you, which you actually have just overtaken.
    - Lastly, the Spotter can now interrupt itself more often, if something urgent needs to be communicated to the driver.
	- {Experts] A couple of updates to the *Conversation* and *Reasoning* booster events:
	  - All events for the *Conversation* and *Reasoning* booster are now fired even if the corresponding voice alert is disabled.
	  - The "OpponentPitting" event in the *Reasoning* booster is now also signalled for *focused* opponents.
	  - A new [event "Focus Gap Update"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) has been defined for the *Reasoning* booster of the Race Spotter, which is signalled, whenever the gap to the currently focused car has changed for a given amount.
  - The Strategist also refers to other cars by the name of the driver from time to time, when asked for gaps, positions, lap times and so on.
  - The tyre compound in the pitstop settings is now initialized from the strategy, if available, in the "Team Center", when using the command "Initialize from Session".
  - The number of driven laps for each tyre are now displayed on the *Session* tab in the "System Monitor".
    - This information is also passed to a LLM in the *Conversation* and *Reasoning* booster of the Race Engineer.
    - [Developer] Also, the number of driven laps for each tyre are available in the ["Session State.json"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) file.
  - The handling of the Assistant cool down phase has been optimized. You can now hold down Ctrl and LeftShift anytime to interrupt the cool down phase, even if the new session already has been started.
  - The session state management for *Le Mans Ultimate* has been updated to be more in line with the behavior of all other simulators. For example, if a session is restarted before the first lap has been completed, the Assistants will stay active.
  - Updated car meta data for *RaceRoom Racing Experience* to the latest version.
  - [Developer] New [keyboard modifiers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) for "Simulator Tools" to control aspects of the build process.

## 6.5.2.0

#### Date: 08/22/25

#### Fixes

  - The booster buttons on the "Basic" setup page in "Simulator Setup" are now disabled as well, when the corresponding Assistant has been disabled.
  - Fixed a few bugs, which caused "Simulator Setup" to freeze when invalid values had been entered in the configuration page of the Driving Coach.
  - Fixed a bug, which caused the Strategist to not consider pitstop service times during strategy simulation. This caused wrong predictions for position and ahead traffic after a pitstop in some situations.
  - Fixed a bug introduced with the last release, which caused the track name to always be the base layout name in *Le Mans Ultimate*. This problem was introduced due to an API change in *Le Mans Ultimate*. Unfortunately this caused some data to be collected for the wrong track layout. See the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-652) for information, how to fix this.
  - Fixed a bug in the configuration apps, which caused the window to freeze, when an Assistant Booster Editor was closed by the close control of the window, but the currently selected script had a syntax error.
  
#### Changes

  - The Strategist and/or the Engineer no longer recommend a tyre change due to weather at the end of the race. To be precise, they use the [setting "Final laps without service"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) from the "Session Database" to determine, if a tyre change should be scheduled.
  - When using a simulator which does not support tyre sets (which are almost all except *Assetto Corsa Competizione*), "Solo Center" no longer automatically creates a new entry in the list of used tyre sets. You can still create tyre set changes manually during practice for documentation purposes, but in a race session all tyre laps will be *booked* on the initial tyre set as long as the compound of the front left tyre is unchanged. The number of driven laps for each mounted tyre will still be computed based on known tyre changes, for example during a pitstop.
  - Again several new articles for the tips & tricks.
  - [Important] LLM Instructions can now be defined individually for each Assistant. Your current changes will be preserved and active until you change the Instructions next time. In this case, you have to incorporate your changes individually for each Assistant.
  - [Important] A new version of the local LLM Runtime is available. If you are using the local runtime, please follow the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-652).

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-652), if you are using the local LLM Runtime or if you need to fix some data, which had been collected for the wrond track layout.

## 6.5.1.1

#### Date: 08/19/25

#### Fixes

  - Fixed a critical performance issue in the API for Le Mans Ultimate after the latest game patch.
  
## 6.5.1.0

#### Date: 08/15/25

#### Fixes

  - Fixed handling of "。", "，" and other full-width punctuation characters in spoken commands for Chinese and Japanese when a neural network based voice recognition like Azure is used, so that the Sorenson-Dice matchmaking algorithm is happy.
  
#### Changes

  - Reduced the OS priority of various background processes, so that the running simulator gets a few more CPU cycles.
  - Reduced startup stutter in *Le Mans Ultimate* a bit more.
  - "Overview" reports are now sortable on position, even if DNF'ed cars are present.
  - "Solo Center" has a new *Auto Telemetry* setting, which automatically opens the Telemetry Viewer (thereby start collecting telemetry), when a new session is started. But make sure, that the automatic opening of the Telemetry Viewer window does not interfere with the operation of the active simulator.
  - Splitting long speeches into individual sentences is now supported for Chinese and Japanese. Only the last sentence will then be repeated, if the speech is interrupted by the Spotter.
  - The controller action function "selectTrackAutomation" can be called multiple times without side effects. This allows you to create an action in the *Reasoning* booster to automatically switch between track automations depending on weather conditions and track grip.
  - Added a new setting "Whisper.Compute Type" to the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#voice-settings). This setting must be set to *float16*, if you want to use Whisper on an RTX 50xx GPU. If you are running a "Whisper Server", please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-651), because the server needs an update.
  - Added two new articles to the tips & tricks this time.
  - [Experts] The [core setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#voice-settings) "Sample Frequency" has been renamed to "ElevenLabs.Sample Frequency". The old name is still supported, but deprecated.
  - [Experts] The process watchdogs can now be configured in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#system-settings).

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-651), if you are using the "Whisper Server" to run Whisper on a second PC.

## 6.5.0.0

#### Date: 08/08/25

#### Fixes

  - Fixed the calculation of driven laps for individual tyres when running team races under control of the "Team Center".
  - Fixed detection of the active driver for *Le Mans Ultimate*.
  - Fixed a bug, that caused the *Lap Times* report to be empty when switching from the *Positions* report with the car class being restricted. Affected "Race Reports", "Solo Center" and "Team Center".
  - Fixed minor problems with Japanese speech generation.
  - Fixed a couple translations for Japanese.
  
#### Changes

  - Full support for team races in *Le Mans Ultimate* under control of the "Team Center".
  - Full support for ElevenLabs Speech API.
    - Use the famous voices from ElevenLabs, where you can create your own voices easily from a couple of samples. So, if you want the Race Spotter to talk with your favorite Crew Chief voice, then give at a go. All voices being marked as "personal", "default" or "workspace" are available in the standard configuration, but with an additional step any voice from the community can be used.
	- ElevenLabs services for speech recognition is also supported.
	
    See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#ElevenLabs) for more information.
  - It is now possible to select the cars to be shown in the *Positions* report in "Race Reports", "Solo Center" and "Team Center".
  - The icons in "Simulator Startup" has been arranged a bit to reflect the typical workflow better.
  - [Internal] (Once again) optimized startup process for *Le Mans Ultimate*.
  - [Internal] Optimized the startup sequence of the "Simulator Controller" background process and all its decendendants, safing a few seconds.

***

[Release Notes Archive](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes-Archive)