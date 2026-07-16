;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Rule Engine Test                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")				; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)		; Ensures a consistent starting directory.

global kBuildConfiguration := "Production"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\RuleEngine.ahk"
#Include "..\Framework\Extensions\ScriptEngine.ahk"
#Include "..\Framework\Extensions\JSON.ahk"
#Include "AHKUnit\AHKUnit.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kCompilerCompliantTestRules
				:= ["persist(?A.grandchild, ?B) <= Call(showRelationship, ?A.grandchild, ?B), !, Set(?A.grandchild, true), Set(?B, grandfather), Produce()"
				  , "reverse([1,2,3,4], ?L)"
				  , "foo(?A, bar(?B, [?C])) <= baz(?, foo(?A, ?)), !, fail"
				  , "reverse([ ?H |?T ], ?REV )<= reverse(?T,?RT), concat(?RT,[?H],?REV)"
				  , "Priority: 5, {Any: [?Peter.grandchild], [Predicate: ?Peter.son = true]} => (Set: Peter = happy), (Call: showRelationship(1, 2)), (Prove: father(maria, willy)), (Call: showRelationship(2, 1))"
				  , "fac(?X, ?R) <= >(?X, 0), -(?N, ?X, 1), fac(?N, ?T), *(?R, ?T, ?X)"]

global kCompilerNonCompliantTestRules
				:= ["persist(?A.grandchild  ?B) <= Call(showRelationship, ?A.grandchild, ?B, !, Set(?A.grandchild, true), Set(?B, grandfather), Produce()"
				  , "reverse([1,2,3,4]], ?L)"
				  , "foo(?A, bar(?B)) => baz(?, foo([?A], !), !, fail"
				  , "reverse([ ?H | ], ?REV )<= reverse(?T,,?RT), concat ?RT,[?H],?REV)"
				  , "Priority: 5, [Any: [?Peter.grandchild], [Preddicate: ?Peter.son = true]} => [Set: Peter = happy), (Call: showRelationship(1, 2)), (Prove: father(maria, willy)), (Call: showRelationship(2, 1))"]

