## Introduction

Several applications of Simulator Controller, most notably the Virtual Race Assistants, exhibit a kind of *intelligence* in the sense, that they are able to understand a given situation or a set of information provided by the user and then they use a reasoning process to recommend an appropriate action or at least recommend a reasonable action. All applications have access to a custom build Hybrid Rule Engine to implement these capabilities. This rule engine supplies forward chaining capabilities similar to the famous OPS5 as well as a first-order logic programming language very similar to Prolog. Both have acces to a shared knowledge base and can work together on a given goal or task.

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

## Rule Engine

As said in the introduction the rule engine stands on three different pillars, the knowledge base, a set of production rules and a set of reduction rules. Let's take a look at each of these.

### Knowledge Base

The state of the knowledge base is a collection of facts known at a specific point in time. Rules are allowed to read from and write to the knowledgebase, i.e. they can create or delete facts, and the can alter the value of a given fact.

#### Facts

A fact in the knowledgebase is identified by a name, which has the format of a string literal (see below). Since literal strings can contain a dot ".", you can create pseudo objects by using common prefixes by convention. Example:

	Tyre.Set
	Tyre.Pressure.Cold.Front.Left
	Tyre.Pressure.Cold.Front.Right
	Tyre.Pressure.Hot.Front.Left
	Tyre.Pressure.Hot.Front.Right

A fact always has a value, but a special value is used internally to represent an unbound fact. A special predicate **unbound?**, which can be used in conditions of production rules and also in reduction rules to test against unbound facts.

WHen you are running one of the applications, which is using the rule engine, you can always take a look at the knowledge base, by choosing "Debug Knowledgebase" from the "Support" menu in the tray icon of that application. This will create a file named like the application process but with an extension ".knowledge", for example "Race Engineer.knowledge". This file contains a textual representation of the knowledge base and will be constantly update. This will slow down everything, of course.

### Literals, expressions and terms

Both production and reduction rules share common basis types and expression.

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

      Strings are all literals, that are not numbers, variables or facts. An interesting aspect here is, that strings in the rules must not be enclosed in quotes, as long as they do not contain spaces or other characters with a role in the syntax.

#### Expressions

Rules are made up of expressions. Expressions are complex structures composed of literals and additional syntactical elements, for example operators. Examples:

	?a = 5
	?a = ?b + 4
	{Predicate: [?Tyre.Pressure.Average > 27.0]}
	[1, 2, 3 | Foo]
	grandFather(Peter, Paul)
  
The different types of expressions are discussed below. In the implementation of the rule engine, expressions are not (yet) fully composable, i.e. elements of expressions cannot be of any type. This is also discussed below.

Important: Literals and expressions conjunctly are also called *terms* in reduction rules.

##### Lists

A special expression is a list. A list of elements is delimited by the braces "[" and "]":

	[1, 2, 3, 4]
	
The empty list is this of course:

	[]

The "|" seperates the first element of the remaining elements of the list.

	[?firstElement | ?moreElements]
	
Good to know: The following two expressions are equivalent.

	[1, 2, 3]
	[1, 2, 3 | []]

##### Compounds

Another special expression is the *Compound*:

	grandfather(Paul, Peter)

It looks like a function call, but it is a structured object in the first place. Said that, terms are used extensively in reduction roals to represent goals and subgoals and therefore can be treated like a function call in that particular case. More on that later down below.

The name of the structured object, *grandfather* in this case, is called a functor. The number of elements in the structure is called the arity. This will become important if we take a look at unification in reduction rules.

### Production Rules (forward chaining)

A production rule is a triggered by a specific situation in the knowledge base and then executes one or more actions.

Syntax: condition **=>** action1, ..., actionN
	
The left hand side of the rule therefore is an expression which repreusents a condition, followed by a "=>" and the a comma-seperated list of actions. Example:

	{Any: [?Lap], {None: [?Fuel.Amount.Target]}} => (Prove: updateFuelTarget(?Lap)), (Set: Pitstop.Ready, true)

