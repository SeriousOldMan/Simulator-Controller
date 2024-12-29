## Introduction

The "Strategy Workbench" is a very valuable tool, which can be used either stand-alone or together with Cato, the Virtual Race Strategist. With the help of this tool, you can develop a pitstop and tyre strategy for an upcoming race. Simple sprint races with a single required pitstop are supported as well as endurance races with multiple stints and complex tyre and fuel saving strategies. An important feature of this tool is the ability to analyze telemetry data of past races, that have been collected by Cato. This telemetry information is stored in the local database at the end of a session, as long as this has been activated in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-race-strategist) for the given simulator.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Workbench.JPG)

Important: "Strategy Workbench" displays various graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corresponding key in the registry. If you encounter an error, that the Google library can not be loaded, you must run "Strategy Workbench" once using administrator privileges.

## Overview

The "Strategy Workbench" is divided into two main areas. The upper area allows you to analyze the available telemetry information for a given car / track / conditions combination using several available graphical charts. Telemetry information is divided into an *Electronics* and a *Tyres* group.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Chart%20Selector.JPG)

Each group provide data sets for all tyre compounds which have been used in the selected conditions. You can choose between the different tyre compounds and you can select different series of values, that are to be plotted against each other in the chart.

If you have data for different drivers available in your telemetry database, you can switch between the dfferent drivers using the "Driver" menu. Only data of the selected driver will then be visible in the various charts.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Chart%20Selector%202.JPG)

The lower area allows you to create a race strategy. You have to enter the race rules and various settings before you can use the simulation tool to create the required pitstops based on your entered settings and also on the telemetry information. In the lower left part of the window, you find a tabbed pane with several input sections.

Good to know: The chart in the upper area of the "Strategy Workbench" allows you to display different information. You can choose between "Telemetry", "Strategy" and "Comparison" in the "Chart" menu located above the chart area. The default, "Telemetry", displays the information for the currently selected set of data. "Strategy" will display the consumption graph of the currently simulated or selected strategy and "Comparison" displays the report of the last strategy comparison, if any.

### Rules & Settings

In the first tab you enter the rules and settings for the upcoming event. Using the *Settings* menu directly above the tabbed area, you can load settings values from different sources, for example from the Session Database or the from the currently active simulation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%201.JPG)

Loading of settings is supported for:

  1. The currently loaded Strategy:
  
     This is the most complete method for initialization of the Rules & Settings. It is most useful, after you restarted "Simulator Workbench" and want to continue your work on a Strategy. Simply load it using the "Strategy" menu and than choose this command. The following fields are loaded from the strategy:
	 
	 - Rules & Settings
	   - Race Duration
	   - Stint Limit
	   - Formation Lap
	   - Post Race Lap
	   - All Pitstop Rules incl. Tyre Sets
	 - Pitstop & Service
	   - Pitstop Delta
	   - Tyre Service Time
	   - Refuel Service Time
	   - Service Rules
	   - Fuel Capacity
	   - Safety Fuel
	 - Drivers
	   - The complete list of drivers, as long as known in the current telemetry database), will be restored
	 - Weather
	   - The complete weather forecast will be restored from the current strategy
	 - Simulation
	   - Tyre Compound
	   - Tyre Compound Color
	   - Tyre Usage
	   - Fuel Amount
	   - Map
	   - Average Lap Time
	   - Average Fuel Consumption
	   - Settings of the Optimizer
	   - Selected data sources (Telemetry & Fixed)
  
  2. *Race.settings* file
  
     The content of the current *Race.settings* file is used to initialize some fields. If the Control key is pressed, when this command is selected, the file chooser dialog is opened in the directory of the settings for the current simulator / car / track combination, but you may navigate to a totally different location if desired. The following fields are loaded from the settings file:
	 
	 - Rules & Settings
	   - Race Duration
	   - Formation Lap
	   - Post Race Lap
	 - Pitstop & Service
	   - Pitstop Delta
	   - Tyre Service Time
	   - Refuel Service Time
	   - Service Rules
	   - Safety Fuel
	 - Simulation
	   - Tyre Compound
	   - Tyre Compound Color
	   - Average Lap Time
	   - Average Fuel Consumption
  
  3. Session Database
     
     All preconfigured setting values for the selected simulator / car / track / weather combination are loaded from the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database). Available values are used to initialize the same fields as with the contents of the *Race.settings* file.

  4. Telemetry Data
  
     The best lap time and the best hot tyre pressures are extracted for for the current simulator / car / track combination and the following fields are initialized from this data:
	 
	 - Simulation
	   - Map
	   - Average Lap Time
	   - Average Fuel Consumption

  5. Simulation
  
     If a simulator session exists and is identical to the currently selected simulator / car / track combination, the following fields are initialized from data acquired from the simulator:
	 
	 - Rules & Settings
	   - Fuel Capacity
	 - Simulation
	   - Initial Fuel Amount
	   - Map
	   - Tyre Compound
	   - Tyre Compound Color

