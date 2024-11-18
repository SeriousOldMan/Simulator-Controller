## Introduction

The Race Assistants collect data from your practice and race sessions (qualifying sessions are not supported by default, since they quite often use special setups which will only be in the perfect window during the first few laps) and saves them together with the associated tyre choice and start pressures, air and asphalt temperature and other environmental conditions in a local database. The Assistants also keep track of lap times, tyre wear, brake wear and many other data points from the telemetry information of the car and store these in the database as well. And you can add many other interesting stuff to the database manually, like car setups, strategies, and so on.

Important: "Session Database" displays some graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corresponding key in the registry. If you encounter an error, that the Google library can not be loaded, you must run "Session Database" once using administrator privileges.

Note: The database is stored in the *Simulator Controller\Database* folder, which is located in your users *Documents* folder. Your own data files will be located in the *User* subfolder, whereas the consolidated data will end up in the *Community* subfolder.

*Very Important*: As long as we can't get the actual car setup information from the different simulation games via APIs, you **really** have to follow the guidelines mentioned [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings), so that the Assistants have a correct understanding of your initial car and tyre setup. This is important to get a correct setup for an upcoming pitstop by the Race Engineer, but it is even more important when building the databse, so that you do not end up with compromised data. Depending on your configuration, the Engineer will ask you at the end of the session, if you were happy with your setup and if you want to include the setup information in the database. Please only answer "Yes" here, if you are sure, that the setup information has been transferred correctly to Jona, as described above. Please note, that you still may have had a too low or too high hot tyre pressure during your session, because your initial setup was wrong in the first place. This is no problem, since the Engineer will store the corrected values in the database, as long as your initial setup values are known.

### Using the Solo Center

As mentioned above, the Race Engineer can store information about your tyre pressures (both hot pressures and recommended cold pressures) in the session database depending on your ["Race Engineer" configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer). But you can also collect your data during a practice run or even a solo race in a special application named "Solo Center", which allows you to inspect the data after your session and finally select the data that should be stored into your database. See the [documentation for the "Solo Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center) for more information.

### Managing the Session Database

Whenever you have to setup your car for a given track and specific environmental conditions you can query the session database to get a recommendation on how to setup your car. When you start the application *Session Database.exe* from the *Binaries* folder, the following dialog will open up.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%203.jpg)

This tool gives you access to the database where you have access to the tyre pressures of all your past sessions, where you can store your track specific car setups and where you can provide default values for various settings for the Virtual Race Asssistants. These values can be used to initialize the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) using track and car specific default values. Telemetry information of all past sessions is also stored in the database. Use the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) to browse this data.

You have to use the menus in the upper left area to specify the simulation, car, track, current weather and so on. After you have done that, you can select one of the database topics using the choice tabs.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%204.jpg)

You will get a summary of all available data in the list below the tabs. Please note, that the "Setups", "Stratgies", "Tyre Pressures" and "Automations" will only be available, when you have selected a specific car and a specific track before.

Last, but not least, you can write some notes in the field in the upper right corner, which are also stored specifically for the simulator / car / track combination.

With the dropdown menu above the list of available data you can choose whether only your own setups (=> "User") will be included in the database search or that also the data of other users of Simulator Controller might be considered (=> "User & Community"). Please see the information at the end of this chapter, how to share data with the community.

Important:

  1. If you change the scope using the dropdown menu mentioned above, this will affect only the behaviour and scope during the current run of the "Session Database" tool. If you want to alter the scope permanently, so that it will also influence the retrieved values by other applications such as the Race Assistants, hold the Control key down while choosing a different scope from the dropdown menu.
  2. Simulator Controller knows nothing about the available cars and tracks of any simulator. This info will only get available when you have run a session with a specific car on a specific track. It is not necessary to save any setup information by the Assistants, simply running one lap is enough.

Following you will find an overview about the different database topics:

#### Race Settings

The Virtual Race Assistants provide many settings, as you may have seen in the section about the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) in the documentation about the Race Engineer. Many values are specific for a given car or track, for example the pitstop delta or the time required to change tyres. You can change all these settings manually before each session, or you can store default values for all theses settings in the session database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%205.jpg)

When you enter a session, these default values are loaded depending on a [setting in the configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-engineer) and are used to initialize the race settings used for this session. You can provide setting values for each possible combination of simulator / car / track /  weather, as selected in the upper left area. When the settings are loaded, they will be loaded in the order from the least specific to the most specific, thereby allowing you to inherit settings and *overwrite* them for a more specific configuration.

