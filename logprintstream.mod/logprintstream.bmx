
SuperStrict

Rem
bbdoc: Log Print Stream
about: Log Print Stream provides a simple, pluggable utility for automatically writing all StandardIO output to a file.
End Rem
Module joe.logprintstream


ModuleInfo "Author: Joseph 'Spacerat' Atkins-Turkish"

Import brl.standardio
Import brl.filesystem
Import brl.system

Rem
bbdoc: Log Print stream, logs all standarid IO output.
about: The log print stream allows you to automatically save all standardIO output to a file. To set it
up, simply call New TLogPrintStream.SetLogFile(URL). 
EndRem
Type TLogPrintStream Extends TCStandardIO
	
	Field file:String
	
	Method New()
		StandardIOStream = TTextStream.Create(Self, TTextStream.UTF8)
	End Method

	Rem
	bbdoc: Set the URL of the file to log to, optionally write a header.
	EndRem
	Method SetLogFile(url:String, writeheader:Int = True)

		Local f:TStream = OpenFile(url)
		If f
			file = url
		Else
			CreateFile(url)
			f = OpenFile(url)
			If f
				file = url
			EndIf
		EndIf
		f.Seek(f.Size())
		If (writeheader=True)
			f.WriteLine("__________________")
			f.WriteLine("|BEGIN LOG        |")
			f.WriteLine("|Date: " + CurrentDate() + "|")
			f.WriteLine("|Time: " + CurrentTime()+"   |")
			f.WriteLine("|_________________|")
		EndIf
		f.Close()
		
	End Method
	
	Method Write:Int(buf:Byte Ptr, count:Int)
		If (file)
					
			Local Log:TStream = OpenStream(file, 1, 1)
			Log.Seek(Log.Size())
		
			For Local n:Int = 0 Until Count
				Log.WriteByte(buf[n])
			Next
			
			Log.Close()
		End If
		
		Return Super.Write(buf, count)
	EndMethod
End Type