Notes:

  1. If you have set a number of required pitstops **and** a pitstop window, it depends on the starting fuel, whether the requirements can be met.
  2. If you have set a pitstop window, it is possible that some settings of the optimizer will be ignored to fullfil the pitstop window requirements.
  3. If you choose "Disallowed" for refueling or tyre change, this restriction applies to the whole session. If you have to apply more context specific restrictions, this can be achieved using the rule based validations, which are described in the next section.
  4. If you are simulating a session with a restricted number of tyre sets, the simulation will keep track of the the tyre usage and may reuse a tyre set, when necessary. In this case, the tyre set with the least amount of usage will always be used next.
  
#### Scenario validation

Beside the session rules, you can enter into the fields in the "Rules & Settings" tab, the simulation engine supports a rule based validation of strategy scenarios created during the simulation. These rules use the same technology used by the different Virtual Race Assistants, a [Hybrid Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine), which supports forward and backward logic resolution. For the scenario validation rules, only the backward chaining part is used, which is more or less similar to the *Prolog* logic programming language. Let's begin with an easy example:

	validScenario() <= pitstopFuel(?, ?refuels), ?refuels > 0

Every validation script has to define a "validScenario()" rule, which is invoked by the simulation engine. When this rule returns logical *true*, the current scenario is considered to be a valid strategy. In this simple example, this is the case, when at least one pitstop with refueling has been planned. Let's take a look at another example:

	validScenario() <= pitstopTyreCompounds(?tyreSets), length(?tyreSets, ?length), ?length > 0

In this case, the current scenario is considered valid, when the tyres will be changed at least once. As yu can see, you have different so called logical predicates like *pitstopFuel* or *pitstopTyreCompounds* at hand, which you can use to implement your "validScenario()" rule. The available predicates are described below.

The previous examples are of course very simple. Therefore, before presenting the available predicates, let's take a look at a more complex example.

	validScenario() <= refuels(0), tyreCompounds(?tyreCompounds), validTyreCompounds(?tyreCompounds)

	validTyreCompounds(?tyreCompounds) <= any?([Wet | ?], ?tyreCompounds)
	validTyreCompounds(?tyreCompounds) <= any?([Intermediate | ?], ?tyreCompounds)
	validTyreCompounds(?tyreCompounds) <= tyreCompounds(?tyreCompounds, Dry, ?temp),
										  unique(?temp, ?compounds),
										  length(?compounds, ?length),
										  ?length > 1

This validation script implements pitstop rules used in Formula 1 races at some time. In such a race, you are not allowed to refuel the car and you have to use at least two different dry tyre compounds, unless you have used a wet or an intermediate tyre set during the race.

##### Builtin Predicates

