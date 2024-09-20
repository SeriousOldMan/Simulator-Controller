## Introduction

The "Solo Center" is an application, which you can run alongside your practice sessions or even while running a solo race. When the Race Assistants detect that the "Solo Center" is running, they transfer all collected data to this application and do not store the data in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool at the end of the session. Instead you can use the "Solo Center" after your session to investigate the data and select the data that should be stored permanently in the session database, if any at all. You can also use the "Solo Center" to plan your practice session, review the car telemetry data and compare your performance to other drivers participating in the same session. In this sense, "Team Center" is a kind of pitwall application.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center.JPG)

The "Solo Center" looks very similar to the ["Team Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center), a tool typically used to manage team endurance races. Both tools share common concepts, reports and data views by intention, but there are also many differences, of course.

### Starting a session

Simply start the "Solo Center" **before** starting the session in your simulator. The Race Assistants will automatically connect to the "Solo Center" after the first lap and initiate a session there as well. Once data has been collected in the "Solo Center", it will **not** connect to a new session, before this data has been exported. However, you can use the "Clear..." command from the "Session" menu and you are ready to go for a new session, if you don't want to retain your collected data.

When you start a new session or when you close the window, the "Solo Center" will ask you before any unsaved / unexported data will be overwritten. You can, however, enable "Auto Export", "Auto Save" or even "Auto Clear" in the "Session" menu according to your preferences. "Auto Export" will, as the name suggests, export the telemetry data from valid laps to the session database and "Auto Save" will save the complete session state to the session database. This sessin state can be retrieved later using the "Load session..." command from the "Session" menu.

Do **not** start the "Solo Center" after you have already started your session in the simulator. Although nothing will explode, you will loose your valuable practice data, since it will be send to the "Solo Center", which most likely will not collect it. Also, do not quit the "Solo Center" **before** quiting the session in your simulator. You will also end up with an inconsistent data constellation. Nothing really harmful, since in the end all data is treated with statistical weights and averages, but if possible, do avoid it.

Note: If you are [running a team session](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#running-a-team-session), the "Solo Center" cannot be used (it will simply ignore the running session), since all data duties are handled by the Team Server in this case. But you may want to use the "Team Center" to control your race in this case anyway.

Good to know: The "Solo Center" benefits from a high data update frequency of the Race Assistants. Therefore, if your PC is powerful enough, you can lower this value in the settings of the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database):

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%207.JPG)

The default value for the data update frequency is 10 seconds, but you can can try to go as low as 2 seconds, if your PC is powerful enough.

### Saving and loading sessions

The "Solo Center" allows you to save the complete session data for later inspection by using the "Save Session..." command from the "Session" menu. You can use the "Load Session..." command to retrieve such a session later on and all information will be restored. Saving a session this way does **not** export the telemetry data to the session database, which is a completely different thing and must be triggered seperately. However, the full session information can also be stored in the session database, if needed, to have all information in a central location.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%2011.JPG)

IMPORTANT: The data format of saved sessions has changed over time. To load a session in the *old* format (before they have been saved to the session database by default), hold down the Control key, once the session browser is open. You will see that the "Load..." button changes to an "Import..." button.

The "Auto Save" setting in the "Session" mennu allows you to automatically save a session before the window of the "Solo Center" is closed or before a new session will be started. However, doing this will collect a great amount of probably unnecessary data in your session database, therefore choose wisely.

### Data Analysis

"Solo Center" supplies you with a couple of reports, which you can use to analyse your performance and dig deeper into the telemetry data of the car. Choose one of the reports in the reports list and this report will be shown in the report area on the top right of "Solo Center" window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%201.JPG)

The reports at the top of the list are the well known reports, which are also available after a session using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool. They are mostly useful to analyze the standings and the performance of the various drivers and cars. The other reports will give you an insight into the telemetry data. You can select the data to be shown using the selector menus on the right of the report list. You can also choose the type of visualization using the "Plot" menu on top of the report area. Use the "Stint" menu to restrict the visualized data to a specific stint or use the "Driver" menu to restrict the data of the various charts to one the drivers who has already driven some laps in the session (normally only you). Only data of the selected driver will be shown then.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%202.JPG)

A special case is the "Running" report, which gives you access to many telemetry values for the previous and the currently running lap. The X-Axis stands for the track length here withe the 0 value beeing the start/finish line and the values are updated, when you reach the given point on the track (depending on the general data update frequency - see below). Please be aware that not all values may be provided by a given simulator.

