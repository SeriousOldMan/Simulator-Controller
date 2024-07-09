## Introduction

*Team Server* is a server-based solution, which enables you to use the services of the Virtual Race Assistants in a team race, e.g. a 24h race. Without the *Team Server* these services are only available to the driver of the first stint, for all other drivers the Race Assistants do not even start because they do not have the data from the first laps. With the help of *Team Server*, a central server that manages the data of all drivers in a database, this critical knowledge can now be shared between all drivers. The connection to this server is established by the individual applications of the Simulator Controller suite ("Simulator Controller", "Race Engineer", "Race Strategist", ...) using Web APIs over HTTPS. This ensures the greatest possible interoperability and flexibility when setting up the central server.

Beside providing the basis for team races, the Team Server can also be used as a central data hub for all telemetry data collected by any team member. This data can be replicated to your local telemetry database to be used during strategy development or any other data related tasks.

A public test server can be used for a test ride with with the Tean Server and ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center), to see what it can do for you and your team. See the [description](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#test-session) below for more information on how to connect to the server and load a test session.

To give you a quick start with the Team Server, a managed server is available for you and your teams to use. To get access, you have to become a patron of Simulator Controller. Please check the [home page](https://www.patreon.com/simulatorcontroller) on www.patreon.com for more information. But you can also host your own instance of the Team Server, which is described in detail in the section below.

Disclaimer: Although the current version of the *Team Server* is no longer to be considered Beta, please always double-check the recommendations and actions of your Race Assistants after picking up the car from a different driver. There still might be situations, where the handover of the required data fails and you might end up with your Assistants as dumb as bread, at least what the recent history of the race concerns. For obvious reasons, there will be no error messages during the race, when for example the connection to the central server has been temporarily lost or another internal error occured, but you will face substantial misbehaviour in those cases. You may take a look into the log files afterwards, though, and it is always a good idea to take a look at the ["System Monitor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities).

## Installation & Configuration

The *Team Server* requires you to run a Web API server process, which has been developed using .NET 6.0. Applications developed using this multi-plattform server framework from Micorsoft can be hosted on Windows, Linux and even macOS operating systems. You can find the *Team Server* in the *Binaries* folder - please copy this directory to your favorite hosting environment or to a location outside the Windows program folders for a local test environment. If you want to set up your own host or if you want to test the *Team Server* on your local PC, you probably will have to install the .NET 6.0 Core framework runtime (Hosting Bundle) - depending on your installed Windows version. All required resources can be found on this [dedicated website](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) from Microsoft.

After you have installed .NET Core 6.0 and the Team Server, you have to configure the URL, where the server listens. Default is "https://localhost:5001" or "http://localhost:5000". But, when you want to setup a server which is available on the network, you have to setup a different URL. Information about this can be found in this [short article](https://andrewlock.net/5-ways-to-set-the-urls-for-an-aspnetcore-app/). The easiest way will be to supply the URL using a command line argument, for example:

	"Team Server.exe" --urls "http://yourip:5100;https://yourip:5101"

with *yourip* substituted with the IP, where your server should be available. And you have to make sure that this IP is visible to the public, of course.

Then you can start the *Team Server* by running "Team Server.exe" (with the required options) from the corresponding directory. But before you do that, take a look at the "Settings.json" file, which is located in the same folder.

	{
	  "DBPath": ":memory:",

	  "TokenLifeTime": 10080,

	  "ConnectionLifeTime": 300,

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
		  "Session": true,
		  "Data": true,
		  "Reset": true
		}
	  ]
	}

You first have to decide, where to locate the database, where all stuff will be stored. *Team Server* uses the *SQLite* SQL database ngine, therefor you can provide for the "DBPath" option any valid connect string supported by *SQLite*. The most common connect string file be a file path like "D:\Controller\Database\TeamServer.db", for example. But you can also provide the special connect string ":memory:", which will instantiate the database in the process memory. Please be aware, that everything will be lost, if this process terminates. You can also use the special connect string ":local:", which creates a "TeamServer.db" file in the same directory as the "Team Server.exe" executable. If this works, depends on your hosting environment and the quotas assigned to your app by your hosting company.

The next option, "TokenLifeTime", specifies, how long a session token for your team mates will be valid. Session tokens will be described in detail in a later chapter. The life time will be specified in minutes, the 10080 minutes from the example above are exactly 7 days. With "ConnectionLifeTime" you specifiy also in seconds how long a connection to the Team Server is to be considered active. This is only for administrtaive purposes, since a client of the Team Server does not need a connection to perform a request, only a valid token. But connections are used in the "Server Administration" tool as well as in the "Race Center" to display, who has been active on the Team Server recently.

Using the "Accounts" option, you can *preload* accounts into an empty database. This cannot be empty, or you won't be able to connect to the *Team Server*. So make sure, that at least one administrator account will be created, since only these accounts will have access to the server administration tools. The number of "Minutes" specifies the amount of time, this account has left for team sessions (necessary for the managed pay-per-use model). Using the attributes "Session" (default: *true*) and "Data" (default: *false*) you can specify whether users from this account may access team sessions and / or use the data synchronization. Last, but not least, you can create accounts, that will reset with each restart of the server, for example for test purposes, by using the "Reset" attribute. Default here is *false*. If you are the only one, who will create and manage teams, this is it, otherwise hand over the corresponding account name and password to your mates.

Last, but not least, you have to communicate the web URL to all team managers and drivers, which will use the *Team Server*. An URL for your local PC will look like "https://localhost:5001", one for an Azure might look like "https://teamserver.thebigo.azurewebsites.com". This depends on your chosen host environment.

If you want to setup and operate a server, which is not only used by your direct team members, but also by other teams and drivers, for example a server for a community or a league, you can do this as well. Please consult the special section on [server administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) down below to learn more about the concept of accounts, contingent renewal and administrative tasks.

### Updating Team Server

Whenever a new version of Simulator Controller is released, there might be changes to the Team Server as well. Normally this is mentioned in the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes). If you host your own Team Server, you will have to redeploy the software, so that frontend and backend are compatible. In most cases you can retain your data, if you are running a persistent database, unless otherwise stated in the update notes. To do that, make a backup copy of the "TeamServer.db" file located in the root directory of your hosted Team Server, and restore this file after the update.

## Managing teams

You manage your teams using the corresponding dialog in "Simulator Startup".

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Team%20Management.JPG)

