## Introduction

*Team Server* is a server-based solution, which enables you to use the services of the Virtual Race Assistants in a team race, e.g. a 24h race. Without the *Team Server* these services are only available to the driver of the first stint, for all other drivers the Race Assistants do not even start because they do not have the data from the first laps. With the help of *Team Server*, a central server that manages the data of all drivers in a database, this critical knowledge can now be shared between all drivers. The connection to this server is established by the individual applications of teh Simulator Controller suite ("Simulator Controller", "Race Engineer", "Race Strategist", ...) using Web APIs over HTTPS. This ensures the greatest possible interoperability and flexibility when setting up the central server.

In a few days, a managed server will be available for you and your teams to use. To use it, you have to become a patron of Simulator Controller. Please check the [creator page](https://www.patreon.com/simulatorcontroller) on www.patreon.com for more information. But you can also host your own instance of the Team Server, which is described in detail in the section below.

Disclaimer: The current version of the *Team Server* should be considered to be in beta stage. Therefore always double-check the recommendations and actions of your race assistants after picking up the from a different driver. There still might be situations, where the handover of the required data might fail and you might end up with your assistants as dumb as bread, at least what the history of the race concerns. Also, parts of the handling for shared special data like telemetry data or tyre pressure history are still under development. Currently, I would not recommend to use the setup for races longer than six hours, unless your PC has a lot of internal memory to spare.

## Installation & Configuration

The *Team Server* requires you to run a Web API server process, which has been developed using .NET Core 3.1. Applications developed using this multi-plattform server framework from Micorsoft can be hosted on Windows, Linux and even macOS operating systems. You can find the *Team Server* in the *Binaries* folder - please copy this directory to your favorite hosting environment. If you want to set up your own host or if you want to test the *Team Server* on your local PC, you will have to install the .NET Core 3.1 framework. All required resources can be found on this [dedicated website](https://dotnet.microsoft.com/download/dotnet/3.1) from Microsoft.

To start the *Team Server*, you simply start the "Team Server.exe" from the corresponding directory. But before you do that, take a look at the "Settings.json" file, which is located in the same folder.

	{
	  "DBPath": ":memory:",

	  "TokenLifeTime": 10080,

	  "Accounts": [
		{
		  "Name": "admin",
		  "Password": "admin",
		  "Administrator": true
		},
		{
		  "Name": "Test",
		  "Password": "",
		  "Minutes": 120,
		  "Reset": true
		}
	  ]
	}

You first have to decide, where to locate the database, where all stuff will be stored. *Team Server* uses the *SQLite* SQL database ngine, therefor you can provide for the "DBPath" option any valid connect string supported by *SQLite*. The most common connect string file be a file path like "D:\Controller\Database\TeamServer.db", for example. But you can also provide the special connect string ":memory:", which will instantiate the database in the process memory. Please be aware, that everything will be lost, if this process terminates. You can also use the special connect string ":local", which creates a "TeamServer.db" file in the same directory as the "Team Server.exe" executable. If this works, depends on your hosting environment and the quotas assigned to your app by your hosting company.

The next option, "TokenLifeTime", specifies, how long an access token for your team mates will be valid. Access tokens will be described in detail in a later chapter. The life time will be specified in minutes, the 10080 minutes from the example above are exactly 7 days.

Using the "Accounts" option, you can *preload* accounts into an empty database. This cannot be empty, or you won't be able to connect to the *Team Server*. So make sure, that at least one administrator account will be created, since only these accounts will have access to the server administration tools. The number of "Minutes" specifies the amount of time, this account has left for team sessions (necessary for a managed pay-per-use model, which might come in the future). Last, but not least, you can create accounts, that will reset with each restart of the server, for example for test purposes. If you are the only one, who will createa and manage teams, this is it, otherwise hand over the corresponding account name and password to your mates.

Last, but not least, you have to communicate the web URI to all team managers and drivers, which will use the *Team Server*. An URI for your local PC will look like "https://localhost:5001", one for an Azure might look like "https://teamserver.thebigo.azurewebsites.com". This depends on your chosen host environment.

If you want to setup and operate a server, which is not only used by your direct team members, but also by other teams and drivers, for example a server for a community or a league, you can do this as well. Please consult the special section on [server administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) down below to learn more about the concept of accounts, contingent renewal and administrative tasks.

## Managing teams

You manage your teams using the "Simulator Configuration" application. You will find everything you need on the "Team Server" tab on the far right of the tab header.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2010.JPG)

In the first field, you select a folder, where dynamic session data will be stored, when you and your team mates will use the "Race Center" during the session. If you don't supply a special directory here, the data will be stored in the temporary folder in the *Simulator Controller\Temp* folder, which is located in your user *Documents* folder and might therefore be lost at the end of the session. Please see the documentation for "Race Center" down below for more information on data handling.

Then you have to enter the URI, where the *Team Server* can be reached (see above). Then you have to provide the account credentials (name and password) in the second line. If everything is correct, you will get an access token, if you click on the small button with the key (otherwise you will see an error dialog, which describes the problem). This access token will always be freshly created and is therefore valid for the period stated in the "Settings.json" file as described in the [installation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#installation--configuration) chapter. You can copy both the Server URI and the token to the clipboard using the small buttons on the right side and you can change your password by clicking on the small pencil beside the password field.

You can now hand the access token to your team mates, but before you do this, you have to create a team for them. You can create as many teams as you whish, each of which can have as many drivers as necessary. The most important part is the naming of the drivers, as these names are used to identify the driver during the race. It is absolutely important that you enter the names (First name, last name and nick name) exactly as they will appear in the simulation. The names will appear in the format *firstName* *lastName* (*nickName*), where the paranthesis are not part of the nick name. In the last list, you enter the sessions or events you want to participate in with your team, for example "24h of Bathurst". Please note, that all changes you made to your teams, drivers and sessions on the "Team" tab will be saved permanently, independent whether you leave the "Race Settings" dialog using the "Ok" or the "Cancel" button.

Note: Sessions can be *used* many times. If you start a session, which has been used before, all data from the previous usage will be deleted automatically. On the other hand you want to have meaningful names for your sessions, so feel free to delete old sessions and create new ones as necessary.

That's it for team administration.

## Preparing a team session

First of all, it is absolutely important to note that a team session can only function properly if all members of the team are using simulator controllers and have configured the same virtual racing assistants (either Jona or Cato or both). In order to participate in a team meeting, each member must prepare the settings for this upcoming team meeting. This is done using the "Race Settings" application.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%204.JPG)

Select the tab named "Team", and enter the server URI as well as the access token, which has been provided by the team manager as described above in the chapter about [team administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams). Please note, that the tab "Team" is not available in the "Setup Database", since the settings that are stored there will be independent of a given team.

Once you have entered the server credentials, you can click on the small button with the key and the available teams, drivers and sessions associated with the access token will be loaded. Select the team, your driver and the session, and you are done - almost.

## Running a team session

When you head out onto the track, you must decide, whether you want this session a team session or not. This decision must be made, before the first stint driver of the session has completed the first lap. More on that down below. It is also absolutely necessary that all drivers are connnected to the simulation during the first lap and also for the rest of the session. Otherwise, Simulator Controller detects, that the simulation has terminated also closes the connection to the *Team Server*. The team session will be initialized and started on the *Team Server* in the moment, the driver of the first stint has completed the first lap. It will be finished and closed, when the current driver in the simulation crosses the finish line or terminates the simulation.

And now the important stuff: To declare, that you want to join a team session, you must use the corresponding [action from the "Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server). For convinience, it is also possible, to always enable team sessions using the action declaration of this plugin, but I don't recommend that, since you might end up being part of a session, you are not planned for.

### Race Center

During a team session, all team members can use the "Race Center" application, even if they are not an active driver of the session and are not running the simulation. This tool gives you complete insights into the telemetry and standings data for the current race session. It also allows you to interact with the Virtual Race Assistants, even when you are not the currently active driver. By this functionality, each team member or a dedicated race engineer can, for example, prepare the perfect settings for an upcoming pitstop based on the myriads of data suppplied by the "Race Center". Before we dig into the details, take a look at the various screens of the "Race Center":

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%201.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%202.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%203.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%204.JPG)

Please note, that all the data and graphs shown in the window will be updated dynamically as the race progresses. Most updates will be done each lap, but some minor details will be updated more frequently.

#### Connecting to a Session

To use the "Race Center", you must have a valid connection to a team session. This is normally handled by entering the corresponding server URL and access token into the ["Race Settings" application](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#preparing-a-team-session), but you can even connect to a team session without being aan active driver in the session by entering the access token supplied by your team manager directly into the field at the top of the "Race Center" window. Then either click on the small button with the key on the left of the token field or choose "Connect" from the "Data" menu.

If you have connected to a session that has already been used in a previous race and there is still data stored in the session, it might take a while, before all data have been loaded. The window controls will be blocked during this time and you will see a small mark rotating on the right side of the window to show you that data is being requested from the server.

It is no problem, to reuse a session for many races, because the old data will be automatically cleared, when the new race is started. But you can also use the command "Clear" from the "Data" menu beforehand to erase all current data, if you whish. Please note, that it is **not** a good idea to use the same session in more than one race at the same time.

#### Session data handling

All data of an active session is stored on the Team Server. It is therefore possible to start the "Race Center" anytime, even late into the race. The data will be kept for a finished session on Team Server as well, depending on the settings chosen by the server administrator. See the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) form more information. To secure the session data on your local PC, you can use the "Save" and "Save a copy..." commands from the "Data" menu at the end of the session and you can load a recent session anytime later using the "Load..." command.

#### Data Analysis

"Race Center" supplies you with a couple of reports, which you can use to analyse the performance of your team drivers, compare them to your oponnents and dig deeper into the telemetry data of the car. Choose one of the reports in the reports list and this report will be shown in the report area on the top right of "Race Center" window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%205.JPG)

