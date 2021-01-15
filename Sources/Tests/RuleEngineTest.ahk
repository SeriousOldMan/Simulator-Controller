;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Rule Engine Test                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

; #Warn ClassOverwrite, Off


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include AHKUnit\AHKUnit.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kCompilerTestRules
				= ["persist(?A.grandchild, ?B) <= Call(showIt, ?A.grandchild, ?B), !, Set(?A.grandchild, true), Set(?B, grandfather), Produce()"
				 , "reverse([1,2,3,4], ?L)"
				 , "reverse([ ?H |?T ], ?REV )<= reverse(?T,?RT), concat(?RT,[?H],?REV)"
				 , "Priority: 5, {Any: [?Peter.grandchild], [Predicate: ?Peter.son = true]} => (Set: Peter, happy), (Call: showIt, 1, 2), (Prove: father, maria, willy), (Call: showIt, 2, 1)"]

kRules =
(
				reverse([], [])
				reverse([?H | ?T], ?REV) <= reverse(?T, ?RT), concat(?RT, [?H], ?REV)

				concat([], ?L, ?L)
				concat([?H | ?T], ?L, [?H | ?R]) <= concat(?T, ?L, ?R)

				persist(?A, ?B) <= Call(showIt, ?A, ?B), !, Set(?B.grandchild, ?A), Set(?B.grandfather, true), Set(?A.grandchild, true), Produce()

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

class RuleEngineTestClass extends Assert {	
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
	
	Compiler_Compile_Test() {
		compiler := new RuleCompiler()
		productions := false
		reductions := false
		text := ""
		
		for ignore, rule in kCompilerTestRules
			text := (text . rule . "`n")
		
		compiler.compileRules(text, productions, reductions)
		
		this.AssertEqual(1, productions.Length())
		this.AssertEqual(3, reductions.Length())
	}
	
	Compiler_Identity_Test() {
		compiler := new RuleCompiler()
		
		for ignore, rule in kCompilerTestRules {
			compiledRule := compiler.compileRule(rule)
			
			this.AssertEqual(this.removeWhiteSpace(compiledRule.toString()
						   , this.substitutePredicate(this.substituteBoolean(this.removeWhiteSpace(rule)))))
			
			newCompiledRule := compiler.compileRule(compiledRule.toString())
			
			this.AssertEqual(newCompiledRule.toString(), compiledRule.toString())
		}
	}
	
	executeTests(tests) {
		compiler := new RuleCompiler()
		
		productions := false
		reductions := false
		
		compiler.compileRules(kExecutionTestRules, productions, reductions)
		
		engine := new RuleEngine(productions, reductions, {})
		
		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])
			
			resultSet := engine.prove(goal)
			
			this.AssertEqual(true, (resultSet != false))
			
			for index, result in test[2] {
				this.AssertEqual(result, goal.toString(resultSet))
				
				this.AssertEqual(index < test[2].Length(), resultSet.nextResult())
			}
		}
		
		return resultSet
	}
	
	Execute_Concat_Test() {
		tests := [["concat([1], [], [1])", ["concat([1], [], [1])"]]
				, ["concat([1, 2], [3, 4, 5], ?L)", ["concat([1, 2], [3, 4, 5], [1, 2, 3, 4, 5])"]]]
		
		this.executeTests(tests)
	}
	
	Execute_Reverse_Test() {
		tests := [["reverse([1, 2, 3, 4], ?R)", ["reverse([1, 2, 3, 4], [4, 3, 2, 1])"]]
				, ["reverse([], [])", ["reverse([], [])"]]
				, ["reverse([1], ?R)", ["reverse([1], [1])"]]]
		
		this.executeTests(tests)
	}
	
	Execute_Father_Test() {
		tests := [["father(?A, ?B)", ["father(Peter, Frank)", "father(Frank, Paul)", "father(Mara, Willy)"]]]
		
		resultSet := this.executeTests(tests)
		
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.son", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Celebrated", false))
	}
	
	/*
	Execute_GrandFather_Test() {
		tests := [["grandfather(?A, ?B)", ["grandfather(Peter, Paul)", "grandfather(Peter, Willy)"]]]
		
		resultSet := this.executeTests(tests)

		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.son", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Celebrated", false))
		this.AssertEqual("happy", resultSet.KnowledgeBase.Facts.getValue("Peter", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Peter.grandchild", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Related.Peter.Paul", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Related.Peter.Willy", false))
		this.AssertEqual("Peter", resultSet.KnowledgeBase.Facts.getValue("Paul.grandchild", false))
		this.AssertEqual("Peter", resultSet.KnowledgeBase.Facts.getValue("Willy.grandchild", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Paul.grandfather", false))
		this.AssertEqual(true, resultSet.KnowledgeBase.Facts.getValue("Willy.grandfather", false))
		
		return resultSet
	}
	
	Execute_Happiness_Test() {
		compiler := new RuleCompiler()
		
		resultSet := this.Execute_GrandFather_Test()
		
		tests := [["happy(Peter)", ["happy(Peter)"]]
				, ["unhappy(Peter)", []]]
		
		engine := resultSet.KnowledgeBase.RuleEngine
		
		for ignore, test in tests {
			goal := compiler.compileGoal(test[1])
			
			resultSet := engine.prove(goal)
			
			for index, result in test[2] {
				msgbox % goal.toString(resultSet)
				this.AssertEqual(result, goal.toString(resultSet))
				
				this.AssertEqual(index < test[2].Length(), resultSet.nextResult())
			}
		}
	}
	*/
}

