
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

Function DrawWrappedLine(a:String, x:Float, xx:Float Var, yy:Float Var, Width:Int, shadow:Int = False)


	If Width <= 0
		DrawTextShadow(a, xx, yy,,, shadow)
		xx:+TextWidth(a)
	ElseIf TextWidth(a) - x + xx < Width
		DrawTextShadow(a, xx, yy,,, shadow)
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
				If (shadow)
					DrawTextShadow(s, xx, yy)
				Else
					DrawTextShadow(s, xx, yy,,, shadow)
				EndIf
				xx = x
				yy:+TextHeight(s) + LineSep
				
				If TextWidth(a[p..a.length]) - x + xx < Width
					DrawTextShadow(a[p..a.length], xx, yy,,, shadow)
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
	Local shadow:Int = False
	For Local c:Int = 0 Until s.Length
		Local ch:String = Chr(s[c])		
		
		If Tag = 0
			Select ch
				Case "<"
					If Not (Escape)
						Tag = 1
						DrawWrappedLine(Text, x, xx, yy, WrapWidth, shadow)
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
						DrawWrappedLine(Text, x, xx, yy, WrapWidth, shadow)
						xx = x
						yy:+TextHeight(s) + LineSep
						Text = ""
					Else
						Text:+ch
					EndIf
					Escape = False
				Case Chr(10), Chr(13)
					DrawWrappedLine(Text, x, xx, yy, WrapWidth, shadow)
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
					Local Value:String = Text[t + 1..Text.length].ToLower()
					
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
						Case "shadow"
							If Value = "off"
								shadow = False
							ElseIf Value = "on"
								shadow = True
							End If
					End Select
				Else
					Select Text.ToLower()
						Case "br"
							yy:+TextHeight(s) + LineSep
							xx = x
							Text = ""
						Case "shadow"
							shadow = True
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
	DrawWrappedLine(Text, x, xx, yy, WrapWidth, shadow)
	OrigCol.Set()
	
	Return (yy + TextHeight("|") + LineSep - y)
End Function

Function DrawTextCentred(s:String, x:Float, y:Float, hcentre:Int = True, vcentre:Int = False)
	If (hcentre) x:-(TextWidth(s) / 2)
	If (vcentre) y:-(TextHeight(s) / 2)
	DrawText(s, x, y)
End Function

Function DrawTextCentredShadow(s:String, x:Float, y:Float, xoffset:Float = 3, yoffset:Float = 3, hcentre:Int = True, vcentre:Int = False)
	If (hcentre) x:-(TextWidth(s) / 2)
	If (vcentre) y:-(TextHeight(s) / 2)
	DrawTextShadow(s, x, y)
End Function

Function DrawTextShadow(s:String, x:Float, y:Float, xoffset:Float = 3, yoffset:Float = 3, drawshadow:Int = True)
	If drawshadow
		Local r:Int, g:Int, b:Int, a:Float
		GetColor(r, g, b)
		a = GetAlpha()
		DrawText(s, x, y)
		SetColor(r + 20, g + 20, b + 20)
		SetAlpha(a / 5.0)
		DrawText(s, x + xoffset, y + yoffset)
		SetColor(r, g, b)
		SetAlpha(a)
	Else
		DrawText(s, x, Y)
	EndIf
End Function
