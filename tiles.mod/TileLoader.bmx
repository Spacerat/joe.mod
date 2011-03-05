SuperStrict

Import brl.max2d
Import brl.map
Import brl.math
?debug
Import brl.standardio
?

Type TTileSetException
	Field url:String
	
	Method Init:TTileSetException(url:String)
		Self.url = url
		Return Self
	End Method
	
	Method ToString:String()
		Return "Unable to load tileset from " + url
	End Method
End Type

Type TTileSet
	
	Rem
	bbdoc: Creates a new tileset from an image file.
	about: @tilewidth and @tileheight specify the size of each tile
	
	@toptile, @lefttile, @righttile and @bottomtile allow you to specifiy which tiles you would like
	to load from the set. Note that if you (for example) set toptile to 3, A tile at [4,0] in the loaded
	tileset will correspond to a tile at [4,3] in the actual file.
	
	@xspacing and @yspacing let the loader know how much space there is in between each tile.
	
	@xstart and @ystart let the loader know how much space there is at the top left of the image, before
	the top left tile
	endrem
	Function Load:TTileSet(url:Object, tilewidth:Int, tileheight:Int, toptile:Int = 0, lefttile:Int = 0, righttile:Int = -1, bottomtile:Int = -1, xspacing:Int = 0, yspacing:Int = 0, startx:Int = 0, starty:Int = 0)
		Local img:TImage = LoadImage(url, DYNAMICIMAGE | MASKEDIMAGE)
		If Not (img)
			?debug
			Throw New TTileSetException.Init(url.ToString())
			?
			Return Null
		EndIf
		
		Local n:TTileSet = New TTileSet
		
		If righttile = -1 righttile = img.width / (tilewidth + xspacing) - 1
		If bottomtile = -1 bottomtile = img.height / (tileheight + yspacing) - 1
		
		n.Width = righttile - lefttile + 1
		n.Height = bottomtile - toptile + 1
		n.TileWidth = tilewidth
		n.TileHeight = tileheight
		
		n.TileArray = New TTileImage[n.Width, n.Height]
		
	'	Local imgpix:TPixmap = LockImage(img)
		
		For Local tx:Int = lefttile To righttile
			
			For Local ty:Int = toptile To bottomtile
 				Local xx:Int = tx * (tilewidth + xspacing) + startx
				Local yy:Int = ty * (tilewidth + yspacing) + starty
				
				Local newtile:TImage = CreateImage(tilewidth, tileheight, 1, FILTEREDIMAGE | DYNAMICIMAGE)
				Local p:TPixmap = LockImage(newtile)
				'CopyImageSlow(p, xx, yy, tilewidth, tileheight, imgpix)
				'UnlockImage(newtile)
				
				CopyImageRect(img, xx, yy, tilewidth, tileheight, newtile)
				
				n.TileArray[tx - lefttile, ty - toptile] = New TTileImage.Init(newtile)
			Next
		
		Next
		
		Return n
		
	End Function
	
	Rem
	bbdoc: Get a tile
	endrem
	Method GetTile:TTileImage(x:Int, y:Int)
		Return TileArray[x, y]
	End Method
	
	Rem
	bbdoc: Draw the entire tileset
	endrem
	Method DrawAllTiles(x:Float, y:Float)
		For Local xx:Int = 0 Until Width
			For Local yy:Int = 0 Until Height
				DrawImage(TileArray[xx, yy].image, x + TileWidth * xx, y + TileWidth * yy)
			Next
		Next
	End Method
	
	Field TileArray:TTileImage[,]
	Field Width:Int, Height:Int
	Field TileWidth:Int, TileHeight:Int
End Type

Type TTileImage
	
	Function Load:TTileImage(url:Object, flags:Int)
		Local n:TImage = LoadImage(url, flags)
		If n <> Null Return New TTileImage.Init(n)
	EndFunction

	Function Create:TTileImage(w:Int, h:Int)
		Return New TTileImage.Init(CreateImage(w, h))
	EndFunction
	
	Method Init:TTileImage(image:TImage)
		Self.image = image
		Return Self
	End Method
	
	Method Width:Int()
		Return image.width
	End Method
	
	Method Height:Int()
		Return image.height
	End Method
	
	Method HandleX:Int()
		Return image.handle_x
	End Method
	
	Method HandleY:Int()
		Return image.handle_y
	End Method
	
	Rem
	bbdoc: A set of properties associated with all tiles that share this image.
	EndRem
	Field Properties:TProperties = New TProperties
	Field image:TImage
