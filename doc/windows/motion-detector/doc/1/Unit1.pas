unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, VFW, StdCtrls, ExtCtrls, Menus, ComCtrls, XPMan;

type
  TForm1 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    Shape1: TShape;
    Label5: TLabel;
    Button3: TButton;
    Label1: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    XPManifest: TXPManifest;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
//===================
  hWndC: HWND;
  s1: TCAPTUREPARMS;
  s2: TCAPSTATUS;
  s3: TCAPDRIVERCAPS;
  d: cardinal;

  bt: bitmapinfo;
  dc: HWND;

  Kadr1,q: Boolean;
  KolVo_Kadrov: Integer;

  Frames_Count: Integer;
  CopySecondFrame: Boolean = False;
  Sens_Old: Integer = 0;
  Sens_New: Integer = 0;

  psCompressed: IAVISTREAM;

  Save:IAVISTREAM;
  newf:IAVIFILE;
  StreamInfo:TAVIStreamInfo;

  pf: IAVIFILE;
  bi: BITMAPINFOHEADER;
  strhdr: TAVISTREAMINFO;
  psSmall: IAVISTREAM;

  Pstream: IAVISTREAM;
  pFile: IAVIFILE;

  BitmapInfo: BitmapInfoHeader;
  BitmapInfoSize: Integer;
  BitmapSize: longInt;
  BitmapBits: pointer;

  Samples_Written: LONG;
  Bytes_Written: LONG;
  AVIERR: integer;
  i: integer;
  startpos: DWORD;
  len: DWORD;

  plpOptions: PAVICOMPRESSOPTIONS;

implementation

{$R *.dfm}

function capVideoFrameCallback(hWnd: HWND; lpVHdr: PVIDEOHDR): LRESULT; stdcall;
type
  TByteArray = array [0..1] of Byte;
  PByteArray = ^TByteArray;

var
  FirstFrame,
  SecondFrame: array[0..320*240*3] of Byte;
  Count,
  Color,
  Itog: Integer;
  SamePixelsInTwoFrames: Cardinal;

begin
  Inc(Frames_Count);
  {
  AVIStreamWrite(pStream, Frames_Count, 1, @SecondFrame, SizeOf(SecondFrame),
    AVIIF_KEYFRAME, @Samples_Written, @Bytes_Written);
  }
{--!!!! Наконец-то доделал Датчик движения:)) !!!!---------------------------->}
  if CopySecondFrame then
  begin
    CopyMemory(@SecondFrame, lpVHdr.lpData, lpVHdr.dwBytesUsed);
    SamePixelsInTwoFrames:= 0;
    for Count:= 0 to 76800 do
    begin
      //SecondFrame[x*3+0]:=148; //B
      //SecondFrame[x*3+1]:=79; //G
      //SecondFrame[x*3+2]:=151;  //R
      for Color:=2 downto 0 do
      begin
        if Abs(FirstFrame[Count*3+Color]-SecondFrame[Count*3+Color])>40 then
          Inc(SamePixelsInTwoFrames);
      end;
    end;
    if Sens_Old <> 0 then
    begin
      Sens_New:= 100*SamePixelsInTwoFrames div 3 div 76800;
      if Sens_New>=Sens_Old then Itog:= 100* Sens_Old div Sens_New
        else Itog:= 100* Sens_New div Sens_Old;
      Form1.Label5.Caption:= IntToStr(Itog)+' %';
      if Itog>0 then Application.Title:='Движение'
        else Application.Title:='Нет Движения';
      //===>
      AVIStreamWrite(psCompressed, Frames_Count, 1, @SecondFrame, SizeOf(SecondFrame),
      AVIIF_KEYFRAME, @Samples_Written, @Bytes_Written);
      //==<
      Sens_Old:= Sens_New;
    end
    else Sens_Old:= 100*SamePixelsInTwoFrames div 3 div 76800;

    CopySecondFrame:= False;
  end;
  CopyMemory(@FirstFrame, lpVHdr.lpData, lpVHdr.dwBytesUsed);
  CopySecondFrame:= True;
{-----------------------------------------------------------------------------<}
  Result:= 0;
end;

