## Introduction

*Team Server* is a server-based solution, which enables you to use the services of the Virtual Race Assistants in a team race, e.g. a 24h race. Without the *Team Server* these services are only available to the driver of the first stint, for all other drivers the Race Assistants do not even start because they do not have the data from the first laps. With the help of *Team Server*, a central server that manages the data of all drivers in a database, this critical knowledge can now be shared between all drivers. The connection to this server is established by the individual applications of the Simulator Controller suite ("Simulator Controller", "Race Engineer", "Race Strategist", ...) using Web APIs over HTTPS. This ensures the greatest possible interoperability and flexibility when setting up the central server.

A public test server can be used for a test ride with with the Tean Server and ["Race Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#race-center), to see what it can do for you and your team. See the [description](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#test-session) below for more information on how to connect to the server and load a test session.

To give you a quick start with the Team Server, a managed server is available for you and your teams to use. To get access, you have to become a patron of Simulator Controller. Please check the [home page](https://www.patreon.com/simulatorcontroller) on www.patreon.com for more information. But you can also host your own instance of the Team Server, which is described in detail in the section below.

Disclaimer: Although the current version of the *Team Server* is no longer to be considered Beta, please always double-check the recommendations and actions of your Race Assistants after picking up the car from a different driver. There still might be situations, where the handover of the required data might fail and you might end up with your assistants as dumb as bread, at least what the recent history of the race concerns. For obvious reasons, there will be no error messages during the race, when for example the connection to the central server has been temporarily lost or other internal error occured, but you might face substantial misbehaviour. You may take a look into the log files afterwards, though.

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

You first have to decide, where to locate the database, where all stuff will be stored. *Team Server* uses the *SQLite* SQL database ngine, therefor you can provide for the "DBPath" option any valid connect string supported by *SQLite*. The most common connect string file be a file path like "D:\Controller\Database\TeamServer.db", for example. But you can also provide the special connect string ":memory:", which will instantiate the database in the process memory. Please be aware, that everything will be lost, if this process terminates. You can also use the special connect string ":local:", which creates a "TeamServer.db" file in the same directory as the "Team Server.exe" executable. If this works, depends on your hosting environment and the quotas assigned to your app by your hosting company.

The next option, "TokenLifeTime", specifies, how long an access token for your team mates will be valid. Access tokens will be described in detail in a later chapter. The life time will be specified in minutes, the 10080 minutes from the example above are exactly 7 days.

Using the "Accounts" option, you can *preload* accounts into an empty database. This cannot be empty, or you won't be able to connect to the *Team Server*. So make sure, that at least one administrator account will be created, since only these accounts will have access to the server administration tools. The number of "Minutes" specifies the amount of time, this account has left for team sessions (necessary for the managed pay-per-use model). Last, but not least, you can create accounts, that will reset with each restart of the server, for example for test purposes. If you are the only one, who will createa and manage teams, this is it, otherwise hand over the corresponding account name and password to your mates.

Last, but not least, you have to communicate the web URI to all team managers and drivers, which will use the *Team Server*. An URI for your local PC will look like "https://localhost:5001", one for an Azure might look like "https://teamserver.thebigo.azurewebsites.com". This depends on your chosen host environment.

If you want to setup and operate a server, which is not only used by your direct team members, but also by other teams and drivers, for example a server for a community or a league, you can do this as well. Please consult the special section on [server administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) down below to learn more about the concept of accounts, contingent renewal and administrative tasks.

### Updating Team Server

Whenever a new version of Simulator Controller is released, there might be changes to the Team Server as well. Normally this is mentioned in the [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes). If you host your own Team Server, you will have to redeploy the software, so that frontend and backend are compatible. In most cases you can retain your data, if you are running a persistent database, unless otherwise stated in the update notes. To do that, make a backup copy of the "TeamServer.db" file located in the root directory of your hosted Team Server, and restore this file after the update.

## Managing teams

You manage your teams using the "Simulator Configuration" application. You will find everything you need on the "Team Server" tab on the far right of the tab header.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2010.JPG)

In the first field, you select a folder, where dynamic session data will be stored, when you and your team mates will use the "Race Center" during the session. If you don't supply a special directory here, the data will be stored in the temporary folder in the *Simulator Controller\Temp* folder, which is located in your user *Documents* folder and might therefore be lost at the end of the session. Please see the documentation for "Race Center" down below for more information on data handling.

Then you have to enter the URI, where the *Team Server* can be reached (see above). Then you have to provide the account credentials (name and password) in the second line. If everything is correct, you will get an access token, if you click on the small button with the key (otherwise you will see an error dialog, which describes the problem). This access token will always be freshly created and is therefore valid for the period stated in the "Settings.json" file as described in the [installation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#installation--configuration) chapter. You can copy both the Server URI and the token to the clipboard using the small buttons on the right side and you can change your password by clicking on the small pencil beside the password field.

You can now hand the access token to your team mates, but before you do this, you have to create a team for them. You can create as many teams as you whish, each of which can have as many drivers as necessary. The most important part is the naming of the drivers, as these names are used to identify the driver during the race. It is absolutely important that you enter the names (First name, last name and nick name) exactly as they will appear in the simulation. The names will appear in the format *firstName* *lastName* (*nickName*), where the paranthesis are not part of the nick name. In the last list, you enter the sessions or events you want to participate in with your team, for example "24h of Bathurst". Please note, that all changes you made to your teams, drivers and sessions on the "Team" tab will be saved permanently, independent whether you leave the "Race Settings" dialog using the "Ok" or the "Cancel" button.

Note: Deleting Teams, Drivers and Sessions may take quite a while, depending on the amount of data to be changed on the server. Deleting a session with data from a 24 hour race, or deleting the corresponding team which owns this session, may take several minutes.

Note: Sessions can be *used* many times. If you start a session, which has been used before, all data from the previous usage will be deleted automatically. On the other hand you want to have meaningful names for your sessions, so feel free to delete old sessions and create new ones as necessary.

That's it for team administration.

## Preparing a team session

First of all, it is absolutely important to note that a team session can only function properly if all members of the team are using Simulator Controller and have configured the same Virtual Race Assistants (either Jona or Cato or both). In order to participate in a team session, each member must prepare the settings for this upcoming team session. This is done using the "Race Settings" application.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Settings%204.JPG)

Select the tab named "Team", and enter the server URI as well as the access token, which has been provided by the team manager as described above in the chapter about [team administration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#managing-teams). Please note, that the tab "Team" is not available in the "Session Database", since the settings that are stored there will be independent of a given team.

Once you have entered the server credentials, you can click on the small button with the key and the available teams, drivers and sessions associated with the access token will be loaded. As an alternative, you can hold down the Control key, while pressing on the "Key" button which will open a login dialog where you can enter the login credentials of the team manager. Select the team, your driver and the session, and you are done - almost.

## Running a team session

When you head out onto the track, you must decide, whether you want this session to be a team session or not. This decision must be made, before the first stint driver of the session has completed the first lap. More on that down below. It is also absolutely necessary that all drivers are connnected to the simulation during the first lap and also for the rest of the session. Otherwise Simulator Controller detects, that the simulation has terminated also closes the connection to the *Team Server*. The team session will be initialized and started on the *Team Server* in the moment, the driver of the first stint has completed the first lap. It will be finished and closed, when the current driver in the simulation crosses the finish line and terminates the simulation.

And now the important stuff: To declare, that you want to join a team session, you must use the corresponding [action from the "Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server). For your convinience, it is also possible, to always enable team sessions using the action declaration of this plugin or using the corresponding preset in "Simulator Setup", but I don't recommend that, since you might end up being part of a session, you are not planned for.

Note: Simulator Controller detects a valid team session configuration upon startup, it will open a notification window and will show you the configuration of this session (either when the Team Server is enabled by default, or later, when you emable the Team Server using the corresponding button). If you missed this notification, you can still check whether the team mode is currently active, when you hover over the small gear icon of Simulator Controller in the task bar. If Simulator Controller is enabled for a team session, the tooltip will show "Simulator Controller (Team)". When no valid team session could be established, the tooltip will read "Simulator Controller (Team) - Invalid".

### Special notes

Every simulation game is unique and handles multiplayer team races different. Therefore, you have to be aware of the individual drawbacks and specialities. In this section I will provide a growing collection of hints and special operation tipps for all the individual simulations, whenever I stumble over them. When you found some specialities on your own, please feel free to share them with me, and I will be happy to add them to this section as well.

#### Assetto Corsa Competizione

  1. *Assetto Corsa Competizione* looses the knowledge about the currently selected repair options in the Pitstop MFD sometimes after a driver swap. The internal selection state of the ["ACC" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) will therefore be reset to the selection during the last pitstop of the previous driver, but this might not reflect the internal state of the Pitstop MFD of the current driver. This means, that you have to open the Pitstop MFD and check both repair options, after the next pitstop has been planned. If you have to correct one or both settings, you must do this **without** the help and control of the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop) of the "ACC" plugin. So do not use your Button Box here. 
  
## Race Center

During a team session, all team members can use the "Race Center" application, even if they are not an active driver of the session and are not running the simulation. This tool gives you complete insights into the telemetry and standings data for the current race session. It also allows you to interact with the Virtual Race Assistants, even when you are not the currently active driver. By this functionality, each team member or a dedicated Race Engineer can, for example, prepare the perfect settings for an upcoming pitstop based on the myriads of data suppplied by the "Race Center". Before we dig into the details, take a look at the various screens of the "Race Center":

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%201.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%202.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%203.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%204.JPG)

Please note, that all the data and graphs shown in the window will be updated dynamically as the race progresses. Most updates will be done each lap, but some minor details will be updated more frequently.

### Connecting to a Session

To use the "Race Center", you must have a valid connection to a team session. This is normally handled by entering the corresponding server URL and access token into the ["Race Settings" application](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#preparing-a-team-session), but you can even connect to a team session without being an active driver in the session by entering the access token supplied by your team manager directly into the field at the top of the "Race Center" window. Then either click on the small button with the key on the left of the token field or choose "Connect" from the "Session" menu. As an alternative, you can hold down the Control key, while pressing on the "Key" button or choosing the menu command, which will open a login dialog where you can enter the login credentials of the team manager.

If you have connected to a session that has already been used in a previous race and there is still data stored in the session, it might take a while, before all data have been loaded. The window controls will be blocked during this time and you will see a small mark rotating on the right side of the window to show you that data is being requested from the server.

It is no problem, to reuse a session for many races, because the old data (except the stint plan and the associated strategy, if any) will be automatically cleared, when the new race is started. But you can also use the command "Clear" from the "Session" menu beforehand to erase all current data, if you whish.

It is obvious, that it is **not** a good idea to use the same session in more than one race at the same time.

Important: Although it is possible and I have done it on my own for several races longer than 6 hours, I do not recommend to run "Race Center" on the same PC where your simulation runs. Sevaral operations, for example updating the strategy using extensive traffic simulation will consume quite a lot of memory and CPU-cycles. This might interfere with the memory requirements of your running simulator and might lead to decreased frame rates and - in very worse cases - to freezes due to shortage of memory. Therefore, I strongly recommend using a laptop or another separate PC, that sits aside your simulation rig, for the "Race Center" operation.

#### Session Data Management

All data of an active session is stored on the Team Server. It is therefore possible to start the "Race Center" anytime, even late into the race. The data might be kept for a finished session on Team Server as well, depending on the settings chosen by the server administrator. See the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) for more information. To secure the session data on your local PC, you can use the "Save" and "Save a copy..." commands from the "Session" menu at the end of the session and you can load a recently saved session anytime later using the "Load..." command.

#### Test Session

A public test server is available for your first test ride with "Race Center". Use the Server URL "https://sc-teamserver-test.azurewebsites.net" and connect to the "demo" account using the password "demo". The generated token, which is valid for seven days, can be used in the "Race Center" together with the Server URL to open the demo session. The server also has ten slots ("test1" - "test10", all with an empty password), which you can use to run your own tests. Only two hours of session time are available on each account but this is enough for a short test race. The accounts will be reset each day.

### Data Analysis

"Race Center" supplies you with a couple of reports, which you can use to analyse the performance of your team drivers, compare them to your oponnents and dig deeper into the telemetry data of the car. Choose one of the reports in the reports list and this report will be shown in the report area on the top right of "Race Center" window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%205.JPG)

