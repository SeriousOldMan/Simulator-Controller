## 4.4.0.0-release 10/21/22 (planned)

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The position on the screen where info and progress overlays are displayed, can now be configured in the [UI settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#customizing-controller-notifications).
  4. The session synchronization can be [temporarily disabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#connecting-to-a-session) in the "Race Center", while you are working with the data.
  5. The Team Server now supports synchronization of telemetry data between different members of a team. The documentation for [team management](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams) of the Team server itself, as well as the [database configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#database-configuration) of the "Session Database" has been heavily revised.

## 4.3.5.0-release 10/14/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. UI specific settings, which are managed by the app "Simulator Settings", are now directly available from "Simulator Startup". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#customizing-startup-configuration) for more information.
  4. You can now choose between different methods for delta calculations for the Virtual Race Spotter. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#alerts--information) for more information.
  

## 4.3.4.0-release 09/30/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The strength of the individual effects applied by the sound post processing using *SoX* can now be dialed in the configuration. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information.
  4. It is now possible to wildcard inidividual arguments in the ["raceAssistantVocalics" parameter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) of the different Race Assistant plugins, so that the values chosen in the voice control configuration will be used.
  5. The name of the team will be shown in the tool tip for the *Simulator Controller* tray icon, when you are connected to a team session.
  6. More superfluous Spotter alerts (for example "Left", "Clear Left", "Left", "Clear Left" in fast succession) will be suppressed in certain situations.
  7. Increased reliability of pitstop handover in team races.
  8. Increased reliability of race report creation in team races.
  9. New tyre compound data for *RaceRoom Racing Experience*, thanks to Chris Matthews. With this, allmost all current cars of *RaceRoom Racing Experience* should be covered now.
  10. New car models for "Setup Advisor" (*Assetto Corsa Competizione* has been completed with this):
      - Assetto Corsa:
	    - Chevrolet Corvette C7R
      - Assetto Corsa Competizione
	    - BMW M4 GT4
		- Lamborghini Huracan ST
		- Lamborghini Huracan ST Evo2

## 4.3.3.0-release 09/23/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Fixed a couple of regressions in "Race Center":
     - Fixed infinite loop in special situations when the track map was updated.
	 - Fixed tyre compound menu on the "Pitstop" tab resetting constantly to "No tyre change".
  4. A couple of tweaks for special cases and edge situations by the Spotter:
     - No more warnings for cars attacking you when they are just beeing passed by you.
	 - No more reports for lapped cars for overtaking far too early.
	 - Fixed tactical advise for possible slipstreaming a slightly faster car approaching from behind.
  5. Fixed volume control for voice output, when SoX is used.
  6. New settings in the [Session Database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#managing-the-session-database) allow to configure, whether the Assistants will be active, when a session has been joined after the second lap has been completed. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#racing-with-jona) for more information.
  7. Increased precision in session end detection in ACC races
  8. New tyre compound data for *Automobilista 2*, thanks to Chris Matthews. With this, all current cars of *Automobilista 2* should be covered now.
  9. New car models for "Setup Advisor":
      - Assetto Corsa Competizione
	    - Nissan GT-R Nismo GT3 (2015)
      - Assetto Corsa
	    - Maserati MC12 GT1

## 4.3.2.0-release 09/16/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. "Setup Advisor" now supports setup files for modded cars.
  4. All applications which use the Google chart library can now be run as administrator, so that the browser settings can be added to the registry. See the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#additional-requirements-for-the-embedded-html-browser) for more details.
  5. "Simulator Setup" now has navigation buttons to jump to the last page and to the first page in one step.
  6. Better last lap detection in races with fixed number of laps.
  7. Race reports will now be created including the last lap for races with fixed number of laps.
  8. Increased precision of average lap time calculation by the Spotter in case of off tracks and incidents.
  9. The gap and position calculations of the Spotter has been completely rewritten. Time between data acquisition and the information reported by the Spotter is now less than 3 seconds.
  10. Added more regular Spotter delta and lap time information for the cars around you.
  11. The real race weather forecast as reported by the simulation is used now when a new strategy is created by the "Race Center".
  12. A lot of new tyre compound data has been added for *Automobilista 2* (many thanks to Chris Matthews to provide the data).
  13. Fixed a regression where in many lists and reports the last name of the drivers where missing.
  14. Implemented state caching in "Simulator Setup" which results in a significant performance improvement when stepping to a page, which had already been visited.
  15. A preset has been added to "Simulator Setup" to enable a toggle mode for the Push-To-Talk trigger. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#push-to-talk-behaviour) for more information.
  16. New car models for "Setup Advisor":
      - Assetto Corsa
        - Pagani Zonda R
	    - Mercedes-Benz AMG GT3
	  - Assetto Corsa Competizione
	    - Bentley Continental GT3 (2015)
		- Lamborghini Huracan GT3

## 4.3.1.0-release 09/09/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Mutually interruption of voice outputs of the Assistants works much more sensitive now.
  4. Better detection for end of race at sessions with fixed laps.
  5. Spotter informs about new best laps of direct opponents and the leader.
  6. Spotter periodically announces lap times of direct oppenents.
  7. Spotter informs about potential problems and much slower lap times of direct opponents.
  8. Better handling of a couple of edge cases in the new weather model for strategy simulations.
  9. Fixed a bug, where the Spotter incorrectly reported a car as one lap up or one lap down.
  10. Small improvements in Spotter responsiveness for side and behind alerts.
  11. Better handling of voice input when Push-2-Talk is not used.

## 4.3.0.1-release 09/03/22

  1. Fixed a bug in session restart handling
  2. Better detection of session end in races with fixed number of laps

## 4.3.0.0-release 09/02/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Improvements for the Spotter proximity alerts:
     - Side alerts are more precise in tight corners.
     - Rear alerts detect the side of the trailing car better in tight corners.
  4. A lot of new Spotter announcements:
     - Initial information at the beginning of a race session (duration, position, weather & temperatures, and so on).
     - Announcement of the Green flag at race start.
	 - Information when direct opponents or the race leader enter the pit.
	 - Applause, when a new personal best lap time has been set.
	 - Information when the current session (Practice or Qualification) is ending in 30, 15 or 5 minutes.
	 - Detailed information package, when the first half of a race session has been finished.
	 - Warning a few laps before the current stint is ending.
	 - Information when temperatures are rising or falling.
	 
	 The configuration of "Race Spotter" plugin has been updated accordingly. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#alerts--information) for more information.
  5. Delta calculation has been improved again for the Spotter:
     - The delta history will be reset when a given car is in the pits.
	 - The delta history will also be reset when a car had a crash or a longer offtrack, which results in a lap time, which is far outside the standard deviation.
	 - Cars that are currently in the pits, will be ignored completely, thereby eliminating disturbing and unnecessary gap updates when you have the last valid position on the track.
  6. Improvements for the Race Strategist and Race Spotter when requesting gap informations:
     - When you ask for the gap to the car ahead or behind, it will be mentioned when this car is in the pits.
     - When you ask for the gap to the car ahead or behind, it will be mentioned whether this car is at least one lap up or one lap down.
  7. A couple of improvements for the automated strategy handling (Race Strategist, Race Engineer and Race Center):
     - When a strategy is recalculated / adjusted in "Race Center", an urgent pitstop is created when the currently mounted tyres are not suitable for the current weather conditions.
     - The Race Strategist can now [recalculate / adjust the currently active strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) anytime during a race.
	   - New voice command for the Strategist to trigger the recalculation of the current strategy.
	   - New controller action ["StrategyRecommend"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin, which is equivalent to the above mentioned voice command, incl. a new icon in the Stream Deck icon set for this controller action.
	 - When the Strategist instructs the Race Engineer to plan and prepare a pitstop, the tyre compound as defined in the strategy will now also be transfered to the Engineer, which will select this specific compound for the tyre change.
	 - The Race Engineer now adjusts the fuel amount for the last stint when the pitstop has been triggered by the active strategy.
  8. Improvements for the Race Engineer:
     - Correct handling of all tyre compounds, incl. Intermediate compounds, for tyre recommendations and for automated pitstops. See the [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) chapter as well as the corrsponding notes for [tyre compound handling by the "Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#how-it-works) for more information.
	 - Voice commands for tyre compound specification now also accept *Intermediate* as keyword.
	 - Engine damage will now be detected and corresponding repair recommendations will be issued.
	   - Damage will be detected for the simulators *Assetto Corsa*, *Automobilista 2*, *Project CARS 2* and *RaceRoom Racing Experience*.
	   - Engine repair will be handled automatically during pitstops for those simulators, which support this.
	   - New voice command to enable or disable engine repairs during the preparation of automated pitstops.
	   - "Race Settings" has been extended, so that you can configure the recommendation rule for engine repairs.
	   - A new default setting has been added to the "Session Database" for the engine repair recommendation as well.
  9. Improvements for the Strategy Workbench:
     - The strategy simulation will always try to use the optimal tyre compound for the selected weather conditions. So, if you start with dry tyres in wet conditions, an immediate pitstop will be planned.
	 - The available tyre cmpounds for the given simulator / car / track combination will be automatically preloaded into the Tyre Sets list in the Pitstop Rules group.
	 - Full support for a weather forecast model. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#weather) for more details.
  10. All Race Assistants will try a few times to repeat their current voice message when they get interrupted by another Assistant, typically the Spotter.
  11. You can now use checkboxes to choose which settings should be included / excluded by the "Setup Advisor", when a new setup is generated. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#managing-car-setups) for more information.
  12. Significant performance improvement for the data acquisition of all Race Assistants. Especially important during the startup phase in the first few laps.
  13. The reliability of the ACC UDP connection has been improved when restarting a session without leaving the current session beforehand.
  14. The termination of a simulation is now detected correctly for *Automobilista 2* and *Project CARS 2*.
  15. Fixed a rare bug when the Google chart library does not load correctly in "Setup Advisor".
  16. Fixed a rare bug for the "Motion Feedback" plugin where the motion intensity dial has not reacted correctly to user input.
  17. A new module "Team Server" has been added to "Simulator Setup", so that support for Team Server can be enabled or disabled during initial configuration.
  18. A new preset "Mode Automation" has been added to "Simulator Setup", which allows to select the modes which should be activated on the hardware controller depending on the current context. This creates the default for the "Mode Automation" configuration available in the "Simulator Settings" tool.
  19. All application windows remember their position after beeing moved with the mouse.
  20. All controller preview windows remember their position after being moved with the mouse in "Simulator Setup", as long as the application is not terminated.
  21. It is now possible to send external commands to the central "Simulator Controller" background process to trigger controller actions. See the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#external-commands) for more information.
  22. Temp and Logs folders will be cleaned automatically when an update is installed.
  23. New options in the Tray menu allow you to dump the knowledgebase and the rule set of various applications  and the position and gap data for the "Race Spotter" as well as trace grammars and recognitions in the "Voice Server". You also have commands to delete the temporary files and the log files.
  24. Significantly reduced CPU consumption of the "Simulator Controller" background process.
  25. Transposed some tables in "Race Center" and "Strategy Workbench" for better readability with many stints.
  26. [For Developer] New Task management system for concurrent processing. All applications have been fully rewritten to utilize the new Task model.
  27. New car models for "Setup Advisor":
      - Assetto Corsa
	    - Lamborghini Huracan GT3
	  - Assetto Corsa Competizione
	    - McLaren 650s GT3

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-430), especially, if you want to use the "StrategyRecommend" controller action.

## 4.2.6.1-release 08/05/22

  1. Fixed "Setup Advisor" not loading the Google chart library in rare cases.
  2. Fixed an unbound variable error message when switching back to the General tab in "Simulator Configuration".

## 4.2.6.0-release 07/29/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. The quality of race reports has been improved for *rFactor 2*.
  4. Some tweaks in the delta calculation of the Spotter.
  5. Many of the important settings like Team Server On/Off, Track Automation On/Off, and so on, are now available in the tray menu of "Simulator Controller". See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#enabling-and-disabling-features) for more information.
  6. The new controller action functions ["enableRaceAssistant" and "disableRaceAssistant"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) let you control the availability of the Race Assistants with an external event source.
  7. The controller action function "changePitstopBrakeType" has been renamed to "changePitstopBrakePadType".
  8. A new new preset in "Simulator Setup" let you mute the Spotter in case, you want to use a different tool for this purpose, but still want to use the track mapping and automation feature that are handled by the Spotter as well.
  9. The connection to the Team Server is now deferred in "Simulator Configuration" until you enter the "Team" tab. The tool therefore starts much faster now.
  10. Brake temperatures and brake wear are now available in "Race Center" for those simulators, which support reading these values.
  
      ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2021.JPG)
	  
  11. New voice commands for the Race Engineer to request the current brake temperatures and wear. Not supported for all simulators, though.
  12. New information request actions "BrakeTemperatures" and "BrakeWear" for the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin to request the brake temperatures and wear by pressing a button on your hardware controller.
  13. New icons for Stream Deck for the "BrakeTemperatures" and "BrakeWear" information request action.
  14. The Stream Deck Icons preset has been updated as well.
  15. Fixed the identification of the current driver in race reports and post race reviews for *RaceRoom Racing Experience*.
  16. The launch pad of "Simulator Startup" now has a button with which you can close all running applications with one click.
  17. The current version number is displayed in the launch pad window of "Simulator Startup".
  18. Fixed many errors in track map creation for *Assetto Corsa*, *Automobilista 2*, *Project CARS 2* and *RaceRoom Racing Experience*. All recorded maps so far will be deleted and re-recorded, since either the scaling factor or the coordinate system has changed. Track automations must be recreated as well.
  19. Additional tyre meta data has been added for *rFactor 2*, *Automobilista 2* and *RaceRoom Racing Experience*. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) for more information about tyre meta data.
  20. Action points can now be dragged with the mouse in the track automation editor.
  21. Finally fixed car model detection for *rFactor 2* in certain car classes, for example Formula 2.
  22. Stream Deck icons will be grayed out for disabled actions.
  23. New car models for "Setup Advisor":
      - Assetto Corsa
	    - Mercedes-Benz SLS AMG GT3
		- Nissan GT-R NISMO 2014 GT3
      - Assetto Corsa Competizione
        - Porsche 991 GT3 R
        - Audi R8 LMS
		- Audi R8 LMS EVO
		- Mercedes AMG GT3

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-426), there are a couple of things to mention.

## 4.2.5.3-release 07/24/22

  1. Fixed "Simulator Setup", which was not working at all.

## 4.2.5.2-release 07/23/22

  1. Fixed a bug, when a track gets not mapped when Spotter learning laps are set to a value > 0.

## 4.2.5.1-release 07/23/22

  1. Fixed position data in multiplayer races for *Assetto Corsa Competizione*.
  2. Fixed a regression introduced with 4.2.5, where plugins for Simulators did not create the "Assistant" mode.

## 4.2.5.0-release 07/22/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New options in pitstop rules for always refueling and always changing tyres in strategy simulation.
  4. Introducing track automation, which let you automate your car settings like TC and ABS depending on track location.
     - A new page has been added to "Session Database", which allows you to specify [location specific actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#automation) for a specific simulator / car / track combination.
     - Added the ["TrackAutomation" action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) to the "Race Spotter" plugin which let's you enable or disable location specific actions when you are out on the track.
	 - New ["enableTrackAutomation", "disableTrackAutomations" and "selectTrackAutomation"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#choosing-between-different-track-automations), which let you control the track automationsm while on the track.
     - Added a new icon to the Stream Deck icon set for the "TrackAutomation" action.
	 - Track automations can be exported and imported using the "Session Database" administration tool.
  5. Track mapping incl. track automations are now supported for *iRacing* as well. But since the algorithm to derive the track layout works without a real coordinate system, there are a [few things to mention](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#special-notes-about-track-mapping-in-iracing).
  6. Pretty track names will be collected for *iRacing* when you visit a track.
  7. Fixed a bug in race reports for *iRacing* when car race numbers contain a **"**.
  8. Fixed general bug in race reports, where no lap times where available in the "Overview" report in special situations. Also improved DNF calculation.
  9. Improved handling of data inconsistencies in race reports, especially for *rFactor 2*.
  10. "Behind" alerts are now issued by the Spotter in *iRacing*.
  11. Automatic forced restart of UDP connection to ACC on session changes. Still buggy, but better than ever.
  12. New car models for "Setup Advisor":
      - Assetto Corsa
        - BMW Z4 GT3
      - Assetto Corsa Competizione
        - Ferrari 488 GT3

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-425), especially if you are an *iRacing* user.
	 
## 4.2.4.0-release 07/15/22

**Important**: Once again we have a major reorganisation of the telemetry database, this time for all the data of *rFactor 2*. Please do not interrupt the reorganisation. It will take some time.

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full support for *Project CARS 2* is available incl. integration with all Race Assistants. See the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-424) how to activate the plugin and read the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pcars2) for a description of all the features of the *Project CARS 2* integration.
  4. The Spotter can now create track maps for most simulators. These maps are then used in "Race Center" to give you a [live view](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#data-analysis) of the current race situation. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-mapping) for more information, how the track mapping actually works.
  5. A new meta-model for tyre compounds has been added, which allow you to describe the tyre compounds used for the various cars in all simulators and how these simulator specific tyre compounds map to the internal compound descriptors of Simulator Controller. A complete new [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) covers this topic. Don't miss it.
  6. Schema specifiers has been added to the [export meta data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#importing-data-from-other-sources), so that you are able to import data from foreign sources, for eexample telemetry data from real cars.
  7. A new preset has been added to "Simulator Setup", which helps you in creating a [patch file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#patching-the-configuration) for the generated configuration. Patch files allow you to change all aspects of configurations generated by "Simulator Setup", for example the names and voices of the Race Assistants.
  8. A delay can now be configured in the "Session Database" for the keyboard commands used when dialing pitstop settings in the various simulators. This helps me to fix problems in rare cases, where the PC is quite old and unable to process the fast keyboard commands issued by Simulator Controller.
  9. A new "TyreCompound" action has been added to the "RaceRoom Racing Experience" plugin which allows you to change the tyre compound for the next pitstop. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-8) for more information.
  10. New car models for "Setup Advisor":
      - Assetto Corsa
        - McLaren MP4-12C GT3
      - Assetto Corsa Competizione
        - Emil Frey Jaguar G3
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-424). It contains, among other things, instructions how to activate the new *Project CARS 2* integration.

## 4.2.3.0-release 07/08/22

**Important**: The new database administration tool and especially the new possibility to ex- and import telemetry data has been tested thoroughly, but there are a couple of data constellation dependent edge cases. So, as always, make a fresh backup copy of your local *Simulator Controller* folder, which resides in your user *Documents* folder, before you play with the new stuff. Just in case.

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support driver filters for telemetry in "Strategy Workbench" and "Race Center". You can now select a driver, for which the data in various reports and charts should be displayed. See the updated documentation for ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development) and ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#data-analysis) for more information.
  4. The strategy simulation in "Race Center" has been extended to support more edge cases regarding the current traffic situation.
  5. When simulating a strategy in "Strategy Workbench", it is now possible to preselect drivers for the various stints. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#drivers) for more information.
  6. When a stint plan is created from a strategy in "Race Center", the drivers are preselected, if the strategy has been created with driver information.
  7. Optimized Pitstop MFD handling in ACC, almost twice as fast now.
  8. It is now possible to enable/disable the Team Server connection in Simulator Controller tray menu. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#running-a-team-session) for more information.
  9. All new database maintenance page in "Session Database", where you can browse all available data categories. Data can be deleted, exported and imported even from other drivers, with the driver identity preserved for the imported data. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#administration) for more information.
  10. The information request action "GapToFront" (which was a misnomer) has been renamed to "GapToAhead". See the update notes, if you have used this action in your configuration.
  11. Fixed a couple of glitches in the ACC car models for the "BMW M4 GT3" and the "AMG GT3 2020".
  12. Fixed rear toe calculation when applying recommendations to a given setup in *Assetto Corsa Competizione* or *Assetto Corsa*.
  13. Added required windows language runtimes to the installation pages of "Simulator Setup".
  14. New car models for "Setup Advisor":
      - Assetto Corsa
        - Ferrari LaFerrari
        - Ferrari F2004
      - Assetto Corsa Competizione
        - Porsche 911II GT3 Cup
        - Reiter R-EX GT3
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-423), if you have used the information request action "GapToFront" in your controller configuration.

## 4.2.2.0-release 07/01/22

**Important**: This update includes a major reorganization of the local database, where all the telemetry data and the tyre pressures, and so on, are stored. I tested everything thoroughly, but the devil is in the details. Please make sure to make a backup copy of your [Documents]\Simulator Controller folder and put it on the side for the next few weeks.

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Dropped support for automatic updates prior to version 3.8.0.
  4. Update procedures for local configuration database is now mandatory and automatic (no more questions asked).
  5. When an update is installed, it is checked, whether there are still running processes of Simulator Controller.
  6. Update manager now checks for active processes and asks for termination before running the update.
  7. All Race Assistants can entertain you now you by telling some jokes. Try: "Can you tell me a joke?"
  8. Reduced click area for window subtitles fixes the unwanted opening of a browser with context-sensitive documentation.
  9. Minimum number of tyre laps and minimum amount of start fuel is set to 10 now.
  10. Full support for the Spotter and Strategist in *Assetto Corsa*. You have to install a plugin in *Assetto Corsa* for the data acquisition. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation-of-telemetry-providers) for more information.
  11. "Simulator Setup" no longer overwrites the Team Server settings in "Simulator Configuration".
  12. Added installation support for all integration plugins to "Simulator Setup".
  13. Assistants can be muted and unmuted with a voice command by saying: "Be quiet please" and "I can listen again" or "You can talk again".
  14. Added Owner column to all database tables to identify the driver who provided the data. Please note, that updating the local configuration database can take quite some time for this reorganization.
  15. New version of the Team Server to support the data owner concept introduced above. See the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-422) for more information.
  16. Fixed the Pitstop MFD handling for *Automobilista 2* to adhere to the new ICM.
  17. Remove the controller action "TyreChange" from the "AMS2" plugin. It has been replaced by "TyreCompound". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-9) for more information.
  18. Added "Strategy" and "DriverSwap" action to the "AMS2" plugin. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-9) for more information.
  19. Updated many Assistant commands to uniformly accept "Please", "Can you" and so on.
  20. All new documentation for the Assistant commands. See the [english version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)) and the [german version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(DE)) for the Race Engineer as an example.
  21. Added the new USA tracks to the track meta data for *Assetto Corsa Competizione*.
  22. New car models for "Setup Advisor":
      - Assetto Corsa
        - Abarth 500 Assetto Corse
      - Assetto Corsa Competizione
        - Chevrolet Camaro GT4.R
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-422), there is a small cleanup task for you to do and you may have to update your Team Server.

