unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ActiveX, DirectShow9, ExtCtrls, Menus, ComCtrls, ToolWin,
  Buttons, ImgList, IniFiles, XPMan, MyCapture;

  type
    TMy_ClassEnumeratorInfo = record
      FriendlyName: array[0..255] of string;
      BaseFilter: array[0..255] of IBaseFilter;
      CountOfBaseFilter: Integer;
  end;

  procedure My_ClassEnumerator(clsidDeviceClass: TGUID;
    out My_ClassEnumeratorInfo: TMy_ClassEnumeratorInfo);
  function SaveGraphFile(pGraph: IGraphBuilder; wszPath: WideString): HRESULT;
  function My_FindBaseFilterByName(clsidDeviceClass: TGUID; sName: string): IBaseFilter;
  procedure ShowFilterPropertyPage(BaseFilter: IBaseFilter);
  
type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Shape2: TShape;
    Label2: TLabel;
    Label4: TLabel;
    Bevel2: TBevel;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Shape1: TShape;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    Timer1: TTimer;
    CoolBar: TCoolBar;
    ToolBar1: TToolBar;
    Bevel3: TBevel;
    XPManifest1: TXPManifest;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);

    procedure CapPreview();
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

//------------------------------------------------------------------------------
  GraphBuilder1, GraphBuilder2: IGraphBuilder;
  MediaControl1, MediaControl2: IMediaControl;
  VideoWindow1, VideoWindow2: IVideoWindow;
//------------------------------------------------------------------------------
  Pin_CapDev_out,
  Pin_ColorSpace1_Input_in, Pin_ColorSpace1_XFormOut_out,
  Pin_SmartTee_Input_in, Pin_SmartTee_Preview_out, Pin_SmartTee_Capture_out,
  Pin_ColorSpace2_Input_in, Pin_ColorSpace2_XFormOut_out,
  Pin_VideoRenderer_Input_in,
  Pin_VideoCompres_Input_in, Pin_VideoCompres_Output_out,
  Pin_AviMux_Input01_in, Pin_AviMux_AVIout_out,
  Pin_FileWriter_Input_in: IPin;
//------------------------------------------------------------------------------
  FileSinkFilter: IFileSinkFilter;
//------------------------------------------------------------------------------
  BaseFilter_ColorSpace1,
  BaseFilter_SmartTee,
  BaseFilter_ColorSpace2,
  BaseFilter_VMRVideoRenderer,
  BaseFilter_AviMux,
  BaseFilter_FileWriter: IBaseFilter;
//------------------------------------------------------------------------------
  VideoInfoHeader: TVideoInfoHeader;
  AMStreamConfig: IAMStreamConfig;
  ppmt: PAMMediaType;

  MediaSeeking: IMediaSeeking;
  Bitmap: TBitmap;
  hBitmapCap_DC: Cardinal;
  MemoryStream: TMemoryStream;

implementation

uses Unit2, Unit4, Unit3;

{$R *.dfm}

procedure ShowFilterPropertyPage(BaseFilter: IBaseFilter);
var
  pages: TCAGUID;
  SpecifyPropertyPages: ISpecifyPropertyPages;
begin
  BaseFilter.QueryInterface(IID_ISpecifyPropertyPages, SpecifyPropertyPages);
  SpecifyPropertyPages.GetPages(pages);
  OleCreatePropertyFrame(0, 30, 30, nil, 1, @BaseFilter, pages.cElems,
    pages.pElems, 0, 0, nil);
end;


//������������ ��������� ��������� (������, ���������� ���/��� ������� � �.�.)->
procedure My_ClassEnumerator(clsidDeviceClass: TGUID;
  out My_ClassEnumeratorInfo: TMy_ClassEnumeratorInfo);
var
  CreateDevEnum: ICreateDevEnum;
  EnumMoniker: IEnumMoniker;
  Moniker: IMoniker;
  PropertyBag: IPropertyBag;
  FriendlyName: OleVariant;
  Count: Integer;

