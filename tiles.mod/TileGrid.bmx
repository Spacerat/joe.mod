SuperStrict

Import "TileLoader.bmx"
Import brl.pngloader
Import brl.map


Rem
bbdoc: The base tile format class.
about: Mainly useful as a dictionary of different possible formats, e.g. in a map editor.
EndRem
Type TTileFormat
	Global SaveFormats:TMap = New TMap
	Global LoadFormats:TMap = New TMAp
	
	Field description:String = "Format description"
	Field extension:String = "*"
	Field name:String
	
	Rem
	bbodc: Save a grid with this format
	EndRem
	Function SaveAsFormat:Int(map:TTileGrid, url:Object, ext:String)
		Local f:TTileFormat = TTileFormat(SaveFormats.ValueForKey(ext))
		If (f) Return f.Save(map, url) Else Return 0
	End Function
	
	Rem
	bbdoc: Load a file as this format
	EndRem
	Function LoadAsFormat:TTileGrid(url:Object, ext:String)
		Local f:TTileFormat = TTileFormat(LoadFormats.ValueForKey(ext))
		If (f) Return f.Load(url)
	End Function
	
	Method Save:Int(map:TTileGrid, url:Object) Abstract
	
	Method Load:TTileGrid(url:Object) Abstract
	
	Rem
	bbdoc: Set the description and extension for this format.
	EndRem
	Method SetInfo(descrip:String, ext:String)
		description = descrip
		extension = ext
	End Method
	
	Rem
	bbdoc: Add this format to the global format list.
	EndRem
	Method AddFormat(save:Int = True, Load:Int = True)

		If Extension = ""
			Throw "Error adding format with no extension"
			Return
		EndIf
		If (save) SaveFormats.Insert(extension, Self)
		If (Load) LoadFormats.Insert(extension, Self)
		
	EndMethod
	
End Type

