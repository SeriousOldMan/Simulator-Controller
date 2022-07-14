## Introduction

Hardly anything is as complicated when implementing a general integration of race simulators as the treatment of tyre compounds. Back then, in the good old days of *Assetto Corsa Competizione*, there were Dry tyres and Wet tyres and that was it. The world was easy. But with the continuing integration of additional race simulators, things became more and more complicated. Each car has different tyre categories to choose from and there are such funny identifiers as "Hypercar Road (HR)". No problem if you just need to display them here and there, but the individual Simulator Controller applications need to understand the *meaning* of these tyre compounds. For this reason, the available tyre compounds from the different race simulators are mapped to a normalized set of tyre compounds within Simulator Controller. However, this mapping must be configured individually for each vehicle. This process is described below.

## Compound Rules

Let's start easy, with a compound mapping. A compound rule maps an internal identifier used by a race simulator to identify an individual tyre compound to a corresponding normalized identifier, which is used in all Simulator Controller applications. A compound mapping looks like this:

	Hard->Dry (H)

This maps the compound identifier "Hard" from *RaceRoom Racing Experience* to the identifier "Dry (H)" which is used in Simulator Controller. The set of supported compound identifiers (on the right side of the "->" in the above example) in Simulator Controller is quite long:

	Wet
	Intermediate
	Dry
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

The list of internal identifiers for a given race simulator (on the left side of the "->" in the above example) is potentially endless.

Most of the time, there are more than one tyre compound available for a given car. Potentially the set of available tyre compounds might even vary depending on a given track, but this is a very special case. Let's take a look at two examples with a couple of available tyre compounds:

	Soft->Dry (S);Medium->Dry (M);Hard->Dry (H)
	
	S7M (Soft)->Dry (S);S8M (Medium)->Dry (M);S9M (Hard)->Dry (H);P2M (Rain)->Wet

As you can see, the different tyre compounds are separated by a ";". The first example is for the "Formula RR 90 V10" car in *RaceRoom Racing Experience* and the second example, which maps three different dry and one wet tyre compound, is for the "McLaren 720s GT3" car in *rFactor 2*.

Once a set of tyre compound mappings has been defined, these can be used to describe the available tyre compounds for agiven car. There are several ways to do this.

### *Tyre Data* files

A special meta data file can be created for each simulator, which contains the tyre compound mappings for a set of cars. Files are provided with the Simulator Controller distribution. These files, which are named "Tyre Data.ini", reside in the *Resources\Simulator Data\[Simulator]* folder, with *[Simulator]* substitued by the short code of a given simulator, for example *AMS2*. They contain a growing list of car and compound definitions, but they will never be complete, since the list of available cars is simply to large. Here is an example of such a file (in this case for *Assetto Corsa*):

	[Compounds]
	Compounds.1=SemiSlicks (SM)->Dry (M);Street (ST)->Dry (H)
	Compounds.2=Slick SuperSoft (SS)->Dry (S+);Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H);Slick SuperHard (SH)->Dry (H+)
	Compounds.3=Hypercar Road (HR)->Dry (H);Hypercar Trofeo (I)->Dry (M)
	Compounds.4=Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H)
	Compounds.5=Slick Medium (M)->Dry (M)
	Compounds.6=Slick Soft (S)->Dry (S);Slick Medium (M)->Dry (M);Slick Hard (H)->Dry (H)
	Compounds.7=Slicks (H)->Dry (H)
	[Cars]
	*.*=*->Dry
	ferrari_458;*=Compounds.1
	ferrari_458_gt2;*=Compounds.2
	ferrari_laferrari;*=Compounds.3
	ks_ferrari_f2004;*=Compounds.4
	lotus_exos_125;*=Compounds.5
	ks_mclaren_650_gt3;*=Compounds.6
	ks_abarth500_assetto_corse;*=Compounds.7

The first section which is named "[Compounds]" defines a list of different tyre compound mappings as introduced above. Each list has an identifier, which can be any symbol, on the left side of the "=". This symbol can than be used in the second section, which is named "[Cars]", where the tyre compound mappings are defined for each individual car.

