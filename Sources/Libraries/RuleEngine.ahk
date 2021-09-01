;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Hybrid Rule Engine              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Constants.ahk
#Include ..\Includes\Variables.ahk
#Include ..\Includes\Functions.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAny = "Any:"
global kAll = "All:"
global kOne = "One:"
global kNone = "None:"
global kPredicate = "Predicate:"

global kEqual = "="
global kNotEqual = "!="
global kIdentical = "=="
global kLess = "<"
global kLessOrEqual = "<="
global kGreater = ">"
global kGreaterOrEqual = ">="
global kContains = "contains"

global kCall = "Call:"
global kProve = "Prove:"
global kProveAll = "ProveAll:"
global kSet = "Set:"
global kClear = "Clear:"

global kBuiltinFunctors = ["option", "sqrt", "+", "-", "*", "/", ">", "<", "=", "!=", "builtin0", "builtin1", "unbound?", "append", "get"]
global kBuiltinFunctions = ["option", "squareRoot", "plus", "minus", "multiply", "divide", "greater", "less", "equal", "unequal", "builtin0", "builtin1", "unbound", "append", "get"]
global kBuiltinAritys = [2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 3, 1, -1, -1]

global kProduction = "Production"
global kReduction = "Reduction"

global kNotInitialized = "__NotInitialized__"
global kNotFound = "__NotFound__"