Rem
bbdoc: TTileGrid stores an entire map.
EndRem
Type TTileGrid
	
	Const FILE_DATA_BLOCK:Int = 0

	Rem
	bbdoc: Create a tile grid.
	aboout: @TileWidth and @TileHeight specify the width and height in pixels of each tile.
	@DefaultTile is drawn for cells containing no tiles.
	EndRem
	Function Create:TTileGrid(width:Int, height:Int, depth:Int = 1, tilewidth:Int, tileheight:Int, defaulttile:TTile = Null)
		Return New TTileGrid.Init(width, height, depth, tilewidth, tileheight, defaulttile)	
	End Function
	
	Rem
	bbdoc: Method version of Create to facilitate inheritence
	EndRem
	Method Init:TTileGrid(width:Int, height:Int, depth:Int = 1, tilewidth:Int, tileheight:Int, defaulttile:TTile = Null)

		Self.Width = width
		Self.Height = height
		Self.Depth = depth
		Self.TileWidth = tilewidth
		Self.TileHeight = tileheight
		
		Self.Tiles = New TTile[width, height, depth]
		Self.SetDefaultTile(defaulttile)
		
		Return Self
		
	End Method
		
	Rem
	bbdoc: Set the size of the array
	about: This is a very expensive method so use it with caution.
	endrem
	Method SetSize(w:Int, h:Int, d:Int)
		
		Local NewArray:TTile[,,] = New TTile[w, h, d]
		
		For Local xx:Int = 0 Until w
			For Local yy:Int = 0 Until h
				For Local zz:Int = 0 Until d
					NewArray[xx, yy, zz] = GetTile(xx, yy, zz, 0)
				Next
			Next
		Next
	
		Width = w
		Height = h
		Depth = d
		
		Tiles = NewArray
	End Method
	
	Rem
	bbdoc: Get the tile at a given coordinate
	about: def specifies weather you would like to return the default tile if the cell is empty.
	endrem
	Method GetTile:TTile(x:Int, y:Int, z:Int = 0, def:Int = 1)
		If Not TileInGrid(x, y, z)
			If (DefaultTile) Return DefaultTile
			Return Null
		EndIf
		
		If Not def Return Tiles[x, y, z]
		Local t:TTile = Tiles[x, y, z]
		If t = Null
			If (DefaultTile) Return DefaultTile
		Else
			Return t
		EndIf
	End Method
	
	Rem
	bbdoc: Converts local coordinates into tile coordinates
	about: Assumes that the tile grid is drawn at the top left of the screen.
	
	If @inside is false coordinates outside the grid can be returned (e.g. negative coordinates)
	endrem
	Method TileAtPos:Int[] (x:Int, y:Int, z:Int = 0, inside:Int = 1)
		If inside = 0
			Return[Int(Floor(Float(x) / TileWidth)), Int(Floor(Float(y) / TileHeight))]
		Else
			Local xx:Int = Int(Floor(Float(x) / TileWidth))
			Local yy:Int = Int(Floor(Float(y) / TileHeight))
			
			If TileInGrid(xx, yy, z) Return[xx, yy, z]
			
		EndIf
	EndMethod
	
	Rem
	bbdoc: Translates tile X to real X
	EndRem
	Method RealX:Int(tilex:Int)
		Return tilex * TileWidth
	EndMethod

	Rem
	bbdoc: Translates tile Y to real Y
	EndRem
	Method RealY:Int(tiley:Int)
		Return tiley * TileHeight
	EndMethod	
		
	Rem
	bbdoc: Set the tile image at a given coordinate
	endrem
	Method SetTile(x:Int, y:Int, z:Int = 0, image:TTileImage, overwrite:Int = 1)
		If Not TileInGrid(x, y, z) Return
		If overwrite = 1 Or (overwrite = 0 And Tiles[x, y, z] = Null)
			If Tiles[x, y, z] = Null Tiles[x, y, z] = New TTile
			Tiles[x, y, z].Image = image
		EndIf
	End Method
	
	Rem
	bbdoc: Set the zone of a tile
	EndRem
	Method SetTileZone(x:Int, y:Int, z:Int, zone:TTileZone)
		If Not TileInGrid(x, y, z) Return
		If Tiles[x, y, z] = Null Return
		
		Tiles[x, y, z].SetZone(zone)
	End Method
	
	Rem
	bbdoc: Remove a tile from the grid
	endrem
	Method RemoveTile(x:Int, y:Int, z:Int = 0)
		If Not TileInGrid(x, y, z) Return
		Local t:TTile = Tiles[x, y, z]
		If t.Zone
			t.Zone.RemoveTile(t)
		End If
		Tiles[x, y, z] = Null
	End Method
	
	Rem
	bbdoc: Set the tile images in a given rectangle
	endrem
	Method SetTileRect(x:Int, y:Int, w:Int, h:Int, z:Int = 0, image:TTileImage, overwrite:Int = 1)
		For Local xx:Int = x Until (x + w)
			For Local yy:Int = y Until (y + h)
				SetTile(xx, yy, z, image, overwrite)
			Next
		Next
	End Method
	
	Rem
	bbdoc: Set the tiles in a given rectangle with a border.
	endrem
	Method SetTileRectBordered(x:Int, y:Int, w:Int, h:Int, z:Int = 0, centre:TTileImage = Null, t:TTileImage = Null, tr:TTileImage = Null, r:TTileImage = Null, br:TTileImage = Null, b:TTileImage = Null, bl:TTileImage = Null, l:TTileImage = Null, tl:TTileImage = Null, overwrite:Int = 1)
	
		SetTile(x, y, z, tl, overwrite)
		SetTile(x, y + h - 1, z, bl, overwrite)
		SetTile(x + w - 1, y, z, tr, overwrite)
		SetTile(x + w - 1, y + h - 1, z, br, overwrite)
		
		SetTileRect(x + 1, y + 1, w - 2, h - 2, z, centre, overwrite)
		SetTileRect(x + 1, y, w - 2, 1, z, t, overwrite)
		SetTileRect(x + w - 1, y + 1, 1, h - 2, z, r, overwrite)
		SetTileRect(x + 1, y + h - 1, w - 2, 1, z, b, overwrite)
		SetTileRect(x, y + 1, 1, h - 2, z, l, overwrite)
	
	EndMethod
	
	Rem
	bbdoc: Set the default image.
	endrem
	Method SetDefaultTile(tile:TTile)
		DefaultTile = tile
	End Method
	
	Rem
	bbdoc: Draw the entire tile grid
	endrem
	Method Draw(x:Float, y:Float, Floor:Int = 0, zoom:Float = 1)
		If zoom = 1
			For Local xx:Int = 0 Until Width
				For Local yy:Int = 0 Until Height
					DrawTile(x + TileWidth * xx, y + TileWidth * yy, xx, yy, Floor)
				Next
			Next
		Else
			
		EndIf
	End Method
	Rem
	bbdoc: Draw part of the tile grid
	about: All values here are not tile coordinates but actual coordinates. This means that some tiles
	may be only partially drawn.
	endrem
	Method DrawArea(x:Float, y:Float, w:Float, h:Float, rx:Int, ry:Int, Floor:Int = 0, zoom:Float = 1, outsidegrid:Int = 0, lines:Int = False, useviewport:Int = False)
		Local ox:Int, oy:Int, ow:Int, oh:Int, osx:Float, osy:Float
		
		GetScale(osx, osy)
		If (useviewport)
			GetViewport(ox, oy, ow, oh)
			SetViewport(x, y, w, h)
		EndIf
		
		SetScale(zoom, zoom)
		
		x:-rx
		y:-ry
		
		'Figure out which cells need drawing
		Local Left:Int = rx / (TileWidth * Zoom) - 1
		Local top:Int = ry / (TileHeight * Zoom) - 1
		Local Right:Int = Left + Ceil(w / (TileWidth * Zoom)) + 2
		Local bottom:Int = top + Ceil(h / (TileHeight * Zoom)) + 2
		
		If outsidegrid = 0
			Left = Max(Left, 0)
			Right = Min(Right, Width)
			Top = Max(top, 0)
			Bottom = Min(bottom, Height)
		End If
		
		SetColor(255, 255, 255)
		
		For Local xx:Int = Left Until Right
			For Local yy:Int = Top Until Bottom
			
				DrawTile(x + TileWidth * Zoom * xx, y + TileWidth * Zoom * yy, xx, yy, Floor)
				
				If (Lines)
					SetScale(1, 1)
					DrawLine(x + TileWidth * Zoom * Left, y + TileWidth * Zoom * yy, x + TileWidth * Zoom * Right, y + TileWidth * Zoom * yy)
					SetScale(zoom, zoom)
				End If
				
			Next
			If (Lines)
				SetScale(1, 1)
				DrawLine(x + TileWidth * Zoom * xx, y + TileWidth * Zoom * Top, x + TileWidth * Zoom * xx, y + TileWidth * Zoom * Bottom)
				SetScale(zoom, zoom)
			End If
		Next
		
		
		
		If (useviewport) SetViewport(ox, oy, ow, oh)
		SetScale(osx, osy)
	End Method
	
	
	Rem
	bbdoc: Draw a tile
	endrem
	Method DrawTile(x:Float, y:Float, tilex:Int, tiley:Int, tilez:Int = 0)
		Local t:TTile = GetTile(tilex, tiley,tilez)
		If (t) t.Draw(x, y)
		If (DrawCoords = 1)
			SetAlpha(0.3)
			DrawText("(" + tilex + "," + tiley + ")", x, y)
			SetAlpha(1)
		EndIf
	End Method
	
	Rem
	bbdoc: Grid width in pixels
	endrem
	Method GridWidth:Int()
		Return Width * TileWidth
	End Method
	
	Rem
	bbdoc: Grid height in pixels
	endrem
	Method GridHeight:Int()
		Return Height * TileHeight
	End Method

	Rem
	bbdoc: Check if a given tile coordinate is inside the grid
	endrem
	Method TileInGrid:Int(x:Int, y:Int, z:Int = 0)
		If x < 0 Then Return 0
		If y < 0 Then Return 0
		If x >= Width Then Return 0
		If y >= Height Then Return 0
		If z < 0 Return 0
		If z >= Depth Return 0
		Return 1
	End Method
	
	Rem
	bbdoc: Create a new tilemap from a file
	EndRem
	Function Load:TTileGrid(url:Object, ext:String)
		Return TTileFormat.LoadAsFormat(url, ext)
	End Function
	
	Rem
	bbdoc: Save the grid to the given file
	endrem
	Method Save:Int(url:Object, ext:String)
		Return TTileFormat.SaveAsFormat(Self, url, ext)
	EndMethod
	
	Rem
	bbdoc: Get a map of every image used in the grid
	about: Used internally, slow.
	endrem
	Method GetImageMap:TMap()
		Local n:Int = 1
		Local map:TMap = New TMap
		For Local xx:Int = 0 Until Width
			For Local yy:Int = 0 Until Height
				For Local zz:Int = 0 Until Depth
					Local t:TTile = GetTile(xx, yy, zz)
					If (t)
						If Not map.Contains(t.Image)
							map.Insert(t.Image, String(n))
							n:+1
						EndIf
					EndIf
				Next
			Next
		Next
		Return map
	EndMethod

	Rem
	bbdoc: Add a zone to the list
	about: The zone is assigned an ID if it doesn't already have one.
	EndRem
	Method AddZone(zone:TTileZone)
		Zones.AddLast(zone)
		If zone.ID >= 0 Return
		For Local i:Int = 0 To 255
			Local f:Int = 1
			For Local z:TTileZone = EachIn Zones
				If z.ID = i
					f = 0
					Exit
				EndIf
				
			Next
			If f = 1
				Zone.ID = i
				Return
			End If
		Next
	End Method
	
	Rem
	bbdoc: Remove a zone, and all of its tiles.
	EndRem
	Method RemoveZone(zone:TTileZone)
		Zones.Remove(zone)
		Local t:TTile
		For Local xx:Int = 0 Until Width
			For Local yy:Int = 0 Until Height
				For Local zz:Int = 0 Until Depth
					t = Tiles[xx, yy, zz]
					If Not t Continue
					If t.Zone = zone
						Self.RemoveTile(xx, yy, zz)
					End If
				Next
			Next
		Next
	End Method
	
	Rem
	bbdoc: Set to True to have each tile draw its coordinates.
	EndRem
	Field DrawCoords:Int = 0
	
	Field Width:Int, Height:Int, Depth:Int
	Field TileWidth:Int, TileHeight:Int
	Field DefaultTile:TTile
	Field Tiles:TTile[,,]
	
	Field Zones:TList = New TList
	