## 4.2.1.1-release 06/25/22

  1. Critical fix for unsupressed error message after a pitstop in IRC, AMS2, R3E and RF2.

## 4.2.1.0-release 06/24/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. The new ACC Pitstop MFD learning algorithm is now standard. If you still want to use the *old* image search method, take a look ate the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-421). Information about the new method can be found in the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling).
  4. The pitstop window calculation for ACC by the Spotter will be correct now for all kind of sessions.
  5. The delta calculation by the Spotter has been improved again. Still not perfectly correct and sometimes way off, after a crash for example, but it keeps getting better.
  6. Selection of the next driver can now be controlled by the "Race Center" for ACC and RF2. Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#automatically-select-the-next-driver) for more information.
  7. There are now several reports for past pitstops available in "Race Center", where you will get wear information for the used tyres for almost all simulators. You will find more information also in the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#planning-a-pitstop).
  8. New voice command for the Race Engineer to request the current tyre wear. Not supported for all simulators, since some of them provide the data only after a pitstop, which is more relaistic imho.
  9. New information request action "TyreWear" for the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin to request the tyre wear by pressing a button on your hardware controller.
  10. New icon for Stream Deck for the "TyreWear" information request action.
  11. The Stream Deck Icons preset has been updated as well.
  12. Tyre wear data is available in "Strategy Workbench" and "Race Center" for those simulators that support this.
  13. New application launch pad in "Simulator Startup". From now on, you will see the following window, when you run "Simulator Startup":

      ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Launch%20Pad.JPG)
	  
	  You can either continue the startup process by clicking on the top left button or you can launch any of the other application of Simulator Controller. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller) for more information.
  14. New car models for "Setup Advisor":
      - Assetto Corsa
        - Ferrari 458 GT3
		- McLaren 650s GT3
      - Assetto Corsa Competizione
	    - KTM X-Bow GT4
  
  Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-421), especially for the changes in the Pitstop MFD handling in ACC.