The reports at the top of the list are the well known report, wich are also available after a session using the ["Race Reports" tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports). They are mostly usefull to analyze the standings and the performance of the various drivers and cars. The other reports will give you an insight into the telemetry data. You can select the data to be shown using the selector menus on the right of the report list. You can also choose the type of visualization using the "Plot" menu on top of the report area. Last but not least, using the small button with the gear icon, you can choose various settings for the currently selected report, for example the range of laps to be considered in the data or the set of drivers in reports which are driver specific.

Beside that, you can request several context specific data, which will be shown in the "Output" area in the lower right of the "Race Center" window.

  1. Details of the current stint
  
     This will give you detailed data for all the laps in a stint as well as performance figures for the driver. Please select a stint in the list of stints to generate this report.

  2. Driver Statistics
  
     You can generate a special report for all active drivers with detailed information about their stints as well as their individual performance figures (potential, race craft, pace, consistency and car control). Choose the "Driver Statistics" command from the "Data" menu to generate this report.
	 
  3. Race Summary
  
     This report is usefull by the end of a race to create a document to be stored away in the archive. It contains data on all stints and drivers. This report is also available in the "Data" menu.
	 
All these report documents are HTML-based and can be saved or printed using the context menu when right-clicking into the output area.

#### Strategy Handling

