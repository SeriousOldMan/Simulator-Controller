## Introduction

Elisa, the Virtual Race Spotter is a part of the Race Assistant family of Simulator Controller. As a spotter, Elisa watches over your car and all the cars around you. Elisa will warn you about critical situations, for example, when a car appears in your blind spot, or when a car is chasing you from behind. Furthermore, Elisa will inform you periodically about other aspects of the traffic around you, for example, when one of the leading cars is closing in from behind and you are getting a blue flag.

Please note, that this is the first release of Elisa. Only ACC is supported and much of the planned functionality is still missing. But the general proximity calculations are all there and Elisa will give you all critical information about the nearby cars. The functionality will be completed with the next releases and support for other simulations will be introduced as well.

Since Elisa does not support any voice commands yet, it will be best to provide *false* for *raceAssistantListener*, so that Elisa does not interfere with voice commands for Jona and/or Cato. So you can use the following plugin arguments for the plugin in "Simulator Configuration" for the moment:

    raceAssistant: On; raceAssistantName: Elisa; raceAssistantSpeaker: true; raceAssistantListener: false

To be continued...