The reports at the top of the list are the well known report, wich are also available after a session using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) tool. They are mostly useful to analyze the standings and the performance of the various drivers and cars. The other reports will give you an insight into the telemetry data. You can select the data to be shown using the selector menus on the right of the report list. You can also choose the type of visualization using the "Plot" menu on top of the report area. Last but not least, using the small button with the gear icon, you can choose various settings for the currently selected report, for example the range of laps to be considered in the data or the set of drivers in reports which are driver specific.

Beside that, you can request several context specific data, which will be shown in the "Output" area in the lower right of the "Race Center" window.

  1. Strategy Summary

     This report will display the details of a currently loaded race strategy. See the next section for details.

  2. Plan Summary

     The Plan Summary show the details of the stint plan, which had been derived from the strategy or was entered manually. See the section [Session & Stint planning](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#session--stint-planning) for the details.

  3. Details of a selected stint
  
     This will give you an overview over the stint, the driven laps, as well as performance figures for the driver. Please select a stint in the list of stints to generate this report.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%208.JPG)

  4. Details for a given lap
  
     When you select a lap in the *Laps* tab, you will get a detailed table of the standings and the gaps to the cars in front of and behind the drivers car, as well as to the leader.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%209.JPG)

  6. Details for a given pitstop
  
     You will get a summary of a given pitstop, when you select it in the *Pitstops* tab, incl. tyre wear data. The amount of infomration provided here depends of the data available for the current simulator.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2016.JPG)
	 
	 Note: For *Assetto Corsa Competizione*, detailed tyre data is only available after a real driver swap when running on an ACC server (no single user session). For most of the other simulators, only the tyre wear percentage is provided for each tyre.
	 
  7. Setups Summary
	 
	 This report, which can be selected with "Setups Summary" command in the "Pitstop" menu, lists all registered, driver-specific tyre setups. Very helpful, if you want to have a printed version, just in case.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2017.JPG)
  
  8. Pitstops Summary
  
     This report is also available in the "Pitstop" menu and gives you a complete list of all recent pitstops and the corresponding tyre data, if available. The information provided is the same as in the report for a single pitstop, but you will see all the data for all pitstops at the same time.

  9. Driver Statistics
  
     You can generate a special report for all active drivers the team with detailed information about their stints as well as their individual performance figures (potential, race craft, pace, consistency and car control). Choose the "Driver Statistics" command from the "Session" menu to generate this report.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2010.JPG) ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2012.JPG)
	 
  10. Race Summary
  
      This report is usefull by the end of a race to create a document to be stored away in the archive. It contains data on all stints and drivers. This report can be created using the "Race Summary" command from the "Session" menu.
	 
	  ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2011.JPG)
	 