Not yet implememted...

If you are running a race based on a predefined strategy developed using the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development), you can alter this strategy, when necessary cause of important race events, for example an accident.

#### Planning a Pitstop

Using the elements on the "Pitstops" tab, any team member can prepare the next pitstop for the current driver. This is a valid alternative instead of using the services of Jona, the Virtual Race Engineer, in an endurance race, where currently passive team members or even a dedicated race engineer are part of the crew supporting the active driver.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%206.JPG)

Especially before selecting the tyre pressures, you might want to analyze the data as described above. But you may also use the "Initialize from Session" command from the "Pitstop" menu, which will use the values, that are currently recommended by Jona, the Virtual Race Engineer. In situations, where the conditions change dramatically, for example an upcoming thunderstorm, you can also load the data from the ["Setup Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database) using the "Load from Setup Database..." command, when you think that you might have setup information there from previous sessions in comparable conditions.

Once, you have dialed all settings, choose "Instruct Engineer" from the "Pitstop" menu and the entered values will be transferred to the Race Engineer of the active driver. The driver will be informed by Jona about the planned pitstop, but no interaction is necessary. The settings will be automatically entered into the Pitstop MFD, once the car crosses the start/finish line of the lap for which the pitstop has been planned, and the driver is called to the pit.

### Special notes

Every simulation game is unique and handles multiplayer team races different. Therefore, you have to be aware of the individual drawbacks and specialities. In this section I will provide a growing collection of hints and special operation tipps for all the individual simulations, whenever I stumble over them. When you found some specialities on your own, please feel free to share them with me, and I will be happy to add them to this section as well.

#### Assetto Corsa Competizione

  1. *Assetto Corsa Competizione* looses the knowledge about the currently selected repair options in the Pitstop MFD after a driver swap. The internal selection state of the ["ACC" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) will therefore be reset to *both selected*, to have some sort of initial state. This means, that you have to open the Pitstop MFD and select both repair options, once you've picked up the car. And you must do this **without** the help and control of the ["Pitstop" mode}(https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) of the "ACC" plugin. So do not use your Button Box here. The other possibility is to leave them as they are, but double check later, after Jona has dialed the pitstop options.
  
## Server Administration

This section is only relevant for those of you, who want to setup and manage their own servers. After you have installed and setup the Team Server in your hosting environment as described above in the first section, you can use the "Server Administration" application to create the different accounts for all team managers, that will run team sessions on this server.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%201.JPG)