Although the logical predicates in *Prolog* look like function calls, the semantics are very different. First, as you can see in the "Formula 1" example above, an unlimited set of alternatives can be defined for a give predicate. These alternatives are called rules. And variables, which are identified by a leading question mark, can be used bi-directional. This is called unification, where a variable is bound to the value, which must be used to satisfy the logical constraints imposed by a given rule. If you want to learn rule programming, please read the documentation about the [rule engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).

That said, let's take a look at the builtin predicates:

  1. *totalFuel(?fuelAmount, ?numRefuels)*
  
     *?fuelAmount* is unified with total amount of fuel which will be used for the session and *?numRefuels* will be unified with the number of refuels at the pitstops during the session.
  
  2. *startFuel(?startFuel)*
  
     *?startFuel* is unified with the amount of fuel in the car at the start of the session.

  3. *pitstopFuel(?refuelAmount, ?numRefuels)*
  
     *?refuelAmount* is unified with amount of fuel which will be refilled at the pitstops and *?numRefuels* will be unified with the number of refuels at the pitstops.
  
  4. *startTyreCompound(?tyreCompound, ?tyreCompoundColor)*
  
     *?tyreCompound* and *?tyreCompoundColor* are unified with the info for the tyre set which has been mounted at the start of the session. Please note, that for *simple* "Wet", "Intermediate" and "Dry" compounds the color will always be "Black".
	 
  5. *startTyreSet(?tyreSet)*
  
     Same as the previous one, but you retrieve the number of the mounted tyre set in *?tyreSet*.

  6. *pitstopTyreCompounds(?tyreCompounds)*
  
     *?tyreCompounds* is unified with a list of tyre compounds mounted in the various pitstops of the session. A list has the syntactical structure "[element1, element2, ...]". A tyre compound is represented as a pair of compound and color, like "[Dry | White]". Example for two different tyre sets used in a session: "[ [Dry | White], [Wet | Black] ]"

  7. *pitstopTyreSets(?tyreSets)*
  
     *?tyreSets* is unified with a list of the numbers of the tyre sets  mounted in the various pitstops of the session. A list has the syntactical structure "[tyreSet1, tyreSet2, ...]". The tyre set may be false, if no tyre sets are supported or not known for the used tyre compound.
  
  8. *refuels(?refuels)*
  
     Convenience predicate for: "refuels(?refuels) <= totalFuel(?, ?refuels)"

  9. *tyreCompounds(?tyreCompounds)*
  
     Similar to *pitstopTyreCompounds*, but also include the info for the tyres mounted at the start of the session.

  10. *tyreSets(?tyreSets)*
  
      Similar to *pitstopTyreSets*, but also include the info for the tyres mounted at the start of the session.
  
  11. *tyreCompounds(?tyreCompounds, ?tyreCompound, ?tyreCompoundColors)*
  
      Use this predicate to query the used different mixtures (colors) for a given tyre compound. *?tyreCompounds* is a list of tyre sets as *returned* for example by the *tyreCompounds* predicate. *?tyreCompound* is identified with the base compound, for example "Dry", "Wet" and so on. For each base compound the list of unique tyre compound colors is unified with *?tyreCompoundColors*. Take a look at the "Formula 1" example, to see how this predicate can be used.

The above predicates will give you summarized information about all pitstops, which will be sufficient in most cases. But you can also acquire informations about each individual pitstop.

  1. *pitstops(?count)*

     *?count* will be unified with the overall number of pitstops.
	 
  2. *pitstopLap(?nr, ?lap)*
  
     This predicate will give you access to the planned lap for each pitstop.
	 
  3. *pitstopTime(?nr, ?minute)*
  
     This predicate will give you access to the planned time (minute into the race) for each pitstop.
	 
  4. *pitstopFuel(?nr, ?fuelAmount)*
  
     *?fuelAmount* will be unifed with the amount of fuel (in liters), which should be added at the pitstop with *?nr*.
	 
  5. *pitstopTyreCompound(?nr, ?tyreCompound, ?tyreCompoundColor)*
  
     Gives you access to the tyre compound and mixture to be mounted at the pitstop with *?nr*. When no tyre change is planned, *?tyreCompound* will be unified with false.
	 
  6. *pitstopTyreSet(?nr, ?tyreSet)*
  
     Gives you access to the tyre set to be mounted at the pitstop with *?nr*. When no tyre change is planned, *?tyreSet* will be unified with false.

  7. *pitstop(?nr, ?lap, ?minute, ?fuelAmount, ?tyreCompound, ?tyreCompoundColor)*
  
     This predicate combines all indivdual ones from above like *pitstopLap* into one single predicate which gives you access too all aspects of the pitstop with *?nr* at once.
  