#### Referencing facts in production rules

Facts are referenced in conditions and actions of a production rule by either the **?***fact* notation or by the **!***fact* notation. There is a subtle difference between using a variable, for example **?Lap** or a direct reference, for example **!Lap**.

 - Direct reference
 
   The direct reference of a fact denoted by "!" prefix always uses the value that is currently bound to the fact at the time of the execution of the given part of the rule.
 
 - Variable reference

   The variable reference of a fact denoted by "?" prefix will store the value of the fact at the time of the first usage of the fact in the condition of the rule and then use this value in all subsequent occurences.

This is a subtle difference, but can be helpful, if one of the actions of the rule modifies the fact.   

#### Conditions

The left-hand side of a production rule is evaluated whenever the knowledge base has been changed, i.e. facts has been added, removed or changed. A condition can be as simple as check, whether a fact exists, but they can be composed and can get as complex as needed. All conditions query the knowledge base for known facts and optionally can store the current value of the fact in a variable for later usage, for example in an action.

  - Predicate

    The predicate condition comes in different flavors:

    Syntax: [?Lap] or {Predicate: [?Lap]}

    This condition checks whether the given fact (*Lap* in this case) exists in the knowledge base. The condition will be evaluated, whenever the fact has changed.

    Syntax: [?Tyre.Pressure.Front.Left > ?Tyre.Pressure.Front.Ideal] or {Predicate: ...}

    This predicate compares two values. Allowed operators are **>**, **<**, **=**, **==**, **<=**, **>=**, **!=** and **contains**. Both sides can be facts or literal values (numbers, strings).

    Notes:
      - The operator **=** compares case-insensitive, wherease the operator **==** is case-sensitive.
      - The operator **contains** requires a string literal value for the left side of the comparison. This string is then split by "," and then is checked whether the right side value is contained in the resulting list.

  - Exists Quantor

    Syntax: {Any: Condition1, ..., ConditionN}

    This composite condition is macthed, if at least one of the enclosed conditions is matched. For the special case, that exactly one and only one of the supplied conditions must macth, use:

    Syntax: {One: Condition1, ..., ConditionN}

  - All Quantor

    Syntax: {All: Condition1, ..., ConditionN}

    This composite condition is macthed, if all of the enclosed conditions are matched.

  - Non-Exists Quantor

    Syntax: {None: Condition1, ..., ConditionN}

    This composite condition is matched, if none of the enclosed conditions are matched.
	
  - Prove Quantor
  
	Syntax: {Prove: goal}
  
	Example: {Prove: unbound?(!Driver.Name)}
	
	This is a special one. The condition is matched by invoking the given target in the reduction rule engine. Ultimately, this allows to define new types of conditions and even call the host programming language, as you will see below.

#### Actions

Once the condition of a production rule is matched, all actions on the right-hand side of the rule are executed. The execution happens sequentially. There are several action types available:

  - Call
  
    Syntax / Example: (Call: messageShow("Hello ", !Driver.Name))
	
	This action calls a function in the global namespace of the host programming language. Beside all arguments, an implicit first argument is passed to the function, an object with two properties:
	
	  1. Knowledgebase - an instance of class *Knowledgebase* in the host language.
	  2. RuleEngine - an instance of class *RuleEngine* in the host language.
	
	They can be used to access the internal state of the knowledge base and the current state of execution in the rule engine. It is even possible to invoke the rule engine recursively while processing the action.
	
  - Produce
  
    Syntax / Example: (Prove: updateAverageLapTime(?Lap, [?lastLapTime, ?previousLapTime, testLapTime]))
	
	Very similar to the call action above, but this calls a reduction rule. The passed arguments (either variables or direct references to facts) must be bound at the time of the invocation, but you can also supply aaitional unbound variables which then can be computed by the reduction rule.
	
	Normally, only the first alternative is calculated (see the documentation for reduction rules below for more information on that). If you need to follow all paths of the reduction, you can use the following action syntax.
	
	Syntax / Example: (ProveAll: preparePitstop(?Lap))
  
  - Set
  
    Syntax / Example: (Set: Session.Laps, ?Lap)
	
	Using this action, you can create a fact in the knowledge base or alter the value of an existing one. If you omit the value, the fact is set to *true*.
  
  - Clear
  
    Syntax / Example: (Clear: Session.Laps)
	
	As the name of the action suggests, the fact is clear and effectivly removed from the knowledge base.

