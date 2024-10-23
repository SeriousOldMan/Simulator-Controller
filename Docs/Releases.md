## 5.9.5.0-release 10/25/24 (planned)
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A couple of fixes in the different Assistant grammars.
  4. A channel for the elapsed time since start of the lap has been added to the telemetry system.
  5. A new filter smoothes out inconsistent telemetry values reported by some simulators.
  6. A section editor has been added to the track map viewer in the "Session Database" (on the way to telemetry based live coaching). The arrangement of the different tabs in the "Session Database" has changed a bit in the course of this change. Please see the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#track--automation) for more information.
  
     It is strongly recommended to rebuild all track maps with this version, so that the track starting point is as close as possible to the real start/finish line. Thias was not important in the past and the track recording started anywhere. Please see the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-595) for instructions how to recreate the track maps.

IMPORTANT: Please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-595), for information how to rebuild the track database.

## 5.9.4.0-release 10/18/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed standings handling and race reports for grids where cars with duplicate race numbers are present. This can happen in *RaceRoom Racing Experience*, for example.
  4. Fixed a rare bug, which resulted in incorrect position information announced by the Spotter for *RaceRoom Racing Experience*.
  5. Fixed a bug, that let the Spotter to report on a focused car although no car was focused. This could happen for cars with the race number **0** (weird to use **0** as race number, isn't it?).
  6. A complete new layout system has been implemented for the Telemetry Viewer. You now can select the channels, you are interested in and arrange them according to your preferences. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#telemetry-viewer) for more information.
  7. Telemetry graphs can now be shifted horizontally to match track position of telemetry data from different sources.
  8. Zooming of telemetry graph is now possible both horizontally and vertically.
  9. Selected zoom factor will now be stored for telemetry graphs.
  10. Lap telemetry data can now also be imported from MoTeC. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#telemetry-viewer) for more information.
  11. Multiple lap telemetry data, setups or strategies can be uploaded at once in "Session Database"
  12. Uploading telemetry data in the "Session Database" can also read MoTeC and Second Monitor files.
  13. A new setting for the steer lock of a car has been integrated in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings). This is used to normalize the steering angle when importing telemetry data from MoTeC, for example. If this setting is not set, the latest value used in the "Setup Workbench" for this car will be used.
  14. The announcement of the last lap times of the cars around you by the Spotter has been moved from the "Session Information" group to the "Opponent Information" group and can be enabled/disabled together with ´gap and delta information in the configuration.
  15. Reduced frequency of superfluous proximity alerts by the Spotter.
  
## 5.9.3.0-release 10/11/24

IMPORTANT READ: A nasty bug had been introduced with the last release, which for some user broke the telemetry / issue analyzer in "Setup Workbench". A very early version of "Setup Workbench" stored files in *[Documents]\Simulator Controller\Garage\Definitions* for personal modification. This was no longer necessary with a later release, but the files were left in place. They now collide with the latest version of "Setup Workbench".

What does that all mean for you:

1. If you have never modified those files, you are fine. Everything is back to normal again.
2. If you have modified at least one of those files, for example to introduce a new setting for a simulator, you will find your files now in *[Documents]\Simulator Controller\Garage\Definitions\Backup* where they do no harm. Please read the documentation about [extending the "Setup Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#extending-and-cutomizing-setup-workbench) for information how to bring your changes back in.

And now back to the usual Release Notes:

  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a rare bug, which prevented the selection of start stint pressures in "Team Center".
  4. Fixed an error in strategy simulation which did not respect the stint timer, when running an autonomous Strategist.
  5. Fixed saving of telemetry data imported from "Second Monitor".
  6. Fixed a bug, that causes action definitions and settings to get lost in the Assistant Booster configuration.
  7. Fixed enabling and disabling of *Reasoning* booster in "Simulator Setup".
  8. Fixed telemetry / issue analyzer for "Setup Workbench" (see above).
  9. The Spotter now compares the drivers lap time to that of the opponents when announcing recent lap times.
  10. The window resizing has been optimized for "Session Database".
  11. Weather-specific personal best lap times retrieved from the session database are now passed to the LLM of the *Reasoning* booster for decision support.
  12. Using new settings in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) you can specify the ideal tyre temperatures for the different tyre compounds. They can be used to trigger tyre temperature related pitstop recommendations.
  13. Updated car meta data for *RaceRoom Racing Experience* to the latest version.

IMPORTANT: Please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-593), if you have configured the *Reasoning* booster for any of the Assistants.

## 5.9.2.2-release 10/04/24
  1. Fixed a critical bug which prevented the Strategist to announce an upcoming weather change.

## 5.9.2.1-release 10/04/24
  1. Fixed a critical bug which prevented the acquisition of standings data from the simulator.

## 5.9.2.0-release 10/04/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a critical bug for iRacing, which disabled the Spotter proximity alerts and flag warnings. Was *introduced* with the telemetry support 2 weeks ago.
  4. Resolved some documentation conflicts:
     - Renamed the "Telemetry Analyzer" in "Setup Workbench" to "Issue Analyzer".
     - Renamed the "Telemetry Browser" everywhere to "Telemetry Viewer".
  5. Lap telemetry data opened in the Telemetry Viewer from a source other than the current session, will now also show the driver name, if available.
  6. A third graph has been added to the Telemetry Viewer, which shows longitudinal and lateral G-Forces and also an information about the curvature of the current corner.
  7. Lap telemetry data can now be imported from "Second Monitor", a sophisticated tool developed by Matus Celko (@winzarten). See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#telemetry-viewer) for more information.
  8. The selection dialog for telemetry data now supports opening multiple lap telemetries at once by shift-clicking in the list. The file selection dialog opened by the "Open..." button also supports multi-selection.
  9. The Telemetry Viewer now can display a track map in a separate. You can click in the graph to show the corresponding location on the track map and vice versa. Only telemetry data collected with 5.9.2 and later will support this. If *WebView2* is configured as HTML Viewer in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration), it will not work yet either. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#telemetry-viewer) for more information.
  10. A rotating ball is now displayed, when the Telemetry Viewer is collecting lap telemetry data.
  11. "Setup Workbench" now also supports collecting lap telemtry data. See the [added documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#telemetry-viewer) for more information.
  12. The Track Automation state is now displayed with color coding on a Button Box. Gray if it is enabled but not yet available, and yellow if no Automation has been defined for the given track and Green, if enabled and active.
  13. The setting to startup a simulation together with Simulator Controller has been moved from the global settings of "Simulator Startup" to the Startup Profiles. Veeery useful...

## 5.9.1.0-release 09/27/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a critical memory runaway bug in certain changing weather conditions.
  4. Fixed a bug in "Solo Center", which prevented sessions with telemetry data to be saved to the session database.
  5. Optimized performance of the builtin database engine for large tables.
  6. Lap telemetry entries in the "Session Database" can now be opened in the Telemetry Browser by double-clicking on them.
  7. Significantly reduced Jitter in telemetry charts.
  8. Recording of lap telemetry data is now also supported in the "Team Center". See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#Telemetry-Viewer) for more information.
  9. Thanks to our community member @Diego Falcone Dev_Dk HawkOne we now have a full translation for the Italian language.
  10. It is now possible ot use a voice which was trained for a specific language for another language. The results are mediocre for the speech synthesizer built into Windows, but very usable for voices supplied by Azure or Google. It is kind of cool to hear an Italian speak English.
  11. [Internal] A new system process observes all user processes and immediately kills them in case of malfunction. The most important and malicious type of malfunction is too much memory consumption, for which the threshold could be defined in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration).
  12. [Internal] Added a special [credits page](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Credits) to the documentation with a tribute to all my supporters and contributors. This page can also be opened from "Simulator Startup".

## 5.9.0.0-release 09/20/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Brake ducts have been removed for *RaceRoom Racing Experience* in the meta data of "Setup Workbench", because these are not available in this simulator.
  4. Fixed the calculation of lap times and sector times for *RaceRoom Racing Experience* in all applications.
  5. Optimized colors for the "Light" UI theme.
  6. Added a complete new data category for low level car telemetry incl. a graphical browser. This is initially supported in the "Solo Center", but will be integrated into the "Team Center" as well. The future goal is to make the AI aware of this data category as well. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#Telemetry-Viewer) for more information.
  7. Lap telemetry data can be saved to and retrieved from the session database.
  8. The ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) has been extended with a section for lap telemetry data:
	 - Telemetry data can uploaded, downloaded, renamed and deleted.
	 - Export and Import support telemetry data as well.
	 - Sharing of telemetry with the Community and/or on the Team Server is supported.
	 - **The consent for sharing data will be requested again to allow you to include sharing of telemetry data**.

## 5.8.7.0-release 09/13/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed automatic pitbox request for *Automobilista 2* when a pitstop is prepared by the Engineer.
  4. Fixed invalid lap handling and reporting in *RaceRoom Racing Experience*.
  5. Fixed remaining session time for *RaceRoom Racing Experience*.
  6. Fixed preselected extensions (".solo" and ".team") when saving sessions in "Solo Center" and "Team Center". Session that already have been saved using the wrong extension will be fixed by the automatic update procedure.
  7. Full rework of the muted mode of the Assistants. The Assistants will follow a conversation, which originally has been initiated by the you, the driver, even in muted mode. And they will communicate for very important stuff like strategy adjustment by the Strategist, and so on.
  8. The [*Assistant.Speak*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions) predicate for LLM event and action rules now supports an optional argument that lets you specify that a phrase will also be spoken in muted mode.
  9. "Strategy Workbench" now remembers the choice of the selected data type in the telemetry browser.
  10. [Internal] Optimization for concurrent access to the session database.

## 5.8.6.0-release 09/06/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Renamed "Practice Center" to "Solo Center". See [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-586).
  4. Renamed "Race Center" to "Team Center". See [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-586).
  5. All graphs and reports are now redrawn live in "Solo Center".
  6. And yet another fix for the handling of used tyre sets in "Solo Center".
  7. Fixed a regression for the Spotter which prevented information about opponent lap times.
  8. Fixed aned of race detection for races with fixed number of laps in *RaceRoom Racing Experience*.
  9. Check box labels now also react to clicks in dark mode.
  10. Laps in "Solo Center" are now deselected by default, if the Strategist did not send any data for this lap. This is the case during qualification by default, but can be changed with a setting in the "Session Database".
  11. Optimized timeout handling of tooltips in "Simulator Startup".
  12. The initial position of the first stint is now displayed as the real starting position and not the position at the end of the first lap.
  13. A new version of the local LLM Runtime is available.
  14. A new LLM event "stint_ending" has been defined for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) of the Race Spotter, which is triggerd, when the current stint will end soon.
  15. [Internal] Reporting of configured but missing optional components like SoX and NirCmd has been optimized.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-586), if you are using the *Reasoning* booster or the local LLM Runtime.

## 5.8.5.0-release 08/30/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed the request of a weather related tyre change by the Strategist or the Engineer (if the Strategist is disabled).
  4. Fixed a critical bug in "Race Center Lite", that prevented loading of a session, if a connection to the particular server has never been established before.
  5. Another bug fix for the handling of used tyre sets in "Practice Center".
  6. Potentially fixed a bug that created corrupted driver names in *Automobilista 2* and *Project CARS 2*.
  7. The "Practice Center" now handles unnumbered tyre sets like Wet tyres, for example, correctly in terms of tyre usage.
  8. "Practice Center" now also can [open every report in a separate window](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#notes), similar to the "Race Center" behaviour introduced with Release 5.8.3. To open a report in a separate window, hold down the Control key while choosing the report.
  9. The team management editor in "Simulator Startup" has become a resizeable window.
  10. Removed minimize controls from several modal windows.
  11. A new LLM event has been defined for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) of the Race Spotter. "opponent_pitting" will be signalled, if the direct opponent ahead or behind is going to the pits.
  12. The LLM action "update_strategy" for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-strategist) of the Race Strategist has been extended. If the new optional lap number is supplied, the Strategist checks whether a pitstop at a given lap might be beneficial and is also allowed for the currently active strategy.
  13. [Experts] Events for the *Reasoning* booster can now also be raised for other Assistants. This opens up complete new possibilities, so that the Assistants can collaborate on a given task thereby creating complex chain of thoughts. See the updated information about *Assistant.Raise* in the [documentation for event management](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-events).
  14. [Experts] A new method has been introduced to customize the Assistant rules by placing rule snippets in an extension folder. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#customizing-the-assistant-rules) for more information.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-585), if you are using the *Reasoning* booster for the Spotter.

## 5.8.4.1-release 08/24/24
  1. Fixed a critical bug that caused the Spotter to get silent after the first lap.
  
## 5.8.4.0-release 08/23/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Significant performance improvement for the "Dark" UI theme.
  4. The last choices for the configuration of the various graphs are now remembered by the "Strategy Workbench".
  5. Using a new setting in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) you can specify in the "Session Database" for *Assetto Corsa*, *iRacing* and *Automobilista 2* the type of a track (Circuit, Rally, Hill, Street). When set to other than "Circuit", track mapping will create a non-closed track. In this case, mapping of the track will start immediately, when the car moves for the first time and will stop, when the car stops. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-types) for more information.
  6. The documentation for [Track Automations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-automations) has been extended to reflect the new "Speech" and "Audio" actions, which can be used to create pace notes and other acoustical hints for open tracks.
  7. Automatic track mapping can now be enabled or disabled in various ways, whichever suits your working style best. Default is "On" as before, but this is helpful, if the starting procedure of a non-circuit track requires to roll forward into the starting box.
     - The Tray menu of the "Simulator Controller" background process now contains an item for *Track Mapping*.
     - New controller action ["TrackMapping"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) for the Race Spotter plugin, which toggles the track mapping on / off.
	 - New [controller action functions *enableTrackMapping* and *disableTrackMapping*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions), which can be used to automate the track mapping.
	 - The *Conversation* booster for the Race Spotter supports starting and stopping the track mapper by voice command (see below).
	 - Track mapping can also be enabled ot disabled in the startup profiles.
	 - New icon in the Stream Deck icon set for the "TrackMapping" action.
  8. The key combination to request an unblocking of all executables in "Simulator Startup" has changed from Ctrl-Shift to Ctrl-Alt.
  9. A new LLM event has been defined for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) of the Race Spotter. "blue_flag_alert" will be signalled, once a faster car appears in the mirror, that is at least one lap ahead. Revisit your event configuration, include the new events and define actions (for example flash a red light in your dashboard using SimHub, for example), if necessary.
  10. Two new [*Conversation* booster actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) have been defined, that can start and stop the track mapping by voice command.
  11. Several new LLM events for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#race-spotter) of the Race Spotter support detection of pitstops, the last lap and also the end of the session.
  12. Vulkan driver support for non-Nvidia GPUs has been added to the local LLM Runtime. Please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-584) for more information, since a conflict with CUDA drivers on Nvidia GPUs is possible.
  13. Several updates for the Spanish translation.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-584), if you are using Assistant Boosters or the local LLM Runtime.

## 5.8.3.2-release 08/16/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug, which prevented auto-saving a session in the "Practice Center", when the window was closed using the close box in the windows title bar.
  4. Updated many controls for longer text labels to improve UI for languages other than English or German.
  5. Replaced all buttons labeled Add/Delete/Save with buttons with graphical icons.
  6. Export of telemetry data is no longer possible for practice sessions, which has been saved to the session database.
  7. Many updates for the French translation.
  8. [Internal] Improved resilience of rule engine against defective foreign functions.

## 5.8.3.1-release 08/09/24
  1. Fixed a critical bug when sessions are saved to the session database.

## 5.8.3.0-release 08/09/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a critical bug, that caused an endless chain of action triggers for virtual Button Boxes that are triggered by keyboard commands.
  4. Increased the resilience against invalid "broadcasting.json" files in the *Assetto Corsa Competizione* configuration, especially if a non-standard file encoding is used.
  5. Increased resilience against invalid tyre compound rules entered in the settings in the "Session Database".
  6. Increased resposiveness of HTML redrawing after window resizing.
  7. Fixed a bug in the new "Auto Save" setting for the "Practice Center", that was ignored when closing the window.
  8. New event has been defined for the *Reasoning* booster of the Race Spotter. Revisit your event configuration, include the new events and define actions (for example flash a red light in your dashboard using SimHub, for example), if necessary.
     - "ahead_gap_update" and "behind_gap_update" are signalled whenever the gap to the car behind or ahead changed by a given amount (according to the configration in the "Session Database").
	 - "attack_imminent" is signalled when an opponent has closed in and an attack might happen soon.
	 
	 The corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#events-2) has been updated.
  9. The "Load Session..." menu command in the "Practice Center" and in the "Race Center" now opens a specialized browser which allows you to search for sessions in the session database. This browser also can open the standard file dialog to load sessions which were stored outside the session database. See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#saving-and-loading-sessions) for more information.
  
     Note: To load a session that has been saved in the old, directory-based format prior to Release 5.8.1, hold down the Control key and click on the "Import..." button.
  10. The same browser is now used when loading Strategies, either in the "Strategy Workbench" or in the "Race Center".
  11. The "Session Database" has a new tab, which allows you to browse the sessions stored in the database.
  12. Sessions and Strategies can be opened for viewing them in the "Practice Center", "Race Center" or "Strategy Workbench" respectively by double-clicking on them in the "Session Database".
  13. A new kind of user interface has been introduced for the "Race Center". This so called [*Lite* mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#normal-vs-simple-user-interface), which is available when starting with a specialized profile from "Simulator Startup" or by holding down the Alt key, when starting "Race Center", presents only the most important information and is therefore suitable for team members in the driver role.
  14. All reports the "Race Center" presents in the *Output* area in the lower right corner of the main window can now be opened in a separate window, when holding down the Control key when selecting them.
  15. "Simulator Startup" removes assets specific to the Team Server from the UI, if no Team Server is configured.
  16. [Important] A new version of the local LLM Runtime is available. If you are using the local runtime, please follow the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-583).

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-583), if you are using Assistant Boosters or the local LLM Runtime.