Note: The values for wear (tyres and brake pads) range from 0% up to 100%. For most of the simulators these values are directly available through the API, whereas in *Assetto Corsa Competizione*, the data interface provide the remaining thickness of each pad. Depending on the compound of the pad, the wear level for 100% ranges from 12 mm to 15.5 mm left pad thickness here, with a starting thickness for a fresh pad with 29 mm.

Last but not least, using the small button with the cog wheel icon, you can choose various settings for the currently selected report, for example the range of laps to be considered in the data or the set of drivers in reports which are driver specific.

  1. Details of a selected stint
  
     This will give you an overview for the stint, the driven laps, as well as some performance figures for the driver. Please select a stint in the list of stints to generate this report.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%203.JPG)
	 
	 While you are in an active session, you can also take notes for a selected stint, for example to remember setup changes, special weather conditions or other stuff worth to mention.

  2. Details for a given lap
  
     When you select a lap in the *Laps* tab, you will get a detailed table of the standings and (depending on the type of the session) the gaps to the cars in front of and behind the drivers car, as well as to the leader.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%204.JPG)
	 
	 If the current race is a multi-class race, the report will also show the class specific positions of all cars, additionally to their overall position in the race. In a multi-class race, the gaps shown in the gap table at the top of the report will always be specific for the own class. Additionaly, if driver categories are available, the category label of a given driver will be added to his name.
	 
	 Last, but not least, you will find informations about the past pitstops of each car (only in a race session). The overall number of pitstops, as well as the lap (in reference to your own laps) of the last stop are shown. Please keep in mind, that due to restrictions in the data provided by the various simulators, it cannot be differentiated in many cases whether a car has been in the pits for a penalty, a regular pitstop or even an unplanned stop due to repairs. It is also possible, that the number of pitstops are not correct at all, since not all stops may be correctly reported by the simulator.
	 
	 If you are in a practice session, the standings table will list all drivers, which has also been present at the start of your session, and the list will be sorted according to the best lap times of all drivers.
	 
	 Some basic data is shown in the header of the lap details as well. Important are here the ambient temperatures and the tyre pressure information. You can see the current hot pressures, recommend cold pressures and information about tyre pressure losses, if there are any.
	 
  3. Session Summary
  
     This report is useful by the end of a session to create a document to be stored away in the archive. It contains data on all stints. This report can be created using the "Session Summary" command from the "Session" menu.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%205.JPG)

  4. Data Summary
  
     Data Summary is another useful report, which gives you a complete documentation of all data collected in your session or already stored in your database (depending on your choice in the "Data" menu.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%209.JPG)
	 
	 You can create this report by chooosing "Data Summary" from the "Data" menu.

  5. Stints Summary
  
     This report combines the output of the stint report (see above) for all stints into one document.
	 
All these report documents are HTML-based and can be saved or printed using the context menu when right-clicking on a free space in the output area.

##### Notes

- The report shown in the output area will be updated live, whenever new data arrives. A special case is the report for the lap details. If the chosen report is for the last lap, the report will automatically switch to the next lap, when this lap has been finished.

- If you want the report to be opened in a separate window, hold down the Control key while requesting it. If the report originates from one of the available lists, you can open the separate window by double-clicking the entry in this list. In this case, the report is frozen and will **not** be updated automatically when new data arrives.

### Telemetry Browser

A valuable tool to improve your lap times is the integrated Telemetry Browser, which can be opened and activated by choosing the "Telemetry..." command from the "Session" menu.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Telemetry%20Browser.JPG)

While you are in an active session and the Telemetry Browser is open, car telemtry data will be collected lap by lap in the background and stored in the session. You can use the browser to load the telemetry for a given lap and you can choose a reference lap for comparison.

When looking for areas of improvement take a close look to your application of throttle and brakes and the activation of TC and ABS. Trailing off the brakes and the transition back to full throttle is the most important skill to master for fast lap times. This does not mean, that sometimes coasting around a corner is not necessary. Use the Telemetry Browser to compare your laps with the fastest lap of a given session and learn what exactly made you faster there.

Important: Session that are saved with telemetry data will NOT be synchronized with the Team Server by default, since the amount of data is quite large and will put a lot of stress on the Team Server. You can still activate the synchronization for a particular session in the "Session Database", but I strongly recommend to not do it.

##### Notes

