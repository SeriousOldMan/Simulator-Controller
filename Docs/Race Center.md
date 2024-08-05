## Introduction

The "Race Center" application can be used when running a team session using the [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server) to browse the current state of the session, the telemetry data of the car and also get detailed information about the standings and the performance of all participants. In this sense, "Race Center" is a kind of pitwall application.

During a team session, all team members can use the "Race Center" application, even if they are not an active driver of the session and are not running the simulation. This tool gives you complete insights into the telemetry and standings data for the current race session. It also allows you to interact with the Virtual Race Assistants, even when you are not the currently active driver. By this functionality, each team member or a dedicated Race Engineer can, for example, prepare the perfect settings for an upcoming pitstop based on the myriads of data suppplied by the "Race Center". Before we dig into the details, take a look at the various screens of the "Race Center":

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%201.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%202.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%203.JPG)

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%204.JPG)

Please note, that all the data and graphs shown in the window will be updated dynamically as the race progresses. Most updates will be done each lap, but some minor details will be updated more frequently.

Important: "Race Center" displays various graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corresponding key in the registry. If you encounter an error, that the Google library can not be loaded, you must run "Race Center" once using administrator privileges.

### Normal vs. Simple user interface

The "Race Center" user interface comes in two flavours. The normal UI as shown in the pictures above targets the expert user, for example a team member, who is in the role of a Race Engineer for the whole team. This UI provides complete access to all information incl. very sophisticated telemetry reports, as well as the possibility to plan and prepare a session, change the strategy and the stint plan because of unplanned events during the session, and so on.

And there is a simplified version available for members of a team, which are in the driver role and only want to get important information and want to prepare a pitstop to get into the car, of course. This so called *Lite* version of the "Race Center", which is available when starting with a specialized profile from "Simulator Startup" (or by holding down the Alt key, when starting "Race Center"), looks like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2026.JPG)

However, if a driver wants to inspect specific data in more detail, for example the state of the tyres after they have been dismounted at a pitstop, this is still possible by double-clicking the corresponding entry in one the lists. Any number of report windows can be opened in this way, which possibly makes it not so simple anymore, but this is optional.

### Connecting to a Session

