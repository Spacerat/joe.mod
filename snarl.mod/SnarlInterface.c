#include <stdio.h>
#include <tchar.h>
#include <windows.h>
#include <stdlib.h>
#include "SnarlInterface.h"

const LPCTSTR SNARL_GLOBAL_MSG = _T("SnarlGlobalEvent");

//-----------------------------------------------------------------------------
// snShowMessage()

/// Displays a message with Title and Text. Timeout controls how long the
/// message is displayed for (in seconds) (omitting this value means the message
/// is displayed indefinately). IconPath specifies the location of a PNG image
/// which will be displayed alongside the message text.
LONG32 snShowMessage(LPCSTR szTitle, LPCSTR szText, LONG32 timeout, LPCSTR szIconPath, HWND hWndReply, WPARAM uReplyMsg)
{
	struct SNARLSTRUCT ss;
	ZeroMemory((void*)&ss, sizeof(ss));

	ss.Cmd = SNARL_SHOW;
	strncpy((LPSTR)&ss.Title, szTitle, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Text, szText, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Icon, szIconPath, SNARL_STRING_LENGTH);
	ss.Timeout = timeout;



	ss.LngData2 = (LONG32)hWndReply;
	ss.Id = uReplyMsg;
	return uSend(ss);
}

//-----------------------------------------------------------------------------
// snShowMessageEx()

/// Displays a notification. This function is identical to snShowMessage()
/// except that Class specifies an alert previously registered with
/// snRegisterAlert() and SoundFile can optionally specify a WAV sound to play
/// when the notification is displayed on screen.

/// @Returns: M_FAILED, M_TIMED_OUT, M_BAD_HANDLE, M_NOT_FOUND, M_ACCESS_DENIED
LONG32 snShowMessageEx(LPCSTR szClass, LPCSTR szTitle, LPCSTR szText, LONG32 timeout, LPCSTR szIconPath, HWND hWndReply, WPARAM uReplyMsg, LPCSTR szSoundFile)
{
	struct SNARLSTRUCTEX ssex;

	ZeroMemory((void*)&ssex, sizeof(ssex));
	ssex.Cmd = SNARL_EX_SHOW;
	ssex.Timeout = timeout;
	ssex.LngData2 = (LONG32)hWndReply;
	ssex.Id = uReplyMsg;

	strncpy((LPSTR)&ssex.Class, szClass, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ssex.Title, szTitle, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ssex.Text, szText, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ssex.Icon, szIconPath, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ssex.Extra, szSoundFile, SNARL_STRING_LENGTH);
	return uSendEx(ssex);
}

//-----------------------------------------------------------------------------
// snHideMessage()

/// Hides the notification specified by Id. Id is the value returned by
/// snShowMessage() or snShowMessageEx() when the notification was initially
/// created. This function returns True if the notification was successfully
/// hidden or False otherwise (for example, the notification may no longer exist).
BOOL snHideMessage(LONG32 Id)
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_HIDE;
	ss.Id = Id;

	if (uSend(ss) == M_OK)
		return TRUE;
	return FALSE;
}

//-----------------------------------------------------------------------------
// snIsMessageVisible()

/// Returns True if the notification specified by Id is still visible, or
/// False if not. Id is the value returned by snShowMessage() or
/// snShowMessageEx() when the notification was initially created.

BOOL snIsMessageVisible(LONG32 Id)
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_IS_VISIBLE;
	ss.Id = Id;

	if (uSend(ss) != 0)
		return TRUE;
	else
		return FALSE;
}

//-----------------------------------------------------------------------------
// snUpdateMessage()

/// Changes the title and text in the message specified by Id to the values
/// specified by Title and Text respectively. Id is the value returned by 
/// snShowMessage() or snShowMessageEx() when the notification was originally
/// created. To change the timeout parameter of a notification, use snSetTimeout()

BOOL snUpdateMessage(LONG32 id, LPCSTR szTitle, LPCSTR szText, LPCSTR szIconPath)
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_UPDATE;
	ss.Id = id;


	strncpy((LPSTR)&ss.Title, szTitle, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Text, szText, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Icon, szIconPath, SNARL_STRING_LENGTH);

	if (uSend(ss) == M_OK)
		return TRUE;
	return FALSE;
}