celebrate(knowledgeBase) {
	if !knowledgeBase.Facts.getValue("Celebrated", false) {
		SplashTextOn 300, 100, , Chaka!!!!
		Sleep 1000
		SplashTextOff
		
		if !knowledgeBase.Facts.hasFact("Celebrated")
			knowledgeBase.Facts.addFact("Celebrated", true)
		else
			knowledgeBase.Facts.setValue("Celebrated", true)
	}
}

showIt(knowledgeBase, grandchild, grandfather) {
	SplashTextOn 300, 100, , %grandchild% is grandchild of %grandfather%
	Sleep 1000
	SplashTextOff
	
	fact := "Related." . grandchild . "." . grandfather
	
	if !knowledgeBase.Facts.hasFact(fact)
		knowledgeBase.Facts.addFact(fact , true)

	return true
}


AHKUnit.AddTestClass(RuleEngineTestClass)
AHKUnit.Run()
exit
	
/*
**************************
Assertion Messages einbauen
**************************


				, ["reverse(?R, [3, 2, 1])", ["reverse([1, 2, 3], [3, 2, 1])"]]



*/
compiler := new RuleCompiler()
		
productions := false
reductions := false

compiler.compileRules(kExecutionTestRules, productions, reductions)

engine := new RuleEngine(productions, reductions, {})

tests := [["concat([1], [], [1])", ["concat([1], [], [1])"]]
				, ["concat([1, 2], [3, 4, 5], ?L)", ["concat([1, 2], [3, 4, 5], [1, 2, 3, 4, 5])"]]]
		

for ignore, test in tests {
	goal := compiler.compileGoal(test[1])
	
	resultSet := engine.prove(goal)
	hasValues := false
	
	for index, result in test[2] {
		MsgBox % goal.toString(resultSet)
		
		hasValues := resultSet.nextResult()
	}
			
	if hasValues
		MsgBox % "OOps: " . goal.toString(resultSet)
}
msgbox here
message := []

for key, value in resultSet.KnowledgeBase.Facts.Facts
	message.Push(key . " = " . value)
	
MsgBox % "Fakten`n`n" . values2String("`n", message*)

exit

engine.iTraceLevel := kTraceOff

start := A_TickCount
Loop 100 {
resultSet := engine.prove(goal)
}
MsgBox % A_TickCount - start . " ms"

if resultSet {
	Loop {
		MsgBox % "Result: " . goal.toString(resultSet)
	} until !resultSet.nextResult()
	
	Msgbox Query exhausted
}
else
	Msgbox Query failed
	
	
message := []

for key, value in resultSet.KnowledgeBase.Facts.Facts
	message.Push(key . " = " . value)
	
MsgBox % "Fakten`n`n" . values2String("`n", message*)


engine.iTraceLevel := kTraceOff

goal := ["happy", "peter"]
goal := theCompiler.parseGoal(goal)

resultSet := resultSet.KnowledgeBase.prove(goal)

if resultSet {
	Loop {
		MsgBox % "Result: " . goal.toString(resultSet)
	} until !resultSet.nextResult()
	
	Msgbox Query exhausted
}
else
	Msgbox Query failed
	
goal := ["reverse", "?A", "?B"]
goal := theCompiler.parseGoal(goal)

resultSet := resultSet.KnowledgeBase.prove(goal)

if resultSet {
	Loop {
		MsgBox % "Result: " . goal.toString(resultSet)
	} until !resultSet.nextResult()
	
	Msgbox Query exhausted
}
else
	Msgbox Query failed


		
		message := []

		for key, value in resultSet.KnowledgeBase.Facts.Facts
			message.Push(key . " = " . value)
			
		MsgBox % "Fakten`n`n" . values2String("`n", message*)