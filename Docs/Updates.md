Before we start, an important information for *First Time Users*: If you install Simulator Controller for the first time, you can skip the information below for the moment, as long, as you don't want to use voice control. Most of the stuff below is only important for users, that already configured their local installation and will want to keep this configuration information, but also want to integrate all the new features as well.

Special steps, that might be necessary for using voice control and pitstop automation for the *RaceRoom Racing Experience* Pitstop MFD, are described [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1). There might be additional requirements for other simulators as well. Up to date information can always be found in chapter about [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes).

***

Beginning with Version 2.0 an automatic update procedure is available to bring a local configuaration database up to the new specs. After you installed the new release package, the system will check, whether an update to the configuration database is necessary for this release (and possibly for releases, you left out) and will greet you with the following dialog:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Update%20Alert.JPG)

You have three possibilities here:

  1. If you choose "No", the application will continue and will use the currrent configuration information. Everything should work as expected, but some of the new features introduced by this and previous releases might be passive due to missing configuration information. But: If you start the application next time, the question will reappear to give you a chance to perform the update then.
  2. In the case of "Never", you will skip the automatic update and also all future questions. This can be undone, but requires some low level tweaking. More on that later.
  3. If you choose "Yes", the update procedure tries to incorporate all new configuration elements from the distribution into your local configuration database in the *Simulator Controller\Config* folder in your user *Documents* folder. This process will be described in detail below.
  
## Automated update procedure

Let's start with some low level information, to give you an understanding, what happens in the background, when an automated update is processed. A new file has been created in the *Simulator Controller\Config* folder. It is named *UPDATES* and keeps track of already carried out updates. If it is missing or does not contain information for the current release (or releases you missed out), the update procedure will start. After the update finished sucessfully, this will be noted in the *UPDATES* file. And here is the trick, if you have chosen "Never" in the dialog above: Just open this file with a text editor and delete the lines for the releases in question and you will be fine.

IMPORTANT: When you already installed and used an alpha or beta release for one of the releases described below, it might be necessary to rerun the update procedure for the final release to be sure to include all necessary updates. The procedure is the same as described above, just delete the corresponding line from the *UPDATES* file, and the update procedure will take care of the rest.

When the automated update procedure runs, there are some standard task, that are carried out for each release and there are release specific tasks. You will will find the release specific information for each release below. Typical standard tasks might be:

  * Update of all translation files
    
	If the release introduces new translations, the local translation files in the *Simulator Controller\Translations* folder will be updated to include the new translatable items. It cannot give you a full tranlation, as long as the corresponding language is not part of the standard distribution, but you will be able to edit these items using the [translation tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor).
	
  * Update of *Controller Action Labels* and *Controller Action Icons*
    
	New labels for the controller actions, which has been introduced by plugin extensions in the current release, will be automatically copied to your local files in the *Simulator Controller\Translations* folder in your user documents folder.
	
  * Update of Phrase Grammars
    
	Many releases bring changes or additions for the grammar files of Jona and/or Cato. These will also be automatically added to your local files in the *Simulator Controller\Grammars* folder.
	
  * New configuration items in *Simulator Configuration.ini*
  
    This is some sort of corner case. If a new configuration item has been introduced, it can be copied to your local configuration, but if this will make sense in combination with all your own configuration items depends on the functionality behind it. For example, enabling a wind motor fan in the configuration will not be very uselful, if your own rig does not have a wind motor at all. But, since in most cases it is of interest to at least see the new functionality in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), all new configuration items will be copied to your local configuration file, as long as there is no conflict, for example duplicate controller functions. Please consult the documentation on each release below to get an overview of all the new configuration items.
	
The update procedure itself is handled by the application *Simulator Tools*. It is autmatically started and the other application, which detected the need for the update will wait, until the update finished successfully. You might want to start *Simulator Tools* manually, but in this case, it will also try to perform other maintenance tasks as well, which might result in warning messages, if your distribution is not configured for development. But you can safely ignore those warnings about missing compiler and so on, nothing harmful will happen.
Although the code, that handles all the update tasks, is integrated into *Simulator Tools*, the activation and, much more important, the dependencies are defined in the *Simulator Tools.targets* file. I do not recommend to change the contents of this file, but it might be helpful to take a look into the update rules, to get a better understanding of the things behind the curtain.

Note: Some of you might want to have more control. No problem. All the files in the *Simulator Controller\Config*, *Simulator Controller\Translations*, *Simulator Controller\Grammars* and *Simulator Controller\Rules* folders are human readable and using a text editor and some *Diff* tool, you can do everything the automated procedure does on your own. But be sure to make a backup copy of all the files, just for peace of mind. Attention: These files use a two-byte character set, so be sure to use an editor that can handle this.

## Release 4.5.2

Since the oversteer detection has been revised for the telemetry analyzer of the "Setup Advisor", you have to adjust the detection thresholds to higher values.

***

## Release 4.5.1

Nothing to do manually, but the reorganization of the race reports database might run quite a long time depending of the number of reports you already have. Please make a backup copy, before running the update.

***

## Release 4.5.0

New controller actions ["Mute" and "Unmute"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) have been introduced for all Race Assistants. If you want to use this new commands and are using a Stream Deck as well, you may want to reload the Stream Deck icon preset using "Simulator Setup", so that the icons for the new actions are available. There are also special icons "Mute_ASSISTANTS.png" and "Unmute_ASSISTANTS.png" available, if you want to create a Stream Deck action, which mutes/unmutes all Assistants with one button press.

***

## Release 4.4.8

Updates are handled automatically. Beside that:

1. If you are hosting your own Team Server, you **must** update your instance before you connect with a version 4.4.8 to the new Team Server. You can continue to use your current database file, schema updates will be handled automatically.
2. If you are using a managed instance of Team Server because of your Patreon membership, please make sure, that you don't connect with a version prior to 4.4.8 to this instance, since it has been ugraded to the new release.
3. When you have already configured a data replication with the Team Server for the session database, you might want to visit the settings in "Session Database", since there are new replication options available for strategies and car setups.

***

## Release 4.4.7

No manual updates necessary.

***

## Release 4.4.6

Nothing to do for you this time.

***

## Release 4.4.5

Everything handled automatically.

***

## Release 4.4.0

Updates are handled automatically. Beside that:

1. If you are using the Team Server for your team races, please renew all your tokens. Old tokens are no longer valid and might even trigger errors. All changes for sessions should be compatible, but I strongly advise to create new sessions, just in case.
2. If you are hosting your own Team Server, you **must** update your installation before you connect with a version 4.4.0 to the new Team Server. You can continue to use your current *.db database file, schema updates will be handled automatically.
3. If you are using a managed instance of Team Server because of your Patreon membership, please make sure, that you don't connect with a version prior to 4.4.0 to this instance, since it has been ugraded to the new release.

## Release 4.3.5

Everything handled automatically this time as well.

***

## Release 4.3.4

Everything handled automatically.

***

## Release 4.3.3

Nothing to see here, move on.

***

## Release 4.3.2

Nothing to do for this release.

***

## Release 4.3.1

Nothing to do this time.

***

## Release 4.3.0

Updates are handled automatically. Beside that:

1. You may want to review the [configuration of the "Race Spotter" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter), since some options have been removed and a new configuration setting has been added.

2. A new controller action ["StrategyRecommend"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin to trigger the recalculation of the current race strategy. If you want to use this new command and are using a Stream Deck as well, you may want to reload the Stream Deck icon preset using "Simulator Setup", so that the icon for this new action is available.

***

## Release 4.2.6

A couple of things to do for you for this update:

1. Unfortunately, this update will once again delete the track maps for *Assetto Corsa*, *Autommobilista 2*, *Project CARS 2* and *RaceRoom Racing Experience*. This has become necessary, since the coordinate system transformation was reversed, so that the track maps were mirrored. All automations created for these simulators are invalid as well.

2. A new preset "Muted Race Spotter" has been added to "Simulator Setup", which let you use the track mapping and track automation services provided by the Spotter, although you are using a different software as a Spotter in your setup.

3. The controller action function "changePitstopBrakeType" has been renamed to "changePitstopBrakePadType". You must adopt your configuration, if you have used this function.

4. The actions "BrakeTemperatures" and "BreakeWear" have been added to the "Race Engineer" plugin. You can add it to your configuration, if you want to get these informations by the press of a button on your controller (but they are available as voice commands as well). If you are using a Stream Deck and you have used the icons preset in "Simulator Setup", remove and reassign it, so that the added icons for the new "BrakeTemperatures" and "BreakeWear" actions will be available to you.

***

## Release 4.2.5

Updates are automatic. Please note, that all recorded track images will be deleted, since the mapping information has changed for the new automation feature. They will be automatically recreated, after you have driven a few laps on each track.

A "TrackAutomation" action has been added to the "Race Spotter" plugin. You must add it to your configuration, if you want the new track events automation feature. If you are using a Stream Deck and you have used the icons preset in "Simulator Setup", remove and reassign it, so that the added icon for the new "TrackAutomation" action will be available to you.

IMPORTANT for *iRacing* users: The identification of the *iRacing* simulator main window has changed. If you want to use the new track automation feature, you must change your configuration as well. Do the following:

1. If you are still using "Simulator Setup" for all your configuration tasks, simply recreate a configuration. Done.
2. If you use "Simulator Configuration", go to the "Applications" tab, select the "iRacing" application and set the Window title to "ahk_exe iRacingSim64DX11.exe". Save and Done.

***

## Release 4.2.4

Configuration updates are automatic, including a complete and possibly time-cosuming reconfiguration of all data for *rFactor 2*.

This release brings a new integration for *Project CARS 2*. A corresponding plugin will be added as disabled to your configuration, but you still have to create the application entry in "Simulator Configuration" and you must enable the plugin. See the [plugin documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pcars2) for more details. Although, if you are still using "Simulator Setup", rerun it and everything will be configured automatically.

The other major change in this release that requires your attention is the introduction of a tyre compound meta model for all simulators. Please read the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) carefully. It contains instructions, what to do, if you want to use this feature. If you are only racing in *Assetto Corsa Competizione*, you can skip this safely, because only *Dry* and *Wet* tyres are available here. So the choice is easy. 

A "TyreCompound" action has beend added to the *RaceRoom Racing Experience* plugin. You may want to add it to your configuration. If you are using a Stream Deck and you have used the icons preset in "Simulator Setup", remove and reassign it, so that the icons for the new "TyreCompound" action will be available to you.

***

## Release 4.2.3

Configuration updates are automatic, but the information request action "GapToFront" was renamed to "GapToAhead". For compatibility reasons, the old spelling is still supported by the different apps, but if you regenerate your configuration using "Simulator Setup", you must fix your controller bindings. If you have used the icon set preset for Stream Deck, remove it from the preset list and reassign it, so that the modified request action names come into effect.

***

## Release 4.2.2

Nothing to do regarding the configuration update, but:

  1. A minor bug in 4.2.1 may have created unnecessary folders in the Session Database, when you have used AC and directly aftwards ACC. These folders will show up as cars from AC in the ACC collection and vice versa, for example in the "Strategy Workbench". Go to the [Documents]\Simulator Controller\User\ACC folder and simply delete these alien folders. Do the same for [Documents]\Simulator Controller\User\AC, if necessary.

  2. The Team Server has been updated to support the storage of owner IDs for all collected data. If you run your own Team Server, make sure to update the binaries, before connecting with any of the applications of the current release. The database structure is unchanged, therefore you can still use your current database file.

  3. The action "TyreChange" is no longer available for the "AMS2" plugin. It has been replaced by "TyreCompound". Two more actions ("Strategy" and "DriverSwap") are available now. You may want to update your configuration and your controller bindings.

***

## Release 4.2.1

Database and configuration update is again handled automatically, but there is a major change in this version, how the Pitstop MFD in ACC is handled. Before this release, you had to create small search images, so that the available options and the current state of the ACC Pitstop MFD could be detected using image recognition. The new method introduced with this release uses a different approach, a kind of fuzzy option walk, to achieve the same result. But you can still use the image recognition method, if you feel disturbed by the fast moving cursor of the Pitstop MFD or - even more important - if there is a malfunction with the new method. To do this, open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--session-database) and insert and check the setting "Pitstop: Image Search" for the *Assetto Corsa Competizione* simulator.

***

## Release 4.2.0

Database and configuration update is handled automatically, but you may want to check out the new support for Assetto Corsa (Pitstop mode and integration with the Virtual Race Engineer) and update your configuration accordingly.