EndType

Rem
bbdoc: An individual tile.
EndRem
Type TTile

	Function Create:TTile(image:TTileImage)
		Local n:TTile = New TTile
		n.Image = image
		Return n
	EndFunction
	
	Rem
	bbdoc: Get the width of this tile's image.
	EndRem
	Method Width:Int()
		Return Image.width()
	End Method
	
	Rem
	bbdoc: Get the height of this tile's image.
	EndRem	
	Method Height:Int()
		Return Image.height()
	End Method
	
	Rem
	bbdoc: Draw this tile (if its zone is visible).
	EndRem
	Method Draw(x:Float, y:Float)
		If (image)
			If (Zone)
				If (Zone.visible)
					DrawImage(Image.image, x, y)
				EndIf
			Else
				DrawImage(Image.image, x, y)
			EndIf
		EndIf
	End Method
	
	Rem
	bbdoc: Set this tile's zone affiliation.
	EndRem
	Method SetZone(newzone:TTileZone)
		If (Zone)
			Zone.Tiles.Remove(Self)
		End If
		Zone = newzone
		If (Zone) Zone.Tiles.AddLast(Self)
	End Method
	
	Field Image:TTileImage
	Field Zone:TTileZone
	
End Type

Rem
bbdoc: A tile zone/group.
about: Used - for example - for grouping tiles in to different 'rooms'.
EndRem
Type TTileZone
	
	Rem
	bbdoc: List of constituant tiles.
	EndRem
	Field Tiles:TList = New TList
	
	Rem
	bbdoc: Name of this zone.
	EndRem
	Field Name:String
	
	Rem
	bbdoc: Zone's visibility parameter. When false, member tiles do not draw.
	EndRem
	Field visible:Int = 1
	
	Rem
	bbdoc: Zone's numeric ID.
	about: Do not change. This is set automatically upon load.
	EndRem
	Field ID:Int = -1
	
	Rem
	bbdoc: A key-value store of properties associated with this zone.
	EndRem
	Field Properties:TProperties = New TProperties
	
	Method AddTile(tile:TTile)
		tile.SetZone(Self)
	End Method

	Method RemoveTile(tile:TTile)
		tile.SetZone(Null)
	End Method	
	
	Rem
	bbdoc: Initialise the zone with a name.
	EndRem
	Method Init:TTileZone(name:String)
		Self.Name = name
		Return Self
	End Method
	
	Rem
	bbdoc: Set this zone's visibility parameter.
	EndRem
	Method SetVisible(bool:Int)
		visible = bool
	EndMethod
	
EndType