//-----------------------------------------------------------------------------
// snRegisterConfig

/// Registers an application's configuration interface with Snarl.
/// AppName is the text that's displayed in the Applications list so it should
/// be people friendly ("My cool app" rather than "my_cool_app").

enum M_RESULT snRegisterConfig(HWND hWnd, LPCSTR szAppName, LONG32 replyMsg)
{
	struct SNARLSTRUCT ss;

	m_hwndFrom = hWnd;

	ss.Cmd = SNARL_REGISTER_CONFIG_WINDOW;
	ss.LngData2 = (LONG32)hWnd;
	ss.Id = replyMsg;
	strncpy((LPSTR)&ss.Title, szAppName, SNARL_STRING_LENGTH);

	return (enum M_RESULT)uSend(ss);
}


//-----------------------------------------------------------------------------
// snRegisterConfig2

/// Registers an application's configuration interface with Snarl.
/// This function is identical to snRegisterConfig() except that Icon can be
/// used to specify a PNG image which will be displayed against the
/// application's entry in Snarl's Preferences panel.

enum M_RESULT snRegisterConfig2(HWND hWnd, LPCSTR szAppName, LONG32 replyMsg, LPCSTR szIcon)
{
	struct SNARLSTRUCT ss;

	m_hwndFrom = hWnd;
	hWndReply = hWnd;

	ss.Cmd = SNARL_REGISTER_CONFIG_WINDOW_2;
	ss.LngData2 = (LONG32)hWnd;
	ss.Id = replyMsg;

	strncpy((LPSTR)&ss.Title, szAppName, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Icon, szIcon, SNARL_STRING_LENGTH);

	return (enum M_RESULT)uSend(ss);
}

//-----------------------------------------------------------------------------
// snRevokeConfig

/// Removes the application previously registered using snRegisterConfig() or
/// snRegisterConfig2(). hWnd should be the same as that used during registration.

BOOL snRevokeConfig(HWND hWnd)
{
	struct SNARLSTRUCT ss;
	
	m_hwndFrom = NULL;

	ss.Cmd = SNARL_REVOKE_CONFIG_WINDOW;
	ss.LngData2 = (LONG32)hWnd;

	if (uSend(ss) == M_OK)
		return TRUE;
	return FALSE;
}

//-----------------------------------------------------------------------------
// snGetVersion()

/// Checks if Snarl is currently running and, if it is, retrieves the major and
/// minor release version numbers in Major and Minor respectively.
/// Returns True if Snarl is running, False otherwise.

BOOL snGetVersion(WORD* Major, WORD* Minor)
{
	LONG32 versionInfo;

	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_GET_VERSION;
	versionInfo = uSend(ss);
	if (versionInfo != M_FAILED && versionInfo != M_TIMED_OUT) {
		*Major = HIWORD(versionInfo);
		*Minor = LOWORD(versionInfo);
		return TRUE;
	}
	return FALSE;
}

//-----------------------------------------------------------------------------
// snGetVersionEx

/// Returns the Snarl system version number. This is an integer value which
/// represents the system build number and can be used to identify the specific
/// version of Snarl running

LONG32 snGetVersionEx()
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_GET_VERSION_EX;
	return uSend(ss);
}


//-----------------------------------------------------------------------------
// snSetTimeout()

/// Sets the timeout of existing notification Id to Timeout seconds. Id is the
/// value returned by snShowMessage() or snShowMessageEx() when the notification
/// was first created. 

enum M_RESULT snSetTimeout(LONG32 Id, LONG32 Timeout)
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_SET_TIMEOUT;
	ss.Id = Id;
	ss.LngData2 = Timeout;

	return (enum M_RESULT)uSend(ss);
}

//-----------------------------------------------------------------------------
// snRegisterAlert()

/// Registers an alert of Class for application AppName which must have previously
/// been registered with either snRegisterConfig() or snRegisterConfig2().

