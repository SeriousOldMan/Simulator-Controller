;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Hybrid Rule Engine              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kAny := "Any:"
global kAll := "All:"
global kOne := "One:"
global kNone := "None:"
global kPredicate := "Predicate:"
global kProve := "Prove:"

global kEqual := "="
global kNotEqual := "!="
global kIdentical := "=="
global kLess := "<"
global kLessOrEqual := "<="
global kGreater := ">"
global kGreaterOrEqual := ">="
global kContains := "contains"

global kCall := "Call:"
global kProve := "Prove:"
global kProveAll := "ProveAll:"
global kSet := "Set:"
global kClear := "Clear:"

global kBuiltinFunctors := ["option", "sqrt", "+", "-", "*", "/", ">", "<", "=<", ">=", "=", "!=", "builtin0", "builtin1", "unbound?", "append", "get"]
global kBuiltinFunctions := [option, squareRoot, plus, minus, multiply, divide, greater, less, lessEqual, greaterEqual, equal, unequal, builtin0, builtin1, unbound, append, get]
global kBuiltinAritys := [2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 3, 1, -1, -1]

global kProduction := "Production"
global kReduction := "Reduction"

global kNotInitialized := "__NotInitialized__"
global kNotFound := "__NotFound__"

global kTraceFull := 1
global kTraceMedium := 2
global kTraceLight := 3
global kTraceOff := 4