New labels and Stream Deck icons where added for *Assetto Corsa*. You may want to take a look in the [Action Labels & Icons editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons). Engine repair icons has been added to the Stream Deck icon collection and also to the corresponding preset for "Simulator Setup". If you want to benefit of them, open "Simulator Setup", remove the preset and re-add it again. But be careful, if you have modified the icon assignments on your own with the [Action Labels & Icons editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons), since your changes will be lost, if you do it this way.

***

## Release 4.1.9

Everything handled automatically.

***

## Release 4.1.8

Once again, nothing to do for you.

***

## Release 4.1.7

Everything is handled automatically.

***

## Release 4.1.6

Configuration and database updates ae handled automatically, but the file structure of the Race Spotter grammars changed. If you have modified or extended the grammars, you have to check and potentially merge your changes.

***

## Release 4.1.4

A new information request action "FuelRemaining" has been added to the "Race Engineer" plugin and all simulator plugins. You might want to configure this to a button on your hardware controller. All other changes will be handled automatically.

***

## Release 4.1.2

Once again, nothing to do for you.

***

## Release 4.1.0

Everything is handled automatically.

***

## Release 4.0.8

Nothing to do this time.

***

## Release 4.0.6

Nothing to see here, move on.

***

## Release 4.0.4

Update is handled automatically, but you will want to check the changes in the grammar files and in the action labels and icons, when you have made changes there. See the [configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) for more information on action labels and icons, but grammar files must be handled with a text editor.

Please note, that from now on, only the changed items in translatable configuration files must be saved to the local configuration database. All items that are not present in the local file will be loaded from the standard file that resides in the program directories of Simulator Controller. This affects the following type of files:

  1. Translations (handled by the [Translation editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor))
  2. Phrase Grammars (handled as plain text file)
  3. Controller Action Labels (handled by the [Action Labels & Icons editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons))
  4. Controller Action Icons (handled by the [Action Labels & Icons](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons))
  5. Settings Definition Files for "Session Database" (handled as plain text file)

***

## Release 4.0.2

Update is handled automatically, but you may want to check the possibilities of the new cloud based voice recognition. Details can be found in the [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes).

The Assistant grammars has been modified with this release for the new voice recognition functionalities. Therefore, if you have modified or extended the grammar files of the Race Assistants, please check the original files and incorporate those changes into your own versions. A new placeholder variable "(Digit)" has been introduced for single-digit numbers. Use it whereever possible, it will increase recognition performance. The usage of "(Number)" for values between 0 and 100 is discouraged where not necessary.

***

## Release 4.0.0

The shared database consolidation and distribution process is enabled with this release. Since you only will receive any data, when you also contribute to the content of the database, you will get a new chance to review your consent regarding the shared data.

Beside that, this version introduces new voice commands for the Race Assistants and also for the Virtual Race Spotter to enable or disable the different announcements and warnings while you are out on the track. Since this is the first time that you can talk to the Spotter, you have to enable the voice listener for the Race Spotter in the configuration, which might be not enabled currently. The update procedure will try to fix this for you, but if that fails, you have to add "raceAssistantListener: On" to the list of plugin arguments for the "Race Spotter" plugin in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

Other changes will be handled automatically. You will notice that the plugin parameter "raceAssistantService" has been renamed to "raceAssistantSynthesizer" and a new paramater "raceAssistantRecognizer" has been introduced.

***

## Release 3.9.8

The local database has been revised heavily but all configuration updates will be handled automatically:

  1. The application "Setup Database" has been renamed to "Session Database" to reflect the extended functionality. The reference to this application created by the installer in the Windows Start Menu will be updated automatically, but if you have created an external link, for example in the Windows task bar, you have to update this link.
  2. The action function *openSetupDatabase* has been renamed to *openSessionDatabase*.
  3. Similar, the plugin parameter *openSetupDatabase* for the plugins "Race Engineer" and "Race Strategist" has been renamed to *openSessionDatabase*.

***

## Release 3.9.6

Everything is handled automatically.

***

## Release 3.9.4

Adjustments to the configuration are carried out automatically. Please check whether the new plugin parameter ["openSetupAdvisor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) should be included in the configuration of the "Race Engineer" plugin. Also, a new action label and action icon slot has been introduced for the "SetupAdvisorOpen" action. See the [configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) for more information.

***

## Release 3.9.2

Configuration update is handled automatically. A bug has been fixed for handling of ICO files in the Stream Deck plugin. If you are using the Stream Deck integration for Simulator Controller, you must update the *de.thebigo.simulatorcontroller.sdplugin* plugin (see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) for more information).

***

## Release 3.9.0

Everything is handled automatically.

***

## Release 3.8.8

Everything is handled automatically, but you might want to have a look at new plugin information request action “TIME”, which is available for the Race Assistant plugins (and also as a voice command). 

***

## Release 3.8.6

This release introduces the new Virtual Race Spotter. A new [plugin "Race Spotter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) will be added to your configuration, but it will be initially deactivated. Beside that, it is now possible to control volume, pitch and speech rate for each Assistant individually by using the new [plugin parameter "raceAssistantSpeakerVocalics"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer). A higher speech rate (speed) will be especially helpful for the Spotter.

A new action label and action icon slot has been introduced for the Spotter. See the [configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) for more information.

***

## Release 3.8.4

Everything is handled automatically.

***

## Release 3.8.2

A new parameter *pitstopMFDMode* has been introduced for all simulator plugins. With this paramater, you can specify the method with which Simulator Controller communicates with the simulation game. Trying different communication modes might help in situations where the communication for the handling of the Pitstop MFD fails.

***

## Release 3.8.0

Nothing special, only some new plugin labels and icon slots have been added to the "Team Server" plugin. If you are using your own labels and icons, for example for integration with Stream Deck, you may want to check the [*Labels & Icon Editor*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) in "Simulator Configuration".

The Team Server backend has been extended. If you are hosting an own installation, you have to redeploy the server. You can keep your data file, it will be updated to the new format.

***

## Release 3.7.8

The file storage format for Strategies has been heavily extended. Although old strategy files should load without error, I strongly recommend to recreate any strategy that will be used in conjunction with the new dynamic, situation aware strategy adjustment feature of the "Race Center" tool.

***

## Release 3.7.6

Many changes in the Team Server internals. If you are hosting an own installation, you have to redeploy the server. Data will be preserved and updated to the new format. All other changes in this release are handled automatically, although you might want to checkout the new [*openRaceCenter* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) parameter of the "Race Engineer" and "Race Strategist" plugins.

Attention: The automatic update handling for versions older than 3.0 has been removed. If you haven't updated Simulator Controller for such a long time, you have to remove your *Simulator Controller* folder in your user *Documents* folder (make a backup copy) and start with a fresh installation. You can restore your changes, if any, later on.

***

## Release 3.7.4

Nothing to do for this release.

***

## Release 3.7.2

The storage format of the Setup Database has been modified for this release. The migration is handled automatically by the update procedure (be patient, might take a few moments), but you should make a backup copy before running the update in order to be on the safe side. The "Team Server" has changed dramatically. You have to use the new version of the "Team Server" for this release and also older versions of Simulator Controller will not be compatible with the current release of "Team Server".

***

## Release 3.7.0

This release introduces the new *Team Server*. For this, a new [plugin "Team Server"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) has been added to the plugin configuration. For existing installations, this new plugin is disabled. You might want to enable and configure it, if you want to use the new *Team Server*. For more information on installation and configuration of the *Team Server*, please consult the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server).

