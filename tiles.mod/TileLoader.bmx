SuperStrict

Import brl.max2d
Import brl.map

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

Rem
bbdoc: A key-value data storage type.
about: TProperties stores the data type of each property as a string. This is important for file-format related stuff.
EndRem
Type TProperties
	
	Field map:TMap = New TMap

	Method AddProperty(label:String, datatype:String, data:String)
			Local array:String[2]
			array[0] = datatype
			array[1] = data
			
			?debug
			
			Print "AddProperty: " + label + "," + array[0]
			?
			
			map.Insert(label, array)
	End Method

	Method RemoveProperty(label:String)
		?debug
		Print "Remove: "+label
		?
		map.Remove(label)
	End Method
	
	Method RenameProperty(label:String, newlabel:String)
		
		?debug
		Print "Rename: " + label + " to " + newlabel
		?
	
		If label = newlabel Return
	
		Local p:String[] = FindProperty(label)
	
		If Not p Return
		
		RemoveProperty(label)
		
		AddProperty(newlabel, p[0], p[1])
		
	End Method
	
	Method SetDataType(label:String, datatype:String)
		If Not FindProperty(label) Return
		FindProperty(label)[0] = datatype
	End Method
		
	Method SetData(label:String, data:String)
		If Not FindProperty(label) Return
		FindProperty(label)[1] = data
	End Method

	Method GetDataType:String(label:String)
		If Not FindProperty(label) Return Null
		Return FindProperty(label)[0]
	End Method
		
	Rem
	bbdoc: Get the data for this key. Numbers must be casted from string (unfortunately).
	EndRem
	Method GetData:String(label:String)
		If Not FindProperty(label) Return Null
		Return FindProperty(label)[1]
	End Method	
		
	Method FindProperty:String[] (label:String)
		Return String[] (map.ValueForKey(label))
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