## 5.8.2.0-release 08/02/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Most important, a new LLM Runtime has been implemented.
     - Better support for execution of all or parts of the model on the graphics card.
	 - Since this runtime is quite large (> 200 MB), it is provided as a downloadable component. Run "Simulator Setup", go to the presets page and install the "Local runtime for LLMs" preset.
	 - See the completely [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#llm-runtime) for more information.
  4. The Race Engineer LLM event "damage_collected" has been renamed to "damage_detected". Revisit your event configuration and include the *updated* event, if necessary.
  5. A new event and a new action has been defined for the *Reasoning* booster of the Race Engineer. This pair handles reporting of critical time loss after an incident. Revisit your event configuration and include the new event and action, if necessary.
  6. The lap history data supplied to the LLMs has been extended.
  7. The "Practice Center" can now save practice session recordings to the session database.
     - The file format of sessions has been changed to support this.
	 - Sessions saved in the *old* format can still be loaded using the "Load Sessions..." command from the "Session" menu. Hold the control key while selecting "Load Session..." to load an *old* session.
	 - See the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#saving-and-loading-sessions) for more information.
  8. An *Auto Save* setting has been added to the "Practice Center".
  9. Saving sessions locally has also changed for the "Race Center".
     - Default location is also the session database.
     - The file format of sessions has also been changed to support this.
	 - Sessions saved in the *old* format can still be loaded using the "Load Sessions..." command from the "Session" menu. Hold the control key while selecting "Load Session..." to load an *old* session.
     - See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#session-data-management) for more information.
  10. Support for practice and race sessions has been added to "Session Database".
      - Data can be browsed in the "Administration" tab.
	  - Full support for Export and Import of session data.
	  - Sessions can be shared within a team using the Team Server. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) for the "Session Database" configuration. You may want to check your replication settings in the "Session Database".
	  - A special purpose browser for practice and race sessions will be made available with one of the next releases.
  11. "Session Database" now also supports importing of car setups from exported archives formerly created by the "Session Database".
  12. UI improvements for directory selection dialogs.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-582), especially if you have used the previous LLM Runtime for the "Driving Coach" or the Assistant Boosters.

## 5.8.1.0-release 07/26/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Added available tyre compounds to the knowledge passed to the LLM in several Assistant Boosters.
  4. The [LLM action plan_pitstop](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#actions) now accept a tyre compound argument.
  5. Optimized pressure loss reporting by the Race Engineer.
  6. Allow both a predefined action for a controller function together with bound actions from plugins. Using this you can, for example, play a short sound for each button press as a kind of acknowledgement. Use the "play" [controller action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) to do this.
  7. Many clarifications in the documentations for ["Customize Assistants"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) and for the ["Rule Engine"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).
  8. The code editor for LLM events and actions now allows scrolling and copying even if the displayed rule text is read-only.
  9. The fields for unchangeable builtin events and actions are now shown as read-only and no longer as disabled.
  10. LLM events and actions can now be cloned using a "Copy" button.
  11. The colors of diagrams and graphs has been optimized for the dark color scheme. 

## 5.8.0.1-release 07/20/24
  1. Fixed a critcal bug for connected hardware controllers (Button Boxes, Stream Decks, ...) that could rapidfire a pressed button.

## 5.8.0.0-release 07/19/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Renamed "Conversation Booster" to "Assistant Booster" throughout the documentation.
  4. All documentation regarding the different Assistant Boosters has been collected into a dedicated [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants).
  5. The knowledge made available to the different Assistant Boosters has been extended massively. A full history of recent laps is now included, which allow the LLM (if smart enough) to make very precise decisions.
  6. A new Assistant Booster has been implemented, which let you integrate an LLM into the reasoning process of an Assistant.
	 - This *Reasoning* booster can use a different GPT service and LLM than the other conversation-related Assistant Boosters.
     - Events raised by the rule system of an Assistant or by rules defined on your own can be used to create a request to an LLM.
	 - The LLM then can use any of the predefined actions or actions defined on your own to handle this event or situation.
	 - Actions triggered this way can raise other events, thereby creating a complex chain of thought for the LLM.
  7. A new syntax-coloring editor for source code has been implemented and is used in the Assistant Booster dialog when rules are being edited.
  8. Large parts of the documentation have been revised, updated and restructured:
     - The documentation for the "Session Database" has been moved to a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database).
     - The documentation for "Strategy Workbench" has been moved to a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench).
     - The documentation for "Practice Center" has been moved to a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center).
     - The documentation for "Race Reports" has been moved to a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports).
     - The documentation for "Race Center" has been moved to a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center).
     - All new complete documentation of the builtin [Hybrid Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).
  9. The transcript of LLM invocations in any Assistant Booster now includes the events raised and actions invoked. Transcripts of Assistant Boosters are normally stored in the *Simulator Controller\Logs* folder, which is located in the user *Documents* folder.
  10. The available color schemes has been revised and a new dark color scheme has been added. Four color schemes ae now available:
      - Classic (default, the original color scheme of Simulator Controller)
	  - Gray (formerly named "Dark")
	  - Light (formerly named "Windows", uses the default Windows colors)
	  - Dark (new, uses the dark theme colors of Windows 10 / 11)
	  
	  See the updated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#color-schemes) for some examples.
  11. A new [controller action functions "speak"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) allows you to output spoken messages from your controller scripts.
  12. A new [controller action functions "play"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) allows you to play sound files from your controller scripts.
  13. "speak" and "play" has been added to the [location specific actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#track-&-automation) in Track Automation, which let's you put out a spoken message or play a sound file at a given track location. Rally support is coming...
  14. The automated update procedure now asks before a non-release version is installed.
  15. [Internal] Implemented a postprocessor for the compiler which compresses the binary files. The applications are much smaller now.
  16. [Internal] Migrated to AHK 2.1-alpha.14 (needed for dark color scheme).
  17. [Developer] A new class library (*LLMAgent*) supports a full recursive round-trip between the rule engine and an associated LLM. Using this architecture, fully autonomous agents can be configured.
  18. [Developer] A new class library (*CodeEditor*) integrates the "SciTex" editor with an easy to use programming interface.

## 5.7.9.0-release 07/05/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A bug has been fixed in "Race Center" which broke the "Initialize from Session" command when the stint plan had been changed during a session.
  4. The stint plan is now fully reloaded and synchronized with the current session, after it has been altered or extended.
  5. The stint plan has no higher priority than the loaded strategy, when the "Initialize from Session" command is called from the "Pitstop" menu. The [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop) has been udated accordingly.
  6. The "Team Management" tab, which has been deprecated for quite some time, has been removed from "Simulator Configuration". You can [manage your teams, sessions and drivers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#team-management) in the "Simulator Starup" application.
  7. Inactive or retired cars are no longer *observed* by the Spotter.
  8. The "Practice Center" can handle a *late join* (i.e. starting the "Practice Center" while already on the track) much better now.

## 5.7.8.0-release 06/28/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug introduced in the last release, which caused connected drivers to no longer show up in Team Server application.
  4. The *warmup* procedure of the Team Server has been improved for installations where the Team Server is run as a swappable virtual machine in a shared environment like in Azure.
  5. Tyre set numbers for wet tyres are no longer displayed as numbers in "Race Center" for *Assetto Corsa Competizione*.
  6. The automatic choice of the next tyre set in *Assetto Corsa Competizione* are now display as "Auto" and no longer as **0** in "Race Center".
  7. Fixed the unit conversion of tyre pressures in the API of *Automobilista 2*. The API documentation says the values are reported as PSI, but they are actually in kPa.
  8. Fixed the reporting of remaining laps by the Spotter for races with fixed number of laps.
  9. More consistency checks for Startup Profiles. It is no longer possible to create a startup profile with no name.

## 5.7.7.0-release 06/21/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Several errors in the translations for Spanish and for French has been fixed.
  4. The resilience of the "Race Center" and the driver connection has been increased for unstable Team Server situations.
  5. The consumption graph will now also be shown in the "Strategy Workbench" for *work-in-progress* strategies.
  6. The "Basic" setup page is now always preselected in "Simulator Setup".
  7. Downloadable presets in "Simulator Setup" now will also be included in the list of installed presets.
  8. A bug has been fixed that prevented the saving of the "Actions" choice in the Conversation Booster dialog.
  9. Several enhacements for the conversation actions editor:
     - More error messages for missing or wrong information.
	 - Syntax errors in rule definitions are now reported using rule reference and character position.
	 - Constant arguments are now allowed for function and method calls. Example: trigger("!w") for a function call on the Controller that enables the wind screen wiper.
	 - Multiple consecutive function or method calls can now be defined for one single conversation action.
	 - Hold down the Control key while clicking on "Ok" button will not leave the editor, but instead will show you the API tool definitions in JSON format.
  10. Whenever a Conversation Booster is configured for a Race Assistant, a transcript of every LLM activation is stored in the *Simulator Controller\Logs\Transcripts* folder which is located in your user *Documents* folder.
  11. The "Plan Pitstop" conversation action for the Race Engineer now lso allows to call for a driver swap in team races.
  12. Two [predefined conversation actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#trigger-actions-from-conversation) for the Spotter are now available:
      - The LLM can decide to reset and recalculate the delta and lap time history for all cars.
	  - And you can ask the LLM to reset the reference speed data of all cars around the track, when too many false positives for accidents and slow cars are given.
  13. [Expert only] All definition files for "Simulator Setup" can be *overwritten* in the *Simulator Controller\Setup\Definitions* folder which is located in your user *Documents* folder. This can be used to introduce new bundled applications or to replace the startup video, just to name two examples.

## 5.7.6.0-release 06/14/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed the lap time comparison information of the Spotter in multiclass races. A bug resulted in a comparison of cars from different classes which resulted in very confusing information.
  4. The default instructions of the Conversation Booster has been updated again to improve conversation quality further. Please see the Update Notes, if you have modified these instructions.
  5. The LLMs used to boost the conversation capabilities of the Assistants are now allowed to trigger some actions as a result of your interaction. A few [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#predefined-actions--events) already have been defined for the Engineer and the Strategist with more to come in the next releases. Using actions, it is possible to define new voice commands, but the LLMs are also allowed to trigger the actions based on the current situation and data constellation.
  
     Please note, that using *Actions* is not enabled by default, but must be explicitly activated in the configuration.
  6. Action definition files are customizeable in the [Documents]\Simulator Controller\Actions folder.
  7. An editor has been implemented to enable or disable the predefined *Conversation* or *Behavior* actions and even define your own ones. But this will require extensive knowledge of the inner workings of Simulator Controller and the Assistants and also a very good understanding how LLMs work. You have been warned. Please see the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions) for more information.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-576), if you have configured the Conversation Booster for the Assistants.

## 5.7.5.0-release 06/07/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in "Simulator Setup", which prevented additional software to be located in the "Applications" step.
  4. Fixed voice test button on the main voice control page in "Simulator Setup".
  5. Fixed the "Always" activation mode in "Recognition" Booster.
  6. Cleanup of the additional software supported in "Simulator Setup":
     - Removed "Voice Macro", since it was needed anymore for a long time now.
	 - Added "Real Head Motion" as optional software, since it is one of the most useful extensions for *Assetto Corsa Competizione*.
  7. Automatic updates from versions prior to 5.0.0 are no longer supported.
  8. Added mounted tyre compound to tyres info component in "System Monitor".
  9. The "Telemetry" instruction has been removed for both the Driving Coach and the Conversation Booster. It has been substituted by the new "Knowledge" instruction. This instruction provides the knowledge of a given Assistant now in JSON format to the LLM, which results in a much better understanding of the state of the car, strategy, standings and other important information by the LLM. The [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) has been updated accordingly.
  10. The Engineer will provide full pitstop history to the LLM. Questions like: "What were the ambient temperatures at the third pitstop and what tyre pressures did we use then?" will be possible now.
  11. The Spotter now also provides his knowledge about all opponents and the current race situation to the connected LLM, if a "Conversation" booster has been configured.
  12. The Strategist and the Spotter learned a new [voice command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)). With this you can ask, how often an opponent has been to the pits already.
  13. [Internal] Migrated to AHK 2.0.17.
  14. [Developer] Added mounted tyre compound to the ["Session State.json"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) file.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-575), especially if you have configured and are using the Driving Coach.

## 5.7.4.0-release 05/31/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Added support for single word driver names in Team Server and all management applications.
  4. The Assistants no longer react, when the *Push-To-Talk* button was pressed, but nothing was said.
  5. Fixed default service URL for GPT4All.
  6. Adopted *GPT4All* 2.8 API. Should be running stable now in all situations.
  7. The Conversation Booster no longer consume a voice command, when the invoked GPT service does not returned a valid result.
  8. LLMs sometimes use markdown syntax in their answers. Most of this syntactical elements are now removed, so that they do not interfere with the spoken words.
  9. [*Ollama*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#ollama) has been added to the list of supported GPT service providers. This is a GPT server, which can be installed on the local PC.
  10. A [*Generic*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#generic) GPT service provider is now also available. This supports HTTP based GPT services, which implements the OpenAI JSON protocol.
  11. The list of available LLMs is now automatically loaded from a GPT service provider (if supported) in the configuration dialogs.
  12. Increased timeout for GPT service requests to 60 seconds, so that even very slow models have a chance to complete their task.
  13. [Internal] Migrated to AHK 2.0.16.
  
## 5.7.3.0-release 05/24/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The translations for checkable menu items has been fixed in several applications.
  4. Several translation errors for the Spanish language has been fixed.
  5. The cold target tyre pressure information in the pitstop component on the session info page in "System Monitor" has been fixed. This bug was introduced with the 5.7.2.
  6. The announcement of chosen tyre pressures by the Engineer in team sessions has been fixed. This bug was introduced with the 5.7.2.
  7. Fixed unwanted automatic re-enabling of simulators and applications by "Simulator Setup" when using the Basic configuration step.
  8. Fixed unwanted automatic re-enabling of "Start with Windows" by "Simulator Setup" when using the Basic configuration step.
  9. Fixed an edge case in "Race Center", where pitstop settings initialization failed after an unplanned pitstop had become necessary after a start incident.
  10. The handling of remote server timeouts has been improved in team sessions. The applications like "Race Center" do not wait anymore in cases of non-important data.
  11. Pressing *Push-To-Talk* without saying anything no longer triggers an "I don't understand, please repeat" answer by the Assistants, as long as you are using Azure or Google for voice recognition.
  12. The Spotter now informs you during qualification whether the car before or behind you is on a valid or on an invalid lap.
  13. It is now possible to configure the instructions for the different GPT-based Conversation Boosters. Please take a look at the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) for more information.
  14. The default instructions for the Conversation Boosters has been extended to include more personality and domain specific behaviour. A full overview for all supported instructions can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm).
  15. Many more announcements and messages by the Spotter can now be rephrased by the Conversation Booster. Only very urgent messages like proximity alerts are excluded, because of the additional latency introduced when calling a GPT service.
  16. The default "Character" instruction for the Driving Coach has been updated. Therefoe all instructions will be reset to their defaults. This is only necessary this time, see next item.
  17. A method has been introduced, that checks whether you are using the default instructions for an LLM, so that you don't need to update them, when they have changed in the distribution package.
  18. It is now possible to manage teams, driver and sessions directly from "Simulator Startup", if you are using the Team Server. Please see the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#team-management) for more information.
  19. Renamed the "Team Server" tab in "Simulator Configuration" to "Team Management". Using this tab is not necessary anymore and it will eventually be removed, since the functionality is now provided from within "Simulator Startup".
  20. [*OpenRouter*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#openrouter) has been added to the list of supported GPT service providers.
  21. The documentation has been updated to cover the [configuration requirements](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#installation) for the added GPT providers.
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-573), especially if you have configured and are using the Driving Coach.

## 5.7.2.0-release 05/17/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed automatic installation of the French language pack for voice recognition by "Simulator Setup".
  4. Fixed calculation of remaining stint time, if driver time is less than stint time.
  5. The configuration of the *Push-To-Talk* button now supports a test mode, which starts two Assistants, so that you can play with the *Push-To-Talk* button. Depending on the chosen recognizer it might be necessary to use the double-press for activation commands, when using the test mode (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#activation-commands-vs-normal-commands) for more information).
  6. The Driving Coach now also has access to the car telemetry data from the general knowledge base. It therefore is theoretically able to correlate degrading lap times with over the top tyre temperatures, for example.
  7. The default context window size for an LLM has been increased to 2k tokens in the Driving Coach configuration.
  8. The next feature of the AI-based booster for the Assistants now integrates a general conversation capability. Every voice command, that cannot be matched against the list of predefined, pattern-based commands, will be forwarded to the GPT service for a general conversation. The LLM has full access to the knowledge base of the Assistant, incl. telemetry data, standings and position data, and so on. The exact knowledge will vary with the type of the Assistant (Engineer, Strategist, ...). See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) for more information.
  9. Configuration of the Conversation Booster is now also possible using "Simulator Configuration". See the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) for more information.
  10. [*Mistral AI*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#mistral-ai) has been added to the list of supported GPT service providers.
  11. Added "GPT-4o" to the list of OpenAI models.
  12. The pitstop component on the session info page of "System Monitor" now also displays the relative tyre pressure increment values for the next pitstop.
  13. [Internal] Migrated to AHK 2.0.15.
  14. [Developer] Add information about tyre pressure increment values to the ["Session State.json"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) file.

## 5.7.1.0-release 05/10/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed saving of probability setting for rephrasing for the Assistant Booster.
  4. Improved meta data handling for Assistant Booster. All instructions to the LLM are now kept in an instructions file and can be modified or extended by the user.
  5. Once again some tweaking for accident detection by the Spotter.
  6. Tweaked lap time delta calculation after collecting damage.
  7. Fixed a couple of Strategist command patterns.
  8. Deferred the call to pit by the Engineer, so that it is not issued, before the pitstop settings has been set up.
  9. The Engineeer now informs about pressure changes incrementally if tyre compound is unchanged.
  10. Added new Ford Mustang for *Assetto Corsa Competizione*.
  11. The AI-based booster for the Assistants now also support semantic understanding of comannds, for which no pattern has been defined in the grammars of the Assistant. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm) of the Assistant Booster for more information. The configuration of the speech improvement is available on the "Basic" setup page of "Simulator Setup".
  12. [Internal] Migrated to AHK 2.0.14.
  13. New car models for "Setup Workbench":
      - Assetto Corsa Competizione
        - Ford Mustang GT3

## 5.7.0.2-release 05/06/24
  1. Second and most probably final fix for the Team Server / "Race Center" bug mentioned below.
  
## 5.7.0.1-release 05/05/24
  1. Hopefully fixed a critical bug for Team Server / "Race Center", which prevented transfer of session state from one driver to the other when Assistants are set to silent in the startup settings.
  
## 5.7.0.0-release 05/03/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The new setting "Spotter: Threshold for Overtaking car ahead" in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" can be used to specify the time gap to a car ahead or behind, in which the Spotter does not issue any additional information about your opponent. This can prevent the Spotter telling you to overtake, while you are actually started doing exactly that.
  4. Rearranged the priority of a couple of information announcements of the Spotter to make them more relevant and timely.
  5. Fine-tuning for some edge cases in the accident detection on tracks with extreme braking zones.
  6. The default models for OpenAI has been updated, since OpenAi introduced new models (always difficult to keep up with them). This relates to the Driving Coach configuration and also to the new speech improvement capabilities (see next topic). You may want to review your choice and update your model reference to the newest version, since they might even be cheaper.
  7. "Simulator Setup" now supports configuration of LLM-based post-prcessing and rephrasing of voice messages issued by the Assistants. This is the first step in a series of enhancements for the Engineer, the Strategist and the Spotter using GPT technology. All this enhancements will be optional, since they either require a very powerful PC to run an LLM locally or you must buy some computing time from companies like OpenAI. Although very inexpensive, this is also not for everybody. Please take a look at the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm).
  8. [Developer] Added a first GPT-based speech post-processor in preparation for the new Assistant GPT architecture. This post processor uses an LLM to randomly rephrase each message issued by the Assistants to bring in more variations. It can also be used to translate between different languages as long as the used LLM supports this.
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-570), especially if you have configured and are using the Driving Coach.

