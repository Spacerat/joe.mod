
SuperStrict

Rem
bbdoc: Advanced text module.
about: Allows you to easilly render wrapped and colour formatted text.
End Rem
Module joe.ADVTEXT

ModuleInfo "Author: Joseph 'Spacerat' Atkins-Turkish"

Import joe.colour

Private
Const OT:String = "<"  'Open Tag
Const CT:String = ">"  'Close Tag
Const NL:String = "\n" 'Newline
Const LineSep:Int = 1  'Line separation

Function DrawWrappedLine(a:String, x:Float, xx:Float Var, yy:Float Var, Width:Int)


	If Width <= 0
		DrawText(a, xx, yy)
		xx:+TextWidth(a)
	ElseIf TextWidth(a) - x + xx < Width
		DrawText(a, xx, yy)
		xx:+TextWidth(a)
	Else
			
		Local l:Int = a.length
		Local p:Int = 0
		Local i:Int = 0
		Local s:String = ""
		
		While i < l + 1
			s = ""
			If TextWidth(a[p..i + 1]) - x + xx > Width
				
			
				Local lastspace:Int
				
			'	If i + 1 < a.Length
				s = a[p..i]
				lastspace = s.findlast(" ", 0) + p
				If lastspace - p > 0
					Local pri:Int = i
					i = lastspace + 1
					
					l:+pri - i
				End If
			'	EndIf

				s = a[p..i]
				p = i
				DrawText(s, xx, yy)
				xx = x
				yy:+TextHeight(s) + LineSep
				
				If TextWidth(a[p..a.length]) - x + xx < Width
					DrawText(a[p..a.length], xx, yy)
					xx:+TextWidth(a[p..a.length])
					Exit
				EndIf
							
			End If
			i:+1
			
		Wend
	
	EndIf
End Function

Public

Rem
bbdoc: Draw optionally wrapped text with colour tags and \n characters.
returns: The height of the text
EndRem
Function DrawParsedText:Int(s:String, x:Float, y:Float, WrapWidth:Int = -1)

	Local xx:Float = x, yy:Float = y
	Local Origcol:TColour = TColour.GetCurrent()
	Local Tag:Int = False
	Local Text:String = ""
	Local Escape:Int = False
	Local Alpha:Float = GetAlpha()
		
	For Local c:Int = 0 Until s.Length
		Local ch:String = Chr(s[c])		
		
		If Tag = 0
			Select ch
				Case "<"
					If Not (Escape)
						Tag = 1
						DrawWrappedLine(Text, x, xx, yy, WrapWidth)
						Text = ""
					Else
						Text:+ch
						Escape = False
					EndIf

				Case "\"
					If (Escape) Text:+ch
					Escape = True
				Case "n"
					If (Escape)
						DrawWrappedLine(Text, x, xx, yy, WrapWidth)
						xx = x
						yy:+TextHeight(s) + LineSep
						Text = ""
					Else
						Text:+ch
					EndIf
					Escape = False
				Case Chr(10), Chr(13)
					DrawWrappedLine(Text, x, xx, yy, WrapWidth)
					xx = x
					yy:+TextHeight(s) + LineSep
					Text = ""
					Escape = False
				Default
					Text:+ch
					Escape = False
			End Select
		ElseIf Tag = 1
			If Ch = ">"
				Tag = 0
				'Parse tag
				
				Local t:Int = Text.Find("=")
				
				If t >= 0
					
					Local Key:String = Text[0..t]
					Local Value:String = Text[t + 1..Text.length]
					
					Select Key.ToLower()
						Case "color", "colour"
							If Value = "default"
								OrigCol.Set()
							Else
								Local nc:TColour = TColour.FromName(Value, GetAlpha())
								If (nc) nc.Set()
							EndIf
						Case "alpha"
							SetAlpha(Value.ToFloat() * Alpha)
					End Select
				Else
					Select Text.ToLower()
						Case "br"
							yy:+TextHeight(s) + LineSep
							xx = x
							Text = ""
						Default
							Local nc:TColour = TColour.FromName(Text, GetAlpha())
							If (nc) nc.Set()
					End Select
				EndIf
				Text = ""
			Else
				Text:+ch
			EndIf
		EndIf
	Next
	DrawWrappedLine(Text, x, xx, yy, WrapWidth)
	OrigCol.Set()
	
	Return (yy + TextHeight("|") + LineSep - y)
End Function