To use the "Race Center", you must have a valid connection to a team session. This is normally handled by entering the corresponding Server URL and session token into the ["Race Settings" application](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#preparing-a-team-session), but you can even connect to a team session without being an active driver in the session by entering the session token supplied by your team manager directly into the field at the top of the "Race Center" window. Then either click on the small button with the key on the left of the token field or choose "Connect" from the "Session" menu. As an alternative, you can hold down the Control key, while pressing on the "Key" button or choosing the menu command, which will open a login dialog where you can enter the login credentials of the team manager. Please do not use a refresh cycle smaller than 10 seconds when connected to a managed Team Server, since this will increase the running costs on Azure dramatically.

Once you are connected to an active session on the Team Server, all the data in "Race Center" will be updated every 10 seconds. During this time the user interface is locked to ensure the integrity of the data. This can be somewhat annoying. Therefore you can disable the synchronization temporarily using the corresponding command from the "Session" menu. Furthermore, you can select the update frequency by holding down the control key, when selecting the "Synchronize" menu item.

It can happen that some data is not available when requested by the "Race Center". Most of the time, the data will be available after a few seconds, because it simply wasn't yet ready at he time when it was requested. Therefore, the "Race Center" will be waiting some time when requesting any kind of data. It will eventually give up, if the data is not available at all for some reason, but you can use the Escape key to terminate the waiting prematurely. In general you should do this only, if you are sure that the data is not available at all, for example while the current driver has encountered a disconnection.

You can reload the data stored on the server for the currently selected session by clicking on the small button with the "Reload" icon. This can be helpful, when data seems to be missin, or when you have made changes, you want to discard.

If you have connected to a session that has already been used in a previous race and there is still data stored in the session, it might take a while, before all data have been loaded. The window controls will be blocked during this time and you will see a small mark rotating on the right side of the window to show you that data is being requested from the server.

It is no problem, to reuse a session for many races, because the old data (except the stint plan, the associated strategy, and the tyre setups, if any) will be automatically cleared, when the new race is started. But you can also use the command "Clear" from the "Session" menu beforehand to erase all current data, if you whish.

It is obvious, that it is **not** a good idea to use the same session in more than one race at the same time.

Important: Although it is possible and I have done it on my own for several races longer than 6 hours, I do not recommend to run "Race Center" on the same PC where your simulation runs. Sevaral operations, for example updating the strategy using extensive traffic simulation will consume quite a lot of memory and CPU-cycles. This might interfere with the memory requirements of your running simulator and might lead to decreased frame rates and - in very worse cases - to freezes due to shortage of memory. Therefore, I strongly recommend using a laptop or another separate PC, that sits aside your simulation rig, for the "Race Center" operation.

#### Connection failures

The Team Server connection is based on http and implements a sophisticated retry strategy. Most of the time, it will recover without notice. More severe is the behaviour of the simulation game itself after an internet failure and it heavily depends on the simulation, whether you may continue your session. In any case, I stronlgy recommend to reload the session in the "Race Center" after the car is back on the road and has crossed the start/finish line for the first time after the failure, since a couple of items in the history, for example the number of pitstops, migh be wrong otherwise.

#### Session Data Management

All data of an active session is stored on the Team Server. It is therefore possible to start the "Race Center" anytime, even late into the race. The data might be kept for a finished session on Team Server as well, depending on the settings chosen by the server administrator. See the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#server-administration) for more information. To secure the session data on your local PC, you can use the "Save Session..." commands from the "Session" menu at the end of the session and you can load a recently saved session anytime later using the "Load Session..." command.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2024.JPG)

IMPORTANT: The data format of locally saved sessions has changed over time. To load a session in the *old* format (before they have been saved to the session database by default), hold down the Control key, once the session browser is open. You will see that the "Load..." button changes to an "Import..." button.

#### Test Session

A public test server is available for your first test ride with "Race Center". Use the Server URL "https://sc-teamserver-test.azurewebsites.net" and connect to the "demo" account using the password "demo". The generated token, which is valid for seven days, can be used in the "Race Center" together with the Server URL to open the demo session. The server also has ten slots ("test1" - "test10", all with an empty password), which you can use to run your own tests. Only two hours of session time are available on each account but this is enough for a short test race. The accounts will be reset each day.

### Multi-class support

The "Race Center" *understands* multi-class and/or multi-category races. Please see in the sections below, how information is shown differently, when you are in a multi-class race. For the most part, class-specific information will be shon in the different reports. Please note, that it depends on your choice the [settings for the race reports](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports#selecting-report-data), how the information about the different classes and categories are interpreted and displayed.

### Data Analysis

"Race Center" supplies you with a couple of reports, which you can use to analyse the performance of your team drivers, compare them to your oponnents and dig deeper into the telemetry data of the car. Choose one of the reports in the reports list and this report will be shown in the report area on the top right of "Race Center" window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%205.JPG)

The reports at the top of the list are the well known reports, wich are also available after a session using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool. They are mostly useful to analyze the standings and the performance of the various drivers and cars. The other reports will give you an insight into the telemetry data. You can select the data to be shown using the selector menus on the right of the report list. You can also choose the type of visualization using the "Plot" menu on top of the report area. Use the "Driver" menu, it is possible to restrict the data of the various charts to one the drivers who has already driven some laps in the session. Only data of the selected driver will be shown then.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2019.JPG)

Note: The values for wear (tyres and brake pads) range from 0% up to 100%. For most of the simulators these values are directly available through the API, whereas in *Assetto Corsa Competizione*, the data interface provide the remaining thickness of each pad. Depending on the compound of the pad, the wear level for 100% ranges from 12 mm to 15.5 mm left pad thickness here, with a starting thickness for a fresh pad with 29 mm.

