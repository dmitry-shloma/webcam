unit UTVideoPlayer;

interface
Uses
        Windows,
        DirectShow,
        ActiveX;

CONST
  dsEventMessage                    = $8000+12345;  // Unique event identifier
  dsEventInstance  : Integer        = 54321;         // Unique event identifier
  dsEventsOn       : Integer        = 0;
  dsEventsOff      : Integer        = 1;

          stClosed = 0;
          stPlay = 1;
          stStop = 2;
          stPaused = 3;


TYPE
                         TVideoRenderer = CLASS
                         Private
                                 FGraph : IGraphBuilder;  //main graph builder
                          FMediaControl : IMediaControl;  //media controller
                                FVidWin : IVideoWindow;   //video window
                                 FEvent : IMediaEventEx;  //event notificator
                                  FSeek : IMediaSeeking;  //position controller
                            MediaLength : Int64;
                          MediaPosition : int64;

                          ControlHandle : HWND;

                         Public
                                plState : Integer;        //program status

                         Constructor Create;
                         Destructor Destroy; override;
                         Procedure  DestroyInterfaces;
                         Procedure  CreateInterfaces; 
                         Procedure OpenFile(const fn: string; CHandle,VHandle: HWND);
                                            //FN - filename
                                            //CHandle - Main form handle (handle of controller)
                                            //VHandle - Handle of video window
                                              //may be equal CHandle or may be not(uses other form
                                              //for output video)
                         Procedure PutControlHandle(wnd: HWND);
                                   //Setup main form(controller) handle              
                         Procedure PutVideoWindowHandle(wnd: HWND);
                                   //Setup video window handle
                         Procedure SetVideoWindowSize(r:TRect);

                         Procedure Play;   //start playing
                         Procedure Stop;   //stop playing (with positioning on start videoclip)
                         Procedure Pause;  //pause/resume playing
                         Procedure SetPosition(NewTime:int64); //set position
                                               //NewTime is DShow unit equal 100 nanoseconds
                         Procedure PlayThreaded;
                         END;

Function PlayVideo(fn:String;CHandle,VHandle:HWND):Boolean;

implementation

{------------------------------------------------------------------------------}

Function PlayVideo(fn:String;CHandle,VHandle:HWND):Boolean;
var
  v: TVideoRenderer;
begin
  result := true;
  try
    v := TVideoRenderer.Create;
    try
      v.OpenFile(fn,CHandle,VHandle);
      v.PlayThreaded;
    finally
      v.free;
    end;
  except
    result := false;
  end;
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.CreateInterfaces;
begin
  CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
                        IID_IGraphBuilder, FGraph);
  FGraph.QueryInterface(IID_IMediaControl, FMediaControl);
  FGraph.QueryInterface(IID_IVideoWindow, FVidWin);
  FGraph.QueryInterface(IID_IMediaEventEx, FEvent);
  FGraph.QueryInterface(IID_IMediaSeeking, FSeek);
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.DestroyInterfaces;
begin
  If assigned(FMediaControl) then FMediaControl.Stop;
  FMediaControl := nil;
  FSeek:=nil;
  FEvent := nil;
  FGraph := nil;
  if assigned(FVidWin) then FVidWin.put_Visible(false);
  FVidWin := nil;
end;

{------------------------------------------------------------------------------}

Constructor TVideoRenderer.Create;
begin
  CoInitialize(nil);
  plstate:=stclosed;
end;

{------------------------------------------------------------------------------}

destructor TVideoRenderer.Destroy;
begin
  CoUninitialize;
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.OpenFile(const fn: string; CHandle,VHandle: HWND);
var
  wc:  array[0..1023] of WideChar;
begin
  DestroyInterfaces;
  CreateInterfaces;
  StringToWideChar(fn, wc, length(wc));
  FGraph.RenderFile(wc, nil);
  PutControlHandle(CHandle);
  PutVideoWindowHandle(VHandle);
  Fseek.GetPositions(MediaPosition,MediaLength);
  plstate:=ststop;
end;

{------------------------------------------------------------------------------}

procedure TVideoRenderer.PutControlHandle(wnd: HWND);
begin
 FEvent.SetNotifyWindow(wnd,dsEventMessage,dsEventInstance);
 FEvent.SetNotifyFlags(dsEventsOn);
 ControlHandle:=wnd;
end;

{------------------------------------------------------------------------------}

procedure TVideoRenderer.PutVideoWindowHandle(wnd: HWND);
 var r:trect;
begin
  FVidWin.put_Owner(wnd);
  FVidWin.put_WindowStyle(WS_CHILD or WS_CLIPSIBLINGS);
  GetClientRect(wnd, r);
  FVidWin.SetWindowPosition(0, 0, r.right, r.bottom);
end;

{------------------------------------------------------------------------------}

procedure TVideoRenderer.Stop;
begin
 if plstate=stclosed then exit;
 FMediaControl.Stop;
  SetPosition(0);
 plstate:=ststop;
end;

{------------------------------------------------------------------------------}

procedure TVideoRenderer.Pause;
begin
 if plstate=stclosed then exit;
 case plstate of
  stplay : begin
            FMediaControl.Pause;
            plstate:=stpaused;
           end;
 stpaused : begin
            FMediaControl.Run;
            plstate:=stplay;
           end;
 stStop : begin
            FMediaControl.Run;
            plstate:=stplay;
           end;
  end;
end;

{------------------------------------------------------------------------------}

procedure TVideoRenderer.Play;
begin
 if plstate=stclosed then exit;
  FMediaControl.Run;
  plstate:=stplay;
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.SetPosition(NewTime:int64);
begin
 fSeek.SetPositions(NewTime,AM_SEEKING_AbsolutePositioning,NewTime,AM_SEEKING_NoPositioning);
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.PlayThreaded;
Var Msg:TMsg;
begin
 Play;
 While getmessage(Msg,ControlHandle,0,0) do
 begin
  TranslateMessage(msg);
  DispatchMessage(msg);
 end;
end;

{------------------------------------------------------------------------------}

Procedure TVideoRenderer.SetVideoWindowSize(r:trect);
begin
  FVidWin.SetWindowPosition(0, 0, r.right, r.bottom);
end;

{------------------------------------------------------------------------------}

end.
