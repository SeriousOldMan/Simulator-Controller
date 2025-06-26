## Introduction

Hardly anything is as complicated when implementing a general integration of race simulators as the treatment of tyre compounds. Back then, in the good old days of *Assetto Corsa Competizione*, there were Dry tyres and Wet tyres and that was it. The world was easy. But with the continuing integration of additional race simulators, things became more and more complicated. Each car has different tyre categories to choose from and there are such funny identifiers as "Hypercar Road (HR)". No problem if you just need to display them here and there, but the individual Simulator Controller applications need to understand the *meaning* of these tyre compounds. For this reason, the available tyre compounds from the different race simulators are mapped to a normalized set of tyre compounds within Simulator Controller. However, this mapping must be configured individually for each vehicle. This process is described below.

## Compound Rules

Let's start easy, with a compound mapping. A compound rule maps an internal identifier used by a race simulator to identify an individual tyre compound to a corresponding normalized identifier, which is used in all Simulator Controller applications. A compound mapping looks like this:

	Hard->Dry (H)

This maps the compound identifier "Hard" from *RaceRoom Racing Experience* to the identifier "Dry (H)" which is used in Simulator Controller. The set of supported compound identifiers (on the right side of the "->" in the above example) in Simulator Controller is quite long:

	Wet (Black)
	Intermediate (Black)
	Dry (Black)
	Wet (S)
	Wet (M)
	Wet (H)
	Intermediate (S)
	Intermediate (M)
	Intermediate (H)
	Dry (S+)
	Dry (S)
	Dry (M)
	Dry (H)
	Dry (H+)
	Dry (Red)
	Dry (Yellow)
	Dry (White)
	Dry (Green)
	Dry (Blue)

Note: *Black* is used whenever a simulator does not provide different compound mixtures. Currently, this is the case especially for *Assetto Corsa Competizione*, which provides only one dry and one wet tyre compound. These compounds can also be abbreviated by ommitting the "(Black)" suffix, naming them simply "Dry" or "Wet" or "Immediate".

As you probably expect, the list of internal identifiers for a given race simulator (on the left side of the "->" in the above example) is potentially endless. Most of the time, there are more than one tyre compound available for a given car. Potentially the set of available tyre compounds might even vary depending on a given track, but this is a very special case. Let's take a look at two examples with a couple of available tyre compounds:

	Soft->Dry (S);Medium->Dry (M);Hard->Dry (H)
	
	S7M (Soft)->Dry (S);S8M (Medium)->Dry (M);S9M (Hard)->Dry (H);P2M (Rain)->Wet

As you can see, the different tyre compounds are separated by a ";". The first example is for the "Formula RR 90 V10" car in *RaceRoom Racing Experience* and the second example, which maps three different dry and one wet tyre compound, is for the "McLaren 720s GT3" car in *rFactor 2*.

Once a set of tyre compound mappings has been defined, these can be used to describe the available tyre compounds for agiven car. There are several ways to do this.

### Simulator specific Tyre Compound identifiers

A word about the tyre compound identifiers used by the different simulators:

Normally, you can use exactly the name, which is visible in the user interface of the given simulator. If a tyre compound is named "Hypercar Road (HR)" in *Assetto Corsa*, for example, you must use this as internal identifier as well. If this doesn't work as expected, you can take a look in the *.data files you find in the *Simulator Controller\Temp\\[Simulator] Data* folder in your user *Documents* folder, with *[Simulator]* substitued by the short code of a given simulator, for example *AMS2*. Search for "TyreCompoundRaw". This field will contain the internal tyre compound identifier used by the given simulator.

When creating the tyre compound rule as in the examples above, it is **important** that you use the same order as the *internal* identifiiers appear in the Pitstop dialog. Otherwise you will end up with wrong tyres after a pitstop. A notable exception here is *rFactor 2* or *Le Mans Ultimate*, which supports any order, since the API supports tyre compound selection by name. And of course *Assetto Corsa Competizione*, where the two available tyre categories (Dry and Wet) are hardcoded.