All these report documents are HTML-based and can be saved or printed using the context menu when right-clicking into the output area.

### Strategy Handling

If you are running a race based on a predefined strategy developed using the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development), you can adopt this strategy when necessary after important race events, for example after an accident, or after or just before significant weather changes.

To do this, you have to load the strategy, which have been selected for the current race using the "Load Race Strategy" command from the "Strategy" menu. This command will load the strategy, which has been selected as the current race strategy in "Strategy Workbench" the last time. This will be done automatically for your convinience, when you enter the "Race Center" and no strategy has been selected so far. Please note, that it will not be checked, whether this strategy will be accepted by the Race Strategist for the current race. Please see the [documentation on strategy handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) for more information. As an alternative to the active race strategy mentioned before you can always load any strategy by using the "Load Strategy..." command.

Important: It is possible by using "Race Center" to activate a race strategy for the current race, even if no strategy has been present at the start of the race. You can switch strategies, discard strategies, activate a different strategy, and so on, as often as necessary or as you like.

A summary of the loaded strategy will be displayed in the output area.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%207.JPG)

Many values from this *base* strategy (session length, stint length, weather, tyre selection, etc.) will be used for the subsequent strategy simulation, therefore it might be beneficial in case of significant weather changes to create a new base strategy using the "Strategy Worbench" with a different set of options and load it into the "Race Center", before trying to simulate a new strategy.

