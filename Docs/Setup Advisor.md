## Introduction

When it comes to race cars, the vast amount of available options when developing a setup for a specific track and the personal driving style can be overwhelming - and this not only for the beginners. Most of us know some thump rules, for example: "Increase the rear wing angle to increase the rear stabiliity in fast corners and under heavy braking". But only a few of us know all the little tricks to create the best possible compromise for a given driver / car / track combination. And it will always be a compromise, since many requirements are contradictory. Creating loads of downforce for fast corners makes you slow on the straights, right?

Welcome to "Setup Advisor", a new member in the growing collection of tools of the Simulator Controller suite.

## Describing Setup Issues

The real world approach, when developing a setup for a race car, is to drive a few laps and make mental notes of all the flaws and drawbacks of the current car handling. You then describe all these issues to your suspension engineer, who then adjusts the settings on the car accordingly. Another test on the track will hopefully confirm the improvements that have been made, but usually also reveal new issues that arise as a result of the changes. After you have gone through this cycle a few times, you usually have found the best possible compromise for the current track.

"Setup Advisor" supports exactly this approach by allowing you to describe the issues with the current setup on the left-hand side of the window. You can determine how badly the issue affects the driving characteristics and how important an improvement is for the overall performance.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/Development/Docs/Images/Setup%20Advisor.JPG)

After starting the tool, you first select the simulation and, if necessary, the car and track, as well as the weather conditions for which a setup is to be developed. Different simulators and also different cars might support different sets of setup options. You can choose "Generic" or "All", if the specific simulator and car is not availabe. Then you can click on the "Problem..." button to select an issue for which you want to explore a possible change to the car setup. With the sliders "Importance" and "Severity" you determine the above-mentioned weighting and the severity of the issue. After a few moments, one or more recommendations for useful changes to the setup will appear on the right side of the window. For many issues, tiered recommendations are available based on the selected severity level.

Please note, that it is possible to describe and edit several issues at once. "Setup Advisor" will try to find the best possible compromise, especially when there are conflicting requirements. Of course, this has its limitations and it is therefore always advisable to tackle one or two issues at a time, even if "Setup Advisor" searches for solutions for up to eight issues at a time.

Using the "Load..." and "Save..." buttons in the lower left corner of the window, you can store and retrieve your current selection of issues to your hard drive. The current state will also be stored, when you hold down the Control key, while exiting "Setup Advisor". This state can be retrieved again, when you hold down the Control key, while starting "Setup Advisor".

## Understanding the Recommendations

Since "Setup Advisor" has no knowledge about the concrete settings in the current car setup, all recommendations are of reltive nature. When you get the recommendation for a reduction of "Camber Rear Left" by -1, this does not mean that you have to reduce the rear left camber by exactly 1 click or by 0.1 degree. It rather means, that a reduction of the camber will have the a large, when not the largest impact in the set of recommendations. To be precise, a recommendation with a value of 1.0 or -1.0 is four times as important than a recommendation with a value of 0.25. This is a hint for you where to start with your incremental tests when applying the recommended setup changes to your car.

### Meaning of the setup values

Most of the recommended setup values will be self-explanatory. The table below will show you the meanung of the positive and negative values of the more special setup options.

| Setting                 | Negative values                   | Positive values                   |
| ----------------------- | --------------------------------- | --------------------------------- |
| Brake Balance           | More pressure to the rear brakes  | More pressure to the front brakes |
| Brake Ducts             | Less open duct                    | More open duct                    |
| Splitter / Wing         | Less drag / downforce             | More drag / downforce             |
| Ride Height             | Lower ride height                 | Higher ride height                |
| Damper                  | Less damping / resistance         | More damping / resistance         |
| Spring / Bumpstop Rate  | Softer                            | Stiffer                           |
| Bumpstop Range          | Shorter                           | Longer                            |
| Differential Preload    | Less opening resistance           | More opening resistance           |
| Anti Roll Bar           | Softer                            | Stiffer                           |
| Toe (1)                 | Less toe out / More toe in        | More toe out / Less toe in        |
| Camber                  | Less negative camber              | More negative camber              |

(1) Most race cars run a little bit of toe in at the rear. The recommendations are based on that assumption. If that is not the case with your car, please reverse the recommendations.