begin
  Count:=-1;
  CoCreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER,
    IID_ICreateDevEnum, CreateDevEnum);
  if CreateDevEnum.CreateClassEnumerator(clsidDeviceClass,
    EnumMoniker, 0) = S_OK then
  begin
    while EnumMoniker.Next(1, Moniker, nil) = S_OK do
    begin
      Inc(Count);
      Moniker.BindToStorage(nil, nil, IID_IPropertyBag, PropertyBag);
      PropertyBag.Read('FriendlyName', FriendlyName, nil);
      My_ClassEnumeratorInfo.FriendlyName[Count]:= FriendlyName;
      Moniker.BindToObject(nil, nil, IID_IBaseFilter,
        My_ClassEnumeratorInfo.BaseFilter[Count]);
    end;
  end;
  My_ClassEnumeratorInfo.CountOfBaseFilter:= Count;
end;
//-----------------------------------------------------------------------------<

//-----����� � �������� ���������, ���������� ����������, �� �����--------------->
function My_FindBaseFilterByName(clsidDeviceClass: TGUID; sName: string): IBaseFilter;
var
  Count: Integer;
  My_ClassEnumeratorInfo_Find: TMy_ClassEnumeratorInfo;
begin
  My_ClassEnumerator(clsidDeviceClass, My_ClassEnumeratorInfo_Find);
  for Count:=0 to My_ClassEnumeratorInfo_Find.CountOfBaseFilter do
  begin
    if My_ClassEnumeratorInfo_Find.FriendlyName[Count]=sName then
      Result:= My_ClassEnumeratorInfo_Find.BaseFilter[Count]
    else Result:= nil;
  end;
end;
//-----------------------------------------------------------------------------<

//-----����� ���� �� ����� � ��������� �������--------------------------------->
procedure My_FindPinByName(BaseFilter: IBaseFilter; PinName: string;
  out outPin: IPin);
var
  EnumPins: IEnumPins;
  pInfo: TPinInfo;
  Pin: IPin;

begin
  BaseFilter.EnumPins(EnumPins);
  while EnumPins.Next(1, Pin, nil) = S_OK do
  begin
    Pin.QueryPinInfo(pInfo);
    if pInfo.achName = PinName then
    begin
      outPin:= Pin;
      break;
    end;
  end;

  PinName:= '';
  Pin:= nil;
  EnumPins:= nil;
end;
//-----------------------------------------------------------------------------<

//From DSPack
function SaveGraphFile(pGraph: IGraphBuilder; wszPath: WideString): HRESULT;
const
  wszStreamName: WideString = 'ActiveMovieGraph';
  IID_IPersistStream: TGUID = '{00000109-0000-0000-C000-000000000046}';

var
  Storage: IStorage;
  Stream: IStream;
  Persist: IPersistStream;
begin
  Result := StgCreateDocfile(PWideChar(wszPath), STGM_CREATE or STGM_TRANSACTED or
    STGM_READWRITE or STGM_SHARE_EXCLUSIVE, 0, Storage);
  if FAILED(Result) then Exit;
  Result := Storage.CreateStream(PWideChar(wszStreamName), STGM_WRITE or STGM_CREATE
    or STGM_SHARE_EXCLUSIVE, 0, 0, Stream);
  if FAILED(Result) then Exit;

  pGraph.QueryInterface(IID_IPersistStream, Persist);
  Result := Persist.Save(Stream, True);
  Stream := nil;
  Persist := nil;
  if SUCCEEDED(Result) then Result := Storage.Commit(STGC_DEFAULT);
  Storage := nil;
end;


procedure TForm1.FormDestroy(Sender: TObject);
var
  pfs: _FilterState;
begin
  if MediaControl1<>nil then
  begin
    MediaControl1.GetState(0, pfs);
    if pfs <> State_Stopped then MediaControl1.Stop;
  end;
  IniFile.Free;
  CloseFile(F);
  CoUninitialize(); // ��������������� COM

end;

procedure TForm1.N2Click(Sender: TObject);
begin
  Form2.ShowModal();
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  Form4.ShowModal();
end;