You then may choose the settings for the upcoming strategy simulation using the "Strategy" menu.

  1. Use Session Data
  
     All telemetry data from the current race session will be used for the strategy simulation. Normally a good choice, except in cases of drastic weather changes.

  2. Use Telemetry Database
  
     Choosing this option will include all the data from the general telemetry database. Use this option, if you think, that you need additional data for example for a different ECU Map choice or different weather conditions.
	 
  3. Keep current Map

     This option chooses only input data for the simulation which is based on the same ECU Map as the currently selected one, even if choosing a different map might supposedly lead to better results.

  4. Analyze Traffic
  
     Selecting this option will run a probalistic traffic analysis based on a stochiastic model using the Monte-Carlo analysis method. It will result in a pitstop strategy with the greatest benefit regarding the probable future traffic development, thus giving you the maximum possible clean air track time. See the [dedicated section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#monte-carlo-traffic-model) for more information.

After you dialed the options, you can select "Adjust Strategy (Simulation)" from the "Strategy" menu, to create a new strategy baseed on a simulation. The result strategy summary will be displayed in the output area. Please note, that when you are typically late into the race, any pitstop rules of the base strategy might be ignored, when conflicting with the current race situation, so please double check, whether the resulting strategy is in accordance with the rules.

#### Monte-Carlo traffic model

If you have selected the *Analyze Traffic* option before running the strategy simulation, you can dial further options for the simulation on the "Strategy" tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2014.JPG)