## 5.6.8.0-release 04/26/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The appearance of checkable menu items have been changed in many applications. It is now much more clear, wether a given menu item is a toggle switch.
  4. Two new options "Auto Clear" and "Auto Export" in the "Session" menu of the "Practice Center" let you specify the behaviour, when a new session is started or the application is closed with some unsaved / unexported data still present.
  5. A [new info component](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) for the "System Monitor" supplies extensive information about car damages collected in previous in incidents. The information provided depends on the capabilities and the supplied data by the given simulator, though.
  6. The same informmation of the new damage info component is supplied in the ["Session State.json" file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) generated by the ["Integration"  plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration).
  7. The warnings issued by the Spotter for unsafe drivers have been optimized. The threshold of cuts and off-tracks is now dynamic and the warning has been rephrased.
  8. Added support for logical key mapping of third party tools like Joy2Key.
  9. [Internal] Migrated to AHK 2.0.13.
  10. [Developer] Added a new generic class library for LLM support in preparation for the new Assistant GPT architecture.

## 5.6.7.0-release 04/19/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in "Simulator Setup", where simulator localization on the basic setup page did not work.
  4. The "NextPitstop" action of the Race Strategist will ask for confirmation before instructing the Engineer even in full autonomous mode.
  5. The active startup profile is now displayed below the startup button in "Simulator Startup".
  6. The Spotter now starts track mapping immediately after the end of the first lap.
  7. Finished sessions will stay at least a week untouched on the Team Server.
  8. Removed "Save Session" from "Race Center" and "Practice Center", which was confusing to many users. You now always save a copy to your local hard drice.
  9. Again some accident detection tweaks for the Spotter
  10. Replays in iRacing will now pause the telemetry acquisition.
  11. The data on the session info page in the "System Monitor" will now be as correct as possible also in team races, even when one or more Assistants are not active for a given driver.
  12. The frequency of information and advice callouts can now be configured for the Race Spotter. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) for more information.
  13. A new mode for the opponent information of the Spotter allows to get information not only at sector boundaries. Very useful for very long tracks like the Nordschleife, when used together with the aforementioned update frequency.
  14. Adjusted some field and box sizes in "Simulator Setup" and "Simulator Configuration".
  15. A small fix for the Team Server extends the life time of finished sessions.
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-567), especially if you are running your own Team Server.

## 5.6.6.0-release 04/12/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Shared database synchronization is back to operation.
  4. The setting "Spotter: Car Indicator" in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" has now a third choice "Both", which let the Spotter refer to a car by race number and current position at the same time.
  5. The setting "Car Indicator" is also available for the Strategist now.
  6. Once again some tweaks for the accident detection and alerting by the Spotter.
  7. *iRacing* practice sessions, where sometimes the lap counter jumps directly to lap 2, are now detected correctly.
  8. Offline "Test Drives" are now treated as practice sessions in *iRacing*.
  9. The detection speed of controller trigger (buttons, dials, and so on) has been greatly increased. Dials are now also detected very reliable and fast.
  10. Key presses on the keyboard are now also detected during trigger detection in "Simulator Setup" and "Simulator Configuration".
  11. The hotkey string (e.g. 2Joy7 or <^<!A) for a detected trigger is now placed in the clipboard for further usage.
  12. The Trigger Detector Tool is now also available when building [Track Automations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-automations).
  13. Added "24H Nürburgring" to the track name file for *Assetto Corsa Competizione*.

## 5.6.5.0-release 04/05/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in all applications sometime popping up a crash info dialog for a fraction of a second, when the PC is shutdown (Windows 11).
  4. Introduced special error handling in the Stream Deck plugin, that can prevent crashing during Windows 11 system shutdown.
  5. A lot of fine-tuning for the accident detection to further reduce false positves. Statistical methods are now used to remove invalid data points.
  6. Accident detection now also supports Big Grid sessions in *Assetto Corsa Competizione*.
  7. The precision for the accident detection on very long tracks has been improved significantly (Nordschleife).
  8. Fixed a recurring bug in the transfer of pitstop settings in *rFactor 2*.
  9. The dashboard widgets on the first page of the "System Monitor" now resize correctly when the window is enlarged.
  10. The automatic pre-selction of the last used track has been fixed for the "Setup Workbench".

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-565), if you are using Stream Deck.

## 5.6.4.0-release 03/29/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a regression introduced with 5.6.3.2 which prevented the race start reported correctly by the Spotter in some situations.
  4. Fixed a bug in the Spanish voice recognition.
  5. Fixed periodic update of the track map in "Race Center".
  6. Fixed "Simulator Setup" to include *Le Mans Ultimate* on the simulation configuration page.
  7. Fixed car positions in race reports as well as in "Race Center" and "Practice Center" for *iRacing* online races.
  8. A memory leak in the *iRacing* data connector has been fixed.
  9. A rare bug has been fixed in the "Track Mapper", which prevented a track map to be calculated correctly, when one of the GPS coordinates were zero for the X value.
  10. It is now detected correctly in *iRacing* whether the drivers car is in the pit for service.
  11. It is also detected correctly in *iRacing* now whether any car is in the pitlane.
  12. Invalid laps for any driver are now detected for *iRacing*. But it depends on the data update frequency set in the "Session Database", whether this detection is reliable, since the iRacing API only signals an invalid lap as long as the car is off-track.
  13. The default for the setting "Engineer: Tyre Service" is now used correctly for *iRacing*, where it is *False* (Off), since *iRacing* does not report valid hot tyre pressures most of the time.
  14. Changing of tyre compounds are now supported during pitstops in *iRacing*:
      - New action "TyreCompound" for the ["IRC" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-irc).
	  - Support added in "Simulator Setup" to configure this action.
	  - Stream Deck icon is available for the "TyreCompound" action.
	  - The Race Engineer is fully aware of the configured tyre compounds for a given car.
  15. "Practice Center" now informs about unsaved data before starting a new session.
  16. Updated car meta data for *RaceRoom Racing Experience* to the latest version.
  17. [Accident and slow car detection](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#accident-detection-for-assetto-corsa-competizione) by the Spotter is now also available for *Assetto Corsa Competizione*.
  18. [Internal] Migrated to AHK version 2.0.12.

**Important:** The accident detection has seen many changes since its initial release with 5.6.3. The current algorithms rely heavily on learning the track layout, the ideal line and the typical speeds during the initial laps. Unfortunately, the initial laps also see many accidents in some races, which can lead to false positives further down the road. I have included additional code which tries to detect and correct this, but it does not work all the time yet. If you encounter many false warnings like "Slow car ahead in 200 meters." by the Spotter during a race, although there is no such slow car, you can then disable the warnings by using the voice command:

	No more *warning*, please.
	
Use one of "slow car warnings", "ahead accidents warnings", "behind accidents information" for *warning* as required. If this is not usable for you, you can also disable the accident warnings completely in the configuration for important races for now.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-564), if you are running *iRacing* and want to use the new "TyreCompound" action.

## 5.6.3.2-release 03/17/24
  1. Fixed a critical bug in "Race Center" which caused standings information only being loaded for the starting driver.

## 5.6.3.1-release 03/16/24
  1. Fixed a critical bug in the Spotter for iRacing which prevented proper startup in some cases.

## 5.6.3.0-release 03/15/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed definition of custom tyre compound rules in "Session Database".
  4. Fixed occasional Spotter crashes for *RaceRoom Racing Experience*.
  5. Fixed telemetry analyzation by the Driving Coach for *RaceRoom Racing Experience* and *iRacing*.
  6. Fixed standings information for *iRacing*.
  7. It is now possible to disable automated pitstop handling for *iRacing* similar to the other simulators. Please take a look at the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-2).
  8. A new customization method allows to introduce support for user specific applications in "Simulator Setup".
  9. The minimum window height of "Simulator Setup" has been increased.
  10. The Strategist (or the Engineer, when the Strategist is disabled) will now inform you immediately, when you started into a race on a wrong tyre compound. No support for automated pitstop or strategy updates will be given, only the information. You won't start a race on wrong tyres, won't you?
  11. The Spotter can now inform about accidents and slow cars ahead and also about accidents behind. The Spotter will learn the track layout and the typical speed and position of a car at each part of the track during the first few laps. When one or more cars are way slower or are at positions far away from the ideal line, this will be counted as an accident.
      - The support for these alerts vary between the different simulators. Be sure to check out the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#alerts--information).
      - "Simulator Configuration" and "Simulator Setup" has been extended to allow enabling / disabling of the new alerts.
      - The announcements voice command of the Spotter has been extended to allow to enable / disable the new alerts while driving. Example: ["Please no more slow car warnings"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)).
      - New settings for the Spotter in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allow you to configure the distance before and behind the car, for which the traffic should be analyzed for accidents.
      - Please note that both *Assetto Corsa Competizione* and in parts also *iRacing* do not support accident detection yet for different reasons. Support will be added with future releases.
  12. Initial support for rain and wet tracks for iRacing. Not everything is working yet, since the iRacing API extensions are still under development. The system will get smarter with each season patch being rolled out.
      - Tyre compound information for the currently mounted tyres as well as the tyre compounds selected for the next pitstop are already available. Make sure to read at least the new documentation about [tyre compound handling in iRacing](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#special-notes-for-iracing).
      - The current weather will be correct in most cases, only fixed weather seams to be making problems. Unfortunately iRacing does not provide any information about the future weather yet. Therefore, the Assistants cannot plan for or even announce upcoming weather changes. But they will react immediately when the weather change happens.
      - The code for handling the grip level of the track is working and will cover the full range from "Optimum" to "Flooded".
      - Changing the tyre compound during a pitstop is not supported yet by the iRacing API at the moment. This will be added with a later release.
  
## 5.6.2.0-release 03/08/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed import of (race) settings in the "Session Database".
  4. Fixed export of (race) settings in the "Session Database" in case the Ctrl key is NOT held down.
  5. Fixed several grammar glitches in the Spotter phrases for the French language.
  6. All already completed pitstops will be taken into account when it comes to race rules validation, when a strategy is being re-calculated by the Strategist or in the "Race Center".
  7. The pitstop window and also the "Required" refueling and "Required" tyre change now only relate to the required pitstops.
  8. The reliability of the pitstop information of all opponents has been increased in the "Race Center".
  9. It is now possible to choose how the Spotter refers to a specific vehicle, like "Car number 7 had a problem" or "The car in P 5 had a problem". A new setting had been introduced in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database". Default is indication by position.
  10. The Spotter now can interrupt itself, when a more urgent information must be communicated, for example when he is informing the driver about the lap time of an opponent and an attack happens from behind.
  11. Parsing of the car name has been improved for *Le Mans Ultimate* - race numbers and cup category will be detected.
  12. If duplicate race numbers are detected in *rFactor 2* or *Le Mans Ultimate*, synthetical race numbers starting from **1** will be used instead. This will fix many internal problems with race standings, race reports, and so on. Please note, that the Assistants will also use these synthetical race numbers when refering to cars, which will make it difficult for you to name a specific car by voice command in this case. But it was a problem anyway with the duplicate numbers before.
  13. [Experts Only] Team specific settings can now be assembled by a team manager and can be imported by every team member using a special preset in "Simulator Setup". Please take a look at the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#managing-common-team-settings) for more information how to assemble such a package.
  14. [Experts Only] Special logging has been implemented which helps tracking down startup performance problems. It can be activated in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration).

## 5.6.1.0-release 03/01/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in the "Practice Center" that prevented tyre pressures to be displayed in the *Laps* list, when a session is loaded after being saved to disk.
  4. Fixed a bug for *rFactor 2* which prevented tyre pressures to be initialized correctly during pitstop automation.
  5. Fixed a bug in strategy simulation, which in rare cases caused failures when re-calculating a strategy using traffic scenarios in the "Race Center" or by the Strategist.
  6. Integrated support for *Le Mans Ultimate*:
     - [New plugin "LMU"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-lmu), which provides the same level of integration and similar controller actions as the "RF2" plugin for *rFactor 2*.
	 - Full support in "Simulator Setup" to configure the "LMU" plugin.
	 - Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation-of-telemetry-providers) for more information on how to install and configure the data integration plugin (*rFactor2SharedMemoryMapPlugin64.dll*) in the *Le Mans Ultimate* installation directory.
	 - *Le Mans Ultimate* is still under heavy development. Although it uses the same engine as *rFactor 2*, it looks like that several aspects of the shared memory API have changed. This is what has been achieved so far and what is not working:
	   - General telemetry is working
       - Pressures, temperatures, and so on are all there
	   - Car positions and timings also
       - The standings information seems to be broken in the API
	   - Driver names sometimes contain glitch characters; looks like an 8bit / 16bit charset bug
	   - Car names do not contain the model of the car, but the name of the team and other weird stuff
	   - Pitstop data input (normally a strength of the *rFactor 2* API) is not working at all
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-561), if you are running *Le Mans Ultimate* and want to activate the integration for this title.

## 5.6.0.1-release 02/23/24
  1. Fixed a critical bug when save strategies with tyre set information.

## 5.6.0.0-release 02/23/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed auto stint creation in "Practice Center", when a *normal* pitstop has been performed without a tyre change in any type of session.
  4. Fixed reporting of incidents and damage by the Engineer in the first lap, if the configured number of learning laps is equal to 1.
  5. New functions are available in the Startup Profiles and the corresponding documentation has been extended with an [overview](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles) of all available functions.
  6. Race settings can now be exported and imported in the "Session Database". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#race-settings) for more information.
  7. The consumption option has been removed from the optimizer in "Strategy Workbench". The main idea behind this option was to lower the fuel consumption a little bit, for example, when the driver implements a lift and coast driving style, but the results were not convincing.
  8. You now have fine-grained control over the length of the first and also the length of the last stint in the strategy simulation. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) for more information.
  9. And you can vary the fuel amount added at a pitstop to some extent in the strategy simulation. This is helpful to reduce the car weight over the full race and even out the stint lengths in cases where otherwise a short last stint would have been used. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) for more information.
  10. The regular pitstop window is now a separate entry in the pitstop rules in the "Strategy Workbench". You now can have 2 required pitstops in this window, for example.
  11. There is a new tab "Pitstops (fixed)" available in the "Strategy Workbench", which allows you to fix the lap for one or more pitstops during strategy simulation. But there are some drawbacks, so read the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#pitstops-fixed) carefully.
  12. The strategy simulation in the "Strategy Workbench" and the "Race Center" and also, when run by the Race Strategist, now keep track of tyre usage for all tyre sets. Tyre sets will appropriately be re-used in sessions with a restricted number of tyre sets and the strategy simulation will try to optimize the overall utilization of tyre sets for the whole session.
  13. Tyre set numbers are displayed in the strategy summary report in the "Strategy Workbench" and also in the "Race Center".
  14. For sessions with a fixed time, the strategy report now displays the full session time (enclosed in paranthesis) in the "Duration" field of the report.
  15. The strategy chart (fuel and tyre diagram) can now also be displayed in the upper area of the "Strategy Workbench". Choose "Strategy" from the "Chart" drop down menu located above the chart area.
  16. Strategy comparison reports now list the strategies in the order form best to worse.
  17. The default for the automatic pressure loss correction is now *Off* in the "Race Center".
  18. Several new RSS Formula cars have been included in the car meta data DLC by @mirko_lesko.
  19. [Experts only] The rules for strategy validation in the "Strategy Workbench" have been revised and extended. Full information about tyre sets are now available for each pitstop. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#scenario-validation) for more information.
  20. New car models for "Setup Workbench":
      - Assetto Corsa
        - Lotus 72D
        - Lotus 98T
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-558), if you have defined your own scenario validation rules in the "Strategy Workbench".
  
## 5.5.8.0-release 02/16/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed several bugs for manual adjustments of an already prepared pitstop.
  4. Fixed a bug in the laptime comparison of the Spotter, which resulted in the Spotter reporting driver to be faster although he in fact wasn't.
  5. Fixed a typo for the Alpine A110 GT4 car meta data in ACC. The car now shows up everywhere with its correct long name.
  6. Fixed new CC GT2 car names in those cases when they were driven, before the meta data was already available in Simulator Controller.
  7. Reading the *udpConnection* argument for the "ACC" plugin now ignores errors.
  8. (Re-)Planning a pitstop will now always clear an already prepared pitstop. The settings transferred to the simulator will be preserved, though.
  9. **Important:** In most cases, it is no longer necessary to double-press the Push-To-Talk button to [initiate an activation command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) like "Hey Jona". There is one exception, so please check the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#activation-commands-vs-normal-commands).
  10. The capabilities of the Driving Coach to discuss with you after a session your performance and possible handling issues of the car, has been greatly improved.
  11. The Stream Deck icons now show a small colored bar at their top for toggleable controller actions to indicate, whether the corresponding function has been activated.
  12. New modded cars, e.g. the Golf GTI MK2, some new RSS Formula cars and all TCR cars have been included in the car meta data DLC.
  13. New car models for "Setup Workbench":
      - Assetto Corsa Competizione
	    - BMW M2 CS (fixed)
      - Assetto Corsa
        - Lotus 25
        - Lotus 49
		- Maserati Granturismo MC GT4 (fixed)
		- Porsche Cayman GT4 Clupsport (fixed)

## 5.5.7.0-release 02/09/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed entering available minutes manually in "Server Administration".
  4. Functions in the Startup Profiles are no longer listed twice.
  5. The list of server objects has been extended in the "Server Administration" application.
  6. "Server Administration" now also conveniently uses a Server URL drop down list to select the server from a list of all recently used servers.
  7. The Server URL drop down list does not jump to the first entry anymore in "Simulator Configuration", when a previously unknown URL has been entered.
  8. When a session database is being rebuild by the "Database Synchronizer", no more duplicate objects are created on the Team Server.
  9. The "Database Synchronizer" has become much more resilient against corrupted data in the local database.
  10. Handling and performance of background processes has been optimized for "Simulator Setup".
  11. The lap time of the first lap of a stint is now ignored in all computations of "Race Center" and "Practice Center".
  12. Downloadable components are now available as presets in "Simulator Setup". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#presets--special-configurations) for more information how to use the DLCs.
      - A new DLC let you download car meta data for "Setup Workbench" for non-standard cars in *Assetto Corsa*.
	  - Another DLC let you download additional media data for custom splash screens.
  13. Previously bundled splash screen media has been removed from the standard distribution and has become a downloadable component (see above).
  14. All car meta data for *Assetto Corsa* has been corrected to not longer provide ABS settings, if these are not part of the *Factory* definition.
  15. New car models for "Setup Workbench":
      - Assetto Corsa
        - Audi R8 LMS 2016 (by @mirko_lesko)
        - Mazda MX5 Cup (by @mirko_lesko)
        - Ferrari F138 (by @mirko_lesko)
        - Ferrari SF70H (by @mirko_lesko)
        - Nissan GT-R GT3 (updated)
        - Toyota MKIV Time Attack (updated)
        - RUF CTR Yellow Bird (updated)
  
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-557), especially if you are running your own Team Server.

