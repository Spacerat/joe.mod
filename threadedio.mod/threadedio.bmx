'This file was edited with BLIde
SuperStrict

Import brl.standardio
?threaded
Import brl.threads
Global iomutex:TMutex = CreateMutex()
?

Rem
bbdoc: Thread safe Print()
EndRem
Function TPrint(s:String)
	SetIOLock(True)
	Print(s)
	SetIOLock(False)
End Function

Rem
bbdoc: Thread safe Input()
returns: User input.
EndRem
Function TInput:String(prompt:String = ">")

	SetIOLock(True)
	StandardIOStream.WriteString prompt
	StandardIOStream.Flush
	SetIOLock(False)
		
    Return StandardIOStream.ReadLine()
End Function

Rem
bbdoc: Lock or unlock the IO mutex
EndRem
Function SetIOLock(lock:Int)
	?Threaded
	If lock = True iomutex.Lock() Else iomutex.Unlock()
	?
End Function