procedure TForm1.N9Click(Sender: TObject);
begin
  Close();
end;

procedure TForm1.CapPreview();
var
  AMVideoProcAmp1: IAMVideoProcAmp;
begin
//������ ��� ����� ��������� ���������� ������� ���������� ��������� ��� �������
  //---�������� ����������� ��� ������� ���������� ������������---------------->
  CoCreateInstance(CLSID_FilterGraph, nil, CLSCTX_INPROC_SERVER,
    IID_IGraphBuilder, GraphBuilder1);
  GraphBuilder1.QueryInterface(IID_IMediaControl, MediaControl1);
  GraphBuilder1.QueryInterface(IID_IVideoWindow, VideoWindow1);
  //---------------------------------------------------------------------------<
////////////////////////////////////////////////////////////////////////////////

///////////////////-----����������� � 1---------------///////////////////------>

  //------��������� �����-������ ������---------------------------------------->
  BaseFilter_VideoCapDevice1.QueryInterface(IID_IAMVideoProcAmp, AMVideoProcAmp1);
  AMVideoProcAmp1.Set_(VideoProcAmp_ColorEnable, 0, VideoProcAmp_Flags_Auto);
  //---------------------------------------------------------------------------<
  //--����� ��������� ���� � ���������� ������������ ��� ��������� �������----->
  My_FindPinByName(BaseFilter_VideoCapDevice1, '������', Pin_CapDev_out);
  if Pin_CapDev_out = nil then
    My_FindPinByName(BaseFilter_VideoCapDevice1, 'Capture', Pin_CapDev_out);
  //---------------------------------------------------------------------------<
  //--������������� ���������� �����, ����� ������ � ���.--��� ���������------->
  Pin_CapDev_out.QueryInterface(IID_IAMStreamConfig, AMStreamConfig);
  AMStreamConfig.GetFormat(ppmt);
  VideoInfoHeader.bmiHeader.biSize:= 320*240*3;
  VideoInfoHeader.bmiHeader.biWidth:= 320;
  VideoInfoHeader.bmiHeader.biHeight:= 240;
  VideoInfoHeader.bmiHeader.biPlanes:= 1;
  VideoInfoHeader.bmiHeader.biCompression:= BI_RGB;
  VideoInfoHeader.AvgTimePerFrame:= Round(1 / 25 * 10000000);
  ppmt.pbFormat:=@VideoInfoHeader;
  ppmt.cbFormat:= SizeOf(TVideoInfoHeader);
  ppmt.subtype:= MEDIASUBTYPE_RGB24;
  ppmt.majortype:= MEDIATYPE_Video;
  ppmt.formattype:= FORMAT_VideoInfo;
  ppmt.bFixedSizeSamples:= True;
  AMStreamConfig.SetFormat(ppmt^);
  //---------------------------------------------------------------------------<
  //----�������� ���� ���������------------------------------------------------>
  GraphBuilder1.AddFilter(BaseFilter_VideoCapDevice1, 'CapDevice');
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_Colour, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_ColorSpace1);
  GraphBuilder1.AddFilter(BaseFilter_ColorSpace1, 'ColorSpace1');
  My_FindPinByName(BaseFilter_ColorSpace1, 'Input', Pin_ColorSpace1_Input_in);
  My_FindPinByName(BaseFilter_ColorSpace1, 'XForm Out', Pin_ColorSpace1_XFormOut_out);
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_SmartTee, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_SmartTee);
  GraphBuilder1.AddFilter(BaseFilter_SmartTee, 'SmartTee');
  My_FindPinByName(BaseFilter_SmartTee, 'Input', Pin_SmartTee_Input_in);
  My_FindPinByName(BaseFilter_SmartTee, 'Preview', Pin_SmartTee_Preview_out);
  My_FindPinByName(BaseFilter_SmartTee, 'Capture', Pin_SmartTee_Capture_out);
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_Colour, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_ColorSpace2);
  GraphBuilder1.AddFilter(BaseFilter_ColorSpace2, 'ColorSpace2');
  My_FindPinByName(BaseFilter_ColorSpace2, 'Input', Pin_ColorSpace2_Input_in);
  My_FindPinByName(BaseFilter_ColorSpace2, 'XForm Out', Pin_ColorSpace2_XFormOut_out);
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_VideoRendererDefault, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_VMRVideoRenderer);
  GraphBuilder1.AddFilter(BaseFilter_VMRVideoRenderer, 'VMRVideoRenderer');
  My_FindPinByName(BaseFilter_VMRVideoRenderer, 'VMR Input0',
    Pin_VideoRenderer_Input_in);
  //---------------------------------------------------------------------------<
  //-----------------���������� ����� ��� ���������---------------------------->
  GraphBuilder1.Connect(Pin_CapDev_out, Pin_ColorSpace1_Input_in);
  GraphBuilder1.Connect(Pin_ColorSpace1_XFormOut_out, Pin_SmartTee_Input_in);
  GraphBuilder1.Connect(Pin_SmartTee_Preview_out, Pin_ColorSpace2_Input_in);
  GraphBuilder1.Connect(Pin_ColorSpace2_XFormOut_out, Pin_VideoRenderer_Input_in);
  //---------------------------------------------------------------------------<