Please be aware, that a long list of change recommendations does not mean that you have to change each and every setting. It rather means, that all these settings have an influence on the given issue. I recommend starting with the setting with the biggest impact and then work through the list step by step while monitoring the resulting change in car handling by driving a few laps after each change.

### Handling of contradictions

If you're working on more than one issue at a time, it's likely that you'll have conflicting recommendations to address. Depending on the "Importance" and "Severity" settings, "Setup Advisor" attempts to balance these contradictions. Example: If both a high top speed and equally high cornering speeds are required in fast corners, it depends on the product of the respective "Importance" and "Severity" whether an increase or decrease in the downforce value of the rear wing is recommended at the end.

### Disclaimer

The rules for the recommendations have been compiled from different sources, above all my own experiences. That said, I do not take responsibility for the correctness of all the recommendations, especially when generating recommendations for complex and partly contradictory multi-problem cases. If you find an error in the recommendations, please let me know. I always strive to improve the quality of my software.

## How it works

"Setup Advisor" uses the same rule engine, that is used by the Virtual Race Assistants. A generic set of rules handle the overall computation and the analysis of the problem descriptions given by the driver. Each problem is identified by a descriptor, for example "Understeer.Corner.Exit.Fast" for understeering while accelerating out of fast corners. For each setup option, a descriptor exists as well, for example "Bumpstop.Range.Front.Left" for the length of the bumpstop rubber in the front left spring damper.

During the first phase, the rule engine analyses all given problems and their "Importance" and "Severity" settings. A resulting correction value is derived, while handling contradictory requirements. The a long list of rules are evaluated that look like this:

	[?Understeer.Corner.Exit.Fast.Correction != 0] =>
			(Prove: changeSetting(Electronics.TC, -0.5, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Aero.Wing.Rear, -0.5, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Aero.Wing.Front, 1, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Aero.Splitter.Front, 1, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Aero.Height.Rear, 0.5, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Aero.Height.Front, -0.5, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Differential.Preload, 0.5, ?Understeer.Corner.Exit.Fast.Correction))

	{All: [?Understeer.Corner.Exit.Fast.Correction != 0], [?Understeer.Corner.Exit.Fast.Value > 50]} =>
			(Prove: changeSetting(Bumpstop.Range, [Front.Left, Front.Right], 1, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Bumpstop.Rate, [Front.Left, Front.Right], -1, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Bumpstop.Range, [Rear.Left, Rear.Right], -0.5, ?Understeer.Corner.Exit.Fast.Correction)),
			(Prove: changeSetting(Bumpstop.Rate, [Rear.Left, Rear.Right], 0.5, ?Understeer.Corner.Exit.Fast.Correction))

As you can see, these rules define the changes to be applied to the setup settings to compensate for a specific problem, fast corner exit understeer in this example. It is self-explanatory, that a lot of settings might be influenced by many applicable rules at the same time. The generic rule set of "Setup Advisor" will handle this by computing the resulting setting as the best possible compromise for all resulting changes.

## Managing Car Setups

After you have described your problems and reviewed the recommendations of "Setup Advisor", you may either change the settings directly in your simulator, or you can load the respective setup file for the given car and let "Setup Advisor" handle the modifications. To do this, click on the button with the little car on the right side of the *Selection* area. This will open a second window which allows you to work with setup files. If you do this for the first time, you first have to find and load the respective setup file, which will be used as the base setup for all modifications. Once you have loaded this file, the following window opens:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/Development/Docs/Images/Setup%20Editor%201.JPG)

On the right side, you will see the simulator specific content of the setup file, in this case a setup for *Assetto Corsa Competizione* in a JSON format. In the list on the right, all settings known to "Setup Advisor", which are valid for the currently selected simulator and car will be listed together with their values from the currently loaded setup file. You can select a setting in this list and change its value using the "Increase" or "Decrease" button. Much more interesting is the "Apply" button below. When you click this button, all recommendations of the "Setup Advisor" will be applied as balanced changes to the currently loaded setup. You can specify with the small slider to the right of the button the amount of the applied changes, thereby filtering small and possibly unneccessary changes. You will then see a list like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/Development/Docs/Images/Setup%20Editor%202.JPG)