## 4.2.0.0-release 06/17/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. An extended integration of *Assetto Corsa* is now available:
     - Jona, the Virtual Race Engineer is aware of *Assetto Corsa* and can handle a pitstop automatically.
     - A number of actions are available in the "Pitstop" and "Assistants" modes.
     - "Simulator Setup" can be used to configure the *Assetto Corsa* integration.
     - Please see the [fully revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-ac) for the "Assetto Corsa" plugin for more information.
  4. "Setup Advisor" handles *Assetto Corsa*. Setups can be loaded, edited, compared and merged.
  5. The settings in the "Session Database" has been renamed and reordered to create groups and make things more clear.
  6. Fixed german voice output for the Spotter, so that "... in Sektor Erster" is now "... im ersten Sektor".
  7. Changed the grammars for all Assistants, so that lap times are now announced in a "X minutes YY.Z seconds" format.
  8. Yellow flag warnings, which are cleared rightaway (< 2.5 seconds) will be suppressed by the Spotter.
  9. Updated the RaceRoom Racing Experience meta and car data to the latest version.
  10. Added generic support for *Assetto Corsa* to "Setup Advisor".
  11. New icons for Stream Deck for *Assetto Corsa* "EngineRepair" pitstop action.
  11. More car specific rules in "Setup Advisor" for:
      - Assetto Corsa
        - Ferrari 458 Italia
		- Lotus Exos T125
      - Assetto Corsa Competizione
	    - Mercedes AMG GT4
  
  Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-420), since there might be manual updates to your local configuration necessary, when you want to use the *Assetto Corsa* integration with your Stream Deck.

