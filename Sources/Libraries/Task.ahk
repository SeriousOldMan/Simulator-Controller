;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Task Management                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLowPriority := 1
global kNormalPriority := 2
global kHighPriority := 3
global kInterruptPriority := 4


;;;-------------------------------------------------------------------------;;;
;;;                         Public Classes Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                           Task                                    ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Task {
	static sInterrupt := (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Task", "Schedule.Interrupt", 50) * -1)
	static sHigh := (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Task", "Schedule.High", 200) * -1)
	static sNormal := (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Task", "Schedule.Normal", 500) * -1)
	static sLow := (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Task", "Schedule.Low", 2000) * -1)

	static sBlocked := false

	static sLowTasks := []
	static sNormalTasks := []
	static sHighTasks := []
	static sInterruptTasks := []

	static sCurrentTask := false

	static sCriticalHandler := () => (Task.CurrentTask && Task.CurrentTask.Critical)

	iPreviousTask := false

	iStopped := false
	iRunnable := true
	iSleep := false
	iRunning := false

	iPriority := kNormalPriority
	iNextExecution := false

	iCallable := false

	iCritical := false

	static LowTimer {
		Get {
			return (- Task.sLow)
		}

		Set {
			return (Task.sLow := - value)
		}
	}

	static NormalTimer {
		Get {
			return (- Task.sNormal)
		}

		Set {
			return (Task.sNormal := - value)
		}
	}

	static HighTimer {
		Get {
			return (- Task.sHigh)
		}

		Set {
			return (Task.sHigh := - value)
		}
	}

	static InterruptTimer {
		Get {
			return (- Task.sInterrupt)
		}

		Set {
			return (Task.sInterrupt := - value)
		}
	}

	static CriticalHandler {
		Get {
			return Task.sCriticalHandler
		}

		Set {
			return (Task.sCriticalHandler := value)
		}
	}

	static CurrentTask {
		Get {
			return Task.sCurrentTask
		}
	}

	static Critical {
		Get {
			return Task.CriticalHandler.Call()
		}
	}

	static Blocked {
		Get {
			return Task.sBlocked
		}
	}

	Window {
		Get {
			return false
		}
	}

	Priority {
		Get {
			return this.iPriority
		}

		Set {
			return (this.iPriority := value)
		}
	}

	NextExecution {
		Get {
			return this.iNextExecution
		}

		Set {
			return (this.iNextExecution := value)
		}
	}

	Stopped {
		Get {
			return this.iStopped
		}

		Set {
			return (this.iStopped := value)
		}
	}

	Runnable {
		Get {
			return ((A_TickCount >= this.NextExecution) && this.iRunnable && !this.Stopped)
		}

		Set {
			return (this.iRunnable := value)
		}
	}

	Sleep {
		Get {
			return this.iSleep
		}

		Set {
			return (this.iSleep := value)
		}
	}

	Running {
		Get {
			return this.iRunning
		}
	}

	Callable {
		Get {
			return this.iCallable
		}
	}

	Critical {
		Get {
			return (this.iCritical || (this.iPreviousTask && this.iPreviousTask.Critical))
		}

		Set {
			return (this.iCritical := value)
		}
	}

	__New(callable := false, sleep := kUndefined, priority := kUndefined) {
		if (callable && !isInstance(callable, Func))
			throw "Non-function callable detected in Task.__New..."

		this.iSleep := ((sleep = kUndefined) ? 0 : sleep)
		this.iNextExecution := (A_TickCount + this.iSleep)

		this.iCallable := callable
		this.iPriority := ((priority = kUndefined) ? kNormalPriority : priority)
	}

	run() {
		local callable := this.Callable
		local result := (isInstance(callable, Task) ? callable.run() : callable.Call())

		return (isInstance(result, Task) ? result : false)
	}

	execute() {
		this.iRunning := true

		try {
			try {
				return this.run()
			}
			finally {
				this.iRunning := false
			}
		}
		catch Any as exception {
			logError(exception, true)

			return false
		}
	}

	resume() {
		this.Runnable := true
	}

	pause() {
		this.Runnable := false
	}

	start() {
		Task.startTask(this)
	}

	stop() {
		Task.stopTask(this)
	}

	static getPriority(priority) {
		if isInteger(priority) {
			switch priority, false {
				case kLowPriority:
					return "Low"
				case kHighPriority:
					return "High"
				case kInterruptPriority:
					return "Interrupt"
				default:
					return "Normal"
			}
		}
		else
			switch priority, false {
				case "Low":
					return kLowPriority
				case "High":
					return kHighPriority
				case "Interrupt":
					return kInterruptPriority
				default:
					return kNormalPriority
			}
	}

	static getNextTask(priority, remove := true) {
		local index, candidate

		switch priority {
			case kInterruptPriority:
				for index, candidate in Task.sInterruptTasks
					if candidate.Runnable {
						if remove
							Task.sInterruptTasks.RemoveAt(index)

						return candidate
					}
			case kHighPriority:
				for index, candidate in Task.sHighTasks
					if candidate.Runnable {
						if remove
							Task.sHighTasks.RemoveAt(index)

						return candidate
					}
			case kNormalPriority:
				for index, candidate in Task.sNormalTasks
					if candidate.Runnable {
						if remove
							Task.sNormalTasks.RemoveAt(index)

						return candidate
					}
			default:
				for index, candidate in Task.sLowTasks
					if candidate.Runnable {
						if remove
							Task.sLowTasks.RemoveAt(index)

						return candidate
					}
		}

		return false
	}

	static addTask(theTask) {
		switch theTask.Priority {
			case kNormalPriority:
				Task.sNormalTasks.Push(theTask)
			case kHighPriority:
				Task.sHighTasks.Push(theTask)
			case kLowPriority:
				Task.sLowTasks.Push(theTask)
			case kInterruptPriority:
				Task.sInterruptTasks.Push(theTask)
			default:
				throw "Unexpected priority detected in Task.addTask..."
		}
	}

	static removeTask(theTask) {
		switch theTask.Priority {
			case kNormalPriority:
				Task.sNormalTasks := remove(Task.sNormalTasks, theTask)
			case kHighPriority:
				Task.sHighTasks := remove(Task.sHighTasks, theTask)
			case kLowPriority:
				Task.sLowTasks := remove(Task.sLowTasks, theTask)
			case kInterruptPriority:
				Task.sInterruptTasks := remove(Task.sInterruptTasks, theTask)
			default:
				throw "Unexpected priority detected in Task.removeTask..."
		}
	}

	static startTask(theTask, sleep := kUndefined, priority := kUndefined) {
		if isInstance(theTask, Task) {
			if (sleep != kUndefined)
				theTask.iNextExecution := (A_TickCount + sleep)

			if (priority != kUndefined)
				theTask.iPriority := priority
		}
		else
			theTask := Task(theTask, sleep, priority)

		Task.addTask(theTask)

		theTask.Stopped := false
		theTask.Runnable := true

		return theTask
	}

	static stopTask(theTask) {
		theTask.Runnable := false
		theTask.Stopped := true

		Task.removeTask(theTask)
	}

	static block(priority) {
		local oldBlocked := Task.sBlocked

		Task.sBlocked := priority

		return oldBlocked
	}

	static unblock(priority := false) {
		Task.block(priority)
	}

	static yield(schedule := true) {
		if schedule
			Task.schedule()
		else
			Sleep(1)
	}

	static schedule(priority := 2) {
		local next, worked, oldScheduling, visited, schedule
		local unprotect := true

		static scheduling := false

		protectionOn(true)

		try {
			if ((scheduling >= priority) || (Task.CurrentTask && (Task.CurrentTask.Priority >= priority)) || (Task.Blocked >= priority))
				return

			else {
				oldScheduling := scheduling
				scheduling := priority

				try {
					if (priority < kInterruptPriority) {
						protectionOff(true)

						unprotect := false
					}

					visited := Map()

					loop {
						worked := false

						next := Task.getNextTask(priority, true)

						if next
							if !visited.Has(next) {
								visited[next] := true

								worked := true

								Task.launch(next)
							}
							else
								Task.addTask(next)
					}
					until !worked
				}
				finally {
					scheduling := oldScheduling
				}
			}
		}
		finally {
			schedule := ObjBindMethod(Task, "schedule", priority)

			SetTimer(schedule, ((priority == kInterruptPriority) ? Task.sInterrupt : ((priority == kHighPriority) ? Task.sHigh : ((priority == kNormalPriority) ? Task.sNormal : Task.sLow))))

			if unprotect
				protectionOff(true)
		}
	}

	static launch(theTask) {
		local oldCurrentTask := Task.CurrentTask
		local window := theTask.Window
		local next := false
		local curAutoActivate

		theTask.iPreviousTask := oldCurrentTask
		Task.sCurrentTask := theTask

		if window
			window.Block()

		try {
			next := theTask.execute()
		}
		finally {
			if window
				if window.HasProp("AutoActivate") {
					curAutoActivate := window.AutoActivate

					try {
						window.AutoActivate := false

						window.Unblock()
					}
					finally {
						window.AutoActivate := curAutoActivate
					}
				}
				else
					window.Unblock()

			theTask.iPreviousTask := false
			Task.sCurrentTask := oldCurrentTask
		}

		if (next && !next.Stopped) {
			next.NextExecution := (A_TickCount + next.Sleep)

			Task.addTask(next)
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       PeriodicTask                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PeriodicTask extends Task {
	execute() {
		super.execute()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        WindowTask                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowTask extends Task {
	iWindow := false

	Window {
		Get {
			return this.iWindow
		}
	}

	__New(window, arguments*) {
		this.iWindow := window

		super.__New(arguments*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    WindowPeriodicTask                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowPeriodicTask extends WindowTask {
	execute() {
		super.execute()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       Continuation                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Continuation extends Task {
	iTask := false

	Task {
		Get {
			return this.iTask
		}
	}

	Window {
		Get {
			return this.Task.Window
		}
	}

	__New(task := false, continuation := false, sleep := kUndefined, priority := kUndefined) {
		if !task
			task := Task.CurrentTask

		this.iTask := task

		if (sleep = kUndefined)
			sleep := task.Sleep

		if (priority = kUndefined)
			priority := task.Priority

		super.__New(continuation, sleep, priority)
	}

	stop() {
		super.stop()

		this.Task.stop()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

changeProtection(up, protect := false, block := false) {
	static level := 0

	if (protect || block) {
		level += (up ? 1 : -1)

		if (level > 0) {
			if protect
				Critical(100)

			if block
				BlockInput("On")
		}
		else if (level == 0) {
			if block
				BlockInput("Off")

			if protect
				Critical("Off")
		}
		else if (level < 0)
			throw "Nesting error detected in changeProtection..."
	}
}

initializeTasks() {
	schedule := ObjBindMethod(Task, "schedule", kLowPriority)

	SetTimer(schedule, Task.sLow)

	schedule := ObjBindMethod(Task, "schedule", kNormalPriority)

	SetTimer(schedule, Task.sNormal)

	schedule := ObjBindMethod(Task, "schedule", kHighPriority)

	SetTimer(schedule, Task.sHigh)

	schedule := ObjBindMethod(Task, "schedule", kInterruptPriority)

	SetTimer(schedule, Task.sInterrupt)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

protectionOn(critical := false, block := false) {
	changeProtection(true, critical, block)
}

protectionOff(critical := false, block := false) {
	changeProtection(false, critical, block)
}

withProtection(function, params*) {
	protectionOn()

	try {
		return function.Call(params*)
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

SetTimer(initializeTasks, -2000)