## 3.2.0-release 07/09/21 (planned)

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New fully integrated telemetry provider for *Automobilista 2*, incl. support for Jona and Cato.
  4. [New "Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-4) for the "AMS2" plugin to control the pitstop settings from your hardware controller.
  4. New [controller action "execute"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) can integrate and control each Windows application from your hardware controller.

## 3.1.6-release 07/02/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Initial support for *Automobilista 2*.
  4. Recommendation for best pitstop lap in relation to traffic density and position development (see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#a-typical-dialog) for an example on how to use this feature).
  5. Handover between virtual strategist and engineer during pitstop planning (part of the above example).
  6. [New options](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the settings dialog for the Virtual Race Strategist.

## 3.1.5-release 06/25/21

  1. Bugfix for several Setup Database issues.

## 3.1.4-release 06/25/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New Assetto Corsa Competizione data acquisition for Cato, the Virtual Race Strategist.
  4. Full propabilistic model for future race positions. You can ask Cato for future race standings (Example: "What will be my position in 4 laps").
  5. New settings for the Virtual Race Strategist in order to customize the standings prediction model. See the ["Strategy" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the "Race Settings" tool for more information.
  6. Renaming of several applications:
     - "Race Engineer Settings" => "Race Settings"
	 - "Race Engineer Setups" => "Setup Database"
  7. Renamed "Race Engineer.settings" => "Race.settings"
  8. The "Race Strategist" plugin now supports plugin parameters ("raceStrategistOpenSettings", "raceStrategistOpenSetups") to open the settings dialog and the setup database query tool similar to the plugin parameters of the "Race Engineer" plugin. Please see the [plugin documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for more information.
  9. [VERY IMPORTANT]: This release introduces an extended *Push To Talk*, which will be active, when multiple *dialog partners* are active. Please read the [revised voice commands documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information.

## 3.1.2-release 06/18/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Multiple actions can be bound to one controller functions. Useful, to group several activation actions into one toggle switch for example. Please consult the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) for more details, if you want to use this new feature.
  4. The [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist) for the Virtual Race Strategist has been extendend - give it a read...
  4. Model and initial rule set for race standings, lap time analysis and gaps between cars have been implemented for Cato, the Virtual Race Strategist.
  5. New iRacing data acquisition for Cato, the Virtual Race Strategist.
  6. New rFactor 2 data acquisition for Cato, the Virtual Race Strategist.
  7. New  RaceRoom Racing Experience data acquisition for Cato, the Virtual Race Strategist.
  8. [For Developers]:
     - Refactored *RaceEngineerSimulatorPlugin* into *RaceAssistantSimulatorPlugin*, which now can handle multiple race assistants.
	 - Refactord the *getAction* and *fireAction* methods of *SimulatorController* into *getActions* and *fireActions* for multiple actions per controller function.

## 3.1.0-release 06/11/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full rework of voice generation and recognition to allow for multiple voices even using different languages (see the [new documentation for voice control](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information)
  4. New plugin parameter *raceEngineerLanguage* for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) to overwrite the default language for the Virtual Race Engineer (same applies for the new Virtual Race Strategist)
  5. Initial integration of the new AI-based [Virtual Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist). No useful initial functionality, but you can ask for weather information and remaining laps based on fuel or stint time calculation.
  6. [New Plugin "Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) to control the new Virtual Race Strategist
  7. [New Tab in the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) for the new Virtual Race Strategist

## 3.0.6-release 05/28/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. A [new page in the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) allows you to customize many aspects of the Race Engineer behaviour and the integration of Jona with the setup database.
  4. The *Race Engineer Settings* tool has been overhauled, since some of the options has been moved to the configuration page of the configuration tool, as mentioned above. The [*Race Engineer Settings* tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) now only contains session or race specific options.
  5. Race Engineer Settings can now be stored also in the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) for future use.
  6. Before beginning a session, the best matching of the Race Engineer Settings can be selected from the setup database depending on the session duration. This settings will be activated for the next session, optionally together with the tyre pressures for the current environmaental conditions.

## 3.0.4-release 05/23/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full rework of fuel consumption projection after a pitstop.
  4. Simulator car setup files can be stored together with additional notes in the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) for future use.
  5. The setup database consent has been extended to give [separate consents](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database) for tyre pressures and car setup information.
  
## 3.0.3-release 05/16/21

  1. Critical bugfix for remaining fuel caluclation after a pitstop in races longer than an hour
  
## 3.0.2-release 05/14/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Tyre pressures can be [transfered from the setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) to the *Race Engineer Settings* tool.
  4. Jona can consult the setup database for a second opinion for tyre pressures.
  5. [New switches](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-pitstop) in *Race Engineer Settings* to control the different strategies that Jona uses to come up with target tyre pressures.
  6. Refactoring of the setup database code and some file relocations.
  7. New Unit Tests for the setup database.

## 3.0.0-release 05/07/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Graphical interface for querying the setup database (see the updated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database) for more information)
  4. [New plugin parameter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin to open the setup database query tool. If a simulation is currently running, most of the query arguments will already be prefilled.

## 2.8.6-release 04/30/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Low level integration of *iRacing* telemetry information (see [IRC SHM Reader](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Foreign/IRC%20SHM%20Reader/IRC%20SHM%20Reader))
  4. Renaming of selected shared memory data fields
  5. ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-1) for *iRacing* plugin
  6. [Jona integration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer) incl. pitstop handling for *iRacing*
  7. Two new actions "Accept" and "Reject" have been added to the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), which are aquivalent to the corrsponding voice commands. This will be helpful, if you want to use Jona without voice recognition support.

## 2.8.5-release 04/23/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Jona can decide to leave the current tyres on the car at a late pitstop (aka splash and dash). You can also instruct Jona to not change tyres at the next pitstop with a phrase like this: "Can we leave the tyres on the car?"
  4. Jona intelligently reports and handles damage late in a stint.
  5. New plugin modes for pitstop control for the plugins for [*rFactor 2*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-6) and [*RaceRoom Racing Experience*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-7) allow you to dial most of the pitstop settings from your controller hardware.
  6. Jona now can handle the pitstop setup for you in the *RaceRoom Racing Experience* simulation. The support is quite limited: Jona can set the amount of fuel to add, and toggle the tyre change and the different repair options for the upcoming pitstop.
  7. (Developer Only): Once again a lot of refactoring in the [simulator plugin implementation classes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#simulator-plugin-implementation-classes) and the various simulator plugins. The "Pitstop" mode implementation class and the various pitstop action classes has been moved to the above library.
  8. Initial support for iRacing by a skeleton plugin

## 2.8.2-release 04/16/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. (Internal): The format of the VERSION file changed, much more information is now included.
  4. The shared memory reader applications for the different simulators now have their Windows Explorer icons.
  5. The "Controller Plugin Labels" file is now available in different translations. See the documentation on [plugin configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) for more information and read the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-282), in case you have changed this file locally.
  6. The active modes of the connected controllers (aka Button Boxes) can now be automatically activated depending on the current simulator and the active session. A default configuration, which behaves as before, is automatically created by the update procedure, but you might want to define your own [automation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#configuration-of-the-controller-mode-automation).
  7. Jona now can handle the pitstop setup for you in the *rFactor 2* simulation.
  8. Beginning with this release, you will find predefined configurations for Simulator Controller in the *Profiles\Simulator Controller* folder, which might help you in the initial configuration of the software. The first one is a configuration for all of you, who only want to use Jona, the Virtual Race Engineer. See the [Installation & Configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) for more information.
  9. (Developer only): Introduced two new base classes *SimulatorPlugin* and *RaceEngineerSimulatorPlugin*, which reduces implementing plugins for simulation games to a few lines of code from now on. Please see the [updated developer reference documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#simulator-plugin-implementation-classes) for more information.

## 2.8-release 04/09/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New plugin "Race Engineer" to handle Jona for different simulation games
     - Some of the *raceEngineer...* plugin parameters of the "ACC" plugin has been moved to the new "Race Engineer" plugin. See the new new documentation for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  4. Integration of Jona, the Virtual Race Engineer, for *RaceRoom Racing Experience*. No support for actual pitstop handling yet, and actually, this might never come due to limitations in the UI and API design of *RaceRoom Racing Experience*.
  5. Initial version of Jona for rFactor 2 too. Support for pitstop handling will be added in a future release.
  6. Jona is now also active in practice sessions but does not support pitstop planning and preparation there.
  7. When the *Race Engineer.settings* file is changed while Jona is already active, the updated settings will be imported into the active session. This is useful during Practice, Qualification or even Endurance Race sessions.
  8. Introduced color coding (Red = Soft, White = Medium, Blue = Hard) to the tyre compound handling of the Virtual Race Engineer.
  9. (Developer only): Documentation for the configuration tool plugin interface has been added. Please take a look here: [Customizing the Configuration Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#customizing-the-configuration-tool) and also the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#configuration-editor-classes) in the *Classes Reference* for more information.
  10. (Developer only): The build pipeline of *Simulator Tools* now incorporates *VS MSBuild*, so that all external applications and DLLs will be automatically compiled too. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#using-the-build-tool) on *Simulator Tools* for more information.
  11. (Developer only): New class *JSON* in *Libraries* to handle JSON files.
  
## 2.7-release 04/01/21

  1. Bugfixes, as always
     - Finally a fix for issue #2 - Language dropdown menu synhronization error in Configuration Dialog
  2. Documentation updates, as always
  3. Support for multiple active plugin modes, when more than one hardware controller is connected and configured. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration) of the "System" plugin configuration for more information.
  4. Layout editor for Button Box layouts integrated into the configuration tool. The [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) for Button Box layout configuration has been updated as well.
  5. Jona can be asked to **not** change the tyre pressures on an upcoming pitstop.
  6. Visual feedback for tyre setup import action. See the documentation on the [Virtual Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) (moved to "Race Engineer" plugin in Release 2.8) integration of the "ACC" plugin for more information.
  7. Setup Data will be stored at the end of the race only if [confirmed by the driver](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database)
  8. Added "No Refuel" to the set of handled pitstop configurations - please take a look at the [Update Notes for Release 2.7](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-27) for more information.
  9. (Developer only): New plugin interface for the configuration tool (no documentation yet, for the moment you can take a look at one of the configuration plugins, for example the [Chat Messages Configuration.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Chat%20Messages%20Configuration%20Plugin.ahk) for an introduction and a template).
  10. An Easter Egg with a precious first prize is somewhere hidden in Simulator Controller. It will only be available for the four days of the upcoming Easter weekend.
  
## 2.6.2-release 03/21/21
  
  1. Critical bugfix for 2.6.1
     - Fixed wrong calculation of refuel amount after using new ACC shared memory information, which could lead to zero refueling

## 2.6.1-release 03/19/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Improved stint time management for Jona
  4. Improvments for ACC Pitstop MFD handling
     - Better support for Single Screen Setups
	 - Several edge case optimizations
	 - Full integration of shared memory information for refuel amount and tyre pressuresm, therefore simplified [setup of pitstop strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop)
  5. Improvements for Jona
	 - *Race Engineer Settings* tool can now [import the current settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race) from the Pitstop MFD 
	 - When driver decides for a different tyre compound than recommended, the target pressures will be fully recalculated
  5. Initial setup of database for [Big Data race setup collection](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database)
     - Opt In for community based data acquisition
  6. Larger window size and better UI for configuration tool
     - You can [open related documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-the-configuration-tool) directly from the configuration tool in several places
  
## 2.5.4-release 03/12/21
  
  1. Bugfixes, as always
  2. Documentation updates, as always
  3. With the completion of the weather trend analysis, the capability to change tyre compounds depending on several conditions and almost 500 rules in the AI kernel, Jona is now feature complete and no longer considered to be in alpha stage. I still advise you to be cautious, especially during important races, and always double check Jonas recommendations, but I do use it during league races and the recommendations had been spot on so far. As always, take a look at the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#how-it-works) and especially on the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) required for Jona
  4. [A new plugin argument](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the *Assetto Corsa Competizione* plugin allows you to open the race engineer settings dialog from your hardware controller (moved to "Race Engineer" plugin in Release 2.8)
  5. The support for multiple Button Boxes has been extended
     - New capabilities in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) for Launchpad applications and chat messages
	 - The Button Box [configuration file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) format has been extended to allow for the definition of several layout margin and filler options
  6. Volume, pitch and speed settings has been added to the [voice control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) to customize the voice output to your taste
  
  As with all releases since Release 2.0, automated update procedures take care of your local configuration database. But there might be additional installation steps or preparations required, which are described in the documentation about the [Release 2.5.4 update requirements](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-254).
  
## 2.5-release 03/05/21
  
  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Push-To-Talk function for voice recognition - this will reduce false positives almost to zero
  4. Button Boxes can be created with a configuration file - no more programming knowledge needed
  5. Extension of ACC Shared Memory Reader for weather information and track grip status
  6. Jona now issues notifications about upcoming weather changes and recommends tyre changes
     - Note: Pitstops do NOT yet consider weather informations and tyre compound changes, therefore be careful. This will be part of Release 2.6 or 2.7
  
## 2.4.1-release 02/26/21
  
  1. Critical bugfix for 2.4
  
## 2.4-release 02/26/21
  
  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Better support in translation tool for missing translations
  4. Support for multiple Button Box visual representations, if you have more than one hardware controller connected. Initial version will span a single mode across all Button Boxes, but a future version will allow for more than one active mode
  5. Change of Calibration Curves now works in the "Pedal Calibration" plugin also during a running simulation (even in an active race situation)
  6. Initial support for RaceRoom Racing Experience by a skeleton plugin
  7. Jona now recommends tyre pressure correction for the next stint based on environmental temperature development
  8. Extended documentation on Jonas capabilities, see the documentation on [How it works](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#how-it-works)

## 2.3-release 02/19/21
  
  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Lots of new stuff in the Jona AI kernel
     - Full statistical laptime analysis after accidents
     - Recommandation, whether an early pitstop strategy might be advantageous after an accident
     - Initial rule set for weather and tyre temperature trend analysis
  4. Initial support for rFactor 2 by a skeleton plugin
  5. Automatic notification, when a new version is available
  6. Lots of refactoring and file location reorganization
  
## 2.2-release 02/13/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Graphical user interface for editing the contents of the *Race Engineer.settings* file. It supports loading and saving the settings outside the standard location, thereby allows building a setup database. See the new documentatation on the [race settings tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) for more information
  4. Phrase grammars can be used directly as controller function hotkeys. See the [updated documentation on configuring hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) for an introduction to voice triggers
  5. More stability improvements for Jona
  6. Update of the voice server process - this process will be started automatically by *Simulator Startup* and will stay open all the time. Normally you can ignore it, since it is controlled by the other Simulator Controller applications. But if you experience problems and want to disable voice completely, go to the Tray area of the Windows taskbar, right click on the *Voice Server.exe* icon and choose Exit.
  7. Complete redesign of all application icons
  
## 2.1.3-release 02/10/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New plugin action for the ACC plugin to enable or disable Jona from the hardware controller
  4. Minor updates in the phrase grammars of Jona
  5. Once again, improved handling of list boxes in the configuration tool
  6. Stability improvements for the inter process communication - no more circular deadlocks
  7. Lots of small improvements for Jona with regards to session and stint handling
  8. New server process, that handles all voice generation and recognition duties - a little bit slower, but much more stable
  9. New target for the maintenance tool to clear the *Temp* folder
  10. From now on, Jona is only available in a race situation, either single- or multiplayer
  
## 2.1.0-release 02/06/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Introduction of the **alpha** version of Jona, the AI based Virtual Race Engineer. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer) for a comprehensive overview of Jona.
  4. A new plugin "Pedal Calibration" allows you to dial in different calibration curves for your high end pedals (Heusinkveld) directly from the Button Box. An adoption to a different pedal vendor is possible without much effort.
  5. A lot of new stuff for developers:
     - A hybrid rule engine, which supports production rules like OPS5 and reduction rules like in Prolog. The rules are fully integrated with the AutoHotkey scripting language, thereby creating a rich, hybrid programming environment
	 - A unit testing framework
	 - A speech generator class library
	 - A speech recognition class library
	 
  As with all releases since Release 2.0, automated update procedures take care of your local configuration database. But there might be additional installation steps or preparations required, which are described in the documentation about the [Release 2.1 update requirements](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-21).

## 2.0.4-release 01/18/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Additional voice support for select driver in pitstop settings
  4. First version of the hybrid rule engine, which will be used to implement the AI based race engineer

## 2.0.2-release 01/10/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support for select driver in pitstop settings

## 2.0.1-release 01/09/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. You can enable an auto save mode in the configuration tool for changed list elements

## 2.0.0-release 01/07/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. The ACC Plugin has been greatly extended to support complete hands-free control over all the pitstop settings. New controller actions can be connected to an external event source like VoiceMarco to control the pitstop settings by voice. What the driving instructor always said - keep your hands on the steering wheel. But for the Button Box lovers, a new plugin mode "Pitstop" supplies control of all pitstop settings from the hardware controller as well. Please be sure, to read the updated documentation on the [ACC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) to get an understanding of all the new features.
  4. A mostly [automatic update procedure](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#automated-update-procedure) for all user configurations has been implemented. When a new release package has been installed, the applications check, whether the user configurations needs to be adopted to the new version and perform the necessary changes as automatic as possible. A full [update information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes) will acompany every release from now on for all possible additional steps to be carried out by the user.
  5. Much better user experience in all list elements of the configuration editor. Single click selection is supported in every list and you can move around using the cursor keys. *Alt-S* as a shortcut to save the current edited element has also been implemented everywhere.


  **IMPORTANT**: Please follow the release specific instructions in the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20) carefully for this release, to be sure, that your configuration will integrate all the new features.

## 1.4.4-release, 01/01/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Unicode based translation support. German translation will be bundled - other languages can be easily added
     - including a graphical tool for translation editing
  4. Updated photorealistic elements for Button Box
  5. All settings dialogs may be moved around by clicking in the main title
  6. All current effect settings will be displayed alternating with the corresponding effect name in the Button Box visual representation
     - Only available for the Motion Feedback plugin. Unfortunately, this is currently not possible for Tactile Feedback, since SimHub does not provide an interface for querying the current effect settings at this time
  7. A new option is available in the configuration dialog, which allows the Button Box window to be centered on a secondary screen. Helpful, when opening the visual representation on a small display located next to the Button Box
  8. Several Refactorings and Renames
     - Renamed "Simulator Configuration" => "Simulator Settings"
     - Renamed "Simulator Setup" => "Simulator Configuration"
	 - Several name changes in the source code to adopt to this new name scheme (Configuration => Settings, Setup => Configuration)

## 1.3.3-stable, 12/27/20

  1. Bugfixes, as always
  2. Documentation updates, as always
     - including a new Wiki page with the hottest backlog features
  3. New photorealistic Button Box Visuals - you will love it
  4. You can now interact with the visual representation of the Button Box using the mouse and everything is functional, even if you don't have a hardware controller. So you can put your old Button Boxes on eBay - not.
  5. Button Box will be moveable by the mouse and the position might be saved according to configuration.
  6. Better window handling of SimFeedback. The main window will stay closed whenever possible.
  7. Introduced *shutdownSystem* controller action.
  8. Debug mode now defaults to *true* in non compiled scripts.

## 1.2.4-stable, 12/23/20

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Complete rewrite of sound volume handling (should resolve issue #1)
  4. Themes Editor: A collection of media files (pictures, animation, sounds) can be grouped together using the themes editor, a part of the setup tool. In the startup configuration, you can enable this group for splash screen and startup animation as a whole. With this functionality, you can have a GT3 look and feel, a Rallye look and feel, an F1 look and feel, and so on. For an introduction to themes, please take a look at the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor).

     Important: You either need to use the themes editor of the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) to configure your own splash themes or you need to copy the "[Splash Themes]" and "[Splash Window]" sections from 
*Resources\Templates\Simulator Configuration.ini* to your local configuration file found in *Simulator Controller\Config* in your user *Documents* folder. Also, be sure to update the runtime configuration of *Simulator Startup.exe* and *Simulator Tools.exe* by holding the Control key down while starting these applications.
  5. Added a special startup handler for Tactile Feedback (SimHub).
  
     Important: If you already defined your own configuration using the setup tool, please set "startSimHub" as the special startup handler for the "Tactile Feedback" application in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the setup tool.

## 1.1.0-stable, 12/19/20

  1. Documentation updates
  2. Several bugfixes
  3. Renamed *Documentation* folder to *Docs* folder.
  4. Introduction of the *Simulator Controller* folder located in the *Documents* folder of the current user. This folder might contain local media files und plugin extensions, as well as log files and configuration files. See the [Installation & Setup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) guide for more information.
  6. Created a *Templates* folder in the *Resources* folder for all the files, that will populate the *Simulator Controller* folder in the users *Documentation* folder.
  7. Several refactorings to support the new customization features.

## 1.0.8-beta, 12/18/20

  1. Second preview and possibly release candidate for the upcoming feature release 1.1.0...

## 1.0.5-beta, 12/17/20

  1. First preview and test release for the upcoming feature release 1.1.0...

## 1.0.2-fix, 12/17/20

  1. Critical bugfix for Motion Feedback Plugin
  2. Small fixes for performance issues

## 1.0.0-stable, 12/15/20

Initial release
