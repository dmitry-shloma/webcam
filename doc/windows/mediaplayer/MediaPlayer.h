#ifndef	__MEDIA_PLAYER_H__
#define __MEDIA_PLAYER_H__

#ifdef __HOME__
#include "d:\job\include\MediaPlayer.cpp"
#else
#include "include\MediaPlayer.cpp"
#endif

#pragma comment ( lib , "d3d8.lib" )
#pragma comment ( lib , "d3dx8.lib" )

#define SAFE_RELEASE(x) { if (x) x->Release(); x = NULL; }

#define			WM_DSNOTIFICATION		WM_USER + 1

#pragma comment ( lib , "strmiids.lib" )

cMediaPlayer::cMediaPlayer( void ){
	Looped = true;
	GraphBuilder = NULL;
    MediaControl = NULL;
    MediaEvent = NULL;
	VideoWindow = NULL;
	MediaSeeking = NULL;
	BasicAudio = NULL;
}

void			cMediaPlayer::HandleEvent( void ){
	if( MediaEvent ){
		LONG evCode, evParam1, evParam2;
		while( SUCCEEDED( MediaEvent->GetEvent( &evCode, 
				( LONG_PTR * ) &evParam1 , ( LONG_PTR *) &evParam2 , 0 ) ) ){
			MediaEvent->FreeEventParams( evCode , evParam1 , evParam2 );

			if( EC_COMPLETE == evCode ){
	            LONGLONG pos=0;

				MediaSeeking->SetPositions( &pos , AM_SEEKING_AbsolutePositioning ,
                                   NULL , AM_SEEKING_NoPositioning );
				if( Looped )PlayFile();
			}
		}
	}
}

void				cMediaPlayer::SetVolume( long volume ){
	BasicAudio->put_Volume( volume );
}

void				cMediaPlayer::AttachToWindow( HWND hWnd ){
	RECT			rect;
	GetClientRect( hWnd , &rect );
	//VideoWindow->put_WindowStyle( WS_CHILD | WS_CLIPSIBLINGS );
	VideoWindow->SetWindowPosition( rect.top , rect.left , rect.right , rect.bottom );
	VideoWindow->SetWindowForeground( OATRUE );
	ShowWindow( hWnd , SW_NORMAL );
	UpdateWindow( hWnd );
	VideoWindow->put_Owner( ( OAHWND ) hWnd );
	SetFocus( hWnd );
}

void				cMediaPlayer::StopFile( void ){
	LONGLONG pos = 0;
	MediaControl->Stop();
	MediaSeeking->SetPositions( &pos , AM_SEEKING_AbsolutePositioning , 
		NULL , AM_SEEKING_NoPositioning );
	MediaControl->Pause();
}

cMediaPlayer::~cMediaPlayer(){
	VideoWindow->Release();
	MediaControl->Release();
	MediaEvent->Release();
	MediaSeeking->Release();
	GraphBuilder->Release();
}

void				cMediaPlayer::ToggleFullscreen( HWND hWnd ){
	VideoWindow->put_WindowStyle( WS_CHILD | WS_CLIPSIBLINGS );
	VideoWindow->SetWindowPosition( 0 , 0 , GetSystemMetrics( SM_CXFULLSCREEN ) , 
		GetSystemMetrics( SM_CYFULLSCREEN ) );

	VideoWindow->SetWindowForeground( OATRUE );
	ShowWindow( hWnd , SW_MAXIMIZE );
	UpdateWindow( hWnd );
	VideoWindow->put_Owner( ( OAHWND ) hWnd );
	SetFocus( hWnd );
}

void				cMediaPlayer::PlayFile( void ){MediaControl->Run();}

void			cMediaPlayer::SetNotifyWindow( HWND hWnd , long message , long lParam ){
	if( VideoWindow ){
		MediaEvent->SetNotifyWindow( ( OAHWND )hWnd , message , 0 );
	}
}

void				cMediaPlayer::LoadFile( HWND hWnd , char *path ){
	USES_CONVERSION;
	WCHAR wpath[ 1000 ];

	wcscpy( wpath , T2W( path ) );

	CoCreateInstance( CLSID_FilterGraph , NULL , CLSCTX_INPROC_SERVER , 
                        IID_IGraphBuilder , ( void ** )&GraphBuilder );
    GraphBuilder->QueryInterface( IID_IMediaControl , ( void ** )&MediaControl );
    GraphBuilder->QueryInterface( IID_IMediaEventEx , ( void ** )&MediaEvent );
	GraphBuilder->QueryInterface( IID_IVideoWindow , ( void ** )&VideoWindow );
	GraphBuilder->QueryInterface( IID_IMediaSeeking , ( void ** )&MediaSeeking );
	GraphBuilder->QueryInterface( IID_IBasicAudio , ( void ** )&BasicAudio );

    GraphBuilder->RenderFile( wpath , NULL );

	VideoWindow->put_Owner( ( OAHWND ) hWnd );
}

#endif