Last but not least, using the small button with the cog wheel icon, you can choose various settings for the currently selected report, for example the range of laps to be considered in the data or the set of drivers in reports which are driver specific.

A very special report is the live track view, which is available for all race simulators, which support track ccordinates. The track maps will be created automatically when you have driven a couple of laps on a given track with the Race Spotter active. See the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center#data-analysis) for more information. If a track map is available, you can select the "Track" report from the reports list to open the live view of the current race situation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2020.JPG)

Your own car will be marked by a black dot, whereas most other cars will be displayed as gray dots on the map, except your direct opponents and the race leader, for which the positions will be color coded. All positions will be updated every couple of seconds. Please note, that when you are in a multi-class race, this information is class-specific.

Beside all that, you can request several context specific data, which will be shown in the "Output" area in the lower right of the "Race Center" window.

  1. Strategy Summary

     This report will display the details of a currently loaded race strategy. See the next section for details.

  2. Plan Summary

     The Plan Summary show the details of the stint plan, which had been derived from the strategy or was entered manually. See the section [Session & stint planning](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center#session--stint-planning) for the details.

  3. Details of a selected stint
  
     This will give you an overview over the stint, the driven laps, as well as some performance figures for the driver. Please select a stint in the list of stints to generate this report.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%208.JPG)

  4. Details for a given lap
  
     When you select a lap in the *Laps* tab, you will get a detailed table of the standings and the gaps to the cars in front of and behind the drivers car, as well as to the leader.
	 
	 ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%209.JPG)
	 
	 If the current race is a multi-class race, the report will also show the class specific positions of all cars, additionally to their overall position in the race. In a multi-class race, the gaps shown in the gap table at the top of the report will always be specific for the own class. Additionaly, if driver categories are available, the category label of a given driver will be added to his name.
	 
	 Last, but not least, you will find informations about the past pitstops of each car. The overall number of pitstops, as well as the lap (in reference to your own laps) of the most recent stops are shown. Please keep in mind, that due to restrictions in the data provided by the various simulators, it cannot be differentiated in many cases whether a car has been in the pits for a penalty, a regular pitstop or even an unplanned stop due to repairs. Data about the particular service (refuel, tyre change, and so on) is unfortunately also not available. Last, but not least, it is possible that the number of pitstops are not correct at all, since not all stops may be correctly reported by the current simulator.
	 
	 Some basic data is shown in the header of the lap details as well. Important are here the ambient temperatures and the tyre pressure information. You can see the current hot pressures, recommend cold pressures (incl. a potential correction factor compared to the pressure setup at the beginning of the stint) and information about tyre pressure losses, if there are any.

  6. Details for a given pitstop
  
     You will get a summary of a given pitstop, when you select it in the *Pitstops* tab, incl. tyre wear data. This report is only available for pitstops, that already have been performed. You can identify performed pitstops by the small check in the corresponding row. Planned pitstops are shown without this check. The amount of infomration provided here depends of the data available for the current simulator.
	 
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
  
      This report is useful by the end of a race to create a document to be stored away in the archive. It contains data on all stints and drivers. This report can be created using the "Race Summary" command from the "Session" menu.
	 
	  ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2011.JPG)
	 
All these report documents are HTML-based and can be saved or printed using the context menu when right-clicking into the output area. If you want the report to be opened in a separate window, hold down the Control key while requesting it. If the report originates from one of the available lists, you can open the separate window by double-clicking the entry in the list.

### Strategy Handling