Some new plugin labels and icon slots have been added to the "ACC" plugin and also for the new "Team Server" plugin. If you are using your own labels and icons, for example for integration with Stream Deck, you may want to check the [*Labels & Icon Editor*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) in "Simulator Configuration".

Please note, that with the latest update of ACC V 1.8 by Kunos, the tyre model changed significantly, which leads to different cold tyre pressures and reduced laptimes on most tracks. This renders the data in the Setup- and Telemetry Database almost useless, but you will find a small tool in the #tools-and-fixes channel in our Discord Server, which you can use to correct the data, at least on average.

***

## Release 3.6.8

Nothing to do for this release, but you may take a look at the new conifguration tools for the Stream Deck integration, if you own one of these little gems.

***

## Release 3.6.6

To support the new Stream Deck integration, all labels for plugin actions has been reworked. Therefore it is necessary to update the "Controller Plugin Labels.XX" files, which are located in the *Simulator Controller\Tranlations* folder, which is located in your user documents folder, if you have modified the labels in the past. The update procedure will move your local files to *.bak files to preserve your changes, but you have to use the "Simulator Configuration" tool to reenter your changes in the updated version of those files.

***

## Release 3.6.4

Nothing to do for this release.

***

## Release 3.6.2

Nothing to do for this release.

***

## Release 3.6.0

Nothing to do for this release.

***

## Release 3.5.8

Beginning with this release, the Virtual Race Strategist will also be active during a Practice session, but only as a passive observer in order to collect the telemetry data for future strategy development. Using the “Simulator Configuration”, you can [configure when to save this telemetry data for the different simulations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist). More important, a new tool „Strategy Workbench“ is introduced with this release. Although the “Strategy” part of this tool is non-functional yet and documentation is not available as well, it can already be used to analyze the telemetry data. Active “Strategy” development using this tool will be completed step by step with the next releases.

A new controller action function “openStrategyWorkbench” has been defined, which might be triggered by an external event source to open the “Strategy Workbench”. Similar, and a new plugin action “StrategyWorkbenchOpen” is available in several plugins to open the “Strategy Workbench” from your controller by a press of a button.

The local folder for the *Setup Database* has been renamed from “Setup Database” to “Database” in order to better reflect the future usage, since the telemetry data for the strategy development will be saved there also. Side note for all, who have given consent to share their tyre and/or setup data: Telemetry data will never be shared with the community, so no new consent is necessary.

***

## Release 3.5.6

All configuration changes are handled automatically for this release. New plugin parameters "Call" have been defined for the "Race Engineer" and the "Race Strategist" plugins. You may want to check the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) to check, if these parameters might be useful for you. Please note, that this version introduces [new report types](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) for the "Race Reports" application. Older reports may show missing data for the new report types.

IMPORTANT for RaceRoom Racing Experience users:

If you have used "Simulator Setup" already, there was an error in the defaults for the Pitstop menu navigation buttons. This will definitely lead to a non-functional Pitstop menu handling. Please correct the "Next Option" value to "S" and the "Previous Option" value to "W" and recreate your configuration. If you are already using "Simulator Configuration" for your configuration tasks, the plugin parameters are *nextOption:* and *previousOption:* correspondingly.

***

## Release 3.5.4

All configuration changes are handled automatically for this release. You might want to check the extended options of the [Race Strategist configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist), if you want to use the new "Race Reports" tool.

***

## Release 3.5.2