## 4.1.9.0-release 06/10/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. [Comparing and merging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#comparing-car-setups) setups is now supported in "Setup Advisor".
  4. The Virtual Race Strategist will give you now a post race summary. It will be very honest, so if you feel offended, you can disable it in the [configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist). But an AI doesn't lie, does it?
  5. Reversed sign of laptime delta in all apps. Faster cars will have a positive delta, slower cars a negative one.
  6. The Spotter-AI has been trained to detect several typical race situations and can advise you how to best react there. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#alerts--information) for more information.
  7. New "Consistency" Report in "Race Reports" and "Race Center". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) for more information.
  8. Reduced volume of radio click noise for Race Assistant speech output. Thereby, the overall volume of the speech output has become louder, so you might have to adjust your volume balancing between your sim(s) and the Assistants.
  9. Fixed a bug in "Setup Advisor" where settings were off by one for some cars.
  10. Detect current simulator, car and track in "Setup Advisor", when launched in-game using the *openSetupAdvisor* action.
  11. More car specific rules in "Setup Advisor" for:
      - Nissan GT-R Nismo GT3 (2018)
      - Audi R8 LMS GT4
	  - Maserati Granturismo MC GT4

## 4.1.8.0-release 06/03/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Increased precision of Spotter opponent delta information. See the extended [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#opponent-and-delta-information) for more information.
  4. Added new Spotter advises and extended information about opponent performance.  
     - [Thresholds for delta information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#opponent-and-delta-information) can be defined in the "Session Database" settings.
	 - [Update frequency](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) can be configured for each sector, beside each one, two, three or four laps.
  5. Spotter alert responsiveness has been increased even further by eliminating outdated warnings waiting in the queue.
  6. Number input dialog will be opened instead of the context menu, when clicking on a control with the Control key pressed in the [Controller Layout Editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#controller-layouts).
  7. The term "distance information" for the Spotter has ben renamed to "delta information" to better reflect the actual meaning. Keep this in mind, when you enable or enable this type of announcement using a voice command.
  8. Additional car specific rules in "Setup Advisor" for:
	 - BMW M6 GT3
	 - Aston Martin Vantage AMR GT3
	 - Ginetta G55 GT4
	 - Aston Martin V8 Vantage GT4

## 4.1.7.2-release 05/31/22

  1. Fixed a critical bug where under special conditions the Race Engineer was unable to calculate refuel amount.

## 4.1.7.1-release 05/27/22

  1. Fixed a critical bug in "Simulator Setup", where configured function triggers were "forgotten".

## 4.1.7.0-release 05/27/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Fixed unexpected translation of Grip status in ACC shared memory.
  4. Optimized linear regression for tyre pressure correction between drivers in "Race Center".
  5. New settings in "Session Database" to enable/disable telemetry and tyre pressure data collection during Practice, Qualifaction and Race sessions.
  6. New settings in "Session Database" to enable/disable pitstop automation support during Practice, Qualifaction and Race sessions.
  7. Improved UDP connection stability (for position data) after restart of ACC.
  8. Spotter warnings now mute other voice output **when** *NirCmd* is installed.
  9. Alternative login dialog for name and password when connecting to Team Server (hold the Ctrl key while clicking on the "Key" button).
  10. Engineer now asks, before he replans an already planned pitstop.
  11. New report in "Race Reports" and "Race Center" with lap times for all cars and laps. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) for more information.

## 4.1.6-release 05/20/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Several bug fixes in "Race Center".
  4. Air and track temperature are now shown in lap report in "Race Center".
  5. Extended strategy validation in "Strategy Workbench".
  6. Extended strategy optimization in "Strategy Workbench" and "Race Center".
  7. Fixed the handling in "Desktop" voice recognition for the predefined (Number) and (Digit) variables - no longer "Cannot register voice command ..." errors shown on startup.
  8. Made Spotter warnings much faster and more responsive.
  9. Added three more car rules to "Setup Advisor".
  10. A new report "Setups Summary" is available in "Race Center".
  11. Driver specific tyre pressures can now be cloned in "Race Center".
  12. Simulator Controller now opens an info window when a valid team session configuration is found and activated.
  
  Please also take a look on the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-416) and check whether any manual updates to your local configuration might be necessary.