A very special case is *Project CARS 2*. The underlying simulation engine does not provide any tyre compound information at all. You may use any identifier here, even the placeholder "*". The system will work with relative offsets to compensate for this deficit.

The situation is a bit different for *Automobilista 2*. Mounted tyre compounds can be identified, but when it comes to set the tyre compound for the next pitstop the tyre compoung must be identified by its index, which means, that the order of the different entries in the tyre compound rule is very important.

### *Tyre Data* files

A special meta data file can be created for each simulator, which contains the tyre compound mappings for a set of cars. Files are provided with the Simulator Controller distribution. These files, which are named "Tyre Data.ini", reside in the *Resources\Simulator Data\\[Simulator]* folder, with *[Simulator]* substitued by the short code of a given simulator, for example *AMS2*. They contain a growing list of car and compound definitions, but they will never be complete, since the list of available cars is simply to large. Here is an example of such a file (in this case for *Assetto Corsa*):

	[Compounds]
	Compounds.1=SemiSlicks (SM)->Dry (M);Street (ST)->Dry (H)
	Compounds.2=Slick SuperSoft (SS)->Dry (S+);Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H);Slick SuperHard (SH)->Dry (H+)
	Compounds.3=Hypercar Road (HR)->Dry (H);Hypercar Trofeo (I)->Dry (M)
	Compounds.4=Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H)
	Compounds.5=Slick Medium (M)->Dry (M)
	Compounds.6=Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H)
	Compounds.7=Slicks (H)->Dry (H)
	[Cars]
	*;*=*->Dry
	ferrari_458;*=Compounds.1
	ferrari_458_gt2;*=Compounds.2
	ferrari_laferrari;*=Compounds.3
	ks_ferrari_f2004;*=Compounds.4
	lotus_exos_125;*=Compounds.5
	ks_mclaren_650_gt3;*=Compounds.6
	ks_abarth500_assetto_corse;*=Compounds.7

The first section which is named "[Compounds]" defines a list of different tyre compound mappings as introduced above. Each list has an identifier, which can be any symbol, on the left side of the "=". This symbol can than be used in the second section, which is named "[Cars]", where the tyre compound mappings are defined for each individual car.

A car rule defines a pattern to identify a car / track combination (where a "*" stands for all possible matches). On the right side of the car rule you can then give a list of tyre compound mappings or reference an identifier of a predefined tyre compound mapping from the first section.

In the above example you see a couple of car specific rules and a *match all* rule "*;*=*->Dry", which is used, when no specific car rule is available. This *match all* rule will map the first compound of the given unknown car to a generic Dry tyre compound. Even if the car has more compounds available, only the first one will be usable in the Simulator Controller applications and it will be named always "Dry".

Here is another example, this time for *rFactor 2*:

	[Compounds]
	GT3=S7M (Soft)->Dry (S);S8M (Medium)->Dry (M);S9M (Hard)->Dry (H);P2M (Rain)->Wet
	F1 2012=Wet->Wet;Intermediate->Intermediate;SuperSoft->Dry (SuperSoft);Soft->Dry (S);Medium->Dry (M);Hard->Dry (H)
	[Cars]
	*;*=*->Dry
	McLaren 720S GT3;*=GT3
	Formula ISI 2012;*=F1 2012

#### Default target pressures

For some simulators, a third section is part of the "Tyre Data.ini" file.

	[Pressures]
	porsche_991_gt3_r;Dry=27.6
	mercedes_amg_gt3;Dry=27.6
	ferrari_488_gt3;Dry=27.6
	...
	porsche_991_gt3_r;Wet=30.1
	mercedes_amg_gt3;Wet=30.1
	ferrari_488_gt3;Wet=30.1
	...