If you are running a race based on a predefined strategy developed using the ["Strategy Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench), you can adopt this strategy when necessary after important race events, for example after an accident, or after or just before significant weather changes.

To do this, you have to load the strategy, which have been selected for the current race using the "Load current Race Strategy" command from the "Strategy" menu. This command will load the strategy, which has been selected as the current race strategy in "Strategy Workbench" the last time. This will be done automatically for your convenience, when you enter the "Race Center" and no strategy has been selected so far. Please note, that it will not be checked, whether this strategy will be accepted by the Race Strategist for the current race. Please see the [documentation on strategy handling](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) for more information. As an alternative to the active race strategy mentioned before you can always load any strategy by using the "Load Strategy..." command.

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
  
     Selecting this option will run a probalistic traffic analysis based on a stochiastic model using the Monte Carlo analysis method. It will result in a pitstop strategy with the greatest benefit regarding the probable future traffic development, thus giving you the maximum possible clean air track time. See the [dedicated section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Center#monte-carlo-traffic-model) for more information.

After you dialed the options, you can select "Adjust Strategy (Simulation)" from the "Strategy" menu, to create a new strategy baseed on a simulation. The resulting strategy summary will be displayed in the output area. Please note, that when you are typically late into the race, any pitstop rules of the base strategy might be ignored, when conflicting with the current race situation, so please double check, whether the resulting strategy is in accordance with the rules.

Good to know: The Race Center will keep track of all already used tyre sets and will consider this, when running a strategy simulation. However, this only covers tyre set usage in the current session. If there are tyre sets that already have been used in a previous session, for example in a qualifying run, this information is not available.

IMPORTANT: Once you have created a new strategy, the stint plan (see below) must be updated as well, so that the information for refuel amount, tyre changes and so on, will be correct, when it comes to the next pitstop.

#### Monte Carlo traffic model

If you have selected the *Analyze Traffic* option before running the strategy simulation, you can dial further options for the simulation on the "Strategy" tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2014.JPG)

The Monte Carlo simulation is based on a stochiastic approach, where the future development of the race is predicted using the capabilities (laptime, consistency, error rate, recent typeical stint length before a pitstop) of the different drivers on the one hand and by introducing random events like a premature pitstop or an accident of one of the opponents on the other hand. You can choose the number of traffic models generated for each strategy candidate using the "# Scenarios" input field and the random impact with "Random Factor" field. The number of possible strategy candidates is derived implicitly by the "Variation" field, wich determines up to which extent the strategy for the upcoming next pitstop (+/- lap) might be altered compared to the "ideal" strategy without traffic. When altering the in-lap for the upcoming pitstop, remaining fuel as well as the pitstop rules of the current race are taken into account.

In the lower area, you can fine-control the traffic model generation by choosing which type of variations are generated and how these will impact the evaluation score of the resulting scenario. You can choose different aspects of your opponents, like driver errors, lap time variations, and so on, to be varied according to the statistical knowledge gathered in the recent laps of the race about each driver. At the end, the resulting strategy with the best score regarding 1. gained position, 2. least amount of traffic after the next pitstop and 3. the least overall amount of pitstops will be chosen as the future strategy.

Please note, that the same algorithm is also available in solo races, when using the [Virtual Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#adjusting-the-strategy-during-a-race).

If you are interested in the theoretical background for this very exciting approach, you can take a look at the [research paper](https://www.mdpi.com/2076-3417/10/12/4229).

#### Altering the current race strategy

You can run as many strategy simulations, with or without traffic anaylsis as you like. You can even go back to the "Strategy Workbench" and create a complete new strategy after a severe weather change, for example, and the adopt this base strategy in the "Race Center" to the current race situation. Once you are satisfied with the new strategy, you can update the strategy on the Team Server with the command "Release Strategy", thereby also updating it on every currently connected "Race Center", or you can even send it to the Virtual Race Strategist of the currently active driver using the "Instruct Strategist" command. If you think, that a predefined strategy will no longer fit the requirements of the session, you can cancel the strategy completely using the "Discard Strategy" command and handle all upcoming pitstops manually using the functions described in the next section. In both cases, the selected strategy will be updated in the "Race Center"s of all team members as well.

IMPORTANT: Once you have created a new strategy, the Stint Plan (see below) must be updated as well, so that the information for refuel amount, tyre changes and so on, will reflect the latest strategy, when it comes to the next pitstop.

Good to know: When you fail to create a better strategy using the simulation tools, you can go back to the strategy, that is associated with the current session in the Team Server by holding down the Control key and choosing the "Load current Race Strategy" from the "Strategy" menu.

### Session & stint planning

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

Beside using the typical "+" and "-" buttons here to create and delete a tyre pressure setups, you can use the button with the copy icon to clone the currently selected setup. Furthermore, you can use the button with the database icon to open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) to look up and load pressure information recorded in previous sessions.

Furthermore, you can download the current list of driver specific reference pressures to an external file and can upload them from this file, for example, to import setups into a different sesison. Finally, when you have made all your changes, push the button labeled "Save Setups", so that everything is stored on the Team Server.

### Planning a Pitstop

Using the elements on the "Pitstops" tab, any team member can prepare the next pitstop for the current driver. This is a valid alternative instead of using the services of the Virtual Race Assistants in an endurance race, where currently passive team members or even a dedicated Race Engineer are part of the crew supporting the active driver.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%206.JPG)

Especially before selecting the tyre pressures, you might want to analyze the data as described above. But you may also use the "Initialize from Session" command from the "Pitstop" menu, which will select the next driver according to the stint plam (make sure, that your plan is correct), and then it will use the values, that are currently recommended by Jona, the Virtual Race Engineer, for tyre pressures and correct them for the next driver as described below. The recommended pitstop lap and the amount of fuel to be added, will be taken from the stint plan or from the strategy, in that order. In situations, where the conditions change dramatically, for example an upcoming thunderstorm, you can also load the tyre data from the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) using the "Load from Database..." command, when you think that you might have cold pressure information available from previous sessions in comparable conditions.

