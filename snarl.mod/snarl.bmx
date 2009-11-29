Rem
bbdoc: Snarl interface
EndRem
Module Joe.Snarl
ModuleInfo "Version: 0.9.0"
ModuleInfo "Author: Spacerat"
ModuleInfo "License: Public Domain"

SuperStrict

?win32

Import "SnarlInterface.c"
Import brl.filesystem


Extern "C"
	
	Rem
	bbdoc: Show a notification
	return: Return a new notification handle, or an error
	EndRem
	Function snShowMessage:Int(Title$z, Text$z, timeout:Int, IconPath$z, hWndReply:Int, uReplyMsg:Int)
	Rem
	bbdoc: Show a registered notification
	EndRem
	Function snShowMessageEx:Int(Class$z, Title$z, Text$z, timeout:Int, IconPath$z, hWndReply:Int, uReplyMsg:Int, SoundFile$z)
	Rem
	bbdoc: Get the path of the snarl application
	EndRem
	Function snGetAppPath$z()
	Rem
	bbdoc: Returns the atom that corresponds to the "SnarlGlobalEvent" registered Windows message
	EndRem
	Function snGetGlobalMessage:Int()
	Rem
	bbdoc: Retrieve the major and minor version number
	returns: True if Snarl is runnign
	EndRem
	Function snGetVersion:Int(Major:Byte Ptr, Minor:Byte Ptr)
	Rem
	bbdoc: Get the version number
	EndRem
	Function snGetVersionEx:Int()
	Rem
	bbdoc: Hide a notification
	EndRem
	Function snHideMessage:Int(Id:Int)
	Rem
	bbdoc: Check if a notification is visible
	EndRem
	Function snIsMessageVisible(Id:Int)
	Rem
	bbdoc: Returns a handle to the current Snarl Dispatcher window, or zero if it wasn't found. This is the recommended way to test if Snarl is running or not
	EndRem
	Function snGetSnarlWindow:Int()
	Rem
	bbdoc: Set the timeout for a notification
	EndRem
	Function snSetTimeout:Int(Id:Int, Timeout:Int)
	Rem
	bbdoc: Update a message's display attributes
	EndRem
	Function snUpdateMessage:Int(Id:Int, Title$z, Text$z, IconPath$z)
	Rem
	bbdoc: Register the application with Snarl.
	about: Call #snRevokeConfig after calling this.
	EndRem
	Function snRegisterConfig:Int(hWnd:Int, AppName$z, replyMsg:Int)
	Rem
	bbdoc: Removes the application previously registered using snRegisterConfig()
	EndRem
	Function snRevokeConfig:Int(hWnd:Int)
	Rem
	bbdoc: Register a new alert type.
	EndRem
	Function snRegisterAlert:Int(AppName$z, Class$z, DefaultSetting:Int)

End Extern

Rem
bbdoc: Get the path containing Snarl icons
EndRem
Function snGetIconsPath:String()
	Return snGetAppPath() + "etc\icons\"
End Function