#### Order of execution

When more rules are applicable for execution, i.e. their conditions are matched, they will be executed sequentially in the order they appeared in the source code (or in the order they have been created dynamically in the rule engine). Executing one rule may change the execution state of other rules, therefore the order is important.

Sometimes it is important, that a specific rule must be executed before all other rules or after a given set of rules. To keep track of this, all production rules have a priority (default is **0**). You can define the priority of a rule, by precedding the rule with a priority specifier. Example:

	priority: -20, [?Lap] => (Prove: cleanupRecentLaps(?Lap))

This rule is executed *after* all rules with a priority higher than -20 have been executed and no more rules are applicable.

Okay, let's have a break here. Production rules may leave with a somewhat alien feeling, if you have used traditional programming languages until now and have never seen logic programming languages before. Reduction rules are even more weird, I promise.

### Reduction Rules (backward chaining)

At a first look, a reduction rule looks like a function definition with a function signature (called the *head* of the rule) and a (possibly empty) list of function calls to be executed when the rule is called (this part of the reduction rule is called the *tail* of the rule).

Syntax: goal [ **<=** subGoal1, ..., subGoalN ]

If a reduction rule has not tail, this can also be called a clause.

Examples:

	availableTyreCompounds(Dry, S)
	availableTyreCompounds(Dry, M)
	availableTyreCompounds(Dry, H)
	
	updateTyrePressureTarget(?lap, Pressure) <=
		computePressureCorrections([FL, FR, RL, RR], Pressure, ?corrections),
		adjustTargetPressures([FL, FR, RL, RR], ?corrections)

Although reduction rules can be seen as and even be used like functions in traditional programming languages, this is only the simple part of the story. In traditional function calls, the caller normally supplies argument values to all parameters of the function. In first-order logic programming languages it is very often the other way around. Let's see it this way:

  1. You have a goal to be proven, for example, whether a given person is the grandchild of another person.
  2. You *call* a reduction rule to prove this goal.
  3. The reduction rule reduces the goal to a set of simpler goals, which then should be proven.
  4. This process continues until all goals have been proven (which means that the original goal has been proven) or until one of the subgoals cannot be proven (which means that the original goal cannot be proven as well).

And now comes the fancy part:

  5. If more than one rule is available which matches a given goal, the rule engine will follow all alternative paths until the orignal goal has been proven, or no more alternative paths are available. This is called backtracking.
  6. While following the path of alternatives the rule engine will create bindings for variables used in a *call*. This is called **unification** and is discussed in more detail below. On the other hand, if the rule execution has reached a dead end, but there are more alternatives available higher in the chain of execution, all variable bindings up to this point are undone and the execution continues with the alternative.

I promised, it is weird. Let's have a look at a concrete implementation of the grandfather *problem*. Let's assume, we have the following rules: 

	father(Peter, Frank)
	father(Frank, Paul)
	father(Mara, Willy)

	mother(Peter, Mara)
	mother(Frank, Barbara)

	grandfather(?A, ?B) <= father(?A, ?C), father(?C, ?B)
	grandfather(?A, ?B) <= mother(?A, ?C), father(?C, ?B)

The *father* clauses define child / father relationships and the *mother* clauses do the same for mother relationships. So far so easy. The *grandfather* rule is equally easy. A person is the grandfather of another person, if he/she is the father of the mother or the father of that other person. SOund straight-forward, right. And logic programming is like that, but finding the right way to break down complex questions into a set of more simple ones is not always as obvious as in this case.

