#ifndef	__MEDIA_PLAYER_CPP__
#define __MEDIA_PLAYER_CPP__

#include <dshow.h>
#include <commctrl.h>
#include <commdlg.h>
#include <stdio.h>
#include <tchar.h>
#include <atlbase.h>
#include <string.h>

class		cMediaPlayer{
	IGraphBuilder			*GraphBuilder;
    IMediaControl			*MediaControl;
    IMediaEventEx			*MediaEvent;
	IVideoWindow			*VideoWindow;
	IMediaSeeking			*MediaSeeking;
	IBasicAudio				*BasicAudio;

	bool					Looped;
public:
	cMediaPlayer( void );
	~cMediaPlayer();
	void					LoadFile( HWND , char* );
	void					PlayFile( void );
	void					StopFile( void );
	void					SetVolume( long );
	void					AttachToWindow( HWND );
	void					ToggleFullscreen( HWND );
	void					SetNotifyWindow( HWND , long , long );
	void					HandleEvent( void );
};

#endif