;;;-------------------------------------------------------------------------;;;
;;;                          Public Class Section                           ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Condition                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Condition {
	Type {
        Get {
            throw "Virtual property Condition.Type must be implemented in a subclass..."
        }
    }

	getFacts(facts) {
	}

	match(knowledgeBase, variables) {
		throw "Virtual method Condition.match must be implemented in a subclass..."
	}

	toString(facts := kNotInitialized) {
		throw "Virtual method Condition.toString must be implemented in a subclass..."
	}

	toObject(facts := kNotInitialized) {
		return this.toString(facts)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           CompositeCondition                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CompositeCondition extends Condition {
	iConditions := []

	Conditions {
		Get {
			return this.iConditions
		}
	}

	__New(conditions) {
		this.iConditions := conditions
	}

	getFacts(facts) {
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			theCondition.getFacts(facts)
	}

	toString(facts := kNotInitialized) {
		local conditions := []
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			conditions.Push(theCondition.toString(facts))

		return values2String(", ", conditions*)
	}

	toObject(facts := kNotInitialized) {
		local conditions := []
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			conditions.Push(theCondition.toObject(facts))

		return conditions
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Quantor                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Quantor extends CompositeCondition {
	toString(facts := kNotInitialized) {
		return "{" . this.Type . A_Space . super.toString(facts) . "}"
	}

	toObject(facts := kNotInitialized) {
		local quantor := Object()

		quantor[this.Type] := super.toObject(facts)

		return quantor
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ExistQuantor                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ExistQuantor extends Quantor {
	Type {
        Get {
            return kAny
        }
    }

	match(knowledgeBase, variables) {
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			if theCondition.match(knowledgeBase, variables)
				return true

		return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    NotExistQuantor                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NotExistQuantor extends Quantor {
	Type {
        Get {
            return kNone
        }
    }

	match(knowledgeBase, variables) {
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			if theCondition.match(knowledgeBase, variables)
				return false

		return true
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    OneQuantor                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class OneQuantor extends Quantor {
	Type {
        Get {
            return kOne
        }
    }

	match(knowledgeBase, variables) {
		local matched := 0
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			if theCondition.match(knowledgeBase, variables)
				matched += 1

		return (matched == 1)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    AllQuantor                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class AllQuantor extends Quantor {
	Type {
        Get {
            return kAll
        }
    }

	match(knowledgeBase, variables) {
		local matched := 0
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			if theCondition.match(knowledgeBase, variables)
				matched += 1

		return (matched == this.Conditions.Length)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Predicate                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Predicate extends Condition {
	iLeftPrimary := kNotInitialized
	iOperator := kIdentical
	iRightPrimary := kNotInitialized

	Type {
		Get {
			return kPredicate
		}
	}

	LeftPrimary[facts := kNotInitialized] {
		Get {
			if (facts != kNotInitialized)
				return this.iLeftPrimary.getValue(facts)
			else
				return this.iLeftPrimary
		}
	}

	Operator {
		Get {
			return this.iOperator
		}
	}

	RightPrimary[facts := kNotInitialized] {
		Get {
			if ((facts != kNotInitialized) && (this.iRightPrimary != kNotInitialized))
				return this.iRightPrimary.getValue(facts)
			else
				return this.iRightPrimary
		}
	}

	__New(leftPrimary, operator := kNotInitialized, rightPrimary := kNotInitialized) {
		this.iLeftPrimary := leftPrimary
		this.iOperator := operator
		this.iRightPrimary := rightPrimary

		if (((operator = kNotInitialized) && (rightPrimary != kNotInitialized)) || ((operator != kNotInitialized) && (rightPrimary = kNotInitialized)))
			throw "Inconsistent argument combination detected in Predicate.__New..."
	}

	getFacts(facts) {
		local left := this.iLeftPrimary
		local right := this.iRightPrimary

		if ((left != kNotInitialized) && isInstance(left, Variable))
			facts.Push(left.Variable[true])

		if ((right != kNotInitialized) && isInstance(right, Variable))
			facts.Push(right.Variable[true])
	}

	match(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local leftPrimary := this.LeftPrimary[facts]
		local unknown := false
		local rightPrimary, result

		if (leftPrimary = kNotInitialized)
			return false
		else {
			rightPrimary := this.RightPrimary[facts]

			if ((this.Operator != kNotInitialized) && (rightPrimary = kNotInitialized))
				return false

			result := false

			try {
				if isNumber(leftPrimary)
					leftPrimary += 0

				if isNumber(rightPrimary)
					rightPrimary += 0

				switch this.Operator, false {
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
						if isObject(leftPrimary)
							result := inList(leftPrimary, rightPrimary)
						else
							try {
								result := inList(string2Values(",", leftPrimary), rightPrimary)
							}
							catch Any {
							}
					default:
						unknown := true
				}
			}
			catch Any as exception {
				logError(exception)
			}

			if unknown
				throw "Unsupported comparison operator `"" . this.Operator . "`" detected in Predicate.match..."

			if isInstance(this.LeftPrimary, Variable)
				variables.setValue(this.LeftPrimary, leftPrimary)

			if ((this.RightPrimary != kNotInitialized) && isInstance(this.RightPrimary, Variable))
				variables.setValue(this.RightPrimary, rightPrimary)

			return result
		}
	}

	toString(facts := kNotInitialized) {
		if (this.Operator = kNotInitialized)
			return ("[" . this.LeftPrimary.toString(facts) . "]")
		else
			return ("[" . this.LeftPrimary.toString(facts) . A_Space . this.Operator . A_Space . this.RightPrimary.toString(facts) "]")
	}

	toObject(facts := kNotInitialized) {
		local predicate := Object()

		if (this.Operator = kNotInitialized)
			predicate[kPredicate] := [this.LeftPrimary.toObject(facts)]
		else
			predicate[kPredicate] := [this.LeftPrimary.toObject(facts), this.Operator, this.RightPrimary.toObject(facts)]

		return predicate
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Goal                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Goal extends Condition {
	iGoal := false

	Type {
		Get {
			return kProve
		}
	}

	Goal {
		Get {
			return this.iGoal
		}
	}

	__New(goal) {
		this.iGoal := goal
	}

	getFacts(facts) {
		local ignore, term

		for ignore, term in this.Goal.Arguments
			if isInstance(term, Variable)
				facts.Push(term.Variable[true])
			else if isInstance(term, Fact)
				facts.Push(term.Fact)
	}

	match(knowledgeBase, variables) {
		local arguments := []
		local resultSet, arguments, ignore, argument, goal

		for ignore, argument in this.Goal.Arguments
			if isInstance(argument, Variable) {
				if (argument.getValue(variables) != kNotInitialized)
					arguments.Push(Literal(argument.toString(variables)))
				else
					arguments.Push(argument)
			}
			else
				arguments.Push(argument.substituteVariables(variables))

		goal := Struct(this.Goal.Functor, arguments)

		resultSet := knowledgeBase.prove(goal)

		if resultSet {
			goal.doVariables(resultSet, ObjBindMethod(variables, "setValue"))

			resultSet.dispose()

			return true
		}
		else
			return false
	}

	toString(facts := kNotInitialized) {
		return ("{" . kProve . A_Space . this.Goal.toString() . "}")
	}

	toObject(facts := kNotInitialized) {
		local predicate := Object()

		predicate[kProve] := [this.Goal.toObject()]

		return predicate
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Primary                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Primary extends Term {
	getValue(factsOrResultSet, default := kNotInitialized) {
		return this
	}

	toString(factsOrResultSet := kNotInitialized) {
		throw "Virtual method Primary.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Variable                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Variable extends Primary {
	iRootVariable := false
	iVariable := kNotInitialized
	iProperty := false

	RootVariable {
		Get {
			return (this.iRootVariable ? this.iRootVariable : this)
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
		this.iRootVariable := rootVariable

		if ((!property && rootVariable) || (property && !rootVariable))
			throw "Inconsistent argument combination detected in Variable.__New..."

		theClass := this.base
		; thePrototype := this.Prototype

		if (this.base != Variable.Prototype)
			throw "Subclassing of Variable is not allowed..."
	}

	getValue(variablesFactsOrResultSet, default := kNotInitialized) {
		local value

		if (variablesFactsOrResultSet = kNotInitialized)
			return this
		else {
			value := variablesFactsOrResultSet.getValue((isInstance(variablesFactsOrResultSet, Facts) || (isInstance(variablesFactsOrResultSet, Variables))) ? this : this.RootVariable)

			if (isObject(value) && (isInstance(value, Variable) || isInstance(value, Literal) || isInstance(value, Fact)))
				value := value.getValue(variablesFactsOrResultSet, value)

			if (value != kNotInitialized)
				return value
			else
				return default
		}
	}

	doVariables(resultSet, function) {
		function.Call(this, this.getValue(resultSet))
	}

	injectValues(resultSet) {
		return this.toString(resultSet)
	}

	hasVariables() {
		return true
	}

	substituteVariables(variables) {
		local name := this.Variable[true]
		local newVariable

		if variables.Has(name)
			return variables[name]
		else {
			if !this.iProperty
				newVariable := Variable(name)
			else
				newVariable := Variable(this.Variable, this.Property, this.RootVariable.substituteVariables(variables))

			variables[name] := newVariable

			return newVariable
		}
	}

	toString(variablesFactsOrResultSet := kNotInitialized) {
		local property := this.Property
		local name := this.Variable
		local root, value

		if InStr(name, "__Unnamed")
			name := ""

		if (variablesFactsOrResultSet = kNotInitialized)
			return ("?" . name . ((property != "") ? ("." . property) : ""))
		else {
			root := this.RootVariable
			value := (isInstance(variablesFactsOrResultSet, Variables) ? this.getValue(variablesFactsOrResultSet) : root.getValue(variablesFactsOrResultSet))

			if (value = kNotInitialized)
				return "?" . name . ((property != "") ? ("." . property) : "") ; . " (" . &root . ")"
			else if isInstance(value, Term)
				return value.toString(isInstance(variablesFactsOrResultSet, Variables) ? kNotInitialized : variablesFactsOrResultSet) . ((property != "") ? ("." . property) : "")
			else
				return value
		}
	}

	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		local cyclic

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

	Fact {
		Get {
			return this.iFact
		}
	}

	__New(name) {
		this.iFact := name

		if (this.base != Fact.Prototype)
			throw "Subclassing of Fact is not allowed..."
	}

	getValue(factsOrResultSet, default := kNotInitialized) {
		if isInstance(factsOrResultSet, Facts)
			return factsOrResultSet.getValue(this.Fact, default)
		else
			return this
	}

	isUnbound(factsOrResultSet) {
		if isInstance(factsOrResultSet, Facts)
			return (this.getValue(factsOrResultSet) = kNotInitialized)
		else if isInstance(factsOrResultSet, ResultSet)
			return (factsOrResultSet.KnowledgeBase.Facts.getValue(this.Fact, kNotInitialized) = kNotInitialized)
		else
			return false
	}

	toString(factsOrResultSet := kNotInitialized) {
		if (factsOrResultSet = kNotInitialized)
			return false
		else if isInstance(factsOrResultSet, Facts)
			return factsOrResultSet.getValue(this.Fact)
		else if isInstance(factsOrResultSet, ResultSet)
			return factsOrResultSet.KnowledgeBase.Facts.getValue(this.Fact)
		else
			return false
	}

	unify(choicePoint, term) {
		local facts

		if isInstance(term, Literal)
			return (term.Literal = choicePoint.ResultSet.KnowledgeBase.Facts.getValue(this.Fact))
		else if isInstance(term, Fact) {
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

	Literal {
		Get {
			return this.iLiteral
		}
	}

	__New(value) {
		this.iLiteral := value

		if (this.base != Literal.Prototype)
			throw "Subclassing of Literal is not allowed..."
	}

	getValue(factsOrResultSet := kNotInitialized, *) {
		if (factsOrResultSet && (factsOrResultSet != kNotInitialized) && isInstance(factsOrResultSet, Facts))
			return this.Literal
		else
			return this
	}

	isUnbound(resultSetOrFacts) {
		return (this.iLiteral = kNotInitialized)
	}

	toString(factsOrResultSet := kNotInitialized) {
		; return RegExReplace(this.Literal, "([^\\]) ", "$1\ ")
		return this.Literal
	}

	unify(choicePoint, term) {
		if isInstance(term, Literal)
			return (this.Literal = term.Literal)
		else if isInstance(term, Fact)
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
		throw "Virtual method Action.execute must be implemented in a subclass..."
	}

	toString(facts := kNotInitialized) {
		throw "Virtual method Action.toString must be implemented in a subclass..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CallAction                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallAction extends Action {
	iFunction := kNotInitialized
	iArguments := []

	Action {
		Get {
			return kCall
		}
	}

	Function[variablesOrFacts := kNotInitialized] {
		Get {
			if (variablesOrFacts = kNotInitialized)
				return this.iFunction
			else
				return this.iFunction.getValue(variablesOrFacts)
		}
	}

	Arguments[variablesOrFacts := kNotInitialized] {
		Get {
			if isNumber(variablesOrFacts)
				return this.iArguments[variablesOrFacts]
			else if (variablesOrFacts = kNotInitialized)
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
		local arguments, argument, ignore

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

		try {
			%StrReplace(function, ".", "_")%(knowledgeBase, arguments*)
		}
		catch Any as exception {
			logMessage(kLogCritical, "Error while calling function " . function . "...")

			logError(exception, true)
		}
	}

	getValues(facts) {
		local values := []
		local ignore, argument

		for ignore, argument in this.Arguments
			values.Push(argument.getValue(facts, argument))

		return values
	}

	toString(facts := kNotInitialized) {
		local arguments := []
		local ignore, argument

		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(facts))

		return ("(" . this.Action . A_Space .  this.Function.toString(facts) . "(" . values2String(", ", arguments*) . "))")
	}

	toObject(facts := kNotInitialized) {
		local action := Object()
		local arguments := []
		local ignore, argument

		for ignore, argument in this.Arguments
			arguments.Push(argument.toObject(facts))

		action[this.Action] := Array(this.Function.toObject(facts), arguments*)

		return action
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProveAction                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProveAction extends CallAction {
	iProveAll := false

	Action {
		Get {
			return (this.iProveAll ? kProveAll : kProve)
		}
	}

	Functor[variablesOrFacts := kNotInitialized] {
		Get {
			return this.Function[variablesOrFacts]
		}
	}

	__New(function, arguments, proveAll := false) {
		this.iProveAll := proveAll

		super.__New(function, arguments)
	}

	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local resultSet, arguments, ignore, argument, goal

		arguments := []

		for ignore, argument in this.Arguments
			if isInstance(argument, Variable) {
				if (argument.getValue(variables) != kNotInitialized)
					arguments.Push(Literal(argument.toString(variables)))
				else
					arguments.Push(argument)
			}
			else
				arguments.Push(argument.substituteVariables(variables))

		goal := Struct(isInstance(this.Functor, Variable) ? this.Functor[variables] : this.Functor[facts], arguments)

		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceMedium)
			knowledgeBase.RuleEngine.trace(kTraceMedium, "Activate reduction rules with goal " . goal.toString())

		resultSet := knowledgeBase.prove(goal)

		if resultSet {
			goal.doVariables(resultSet, ObjBindMethod(variables, "setValue"))

			if this.iProveAll
				loop
					if !resultSet.nextResult()
						break
					else
						goal.doVariables(resultSet, ObjBindMethod(variables, "setValue"))

			resultSet.dispose()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetFactAction                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetFactAction extends Action {
	iFact := kNotInitialized
	iValue := kNotInitialized

	Fact[variablesOrFacts := kNotInitialized] {
		Get {
			if (variablesOrFacts = kNotInitialized)
				return this.iFact
			else
				return this.iFact.getValue(variablesOrFacts)
		}
	}

	Value[variablesOrFacts := kNotInitialized] {
		Get {
			if (variablesOrFacts = kNotInitialized)
				return this.iValue
			else
				return this.iValue.getValue(variablesOrFacts)
		}
	}

	__New(fact, value := kNotInitialized) {
		this.iFact := fact
		this.iValue := ((value = kNotInitialized) ? Literal(true) : value)
	}

	execute(knowledgeBase, variables) {
		local facts := knowledgeBase.Facts
		local fact := (isInstance(this.Fact, Variable) ? this.Fact[variables] : this.Fact[facts])

		facts.setFact(fact, isInstance(this.Value, Variable) ? this.Value[variables] : this.Value[facts])
	}

	toString(facts := kNotInitialized) {
		if (this.Value == this.Fact)
			return ("(Set: " . this.Fact.toString(facts) . ")")
		else
			return ("(Set: " . this.Fact.toString(facts) . ", " . this.Value.toString(facts) . ")")
	}

	toObject(facts := kNotInitialized) {
		local action := Object()

		if (this.Value == this.Fact)
			action[this.Action] := [this.Fact.toObject(facts)]
		else
			action[this.Action] := [this.Fact.toObject(facts), this.Value.toObject(facts)]

		return action
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    SetComposedFactAction                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SetComposedFactAction extends Action {
	iFact := kNotInitialized
	iValue := kNotInitialized

	Fact[variablesOrFacts := kNotInitialized] {
		Get {
			local result, index, component

			if (variablesOrFacts = kNotInitialized)
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

	Value[variablesOrFacts := kNotInitialized] {
		Get {
			if (variablesOrFacts = kNotInitialized)
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
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= (isInstance(component, Variable) ? component.getValue(variables) : component.getValue(facts))
		}

		facts.setFact(fact, isInstance(this.Value, Variable) ? this.Value[variables] : this.Value[facts])
	}

	toString(facts := kNotInitialized) {
		local fact := ""
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= component.toString(facts)
		}

		return ("(Set: " . fact . ", " . this.Value.toString(facts) . ")")
	}

	toObject(facts := kNotInitialized) {
		local action := Object()
		local fact := ""
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= component.toString(facts)
		}

		action[this.Action] := [fact, this.Value.toObject(facts)]

		return action
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearFactAction                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearFactAction extends Action {
	iFact := kNotInitialized

	Fact[variablesOrFacts := kNotInitialized] {
		Get {
			if (variablesOrFacts = kNotInitialized)
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

		facts.clearFact(isInstance(this.Fact, Variable) ? this.Fact[variables] : this.Fact[facts])
	}

	toString(facts := kNotInitialized) {
		return ("(Clear: " . this.Fact.toString(facts) . ")")
	}

	toObject(facts := kNotInitialized) {
		local action := Object()

		action[kClear] := this.Fact.toObject(facts)

		return action
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ClearComposedFactAction                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ClearComposedFactAction extends Action {
	iFact := kNotInitialized

	Fact[variablesOrFacts := kNotInitialized] {
		Get {
			local result, index, component

			if (variablesOrFacts = kNotInitialized)
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
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= (isInstance(component, Variable) ? component.getValue(variables) : component.getValue(facts))
		}

		facts.clearFact(fact)
	}

	toString(facts := kNotInitialized) {
		local fact := ""
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= component.toString(facts)
		}

		return ("(Clear: " . fact . ")")
	}

	toObject(facts := kNotInitialized) {
		local action := Object()
		local fact := ""
		local index, component

		for index, component in this.Fact {
			if (index > 1)
				fact .= "."

			fact .= component.toString(facts)
		}

		action[kClear] := fact

		return action
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Term                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Term {
	class Complex extends Term {
		iFunctor := ""
		iArguments := []
		iHasVariables := false

		Functor {
			Get {
				return this.iFunctor
			}
		}

		Arity {
			Get {
				return this.Arguments.Length
			}
		}

		Arguments[resultSet := kNotInitialized] {
			Get {
				if isNumber(resultSet)
					return this.iArguments[resultSet]
				else if (resultSet = kNotInitialized)
					return this.iArguments
				else
					return this.getValues(resultSet)
			}
		}

		__New(functor, arguments) {
			this.iFunctor := functor
			this.iArguments := arguments
			this.iHasVariables := this.hasVariables()

			if ((this.base != Struct.Prototype) && (this.base != Cut.Prototype) && (this.base != Fail.Prototype))
				throw "Subclassing of Term.Complex is not allowed..."
		}

		toObject(resultSet := kNotInitialized) {
			local term := Map()
			local arguments := []
			local ignore, argument

			for ignore, argument in this.Arguments
				arguments.Push(argument.toObject(resultSet))

			term[this.Functor] := arguments

			return term
		}

		getValues(resultSet) {
			local values := []
			local ignore, argument

			for ignore, argument in this.Arguments
				values.Push(argument.getValue(resultSet, argument))

			return values
		}

		doVariables(resultSet, function) {
			local ignore, argument

			for ignore, argument in this.Arguments
				argument.doVariables(resultSet, function)
		}

		hasVariables() {
			local ignore, argument

			for ignore, argument in this.Arguments
				if argument.hasVariables()
					return true

			return false
		}

		substituteVariables(variables) {
			local arguments, ignore, argument

			if this.iHasVariables {
				arguments := []

				for ignore, argument in this.Arguments
					arguments.Push(argument.substituteVariables(variables))

				return Struct(this.Functor, arguments)
			}
			else
				return this
		}

		unify(choicePoint, term) {
			local termArguments, index, argument

			if (isInstance(term, Struct) && (this.Functor = term.Functor) && (this.Arity == term.Arity)) {
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
			local ignore, argument

			if (ruleEngine.TraceLevel <= kTraceFull)
				ruleEngine.trace(kTraceFull, "Check whether " . var.toString() . " occurs in " . this.toString(resultSet))

			for ignore, argument in this.Arguments
				if argument.getValue(resultSet, argument).occurs(resultSet, var)
					return true

			return false
		}
	}

	getValue(factsOrResultSet, default := kNotInitialized) {
		return this
	}

	toString(factsOrResultSet := kNotInitialized) {
		throw "Virtual method Term.toString must be implemented in a subclass..."
	}

	toObject(factsOrResultSet := kNotInitialized) {
		return this.toString(factsOrResultSet)
	}

	doVariables(resultSet, function) {
	}

	injectValues(resultSet) {
		return this
	}

	isUnbound(resultSetOrFacts) {
		return (this.getValue(resultSetOrFacts) = kNotInitialized)
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
;;; Sealed Class             Struct                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Struct extends Term.Complex {
	__New(functor, arguments) {
		super.__New(functor, arguments)

		if (this.base != Struct.Prototype)
			throw "Subclassing of Struct is not allowed..."
	}

	toString(resultSet := kNotInitialized) {
		local arguments := []
		local ignore, argument

		for ignore, argument in this.Arguments
			arguments.Push(argument.toString(resultSet))

		return (this.Functor . "(" . values2String(", ", arguments*) . ")")
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Cut                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Cut extends Term.Complex {
	__New() {
		super.__New("!", [])

		if (this.base != Cut.Prototype)
			throw "Subclassing of Cut is not allowed..."
	}

	toString(resultSet := kNotInitialized) {
		return "!"
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Fail                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Fail extends Term.Complex {
	__New() {
		super.__New("fail", [])

		if (this.base != Fail.Prototype)
			throw "Subclassing of Fail is not allowed..."
	}

	toString(resultSet := kNotInitialized) {
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

	LeftTerm {
		Get {
			return this.iLeftTerm
		}
	}

	RightTerm {
		Get {
			return this.iRightTerm
		}
	}

	__New(leftTerm, rightTerm) {
		this.iLeftTerm := leftTerm
		this.iRightTerm := rightTerm
		this.iHasVariables := this.hasVariables()

		if (this.base != Pair.Prototype)
			throw "Subclassing of Pair is not allowed..."
	}

	toString(resultSet := kNotInitialized) {
		local result := "["
		local next := this
		local left, right, separator

		loop {
			left := next.LeftTerm.toString(resultSet)
			right := next.RightTerm.getValue(resultSet, next.RightTerm)

			separator := (!isInstance(right, Nil) ? (isInstance(right, Pair) ? ", " : " | ") : "")

			result := result . left . separator

			if !isInstance(right, Pair) {
				if !isInstance(right, Nil)
					result := result . next.RightTerm.toString(resultSet)

				break
			}
			else
				next := right
		}

		return (result . "]")
	}

	toObject(resultSet := kNotInitialized) {
		local list := []
		local next := this

		loop {
			list.Push(next.LeftTerm.toObject(resultSet))

			if isInstance(next.RightTerm, Pair)
				next := next.RightTerm
			else if isInstance(next.RightTerm, Nil)
				break
			else {
				list.Push(next.RightTerm.toObject(resultSet))

				break
			}
		}

		return list
	}

	doVariables(resultSet, function) {
		this.LeftTerm.doVariables(resultSet, function)
		this.RightTerm.doVariables(resultSet, function)
	}

	injectValues(resultSet) {
		return Pair(this.LeftTerm.injectValues(resultSet), this.RightTerm.injectValues(resultSet))
	}

	hasVariables() {
		return (this.LeftTerm.hasVariables() || this.iRightTerm.hasVariables())
	}

	substituteVariables(variables) {
		if this.iHasVariables
			return Pair(this.LeftTerm.substituteVariables(variables), this.RightTerm.substituteVariables(variables))
		else
			return this
	}

	unify(choicePoint, term) {
		local resultSet

		if isInstance(term, Pair) {
			resultSet := choicePoint.ResultSet

			return (resultSet.unify(choicePoint, this.LeftTerm, term.LeftTerm) && resultSet.unify(choicePoint, this.RightTerm, term.RightTerm))
		}
		else
			return false
	}

	occurs(resultSet, var) {
		local ruleEngine := resultSet.KnowledgeBase.RuleEngine
		local leftTerm, rightTerm

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
		if (this.base != Nil.Prototype)
			throw "Subclassing of Nil is not allowed..."
	}

	toString(resultSet := kNotInitialized) {
		return "[]"
	}

	toObject(resultSet := kNotInitialized) {
		return []
	}

	unify(choicePoint, term) {
		return isInstance(term, Nil)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    Variables                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Variables {
	iVariables := CaseInsenseMap()

	setValue(variable, value) {
		this.iVariables[variable.Variable[true]] := value
	}

	getValue(variable, default := kNotInitialized) {
		local fullName := variable.Variable[true]

		if this.iVariables.Has(fullName)
			return this.iVariables[fullName]
		else
			return default
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Rule                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Rule {
	Type {
        Get {
            throw "Virtual property Rule.Type must be implemented in a subclass..."
        }
    }

	toObject(facts := kNotInitialized) {
		throw "Rules cannot be converted to objects in Rule.toObject..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ProductionRule                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ProductionRule extends Rule {
	iPriority := 0
	iConditions := false
	iActions := []

	Type {
        Get {
            return kProduction
        }
    }

	Priority {
		Get {
			return this.iPriority
		}
	}

	Conditions {
		Get {
			return this.iConditions
		}
	}

	Actions {
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
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			theCondition.getFacts(facts)

		return facts
	}

	match(knowledgeBase) {
		local vars := Variables()
		local ignore, theCondition

		for ignore, theCondition in this.Conditions
			if !theCondition.match(knowledgeBase, vars)
				return false

		return vars
	}

	fire(knowledgeBase, variables) {
		local ignore, theAction

		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Firing rule " . this.toString())

		for ignore, theAction in this.Actions
			theAction.execute(knowledgeBase, variables)
	}

	produce(knowledgeBase) {
		local variables

		if (knowledgeBase.RuleEngine.TraceLevel <= kTraceLight)
			knowledgeBase.RuleEngine.trace(kTraceLight, "Trying rule " . this.toString())

		variables := this.match(knowledgeBase)

		if variables {
			this.fire(knowledgeBase, variables)

			return true
		}
		else
			return false
	}

	toString(facts := kNotInitialized) {
		local priority := this.Priority
		local conditions := ((priority != 0) ? ["Priority: " . priority] : [])
		local actions := []
		local ignore, theCondition, theAction

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

	Type {
        Get {
            return kReduction
        }
    }

	Head {
		Get {
			return this.iHead
		}
	}

	Tail {
		Get {
			return this.iTail
		}
	}

	__New(head, tail) {
		this.iHead := head
		this.iTail := tail
		this.iHasVariables := this.hasVariables()
	}

	toString(resultSet := kNotInitialized) {
		local tail := this.Tail
		local terms, ignore, theTerm

		if (tail && (tail.Length > 0)) {
			terms := []

			for ignore, theTerm in tail
				terms.Push(theTerm.toString(resultSet))

			return (this.Head.toString(resultSet) . " <= " . values2String(", ", terms*))
		}
		else
			return this.Head.toString(resultSet)
	}

	hasVariables() {
		local ignore, theTerm

		if this.Head.hasVariables()
			return true

		for ignore, theTerm in this.Tail
			if theTerm.hasVariables()
				return true

		return false
	}

	substituteVariables() {
		local variables, terms
		local ignore, theTerm

		if this.iHasVariables {
			variables := CaseInsenseMap()
			terms := []

			for ignore, theTerm in this.Tail
				terms.Push(theTerm.substituteVariables(variables))

			return ReductionRule(this.Head.substituteVariables(variables), terms)
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

	iBindings := CaseInsenseMap()

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	Rules {
		Get {
			return this.KnowledgeBase.Rules
		}
	}

	RuleEngine {
		Get {
			return this.KnowledgeBase.RuleEngine
		}
	}

	ChoicePoint[retry := false] {
		Get {
			local choicePoint := this.iChoicePoint
			local next

			if retry
				loop {
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

	dispose() {
		local cp, removeables

		this.iBindings := false

		cp := this.iChoicePoint

		if cp {
			removeables := []

			while cp {
				removeables.Push(cp)

				cp := cp.next()
			}

			ChoicePoint.remove(removeables)
		}

		this.iChoicePoint := false
	}

	resetChoicePoint(choicePoint) {
	}

	setVariable(choicePoint, var, value) {
		local bindings := this.iBindings

		var := ObjPtr(var.RootVariable)

		choicePoint.saveVariable(var, (bindings.Has(var) ? bindings[var] : kNotInitialized))

		bindings[var] := value
	}

	resetVariable(choicePoint, var, oldValue) {
		if (oldValue = kNotInitialized)
			this.iBindings.Delete(var)
		else
			this.iBindings[var] := oldValue

		if (this.RuleEngine.TraceLevel <= kTraceFull)
			this.RuleEngine.trace(kTraceFull, "Reset " . var.toString() . " to " . oldValue)
	}

	unify(choicePoint, termA, termB) {
		if isInstance(termA, Variable)
			termA := termA.RootVariable

		if isInstance(termB, Variable)
			termB := termB.RootVariable

		termA := termA.getValue(this, termA)
		termB := termB.getValue(this, termB)

		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			this.RuleEngine.trace(kTraceMedium, "Unifying " . termA.toString() . " with " . termB.toString())

		if isInstance(termA, Variable) {
			if (this.KnowledgeBase.OccurCheck && termB.occurs(this, termA))
				return false

			if (this.RuleEngine.TraceLevel <= kTraceFull)
				this.RuleEngine.trace(kTraceFull, "Binding " . termA.toString(this) . " to " . termB.toString(this))

			this.setVariable(choicePoint, termA, termB)
		}
		else if isInstance(termB, Variable) {
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
		local tickCount := A_TickCount
		local choicePoint

		if this.iExhausted
			return false

		choicePoint := this.ChoicePoint[true]

		loop {
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

					this.dispose()

					return false
				}
			}
		}
	}

	getValue(var, default := kNotInitialized) {
		local ruleEngine := this.RuleEngine
		local bindings := this.iBindings
		local last := default
		local value, root

		loop {
			var := var.RootVariable

			if (ruleEngine.TraceLevel <= kTraceFull)
				ruleEngine.trace(kTraceFull, "Look for value of " . var.toString()) ; . "(" . &var . ")")

			if (bindings && bindings.Has(ObjPtr(var))) {
				value := bindings[ObjPtr(var)]

				if isInstance(value, Variable) {
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
					ruleEngine.trace(kTraceFull, var.toString() . " is unbound - return " . (isObject(last) ? last.toString() : last))

				return last
			}
		}
	}

	createChoicePoint(goal, environment := false) {
		local functor := goal.Functor
		local builtin

		switch functor, false {
			case "produce":
				return ProduceChoicePoint(this, goal, environment)
			case "call":
				return CallChoicePoint(this, goal, environment)
			case "set":
				return SetFactChoicePoint(this, goal, environment)
			case "clear":
				return ClearFactChoicePoint(this, goal, environment)
			case "!":
				return CutChoicePoint(this, goal, environment)
			case "fail":
				return FailChoicePoint(this, goal, environment)
			default:
				builtin := inList(kBuiltinFunctors, functor)

				if (builtin && ((kBuiltinAritys[builtin] == goal.Arity) || (kBuiltinAritys[builtin] == -1)))
					return CallChoicePoint(this, goal, environment)
				else
					return RulesChoicePoint(this, goal, environment)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           ChoicePoint                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ChoicePoint {
	iDisposed := false

	iPreviousChoicePoint := false
	iNextChoicePoint := false

	iEnvironment := false
	iSavedVariables := Map()

	iResultSet := false
	iGoal := false

	ResultSet {
		Get {
			return this.iResultSet
		}
	}

	KnowledgeBase {
		Get {
			return this.ResultSet.KnowledgeBase
		}
	}

	RuleEngine {
		Get {
			return this.KnowledgeBase.RuleEngine
		}
	}

	Goal {
		Get {
			return this.iGoal
		}
	}

	Environment {
		Get {
			return this.iEnvironment
		}
	}

	SubChoicePoints {
		Get {
			return []
		}

		Set {
			return value
		}
	}

	__New(resultSet, goal, environment) {
		this.iResultSet := resultSet
		this.iGoal := goal
		this.iEnvironment := environment
	}

	dispose() {
		this.iResultSet := false
		this.iGoal := false
		this.iEnvironment := false
		this.iSavedVariables := false
	}

	nextChoice() {
		throw "Virtual method ChoicePoint.nextChoice must be implemented in a subclass..."
	}

	saveVariable(var, value) {
		this.iSavedVariables[var] := value
	}

	resetVariables() {
		local resultSet := this.ResultSet
		local var, value

		for var, value in this.iSavedVariables
			resultSet.resetVariable(this, var, value)

		this.iSavedVariables := Map()
	}

	append(afterChoicePoint) {
		local resultSet := this.ResultSet

		if (resultSet.RuleEngine.TraceLevel <= kTraceMedium)
			resultSet.RuleEngine.trace(kTraceMedium, "Inserting goal " . this.Goal.toString(resultSet) . " after " . afterChoicePoint.Goal.toString(resultSet))

		this.iNextChoicePoint := afterChoicePoint.iNextChoicePoint
		this.iPreviousChoicePoint := afterChoicePoint

		afterChoicePoint.iNextChoicePoint := this

		if this.iNextChoicePoint
			this.iNextChoicePoint.iPreviousChoicePoint := this
	}

	unlink() {
		local next := this.iNextChoicePoint
		local previous := this.iPreviousChoicePoint

		if next
			next.iPreviousChoicePoint := previous

		if previous
			previous.iNextChoicePoint := next

		this.iNextChoicePoint := false
		this.iPreviousChoicePoint := false

		this.dispose()
	}

	static remove(removeables := false) {
		local last, cp, subChoicePoints, scpLength

		if !removeables
			removeables := [this]

		last := removeables.Length

		while (last > 0) {
			cp := removeables[last]

			subChoicePoints := cp.SubChoicePoints
			scpLength := subChoicePoints.Length

			if (scpLength > 0) {
				cp.SubChoicePoints := []

				loop scpLength
					removeables.Push(subChoicePoints[scpLength - A_Index + 1])
			}
			else
				removeables.Pop().unlink()

			last := removeables.Length
		}
	}

	reset() {
		local subChoicePoints := this.SubChoicePoints
		local removeables, ignore, theChoicePoint

		if (subChoicePoints.Length > 0) {
			removeables := []

			for ignore, theChoicePoint in reverse(subChoicePoints)
				removeables.Push(theChoicePoint)

			ChoicePoint.remove(removeables)
		}

		this.resetVariables()

		this.ResultSet.resetChoicePoint(this)
	}

	cut() {
		this.reset()
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
	iSubstitutedReductions := Map()
	iNextRuleIndex := 1

	iSubChoicePoints := []

	SubChoicePoints {
		Get {
			return this.iSubChoicePoints
		}

		Set {
			return (this.iSubChoicePoints := value)
		}
	}

	Reductions[reset := false] {
		Get {
			local ruleEngine, goal, resultSet

			if reset {
				resultSet := this.ResultSet
				goal := this.Goal

				this.iReductions := this.ResultSet.Rules.Reductions[goal.Functor, goal.Arity]

				ruleEngine := resultSet.RuleEngine

				if (ruleEngine.TraceLevel <= kTraceLight) {
					ruleEngine.trace(kTraceLight, "Trying to prove " . goal.toString(resultSet))
					ruleEngine.trace(kTraceLight, this.iReductions.Length . " rules selected for " . goal.toString(resultSet))
				}
			}

			return this.iReductions
		}
	}

	dispose() {
		this.iSubstitutedReductions := Map()
		this.iReductions := []

		super.dispose()
	}

	nextChoice() {
		local rule, resultSet, reductions, index

		reductions := this.Reductions[this.iNextRuleIndex == 1]

		loop {
			index := this.iNextRuleIndex++

			if (index > 1)
				this.reset()

			if (index > reductions.Length) {
				this.iNextRuleIndex := 1

				return false
			}
			else {
				resultSet := this.ResultSet

				rule := reductions[index]

				if !this.iSubstitutedReductions.Has(ObjPtr(rule))
					this.iSubstitutedReductions[ObjPtr(rule)] := rule.substituteVariables()

				rule := this.iSubstitutedReductions[ObjPtr(rule)]

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
		local choicePoint, previous, ignore, theGoal

		this.SubChoicePoints := []

		previous := this

		for ignore, theGoal in goals {
			choicePoint := this.ResultSet.createChoicePoint(theGoal, this)

			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Pushing subgoal " . theGoal.toString(this.ResultSet))

			this.SubChoicePoints.Push(choicePoint)

			choicePoint.append(previous)

			previous := choicePoint
		}
	}

	cut() {
		super.cut()

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

		super.__New(resultSet, goal, environment)
	}

	nextChoice() {
		local resultSet, knowledgeBase, facts, fact, arguments, length, index, argument, value

		if this.iFirst {
			this.iFirst := false

			resultSet := this.ResultSet
			knowledgeBase := resultSet.KnowledgeBase
			facts := knowledgeBase.Facts
			arguments := this.Goal.Arguments
			length := arguments.Length

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
		super.reset()

		this.iFirst := true
	}

	resetVariables() {
		local facts

		super.resetVariables()

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
		super.__New(resultSet, goal, environment, true)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    CallChoicePoint                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallChoicePoint extends ChoicePoint {
	iBuiltin := false
	iFirst := true

	__New(ruleSet, goal, environment) {
		super.__New(ruleSet, goal, environment)

		this.iBuiltin := (goal.Functor != "call")
	}

	nextChoice() {
		local result

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
		super.reset()

		this.iFirst := true
	}

	foreignCall() {
		local resultSet := this.ResultSet
		local function, values, builtin, index, theTerm, value, newValues, callable

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

		try {
			if builtin
				callable := kBuiltinFunctions[inList(kBuiltinFunctors, function)]
			else
				callable := %StrReplace(function, ".", "_")%

			return callable.Call(this, values*)
		}
		catch Any as exception {
			logMessage(kLogCritical, "Error while calling function " . function . "...")

			logError(exception, true)

			return false
		}
	}

	builtinCall() {
		local resultSet := this.ResultSet
		local function := this.Goal.Functor
		local values := []
		local index, theTerm, newValues, value

		for index, theTerm in this.Goal.Arguments
			values.Push(theTerm.getValue(resultSet, theTerm))

		if (resultSet.RuleEngine.TraceLevel <= kTraceMedium) {
			newValues := []

			for index, value in values
				newValues.Push(value.toString(resultSet))

			resultSet.RuleEngine.trace(kTraceMedium, "Call " . function . "(" . values2String(", ", newValues*) . ")")
		}

		try {
			return kBuiltinFunctions[inList(kBuiltinFunctors, function)].Call(this, values*)
		}
		catch Any as exception {
			logMessage(kLogCritical, "Error while calling function " . function . "...")

			logError(exception, true)

			return false
		}
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
		super.reset()

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
		super.reset()

		this.iFirst := true
	}

	previous() {
		local resultSet := this.ResultSet
		local ruleEngine := resultSet.RuleEngine
		local environment := this.Environment
		local candidate := super.previous()

		loop {
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

	RuleEngine {
		Get {
			return this.iRuleEngine
		}
	}

	KnowledgeBase {
		Get {
			return this
		}
	}

	Facts {
		Get {
			return this.iFacts
		}
	}

	Rules {
		Get {
			return this.iRules
		}
	}

	OccurCheck {
		Get {
			return this.iOccurCheck
		}
	}

	DeterministicFacts {
		Get {
			return this.iDeterministicFacts
		}
	}

	__New(ruleEngine, facts, rules, includes := false) {
		local production := rules.Productions[false]

		this.iRuleEngine := ruleEngine
		this.iFacts := facts
		this.iRules := rules

		while production {
			this.registerRuleFacts(production.Rule)

			production := production.Next[false]
		}

		if includes
			this.registerIncludes(includes)
	}

	registerRuleFacts(rule) {
		local facts := this.Facts
		local ignore, theFact, fRules

		for ignore, theFact in rule.getFacts() {
			fRules := facts.getObserver(theFact)

			if !fRules {
				fRules := FactRules(this, theFact)

				facts.registerObserver(theFact, fRules)
			}

			fRules.addRule(rule)
		}
	}

	deregisterRuleFacts(rule) {
		local facts := this.Facts
		local ignore, theFact, fRules

		for ignore, theFact in rule.getFacts() {
			fRules := facts.getObserver(theFact)

			if fRules {
				fRules.removeRule(rule)

				if (fRules.Rules.Length == 0)
					facts.deregisterObserver(theFact, fRules)
			}
			else
				throw "Inconsistency detected in KnowledgeBase.deregisterRuleFacts..."
		}
	}

	factChanged(fact, rules) {
		if (this.RuleEngine.TraceLevel <= kTraceMedium)
			this.RuleEngine.trace(kTraceMedium, "Fact `"" . fact . "`" changed - reactivating " . rules.Length . " rules")

		this.Rules.activateRules(rules)
	}

	compileRules(rules, &productions, &reductions, &includes) {
		this.Rules.compileRules(rules, &productions, &reductions, &includes)
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

	registerIncludes(includes) {
		this.Rules.registerIncludes(includes)
	}

	registerInclude(include) {
		this.Rules.registerInclude(include)
	}

	setValue(fact, value, propagate := false) {
		this.Facts.setValue(fact, value, propagate)
	}

	getValue(fact, default := kNotInitialized) {
		return this.Facts.getValue(fact, default)
	}

	setFact(fact, value, propagate := false) {
		this.Facts.setFact(fact, value, propagate)
	}

	getFact(fact, default := kNotInitialized) {
		return this.Facts.getValue(fact, default)
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
	}

	produce() {
		local facts := this.Facts
		local rules := this.Rules
		local result := false
		local ruleEntry, tickCount, generation, produced, matched

		tickCount := A_TickCount

		loop {
			generation := facts.Generation
			produced := false

			ruleEntry := rules.Productions

			loop {
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
		local tickCount := A_TickCount
		local resultSet

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

	dumpFacts(name := false) {
		this.Facts.dumpFacts(name)
	}

	dumpRules(name := false) {
		this.Rules.dumpRules(name)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Sealed Class             Facts                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Facts {
	iRuleEngine := false
	iFacts := CaseInsenseMap()
	iObservers := CaseInsenseMap()
	iGeneration := 0

	RuleEngine {
		Get {
			return this.iRuleEngine
		}
	}

	Facts {
		Get {
			return this.iFacts
		}

		Set {
			return (this.iFacts := toMap(value, CaseInsenseMap))
		}
	}

	Generation {
		Get {
			return this.iGeneration
		}
	}

	__New(ruleEngine, initialFacts) {
		this.iRuleEngine := ruleEngine
		this.Facts := initialFacts

		if (this.base != Facts.Prototype)
			throw "Subclassing of Facts is not allowed..."
	}

	setValue(fact, value, propagate := false) {
		if (value = kNotInitialized)
			this.clearFact(fact)
		else
			if this.hasFact(fact) {
				if (this.RuleEngine.TraceLevel <= kTraceMedium)
					this.RuleEngine.trace(kTraceMedium, "Setting fact " . fact . " to " . value)

				if ((this.iFacts[fact] != value) || propagate) {
					this.iGeneration += 1

					this.iFacts[fact] := value

					if this.hasObserver(fact)
						this.getObserver(fact).factChanged()
				}
			}
			else
				throw "Unknown fact `"" . fact . "`" encountered in Facts.setValue..."
	}

	getValue(fact, default := kNotInitialized) {
		local facts := this.Facts

		if isInstance(fact, Variable)
			fact := fact.Variable[true]
		else if isInstance(fact, Literal)
			fact := fact.Literal

		return (facts.Has(fact) ? facts[fact] : default)
	}

	setFact(fact, value, propagate := false) {
		if this.hasFact(fact)
			this.setValue(fact, value, propagate)
		else
			this.addFact(fact, value)
	}

	clearFact(fact) {
		if this.Facts.Has(fact) {
			if (this.RuleEngine.TraceLevel <= kTraceMedium)
				this.RuleEngine.trace(kTraceMedium, "Deleting fact " . fact)

			this.Facts.Delete(fact)

			this.iGeneration += 1

			if this.hasObserver(fact)
				this.getObserver(fact).factRemoved()
		}
	}

	hasFact(fact) {
		return this.Facts.Has(fact)
	}

	addFact(fact, value) {
		local facts := this.Facts

		if facts.Has(fact)
			throw "Duplicate fact `"" . fact . "`" encountered in Facts.addFact..."
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
	}

	registerObserver(fact, observer) {
		if this.iObservers.Has(fact)
			throw "Observer already registered for fact `"" . fact . "`""

		this.iObservers[fact] := observer
	}

	deregisterObservers(fact, observer) {
		this.iObservers.Delete(fact)
	}

	hasObserver(fact) {
		return this.iObservers.Has(fact)
	}

	getObserver(fact) {
		local observers := this.iObservers

		return (observers.Has(fact) ? observers[fact] : false)
	}

	dumpFacts(name := false) {
		local key, value, text, fileName

		if !name
			name := StrSplit(A_ScriptName, ".")[1]

		fileName := (kTempDirectory . name . ".knowledge")

		deleteFile(fileName)

		for key, value in this.Facts {
			text := (key . " = " . String(value) . "`n")

			FileAppend(text, fileName)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    FactRules                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FactRules {
	iKnowledgeBase := false
	iFact := ""
	iRules := []

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	Fact {
		Get {
			return this.iFact
		}
	}

	Rules {
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
		local index := inList(rules, rule)

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
	iReductions := CaseInsenseMap()
	iIncludes := []
	iGeneration := 1

	iProductionRules := CaseInsenseMap()

	class Production {
		iNext := false
		iPrevious := false

		iRule := false
		iActive := true

		Next[active := true] {
			Get {
				local candidate := this.iNext

				while candidate
					if (active && !candidate.Active)
						candidate := candidate.iNext
					else
						return candidate

				return candidate
			}
		}

		Previous[active := true] {
			Get {
				local candidate := this.iPrevious

				while candidate
					if (active && !candidate.Active)
						candidate := candidate.iPrevious
					else
						return candidate

				return candidate
			}
		}

		Rule {
			Get {
				return this.iRule
			}
		}

		Active {
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
			local next := this.iNext
			local previous := this.iPrevious

			if next
				next.iPrevious := previous

			if previous
				previous.iNext := next
		}
	}

	RuleEngine {
		Get {
			return this.iRuleEngine
		}
	}

	Productions[active := true] {
		Get {
			local candidate

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
			local reductions := this.iReductions
			local key

			if functor {
				key := functor . "." . arity

				if reductions.Has(key)
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

	Generation {
		Get {
			return this.iGeneration
		}
	}

	__New(ruleEngine, productions, reductions, includes := false) {
		local last := false
		local index, production, entry, ignore, reduction, key

		this.iRuleEngine := ruleEngine

		if includes
			this.iIncludes := includes

		productions := productions.Clone()

		for index, production in this.sortProductions(productions) {
			entry := Rules.Production(production, last)
			last := entry

			if (index == 1)
				this.iProductions := entry
		}

		for ignore, reduction in reductions {
			key := (reduction.Head.Functor . "." . reduction.Head.Arity)

			if !this.iReductions.Has(key)
				this.iReductions[key] := Array()

			this.iReductions[key].Push(reduction)
		}
	}

	compileRules(rules, &productions, &reductions, &includes) {
		local newIncludes := this.iIncludes.Clone()

		RuleCompiler().compileRules(rules, &productions, &reductions, &newIncludes)

		includes := choose(newIncludes, (include) => !inList(this.iIncludes, include))
	}

	addRule(rule) {
		local priority, last, candidate, newProduction

		if (rule.Type == kProduction) {
			priority := rule.Priority
			last := false
			candidate := this.Productions[false]

			loop {
				if !candidate {
					if last
						Rules.Production(rule, last)
					else
						this.iProductions := Rules.Production(rule)

					this.iGeneration += 1

					break
				}
				else if (priority > candidate.Rule.Priority) {
					newProduction := Rules.Production(rule)

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
		local rules, production, index, candidate

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

	registerIncludes(includes) {
		do(includes, (include) => this.registerInclude(include))
	}

	registerInclude(include) {
		if !inList(this.iIncludes, include)
			this.iIncludes.Push(include)
	}

	activateRules(rules) {
		local productionRules := this.iProductionRules
		local ignore, rule

		connectRule(rule) {
			local candidate := this.Productions[false]

			while candidate {
				if (candidate.Rule = rule) {
					productionRules[rule] := candidate

					return true
				}

				candidate := candidate.Next[false]
			}

			return false
		}

		for ignore, rule in rules
			if (productionRules.Has(rule) || connectRule(rule)) {
				if (this.RuleEngine.TraceLevel <= kTraceMedium)
					this.RuleEngine.trace(kTraceMedium, "Reactivating rule " . rule.toString())

				productionRules[rule].activate()
			}
	}

	sortProductions(productions) {
		productions := productions.Clone()

		bubbleSort(&productions, (r1, r2) => r1.Priority < r2.Priority)

		return productions
	}

	dumpRules(name := false) {
		local rules, rule, production, text, ignore, fileName

		if !name
			name := StrSplit(A_ScriptName, ".")[1]

		fileName := (kTempDirectory . name . ".rules")

		deleteFile(fileName)

		production := this.Productions[false]

		loop {
			if !production
				break

			text := (production.Rule.toString() . "`n")

			FileAppend(text, fileName)

			production := production.Next[false]
		}

		for ignore, rules in this.Reductions
			for ignore, rule in rules {
				text := (rule.toString() . "`n")

				FileAppend(text, fileName)
			}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    RuleEngine                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RuleEngine {
	iInitialFacts := Map()
	iInitialProductions := []
	iInitialReductions := []
	iInitialIncludes := []
	iTraceLevel := kTraceOff

	InitialFacts {
		Get {
			return this.iInitialFacts
		}
	}

	InitialProductions {
		Get {
			return this.iInitialProductions
		}
	}

	InitialReductions {
		Get {
			return this.iInitialReductions
		}
	}

	InitialIncludes {
		Get {
			return this.iInitialIncludes
		}
	}

	TraceLevel {
		Get {
			; return (isCritical() ? Min(kTraceLight, this.iTraceLevel) : this.iTraceLevel)

			return this.iTraceLevel
		}
	}

	__New(productions, reductions, facts := false, includes := false) {
		this.iInitialProductions := productions
		this.iInitialReductions := reductions

		if facts
			this.iInitialFacts := facts

		if includes
			this.iInitialIncludes := includes
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
		return Facts(this, this.InitialFacts)
	}

	createRules() {
		return Rules(this, this.InitialProductions, this.InitialReductions, this.InitialIncludes)
	}

	createKnowledgeBase(facts, rules) {
		return KnowledgeBase(this, facts, rules)
	}

	createResultSet(knowledgeBase, goal) {
		return ResultSet(knowledgeBase, goal)
	}

	setTraceLevel(traceLevel) {
		this.iTraceLevel := traceLevel
	}

	trace(traceLevel, message) {
		if (this.TraceLevel <= traceLevel)
			logMessage(kLogOff, "RuleEngine: " . message)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    RuleCompiler                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RuleCompiler {
	compile(fileName, &productions, &reductions, &includes := false, path := false) {
		if !includes
			includes := []

		if !path {
			if !isObject(productions)
				productions := false

			if !isObject(reductions)
				reductions := false
		}

		SplitPath(fileName, , &path)

		this.compileRules(FileRead(fileName), &productions, &reductions, &includes, path)
	}

	compileRules(text, &productions, &reductions, &includes := false, path := false) {
		local incompleteLine := false
		local one, line, currentDirectory, fileName, compiledRule

		if !includes
			includes := []

		if !path {
			if !isObject(productions)
				productions := []

			if !isObject(reductions)
				reductions := []
		}

		loop Parse, text, "`n", "`r" {
			line := Trim(A_LoopField)

			if (InStr(line, "#Include") == 1) {
				fileName := substituteVariables(Trim(SubStr(line, 9)))

				if !inList(includes, fileName) {
					currentDirectory := A_WorkingDir

					try {
						includes.Push(fileName)

						if (path && (Trim(path) != ""))
							SetWorkingDir(path)

						SplitPath(fileName, , &path)

						this.compile(fileName, &productions, &reductions, &includes, path)
					}
					finally {
						SetWorkingDir(currentDirectory)
					}
				}
			}
			else {
				line := Trim(line)
				one := 1

				if ((line != "") && this.skipDelimiter(";", &line, &one, false))
					line := ""

				if (incompleteLine && (line != "")) {
					line := (incompleteLine . line)
					incompleteLine := false
				}

				if ((line != "") && (SubStr(line, StrLen(line), 1) == ","))
					incompleteLine := line
				else if ((line != "") && (StrLen(line) > 1) && ((SubStr(line, StrLen(line) - 1, 2) = "<=") || (SubStr(line, StrLen(line) - 1, 2) = "=>")))
					incompleteLine := (line . A_Space)
				else if ((line != "") && (SubStr(line, StrLen(line), 1) == "\"))
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
		local production := this.readProduction(text)

		return this.createProductionRuleParser(production).parse(production)
	}

	compileReduction(text) {
		local reduction := this.readReduction(text)

		return this.createReductionRuleParser(reduction).parse(reduction)
	}

	compileGoal(text) {
		local one := 1
		local goal := this.readHead(&text, &one)

		return this.createStructParser(goal).parse(goal)
	}

	readReduction(text) {
		local nextCharIndex := 1
		local head := this.readHead(&text, &nextCharIndex)
		local tail := this.readTail(&text, &nextCharIndex)

		if (tail != kNotFound)
			return Array(head, "<=", tail*)
		else
			return Array(head)
	}

	readProduction(text) {
		local priority := kNotInitialized
		local nextCharIndex := 1
		local conditions := this.readConditions(&text, &nextCharIndex, &priority)
		local actions

		if (this.readLiteral(&text, &nextCharIndex) != "=>")
			throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readProduction..."

		actions := this.readActions(&text, &nextCharIndex)

		if (priority != kNotInitialized)
			return concatenate(["priority:", priority], conditions, ["=>"], actions)
		else
			return concatenate(conditions, ["=>"], actions)
	}

	readHead(&text, &nextCharIndex) {
		local head := this.readStruct(&text, &nextCharIndex)

		if (head = kNotFound)
			throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readHead..."
		else
			return head
	}

	readTail(&text, &nextCharIndex) {
		local literal := this.readLiteral(&text, &nextCharIndex)
		local terms, term

		if (literal != "") {
			if (literal == "<=") {
				terms := []

				loop {
					term := this.readTailTerm(&text, &nextCharIndex, (A_Index == 1) ? false : ",")

					if (term != kNotFound)
						terms.Push(term)
					else if (!this.isEmpty(&text, &nextCharIndex) || (A_Index == 1))
						throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readTail..."
					else
						return terms
				}
			}
			else
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readTail..."
		}
		else
			return kNotFound
	}

	readTailTerm(&text, &nextCharIndex, skip := false) {
		local literal
		local struct

		if skip
			if !this.skipDelimiter(skip, &text, &nextCharIndex, false)
				return kNotFound

		literal := this.readLiteral(&text, &nextCharIndex)

		if ((literal == "!") || (literal = "fail"))
			return literal
		else {
			struct := this.readStruct(&text, &nextCharIndex, literal)

			if (struct = kNotFound)
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readTailTerm..."

			return struct
		}
	}

	readStruct(&text, &nextCharIndex, functor := false) {
		local xOperand, operation, yOperand, arguments

		if !this.isEmpty(&text, &nextCharIndex) {
			if !functor
				functor := this.readLiteral(&text, &nextCharIndex)
			else {
				this.skipWhiteSpace(&text, &nextCharIndex)

				operation := SubStr(text, nextCharIndex, 2)

				if inList(["!=", "=<", ">="], operation) {
					; r op x
					nextCharIndex += 2

					xOperand := this.readStructArgument(&text, &nextCharIndex)

					return Array(operation, functor, xOperand)
				}
				else if (SubStr(text, nextCharIndex, 1) = "=") {
					; r = x op y OR x = y
					nextCharIndex += 1

					xOperand := this.readStructArgument(&text, &nextCharIndex)

					this.skipWhiteSpace(&text, &nextCharIndex)

					if !this.isEmpty(&text, &nextCharIndex) {
						operation := SubStr(text, nextCharIndex, 1)

						if InStr("+-*/", operation) {
							nextCharIndex += 1

							yOperand := this.readStructArgument(&text, &nextCharIndex)

							return Array(operation, functor, xOperand, yOperand)
						}
						else
							return Array("=", functor, xOperand)
					}
					else
						return Array("=", functor, xOperand)
				}
				else if InStr("<>", SubStr(text, nextCharIndex, 1))  {
					; x op y

					operation := SubStr(text, nextCharIndex, 1)

					nextCharIndex += 1

					yOperand := this.readLiteral(&text, &nextCharIndex)

					return Array(operation, functor, yOperand)
				}
			}

			this.skipDelimiter("(", &text, &nextCharIndex)

			arguments := this.readStructArguments(&text, &nextCharIndex)

			this.skipDelimiter(")", &text, &nextCharIndex)

			return Array(functor, arguments*)
		}
		else
			return kNotFound
	}

	readStructArguments(&text, &nextCharIndex) {
		local arguments := []
		local argument

		loop {
			argument := this.readStructArgument(&text, &nextCharIndex)

			if ((argument != kNotFound) || (argument = "0"))
				arguments.Push(argument)
			else if (A_Index == 1)
				return arguments
			else
				throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readStructArguments..."

			if !this.skipDelimiter(",", &text, &nextCharIndex, false)
				return arguments
		}
	}

	readStructArgument(&text, &nextCharIndex) {
		local literal, structArguments

		if this.skipDelimiter("[", &text, &nextCharIndex, false)
			return this.readList(&text, &nextCharIndex, false)
		else {
			literal := this.readLiteral(&text, &nextCharIndex)

			if ((literal = "") || (literal = kNotFound))
				return kNotFound
			else if this.skipDelimiter("(", &text, &nextCharIndex, false) {
				structArguments := this.readStructArguments(&text, &nextCharIndex)

				this.skipDelimiter(")", &text, &nextCharIndex)

				return Array(literal, structArguments*)
			}
			else
				return literal
		}
	}

	readList(&text, &nextCharIndex, skip := true) {
		local arguments, argument

		if (skip && !this.skipDelimiter("[", &text, &nextCharIndex, false))
			return kNotFound

		if this.skipDelimiter("]", &text, &nextCharIndex, false)
			return "[]"
		else {
			arguments := this.readStructArguments(&text, &nextCharIndex)

			if this.skipDelimiter("|", &text, &nextCharIndex, false) {
				argument := this.readStructArgument(&text, &nextCharIndex)

				this.skipDelimiter("]", &text, &nextCharIndex)

				if (argument != kNotFound)
					return concatenate(["["], arguments, ["|"], Array(argument), ["]"])
				else
					throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readList..."
			}
			else {
				this.skipDelimiter("]", &text, &nextCharIndex)

				return concatenate(["["], arguments, ["]"])
			}
		}
	}

	readConditions(&text, &nextCharIndex, &priority := false) {
		local conditions := []
		local keyword, leftLiteral, operator, rightLiteral

		loop {
			if this.skipDelimiter("{", &text, &nextCharIndex, false) {
				keyword := this.readLiteral(&text, &nextCharIndex)

				if (keyword = kProve)
					conditions.Push(Array(keyword, this.readStruct(&text, &nextCharIndex)))
				else
					conditions.Push(Array(keyword, this.readConditions(&text, &nextCharIndex)*))

				this.skipDelimiter("}", &text, &nextCharIndex)
			}
			else if this.skipDelimiter("[", &text, &nextCharIndex, false) {
				leftLiteral := this.readLiteral(&text, &nextCharIndex)

				if (leftLiteral = kPredicate)
					leftLiteral := this.readLiteral(&text, &nextCharIndex)

				if this.skipDelimiter("]", &text, &nextCharIndex, false)
					conditions.Push(Array(leftLiteral))
				else {
					operator := this.readLiteral(&text, &nextCharIndex)
					rightLiteral := this.readLiteral(&text, &nextCharIndex)

					conditions.Push(Array(leftLiteral, operator, rightLiteral))

					this.skipDelimiter("]", &text, &nextCharIndex)
				}
			}
			else if priority
				if (this.readLiteral(&text, &nextCharIndex) = "priority:")
					priority := this.readLiteral(&text, &nextCharIndex)
				else
					throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.readConditions..."

			if !this.skipDelimiter(",", &text, &nextCharIndex, false)
				return conditions
		}
	}

	readActions(&text, &nextCharIndex) {
		local actions := []
		local action, arguments

		loop {
			this.skipDelimiter("(", &text, &nextCharIndex)

			action := this.readLiteral(&text, &nextCharIndex)

			if inList([kCall, kProve, kProveAll], action)
				actions.Push(Array(action, this.readStruct(&text, &nextCharIndex)))
			else {
				arguments := Array(action)

				loop {
					if ((A_Index > 1) && !this.skipDelimiter(",", &text, &nextCharIndex, false))
						break

					arguments.Push(this.readLiteral(&text, &nextCharIndex))
				}

				actions.Push(arguments)
			}

			this.skipDelimiter(")", &text, &nextCharIndex)

			if !this.skipDelimiter(",", &text, &nextCharIndex, false)
				return actions
		}
	}

	isEmpty(&text, &nextCharIndex) {
		local remainingText := Trim(SubStr(text, nextCharIndex))
		local one := 1

		if ((remainingText != "") && this.skipDelimiter(";", &remainingText, &one, false))
			remainingText := ""

		return (remainingText = "")
	}

	skipWhiteSpace(&text, &nextCharIndex) {
		local length := StrLen(text)

		loop {
			if (nextCharIndex > length)
				return

			if InStr(" `t`n`r", SubStr(text, nextCharIndex, 1))
				nextCharIndex += 1
			else
				return
		}
	}

	skipDelimiter(delimiter, &text, &nextCharIndex, throwError := true) {
		local length := StrLen(delimiter)

		this.skipWhiteSpace(&text, &nextCharIndex)

		if (SubStr(text, nextCharIndex, length) = delimiter) {
			nextCharIndex += length

			return true
		}
		else if throwError
			throw "Syntax error detected in `"" . text . "`" at " . nextCharIndex . " in RuleCompiler.skipDelimiter..."
		else
			return false
	}

	readLiteral(&text, &nextCharIndex, delimiters := "{[()]}|`, `t") {
		local length := StrLen(text)
		local literal, beginCharIndex, quoted, hasQuote, character, isDelimiter, rnd

		this.skipWhiteSpace(&text, &nextCharIndex)

		beginCharIndex := nextCharIndex
		quoted := false
		hasQuote := false

		loop {
			character := SubStr(text, nextCharIndex, 1)

			if ((A_Index == 1) && ((character == "`"") || (character == "'")))
				hasQuote := character
			else if (hasQuote && (A_Index == 2))
				delimiters := hasQuote

			if (!hasQuote && (character == "\")) {
				nextCharIndex := nextCharIndex + 2

				quoted := true

				continue
			}

			if (character != "")
				isDelimiter := InStr(delimiters, character)
			else
				isDelimiter := false

			if (isDelimiter || (nextCharIndex > length)) {
				literal := SubStr(text, beginCharIndex, nextCharIndex - beginCharIndex)

				if (hasQuote && isDelimiter) {
					nextCharIndex += 1

					return SubStr(literal, 2, StrLen(literal) - 1)
				}
				else if (literal = kTrue)
					return true
				else if (literal = kFalse)
					return false
				else if (!hasQuote && quoted) {
					rnd := Random(1, 100000)

					return StrReplace(StrReplace(StrReplace(literal, "\\", "###" . rnd . "###"), "\", ""), "###" . rnd . "###", "\")
				}
				else
					return literal
			}
			else
				nextCharIndex += 1
		}
	}

	parseProductions(rules) {
		local result := []
		local ignore, theRule

		for ignore, theRule in rules
			result.Push(this.parseProduction(theRule))

		return result
	}

	parseProduction(rule) {
		return this.createProductionRuleParser(rule).parse(rule)
	}

	parseReductions(rules) {
		local result := []
		local ignore, theRule

		for ignore, theRule in rules
			result.Push(this.parseReduction(theRule))

		return result
	}

	parseReduction(rule) {
		return this.createReductionRuleParser(rule).parse(rule)
	}

	parseGoal(goal) {
		return this.createStructParser(goal).parse(goal)
	}

	createProductionRuleParser(condition, variables := kNotInitialized) {
		return ProductionRuleParser(this, variables)
	}

	createReductionRuleParser(condition, variables := kNotInitialized) {
		return ReductionRuleParser(this, variables)
	}

	createConditionParser(condition, variables := kNotInitialized) {
		return ConditionParser(this, variables)
	}

	createPredicateParser(predicate, variables := kNotInitialized) {
		return PredicateParser(this, variables)
	}

	createPrimaryParser(predicate, variables := kNotInitialized) {
		return PrimaryParser(this, variables)
	}

	createActionParser(action, variables := kNotInitialized) {
		return ActionParser(this, variables)
	}

	createTermParser(term, variables := kNotInitialized, forArguments := true) {
		local complex := isObject(term)

		if ((term == "!") && !forArguments)
			return CutParser(this, variables)
		else if ((term = "fail") && !forArguments)
			return FailParser(this, variables)
		else if (!complex && (StrReplace(term, A_Space, "") == "[]") && forArguments)
			return NilParser(this, variables)
		else if (!complex && forArguments)
			return PrimaryParser(this, variables)
		else if complex {
			if ((term[1] == "[") && forArguments)
				return ListParser(this, variables)
			else
				return this.createStructParser(this, variables)
		}

		throw "Unexpected terms detected in RuleCompiler.createTermParser..."
	}

	createStructParser(term, variables := kNotInitialized) {
		return StructParser(this, variables)
	}

	createProductionRule(conditions, actions, priority) {
		return ProductionRule(conditions, actions, priority)
	}

	createReductionRule(head, tail) {
		return ReductionRule(head, tail)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Abstract Class           Parser                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Parser {
	iCompiler := false
	iVariables := kNotInitialized

	Compiler {
		Get {
			return this.iCompiler
		}
	}

	Variables {
		Get {
			return this.iVariables
		}
	}

	__New(compiler, variables := kNotInitialized) {
		this.iCompiler := compiler
		this.iVariables := ((variables = kNotInitialized) ? CaseInsenseMap() : variables)
	}

	getVariable(name) {
		local key, variables, rootName, rootVariable

		if (SubStr(name, 1, 1) == "?")
			name := SubStr(name, 2)

		if (name = "")
			name := ("__Unnamed" . Random(0, 2147483647) . "__")

		key := StrReplace(StrReplace(name, A_Space, ""), A_Tab, "")

		variables := this.iVariables

		if variables.Has(key)
			return variables[key]
		else {
			name := StrSplit(name, ".", " `t", 2)
			rootName := name[1]

			if variables.Has(rootName)
				rootVariable := variables[rootName]
			else {
				rootVariable := Variable(rootName)

				variables[rootName] := rootVariable
			}

			name := ((name.Length == 1) ? rootVariable : Variable(rootName, name[2], rootVariable))

			variables[key] := name

			return name
		}
	}

	parse(expression) {
		throw "Virtual method Parser.parse must be implemented in a subclass..."
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
		local parseActions := false
		local parsePriority := false
		local conditions := []
		local actions := []
		local priority := 0
		local ignore, expression

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
			throw "Syntax error detected in production rule in ProductionRuleParser.parse..."
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ReductionRuleParser                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ReductionRuleParser extends RuleParser {
	parse(rule) {
		local head := this.Compiler.createStructParser(rule[1], this.Variables).parse(rule[1])
		local tail := []

		if (rule.Length > 1) {
			if (rule[2] != "<=")
				throw "Syntax error detected in reduction rule in ReductionRuleParser.parse..."
			else {
				try {
					tail := this.parseTail(rule, 3)
				}
				catch Any {
					throw "Syntax error detected in reduction rule in ReductionRuleParser.parse..."
				}
			}
		}

		return ReductionRule(head, tail)
	}

	parseTail(terms, start) {
		local result := []
		local index, theTerm

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
		switch expressions[1], false {
			case kAll:
				return AllQuantor(this.parseArguments(expressions, 2))
			case kOne:
				return OneQuantor(this.parseArguments(expressions, 2))
			case kAny:
				return ExistQuantor(this.parseArguments(expressions, 2))
			case kNone:
				return NotExistQuantor(this.parseArguments(expressions, 2))
			case kProve:
				return Goal(this.parseStruct(expressions, 2))
			default:
				return this.Compiler.createPredicateParser(expressions, this.Variables).parse(expressions)
		}
	}

	parseArguments(conditions, start) {
		local result := []
		local index, theCondition

		for index, theCondition in conditions
			if (index >= start)
				result.Push(this.Compiler.createConditionParser(theCondition, this.Variables).parse(theCondition))

		return result
	}

	parseStruct(conditions, start) {
		return this.Compiler.createStructParser(conditions[2], this.Variables).parse(conditions[2])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    PredicateParser                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PredicateParser extends Parser {
	parse(expressions) {
		if (expressions.Length == 3)
			return Predicate(this.Compiler.createPrimaryParser(expressions[1]
															 , this.Variables).parse(expressions[1])
																				   , expressions[2]
																				   , this.Compiler.createPrimaryParser(expressions[3]
																													 , this.Variables).parse(expressions[3]))
		else
			return Predicate(this.Compiler.createPrimaryParser(expressions[1], this.Variables).parse(expressions[1]))
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
			return Fact(SubStr(expression, 2))
		else
			return Literal(expression)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ActionParser                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ActionParser extends Parser {
	parse(expressions) {
		local action := expressions[1]
		local struct, argument, arguments

		switch action, false {
			case kCall:
				struct := this.Compiler.createStructParser(expressions[2]).parse(expressions[2])

				return CallAction(Literal(struct.Functor), struct.Arguments)
			case kProve:
				struct := this.Compiler.createStructParser(expressions[2]).parse(expressions[2])

				return ProveAction(Literal(struct.Functor), struct.Arguments)
			case kProveAll:
				struct := this.Compiler.createStructParser(expressions[2]).parse(expressions[2])

				return ProveAction(Literal(struct.Functor), struct.Arguments, true)
			default:
				argument := this.Compiler.createPrimaryParser(expressions[2], this.Variables).parse(expressions[2])

				switch action, false {
					case kSet:
						arguments := this.parseArguments(expressions, 3)

						if (arguments.Length = 1)
							return SetFactAction(argument, arguments[1])
						else if (arguments.Length > 1)
							return SetComposedFactAction(argument, arguments*)
						else
							return SetFactAction(argument)
					case kClear:
						arguments := this.parseArguments(expressions, 3)

						if (arguments.Length > 0)
							return ClearComposedFactAction(argument, arguments*)
						else
							return ClearFactAction(argument)
					default:
						throw "Unknown action type `"" . action . "`" detected in ActionParser.parse..."
				}
		}
	}

	parseArguments(expressions, start) {
		local result := []
		local index, expression

		for index, expression in expressions
			if (index >= start)
				result.Push(this.Compiler.createPrimaryParser(expression, this.Variables).parse(expression))

		return result
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    StructParser                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StructParser extends Parser {
	parse(terms) {
		return Struct(terms[1], this.parseArguments(terms, 2))
	}

	parseArguments(terms, start) {
		local result := []
		local index, theTerm

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
		return Cut()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    FailParser                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class FailParser extends Parser {
	parse(terms) {
		return Fail()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    ListParser                                     ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ListParser extends Parser {
	parse(terms) {
		local length := terms.Length
		local subTerms := []
		local lastTerm := false
		local index, theTerm

		for index, theTerm in terms {
			if (((theTerm = "[") && (index != 1)) || ((theTerm = "]") && (index != length))
												  || ((theTerm = "|") && (index != (length - 2))))
				throw "Unexpected list structure `"" . values2String(", ", terms*) . "`" detected in ListParser.parse..."

			if ((index > 1) && (index < length))
				if (theTerm == "|")
					lastTerm := true
				else if (lastTerm == true)
					lastTerm := this.Compiler.createTermParser(theTerm, this.Variables).parse(theTerm)
				else
					subTerms.Push(this.Compiler.createTermParser(theTerm, this.Variables).parse(theTerm))
		}

		if !lastTerm
			lastTerm := Nil()

		index := subTerms.Length

		loop
			lastTerm := Pair(subTerms[index], lastTerm)
		until (--index == 0)

		return lastTerm
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    NilParser                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class NilParser extends Parser {
	parse(terms) {
		return Nil()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

messageBox(ignore, args*) {
	withBlockedWindows(MsgBox, values2String(A_Space, args*))

	return true
}

messageShow(ignore, args*) {
	showMessage(values2String(A_Space, args*))

	return true
}

option(choicePoint, option, value) {
	if isInstance(option, Term)
		option := option.toString(resultSet)

	if isInstance(value, Term)
		value := value.toString(resultSet)

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
	local value1, value2

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if isInstance(operand1, Variable) {
		if isInstance(operand2, Variable)
			return false
		else
			return resultSet.unify(choicePoint, operand1, Literal(operand2.toString(resultSet) * operand2.toString(resultSet)))
	}
	else if isInstance(operand2, Variable) {
		if isInstance(operand1, Variable)
			return false
		else {
			value1 := operand1.toString(resultSet)

			if !isNumber(value1)
				return false

			return resultSet.unify(choicePoint, operand2, Literal(Sqrt(value1)))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		return (Sqrt(value1) = value2)
	}
}

plus(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	local value1, value2, value3

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)

	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value2)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand1, Literal(value2 + value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand2, Literal(value1 - value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value2)
				return false

			return resultSet.unify(choicePoint, operand3, Literal(value1 - value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		if !isNumber(value3)
			return false

		return (value1 = (value2 + value3))
	}
}

minus(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	local value1, value2, value3

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)

	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value2)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand1, Literal(value2 - value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand2, Literal(value1 + value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value2)
				return false

			return resultSet.unify(choicePoint, operand3, Literal(value1 + value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		if !isNumber(value3)
			return false

		return (value1 = (value2 - value3))
	}
}

multiply(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	local value1, value2, value3

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)

	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value2)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand1, Literal(value2 * value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value1)
				return false

			if (!isNumber(value3) || (value3 = 0))
				return false

			return resultSet.unify(choicePoint, operand2, Literal(value1 / value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)

			if !isNumber(value1)
				return false

			if (!isNumber(value2) || (value2 = 0))
				return false

			return resultSet.unify(choicePoint, operand3, Literal(value1 / value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		if !isNumber(value3)
			return false

		return (value1 = (value2 * value3))
	}
}

divide(choicePoint, operand1, operand2, operand3) {
	local resultSet := choicePoint.ResultSet
	local value1, value2, value3

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)
	operand3 := operand3.getValue(resultSet, operand3)

	if isInstance(operand1, Variable) {
		if (isInstance(operand2, Variable) || isInstance(operand3, Variable) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value2 := operand2.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value2)
				return false

			if (!isNumber(value3) || (value3 = 0))
				return false

			return resultSet.unify(choicePoint, operand1, Literal(value2 / value3))
		}
	}
	else if isInstance(operand2, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand3, Variable) || (operand1.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value3 := operand3.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value3)
				return false

			return resultSet.unify(choicePoint, operand2, Literal(value1 * value3))
		}
	}
	else if isInstance(operand3, Variable) {
		if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else {
			value1 := operand1.toString(resultSet)
			value2 := operand2.toString(resultSet)

			if !isNumber(value1)
				return false

			if !isNumber(value2)
				return false

			return resultSet.unify(choicePoint, operand3, Literal(value1 * value2))
		}
	}
	else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)) || (operand3.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)
		value3 := operand3.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		if (!isNumber(value3) || (value3 = 0))
			return false

		return (value1 = (value2 / value3))
	}
}

greater(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	local value1, value2

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		return (value1 > value2)
	}
}

less(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	local value1, value2

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		return (value1 < value2)
	}
}

lessEqual(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	local value1, value2

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		return (value1 <= value2)
	}
}

greaterEqual(choicePoint, operand1, operand2) {
	local resultSet := choicePoint.ResultSet
	local value1, value2

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if (isInstance(operand1, Variable) || isInstance(operand2, Variable) || (operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
		return false
	else {
		value1 := operand1.toString(resultSet)
		value2 := operand2.toString(resultSet)

		if !isNumber(value1)
			return false

		if !isNumber(value2)
			return false

		return (value1 >= value2)
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

	if isInstance(function, Term)
		function := function.toString(resultSet)

	try {
		return resultSet.unify(choicePoint, Literal(%function%()), operand1.getValue(resultSet, operand1))
	}
	catch Any as exception {
		logMessage(kLogCritical, "Error while calling function " . function . "...")

		logError(exception, true)

		return false
	}
}

builtin1(choicePoint, function, operand1, operand2) {
	local resultSet := choicePoint.ResultSet

	operand1 := operand1.getValue(resultSet, operand1)
	operand2 := operand2.getValue(resultSet, operand2)

	if isInstance(function, Term)
		function := function.toString(resultSet)

	if (isInstance(operand1, Variable) || operand1.isUnbound(resultSet))
		return false
	else
		try {
			return resultSet.unify(choicePoint, Literal(%function%(operand1.toString(resultSet))), operand2)
		}
		catch Any as exception {
			logMessage(kLogCritical, "Error while calling function " . function . "...")

			logError(exception, true)

			return false
		}
}

unbound(choicePoint, operand1) {
	local value := operand1.getValue(choicePoint.ResultSet, operand1)

	if (value.toString(choicePoint.ResultSet) = kNotInitialized)
		return true
	else if isInstance(operand1, Variable)
		return ((value = operand1) || (value = operand1.RootVariable))
	else if isInstance(operand1, Fact)
		return (operand1.getValue(choicePoint.ResultSet.KnowledgeBase.Facts) = kNotInitialized)
}

append(choicePoint, arguments*) {
	local resultSet, operand1, string, ignore, argument

	if (arguments.Length <= 1)
		return false
	else {
		resultSet := choicePoint.ResultSet

		operand1 := arguments.Pop()
		operand1 := operand1.getValue(resultSet, operand1)

		string := ""

		for ignore, argument in arguments
			string .= argument.getValue(resultSet, argument).toString(resultSet)

		if isInstance(operand1, Variable)
			return resultSet.unify(choicePoint, operand1, Literal(string))
		else
			return (operand1.toString(resultSet) = string)
	}
}

get(choicePoint, arguments*) {
	local resultSet, operand1, operand2, result, index, argument

	if (arguments.Length <= 1)
		return false
	else {
		resultSet := choicePoint.ResultSet

		if (arguments.Length = 2) {
			operand1 := arguments[1]
			operand2 := arguments[2]

			operand1 := Literal(resultSet.KnowledgeBase.Facts.getValue(operand1.getValue(resultSet, operand1).toString(resultSet)))
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

			operand1 := Literal(resultSet.KnowledgeBase.Facts.getValue(result))
		}

		if (isInstance(operand2, Variable) && !operand1.isUnbound(resultSet))
			return resultSet.unify(choicePoint, operand1, operand2)
		else if ((operand1.isUnbound(resultSet)) || (operand2.isUnbound(resultSet)))
			return false
		else
			return (operand1.toString(resultSet) = operand2.toString(resultSet))
	}
}