This release introduces a fully automatic program installation and update process. You have the option to install Simulator Controller in any location you want either as a portable application (pretty much the same as it has been in the past) or as a fully registered and compliant Windows application. As always, but especially in this case, make a backup copy of your *Simulator Controller* folder in your user *Documents* folder, before carrying out the update. Then completely delete the folder of your current installation of Simulator Controller. Now you have two options:

  1. Use the new automated installer to download and install tha latest version of Simulator Controller (3.5.2 in this case). See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) for more details. Use this method for the official release of Version 3.5.2 on Friday, 08/27/21 and all later release versions.
  2. Download the latest version (3.5.2 or later) from the [release section on GitHub](https://github.com/SeriousOldMan/Simulator-Controller#latest-release-build), extract the contents of the archive and run the application "Simulator Tools" in the *Binaries* folder. This will guide you through the installation process. The files of the installation archive will be deleted afterwards, unless you have chosen a portable installation and the target installation folder is the same as the folder of the installation archive files.

***

## Release 3.5.0

Important: Make a backup copy of the files "Simulator Configuration.ini", "Button Box Configuration.ini" and "Simlator Settings.ini" from your *Simulator Controller\Config* folder in your user *Documents* folder, before using the new "Simulator Setup" Wizard. It has been tested extensively, but it is a complex piece of software, so just to be safe...

The biggest change in this release is the introduction of the all-new [Setup Wizard](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool). In the course of implementing this very challenging tool, the labels for the visual representation of the Button Boxes were extensively revised. Therefore the [plugin label files](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Templates/Controller%20Plugin%20Labels.de) will be completely overwritten in this release (the old files will be retained as backup files in this case).

Therefore: If you have edited your local files in the *Simulator Controller\Translations* folder in your *Documents* folder and introduced your own label identifiers, be sure to re-integrate your changes after running the update. You may have to manually copy the original files from the *Resources\Translations* folder to the *Simulator Controller\Translations* folder in your user *Documents* folder before re-integrating your changes, if you do **not** start the editor from inside the "Simulator Configuration* application.

***

## Release 3.3.0

This release is all about speech synthesis - and it took a great step forward.

  1. Support for *Azure Cognitive Services* for speech synthesis is now available. Please see the revised documentation for [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. If you are using Jona and/or Cato, you can choose between different synthesization methods and voices using the new plugin parameter *raceAssistantService*. See the documentation for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), it is really worth it.
  2. Audio post processing for a really immersive in-car team radio sound is also available now. You have to install a small sound processing utility] [SoX](http://sox.sourceforge.net/) on your computer (for your convinience, you will find the current SoX installer in the *Utilities\3rd Party\Sound Processing* folder) and you have to configure it in the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) as well. It will take only a few minutes, and the immersion effect is great, so you don't want to miss this.

***

## Release 3.2.2

  - A lot of new plugin parameters has been introduced for the ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and most of the present parameters have been renamed. The renaming will be handled by the automated update procedure, but you might want to take a look at the documentation and integrate the new functions into your Controller configuration.
  - All these new actions may also be used in the configuration for the ["Pitstop" modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) of all the simulator plugins or for the new ["Assistant" modes}(https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-assistant), which have been introduced with this release. You may want to adjust the [controller automation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#configuration-of-the-controller-mode-automation), if you use these new modes, so that they are automatically activated during a race or practice session.
  - Furthermore, the "Accept" and "Reject" commands of the "Race Engineer" and "Race Strategist" and of the "Pitstop" modes of all simulation game plugins will now trigger the answer for the currently focused Race Assistant. Nothing to do here, but you should be aware of this new behaviour.
  - New images for the repair options in the *RaceRoom Racing Experience* Pitstop MFD have been introduced. If you created your own images for your local screen resolution and language choice, you need to images for the new options as well ("Bodywork Damage", "Bodywork Damage Selected", "Rear Damage" and "Rear Damage Selected").

***

## Release 3.2.0

Release 3.2.0 integrates the telemetry and data provider for *Automobilista 2*. Nothing to do here with regards to installation, but you must enable the shared memory interface of *Automobilista 2* in the settings of the game. Please choose the mode "PCars 2".

Furthermore, a "Pitstop" controller mode is available for *Automobilista 2* as well. Please take a look at the configuration documentation for the ["AMS2" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-8), if you want to use the new mode on your Button Box. You also might want to adjust the [controller automation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#configuration-of-the-controller-mode-automation) as well, so that the pitstop mode is automatically selected during a race or practice session.

***

## Release 3.1.6

This release introduces the first version of the plugin for Automobilista 2. If you are a fan of Automobilista 2, you will see growing support for this simulation, including an integration with Jona and Cato, in the upcoming releases of Simulator Controller.

The automated update procedure described above will add the plugin descriptor to your local configuration, but the plugin will be deactivated. You may want to activate it using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), but to do so, you also have to add a new application on the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications), which must be named "Automobilista 2". Please set "startAMS2" as the *Startup Function Hook*. And last but not least, you may want to add "Automobilista 2" to the list of Simulators on the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general).

***

## Release 3.1.4

Please take note of the following:

  - The application "Race Engineer Settings" has been renamed to "Race Settings" and the application "Race Engineer Setups" has been renamed to "Setup Database". If you have referenced them *outside* of Simulator Controller, for example in a StreamDeck configuration, please take care of the renaming.
  - The "Race Engineer.settings" file has been renamed to "Race.settings". The automated update procedure will take care of the renaming in all locations, even in the local setup database. But an additional tab with settings for the strategy simulation model has been added. You may want to take a look at the new settings using the *Race Settings* tool.
  - The controller actions "openRaceEngineerSettings" and "openRaceEngineerSetups" have been renamed to "openRaceAssistantSettings" and "openSessionDatabase" respectively. If you have used them in your configuration, you must rename them manually using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

***

## Release 3.1.2

This release takes the next step for Cato, the Virtual Race Strategist and introduces integrations for iRacing, rFactor 2 and RaceRoom Racing Experience. Nothing to do here on your side. Small adaptions may be necessary for:

  - A new plugin parameter *raceStrategist* has been implemented for the ["Race Strategist" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist), which allows you to enable or disble the Assistant from your controller hardware. Maybe you want to add this parameter to your configuration.
  - [For Developers]: The class *RaceEngineerSimulatorPlugin* has been renamed to *RaceAssistantSimulatorPlugin* the methods *getAction* and *fireAction* of the class *SimulatorController* have been renamed to *getActions* and *fireActions* and now support multiple actions for one controller function.
  
Note: Beginning with this release, the source code is no longer part of the distribution to save some space. But you can always load the sources from GitHub, if required.

***

## Release 3.1.0

Release 3.1 introduces a new Assistant, Cato, the Virtual Race Strategist. The new Assistant, although fully integrated already, does not do anything useful yet (you can ask for info about the remaining laps and upcoming weather changes for demo purposes, though), so you can ignore it for the moment. But to integrate the new Assistant in Simulator Controller, a lot of small changes were necessary:

  - The voice handling framework now supports multiple different active communication partners. Each one must have an activation command to *focus* the voice recognition for this communication partner (see the [new documentation for voice control](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information).
  - A new plugin has been created for the control of the new Virtual Race Strategist. Please take a look at the documentation of the ["Race Strategist" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) for more information. This plugin will be added automatically to your configuration, but it will be deactivated by default.
  - [Mostly for Developers]: A lot of files were moved to new locations in the course of the integration of Cato. This will be handled by the automated update procedure. Affected are Plugin Labels, Translations, Grammars and Rules. If you have created your own translations for example, you will find those files from now on in the *Simulator Controller\Translations* folder, which is located in your user *Documents* folder. Furthermore, the Rules files had been split apart to allow for a more modular approach.
  
  | Files | Old Location | New Standard Location | New User Location |
  | ----- | ------------ | --------------------- | ----------------- |
  | Translations | Config | [SC]\Resources\Translations | Simulator Controller\Translations |
  | Controller Plugin Labels | Config | [SC]\Resources\Translations | Simulator Controller\Translations |
  | Grammars | Config | [SC]\Resources\Grammars | Simulator Controller\Grammars |
  | Rules | Config | [SC]\Resources\Rules | Simulator Controller\Rules |

***

## Release 3.0.6

The local configuration database will be covered as usual by the automatic update procedure. But you will take a look at the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), since a new configuration page has been added for the Virtual Race Engineer. A lot of [new configuration options](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) will allow you to control the dynamic behaviour of certain algorithms of the AI kernel and the integration of Jona with the setup database. The default values of all thesse new options has been chosen so, that the default behaviour should be the same as before.