The Monte-Carlo simulation is based on a stochiastic approach, where the future development of the race is predicted using the capabilities (laptime, consistency, error rate) of the different drivers on the one hand and by introducing random events like a premature pitstop or an accident of one of the opponents on the other hand. You can choose the number of traffic models generated for each strategy candidate using the "# Scenarios" input field and the random impact with "Random Factor" field. The number of possible strategy candidates is derived implicitly by the "Variation" field, wich determines up to which extent the strategy might be altered compared to the "ideal" strategy without traffic.

In the lower area, you can fine-control the traffic model generation by choosing which type of variations are generated and how these will impact the evaluation score of the resulting model. At the end, the resulting strategy with best score regarding 1. gained position, 2. least amount of traffic after a pitstop and 3. the least overall amount of pitstops will be chosen as the future strategy.

#### Altering the current race strategy

You can run as many strategy simulations, with or without traffic anaylsis as you like. You can even go back to the "Strategy Workbench" and create a complete new strategy after a severe weather change, for example, and the adopt this base strategy in the "Race Center" to the current race situation. Once you are satisfied with the new strategy, you can send it to the Virtual Race Strategist of the currently active driver using the "Instruct Strategist" command. If you think, that a predefined strategy will no longer fit the requirements of the session, you can cancel the strategy completely using the "Discard Strategy" command and handle all upcoming pitstops manually using the functions described in the next section. In both cases, the selected strategy will be updated in the "Race Center"s of all team members as well.