Let's take a look at a specific example:

The Race Assistants use several values from the race settings to calculate how much time a specific pitstop will need - the time required to refuel the car,  to change the tyres and for entering and leaving the pits. Some values are specific for the given track, some for the car in use and even some might be identical for all cars and tracks. This is how you use the default values for these settings, you simply select the desired scope using the menus in the upper left corner and then enter the required values in the list of settings.

| Settings for *all* cars and *all* tracks | Specific setting for *Hungaroring* |
|------------------------------------------|------------------------------------|
| ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%208.jpg) | ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%209.jpg) |

Below you find the order, in which the different combinations will be loaded. As you can see, setting values for a more concrete combination of car / track / weather will have precedence over those of a less specific combination.

| Car      | Track    | Weather  |
|----------|----------|----------|
| All      | All      | All      |
| Specific | All      | All      |
| All      | Specific | All      |
| All      | All      | Specific |
| Specific | Specific | All      |
| Specific | All      | Specific |
| All      | Specific | Specific |
| Specific | Specific | Specific |

Important note: Some values underly a transformation between internal and external representations. For example, lap times are stored in a millisecond format in many places, **0** for tyre sets means "Auto" and so on. Therefore, when entering a new settings value, take a look at the supplied default value, and understand its meaning. And use the "Test..." button to open the "Race Settings" tool to check the resulting values for the current selected car / track / weather combination, after you have entered or changed any settings. Additionally, you may find entries in the list of available settings for which no corresponding field in the "Race Settings" tool exist. These settings are for internal calculations in most cases, for example the correction factor for temperature based tyre pressure calculations. Be careful, when entering values for these settings, you may get funny results. The default values are generally the best choice here.

The default values for all these settings may not only be used to initialize the race settings for an upcoming session, but they may also be used in the "Strategy Workbench" to provide values for many [settings for strategy simulation & planning](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench#rules--settings).

A detailed overview and description for all available settings and their usage can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings).

##### Exporting and importing settings

You can use the "Export..." button below the settings list to export a set of settings to an external location on your PC, for example, to share them with your team mates. Normally, only the current list of visible settings will be exported, but if you hold down the Control key, all settings from your database will be exported.

When clicking on "Import...", you can select a folder with recently exported settings. A window will open up, which let you choose the settings you want to import into your database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2017.jpg)

#### Track & Automation

This page offers two different editors. The first one allows you to divide the track into different sections, thereby creating a sequence of corners and straights. This information is used by the Driving Coach to understand the track layout.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2020.jpg)

To start a new section, simply click on a position on the track and choose whether the following section is considered a corner or a straight. You can also move section starting points around using the mouse. If you want to delete a section starting point, hold down the control key and click on the corresponding starting point. By the way, the small gray dot marks the start/finish line as recorded by the track mapper.

When defining sections and you want to work with telemetry data or use the on-track coaching of the Driving Coach, it is important to set the section starting point before any section specific driver inputs take place. For example, a corner section should include the complete braking phase and also the initial part of the acceleration phase until the car has settled.

With the second editor you can define automatic actions for specific locations at the track. Since this is a very extensive functionality and observing your car and its position on the track is the duty of the Race Spotter, there is a [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#track-automations) in the documentation of the Virtual Race Spotter, which shows how to setup and use track automations.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2013.jpg)

#### Sessions

All practice and race sessions, which have been stored in the database are shown here. Practice sessions can be recorded and saved using the ["Solo Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center), which can collect data from all solo sessions, therefore also solo races. The name "Solo Center" is therfore somewhat misleading. Race session on the other hand are created by the ["Team Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center), which collects data for a team race on a central server, the [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server). Normally, the sessions run this way are team races with multiple drivers.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2018.jpg)

You can use the buttons below the list to rename or delete a session. You will have to use the "Solo Center" or the "Team Center" to create a session and store it in the database. Once you have selected a session in the list above, you can decide whether you want to synchronize the session with any of the [connected Team Servers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) (see below). Sharing of sessions with the community is not possible, for obvious reasons.

Good to know: Sessions can be opened in the corresponding *Center* by double-clicking them.

#### Laps