Beside these predicates, which access the data of the current scenario, you have a set of additional predicates, which you can use to implement your validation rules.

  - *unique(?list, ?uniqueList)*
  
    *?uniqueList* is unified with a list which contains only the unique elements in list *?list*.
  
  - *any?(?value, ?list)*
  
    *any?* is considered logically *true*, when *?value* occurs in *?list* at least once.
	
  - *all?(?value, ?list)*
  
    *all?* is considered logically *true*, when *?list* contains only elements equal to *?value*.

  - *none?(?value, ?list)*
  
    *none?* is considered logically *true*, when *?list* does not contain *?value*.
	
  - *one?(?value, ?list)*
  
    *one?* is considered logically *true*, when *?list* contain exactly one element equal to *?value*.

  - *length(?list, ?length)*
  
    *?length* is unified with the number of elements in *?list*.

  - *reverse(?list, ?reversedList)*
  
    *?reversedList* is unified with a list, which contains the elements of *?list* in reversed order.

  - *concat(?list1, ?list2, ?concatenatedList)*
  
    *?concatenatedList* is unified with a list which contains the elements of both *?list1* and *?list2* in that order.
	
  - *remove(?list, ?value ?resultList)*
  
    *?resultList* is unified with a list which contains all elements of *?list* except all occurences of *?value*.

##### Integrating into Strategy Workbench

Once you have created a set of validation rules similar to the examples above, you can put the script in a file with the ".rules" extension and place this file in the *Validators* folder which is located in the *Simulator Controller* folder in your user *Documents* folder. For your convenience, this folder opens when you choose the "Rules:" item in the "Settings" menu. Once you have done this, you can activate the *validator* in the "Settings" menu of "Simulator Workbench". And from now on, you can hold down the control key while selecting the validator from the menu to start a text editor for this file.

### Pitstop & Service

In this tab you have to enter the time required for several pitstop activities. With the value of Pitstop Delta, you supply the difference time needed for a normal pitstop (time for pit in and pit out but without any service time minus the time to pass the pit area on the track, i.e. Drive through vs. Drive by), The fields below specify the time required for the various pit services, like changing tyres, refueling, and so on. As you can see, this is very similar to the settings in the [*Strategy* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#tab-strategy) in the "Race Settings" application.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%202.JPG)

### Pitstops (fixed)

In very rare cases it might be beneficial to define one or more fixed pitstops before running a simulation. Because it is possible to create invalid strategies using this functionality, you have to explicitly enable fixed pitstops, before you can enter any fixed pitstops at this tab. This can be done in the "Session" menu.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%207.JPG)

Enter the number of the pitstop that should be fixed at the specified lap, the amount of fuel to be added and choose whether you want to change tyres at this pitstop.

Important: The strategy simulation tries to compensate for the intervention as best as possible. But there are limits. For example, it is not checked whether the available fuel in the stint before a fixed pitstop is sufficient to extent this stint up to the fixed lap. Also, any additional restrictions like stint timers, tyre life, pitstop rules, and so on, might be ignored as well. Therefore it is possible that the simulation will come up with an invalid strategy, which, even worse, might not be detected correctly.

