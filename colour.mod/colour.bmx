
SuperStrict

Import brl.max2d

Rem
bbdoc: TColour class.
about: Stores ARGB information.
EndRem
Type TColour
	Field r:Byte, g:Byte, b:Byte, a:Float = 1
	
	Rem
	bbdoc: Creates a new TColour with the given argb values.
	EndRem
	Function CreateRGB:TColour(r:Byte, g:Byte, b:Byte, a:Float = 1)
		Local n:TColour = New TColour
		n.r = r
		n.g = g
		n.b = b
		n.a = a
		Return n
	EndFunction

	Function Red:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 0, 0, a)
	End Function

	Function Green:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 128, 0, a)
	End Function
	
	Function Lime:TColour(a:Float = 1)
		Return TColour.CreateRGB(0,255,0,a)
	End Function
	
	Function Blue:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 255, a)
	End Function

	Function Cyan:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 255, 255, a)
	End Function	
		
	Function Yellow:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 255, 0, a)
	End Function
	
	Function White:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 255, 255, a)
	End Function
	
	Function Black:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 0, a)
	End Function
		
	Function Magenta:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 0, 255, a)
	End Function
	
	Function Fuchsia:TColour(a:Float = 1)
		Return Magenta(a)
	End Function
		
	Function Gray:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 128, 128, a)
	End Function

	Function Grey:TColour(a:Float = 1)
		Return Gray(a)
	End Function	
	
	Function Silver:TColour(a:Float = 1)
		Return TColour.CreateRGB(191, 191, 191, a)
	End Function
	
	Function Navy:TColour(a:Float = 1)
		Return TColour.CreateRGB(0, 0, 128, a)
	End Function

	Function Olive:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 128, 0, a)
	End Function
	
	Function Purple:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 0, 128, a)
	End Function
		
	Function Maroon:TColour(a:Float = 1)
		Return TColour.CreateRGB(128, 0, 0, a)
	End Function
	
	Function Orange:TColour(a:Float = 1)
		Return TColour.CreateRGB(255, 165, 0, a)
	End Function
	
	Function Brown:TColour(a:Float = 1)
		Return TColour.CreateRGB(139, 69, 19, a)
	End Function

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