Some simulators not only provide different tyre compounds for a given car, but also manage a number of available tyre sets for each compound, where this number might differ between different events or sessions. When initializing a pitstop, the next unused tyre set number for the given compound will be automatically calculated in most cases and will be entered in the "Tyre Set" field (you can enable or disable the automatic tyre set selection in the "Pitstop" menu). Always double check the value here, or you might end up with worn tyres on the wheels. Please note, that *Assetto Corsa Competizione* provide a kind of automatic selection, which only works reliable, when using the same compound as in the last stint. Set "Tyre Set" to **0** in this case.

You can also choose between two different methods to further adjust tyre pressures, when swapping drivers, as described in the previous section:

  1. Reference
  
     When you choose this method and there are tyre pressure setups available for the next driver according to the stint plan, these reference pressures will be used (possibly temperature corrected) and the pressure values derived by the Virtual Race Engineer will be ignored.

  2. Relative
  
     Using this method will use the target pressures derived by the Virtual Race Engineer, but these values will be corrected by applying the temperature corrected difference between the base pressures of the current driver and the next driver according to the stint plan. This will work best, when the reference pressures have been entered for very similar conditions.

The choices will be remembered between different runs of "Race Center".

Important: The correction factor to be applied for temperature corrections will be calculated with a linear regression using the supplied setup data. If there is not enough data available and the dependency of tyre pressures from the ambient temperatures cannot be derived, a fixed correction factor will be used instead. This correction factor can be defined in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#race-settings) independently for each simulator / car / track / weather combination, when necessary. When even these settings are missing, -0.1 PSI will be applied for each degree Celsius increase in air temperature, and -0.02 PSI for each increase in track temperature.

Furthermore, it is possible to enable a compensation for pressure losses as reported by the Race Engineer, like slow punctures or sudden pressure losses cause of collisions with curbs. But be sure, that it is really a loss of pressure due to a puncture or running over curbs. If not, you will end up with even worse pressures in those tyres.

Also important: "Race Center" will try to guess the best possible tyre pressures using input from the AI and also from the calculation methods discussed above. But you need to take a look as well, since the software can't cope with everything, especially sudden weather changes, moisture in the night, and so on. In these cases you might have to correct some of the recommended pressures manually to compensate for bad decisisions made by the software.