A car rule defines a pattern to identify a car / track combination (where a "*" stands for all possible matches). On the right side of the car rule you can then give a list of tyre compound mappings or reference an identifier of a predefined tyre compound mapping from the first section.

In the above example you see a couple of car specific rules and a *match all* rule "*.*=*->Dry", which is used, when no specific car rule is available. This *match all* rule will map the first compound of the given unknown car to a generic Dry tyre compound. Even if the car has more compounds available, only the first one will be usable in the Simulator Controller applications and it will be named always "Dry".

Here is another example, this time for *rFactor 2*:

	[Compounds]
	GT3=S7M (Soft)->Dry (S);S8M (Medium)->Dry (M);S9M (Hard)->Dry (H);P2M (Rain)->Wet
	F1 2012=Wet->Wet;Intermediate->Intermediate;SuperSoft->Dry (SuperSoft);Soft->Dry (S);Medium->Dry (M);Hard->Dry (H)
	[Cars]
	*.*=*->Dry
	McLaren 720S GT3;*=GT3
	Formula ISI 2012;*=F1 2012

### Creating own Compound Rules

In the most likely case, that your preffered cars are not available in the predefined set of tyre compound and car rules, you can create your own ones. There are two different ways to do this.

#### *Tyre Data* files

You can create your own "Tyre Data.ini" files. Use the above examples as a guide line to create your own mappings and store them as "Tyre Data.ini" file in the special *Simulator Controller\Simulator Data\[Simulator]* folder which resides in your user *Documents* folder, with *[Simulator]* substitued by the short code of the given simulator. When the subfolder for the given simulator does not exist, simply create it. Use the short codes "AMS2", "RF2", "R3E", "IRC", "AC", "PCARS" and so on.

Please make sure, that you use unique identifiers in the "[Compounds]" section, otherwise you will *overwrite* predefined compounds from the standard files. By the way, this is a possibility to substitute definitions from *standard*, but this is a different story.

Note: Once you have created your own sets of car and tyre compound definitions, you can send them to me. I will incorporate them into the standard distribution with the next release.

#### Settings in the "Session Database"

The other - and to be honest much more convinient - possibility to create a tyre compound mapping for a given car, is by using the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--session-database). Insert a new setting for the car in question and enter the tyre compound mapping as follows:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Database%2012.jpg)

Note: The same is true here, you may want to share your definitions with me, so that I can incorporate them into the standard distribution with the next release.

## Using Tyre Compounds

You may have already wondered what all the nonsense is about. There are different places in Simulator Controller where the information is used.

1. When changing the tyre compound for the next pitstop using one of the controller actions described in [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes), the tyre compound mapping is useed to derive the number of diffent compounds and the correct tyre compound identifier to send to the current simulator, when you choose the next compound.
2. When the pitstop settings are derived by the Virtual Race Engineer, the same applies.
3. All applications, which let you choose a tyre compound, will also use the available tyre compounds for the currently chosen car. This is especially true for "Strategy Workbench", where the compounds are used in the strategy simulation as well. The "Race Center" also uses the available tyre compounds when preparing a pitstop.

### Default behaviour

The default tyre compouund is "Dry", when no dedicated information is available for a given car. This was the behaviour before the introduction of the tyre compound model. So everything should work as before, when you do nothing, but you may not be able to change the compound for a pitstop.

### Special notes for *Assetto Corsa Competizione*

As already mentioned, the world is easy in *Assetto Corsa Competizione*. Every car has a "Dry" and a "Wet" compound to use. So nothing to do here.

#### *Automobilista 2* and *Project CARS 2*

Unfortunately, these two simulators does not provide any information about the currently mounted tyre compound in the data available through the API. So make sure, that you have set the mounted tyre compound with the [*Race Settings*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#tab-race), before you head out onto the track, otherwise you will end up with a wrong compound chosen during the next pitstop, or the control of tyre compounds in the ICM might fail completely.