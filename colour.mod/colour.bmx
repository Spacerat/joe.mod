
SuperStrict


Module Joe.Colour
ModuleInfo "Name: Colour Module"
ModuleInfo "Description: Very basic module for storing and manipulating colours."
ModuleInfo "Version: 0.1.0"
ModuleInfo "Author: Joseph 'Spacerat' Atkins-Turkish"
ModuleInfo "License: Public Domain"

Import brl.max2d

Rem
bbdoc: TColour class.
about: Stores ARGB information.
EndRem
Type TColour
	Field r:Byte, g:Byte, b:Byte, a:Float = 1
	Global savedcol:TColour = Null
	
	Rem
	bbdoc: Creates a new TColour with the given argb values.
	EndRem
	Function CreateRGB:TColour(r:Byte, g:Byte, b:Byte, a:Float = 1)
		Local n:TColour = New TColour
		n.r = Min(Max(r,0),255)
		n.g = Min(Max(g,0),255)
		n.b = Min(Max(b,0),255)
		n.a = a
		Return n
	EndFunction

	Rem
	bbdoc: Return Red
	EndRem
	Function Red:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 0, 0, a)
	End Function

	Rem
	bbdoc: Return Green
	EndRem
	Function Green:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 128, 0, a)
	End Function

	Rem
	bbdoc: Return Lime
	EndRem	
	Function Lime:TColour(a:Float = 1)
		Return TColour.CreateRGB(0,255,0,a)
	End Function

	Rem
	bbdoc: Return Blue
	EndRem	
	Function Blue:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 255, a)
	End Function

	Rem
	bbdoc: Return Cyan
	EndRem
	Function Cyan:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 255, 255, a)
	End Function	

	Rem
	bbdoc: Return Yellow
	EndRem		
	Function Yellow:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 255, 0, a)
	End Function

	Rem
	bbdoc: Return White
	EndRem	
	Function White:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 255, 255, a)
	End Function

	Rem
	bbdoc: Return Black
	EndRem		
	Function Black:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 0, a)
	End Function

	Rem
	bbdoc: Return Magenta
	EndRem		
	Function Magenta:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 0, 255, a)
	End Function

	Rem
	bbdoc: Return Fuchsia
	EndRem	
	Function Fuchsia:TColour(a:Float = 1)
		Return Magenta(a)
	End Function

	Rem
	bbdoc: Return Gray
	EndRem		
	Function Gray:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 128, 128, a)
	End Function

	Rem
	bbdoc: Return Grey
	EndRem
	Function Grey:TColour(a:Float = 1)
		Return Gray(a)
	End Function	

	Rem
	bbdoc: Return Silver
	EndRem	
	Function Silver:TColour(a:Float = 1)
		Return TColour.CreateRGB(191, 191, 191, a)
	End Function

	Rem
	bbdoc: Return Navy
	EndRem	
	Function Navy:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 128, a)
	End Function

	Rem
	bbdoc: Return Olive
	EndRem
	Function Olive:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 128, 0, a)
	End Function

	Rem
	bbdoc: Return Purple
	EndRem	
	Function Purple:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 0, 128, a)
	End Function

	Rem
	bbdoc: Return Maroon
	EndRem		
	Function Maroon:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 0, 0, a)
	End Function

	Rem
	bbdoc: Return Orange
	EndRem	
	Function Orange:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 165, 0, a)
	End Function

	Rem
	bbdoc: Return Brown
	EndRem	
	Function Brown:TColour(a:Float = 1)
		Return TColour.CreateRGB(139, 69, 19, a)
	End Function
	Rem
	
	bbdoc: Return Pink
	EndRem
	Function Pink:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 192, 203, a)
	End Function
			
	Rem
	bbdoc: Creates a new TColour using the given string name.
	EndRem
	Function FromName:TColour(name:String, Alpha:Float = 1)
		Select name.ToLower()
			Case "red"
				Return Red(Alpha)
			Case "green"
				Return Green(Alpha)
			Case "lime"
				Return Lime(Alpha)
			Case "blue"
				Return Blue(Alpha)
			Case "cyan"
				Return Cyan(Alpha)
			Case "yellow"
				Return Yellow(Alpha)
			Case "black"
				Return Black(Alpha)
			Case "white"
				Return White(Alpha)
			Case "magenta"
				Return Magenta(Alpha)
			Case "fuchsia"
				Return Fuchsia(Alpha)
			Case "grey"
				Return Grey(Alpha)
			Case "gray"
				Return Gray(Alpha)
			Case "sliver"
				Return Silver(Alpha)
			Case "navy"
				Return Navy(Alpha)
			Case "olive"
				Return Olive(Alpha)
			Case "purple"
				Return Purple(Alpha)
			Case "maroon"
				Return Maroon(Alpha)
			Case "orange"
				Return Orange(Alpha)
			Case "brown"
				Return Brown(Alpha)
			Case "pink"
				Return Pink(Alpha)
		End Select
	End Function
				
	Rem
	bbdoc: Creates a TColour from a bgra integer.
	EndRem
	Function FromInt:TColour(i:Int)
		Local p:Byte Ptr = Varptr i
		Local n:TColour = TColour.CreateRGB(p[2], p[1], p[0], Float(p[3]) / 255)
		Return n
	EndFunction
	
	Rem
	bbdoc: Get the current Max2D colour as a new TColour object.
	EndRem
	Function GetCurrent:TColour()
		Local r:Int, g:Int, b:Int
		GetColor(r, g, b)
		Return TColour.CreateRGB(r, g, b, GetAlpha())
	End Function
	
	Rem
	bbdoc: Save the current Max2D colour so that it can be retrieved later.
	EndRem
	Function SaveCurrent()
		Local r:Int, g:Int, b:Int
		GetColor(r, g, b)
		savedcol = TColour.CreateRGB(r, g, b, GetAlpha())
	End Function
	
	Rem
	bbdoc: Retrieve the saved Max2D colour 
	EndRem
	Function GetSaved:TColour()
		Return savedcol.Copy()
	EndFunction
	
	Rem
	bbdoc: Convert this TColour to a bgra integer.
	EndRem
	Method ToInt:Int()
		Local n:Int
		Local p:Byte Ptr = Varptr n
		p[0] = b
		p[1] = g
		p[2] = r
		p[3] = Byte(a * 255)
		Return n
	EndMethod
	
	Method ToString:String()
		Return "R: " + String(r) + "  G: " + String(g) + "  B: " + String(b) + "  A: " + String(a)
	End Method
	
	Rem
	bbdoc: Return a new colour darker than this one.
	EndRem	
	Method Darker:TColour(amt:Int=20)
		Return New TColour.CreateRGB(r-amt,g-amt,b-amt,a)
	End Method
	
	Rem
	bbdoc: Return a new colour lighter than this one.
	EndRem
	Method Lighter:TColour(amt:Int=20)
		Return New TColour.CreateRGB(r+amt,g+amt,b+amt,a)
	End Method
	
	Rem
	bbdoc: Set this TColour as the current Max2D TColour.
	EndRem	
	Method Set()
		SetAlpha(a * GetAlpha())
		SetColor(r, g, b)
	End Method
	
	Rem
	bbdoc: Create a copy of this TColour.
	Endrem
	Method Copy:TColour()
		Return TColour.CreateRGB(r, g, b, a)
	End Method
	
EndType

Function ColValue:Byte(col:Int, valnum:Byte)
	Local p:Byte Ptr = Varptr col
	Return p[valnum]
End Function