End Type

Private
Type TProp
	Field default_value:Int = False
	Method ToInt:Int() Abstract
	Method ToFloat:Float() Abstract
	Method GetDataType:String() Abstract
	Method IsDefault:Int()
		Return default_value
	End Method
End Type
Type TPropFloat Extends TProp
	Field v:Float
	Method Init:TPropFloat(f:Float, def:Int)
		v = f
		default_value = def
		Return Self
	End Method
	Method ToString:String()
		Return String(v)
	End Method
	Method ToInt:Int()
		Return Int(v)
	End Method
	Method ToFloat:Float()
		Return v
	End Method
	Method GetDataType:String()
		Return "Float"
	End Method
End Type
Type TPropInt Extends TProp
	Field v:Int
	Method Init:TPropInt(i:Float, def:Int)
		default_value = def
		v = i
		Return Self
	End Method
	Method ToString:String()
		Return String(v)
	End Method
	Method ToInt:Int()
		Return v
	End Method
	Method ToFloat:Float()
		Return v
	EndMethod
	Method GetDataType:String()
		Return "Integer"
	End Method
End Type
Type TPropString Extends TProp
	Field v:String
	Method Init:TPropString(s:String, def:Int)
		v = s
		default_value = def
		Return Self
	End Method
	Method ToString:String()
		Return v
	End Method
	Method ToInt:Int()
		Return v.ToInt()
	End Method
	Method ToFloat:Float()
		Return v.ToFloat()
	End Method
	Method GetDataType:String()
		Return "String"
	End Method
End Type
Public

Rem
bbdoc: A key-value data storage type.
about: TProperties stores the data type of each property as a string. This is important for file-format related stuff.
EndRem
Type TProperties
	
	Field map:TMap = New TMap

	Rem
	bbdoc: Add a string to the property map.
	Endrem
	Method SetString(label:String, data:String, isdefault:Int = False)
			map.Insert(label, New TPropString.Init(data, isdefault))
	End Method
	
	Rem
	bbdoc: Add an integer to the property map.
	EndRem
	Method SetInt(label:String, data:Int, isdefault:Int = False)
		map.Insert(label, New TPropInt.Init(data, isdefault))
	End Method
	
	rem
	bbdoc: Add a byte to the property map.
	EndRem
	Method SetFloat(label:String, data:Float, isdefault:Int = False)
		map.Insert(label, New TPropFloat.Init(data, isdefault))
	End Method	
	
	
	Rem
	bbdoc: Find and remove a property by its label.
	EndRem
	Method RemoveProperty(label:String)
		map.Remove(label)
	End Method
	
	Rem
	bbdoc: Change a property's label to newlabel.
	EndRem
	Method RenameProperty(label:String, newlabel:String)

		If label = newlabel Return
	
		Local p:Object = FindProperty(label)
	
		If Not p Return
		
		RemoveProperty(label)
		
		map.Insert(label, p)
	End Method
	
	Rem
	bbdoc: Set the datatype of a property that already exists.
	EndRem
	Method SetDataType(label:String, datatype:String)
		Local l:String = GetDataType(label)
		If l = datatype Return
		Local p:TProp = TProp(map.ValueForKey(label))
		Select l
			Case "Null"
				Return
			Case "Integer", "Float"
				Local v:Float = p.ToFloat()
				Select datatype.ToLower()
					Case "Int", "Integer"
						SetInt(label, v)
					Case "Float"
						SetFloat(label, v)
				End Select
			Case "String"
				Local s:String = label.ToString()
				Select datatype.ToLower()
					Case "Int", "Integer"
						SetInt(label, s.ToInt())
					Case "Float"
						SetFloat(label, s.ToFloat())
				End Select
		End Select
	End Method

	Rem
	bbdoc: Get the name (as a string) of the data type of the key held by label.
	EndRem
	Method GetDataType:String(label:String)
		Local v:TProp = TProp(map.ValueForKey(label))
		If Not v Return "Null"
		Return v.GetDataType()
	End Method
	
	Rem
	bbdoc: Get a string value.
	EndRem
	Method GetString:String(label:String)
		Local o:Object = map.ValueForKey(label)
		If o Then Return o.ToString()
	End Method
	
	Rem
	bbdoc: Get an integer value stored at label.
	EndRem
	Method GetInt:Int(label:String)
		Local o:TProp = TProp(map.ValueForKey(label))
		If o Then Return o.ToInt()
	End Method
	
	Rem
	bbdoc: Get a float value stored at label.
	Endrem
	Method GetFloat:Float(label:String)
		Local o:TProp = TProp(map.ValueForKey(label))
		If o Then Return o.ToFloat()
	End Method
	
	Rem
	bbdoc: Same as GetString (for compatibility)
	EndRem
	Method GetData:String(label:String)
		Return GetString(label)
	End Method
	
	Rem
	bbdoc: Add a string property and cast it to the given datatype ("String", "Integer", "Float")
	EndRem
	Method AddProperty:String(label:String, dtype:String, data:String, isdefault:Int = False)
		Select dtype
			Case "String"
				SetString(label, data, isdefault)
			Case "Int", "Integer", "Byte"
				SetInt(label, data.ToInt(), isdefault)
			Case "Float"
				SetFloat(label, data.ToFloat(), isdefault)
		End Select
		Return GetData(label)
	End Method
		
	Rem
	bbdoc: Add all the properties from 'from' to this TProperites.
	EndRem
	Method AddProperties(from:TProperties)
		For Local key:String = EachIn from.map.Keys()
			Local o:TProp = TProp(from.map.ValueForKey(key))
			If TPropFloat(o)
				Self.SetFloat(key, o.ToFloat(), o.default_value)
			ElseIf TPropInt(o)
				Self.SetFloat(key, o.ToInt(), o.default_value)
			ElseIf TPropString(o)
				Self.SetString(key, o.toString(), o.default_value)
			EndIf
		Next
	End Method
	
	Rem
	bbdoc: Make a new copy of this TProperties.
	EndRem
	Method Copy:TProperties()
		Local n:TProperties = New TProperties
		For Local key:String = EachIn map.Keys()
			Local o:TProp = TProp(map.ValueForKey(key))
			If TPropFloat(o)
				n.SetFloat(key, o.ToFloat(), o.default_value)
			ElseIf TPropInt(o)
				n.SetFloat(key, o.ToInt(), o.default_value)
			ElseIf TPropString(o)
				n.SetString(key, o.toString(), o.default_value)
			EndIf
		Next
		Return n
	End Method
	
	Method IsDefault:Int(label:String)
		Local p:TProp = TProp(map.ValueForKey(label))
		If p
			Return p.IsDefault()
		Else
			Throw "Invalid label "+label
		EndIf
	End Method
	
	Method FindProperty:Object(label:String)
		Return map.ValueForKey(label)
	End Method
	