global kExecutionTestRules := "
(
				oc(?O) <= ?O = f(?O)
				eq(?X, ?X)

				sf(?F) <= Set(?F, true), !, fail

				reverse([], [])
				reverse([?H | ?T], ?REV) <= reverse(?T, ?RT), concat(?RT, [?H], ?REV)

				concat([], ?L, ?L)
				concat([?H | ?T], ?L, [?H | ?R]) <= concat(?T, ?L, ?R)

				fac(0, 1)
				fac(?X, ?R) <= ?X > 0, -(?N, ?X, 1), fac(?N, ?T), ?R = ?T * ?X

				sum([], 0)
				sum([?h | ?t], ?sum) <= sum(?t, ?tSum), ?sum = ?h + ?tSum

				construct(?A, ?B) <= Append(Foo., ?B, .Bar, ?A)

				persist(?A, ?B) <= :showRelationship(?A, ?B), !, Set(?B.grandchild, ?A), Set(?B.grandfather, true), Set(?A.grandchild, true), Produce()

				father(Peter, Frank) <= Set(Peter.son, true), Produce()
				father(Frank, Paul)
				father(Mara, Willy)

				mother(Peter, Mara)
				mother(Frank, Barbara)

				grandfather(?A, ?B) <= father(?A, ?C), father(?C, ?B), persist(?A, ?B)
				grandfather(?A, ?B) <= mother(?A, ?C), father(?C, ?B), persist(?A, ?B)

				happy(Peter) <= mood(!Peter)
				unhappy(Peter) <= mood(!Peter), !, fail
				mood(happy)

				isHappy(?mood, Paul) <= mood(?mood)

				empty() <= father(Mara, Willy)

				complexClause(?x, ?y) <= ?x = [1, 2, 3], ?y = complex(A, foo([1, 2]))

				{All: [?Input], {Is: ?Result = ?Input + 1}} => (Let: ?Temp = ?Result + 1), (Set: CalcResult = ?Temp)

				{Any: [?Peter.grandchild], [?Peter.son]} => (Set: Peter, happy)
				[?Peter = happy] => (Call: celebrate())
				{Any: [?Paul.grandchild], [?Willy.grandChild]} => (Set: Bound, ?Paul.grandChild), (Set: NotBound, ?Peter.son), (Set: ForcedBound, !Willy.grandchild)

				{All: [?Peter], {Prove: isHappy(?Peter, ?gf)}} => (Prove: father(?father, ?gf)), (Call: celebrate())

				scriptTestSuccess(?path) <= execute(?path, "Yes")
				scriptTestFail(?path) <= execute(?path, "No")

				transpose([], [])
				transpose([?first | ?rest], ?transposed) <= transpose(?first, [?first | ?rest], ?transposed)

				transpose([], ?, [])
				transpose([? | ?rest], ?matrix, [?transposedFirst | ?transposedRest]) <=
						transposeRow(?matrix, ?transposedFirst, ?matrixFirst),
						transpose(?rest, ?matrixFirst, ?transposedRest)

				transposeRow([], [], [])
				transposeRow([[?rFirst | ?oFirst] | ?rest], [?rFirst | ?rRest], [?oFirst | ?oRest]) <=
						transposeRow(?rest, ?rRest, ?oRest)

				testFunctionCall(?input, ?result) <= :testFunctionCall=(?input, ?result)

				{All: [?Test], {Is: :testFunctionCall=(Foo, ?Result)}} =>
						(Set: CallResult1 = ?Result),
						(Prove: addRule("printFather(?v) <= :showArgs(?v), Set(FatherResult, ?v)", ?))

				{All: [?Test], {Is: :%Singleton.Instance.testMethodCall1%=("Foo", ?Result)}} =>
						(Call: Singleton.Instance.testMethodCall2("Baz")), (Set: CallResult2 = ?Result)

				[?Test] => (Let: ?var = father(Peter, Paul)), (Prove: printFather(?var))
				[?Test] => (Prove: parse("son(Paul, Peter)", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult1 = ?text)
				[?Test] => (Prove: parse("47.11", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult2 = ?text)
				[?Test] => (Prove: parse("Hugo", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult3 = ?text)
				[?Test] => (Prove: parse("[1,2|3]", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult4 = ?text)
				[?Test] => (Set: TestFact = "Hello"),
						   (Prove: parse("!TestFact", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult5 = ?text)
				[?Test] => (Let: ?Var = "There"),
						   (Prove: parse("?Var", ?term)), (Prove: print(?term, ?text)),
						   (Call: showArgs(?text)), (Set: ParseResult6 = ?text)
				{All: [?Test], {Is: ?var = answer(?x)}, {Prove: checkStruct(live(?var))}} =>
							(Let: ?x = 42), (Set: ParseResult7 = ?var)
				{All: [?Test], {Is: :%answerTerm%=(?var)}, {Prove: checkStruct(live(?var))}} =>
				 			(Let: ?x = 42), (Set: ParseResult8 = ?var)
				{All: [?Test], {Is: :%answerString%=(?var)}, {Prove: checkStruct(live(?var))}} =>
				 			(Let: ?x = 13), (Set: ParseResult9 = ?var)
				[?Test] => (Let: ?var = answer(!Answer)), (Set: Answer = 42), (Set: ParseResult10 = ?var)
				[?Test] => (Let: ?var = #Compiler.Life.Question), (Set: CallResult4 = ?var)
				[?Test] => (Let: ?var = "Compiler.Life.Question"), (Prove: extern=(?var, ?val)), (Set: CallResult5 = ?val)

				checkStruct(live(answer(?x)))

				printFather(?v) <= fail

				[?Compose] => (Let: ?Var = "Foo"), (Set: ?Var, Bar, ?Var = "Baz")

				[?Compose] => (Set: L = Object)
				{All: [?Compose], [?L]} => (Set: ?L.prop = Yes)
				{All: [?Compose], [?L]} => (Prove: setMethod(?L, No))
				{All: [?Compose], [?L]} => (Prove: Set(?L.func, Maybe))

				setMethod(?object, ?value) <= Set(?object.meth, ?value)

				{All: [?Rules], {Prove: productions(?productions)}, {Prove: reductions(?reductions)}} =>
						(Prove: printRules(?productions)), (Prove: printRules(?reductions))

				printRules([])
				printRules([[?id | ?rule] | ?rules]) <= :showArgs(?id, ": ", ?rule), printRules(?rules)

				{All: [?List], {Is: ?temp = 3}, {Is: ?temp = ?three}, [[1,2,?three] contains 3]} => (Call: showArgs("Yes")), (Set: ThreeFound)
				{All: [?List], {Is: ?three = 3}, {Is: ?three = 4}, [[1,2,?three] contains 3]} => (Call: showArgs("Oops")), (Set: SecondThreeFound)
				{All: [?List], {Is: ?L1 = [1, 2]}, {Is: ?L2 = [3]},
						{Prove: concat(?L1, ?L2, ?L)}, {None: [?L contains 4]}} => (Set: FourNotFound)

				[?Backtrack] => (ProveAll: getValue(?value)), (Call: showArgs(?value)), (Set: Result = ?value)
				[?Backtrack] => (ProveAll: getValue(?value)), (Set: Result, ?value = ?value)

				getValue(1)
				getValue(2)
				getValue(3)
)"


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class Singleton {
	__New() {
		Singleton.Instance := this
	}

	testMethodCall1(first) {
		return (first . "_Bar")
	}

	testMethodCall2(knowledgeBase, first) {
		knowledgeBase.setFact("CallResult3", first . "_Bar")
	}
}

class ScriptKnowledgeBase extends KnowledgeBase {
	execute(executable, arguments) {
		local result := false
		local extension, context, script, scriptFileName, message

		try {
			SplitPath(executable, , , &extension)

			if ((extension = "script") || (extension = "lua")) {
				context := scriptOpenContext()

				try {
					scriptFileName := executable

					try {
						if !scriptLoad(context, scriptFileName, &message)
							throw message
					}
					finally {
						if !isDebug()
							deleteFile(scriptFileName)
					}

					scriptPushArray(context, collect(arguments, (a) => ((a = kNotInitialized) ? kUndefined : a)))
					scriptSetGlobal(context, "Arguments")

					scriptPushValue(context, kUndefined)
					scriptSetGlobal(context, "__Undefined")
					scriptPushValue(context, kNotInitialized)
					scriptSetGlobal(context, "__NotInitialized")

					scriptPushValue(context, (c) {
						this.setFact(scriptGetString(c), scriptGetString(c, 2))

						return Integer(0)
					})
					scriptSetGlobal(context, "__Rules_SetValue")
					scriptPushValue(context, (c) {
						local value := this.getValue(scriptGetString(c))

						if ((value = kUndefined) || (value = kNotInitialized))
							value := kNull

						scriptPushValue(c, value)

						return Integer(1)
					})
					scriptSetGlobal(context, "__Rules_GetValue")
					scriptPushValue(context, (c) {
						this.produce()

						return Integer(0)
					})
					scriptSetGlobal(context, "__Rules_Execute")

					if scriptExecute(context, &message) {
						result := scriptGetBoolean(context)
						value := scriptGetString(context, 2)
					}
					else
						throw message
				}
				finally {
					scriptCloseContext(context)
				}
			}
			else
				result := super.execute(executable, arguments)
		}
		catch Any as exception {
			logError(exception)
		}

		return result
	}
}

class Compiler extends Assert {
	static Life := {Question: 42}

	removeWhiteSpace(text) {
		text := StrReplace(text, A_Space, "")
		text := StrReplace(text, A_Tab, "")
		text := StrReplace(text, "`n", "")
		text := StrReplace(text, "`r", "")

		return text
	}

	substituteBoolean(text) {
		text := StrReplace(text, kTrue, "1")
		text := StrReplace(text, kFalse, "0")

		return text
	}

	substitutePredicate(text) {
		text := StrReplace(text, "Predicate:", "")

		return text
	}

	Compiler_Compliance_Test() {
		local compiler := RuleCompiler()
		productions := false
		reductions := false
		text := ""

		for ignore, theRule in kCompilerCompliantTestRules
			text := (text . theRule . "`n")

		compiler.compileRules(text, &productions, &reductions)

		this.AssertEqual(1, productions.Length, "Not all production rules compiled...")
		this.AssertEqual(5, reductions.Length, "Not all reduction rules compiled...")
	}

	Compiler_NonCompliance_Test() {
		local compiler := RuleCompiler()
		productions := false
		reductions := false
		text := ""

		for ignore, theRule in kCompilerNonCompliantTestRules {
			try {
				compiler.compileRule(text)

				this.AssertEqual(false, true, "Syntax error not reported for rule `"" . theRule . "`"...")
			}
			catch Any as exception {
				this.AssertEqual(true, true)
			}
		}
	}

	Compiler_Identity_Test() {
		local compiler := RuleCompiler()

		for ignore, theRule in kCompilerCompliantTestRules {
			compiledRule := compiler.compileRule(theRule)

			this.AssertEqual(this.substitutePredicate(this.substituteBoolean(this.removeWhiteSpace(theRule)))
						   , this.removeWhiteSpace(compiledRule.toString()), "Error in compiled rule " . compiledRule.toString())

			newCompiledRule := compiler.compileRule(compiledRule.toString())

			this.AssertEqual(compiledRule.toString(), newCompiledRule.toString(), "Error in compiled rule " . newCompiledRule.toString())
		}
	}

	Compiler_FullScript_Test() {
		local compiler := RuleCompiler()

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		this.AssertEqual(31, productions.Length, "Not all production rules compiled...")
		this.AssertEqual(43, reductions.Length, "Not all reduction rules compiled...")
	}

	Compiler_Converter_Test() {
		local compiler := RuleCompiler()

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		pCount := 0
		rCount := 0

		do(productions, (p) {
			local text := p.JSON

			try {
				new := compiler.fromJSON(text)

				if (new && (p.toString() = StrReplace(new.toString(), "47.109999999999999", "47.11")))
					pCount += 1
			}
			catch Any as exception {
				logError(exception)
			}
		})

		do(reductions, (r) {
			local text := r.JSON

			try {
				new := compiler.fromJSON(text)

				if (new && (r.toString() = new.toString()))
					rCount += 1
			}
			catch Any as exception {
				logError(exception)
			}
		})

		this.AssertEqual(31, pCount, "Not all production rules converted...")
		this.AssertEqual(43, rCount, "Not all reduction rules compiled...")
	}
}

class CoreEngine extends Assert {
	OccurCheck_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		loop 1 {
			if (A_Index == 1) {
				tests := [["oc(?R)", []]]

				kb.enableOccurCheck()
			}
			else {
				tests := [["oc(?R)", ["oc(f(?R))"]]]

				kb.disableOccurCheck()
			}

			for ignore, test in tests {
				goal := compiler.compileGoal(test[1])

				resultSet := kb.prove(goal)

				if (test[2].Length > 0) {
					this.AssertEqual(true, (resultSet != (A_Index == 2)), "Unexpected remaining results...")

					if resultSet
						for index, result in test[2] {
							this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))

							this.AssertEqual(true, resultSet.nextResult(), "Unexpected remaining results...")
						}
				}
				else
					this.AssertEqual(true, (resultSet == false), "Unexpected remaining results...")
			}
		}
	}

	Deterministic_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.enableDeterministicFacts()

		goal := compiler.compileGoal("sf(Fact)")

		resultSet := kb.prove(goal)

		this.AssertEqual(true, (resultSet == false), "Unexpected remaining results...")
		this.AssertEqual(true, kb.getValue("Fact", false), "Fact is missing...")

		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.disableDeterministicFacts()

		goal := compiler.compileGoal("sf(Fact)")

		resultSet := kb.prove(goal)

		this.AssertEqual(true, (resultSet == false), "Unexpected remaining results...")
		this.AssertEqual(false, kb.getValue("Fact", false), "Fact should be missing...")
	}

	Lua_Script_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := ScriptKnowledgeBase(engine, engine.createFacts(), engine.createRules())

		goal := compiler.compileGoal("scriptTestFail(`"" . kSourcesDirectory . "Tests\Test Scripts\Simple.script`")")

		resultSet := kb.prove(goal)

		this.AssertEqual(true, (resultSet == false), "Unexpected success of Lua script...")

		goal := compiler.compileGoal("scriptTestSuccess(`"" . kSourcesDirectory . "Tests\Test Scripts\Simple.script`")")

		resultSet := kb.prove(goal)

		this.AssertEqual(true, (resultSet != false), "Unexpected success of Lua script...")
	}
}

class Unification extends Assert {
	static __New() {
		local compiler := RuleCompiler()

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		this.Engine := RuleEngine(productions, reductions, Map())
	}

	executeTests(tests, trace := false) {
		local compiler := RuleCompiler()
		local resultSet, goal

		/*
		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		*/

		engine := Unification.Engine
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.RuleEngine.setTraceLevel(trace ? trace : kTraceOff)

		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])

			resultSet := kb.prove(goal)

			if (test[2].Length > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")

				if resultSet
					for index, result in test[2] {
						this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))

						if ((index == (test[2].Length - 1)) && (test[2][index + 1] == "..."))
							break

						this.AssertEqual(index < test[2].Length, resultSet.nextResult(), "Unexpected remaining results...")
					}
			}
			else
				this.AssertEqual(false, (resultSet != false), "Unexpected remaining results...")

			if resultSet
				resultSet.dispose()
		}
	}

	Simple_Test() {
		tests := [["empty()", ["empty()"]]]

		this.executeTests(tests, isDebug() ? kTraceFull : kTraceOff)
	}

	Concat_Test() {
		tests := [["concat([1], [], [1])", ["concat([1], [], [1])"]]
				, ["concat([1, 2], [3, 4, 5], ?L)", ["concat([1, 2], [3, 4, 5], [1, 2, 3, 4, 5])"]]]

		this.executeTests(tests)
	}

	Reverse_Test() {
		tests := [["reverse([1, 2, 3, 4], ?R)", ["reverse([1, 2, 3, 4], [4, 3, 2, 1])"]]
				, ["reverse([], [])", ["reverse([], [])"]]
				, ["reverse([1], ?R)", ["reverse([1], [1])"]]
				, ["reverse(?R, [3, 2, 1])", ["reverse([1, 2, 3], [3, 2, 1])", "..."]]]

		this.executeTests(tests)
	}

	Recursion_Test() {
		tests := [["sum([], ?R)", ["sum([], 0)"]]
				, ["sum([1], ?R)", ["sum([1], 1)"]]
				, ["sum([1, 2, 3], ?R)", ["sum([1, 2, 3], 6)"]]]

		this.executeTests(tests)
	}

	Transpose_Test() {
		tests := [["transpose([[1,2,3], [4,5,6], [7,8,9]], ?m)"
				 , ["transpose([[1, 2, 3], [4, 5, 6], [7, 8, 9]], [[1, 4, 7], [2, 5, 8], [3, 6, 9]])"]]
				, ["transpose([[1,2,3,4], [4,5,6], [7,8,9,10]], ?m)", []]]

		this.executeTests(tests)
	}

	Transpose_Empty_Test() {
		tests := [["transpose([], ?m)", ["transpose([], [])"]]]

		this.executeTests(tests)
	}

	Builtin_Test() {
		tests := [["fac(0, ?R)", ["fac(0, 1)"]]
				, ["fac(1, ?R)", ["fac(1, 1)"]]
				, ["construct(?A, 42)", ["construct(Foo.42.Bar, 42)"]]]

		this.executeTests(tests)
	}

	Complex_Clause_Test() {
		tests := [["complexClause([1, ?x, 3], complex(?y, ?z))", ["complexClause([1, 2, 3], complex(A, foo([1, 2])))"]]]

		this.executeTests(tests)
	}

	Call_Test() {
		tests := [["testFunctionCall(Foo, ?)", ["testFunctionCall(Foo, Foo_Bar)"]]]

		this.executeTests(tests)
	}
}

class HybridEngine extends Assert {
	executeTests(tests, trace := false) {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())

		if trace
			engine.setTraceLevel(trace)

		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.produce()

		this.AssertEqual(0, kb.Facts.Facts.Count, "Unexpected facts materialized...")

		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])

			resultSet := kb.prove(goal)

			if (test[2].Length > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")

				if resultSet
					for index, result in test[2] {
						this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))

						this.AssertEqual(index < test[2].Length, resultSet.nextResult(), "Unexpected remaining results...")
					}
			}
			else
				this.AssertEqual(false, (resultSet != false), "Unexpected remaining results...")
		}

		return resultSet
	}

	Hybrid_Reasoning_Test() {
		local resultSet

		tests := [["father(?A, ?B)", ["father(Peter, Frank)", "father(Frank, Paul)", "father(Mara, Willy)"]]]

		resultSet := this.executeTests(tests)

		this.AssertEqual(true, resultSet && resultSet.KnowledgeBase.getValue("Peter.son", false), "Fact Peter.son is missing...")
		this.AssertEqual(true, resultSet && resultSet.KnowledgeBase.getValue("Celebrated", false), "Fact Celebrated is missing...")
	}

	Script_Integration_Test() {
		local resultSet

		tests := [["grandfather(?A, ?B)", ["grandfather(Peter, Paul)", "grandfather(Peter, Willy)"]]]
		curTickCount := A_TickCount

		resultSet := this.executeTests(tests)

		; resultSet.KnowledgeBase.produce()

		showFacts(resultSet.KnowledgeBase)

		this.AssertEqual("Peter", resultSet.KnowledgeBase.getValue("Bound", false), "Fact Bound is missing...")
		this.AssertEqual("Peter", resultSet.KnowledgeBase.getValue("ForcedBound", false), "Fact ForcedBound is missing...")
		this.AssertEqual(kNotInitialized, resultSet.KnowledgeBase.getValue("NotBound", kNotInitialized), "Fact NotBound should not be bound...")

		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Celebrated", false), "Fact Celebrated is missing...")
		this.AssertEqual("happy", resultSet.KnowledgeBase.getValue("Peter", false), "Fact Peter is not happy...")
		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Peter.grandchild", false), "Fact Peter.grandchild is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Related.Peter.Paul", false), "Fact Related.Peter.Paul is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Related.Peter.Willy", false), "Fact Related.Peter.Willy is missing...")
		this.AssertEqual("Peter", resultSet.KnowledgeBase.getValue("Paul.grandchild", false), "Fact Paul.grandchild is not Peter...")
		this.AssertEqual("Peter", resultSet.KnowledgeBase.getValue("Willy.grandchild", false), "Fact Willy.grandchild is not Peter...")
		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Paul.grandfather", false), "Fact Paul.grandfather is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.getValue("Willy.grandfather", false), "Fact Willy.grandfather is missing...")
	}

	Fact_Unification_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		tests := [["grandfather(?A, ?B)", ["grandfather(Peter, Paul)", "grandfather(Peter, Willy)"]]
				, ["happy(Peter)", ["happy(Peter)"]]
				, ["unhappy(Peter)", []]]

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])

			resultSet := kb.prove(goal)

			if (test[2].Length > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")

				if resultSet
					for index, result in test[2] {
						this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))

						this.AssertEqual(index < test[2].Length, resultSet.nextResult(), "Unexpected remaining results...")
					}
			}
			else
				this.AssertEqual(false, (resultSet != false), "Unexpected remaining results...")
		}
	}

	Calculation_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.setFact("Input", 5)
		kb.produce()

		this.AssertEqual(7, kb.getValue("CalcResult"), "Unexpected calculation results...")
	}

	Function_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.setFact("Test", true)
		kb.produce()

		this.AssertEqual("Foo_Bar", kb.getValue("CallResult1"), "Unexpected function call result...")
		this.AssertEqual("Foo_Bar", kb.getValue("CallResult2"), "Unexpected function call result...")
		this.AssertEqual("Baz_Bar", kb.getValue("CallResult3"), "Unexpected function call result...")
		this.AssertEqual(42, kb.getValue("CallResult4"), "Unexpected external call result...")
		this.AssertEqual(42, kb.getValue("CallResult5"), "Unexpected external call result...")
		this.AssertEqual("father(Peter, Paul)", kb.getValue("FatherResult"), "Unexpected function call result...")
		this.AssertEqual("son(Paul, Peter)", kb.getValue("ParseResult1"), "Unexpected function call result...")
		this.AssertEqual("47.11", kb.getValue("ParseResult2"), "Unexpected function call result...")
		this.AssertEqual("Hugo", kb.getValue("ParseResult3"), "Unexpected function call result...")
		this.AssertEqual("[1, 2 | 3]", kb.getValue("ParseResult4"), "Unexpected function call result...")
		this.AssertEqual("Hello", kb.getValue("ParseResult5"), "Unexpected function call result...")
		this.AssertEqual("There", kb.getValue("ParseResult6"), "Unexpected function call result...")
		this.AssertEqual("answer(42)", kb.getValue("ParseResult7"), "Unexpected function call result...")
		this.AssertEqual("answer(42)", kb.getValue("ParseResult8"), "Unexpected function call result...")
		this.AssertEqual("answer(13)", kb.getValue("ParseResult9"), "Unexpected function call result...")
		this.AssertEqual("answer(42)", kb.getValue("ParseResult10"), "Unexpected function call result...")
	}

	Compose_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		try {
			kb.setFact("Compose", true)
			kb.produce()

			this.AssertEqual("Baz", kb.getValue("Foo.Bar.Foo"), "Unexpected function call result...")
			this.AssertEqual("Yes", kb.getValue("Object.prop"), "Unexpected function call result...")
			this.AssertEqual("No", kb.getValue("Object.meth"), "Unexpected function call result...")
			this.AssertEqual("Maybe", kb.getValue("Object.func"), "Unexpected function call result...")

			kb.setFact("Rules", true)
			kb.produce()
		}
		catch Any as exception {
			logError(exception)
		}
	}

	Contains_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		try {
			kb.setFact("List", true)
			kb.produce()

			this.AssertTrue(kb.getValue("ThreeFound", kUndefined) != kUndefined, "Unexpected list contains result...")
			this.AssertTrue(kb.getValue("SecondThreeFound", kUndefined) == kUndefined, "Unexpected list contains result...")
			this.AssertTrue(kb.getValue("FourNotFound", kUndefined) != kUndefined, "Unexpected list contains result...")
		}
		catch Any as exception {
			logError(exception)
		}
	}

	Backtrack_Test() {
		local compiler := RuleCompiler()
		local resultSet, goal

		productions := false
		reductions := false

		compiler.compileRules(kExecutionTestRules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, Map())
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())

		kb.setFact("Backtrack", true)
		kb.produce()

		this.AssertEqual(3, kb.getValue("Result"), "Unexpected backtrack result...")
		this.AssertEqual(1, kb.getValue("Result.1"), "Unexpected backtrack result...")
		this.AssertEqual(2, kb.getValue("Result.2"), "Unexpected backtrack result...")
		this.AssertEqual(3, kb.getValue("Result.3"), "Unexpected backtrack result...")
	}
}

answerTerm() {
	return Struct("answer", [Variable("x")])
}

answerString() {
	return "answer(?x)"
}

testFunctionCall(resultSet, value) {
	return (value . "_Bar")
}

celebrate(knowledgeBase) {
	if !knowledgeBase.getValue("Celebrated", false) {
		if (knowledgeBase.RuleEngine.TraceLevel < kTraceOff) {
			SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Message"), SplashTextGui.Add("Text",, "Party, Party..."), SplashTextGui.Show("w200 h60")
			Sleep(1000)
			SplashTextGui.Destroy()
		}

		knowledgeBase.setFact("Celebrated", true)
	}
}

showArgs(choicePoint, arguments*) {
	local kb := choicePoint.KnowledgeBase

	if (kb.RuleEngine.TraceLevel < kTraceOff) {
		SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Message"), SplashTextGui.Add("Text",, values2String(" ", arguments*)), SplashTextGui.Show("w200 h60")
		Sleep(100)
		SplashTextGui.Destroy()
	}

	return true
}

showRelationship(choicePoint, grandchild, grandfather) {
	local knowledgeBase := choicePoint.KnowledgeBase
	local fact := "Related." . grandchild . "." . grandfather

	if (knowledgeBase.RuleEngine.TraceLevel < kTraceOff) {
		SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Message"), SplashTextGui.Add("Text",, grandchild " is grandchild of " grandfather), SplashTextGui.Show("w200 h60")
		Sleep(1000)
		SplashTextGui.Destroy()
	}

	if !knowledgeBase.hasFact(fact)
		knowledgeBase.addFact(fact, true)

	return true
}

showFacts(knowledgeBase) {
	if (knowledgeBase.RuleEngine.TraceLevel < kTraceOff) {
		message := []

		for key, value in knowledgeBase.Facts.Facts
			message.Push(key . " = " . value)

		SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Facts"), SplashTextGui.Add("Text",, values2String("`n", message*)), SplashTextGui.Show("w200 h250")
		Sleep(5000)
		SplashTextGui.Destroy
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if true {
	AHKUnit.AddTestClass(Compiler)
	AHKUnit.AddTestClass(CoreEngine)
	AHKUnit.AddTestClass(Unification)
	AHKUnit.AddTestClass(HybridEngine)

	Singleton()

	AHKUnit.Run()
}
else {
	theRules := "
	(
		=<(?x, ?y) <= ?x =< ?y

		>=(?x, ?y) <= ?x >= ?y

		>(?x, ?y, true) <= ?x > ?y, !
		>(?x, ?y, false)

		max(?x, ?y, ?x) <= ?x > ?y, !
		max(?x, ?y, ?y)

		min(?x, ?y, ?x) <= ?x < ?y, !
		min(?x, ?y, ?y)

		abs(?x, ?r) <= ?x < 0, ?r = ?x * -1, !
		abs(?x, ?x)

		bound?(?x) <= unbound?(?x), !, fail
		bound?(?)

		any?(?value, [?value | ?])
		any?(?value, [? | ?tail]) <= any?(?value, ?tail)

		all?(?value, [?value])
		all?(?value, [?value | ?tail]) <= all?(?value, ?tail)

		none?(?value, [])
		none?(?value, [?value | ?]) <= !, fail
		none?(?value, [? | ?tail]) <= none?(?value, ?tail)

		one?(?value, []) <= fail
		one?(?value, [?value | ?tail]) <= !, none?(?value, ?tail)
		one?(?value, [? | ?tail]) <= one?(?value, ?tail)

		length([], 0)
		length([?h | ?t], ?length) <= length(?t, ?tLength), ?length = ?tLength + 1

		sum([], 0)
		sum([?h | ?t], ?sum) <= sum(?t, ?tSum), ?sum = ?h + ?tSum

		remove([], ?, [])
		remove([?h | ?t], ?h, ?result) <= remove(?t, ?h, ?result), !
		remove([?h | ?t], ?x, [?h | ?result]) <= remove(?t, ?x, ?result)

		removeUnbound([], []) <= !
		removeUnbound([?h | ?t], [?hr | ?r]) <= bound?(?h), !, removeUnbound(?h, ?hr), removeUnbound(?t, ?r)
		removeUnbound([?h | ?t], ?r) <= unbound?(?h), !, removeUnbound(?t, ?r)
		removeUnbound(?r, ?r)

		testRemoveUnbound(?a, ?r) <= ?a = Foo, removeUnbound([?a, ?b], ?r)
		testRemoveUnbound(?a, ?r) <= removeUnbound([1, 2, ?a], ?r)
		testRemoveUnbound(?a, ?r) <= ?a = Foo, removeUnbound([[?a, ?a], ?b], ?r)
		testRemoveUnbound(?a, ?r) <= removeUnbound([[?a, ?a], ?b], ?r)
		testRemoveUnbound(?a, ?r) <= removeUnbound([[?a, ?a, [?c, Foo]], ?b], ?r)

		complexClause(?x, ?y) <= ?x = [1, 2, 3], ?y = complex(A, foo([1, 2]))

		index(?list, ?element, ?index) <= index(?list, ?element, 0, ?index)

		index([?element], ?element, ?index, ?index) <= !
		index([?head | ?tail], ?head, ?index, ?index) <= !
		index([?head | ?tail], ?element, ?running, ?index) <= ?nRunning = ?running + 1, index(?tail, ?element, ?nRunning, ?index)

		weatherIndex(?weather, ?index) <= index([Dry, Drizzle, LightRain, MediumRain, HeavyRain, Thunderstorm], ?weather, ?index)

		weatherSymbol(?index, ?weather) <= weatherIndex(?weather, ?index)

		{Any: [?Peter.grandchild], [?Peter.son], {Prove: grandFather(?A, ?Peter.grandchild)}} => (Call: celebrate())

		reportAnalysis(?sDelta, ?bDelta, ?eDelta) <= max(?sDelta, ?bDelta, ?tDelta), max(?tDelta, ?eDelta, ?delta),
													 Call(messageBox, ?delta)

		{All: [?Input], {Is: ?Result = ?Input + 1}} => (Call: messageBox(?Result))
	)"

	productions := false
	reductions := false

	rc := RuleCompiler()

	rc.compileRules(theRules, &productions, &reductions)

	eng := RuleEngine(productions, reductions, Map())

	kb := eng.createKnowledgeBase(eng.createFacts(), eng.createRules())
	; eng.setTraceLevel(kTraceFull)

	/*
	g := rc.compileGoal("reportAnalysis(0, 0, 0)")

	rs := kb.prove(g)

	while (rs != false) {
		withBlockedWindows(MsgDlg, g.toString(rs))

		if !rs.nextResult()
			rs := false
	}

	withBlockedWindows(MsgDlg, "Done")
	*/

	kb.setFact("Input", 5)
	kb.produce()
}