global kTraceFull = 1
global kTraceMedium = 2
global kTraceLight = 3
global kTraceOff = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Condition                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Condition {
	Type[] {
        Get {
            Throw "Virtual property Condition.Type must be implemented in a subclass..."
        }
    }
	
	getFacts(ByRef facts) {
	}
	
	match(facts, variables) {
		Throw "Virtual method Condition.match must be implemented in a subclass..."
	}
	
	toString(facts := "__NotInitialized__") {
		Throw "Virtual method Condition.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           CompositeCondition                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CompositeCondition extends Condition {
	iConditions := []
	
	Conditions[] {
		Get {
			return this.iConditions
		}
	}
	
	__New(conditions) {
		this.iConditions := conditions
	}
	
	getFacts(ByRef facts) {
		for ignore, theCondition in this.Conditions
			theCondition.getFacts(facts)
	}
	
	toString(facts := "__NotInitialized__") {
		conditions := []
		
		for ignore, theCondition in this.Conditions
			conditions.Push(theCondition.toString(facts))
			
		return values2String(", ", conditions*)
	}
}	

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Quantor                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Quantor extends CompositeCondition {
	toString(facts := "__NotInitialized__") {
		return "{" . this.Type . A_Space . base.toString(facts) . "}"
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ExistQuantor                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ExistQuantor extends Quantor {
	Type[] {
        Get {
            return kAny
        }
    }
	
	match(facts, variables) {
		for ignore, theCondition in this.Conditions
			if theCondition.match(facts, variables)
				return true
				
		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    NotExistQuantor                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NotExistQuantor extends Quantor {
	Type[] {
        Get {
            return kNone
        }
    }
	
	match(facts, variables) {
		for ignore, theCondition in this.Conditions
			if theCondition.match(facts, variables)
				return false
				
		return true
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    OneQuantor                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class OneQuantor extends Quantor {
	Type[] {
        Get {
            return kOne
        }
    }
	
	match(facts, variables) {
		matched := 0
		
		for ignore, theCondition in this.Conditions
			if theCondition.match(facts, variables)
				matched += 1
				
		return (matched == 1)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    AllQuantor                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class AllQuantor extends Quantor {
	Type[] {
        Get {
            return kAll
        }
    }
	
	match(facts, variables) {
		matched := 0
		
		for ignore, theCondition in this.Conditions
			if theCondition.match(facts, variables)
				matched += 1
				
		return (matched == this.Conditions.Length())
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Predicate                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Predicate extends Condition {
	iLeftPrimary := kNotInitialized
	iOperator := kIdentical
	iRightPrimary := kNotInitialized
	
	Type[] {
		Get {
			return kPredicate
		}
	}
	
	LeftPrimary[facts := "__NotInitialized__"] {
		Get {
			if (facts != kNotInitialized)
				return this.iLeftPrimary.getValue(facts)
			else
				return this.iLeftPrimary
		}
	}
	
	Operator[] {
		Get {
			return this.iOperator
		}
	}
	
	RightPrimary[facts := "__NotInitialized__"] {
		Get {
			if ((facts != kNotInitialized) && (this.iRightPrimary != kNotInitialized))
				return this.iRightPrimary.getValue(facts)
			else
				return this.iRightPrimary
		}
	}
	
	__New(leftPrimary, operator := "__NotInitialized__", rightPrimary := "__NotInitialized__") {
		this.iLeftPrimary := leftPrimary
		this.iOperator := operator
		this.iRightPrimary := rightPrimary
		
		if (((operator == kNotInitialized) && (rightPrimary != kNotInitialized)) || ((operator != kNotInitialized) && (rightPrimary == kNotInitialized)))
			Throw "Inconsistent argument combination detected in Predicate.__New..."
	}
	
	getFacts(ByRef facts) {
		left := this.iLeftPrimary
		
		if (left.base == Variable)
			facts.Push(left.Variable[true])
		
		right := this.iRightPrimary
		
		if ((right != false) && (right.base == Variable))
			facts.Push(right.Variable[true])
	}
	
	match(facts, variables) {
		leftPrimary := this.LeftPrimary[facts]
		
		if (leftPrimary == kNotInitialized)
			return false
		else {
			rightPrimary := this.RightPrimary[facts]
			
			if ((this.Operator != kNotInitialized) && (rightPrimary == kNotInitialized))
				return false
			
			result := false
			
			switch this.Operator {
				case kNotInitialized:
					result := true
				case kEqual:
					result := (leftPrimary = rightPrimary)
				case kNotEqual:
					result := (leftPrimary != rightPrimary)
				case kIdentical:
					result := (leftPrimary == rightPrimary)
				case kLess:
					result := (leftPrimary < rightPrimary)
				case kLessOrEqual:
					result := (leftPrimary <= rightPrimary)
				case kGreater:
					result := (leftPrimary > rightPrimary)
				case kGreaterOrEqual:
					result := (leftPrimary >= rightPrimary)
				case kContains:
					if rightPrimary in leftPrimary
						result := true
					else
						result := inList(leftPrimary, rightPrimary)
				default:
					Throw "Unsupported comparison operator """ . this.Operator . """ detected in Predicate.match..."
			}
					
			if isInstance(this.LeftPrimary, Variable)
				variables.setValue(this.LeftPrimary, leftPrimary)
				
			if ((this.RightPrimary != kNotInitialized) && isInstance(this.RightPrimary, Variable))
				variables.setValue(this.RightPrimary, rightPrimary)
			
			return result
		}
	}
	
	toString(facts := "__NotInitialized__") {
		if (this.Operator == kNotInitialized)
			return ("[" . this.LeftPrimary.toString(facts) . "]")
		else
			return ("[" . this.LeftPrimary.toString(facts) . A_Space . this.Operator . A_Space . this.RightPrimary.toString(facts) "]")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Primary                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Primary extends Term {
	getValue(factsOrResultSet, default := "__NotInitialized__") {
		return this
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		Throw "Virtual method Primary.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Variable                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Variable extends Primary {
	iRootVariable := false
	iVariable := kNotInitialized
	iProperty := false
	
	RootVariable[] {
		Get {
			return this.iRootVariable
		}
	}
	
	Variable[fullPath := false] {
		Get {
			if (fullPath && this.Property) {
				return (this.Variable . "." . this.Property)
			}
			else
				return this.iVariable
		}
	}
	
	Property[asString := true] {
		Get {
			return (asString ? (this.iProperty ? values2String(".", this.iProperty*) : "") : this.iProperty)
		}
	}
	
	__New(name, property := false, rootVariable := false) {
		this.iVariable := name
		this.iProperty := ((property && (property != "")) ? string2Values(".", property) : false)
		this.iRootVariable := (rootVariable ? rootVariable : this)
		
		if ((!property && rootVariable) || (property && !rootVariable))
			Throw "Inconsistent argument combination detected in Variable.__New..."
		
		if (this.base != Variable)
			Throw "Subclassing of Variable is not allowed..."
	}
	
	getValue(variablesFactsOrResultSet, default := "__NotInitialized__") {
		value := variablesFactsOrResultSet.getValue(((variablesFactsOrResultSet.base == Facts) || ((variablesFactsOrResultSet.base == ProductionRule.Variables))) ? this : this.iRootVariable)
	
		if (IsObject(value) && ((value.base == Variable) || (value.base == Literal) || (value.base == Fact)))
			value := value.getValue(variablesFactsOrResultSet, value)
					
		if (value != kNotInitialized)
			return value
		else
			return default
	}
	
	injectValues(resultSet) {
		return this.toString(resultSet)
	}
	
	hasVariables() {
		return true
	}
	
	substituteVariables(variables) {
		var := this.Variable[true]
		
		if variables.HasKey(var)
			return variables[var]	
		else {
			if !this.iProperty
				newVariable := new Variable(var)
			else
				newVariable := new Variable(this.Variable, this.Property, this.RootVariable.substituteVariables(variables))
			
			variables[var] := newVariable

			return newVariable
		}
	}
	
	toString(variablesFactsOrResultSet := "__NotInitialized__") {
		property := this.Property
		name := this.Variable
		
		if InStr(name, "__Unnamed")
			name := ""
			
		if (variablesFactsOrResultSet == kNotInitialized)
			return ("?" . name . ((property != "") ? ("." . property) : ""))
		else {
			root := this.RootVariable
			value := ((variablesFactsOrResultSet.base == ProductionRule.Variables) ? this.getValue(variablesFactsOrResultSet) : root.getValue(variablesFactsOrResultSet))
			
			if (value == kNotInitialized)
				return "?" . name . ((property != "") ? ("." . property) : "") ; . " (" . &root . ")"
			else if isInstance(value, Term)
				return value.toString((variablesFactsOrResultSet.base == ProductionRule.Variables) ? kNotInitialized : variablesFactsOrResultSet) . ((property != "") ? ("." . property) : "")
			else
				return value
		}
	}
	
	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		
		if (ruleEngine.TraceLevel <= kTraceFull)
			ruleEngine.trace(kTraceFull, "Check whether " . var.toString() . " occurs in " . this.toString(resultSet))
		
		cyclic := (this.RootVariable.getValue(resultSet, this.RootVariable) == var)
		
		if (cyclic && (ruleEngine.TraceLevel <= kTraceFull))
			ruleEngine.trace(kTraceFull, "Cyclic reference detected for " . var.toString())
			
		return cyclic	
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Fact                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Fact extends Primary {
	iFact := kNotInitialized
	
	Fact[] {
		Get {
			return this.iFact
		}
	}
	
	__New(name) {
		this.iFact := name
		
		if (this.base != Fact)
			Throw "Subclassing of Fact is not allowed..."
	}
	
	getValue(factsOrResultSet, default := "__NotInitialized__") {
		if (factsOrResultSet.base == Facts)
			return factsOrResultSet.getValue(this.Fact, default)
		else 
			return this
	}
	
	isUnbound(factsOrResultSet) {
		if (factsOrResultSet.base == Facts)
			return (this.getValue(factsOrResultSet) = kNotInitialized)
		else if (factsOrResultSet.base == ResultSet)
			return (factsOrResultSet.KnowledgeBase.Facts.getValue(this.Fact, kNotInitialized) = kNotInitialized)
		else
			return false
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		if (factsOrResultSet.base == Facts)
			return factsOrResultSet.getValue(this.Fact)
		else if (factsOrResultSet.base == ResultSet)
			return factsOrResultSet.KnowledgeBase.Facts.getValue(this.Fact)
		else
			return false
	}
	
	unify(choicePoint, term) {
		local facts
		
		if (term.base == Literal)
			return (term.Literal = choicePoint.ResultSet.KnowledgeBase.Facts.getValue(this.Fact))
		else if (term.base == Fact) {
			facts := choicePoint.ResultSet.KnowledgeBase.Facts
			
			return (facts.getValue(term.Fact) = facts.getValue(this.Fact))
		}
		else
			return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Literal                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Literal extends Primary {
	iLiteral := kNotInitialized
	
	Literal[] {
		Get {
			return this.iLiteral
		}
	}
	
	__New(value) {
		this.iLiteral := value
		
		if (this.base != Literal)
			Throw "Subclassing of Literal is not allowed..."
	}
	
	getValue(factsOrResultSet := "__NotInitialized__") {
		if (factsOrResultSet.base == Facts)
			return this.Literal
		else
			return this
	}
	
	isUnbound(resultSetOrFacts) {
		return (this.iLiteral == kNotInitialized)
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		; return RegExReplace(this.Literal, "([^\\]) ", "$1\ ")
		return this.Literal
	}
	
	unify(choicePoint, term) {
		if (term.base == Literal)
			return (this.Literal = term.Literal)
		else if (term.base == Fact)
			return (this.Literal = choicePoint.ResultSet.KnowledgeBase.Facts.getValue(term.Fact))
		else
			return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Action                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Action {
	execute(knowledgeBase, variables) {
		Throw "Virtual method Action.execute must be implemented in a subclass..."
	}
	
	toString(facts := "__NotInitialized__") {
		Throw "Virtual method Action.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CallAction                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallAction extends Action {
	iFunction := kNotInitialized
	iArguments := []
	
	Action[] {
		Get {
			return kCall
		}
	}
	
	Function[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iFunction
			else
				return this.iFunction.getValue(variablesOrFacts)
		}
	}
	
	Arguments[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if variablesOrFacts is Number
				return this.iArguments[variablesOrFacts]
			else if (variablesOrFacts == kNotInitialized)
				return this.iArguments
			else
				this.getValues(variablesOrFacts)
		}
	}
	
	__New(function, arguments) {
		this.iFunction := function
		this.iArguments := arguments
	}
	
	execute(knowledgeBase, variables) {
		local function
		local facts := knowledgeBase.Facts
		
		if isInstance(this.Function, Variable)
			function := this.Function[variables]
		else
			function := this.Function[facts]
		
		arguments := []
		
		for ignore, argument in this.Arguments
			if isInstance(argument, Variable)
				arguments.Push(argument.toString(variables))
			else
				arguments.Push(argument.toString(facts))
		
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
			knowledgeBase.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", arguments*) . ")")
		
		%function%(knowledgeBase, arguments*)
	}
	
	getValues(facts) {
		values := []
		
		for ignore, argument in this.Arguments
			values.Push(argument.getValue(facts, argument))
		
		return values
	}
	
	toString(facts := "__NotInitialized__") {
		arguments := []
		
		for index, argument in this.Arguments
			arguments.Push(argument.toString(facts))
			
		return ("(" . this.Action . A_Space .  this.Function.toString(facts) . "(" . values2String(", ", arguments*) . "))")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProveAction                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProveAction extends CallAction {
	iProveAll := false
	
	Action[] {
		Get {
			return (this.iProveAll ? kProveAll : kProve)
		}
	}
	
	Functor[variablesOrFacts := "__NotInitialized__"] {
		Get {
			return this.Function[variablesOrFacts]
		}
	}
	
	__New(function, arguments, proveAll := false) {
		this.iProveAll := proveAll
		
		base.__New(function, arguments)
	}
	
	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local resultSet
		
		arguments := []
		
		for ignore, argument in this.Arguments
			if isInstance(argument, Variable)
				arguments.Push(new Literal(argument.toString(variables)))
			else
				arguments.Push(argument.substituteVariables(variables))
		
		goal := new Compound(isInstance(this.Functor, Variable) ? this.Functor[variables] : this.Functor[facts], arguments)
		
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
			knowledgeBase.RuleEngine.trace(kTraceMedium, "Activate reduction rules with goal " . goal.toString())
		
		resultSet := knowledgeBase.prove(goal)
		
		if (resultSet && this.iProveAll)
			Loop
				if !resultSet.nextResult()
					break
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetFactAction                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetFactAction extends Action {
	iFact := kNotInitialized
	iValue := kNotInitialized
	
	Fact[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iFact
			else
				return this.iFact.getValue(variablesOrFacts)
		}
	}
	
	Value[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iValue
			else
				return this.iValue.getValue(variablesOrFacts)
		}
	}
	
	__New(fact, value := "__NotInitialized__") {
		this.iFact := fact
		this.iValue := ((value == kNotInitialized) ? new Literal(true) : value)
	}
	
	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local fact := (isInstance(this.Fact, Variable) ? this.Fact[variables] : this.Fact[facts])
		value := (isInstance(this.Value, Variable) ? this.Value[variables] : this.Value[facts])
		
		facts.setFact(fact, value)
	}
	
	toString(facts := "__NotInitialized__") {
		if (this.Value == this.Fact)
			return ("(Set: " . this.Fact.toString(facts) . ")")
		else
			return ("(Set: " . this.Fact.toString(facts) . ", " . this.Value.toString(facts) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetComposedFactAction                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetComposedFactAction extends Action {
	iFact := kNotInitialized
	iValue := kNotInitialized
	
	Fact[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iFact
			else {
				result := ""
			
				for index, component in this.iFact {
					if (index > 1)
						result .= "."
					
					result .= component.getValue(variablesOrFacts)
				}
				
				return result
			}
		}
	}
	
	Value[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iValue
			else
				return this.iValue.getValue(variablesOrFacts)
		}
	}
	
	__New(arguments*) {
		this.iValue := arguments.Pop()
		this.iFact := arguments
	}
	
	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local fact := ""
		
		for index, component in this.Fact {
			if (index > 1)
				fact .= "."
		
			fact .= (isInstance(component, Variable) ? component.getValue(variables) : component.getValue(facts))
		}
		
		value := (isInstance(this.Value, Variable) ? this.Value[variables] : this.Value[facts])
		
		facts.setFact(fact, value)
	}
	
	toString(facts := "__NotInitialized__") {
		local fact := ""
			
		for index, component in this.Fact {
			if (index > 1)
				fact .= "."
			
			fact .= component.toString(facts)
		}

		return ("(Set: " . fact . ", " . this.Value.toString(facts) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearFactAction                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearFactAction extends Action {
	iFact := kNotInitialized
	
	Fact[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iFact
			else
				return this.iFact.getValue(variablesOrFacts)
		}
	}
	
	__New(fact) {
		this.iFact := fact
	}
	
	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local fact := (isInstance(this.Fact, Variable) ? this.Fact[variables] : this.Fact[facts])
		
		facts.clearFact(fact)
	}
	
	toString(facts := "__NotInitialized__") {
		return ("(Clear: " . this.Fact.toString(facts) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearComposedFactAction                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearComposedFactAction extends Action {
	iFact := kNotInitialized
	
	Fact[variablesOrFacts := "__NotInitialized__"] {
		Get {
			if (variablesOrFacts == kNotInitialized)
				return this.iFact
			else {
				result := ""
			
				for index, component in this.iFact {
					if (index > 1)
						result .= "."
					
					result .= component.getValue(variablesOrFacts)
				}
				
				return result
			}
		}
	}
	
	__New(arguments*) {
		this.iFact := arguments
	}
	
	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local fact := ""
		
		for index, component in this.Fact {
			if (index > 1)
				fact .= "."
		
			fact .= (isInstance(component, Variable) ? component.getValue(variables) : component.getValue(facts))
		}
		
		facts.clearFact(fact)
	}
	
	toString(facts := "__NotInitialized__") {
		local fact := ""
			
		for index, component in this.Fact {
			if (index > 1)
				fact .= "."
			
			fact .= component.toString(facts)
		}
		
		return ("(Clear: " . fact . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Term                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Term {
	getValue(factsOrResultSet, default := "__NotInitialized__") {
		return this
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		Throw "Virtual method Term.toString must be implemented in a subclass..."
	}
	
	injectValues(resultSet) {
		return this
	}
	
	isUnbound(resultSetOrFacts) {
		return (this.getValue(resultSetOrFacts) == kNotInitialized)
	}
	
	hasVariables() {
		return false
	}
	
	substituteVariables(variables) {
		return this
	}
	
	unify(choicePoint, term) {
		return (this == term)
	}
	
	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		
		if (ruleEngine.TraceLevel <= kTraceFull)
			ruleEngine.trace(kTraceFull, "Check whether " . var.toString() . " occurs in " . this.toString(resultSet))
			
		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Compound                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Compound extends Term {
	iFunctor := ""
	iArguments := []
	iHasVariables := false
	
	Functor[] {
		Get {
			return this.iFunctor
		}
	}
	
	Arity[] {
		Get {
			return this.Arguments.Length()
		}
	}
	
	Arguments[resultSet := "__NotInitialized__"] {
		Get {
			if resultSet is Number
				return this.iArguments[resultSet]
			if (resultSet == kNotInitialized)
				return this.iArguments
			else
				return this.getValues(resultSet)
		}
	}
	
	__New(functor, arguments) {
		this.iFunctor := functor
		this.iArguments := arguments
		this.iHasVariables := this.hasVariables()
		
		if ((this.base != Compound) && (this.base != Cut) && (this.base != Fail))
			Throw "Subclassing of Compound is not allowed..."
	}
	
	toString(resultSet := "__NotInitialized__") {
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(resultSet))
		
		return (this.Functor . "(" . values2String(", ", arguments*) . ")")
	}
	
	getValues(resultSet) {
		values := []
		
		for ignore, argument in this.Arguments
			values.Push(argument.getValue(resultSet, argument))
			
		return values
	}
	
	injectValues(resultSet) {
		arguments := this.Arguments[resultSet]
		
		if (arguments.Length() == 0)
			return this
		else
			return new Compound(this.Functor, arguments)
	}
	
	hasVariables() {
		for ignore, argument in this.Arguments
			if argument.hasVariables()
				return true

		return false
	}
	
	substituteVariables(variables) {
		if this.iHasVariables {
			arguments := []
			
			for ignore, argument in this.Arguments
				arguments.Push(argument.substituteVariables(variables))
			
			return new Compound(this.Functor, arguments)
		}
		else
			return this
	}
	
	unify(choicePoint, term) {
		if ((term.base == Compound) && (this.Functor == term.Functor) && (this.Arity == term.Arity)) {
			termArguments := term.Arguments
			
			for index, argument in this.Arguments
				if !choicePoint.ResultSet.unify(choicePoint, argument, termArguments[index])
					return false
				
			return true
		}
		else
			return false
	}
	
	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		
		if (ruleEngine.TraceLevel <= kTraceFull)
			ruleEngine.trace(kTraceFull, "Check whether " . var.toString() . " occurs in " . this.toString(resultSet))
			
		for ignore, argument in this.Arguments
			if argument.getValue(resultSet, argument).occurs(resultSet, var)
				return true
				
		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Cut                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Cut extends Compound {
	__New() {
		base.__New("!", [])
		
		if (this.base != Cut)
			Throw "Subclassing of Cut is not allowed..."
	}
	
	toString(resultSet := "__NotInitialized__") {
		return "!"
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Fail                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Fail extends Compound {
	__New() {
		base.__New("fail", [])
		
		if (this.base != Fail)
			Throw "Subclassing of Fail is not allowed..."
	}
	
	toString(resultSet := "__NotInitialized__") {
		return "fail"
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Pair                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Pair extends Term {
	iLeftTerm := false
	iRightTerm := false
	iHasVariables := false
	
	LeftTerm[] {
		Get {
			return this.iLeftTerm
		}
	}
	
	RightTerm[] {
		Get {
			return this.iRightTerm
		}
	}
	
	__New(leftTerm, rightTerm) {
		this.iLeftTerm := leftTerm
		this.iRightTerm := rightTerm
		this.iHasVariables := this.hasVariables()
		
		if (this.base != Pair)
			Throw "Subclassing of Pair is not allowed..."
	}
	
	toString(resultSet := "__NotInitialized__") {
		result := "["
	
		next := this
		
		Loop {
			left := next.LeftTerm.toString(resultSet)
			right := next.RightTerm.getValue(resultSet, next.RightTerm)
			
			separator := ((right.base != Nil) ? ((right.base == Pair) ? ", " : " | ") : "")
		
			result := result . left . separator
			
			if (right.base != Pair) {
				if (right.base != Nil)
					result := result . next.RightTerm.toString(resultSet)
				
				break
			}
			else
				next := right
		}
		
		return (result . "]")
	}
	
	injectValues(resultSet) {
		return new Pair(this.LeftTerm.injectValues(resultSet), this.RightTerm.injectValues(resultSet))
	}
	
	hasVariables() {
		return (this.LeftTerm.hasVariables() || this.iRightTerm.hasVariables())
	}
	
	substituteVariables(variables) {
		if this.iHasVariables
			return new Pair(this.LeftTerm.substituteVariables(variables), this.RightTerm.substituteVariables(variables))
		else
			return this
	}
	
	unify(choicePoint, term) {
		local resultSet
		
		if (term.base == Pair) {
			resultSet := choicePoint.ResultSet
			
			return (resultSet.unify(choicePoint, this.LeftTerm, term.LeftTerm) && resultSet.unify(choicePoint, this.RightTerm, term.RightTerm))
		}
		else
			return false
	}
	
	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		
		if (ruleEngine.TraceLevel <= kTraceFull)
			ruleEngine.trace(kTraceFull, "Check whether " . var.toString() . " occurs in " . this.toString(resultSet))
			
		leftTerm := this.LeftTerm
		rightTerm := this.RightTerm
		
		return (leftTerm.getValue(resultSet, leftTerm).occurs(resultSet, var) || rightTerm.getValue(resultSet, rightTerm).occurs(resultSet, var))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Nil                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Nil extends Term {
	__New() {
		if (this.base != Nil)
			Throw "Subclassing of Nil is not allowed..."
	}
	
	toString(resultSet := "__NotInitialized__") {
		return "[]"
	}
	
	unify(choicePoint, term) {
		return (term.base == Nil)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Rule                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Rule {
	Type[] {
        Get {
            Throw "Virtual property Rule.Type must be implemented in a subclass..."
        }
    }
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProductionRule                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProductionRule extends Rule {
	iPriority := 0
	iConditions := false
	iActions := []
	
	class Variables {
		iVariables := {}
		
		setValue(variable, value) {
			this.iVariables[variable.Variable[true]] := value
		}
		
		getValue(variable, default := "__NotInitialized__") {
			fullName := variable.Variable[true]
			
			if this.iVariables.HasKey(fullName)
				return this.iVariables[fullName]
			else
				return default
		}
	}
	
	Type[] {
        Get {
            return kProduction
        }
    }
	
	Priority[] {
		Get {
			return this.iPriority
		}
	}
	
	Conditions[] {
		Get {
			return this.iConditions
		}
	}
	
	Actions[] {
		Get {
			return this.iActions
		}
	}
	
	__New(conditions, actions, priority := 0) {
		this.iConditions := conditions
		this.iActions := actions
		this.iPriority := priority
	}
	
	getFacts() {
		local facts := []
		
		for ignore, theCondition in this.Conditions
			theCondition.getFacts(facts)
				
		return facts		
	}
	
	match(facts) {
		variables := new this.Variables()
		
		for ignore, theCondition in this.Conditions
			if !theCondition.match(facts, variables)
				return false
				
		return variables
	}
	
	fire(knowledgeBase, variables) {
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Firing rule " . this.toString())
		
		for ignore, theAction in this.Actions
			theAction.execute(knowledgeBase, variables)
	}
	
	produce(knowledgeBase) {
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Trying rule " . this.toString())
		
		variables := this.match(knowledgeBase.Facts)
		
		if variables {
			this.fire(knowledgeBase, variables)
			
			return true
		}
		else
			return false
	}
	
	toString(facts := "__NotInitialized__") {
		priority := this.Priority
		conditions := ((priority != 0) ? ["Priority: " . priority] : [])
		actions := []
		
		for ignore, theCondition in this.Conditions
			conditions.Push(theCondition.toString(facts))
		
		for ignore, theAction in this.Actions
			actions.Push(theAction.toString(facts))
			
		return values2String(", ", conditions*) . " => " . values2String(", ", actions*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ReductionRule                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ReductionRule extends Rule {
	iHead := false
	iTail := []
	iHasVariables := false
	
	Type[] {
        Get {
            return kReduction
        }
    }
	
	Head[] {
		Get {
			return this.iHead
		}
	}
	
	Tail[] {
		Get {
			return this.iTail
		}
	}
	
	__New(head, tail) {
		this.iHead := head
		this.iTail := tail
		this.iHasVariables := this.hasVariables()
	}
	
	toString(resultSet := "__NotInitialized__") {
		tail := this.Tail
		
		if (tail && (tail.Length() > 0)) {
			terms := []
			
			for ignore, theTerm in tail
				terms.Push(theTerm.toString(resultSet))
				
			return (this.Head.toString(resultSet) . " <= " . values2String(", ", terms*))
		}
		else
			return this.Head.toString(resultSet)
	}
	
	hasVariables() {
		if this.Head.hasVariables()
			return true
			
		for ignore, theTerm in this.Tail
			if theTerm.hasVariables()
				return true
				
		return false
	}
	
	substituteVariables() {
		if this.iHasVariables {
			variables := {}
			terms := []
			
			for ignore, theTerm in this.Tail
				terms.Push(theTerm.substituteVariables(variables))
				
			return new ReductionRule(this.Head.substituteVariables(variables), terms)
		}
		else
			return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ResultSet                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ResultSet {
	iKnowledgeBase := false
	iChoicePoint := false
	iExhausted := false
	
	iBindings := {}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	Rules[] {
		Get {
			return this.KnowledgeBase.Rules
		}
	}
	
	RuleEngine[] {
		Get {
			return this.KnowledgeBase.RuleEngine
		}
	}
	
	ChoicePoint[retry := false] {
		Get {
			local choicePoint := this.iChoicePoint
			
			if retry
				Loop {
					next := choicePoint.next()
					
					if next
						choicePoint := next
					else
						break
				}
			
			return choicePoint
		}
	}
	
	__New(knowledgeBase, goal) {
		this.iKnowledgeBase := knowledgeBase
		
		this.iChoicePoint := this.createChoicePoint(goal)
	}
		
	resetChoicePoint(choicePoint) {
	}
	
	setVariable(choicePoint, var, value) {
		var := var.RootVariable
		bindings := this.iBindings
		
		choicePoint.saveVariable(var, (bindings.HasKey(var) ? bindings[var] : kNotInitialized))
		
		bindings[var] := value
	}
	
	resetVariable(choicePoint, var, oldValue) {
		if (oldValue == kNotInitialized)
			this.iBindings.Delete(var)
		else
			this.iBindings[var] := oldValue
			
		if (this.RuleEngine.TraceLevel <= kTraceFull)
			this.RuleEngine.trace(kTraceFull, "Reset " . var.toString() . " to " . oldValue)
	}
	
	unify(choicePoint, termA, termB) {
		if (termA.base == Variable)
			termA := termA.RootVariable
		
		if (termB.base == Variable)
			termB := termB.RootVariable
			
		termA := termA.getValue(this, termA)
		termB := termB.getValue(this, termB)
		
		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			this.RuleEngine.trace(kTraceMedium, "Unifying " . termA.toString() . " with " . termB.toString())
		
		if (termA.base == Variable) {
			if (this.KnowledgeBase.OccurCheck && termB.occurs(this, termA))
				return false
			
			if (this.RuleEngine.TraceLevel <= kTraceFull)
				this.RuleEngine.trace(kTraceFull, "Binding " . termA.toString(this) . " to " . termB.toString(this))
			
			this.setVariable(choicePoint, termA, termB)
		}
		else if (termB.base == Variable) {
			if (this.KnowledgeBase.OccurCheck && termA.occurs(this, termB))
				return false
					
			if (this.RuleEngine.TraceLevel <= kTraceFull)
				this.RuleEngine.trace(kTraceFull, "Binding " . termB.toString() . " to " . termA.toString())
			
			this.setVariable(choicePoint, termB, termA)
		}
		else
			return termA.unify(choicePoint, termB)
			
		return true
	}
	
	nextResult() {
		local ruleEngine := this.RuleEngine
		local choicePoint

		tickCount := A_TickCount
		
		if this.iExhausted
			return false
			
		choicePoint := this.ChoicePoint[true]
			
		Loop {
			if choicePoint.nextChoice() {
				choicePoint := choicePoint.next()
				
				if choicePoint {
					if (ruleEngine.TraceLevel <= kTraceMedium)
						ruleEngine.trace(kTraceMedium, "Targeting " . choicePoint.Goal.toString(this))
				}
				else {
					if (ruleEngine.TraceLevel <= kTraceMedium)
						ruleEngine.trace(kTraceMedium, "Query yields " . this.ChoicePoint.Goal.toString(this))
		
					if (ruleEngine.TraceLevel <= kTraceMedium)
						showMessage("NextResult took " . (A_TickCount - tickCount) . " milliseconds...")
			
					return true
				}
			}
			else {
				choicePoint := choicePoint.previous()
				
				if !choicePoint {
					if (ruleEngine.TraceLevel <= kTraceMedium) {
						ruleEngine.trace(kTraceMedium, "Query is exhausted")
						
						showMessage("NextResult took " . (A_TickCount - tickCount) . " milliseconds...")
					}
					
					this.iExhausted := true
					
					return false
				}
			}
		}
	}
	
	getValue(var, default := "__NotInitialized__") {
		local ruleEngine := this.RuleEngine
		bindings := this.iBindings
		
		last := default
		
		Loop {
			var := var.RootVariable
			
			if (ruleEngine.TraceLevel <= kTraceFull)
				ruleEngine.trace(kTraceFull, "Look for value of " . var.toString()) ; . "(" . &var . ")")
			
			if bindings.HasKey(var) {
				value := bindings[var]
				
				if (value.base == Variable) {
					root := value.RootVariable
					
					if (ruleEngine.TraceLevel <= kTraceFull)
						ruleEngine.trace(kTraceFull, "Found variable " . value.toString()) ; . "(" . &root . ")")
						
					last := value
					var := value
				}
				else {
					if (ruleEngine.TraceLevel <= kTraceFull)
						ruleEngine.trace(kTraceFull, "Found term " . value.toString()) ; . "(" . &value . ")")
					
					return value
				}
			}
			else {
				if (ruleEngine.TraceLevel <= kTraceFull)
					ruleEngine.trace(kTraceFull, var.toString() . " is unbound - return " . (IsObject(last) ? last.toString() : last))
				
				return last
			}
		}
	}
	
	createChoicePoint(goal, environment := false) {
		functor := goal.Functor
		
		switch functor {
			case "produce":
				return new ProduceChoicePoint(this, goal, environment)
			case "call":
				return new CallChoicePoint(this, goal, environment)
			case "set":
				return new SetFactChoicePoint(this, goal, environment)
			case "clear":
				return new ClearFactChoicePoint(this, goal, environment)
			case "!":
				return new CutChoicePoint(this, goal, environment)
			case "fail":
				return new FailChoicePoint(this, goal, environment)
			default:
				builtin := inList(kBuiltinFunctors, functor)
				
				if (builtin && ((kBuiltinAritys[builtin] == goal.Arity) || (kBuiltinAritys[builtin] == -1)))
					return new CallChoicePoint(this, goal, environment)
				else
					return new RulesChoicePoint(this, goal, environment)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           ChoicePoint                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ChoicePoint {
	iPreviousChoicePoint := false
	iNextChoicePoint := false
	
	iEnvironment := false
	iSavedVariables := {}
	
	iResultSet := false
	iGoal := false
	
	ResultSet[] {
		Get {
			return this.iResultSet
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.ResultSet.KnowledgeBase
		}
	}
	
	Goal[] {
		Get {
			return this.iGoal
		}
	}
	
	Environment[] {
		Get {
			return this.iEnvironment
		}
	}
	
	__New(resultSet, goal, environment) {
		this.iResultSet := resultSet
		this.iGoal := goal
		this.iEnvironment := environment
	}
	
	nextChoice() {
		Throw "Virtual method ChoicePoint.nextChoice must be implemented in a subclass..."
	}
	
	saveVariable(var, value) {
		this.iSavedVariables[var] := value
	}
	
	resetVariables() {
		local resultSet := this.ResultSet
		
		for var, value in this.iSavedVariables
			resultSet.resetVariable(this, var, value)
			
		this.iSavedVariables := {}
	}
	
	reset() {
		this.resetVariables()
		
		this.ResultSet.resetChoicePoint(this)
	}
	
	cut() {
		this.reset()
	}
	
	insert(afterChoicePoint) {
		local resultSet := this.ResultSet
		
		if (resultSet.RuleEngine.TraceLevel <= kTraceMedium)
			resultSet.RuleEngine.trace(kTraceMedium, "Inserting goal " . this.Goal.toString(resultSet) . " after " . afterChoicePoint.Goal.toString(resultSet))
		
		this.iNextChoicePoint := afterChoicePoint.iNextChoicePoint
		this.iPreviousChoicePoint := afterChoicePoint
		
		afterChoicePoint.iNextChoicePoint := this
			
		if this.iNextChoicePoint
			this.iNextChoicePoint.iPreviousChoicePoint := this
	}
	
	remove() {
		next := this.iNextChoicePoint
		previous := this.iPreviousChoicePoint
		
		if next
			next.iPreviousChoicePoint := previous
			
		if previous
			previous.iNextChoicePoint := next
	}
	
	previous() {
		return this.iPreviousChoicePoint
	}
	
	next() {
		return this.iNextChoicePoint
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    RulesChoicePoint                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RulesChoicePoint extends ChoicePoint {
	iReductions := []
	iSubstitutedReductions := {}
	iNextRuleIndex := 1
	
	iSubChoicePoints := []
		
	Reductions[reset := false] {
		Get {
			local ruleEngine
			local goal
			local resultSet
			
			if reset {
				resultSet := this.ResultSet
				goal := this.Goal
				
				this.iReductions := this.ResultSet.Rules.Reductions[goal.Functor, goal.Arity]
				
				ruleEngine := resultSet.RuleEngine
				
				if (ruleEngine.TraceLevel <= kTraceLight) {
					ruleEngine.trace("Trying to prove " . goal.toString(resultSet))
					ruleEngine.trace(kTraceLight, this.iReductions.Length() . " rules selected for " . goal.toString(resultSet))
				}
			}
				
			return this.iReductions
		}
	}
	
	nextChoice() {
		local rule
		local resultSet
		
		reductions := this.Reductions[this.iNextRuleIndex == 1]
		
		Loop {
			index := this.iNextRuleIndex++
		
			if (index > 1)
				this.reset()
			
			if (index > reductions.Length()) {
				this.iNextRuleIndex := 1
				
				return false
			}
			else {
				resultSet := this.ResultSet
				
				rule := reductions[index]
				
				if !this.iSubstitutedReductions.HasKey(rule)
					this.iSubstitutedReductions[rule] := rule.substituteVariables()
					
				rule := this.iSubstitutedReductions[rule]
			
				if (resultSet.RuleEngine.TraceLevel <= kTraceLight)
					resultSet.RuleEngine.trace(kTraceLight, "Trying rule " . rule.toString())
				
				if resultSet.unify(this, this.Goal, rule.Head) {
					this.addSubChoicePoints(rule.Tail)
						
					return true
				}
			}
		}
	}
	
	addSubChoicePoints(goals) {
		local choicePoint
		
		this.iSubChoicePoints := []

		previous := this
		
		for ignore, theGoal in goals {
			choicePoint := this.ResultSet.createChoicePoint(theGoal, this)
		
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Pushing subgoal " . theGoal.toString(this.ResultSet))
			
			this.iSubChoicePoints.Push(choicePoint)
			
			choicePoint.insert(previous)
			
			previous := choicePoint
		}
	}
	
	removeSubChoicePoints() {
		for ignore, theChoicePoint in this.iSubChoicePoints
			theChoicePoint.remove()
	}
	
	reset() {
		this.removeSubChoicePoints()
		
		base.reset()
	}
	
	cut() {
		base.cut()
		
		this.iNextRuleIndex := 1
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           FactChoicePoint                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FactChoicePoint extends ChoicePoint {
	iFact := false
	iOldValue := kNotInitialized
	iFirst := true
	iClear := false
	
	__New(resultSet, goal, environment, clear := false) {
		this.iClear := clear
		
		base.__New(resultSet, goal, environment, true)
	}
	
	nextChoice() {
		local resultSet
		local knowledgeBase
		local facts
		local fact
		
		if this.iFirst {
			this.iFirst := false
		
			resultSet := this.ResultSet
			knowledgeBase := resultSet.KnowledgeBase
			facts := knowledgeBase.Facts
			arguments := this.Goal.Arguments
			length := arguments.Length()
			
			if this.iClear {
				if (length == 1)
					fact := arguments[1].toString(resultSet)
				else {			
					fact := ""
						
					for index, argument in arguments {
						if (index > 1)
							fact .= "."
						
						fact .= argument.toString(resultSet)
					}
				}
				
				this.iFact := fact
				this.iOldValue := facts.getValue(fact)
				
				facts.clearFact(fact)
			}
			else {
				if (length <= 2)
					fact := arguments[1].toString(resultSet)
				else {			
					fact := ""
						
					for index, argument in arguments {
						if (index == length)
							break
							
						if (index > 1)
							fact .= "."
						
						fact .= argument.toString(resultSet)
					}
				}
				
				value := ((length >= 2) ? arguments[length].toString(resultSet) : true)
			
				this.iFact := fact
				this.iOldValue := facts.getValue(fact)
				
				facts.setFact(fact, value)
			}
			
			return true
		}
		else {
			this.reset()
			
			return false
		}
	}
	
	reset() {
		base.reset()
		
		this.iFirst := true
	}
	
	resetVariables() {
		local facts
		
		base.resetVariables()
		
		if !this.ResultSet.KnowledgeBase.DeterministicFacts {
			facts := this.ResultSet.KnowledgeBase.Facts
			
			if (this.iOldValue != kNotInitialized)
				facts.setFact(this.iFact, this.iOldValue)
			else
				facts.clearFact(this.iFact)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetFactChoicePoint                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetFactChoicePoint extends FactChoicePoint {
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearFactChoicePoint                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearFactChoicePoint extends FactChoicePoint {
	__New(resultSet, goal, environment) {
		base.__New(resultSet, goal, environment, true)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CallChoicePoint                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallChoicePoint extends ChoicePoint {
	iBuiltin := false
	iFirst := true
	
	__New(ruleSet, goal, environment) {
		base.__New(ruleSet, goal, environment)
		
		this.iBuiltin := (goal.Functor != "call")
	}
	
	nextChoice() {
		if this.iFirst {
			this.iFirst := false
		
			if this.iBuiltin
				result := this.builtinCall()
			else
				result := this.foreignCall()
			
			if !result
				this.reset()
			
			return result
		}
		else {
			this.reset()
		
			return false
		}
	}
	
	reset() {
		base.reset()
		
		this.iFirst := true
	}
	
	foreignCall() {
		local resultSet := this.ResultSet
		local function
		
		values := []
		builtin := false
		
		for index, theTerm in this.Goal.Arguments
			if (index == 1) {
				function := theTerm.getValue(resultSet, theTerm).toString(resultSet)
				
				builtin := inList(kBuiltinFunctors, function)
			}
			else {
				value := theTerm.getValue(resultSet, theTerm)
				
				if !builtin
					value := value.toString(resultSet)
					
				values.Push(value)
			}
		
		if (resultSet.RuleEngine.TraceLevel <= kTraceMedium) {
			if builtin {
				newValues := []
			
				for index, value in values
					newValues.Push(value.toString(resultSet))
			
				resultSet.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", newValues*) . ")")
			}
			else
				resultSet.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", values*) . ")")
		}
		
		if builtin
			function := kBuiltinFunctions[inList(kBuiltinFunctors, function)]
		
		return %function%(this, values*)
	}
	
	builtinCall() {
		local resultSet := this.ResultSet
		local function := this.Goal.Functor
		
		values := []
		
		for index, theTerm in this.Goal.Arguments
			values.Push(theTerm.getValue(resultSet, theTerm))
		
		if (resultSet.RuleEngine.TraceLevel <= kTraceMedium) {
			newValues := []
			
			for index, value in values
				newValues.Push(value.toString(resultSet))
					
			resultSet.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", newValues*) . ")")
		}
		
		function := kBuiltinFunctions[inList(kBuiltinFunctors, function)]
		
		return %function%(this, values*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProduceChoicePoint                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProduceChoicePoint extends ChoicePoint {
	iFirst := true
	
	nextChoice() {
		local knowledgeBase
		
		if this.iFirst {
			this.iFirst := false
		
			knowledgeBase := this.ResultSet.KnowledgeBase
			
			if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
				knowledgeBase.RuleEngine.trace(kTraceMedium, "Activate production rules")
			
			return knowledgeBase.produce()
		}
		else
			return false
	}
	
	reset() {
		base.reset()
		
		this.iFirst := true
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CutChoicePoint                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CutChoicePoint extends ChoicePoint {
	iFirst := true
	
	nextChoice() {
		if this.iFirst {
			this.iFirst := false
		
			return true
		}
		else
			return false
	}
	
	reset() {
		base.reset()
		
		this.iFirst := true
	}
	
	previous() {
		local resultSet := this.ResultSet
		local ruleEngine := resultSet.RuleEngine
	
		environment := this.Environment
		candidate := base.previous()
		
		Loop {
			if !candidate
				return false
			
			if (ruleEngine.TraceLevel <= kTraceLight)
				ruleEngine.trace(kTraceLight, "Cutting " . candidate.Goal.toString(resultSet))
		
			candidate.cut()
			
			if (candidate == environment)				
				return candidate.previous()
			else
				candidate := candidate.previous()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    FailChoicePoint                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FailChoicePoint extends ChoicePoint {
	nextChoice() {
		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    KnowledgeBase                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class KnowledgeBase {
	iRuleEngine := false
	
	iFacts := false
	iRules := false
	
	iOccurCheck := false
	iDeterministicFacts := true
	
	RuleEngine[] {
		Get {
			return this.iRuleEngine
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this
		}
	}
	
	Facts[] {
		Get {
			return this.iFacts
		}
	}
	
	Rules[] {
		Get {
			return this.iRules
		}
	}
	
	OccurCheck[] {
		Get {
			return this.iOccurCheck
		}
	}
	
	DeterministicFacts[] {
		Get {
			return this.iDeterministicFacts
		}
	}
	
	__New(ruleEngine, facts, rules) {
		this.iRuleEngine := ruleEngine
		this.iFacts := facts
		this.iRules := rules
		
		production := rules.Productions[false]
		
		while production {
			this.registerRuleFacts(production.Rule)
			
			production := production.Next[false]
		}
	}
	
	registerRuleFacts(rule) {
		local facts := this.Facts
		
		for ignore, theFact in rule.getFacts() {
			fRules := facts.getObserver(theFact)
			
			if !fRules {
				fRules := new FactRules(this, theFact)
				
				facts.registerObserver(theFact, fRules)
			}
			
			fRules.addRule(rule)
		}
	}
	
	deregisterRuleFacts(rule) {
		local facts := this.Facts
		
		for ignore, theFact in rule.getFacts() {
			fRules := facts.getObserver(theFact)
			
			if fRules {
				fRules.removeRule(rule)
				
				if (fRules.Rules.Length() == 0)
					facts.deregisterObserver(theFact, fRules)
			}
			else
				Throw "Inconsistency detected in KnowledgeBase.deregisterRuleFacts..."
		}
	}
	
	factChanged(fact, rules) {
		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			this.RuleEngine.trace(kTraceMedium, "Fact """ . fact . """ changed - reactivating " . rules.Length() . " rules")
					
		this.Rules.activateRules(rules)
	}
	
	addRule(rule) {
		this.Rules.addRule(rule)
		
		if (rule.Type == kProduction)
			this.registerRuleFacts(rule)
	}
	
	removeRule(rule) {
		this.Rules.removeRule(rule)
		
		if (rule.Type == kProduction)
			this.deregisterRuleFacts(rule)
	}
	
	setValue(fact, value) {
		this.Facts.setValue(fact, value)
	}

	getValue(fact, default := "__NotInitialized__") {
		return this.Facts.getValue(fact, default)
	}
	
	setFact(fact, value) {
		this.Facts.setFact(fact, value)
	}
	
	clearFact(fact) {
		this.Facts.clearFact(fact)
	}
	
	hasFact(fact) {
		return this.Facts.hasFact(fact)
	}
	
	addFact(fact, value) {
		this.Facts.addFact(fact, value)
	}
	
	removeFact(fact) {
		this.Facts.removeFact(fact)
		
		this.removeFact := this.clearFact
	}
	
	produce() {
		local facts := this.Facts
		local rules := this.Rules
		local result := false
		
		tickCount := A_TickCount
		
		Loop {
			generation := facts.Generation
			produced := false
			
			ruleEntry := rules.Productions
			
			Loop {
				if !ruleEntry
					break
					
				ruleEntry.deactivate()
				
				matched := ruleEntry.Rule.produce(this)
				
				if (!ruleEntry.Active && (this.RuleEngine.TraceLevel <= kTraceMedium))
					this.RuleEngine.trace(kTraceMedium, "Deactivating rule " . ruleEntry.Rule.toString())
				
				if matched {
					result := true
					
					if (generation != facts.Generation) {
						produced := true
							
						break
					}
				}
					
				ruleEntry := ruleEntry.Next
			}
			
			if !produced
				break
		}
		
		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			showMessage("Produce took " . (A_TickCount - tickCount) . " milliseconds...")
		
		return result
	}
	
	prove(goal) {
		local resultSet
		
		tickCount := A_TickCount
		
		resultSet := this.RuleEngine.createResultSet(this, goal)
		
		if resultSet.nextResult() {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				showMessage("Prove took " . (A_TickCount - tickCount) . " milliseconds...")
			
			return resultSet
		}
		else
			return false
	}
	
	enableOccurCheck() {
		this.iOccurCheck := true
	}
	
	disableOccurCheck() {
		this.iOccurCheck := false
	}
	
	enableDeterministicFacts() {
		this.iDeterministicFacts := true
	}
	
	disableDeterministicFacts() {
		this.iDeterministicFacts := false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Facts                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Facts {
	iRuleEngine := false
	iFacts := {}
	iObservers := {}
	iGeneration := 0
	
	RuleEngine[] {
		Get {
			return this.iRuleEngine
		}
	}
	
	Facts[] {
		Get {
			return this.iFacts
		}
	}
	
	Generation[] {
		Get {
			return this.iGeneration
		}
	}
	
	__New(ruleEngine, initialFacts) {
		this.iRuleEngine := ruleEngine
		this.iFacts := initialFacts.Clone()
		
		if (this.base != Facts)
			Throw "Subclassing of Facts is not allowed..."
	}
	
	setValue(fact, value) {
		if (value == kNotInitialized)
			this.clearFact(fact)
		else
			if this.hasFact(fact) {
				if (this.RuleEngine.TraceLevel <= kTraceMedium)
					this.RuleEngine.trace(kTraceMedium, "Setting fact " . fact . " to " . value)
				
				if (this.iFacts[fact] != value) {
					this.iGeneration += 1
					
					this.iFacts[fact] := value
					
					if this.hasObserver(fact)
						this.getObserver(fact).factChanged()
				}
			}
			else	
				Throw "Unknown fact """ . fact . """ encountered in Facts.setValue..."
	}
	
	getValue(fact, default := "__NotInitialized__") {
		local facts := this.Facts
		
		if (fact.base == Variable)
			fact := fact.Variable[true]
		else if (fact.base == Literal)
			fact := fact.Literal
		
		return (facts.HasKey(fact) ? facts[fact] : default)
	}
	
	setFact(fact, value) {
		if this.hasFact(fact)
			this.setValue(fact, value)
		else
			this.addFact(fact, value)
	}
	
	clearFact(fact) {
		if this.Facts.HasKey(fact) {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Deleting fact " . fact)
				
			this.Facts.Delete(fact)
			
			this.iGeneration += 1
			
			if this.hasObserver(fact)
				this.getObserver(fact).factRemoved()
		}
	}
	
	hasFact(fact) {
		return this.Facts.HasKey(fact)
	}
	
	addFact(fact, value) {
		local facts := this.Facts
		
		if facts.HasKey(fact)
			Throw "Duplicate fact """ . fact . """ encountered in Facts.addFact..."
		else if (value != kNotInitialized) {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Adding fact " . fact . " as " . value)
			
			facts[fact] := value
			
			this.iGeneration += 1
			
			if this.hasObserver(fact)
				this.getObserver(fact).factAdded()
		}
	}
	
	removeFact(fact) {
		this.clearFact(fact)
		
		this.removeFact := this.clearFact
	}
	
	registerObserver(fact, observer) {
		if this.iObservers.HasKey(fact)
			Throw "Observer already registered for fact """ . fact . """"
			
		this.iObservers[fact] := observer
	}
	
	deregisterObservers(fact, observer) {
		this.iObservers.Delete(fact)
	}
	
	hasObserver(fact) {
		return this.iObservers.HasKey(fact)
	}
	
	getObserver(fact) {
		observers := this.iObservers
		
		return (observers.HasKey(fact) ? observers[fact] : false)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    FactRules                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FactRules {
	iKnowledgeBase := false
	iFacts := false
	iFact := ""
	iRules := []
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	Facts[] {
		Get {
			return this.KnowledgeBase.Facts
		}
	}
	
	Fact[] {
		Get {
			return this.iFact
		}
	}
	
	Rules[] {
		Get {
			return this.iRules
		}
	}
	
	__New(knowledgeBase, fact) {
		this.iKnowledgeBase := knowledgeBase
		this.iFact := fact
	}
	
	addRule(rule) {
		local rules := this.Rules
		
		if !inList(rules, rule)
			rules.Push(rule)
	}
	
	removeRule(rule) {
		local rules := this.Rules
		
		index := inList(rules, rule)
		
		if index
			rules.RemoveAt(index)
	}
	
	factAdded() {
		this.factChanged()
	}
	
	factRemoved() {
		this.factChanged()
	}
	
	factChanged() {
		this.KnowledgeBase.factChanged(this.Fact, this.Rules)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Rules                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Rules {
	iRuleEngine := false
	iProductions := false
	iReductions := {}
	iGeneration := 1
	
	class Production {
		iNext := false
		iPrevious := false
		
		iRule := false
		iActive := true
		
		Next[active := true] {
			Get {
				candidate := this.iNext
				
				while candidate
					if (active && (candidate.Active == false))
						candidate := candidate.iNext
					else
						return candidate
						
				return candidate
			}
		}
		
		Previous[active := true] {
			Get {
				candidate := this.iPrevious
				
				while candidate
					if (active && (candidate.Active == false))
						candidate := candidate.iPrevious
					else
						return candidate
						
				return candidate
			}
		}
		
		Rule[] {
			Get {
				return this.iRule
			}
		}
		
		Active[] {
			Get {
				return this.iActive
			}
		}
		
		__New(rule, after := false) {
			this.iRule := rule
			
			if after
				this.insertAfter(after)
		}
		
		activate() {
			this.iActive := true
		}
		
		deactivate() {
			this.iActive := false
		}
	
		insertBefore(before) {
			this.iPrevious := before.iPrevious
			this.iNext := before
			
			before.iPrevious := this
				
			if this.iPrevious
				this.iPrevious.iNext := this
		}
	
		insertAfter(after) {
			this.iNext := after.iNext
			this.iPrevious := after
			
			after.iNext := this
				
			if this.iNext
				this.iNext.iPrevious := this
		}
		
		remove() {
			next := this.iNext
			previous := this.iPrevious
			
			if next
				next.iPrevious := previous
				
			if previous
				previous.iNext := next
		}
	}
	
	RuleEngine[] {
		Get {
			return this.iRuleEngine
		}
	}
	
	Productions[active := true] {
		Get {
			if active {
				candidate := this.iProductions
				
				return (candidate.Active ? candidate : candidate.Next)
			}
			else
				return this.iProductions
		}
	}
	
	Reductions[functor := false, arity := false, create := false] {
		Get {
			reductions := this.iReductions
			
			if functor {
				key := functor . "." . arity
				
				if reductions.HasKey(key) 
					return reductions[key]
				else if create
					return (reductions[key] := Array())
				else
					return []
			}
			else
				return reductions
		}
	}
	
	Generation[] {
		Get {
			return this.iGeneration
		}
	}
	
	__New(ruleEngine, productions, reductions) {
		this.iRuleEngine := ruleEngine
		
		productions := productions.Clone()
		
		last := false
		
		for index, production in this.sortProductions(productions) {
			entry := new this.Production(production, last)
			last := entry
			
			if (index == 1)
				this.iProductions := entry
		}
		
		for ignore, reduction in reductions {
			key := (reduction.Head.Functor . "." . reduction.Head.Arity)
			
			if !this.iReductions.HasKey(key)
				this.iReductions[key] := Array()
				
			this.iReductions[key].Push(reduction)
		}
	}
	
	addRule(rule) {
		if (rule.Type == kProduction) {
			priority := rule.Priority
			last := false
			candidate := this.Productions[false]
			
			Loop {
				if !candidate {
					if last
						new this.Production(rule, last)
					else
						this.iProductions := new Production(rule)
					
					this.iGeneration += 1
					
					break
				}
				else if (priority > candidate.Rule.Priority) {
					newProduction := new this.Production(rule)
					
					newProduction.insertBefore(candidate)
					
					if (this.iProductions == candidate)
						this.iProductions := newProduction
					
					this.iGeneration += 1
					
					break
				}
				else {
					last := candidate
					candidate := candidate.Next[false]
				}
			}
			
			this.iGeneration += 1
		}
		else
			this.Reductions[rule.Head.Functor, rule.Head.Arity, true].Push(rule)
		
		this.iGeneration += 1
	}
	
	removeRule(rule) {
		local rules
		
		if (rule.Type == kProduction) {
			production := this.Productions[false]
			
			while production {
				if (production.Rule == rule) {
					production.remove()
					
					this.iGeneration += 1
					
					break
				}
				
				production := production.Next[false]
			}
		}			
		else {
			rules := this.Reductions[rule.Head.Functor, rule.Head.Arity]
			
			for index, candidate in rules
				if (rule == candidate) {
					rules.RemoveAt(index)
					
					this.iGeneration += 1
					
					break
				}
		}
	}
	
	activateRules(rules) {
		local rule := this.Productions[false]
		
		while rule {
			if inlist(rules, rule.Rule) {
				if (this.RuleEngine.TraceLevel <= kTraceMedium)
					this.RuleEngine.trace(kTraceMedium, "Reactivating rule " . rule.Rule.toString())
					
				rule.activate()
			}
				
			rule := rule.Next[false]
		}
	}
	
	sortProductions(productions) {
		productions := productions.Clone()
		
		bubbleSort(productions, ObjBindMethod(this, "compareProductions"))
		
		return productions
	}
	
	compareProductions(r1, r2) {
		return (r1.Priority < r2.Priority)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    RuleEngine                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RuleEngine {
	iInitialFacts := {}
	iInitialProductions := []
	iInitialReductions := []
	iTraceLevel := kTraceOff
	
	InitialFacts[] {
		Get {
			return this.iInitialFacts
		}
	}
	
	InitialProductions[] {
		Get {
			return this.iInitialProductions
		}
	}
	
	InitialReductions[] {
		Get {
			return this.iInitialReductions
		}
	}
	
	TraceLevel[] {
		Get {
			return this.iTraceLevel
		}
	}
	
	__New(productions, reductions, facts) {
		this.iInitialProductions := productions
		this.iInitialReductions := reductions
		this.iInitialFacts := facts
	}
	
	produce() {
		local knowledgeBase := this.createKnowledgeBase(this.createFacts(), this.createRules())

		if knowledgeBase.produce()
			return knowledgeBase
		else
			return false
	}
	
	prove(goal) {
		return this.createKnowledgeBase(this.createFacts(), this.createRules()).prove(goal)
	}
	
	createFacts() {
		return new Facts(this, this.InitialFacts)
	}
	
	createRules() {
		return new Rules(this, this.InitialProductions, this.InitialReductions)
	}
	
	createKnowledgeBase(facts, rules) {
		return new KnowledgeBase(this, facts, rules)
	}
	
	createResultSet(knowledgeBase, goal) {
		return new ResultSet(knowledgeBase, goal)
	}
	
	setTraceLevel(traceLevel) {
		this.iTraceLevel := traceLevel
	}
	
	trace(traceLevel, message) {
		if (this.iTraceLevel <= traceLevel)
			logMessage(kLogOff, "RuleEngine: " . message)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    RuleCompiler                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RuleCompiler {
	compile(fileName, ByRef productions, ByRef reductions, path := false) {
		if !path {
			productions := false
			reductions := false
		}
		
		FileRead text, %fileName%
		SplitPath fileName, , path
		
		this.compileRules(text, productions, reductions, path)
	}
	
	compileRules(text, ByRef productions, ByRef reductions, path := false) {
		if !path {
			productions := []
			reductions := []
		}
		
		incompleteLine := false
		
		Loop Parse, text, `n, `r
		{
			line := Trim(A_LoopField)
			
			if (InStr(line, "#Include") == 1) {
				fileName := substituteVariables(Trim(SubStr(line, 9)))
				
				currentDirectory := A_WorkingDir
				
				try {
					if (path && (Trim(path) != ""))
						SetWorkingDir %path%
					
					SplitPath fileName, , path
				
					this.compile(fileName, productions, reductions, path)
				}
				finally {
					SetWorkingDir %currentDirectory%
				}
			}
			else {
				if ((line != "") && this.skipDelimiter(";", line, 1, false))
					line := ""
			
				if (incompleteLine && (line != "")) {
					line := (incompleteLine . line)
					incompleteLine := false
				}
				
				if ((line != "") && (SubStr(line, StrLen(line), 1) == "\"))
					incompleteLine := SubStr(line, 1, StrLen(line) - 1)
					
				if (!incompleteLine && (line != "")) {
					compiledRule := this.compileRule(line)
					
					if (compiledRule.Type == kProduction)
						productions.Push(compiledRule)
					else
						reductions.Push(compiledRule)
				}
			}
		}
	}
	
	compileRule(text) {
		if InStr(text, "=>")
			return this.compileProduction(text)
		else
			return this.compileReduction(text)
	}
	
	compileProduction(text) {
		production := this.readProduction(text)
					
		return this.createProductionRuleParser(production).parse(production)
	}
	
	compileReduction(text) {
		reduction := this.readReduction(text)
					
		return this.createReductionRuleParser(reduction).parse(reduction)
	}
	
	compileGoal(text) {
		goal := this.readHead(text, 1)
		
		return this.createCompoundParser(goal).parse(goal)
	}
	
	readReduction(text) {
		local nextCharIndex := 1
		local head := this.readHead(text, nextCharIndex)
		local tail := this.readTail(text, nextCharIndex)
		
		if (tail != kNotFound)
			return Array(head, "<=", tail*)
		else
			return Array(head)
	}
	
	readProduction(text) {
		local priority := kNotInitialized
		local nextCharIndex := 1
		
		conditions := this.readConditions(text, nextCharIndex, priority)
				
		if (this.readLiteral(text, nextCharIndex) != "=>")
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readProduction..."
			
		actions := this.readActions(text, nextCharIndex)
		
		if (priority != kNotInitialized)
			return concatenate(["priority:", priority], conditions, ["=>"], actions)
		else
			return concatenate(conditions, ["=>"], actions)
	}
	
	readHead(ByRef text, ByRef nextCharIndex) {
		head := this.readCompound(text, nextCharIndex)
		
		if (head == kNotFound)
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readHead..."
		else
			return head
	}
	
	readTail(ByRef text, ByRef nextCharIndex) {
		local term
		local literal := this.readLiteral(text, nextCharIndex)
		
		if (literal != "") {
			if (literal == "<=") {
				terms := []
				
				Loop {
					term := this.readTailTerm(text, nextCharIndex, (A_Index == 1) ? false : ",")
					
					if (term != kNotFound)
						terms.Push(term)
					else if (!this.isEmpty(text, nextCharIndex) || (A_Index == 1))
						Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readTail..."
					else
						return terms
				}
			}
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readTail..."
		}
		else
			return kNotFound
	}
	
	readTailTerm(ByRef text, ByRef nextCharIndex, skip := false) {
		local literal
		local compound
		
		if skip
			if !this.skipDelimiter(skip, text, nextCharIndex, false)
				return kNotFound
			
		literal := this.readLiteral(text, nextCharIndex)
		
		if ((literal == "!") || (literal = "fail"))
			return literal
		else {
			compound := this.readCompound(text, nextCharIndex, literal)
		
			if (compound == kNotFound)
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readTailTerm..."
			
			return compound
		}
	}
	
	readCompound(ByRef text, ByRef nextCharIndex, functor := false) {
		if !this.isEmpty(text, nextCharIndex) {
			if !functor
				functor := this.readLiteral(text, nextCharIndex)
			else {
				this.skipWhiteSpace(text, nextCharIndex)
				
				if (SubStr(text, nextCharIndex, 2) = "!=") {
					; r != x
					nextCharIndex += 2
					 
					xOperand := this.readCompoundArgument(text, nextCharIndex)
					
					return Array("!=", functor, xOperand)
				}
				else if (SubStr(text, nextCharIndex, 1) = "=") {
					; r = x op y OR x = y
					nextCharIndex += 1
					 
					xOperand := this.readCompoundArgument(text, nextCharIndex) 
				
					this.skipWhiteSpace(text, nextCharIndex)
					
					if !this.isEmpty(text, nextCharIndex) {
						operation := SubStr(text, nextCharIndex, 1)
						
						if InStr("+-*/", operation) {
							nextCharIndex += 1
							
							yOperand := this.readCompoundArgument(text, nextCharIndex)
							
							return Array(operation, functor, xOperand, yOperand)
						}
						else
							return Array("=", functor, xOperand)
					}
					else
						return Array("=", functor, xOperand)
				}
				else if InStr("<>", SubStr(text, nextCharIndex, 1)) {
					 ; x op y
					
					operation := SubStr(text, nextCharIndex, 1)
					
					nextCharIndex += 1
					
					yOperand := this.readLiteral(text, nextCharIndex)
					
					return Array(operation, functor, yOperand)
				}
			}
			
			this.skipDelimiter("(", text, nextCharIndex)
			
			arguments := this.readCompoundArguments(text, nextCharIndex)
			
			this.skipDelimiter(")", text, nextCharIndex)
			
			return Array(functor, arguments*)
		}
		else
			return kNotFound
	}
	
	readCompoundArguments(ByRef text, ByRef nextCharIndex) {
		arguments := []
		
		Loop {
			argument := this.readCompoundArgument(text, nextCharIndex)
			
			if ((argument != kNotFound) || (argument == "0"))
				arguments.Push(argument)
			else if (A_Index == 1)
				return arguments
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readCompoundArguments..."
			
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				return arguments
		}
	}
	
	readCompoundArgument(ByRef text, ByRef nextCharIndex) {
		local literal
		
		if this.skipDelimiter("[", text, nextCharIndex, false)
			return this.readList(text, nextCharIndex, false)
		else {
			literal := this.readLiteral(text, nextCharIndex)

			if ((literal == "") || (literal == kNotFound))
				return kNotFound
			else if this.skipDelimiter("(", text, nextCharIndex, false) {
				compoundArguments := this.readCompoundArguments(text, nextCharIndex)
				
				this.skipDelimiter(")", text, nextCharIndex)
				
				return Array(literal, compoundArguments*)
			}
			else
				return literal
		}
	}
	
	readList(ByRef text, ByRef nextCharIndex, skip := true) {
		if (skip && !this.skipDelimiter("[", text, nextCharIndex, false))
			return kNotFound
		
		if this.skipDelimiter("]", text, nextCharIndex, false)
			return "[]"
		else {
			arguments := this.readCompoundArguments(text, nextCharIndex)
			
			if this.skipDelimiter("|", text, nextCharIndex, false) {
				argument := this.readCompoundArgument(text, nextCharIndex)
				
				this.skipDelimiter("]", text, nextCharIndex)
				
				if (argument != kNotFound)
					return concatenate(["["], arguments, ["|"], Array(argument), ["]"])
				else
					Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readList..."
			}
			else {
				this.skipDelimiter("]", text, nextCharIndex)
				
				return concatenate(["["], arguments, ["]"])
			}
		}
	}
	
	readConditions(ByRef text, ByRef nextCharIndex, ByRef priority := false) {
		conditions := []
		
		Loop {
			if this.skipDelimiter("{", text, nextCharIndex, false) {
				keyword := this.readLiteral(text, nextCharIndex)
				
				conditions.Push(Array(keyword, this.readConditions(text, nextCharIndex)*))
				
				this.skipDelimiter("}", text, nextCharIndex)
			}
			else if this.skipDelimiter("[", text, nextCharIndex, false) {
				leftLiteral := this.readLiteral(text, nextCharIndex)
				
				if (leftLiteral = kPredicate)
					leftLiteral := this.readLiteral(text, nextCharIndex)
				
				if this.skipDelimiter("]", text, nextCharIndex, false)
					conditions.Push(Array(leftLiteral))
				else {
					operator := this.readLiteral(text, nextCharIndex)
					rightLiteral := this.readLiteral(text, nextCharIndex)
				
					conditions.Push(Array(leftLiteral, operator, rightLiteral))
					
					this.skipDelimiter("]", text, nextCharIndex)
				}
			}
			else if priority
				if (this.readLiteral(text, nextCharIndex) = "priority:")
					priority := this.readLiteral(text, nextCharIndex)
				else
					Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.readConditions..."
				
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				return conditions
		}
	}
	
	readActions(ByRef text, ByRef nextCharIndex) {
		local action
		
		actions := []
		
		Loop {
			this.skipDelimiter("(", text, nextCharIndex)
			
			action := this.readLiteral(text, nextCharIndex)
			
			if inList([kCall, kProve, kProveAll], action)
				actions.Push(Array(action, this.readCompound(text, nextCharIndex)))
			else {
				arguments := Array(action)
				
				Loop {
					if ((A_Index > 1) && !this.skipDelimiter(",", text, nextCharIndex, false))
						break
					
					arguments.Push(this.readLiteral(text, nextCharIndex))
				}
				
				actions.Push(arguments)
			}
			
			this.skipDelimiter(")", text, nextCharIndex)
			
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				return actions
		}
	}
	
	isEmpty(ByRef text, ByRef nextCharIndex) {
		remainingText := Trim(SubStr(text, nextCharIndex))
		
		if ((remainingText != "") && this.skipDelimiter(";", remainingText, 1, false))
			remainingText := ""
		
		return (remainingText == "")
	}
	
	skipWhiteSpace(ByRef text, ByRef nextCharIndex) {
		length := StrLen(text)
		
		Loop {
			if (nextCharIndex > length)
				return
				
			if InStr(" `t`n`r", SubStr(text, nextCharIndex, 1))
				nextCharIndex += 1
			else
				return
		}
	}
	
	skipDelimiter(delimiter, ByRef text, ByRef nextCharIndex, throwError := true) {
		length := StrLen(delimiter)
		
		this.skipWhiteSpace(text, nextCharIndex)
	
		if (SubStr(text, nextCharIndex, length) = delimiter) {
			nextCharIndex += length
			
			return true
		}
		else if throwError
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in RuleCompiler.skipDelimiter..."
		else
			return false
	}
	
	readLiteral(ByRef text, ByRef nextCharIndex, delimiters := "{[()]}|`, `t") {
		local literal
		
		length := StrLen(text)
		
		this.skipWhiteSpace(text, nextCharIndex)
		
		beginCharIndex := nextCharIndex
		quoted := false
		
		Loop {
			character := SubStr(text, nextCharIndex, 1)
		
			if (character == "\") {
				nextCharIndex := nextCharIndex + 2
				
				quoted := true
				
				continue
			}
			
			if (InStr(delimiters, character) || (nextCharIndex > length)) {
				literal := SubStr(text, beginCharIndex, nextCharIndex - beginCharIndex)
				
				if (delimiters == """")
					return literal
				else if (literal = kTrue)
					return true
				else if (literal = kFalse)
					return false
				else if quoted {
					Random rand, 1, 100000
				
					return StrReplace(StrReplace(StrReplace(literal, "\\", "###" . rand . "###"), "\", ""), "###" . rand . "###", "\")
				}
				else
					return literal
			}
			else
				nextCharIndex += 1
		}
	}
	
	parseProductions(rules) {
		result := []
		
		for ignore, theRule in rules
			result.Push(this.parseProduction(theRule))
			
		return result
	}
	
	parseProduction(rule) {
		return this.createProductionRuleParser(rule).parse(rule)
	}

	parseReductions(rules) {
		result := []
		
		for ignore, theRule in rules
			result.Push(this.parseReduction(theRule))
			
		return result
	}
	
	parseReduction(rule) {
		return this.createReductionRuleParser(rule).parse(rule)
	}

	parseGoal(goal) {
		return this.createCompoundParser(goal).parse(goal)
	}
	
	createProductionRuleParser(condition, variables := "__NotInitialized__") {
		return new ProductionRuleParser(this, variables)
	}
	
	createReductionRuleParser(condition, variables := "__NotInitialized__") {
		return new ReductionRuleParser(this, variables)
	}
	
	createConditionParser(condition, variables := "__NotInitialized__") {
		return new ConditionParser(this, variables)
	}
	
	createPredicateParser(predicate, variables := "__NotInitialized__") {
		return new PredicateParser(this, variables)
	}
	
	createPrimaryParser(predicate, variables := "__NotInitialized__") {
		return new PrimaryParser(this, variables)
	}
	
	createActionParser(action, variables := "__NotInitialized__") {
		return new ActionParser(this, variables)
	}
	
	createTermParser(term, variables := "__NotInitialized__", forArguments := true) {
		if ((term == "!") && !forArguments)
			return new CutParser(this, variables)
		else if ((term = "fail") && !forArguments)
			return new FailParser(this, variables)
		else if ((term == "[]") && forArguments)
			return new NilParser(this, variables)
		else if (!IsObject(term) && forArguments)
			return new PrimaryParser(this, variables)
		else if ((term[1] == "[") && forArguments)
			return new ListParser(this, variables)
		else if IsObject(term)
			return this.createCompoundParser(this, variables)
			
		Throw "Unexpected terms detected in RuleCompiler.createTermParser..."
	}
	
	createCompoundParser(term, variables := "__NotInitialized__") {
		return new CompoundParser(this, variables)
	}
	
	createProductionRule(conditions, actions, priority) {
		return new ProductionRule(conditions, actions, priority)
	}
	
	createReductionRule(head, tail) {
		return new ReductionRule(head, tail)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Parser                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Parser {
	iCompiler := false
	iVariables := kNotInitialized
	
	Compiler[] {
		Get {
			return this.iCompiler
		}
	}
	
	Variables[] {
		Get {
			return this.iVariables
		}
	}
	
	__New(compiler, variables := "__NotInitialized__") {
		this.iCompiler := compiler
		this.iVariables := ((variables == kNotInitialized) ? {} : variables)
	}

	getVariable(name) {
		if (SubStr(name, 1, 1) == "?")
			name := SubStr(name, 2)
		
		if (name == "") {
			Random name, 0, 2147483647
			
			name := "__Unnamed" . name . "__"
		}
			
		key := StrReplace(StrReplace(name, A_Space, ""), A_Tab, "")
		
		variables := this.iVariables
		
		if variables.HasKey(key)
			return variables[key]
		else {
			name := StrSplit(name, ".", " `t", 2)
			rootName := name[1]
			
			if variables.HasKey(rootName)
				rootVariable := variables[rootName]
			else {
				rootVariable := new Variable(rootName)
				
				variables[rootName] := rootVariable
			}
			
			name := ((name.Length() == 1) ? rootVariable : new Variable(rootName, name[2], rootVariable))
		
			variables[key] := name
			
			return name
		}
	}
	
	parse(expression) {
		Throw "Virtual method Parser.parse must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           RuleParser                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RuleParser extends Parser {
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProductionRuleParser                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProductionRuleParser extends RuleParser {
	parse(rule) {
		parseActions := false
		parsePriority := false
		conditions := []
		actions := []
		priority := 0
		
		for ignore, expression in rule
			if parseActions
				actions.Push(this.Compiler.createActionParser(expression, this.Variables).parse(expression))
			else if parsePriority {
				priority := expression
				
				parsePriority := false
			}
			else if (expression == "=>")
				parseActions := true
			else if (expression = "priority:")
				parsePriority := true
			else 
				conditions.Push(this.Compiler.createConditionParser(expression, this.Variables).parse(expression))
				
		if parseActions
			return this.Compiler.createProductionRule(conditions, actions, priority)
		else
			Throw "Syntax error detected in production rule """ . rule.toString() . """ in ProductionRuleParser.parse..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ReductionRuleParser                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ReductionRuleParser extends RuleParser {
	parse(rule) {
		head := this.Compiler.createCompoundParser(rule[1], this.Variables).parse(rule[1])
		tail := []
		
		if (rule.Length() > 1) {
			if (rule[2] != "<=")
				Throw "Syntax error detected in reduction rule """ . rule.toString() . """ in ReductionRuleParser.parse..."
			else {
				try {
					tail := this.parseTail(rule, 3)
				}
				catch exception {
					Throw "Syntax error detected in reduction rule """ . rule.toString() . """ in ReductionRuleParser.parse..."
				}
			}
		}
		
		return new ReductionRule(head, tail)
	}
	
	parseTail(terms, start) {
		result := []	
		
		for index, theTerm in terms
			if (index >= start)
				result.Push(this.Compiler.createTermParser(theTerm, this.Variables, false).parse(theTerm))
				
		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ConditionParser                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConditionParser extends Parser {
	parse(expressions) {
		switch expressions[1] {
			case kAll:
				return new AllQuantor(this.parseArguments(expressions, 2))
			case kOne:
				return new OneQuantor(this.parseArguments(expressions, 2))
			case kAny:
				return new ExistQuantor(this.parseArguments(expressions, 2))
			case kNone:
				return new NotExistQuantor(this.parseArguments(expressions, 2))
			default:
				return this.Compiler.createPredicateParser(expressions, this.Variables).parse(expressions)
		}
	}
	
	parseArguments(conditions, start) {
		result := []
		
		for index, theCondition in conditions
			if (index >= start)
				result.Push(this.Compiler.createConditionParser(theCondition, this.Variables).parse(theCondition))
				
		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    PredicateParser                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PredicateParser extends Parser {
	parse(expressions) {
		if (expressions.Length() == 3)
			return new Predicate(this.Compiler.createPrimaryParser(expressions[1], this.Variables).parse(expressions[1])
							   , expressions[2]
							   , this.Compiler.createPrimaryParser(expressions[3], this.Variables).parse(expressions[3]))
		else
			return new Predicate(this.Compiler.createPrimaryParser(expressions[1], this.Variables).parse(expressions[1]))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    PrimaryParser                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PrimaryParser extends Parser {
	parse(expression) {
		if (SubStr(expression, 1, 1) == "?")
			return this.getVariable(expression)
		else if (SubStr(expression, 1, 1) == "!")
			return new Fact(SubStr(expression, 2))
		else
			return new Literal(expression)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ActionParser                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ActionParser extends Parser {
	parse(expressions) {
		local compound
	
		local action := expressions[1]
		
		switch action {
			case kCall:
				compound := this.Compiler.createCompoundParser(expressions[2]).parse(expressions[2])
				
				return new CallAction(new Literal(compound.Functor), compound.Arguments)
			case kProve:
				compound := this.Compiler.createCompoundParser(expressions[2]).parse(expressions[2])
				
				return new ProveAction(new Literal(compound.Functor), compound.Arguments)
			case kProveAll:
				compound := this.Compiler.createCompoundParser(expressions[2]).parse(expressions[2])
				
				return new ProveAction(new Literal(compound.Functor), compound.Arguments, true)
			default:
				argument := this.Compiler.createPrimaryParser(expressions[2], this.Variables).parse(expressions[2])
		
				switch action {
					case kSet:
						arguments := this.parseArguments(expressions, 3)
						
						if (arguments.Length() = 1)
							return new SetFactAction(argument, arguments[1])
						else if (arguments.Length() > 1)
							return new SetComposedFactAction(argument, arguments*)
						else
							return new SetFactAction(argument)
					case kClear:
						arguments := this.parseArguments(expressions, 3)
						
						if (arguments.Length() > 0)
							return new ClearComposedFactAction(argument, arguments*)
						else
							return new ClearFactAction(argument)
					default:
						Throw "Unknown action type """ . action . """ detected in ActionParser.parse..."
				}
		}
	}
	
	parseArguments(expressions, start) {
		result := []
		
		for index, expression in expressions
			if (index >= start)
				result.Push(this.Compiler.createPrimaryParser(expression, this.Variables).parse(expression))
				
		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CompoundParser                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CompoundParser extends Parser {
	parse(terms) {
		return new Compound(terms[1], this.parseArguments(terms, 2))
	}
	
	parseArguments(terms, start) {
		result := []
		
		for index, theTerm in terms
			if (index >= start)
				result.Push(this.Compiler.createTermParser(theTerm, this.Variables).parse(theTerm))
				
		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CutParser                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CutParser extends Parser {
	parse(terms) {
		return new Cut()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    FailParser                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FailParser extends Parser {
	parse(terms) {
		return new Fail()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ListParser                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ListParser extends Parser {
	parse(terms) {
		length := terms.Length()
		subTerms := []
		lastTerm := false
		
		for index, theTerm in terms {
			if (((theTerm = "[") && (index != 1)) || ((theTerm = "]") && (index != length))
												  || ((theTerm = "|") && (index != (length - 2))))
				Throw "Unexpected list structure """ . values2String(", ", terms*) . """ detected in ListParser.parse..."
			
			if ((index > 1) && (index < length))
				if (theTerm == "|")
					lastTerm := true
				else if (lastTerm == true)
					lastTerm := this.Compiler.createTermParser(theTerm, this.Variables).parse(theTerm)
				else
					subTerms.Push(this.Compiler.createTermParser(theTerm, this.Variables).parse(theTerm))
		}
		
		if !lastTerm
			lastTerm := new Nil()
			
		index := subTerms.Length()
		
		Loop {
			lastTerm := new Pair(subTerms[index], lastTerm)
		} until (--index == 0)
		
		return lastTerm
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    NilParser                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NilParser extends Parser {
	parse(terms) {
		return new Nil()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

msgBox(ignore, args*) {
	MsgBox % values2String(A_Space, args*)
	
	return true
}

option(choicePoint, option, value) {
	if isInstance(option, Term)
		option := option.toSTring(resultSet)
	
	if isInstance(value, Term)
		value := value.toSTring(resultSet)
	
	if (option = "Trace") {
		value := inList(["Full", "Medium", "Light", "Off"], value)
		
		if value
			choicePoint.ResultSet.KnowledgeBase.RuleEngine.setTraceLevel(value)
		else
			return false
	}
	else if (option = "OccurCheck") {
		if ((value = false) || (value = kFalse))
			choicePoint.ResultSet.KnowledgeBase.disableOccurCheck()
		else if ((value = true) || (value = kTrue))
			choicePoint.ResultSet.KnowledgeBase.enableOccurCheck()
		else
			return false
	}
	else if (option = "DeterministicFacts") {
		if ((value = false) || (value = kFalse))
			choicePoint.ResultSet.KnowledgeBase.disableDeterministicFacts()
		else if ((value = true) || (value = kTrue))
			choicePoint.ResultSet.KnowledgeBase.enableDeterministicFacts()
		else
			return false
	}
	
	return true
}

squareRoot(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	
	if isInstance(operand1, Variable) {
		if isInstance(operand2, Variable)
			return false
		else
			return resultSet.unify(choicePoint, operand1, new Literal(operand2.toString(resultSet) * operand2.toString(resultSet)))
	}
	else if isInstance(operand2, Variable) {
		if isInstance(operand1, Variable)
			return false
		else {
			value1 := operand1.toString(resultSet)
			
			if value1 is not number
				return false
			
			return resultSet.unify(choicePoint, operand2, new Literal(Sqrt(value1)))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		
		return (Sqrt(value1) = value2)
	}
}

plus(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)
	
	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value2 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand1, new Literal(value2 + value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value1 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand2, new Literal(value1 - value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)
			
			if value1 is not number
				return false
			if value2 is not number
				return false
			
			return resultSet.unify(choicePoint, operand3, new Literal(value1 - value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		if value3 is not number
			return false
			
		return (value1 = (value2 + value3))
	}
}

minus(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)
	
	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value2 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand1, new Literal(value2 - value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value1 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand2, new Literal(value1 + value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)
			
			if value1 is not number
				return false
			if value2 is not number
				return false
			
			return resultSet.unify(choicePoint, operand3, new Literal(value1 + value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		if value3 is not number
			return false
			
		return (value1 = (value2 - value3))
	}
}

multiply(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)
	
	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value2 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand1, new Literal(value2 * value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value1 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand2, new Literal(value1 / value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)
			
			if value1 is not number
				return false
			if value2 is not number
				return false
			
			return resultSet.unify(choicePoint, operand3, new Literal(value1 / value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		if value3 is not number
			return false
			
		return (value1 = (value2 * value3))
	}
}

divide(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)
	
	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value2 is not number
				return false
			if value3 is not number
				return false

			return resultSet.unify(choicePoint, operand1, new Literal(value2 / value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)
			
			if value1 is not number
				return false
			if value3 is not number
				return false
			
			return resultSet.unify(choicePoint, operand2, new Literal(value1 * value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)
			
			if value1 is not number
				return false
			if value2 is not number
				return false
			
			return resultSet.unify(choicePoint, operand3, new Literal(value1 * value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		if value3 is not number
			return false
			
		return (value1 = (value2 / value3))
	}
}

greater(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	
	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		
		return (value1 > value2)
	}
}

less(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	
	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		
		if value1 is not number
			return false
		if value2 is not number
			return false
		
		return (value1 < value2)
	}
}

equal(choicePoint, operand1, operand2) {
	return choicePoint.ResultSet.unify(choicePoint, operand1, operand2)
}

unequal(choicePoint, operand1, operand2) {
	return !choicePoint.ResultSet.unify(choicePoint, operand1, operand2)
}

builtin0(choicePoint, function, operand1) {
	local resultSet := choicePoint.ResultSet
	
	function := function.toString(resultSet)
	
	return resultSet.unify(choicePoint, new Literal(%function%()), operand1.getValue(resultSet, operand1))
}

builtin1(choicePoint, function, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	
	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	
	function := function.toString(resultSet)
	
	if (isInstance(operand1, Variable) || operand1.isUnbound(resultSet))
		return false
	else
		return resultSet.unify(choicePoint, new Literal(%function%(operand1.toString(resultSet))), operand2)
}

unbound(choicePoint, operand1) {
	if isInstance(operand1, Variable)
		return (operand1.getValue(choicePoint.ResultSet, operand1) == operand1)
	else if isInstance(operand1, Fact)
		return (operand1.getValue(choicePoint.ResultSet.KnowledgeBase.Facts) = kNotInitialized)
	else
		return (operand1.toString(choicePoint.ResultSet) = kNotInitialized)
}

append(choicePoint, arguments*) {
	local resultSet
	
	if (arguments.Length() <= 1)
		return false
	else {
		resultSet := choicePoint.ResultSet
		
		operand1 := arguments.Pop()
		operand1 := operand1.getValue(resultSet, operand1)
		
		string := ""
		
		for ignore, argument in arguments
			string .= argument.getValue(resultSet, argument).toString(resultSet)
		
		if isInstance(operand1, Variable)
			return resultSet.unify(choicePoint, operand1, new Literal(string))
		else
			return (operand1.toString(resultSet) = string)
	}
}

get(choicePoint, arguments*) {
	local resultSet
	
	if (arguments.Length() <= 1)
		return false
	else {
		resultSet := choicePoint.ResultSet
		
		if (arguments.Length() = 2) {
			operand1 := arguments[1]
			operand2 := arguments[2]
			
			operand1 := new Literal(resultSet.KnowledgeBase.Facts.getValue(operand1.getValue(resultSet, operand1).toString(resultSet)))
			operand2 := operand2.getValue(resultSet, operand2)
		}
		else {
			operand2 := arguments.Pop()
			operand2 := operand2.getValue(resultSet, operand2)
			
			result := ""
				
			for index, argument in arguments {
				if (index > 1)
					result .= "."
				
				result .= argument.getValue(resultSet, argument).toString(resultSet)
			}
			
			operand1 := new Literal(resultSet.KnowledgeBase.Facts.getValue(result))
		}
	
		if (isInstance(operand2, Variable) && !operand1.isUnbound(resultSet))
			return resultSet.unify(choicePoint, operand1, operand2)
		else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else
			return (operand1.toString(resultSet) = operand2.toString(resultSet))
	}
}