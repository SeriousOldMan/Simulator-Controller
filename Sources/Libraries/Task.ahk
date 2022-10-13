;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Task Management                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


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
	static sInterrupt := -50
	static sHigh := -200
	static sNormal := -500
	static sLow := -2000

	static sBlocked := false

	static sLowTasks := []
	static sNormalTasks := []
	static sHighTasks := []
	static sInterruptTasks := []

	static sCurrentTask := false

	iStopped := false
	iRunnable := true
	iSleep := false
	iRunning := false

	iPriority := kNormalPriority
	iNextExecution := false

	iCallable := false

	LowTimer[] {
		Get {
			return (- Task.sLow)
		}

		Set {
			return (Task.sLow := - value)
		}
	}

	NormalTimer[] {
		Get {
			return (- Task.sNormal)
		}

		Set {
			return (Task.sNormal := - value)
		}
	}

	HighTimer[] {
		Get {
			return (- Task.sHigh)
		}

		Set {
			return (Task.sHigh := - value)
		}
	}

	InterruptTimer[] {
		Get {
			return (- Task.sInterrupt)
		}

		Set {
			return (Task.sInterrupt := - value)
		}
	}

	CurrentTask[] {
		Get {
			return Task.sCurrentTask
		}
	}

	Blocked[] {
		Get {
			return Task.sBlocked
		}
	}

	Window[] {
		Get {
			return false
		}
	}

	Priority[] {
		Get {
			return this.iPriority
		}

		Set {
			return (this.iPriority := value)
		}
	}

	NextExecution[] {
		Get {
			return this.iNextExecution
		}

		Set {
			return (this.iNextExecution := value)
		}
	}

	Stopped[] {
		Get {
			return this.iStopped
		}

		Set {
			return (this.iStopped := value)
		}
	}

	Runnable[] {
		Get {
			return ((A_TickCount >= this.NextExecution) && this.iRunnable && !this.Stopped)
		}

		Set {
			return (this.iRunnable := value)
		}
	}

	Sleep[] {
		Get {
			return this.iSleep
		}

		Set {
			return (this.iSleep := value)
		}
	}

	Running[] {
		Get {
			return this.iRunning
		}
	}

	Callable[] {
		Get {
			return this.iCallable
		}
	}

	__New(callable := false, sleep := 0, priority := 2) {
		this.iSleep := ((sleep = kUndefined) ? 0 : sleep)
		this.iNextExecution := (A_TickCount + sleep)

		this.iCallable := callable
		this.iPriority := ((priority = kUndefined) ? kNormalPriority : priority)
	}

	run() {
		local callable := this.Callable
		local result := (isInstance(callable, Task) ? callable.run() : %callable%())

		return (isInstance(result, Task) ? result : false)
	}

	execute() {
		this.iRunning := true

		try {
			return this.run()
		}
		finally {
			this.iRunning := false
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

	getNextTask(priority, remove := true) {
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

	addTask(theTask) {
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

	removeTask(theTask) {
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

	startTask(theTask, sleep := "__Undefined__", priority := "__Undefined__") {
		if isInstance(theTask, Task) {
			if (sleep != kUndefined)
				theTask.iNextExecution := (A_TickCount + sleep)

			if (priority != kUndefined)
				theTask.iPriority := priority
		}
		else
			theTask := new Task(theTask, sleep, priority)

		Task.addTask(theTask)

		theTask.Stopped := false
		theTask.Runnable := true

		return theTask
	}

	stopTask(theTask) {
		theTask.Runnable := false
		theTask.Stopped := true

		Task.removeTask(theTask)
	}

	block(priority) {
		local oldBlocked := Task.sBlocked

		Task.sBlocked := priority

		return oldBlocked
	}

	unblock(priority := false) {
		Task.block(priority)
	}

	yield() {
		Task.schedule()
	}

	schedule(priority := 2) {
		local next, worked, oldScheduling, visited, schedule

		static scheduling := false

		protectionOn(true)

		try {
			if ((scheduling >= priority) || (Task.CurrentTask && (Task.CurrentTask.Priority >= priority)) || (Task.Blocked >= priority)) {
				protectionOff(true)

				return
			}
			else {
				oldScheduling := scheduling
				scheduling := priority

				try {
					if (priority < kInterruptPriority)
						protectionOff(true)

					visited := {}

					loop {
						worked := false

						next := Task.getNextTask(priority, true)

						if next
							if !visited.HasKey(next) {
								visited[next] := true

								worked := true

								Task.launch(next)
							}
							else
								Task.addTask(next)
					} until !worked
				}
				finally {
					scheduling := oldScheduling
				}
			}
		}
		finally {
			schedule := ObjBindMethod(Task, "schedule", priority)

			SetTimer %schedule%, % ((priority == kInterruptPriority) ? Task.sInterrupt : ((priority == kHighPriority) ? Task.sHigh : ((priority == kNormalPriority) ? Task.sNormal : Task.sLow)))

			if (priority == kInterruptPriority)
				protectionOff(true)
		}
	}

	launch(theTask) {
		local oldCurrentTask := Task.CurrentTask
		local oldDefault := A_DefaultGui
		local window := theTask.Window
		local next

		Task.sCurrentTask := theTask

		if window {
			Gui %window%:Default

			Gui %window%:+Disabled
		}

		try {
			next := theTask.execute()
		}
		catch exception {
			logError(exception)

			next := false
		}
		finally {
			if window {
				Gui %oldDefault%:Default

				Gui %window%:-Disabled
			}

			Task.sCurrentTask := oldCurrentTask
		}

		if (next && !next.Stopped)
			Task.addTask(next)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       PeriodicTask                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PeriodicTask extends Task {
	execute() {
		base.execute()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        WindowTask                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowTask extends Task {
	iWindow := false

	Window[] {
		Get {
			return this.iWindow
		}
	}

	__New(window, arguments*) {
		this.iWindow := window

		base.__New(arguments*)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                    WindowPeriodicTask                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class WindowPeriodicTask extends WindowTask {
	execute() {
		base.execute()

		this.NextExecution := (A_TickCount + this.Sleep)

		return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       Continuation                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class Continuation extends Task {
	iTask := false

	Task[] {
		Get {
			return this.iTask
		}
	}

	Window[] {
		Get {
			return this.Task.Window
		}
	}

	__New(task := false, continuation := false, sleep := "__Undefined__", priority := "__Undefined__") {
		if !task
			task := Task.CurrentTask

		this.iTask := task

		if (sleep = kUndefined)
			sleep := task.Sleep

		if (priority = kUndefined)
			priority := task.Priority

		base.__New(continuation, sleep, priority)
	}

	stop() {
		base.stop()

		this.Task.stop()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeTasks() {
	schedule := ObjBindMethod(Task, "schedule", kLowPriority)

	SetTimer %schedule%, % Task.sLow

	schedule := ObjBindMethod(Task, "schedule", kNormalPriority)

	SetTimer %schedule%, % Task.sNormal

	schedule := ObjBindMethod(Task, "schedule", kHighPriority)

	SetTimer %schedule%, % Task.sHigh

	schedule := ObjBindMethod(Task, "schedule", kInterruptPriority)

	SetTimer %schedule%, % Task.sInterrupt
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

SetTimer, initializeTasks, -2000
