;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Rule Engine Test                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

; SetBatchLines -1				; Maximize CPU utilization
; ListLines Off					; Disable execution history


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kCompilerCompliantTestRules
				= ["persist(?A.grandchild, ?B) <= Call(showRelationship, ?A.grandchild, ?B), !, Set(?A.grandchild, true), Set(?B, grandfather), Produce()"
				 , "reverse([1,2,3,4], ?L)"
				 , "foo(?A, bar(?B, [?C])) <= baz(?, foo(?A, ?)), !, fail"
				 , "reverse([ ?H |?T ], ?REV )<= reverse(?T,?RT), concat(?RT,[?H],?REV)"
				 , "Priority: 5, {Any: [?Peter.grandchild], [Predicate: ?Peter.son = true]} => (Set: Peter, happy), (Call: showRelationship, 1, 2), (Prove: father, maria, willy), (Call: showRelationship, 2, 1)"]

global kCompilerNonCompliantTestRules
				= ["persist(?A.grandchild  ?B) <= Call(showRelationship, ?A.grandchild, ?B, !, Set(?A.grandchild, true), Set(?B, grandfather), Produce()"
				 , "reverse([1,2,3,4]], ?L)"
				 , "foo(?A, bar(?B)) => baz(?, foo([?A], !), !, fail"
				 , "reverse([ ?H | ], ?REV )<= reverse(?T,,?RT), concat ?RT,[?H],?REV)"
				 , "Priority: 5, [Any: [?Peter.grandchild], [Preddicate: ?Peter.son = true]} => [Set: Peter, happy), (Call: showRelationship, 1, 2), (Prove: father, maria, willy), (Call: showRelationship, 2, 1)"]

kRules =
(
				oc(?O) <= eq(?O, f(?O))
				eq(?X, ?X)
				
				sf(?F) <= Set(?F, true), !, fail
				
				reverse([], [])
				reverse([?H | ?T], ?REV) <= reverse(?T, ?RT), concat(?RT, [?H], ?REV)

				concat([], ?L, ?L)
				concat([?H | ?T], ?L, [?H | ?R]) <= concat(?T, ?L, ?R)

				persist(?A, ?B) <= Call(showRelationship, ?A, ?B), !, Set(?B.grandchild, ?A), Set(?B.grandfather, true), Set(?A.grandchild, true), Produce()

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

				{Any: [?Peter.grandchild], [?Peter.son]} => (Set: Peter, happy)
				[?Peter = happy] => (Call: celebrate)
)

global kExecutionTestRules = kRules


;;;-------------------------------------------------------------------------;;;
;;;                              Test Section                               ;;;
;;;-------------------------------------------------------------------------;;;

class CompilerTestClass extends Assert {	
	removeWhiteSpace(text) {
		text := StrReplace(text, A_Space, "")
		text := StrReplace(text, A_Tab, "")
		text := StrReplace(text, "`n", "")
		text := StrReplace(text, "`r", "")
		
		return text
	}
	
	substituteBoolean(text) {
		text := StrReplace(text, "true", "1")
		text := StrReplace(text, "false", "0")
		
		return text
	}
	
	substitutePredicate(text) {
		text := StrReplace(text, "Predicate:", "")
		
		return text
	}
	
	Compiler_Compliance_Test() {
		compiler := new RuleCompiler()
		productions := false
		reductions := false
		text := ""
		
		for ignore, theRule in kCompilerCompliantTestRules
			text := (text . theRule . "`n")
		
		compiler.compileRules(text, productions, reductions)
		
		this.AssertEqual(1, productions.Length(), "Not all production rules compiled...")
		this.AssertEqual(4, reductions.Length(), "Not all reduction rules compiled...")
	}
	