***

## Release 3.0.4

The update of the local configuration is covered by the automated update procedure, but you will be asked for a new consent for the extended setup database. Please rethink your consents and be part of the community.

***

## Release 3.0.2

No manual update steps necessary for this release, everything is handled automatically.

***

## Release 3.0

This update is handled completely without manual interaction. You might want to add the new application *Setup Database.exe* to your *launchpad* (see the ["Launch" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-launch) of the "System" plugin for more information), though. Also, you might want to use the new [plugin parameter *raceEngineerOpenSetups*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin to open the setup database query tool.

***

## Release 2.8.6

This release finalizes the integration for *iRacing*. A new "Pitstop" mode has been introduced and Jona is aware of iRacing and can execute a pitstop automatically. Please take a look at the configuration documentation for the ["IRC" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-2), if you want to use the "Pitstop" mode on your Button Box. You also might want to adjust the [controller automation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#configuration-of-the-controller-mode-automation) for the new plugin modes as well.

For Developers: Some of the data fields in the telemtry interface file structure have changed, please consult the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#telemetry-integration), if required.

***

## Release 2.8.5

The major change in this release is the introduction of the "Pitstop" controller mode for *RaceRoom Racing Experience* and *rFactor 2*.

  1. The plugin parameter "pitstopSettings" has been renamed to "pitstopCommands" for the various simulator plugins, and the actions of the "raceEngineerCommands" has been included in "pitstopCommands" and the "raceEngineerCommands" parameter is no longer valid. All this will be handled by the automated update procedure.
  2. Several controller actions from "openPitstopMFD" up to "changePitstopDriver" had been generalized and are now available in all race simulation plugins. The action function "togglePitstopActivity" had been replaced by "changePitstopOption", and the "changePitstopTyreCompound" has changed paramater semantics (both not handled by the automated update procedure). If you have used some of these action functions in your configuration, you might want to take a look at the [documentation of the controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information, and update your configuration accordingly.
  3. A new "Pitstop" mode has been introduced for both the "R3E" and "RF2" plugins. Please take a look at the configuration documentation for the ["R3E" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-7) and the ["RF2" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-6), if you want to use these modes on your Button Box. You also might want to adjust the [controller automation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#configuration-of-the-controller-mode-automation) for the new plugin modes as well.
  4. This release also introduces the first version of the plugin for iRacing. If you are a fan of iRacing, you will see growing support for this simulation, including an integration with Jona, in the upcoming releases of Simulator Controller. The automated update procedure described above will add the plugin descriptor to your local configuration, but the plugin will be deactivated. You may want to activate it using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), but to do so, you also have to add a new application on the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications), which must be named "iRacing". Please set "startIRC" as the *Startup Function Hook*. Locate the "iRacingUI.exe" application and set "ahk_exe iRacingUI.exe" as the window title. And last but not least, you may want to add "iRacing" to the list of Simulators on the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general).

***

## Release 2.8.2

Beside the automated update, two things are worth to mention for this release:

  1. This release introduces localized versions of the *Controller Plugin Labels.ini* file, which was located in the *Simulator Controller\Config* folder in your *Documents* folder. The old file will be deleted during this transformation. Therefore, if you have modified this file, either directly or from the *Plugins* tab of the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), please make a backup copy, BEFORE running the update procedure, and transfer your changes afterwards.
  2. The *rFactor 2* simulation telemetry provider has been extended. Jona is now able to handle a pitstop completely on its own. Please be sure to install the Shared Memory plugin in *rFactor 2* as described in the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rf2). If you forgot this, nothing will happen.

***

## Release 2.8

As always, must of the update work in this release will be handled automatically. But there are some changes, where you might want to adjust your configuration, to get the most out of the new features:

  1. The plugin "RRE" had been renamed to "R3E". The update to the configuration will handle this and will also update the start hook from "startRRE" to "startR3E" automatically. If you configured additional hooks for the *RaceRoom Racing Experience* plugin, you should rename them as well.
  2. This update introduces the integration of Jona with *rFactor 2* and *RaceRoom Racing Experience*. Therefore a lot of functionality, that had been private to the "ACC" plugin in the past, had been moved to a new plugin "Race Engineer", in order to make them available to other simulation plugins as well. Most of the initialization parameters of the "ACC" plugin for the Virtual Race Engineer have been moved to the new plugin as well. This is also handled by the update procedure, but you might want to have a look afterwards to check, if everything is correct. Please also take a look at the documentation for the new ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer). Important: You must install a plugin into *rFactor 2* for the telemetry interface to work, which you can find in the *Utilities\3rd Part\rf2_sm_tools_3.7.14.2.zip*. A Readme file is included.
  3. There had been quite some changes for the internal data format of the telemtry information and also some changes in the AI kernel of Jona, but I don't think, that there is someone out there, who already worked on this stuff.
  4. Two new actions "Accept" and "Reject" have been added to the "Race Engineer" plugin, which you might wand to include in your [configuration}(https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer).
  5. (Developer only): The *Simulator Tools.targets* file changed again, so you might have to mrge your local changes, if there are any.

***

## Release 2.7

VERY IMPORTANT: You MUST run *Simulator Tools* from the *Binaries* folder BEFORE running any other application of Simulator Controller, and accept the "Update" of the local database. Otherwise you might get execution errors from the other applications. But before you do this, read this update notes carefully, since you may want to *rescue* your setup database, before running the update.

Note: If you have you already installed and used an early or development release for version 2.7, it is NECESSARY to rerun the update procedure for the final release to be sure to include all required updates. To achieve this, just delete the corresponding line from the *UPDATES* file in the *Simulator Controller\Config* folder in your users *Documents* folder, and the update procedure will take care of the rest.