///////////////////-----------------------------------///////////////////------<

  VideoWindow1.put_Owner(GroupBox1.Handle);
  VideoWindow1.put_WindowStyle(WS_CHILD);
  VideoWindow1.SetWindowPosition(9, 25, 320, 240);
  VideoWindow1.put_Visible(True);

  SaveGraphFile(GraphBuilder1, 'PreviewGraph.grf');

  MediaControl1.Run(); //������ ����� ���������

  SpeedButton1.Visible:= False; // ������ "�������� ������"
//  SpeedButton5.Visible:= True; // ������ "��������� ������"
  SpeedButton4.Enabled:= True; // ������ "������ ������"

end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  CapPreview();
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin

  MediaControl1.Stop(); // ������������� ���� �������
  Timer1.Enabled:= False; 
  SpeedButton4.Visible:= True; // ������ "������ ������"
  SpeedButton3.Visible:= False; // ������ "���������� ������"
//  SpeedButton5.Enabled:= True; // ������ "��������� ������"

  //��������� �������� �� �����, ���������� ���� ������� � ���� ���������------>
  GraphBuilder1.RemoveFilter(BaseFilter_VideoCoder);
  GraphBuilder1.RemoveFilter(BaseFilter_AviMux);
  GraphBuilder1.RemoveFilter(BaseFilter_FileWriter);
  //---------------------------------------------------------------------------<

  MediaControl1.Run(); //������ ����� ���������

end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
var
  PathOfCapFile: array[0..MAX_PATH] of PWideChar;

begin
  if BaseFilter_VideoCoder = nil then
  begin
    MessageBox(Handle, PChar('��������������� '+NameOfCoderFromIni+' �� ������'),
      '������', MB_ICONERROR);
  Exit;
  end;

  //--���� ���������� ��������� ����� �� ����� ������, ������� �����
  // ���������� ������������� ������������ ����� ���������
  //-----------------------------------------------------------------------------
  MediaControl1.Stop(); // ������������� ���� ���������

  SpeedButton4.Visible:= False; // ������ "������ ������"
  SpeedButton3.Visible:= True; // ������ "���������� ������"