Telemetry data for individual laps can be stored in the session database, for example to use them as reference for future comparisons. Note: Lap telemetry data can be recorded in the ["Solo Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center), for example, and can then be stored in the session database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2019.jpg)

You can use the buttons below the list to upload, download, rename or delete lap telemetry data, but in most cases you will use the ["Solo Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center), the ["Team Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center) or the ["Setup Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench) to record the telemetry data and store it in the database. Once you have selected telemetry data in the list above, you can decide whether you want to share it potentially with the community (if you have given consent to share telemetry data - see the information about community data at the end of this chapter) and/or whether you want to synchronize the lap telemetry with any of the [connected Team Servers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) (see below).

##### Naming conventions

Although technically not strictly necessary, it would be benificial that everybody who contributes to the lap telemetry collection will follow the same naming conventions. Therefore, I dare to propose a naming scheme here:

[Nickname] [Laptime] [Date]

with *Laptime* in Seconds and *Date* in YYYYMMDD format. Example: "TBO 104.5 20241101"

##### Telemetry Viewer

If a lap is double clicked, the Telemetry Viewer will open up and let you examine the given telemetry data.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Telemetry%20Browser.JPG)

You can load additional laps from the session database or any other location for comparison using the small button with the "Folder" icon. Please note, that deleting a lap from the Telemetry Viewer using the *delete* button (the one with the "-" icon) will not remove it from its original location. Different rules may apply, when the Telemetry Viewer had been opened from one of the application listed below.

When a reference lap is loaded, it can be shifted horizontally to align it perfectly with the other lap telemetry data. This is especially useful, when comparing laps from different simulators or when data is used, that has been imported from other sources like "Second Monitor", but because of the inherent nature of discrete data sampling there might still be differences which can restrict comparison of data that has been acquired from different sources.

With the controls in the upper right, you can change the zoom factor in both dimensions and you can define and use different layouts for the graph. Click on the small button with the "..." to open a dialog to define and change layouts.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Telemetry%20Browser%20Settings.JPG)

Select the channels you want to display in the telemetry graph and move them up and down as you like. Please note, that not every channel is available for every simulator or for data imported from external sources. Additionally, only telemetry data from the same source may be really comparable.

If available, a map for the current track can be opened with the "Map..." button. You can click on a location of the track map and the corresponding data points will be highlighted in the telemetry graph. It is also possible to click on a data point in the graph and the corresponding location will be selected in the track map.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Telemetry%20Browser%20Track%20Map.jpg)

Also, you can edit the track sections by clicking on the "Edit" button in the right corner of the window. 

Important: This functionality may not be available when using *WebView2* as the HTML viewer.

The Telemetry Viewer is available in the following applications to collect lap telemetry data, where additional documentation is available:

- [Setup Workbench](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#Telemetry-Viewer)
- [Solo Center](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center#Telemetry-Viewer)
- [Team Center](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center#Telemetry-Viewer)

###### Importing telemetry data

If you use the "Open..." button in the dialog, which let's you browse the available telemetry data, you can load telemetry data that has not been stored in the session database.

- You can load telemetry files from Simulator Controller, for example a file that has been sent to you by a team mate.
- You can import telemetery data from ["Second Monitor"](https://gitlab.com/winzarten/SecondMonitor), as long as it has been saved as JSON file, which can be activated in the settings of "Second Monitor".
- And you can import telemetry files from "MoTec". They must be exported as "CSV" files and the "Distance" field must be included. Since "MoTeC" uses the absolute angle for the steering information, it is beneficial to divide this value to the steer lock of the car, to make the information comparable to that of other lap telemetry data. The importer will use the information available in the "Setup Workbench" about the different cars, or you can define the [corresponding setting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#race-settings) in the "Session Database".

Good to know: When importing lap telemetry data directly in the "Laps" tab of "Session Database", the same applies.

###### Special notes for *Assetto Corsa Competizione*

For unknown (and maybe historical) reasons *Assetto Corsa Competizione* supplies two different APIs, one of which comes with a very low refresh rate. The first is the so called shared memory API which provides a complete set of car telemetry data, but unfortunately not the current distance into the track spline. This information is provided in the so called UDP interface, which is network based and uses a low refresh rate. Long story short, collecting position dependent telemetry data for *Assetto Corsa Competizione* is complicated and unprecise to say the least.

To get high precision samples with a resolution of at least 20 Hz, the telemetry collector implements a special method. This method first learns the layout of the track in the same manner as [track mapping for *iRacing*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter#special-notes-about-track-mapping-in-iracing) is implemented, before telemetry data can be correlated to the track position. Therefore be sure to drive clean during the first laps.

A drawback of this method is, that telemetry data can be reliably compared to each other only within one single session. The Telemetry Viewer provides the possibility to shift lap data *horizontally*, but there also may be subtle differences in track position between sessions. Be aware of that when comparing lap telemetry data of different sessions.

#### Strategies

This tab shows you a list of race stratagies, which are stored in the database. Note: Race strategies can be created and stored in the session database using the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench).

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2015.jpg)

You can use the buttons below the list to upload, download, rename or delete a strategy, but in most cases you will use the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench) to create a strategy and store it in the database. Once you have selected a strategy in the list above, you can decide whether you want to share this strategy potentially with the community (if you have given consent to share strategies - see the information about community data at the end of this chapter) and/or whether you want to synchronize the strategy with any of the [connected Team Servers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) (see below).

Good to know: Strategies can be opened in the "Strategy Workbench" by double-clicking them.

##### Naming conventions

Although technically not strictly necessary, it would be benificial that everybody who contributes to the strategy collection will follow the same naming conventions. Therefore, I dare to propose a naming scheme here:

[Nickname] [Format] ( ... )

with *Format* something like "144M", "6H", "30L", and so on, followed by additional information enclosed in paranthesis. Example: "TBO 6H (65M stint timer, 4 tyre sets)"

#### Setups

This tab allows you to store your preferred car setup files for different conditions (Wet vs. Dry) and different Sessions (Qualifying vs. Race) in the session database.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%206.jpg)

Use the drop down menu at the top to select the type of setup, you want to store or retrieve. After you have done that, you can use the buttons below the list to upload, download, rename or delete a setup file. Once you have selected a setup in the list above, you can decide whether you want to share this setup potentially with the community (if you have given consent to share setups - see the information about community data at the end of this chapter) and/or whether you want to synchronize the setup with any of the [connected Team Servers](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#database-configuration) (see below).

##### Naming conventions

Although technically not strictly necessary, it would be benificial that everybody who contributes to the setup collection will follow the same naming conventions. Therefore, I dare to propose a naming scheme here:

	[Nickname] [T Air] [T Track] [Weather] [Track Surface] [Compound]

Example: "TBO 21 27 Drizzle Damp Dry(Soft)" - (TBO is my nickname (for TheBigO), Dry(Soft) is the tyre compound, the rest is self-explanatory)

Why so complex? There is a strong dependency between the track surface state, air and track temperatures and the needed tyre pressures. Following this convention will give any user of the setup enough information how to alter the pressures for different conditions.

Please note, that you can use the "Pencil" button to rename an already uploaded setup file to follow the above conventions, if necessary.

#### Tyre Pressures

Here you will get a recommendation for initial cold tyre pressures, if a matching setup is available in the database. Depending on the temperature settings the recommended tyre pressures will be marked in dark green for a perfect match, or light green or even yellow, if the values have been extra- or interpolated from different air and/or track temperatures.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%207.jpg)

Notes:

  1. If you choose a specific driver in the "Driver" menu, only the tyre pressures of this driver are shown, if available.
  2. If the "Session Database" tool has been [started by the "Race Settings" tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race), you can transfer the current tyre pressure and compound information to the *Race Settings* by pressing the "Load" button.
  3. You can configure using the settings in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#race-settings) the session types, from which tyre pressure data will be collected and stored into the database by the Race Engineer. Default is to collect tyre pressure data during practice and race sessions.

##### Browsing and editing Tyre Pressures

A tool is available to investigate the tyre pressure data collected in the past by the Race Engineer. Using this tool you can also correct invalid data points, if wrong pressures might have been mistakingly recorded. To open this tool, you must select a specific weather condition (i.e. not "All") and you must choose yourself as the current driver. Then you can click on the small button with the "Pencil" beside the driver name and the following window opens:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2016.jpg)

Here you can select one of the tyre compounds, you have used in that specific weather condition, and the temperatures (air / track) for which pressure data is available. In the list in the lower part of the window you will see all recorded data points. Select one of the entries, and you can increase or decrease the count and thereby the weight of this data point, or you can delete it alltogether. The graph in the upper area shows you the data distribution. The narrower the box, the more accurate the cold tyre pressure recommendation.

Please note, that **all** changes will only be saved, if you close the tool using the "Save" button.

#### Administration

Here you can browse all available data in your session database. Data can be deleted by request and you can export data, so that it can be imported by one of your team mates or vice versa. The driver, who originally created the corresponding data will be preserved. Data of multiple drivers can be used, for example, in the strategy development using the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench). When running team races using the ["Team Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center), data of your team mates will be stored in your database at the end of the race as well.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2010.jpg)

You can restrict the scope of the data in the browser using the menus in the topleft corner of the window, thereby making it possible to work with the all the available data of a given simulator or only for a single car on a single track, for example. The window above shows a list of all available cars and tracks for *Assetto Corsa Competizione* with the *Honda NSX Evo* / *Hungaroring* combination selected either for export or even for deletion.

When you export data by clicking on "Export...", you will be prompted to identify the target directory, where a directory containing all the selected data will be created. This export directory will be automatically named "Export_XXYYZZ", where *XXYYZZ* represents the current date and time. You may change the name afterwards, but make sure that you always pass the complete export directory to the target PC, where the data will be imported again.

If you click on "Import..." you will be requested to locate this export directory. When you located a valid export directory, a window opens where you can select all data or only a fraction of the data available in the export package to be imported.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2011.jpg)