In the top section of "Server Administration" you have to enter the login credentials of one of the administration accounts you have setup during the initial configuration of the Team Server. You have thought of that, right? If not, back to start. After you have successfully logged into the Team Server, you can create, delete or change accounts, which will have access to the server. An account is identified of a name, which must be unique, an optional E-Mail address, as well as contingent rule for the minutes which are available for race sessions on this account. You also have to create an initial password, which you must hand over together with the account name to the (team) manager of this account. You can create a password by clicking on the small key button and you can copy the password to the clipboard using the small button on the right.

Very important are the settings for the time contingent. You can choose between "One-Time" contingents, which renders the account useless after the contingent has been used up, or you can choose to variants of renewable time contingents. The number of minutes entered on the right will be available directly after the account has been saved and they might be automatically renewed according to the contingent rule. More on that later. Last, but not least, you can manually set the number of currently available minutes using the small button with the clock.

If you don't want to use all this stuff, simply set the number of minutes to an astronomical high number and the contingent rule to "One-Time". You will end up with an account, that will last forever.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%202.JPG)

On the second page, you start a couple of background jobs on the server, which will keep everything tight and clean. You can delete periodically expired access tokens, you can define when to renew the time contingents on all accounts, and you can manage finished sessions, which might occupy a lot of disk space on the server. "Cleanup" means that all secondary data (telemetry, standings, etc.) will be deleted, but the stints and laps will survive whereas a "Reset" also deletes all stints with their laps, which just retains the name of the session. But you might also let the server fully delete finished sessions. Whatever you define here, finished session will always be retained for one hour after the end of the session, so that all drivers have enough time to download the session data from the server.

## How it works

When you start a team session as described above, Jona and Cato will act and behave as in a single driver session, though you might notice subtle differences. For example, a new driver will be greated by the assistants after a driver swap or a returning driver will get a warm welcome. But the important differences are all below the waterline.

  1. Handover of the Knowledgebase
  
	 Jona and Cato both have a working memory, which stores the current state and is used to derive the recommendations and to control the actions of the assistants. This data is held locally in memory in the "Race Engineer" and "Race Strategist" processes of the current driver. During a pitstop, copies of the complete working memory of the Race Assistants of the current driver are transferred to the *Team Server* and stored there in a database. After the next driver has picked up the car, this copies are requested from the central server and are used to initialize the working memory of the Race Assistants of this driver. This happens completely in the background.

  2. Handover of Race Settings
  
	 The next driver after a pitstop will also receive the current race settings of the previous driver, as defined by the "Race Settings" application. Especially important are those settings that influence the pitstop planning, the calculations for cold tyre pressures and the rules for the valuation of potential repairs. It is therefore important that all drivers of a team race decide together, which options they will choose for their race.

  3. Storing of Race Standings, Telemetry and Tyre Pressure Information

     Jona and Cato collect a lot of data during your races, for example race standings, lap times and other statistical data from all your opponents for after race analysis or telemetry data for setup and strategy development. For a single or double stint event with a single driver, all this data is kept in-memory. This is almost impossible for 24h race due to memory restrictions and completely impossible for multiplayer team races. Therefore, this data will also be stored centrally in the *Team Server* and will be reloaded at the end of the session for further processing.

## Troubleshooting

A lot can happen when talking to services on the internet. The system tries to be as robust as possible. For example, when the connection to the *Team Server* is lost, the Race Assistants will continue to run in local mode. There will be no error messages on the screen in this situation in order to not interfere with your current stint. You can consult the log files in the *Simulator Controller\Logs* folder which is located in your user *Documents* folder afterwards. In most cases it will be a problem with the connection to the *Team Server*, but a full database (depending on your hosting environment quotas) might also be a root cause. Here are some tipps:

  1. Always check the connection to the *Team Server* using the "Race Settings" application just before the race.
  
  2. Do not use "cheap" or free hosting. Especially the free account on Azure or AWS do not have any SLAs regarding service availibility and service quality.
  
  3. When running on a managed pay-per-use *Team Server*, be sure to check the number of available minutes before the session. It would be bad, if your contingent deplates during your best session ever.
  
  4. Always delete your sessions after the end of the race. This will free up all the used memory on the server.