### Session & Stint Planning

It is quite common for long endurance races to create some kind of stint plan before the race, so that each driver knows, when he has to be on the track. A stint plan is tightly coupled to the race strategy and indeed, you can create a stint plan by using the command "Load From Strategy" from the "Plan" menu. But you can also create a plan manually, as we will see below.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2013.JPG)

Before creating the plan, please enter the date and time of the event into the fields above the list of stints. Then you have two options:

  1. Create the plan from the strategy
  
     As mentioned, load a strategy with the commands from the "Strategy" menu and then select the "Load from Strategy" command from the "Plan" menu and the plan will be created one predefined stint for each stint in the strategy. After the plan has been created, select each stint and choose the driver which will be responsible for this stint. You can also tweak the estimated starting times and estimated starting laps, if applicable, but be aware, that these has no influence on the real events. The other elements (refuel amount, tyre change, etc.) are there for your information and also will have no impact on the behaviour of the Race Assistants as the selected strategy has always priority. But these values will be taken into account when you prepare a manual pitstop with the tools on the "Pitstop" tab. Last, but not least, the *actual* values for time and lap of a stint will be updated autmatically by the "Race Center" when the stint starts, so you can leave them alone as well. The driver who actually took over the car for the stint is also entered into the list.
	 
	 You can use the "Load from Strategy" command as often as you like, or whenever the strategy has changed. As long as the number of stints in the strategy is equal or greater to the number of stints in the stint plan, all crucial information entered by you will be preserved. Otherwise you will be asked, where to remove superfluous stints from the plan, at the beginning or at the end.

  2. Create a plan manually
  
     If you don't want to use a race strategy for whatever reason, or if you want to defer from the predefined strategy, you can alter the stint plan manually. Use the "+" button and create as many stints as necessary, or to insert a stint between two other stints. Then enter the values for each stint, as described above. You can also delete superfluous stints by selecting them and clicking on the "-" button.

I recommend that only one person from the team is responsible for the strategy and stint plan, otherwise it will get chaotic quite fast. Therefore, if you choose "Release Plan" from the "Plan" menu, your current plan will be updated automatically in all "Race Center"s of your team mates.

### Managing driver specific tyre pressures

A typical problem in team races is the different driving styles of the team members. In most cases, the race rules does not allow changing the suspension and aerodynamics setup during a pitstop, but handling driver specific tyre pressures due to a more or less aggressive driving style is fortunately allowed and easily doable. Using the "Setups" tab, you can enter one or more reference tyre pressures for your team mates, which can then be used to adjust tyre pressures during a driver swap.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2015.JPG)

You can enter as many setups here as you like for different weather conditions, temperatures and used tyre compounds. The more you have at your finger tips, the better are the chances that you can't be catched off guard by a sudden weather change. See the next section, how this data can be used to automatically adjust the tyre pressures, when planning an upcoming pitstop.

### Planning a Pitstop

Using the elements on the "Pitstops" tab, any team member can prepare the next pitstop for the current driver. This is a valid alternative instead of using the services of the Virtual Race Assistants in an endurance race, where currently passive team members or even a dedicated Race Engineer are part of the crew supporting the active driver.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%206.JPG)

Especially before selecting the tyre pressures, you might want to analyze the data as described above. But you may also use the "Initialize from Session" command from the "Pitstop" menu, which will use the values, that are currently recommended by Jona, the Virtual Race Engineer, for tyre pressures. Also, the recommended pitstop lap and the amount of fuel to be added, will be taken from the stint plan, or from the stratetgy, in that order. In situations, where the conditions change dramatically, for example an upcoming thunderstorm, you can also load the tyre data from the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--session-database) using the "Load from Database..." command, when you think that you might have cold pressure information available from previous sessions in comparable conditions.