Here only the *McLaren 720s* data for the *Mount Panorama* and the *Nürburgring* will be imported, when you click on "Ok".

##### Importing data from other sources

You can import data from foreign sources, for example telemetry information from a real car, in order to use this data in "Strategy Workbench" or in other tools of Simulator Controller, as long as the structure follows the rules:

1. For the moment you have to choose one of the simulators as the home for your imported data. A future release might provide a special place for foreign data.
2. You have to create a folder with the data to be imported.
3. You must create a subfolder for each car and therein a subfolder for each track. The names of the cars and the names of the tracks can be chosen as you like, but it is preferred to not interfere with the names of the chosen simulator, so that the data will not be used in conjunction with already present data.
4. Create a CSV file for each of the telemetry data type you want to import ("Electronics", "Tyres", "Tyres.Pressures", "Tyres.Pressures.Distribution"). Please take a look at a sample export for the naming conventions and the content for these files. But you may omit columns in the CSV files, if the corresponding data is not available (see next point).
5. At the root of the export folder, you must create a "Export.info" file with the meta data. Here is an example:

		[Driver]
		123.456.789=Oliver Juwig (OJU)
		[General]
		Creator=123.456.789
		Origin=123.456.789
		Simulator=Assetto Corsa Competizione
		[Schema]
		Electronics=Weather,Temperature.Air,Temperature.Track,Tyre.Compound,Tyre.Compound.Color,Fuel.Remaining,Fuel.Consumption,Lap.Time,Map,TC,ABS,Driver
		Tyres=Weather,Temperature.Air,Temperature.Track,Tyre.Compound,Tyre.Compound.Color,Fuel.Remaining,Fuel.Consumption,Lap.Time,Tyre.Laps,Tyre.Pressure.Front.Left,Tyre.Pressure.Front.Right,Tyre.Pressure.Rear.Left,Tyre.Pressure.Rear.Right,Tyre.Temperature.Front.Left,Tyre.Temperature.Front.Right,Tyre.Temperature.Rear.Left,Tyre.Temperature.Rear.Right,Tyre.Wear.Front.Left,Tyre.Wear.Front.Right,Tyre.Wear.Rear.Left,Tyre.Wear.Rear.Right,Driver
		Tyres.Pressures=Weather,Temperature.Air,Temperature.Track,Compound,Compound.Color,Tyre.Pressure.Cold.Front.Left,Tyre.Pressure.Cold.Front.Right,Tyre.Pressure.Cold.Rear.Left,Tyre.Pressure.Cold.Rear.Right,Tyre.Pressure.Hot.Front.Left,Tyre.Pressure.Hot.Front.Right,Tyre.Pressure.Hot.Rear.Left,Tyre.Pressure.Hot.Rear.Right,Driver
		Tyres.Pressures.Distribution=Weather,Temperature.Air,Temperature.Track,Compound,Compound.Color,Type,Tyre,Pressure,Count,Driver

Here is what you have to do:

- For each driver, for whom you have data sets available, create a line in the "[Driver]" section. You may choose the driver id randomly, as long as the identifier follows the 3-dot scheme and is unique acroos all your drivers.

- Identify the simulator, where you want the data to be imported in the "[General]" section. You can omit the *Creator* and *Origin* settings.

- Describe the contents of each of your CSV file in the "[Schema]" section. As mentioned above, you can omit fields, for example the *Temperature.Track*, if not available. The values will be set to *Null* during the import, but whether you can work with this data afterwards, is not guaranted. You must provide the *Driver* field, though, otherwise the import will fail.