## 5.5.6.1-release 02/02/24
  1. Fixed a freeze in "Simulator Setup".

## 5.5.6.0-release 02/02/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed several bugs for the Race Assistants in conjunction with a deactivated voice listener.
  4. Fixed a bug in the handling of Team Server default connections for the Startup Profiles.
  5. Fixed a (critical) bug in "Simulator Configuration", which didn't open its main window, when one or more Asistants had been disabled.
  6. Fixed all applications terminating correctly when "Simulator Download" is started manually.
  7. Fixed Franch grammar files for the Spotter.
  8. Fixed pitstop plan to display the wrong driver name when planning a pitstop without a stint plan in "Race Center".
  9. When a pitstop is planned in "Race Center" without a stint plan, the planned lap will be set to the current lap, when no future lap has been specified.
  10. The ACC plugin for Assetto Corsa Competizione now checks the UDP configuration at startup and warns you, if an invalid configuration is detected.
  11. Added title bars to a couple of more windows to make them moveable.
  12. A pre-configured Stream Deck profile is now available in the *Profiles* folder.
  13. A new module entry shows the voice configuration status in the "System Monitor".
  14. It is now possible to use the Escape key to stop the "Race Center" waiting for data. Use with caution, because this data object will never be requested again and might therefore be missing then. Use only, if you know that one of your team mates does not send poosition data, for example, due to a configuration error.
  15. Several new settings in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allow you to customize the strategy summary given the the Strategist, when running a race with a pre-configured strategy.
  16. The strategy comparison report in the "Strategy Workbench" now also includes the *Consumables* chart for each indivdual strategy.
  17. Again improvements for the "Setup Workbench":
      - New standard setup setting "Boost" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
	  - Several new rules for handling issue recommendations with regards to turbo boost settings.
      - New standard setup setting "Limiter" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
  18. New car models for "Setup Workbench":
      - Assetto Corsa Competizione
        - Audi R8 LMS GT2
        - KTM X-BOW GT2
        - Maserati GT2
        - Mercedes-AMG GT2
        - Porsche 935
        - Porsche 991II GT2 RS CS Evo
      - Assetto Corsa
        - Mazda 787B (by @mirko_lesko)
        - Sauber-Mercedes C9 (by @mirko_lesko)
        - Porsche 962C Long Tail (by @mirko_lesko)
        - Porsche 962C Short Tail (by @mirko_lesko)

## 5.5.5.0-release 01/26/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a critical bug in Race Engineer for wet cold tyre pressure calculation.
  4. Fixed a bug in Race Engineer, where a planned but not prepared pitstop was not cleared after a manual pitstop had been performed.
  5. Fixed many errors in the car meta data definitions for *Assetto Corsa* in "Setup Workbench".
  6. The Driving Coach will not inform you over and over again, when there is a problem with the configuration or the connection. This is especially helpful, when running an initial setup without a configured Push-To-Talk button.
  7. Several improvements for the "Setup Workbench", which now supports many more unconventional setup options and is fully prepared to handle hybrid cars with electrical power units and energy recovery systems:
     - New standard setup setting "Differential Coast" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
     - New standard setup setting "Differential Power" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
     - New standard characteristic "Battery Depletion" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*, since only a few cars provide this characteristic.
     - New standard setup settings "MGUK Delivery", "MGUK Recovery", "MGUH Mode" and "Brake Engine" for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*, since only a few cars provide this setup option.
     - New standard setup settings for *Heave Suspensions* (Spring Rate and Damping) for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*, since only a few cars provide this setup option.
     - New standard setup settings for separate left / right aero height for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
     - New standard setup settings for separate left / right aero wings for "Setup Workbench". Please note, that this setting is not enabled by default in *Assetto Corsa*.
  8. Optimized layout of the setup editor in "Setup Workbench" to give the settings editor more room.
  9. New "-Startup" argument for "Simulator Startup", which let's you choose the [startup profile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles) to launch independent of what has been configured.
  10. Added track meta data for Spielberg in *Assetto Corsa Competizione*.
  11. Added basic car meta data for the new cars in *Assetto Corsa Competizione*. Setup meta data for the "Setup Workbench" will follow with the next release.
  12. New car models for "Setup Workbench":
      - Assetto Corsa
        - Ferrari F2004 (added Diff Coast & Power)
        - Ferrari SF15-T (added Heave Suspension and electrical system)
        - Lotus Exos T125 (added Diff Coast & Power)
        - Tatuus FA01 (updated for new settings as well)
        - All other cars (updated Differential settings where necessary)
        - Porsche 919 Hybrid 2015 (by @mirko_lesko)
        - Porsche 919 Hybrid 2016 (by @mirko_lesko)
        - Audi R18 e-tron 2014 (by @mirko_lesko)
        - Toyota TS040 Hybrid (by @mirko_lesko)

## 5.5.4.0-release 01/19/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed crash in "Simulator Configuration" when the internal voice synthesizer of Windows is not available.
  4. Fixed refuel rule not initializing correctly from a loaded strategy in "Strategy Workbench".
  5. Fixed a bug for Race Engineer, who didn't ask to save the pressures at the end of a session with a pitstop without a tyre change.
  6. Support for Custom functions in external command loop of Simulator Controller. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#external-commands) for more information.
  7. Optimized the pitstop preview information in "Race Center". No tyre change is now displayed correctly and settings modified by the driver **after** a pitstop has already been prepared, are reflected as well.
  8. Better handling of invalid values in the setup editor of the "Setup Workbench".
  9. The "Pit Strategy" slider can now also be used to optimize the last two stints in longer races in the "Strategy Workbench". Please read the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) for more information.
  10. The scroll position of the setup viewer in the "Setup Workbench" is retained when a setting value is changed.
  11. Thanks to @mirk_lesko, we now have a great example for non-standard car meta data in the "Setup Workbench". This car, the *Tatuus FA01* in *Assetto Corsa*, demonstrates the use of custom setup options as well as extended rules for the handling issue recommendations. Links to the car meta data specification files can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#example-and-further-information).
  12. [Internal] The "Database Synchronizer" is now started deferred, so that occasional file locks occur less often.
  13. New car models for "Setup Workbench":
      - Assetto Corsa
        - Tatuus FA01 (by @mirko_lesko)
  
## 5.5.3.0-release 01/12/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed selection of driver and session on the *Team Server* tab in "Simulator Configuration".
  4. Fixed a misleading error message in the automatic update procedure that indicates a security problem, although the download file simply was not available.
  5. Fixed a critical bug for initial tyre setup import in non-dry weather conditions (especially for *Assetto Corsa Competizione*).
  6. Fixed some edge cases for Full Course Yellow handling by the Strategist.
  7. Fixed a bug in "Strategy Workbench", where in some cases the fuel calculation for races with formation lap was too high, resulting in too much fuel left at the end of the race.
  8. The default for *Save* mode in "Simulator Configuration" is now "Auto". If you changed the setting already, your choice will be preserved.
  9. When the race settings are modified with the "Race Settings" app while already being in a session, all choices of the active startup profile are also incorporated.
  10. The translation for the French language has been finalized by @SlatMars, with "Simulator Setup" now also available with a user interface in French.
  11. The "Controller Actions Editor" now shows preview icons in the list of available actions.
  12. The new logo for Simulator Controller has been added to the splash screens.
  13. The preset "Race Engineer w/o Pitstop Control" has been deprecated because this setting is now available in the startup profiles (named "Pitstop Service").
  14. The Stream Deck Icons are now also available when the French language is selected.
  15. New car models for "Setup Workbench":
      - Assetto Corsa
        - BMW Z4 E89

## 5.5.2.1-release 01/06/24
  1. Fixed several bugs for function setting application in the new startup profiles.

## 5.5.2.0-release 01/05/24
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed recurring installation of the French speech recognition library.
  4. Fixed controller preview windows forgetting their last position in "Simulator Setup".
  5. Fixed setup category display in "Setup Workbench".
  6. Fixed a bug for "Race Center", "Race Reports" and the Race Strategist where starting position were missing in big grid multiclass races.
  7. [Expert] Clarified several aspects in the documentation about [car meta data definition](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#introducing-a-new-car) for "Setup Workbench".
  8. [Expert] New [EnumerationHandler](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#introducing-new-car-specifications) for car meta data definition in "Setup Workbench".
  9. "Simulator Startup" now supports the so-called startup profiles, which let you manage and activate the most important configuration settings for solo and team races in a matter of seconds. See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles) for more information.
  10. New [control key modifiers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) for "Simulator Startup" allow you to quickly open the startup profiles editor and run the startup process automatically when closing the editor. Some of the former keyboard modifiers for "Simulator Startup" have changed, therefore take a close look at the [list of modifiers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers).
  11. Some presets, that were used to disable voice handling completely or to start the Assistants muted, has been deprecated in "Simulator Setup". The functionality is now available in the [startup profiles](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles).
  12. A new preset has been added to "Simulator Setup" that installs a set of predefined startup profiles for you.
  13. Information about the active startup profile has been added to the "System Monitor".
  14. The Button Box visual representation got a little bit slicker.
  15. The memory of the Driving Coach is not cleared any longer after the end of a session, so that ou can talk about our recent race after crossing the finish line, for example.
  16. New version of the Team Server with some internal changes. If you are running your onw Team Server, you have to redeploy it.
  17. Added support for new AI driver swap in Automobilista 2.
  18. Optimized keyboard navigation in list views.
  19. All dialog boxes like alerts, file selectors, and so on, now fully shield their underlying windows against user interaction.
  20. [Developer] Information about the active startup profile has been added to the "Session State.json" file.
  21. [Developer] Information about the pitstop forecast has been added to the "Session State.json" file.
  22. [Developer] The new function *withBlockedWindows* allows you to execute a function with all open windows blocked against interaction.
  23. [Internal] Migrated to AHK version 2.0.11.
  24. [Internal] The copyright information has been updated to 2024 in all parts of the software.
  25. New car models for "Setup Workbench":
      - Assetto Corsa
        - BMW M3 E30 (fixed)
		- McLaren F1 GTR

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-552), since a couple of presets were deprecated, but also, if you are running your own Team Server.

## 5.5.1.2-release 12/22/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed incorrect information given by the Strategist, when no valid strategy can be computed in autonomous mode.
  4. Fixed a couple of permission errors when accessing the installation and update download repository in the Amazon cloud.
  5. Controller binding artefacts are now handled correctly for controllers that have been removed from the configuration.
  6. Introduced special handling for errors raised during application startup.
  7. Fixed handling of unknown tyre compound for any simulator. Unknown tyre compounds are now mapped always to "Dry (Black)".
  8. [Developer only] The language-specific default instructions for the Driving Coach have been made translatable.
  9. New car models for "Setup Workbench":
     - Assetto Corsa
       - BMW M1

## 5.5.1.1-release 12/19/23
  1. Fixed a critical bug in the telemetry providers for rFactor 2.

## 5.5.1.0-release 12/15/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The automatic updater now checks, whether the update was successful for all files. A warning is emitted, if any files had been skipped, for example, because they are in use by another software at the time of the update.
  4. The "Edit Labels & Icons..." button is now also available on the simulators page in "Simulator Setup".
  5. The actions to select the front and rear brake pads for service has been added for *Assetto Corsa Competizione* to "Simulator Setup".
  6. A sanity check has been integrated in the automatic setup of the pitstop settings for *Assetto Corsa Competizione*. A warning sound is emitted, if incorrect values have been entered, for example, if a brake pad change has been activated.
  7. The application of the preference slider for an early or a late pitstop has been optimized for the automatic recalculation of a strategy by the Strategist or in the "Race Center".
  8. Fixed an off by one error for the post pitstop tyre set information for *Asseto Corsa Competizione* in "Race Center".
  9. Corrected several values in the *Service* section of the Pitstop report in "Race Center".
  10. Separate values for service time, repairs time and pitlane time loss are now displayed in the Pitstop report in "Race Center".
  11. Many [changes to the pitstop settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop), that are made using the game controls, will be correctly detected now by the Race Engineer in *rFactor 2*, *Assetto Corsa Competizione* and *iRacing*, as long as a pitstop has been already planned and prepared. The changed settings will be automatically integrated in the active pitstop plan of the Engineer and will also update the planned pitstop in the "Race Center". Exceptions are, for example, the choice of the tyre compound or the repair options in *Assetto Corsa Competizione*, since these values are unfortunately not available in the data API. More information can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#the-pitstop).
  12. Changes in the pitstop settings are now almost immediately reflected in the "Race Center", independent how the change was initiated.
  13. Potential fix for scrambled result in "Race Reports", when drivers quit in the post-race lap, before the current driver has finished.
  14. New car models for "Setup Workbench":
      - Assetto Corsa
        - BMW M3 E30 Group A

## 5.5.0.0-release 12/06/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a couple of bugs in the handling of the *rFactor 2* pitstop setup.
  4. Fixed position and standings handling for *rFactor 2*.
  5. A new setting in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allows you to set the interval, in which pitstop setup information is requested from *rFactor 2*. Default is once per minute.
  6. The handling of the *Automobilista 2* ICM has changed. You must now [set the ICM to the Pitstop page](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#special-requirements-when-using-the-pitstop-automation-1) and select the line at the bottom before using any of the automation of Simulator Controller.
  7. Added a switch in the "Race Settings" app which allows you to promote the Assistants into fully autonomous mode for strategy and pitstop handling. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#autonomous-mode) for more information.
  8. A corresponding setting is available in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) of the "Session Database".
  9. The Assistants now detect correctly that you have have quitted a session in the formation lap and started a new session with a different car or a different track.
  10. Increased reliability for position and standings calculations for retired cars.
  11. The compatibility of "Simulator Setup" and "Simulator Configuration" has been increased further.
  12. It is no longer necessary to hold down the Control key, if you want to revisit the "Basic" configuration step in "Simulator Setup".
  13. [Developer only] You can now run a replay of a recorded session for debugging purposes. Make a copy of the *Temp\XXX Data* folder, with *XXX* the three-letter code for the given simulator. Then start "Simulator Controller" with arguments "-replay *dataFolder*" (with *dataFolder* pointing to the beforementioned copy of the data folder).
  14. [Internal] Finalized migration of all Simulator Controller downloadable components to AWS.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-550).

## 5.4.8.0-release 12/01/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in Google speech recognizers which raised a spoken error message, when effectively only silence was recognized.
  4. The [text size of the info components](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) in the "System Monitor" can now be configured.
  5. The pitstop info component will show you a forecast of the settings for a pitstop, when no pitstop has been planned by the Race Engineer yet.
  6. An installer for the .NET 7 Runtime has been added to the automated installation process.
  7. The "Tactile Feedback" plugin has been updated to work with the latest version of *SimHub*. Please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-548), if you are using this plugin, since you have to update the triggers in *SimHub*.
  8. The *SimHub* profiles provided in the *Profiles* directory has been updated to reflect the changes mentioned above.
  9. More translations for the French language has been provided by our community member @SlatMars. This time translations has been added for the settings in "Session Database" as well as all the action labels used for Button Boxes and Stream Decks.
  10. New car models for "Setup Workbench":
      - Assetto Corsa
        - BMW M3 E30

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-548), especially if you are using the *SimHub* integration with the "Tactile Feedback" plugin.

## 5.4.7.0-release 11/24/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed Spotter to announce best top speed in localized units.
  4. Thanks to our community member @SlatMars we now have a complete translation of the Assistant grammars for the French language.
  5. The handling issues as well as the car setup settings in the "Setup Workbench" has been also translated to the French language.
  6. The French language pack for the voice recognition has been added to the automated installer.
  7. Removed ".NET Runtime 6.0" from the automated installer.
  8. A couple of optical enhancements & clarifications in "Session Database".
  9. Fixed tyre laps counting in "Practice Center" for rare cases of automated pitstops.
  10. The default pitstop rule in "Strategy Workbench" is now set to *Optional*, rather than *Window*.
  11. Full rework of the handling of the start procedure incl. formation lap for the Spotter. No proximity warnings will be issued by the Spoter during the formation lap under normal circumstances.
  12. New car models for "Setup Workbench":
      - Assetto Corsa
        - BMW M4 Coupe
        - BMW M4 Coupe Akrapovic Edition

## 5.4.6.1-release 11/18/23
  1. Fixed the OpenAI connection for the Driving Coach.
  
## 5.4.6.0-release 11/17/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A new Control modifier lets you overrule apps which resist to exit, because they are currently working on background tasks. Hold the Control key, until all applications have exited. Please note, that this may lead to a loss of data, for example the post race report.
  4. The UI translation for the French language has been completed.
  5. A couple of optimizations for the handling of the Pitstop settings in *Assetto Corsa Competizione* has been introduced:
     - Every setting change will now be checked after completion of the setup process. If an unwanted difference is detected, for example, because the driver intervened with the keyboard command input, the desired change is done again.
	 - Unfortunately, *Assetto Corsa Competizione* does not provide the information, which tyre compound is currently selected in the Pitstop MFD in the data API. A new strategy in the option walk will now detect it anyway by checking the availibilty of other settings.
  6. Superfluous proximity alerts for cars that are actually behind a wall and driving in another direction or are not moving at all, are now supressed.
  7. You can now specify [a preference for an early or a late first pitstop](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation), when running a strategy simulation in the "Strategy Workbench".
  8. A runtime for large language models has been integrated into Simulator Controller, which allows you to run a LLM for the "Driving Coach" locally on your PC, without installing additional software or creating an OpenAI account. Please note that this increases the performance and memory requirements for the "Driving Coach" dramatically, but if your PC can handle it, then it is a great alternative to OpenAI and Co. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#llm-runtime) for more information about the configuration requirements.
  9. New [control key modifiers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) for "Simulator Configuration" and "Simulator Setup" let you decide whether other applications will be terminated before working on the configuration.
  10. New car models for "Setup Workbench":
      - Assetto Corsa
        - Alfa Romeo GTA (fixed)
	    - BMW M3 E92

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-546).