Using the checkboxes on the left side of each setting, you can control which modifications will be included in the modified setup and which are not. The changes will also be reflected in the internal format at the right, but this is more for documentary purposes. Once you have reviewed, chosen and possibly corrected some of the modifications, you can press the "Save..." button to save everything to a new setup file. Or you can use the "Reset" button to start over again.

Note: The *Setup Editor* is currently only available for *Assetto Corsa* and *Assetto Corsa Competizione*. More simulators might be supported with future releases. Please see the [notes section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Advisor#notes) down below.

## Comparing Car Setups

Beside applying selected recommendations for handling problems to a given setup, "Setup Advisor" is also able to compare two given setups and can also *merge* setups, for example a setup for dry conditions with a setup for wet conditions to create some kind of hybrid setup for endurance races. To do this, first load one setup into the *Setup Editor* as described above, and then click the "Compare..." button. You will be asked to load a second setup, which then will be compared to the first one. The differences will be shown in the following window.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/Development/Docs/Images/Setup%20Editor%203.JPG)

The orginal setup will be named "Setup A" and the second will be named "Setup B" here. Beside only investigating the differences betweeen the two setups, you can also create a *merged* setup, name "Setup A/B". Use the slider in the lower middle of the window, to balance the weight of the two orginal setups for the settings in the merged setup. You can also use the two "Decrease" and "Increase" buttons, to change individual settings in the "Setup A/B".

When you want the merged setup to be taken over to the *Setup Editor*, when you are finished, click on the "Apply" button, otherwise close the window using the "Close" button.

## Extending and cutomizing "Setup Advisor"

As you might have noticed, the "Setup Advisor" implements a quite generic, but also to a large extent general approach to car handling problems. But it is also possible to introduce simulator specific or even car specific rules for the AI processing and you can also describe the car specific settings, their ranges and rules for reading and modifying setup files. All builtin definitions and rules can be found in the *Resources\Advisor\Definitions* and in the *Resources\Advisor\Rules* folder in the program directory. But you can introduce their own versions of these files or even new ones in the *Simulator Controller\Advisor* folder in your user *Documents* folder. You can use the definition and rule files which are located in the programm directory as a template when creating your own files.

Although it is possible to introduce support for a completely new simulator, much more common is the addition of a new car. Every simulator will support a so called generic car, with all setup settings supported by this simulator. Also, the Setup Editor will handle this generic car, but almost all settings will be handled a simple "clicks" without restricting the changes to a known range. This information is provided by the so called car definition files and the car specific rules.

### Introducing new car specifications

Each simulator comes with a set of default settings which will be available for all cars. A specific car might restrict or change this set by using a car specific rule file. Let's start with a simple example:

	[?Initialize] => (Prove: removeSetting("Assetto Corsa Competizione", "McLaren 720s GT3", Aero.Splitter.Front))

This rule removes the front splitter setting from the set of available settings in *Assetto Corsa Competizione* for the "McLaren 720s GT3" upon initialization of the rule set, since this car does not have an adjustable front splitter.

Car specific rules are either located in the *Resources\Advisor\Rules\Cars* folder in the program directory or in the *Simulator Controller\Advisor\Rules\Cars* folder which is located in your user *Documents* folder. These files must implement the following naming scheme:

	[Simulator].[Car].rules

with [Simulator] and [Car] substituted by the specific names.

These rules are loaded and activated, when you select a specific car in "Setup Advisor". In most cases, the car specific rules will alter the set of available car settings, but it is also possible to modify, add or remove rules for the problem analysis as described above.