Of course, you can calculate and enter all values here on your own. For your convenience, you can use the small button with the "Copy" icon to the right of the tyre change drop down menu.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2022.JPG)

A menu appears, which let you choose one of the tyre pressure setups from the "Setups" tab or one of the settings for a past pitstop, which will then be entered together with the corresponding driver into the tyre pressure fields, where you can edit them afterwards, if desired.

#### Automatically select the next driver

The automatic selection of the next driver is supported for *Assetto Corsa Competizione*, *rFactor 2* and *Le Mans Ultimate* (in the future), as long as the following apply:

  1. A stint plan is available and is up to date, at least for the driver of the current and the driver for the next stint.
  2. You selected the participating drivers from all available drivers of your team and ordered them according to the entry list of the event using "Select Team..." command in the "Session" or in the "Pitstop" menu. Once you have done this, you can choose the next driver when planning a pitstop using the correspnding drop down menu.
  
     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2018.JPG)
	 
	 Please make sure, that the names and the order of the selected drivers are identical to the content of the entry list for your team in the upcoming session. Otherwise, wrong drivers might be selected for the next stint in the pitstop automation. As a beneficial side effect, you can see in the list of drivers also, which of the drivers are currently connected to the Team Server as a *Driver*.

Note: Once you have dialed the next driver for the first time in the simulator, and you want to correct some values for the pitstop, choose "No driver change" in the *Driver* dropdown menu. This will preserve the last selection of the next driver in the pitstop settings, while changing the refuel amount, for example.

#### Initiating a pitstop for the current driver

Once, you have dialed all settings, choose "Instruct Engineer" from the "Pitstop" menu and the entered values will be transferred to the Race Engineer of the active driver. The driver will be informed by Jona about the planned pitstop, but no interaction is necessary. The settings will be automatically entered into the Pitstop MFD, once the car crosses the start/finish line of the lap for which the pitstop has been planned, and the driver is called to the pit.

For some simulators, it is possible to bring up a floating information window, which displays (some of) the currently chosen settings in the Pitstop MFD. To bring up this window, click on the small button with crossed tools on the right of the "Lap" input field.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%2023.JPG)

This floating window, which can be left open all the time, will be updated once per lap with the actual data currently entered into the Pitstop MFD, of the simulator. Please note, that only the data, that is actually available from the simulator data API is shown here. The following simulators are supported here:

1. *Assetto Corsa Competizione*

   Information about a tyre change is really selected and the chosen tyre compound is not available. The most probable tyre compound will be derived from current and future weather conditions. Also, information about the chosen repair settings (although the time needed for the repair may be computed) and the chosen next driver is not available. Refuel amount, tyre pressures and tyre set are exact.

2. *rFactor 2* and *Le Mans Ultimate*

   Refuel amount, the chosen tyre compound and pressures, as well as the repair settings are exact.

3. *iRacing*

   Only chosen cold tyre pressures are available here.