Most of the changes necessary for release 2.7 will then have been handled automatically by *Simulator Tools*, as described above. But there are a few more things to mention:

  1. IMPORTANT: A new state has been introduced for the *Assetto Corsa Competizione* Pitstop MFD. Since refueling might not be allowed in some races, a new label picture "No Refuel" has been added to the set of pictures searched by Simulator Controller. If you created your own set of picture as described in the [update notes for Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20), you will have to create a version for the new picture as well. Please note, that the color difference for the "No Refuel" label between active and passive state is quite small, as you will see when taking the pictures with the Snippet Tool. Because of that, there might be some false positives or the "No Refuel" state might not be detected correctly and the Pitstop MFD might behave strangely. Unfortunately, there is no workaround for the moment, as long as Kunos has not supplied a structured API to handle the Pitstop MFD. Therefore, I do not recommend to use the pitstop automation in races where refueling is not available.
  
  2. You may want to check your Button Box configuration using the configuration tool and the [new Button Box layout editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts), if you have defined your own Button Box configuration file in the past.
  
  3. The *raceEngineerSettings* parameter of the [ACC plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) has been renamed to *raceEngineerOpenSettings*. The old parameter still works, but is deprecated now, so you want to rename the parameter, if you have used it in your configuration.
  
  4. (Developer only): The file "Plugins.ahk" in the *Simulator Controller\Plugins* in your user *Documents* folder has been renamed to "Controller Plugins.ahk". The reason for that is, that an additional set of plugins has been introduced for the configuration tool. You will find the plugin include file for the configuration plugins in the *Simulator Controller\Plugins* folder as well, which has been named "Configuration Plugins.ahk".
  
  5. Since many of you did not trust the setup database collection, the text of the consent has been changed to state specifically, that only tyre setup informations are collected. Therefore the consent dialog will appear again and you might rethink your decision. If more data will be collected in the future, I promise that you can decide for each data category separately. Also, since there were some confusions about the required steps to create the correct content in the setup database, I decided to delete all content for this release again. If you are really sure that your recorded tyre setups have been created with the correct initial setup data, move your *Setup Database* folder to a secure location, run the update procedure and restore the database afterwards. Since Jona [now asks at the end of a race](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race), if you want to store your data in the database, in the future you can easily make sure, that only correct data will be stored.

Note: Please see the [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes#27-release-040121) for links to the documentation of all the new features.

***

## Release 2.6

Nothing major for this release, everything will be taken care of by the automated update procedure. For political correctness (sorry for my previous choice of words, but I am an IT guy and in the world of IT these terminology is of widespread use), I renamed "Master Controller" to "Main Controller" and "Slave Controller" to "Support Controller" for the Button Box configurations. As said, this renaming will be handled by the automated update, but if you have configured your own Button Boxes based on the preconfigured ones of the previous release, you might want to check in your configuration, whether everything is as expected after the update.

***

## Release 2.5.4

With this release, Jona is feature complete and therefore no longer to be considered in alpha stage. There still might be situations, where Jonas recommendations are wrong, so always double check, especially during important races. See the documentation on the [Virtual Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer), especially the chapter on [How it works](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#how-it-works) for updated information.

The format of the *Race Engineer.settings* file changed again and the [settings tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) had been updated for the tyre compound selection rules. Please open the settings tool and check all values, especially for weather related tyre compound changes on upcoming pitstops, and leave the dialog by pressing "Ok".

Beside tremendous changes under the hood for Jona, Release 2.5.4 delivers a new plugin argument for the *Assetto Corsa Competizione* plugin, which allows you to open the Race Settings dialog from your hardware controller. Please consult the update [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for more information as well.

And, last but not least, the support for multiple button boxes has been extended. You can now distribute the applications of the Lauchpad and also the chat messages across multiple Button Boxes using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

***

## Release 2.5

A new tab in the configuration tool allows you to configure the language to be used for voice generation and recognition and also introduces a *Push To Talk* functionality for voice recognition. Please read the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control), if you want to use the new features.

Another important change in this release is the introduction of a configuration based approach for Button Box layouts. The automatic update procedure will take care, that the predfiend Button Box visual representation will function as before, but you will want to have a look into the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts), if you had defined your own Button Box with the API based approach. Because of this new feature, Release 2.5 introduces changes in the format of the *Simulator Settings.ini* file, but the automated update procedure will take care of most of that. Nevertheless, you might have to reposition your Button Boxes, since the old saved positions will be lost after the update.

Beside that, Jona learned a lot about upcoming weather changes and tyre compound recommendations with Release 2.5, but this will come for free with regards to the necessary update activities. With this release, more information is used from the *Race Engineer.settings* file. Please use the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) and check all values. Especially, if you want to use Jona to setup your pitstop, this is more important than ever.

***

## Release 2.4

Release 2.4 introduces the first version of the plugin for RaceRoom Racing Experience. If you are a fan of RaceRoom Racing Experience, you will see growing support for this simulation, including an integration with Jona, in the upcoming releases of Simulator Controller.

The automated update procedure described above will add the plugin descriptor to your local configuration, but the plugin will be deactivated. You may want to activate it using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), but to do so, you also have to add a new application on the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications), which must be named "RaceRoom Racing Experience". Please set "startRRE" as the *Startup Function Hook* and "ahk_exe RRRE64.exe" (yes, three "R"s) as the window title. And last but not least, you may want to add "RaceRoom Racing Experience" to the list of Simulators on the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general).

Unfortunately, the format of some of the Settings files have changed again with this release and you have to recreate them:
  1. The format of the *Race Engineer Settings* file has changed again. Please start the *Race Engineer Settings* application, adjust all the settings and close the dialog with the "Ok" button.
  2. Hold the control button down, while starting "Simulator Startup" and adjust the Button Box position. This is necessary, since Simulator Controller now supports multiple Button Boxes.
  
Last, but not least, the former automatically activated "Shutdown" function in the "Launch" mode now is configured by an explicit plugin argument of the *System* plugin. You must update your [plugin configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration), if you want the "Shutdown" function to still be available.

***

## Release 2.3

Beside lots of new functionality for Jona, the Virtual Race Engineer, this release introduces the first version of the plugin for rFactor 2. If you are a fan of rFactor 2, you will see growing support for this simulation, including an integration with Jona, in the upcoming releases of Simulator Controller.

The automated update procedure described above will add the plugin descriptor to your local configuration, but the plugin will be deactivated. You may want to activate it using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), but to do so, you also have to add a new application on the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications), which must be named "rFactor 2". Please set "startRF2" as the *Startup Function Hook*. And last but not least, you may want to add "rFactor 2" to the list of Simulators on the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general).

A second step for the update requires the recreation of of the *Race Engineer.settings* file, since the format has changed substantially. Please start the *Race Engineer Settings* application, adjust all the settings and close the dialog with the "Ok" button.