//  SpeedButton5.Enabled:= False; // ������ "��������� ������"
  //-----------------------------------------------------------------------------

  //----������������� ���������� �����, ����� ������ � ���.--��� ������-------->
  Pin_CapDev_out.QueryInterface(IID_IAMStreamConfig, AMStreamConfig);
  AMStreamConfig.GetFormat(ppmt);
  VideoInfoHeader.bmiHeader.biSize:= 320*240*3;
  VideoInfoHeader.bmiHeader.biWidth:= 320;
  VideoInfoHeader.bmiHeader.biHeight:= 240;
  VideoInfoHeader.bmiHeader.biPlanes:= 1;
  VideoInfoHeader.bmiHeader.biCompression:= BI_RGB;
  VideoInfoHeader.AvgTimePerFrame:= Round(1 / 25 * 10000000);
  ppmt.pbFormat:=@VideoInfoHeader;
  ppmt.cbFormat:= SizeOf(TVideoInfoHeader);
  ppmt.subtype:= MEDIASUBTYPE_RGB24;
  ppmt.majortype:= MEDIATYPE_Video;
  ppmt.formattype:= FORMAT_VideoInfo;
  ppmt.bFixedSizeSamples:= True;
  AMStreamConfig.SetFormat(ppmt^);
  //---------------------------------------------------------------------------<

  //-----�������� ���� ������-------------------------------------------------->
  GraphBuilder1.AddFilter(BaseFilter_VideoCoder, 'VideoCompres');
  My_FindPinByName(BaseFilter_VideoCoder, 'Input', Pin_VideoCompres_Input_in);
  My_FindPinByName(BaseFilter_VideoCoder, 'Output', Pin_VideoCompres_Output_out);
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_AviDest, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_AviMux);
  GraphBuilder1.AddFilter(BaseFilter_AviMux, 'AviMux');
  My_FindPinByName(BaseFilter_AviMux, 'Input 01', Pin_AviMux_Input01_in);
  My_FindPinByName(BaseFilter_AviMux, 'AVI Out', Pin_AviMux_AVIout_out);
  //----------------------------------------------------------------------------
  CoCreateInstance(CLSID_FileWriter, nil, CLSCTX_INPROC_SERVER,
    IID_IBaseFilter, BaseFilter_FileWriter);
  GraphBuilder1.AddFilter(BaseFilter_FileWriter, 'FileWriter');
  BaseFilter_FileWriter.QueryInterface(IID_IFileSinkFilter, FileSinkFilter);
  //----------------------------------------------------------------------------
  StringToWideChar(ExtractFilePath(Application.ExeName)+'������.avi',
    @PathOfCapFile, MAX_PATH);
  //----------------------------------------------------------------------------
  if FileExists(WideCharToString(@PathOfCapFile)) then
    DeleteFile(WideCharToString(@PathOfCapFile));
  FileSinkFilter.SetFileName(@PathOfCapFile, nil);
  My_FindPinByName(BaseFilter_FileWriter, 'in', Pin_FileWriter_Input_in);
  //---------------------------------------------------------------------------<
  //-----------------���������� ����� ��� ������------------------------------->
  GraphBuilder1.Connect(Pin_SmartTee_Capture_out, Pin_VideoCompres_Input_in);
  GraphBuilder1.Connect(Pin_VideoCompres_Output_out, Pin_AviMux_Input01_in);
  GraphBuilder1.Connect(Pin_AviMux_AVIout_out, Pin_FileWriter_Input_in);
  //---------------------------------------------------------------------------<

  BaseFilter_AviMux.QueryInterface(IID_IMediaSeeking, MediaSeeking);
  SaveGraphFile(GraphBuilder1, 'CaptureGraph.grf');
  Timer1.Enabled:= True;
  MediaControl1.Run(); // ������ ����� ������

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Capture: TCapture;
begin
  Capture:=TCapture.Create;
  Capture.GetCapDevices(ComboBox1.Items);

  Capture.Destroy;
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
  MediaControl1.Run;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
const
  MSecInOneDay: Integer = 86400000;
var
  Hour, Min, Sec, MSec: Word;
  pCurrent: Int64;
begin
  MediaSeeking.GetCurrentPosition(pCurrent);
  DecodeTime(2*pCurrent/ 16666.6666/MSecInOneDay, Hour, Min, Sec, MSec);
  StatusBar1.Panels[0].Text:= Format('%d:%d:%d:%d',[ Hour, Min, Sec, MSec]);
end;


procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  Form2.ShowModal();
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  Form3.ShowModal();
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
begin
  Form1.Close();
end;

end.