## 4.1.5-release 05/14/22

  1. Fixed a timing and redrawing problem in the "Session Database" tool.

## 4.1.4-release 05/13/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Delta time calculation by the Spotter is much more precise now.
  4. Spotter warnings are much faster now due to caching of the generated sound files.
  5. Session Database location is now configurable. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#database-configuration) for more information.
  6. The Virtual Race Engineer can be asked about the amount of remaining fuel, like: "How much fuel is remaining?".
  7. The same can be achieved using the new *InformationRequest* action *FuelRemaining*, which is available for all simulator plugins and the "Race Engineer" plugin. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  8. Larger window sizes for "Strategy Workbench" and "Race Center" (as requested by the community).
  9. Two new icons for Stream Deck to support the new action *FuelRemaining*.
  10. New preset for "Simulator Setup" to always enable Team Server.
  11. Fixed Spotter not starting in AMS2 after the formation lap.
  12. Base setups can be configured for each participating driver in "Race Center". This information is used to adjust tyre pressures, when the driver changes for the next stint. See the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-driver-specific-tyre-pressures) for more information.
  13. New settings in "Session Database" to specifiy tyre pressure correction values for changes in ambient and track temperatures.
  14. Track specific fuel capacity will be saved to the session database by the Race Engineer at the end of the session, when saving settings is configured.
  15. Additional car specific rules in "Setup Advisor" for
  
      - Bentley Continental GT3 (2018)
      - Lamborghini Huracan GT3 EVO
      - Porsche 991 II GT3 R
      - BMW M2 CS
  
  Please also take a look on the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-414) and check whether any manual updates to your local configuration might be necessary.

## 4.1.2-release 05/06/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support track choice for ACC cars in "Setup Advisor".
  4. Improved responsiveness of voice generation and recognition. Reaction time is now twice as fast in many cases.
  5. Improved handling of formation lap and post race lap in strategy devlopment.
  6. Spotter might give tactical advises before overtaking a car.
  7. Spotter informs that the car in front is to be lapped.
  8. More detailed rear car alert by Spotter incl. warning for possible dive bombs.
  9. Rule supoort has been to "Setup Advisor" for several additional cars.
  10. Race Engineer no longer complains about zero fuel when parking in the pitlane in ACC.
  12. Fixed the Spotter greeting erroneously with a strategy comment.
  13. Spotter tells you whether car in front is for position or lap down or lap up.

## 4.1.1-release 05/01/22

  1. Fixed a critical bug, when cold tyre pressures are not initialized correctly.

## 4.1.0-release 04/29/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support "No Tyre Change" for post-preparing pitstop option changes.
  4. Support for multiple hotkeys in "Simulator Setup".
  5. Stability improvements in "Race Center".
  6. New Stream Deck icons for Chat messages.
  7. Support editing of validation rules directly from "Strategy Workbench". See the revised [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#integrating-into-strategy-workbench) for more information.
  8. "Setup Advisor" is now able to [load, modify and save setup files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#managing-car-setups) for *Assetto Corsa Competizione*.
  9. Track names are now displayed in non-internal format for ACC tracks.

## 4.0.9-release 04/22/22

  1. Prevent installation to non-empty directories.

## 4.0.8-release 04/22/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Fixed fuel consumption displayed as negative after pitstop in "Race Center".
  4. Default value for the "teamServer:" plugin argument is now *Off* in a new generated configuration. Please pay attention to this, when generating a new configuration using "Simulator Setup" and create an action binding for the "TeamServer" action for at least one of the Virtual Race Assistants.
  5. Fixed a critical stack overflow with blocking error message in the Race Assistants, when corrupt data is processed from the ACC server backend.
  6. All new icon set for Stream Deck actions. Included as a preset in "Simulator Setup".
  7. Race Engineer now acknowledges any additional change of pitstop options after a pitstop has been prepared in ACC or RF2.
  8. Fixed a bug in in "Simulator Setup", so that "Assetto Corsa" is registered as a valid simulator.
  9. Changed update frequency for icons on large or multiple Stream Decks in order to increase responsiveness.

## 4.0.6-release 04/15/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Optimized pitstop search pictures for R3E.
  4. Fixed initialization of pitstop service order in "Strategy Workbench".
  5. Optimized chart drawing algorithms.
  6. Better validation for number entry fields.
  7. Support for extensive logging for Team Server and "Race Center" (use "Info" log level).
  8. Display lap times in "M:SS.s" format in all applications of Simulator Controller.
  9  Display initial cold pressures in "Race Center" after first lap.
  10. Increased robustness of ACC Pitstop fallback algorithm.
  11. Improved handling of background data processing in "Race Center".

## 4.0.4-release 04/08/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Improvements and fixes in several edge cases with required pitstops for "Strategy Workbench".
  4. Many new presets for the ACC pitstop search images thanks to contributions from iEnki (Robert Deutsch), Manfred Gnadl and Martin Moser.
  5. Fixed broken position reporting for RaceRoom Racing Experience.
  6. A couple of minor fixes and improvements for "Race Center".
  7. Performance improvements for the Virtual Race Strategist by 20% for standings, track gap and future predictions.
  8. Initial preparation for sector based timing in the shared memory interfaces.
  9. More frequent position and gap update for Race Strategist and Race Spotter.
  10. Fixed a bug where the Spotter got into an endless loop announcing pit window in Assetto Corsa Competizione.
  11. Allow the Spotter to give the same information as the Strategist about track and standings gaps, the current race position and so on. These commands are available as voice commands and also as actions for your hardware controller. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) for more information, which commands are available.
  12. [Experts Only] The translation management for various items has been reworked. Only changed values are stored in the local configuration database. This affects the following categories:
  
      - Translations (handled by the [Translation editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor))
      - Phrase Grammars (handled as plain text file)
      - Controller Action Labels (handled by the [Action Labels & Icons editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons))
      - Controller Action Icons (handled by the [Action Labels & Icons](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons))
      - Settings Definition Files for "Session Database" (handled as plain text file)
  
  Please also take a look on the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-404) and check whether any manual updates to your local configuration might be necessary.

## 4.0.2-release 04/01/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full support for cloud based voice recognition. Use *Azure Cognitive Services* for the best possible recognition quality. You can choose in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control), which recognition language you want to use (as long as a grammar for this language is available).
  4. The selection of the new cloud based voice recognition is also possible using the [plugin parameters](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) of the Virtual Race Assistants.
  5. A new preset function in "Simulator Setup" let you pre-install Button Box and Stream Deck layouts and gives you control over some very special configuration options.
  6. The Race Spotter will start with its announcements when the race is started. Implemented for all simulators.
  7. [Experts Only] The [patch mechanism](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#patching-the-configuration) for configuration files generated by "Simulator Setup" has been extended.
  8. [Experts Only] The phrase grammars have changed and were extended. So, if you have your own files here, you have to merge your changes. A new placeholder variable "(Digit)" has been introduced for single-digit numbers. Use it whereever possible, it will increase recognition performance.
  
  Please also take a look on the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-402) and check whether any manual updates to your local configuration might be necessary.