Please take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#team-management) for information how to bring up ths dialog.

In the first field, you select a folder, where dynamic session data will be stored, when you and your team mates will use the "Race Center" during the session. If you don't supply a special directory here, the data will be stored in the temporary folder in the *Simulator Controller\Temp* folder, which is located in your user *Documents* folder and might therefore be lost at the end of the session. Please see the documentation for "Race Center" down below for more information on data handling.

Then you have to enter the URL, where the *Team Server* can be reached (see above). Then you have to provide the account credentials (name and password) in the second line. If everything is correct, access tokens will be created, if you click on the small button with the key (otherwise you will see an error dialog, which describes the problem). The token in the first field is a session token to access team races. It will always be freshly created and is therefore valid for the period stated in the "Settings.json" file as described in the [installation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#installation--configuration) chapter. The second token, which will never change as long as the account exists, can be used to create a replication partnership between your local telemetry database and the central database. See the documentation for the ["Session Database" configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#choosing-the-database-location) for more information.

Please note, that you can copy the Server URL and the tokens to the clipboard using the small buttons on the right side of the fields and you can change your password by clicking on the small pencil beside the password field.

You can now hand the session token to your team mates, but before you do this, you have to create a team for them. You can create as many teams as you whish, each of which can have as many drivers as necessary. The most important part is the naming of the drivers, as these names are used to identify the driver during the race. It is absolutely important that you enter the names (First name, last name and nick name) exactly as they will appear in the simulation. The names will appear in the format *firstName* *lastName* (*nickName*), where the paranthesis are not part of the nick name. In the last list, you enter the sessions or events you want to participate in with your team, for example "24h of Bathurst". Please note, that all changes you made to your teams, drivers and sessions on the "Team" tab will be saved permanently, independent whether you leave the configuration dialog using the "Save" or the "Cancel" button.

Data tokens can also be shared with your team mates. You do not have to create a team in this case. Simply send the token to everyone who will take part in the data replication partnership. When a driver is connected to the Team Server using a data token, all his telemetry data will be replicated to the Team Server and in return he will receive the data of all other drivers as well. The telemetry data synchronized using the central Team Server in this way can then be used in the "Strategy Workbench" to create strategies for teams, for example. See the documentation of the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool for more information.

If you ever need to invalidate the current data token for any reason, for example because a driver left your team, you can click on the small button to the left of the data token field. The current data token will be invalidated and a new one will be created. Send the new token to all your team members that are still part of the data replication partnership.

Note: Deleting Teams, Drivers and Sessions may take quite a while, depending on the amount of data to be changed on the server. Deleting a session with data from a 24 hour race, or deleting the corresponding team which owns this session, may take several minutes.

Note: Sessions can be *used* multiple times. If you start a session, which has been used before, all data from the previous usage will be deleted automatically. On the other hand you want to have meaningful names for your sessions, so feel free to delete old sessions and create new ones as necessary.

That's it for team administration.

## Preparing a team session

First of all, it is absolutely important to note that a team session can only function properly if all members of the team are using Simulator Controller and have configured the same Virtual Race Assistants (either Jona or Cato or both). In order to participate in a team session, each member must prepare the settings for this upcoming team session. This is done using the "Race Settings" application.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%204.JPG)