enum M_RESULT snRegisterAlert(LPCSTR szAppName, LPCSTR szClass, BOOL defaultSetting)
{
	struct SNARLSTRUCT ss;
	ss.Cmd = SNARL_REGISTER_ALERT;
	strncpy((LPSTR)&ss.Title, szAppName, SNARL_STRING_LENGTH);
	strncpy((LPSTR)&ss.Text, szClass, SNARL_STRING_LENGTH);
	if (!defaultSetting) {
		ss.LngData2 = 0x00000001;
	} else {
		ss.LngData2 = 0x00000000;
	}

	return (enum M_RESULT)uSend(ss);
}

//-----------------------------------------------------------------------------
// snGetGlobalMsg()

/// Returns the atom that corresponds to the "SnarlGlobalEvent" registered
/// Windows message. This message is sent by Snarl when it is first starts and
/// when it shuts down.

LONG32 snGetGlobalMsg()
{
	return RegisterWindowMessage(_T("SnarlGlobalEvent"));
}

//-----------------------------------------------------------------------------
// snGetAppPath()

/// Returns a pointer to the path.
/// delete [] when finished !

LPCTSTR snGetAppPath()
{
	HWND hWnd = snGetSnarlWindow();

	strcpy(snarlAppPath,"\0");
	if (hWnd)
	{
		HWND hWndPath = FindWindowEx(hWnd, 0, ("static"), NULL);
		if (hWndPath) {	
			int nReturn = GetWindowText(hWndPath, snarlAppPath, 1024);
			if (nReturn > 0) {
				return snarlAppPath;
			//	return TRUE;
			}
		}
	} 
	return NULL;
}


//-----------------------------------------------------------------------------
// snGetIconsPath()

/// Returns a pointer to the iconpath.
/// ** delete [] when finished !

LPCTSTR snGetIconsPath()
{
	//not implemented
	return NULL;
	/*
	size_t nLen;

	TCHAR* szIconPath = NULL;
	LPCTSTR szPath = snGetAppPath();
	if (!szPath)
		return NULL;

	nLen = 0;
	if (SUCCEEDED(StringCbLength(szPath, MAX_PATH, &nLen)))
	{
		nLen += 10 + 1; // etc\\icons\\ + NULL
		szIconPath = new TCHAR[nLen];

		StringCbCopy(szIconPath, nLen * sizeof(TCHAR), szPath);
		StringCbCat(szIconPath, nLen * sizeof(TCHAR), _T("etc\\icons\\"));
	}
	
	delete [] szPath;

	return szIconPath;
	*/
}



HWND snGetSnarlWindow()
{
  HWND snarlWindowHandle =  FindWindow("w>Snarl", _T("Snarl"));  
  if (!snarlWindowHandle) {
      // has been changed in Snarl 2.2
      snarlWindowHandle =  FindWindow(NULL, _T("Snarl"));
    }
	return snarlWindowHandle;
}


LONG32 uSend(struct SNARLSTRUCT ss)
{
	DWORD nReturn = M_FAILED;
	HWND hWnd = snGetSnarlWindow();
	if (IsWindow(hWnd))
	{
		COPYDATASTRUCT cds;
		cds.dwData = 2;
		cds.cbData = sizeof(ss);
		cds.lpData = &ss;
		if (!SendMessageTimeout(hWnd, WM_COPYDATA, (WPARAM)m_hwndFrom, (LPARAM)&cds, SMTO_NORMAL, 1000, &nReturn))
		{
			nReturn = M_TIMED_OUT;
		}


	}
	return nReturn;
}

LONG32 uSendEx(struct SNARLSTRUCTEX ssex)
{
	DWORD nReturn = M_FAILED;
	HWND hWnd = snGetSnarlWindow();
	if (IsWindow(hWnd))
	{
		COPYDATASTRUCT cds;
		cds.dwData = 2;
		cds.cbData = sizeof(ssex);
		cds.lpData = &ssex;
		if (!SendMessageTimeout(hWnd, WM_COPYDATA, (WPARAM)m_hwndFrom, (LPARAM)&cds, SMTO_NORMAL, 1000, &nReturn))
		{
			nReturn = M_TIMED_OUT;
		}
	}
	return nReturn;
}