Here is a much longer example for the "Porsche 992 GT3 Cup" which follows a very minimalistic approach, when it comes to car setup possibilities:

	[?Initialize] => (Prove: removeSettings("Assetto Corsa Competizione", "Porsche 992 GT3 Cup",
				[Electronics.TC, Aero.Splitter.Front,
				 Spring.Rate.Front.Left, Spring.Rate.Front.Right,
				 Spring.Rate.Rear.Left, Spring.Rate.Rear.Right,
				 Bumpstop.Rate.Front.Left, Bumpstop.Rate.Front.Right,
				 Bumpstop.Rate.Rear.Left, Bumpstop.Rate.Rear.Right,
				 Bumpstop.Range.Front.Left, Bumpstop.Range.Front.Right,
				 Bumpstop.Range.Rear.Left, Bumpstop.Range.Rear.Right,
				 Damper.Compression.Slow.Front.Left, Damper.Compression.Slow.Front.Right,
				 Damper.Compression.Slow.Rear.Left, Damper.Compression.Slow.Rear.Right,
				 Damper.Compression.Fast.Front.Left, Damper.Compression.Fast.Front.Right,
				 Damper.Compression.Fast.Rear.Left, Damper.Compression.Fast.Rear.Right,
				 Damper.Rebound.Slow.Front.Left, Damper.Rebound.Slow.Front.Right,
				 Damper.Rebound.Slow.Rear.Left, Damper.Rebound.Slow.Rear.Right,
				 Damper.Rebound.Fast.Front.Left, Damper.Rebound.Fast.Front.Right,
				 Damper.Rebound.Fast.Rear.Left, Damper.Rebound.Fast.Rear.Right,
				 Differential.Preload, AntiRollBar.Rear]))

Beside the rules, which influence the way, the "Setup Advisor" analyses your handling problems, a so called definition file describe the car settings, their units and value ranges in more detail for the Setup Editor. These files are located in the *Resources\Advisor\Definitions\Cars* folder in the program directory or in the *Simulator Controller\Advisor\Definitions\Cars* folder which is located in your user *Documents* folder. These files must implement the following naming scheme:

	[Simulator].[Car].ini

with [Simulator] and [Car] substituted by the specific names.

Here is an extract from the definition file for the "McLaren 720s GT3":

	[Setup.Settings.Handler]
	Brake.Balance=FloatHandler(47.0, 0.2, 1, 47.0, 68.0)
	Brake.Duct.Front=ClicksHandler(0, 6)
	Brake.Duct.Rear=ClicksHandler(0, 6)
	Aero.Height.Front=IntegerHandler(50, 1, 50, 80)
	Aero.Height.Rear=IntegerHandler(64, 1, 64, 105)
	Aero.Wing.Rear=IntegerHandler(1, 1, 1, 8)
	Geometry.Toe.Front.Left=FloatHandler(-0.48, 0.01, 2, -0.48, 0.44)
	Geometry.Toe.Front.Right=FloatHandler(-0.48, 0.01, 2, -0.48, 0.44)
	Geometry.Toe.Rear.Left=FloatHandler(-0.1, 0.01, 2, -0.1, 0.4)
	Geometry.Toe.Rear.Right=FloatHandler(-0.1, 0.01, 2, -0.1, 0.4)
	...
	[Setup.Settings.Units.DE]
	Brake.Balance=% Vorne
	Aero.Height.Front=mm
	Aero.Height.Rear=mm
	Geometry.Toe.Front.Left=Grad
	Geometry.Toe.Front.Right=Grad
	Geometry.Toe.Rear.Left=Grad
	Geometry.Toe.Rear.Right=Grad
	...
	[Setup.Settings.Units.EN]
	Brake.Balance=% Front
	Aero.Height.Front=mm
	Aero.Height.Rear=mm
	Geometry.Toe.Front.Left=Degrees
	Geometry.Toe.Front.Right=Degrees
	Geometry.Toe.Rear.Left=Degrees
	Geometry.Toe.Rear.Right=Degrees
	...