In this section, tyre compound specific target pressures for hot tyres are configured. This information, if available, will be used by various parts of the Simulator Controller suite, for example the Race Engineer, and it will overwrite the information provided in the "Race Settings" (but not values configured in the "Session Database").

### Creating own Compound Rules

In the most likely case, that your preffered cars are not available in the predefined set of tyre compound and car rules, you can create your own ones. There are two different ways to do this.

#### *Tyre Data* files

You can create your own "Tyre Data.ini" files. Use the above examples as a guide line to create your own mappings and store them as "Tyre Data.ini" file in the special *Simulator Controller\Simulator Data\\[Simulator]* folder which resides in your user *Documents* folder, with *[Simulator]* substitued by the short code of the given simulator. When the subfolder for the given simulator does not exist, simply create it. Use the short codes "AMS2", "RF2", "R3E", "IRC", "AC", "PCARS2" and so on.

Please make sure, that you use unique identifiers in the "[Compounds]" section, otherwise you will *overwrite* predefined compounds from the standard files. By the way, this is a possibility to substitute definitions from *standard*, but this is a different story.

Note: Once you have created your own sets of car and tyre compound definitions, you can send them to me. I will incorporate them into the standard distribution with the next release.

#### Settings in the "Session Database"

The other - and to be honest much more convenient - possibility to create a tyre compound mapping for a given car, is by using the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database). Insert a new setting for the car in question and enter the tyre compound mapping as follows:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2012.jpg)

Note: The same is true here, you may want to share your definitions with me, so that I can incorporate them into the standard distribution with the next release.

## Using Tyre Compounds

You may have already wondered what all the nonsense is about. There are different places in Simulator Controller where the information is used.

1. When changing the tyre compound for the next pitstop using one of the controller actions described in [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes), the tyre compound mapping is useed to derive the number of diffent compounds and the correct tyre compound identifier to send to the current simulator, when you choose the next compound.
2. When the pitstop settings are derived by the AI Race Engineer, the same applies.
3. All applications, which let you choose a tyre compound, will also use the available tyre compounds for the currently chosen car. This is especially true for "Strategy Workbench", where the compounds are used in the strategy simulation as well. The "Team Center" also uses the available tyre compounds when preparing a pitstop or to store the driver specific car setups.

As you have seen above, a tyre compound consists of a tyre category (Dry, Intermediate and Wet) and a suffix, which specifies the mixture or hardness of the compound. As you might expect, the tyre category is most important for the behaviour of the tyre in varying conditions, whereas the mixture determine properties like tyre life time.

### Weather and Tyre Compounds

When a tyre compound will be selected for a given weather condition, the following rules apply:

| Weather      | Suitable Category | Optimal Category |
| ------------ | ----------------- | ---------------- |
| Dry          | Dry               | Dry              |
| Drizzle      | Dry, Intermediate | Intermediate (1) |
| Light Rain   | Intermediate, Wet | Intermediate (1) |
| Medium Rain  | Wet               | Wet              |
| Heavy Rain   | Wet               | Wet              |
| Thunderstorm | Wet               | Wet              |

(1) If no Intermediates are available, Dry Tyres will be used in Drizzle conditions and Wet Tyres in Light Rain conditions.

When different mixtures are available for a given tyre type, only the first one will be used in most cases, where the tyre compound is chosen automatically, for example by the Race Engineer. Therefore it is wise, to configure the most suitable mixture in the first place. The same is true for the "Strategy Workbench", unless you limit the number of available tyre sets per mixture and use *Tyre Compound Variation* during the strategy simulation. A notable exception is the pitstop management in "Team Center", where you can manually select the desired tyre compound for the next pitstop.