You can also choose between two different methods to further adjust tyre pressures, when swapping drivers, as described in the previous section:

  1. Reference
  
     When you choose this method and there are tyre pressure setups available for the next driver according to the stint plan, these reference pressures will be used (possibly temperature corrected) and the pressure values derived by the Virtual Race Engineer will be ignored.

  2. Relative
  
     Using this method will use the target pressures derived by the Virtual Race Engineer, but these values will corrected by applying the temperature corrected difference between the base pressures of the current driver and the next driver according to the stint plan. This will work best, when the reference pressures have been entered for very similar conditions.

Important: The correction factor to be applied for temperature corrections will be calculated with a linear regression using the supplied setup data. If there is not enough data available and the dependency of tyre pressures from the ambient temperatures cannot be derived, a fixed correction factor will be used instead. This correction factor can be defined in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings-1) independently for each simulator / car / track / weather combination, when necessary. When even these settings are missing, -0.1 PSI will be applied for each degree Celsius increase in air temperature, and -0.02 PSI for each increase in track temperature.

#### Automatically select the next driver

The automatic selection of the next driver is supported for *Assetto Corsa Competizione* and *rFactor 2*, as long a sthe following apply:

  1. A stint plan is available and is up to date, at least for the driver of the current and the driver for the next stint.
  2. You selected the participating drivers from all available drivers of your team and ordered them according to the entry list of the event using "Select Team..." command in the "Pitstop" menu. Once you have done this, you can choose the next driver when planning a pitstop using the correspnding drop down menu.
  
     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2018.JPG)
	 
	 Please make sure, that the names and the order of the selected drivers are identical to the content of the entry list for your team in the upcoming session. Otherwise, wrong drivers might be selected for the next stint in the pitstop automation.

Once, you have dialed all settings, choose "Instruct Engineer" from the "Pitstop" menu and the entered values will be transferred to the Race Engineer of the active driver. The driver will be informed by Jona about the planned pitstop, but no interaction is necessary. The settings will be automatically entered into the Pitstop MFD, once the car crosses the start/finish line of the lap for which the pitstop has been planned, and the driver is called to the pit.
  
## Server Administration

This section is only relevant for those of you, who want to setup and manage their own servers. After you have installed and setup the Team Server in your hosting environment as described above in the first section, you can use the "Server Administration" application to create the different accounts for all team managers, that will run team sessions on this server.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%201.JPG)

In the top section of "Server Administration" you have to enter the login credentials of one of the administration accounts you have setup during the initial configuration of the Team Server. You have thought of that, right? If not, back to start. After you have successfully logged into the Team Server, you can create, delete or change accounts, which will have access to the server. An account is identified of a name, which must be unique, an optional E-Mail address, as well as contingent rule for the minutes which are available for race sessions on this account. You also have to create an initial password, which you must hand over together with the account name to the (team) manager of this account. You can create a password by clicking on the small key button and you can copy the password to the clipboard using the small button on the right.

Very important are the settings for the time contingent. You can choose between "One-Time" contingents, which renders the account useless after the contingent has been used up, or you can choose two variants of renewable time contingents. The number of minutes entered on the right will be available directly after the account has been saved and they might be automatically renewed according to the contingent rule. More on that later. Last, but not least, you can manually set the number of currently available minutes using the small button with the clock.

If you don't want to use all this stuff, simply set the number of minutes to an astronomical high number and the contingent rule to "One-Time". You will end up with an account, that will last forever.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Server%20Administration%202.JPG)

On the second page, you start a couple of background jobs on the server, which will keep everything tight and clean. You can delete periodically expired access tokens, you can define when to renew the time contingents on all accounts, and you can manage finished sessions, which might occupy a lot of disk space on the server. "Cleanup" means that all secondary data (telemetry, standings, etc.) will be deleted, but the stints and laps will survive whereas a "Reset" also deletes all stints with their laps, which just retains the name of the session. But you might also let the server fully delete finished sessions. Whatever you define here, finished session will always be retained for one hour after the end of the session, so that all drivers have enough time to download the session data from the server.