The last step is only required by the developers amongst you: If you are using a local version of the *Simulator Tools.targets* file, you need to take a look witth you favorite Diff tool, since the original file changed substantially as well.

***

## Release 2.1

Although only a small step in the minor version number, Release 2.1 is by far the biggest release since the initial launch. It introduces the *Virtual Race Engineer*, an Artificial Intelligence, which supports you during a race. The Virtual Race Engineer, which I will name Jona from now on, uses the telemetry data supplied by a simulation game as a knowledge base for a hybrid rule engine. The rule engine can calculate the settings for the next pitstop, can recomend necessary tyre changes because of changing weather conditions, and it will take an eye on your lap times after you collected some damage. You can interact with Jona by natural voice, but the most import actions, like "Plan the next pitstop", can also be triggered by your controller hardware. For now, Jona is integrated with the ACC plugin for *Assetto Corsa Competizione*, but adopting it to a different simulation game is an easy task for an experienced developer.

Using the handling of the Pitstop MFD introduced with Release 2.0 (see below), the setup of a pitstop in *Assetto Corsa Competizione* was never as easy as now. Just say: "Can you prepare the pitstop?" and Jona will take care of everything.

The installation and configuration of Jona is described in its [own chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer). The most important part of the initial setup of Jona is to add the [necessary speech recognition libraries](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-speech-recognition-libraries) from Microsoft to your Windows installation. After that, you might want to take a look at the new [plugin arguments](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) of the ACC Plugin, which must be provided to start Jona during a race.

Important: Jona will handle the ACC Pitstop MFD by using the functionality introduced in Release 2.0. You should read the information below about the necessary steps you need to take, to get the image recognition up and running, which is used to understand and control the Pitstop MFD of ACC. When you are using Jona with its interactive voice dialog feature, there is no more need for Voice Macro as described in the section on Release 2.0 below. Therefore, you might skip the corresponding steps.

If you are updating to Release 2.1 from an earlier version, Jona will be activated for the ACC Plugin, but without voice recognition support, since you might have to install the [required Windows libraries](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-speech-recognition-libraries) beforehand. You can activate voice recognition anytiem later by adding the correspnding argument to the [ACC plugin in the configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc).

IMPORTANT: Jona is considered an alpha version in Release 2.1. There are a lot of planned features still missing and there is also a list of known problems. The biggest issue is a potential deadlock situation in the multidirectional communication between Simulator Controller, *Assetto Corsa Competizione* and Jona itself, when the Pitstop MFD is open. Therefore, I do not recommend to use Jona during an important race, at least for the moment. If you have trouble using it or don't want to use it at all, simply disable it by eliminating the corresponding ACC plugin arguments as described in the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for the ACC plugin.

Another new feature of Release 2.1 introduces the all new [plugin "Pedal Calibration"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pedal-calibration) for the Button Box controller. This plugin allows you to control the different calibration curves of your high end pedals directly from the Button Box. The plugin "Pedal Calibration" plugin will be added to your local configuration by the automated update procedure described above, but it will be deactivated. Activate as needed...

Beside that, all other changes for Release 2.1, for example for the translation files, should be handled by the automated update procedure as well. As always, it might be a good idea to make a backup copy of your local files before you start the first application of Simulator Controller after updating the files, just to be on the safe side.

***

## Release 2.0

Note: The following information is outdated. Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for the *ACC* plugin for up to date information.

Release 2.0 introduces, beside the new automated update mechanism, a full rework of the *ACC* plugin for *Assetto Corsa Competizione*. See the *ACC* plugin documentation about the [new features](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for an in depth introduction of pitstop management. To support this new functionality, there are new plugin arguments for the *ACC* plugin, which will be autmatically added to the plugin configuration item by the automated update procedure. Please use the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) to edit the arguments for the *ACC* plugin according to your needs.

Additionally, a set of new controller actions and controller functions has been introduced by this release to help you to connect an external event source like *VoiceMacro* to the *ACC* plugin to control all the pitstop settings with voice commands. You will find all the new controller actions in the [configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions). After performing the automated update, you will find the new controller functions for those controller actions in the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) of the configuration tool. Please use the editor to configure the functions *Custom* #13 up to *Custom* #32 according to your needs.

Another tweak will be necessary, if your are using *Assetto Corsa Competizione* with a language setting other than English or a screen resolution other than 5760 x 1080. To *understand* the Pitstop MFD state of *Assetto Corsa Competizione*, Simulator Controller searches for small picture elements in the graphics of the game window. As you can see below, this are language specific texts shown in the Pitstop MFD.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Pit%20Strategy%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Compound%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Select%20Driver%202.jpg)

All these pictures are located in the *Resources\Screen Images\ACC* folder in the installation folder of Simulator Controller, but you can *overwrite* these pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\ACC* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes. It is important, that you choose identical names as the originals for your versions of the picture files.

Note: You may use the Windows print screen command to generate a full screen picture of the ACC window and then open this screenshot with "Paint" and grap the pictures using the Snipping Tool. But you will introduce the double amount of compression artefacts into the pictures, since JPG does not use a losslesss compression. This may lead to recognition errors. The preferred method is to switch between the Snipping Tool and ACC back and forth using Alt-Tab and take the pictures single by single.

Hint: The "Select Driver" option might only be available in special multiuser server setups or custom single user races, whereas the "Strategy" option is available in almost every session.

Last but not least, you can configure *VoiceMacro*. This little donationware tool is not part of the Simulator Controller distribution, but it is a part of the [third party application](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications), which are tightely integrated into Simulator Controller. Even the first release already had voice control support, for example to start or stop a simulation game or fire up your motion feedback system, if there is one. Now, with the introduction of the pitstop management system, voice control might become an integral part of your ingame experience. You will find a *VoiceMarco* profile to start with in the *Profiles* folder of the Simulator Controller installation folder. Beside loading this profile, it is very important to tweak the voice recognition settings up to perfection to have the best possible experience while hunting for the lap of the gods. This might be easy, if you use a headset, but if you have a setup similar to mine (Open Webcam micro and 5.1 surround system), you will have a hard time to suppress false positives in voice recognition. I finally found a setting, which I can share here:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Voice%20Macro%20Settings.JPG)

Note: *VoiceMacro* is not longer needed, since a voice recognition capability has been integrated into Simulator Controller directly. But you can still use *VoiceMacro* as an external event source for Simulator Controller, comparable to a Button Box.