Select the tab named "Team", and enter the Server URL as well as the session token, which has been provided by the team manager as described above in the chapter about [team administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams). Please note, that the tab "Team" is not available in the "Session Database", since the settings that are stored there will be independent of a given team.

Once you have entered the server credentials, you can click on the small button with the key and the available teams, drivers and sessions associated with the session token will be loaded. As an alternative, you can hold down the Control key, while pressing on the "Key" button which will open a login dialog where you can enter the login credentials of the team manager. Select the team, your driver and the session, and you are done - almost.

## Running a team session

When you head out onto the track, you must decide, whether you want this session to be a team session or not. This decision must be made, before the first stint driver of the session has completed the first lap. More on that down below. It is also absolutely necessary that all drivers are connnected to the simulation during the first lap and also for the rest of the session. Otherwise Simulator Controller detects, that the simulation has terminated also closes the connection to the *Team Server*. The team session will be initialized and started on the *Team Server* in the moment, the driver of the first stint has completed the first lap. It will be finished and closed, when the current driver in the simulation crosses the finish line and terminates the simulation.

And now the important stuff: To declare, that you want to join a team session, you must use the corresponding [action from the "Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server). For your convenience, it is also possible, to always enable team sessions using the action declaration of this plugin or using the corresponding preset in "Simulator Setup", but I don't recommend that, since you might end up being part of a session, you are not planned for. And finally, you can use the tray menu of the Simulator Controller application as an alternative to declare an action to enable the Team Server with a button on your Button Box or Steering Wheel.

Note: Simulator Controller detects a valid team session configuration upon startup, it will open a notification window and will show you the configuration of this session (either when the Team Server is enabled by default, or later, when you enable the Team Server using the corresponding button). If you missed this notification, you can still check whether the team mode is currently active, when you hover over the small cog wheel icon of Simulator Controller in the task bar. If Simulator Controller is enabled for a team session, the tooltip will show "Simulator Controller (Team)". When no valid team session could be established, the tooltip will read "Simulator Controller (Team) - Invalid". Also, the *Team Server* item in the right mouse menu of the tray icon will be checked.

## Race Center

As already said, all drivers are connected to the Team Server when running a team session and store the current session state, the telemetry data of the car and information about the standings and the performance of all opponents in the Team Server database. Using the ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center), an application of Simulator Controller, you can get access to this data and even (remote-)control some settings of the car. Please consult the separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center) for more information.
  
## Server Administration

This section is only relevant for those of you, who want to setup and manage their own servers. After you have installed and setup the Team Server in your hosting environment as described above in the first section, you can use the "Server Administration" application to create the different accounts for all team managers, that will run team sessions on this server.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%201.JPG)

In the top section of "Server Administration" you have to enter the login credentials of one of the administration accounts you have setup during the initial configuration of the Team Server. You have thought of that, right? If not, back to start. After you have successfully logged into the Team Server, you can create, delete or change accounts, which will have access to the server. An account is identified of a name, which must be unique, an optional E-Mail address, as well as contingent rule for the minutes which are available for race sessions on this account. You also have to create an initial password, which you must hand over together with the account name to the (team) manager of this account. You can create a password by clicking on the small key button and you can copy the password to the clipboard using the small button on the right.

Then you define, whether users of this account can access team session and / or use data replication using the checkboxes. Although technically possible to create an account which has no rights at all, this does not make much sense, right? So tick at least one of those boxes.

Very important are the settings for the time contingent. You can choose between "One-Time" contingents, which renders the account useless after the contingent has been used up, or you can choose two variants of renewable time contingents. The number of minutes entered on the right will be available directly after the account has been saved and they might be automatically renewed according to the contingent rule. More on that later. Last, but not least, you can manually set the number of currently available minutes using the small button with the clock. If you don't want to use all this stuff, you can create an unlimited account which is useful, if you run your own server for a closed group of team mates.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%202.JPG)

On the second page, you start a couple of background jobs on the server, which will keep everything tight and clean. You can delete periodically expired access tokens, you can define when to renew the time contingents on all accounts, and you can manage finished sessions, which might occupy a lot of disk space on the server. "Cleanup" means that all secondary data (telemetry, standings, etc.) will be deleted, but the stints and laps will survive whereas a "Reset" also deletes all stints with their laps, which just retains the name of the session. But you might also let the server fully delete finished sessions. Whatever you define here, finished session will always be retained for one week after the end of the session, so that all drivers have enough time to download the session data from the server.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%203.JPG)