If you now *call* "grandfather(Peter, Paul)", the rule engine will tell you that this is *true*. Same will be for "grandfather(Peter, Willy)" and "grandfather(Peter, Frank)" will be considered *false*. But you can also ask "grandfather(?grandchild, ?grandfather)" which will give you all valid alternatives.

Nice and quite easy to understand, right? Let's move on to a more complex example:

	reverse([], [])
	reverse([?H | ?T], ?REV) <= reverse(?T, ?RT), concat(?RT, [?H], ?REV)

	concat([], ?L, ?L)
	concat([?H | ?T], ?L, [?H | ?R]) <= concat(?T, ?L, ?R)

These rules can concatenate and revers lists. A list of elements is delimited by the braces "[" and "]" and the "|" seperates the first element of the remaining elements of the list. Let me try to translate the **reverse** rules into natural language:

1. reverse([], [])

   An empty list always reverses to an empty list, of course.

2. reverse([?H | ?T], ?REV) <= reverse(?T, ?RT), concat(?RT, [?H], ?REV)

   Any list can be reversed, if you remove the first element, then reverse the rest of the list and the concatenate the first element at the end of that list. Also quite understandable, but that is all.

Can you figure out how **concat** works on your own now?

The *reverse* rule can now be used in many different ways. Of course, you can *call* it with a given list and you will get the reversed list as result. But you can also *call* it with two lists, and the *call* will only succeed, if one is the reverse ot the other. Or you can *call* it with two unbound variables, and the rule engine will create an infinite stream of lists and their reversed counterparts with anonymous variables as elements. Funny, eh?

By the way, reversing lists with the rules used above is not very efficient, but easy to explain. Therefore this example.

#### Goals

As introduced above, a goal in a reduction is a compound like "grandfather(?a, Paul)". When a goal is to be proved by the rule engine, all reduction rules with the same functor (i.e. same name) and the same arity (i.e. same number of arguments) are selected and then tested in the order of their definition. A rule is considered to be applicable when its head can be unified with the goal (see below). If this is the case, the rule engine will now try to prove all goals from the tail of the selected rule, in order to prove the original goal.

A goal can be as simple as

	grandfather(?a, ?b)
	
or as complex as

	historicPressures(?lap, [hot(?hfl, ?hfr, ?hrl, ?hrr), cold(?cfl, ?cfr, ?crl, ?crr)])