The most important part is the "[Setup.Settings.Handler]" section. Here you specify a special handler for each setting, which manages this specific setting. If you don't supply a handler for an active setting of the given car, a default *ClicksHandler* with an unrestricted range will be active. You can also supply *false* as a handler, which means that this setting will be unavailable. The following handlers are available:

  - **RawHandler(increment, minValue, maxValue)**
  
    This handler implements a range of numbers. The valid range of setting values goes from minValue to maxValue with each step defined be *increment*. The values will be used as such in the underlying simulator specific setup file.

  - **ClicksHandler(minValue, maxValue)**
  
    Available values for this setting range from *minValue* to *maxValue* and are incremented by **1**. *minValue* and *maxValue* must be both integers.

  - **IntegerHandler(baseValue, increment, minValue, maxValue)**
  
    This handler implements a more complex range of natural numbers. All supplied values must be integers. The valid range of setting values goes from minValue to maxValue with each step defined be *increment*. *baseValue* will be used as the anchor, which corresponds to **0** in the underlying simulator specific setup file. Each step will correspond to an increment by **1** in the underlying raw value.

  - **DecimalHandler(baseValue, increment, precision, minValue, maxValue)**
  
    Similar in behaviour to the *IntegerHandler*, but uses floating point numbers. *precision* defines, how many places after the decimal point are considered and displayed. *FloatHandler* can be used as well, as it is synonym to *DecimalHandler*.
	
	Example:
	
		DecimalHandler(0, 0.1, 1, -3.5, 0.1)
	
	will create a continuous range of -35 to 1 in the simulator specific setup file, where -35 equals the display value -3.5 and 1 equals the display value 0.1.

The sections "[Setup.Settings.Units.DE]" and "[Setup.Settings.Units.EN]" and so on allow you to supply language specific unit labels for all the settings. If an entry is missing for a given setting, the label will be "Clicks" (or a corresponding translation).

### Introducing new simulators

Most of the stuff we talked about so far is independent of a specific simulator, since all of them store the setups more or less in the same way - as numbers. The file format, though, is very different. As you have seen above, the setups are stored as a JSON file in *Assetto Corsa Competizione*. INI files are supported for *assetto Corsa*. Therefore, let's take a look into the simulator specific configuration.

Similar to cars, each simulator has a definition file which is located in the *Resources\Advisor\Definitions* folder in the program directory. You can add your own, as mentioned above, by adding them to *Simulator Controller\Advisor\Definitions* folder in your local *Documents* folder. A rule file for a given simulator is also available, which is located (I think you can guess it) in the *Resources\Advisor\Rules* folder in the program directory. You can also add your own here by adding them to *Simulator Controller\Advisor\Rules* folder in your local *Documents* folder.

"Setup Advisor" scans both directories at startup and compiles the list of available simulators. Let's now take a look at the simulator specific configuration.

### Assetto Corsa Competizione

The access paths for the JSON-based setup files of *Assetto Corsa Competizione* are stored in the *Assetto Corsa Competizione.ini* file. Here is excerpt from this file:

	[Simulator]
	Simulator=Assetto Corsa Competizione
	[Setup]
	Editor=ACCSetupEditor
	Comparator=ACCSetupComparator
	Type=JSON
	[Setup.Settings]
	Electronics.TC=basicSetup.electronics.tC1
	Electronics.ABS=basicSetup.electronics.abs
	Brake.Pressure=advancedSetup.mechanicalBalance.brakeTorque
	Brake.Balance=advancedSetup.mechanicalBalance.brakeBias
	Brake.Duct.Front=advancedSetup.aeroBalance.brakeDuct[1]
	Brake.Duct.Rear=advancedSetup.aeroBalance.brakeDuct[2]
	...

As you can see, the approach is quite simple, since the structure of the JSON-based setup file is very similar to the internal storage format, which is used by "Setup Advisor".

## Notes

  1. Only *Assetto Corsa* and *Assetto Corsa Competizione* are supported at the moment, when it comes to editing, comparing and saving setup files. Other simulators might follow with future releases, but a first investigation has shown that setup file handling and - even more important - setup file format is rather cryptic and undocumented in other simulators.
  2. The implementation for *Assetto Corsa Competizione* provides a generic car model and a couple of very detailed car specifications at the moment. More will be added in the future. If you don't find your favorite car, please feel free to implement the car definition and rules files (takes a couple of minutes, see the description in the previous section). I will be happy to add your car to the package as a community contribution.
  3. The implementation for *Assetto Corsa* currently only provides only a generic car model and one detailed car model as an example at the moment. Other detailed car models will be added over time. If you don't find your favorite car, please feel free to implement the car definition and rules files (takes a couple of minutes, see the description in the previous section). I will be happy to add your car to the package as a community contribution.
  4. Last but not least, specifications for specific car models are missing as well at the moment for all other simulators, only a generic car is supported here. But only those settings, which are actually available in a given simulator, are used by "Setup Advisor". 