1. It can take a few laps before the first telemetry data gets recorded.
2. A special method is used for *Assetto Corsa Competizione*, which unfortunately does not supply the distance of the car into the track in the shared memory API (it is available in the UDP interface, though, but this interface does not provide telemetry data). Because of that, the track layout must be learned, before telemetry data can be correlated to the track position. Be sure to drive clean during the first laps.
3. The telemetry recorder is only running, while the Telemetry Browsr is open. Therefore, you can restart the learning process for *Assetto Corsa Competizione*, if necessary, by closing the browser and re-open it.
4. The currently selected lap can be deleted by using the "-" button to the right of the drop down menu of all laps. If you hold down the Control key, all laps can be deleted at once.
5. You can save and load telemetry data for a given lap for later usage:
   - Typically used for reference laps, even from other drivers.
   - Use the small button with the "Disc" icon to save a telemetry lap to the session database or any other location.
   - Use the small button with the "Folder" icon to load a telemetry lap from the session database or any other location.
   - Telemetry data, which has been *imported* this way will not become part of the current session.
   *Imported* telemetry data can be removed by using the *delete* button. This will not remove it from its original location.

### Managing tyres and planning practice stints

The first tab "Tyres" in the lower left corner allows you to manage your tyre sets during your practice runs. In many cases, you can let the "Solo Center" decide automatically, when to create a new stint and when a tyre change happened (at least for *Assetto Corsa Competizione*, *rFactor 2* and *Le Mans Ultimate*). But not all simulators provide access to the mounted tyres in their data API, so it is also possible to create a new stint with your individual tyre setup manually.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%206.JPG)

To create a new stint manually while you are standing in the pit, follow these steps:

1. Select "Manual" from the "Mode" drop down menu.
2. Select whether you want to change tyres and possibly a specific tyre compound using the "Compound" drop down menu. You can also use the small button beside the drop down menu to query the simulator for the currently mounted tyre compound and tyre set, if this data is provided.
3. Select the number of the mounted tyre set. This is important, so that the "Solo Center" can manage the number of laps driven with this specific tyre set.
4. Enter the cold pressures, you have chosen for the new tyres. This is particular important, otherwise the cold pressures derived by the Race Engineer will be wrong.
5. Finally click on the button "New Stint" or choose the corresponding command from the "Stints" menu.

It is recommended to use the "Auto" mode in races, since then the pitstops are reliable detected by the Race Assistants (and the additional data like tyre set and tyre pressures will be taken from the pitstop plan), whereas in Practice sessions, it will be much better to create the different practice stints manually. Esspecially the ideal cold tyre pressures derived by the Race Engineer will be mostly wrong, when the tyre change has not been planned and prepared under the control of the Race Engineer, which is uncommon in a practice session.

#### Using the Run Sheet

The "Solo Center" can give you hints for worthy practice runs, which will create data for specific car configurations, for which currently no data is available in the database. This is somewhat the inverse approach as taken by the data explorer described in the next section, since the "Run Sheet" will show you data, that is *missing*

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%2010.JPG)

You can open the "Run Sheet" by choosing the corresponding command in the "Data" menu and the window can stay open, while you are working in other areas of the "Solo Center". The data shown, will always reflect your current selection of car and track and the chosen data setting in the "Data" menu.

In the upper list, you will see entries for missing data which relate your lap times to the combination of chosen engine map (if available in your simulator) and the amount of fuel currently in the tank (thereby determining the car weight and balance). The lower list show missing data correlations between fuel level (car weight) and the number of laps you have already driven with a given tyre set.

When you now select an entry in one of these lists, instructions will be given how to create the missing data points, thereby defining the conditions for a worthy practice run.

Please note, that not all data points may be of interest. Decide for yourself, if you will ever encounter a situation, where you will run a car with a full tank, but worn tyres, for example. If you are participating mostly in sprint races, this will be very unlikely. If you are running high class endurance races, on the other hand, it can happen that you must double stint a tyre set due to tyre set restrictions imposed by the race rules. You see, it depends...

### Exploring data

The "Data" tab will give you an overview of what data you have collected during your session, or, after you have selected the corrsponding option in the "Data" menu, what data is available in your session database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Practice%20Center%208.JPG)

Using the "Data" menu, you can choose between the different weather conditions and available tyre compounds, thereby identifying possible gaps in your data collection that need to be filled with a specific practice run.

The choices (except tyre compounds) will be remembered between different runs of "Solo Center".

### Exporting data to the session database

At the end of your session, you can decide which data should be transfered to the session database by clicking the small check marks for each lap in the list of driven laps. "Solo Center" will already have selected by default all valid laps for your convenience. Then choose the command "Export to Database" from the "Session" menu.

Please note, that this export is possible only once, to prevent duplicate data entries in your database, and cannot be undone. Therefore check your selection carefully beforehand.

You can also store your session for later inspection in any location on your PC using the "Save Session..." command from the "Session" menu. The mentioned data export can also be initiated from a saved copy - very helpful, if you are exhausted after your session and want to defer the data inspection for later.