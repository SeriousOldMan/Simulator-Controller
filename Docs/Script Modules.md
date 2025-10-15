This documentation provides reference information for all modules which are available to include in *Lua* scripts. These modules can be used to interface with the simulator and provide information about the current session. The modules can be loaded into any script which is used to implement an action for an [Assistant booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) as described [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions). Use the "require" function to load a given module, which then defines some global objects which provide the specific properties and functions. which in turn keeps the namespace clean. Example:

	require("Session")

After the module references, several examples are provided which demonstrate some of the provided functionality.

## Module *Simulator*

This module defines two functions, which allows you to read data from the simulation and also send some data to the simulator or activate commands for the simulator, if supported.

### Topics

Only one topic is defined, which is named "Simulator". It defines the following functions:

| Function | Arguments                      | Description |
|----------|--------------------------------|-------------|
| Read     | simulator, car, track          | Returns the full set of data provided by the *simulator* for the given *car* and *track* combination. The data is returned as string coded in "INI" format as [described in the Assistants documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#telemetry-integration). |
| Call     | simulator, command             | Sends the given command to the simulator. See the examples below to see some of the available commands. |

## Module *Session*

The "Session" module for the integrated script engine defines three global objects (named topic in the following documentation), which can be used to access important information about the current session.

### Topics

In the following sections you will find an overview for all objects. Please note that not every property may be available for all simulators or that individual properties will have individual value ranges for a specific simulator.

#### Session

The *Session* topic gives you access to the overall state of the current session. *Session* provides the following properties (please note, that *Lua* ia a case-sensitive language):

| Property      | Description |
|---------------|-------------|
| Active        | Is *true*, a simulation is running and a session is currently active. Only if this is *true*, all other properties described below will have a meaningful value. Accessing them may even raise an error, if accessed, if *Active == false*. |
| Simulator     | The name of the currently active simulator. |
| Car           | The name of the car in use in the currently active session. |
| Track         | The name of the track in use in the currently active session. |
| Type          | The type of the currently active session. This will be one of "Practice", "Qualifying", "Race", "Time Trial" and "Other". |
| Format        | The value of this property is either "Time" or "Laps". |
| RemainingLaps | The number of laps in the current session. In "Time"-based session this value is based on the average lap time. |
| RemainingTime | The remaining time of the current session. In "Laps"-based session this value is based on the average lap time. |
| Data          | This property gives you access to the internal data represenation of the current session state. It is a string in "INI" format as [described in the Assistants documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#telemetry-integration). Using this property is almost identical to calling the *read* function of the "Simulator" module, but since this information is processed asynchronously, it may be a few seconds *old*. |
| Knowledge     | This property returns a JSON object, which is also passed to a LLM of a *Conversation* booster. An example for the structure and contents of this object can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#conversation-booster). |

#### Stint

The *Stint* topic provides a couple of properties which rerpesents real-time data of the currently running stint:

| Property      | Description |
|---------------|-------------|
| Driver        | The name of the driver of the current stint. |
| Lap           | The current lap. |
| Sector        | The number of the current sector, if available by the simulator. |
| Laps          | The number of laps that have already been run in the current stint. |
| RemainingLaps | The number of laps remaining for the current stint. This is either restricted by the available fuel or by the remaing time available for the stint or even the driver. |
| RemainingTime | The remaining time for the current stint. This is either restricted by the available fuel or by the remaing time available for the stint or even the driver. |
| LastTime      | The lap time in seconds of the last lap in the stint. |
| BestTime      | The lap time in seconds of the best lap in the stint. |
| Conditions    | This property returns an object with the following properties:<br><br>1.*weather* = "Dry", "Drizzle", "LightRain", "MiddleRain", "HeavyRain" or "Thunderstorm"<br>2. *air_temperature* = air temperature in Celsius<br>3. *track_temperature* = track temperature in Celsius<br>4.*weather_10_min* = weather forecast in 10 minutes<br>5.*weather_30_min* = weather forecast in 30 minutes<br>6.*grip* = "Dusty", "Old", "Slow", "Greasy", "Damp", "Wet", "Flooded", "Green", "Fast" or "Optimum" |
| Car          | Returns a structured object which represents the current state of the car. It has the following properties:<br><br>1.*tyres* = an object with 4 properties (*front_left* up to *rear_right*) each of which has the properties *compound*, *pressure*, *temperature* and *wear*<br>2. brakes = an object with 4 properties (*front_left* up to *rear_right*) each of which has the properties *temperature* and *wear*<br>3. *fuel_consumption* = the average fuel consumption in liters for the last laps<br>4.*remaining_fuel* = the currently remaining fuel in liters<br>5.*damage* = an object with the properties *bodywork*, *suspension* and *engine* each of which holding a number representing the current damage respectively<br><br>Please note, that this property is only available in scripts which are defined for the Race Engineer. |

#### Standings

This topic gives you access to the current standings including information about all opponents. This information is only available in scripts which have been defined for either the Race Strategist, the Race Spotter or the Driving Coach.

| Property        | Description |
|-----------------|-------------|
| OverallPosition | The current overall position in the grid. |
| ClassPosition   | The current position in the standings for the class of the car. |
| Position        | Synonymous for *OverallPosition*. |
| Standings       | Returns the full table of standings, sorted by the overall position. It contains objects for each car with the following properties::<br><br>1.*overallPosition* = the current overall position<br>2.*classPosition* = the current position with regards to the class-specific standings<br>3.*car* = the car in this position<br>4.*nr* = the race number of the car in this position<br>5.*driver* = the name of the driver in this position<br>6.*laps* = the number of laps the car in this position already has driven<br>7.*time* = the last lap time of the car in this position |

## Module Assistants

The "Assistants" module which can be used in scripts started from the controller action function [*execute*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) or started as action in the currently active [track automation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-automations).

### Topics

Only one topic is defined, which is named "Reasoning". It defines the following functions:

| Function      | Arguments                                  | Description |
|---------------|--------------------------------------------|-------------|
| RaiseEvent    | assistant, event, [Optional] arguments...  | Raises *event* in the *Reasoning* booster of the given *assistant*. Any number of arguments can be supplied as defined for the given *event*. See the documentation on [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information. |
| TriggerAction | assistant, action, [Optional] arguments... | Triggers *action* in the *Reasoning* booster of the given *assistant*. Any number of arguments can be supplied as defined for the given *action*. See the documentation on [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information. |

## Examples

Following you will find several examples which demonstrate the usage of the "Session" module.

### Controlling the fuel ratio in *Le Mans Ultimate*

This example demonstrates a conversation action which let you control the fuel ratio using a voice command like "Can you set the fuel ratio to 94 percent."

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Session%20Module%20Example%201.jpg)

This example demonstrates many techniques to interface to a simulator. *Le Mans Ultimate* provide an HTTP-based API for which you can get the documentation uing a Swagger page while the simulator is running. With regards to the "Session" module, only the property *Session.Simulator* is used to make sure, that *Le Mans Ultimate* is actually running, before calling the HTTP API. Here is the full code:

	-- Action:      set_fuel_ratio
	-- Activation:  "Can you set the fuel ratio to 94 percent."
	-- Description: Call this, if the driver wants to assign a new value to the fuel ratio.
	-- Parameters:  1: Name: newRatio
	--                 Type: Number
	--                 Required: Yes
	--                 Description: Represents the new value for fuel ratio. Must be a fractional value between 0 and 1. 

	require("Session")

	if Session.Simulator == "Le Mans Ultimate" then
		local JSON = require("lunajson")
		local httpGet = extern("httpGet")
		local httpPost = extern("httpPost")

		function lookup(data, name)
			for ignore, candidate in ipairs(data) do
				if candidate.name == name then
					do return candidate end
				end
			end
					
			return false
		end

		function round(value, places)
			local mult = 10 ^ (places or 0)

			return math.floor(value * mult + 0.5) / mult
		end

		local pitstop = JSON.decode(httpGet("http://localhost:6397/rest/garage/PitMenu/receivePitMenu"))
		local ratio = lookup(pitstop, "FUEL RATIO:")

		if ratio then
			local value = round(%newRatio%, 2)
		 
			for index, candidate in ipairs(ratio.settings) do
				candidate = tonumber(candidate.text)

				if index == 1 and value < candidate then
					ratio.currentSetting = 0
					
					break
				elseif value == candidate or index == (#ratio.settings - 1) then
					ratio.currentSetting = (index - 1)
				
					break
				end
			end

			httpPost("http://localhost:6397/rest/garage/PitMenu/loadPitMenu", JSON.encode(pitstop))
		else
			Assistant.Speak("This is not possible right now!")
		end
	else
		Assistant.Speak("Are you kidding?")
	end

### Choosing service for selected tyres / axles

This example demonstrates simulator specific coding of pitstop service requests. It represents an action which can be used to fulfill a driver command to the Engineer like "Do not change the tyres at the front axle." As you can see by the script, support is available for *Le Mans Ultimate*, *rFactor 2* and *iRacing*. A similar action for controlling the change of the rear tyres can be defined accordingly.

	-- Action:      no_front_tyre_change
	-- Activation:  "Do not change the tyres at the front axle."
	-- Description: Call this, if the driver do not want to change the front tyres at the next pitstop.
	-- Parameters:  -

	require("Session")
	require("Simulator")

	if Session.Simulator == "Le Mans Ultimate" then
		local JSON = require("lunajson")
		local pitstop = JSON.decode(extern("httpGet")("http://localhost:6397/rest/garage/PitMenu/receivePitMenu"))

		function lookup(data, name)
			for ignore, candidate in ipairs(data) do
				if candidate.name == name then
					do return candidate end
				end
			end
					
			return false
		end

		local tire = lookup(pitstop, "FL TIRE:")

		if tire then
			tire.currentSetting = 0

			lookup(pitstop, "FR TIRE:").currentSetting = 0

			extern("httpPost")("http://localhost:6397/rest/garage/PitMenu/loadPitMenu", JSON.encode(pitstop))
		else
			Assistant.Speak("Cannot do this right now!")
		end
	elseif Session.Simulator == "rFactor 2" then
		Simulator.Call("rFactor 2", "Pitstop=Set=Tyre Compound Front:None")
	elseif Session.Simulator == "iRacing" then
		Simulator.Call("iRacing", "Pitstop=Set=Tyre Change Front Left:false")
		Simulator.Call("iRacing", "Pitstop=Set=Tyre Change Front Right:false")
	else
		Assistant.Speak("Are you kidding?")
	end