Sometimes, especially when the goal can be interpreted as a logical question, the literature is talking from predicates. To be precise, Prolog is an implementation of first order logic, also called predicate calculus or predicate logic (see [here](https://en.wikipedia.org/wiki/First-order_logic) if interested).

#### Unification

Let's come to the most important and also the most difficult to explain part of reduction rules, the unification. Whenever two terms, for example a goal and the head of a candidate rule, are matched, this is done recursively for each part of the term.

  - If either term is a bound variable, the value of the variable is used for the unfication.
  - If either term is an unbound variable, the variable is bound to the other term.
  - If both terms are unbound variables, these variables are forced to share the same value for all future unifications. Here is where the magic happens.
  - If one term is a literal, the other term must either be an unbound variable or it must be an identical literal term. If the other term is a variable, that variable is bound to the literal term.
  - If one term is a composite term, the other term must either be an unbound variable or it must be a composite term itself and each part of both terms must be unifyable. If the other term is a variable, that variable is bound to the composite term.
  - Compound terms can only be unifed with other compound terms if functors and arity are the same.
  - Anonymous variables (expressed as a single question mark "?") unify with anything.
  - When the rule engine goes back (aka backtracking) to search for an alternative solution, all bindings are undone.
  
Examples:

	test(A, foo([1, 2]))

can be unfied with all the following terms (as long as ?a and ?b are unbound variables or are bound to a unifyable term):

	test(?a, ?b)
	test(?, foo([?a | ?]))
	test(?, foo([1, 2]))
	test(A, ?)

but it cannot be unfied with:

	test(A)
	test(A, foo(?, ?))
	test(?a, foo([?a, ?b])

Note: In the last example, the unification fails, because *?a* has been bound to **A** in the first step and **A** cannot be unified with the first element of the list in *foo*, which is a **1**.

#### Cut and Fail

Sometimes you want to stop following the path of alternative rules, once you have found the best answer for a given goal. Example:

	ask(?question, ?answer) <= lookupInCache(?question, ?answer), !
	ask(?question, ?answer) <= searchInWeb(?question, ?answer)

Once a question and the corresponding answer has been found in the cache, it is not necessary anymore to search the web, even if the answer was not satisfactory.

Another interesting use is to completely stop the search for a solution and consider the current goal to be unsuccessful.

	historicPressures(?lap, [hot(?hfl, ?hfr, ?hrl, ?hrr), cold(?cfl, ?cfr, ?crl, ?crr)]) <= ?lap < 1, !, fail
	historicPressures(?lap, [hot(?hfl, ?hfr, ?hrl, ?hrr), cold(?cfl, ?cfr, ?crl, ?crr)]) <= ...

The first rule checks, whether the supplied lap number is invalid (less than 1). If this is the case, the goal completely fails.

#### Builtin Predicates

The rule engine has some builtin predicates which can be used when formulating rules. But they are also helpful to formulate more complex rules.

  - option
  
    Syntax: option(*setting*, *value*)
	
	This is not a typical predicate, but can be used to alter the behaviour of the rule execution during runtime. *Setting* can be
	
    - OccurCheck
  
	  If you set this to *true*, each unification checks, whether an unbound variable occurs in a term to which the variable will be bound during unfication. If this is the case, the unification fails, since infinite structures can be created otherwise.

	  Example:
	
	      occurs(?x, [1, 2, ?x])
		
		  createInfinite(?y) <= occurs(?y, ?y)
		
	  But checking for this has a high performance penalty and is therefore not enabled by default.

    - DeterministicFacts
  
	  Facts can be altered during the execution of reduction rules. Using this setting you can control, whether the change should be undone during backtracking (if *false*) or if the change to facts should be retained (if *true*, which is the default).
	
    - Trace
  
	  Not really a change in behaviour, but very helpful. Values can be "Full", "Medium", "Light", "Off". If the *Trace* is not "Off", which is the default, a lot of information is written to the log file during rule execution, not only for reduction rules, but also for production rules. This has a high performance penalt, of course.
    
	option always succeeds, even if called with an unknown setting.

  - sqrt
  
	Syntax: sqrt(value, term)
	
	If *value* is numerical, then sqrt unifies *term* with the square root of this number.
	
  - **\+** - plus
  
    Syntax: +(value1, value2, sum)    or    sum = value1 + value2
	
	**\+** computes the sum of two values using unification. At least two of the three terms must be bound to numerical values, but in contrast to traditional programming languages, it is not required that these are the *value1* and *value2*.
	
  - **\-** - minus
  
    Syntax: -(value1, value2, sum)    or    sum = value1 - value2
	
	**\-** computes the difference of two values using unification. At least two of the three terms must be bound to numerical values, but in contrast to traditional programming languages, it is not required that these are the *value1* and *value2*.
	
  - **\*** - multiply
  
    Syntax: -(value1, value2, sum)    or    sum = value1 - value2
	
	**\*** multiplies two values using unification. At least two of the three terms must be bound to numerical values, but in contrast to traditional programming languages, it is not required that these are the *value1* and *value2*.
	
  - **\/** - divide
  
    Syntax: -(value1, value2, sum)    or    sum = value1 - value2
	
	**\/** divides two values using unification. At least two of the three terms must be bound to numerical values, but in contrast to traditional programming languages, it is not required that these are the *value1* and *value2*.
	
  - **\=**
  
    Syntax: =(term1, term2)    or    term1 = term2
	
	Unifies *term1* with *term2*.
	
  - **\>**, **\<**, **\=\<**, **\>\=**, **\!\=**
  
    Syntax: op(term1, term2)    or    term1 op term2
	
	Compares two terms according to the operator. Because the rule engine does not support constrain based unification (yet), both terms must be bound to comparable literals at the moment of execution.
	
  - append
  
    Syntax: append(term1, ..., termN, result)
	
	append accepts any number of terms, concatenates the string reperesentation of those terms and then unifies the resulting string with *result*. Unbound variables are *printed* as variable names, like: "?a".
	
  - get
  
	Syntax: get(term1, ..., termN, value)
	
	Similar to *append*, *get* accepts any number of terms and concatenates the string reperesentation of those terms. But other as *append*, *get* uses the resulting string as the name of a fact in the knowledge base and unifies the value of the fact with *value*. If the fact is unknown, *get* fails.
	
  - set
  
	Syntax: set(term1, ..., termN, value)
	
	Similar to *append*, *set* accepts any number of terms and concatenates the string reperesentation of those terms. But other than *append*, *set* uses the resulting string as the name of a fact in the knowledge base and then sets the fact to the given *value. If *value* is unbound, the variable name, like: "?a", is used.
	
  - clear
  
	Syntax: clear(term1, ..., termN)
	
	Similar to *append*, *clear* accepts any number of terms and concatenates the string reperesentation of those terms. But other than *append*, *clear* uses the resulting string as the name of a fact in the knowledge base and removes that fact.
	
  - unbound?
  
    Syntax: unbound?(*any*)
	
	unbound? can be *called* with a single argument. The *call* succeeds, if the argument is an unbound variable, a fact with no value or an unknown fact. In all other cases, unbound? fails. Creating the reverse predicate is quite simple:
	
		bound?(?x) <= unbound?(?x), !, fail
		bound?(?x)

  - call
  
	Syntax: call(function, arg1, ..., argN)
  
    Using *call*, you can invoke functions in the global name space of the host programming language. Beside all arguments, an implicit first argument is passed to the function. This is an instance of the *ChoicePoint* class of the rule engine. This object also contains the following two properties to make is symetrical to the *Call* action in production rules:
	
	  1. Knowledgebase - an instance of class *Knowledgebase* in the host language.
	  2. RuleEngine - an instance of class *RuleEngine* in the host language.
	
	They can be used to access the internal state of the knowledge base and the current state of execution in the rule engine. It is even possible to invoke the rule engine recursively while processing the function.
	
	*function* must return true, if the call succeeds and the next subgoal should be processed. If *function* returns *false*, it fails and the next alternative will be processed by the rule engine.

  - produce
  
    Syntax: produce()
	
	This is a very special predicate. It interrupts the reduction rule execution and allows the rule engine to run all pending production rules. Since these can *call* reduction rules in their actions and also in their conditions, this results in a stack of active execution environments.
  
### Event-based programming

The combination of the facts in the knowledge base with both type of rules, allows you to build event-based systems very easily. Let's discuss that with regards to the Race Assistants.

  1. The current state of the session, the state of the car like important telemetry values and also information about all opponente are stored as facts in the knowledge base.
  2. A set of production rules constantly check whether a specific condition exists, for example that fuel will be depleted in about 3 laps.
  3. If one of this conditions is detected, the production rule can start complex calculations using reductions rules as a resulting action.

This is exactly the approach, how the rule sets for the Race Assistants has been built.

## Customizing the Assistant rules

The rule sets for the Race Assistants can be found in the *Resources\Rules* directory in the installation folder of Simulator Controller. But as with most of the configuration files of Simulator Controller, they can be locally customized or extended. Simply make a copy of one of the rule files and place it in the *Simulator Controller\Rules* directory, which can be found in your user *Documents* folder.

You can also extend the reasoning process of a Race Assistant by connecting the rule engine to a GPT-based large language model. Please see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#reasoning-booster) for more information.