function qwerty(): dword; stdcall;
begin
  //capGrabFrame(hwndc);

  Result:=0;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  hWndC:= capCreateCaptureWindow('CaptureWindow1', WS_CHILD or WS_VISIBLE,
    9, 17, 320, 240, GroupBox1.Handle, 0);

  capDriverConnect (hWndC, 0);
  FillChar(s1, SizeOf(TCAPTUREPARMS), 0);
  capCaptureGetSetup(hWndC, @s1, SizeOf(TCAPTUREPARMS));
  s1.dwRequestMicroSecPerFrame:= 40000;
  s1.fYield:= True;
  s1.fCaptureAudio:= False;
  s1.fLimitEnabled:= False;
 	s1.vKeyAbort:= 0;
	s1.fAbortLeftMouse:= False;
	s1.fAbortRightMouse:= False;
  capCaptureSetSetup(hWndC, @s1, SizeOf(TCAPTUREPARMS));

  FillChar(s2, SizeOf(TCAPSTATUS), 0);
  capGetStatus(hWndC, @s2, SizeOf(TCAPSTATUS));

  FillChar(s3, SizeOf(TCAPDRIVERCAPS), 0);
  capDriverGetCaps(hWndC, @s3, SizeOf(TCAPDRIVERCAPS));

  capPreviewRate(hWndC, 1);
{
  SendMessage(hWndC, WM_CAP_GET_VIDEOFORMAT, SizeOf(Bt), LongInt(@Bt));
  Bt.bmiHeader.biWidth:= 320;
  Bt.bmiHeader.biHeight:= 240;
  Bt.bmiHeader.biSize:= SizeOf(Bt.bmiHeader);
  Bt.bmiHeader.biPlanes:= 1;
  Bt.bmiHeader.biBitCount:= 24;
  SendMessage(hWndC, WM_CAP_SET_VIDEOFORMAT, SizeOf(Bt), LongInt(@Bt));
  capSetCallbackOnFrame(hWndC, @capVideoFrameCallback);
}
  //createthread(nil,0,@qwerty,nil,0,fg);
  capPreview(hWndC, True);
  //capOverlay(hWndC, True);
  //capCaptureSequenceNoFile(hWndC);
  //capDlgVideoFormat(hWndC);
  //capFileSetCaptureFile(hWndC, 'c:\1.avi');
  //capFileAlloc(hWndC, 524288000);
  //capDlgVideoCompression(hWndC);
  //capCaptureSequence(hWndC);

  Button1.Enabled:=True;
  Button2.Enabled:=True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  capDlgVideoSource(hWndC);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  capDlgVideoFormat(hWndC);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.Title:=Caption;
  //Open AVI file for write
  AVIFileInit;
  AVIFileOpen(pFile, '2.avi', OF_WRITE or OF_CREATE, nil);
  FillChar(StreamInfo, sizeof(StreamInfo), 0);
  //Set frame rate and scale
  StreamInfo.fccType:= streamtypeVIDEO;
  StreamInfo.fccHandler:=  mmioFOURCC('x','v','i', 'd');
  StreamInfo.dwFlags:= 0;
  StreamInfo.dwRate:= 12000;
  StreamInfo.dwScale:= 1000;
  StreamInfo.dwSuggestedBufferSize:= 0;
  StreamInfo.rcFrame.Right:= 320;
  StreamInfo.rcFrame.Bottom:= 240;

  FillChar(BitmapInfo, sizeof(BitmapInfo), 0);
  BitmapInfo.biSize:= sizeof(BitmapInfo);
  BitmapInfo.biWidth:=320;
  BitmapInfo.biHeight:=240;
  BitmapInfo.biPlanes:=1;
  BitmapInfo.biBitCount:=24;
  BitmapInfo.biCompression:=BI_RGB;

  //Open AVI data stream
  AVIFileCreateStream(pFile, pStream, StreamInfo);
  AVIMakeCompressedStream(psCompressed, pStream, plpOptions, nil);
  AVIStreamSetFormat(psCompressed, 0, @BitmapInfo, sizeof(BitmapInfo));

  Frames_Count:= 0;
end;

end.
