SuperStrict

Import joe.riff
Import gman.zipengine
Import "TileGrid.bmx"

Type TTileFormat_Map Extends TTileFormat
	
	Method Init(descrip:String = "Default tile format", ext:String = "map")
		SetInfo(descrip, ext)
		AddFormat()
	End Method
	
	Method SaveProperties(properties:TProperties, list:RIFFList)
	
		For Local prop:String = EachIn properties.map.Keys()
			If Properties.IsDefault(prop) Continue
			Local props:TStream = list.NewChunk("prop").GetNewDataStream()
			props.WriteLine(prop)
			Select Properties.GetDataType(prop)
				Case "String"
					props.WriteString("S")
					props.WriteLine(properties.GetString(prop))
				Case "Integer"
					Local i:Int = properties.GetInt(prop)
					If i < 255
						props.WriteString("B")
						props.WriteByte(i)
					Else
						props.WriteString("I")
						props.WriteInt(i)
					EndIf
				Case "Float"
					props.WriteString("F")
					props.WriteFloat(properties.GetFloat(prop))
			EndSelect
		Next
	EndMethod
	
	Method LoadProperties(properties:TProperties, list:RIFFList)
		For Local prop:RIFFChunk = EachIn list.Subchunks
			If prop.id <> "prop" Continue
			Local str:TStream = prop.GetNewDataStream()
			Local name:String = str.ReadLine()
			Select Chr(str.ReadByte())
				Case "S"
					properties.SetString(name, str.ReadLine())
				Case "I"
					properties.SetInt(name, str.ReadInt())
				Case "B"
					properties.SetInt(name, str.ReadByte())
				Case "F"
					properties.SetFloat(name, str.ReadFloat())
			End Select			
		Next
	End Method	
	
	Method Save:Int(map:TTileGrid, url:Object)
		Local path:String = String(url)
		If Not path Return 0
			
		Local zip:ZipWriter = New ZipWriter
		If Not zip.OpenZip(path, 0) Return 0
		zip.SetCompressionLevel(9)

		'''''''''''''
		'Main header'
		'''''''''''''
		Local c_riff:RIFFFile = CreateRIFFFile(RIFFID_FORMAT)		
			
		''''''''
		'Images'
		''''''''
		Local imagemap:TMap = map.GetImageMap()
		Local imagecount:Int = 0
		Local c_imgs:RIFFList = c_riff.NewList(RIFFID_IMAGES)
		
		
		For Local i:TTileImage = EachIn imagemap.Keys()
			Local bs:TBankStream = CreateBankStream(CreateBank())
			SavePixmapPNG(LockImage(i.image,, True, False), bs)
			UnlockImage(i.image)
			zip.AddStream(bs, String(imagemap.ValueForKey(i)) + ".png")
			
			Local c_img:RIFFList = c_imgs.NewList(RIFFID_IMAGE)
			c_img.AddTag(RIFFID_IMAGEID, Chr(Byte(String(imagemap.ValueForKey(i)))))
			
			SaveProperties(i.Properties, c_img)
			
			imagecount:+1
		Next

		''''''''''	
		'Map info'
		''''''''''
		Local c_mapinfo:RIFFList = CreateRIFFList(RIFFID_MAPINFO, c_riff)
		Local s_tsize:TStream = c_mapinfo.NewChunk(RIFFID_TILESIZE).GetNewDataStream()
		
		WriteUnsignedInt32(s_tsize, map.TileWidth)
		WriteUnsignedInt32(s_tsize, map.TileHeight)
		
		Local s_msize:TStream = c_mapinfo.NewChunk(RIFFID_MAPSIZE).GetNewDataStream()
		WriteUnsignedInt32(s_msize, map.Width)
		WriteUnsignedInt32(s_msize, map.Height)
		WriteUnsignedInt32(s_msize, map.Depth)
		
		Local s_imgnum:TStream = c_mapinfo.NewChunk(RIFFID_IMAGES).GetNewDataStream()
		WriteUnsignedInt32(s_imgnum, imagecount)
		
		''''''''''
		'Entities'
		''''''''''
		Local c_ents:RIFFList = CreateRIFFList(RIFFID_ENTS, c_riff)
		For Local ent:TTileEntity = EachIn map.Entities
			Local c_ent:RIFFList = CreateRIFFList(RIFFID_ENT, c_ents)
			'Entity x, y, z, name
			Local ids:TStream = c_ent.NewChunk(RIFFID_ENTINFO).GetNewDataStream()
			ids.WriteInt(ent.x)
			ids.WriteInt(ent.y)
			ids.WriteInt(ent.z)
			ids.WriteLine(ent.typename)
			
			'Entity properties
			SaveProperties(ent.props, c_ent)
		Next
		
		'''''''
		'Zones'
		'''''''
		Local c_zones:RIFFList = CreateRIFFList(RIFFID_ZONES, c_riff)
		For Local z:TTileZone = EachIn map.Zones
			'Zone ID and name
			Local c_zone:RIFFList = CreateRIFFList(RIFFID_ZONE, c_zones)
			Local ids:TStream = c_zone.NewChunk(RIFFID_ZONEID).GetNewDataStream()
			ids.WriteByte(z.ID)
			ids.WriteLine(z.Name)	
			
			'Zone proporties
			SaveProperties(z.Properties, c_zone)
			
		Next
		
		''''''''	
		'Layers'
		''''''''
		Local c_layers:RIFFList = CreateRIFFList(RIFFID_LAYERS, c_riff)
		
		For Local f:Int = 0 Until map.Depth
			Local c_layer:RIFFList = CreateRIFFList(RIFFID_LAYER)
			WriteUnsignedInt32(c_layer.NewChunk(RIFFID_LAYERID).GetNewDataStream(), f)
			
			Local c_data:RIFFChunk = CreateRIFFChunk(RIFFID_TILEBLOCK)
			Local s:TStream = c_data.GetNewDataStream()
			
			Local nulltile:Short = 0
			Local isempty:Int = 1
			For Local yy:Int = 0 Until map.Width
				For Local xx:Int = 0 Until map.Height
					Local t:TTile = map.GetTile(xx, yy, f, 0)
					If t
						IsEmpty = 0
						If nulltile > 0
							s.WriteByte(0)
							s.WriteShort(nulltile)
							nulltile = 0
						End If
						s.WriteByte(Int(String(imagemap.ValueForKey(t.Image))))
						s.WriteByte(t.Zone.ID)
					Else
						nulltile:+1
					EndIf
				Next
			Next
			If nulltile > 0
				s.WriteByte(0)
				s.WriteShort(nulltile)
				nulltile = 0
			End If		
			If Not (IsEmpty) c_layer.AddChunk(c_data)

			If c_layer.Subchunks.Count() > 1 c_layers.AddChunk(c_layer)
		Next
		
		'''''''''''''
		'Final write'
		'''''''''''''
		Local bs:TBankStream = CreateBankStream(CreateBank())
		c_riff.Save(bs)
		zip.AddStream(bs, RIFF_FILENAME)
		zip.CloseZip()	
		
		Return 1
	End Method	
	
	Rem
	bbdoc: Override this method if you want the loader to create an object other than a base TTileGrid.
	EndRem
	Method CreateTileGrid:TTileGrid(w:Int, h:Int, d:Int, tw:Int, th:Int)
		Return TTileGrid.Create(w, h, d, tw, th)
	EndMethod
	
	Method Load:TTileGrid(url:Object)
	
		Local path:String = String(url)
		If Not path Return Null
		
		
		Local zip:ZipReader = New ZipReader
		If Not zip.OpenZip(path)
			'Error
			Return Null
		EndIf
		
		Local c_riff:RIFFFile
		Local imgarray:TTileImage[256]
		
		'''''''''''''''''
		'Data Extraction'
		'''''''''''''''''
		zip.readFileList()
		
		For Local i:Int = 0 Until zip.getFileCount()
			Local fileinf:SZipFileEntry = zip.getFileInfo(i)
			Local data:TRamStream
			Select ExtractExt(fileinf.simpleFileName)
				Case "dat"
					data = zip.ExtractFile(fileinf.simpleFileName)
					c_riff = LoadRIFFFile(data)
				Case "png"
					data = zip.ExtractFile(fileinf.simpleFileName)				
					imgarray[Int(StripAll(fileinf.simpleFileName))] = New TTileImage.Init(LoadImage(data))
			End Select
		Next
		
		If c_riff = Null Return Null
		
		''''''''''''
		'Image data'
		''''''''''''
		Local c_images:RIFFList = RIFFList(c_riff.FindChunk(RIFFID_IMAGES))
		For Local c_img:RIFFList = EachIn c_images.Subchunks
			If Not c_img.ChunkType = RIFFID_IMAGE Continue
				
			Local imgid:Int = c_img.FindChunk(RIFFID_IMAGEID).GetNewDataStream().ReadByte()
			
			LoadProperties(imgarray[imgid].Properties, c_img)

		Next
		
		
		''''''''''	
		'Map info'
		''''''''''		
		Local c_mapinfo:RIFFList = RIFFList(c_riff.FindChunk(RIFFID_MAPINFO))
		
		If Not (c_mapinfo)
			'Error
			Return Null
		End If
		
		Local ds:TStream = c_mapinfo.FindChunk(RIFFID_TILESIZE).GetNewDataStream()
		Local tw:Int = ReadUnsignedInt32(ds)
		Local th:Int = ReadUnsignedInt32(ds)
		
		ds = c_mapinfo.FindChunk(RIFFID_MAPSIZE).GetNewDataStream()
		Local w:Int = ReadUnsignedInt32(ds)
		Local h:Int = ReadUnsignedInt32(ds)
		Local d:Int = ReadUnsignedInt32(ds)
				
		Local map:TTileGrid = CreateTileGrid(w, h, d, tw, th)
		
		'''''''
		'Zones'
		'''''''
		Local zonearray:TTileZone[256]
		Local c_zones:RIFFList = RIFFList(c_riff.FindChunk(RIFFID_ZONES))
		For Local c_zone:RIFFList = EachIn c_zones.Subchunks
			
			Local zid:TStream = c_zone.FindChunk(RIFFID_ZONEID).GetNewDataStream()
			
			Local id:Byte = zid.ReadByte()
			Local name:String = zid.ReadLine()
		
			Local zone:TTileZone = New TTileZone.Init(name)
			zone.ID = id
			map.AddZone(zone)
			zonearray[ID] = zone
			
			'Zone proporties
			
			LoadProperties(zone.Properties, c_zone)		
			
		Next
		
		''''''''''
		'Entities'
		''''''''''
		Local c_ents:RIFFList = RIFFList(c_riff.FindChunk(RIFFID_ENTS))
		If (c_ents)
			For Local c_ent:RIFFList = EachIn c_ents.Subchunks
				'Entity x, y, z, name
				Local einfo:TStream = c_ent.FindChunk(RIFFID_ENTINFO).GetNewDataStream()
				Local x:Int = einfo.ReadInt()
				Local y:Int = einfo.ReadInt()
				Local z:Int = einfo.ReadInt()
				Local name:String = einfo.ReadLine()
				Local ent:TTileEntity = New TTileEntity.Init(name)
				'Entity properties
				LoadProperties(ent.props, c_ent)
				map.AddEntity(x, y, z, ent)
			Next
		EndIf
		''''''''	
		'Layers'
		''''''''		
		Local c_layers:RIFFList = RIFFList(c_riff.FindChunk(RIFFID_LAYERS))
		
		For Local c_layer:RIFFList = EachIn c_layers.Subchunks
			
			Local z:Int = ReadUnsignedInt32(c_layer.FindChunk(RIFFID_LAYERID).GetNewDataStream())
		'	Try
			Local data:TStream = c_layer.FindChunk(RIFFID_TILEBLOCK).GetNewDataStream()
			Local t:Int
			Local skipcount:Int = 0
			For Local y:Int = 0 Until w
				For Local x:Int = 0 Until h
					If skipcount > 0
						skipcount:-1
						Continue
					End If
					
					t = data.ReadByte()
					If t = 0
						skipcount = data.ReadShort() - 1
					Else
						map.SetTile(x, y, z, imgarray[t])
						map.SetTileZone(x, y, z, zonearray[data.ReadByte()])
					EndIf
				Next
			Next
			
		'	Catch s:Object
		'		Print s.ToString()
		'	End Try
									
		Next
				
		Return map
			
	EndMethod
	
	
	Global RIFF_FILENAME:String = "lvl.dat"
	Global RIFFID_FORMAT:String = "TILZ"
	Global RIFFID_MAPINFO:String = "minf"
	Global RIFFID_TILESIZE:String = "tsiz"
	Global RIFFID_MAPSIZE:String = "msiz"
	Global RIFFID_LAYERS:String = "lyrs"
	Global RIFFID_LAYER:String = "layr"
	Global RIFFID_LAYERID:String = "lid "
	Global RIFFID_TILEBLOCK:String = "tile"
	Global RIFFID_ZONES:String = "zons"
	Global RIFFID_ZONE:String = "zone"
	Global RIFFID_ZONEID:String = "zid "
	Global RIFFID_IMAGES:String = "imgs"
	Global RIFFID_IMAGE:String = "img "
	Global RIFFID_IMAGEID:String = "iid "
	Global RIFFID_ENTS:String = "ents"
	Global RIFFID_ENT:String = "ent "
	Global RIFFID_ENTINFO:String = "einf"
End Type