The third page lets investigate the list of currently active connections to the server. You will see the name of your team mate, the role with which he is currently connected to the server and since then. If the connection is for an active team session, the name of the session will be shown as well.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%204.JPG)

Last, but not least, the last page shows you a list of all data currently stored on the server. If you are running a very large server, it would be a good idea to compact the database from time to time using the "Compact..." button, but make sure you have a valid backup copy and that are no active connections to the server in that particular moment.

## How it works

To get the best possible reesults in ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center), the Virtual Race Engineer as well as the Virtual Race Strategist must be enabled in your configuration. Jona will take care of the pitstops and the corresponding data like tyre pressures, fuel level, etc. and Cato is responsible to acquire all performance related telemetry data and the critical knowledge about the performance of your oppenents. When you start a team session as described above, Jona and Cato will act and behave as in a single driver session, though you might notice subtle differences. For example, a new driver will be greated by the Assistants after a driver swap or a returning driver will get a warm welcome. But the important differences are all below the waterline.

  1. Handover of the Knowledge Base
  
	 Jona and Cato both have a working memory, which stores the current state and is used to derive the recommendations and to control the actions of the Assistants. This data is held locally in memory in the "Race Engineer" and "Race Strategist" processes of the current driver. During a pitstop, copies of the complete working memory of the Race Assistants of the current driver are transferred to the *Team Server* and stored there in a database. After the next driver has picked up the car, this copies are requested from the central server and are used to initialize the working memory of the Race Assistants of this driver. This happens completely in the background.

  2. Handover of Race Settings
  
	 The next driver after a pitstop will also receive the current race settings of the previous driver, as defined by the "Race Settings" application. Especially important are those settings that influence the pitstop planning, the calculations for cold tyre pressures and the rules for the valuation of potential repairs. It is therefore important that all drivers of a team race decide together, which options they will choose for their race.

  3. Storing of Race Standings, Telemetry and Tyre Pressure Information

     Jona and Cato collect a lot of data during your races, for example race standings, lap times and other statistical data from all your opponents for after race analysis or telemetry data for setup and strategy development. For a single or double stint event with a single driver, all this data is kept in-memory. This is almost impossible for 24h race due to memory restrictions and completely impossible for multiplayer team races. Therefore, this data will also be stored centrally in the *Team Server* and will be reloaded at the end of the session for further processing.

A word about memory consumption here as well: Although a lot of effort has been put into optimizing the memory consumption of the overall solution, the Race Assistants still consume some memory, which is especially important for very long endurance races. You can expect around 500 MB of memory usage for a 1-hour stint as active driver, so take that into account. A 32 GB computer will be always on the safe side, but a 24h race with 2 drivers can be on the edge with a 16 GB setup, especially, when you run "Race Center" on your simulation PC as well (see the corresponding remarks above). Since the memory consumption depends heavily on the settings, it may be possible to use a 16GB setup, though. I therefore recommend running a local test (i.e. Team Server on localhost as described above) with up to 3 stints and check the memory consumption of "Race Engineer.exe", "Race Strategist.exe" and "Race Spotter.exe" afterwards. And I also recommend to check your virtual memory settings - on a 16GB system, a pagefile size of factor 1.5 might be helpful. You will find the required settings in the "System Properties" dialog of Windows:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Virtual%20Memory.JPG)

## Troubleshooting

A lot can happen when talking to services on the internet. The system tries to be as robust as possible. For example, when the connection to the *Team Server* is lost, the Race Assistants will continue to run in local mode. There will be no error messages on the screen in this situation in order to not interfere with your current stint. You can consult the log files in the *Simulator Controller\Logs* folder which is located in your user *Documents* folder afterwards. In most cases it will be a problem with the connection to the *Team Server*, but a full database (depending on your hosting environment quotas) might also be a root cause. Here are some tipps:

  1. Always check the connection to the *Team Server* using the "Race Settings" application just before the race or use the "System Monitor", which will constantly check the health state of the Team Server connection.
  
  2. Do not use "cheap" or free hosting. Especially the free account on Azure or AWS do not have any SLAs regarding service availibility and service quality.
  
  3. When running on a managed pay-per-use *Team Server*, be sure to check the number of available minutes before the session. It would be bad, if your contingent deplates during your best session ever.
  
  4. Always delete your sessions after the end of the race. This will free up all the used memory on the server.