Good to know: When a strategy, that originally was created using fixed pitstops, is adjusted in the "Team Center" or is revised by the Strategist, the fixed pitstops will not be taken into account. There is a reason, why the strategy needs a revison, isn't it?

### Drivers

Using this tab, you can create a kind of a stint plan for the simulated session. You can use every driver, which is known in the local telemetry database. When the simulation runs, the drivers are picked up for each stint in the order, in which they appear in this list and the simulation will use the driver specific data for all simulation relevant aspects like lap times, fuel consumption, tyre degredation, and so on. If no such data is available, the simulation ight fail to create a valid strategy. In that case, use for the corresponding stint.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%205.JPG)

Note: If you import the strategy into the "Team Center", the driver information may be used to populate the stint plan for the session in "Team Center".

### Weather

Here you can configure a time dependent weather forecast for the strategy simulation. For each weather change specify the time into the race in hours and minutes and supply the expected rain level and temperatures.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%206.JPG)

Depending on the forecast, appropriate pitstops with tyre changes will be planned just before the weather change. If you use this feature, make sure to have sufficient telemetry data for all applicable tyre compounds available. Otherwise, the simulation will fail or yield false results.

Note: This information will be only used during the initial simulation of the strategy. If you later on recalculate the strategy using the Race Strategist or the "Team Center", the actual current weather or the weather outlook (if available by the simulator) will be used instead.

### Simulation

This is the central functionality for strategy development. Using the fields in this tab, you can define the starting conditions and settings for your first stint and run a strategy simulation. You can choose, whether to use only the values you entered here for engine map, lap time and average fuel consumption, or you can include the full knowledge from the telemetry data from previous sessions on the same track in similar conditions. For each different engine map and therefore fuel consumption and resulting average lap time, a strategy scenario will be created. A complex tyre degredation model as well as the improvement of the lap times, as the car gets lighter with decreasing fuel level, are taken into account as well. These scenarios together with all additional scenarios created by the optimization algorithm (see below), will be compared at the end of the simulation and the best one regarding the overall race result will be selected as the current strategy. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%203.JPG)

Enter the required values in the *Initial Conditions* group, choose the data to use and click on the "Simulate!" button. A summary of the strategy will be shown in fields in the *Summary* group. Use the sliders in the *Optimizer* group to define weights for diffferent variations of the simulation algorithm. These has the following meanings:

  - Initial fuel
  
	Perhaps the most tricky one and it needs a lot of historical telemetry data to create sensible results. Using the slider, you can optimize the amount of fuel to be used for the first stint, thereby influencing the car weight and in the end the resulting lap times in the critical first phase of a race. For some cars, for example, lap times increase significantly, if the amount of fuel and therefore the car weight is above a specific threshold. This can be derived from the telemtry data. If you set the slider completely to the left, the initial fuel amount entered in the *Initial Conditions* field group will be used only, whereas, if you set the slider to the right, you specify, how much of the fuel capacity of the car might be used as additional fuel for the simulation variations.
	
	Hint: If you want to simulate the whole range of initial fuel levels, enter **0** for the initial fuel level in the *Initial Conditions* field group and set the slider completely to the right.
	
  - Refuel
  
	Using this slider, it is possible to give the amount of fuel added at each pitstop some variation. The maximum variation with the slider at the far right is 50% of the fuel amount which have to be added to refill the car up to its fuel capacity at a given pitstop. You can use this optimization in races where the last stint otherwise will become very short (and a splash n dash stop is not beneficial for other reasons) to bring the max. fuel level down over the whole race.
	
  - Tyre Usage
  
	Here you have a range from 0 to 100% to enable some kind of *over-* or *underuse* of tyres. If you set the "Tyre Usage" slider to 30%, for example, this means that the tyres can be used for 54 laps, even if the optimum tyre life is at the beginning 40 laps was set. This might be useful to skip the tyre change in the last shorter stint of an endurance race. The number of possible laps will be varied on a stint by stint base, not only for the whole race.
	
  - Tyre Compound
  
    When you are preparing the Strategy for a car, for which different tyre compound mixtures (for example White - Blue - Red) are available, you can define with this slider the propabilty, with which a different mixture will be used for the next stint. Up to 100 variations may be evaluated for best possible lap times and thereby overall race performance. Tyre usage based lap time degredation will be included in the stochiastic modeling, as long as sufficient data is available for each tyre compound mixture.
	
	Important to understand: The simulation will use only those tyre compounds, for which telemtry data is available. So even, if you enetered a soft dry compound into the list of available tyre sets for example, it might never be used, if there is no data available. So be sure to have driven and recorded at least a couple of laps in varying conditions with all tyre compounds, which are available for the given car / track combination.

  - First Stint
    
	This slider let you define the weight of the first stint. Move it to the left and an early pitstop is preferred, move it to the right and a late stop will be preferred. This is a useful setting for sprint races with one required pitstop, to get out of traffic as early as possible or to create a splash n dash strategy for races without a required tyre change.
	
  - Last Stint
  
	Very similar to the *First Stint* optimization, but here you can adjust the length of the last two stints depending on the position of the slider.
	
	Example:
	
	Normally, when you create a strategy for an endurance race, the strategy simulation tries to evenly distribute the last two stints, when not enough tyre degredation and fuel related lap time data is available in the database, like in this case:
	
	![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Pit%20Strategy%201.png)
	
	If you now move the *Last Stint* slider completely to the right, the resulting strategy will create a splash n dash scenario, most likely without a driver change:
	
	![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Pit%20Strategy%202.png)