## 4.0.0-release 03/25/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full implementation of the database consolidation and distribution process. Depending on your own consent, you will receive new tyre pressure information or even shared car setups from the community every 2 days. Because of this, you will be asked to renew your consent for sharing your own data, because you will only receive anything, if you are also willing to share.
  4. New voice commands for the Virtual Race Spotter and the other Assistants to enable or disable announcments and warnings while out on the track. You can say, for example: "No more weather warnings please" or "Please give me blue flag warnings". See the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#enabling-and-disabling-specific-warnings-and-announcements) for more information.
  5. Support for .NET compatible TTS 5.1 voices for voice output. See the revised documentation for [voice control](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) configuration for more information.
  6. Support for an additional voice recognition framework, which provide a much better recognition rate and quality, as long as you have a decent voice audio quality (for example when using a headset). The changes are documented [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) as well.
  7. Renamed plugin parameter "raceAssistantService" to "raceAssistantSynthesizer" and introduced new parameter "raceAssistantRecognizer" for all Race Assistant plugins. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  8. Integrated the new cars of the Challenger DLC into the car model file for ACC.
  9. Updated the spectator overlay file for R3E to reflect the latest additions in RaceRoom Racing Experience.
  10. Spotter side proximity warnings may now be disabled as well.
  11. Fixed a bug in race report viewer, when a report shows up as empty although correct data is available.
  12. [Developer] Added a class library for handling complex FTP operations.
  
  Please also take a look on the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-400) and check whether any manual updates to your local configuration might be necessary.

## 3.9.8-release 03/18/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Finetuning for average lap times in Strategy simulation.
  4. Renamed the application "Setup Database" to "Session Database".
  5. Renamed action function "openSetupDatabase" to "openSessionDatabase". Also renamed the similar named plugin parameters of the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) and ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugins.
  6. Comprehensive revision of the session database backend to support the new race settings model.
  7. Completely new [handling of race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings-1) at the start of a session. For the moment, the saving of race settings at the end of a session is disabled. This will be enabled again with the next release.
  8. All new user interface for "Session Database". See the fully [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--session-database) for more information.