## 5.4.5.0-release 11/10/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed tyre handling for modded cars in *Assetto Corsa*.
  4. Fixed a couple of timing issues related to the Assistants startup orchestration on systems with a low-end CPU.
  5. Fixed start grid positions (lap 0) for "Race Reports".
  6. Fixed a bug in "Practice Center" with data lost even if a switch to a differen simulator, car or track was rejected.
  7. Strategies are now saved together with a session in "Race Center".
  8. The top speed of the last lap as well as the overall best top speed are now shown on the session info page in "System Monitor".
  9. The Spotter now informs you whenever you have set a new best top speed.
  10. You can now [take notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#data-analysis) in the "Practice Center" for each stint, for example to remember and compare any changes made to the setup.
  11. You will now get a warning on the dashboard in "System Monitor", when no valid participant information is available in the simulation data.
  12. Thanks to our Discord member @slatmars we will get a full translation of Simulator Controller for the French language. This release contains initial tranlsations for the UI. More translations, as well as Assistant grammars and other stuff will follow with the next releases.
  13. Added configuration support for the newly released GPT models by OpenAI for the "Driving Coach".
  14. [Developer only] The top speed information is also available in the "Session State.json".
  15. [Internal] Cleanup of the Binaries folder.
  16. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Alfa Romeo GTA
	    - BMW M235i Racing

## 5.4.4.0-release 11/03/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Integrated the Google Cloud Services for voice recognition. Additional info has been added to the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control).
  4. The session info components are now aligned at the top in "System Monitor".
  5. **Don't miss this new feature, it is insanely powerful:** A couple of new [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allows you to control the confirmation behaviour of the Assistants. Using this, full autonomy can be given to the Assistants regarding decisions when and how to change the strategy, when to plan and prepare a pitstop, and so on. See the new [documentation about non-standard configurations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#non-standard-voice-configurations) for more information.
  6. The actually driven time so far is now shown in the "Duration" widget on the session info page of "System Monitor".
  7. It is now enforced to close other applications before working on the configuration in "Simulator Setup" or "Simulator Configuration".
  8. [Developer only] A file "Translations.report" is now stored in the *Temp* directory with information about missing or erroneous translations, if *Debug* mode is enabled.
  9. New car models for "Setup Workbench":
     - Assetto Corsa
	   - Toyota Supra MKIV
	   - Toyota GT86
		
## 5.4.3.2-release 10/27/23
  1. Fixed a **critical** bug for the voice synthesizer handling during configuration.

## 5.4.3.0-release 10/27/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed sorting of the "Overview" report to the race number column in "Race Reports" and "Race Center".
  4. Windows size constraints can now be disabled in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration), to make windows smaller than originally designed. Usefull in environments with very small monitors.
  5. The original size of the "Strategy Workbench" window has been reduced a little bit.
  6. The "Pitstop" menu in "Race Center" has been extended with additional commands, which were available only as buttons before.
  7. The tyre info widget on the "Session" page of the "System Monitor" now includes the currently mounted tyre set.
  8. The mounted tyre set has also been included ["Session State.json" file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) generated by the ["Integration"  plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration).
  9. The voice synthesizer now also supports the Google Cloud Services. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#google-speech-services) for more information.
  10. [Developer only] Complete new documentation, which describes the [Localization and Translation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#localization-and-translation) process.
  11. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Toyota Supra MKIV Time Attack

## 5.4.2.0-release 10/20/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed transfer of tyre setup from first stint to pitstop fields using the copy menu in "Race Center".
  4. Another (and hopefully last) fix for the **critical** runaway loop during install and update.
  5. Fixed FCY handling by the Strategist for cases when traffic simulation has been disabled.
  6. Fixed a bug for explicit tyre set selection in solo races with more than two pitstops.
  7. The scaling of widgets in all windows on high DPI monitors with activated size scaling has been optimized. Should look pretty good now.
  8. The duration of pitstop service and repairs as well as the pitlane delta will be shown in the pitstop info window in "Race Center". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#initiating-a-pitstop-for-the-current-driver) for more information.
  9. The pitstop info widget on the "Session" page of the "System Monitor" now includes the required time for the pitstop incl. pitlane delta.
  10. The required pitstop time has also been included ["Session State.json" file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) generated by the ["Integration"  plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration).
  11. New simulator specific [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database", which define the conversion between internal damage values for bodywork, suspension and engine damage and the time in seconds needed for repair the damage.
  12. The behaviour of the "Treshold" choice for repairs in "Race Settings" has changed. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-pitstop) for more information.
  13. Default for refueling time has changed to 1.8 seconds per 10 liter of fuel.
  14. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Lotus Evora GTE
	    - Lotus Evora GTE Carbon

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-542).

## 5.4.1.2-release 10/16/23
  1. Fixed a **critical** bug for *Assetto Corsa* which refuses to work after a fresh installation.

## 5.4.1.1-release 10/15/23
  1. Fixed a couple bugs when registring voice commands in mixed mode (both pattern based and full-text based).
  2. Fixed a **critical** bug in strategy re-calculation which could result in a call to pit way too early.

## 5.4.1.0-release 10/13/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a **critical** bug, that triggered an endless loop in the isntall and update process, when the current Windows user has Admin privileges.
  4. Many functional additions to the Driving Coach.
     - The instructions have been updated and extended. Please read the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-541) for instructions how to update your configuration accordingly.
	 - Part of the new instructions is a data interface, that can be used to provide data about your recent laps as well as the full standings at the end of the last lap to the Driving Coach for performance analysis.
	 - The Driving Coach can use the Telemetry Analyzer of the "Setup Workbench" during a session to acquire information about any handling issues to give you precise and context aware coaching on driving behaviour and possible car setup changes.
	 - Instructions can be deleted in the configuration, if you don't need them at all.
	 - New [voice commands](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#enabling-and-disabling-specific-instructions-and-information-processing) for the Drivong Coach to enable / disable instructions and thereby data integration during a running session.
	 - A couple of [new settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allow you to select, which instructions will be active during the different session types (Practice, Qualifying, Race).
     - Additionally, a [new setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" can be used to enable a mode, in which the Driving Coach will only repeat the last sentence and then continue, when the voice output is interrupted by another Assistant. Note: This setting is also available for all other Assistants.
	 - Extensive [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#instructions) has been added which describes in detail how to use instructions to customize the behaviour and personality of the Driving Coach to your personal taste.
	 
	 Please note, that it might be necessary to use a larger model like GPT 3.5 16k or GPT 4 to handle the full size of the input area, when all new instructions are active.
  5. New data categories in the Telemetry Analyzer of "Setup Workbench". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-issue-analyzer) for more information.
     - Issues for tyre temperatures outside a predefined range can be generated.
	 - Issues can be generated when the temperature difference of the outer and the inner part of the tyre is higher than a given threshold.
	 - Issues for brake temperatures outside a predefined range can be generated.
  6. The persistent structure of the Telemetry Analyzer settings has changed. You may have to recreate your settings in some rare cases.
  7. Tweaked the last lap detection for timed races again.
  8. Added "Practice Center" to Windows Start menu, which was forgotten at the initial release of "Practice Center".
  9. Optimized performance of icon refresh when switching profiles on Stream Deck.
  10. New car models for "Setup Workbench":
      - Assetto Corsa
        - Lotus Exige Scura
        - Lotus Exige 240 R
        - Lotus Exige S
        - Lotus Exige S Roadster

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-541), especially if you are using the Driving Coach.

## 5.4.0.0-release 10/06/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in "Strategy Workbench", which created a strategy with the wrong race length, when a mandatory pitstop in timed window was selected and the tyre usage forced an additional pitstop one lap before the end of the race. Certainly an edge case...
  4. A new assistant, the Driving Coach, is available. It is based on GPT technology and allows fluent communication about driving techniques, car handling issues, car setup topics and strategy. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach) for more information.
     - New plugin "Driving Coach", which handles the configuration and the communication with the assistant. The configuration of the Driving Coach supports three different service providers: OpenAI, Azure and GPT4All.
	 - "Simulator Setup" has been updated to support the new Assistant.
	 - New controller actions are available for the "Driving Coach" plugin.
	 - New icons have been introduced in the Stream Deck icon set.
  5. When the name of the current driver is unknown for any reason, "John Doe" was used in the past. Now, the name of the current user of Simulator Controller is used.
  6. The documentation link in "Simulator Configuration" is now context-aware and opens the documentation for the configuration tab, which is currently selected.
  7. "Simulator Setup" and "Simulator Configuration" are now almost fully compatible, when using both to work on the configuration.
  8. The meta model for "Setup Workbench" has been extended. It now supports non-standard setup settings for modded cars (currently only relevant for *Assetto Corsa*). See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#extending-and-cutomizing-setup-workbench) for more information.
  9. You can now supply your own sound files for the different notifcation sounds of Simulator Controller applications. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-your-own-sounds-for-confirmation-sounds) for more information.
  10. [Internal] Improved the detection of outdated downloadable components.
  11. [Developer Only] A new library for HTTP REST calling has been implemented.
  12. [Developer Only] The speech recognition framework now also supports free text recognition in addition to pattern based text recognition.
  13. New car models for "Setup Workbench":
      - Assetto Corsa Competizione
        - McLaren 720s Evo (fixed)
      - Assetto Corsa
        - Lotus Exige V6 CUP

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-540), because you don't want to miss out the new Assistant.

## 5.3.2.0-release 09/29/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A significant performance improvement has been achieved for the ACC Pitstop MFD handling.
  4. The detection of the last lap in timed races has been optimized.
  5. Manual installations using the ZIP file from GitHub are working again.
  6. "Simulator Setup" now detects software that has been removed from the PC after the last run of "Simulator Setup".
  7. The semantics of tyre set handling in "Race Settings" has changed. Please read the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#assetto-corsa-competizione) for more information.
  8. Migrated sources to AHK 2.0.10.
  9. New car models for "Setup Workbench":
     - Assetto Corsa
       - Shelby Cobra 427 S/C

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-532), because you may want to check the definition of tyre set handling for *Assetto Corsa Competizione*.

## 5.3.1.2-release 09/26/23
  1. Fixed a critical bug which creates an infinite loop during pitstop setup by the Engineer, when wrong tyre sets had been configured in the "Race Settings".

## 5.3.1.1-release 09/23/23
  1. Fixed a critical bug for the track mapper, that could present a dialog box while you are on the track.

## 5.3.1.0-release 09/22/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed a bug in "Simulator Setup", where last changes were not saved, when generating a new configuration directly from the basic setup page.
  4. Fixed a bug in "Session Database", where the list of settings were not updated correctly, when a new setting was added.
  5. Fixed a rare off by one error, when requesting a specific tyre set for a pitstop controlled by the "Race Center" in *Assetto Corsa Competizione*.
  6. Fixed too optimistic reporting of remaining laps based on remaining fuel by the Race Engineer.
  7. Fixed a couple of bugs in "Race Center" related to handling and reporting of sector times.
  8. Fixed a couple of bugs in "Practice Center" related to handling and reporting of sector times.
  9. Fixed hundreds of translation errors for the Spanish translation.
  10. Added the possible remaining driving time based on remaning fuel to the "Fuel" info widget in "System Monitor".
  11. A couple of optical enhancements to the info widgets in "System Monitor" to make them more readable.
  12. Prevent exit of applications while a background process is still running. This is especially important at the end of a long session, when the "Simulator Controller" process is still working on the session database or is creating a race report.
  13. Donload and installation has been optimized. A couple of very large parts of the package that are changed not very often has been removed from the installation package and will be handled as separate downloads, if required. This will speed up the update process significantly in the future.
  14. Migrated sources to AHK 2.09.
  15. [Experts Only] Changed timestamp in log files to 24 hour format.
  16. New car models for "Setup Workbench":
      - Assetto Corsa
        - Pagani Huayra
        - Pagani Huayra BC

## 5.3.0.0-release 09/13/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The "Simulator Setup" application has seen a major overhaul:
     - A new navigation menu at the bottom of the window allows you to go to each configuration step quickly.
	 - You can also always jump to a specific page when "Simulator Setup" is started, by [referencing this page in "Application Settings.ini"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool).
     - "Simulator Setup" now supports a kind of quick configuration, which allow especially new users to create a useful configuration very fast. See the extended documentation of the [quick start guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Quick-Start-Guide) for more information.
	 - Full configuration of the *Names*, *Languages* and *Voices* of the Race Assistants is now possible in the "Basic" configuration page.
	 - When a new configuration is being created, some of the changes made by the user in other application, for example in the settings of "Simulator Startup", will be preserved, if possible.
	 - The presets "Names and voices of Assistants", "Different Speaker Voices" and "Mode Automation" have been removed, since they are no longer needed. If such a preset is in use in your configuration, it will still be active, until you remove it.
	 - The "Push-To-Talk Behaviour" preset has been deprecated as well. This option is now available in the standard voice control configuration.
	 - All presets with search images for *Assetto Corsa Competizione* has been removed, since they are no longer needed.
	 - [Expert Only] A new preset "Custom Configuration" has been added with a very extensive sample section, which helps the experts to create special configurations.
	 - [Expert Only] When a new configuration is beeing created, "Simulator Setup" will first read the currently active configuration and then will generate the new configuration. The new configuration will then be integrated into the current configuration, preserving in most cases the custom additions, that may have been made with "Simulator Configuration", as long as they are not in conflict or happen to be the same configuration item. This means, that it is now possible to use the wizard "Simulator Setup" together with "Simulator Configuration" for configuration tasks.
  4. "Simulator Startup" learned a new trick. It can now unblock applications and DLLs, when holding down the Control together with the Shift key, while starting. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#fixing-problems) for more information.
  5. A fourth page has been added to the "Server Administration" application. This page shows a [list of all data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) currently stored on the Team Server and also allows to compact the database, if necessary. This requires a new version of the Team Server. **If you are running your own Team Server, you should update your instance(s).**
  6. The "Practice Center" now shows the sector times, if available from the simulator data API, in the laps list and various reports.
  7. The "Race Center" now shows the sector times, if available from the simulator data API, in the laps list and various reports.
  8. The Race Spotter now compares your pace to the pace of all cars on the grid and informs you from time, whether you are faster than cars that are in positions in front of you.
  9. When you are in close combat with other cars, the Spotter now informs you, in which sectors your opponent is faster or slower than you.
  10. The Race Strategist now understands Full Course Yellow situations and can evaluate, whether a pitstop under FCY might be beneficial:
      - New [voice command "We have Full Course Cellow. Should I come to the pit?"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) to ask the Strategist for possible actions under Full Course Yellow.
	  - New controller action ["FCYRecommend"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the Race Strategist plugin, which triggers the same.
	  - New icon in the Stream Deck icon set for the "FCYRecommend" action.
	 Please see the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#handling-full-course-yellow) for more information about Full Course Yellow handling.
  11. New voice command for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)) to ask for the last lap time of a specific car: "Can you tell me the last lap time of car number X?"
  12. New voice command for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)) to ask for the last lap time of a car in a specific position: "Can you tell me the last lap time of position X?"
  13. You can also get information about the name of the driver in the car ahead or behind you:
      - New voice command for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)): "Can you tell me the name of the driver ahead / behind?"
	  - Corresponding information request actions "DriverNameAhead" and "DriverNameBehind" for ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and ["Race Spotter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) plugins.
	  - New icons for the Stream Deck icon set for above actions.
  14. Also you can get information about the class of the car ahead or behind you (as long as available):
      - New voice command for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)): "Can you tell me the class of the car ahead / behind?"
	  - Corresponding information request actions "CarClassAhead" and "CarClassBehind" for ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and ["Race Spotter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) plugins.
	  - New icons for the Stream Deck icon set for above actions.
  15. Finally you can get information about the cup category of the car ahead or behind you (as long as available):
      - New voice command for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)): "Can you tell me the cup category of the car ahead / behind?"
	  - Corresponding information request actions "CarCupAhead" and "CarCupBehind" for ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and ["Race Spotter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) plugins.
	  - New icons for the Stream Deck icon set for above actions.
  16. *Reactivated* proper handling of improper formed voice commands.
  17. Small performance improvement for voice commands, since grammars are now pre-compiled in the background.
  18. The threshold values for the Sorenson-Dice algorithm, which is used to compare spoken commands against the registered command syntax, can now be configured in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). This allows you to tune, how exact your commands must follow the predefined syntax and it can also be used in cases, where a wrong command is detected, which can happen when two commands are quite similar.
  19. New test mode in the voice configuration let you now test your changes to pitch, speed or distortion in place.
  21. The special configuration to choose between the different possible behaviours of the *Push-To-Talk* button (formerly handled by the "P2T Configuration.ini" file) has been moved to the standard configuration. This is automatically handled by "Simulator Setup" and "Simulator Configuration".
  21. Automatic updates for versions prior to 4.0.0 are no longer possible.
  22. Migrated the sources to AHK 2.08.
  23. [Experts Only] The grammar files has been split up and modularized.
  24. [Experts Only] New [controller action functions "targetListener", "startActivation", "startListen" and "stopListen"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions), which let you control the listen mode of voice control from your custom scripts. There are also three new icons in the Stream Deck icon set, which can represent these custom actions.
  25. [Experts Only] *Normal* controller functions (for example "Button", "Dial", etc.) can now also call a [controller action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) directly. This opens endless possibilities for controller hardware configuration.
  26. [Developers Only] MultiMap files can now "#Include" other MultiMap files.
  27. New car models for "Setup Workbench":
      - Assetto Corsa
        - Alfa Romeo MiTo QV
		- Alfa Romeo Giulietta QV

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-530). You will find there a description how to change your configuration to use the new capabilities of "Simulator Setup".

## 5.2.3.0-release 08/18/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Significant speed improvement in ACC pitstop setup when using the same tyre compound.
  4. Fixed position data handling for retired cars in *Assetto Corsa Competizione*. Previously it was possible for the complete grid information to be in disorder, when a car retired, but was still reported with its last position by the data interface.
  5. The session info widget in the "System Monitor" will now also be updated for all team members in a team race, which have not driven their first stint. Same is true for the JSON state file generated by the "Integration" plugin.
  6. The recommended cold tyre pressures will be displayed in the "Tyres" session info widget in the "System Monitor".
  7. The "Practice Center" now warns you, if you try to switch the simulator, car or track, while still having unsaved data in an active session.
  8. The audio routing capabilities have been extended. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) for more information.
  9. [Experts Only] A new [controller action function "callCustom"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) has been addded, which allow you to activate custom controller functions from external scripts, for example.
  10. [Developer Only] Additional information has been added to the ["Session State.json" file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) for tyre pressures. The property "Pressures" was renamed to "HotPressures" and a new property "ColdPressures" is available now.
  11. New car models for "Setup Workbench":
      - Assetto Corsa
        - Alfa Romeo 4C
        - Alfa Romeo 33 Stradale (Fixed)
        - Lamborghini Miura (Fixed)

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-523).
  