Looking at the above table, you can understand when and why a tyre change will be recommended by the Race Engineer or when you recalculate the currently active strategy either in the "Team Center" or by instructing the Race Strategist. As long as the currently mounted tyre has a suitable category, no unplanned pitstop will be requested. If you come in for a regular pitstop, the tyre compound with the optimal category will always be chosen, as long as it is available (see note (1)). But in the case, that the currently mounted tyre is not suitable for the current or upcoming weather conditions, an urgent pitstop will be requested and the optimal tyre compound will be chosen, if available.

### Usable life of a Tyre Compound

Depending on the given car and track combination, and also depending on the personal driving style, each tyre compound will have a specific number of laps, after which it will be beneficial to change the tyres. This information is used in the "Stratgy Workbench" and also, if you run a race using *simple* race rules defined in "Race Settings". You can specifiy the default values for the tyre life in the "Session Database" using the "Pitstop: Tyre Compound Usage" setting. The format is as follows:

	Dry (S)->15;Dry (M)->25;Dry (H)->40

where the number specifies the number of laps for which the corresponding tyre compound mixture can be used.

### Default Tyre Compound

The default tyre compouund is "Dry", when no dedicated information is available for a given car. This was the behaviour before the introduction of the tyre compound model. So everything should work as before, when you do nothing, but you may not be able to change the compound for a pitstop.

### Special notes for *Assetto Corsa Competizione*

As already mentioned, the world is easy in *Assetto Corsa Competizione*. Every car has a "Dry" and a "Wet" compound to use. So nothing to do here.

### Special notes for *Project CARS 2*

Unfortunately, this simulator does not provide any information about the currently mounted tyre compound in the data available through the API. So make sure, that you have set the mounted tyre compound with the [*Race Settings*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#tab-session), before you head out onto the track, otherwise you will end up with a wrong compound chosen during the next pitstop, or the control of tyre compounds in the ICM might fail completely.

### Special notes for *iRacing*

Tyre compounds are identified by an integer in *iRacing*. As mentioned above, the order of the tyre compounds in the tyre compound rule therefore must resemble the order of available tyre compounds for the given car. The default compound "Dry" is always available. The most simple rule for a car which provides a dry and a wet compound will typically look like this:

	Dry->Dry (M);Wet->Wet (M)

## Handling of Tyre Compounds on inidividual wheels

All applications of Simulator Controller can handle individual tyre compounds for each wheel. Of course, it depends on the simulator, whether indivdual tyre compounds can be specified. See the following table:

| Simulator                  | Tyre Change           |
| -------------------------- | --------------------- |
| rFactor 2                  | Axle                  |
| Le Mans Ultimate           | Wheel                 |
| iRacing                    | Wheel (1)             |
| RaceRoom Racing Experience | Axle (2)              |
| All other simulators       | All                   |

(1) Individual tyre changes are supported, but all tyres must be of the same compound.

(2) No support for chosen pitstop settings provided in the API, so the understanding of tyre compounds in Simulator Controller is very restricted.

Various apllications like the "Solo Center" or the session info widgets in "System Monitor" display tyre compounds. If the tyre compound is identical for all wheels, only a signle tyre compound will be displayed, otherwise tyre compounds will be shown individually for all four wheels or for the axles, depending on the capabilities of the simulator (see above).

At the time of this writing, tyre changes are planned by the Engineer always for all four wheels with the same tyre compound. This is also true for all pre-calculated or dynamically created strategies handled by the Strategist. But once a pitstop has been prepared, you can change the tyre compound selection or even deactivate a tyre change on a selected wheel altogether using the respective controller actions as documented in [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) or using the in-game controls, and as long as this information is available in the API, the Assistants and all applications like "Solo Center" will notice that and will react accordingly.

Additionally, the information about tyre wear and the number of laps driven on a specific tyre will also be collected and processed for each tyre individually. You can use this information in the "Strategy Workbench", for example, or you can create reports in "Solo Center" or "Team Center" using the information about the number of driven laps.

Important: Whenever a single tyre compound is assumed for the whole car, for example, for a strategy simulation, the current compound of the front left tyre is used.