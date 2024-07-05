## Introduction

Several applications of Simulator Controller, most notably the Virtual Race Assistants, exhibit a kind of *intelligence* in the sense, that they are able to understand a given situation or a set of information provided by the user and then they use a reasoning process to recommend an appropriate action or at least recommend a reasonable action. All applications have access to a custom build Hybrid Rule Engine to implement these capabilities. This rule engine supplies forward chaining capabilities similar to the famous OPS5 as well as a first-order logic programming language very similar to Prolog. Both have acces to a shared knowledge base and can work in conjunction on a given goal.

The rule engine can handle thousands of rules and execute them efficiently. Forward chaining rules (also named productions) are arranged in a so called [Rete network](https://en.wikipedia.org/wiki/Rete_algorithm) so that only rules are considered for execution, for which the incoming facts in the condition part has been changed since the last execution. Efficient execution of the backward chaining rules (als called reductions) is secured by a compiler which create an execution pseudo code which then can be efficiently execute incl. proper tail-recursion optimization.

Okay, enough tech babble. Before going more into the details, let's take a look at a concrete example.

### Example: Calculating required refuel amount

The following rules are used by the Jona, the Race Engineer to calculate the amount of fuel that needs to be added at the next pitstop. This is done each lap and the result is used in many other rules, for example, when planning and preparing a pitstop.

	{Any: [?Lap], {None: [?Fuel.Amount.Target]}} =>
			(Prove: updateFuelTarget(?Lap))

	updateFuelTarget(?lap) <=
			lapAvgConsumption(?lap, ?avgConsumption),
			lapRemainingFuel(?lap, ?remainingFuel),
			remainingSessionLaps(?lap, ?remainingLaps),
			?sessionFuel = ?avgConsumption * ?remainingLaps,
			safetyFuel(?avgConsumption, ?safetyFuel, false),
			?neededFuel = ?sessionFuel + ?safetyFuel,
			?neededFuel > ?remainingFuel,
			?refillAmount = ?neededFuel - ?remainingFuel,
			min(?refillAmount, !Session.Settings.Fuel.Max, ?temp),
			max(0, ?temp, ?adjustedRefillAmount),
			Set(Fuel.Amount.Target, ?adjustedRefillAmount), !
			
	updateFuelTarget(?lap) <=
			Clear(Fuel.Amount.Target)

The first rule is a forward chaining rule. It takes information from the current state of the knowledge base and checks whether specific conditions are matched. If this is the case, a forward chaining rule can execute any number of actions, thereby potentially chaning the knowledge base and triggering other rules.

	{Any: [?Lap], {None: [?Fuel.Amount.Target]}} =>
			(Prove: updateFuelTarget(?Lap))

In this case, the condition first checks whether **Lap** fact has been changed in the knowledge base, which happens aall the time, when the driver crosses the start/finish line. Alternativly, the condition is also met, if there is no fact named **Fuel.Amount.Target** known in the knowledgebase. The only action fired by this production rule is to *call* the backward chaining engine to compute and update the fuel target. This is achieved by the action "(Prove: updateFuelTarget(?Lap))".

The *updateFuelTarget* reduction rule actually consists of two rules. The first rule looks at the average consumption, the fuel capacity of the car, the number of remaining laps in the session, and so on, to decide whether refueling is necessary. If this is the case (checked by "?neededFuel > ?remainingFuel") the fact **Fuel.Amount.Target** is created in the knowledge base with the calculated refuel amount as value. The second rule is called, when the first does not succceed, which is the case, if the remaining fuel is enough for the remaining session, or if no average consumption is known, and so on. The fact **Fuel.Amount.Target** is removed from the knowledge base, thereby indicating that refueling is not necessary or not possible at the moment.

## Rule Engine Overview

As said in the introduction the rule engine stands on three different pillars, the knowledge base, a set of production rules and a set of reduction rules. Let's take a look at each of these.

### Knowledge Base

The state of the knowledge base is a collection of facts known at a specific point in time. Rules are allowed to read from and write to the knowledgebase, i.e. they can create or delete facts, and the can alter the value of a given fact.

#### Facts

### General Syntax

Both production and reduction rules share common snytax rules.

#### Literals

Literals are represented as a sequence of characters. They can contain almost any character except the paranthesis "{[()]}", the vertical bar "|", a white space character, or a comma ",". If a literal should contain one of these characters, it must be enclosed in single or double quotes or the character must be escaped using a backslash "\". Examples:
   
	foo
	bar1
	Lap.Remaining
	"This is a string"
	This\ is\ also\ a\ string
	24/7
	24.7
   
   1. Numbers

      Literals that represent numbers are all literals which start with a number and adhere to the typical format of a number. Examples: 5, 5.1, 5.47e+2

   2. Variables

      Variables are special literals that start with a question mark. Example: ?CurrentLap
   
      Although it is possible to create a variable which starts with a number like *?42*, this is not recommended.

   3. Facts

      Facts are identified by special literals that start with an exclamation mark. Example: !Tyre.Compound.Target
   
   4. Strings

      Strings are all literals, that are not numbers, variables or facts. An interesting aspect here is, that strings in the rules must not be enclosed in quotes, as long as they do not contain characters.

#### Expressions

Rules are made up of expressions. Expressions are complex structures composed of literals and additional syntactical elements, for example operators. Examples:

	?a = 5
	?a = ?b + 4
	{Predicate: [?Tyre.Pressure.Average > 27.0]}
	[1, 2, 3 | Foo]
	grandFather(Peter, Paul)
  
The different types of expressions are discussed below. Expressions are not (yet) fully composable, i.e. each element of an expression cannot be a general expression by itself. This is also discussed below.

### Production Rules (forward chaining)

#### Variables

Variables are 

#### Conditions

#### Actions

### Reduction Rules (backward chaining)

#### Predicates

#### Unification

#### Cut and Fail

## Integration with GPT and LLMs