Additional information will be available most of the time for the duration of the normal pitstop service (refueling and tyre change), the time needed for the repairs (whether this value will be correct, depends on correct values in the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database" for conversion between internal damage values of the simulator and the corresponding repair duration), and also the pitlane delta, which is the time difference between a drive-by and a drive-thorugh the pitlane. This value is also taken from the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings) in the "Session Database".

#### Planning and preparing pitstops in a team race using the Race Assistants

You probably already have used the Race Engineer to plan and prepare a pitstop during solo races or even have used the Race Strategist to run a full race with a pre-selected strategy. Although in most cases these duties will be taken by your team mates in a team race, it is still possible to use the Assistants as additional support as well. The following applies:

1. Planning and preparing a pitstop using the Race Engineer

   You can use the Race Engineer to plan and prepare a pitstop even during a team race. Doing it the same way as in a solo race might be the perfect method, when you are running a double stint, since you will be selected as the next driver. You initiate this process by issuing the voice command "Can you plan a pitstop?" or using the controller action ["PitstopPlan"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer). A pitstop planned and performed this way will also recorded in the list of pitstops in the "Race Center" as well. But be aware, that the Race Engineer has no knowledge about your stint plan and race schedule. Therefore it is possible, that you may end up with too much fuel in the tank after the pitstop.
   
   And this might also not be the best way when another driver will take the seat, since the tyre pressures calculated for you will not be perfect for your team mate in most cases. Therefore a second command exist to initiate a pitstop including a driver swap. Ask the Engineer "Can you plan a driver swap?" or use the controller action ["DriverSwapPlan"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer). When you initiate the process in this way, the Race Engineer will consult the Team Server to lookup the planned lap for the service, the next driver and the refuel amount from the Strategy or the stint plan and will also take a look at the driver specific tyre pressures to calculate the best possible tyre pressures for the next stint. Therefore, at least one instance of the "Race Center" must be running (not necessarily on the same PC as the current driver) for this method to be used. Please note, that the above mentioned adjustments for the tyre pressures will be apllied as well in this case, so be careful that the desired settings have been chosen in the "Pitstop" menu.

2. Strategy handling using the Race Strategist

   The Race Strategist will also be aware of a team session and will adjust its behaviour accordingly. You can send the strategy, which has been loaded into the "Race Center", to the Race Strategist, so that he will inform the driver about upcoming pitstops and will collaborate with the Engineer to plan and prepare these pitstops. Doing it this way will also use the integrated method, which will consult the "Race Center" for the stint plan, tyre pressures and so on. This will also be the case, if you ask the Strategist to recommend a pitstop lap to optimize for undercuts, and so on. If you cleverly combine and use all these functions, it is possible to run a team race under complete automatic control. No manual interaction will be necessary except reviewing and accepting the recommendations made by the Race Assistants.
   
   But there are, of course, exceptions which cannot be handled automatically. One notable exception might be an unplanned stop due to unexpected weather changes or a heavy crash. In some cases, especially when there is not enough data already available in the "Race Center" for the upcoming weather conditions, the stop will planned by the Race Engineer locally, which means that the current driver will stay in the car. But it is of course possible to plan the pitstop using the "Race Center" manually by your team mate in this case as well. Another exception might be a deviation from the stint plan or the current strategy due to an absent driver or an unexpected disconnect. You might adopt the plan or the strategy before proceeding, but there might not be enough time to do this. In the later case, try to adopt the stint plan and the strategy to the new situation afterwards and check whether everything picks up the new conditions.
   
   Please note, that whenever a strategy has been revised, either locally in the "Race Center" or by the Race Strategist at the current drivers site, you should check and possibly update the Stint Plan as well, since data taken from the strategy like refuel amount might have changed.

#### Special notes

Every simulation game is unique and handles multiplayer team races differently. Therefore, you have to be aware of the individual drawbacks and specialities. In this section I will provide a growing collection of hints and special operation tipps for all the individual simulations, whenever I stumble over them. When you found some specialities on your own, please feel free to share them with me, and I will be happy to add them to this section as well.

##### Assetto Corsa Competizione

  1. *Assetto Corsa Competizione* provides tyre set identification for dry tyres. Unfortunately, information about the state of the tyre sets is not available through the data API. The "Race Center will do its best to select the next fresh tyre set for the next pitstop, but always double check, especially when switching from wet to dry tyres, since in this case *Assetto Corsa Competizione* will reset the next tyre set number back to 1. *Assetto Corsa Competizione* also provides a kind of automatic mode to select the next free tyre set on its own. To use this, disable the calculation of the "Race Center" in the "Pitstop" menu or set the "Tyre Set" field to zero. But be aware, that this might fail, if you switch from wet to dry tyres due to a bug in *Assetto Corsa Competizione*.