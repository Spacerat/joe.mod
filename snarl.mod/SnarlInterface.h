#ifndef SNARL_INTERFACE
#define SNARL_INTERFACE		


const LPCTSTR SNARL_GLOBAL_MSG;
const int SNARL_STRING_LENGTH = 1024; // not used because C-compiler doesn't accept it for char lenght :(
		static const LONG32 SNARL_LAUNCHED = 1;                // Snarl has just started running
		static const LONG32 SNARL_QUIT = 2;                    // Snarl is about to stop running
		static const LONG32 SNARL_ASK_APPLET_VER = 3;          // (R1.5) Reserved for future use
		static const LONG32 SNARL_SHOW_APP_UI = 4;             // (R1.6) Application should show its UI
		static const LONG32 SNARL_NOTIFICATION_CLICKED = 32;   // notification was right-clicked by user
		//static const LONG32 SNARL_NOTIFICATION_CANCELLED = SNARL_NOTIFICATION_CLICKED;  // Added in R1.6
		static const LONG32 SNARL_NOTIFICATION_TIMED_OUT = 33;
		static const LONG32 SNARL_NOTIFICATION_ACK = 34;       // notification was left-clicked by user
		static const DWORD WM_SNARLTEST    = WM_USER + 237;    // note hardcoded WM_USER value!
		static const DWORD WM_MANAGE_SNARL = WM_USER + 238; 


				// typedef enum M_RESULT {
		// http://forums.devarticles.com/c-c-help-52/empty-declaration-11908.html
		enum M_RESULT {
			M_ABORTED         = 0x80000007,
			M_ACCESS_DENIED   = 0x80000009,
			M_ALREADY_EXISTS  = 0x8000000C,
			M_BAD_HANDLE      = 0x80000006,
			M_BAD_POINTER     = 0x80000005,
			M_FAILED          = 0x80000008,
			M_INVALID_ARGS    = 0x80000003,
			M_NO_INTERFACE    = 0x80000004,
			M_NOT_FOUND       = 0x8000000B,
			M_NOT_IMPLEMENTED = 0x80000001,
			M_OK              = 0x00000000,
			M_OUT_OF_MEMORY   = 0x80000002,
			M_TIMED_OUT       = 0x8000000A
		};

  enum SNARL_COMMANDS {
			SNARL_SHOW = 1,
			SNARL_HIDE,
			SNARL_UPDATE,
			SNARL_IS_VISIBLE,
			SNARL_GET_VERSION,
			SNARL_REGISTER_CONFIG_WINDOW,
			SNARL_REVOKE_CONFIG_WINDOW,

			// R1.6 onwards
			SNARL_REGISTER_ALERT,
			SNARL_REVOKE_ALERT,   // for future use
			SNARL_REGISTER_CONFIG_WINDOW_2,
			SNARL_GET_VERSION_EX,
			SNARL_SET_TIMEOUT,

			// extended commands (all use SNARLSTRUCTEX)
			SNARL_EX_SHOW = 0x20
		};

		struct SNARLSTRUCT {
			enum SNARL_COMMANDS Cmd;
			LONG32 Id;
			LONG32 Timeout;
			LONG32 LngData2;
			char Title[1024];
			char Text[1024];
			char Icon[1024];
		};

	struct SNARLSTRUCTEX {
			enum SNARL_COMMANDS Cmd;
			LONG32 Id;
			LONG32 Timeout;
			LONG32 LngData2;
			char Title[1024];
			char Text[1024];
			char Icon[1024];

			char Class[1024];
			char Extra[1024];
			char Extra2[1024];
			LONG32 Reserved1;
			LONG32 Reserved2;
		};

	
HWND m_hwndFrom;
HWND hWndReply = NULL;

LONG32 uSend(struct SNARLSTRUCT StructToBeSend);
LONG32 uSendEx(struct SNARLSTRUCTEX ssex);

LONG32 snShowMessage(LPCSTR szTitle, LPCSTR szText, LONG32 timeout, LPCSTR szIconPath, HWND hWndReply, WPARAM uReplyMsg);
LONG32 snShowMessageEx(LPCSTR szClass, LPCSTR szTitle, LPCSTR szText, LONG32 timeout, LPCSTR szIconPath, HWND hWndReply, WPARAM uReplyMsg, LPCSTR szSoundFile);

LPCTSTR snGetAppPath(void);
LPCTSTR snGetIconsPath(void);
			
LONG32 snGetGlobalMsg(void);

BOOL			snGetVersion(WORD* Major, WORD* Minor);
LONG32			snGetVersionEx(void);
BOOL			snHideMessage(LONG32 Id);
BOOL			snIsMessageVisible(LONG32 Id);
HWND			snGetSnarlWindow(void);
enum M_RESULT	snRegisterAlert(LPCSTR szAppName, LPCSTR szClass,BOOL defaultSetting);
enum M_RESULT	snRegisterConfig(HWND hWnd, LPCSTR szAppName, LONG32 replyMsg);
enum M_RESULT	snRegisterConfig2(HWND hWnd, LPCSTR szAppName, LONG32 replyMsg, LPCSTR szIcon);
BOOL			snRevokeConfig(HWND hWnd);
enum M_RESULT	snSetTimeout(LONG32 Id, LONG32 Timeout);
BOOL			snUpdateMessage(LONG32 Id, LPCSTR szTitle, LPCSTR szText, LPCSTR szIconPath);

char snarlAppPath[1024] = "";

/*char lastTitle[1024] = "";
char lastText[1024] = "";
char lastClass[1024] = "";
char lastIcon[1024] = "";
BOOL avoidDoubleAlerts = TRUE;*/

	#endif