## 3.9.6-release 03/11/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support for *Intermediate* tyres in all parts of Simulator Controller.
  4. New ["Import from Strategy" command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#rules--settings) in "Strategy Workbench" to initialize all Rules & Settings from a currently loaded strategy.
  5. Support for [Stint time variation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#simulation) based on tyre usage dependent lap time degradation in Strategy simulation.
  6. New settings for [disallowed refueling and disallowed tyre change](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#rules--settings) in Strategy simulation.
  7. Support for [scenario validation rules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#scenario-validation) in Strategy simulation. These rules, which can be created or changed by the user, are based on the logic programming language *Prolog*.
  8. Significant performance improvements by a factor of 10 in Strategy simulations.
  9. Full handling of restricted tyre sets in "Race Center" and special validation rules, when a strategy gets adopted to the current race situation.
  10. Improved data quality for missing laps in "Race Center".
  11. Initial preparation for simulation and car specific rules in "Setup Advisor".
  12. Fixed some rules in "Setup Advisor".
  
## 3.9.4-release 03/04/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New tool ["Setup Advisor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor), which generates recommendations for changing the setup options of a car based on problem descriptions provided by the driver.
  4. New [plugin parameter "openSetupAdvisor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for "Race Engineer" plugin.
  5. New [action function "openSetupAdvisor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions).
  6. Frequency of blue flag warnings has been drastically reduced.
  7. Fixed sporadic cacophony of Race Assistants voice output.
  8. Support for tyre compound color variation in Strategy simulations. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#simulation) for more information.
  9. Support to restrict the number of tyre sets available for the different tyre compound in Strategy simulations. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#rules--settings) for more information.

## 3.9.2-release 02/25/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Pre-Alpha version of "Setup Advisor". No documentation and not feature complete at all.
  4. Pitstop settings and Strategy updates are synchronized in Race Center every 10 seconds now.
  5. Fixed a crash when using ICON instead of JPEG or PNG files for icons in Stream Deck. Please update the plugin in the Stream Deck directory.

## 3.9.1-release 02/18/22

  1. Critical fixes in several grammar files
  
## 3.9.0-release 02/18/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support for rFactor 2 has been added for the new Spotter Assistant.
  4. The capabilities of the Spotter has been extended again. It now informs about your performance after the first few laps and also periodically during the race. It also announces you the final laps. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#alerts--information) for more information.
  5. Fix for wonky Spotter side alerts in RaceRoom Racing Experience.
  6. Improved the Strategy Simulation by introducing an alorithm which includes tyre wear, fuel level induced lap time variations and the effects of ECU maps at the same time.
  7. Introduced new tyre compound types (colors) in all applications. Yellow, Green, Soft, Medium and Hard compounds are now supported, when the corresponding simulation supports them.
  8. The Race Spotter can now be fully configured with regards to the issued warnings and announcements. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) for more information.
  9. Import of cold tyre pressures is now supported for iRacing in "Race Settings" and the Race Assistants.
  10. Fixed a bug in the new image search fallback algorithm for the ACC Pitstop control, where the data input took almost a minute.

## 3.8.8-release 02/11/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support for the new Spotter Assistant has been added for iRacing, Automobilista 2 and RaceRoom Racing Experience.
  4. The capabilities of the Spotter has been extended. It now supports yellow flag and blue flag warnings as well as information about pit window events. See the [expanded documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#introduction) for the Spotter for more information.
  5. New InformationRequest Action for Jona and Cato to request the current time. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  6. Improved handling in Race Reports when drivers leave before the end of the session.
  7. Fixed several bugs in iRacing Pitstop MFD control.
  8. Fixed several bugs in Automobilista 2 Pitstop MFD control.
  9. Start grid positions will be correctly reported in Race Reports.
  10. Implemented a fallback algorithm for ACC Pitstop MFD control, when the image recognition fails. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling) for more information.
  11. Fuel requirements calculation in strategy development has been improved to always take the fuel reserve into account.

## 3.8.6-release 02/04/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Extensive memory consumption reduction of all Race Assistants, especially when using the Team Server.
  4. Initial implementation of a new Virtual Race Assistant, the [Spotter Elisa](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter). The first version only supports ACC for the moment, all other Simulations will follow with the next releases.
  5. New plugin ["Race Spotter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) as the configuration interface for the Spotter, as well as the new [configuration tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) in "Simulator Configuration" to configure the statistical settings of the Spotter AI kernel.
  6. New plugin parameter "raceAssistantSpeakerVocalics" to set pitch, speed, etc. individually for each Race Assistant. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more details.

## 3.8.4-release 01/28/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Last version introduced a critical bug in "Race Reports" when switching cars. This has been fixed.
  4. Introduced data filtering in "Race Reports" for spurios average lap times, which origin from formation and post race laps.
  5. Strategy Simulation now includes a tyre degradation model based on telemetry data.
  6. Improved control for pitstop service time calculation.
  7. Improved calculation of overtake deltas.
  8. A fixed number of required pitstops can be defined for a strategy simulation, when a required pitstop is chosen in the "Rules & Settings" tab.
  9. Introduction of a traffic model using Monte Carlo alogrithms for taffic density prediction as well as over- and undercut optimization in "Race Center". See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#monte-carlo-traffic-model) for more information.
  10. Reduced frequency of damage reporting by Jona. One a damage had been reported, any subsequent damage will be included in the currently running lap time analysis.

## 3.8.2-release 01/07/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Defining keyboard and other generic triggers are now supported in "Simulator Setup".
  4. Fixed Pitstop automation blocking Alt-Tab in ACC.
  5. Optical enhancements in "Race Center" HTML output.
  6. Support keyboard and generic trigger in "Simulator Setup".
  7. New parameter "pitstopMFDMode" for all simulator plugins, which gives you several different communication modes between Simulator Controller and the various simulation games. this greatly enhances the compatibility and stability of the pitstop automation. See the revised [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-4) for more information.
  8. Lots of small fixes for Team Server and "Race Center". Handling of incomplete data, for example missing stints and/or laps due to connection issues, has been greatly improved.

## 3.8.0-release 12/31/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Added support for pre-race stint planning in "Race Center". See the new [Session & Stint planning](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#session--stint-planning) documentation for more information.
  4. New [plugin parameter "openRaceCenter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) for the "Team Server" plugin. This parameter is identical to the same parameter already defined for the "Race Strategist" and "Race Engineer" plugins and is therfore not much more than a convinience feature.
  5. "Strategy Workbench" can now create strategies even without telemetry data for a specific car and track.
  6. Fixed a bug, where telemetry data were not collected during practice sessions.

## 3.7.8-release 12/24/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Fixed a bug in Telemetry Provider for RaceRoom Racing Experience, which may result in error messages during the startup of R3E.
  4. Complete new and optical pleasing table layout in HTML vievs in "Strategy Workbench" and "Race Center".
  5. Going to replay in a paused game no longer ends the session in *Assetto Corsa Competizione*.
  6. Detailed standings and gap report in "Race Center" when clicking on a lap in the lap list.
  7. Full refactoring and partial rewrite of the strategy development and handling algorithms.
  8. Added strategy handling and updating to "Race Center". See the updated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#strategy-handling) for more information.
  9. Optimized Race Assistant behaviour when no voice recognition is enabled - more interaction possible using hardware controller.

## 3.7.6-release 12/17/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Almost fully implemented "Race Center" (formerly "Team Dashboard") for multiplayer endurance races and professional stint races with engineer support by a team mate. See the complete new and extensive [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#race-center) for more information.
  4. New [plugin parameter "openRaceCenter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for "RaceEngineer" and "Race Strategist" plugins.
  5. New ["openRaceCenter" action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) to trigger opening the "Race Center" from external event sources.
  6. Fixed several critical bugs in "Server Administration".
  7. Added the new BMW M4 GT3 to the list of known ACC cars.

## 3.7.4-release 12/06/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New "Server Administration" application for [Team Server administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration).
  4. New application ["Team Dashboard"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#race-center) supports pitstop settings preparation by a team member in multiplayer endurance races.
  5. [Developer]Added *parseConfiguration* and *printConfiguration* functions.

## 3.7.2-release 12/03/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full refactoring of the Setup Database persistant storage - now uses the Database engine.
  4. Hundreds of bug fixes for Team Server.
  5. Vastly reduced memory consumption of Assistants in endurance races.
  6. Fixed pitstop handling for ACC 1.8.
  7. Fixed a bug in "Tactile Feedback" plugin with effect actions which were not associated correctly with hardware dials.
  8. Administration backend for "Team Server". Frontend will follow with the next release.

## 3.7.1-release 11/26/21

  1. Critical bug fixes for "Simulator Setup"

## 3.7.0-release 11/26/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New server based solution for team endurace races. See the all [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server) for more information.
     a. New ["Team Server" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-team-server) in "Simulator Configuration" for managing your Teams, Drivers and Sessions.
	 b. New ["Team" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-team) in "Race Settings" for all team member to configure their role in a team session.
  4. The new "Team Server" plugin as well as the "Race Engineer" and the "Race Strategist" plugins now allow to specify the initial operation state without supplying a function to be triggered from a hardware controller.
  5. Major bug fixes in "Simulator Setup"
	 a. Fixed a bug Stream Deck configuration support
	 b. Fixed an error in handling of labels "Simlator Setup" which was introduced with the last release.
	 c. Fixed several other mostly minor bugs
  6. Fixed an evaluation bug in "Simulator Workbench" when comparing talemetry-based scenarions with fixed-value scenarios.
  7. Initialize name of "unnamed" strategies with the label of the scenario in "Strategy Workbench".
  8. The configuration of voices for different languages has been heavily improved. For Azure, the system will now supply you a list of **all** available voices for the chosen language and the configuration of locally installed voices now also supports third party voice packs, as long as they adhere to the Windows SPVoice standard.

## 3.6.8-release 11/12/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full support for graphical configuration of the Stream Deck integration. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) for more information.
  4. "Simulator Configuration" and "Simulator Setup" has been revised to include full support for Stream Deck configuration.
  5. New tool to edit controller action labels and icons as part of the new configuration process for Stream Decks. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) for more information.

## 3.6.6-release 11/05/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Much more sophisticated tyre compound handling in changing weather conditions.
  4. Initial support for the Stream Deck controller. You can associate controller actions with Stream Deck Actions, which will be automatically kept in sync. Also, you can associate an icon with each controller action, which will be shown on the Stream Deck. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) for more information.
  5. Renamed "Controller Plugin Labels" file to "Controller Action Labels". Important: Take a look at the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-366), if you have changed labels in the past.
  6. Introduced "Controller Action Icons.XX" file in order to support action specific icons on the Stream Deck controller.
  7. With the new plugin parameter [*udpConnection*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-4) for the ACC plugin to support non-standard UDP connect strings for the broadcasting interface.
  8. ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development) supports a new command to remove faulty data from the telemetry database.
  9. Only valid laps will be written to the telemetry database and will be used for statistical tyre pressure data.
  10. Support for binary functions for the effect intensity manipulation in the "Motion Feedback" plugin. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-2) for more information.
  11. [Developer only] Full refactoring of the *ButtonBox* class which is now the [*FunctionController*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-functioncontroller-extends-configurationitem-simulator-controllerahk) in [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk) in order to support the new Stream Deck integration.

## 3.6.5-release 10/22/21

  1. Fixed a critical bug in Strategy Workbench due to incomplete build rules
  
## 3.6.4-release 10/22/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Improved corner case handling and stint optimizations in strategy development.
  4. Variation of fuel consumption, initial fuel level and tyre usage is now possible in strategy simulations. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#simulation) for more details.
  5. Strategies created and exported by the "Simulator Workbench" will be automatically picked up by Cato in matching race session.  Cato will instruct Jona for all Pitstops defined in the strategy. See the [documentation on strategy handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) of the Virtual Race Strategist for more information.
  6. Many new phrase grammars for Cato to handle all the new strategy stuff. See the [phrase grammar definition files](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Assistants/Grammars) for more information.
  7. New action "StrategyCancel" for "Race Strategist" and all simulator plugins to cancel a strategy, that is no longer applicable, from the Button Box.
  8. New "InformationRequest" commands "StrategyOverview" and "NextPitstop" for "Race Strategist" and all simulator plugins to request information about the current strategy or the upcoming pitstop, as defined in the strategy, from your Button Box.
  9. Coloured many application icons

## 3.6.2-release 10/15/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Number of data fields for a simulated strategy has been vastly expanded.
  4. "Strategy Workbench" now supports loading and saving of strategies.
  5. Initializing a various fields in the "Strategy Workbench" from *Race.settings* files, from a running simulation or from data acquired from the telemetry information is now supported.
  6. Comparison of strategies is now supported in the "Strategy Workbench".
  7. Defined pitstop rules are now taken into account for strategy simulations.
  8. Expanded [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development) to reflect the new functions of the "Strategy Workbench".

## 3.6.0-release 10/08/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Important fix for handling startup of SimFeedback by the "Motion Feedback" plugin.
  4. Initial strategy simulation based on telemetry data for the "Strategy Workbench". The tool is still in an early stage of development and the functionality might change with future releases. A very rudimentary [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development) can be found in the chapter on the Virtual Race Strategist. This documentation will be completed with the upcoming releases.

## 3.5.9-release 10/01/21

  1. Fix for automated save of settings by Race Assistants

## 3.5.8-release 09/24/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Renamed "Setup Database" repository to "Database".
  4. New "Strategy Workbench" tool. Currently undocumented and not much more than an Alpha release.
  5. "Race Strategist" can now save race statistics for later use in the "Strategy Workbench". See the [revised configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) for the "Race Strategist" plugin for more information.
  6. New [plugin parameter "openStrategyWorkbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for "Race Strategist" plugin.
  7. New ["openStrategyWorkbench" action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) to trigger opening the "Strategy Workbench" from external event sources.
  8. Fixed "Setup Wizard" to correctly generate the "Pedal Calibration" configuration.
  9. [Developer] New lightweight Database library to handle simple in-memory or persistent data sets.

## 3.5.6-release 09/10/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Three new reports for the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) tool:
     - Overview - as the name says, gives you an overview over the grid (starting positions, best and average lap times and race result.
	 - Car - specific data for your car, weather conditions, mounted tyres, elecronic settins, lap times and pitstops.
	 - Driver - compare the different drivers on the grid regarding potential, race craft, speed, consistency and car control.
  4. Improved "Pace" report including median and quartile calculation.
  5. Various usability improvements for the "Race Reports" tool, incl. better selection of reports based on car and track grouping.
  6. [New "Call" command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) allows you to actiavte the listen mode of a Race Assistant by the touch of a button on your Button Box.
  7. Improved reliability for voice control of multiple Race Assistants, when Push-to-Talk is not used.
  8. Optimized language handling for SAPI voices to support non-Microsoft language packs.

## 3.5.4-release 09/03/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) tool. This tool will bring post race analysis to Simulator Controller.
  4. New options for the [Race Strategist configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) to support the "Race Reports" tool.
  5. More confirmation questions when deleting settings or setups in the "Setup Database" tool.

## 3.5.2-release 08/27/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New automatic download for Simulator Controller software and support for installation either as fully registered Windows application or as portable application. The beginning of the [Installation & Configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) has been completely rewritten to give you the necessary background information.
  4. Fully automatic update package download and installation process.
  5. Change already prepared Pitstop settings created by the Race Engineer with your Button Box. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop) for Jonas pitstop handling for more information.
  
## 3.5.1-release 08/21/21

  1. Bugfix for missing Button Box actions

## 3.5.0-release 08/20/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. All new Setup Wizard, which greatly flattens the learning curve, while installing and configuring Simulator Controller. Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool) for more information.
  4. Button Boxes can now be invisible to define and group controls, which are located on non-typical controllers like steering wheels.
  5. For the introduction of the new Setup Wizard, the localized Plugin Labels has been extensively reworked. Please see the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-350), if you have changed the default Plugin Labels and want to preserve your changes.
  6. The "System" plugin now supports a [parameter *launchApplications*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration) to specify the applications to be used for the "Launch" mode.
  7. The Push-To-Talk function now emits a short sound, when the listen mode is activated.

## 3.3.1-release 07/25/21

  1. Bugfix for voice service default selection

## 3.3.0-release 07/23/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full support for cloud based voice synthesis. Use *Azure Cognitive Services* for the best sound, most natural speech generation. You can choose in the [configuration process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control), which speech synthesizer engine you want to use.
  4. Support for audio post processing to create the typical sound of a in-car team radio. You have to install a small audio manipulation utility to be ready for this, please see the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-330) for more information.
  5. A lot of refactoring and file location changes, which will most likely be completely transparent for you, unless you are a developer.

## 3.2.2-release 07/16/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. More information is supplied by Cato. You can ask for gaps to other cars either in relation to the standings or in relation to the positions on the track. See the [command phrases](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Assistants/Grammars) for more information.
  4. New plugin arguments for ["Race Strategist" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist). You can trigger the recommendation of a pitstop lap by your hardware controller now.
  5. Accept & Reject plugin actions now work always for the currently focused voice Assistant.
  6. New information actions for ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) and ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugins. With those you can request almost any information regarding your car state or the race situation with the press of a button on your hardware controller.
  7. New ["Assistant" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-assistant) for all simulator plugins, which may be used to group all Assistant actions, like information requests or pitstop planning, into one dedicated layer for your hardware controller.
  8. Many of the plugin parameters for the ["Race Engineer" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) and ["Race Strategist" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) have been renamed.
  9. Support for the new repair options in [*RaceRoom Racing Experience* Pitstop MFD](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1). Please note that "Repair Bodywork", "Repair Front Aero" and "Repair Rear Aero" can only be toggled together for the moment.
  10. [Developer] Refactoring of Assistant plugins and introduction of *RaceAssistantPlugin* base class.
  11. [Developer] Automated unit tests for *RaceStrategist* class.

## 3.2.0-release 07/09/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New fully integrated telemetry provider for *Automobilista 2* (see [AMS2 SHM Reader](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Foreign/AMS2%20SHM%20Reader)).
  4. Full support for Jona and Cato incl. automated pitstop handling for *Automobilista 2*.
  5. [New "Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-5) for the "AMS2" plugin to control the pitstop settings from your hardware controller.
  6. New [controller action "execute"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) can integrate and control each Windows application from your hardware controller.

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
     - Refactored *RaceEngineerSimulatorPlugin* into *RaceAssistantSimulatorPlugin*, which now can handle multiple Race Assistants.
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
  5. Race Engineer Settings can now be stored also in the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-session-database) for future use.
  6. Before beginning a session, the best matching of the Race Engineer Settings can be selected from the setup database depending on the session duration. This settings will be activated for the next session, optionally together with the tyre pressures for the current environmaental conditions.

## 3.0.4-release 05/23/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Full rework of fuel consumption projection after a pitstop.
  4. Simulator car setup files can be stored together with additional notes in the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-session-database) for future use.
  5. The setup database consent has been extended to give [separate consents](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database) for tyre pressures and car setup information.
  
## 3.0.3-release 05/16/21

  1. Critical bugfix for remaining fuel caluclation after a pitstop in races longer than an hour
  
## 3.0.2-release 05/14/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Tyre pressures can be [transfered from the setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-session-database) to the *Race Engineer Settings* tool.
  4. Jona can consult the setup database for a second opinion for tyre pressures.
  5. [New switches](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-pitstop) in *Race Engineer Settings* to control the different strategies that Jona uses to come up with target tyre pressures.
  6. Refactoring of the setup database code and some file relocations.
  7. New Unit Tests for the setup database.

## 3.0.0-release 05/07/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Graphical interface for querying the setup database (see the updated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-session-database) for more information)
  4. [New plugin parameter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin to open the setup database query tool. If a simulation is currently running, most of the query arguments will already be prefilled.

## 2.8.6-release 04/30/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Low level integration of *iRacing* telemetry information (see [IRC SHM Reader](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Foreign/IRC%20SHM%20Reader/IRC%20SHM%20Reader))
  4. Renaming of selected shared memory data fields
  5. ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-2) for *iRacing* plugin
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
  4. [A new plugin argument](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the *Assetto Corsa Competizione* plugin allows you to open the Race Engineer settings dialog from your hardware controller (moved to "Race Engineer" plugin in Release 2.8)
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
     - Full statistical lap time analysis after accidents
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
  4. First version of the hybrid rule engine, which will be used to implement the AI based Race Engineer

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