Rem
bbdoc: Structure describing a Snarl notification.
End Rem
Type TSnarlNotification

	
	Field snarlID:Int
	Field Title:String, Description:String
	Field Timeout:Int
	Field IconPath:String

	Rem
	bbdoc: Creates and displays new notification
	about: The new notifaction is displayed with the given @title and @description, disappears after @timeout seconds (or stays until clicked if timeout is 0), and displays the PNG image specified by @IconPath
	
	Null is returned if the function is unsuccessful
	End Rem
	Function CreateSnarlNotification:TSnarlNotification(title:String, description:String = "", timeout:Int = 6, IconPath:String = "")
		Return New TSnarlNotification.Create(title, description, timeout, IconPath)
	End Function
	
	Rem
	bbdoc: See #CreateSnarlNotification
	End Rem
	Method Create:TSnarlNotification(title:String, description:String = "", timeout:Int = 6, IconPath:String = "")
		If IconPath = Null IconPath = ""
		IconPath = RealPath(IconPath)
		snarlID = snShowMessage(title, Description, timeout, IconPath, Null, Null)
		
		self.Title = title
		self.Description = description
		self.Timeout = Timeout
		self.IconPath = IconPath
		
		If snarlID <> SNARL_M_FAILED and snarlID <> SNARL_M_TIMED_OUT Return Self
	End Method

	Rem
	bbdoc: Sets the notification title.
	about: A notification's title describes the notification briefly.
	<p>
	It should be easy to read quickly by the user.
	</p>
	retuns:SNARL_M_OK, SNARL_M_NOTFOUND, SNARL_M_TIMED_OUT  or SNARL_M_FAILED
	End Rem
	Method SetTitle:Int(title:String)
		Return snUpdateMessage(snarlID, Title, Description, Iconpath)
	End Method

	Rem
	bbdoc: Sets the notification description.
	about: The description supplements the title with more
	information. It is usually longer and sometimes involves a list of
	subjects. For example, for a 'Download complete' notification, the
	description might have one filename per line. GrowlMail in Growl 0.6
	uses a description of '%d new mail(s)' (formatted with the number of
	messages).
	retuns:SNARL_M_OK, SNARL_M_NOTFOUND, SNARL_M_TIMED_OUT  or SNARL_M_FAILED
	End Rem
	Method SetDescription:Int(Description:String)
		Return snUpdateMessage(snarlID, Title, Description, Iconpath)
	End Method
	
	Rem
	bbdoc: Sets the notification icon.
	about: The notification icon usually indicates either what
	happened (it may have the same icon as e.g. a toolbar item that
	started the process that led to the notification), or what it happened
	to (e.g. a document icon).
	<p>
	The icon must be a path to a PNG file, or an empty string to display no icon.
	</p>
	retuns:SNARL_M_OK, SNARL_M_NOTFOUND, SNARL_M_TIMED_OUT  or SNARL_M_FAILED
	End Rem
	Method SetIcon:Int(IconPath:String)
		If IconPath = Null IconPath = ""
		IconPath = RealPath(IconPath)
		Return snUpdateMessage(snarlID, Title, Description, Iconpath)
	End Method
	
	Rem
	bbdoc: Sets the timeout of the notification to @Timeout seconds.
	about: If @Timeout is 0, the notification remains until clicked on.
	EndRem
	Method SetTimeOut:Int(Timeout:Int)
		snSetTimeout(snarlID, Timeout)
	End Method
	
	Rem
	bbdoc: Set all of the notification's display attributes at once.
	retuns:SNARL_M_OK, SNARL_M_NOT_FOUND, SNARL_M_TIMED_OUT or SNARL_M_FAILED
	EndRem
	Method Update:Int(Title:String, Description:String, Iconpath:String)
		If IconPath = Null IconPath = ""
		IconPath = RealPath(IconPath)
		Return snUpdateMessage(snarlID, Title, Description, Iconpath)
	EndMethod
	
	Rem
	bbdoc: Returns True if the notification is visible.
	EndRem
	Method IsVisible:Int()
		Return snIsMessageVisible(snarlID)
	EndMethod
	
	Rem
	bbdoc: Returns True if the notification was succesfully hidden.
	EndRem
	Method Hide:Int()
		Return snHideMessage(snarlID)
	End Method
End Type

''''''''
'Consts'
''''''''
Const SNARL_LAUNCHED:Int = 1                 'Snarl has just started running
Const SNARL_QUIT:Int = 2                     'Snarl is about to stop running

Const SNARL_ASK_APPLET_VER:Int = 3           '(R1.5) Reserved for future use
Const SNARL_SHOW_APP_UI:Int = 4              '(R1.6) Application should show its UI
Const SNARL_NOTIFICATION_CLICKED:Int = 32    'Notification was right-clicked by user
Const SNARL_NOTIFICATION_TIMED_OUT:Int = 33
Const SNARL_NOTIFICATION_ACK:Int = 34        'Notification was left-clicked by user

Const SNARL_M_ABORTED:Int = $80000007
Const SNARL_M_ACCESS_DENIED:Int = $80000009
Const SNARL_M_ALREADY_EXISTS:Int = $8000000C
Const SNARL_M_BAD_HANDLE:Int = $80000006
Const SNARL_M_BAD_POINTER:Int = $80000005
Const SNARL_M_FAILED:Int = $80000008
Const SNARL_M_INVALID_ARGS:Int = $80000003
Const SNARL_M_NO_INTERFACE:Int = $80000004
Const SNARL_M_NOT_FOUND:Int = $8000000B
Const SNARL_M_NOT_IMPLEMENTED:Int = $80000001
Const SNARL_M_OK:Int = $00000000
Const SNARL_M_OUT_OF_MEMORY:Int = $80000002
Const SNARL_M_TIMED_OUT:Int = $8000000A

?