	Compiler_NonCompliance_Test() {
		compiler := new RuleCompiler()
		productions := false
		reductions := false
		text := ""
		
		for ignore, theRule in kCompilerNonCompliantTestRules {
			try {
				compiler.compileRule(text)
		
				this.AssertEqual(false, true, "Syntax error not reported for rule """ . theRule . """...")
			}
			catch exception {
				this.AssertEqual(true, true)
			}
		}
	}
	
	Compiler_Identity_Test() {
		compiler := new RuleCompiler()
		
		for ignore, theRule in kCompilerCompliantTestRules {
			compiledRule := compiler.compileRule(theRule)
			
			this.AssertEqual(this.removeWhiteSpace(compiledRule.toString())
						   , this.substitutePredicate(this.substituteBoolean(this.removeWhiteSpace(theRule))), "Error in compiled rule " . compiledRule.toString())
			
			newCompiledRule := compiler.compileRule(compiledRule.toString())
			
			this.AssertEqual(newCompiledRule.toString(), compiledRule.toString(), "Error in compiled rule " . newCompiledRule.toString())
		}
	}
}

class EngineTestClass extends Assert {
	OccurCheck_Test() {
		local resultSet
		
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
		
		Loop 1 {
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
				
				if (test[2].Length() > 0) {
					this.AssertEqual(true, (resultSet != (A_Index == 2)), "Unexpected remaining results...")
				
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
		local resultSet
		
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
		
		kb.enableDeterministicFacts()
		
		goal := compiler.compileGoal("sf(Fact)")
				
		resultSet := kb.prove(goal)
		
		this.AssertEqual(true, (resultSet == false), "Unexpected remaining results...")
		this.AssertEqual(true, kb.Facts.getValue("Fact", false), "Fact is missing...")
		
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
		
		kb.disableDeterministicFacts()
		
		goal := compiler.compileGoal("sf(Fact)")
				
		resultSet := kb.prove(goal)
		
		this.AssertEqual(true, (resultSet == false), "Unexpected remaining results...")
		this.AssertEqual(false, kb.Facts.getValue("Fact", false), "Fact should be missing...")
	}
}

class UnificationTestClass extends Assert {
	executeTests(tests) {
		local resultSet
		
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
			
		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])
			
			resultSet := kb.prove(goal)
			
			if (test[2].Length() > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")
			
				for index, result in test[2] {
					this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))
					
					if ((index == (test[2].Length() - 1)) && (test[2][index + 1] == "..."))
						break
					
					this.AssertEqual(index < test[2].Length(), resultSet.nextResult(), "Unexpected remaining results...")
				}
			}
			else
				this.AssertEqual(false, (resultSet != false), "Unexpected remaining results...")
		}
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
}

class HybridEngineTestClass extends Assert {
	executeTests(tests) {
		local resultSet
		
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		
		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])
			
			resultSet := engine.prove(goal)
			
			if (test[2].Length() > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")
			
				for index, result in test[2] {
					this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))
					
					this.AssertEqual(index < test[2].Length(), resultSet.nextResult(), "Unexpected remaining results...")
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
		
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.son", false), "Fact Peter.son is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Celebrated", false), "Fact Celebrated is missing...")
	}
	
	Script_Integration_Test() {
		local resultSet
		
		tests := [["grandfather(?A, ?B)", ["grandfather(Peter, Paul)", "grandfather(Peter, Willy)"]]]
		
		resultSet := this.executeTests(tests)

		showFacts(resultSet.KnowledgeBase)
		
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.son", false), "Fact Peter.son is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Celebrated", false), "Fact Celebrated is missing...")
		this.AssertEqual("happy", resultSet.KnowledgeBase.Facts.getValue("Peter", false), "Fact Peter is not happy...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.grandchild", false), "Fact Peter.grandchild is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Related.Peter.Paul", false), "Fact Related.Peter.Paul is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Related.Peter.Willy", false), "Fact Related.Peter.Willy is missing...")
		this.AssertEqual("Peter", resultSet.KnowledgeBase.Facts.getValue("Paul.grandchild", false), "Fact Paul.grandchild is not Peter...")
		this.AssertEqual("Peter", resultSet.KnowledgeBase.Facts.getValue("Willy.grandchild", false), "Fact Willy.grandchild is not Peter...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Paul.grandfather", false), "Fact Paul.grandfather is missing...")
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Willy.grandfather", false), "Fact Willy.grandfather is missing...")
	}
	
	Fact_Unification_Test() {
		local resultSet
		
		compiler := new RuleCompiler()
		
		tests := [["grandfather(?A, ?B)", ["grandfather(Peter, Paul)", "grandfather(Peter, Willy)"]],
				, ["happy(Peter)", ["happy(Peter)"]]
				, ["unhappy(Peter)", []]]
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		kb := engine.createKnowledgeBase(engine.createFacts(), engine.createRules())
		
		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])
			
			resultSet := kb.prove(goal)
			
			if (test[2].Length() > 0) {
				this.AssertEqual(true, (resultSet != false), "Unexpected remaining results...")
			
				for index, result in test[2] {
					this.AssertEqual(result, goal.toString(resultSet), "Unexpected result " . goal.toString(resultSet))
					
					this.AssertEqual(index < test[2].Length(), resultSet.nextResult(), "Unexpected remaining results...")
				}
			}
			else
				this.AssertEqual(false, (resultSet != false), "Unexpected remaining results...")
		}
	}
}

celebrate(knowledgeBase) {
	if !knowledgeBase.Facts.getValue("Celebrated", false) {
		SplashTextOn 200, 60, Message, Chaka!!!!
		Sleep 1000
		SplashTextOff
		
		if !knowledgeBase.Facts.hasFact("Celebrated")
			knowledgeBase.Facts.addFact("Celebrated", true)
		else
			knowledgeBase.Facts.setValue("Celebrated", true)
	}
}

showRelationship(knowledgeBase, grandchild, grandfather) {
	local fact := "Related." . grandchild . "." . grandfather
	
	SplashTextOn 200, 60, Message, %grandchild% is grandchild of %grandfather%
	Sleep 1000
	SplashTextOff
	
	if !knowledgeBase.Facts.hasFact(fact)
		knowledgeBase.Facts.addFact(fact , true)

	return true
}

showFacts(knowledgeBase) {
	message := []

	for key, value in knowledgeBase.Facts.Facts
		message.Push(key . " = " . value)
	
	SplashTextOn 200, 250, Facts, % values2String("`n", message*)
	Sleep 5000
	SplashTextOff
}

setOccurCheck(knowledgeBase, enable) {
	if enable
		knowledgeBase.enableOccurCheck()
	else
		knowledgeBase.disableOccurCheck()
}

setDeterministicFacts(knowledgeBase, enable) {
	if enable
		knowledgeBase.enableDeterministicFacts()
	else
		knowledgeBase.disableDeterministicFacts()
}

AHKUnit.AddTestClass(CompilerTestClass)
AHKUnit.AddTestClass(EngineTestClass)
AHKUnit.AddTestClass(UnificationTestClass)
AHKUnit.AddTestClass(HybridEngineTestClass)

AHKUnit.Run()