End Type


Private
Function CopyImageRect(Source:TImage, SX:Int, SY:Int, SWidth:Int, SHeight:Int, Dest:TImage, DX:Int = 0, DY:Int = 0)
	'get the pixmap for the images
	Local SourcePix:TPixmap = LockImage(Source)
	Local DestPix:TPixmap = LockImage(Dest)
	
	'find the dimentions
	Local SourceWidth:Int = PixmapWidth(SourcePix)
	Local SourceHeight:Int = PixmapHeight(SourcePix)
	Local DestWidth:Int = PixmapWidth(DestPix)
	Local DestHeight:Int = PixmapHeight(DestPix)
	
	If SX < SourceWidth And SY < SourceHeight And DX < DestWidth And DY < DestHeight 'make sure rects are on image
		If SX+SWidth > SourceWidth Then SWidth = SourceWidth - SX 'bound the coordinates to the image area
		If SY+SHeight > SourceHeight Then SHeight = SourceHeight - SY
		If DX+SWidth > DestWidth Then SWidth = DestWidth - DX 'Make sure coordinates will fit into the destination
		If DY+SHeight > DestHeight Then SHeight = DestHeight - DY
		
		'find the pitch
		Local SourcePitch:Int = PixmapPitch(SourcePix)
		Local DestPitch:Int = PixmapPitch(DestPix)
	
		'pointers To the first pixel of pixmaps
		Local SourcePtr:Byte Ptr = PixmapPixelPtr(SourcePix) + SY * SourcePitch + SX * 4
		Local DestPtr:Byte Ptr = PixmapPixelPtr(DestPix) + DY * DestPitch + DX * 4
		
		'copy pixels over one line at a time
		For Local i:Int = 1 To SHeight
			MemCopy(DestPtr,SourcePtr,SWidth*4)
			SourcePtr :+ SourcePitch
			DestPtr :+ DestPitch
		Next
	End If
	
	'unlock the buffers
	UnlockImage(Source)
	UnlockImage(Dest)
End Function
Public