## 5.2.2.0-release 08/11/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The management of tyre pressure data has been fixed. It happened in rare situations, that tyre pressure were not stored in the session database, although you gave your consent.
  4. A new [voice command "Tell me my last laptime"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) is available for the Race Strategist and Race Spotter.
  5. A new [information request action "LapTime"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) is available for the Race Strategist and Race Spotter to request the last lap time by a press of a button on your controller hardware.
  6. An icon has been added to the Stream Deck icon set for the "LapTime" information request action.
  7. *Practice run sheets* have been added to the "Practice Center", which helps you to create telemetry data for special conditions and car setups, for which no data is available yet. See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#using-the-run-sheet) for more information.
  8. When a stint plan is created or updated in the "Race Center" it now not only includes information from the strategy but also take the already run stints into account, especially for the driver selection of a stint in the stint plan. When a stint plan is already present, driver selection of stints that have not been started will not be overwritten anymore by information from the strategy.
  9. When initializing the settings for the next pitstop in the "Race Center", used tyre sets of past stints will be taken into account and the system tries to [recommend the next fresh tyre set](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop). But be sure to double check the recommendation to not end up with worn tyres after your pitstop. This method can be deactivated in the "Pitstop" menu.
  10. "Race Center" and "Practice Center" now remember many menu choices between different runs.
  11. "Practice Center" and "Race Center" remember the layout of the telemetry charts between different runs.
  12. Holding down the Ctrl key while starting the "Race Center" will deactivate the synchronization.
  13. Potential fix for the nasty auto update loop, which has been encountered by a couple of users.
  14. [Developer] Additional information has been added to the ["Session State.json" file](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) introduced with the last release.
  15. [Developer] The data format of the "Session State.json" file has been updated to better reflect the JSON data type standard.
  16. New car models for "Setup Workbench":
      - Assetto Corsa
        - Lamborghini Miura

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-522).
  
## 5.2.1.0-release 08/04/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Many bugfixes and polishing in the new "Practice Center".
  4. Better last lap detection in timed races.
  5. The Spotter now announces the last lap of the leader or yourself.
  6. Fixed the handling of the "Invalid" column in "Race Center".
  7. Fixed data integration for RaceRoom Racing Experience. Sorry for that.
  8. Fixed tyre wear for RaceRoom Racing Experience, which was 100% for fresh tyres.
  9. Fixed a couple of stability issues in the Stream Deck plugin. If you have encountered problems lately, you might want to update the plugin.
  10. Fixed a rare bug with SFX-100 motion intensity controller.
  11. Support for a couple of new fields has been added in the simulator data files - inner, middle and outer tyre temperatures and in-game tyre compound identifiers for *Automobilista 2*.
  12. The telemetry charts in "Race Center" and "Practice Center" now apply unit conversion correctly.
  13. New data summary report in "Practice Center" and a new tab to review the [available telemtry data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#exploring-data).
  14. New [stints summary report](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#data-analysis) in "Practice Center".
  15. Updated *Automobilista 2* data integration to shared memory API version 13.
  16. The Standings info widget in "Session Monitor" now also shows the observed opponent, if one is currently observed by the Spotter.
  17. A new [plugin named "Integration"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) is available, which exposes the internal state of the Race Assistants and many information about the current session to external applications using a JSON file, which is updated periodically, even when another driver is running the car in a team race. With this it is possible, for example, to create a dashboard for Simulator Controller in SimHub.
  18. New car models for "Setup Workbench":
      - Assetto Corsa
        - Alfa Romeo 33 Stradale
		- Alfa Romeo Giulietta QV Launch Edition 2014 (Fixed)

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-521).
  
## 5.2.0.0-release 07/28/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Introducing a complete [new tool "Practice Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center), which helps you to manage your practice sessions and allows you to inspect and select the data to be transfered to the session database. The development of this application is still in its early stage, but it is already quite usable.
  4. A new controller action function "openSoloCenter" allows you to open the "Practice Center" from your controller hardware.
  5. A new plugin argument "openSoloCenter" has been introduced for the "Race Engineer" and "Race Strategist" plugins.
  6. Added an "Invalid" column for the "Car" report in "Race Reports".
  7. Added an "Invalid" column for the *Laps* list in "Race Center".
  8. A bug has been fixed which may crash the Simulator Controller background process, when a custom controller function without a trigger was configured.
  9. The application icons in "Simulator Startup" have been rearranged.
  10. New car models for "Setup Workbench":
      - Assetto Corsa
        - Alfa Romeo Giulietta QV Launch Edition 2014

## 5.1.2.0-release 07/21/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The Strategist and the Spotter can now be asked for the time to a specific car. Example: "Can you tell me the gap to the car number 81?"
  4. The Spotter can now be asked to observe a specific car: "Can you observe car number 81?". Very useful to gather periodic information about what your most important opponent is doing. Please take a look at the [updated documentation for voice commands](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)).
  5. Car numbers are now shown in the standings widget for the "System Monitor".
  6. Playing a replay in *Automobilista 2* no longer is interpreted as a valid session.
  7. A couple of voice commands has been fixed in the Spanish grammar for the Strategist and the Spotter.
  8. A new communication method is available for the Stream Deck. It has been reported, that using OBS parallel to Simulator Controller can brake the Stream Deck functionality of Simulator Controller. The new communication method, although a little bit slower, prevents this. A new setting in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) let you choose between the available communication methods.
  9. [Experts only] A new setting in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) let you choose the frequency of external command processing. Change with caution.
  10. [Experts only] The controller action function "call" has been renamed to "invoke".
  11. [Experts only] It is now possible to alter the time, a press or click on the *Push-To-Talk* button is considered as an activation event. Default is the Windows setting for mouse double click speed. See the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) for more information.
  12. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Audi R8 LMS Ultra

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-512).

## 5.1.1.0-release 07/14/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. You can now enable an acoustic feedback for Audible feedback in the Telemetry Analyzer. Whenever a handling event is registered (over- or understeering) a short beep of varying pitch and intensity will give you some feedback. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-issue-analyzer) for more information.
  4. [Experts only] It is now possible to define your own modes and layers for Button Boxes. This allows any function of your sim or other applications on your PC to be triggered by the Button Box, not only the actions supplied by the plugins. Please see the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-of-custom-modes) for more information.
  5. A new controller action function "mouse" is available, which allows you to send virtual mouse clicks to any application by a button press on your controller.
  6. [Experts only] A new controller action function "call" let's you invoke internal methods for any plugin or the Controller itself.
  7. Fixed a regression introduced in the last release, which disabled the pitstop settings preview window in "Race Center".
  8. A new setting in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) allows you to set the update frequency for the data transferred to the Team Server in team sessions. The default is an update each 10 seconds and I advise you to only go lower when hosting your own Team Server on a really powerful backend. Going lower on an instance run in the Azure cloud, for example, may stall the server and will increase the running costs at least.
  9. Apps launched from "Simulator Startup" will select the current simulator, car and track a simulation is currently running.
  10. "Race Reports" will now try to open the recently selected simulator, car and track, if no simulation is currently running.
  11. New plugin parameter "openRaceReports" for the ["Race Strategist"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist), which let you start the race reports browser from your controller hardware.
  12. New controller action function ["openRaceReports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) which you can use in your custom controller actions.
  13. Fixed "Use initial pressures" for initialization of sessions with a very long formation lap.
  14. Migrated the sources to AHK 2.04.
  15. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Ford GT40

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-511) if you have defined custom controller functions in your "Configuration Patch.ini" file (mostly an experts topic).

## 5.1.0.0-release 07/07/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. The oversteer detection method of the Telemetry Analyzer in the "Setup Workbench" has become much more sensitive and counter steering is now detected correctly (will always count as a *heavy+ oversteer event).
  4. Loading of car specific defaults in the Telemetry Analyzer has been fixed as well.
  5. A couple of bugs in the behaviour of the sliders in the Telemetry Analyzer in the "Setup Workbench" has been fixed.
  6. New real-time capable data connector architecture. This will enable exciting new features in the future. A switch is available in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) to choose between the different protocols. The new protocol is the default, but you can go back, if you encounter data consistency issues.
  7. The bounding box for side proximity alerts by the Spotter has been increased from 6 to 8 meters lateral.
  8. The waiting time for unavailable data in "Race Center" has been reduced.
  9. Fixed a couple of bugs, which had been introduced to the Spotter for *Assetto Corsa* and *rFactor 2* by the latest .NET framework update by Microsoft.
  10. Fixed car coordinates for *rFactor2* (used by the Track Automations).
  11. Fixed race reports and standings data in "Race Center" for *rFactor2*.
  12. Fixed track scanner and mapper for rare cases with special characters in car or track names. Happened especially in *Automobilista 2*.
  13. Fixed a problem with manually locating *iRacing* in a non-standard install location.
  14. A new documentation chapter describes the process of [manually locating games and other software](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#locating-simulators-and-applications) during installation.
  15. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Ferrari SF15-T

## 5.0.9.1-release 06/30/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. When you press the renew button for the data token, you are now asked, if you really want to renew the token, before it is actually renewed.
  4. Traffic simulation now respects the pitstop window rule when calculating the lap for the next pitstop.
  5. Imprecise Spotter gap announcements are further reduced.
  6. Fixed session info in "System Monitor" not updating when not having run the first stint in team sessions.
  7. "System Monitor" can now be resized vertically.
  8. Performance improvements in process communication.
  9. You can now press and hold Control to restart the ACC pitstop option walk, if it is running for an unusually long time.
  10. Fixed drivers position information for *iRacing*.
  11. Initial support for *Rennsport*. Not yet documented...

## 5.0.9.0-release 06/23/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. New Control key modifier for "Load current Race Strategy" in "Race Center" allows you to go back to the strategy, that is associated with the current session. Helpful, after you have run a strategy simulation, but you want to go *back*.
  4. New [core setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration) to choose the activation recognizer for the "Voice Server". Normally, the "Server" recognition engine will be used, but you can use this setting to change to a recognizer run on Azure, for example.
  5. Fixed data synchronization of setups and strategies in the "Session Database". Also a bug has been fixed in the Team Server, that causes a setup or strategy not to be deleted on the Team Server, when it gets deleted locally. **If you are running your own Team Server, you should update your instance(s).**
  6. New "Empty" option for session info layout in "System Monitor".
  7. New floating layout for session info page in "System Monitor".
  8. Support for 3 more info widgets on the session info page in "System Monitor".
  9. Fixed the *Overview* report in "Race Reports" and "Race Center" to show only one position when no classes or cups are selected for grid partitioning.
  10. Increased stability of Team Server connections in case of connection loss events.
  11. Fixed team data management in cases where one or more assistants are disabled.
  12. Fixed a couple of bugs in the post pitstop report of "Race Center".
  13. More intelligent detection of unplanned pitstops and stops for penalties by the Race Strategist.
  14. The collaboration between the Strategist and the Engineer, when running a prepared strategy, has become more inteligent, especially for the last stint. The [documentation on strategy handliing](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) has been revised.
  15. If you ask the Strategist for the next pitstop, it will give you the option to inform the Engineer right away. Helpful, if you missed the upcoming pitstop warning.
  16. Fixed spurious input field appearing in Telemetry Analyzer, when running a recording.
  17. Migrated the sources to AHK 2.03
  18. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Alfa Romeo 155 V6 TI
		
Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-509) if you are running your own Team Server.
  
## 5.0.8.1-release 06/18/23
  1. Fixed a rare bug in the Spotter issuing a long list of proximity warnings in a row.
  2. Fixed strategy cancellation in team races.

## 5.0.8.0-release 06/16/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Four new widgets are available for the *Session* info page of the "System Monitor". The [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) has been extended.
  4. The widgets, that will be shown on the *Session* info page of the "System Monitor", can now be [configured individually](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities).
  5. A couple of new sanity checks has been integrated in "Simulator Setup" to ensure that only correct configurations can be created.
  6. Removed duplicate setting named "Strategy: Pitstop Window" has been removed from the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) and joined with "Strategy: Pitstop Variation Window (+/- Lap)". Please check your settings in the "Session Database", when you have used these settings.
  7. The Strategist will now only report strategy changes worth to be mentioned. New strategies, where only a small amount of fuel changed (up to half of the safety fuel), will be adopted silently.
  8. The Strategist will give you an even more detailed explanation of strategy differences when a change of strategy is recommended.
  9. The "Race Center" will from now on use values from the current strategy (if any) before taking values from the stint plan into account.
  10. The Spotter no longer will interrupt himself.
  11. Connecting to the Team Server using the Ctrl key works again.
  12. It is now possible to fully control a team race by the AI based Race Strategist running a predefined strategy. Please take a look at the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-and-preparing-pitstops-in-a-team-race-using-the-race-assistants) for more information.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-508) if you have used the *Pitstop Window* setting (see item 6 from the list above).

## 5.0.7.0-release 06/06/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A new page has been added to the "System Monitor", where important [information about the current session](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) is displayed. The next release will introduce more widgets for this session dashboard and the possibility to create your own set to be displayed according to your personal preferences and needs.
  4. When automatic strategy revision is enabled for the Strategist and a new strategy is available, you will get an overview about the key facts of the new strategy before you can decide, whether you want to activate it.
  5. It is now possible to enable the [Monte Carlo traffic simulation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#adjusting-the-strategy-during-a-race) method, which has been [available in the "Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#strategy-handling) for quite some time, for the strategy simulation by the Virtual Race Strategist as well.
     - New option in ["Race Settings"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) let you enable / disable the Monte Carlo method.
	 - A couple of [new settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" allow you to fine tune the behaviour of the probabilistic algorithm.
     Important: Use with caution, since it imposes additional load on the CPU.
  6. A couple of bugs in the Monte Carlo simulation of the "Race Center" has been fixed, which were introduced with version 5.0.
  7. Fixed a rare bug, when the wrong map was selected during strategy simulation.
  8. The pitstop history of all opponent cars will be considered to predict future pitstops in traffic simulations both in the "Race Center" as well as now with the Race Strategist. During the first stint, where no pitstop history is available, a probabilistic model is used as before.
  9. A [new setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) is available in the "Session Database" for each Assistant, to enable or disable grouping of voice output. When an Assistant voice output is interrupted, it tries to repeat its message. With the new setting you can choose, whether the whole message with all sentences which belong together or only the last sentence will be repeated.
  10. Handling of missing stint data (due to drivers not connected by intent or unintentionally) in the "Race Center" has been improved.
  11. The meta data for *RaceRoom Racing Experience* has been updated to the latest version.
  12. The meta data for *Assetto Corsa Competizione* has been updated to 1.9.3, incl. the new McLaren 720s GT3 Evo car model.
  13. New car models for "Setup Workbench":
      - Assetto Corsa Competizione
	    - McLaren 720s GT3 Evo

## 5.0.6.0-release 05/26/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Optimized fuel level simulation in "Strategy Workbench".
  4. **0** is supported again for initialial fuel level in strategy simulations.
  5. Tweaked strategy coefficients generated by machine learning for "Strategy Workbench".
  6. The time, when a pitstop is due, is now shown together with the corresponding lap in the strategy summary report.
  7. Default for strategy simulations is now "Telemetry Data" and the entry fields, which are only available in *initial conditions* simulations, are now disabled.
  8. It was possible that the Strategist asks two questions about pending pitstops at the same time. This has been fixed.
  9. Tweaked strategy comparison and selection by the Strategist, when using background strategy revision.
  10. The Strategist will remember, if the user has rejected a strategy update, and will not ask again for a revised strategy, which is considered to be similar.
  11. Both the Engineer and the Strategist will tell you now the number of laps already driven, when you ask for the remaining laps.
  12. Optimized the calculation and display of other cars pitstops in "Race Center".
  13. Fixed relocation of session database (broken since 5.0).
  14. Fixed data cleanup in "Strategy Workbench" (broken since 5.0).
  15. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Audi Sport Quattro
	    - Ford Escort RS1600
		
## 5.0.5.0-release 05/19/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. You can now set the range of interest for the gap (in seconds) for opponent information given by the Spotter. For example, you can ask the Spotter to give you only information about an opponent, which as at least a minute behind you, but you want no more information, when he is 5 seconds or less behind you, since you then will have visual information in the mirrors. You can find the corresponding [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database".
  4. It is now possible to let the Strategist recalculate the currently chosen strategy from time to time in the background, while you are in a race. Whenever a better strategy can be found (also, when no valid strategy is available anymore), you will be informed and can decide what to do. You can find the corresponding [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database", as well as on the [*Strategy* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in "Race Settings". This settings allow you to specify, in what situations the current strategy should revised. See also the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#adjusting-the-strategy-during-a-race) about strategy handling during a race, to understand what the Strategist will do automatically and what not.
  5. Support for cup categories has been added to the multi-class management. It is now possible to create reports with cars splitted in cup categories and you can also configure the assistants to understand cup categories to give you gap and delta information with regards to your own category. You can find the corresponding [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database". In all interactive reports as well as in the "Race Center", you can use the [settings for the race reports](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#selecting-report-data) to specify, how the information about the different car classes and cup categories should be displayed.
  6. If driver categories are available in the simulator (Platinum, Gold, ...), they can be displayed in various reports as well. See the documentation for the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#selecting-report-data) tool for information how to enable this.
  7. The "Strategy Workbench" has become a little bit *smarter*:
     - New stint length optimization rules based on data generated by machine learning have been included in the "Strategy Workbench". Will be active, if at least one optimization is enabled in the strategy optimizer. 
     - New tyre wear model based on data generated by machine learning have been included in the "Strategy Workbench". Will be active, if the *Tyre Usage* optimization is enabled in the strategy optimizer. The new approach gives the "Strategy Workbench" the ability to double-stint a tyre set, if necessary.
  8. The strategy scripting language has been extended with new functions and predicates. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#scenario-validation) for more information.
  9. Long running strategy simulations can now be canceled by pressing the ESC key.
  10. The data refresh frequency of the "Race Center" can now be configured, when holding down the control key and select the ["Synchronize"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) item in the "Session" menu.
  11. Fixed handling of *No tyre change* in pitstop preparation in "Race Center".
  12. Fixed handling of pitstop preparation in "Race Center", when no strategy has been selected.
  13. Fixed saving of tyre pressure data at the end of a solo session.
  14. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Nissan 370Z NISMO 2016
		- Nissan GT-R NISMO

## 5.0.3.0-release 05/12/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. Fixed the calculation of tyre laps in "Race Center", when an unplanned pitstop without tyre change has happened.
  4. Fixed the identification of the car of the driver for *Assetto Corsa Competizione* when a server has been restarted with the result positions of the previous server.
  5. The Spotter no longer informs about lapped cars that are actually in the pit.
  6. Fixed a few more possible deadlock situations in the session database, which could cause all applications to freeze up.
  7. Fixed the initialization of the race settings from the defaults in the session database (critical bug).
  8. Fixed cursor jumping to the left of an input field, when an incorrect character was entered.
  9. Integrated many changes for the English version of the Assistant grammars. Many thanks to our community member *Wayne Wortley* for the great work.
  10. New settings in the "Session Database" to [control the frequency of the telemetry updates](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) for all Assistants. Use with caution.
  11. New settings in the "Session Database" to [control the cooldown time](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) of the Race Assistants and the connection to the Team Server.
  12. All new [documentation of each and every modifier key](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Keyboard-Modifiers) available in the applications of Simulator Controller.
  13. [Experts only] All new [documentation of internal configuration options of the runtime environment](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). Use with caution.
  14. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Praga R1

## 5.0.2.1-release 05/05/23
  1. Critical bugfix for a potential deadlock situation in the session database, which could cause all applications to freeze up.

## 5.0.2.0-release 05/05/23
  1. Minor bugfixes, as always
  2. Documentation updates here and there, as always
  3. A lot of fixes for the "Race Center" in situations with incomplete data. These errors have occured after the rewrite for Release 5.0 and there still might bugs be in there in situations where not all drivers deliver correct data to the central Team Server. If you encounter such problems, please let me know together with a ZIP of the log files.
  4. UI themes (color schemes) are now available for selection in the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings) of "Simulator Startup".
  5. New settings in the "Session Database" to enable or disable parts or all of the automatic pitstop servicing specifically for a given simulator. This can be helpful, when a simulator, for example *iRacing* for tyre pressures, does not deliver correct data through the API and the calculations of the Engineer will be therefore wrong. See also next topic. Please note, that the tyre service is now disabled by default for *iRacing*. Please take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-502), if you want to enable it again.
  6. All new [documentation of each and every setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database".
  7. Fixed driver selection for telemetry browser in the "Strategy Workbench".
  8. Fixed penalty announcement by the Spotter after penalty has been cleared (hopefully for the last time).
  9. Fixed handling of tyre pressure settings for all cars in "Setup Workbench".
  10. Fixed a critical bug, which prevented settings from the "Session Database" to be actually used (falling back to default value in this case).
  11. Fixed Team Server build rule, thereby updating it to .NET Core 6.0. Please see the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-502), if you are using the Team Server locally, or if you are hosting a Team Server outside Azure.
  12. [Developer] All functions formerly named xxxTheme have been renamed to xxxSplashScreen. For example *getAllThemes()* => *getAllSplashScreens()*.
  13. New car models for "Setup Workbench":
      - Assetto Corsa
	    - Porsche 911 GT1-98

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-502) if you are using your own Team Server and you are not running it on Azure.

## 5.0.1.0-release 04/28/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Full integration of the WebView2 HTML rendering engine as a substitute for the old Internet Explorer plugin, since the support for Internet Explorer has been canceled by Microsoft. The implementation is not activated by default, but you can take a testflight by following the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-501).
  4. Initial implementation of a UI theming engine. Not fully implemented yet, but you can choose one of the predefined themes by following the instructions in the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-501).
  5. New car models for "Setup Workbench"
     - Assetto Corsa Competizione
	   - Ferrari 296 GT3
	   - Porsche 992 GT3 R
	   - Lamborghini Huracan GT3 Evo2 

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-501) for instructions on how to enable the WebView2 HTML rendering engine or switch between UI themes.

