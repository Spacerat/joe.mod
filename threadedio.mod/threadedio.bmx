
Module Joe.ThreadedIO

ModuleInfo "Name: ThreadedIO"
ModuleInfo "Description: Some simple functions for thread-safe IO."
ModuleInfo "Version: 0.9.0"
ModuleInfo "Author: Joseph 'spacerat' Atkins-Turkish"
ModuleInfo "License: Public Domain"

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