Then start the "Session Database", select the target simulator and run the import as described [above](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#administration).

#### Database Configuration

Normally, your local database is located in the *Simulator Controller\Database* folder in your user *Documents* folder. You can move the database to another location on your PC, and you also can synchronize most data objects with those of other drivers in your team, as long as all of you are using the [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server). To change the database configuration, click on the small button with the cog wheel in the upper right corner. The following window appears:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2014.jpg)

In the first field, you can define the location of the database on your local PC. Doing this, you can move your own database folder to another location, or you can switch temporarily to another database, for example to look at the data of a friend or team mate. If you change this location and leave the dialog with "Ok", you will be asked, if you want to transfer all your current data to the new location, or if you want to use the new database folder as it is. Please note, that as long as you configured your database to a location of a copy of a *foreign* users database, no data will be collected in order to prevent disorder.

In the lower area of the window, you can configure one or more connections to Team Servers, which allow you to synchronize all kinds of *your* data to a central database and also replicate the same kind of data of all your team mates from the central database to your local database. Very helpful for data analysis, strategy development and stint planning in endurance races.

To enable data synchronization, click on the "+" button to create a new entry and then tick the corresponding check boxes for the desired data categories and enter the login credentials (Server URL and access token), which you will normally get from the team manager (see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams) for more information), which is responsible for this Team Server. Once you have entered the credentials, you can click on the small button with the key to check, whether a valid connection to the synchronization service can be established. If a data connection is no longer needed, you can remove it with "-" button and using the "<" and ">" buttons, you can switch between all currently configured data connections.

You can also set the synchronization interval here. Using higher values will decrease the load on the connected Team Servers, but in general it will be fine to use the default value of 10 minutes here.

If you want to rebuild your local database, for example, after losing all your data due to a harddisk problem, you can click the "Rebuild" button. This will reload all data, which is available to you. Since pushing this button will trigger a complete and very time consuming re-synchronization, use it only in *emergency* situations.

Please note, that the initial synchronization might take quite a while (up to a couple of hours), depending on the amount of data in your local database, but also depending on the amount of data available by your team mates. The synchronization will run in the background without any further user interaction. The background process is automatically started by "Simulator Startup". Once, the initial synchronization is finished, the incremental update of your database will take only a few seconds and happens in the interval mentioned above.

Final note: Once you have changed the database location or the synchronization settings, you will be prompted to restart all applications of Simulator Controller.

##### Data privacy

It is important to understand, that in all cases only data that you created yourself, will be replicated to a central database in a Team Server. This protects the personal rights and copyrights of other drivers. Although you will receive all data from all other team members, this data will never be replicated back to any (other) Team Server. So, if you switch teams, for example, the data replicated from your former team will still be available in your local database, but it will not be synchronized with the central Team Server database of your new team.

### Sharing data with the community

Beside sharing data with your team mates using the Team Server, you can also share some of your data with the data of all other users in the Simulator Controller community, and in return a consolidated database will be made available to all contributors.

No data about your driving performance, for example lap times, etc. will ever be transferred and only data which you explicitely selected for sharing will be contributed. When your data is transferred, no direct or indirect personal data is involved. It is not possible to draw any conclusions about the individual user or the computers from which the data originated. A randomly generated key is used to identify the local database and the data supplied for further processing. Nevertheless and according to good data privacy standards, you must give your consent to share your data with other users of Simulator Controller by answering "Yes" for the different options in the dialog below. This consents are saved in the "CONSENT" file in the "Simulator Controller\Config" directory which is located in your user *Documents* folder. If you want to change your consents in the future, delete this file and this dialog will appear again.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Consent.JPG)

Note: You can give separate consents for sharing your tyre pressure setups, your race strategies and your mechanical and aerodynamic car setups. Since car setups and race strategies might be considered kind of a secret, you must declare, whether you want to share the given strategy or setup individually for each item and you must explicitly upload car setup data to be shared to the session database. On the other hand, tyre pressures will be collected automatically by the Race Engineer, but you will be asked whether to include them in the session database (see below).

If you have given your consents, the data collected in your local sessions will be transferred to a cloud database once a week. You will get a payback in terms of a consolidated database of all contributors and the Race Engineer will use the data to help you in your setup task in the pit, but also during a race, when radical weather changes are upcoming. This community database will be updated on your local PC frequently, so you will always get the latest and greatest setup data. The update process works completely in the background, so nothing to do on your side.