## 5.0.0.2-beta 04/26/23
  1. A couple of small bugfixes here and there.
  2. Fixed the startup of the Race Assistants to create a short flicker in various simulators.
  3. Fixed a rare connection issue between Stream Deck and Simulator Controller.
  4. Fixed that no account could be selected in "Server Administration".
  5. Fixed new password creation in "Server Administration".
  6. Fixed enabling / disabling a couple of options in the Tray menus.
  7. Fixed planning of pitstops w/o tyre swaps in "Race Center".

## 5.0.0.1-beta 04/23/23
  1. A large list of minor fixes.
  2. Fixed "Race Center" coming to the front of the window stack and redraw reports every 10 seconds.
  3. Introduced a field with a subversion info in "Simulator Startup".
  4. Added a preset for the new Stream Deck Plus layout.
  5. No more cut warnings in non-race sessions.
  6. Fixed a couple of window operations on devices with active DPI scaling.
  7. Fixed a bug where the report settings cannot be opened in "Race Center" when the reports are empty.
  8. Fixed deletion of entries in the "Session Database".
  9. Fixed "Simulator Download", so that it can be manually activated from the application launchpad again.

## 5.0.0.0-beta 04/21/23
  **IMPORTANT**: This release is based on a complete rewrite of the suite for a new version of the underlying programming language. Although testing has been intense, there still might be a couple of bugs lurking here and there. Therefore be sure to **make a backup copy of the "Simulator Controller" folder in your "Documents" folder**, before using this version. If you encounter problems, be sure to report them including a ZIP of the "[Documents]\Simulator Controller\Logs" folder and go back to the last stable build, which can be downloaded from the GitHub page.

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Full rework of all applications to support the new AutoHotkey 2.0 language.
  4. Modernized UI for all windows, especially on Windows 11.
  5. Support for window resizing in almost all applications.
  6. Renamed controller action function "hotkey" to "trigger" to avoid conflict with a new builtin function.
  7. Renamed "Setup Advisor" to ["Setup Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench).
  8. Allow multiple Setup Editor windows to be opened at the same time in "Setup Workbench"
  9. Renamed plugin argument "openSetupAdvisor" to ["openSetupWorkbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for all Race Assistant plugins.
  10. Big performance improvements in the rule engine.
  11. Fixed Spotter for reporting a penalty in ACC after actually clearing the penalty.
  12. Optimized collaboration between Strategist and Engineer for planned or recommended pitstops.
  13. Introduced support for the new Stream Deck Plus Layout.
  14. Copy menu for tyre pressures in "Race Center" now includes the initial setup from race start.
  15. Reduced # of incorrect warnings and announcements for the Race Assistants after a pitstop with driver swap.
  16. Updated the car meta data for *RaceRoom Racing Experience* to the latest version.
  17. Updated car and track meta data for *Assetto Corsa Competizione* 1.9, incl. new default for target tyre pressures.
  18. [Developer] Renamed configuration map functions to [Multi Map](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference#multi-maps-multimapahk) functions.
  19. [Developer] Introduced a couple of [specialized Array and Map](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#collections-classes) subtypes, which supports failure safe handling of unset elements.
  20. [Developer] Introduced of a [specialized subclass of *Gui*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#window-guiahk) which supports seamless resizing rules for controls.
  21. [Developer] Please note, that your own plugins must be ported to AutoHotkey 2 as well, to be used with the new version.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-500).

## 4.6.3.2-release 04/07/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Stint plans are now reset in the Race Center, when a session is cleared.
  4. A couple of performance improvements in the session database.

## 4.6.3.1-release 03/17/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Improved detection of retired cars in "Race Reports" and "Race Center".
  4. Improved display of pitstops in "Race Center".
  5. Fixed a bug in audio routing where a route was forgotten when an Assistant restarted.
  6. Fixed german grammars for Spotter and Strategist.
  7. Fixed the Spotter announcing a 0 time penalty in *Assetto Corsa Competizione*.
  8. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Lamborghini Aventador SV

## 4.6.3.0-release 03/10/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Multiple controller actions can be bound to a single custom voice command.
  4. Multiple action functions can be executed by a custom controller function.
  5. Increased performance of lap update in "Race Center" in low latency situations.
  6. The Spotter informs you know whether you are ahead or behind your opponent regarding the number of performed pitstops.
  7. Improved detection of retired cars in "Race Reports" and "Race Center".
  8. Fixed potential race condition in session database which leads to "Session Database" freezing while editing settings.
  9. Added a mechanism that creates a *.bak file whenever a database file is updated.
  10. The update procedure for Release 4.6.0 had a bug, which rendered the "MutedAssistant" preset to be non-functional after the update. This has been fixed with this release.
  11. New voice command for requesting the number of active cars in a session from the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Strategist-Commands-(EN)) or the [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)).
  12. New information request controller action "ActiveCars" for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and the [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter).
  13. New Stream Deck icon for the "ActiveCars" information request action.
  14. An *Input* section has been added to the [audio routing](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) capabilities, which allows you to configure the audio input device(s) to use for your different voice commands.
  15. Fixed toe values in meta data for "Audi TT RS VLN" in *Assetto Corsa*.
  16. A new script in the *Utilities* folder allows a fast startup of the voice command test mode.
  17. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Audi TT Cup

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-463), when you are using a Stream Deck, or when you want to use the new audio routing capabilities for your streaming setup.
  
## 4.6.2.0-release 03/03/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Better session end detection for practice sessions when you has been standing in the pitlane for a long time.
  4. General better last lap and session end detection for *Assetto Corsa Competizione*.
  5. "Race Center" now provides detailed information about the pitstops of all cars. This information is available in the details report for each lap.
  6. New [*hotkey* controller action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) allows you to program special keyboard sequences which then can be triggered by a push of a button or by issuing a voice command.
  7. A new "Copy" button in "Race Center" lets you select one of the predefined tyre pressure setups or one of the past pitstops settings which will then be used to [initialize the fields](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop) in the "Pitstop" tab.
  8. "Race Center" can now display the actual settings in the Pitstop MFD for those simulators, which support reading this data. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#initiating-a-pitstop-for-the-current-driver) for more information.
  9. Fixed several tyre compound meta data after the recent *rFactor 2* update.
  10. Increased reliability of repair setting choices in *Assetto Corsa Competizione*.
  11. Reduced frequency of blue flag alerts by the Spotter.
  12. Reduced frequency of behind alerts by the Spotter.
  13. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Mercedes-Benz SLS AMG

## 4.6.1.0-release 02/24/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Changed default for pressure calculation in "Race Center" to "Adjust (Reference)".
  4. Changed default for repairs to *Everything* in "Race Center".
  5. A new tool has been added to the "Session Database", which let's you investigate and correct (if necessary) recorded cold tyre pressures recommendations. See the [all new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#browsing-and-editing-tyre-pressures) for more information.
  6. Fixed a couple of bugs for pitstop handling in "Race Center".
  7. Fixed a critical bug in "Race Reports" where car and position information got scrambled in team races.
  8. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Ford Mustang 2015

## 4.6.0.0-release 02/17/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. New voice command for Race Engineer to ask for a pitstop plan including driver swap in team races. See the [all new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-and-preparing-pitstops-in-a-team-race-using-the-race-assistants) about the interaction between the Race Assistants and the "Race Center".
  4. New [controller action "DriverSwapPlan"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the Race Engineer and all simulators to create a pitstop including driver swap in team races. Aquivalent to the above voice command.
  5. New voice command for Race Engineer to adjust the pitstop plan so that a given amount of fuel is available after the pitstop. Just ask "Can we refuel **up to** xx liters?". Refuel target will be calculated for the next lap in this case.
  6. New [controller action "NoRefuel"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) for all simulators to set refueling amount to zero, New icons in the Stream Deck icon set for all new controller actions.
  7. New icons in the Stream Deck icon set for all above new controller actions.
  8. A fourth method to identify initial tyre pressures has been added to the configuration. This one takes the initial pressures which the tyres have in the moment, when data is acquired for the first time from the simulator. They can be a little bit off, though, when the car had sit for some time and the tyres lost temperature. Please see the [updated documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) for more details.
  9. List of driver-specific tyre setups can now be sorted in the "Race Center" by clicking in the column headers.
  10. Unprepared pitstops that had been performed without the control of the Race Engineer will be recorded for documentation in the "Race Center", although all information about refueling, tyre changes, and so on, will be empty.
  11. The term "Qualification" has been renamed throughout the suite to "Qualifying".
  12. New plugin parameter *raceAssistantMuted* for all Race Assistants to start the correspnding assistant in muted state. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  13. The "Simulator Setup" presets *Muted Engineer*, *Muted Strategist* and *Muted Spotter*, which completely disables voice input and output of a given Race Assistant, had been renamed to *Silent Engineer* and so on.
  14. New presets for "Simulator Setup", which are now named *Muted Engineer*, *Muted Strategist* and *Muted Spotter*, will use the new plugin parameter *raceAssistantMuted* to start up the corresponding Race Assistant in muted state. When you later on want to unmute the Assistant again, you can use voice command "You can talk again." or the "Unmute" controller action.
  15. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Lotus Evora GTC
	    - Lotus Evora GX

## 4.5.9.0-release 02/10/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. You can now [ask the Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)) about the cold trye pressures, which will result in ideal tyre pressures for the current conditions.
  4. You can also [ask the Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)) for the cold tyre pressures that had been used to setup the current tyres.
  5. New information request controller action "TyrePressuresCold" for the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), which is equivalent to using the first above voice command.
  6. New information request controller action "TyrePressuresSetup" for the ["Race Engineer"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer), which is equivalent to using the second above voice command.
  7. New icons in the Stream Deck icon set for request the cold or setup tyre pressure information.
  9. New [voice command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)) for Race Engineer to increase/decrease the cold pressures for all tyres at once for the next pitstop.
  10. New setting to decide whether [pressure loss corrections should be included in pitstop initialization](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop) in "Race Center".
  11. Remaining stint and remaining driver time will be shown in the lap report in "Race Center".
  12. Holding down the Shift and Control key while ending a session now prevents the Assistants to run their post-session actions.
  13. New car models for "Setup Advisor":
      - Assetto Corsa:
        - Mercedes-Benz C9

## 4.5.8.0-release 02/03/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Migrated Team Server to .NET Core 6.0. Attention: This requires an update of the Team Server. Please read the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-458), if you are hosting your own Team Server.
  4. Made gap ahead calculation more reliable for Strategist and Spotter.
  5. Track cut and penalty information are now given by the Spotter.
  6. "Race Center" shows penalties in the Stints and Laps lists and all associated reports.
  7. Added [new settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-spotter) to configure the verbosity for cut warnings and penalty information to the Spotter configuration.
  8. New car models for "Setup Advisor":
      - Assetto Corsa:
        - Lamborghini Huracan ST

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-458), especially, if you are using or even hosting a Team Server. The server code has changed and needs a redeploy.

## 4.5.7.0-release 01/27/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Reduced superfluous proximity alerts by the Spotter for cars behind the pit wall.
  4. The no longer needed race duration has been removed from all settings.
  5. A couple of new settings for Race Engineer in "Session Database". These allow you to choose the amount of information provided by the Engineer in practice, qualifacation and race sessions.
  6. Separated British from US-American Gallon in unit conversion framework.
  7. Fixed a couple of unit conversion bugs.
  8. Fixed the "RemainingSessionTime" information for *rFactor 2*, which prevented a preselected strategy to be accepted by the Race Strategist.
  9. "Race Center" will now also show information for planned, but not yet performed pitstops.
  10. Optimized driver selection in "Race Center" for *Assetto Corsa Competizione* and *rFactor 2*. Driver selection should be correct now, even when you plan and prepare a pitstop several times.
  11. "Race Center" is now compatible with pitstops planned and performed by the Race Engineer alone. Very helpful, when you are double stinting and no team mate is around.
  12. You can now save all driver specific tyre setups from the "Race Center" to an external file and you can upload from this file to another session. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#managing-driver-specific-tyre-pressures) for more information.
  13. "Simulator Setup" now allows you to locate a simulation or other software which is not installed in the standard location on your PC.
  14. New car models for "Setup Advisor":
      - Assetto Corsa:
        - Porsche Cayman GT4 Clubsport

## 4.5.6.0-release 01/20/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. New heuristical approach in strategy simulation to minimize surplus fuel at the end of a race.
  4. Fixed endless loop in strategy simulation with high optimizer values.
  5. Fixed weather forecast simulation for strategie development.
  6. Fixed standings and delta datas in "Race Center" for second stint drivers.
  7. Optimized pressure loss detection by the Race Engineer.
  8. All Assistants are now aware of the unit conversion framework. You can ask the Rece Engineer, for example, to refill 5 Gallons at the next pitstop. Or you will get tyre temperatures in Fahrenheit, if that is your chosen temperature unit.
  9. Fixed several unit conversion errors in "Race Center".
  10. [Developer] Documentation of the unit and data format localization framework.
  11. New car models for "Setup Advisor":
      - Assetto Corsa:
        - Maserati Granturismo MC GT4
		
## 4.5.5.0-release 01/13/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The copyright information of all sources has been updated to 2023.
  4. Further optimization of the pitstop recommendation by Strategist. If no specific lap can be derived, the next pitstop according to the current strategy will be used instead.
  5. Pitstop plans can now be updated from partial strategies in "Race Center". This is useful, after you have run a strategy simulation during an active session in "Race Center".
  6. Fixed handling of unplanned pitstops in "Race Center". A dummy entry will be inserted in the list of pitstops in "Race Center".
  7. Extended the stint plan report in "Race Center" with information about the date and time of the session.
  8. Extended session summary report in "Race Center" with information about the date and time of the session.
  9. Fixed the calculation of the pitlane duration for races with only a single pitstop in strategy simulations.
  10. Preset patch files can now be edited by double clicking on them in "Simulator Setup".
  11. Pitstops can now be prepared in the "Race Center" even during learning laps.
  12. Full support for system-wide localization of units and number formats. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#units-and-formats) for more information.
      Disclaimer: The current implementation changes only the bahaviour of the user interface. The Race Assistants still work with the default units as described in the documentation. This will change with a future release.
  
## 4.5.4.0-release 01/06/23
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. A new reload button allows you to reload the list of reports in "Race Reports". Helpful, when you just recorded a race on the selected track.
  4. Optimized the pitstop strategy simulation by the Race Strategist.
  5. The Race Strategist can now optionally explain its pitstop recommendation. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#racing-with-cato) for more information.
  6. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Porsche 911 GT3 R 2016

## 4.5.3.1-release 12/30/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Fixed handling of custom motion and tactile effects in "Simulator Setup".
  4. Potential fix for repair settings handling in Assetto Corsa Competizione.
  5. Optimized Spotter gap and delta announcements.
  6. Fixed loading and visualization of tyre pressures in "Race Center".
  7. Introduced a "Reconnect" button in "Race Center".
  8. Introduced a "No driver change" option for pitstop plans in "Race Center".
  9. The detection of the connected drivers in team races for *Assetto Corsa Competizione* was made more reliable.
  10. [Developer] Full refactoring of core framework in preparation for the integration of the unit and time/number format handling.

## 4.5.3.0-release 12/23/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The AI now detects pressure loss - either sudden or even a kreeping puncture, as long as not all tires are affected at the same time. The Race Engineer will inform you about pressure losses and he as well as the "Race Center" will try to compensate for that when planning and preparing pitstop. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#how-it-works) for more information.
  4. It is now possible to configure the [audio routing](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#audio-routing) for the voice output. This is an interesting feature for streamers or when you want to use your headphones and a 5.1 sound equipment at the same time.
  5. The input ranges of many integer fields have been tweaked to reflect the required number ranges.
  6. The handling of initial fuel in races with a formation lap has been optimized.
  7. A couple of rare update problems in "Race Center" has been fixed.
  8. Found and fixed (potentially) a rare bug, when the Spotter announces race half time at a totally wrong point in time. Happens only in team races.
  10. The "Race Center" now show target pressure deviations from the ideal setup in the lap report.
  11. Update of the Spanish translations by J. Krilin, so that all recent changes and additions are covered.
  12. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Audi Sport Quattro S1 E2
		- RUF CTR Yellowbird

## 4.5.2.1-release 12/16/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. *iRacing* is now supported for the telemetry analyzer of "Setup Advisor".
  4. The oversteer calculation has been revised for the telemetry analyzer. You may have to adjust your thresholds to higher values.
  5. The telemetry analyzer in the "Setup Advisor" now supports an auto calibration mode. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#real-time-issue-analyzer) for more information.
  6. Handling of tyre pressures has been optimized in the "Session Database" in cases where pressure data from multiple drivers are present in your database.
  7. Ideal tyre pressures are now supported for dry and wet tyres in the car specific meta data. If this information is present, it is used rather and will supersede the information entered in "Race Settings". You may however still overwrite it in the "Session Database".
  8. Tyre pressure setups can [now be initialized](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop) from data in the "Session Database" in "Race Center".
  9. Fixed a rare situation, where lap times are reported way too low during the first laps.
  10. Updated *RaceRoom Racing Experience* meta data to the latest version.
  11. The selection of simulator, car and track are now remembered in many applications
  12. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - BMW M3 GT2
		- Mercedes-Benz 190E EVO II

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-452).

