;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Hybrid Rule Engine              ;;;
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
global kIdentical = "=="
global kLess = "<"
global kLessOrEqual = "<="
global kMore = ">"
global kMoreOrEqual = ">="
global kContains = "contains"

global kCall = "Call:"
global kProve = "Prove:"
global kSet = "Set:"
global kClear = "Clear:"

global kProduction = "Production"
global kReduction = "Reduction"

global kNotInitialized = "__NotInitialized__"

global kTraceFull = 1
global kTraceMedium = 2
global kTraceLight = 3
global kTraceOff = 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class:          Condition                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Condition {
	Type[] {
        Get {
            Throw "Virtual property Condition.Type must be implemented in a subclass..."
        }
    }
	
	match(facts) {
		Throw "Virtual method Condition.match must be implemented in a subclass..."
	}
	
	toString(facts := "__NotInitialized__") {
		Throw "Virtual method Condition.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class:          CompositeCondition                             ;;;
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
	
	toString(facts := "__NotInitialized__") {
		conditions := []
		
		for ignore, condition in this.Conditions
			conditions.Push(condition.toString(facts))
			
		return values2String(", ", conditions*)
	}
}	

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Quantor                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Quantor extends CompositeCondition {
	toString(facts := "__NotInitialized__") {
		return "{" . this.Type . ": " . base.toString(facts) . "}"
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
	
	match(facts) {
		for ignore, condition in this.Conditions
			if condition.match(facts)
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
	
	match(facts) {
		for ignore, condition in this.Conditions
			if condition.match(facts)
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
	
	match(facts) {
		matched := 0
		
		for ignore, condition in this.Conditions
			if condition.match(facts)
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
            return kAllm
        }
    }
	
	match(facts) {
		matched := 0
		
		for ignore, condition in this.Conditions
			if condition.match(facts)
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
	
	match(facts) {
		leftPrimary := this.LeftPrimary[facts]
		
		if (leftPrimary == kNotInitialized)
			return false
		else {
			rightPrimary := this.RightPrimary[facts]
			
			switch this.Operator {
				case kNotInitialized:
					return true
				case kEqual:
					return (leftPrimary = rightPrimary)
				case kIdentical:
					return (leftPrimary == rightPrimary)
				case kLess:
					return (leftPrimary < rightPrimary)
				case kLessOrEqual:
					return (leftPrimary <= rightPrimary)
				case kMore:
					return (leftPrimary > rightPrimary)
				case kMoreOrEqual:
					return (leftPrimary >= rightPrimary)
				case kContains:
					return inList(leftPrimary, rightPrimary)
				default:
					Throw "Unsupported comparison operator """ . this.Operator . """ detected in Predicate.match..."
			}
		}
	}
	
	toString(facts := "__NotInitialized__") {
		if (this.Operator == kNotInitialized)
			return ("[" . this.LeftPrimary.toString(facts) . "]")
		else
			return ("[" . this.LeftPrimary.toString(facts) . " " . this.Operator . " " . this.RightPrimary.toString(facts) "]")
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
	iVariable := kNotInitialized
	iProperty := false
	
	Variable[] {
		Get {
			return this.iVariable
		}
	}
	
	Property[asString := true] {
		Get {
			return (asString ? (this.iProperty ? values2String(".", this.iProperty*) : "") : this.iProperty)
		}
	}
	
	__New(name, property := false) {
		this.iVariable := name
		this.iProperty := (property ? string2Values(".", property) : false)
		
		if (this.base != Variable)
			Throw "Subclassing of Variable is not allowed..."
	}
	
	getValue(factsOrResultSet, default := "__NotInitialized__") {
		value := factsOrResultSet.getValue(this)
	
		if (IsObject(value) && ((value.base == Variable) || (value.base == Literal)))
			value := value.getValue(factsOrResultSet)
					
		if (value != kNotInitialized) {
		/*
			property := this.Property[false]
			
			if property
				for ignore, field in property
					value := value[field]
					
			if (IsObject(value) && ((value.base == Variable) || (value.base == Literal)))
				value := value.getValue(factsOrResultSet)
		*/	
			return value
		}
		else
			return default
	}
	
	injectValues(resultSet) {
		return this.toString(resultSet)
	}
	
	substituteVariables(variables) {
		var := this.Variable
		
		if variables.HasKey(var)
			return variables[var]	
		else {
			newVariable := new Variable(var, this.Property)
			
			variables[var] := newVariable

			return newVariable
		}
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		property := this.Property
		name := this.Variable
		
		if InStr(name, "__Unnamed")
			name := ""
			
		if (factsOrResultSet == kNotInitialized)
			return ("?" . name . ((property != "") ? ("." . property) : ""))
		else {
			value := this.getValue(factsOrResultSet)
			
			if (value == kNotInitialized)
				return "?" . name . ((property != "") ? ("." . property) : "")
			else
				return value.toString(factsOrResultSet) . ((property != "") ? ("." . property) : "")
		}
	}
	
	occurs(resultSet, var) {
		return (this.getValue(resultSet, this) == var)
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
	
	getValue(factsOrResultSet := "__NotInitialized__") {
		if (factsOrResultSet.base == Facts)
			return factsOrResultSet.getValue(this.Fact)
		else
			return this
	}
	
	toString(factsOrResultSet := "__NotInitialized__") {
		if (factsOrResultSet.base == Facts)
			return factsOrResultSet.getValue(this.Fact)
		else if (factsOrResultSet.base == ResultSet)
			return factsOrResultSet.KnowledgeBase.Facts.getValue(this.Fact)
		else
			return ("!" . this.Fact)
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
	
	toString(factsOrResultSet := "__NotInitialized__") {
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
	execute(knowledgeBase) {
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
	
	Function[facts := "__NotInitialized__"] {
		Get {
			if (facts == kNotInitialized)
				return this.iFunction
			else
				return this.iFunction.getValue(facts)
		}
	}
	
	Arguments[facts := "__NotInitialized__"] {
		Get {
			if (facts == kNotInitialized)
				return this.iArguments
			else
				this.getValues(facts)
		}
	}
	
	__New(function, arguments) {
		this.iFunction := function
		this.iArguments := arguments
	}
	
	execute(knowledgeBase) {
		local facts := knowledgeBase.Facts
		
		function := this.Function[facts]
		
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(facts))
		
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
			knowledgeBase.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", arguments*) . ")")
		
		%function%(knowledgeBase, arguments*)
	}
	
	getValues(facts) {
		values := []
		
		for ignore, argument in this.Arguments
			values.Push(argument.getValue(facts))
		
		return values
	}
	
	toString(facts := "__NotInitialized__") {
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(facts))
			
		return ("(Call: " .  values2String(", ", this.Function.toString(facts), arguments*) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProveAction                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProveAction extends CallAction {
	Functor[facts := "__NotInitialized__"] {
		Get {
			return this.Function[facts]
		}
	}
	
	execute(knowledgeBase) {
		local facts := knowledgeBase.Facts
		
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(new Literal(argument.toString(facts)))
		
		goal := new Compound(this.Functor[facts], arguments)
		
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
			knowledgeBase.RuleEngine.trace(kTraceMedium, "Activate reduction rules with goal " . goal.toString())
		
		knowledgeBase.prove(goal)
	}
	
	toString(facts := "__NotInitialized__") {
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(facts))
			
		return ("(Prove: " .  values2String(", ", this.Functor.toString(facts), arguments*) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetFactAction                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetFactAction extends Action {
	iFact := kNotInitialized
	iValue := kNotInitialized
	
	Fact[facts := "__NotInitialized__"] {
		Get {
			if (facts == kNotInitialized)
				return this.iFact
			else
				return this.iFact.getValue(facts)
		}
	}
	
	Value[facts := "__NotInitialized__"] {
		Get {
			if (facts == kNotInitialized)
				return this.iValue
			else
				return this.iValue.getValue(facts)
		}
	}
	
	__New(fact, value := "__NotInitialized__") {
		this.iFact := fact
		this.iValue := ((value == kNotInitialized) ? fact : value)
	}
	
	execute(knowledgeBase) {
		local facts := knowledgeBase.Facts
		local fact := this.Fact[facts]
		value := this.Value[facts]
		
		if facts.hasFact(fact)
			facts.setValue(fact, value)
		else
			facts.addFact(fact, value)
	}
	
	toString(facts := "__NotInitialized__") {
		if (this.Value == this.Fact)
			return ("(Set: " . this.Fact.toString(facts) . ")")
		else
			return ("(Set: " . this.Fact.toString(facts) . " " . this.Value.toString(facts) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearFactAction                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearFactAction extends Action {
	iFact := kNotInitialized
	
	Fact[facts := "__NotInitialized__"] {
		Get {
			if (facts == kNotInitialized)
				return this.iFact
			else
				return this.iFact.getValue(facts)
		}
	}
	
	__New(fact) {
		this.iFact := fact
	}
	
	execute(knowledgeBase) {
		local facts := knowledgeBase.Facts
		local fact := this.Fact[facts]
		
		facts.removeFact(fact)
	}
	
	toString(facts := "__NotInitialized__") {
		return ("(Clear: " . this.Fact.toString(facts) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Term                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Term {
	getValue(resultSet, default := "__NotInitialized__") {
		return this
	}
	
	injectValues(resultSet) {
		return this
	}
	
	substituteVariables(variables) {
		return this
	}
	
	unify(choicePoint, term) {
		return (this == term)
	}
	
	occurs(resultSet, var) {
		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Compound                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Compound extends Term {
	iFunctor := ""
	iArguments := []
	
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
			if (resultSet == kNotInitialized)
				return this.iArguments
			else
				return this.getValues(resultSet)
		}
	}
	
	__New(functor, arguments) {
		this.iFunctor := functor
		this.iArguments := arguments
		
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
			values.Push(argument.getValue(resultSet))
			
		return values
	}
	
	injectValues(resultSet) {
		arguments := this.Arguments[resultSet]
		
		if (arguments.Length() == 0)
			return this
		else
			return new Compound(this.Functor, arguments)
	}
	
	substituteVariables(variables) {
		arguments := []
		
		for ignore, argument in this.Arguments
			arguments.Push(argument.substituteVariables(variables))
		
		if (arguments.Length() == 0)
			return this
		else
			return new Compound(this.Functor, arguments)
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
		for ignore, argument in this.Arguments
			if argument.getValue(resultSet, argument).occurs(var)
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
	
	substituteVariables(variables) {
		return new Pair(this.LeftTerm.substituteVariables(variables), this.RightTerm.substituteVariables(variables))
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
		leftTerm := this.LeftTerm
		rightTerm := this.RightTerm
		
		return (leftTerm.getValue(resultSet, leftTerm).occurs(var) || rightTerm.getValue(resultSet, rightTerm).occurs(var))
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Nil                                            ;;;
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
	
	match(facts) {
		for ignore, condition in this.Conditions
			if !condition.match(facts)
				return false
				
		return true
	}
	
	fire(knowledgeBase) {
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Firing rule " . this.toString())
		
		for ignore, action in this.Actions
			action.execute(knowledgeBase)
	}
	
	produce(knowledgeBase) {
		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Trying rule " . this.toString())
		
		if this.match(knowledgeBase.Facts) {
			this.fire(knowledgeBase)
			
			return true
		}
		else
			return false
	}
	
	toString(facts := "__NotInitialized__") {
		priority := this.Priority
		conditions := ((priority != 0) ? ["Priority: " . priority] : [])
		actions := []
		
		for ignore, condition in this.Conditions
			conditions.Push(condition.toString(facts))
		
		for ignore, action in this.Actions
			actions.Push(action.toString(facts))
			
		return values2String(", ", conditions*) . " => " . values2String(", ", actions*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ReductionRule                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ReductionRule extends Rule {
	iHead := false
	iTail := []
	
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
		this.Tail := tail
	}
	
	toString(resultSet := "__NotInitialized__") {
		tail := this.Tail
		
		if (tail && (tail.Length() > 0)) {
			terms := []
			
			for ignore, term in tail
				terms.Push(term.toString(resultSet))
				
			return (this.Head.toString(resultSet) . " <= " . values2String(", ", terms*))
		}
		else
			return this.Head.toString(resultSet)
	}
	
	substituteVariables() {
		variables := {}
		terms := []
		
		for ignore, term in this.Tail
			terms.Push(term.substituteVariables(variables))
			
		return new ReductionRule(this.Head.substituteVariables(variables), terms)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ResultSet                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ResultSet {
	iKnowledgeBase := false
	iChoicePoint := false
	
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
		bindings := this.iBindings
		
		choicePoint.saveVariable(var, (bindings.HasKey(var) ? bindings[va] : kNotInitialized))
		
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
		termA := termA.getValue(this, termA)
		termB := termB.getValue(this, termB)
		
		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			this.RuleEngine.trace(kTraceMedium, "Unifying " . termA.toString() . " with " . termB.toString())
		
		if (termA.base == Variable) {
			if (this.KnowledgeBase.OccurCheck && termB.occurs(this, termA))
				return false
			
			if (this.RuleEngine.TraceLevel <= kTraceFull)
				this.RuleEngine.trace(kTraceFull, "Binding " . termA.toString() . " to " . termB.toString())
			
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
		local choicePoint := this.ChoicePoint[true]
		
		Loop {
			if choicePoint.nextChoice() {
				choicePoint := choicePoint.next()
				
				if choicePoint {
					if (this.RuleEngine.TraceLevel <= kTraceMedium)
						this.RuleEngine.trace(kTraceMedium, "Targeting " . choicePoint.Goal.toString(this))
				}
				else
					return true
			}
			else {
				choicePoint := choicePoint.previous()
				
				if !choicePoint
					return false
			}
		}
	}
	
	getValue(var, default := "__NotInitialized__") {
		bindings := this.iBindings
		
		Loop {
			if bindings.HasKey(var) {
				value := bindings[var]
				
				if (value.base == Variable)
					var := value
				else
					return value
			}
			else
				return default
		}
	}
	
	createChoicePoint(goal, environment := false) {
		switch goal.Functor {
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
	iNextRuleIndex := 1
	
	iSubChoicePoints := []
		
	Reductions[reset := false] {
		Get {
			local goal
			local resultSet
			
			if reset {
				resultSet := this.ResultSet
				goal := this.Goal
				
				this.iReductions := this.ResultSet.Rules.Reductions[goal.Functor, goal.Arity]
				
				if (resultSet.RuleEngine.TraceLevel <= kTraceLight)
					resultSet.RuleEngine.trace(kTraceLight, this.iReductions.Length() . " rules selected for " . goal.toString(resultSet))
			}
				
			return this.iReductions
		}
	}
	
	nextChoice() {
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
				rule := reductions[index].substituteVariables()
			
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
		local goal
		
		this.iSubChoicePoints := []

		previous := this
		
		for ignore, goal in goals {
			choicePoint := this.ResultSet.createChoicePoint(goal, this)
		
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Pushing subgoal " . goal.toString(this.ResultSet))
			
			this.iSubChoicePoints.Push(choicePoint)
			
			choicePoint.insert(previous)
			
			previous := choicePoint
		}
	}
	
	removeSubChoicePoints() {
		for ignore, choicePoint in this.iSubChoicePoints
			choicePoint.remove()
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
	
	nextChoice() {
		local resultSet
		local knowledgeBase
		local facts
		local fact
		
		if this.iFirst {
			this.iFirst := false
		
			resultSet := this.ResultSet
			arguments := this.Goal.Arguments
			knowledgeBase := resultSet.KnowledgeBase
			facts := knowledgeBase.Facts
			
			this.iFact := arguments[1].toString(resultSet)
			this.iOldValue := facts.getValue(this.iFact)
	
			fact := this.iFact
			
			if (arguments.Length() == 2) {
				value := arguments[2].toString(resultSet)
				
				if facts.hasFact(fact)
					facts.setValue(fact, value)
				else
					facts.addFact(fact, value)
			}
			else
				facts.removeFact(fact)
			
			return true
		}
		else {
			this.reset()
			
			return false
		}
	}
	
	resetVariables() {
		local facts
		
		base.resetVariables()
		
		if !this.ResultSet.KnowledgeBase.DeterministicFacts {
			facts := this.ResultSet.KnowledgeBase.Facts
			
			if (this.iOldValue != kNotInitialized) {
				if facts.hasFact(this.iFact)
					facts.setValue(this.iFact, this.iOldValue)
				else
					facts.addFact(this.iFact, this.iOldValue)
			}
			else
				facts.removeFact(this.iFact)
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

class ClearFactChoicePoint extends ChoicePoint {
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CallChoicePoint                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallChoicePoint extends ChoicePoint {
	iFirst := true
	
	nextChoice() {
		local resultSet
		
		if this.iFirst {
			this.iFirst := false
		
			resultSet := this.ResultSet
			values := []
			function := false
			
			for index, term in this.Goal.Arguments
				if (index == 1)
					function := term.getValue(resultSet).toString(resultSet)
				else
					values.Push(term.getValue(resultSet).toString(resultSet))
			
			if (resultSet.RuleEngine.TraceLevel <= kTraceMedium)
				resultSet.KnowledgeBase.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", values*) . ")")
			
			return %function%(resultSet.KnowledgeBase, values*)
		}
		else
			return false
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
			
			knowledgeBase.produce()
			
			return true
		}
		else
			return false
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
	
	previous() {
		local resultSet := this.ResultSet
		local ruleEngine := resultSet.RuleEngine
	
		environment := this.Environment
		candidate := base.previous()
		
		Loop {
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
	}
	
	produce() {
		Loop {
			generation := this.Facts.Generation
			produced := false
			
			for ignore, rule in this.Rules.Productions
				if rule.produce(this) {
					if (generation != this.Facts.Generation) {
						produced := true
							
						break
					}
				}
			
			if !produced
				break
		}
	}
	
	prove(goal) {
		local resultSet := this.RuleEngine.createResultSet(this, goal)
		
		if resultSet.nextResult()
			return resultSet
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
		if this.hasFact(fact) {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Setting fact " . fact . " to " . value)
			
			if (this.iFacts[fact] != value)
				this.iGeneration += 1
				
			this.iFacts[fact] := value
		}
		else	
			Throw "Unknown fact """ . fact . """ encountered in Facts.setValue..."
	}
	
	getValue(fact, default := "__NotInitialized__") {
		local facts := this.Facts
		
		if (fact.base == Variable) {
			property := fact.Property
			
			if (property != "")
				fact := (fact.Variable . "." . fact.Property)
			else
				fact := fact.Variable
		}
		else if (fact.base == Literal)
			fact := fact.Literal
		
		return (facts.HasKey(fact) ? facts[fact] : default)
	}
	
	hasFact(fact) {
		return this.Facts.HasKey(fact)
	}
	
	addFact(fact, value) {
		local facts := this.Facts
		
		if facts.HasKey(fact)
			Throw "Duplicate fact """ . fact . """ encountered in Facts.addFact..."
		else {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Adding fact " . fact . " as " . value)
			
			facts[fact] := value
			
			this.iGeneration += 1
		}
	}
	
	removeFact(fact) {
		if this.Facts.HasKey(fact) {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Deleting fact " . fact)
				
			this.Facts.Delete(fact)
			
			this.iGeneration += 1
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Rules                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Rules {
	iProductions := []
	iReductions := {}
	iGeneration := 1
	
	Productions[] {
		Get {
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
		this.iProductions := productions.Clone()
		
		this.sortProductions()
		
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
			rules := this.Productions
			
			for index, rule in rules
				if (priority > rule.Priority) {
					rules.InsertAt(index, rule)
					this.iGeneration += 1
					
					return
				}
					
			rules.Push(rule)
		}
		else
			this.Reductions[rule.Head.Functor, rule.Head.Arity, true].Push(rule)
		
		this.iGeneration += 1
	}
	
	removeRule(rule) {
		if (rule.Type == kProduction)
			rules := this.Productions
		else
			rules := this.Reductions[rule.Head.Functor, rule.Head.Arity]
			
		for index, candidate in rules
			if (rule == candidate) {
				rules.RemoveAt(index)
				this.iGeneration += 1
				
				return
			}
	}
	
	sortProductions() {
		bubbleSort(this.Productions, ObjBindMethod(this, "compareProductions"))
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
	iTraceLevel := kTraceLight
	
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

		knowledgeBase.produce()
		
		return knowledgeBase.Facts
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
	
	trace(traceLevel, message) {
		if (this.iTraceLevel <= traceLevel)
			logMessage(traceLevel, message)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Compiler                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Compiler {
	compileRules(text, ByRef productions, ByRef reductions) {
		productions := []
		reductions := []
		
		Loop Parse, text, `n, `r
		{
			line := Trim(A_LoopField)
			
			if (line != "")
				if InStr(line, "=>") {
					production := this.readProduction(line)
					
					productions.Push(this.createProductionRuleParser(production).parse(production))
				}
				else {
					reduction := this.readReduction(line)
					
					reductions.Push(this.createReductionRuleParser(reduction).parse(reduction))
				}
		}
	}
	
	readReduction(text) {
		local nextCharIndex := 1
		local head := this.readHead(text, nextCharIndex)
		local tail := this.readTail(text, nextCharIndex)
		
		if tail
			return Array(head, "<=", tail*)
		else
			return Array(head)
	}
	
	readProduction(text) {
		local priority := kNotInitialized
		local nextCharIndex := 1
		
		conditions := this.readConditions(text, nextCharIndex, priority)
				
		if (this.readLiteral(text, nextCharIndex) != "=>")
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readProduction..."
			
		actions := this.readActions(text, nextCharIndex)
		
		if (priority != kNotInitialized)
			return concatenate(["priority:", priority], conditions, ["=>"], actions)
		else
			return concatenate(conditions, ["=>"], actions)
	}
	
	readHead(ByRef text, ByRef nextCharIndex) {
		head := this.readCompound(text, nextCharIndex)
		
		if !head
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readHead..."
		else
			return head
	}
	
	readTail(ByRef text, ByRef nextCharIndex) {
		local term
		local literal := this.readLiteral(text, nextCharIndex)
		
		if literal {
			if (literal == "<=") {
				terms := []
				
				Loop {
					term := this.readTailTerm(text, nextCharIndex, (A_Index == 1) ? false : ",")
					
					if term
						terms.Push(term)
					else if (!this.isEmpty(text, nextCharIndex) || (A_index == 1))
						Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readTail..."
					else
						return terms
				}
			}
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readTail..."
		}
		else
			return false
	}
	
	readTailTerm(ByRef text, ByRef nextCharIndex, skip := false) {
		local literal
		
		if skip
			if !this.skipDelimiter(skip, text, nextCharIndex, false)
				return false
			
		literal := this.readLiteral(text, nextCharIndex)
		
		if ((literal == "!") || (literal = "fail"))
			return literal
		else
			return this.readCompound(text, nextCharIndex, literal)
	}
	
	readCompound(ByRef text, ByRef nextCharIndex, functor := false) {
		if !this.isEmpty(text, nextCharIndex) {
			if !functor
				functor := this.readLiteral(text, nextCharIndex)
			
			this.skipDelimiter("(", text, nextCharIndex)
			
			arguments := this.readCompoundArguments(text, nextCharIndex)
			
			this.skipDelimiter(")", text, nextCharIndex)
			
			return Array(functor, arguments*)
		}
		else
			return false
	}
	
	readCompoundArguments(ByRef text, ByRef nextCharIndex) {
		arguments := []
		
		Loop {
			argument := this.readCompoundArgument(text, nextCharIndex)
			
			if argument
				arguments.Push(argument)
			else if (A_Index == 1)
				return arguments
			else
				Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readCompoundArguments..."
			
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

			if (literal == "")
				return false
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
			return false
		
		if this.skipDelimiter("]", text, nextCharIndex, false)
			return "[]"
		else {
			arguments := this.readCompoundArguments(text, nextCharIndex)
			
			if this.skipDelimiter("|", text, nextCharIndex, false) {
				argument := this.readCompoundArgument(text, nextCharIndex)
				
				this.skipDelimiter("]", text, nextCharIndex)
				
				if argument
					return concatenate(["["], arguments, ["|"], Array(argument), ["]"])
				else
					Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readList..."
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
					Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.readConditions..."
				
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				return conditions
		}
	}
	
	readActions(ByRef text, ByRef nextCharIndex) {
		actions := []
		
		Loop {
			this.skipDelimiter("(", text, nextCharIndex)
			
			arguments := Array(this.readLiteral(text, nextCharIndex))
			
			Loop {
				if ((A_Index > 1) && !this.skipDelimiter(",", text, nextCharIndex, false))
					break
				
				arguments.Push(this.readLiteral(text, nextCharIndex))
			}
			
			actions.Push(arguments)
			
			this.skipDelimiter(")", text, nextCharIndex)
			
			if !this.skipDelimiter(",", text, nextCharIndex, false)
				return actions
		}
	}
	
	isEmpty(ByRef text, ByRef nextCharIndex) {
		return (Trim(SubStr(text, nextCharIndex)) == "")
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
			Throw "Syntax error detected in """ . text . """ at " . nextCharIndex . " in Compiler.skipDelimiter..."
		else
			return false
	}
	
	readLiteral(ByRef text, ByRef nextCharIndex, delimiters := "{[()]}|, `t") {
		local literal
		
		length := StrLen(text)
		
		this.skipWhiteSpace(text, nextCharIndex)
		
		beginCharIndex := nextCharIndex
		
		Loop {
			character := SubStr(text, nextCharIndex, 1)
			
			if (InStr(delimiters, character) || (nextCharIndex >= length)) {
				literal := SubStr(text, beginCharIndex, nextCharIndex - beginCharIndex)
				
				if (literal = "true")
					return true
				else if (literal = "false")
					return false
				else
					return literal
			}
			else
				nextCharIndex += 1
		}
	}
	
	parseProductions(rules) {
		result := []
		
		for ignore, rule in rules
			result.Push(this.parseProduction(rule))
			
		return result
	}
	
	parseProduction(rule) {
		return this.createProductionRuleParser(rule).parse(rule)
	}

	parseReductions(rules) {
		result := []
		
		for ignore, rule in rules
			result.Push(this.parseReduction(rule))
			
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
			
		Throw "Unexpected terms detected in Compiler.createTermParser..."
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
			
			name := ((name.Length() == 1) ? new Variable(name[1]) : new Variable(name[1], name[2]))
		
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
			else
				;try {
					tail := this.parseTail(rule, 3)
				/*
				}
				catch exception {
					Throw "Syntax error detected in reduction rule """ . rule.toString() . """ in ReductionRuleParser.parse..."
				}
				*/
		}
		
		return new ReductionRule(head, tail)
	}
	
	parseTail(terms, start) {
		result := []
		
		for index, term in terms
			if (index >= start)
				result.Push(this.Compiler.createTermParser(term, this.Variables, false).parse(term))
				
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
		
		for index, condition in conditions
			if (index >= start)
				result.Push(this.Compiler.createConditionParser(condition, this.Variables).parse(condition))
				
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
		action := expressions[1]
		argument := this.Compiler.createPrimaryParser(expressions[2], this.Variables).parse(expressions[2])
		
		switch action {
			case kCall:
				return new CallAction(argument, this.parseArguments(expressions, 3))
			case kProve:
				return new ProveAction(argument, this.parseArguments(expressions, 3))
			case kSet:
				return new SetFactAction(argument, this.parseArguments(expressions, 3)[1])
			case kClear:
				return new ClearFactAction(argument)
			default:
				Throw "Unknown action type """ . action . """ detected in ActionParser.parse..."
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
		
		for index, term in terms
			if (index >= start)
				result.Push(this.Compiler.createTermParser(term, this.Variables).parse(term))
				
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
		
		for index, term in terms {
			if (((term = "[") && (index != 1)) || ((term = "]") && (index != length))
											   || ((term = "|") && (index != (length - 2))))
				Throw "Unknown list structure """ . values2String(", ", terms*) . """ detected in ListParser.parse..."
			
			if ((index > 1) && (index < length))
				if (term == "|")
					lastTerm := true
				else if (lastTerm == true)
					lastTerm := this.Compiler.createTermParser(term, this.Variables).parse(term)
				else
					subTerms.Push(this.Compiler.createTermParser(term, this.Variables).parse(term))
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

;;; ----------------------------------------------------------------------- ;;;

theCompiler := new Compiler()

theRules =
(
persist(?A.Enkel, ?B) <= Call(showIt, ?A.Enkel, ?B), !, Set(?A.Enkel, true), Set(?B, Grossvater), Produce()
reverse([1,2,3,4], ?L)
reverse([ ?H |?T ], ?REV )<= reverse(?T,?RT), concat(?RT,[?H],?REV)

Priority: 5, {Any: [?Peter.Enkel], [Predicate: ?Peter.Sohn = true]} => (Set: Peter, Gluecklich), (Call: showIt, 1, 2), (Prove: vater, maria, willy), (Call: showIt, 2, 1)
)

productions := false
reductions := false

start := A_TickCount

theCompiler.compileRules(theRules, productions, reductions)

MsgBox % A_TickCount - start . " ms"

for ignore, rule in concatenate(productions, reductions)
	MsgBox % rule.toString()
	
	
	
	
rRule1 := [["reverse", "[]", "[]"]]
rRule2 := [["reverse", ["[", "?H", "|", "?T", "]"], "?REV"], "<=", ["reverse", "?T", "?RT"], ["concat", "?RT", ["[", "?H", "]"], "?REV"]]
rRule3 := [["concat", "[]", "?L", "?L"]]
rRule4 := [["concat", ["[", "?H" , "|", "?T", "]"], "?L", ["[", "?H", "|", "?R", "]"]], "<=", ["concat", "?T", "?L", "?R"]]

rRule5 := [["persist", "?A.Enkel", "?B"], "<=", ["Call", "showIt", "?A.Enkel", "?B"], "!", ["Set", "?A.Enkel", true], ["Set", "?B", "Grossvater"], ["Produce"]]
rRule6 := [["vater", "peter", "frank"], "<=", ["Set", "Peter.Sohn", true], ["Produce"]]
rRule7 := [["vater", "frank", "paul"]]
rRule8 := [["mutter", "peter", "mara"]]
rRule9 := [["grossvater", "?A", "?B"], "<=", ["vater", "?A", "?C"], ["vater", "?C", "?B"], ["persist", "?A", "?B"]]
rRule10 := [["grossvater", "?A", "?B"], "<=", ["mutter", "?A", "?C"], ["vater", "?C", "?B"], ["persist", "?A", "?B"]]
rRule11 := [["mutter", "frank", "barbara"]]
rRule12 := [["vater", "mara", "willy"]]
rRule13 := [["gluecklich", "peter"], "<=", ["stimmung", "!peter"]]
rRule14 := [["ungluecklich", "peter"], "<=", ["stimmung", "!peter"], "!", "fail"]
rRule15 := [["stimmung", "gluecklich"]]

; pRule1 := [["One:", ["?Peter", "=", "Sohn"], ["?Peter", "=", "Enkel"]], "=>", ["Set:", "Peter.Stimmung", "Gluecklich"], ["Call:", "showIt", "1", "2"], ["Prove:", "vater", "maria", "willy"], ["Call:", "showIt", "2", "1"]]

; pRule1 := [["Any:", ["?Peter.Enkel"], ["?Peter.Sohn"]], "=>", ["Set:", "Peter", "Gluecklich"], ["Call:", "showIt", "1", "2"], ["Prove:", "vater", "maria", "willy"], ["Call:", "showIt", "2", "1"]]
pRule1 := [["Any:", ["?Peter.Enkel"], ["?Peter.Sohn"]], "=>", ["Set:", "Peter", "Gluecklich"]]
pRule2 := [["?Peter", "=", "Gluecklich"], "=>", ["Call:", "feiern"]]

showIt(knowledgeBase, enkel, grossvater) {
	; MsgBox %enkel% ist der Enkel von %grossvater%

	return true
}

feiern(knowledgeBase) {
	/*
	MsgBox Chaka!!!!!
	
	message := []

	for key, value in knowledgeBase.Facts.Facts
		message.Push(key . " = " . value)
		
	MsgBox % "Fakten`n`n" . values2String("`n", message*)
	*/
}




engine := new RuleEngine(theCompiler.parseProductions([pRule1, pRule2])
					   , theCompiler.parseReductions([rRule1, rRule2, rRule3, rRule4, rRule5, rRule6, rRule7, rRule8, rRule9, rRule10, rRule11, rRule12, rRule13, rRule14, rRule15]), {})

; goal := ["reverse", ["[", 1, 2, 3, 4, "]"], "?REV"]
; goal := ["reverse", "[]", "[]"]
; goal := ["reverse", ["[", 1, "]"], "?REV"]
; goal := ["concat", ["[", 1, "]"], "[]", ["[", 1, "]"]]
; goal := ["concat", ["[", 1, 2, "]"], ["[", 3, 4, 5, "]"], "?L"]
; goal := theCompiler.parseGoal(goal)

goal := ["grossvater", "?A", "?B"]
goal := theCompiler.parseGoal(goal)

engine.iTraceLevel := kTraceOff

start := A_TickCount

resultSet := engine.prove(goal)

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

goal := ["gluecklich", "peter"]
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