For every slider not at the zero position, different variations of the underlying value will be created as strategy scenarios, which will be compared at the end for better results. The number of variations depend on the slider position. The slider more to the right will result in more variations.

You can use the commands in the *Simulation* menu to start a simulation (similar to use the "Simulate!" button), and to copy the current results over to the *Strategy* tab. If you hold the Control key while pressing the "Simulate!" button or choosing the corresponding menu item, the selected scenario will be copied to the *Strategy* tab after the simulation.

Important: You all know the phrase "Shit in - shit out". Therefore please check that the telemetry data, that is used for the strategy simulation, is correct. There is a filter that learns, what are correct entries and what are not, but this filter uses a standard variation algorithm and therefore needs a lot of valid data vs. a small amount of invalid data. Especially in the beginning, if you only have data from a few laps, double check the results of the simulation and - if you think, they are off, for example for the fuel consumption - use only the data, you entered in the *Initial Conditions* field group for the simulation. By the way, you can delete corrupt data, if necessary. The telemtry data is stored lap by lap in the CSV files "Electronics.CSV" and "Tyres.CSV", which are located in the folder *Simulator Controller\Database\User\\[simulator]\\[car]\\[track]* (with [simulator], [car] and [track] substituted with the corresponding values) in your user *Documents* folder. You can open this file with your favorite editor and delete the suspicious lines. Another approach is to use the "Cleanup Data" command from the data selection popup. It will remove all entries from the telemetry database, whose values are way off the average value. Only the values for the currently selected driver (or in case "All" are selected, your own driver) will be considered during the cleanup process, and if you have configured a data replication to the Team Server, the entries will be deleted there as well.

### Strategy

The values in this tab and also the document display on the right side of the tabbed pane describe the currently selected strategy. The *Strategy* menu above allows you to save the current strategy, you can load a strategy from the database (or any other location on your PC) and you can compare different strategies. Finally, you can export the current stragey to Cato to be used for the next race or you can clear a previously exported strategy, so that you are on your own on the track.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Settings%204.JPG)

Good to know: The document shown on the right side can be printed using the right mouse button context menu.

Note: Exported strategies will be saved in the file "Race.strategy", which is located in the *Simulator Controller\Config* folder in your user *Documents* folder. There can only be one currently active strategey. Please see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-handling) for information, how Cato uses such a predefined strategy during a race.