## 4.5.1.0-release 12/09/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Fixed a bug, where an entry in the race settings could have been created automaticllay with an average fuel consumption of zero.
  4. Added the *rFactor 2* shared memory interface plugin to the installation plugins.
  5. Reorganization of the race reports database which provide a much improved performance when loading reports. Please make a backup copy before running the update, just in case.
  6. Optimized display of boolean values in "Session Database".
  7. Massive performance improvements in handling of settings in "Session Database".
  8. Fixed lap range selection in race reports.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-451).

## 4.5.0.0-release 12/06/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The "Setup Advisor" now supports a telemetry data analyzer, which derives handling issue entries from actual over- or understeering, while you are driving. See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#real-time-issue-analyzer) for more information.
  4. Introduced new "Release Strategy" command in "Race Center" which saves the current strategy to the Team Server without instructing the Race Strategist at the same time.
  5. Valid Team Server URLs are remembered in all applications, so that you can choose them from a list instead of retyping them all the time.
  5. Creating teams, drivers and sessions for the Team Server with "empty" names is no longer possible. Old "zombies" will be deleted automatically.
  6. New controller actions to "Mute" and "Unmute" for the [Race Assistant plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer).
  7. New icons for Stream Deck for the "Mute" and "Unmute" controller actions, individual for each assistant, but also available as an icon for *all* assistants.
  8. The Stream Deck Icons preset has been updated as well.

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-450), especially if you want to use the "Mute" and "Unmute" controller actions.

## 4.4.9.1-release 11/26/22
  1. Fixed a critical bug in the tyres database, where under specific conditions cold pressure from the last session was lost.

## 4.4.9.0-release 11/25/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Race strategies are now included in the "Session Database" browser and can be [managed here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#strategies).
  4. Support for sharing race strategies with the community (your [sharing consent](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#sharing-data-with-the-community) will popup for review again).
  5. Fixed post pitstop tyre analysis in "Race Center".
  6. Tweaked color coding of used tyres in "Race Center".
  7. Fixed unlimited practice mode for *Assetto Corsa Competizione*.

## 4.4.8.0-release 11/18/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Support for replication of car setups as well as race strategies has been added to the [Team Server data replication](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration). Attention: Using this feature requires an update of the Team Server. Please read the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-448), if you are hosting your own Team Server.
  4. You can now decide for each car setup individually, whether it will be [shared with the community](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#setups). But as before, sharing of setups with the community generally requires your consent. If you want to review your consent, simply delete the file "CONSENT", which can be found in the *Simulator Controller\Config* folder, which is located in your user *Documents* folder. And you can also decide inidividually, whether a car setup will be synchronized with any of the connected Team Server databases (see 3. above).
  5. Multiple data connections are now supported for the [Team Server data replication](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) which allows you to use telemetry data, pressures data and so on from multiple differen teams.
  6. Fixed end of race detection for fixed-lap races in rFactor 2.
  7. Race Assistant configurations can be [synchronized](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) by a click of a button.
  8. Optical enhancements for the launch pad of "Simulator Startup".
  9. "Simulator Setup" can be configured to [jump to a specific page on startup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool).
  10. Support for fixed refueling time during pitstops has been added to all applications. See for example the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#pitstop--service) of "Strategy Workbench" for more information.
  12. Fixed installation of Spanish speech recognition library.
  13. Introduced a new log level "Debug" to track down really complex problems.
  14. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Ferrari F40
		- KTM X-Bow R

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-448), especially, if you are using or even hosting a Team Server. The server code has changed and needs a redeploy.

## 4.4.7.0-release 11/11/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. New notes field for driver specific car setups in "Race Center".
  4. Fixed regression of the driver statistics report in "Race Center", which was introduced by the new mean and median calculation.
  5. Full support has been added for multi-class races. The Race Assistants are aware of your specific class and will give you all information like standings, gaps, lap times, and so on, in a class-specific way. Tools like "Race Reports" and "Race Center" are also aware of multi-class races and will show you additional information, if necessary. When looking at reports you can now [filter the results](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#selecting-report-data) according to class.
  6. The "Server Administration" tool now remembers server URL and login name.

## 4.4.6.0-release 11/04/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Fixed a bug for occasional crashes during update installations.
  4. Thanks to Jose Krilin, Spanish is now also supported for voice output and voice recognition of the Race Assistants.
  5. Map and caster meta data has been completed for all cars of *Assetto Corsa Competizione* in "Setup Advisor".
  6. Automated driver selection works in "Race Center" now,  when no stint plan has been created.
  7. Fixed a bug in "Race Reports", when a race number of a car is actually not a number like in '59B'.
  8. Simple tyre compounds now all use the suffix "(Black)" for a better distinguishment from "dry" and "wet" weather conditions, which was necessary for translation support.
  9. Speech synthesizer and recognizer libraries are updated to the latest release of the Azure libraries.
  10. Race reports have been updated to show both the [median and mean values](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) of the lap times of the selected drivers / cars.
  11. A new report has been added to "Race Reports" and "Race Center" which shows the [performance](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#performance-report) of a driver / car lap by lap.

## 4.4.5.0-release 10/28/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. Telemetry and pressures synchronization can now be choosen separately in the "Session Database".
  4. A new monitoring tool gives you an integrated view over the health and activities of all system components. See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) for more information.
  5. Updated the upload / download of the community setup database to a new FTP service provider.
  6. Telemetry data synchronization will pick up at the right point in time after a system failure.
  7. ECU Map and Caster are now supported for *Assetto Corsa Competizione* in "Setup Advisor". Range definitions has been updated for most cars of *Assetto Corsa Competizione*, the rest will follow with the next release.
  8. Windows of Simulator Controller applications are no longer lost offscreen, when a Monitor has been deactivated or disconnect from the PC.
  9. Info and progress overlays can now be positioned on a secondary screen as well, so that they do not interfere with the simulation at all.
  10. New quick start guide for new users at the very beginning of the [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) documentation.
  11. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Ferrari 488 GT3
	    - Ferrari 488 GT3 Evo

## 4.4.0.0-release 10/21/22
  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. The position on the screen where info and progress overlays are displayed, can now be configured in the [UI settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#customizing-controller-notifications).
  4. The session synchronization can be [temporarily disabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#connecting-to-a-session) in the "Race Center", while you are working with the data.
  5. The Team Server now supports synchronization of telemetry data between different members of a team. The documentation for [team management](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams) of the Team server itself, as well as the [database configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) of the "Session Database" has been heavily revised.
  6. A driver may be selected in the "Session Database" when [looking for tyre pressures](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#tyre-pressures). This very helpful when looking for cold tyre pressures for your team mate during a team race.
  7. Refactoring of the translation framework to better support the new Spanish translation.
  8. Thanks to the great work of Jose Krilin, we have an initial version of a Spanish translation. The UI has been translated for the most part and will be polished in the next weeks and you can also expect a working version of the voice generation and recognition soon.
  9. Fixed startup of Race Spotter in situations with a very short rolling or even a standing start.
  10. New car models for "Setup Advisor":
      - Assetto Corsa:
	    - Audi TT RS VLN

Please also take a look at the [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-440), especially, if you are using or even hosting a Team Server. The server code has changed and needs a redeploy.

## 4.3.5.0-release 10/14/22

  1. Minor bugfixes, as always
  2. Documentation updates, as always
  3. UI specific settings, which are managed by the app "Simulator Settings", are now directly available from "Simulator Startup". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller) for more information.
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
  6. New settings in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) allow to configure, whether the Assistants will be active, when a session has been joined after the second lap has been completed. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#racing-with-jona) for more information.
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
  15. A preset has been added to "Simulator Setup" to enable a toggle mode for the *Push-To-Talk* trigger. Please see the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#Push-To-Talk-behaviour) for more information.
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
	 - Information when the current session (Practice or Qualifying) is ending in 30, 15 or 5 minutes.
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
	 - Full support for a weather forecast model. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#weather) for more details.
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
  23. New options in the Tray menu allow you to dump the knowledge base and the rule set of various applications  and the position and gap data for the "Race Spotter" as well as trace grammars and recognitions in the "Voice Server". You also have commands to delete the temporary files and the log files.
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
  18. Fixed many errors in track map creation for *Assetto Corsa*, *Automobilista 2*, *Project CARS 2* and *RaceRoom Racing Experience*. All recorded maps so far will be deleted and re-recorded, since either the scaling factor or the coordinate system has changed. Track Automations must be recreated as well.
  19. Additional tyre meta data has been added for *rFactor 2*, *Automobilista 2* and *RaceRoom Racing Experience*. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds) for more information about tyre meta data.
  20. Action points can now be dragged with the mouse in the Track Automations editor.
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
  4. Introducing Track Automations, which let you automate your car settings like TC and ABS depending on track location.
     - A new page has been added to "Session Database", which allows you to specify [location specific actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#track-&-automation) for a specific simulator / car / track combination.
     - Added the ["TrackAutomation" action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) to the "Race Spotter" plugin which let's you enable or disable location specific actions when you are out on the track.
	 - New ["enableTrackAutomation", "disableTrackAutomations" and "selectTrackAutomation"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#choosing-between-different-track-automations), which let you control the Track Automations while on the track.
     - Added a new icon to the Stream Deck icon set for the "TrackAutomation" action.
	 - Track Automations can be exported and imported using the "Session Database" administration tool.
  5. Track mapping incl. Track Automations are now supported for *iRacing* as well. But since the algorithm to derive the track layout works without a real coordinate system, there are a [few things to mention](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#special-notes-about-track-mapping-in-iracing).
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
  4. The Spotter can now create track maps for most simulators. These maps are then used in "Race Center" to give you a [live view](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#data-analysis) of the current race situation. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-mapping) for more information, how the track mapping actually works.
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
  3. Support driver filters for telemetry in "Strategy Workbench" and "Race Center". You can now select a driver, for which the data in various reports and charts should be displayed. See the updated documentation for ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) and ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#data-analysis) for more information.
  4. The strategy simulation in "Race Center" has been extended to support more edge cases regarding the current traffic situation.
  5. When simulating a strategy in "Strategy Workbench", it is now possible to preselect drivers for the various stints. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#drivers) for more information.
  6. When a stint plan is created from a strategy in "Race Center", the drivers are preselected, if the strategy has been created with driver information.
  7. Optimized Pitstop MFD handling in ACC, almost twice as fast now.
  8. It is now possible to enable/disable the Team Server connection in Simulator Controller tray menu. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#running-a-team-session) for more information.
  9. All new database maintenance page in "Session Database", where you can browse all available data categories. Data can be deleted, exported and imported even from other drivers, with the driver identity preserved for the imported data. See the new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#administration) for more information.
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
  6. Selection of the next driver can now be controlled by the "Race Center" for ACC and RF2. Please see the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#automatically-select-the-next-driver) for more information.
  7. There are now several reports for past pitstops available in "Race Center", where you will get wear information for the used tyres for almost all simulators. You will find more information also in the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#planning-a-pitstop).
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
  7. New "Consistency" Report in "Race Reports" and "Race Center". See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#consistency-report) for more information.
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
  11. New report in "Race Reports" and "Race Center" with lap times for all cars and laps. See the [extended documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#lap-times-report) for more information.

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
  5. Session Database location is now configurable. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) for more information.
  6. The Virtual Race Engineer can be asked about the amount of remaining fuel, like: "How much fuel is remaining?".
  7. The same can be achieved using the new *InformationRequest* action *FuelRemaining*, which is available for all simulator plugins and the "Race Engineer" plugin. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for more information.
  8. Larger window sizes for "Strategy Workbench" and "Race Center" (as requested by the community).
  9. Two new icons for Stream Deck to support the new action *FuelRemaining*.
  10. New preset for "Simulator Setup" to always enable Team Server.
  11. Fixed Spotter not starting in AMS2 after the formation lap.
  12. Base setups can be configured for each participating driver in "Race Center". This information is used to adjust tyre pressures, when the driver changes for the next stint. See the [new documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#managing-driver-specific-tyre-pressures) for more information.
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
  7. Completely new [handling of race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#race-settings) at the start of a session. For the moment, the saving of race settings at the end of a session is disabled. This will be enabled again with the next release.
  8. All new user interface for "Session Database". See the fully [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) for more information.

## 3.9.6-release 03/11/22

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Support for *Intermediate* tyres in all parts of Simulator Controller.
  4. New ["Import from Strategy" command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#rules--settings) in "Strategy Workbench" to initialize all Rules & Settings from a currently loaded strategy.
  5. Support for [Stint time variation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) based on tyre usage dependent lap time degradation in Strategy simulation.
  6. New settings for [disallowed refueling and disallowed tyre change](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#rules--settings) in Strategy simulation.
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
  8. Support for tyre compound color variation in Strategy simulations. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) for more information.
  9. Support to restrict the number of tyre sets available for the different tyre compound in Strategy simulations. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#rules--settings) for more information.

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
  4. Introduced data filtering in "Race Reports" for spurious average lap times, which origin from formation and post race laps.
  5. Strategy Simulation now includes a tyre degradation model based on telemetry data.
  6. Improved control for pitstop service time calculation.
  7. Improved calculation of overtake deltas.
  8. A fixed number of required pitstops can be defined for a strategy simulation, when a required pitstop is chosen in the "Rules & Settings" tab.
  9. Introduction of a traffic model using Monte Carlo alogrithms for taffic density prediction as well as over- and undercut optimization in "Race Center". See the all new [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#monte-carlo-traffic-model) for more information.
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
  4. New [plugin parameter "openTeamCenter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) for the "Team Server" plugin. This parameter is identical to the same parameter already defined for the "Race Strategist" and "Race Engineer" plugins and is therfore not much more than a convenience feature.
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
  8. Added strategy handling and updating to "Race Center". See the updated [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#strategy-handling) for more information.
  9. Optimized Race Assistant behaviour when no voice recognition is enabled - more interaction possible using hardware controller.

## 3.7.6-release 12/17/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Almost fully implemented "Race Center" (formerly "Team Dashboard") for multiplayer endurance races and professional stint races with engineer support by a team mate. See the complete new and extensive [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center) for more information.
  4. New [plugin parameter "openTeamCenter"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for "RaceEngineer" and "Race Strategist" plugins.
  5. New ["openTeamCenter" action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) to trigger opening the "Race Center" from external event sources.
  6. Fixed several critical bugs in "Server Administration".
  7. Added the new BMW M4 GT3 to the list of known ACC cars.

## 3.7.4-release 12/06/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New "Server Administration" application for [Team Server administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration).
  4. New application ["Team Dashboard"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center) supports pitstop settings preparation by a team member in multiplayer endurance races.
  5. [Developer]Added *parseMultiMap* and *printMultiMap* functions.

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
     a. New ["Team MAnagement" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-team-management) in "Simulator Configuration" for managing your Teams, Drivers and Sessions.
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
  8. ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) supports a new command to remove faulty data from the telemetry database.
  9. Only valid laps will be written to the telemetry database and will be used for statistical tyre pressure data.
  10. Support for binary functions for the effect intensity manipulation in the "Motion Feedback" plugin. See the [revised documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#configuration-2) for more information.
  11. [Developer only] Full refactoring of the *ButtonBox* class which is now the [*FunctionController*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-functioncontroller-extends-configurationitem-simulator-controllerahk) in [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk) in order to support the new Stream Deck integration.

## 3.6.5-release 10/22/21

  1. Fixed a critical bug in Strategy Workbench due to incomplete build rules
  
## 3.6.4-release 10/22/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Improved corner case handling and stint optimizations in strategy development.
  4. Variation of fuel consumption, initial fuel level and tyre usage is now possible in strategy simulations. See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#simulation) for more details.
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
  8. Expanded [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) to reflect the new functions of the "Strategy Workbench".

## 3.6.0-release 10/08/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Important fix for handling startup of SimFeedback by the "Motion Feedback" plugin.
  4. Initial strategy simulation based on telemetry data for the "Strategy Workbench". The tool is still in an early stage of development and the functionality might change with future releases. A very rudimentary [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) can be found in the chapter on the Virtual Race Strategist. This documentation will be completed with the upcoming releases.

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
  3. Three new reports for the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool:
     - Overview - as the name says, gives you an overview over the grid (starting positions, best and average lap times and race result.
	 - Car - specific data for your car, weather conditions, mounted tyres, elecronic settins, lap times and pitstops.
	 - Driver - compare the different drivers on the grid regarding potential, race craft, speed, consistency and car control.
  4. Improved "Pace" report including median and quartile calculation.
  5. Various usability improvements for the "Race Reports" tool, incl. better selection of reports based on car and track grouping.
  6. [New "Call" command](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) allows you to actiavte the listen mode of a Race Assistant by the touch of a button on your Button Box.
  7. Improved reliability for voice control of multiple Race Assistants, when *Push-To-Talk* is not used.
  8. Optimized language handling for SAPI voices to support non-Microsoft language packs.

## 3.5.4-release 09/03/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. New ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool. This tool will bring post race analysis to Simulator Controller.
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
  7. The *Push-To-Talk* function now emits a short sound, when the listen mode is activated.

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
  9. [VERY IMPORTANT]: This release introduces an extended *Push-To-Talk*, which will be active, when multiple *dialog partners* are active. Please read the [revised voice commands documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information.

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
  4. Simulator car setup files can be stored together with additional notes in the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#setups) for future use.
  5. The setup database consent has been extended to give [separate consents](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#sharing-data-with-the-community) for tyre pressures and car setup information.
  
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
  7. When the *Race Engineer.settings* file is changed while Jona is already active, the updated settings will be imported into the active session. This is useful during Practice, Qualifying or even Endurance Race sessions.
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
  3. *Push-To-Talk* function for voice recognition - this will reduce false positives almost to zero
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
  3. Graphical user interface for editing the contents of the *Race Engineer.settings* file. It supports loading and saving the settings outside the standard location, thereby allows building a setup database. See the new documentation on the [race settings tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-engineer-settings) for more information
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
