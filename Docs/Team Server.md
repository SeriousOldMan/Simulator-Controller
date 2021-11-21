# Team Server

*Team Server* is a server-based solution which enables you to use the services of the racing assistants in a team race, e.g. a 24h race. Without the *Team Server* these services are only available to the driver of the first stint, for all other drivers the race assistants do not even start because they do not have the data from the first laps. With the help of *Team Server*, a central server that manages the data of all drivers in a database, this critical knowledge can now be shared between all drivers. The connection to this server is established by the individual applications of teh Simulator Controller suite ("Simulator Controller", "Race Engineer", "Race Strategist", ...) using Web APIs over HTTPS. This ensures the greatest possible interoperability and flexibility when setting up the central server.

## Installation & Setup

The *Team Server* requires you to run a Web API server process, which has been developed using .NET Core 3.1. Applications developed using this multi-plattform server framework from Micorsoft can be hosted on Windows, Linux and even macOS operating systems. You can find the *Team Server* in the *Binaries* folder - please copy this directory to your favorite hosting environment. If you want to set up your own host or if you want to test the *Team Server* on your local PC, you will have to install the .NET Core 3.1 framework. All required resources can be found on this [dedicated website](https://dotnet.microsoft.com/download/dotnet/3.1) from Microsoft.

To start the *Team Server*, you simply start the "Team Server.exe" from the corresponding directory. But before you do that, take a look at the "Settings.json" file, which is located in the same folder.

	{
	  "DBPath": ":memory:",

	  "TokenLifeTime": 10080,

	  "Accounts": [
		{
		  "Name": "admin",
		  "Password": "admin",
		  "Minutes": 2147483647,
		  "Administrator": true
		}
	  ]
	}

You first have to decide, where to locate the database, where all stuff will be stored. *Team Server* uses the *SQLite* SQL database ngine, therefor you can provide for the "DBPath" option any valid connect string supported by *SQLite*. The most common connect string file be a file path like "D:\Controller\Database\TeamServer.db", for example. But you can also provide the special connect string ":memory:", which will instantiate the database in the process memory. Please be aware, that everything will be lost, if this process terminates. You can also use the special connect string ":local", which creates a "TeamServer.db" file in the same directory as the "Team Server.exe" executable. If this works, depends on your hosting environment and the quotas assigned to your app by your hosting company.

The next option, "TokenLifeTime", specifies, how long an access token for your team mates will be valid. Access tokens will be described in detail in a later chapter. The life time will be specified in minutes, the 10080 minutes from the example above are exactly 7 days.

Using the "Accounts" option, you can *preload* accounts into an empty database. This cannot be empty, or you won't be able to connect to the *Team Server*. So make sure, that at least one administrator account will be created. The number of "Minutes" specifies the amount of time, this account has left for team sessions (necessary for a managed pay-per-use model, which might come in the future). If you are the only one, who will createa and manage teams, this is it, otherwise hand over the corresponding account name and password to your mates.

Last, but not least, you have to communicate the web URI to all team managers and drivers, which will use the *Team Server*. An URI for your local PC will look like "https://localhost:5001", one for an Azure might look like "https://teamserver.thebigo.azurewebsites.com". This depends on your chosen host environment.

## Managing teams

You manage your teams using the "Simulator Configuration" application. You will find everything you need on the "Team Server" tab on the far right of the tab header.

![](*)

First you have to enter the URI, where the *Team Server* can be reached (see above). Then you have to provide the account credentials (name and password) in the second line. If everything is correct, you will get an access token, if you click on the small button with the key (otherwise you will see an error dialog, which describes the problem). This access token will always be freshly created and is therefore valid for the period stated in the "Settings.json" file as described in the [installation](*) chapter. You can copy both the Server URI and the token to the clipboard using the small buttons on the right side

You can now hand the access token to your team mates, but before you do this, you have to create a team for them. You can create as many teams as you whish, each of which can have as many drivers as necessary. The most important part is the naming of the drivers, as these names are used to identify the driver during the race. It is absolutely important that you enter the names (First name, last name and nick name) exactly as they will appear in the simulation. The names will appear in the format *firstName* *lastName* (*nickName*), where the paranthesis are not part of the nick name. In the last list, you enter the sessions or events you want to participate in with your team, for example "24h of Bathurst". Please note, that all changes you made to your teams, drivers and sessions on the "Team" tab will be saved permanently, independent whether you leave the "Race Settings" dialog using the "Ok" or the "Cancel" button.

Note: Sessions can be *used* many times. If you start a session, which has been used before, all data from the previous usage will be deleted automatically. On the other hand you want to have meaningful names for your sessions, so feel free to delete old sessions and create new ones as necessary.

That's it for team administration.

## Preparing a team session

Every member of a team will have to prepare the settings for an upcoming team session. This is done using the already "Race Settings" application.

![](*)

Select the tab named "Team", and enter the server URI as well as the access token, which has been provided by the team manager as described above in the chapter about [team administration](*). Please note, that the tab "Team" is not available in the "Setup Database", since the settings that are stored there will be independent of a given team.

Once you have entered the server credentials, you can click on the small button with the key and the available teams, drivers and sessions associated with the access token will be loaded. Select the team, your driver and the session, and you are done - almost.

## Running a team session

When you head out onto the track, you must decide, whether you want this session a team session or not. This decision must be made, before the first stint driver of the session has completed the first lap. More on that down below. It is also absolutely necessary that all drivers are connnected to the simulation during the first lap and also for the rest of the session. Otherwise, Simulator Controller detects, that the simulation has terminated also closes the connection to the *Team Server*. The team session will be initialized and started on the *Team Server* in the moment, the driver of the first stint has completed the first lap. It will be finished and closed, when the current driver in the simulation crosses the finish line or terminates the simulation.

And now the important stuff: To declare, that you want to join a team session, you must use the corresponding [action from the "Team Server" plugin](*). It is also possible, to always enable team sessions using the action declaration of this plugin, but I don't recommend that.

## How it works

When you start a team session as described above, Jona and Cato will act and behave as in a single driver session, though you might notice subtle differences. For example, a new driver will be greated by the assistants after a driver swap or a returning driver will get a warm welcome. But the important differences are all below the waterline.

  1. Handover of the Knowledgebase
  
	 Jona and Cato both have a working memory, which stores current state and is used to derive the recommendations control the actions of the assistants. This memory is located locally in "Race Engineer" and "Race Strategist" process of the current driver. During a pitstop the complete working memory of the Race Assistants of the current driver is transferred to the *Team Server* and from there it is used to initialize the working memory of the Race Assistants of the next driver. This happens completely in the background.

  2. Handling of large data sets

     Jona and Cato collect a lot of data during your races, for example race standings, lap times and other statistical data from all your opponents for after race analysis or telemetry data for setup and strategy development. For a single or double stint event with a single driver, all this data is kept in-memory. This is almost impossible for 24h race. Therefore these data sets will also be stored in the *Team Server* and will be reloaded at the end of the session for further processing.

## Troubleshooting

A lot can happen when talking to services on the internet. The system tries to be as robust as possible. For example, when the connection to the *Team Server* is lost, the Race Assistants will continue to run in local mode. There will be no error messages on the screen in this situation in order to not interfere with your current stint. You can consult the log files in the *Simulator Controller\Logs* folder which is located in your user *Documents* folder afterwards. In most cases it will be a problem with the connection to the *Team Server*, but a full database (depending on your hosting environment quotas) might also be a root cause. Here are some tipps:

  1. Always check the connection to the *Team Server* using the "Race Settings" application just before the race.
  
  2. Do not use "cheap" or free hosting. Especially the free account on Azure or AWS do not have any SLAs regarding service availibility and service quality.
  
  3. When running on a managed pay-per-use *Team Server*, be sure to check the number of available minutes before the session. It would be bad, if your contingent deplates during your best session ever.
  
  4. Always delete your sessions after the end of the race. This will free up all the used memory on the server.