## How it works

To get the best possible reesults in "Race Center", the Virtual Race Engineer as well as the Virtual Race Strategist must be enabled in your configuration. Jona will take care of the pitstops and the corresponding data like tyre pressures, fuel level, etc. and Cato is responsible to acquire all performance related telemetry data and the critical knowledge about the performance of your oppenents. When you start a team session as described above, Jona and Cato will act and behave as in a single driver session, though you might notice subtle differences. For example, a new driver will be greated by the assistants after a driver swap or a returning driver will get a warm welcome. But the important differences are all below the waterline.

  1. Handover of the Knowledgebase
  
	 Jona and Cato both have a working memory, which stores the current state and is used to derive the recommendations and to control the actions of the assistants. This data is held locally in memory in the "Race Engineer" and "Race Strategist" processes of the current driver. During a pitstop, copies of the complete working memory of the Race Assistants of the current driver are transferred to the *Team Server* and stored there in a database. After the next driver has picked up the car, this copies are requested from the central server and are used to initialize the working memory of the Race Assistants of this driver. This happens completely in the background.

  2. Handover of Race Settings
  
	 The next driver after a pitstop will also receive the current race settings of the previous driver, as defined by the "Race Settings" application. Especially important are those settings that influence the pitstop planning, the calculations for cold tyre pressures and the rules for the valuation of potential repairs. It is therefore important that all drivers of a team race decide together, which options they will choose for their race.

  3. Storing of Race Standings, Telemetry and Tyre Pressure Information

     Jona and Cato collect a lot of data during your races, for example race standings, lap times and other statistical data from all your opponents for after race analysis or telemetry data for setup and strategy development. For a single or double stint event with a single driver, all this data is kept in-memory. This is almost impossible for 24h race due to memory restrictions and completely impossible for multiplayer team races. Therefore, this data will also be stored centrally in the *Team Server* and will be reloaded at the end of the session for further processing.

A word about memory consumption here as well: Although a lot of effort has been put into optimizing the memory consumption of the overall solution, the Race Assistants still consume some memory, which is especially important for very long endurance races. You can expect around 500 MB of memory usage for a 1-hour stint as active driver, so take that into account. A 32 GB computer will be always on the safe side, but a 24h race with 2 drivers can be on the edge with a 16 GB setup, especially, when you run "Race Center" on your simulation PC as well (see the corresponding remarks above). Since the memory consumption depends heavily on the settings, it may be possible to use a 16GB setup, though. I therefore recommend running a local test (i.e. Team Server on localhost as described above) with up to 3 stints and check the memory consumption of "Race Engineer.exe", "Race Strategist.exe" and "Race Spotter.exe" afterwards. And I also recommend to check your virtual memory settings - on a 16GB system, a pagefile size of factor 1.5 might be helpful. You will find the required settings in the "System Properties" dialog of Windows:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Virtual%20Memory.JPG)

## Troubleshooting

A lot can happen when talking to services on the internet. The system tries to be as robust as possible. For example, when the connection to the *Team Server* is lost, the Race Assistants will continue to run in local mode. There will be no error messages on the screen in this situation in order to not interfere with your current stint. You can consult the log files in the *Simulator Controller\Logs* folder which is located in your user *Documents* folder afterwards. In most cases it will be a problem with the connection to the *Team Server*, but a full database (depending on your hosting environment quotas) might also be a root cause. Here are some tipps:

  1. Always check the connection to the *Team Server* using the "Race Settings" application just before the race.
  
  2. Do not use "cheap" or free hosting. Especially the free account on Azure or AWS do not have any SLAs regarding service availibility and service quality.
  
  3. When running on a managed pay-per-use *Team Server*, be sure to check the number of available minutes before the session. It would be bad, if your contingent deplates during your best session ever.
  
  4. Always delete your sessions after the end of the race. This will free up all the used memory on the server.