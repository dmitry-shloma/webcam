UNIT FormMain;

{******************************************************************************}
{**  ������������ ������ TdshCaptureManager                                  **}
{**  �����: ������ ������ �����������                                        **}
{******************************************************************************}

{**} INTERFACE {***************************************************************}

{**} USES {********************************************************************}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DirectShow9, ActiveX, ComObj, ExtCtrls, StdCtrls,
  UdxCaptureManager;

{**} TYPE {********************************************************************}
  TMainForm = class(TForm)
    panelVideo: TPanel;
    labelVideo: TLabel;
    labelAudio: TLabel;
    labelVideoCompressor: TLabel;
    labelAudioCompressor: TLabel;
    listBoxVideo: TListBox;
    listBoxVideoCompressor: TListBox;
    listBoxAudio: TListBox;
    listBoxAudioCompressor: TListBox;
    panelRecord: TPanel;
    editFileName: TEdit;
    checkBoxPreview: TCheckBox;
    buttonVideoProperties: TButton;
    buttonVideoCompressorProperties: TButton;
    buttonAudioProperties: TButton;
    buttonAudioCompressorProperties: TButton;
    buttonVideoPinProperties: TButton;
    labelFileName: TLabel;
    buttonStartCapture: TButton;
    buttonStopCapture: TButton;
    saveDialogMain: TSaveDialog;
    buttonFileName: TButton;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure buttonStartCaptureClick(Sender: TObject);
    procedure buttonStopCaptureClick(Sender: TObject);
    procedure listBoxVideoClick(Sender: TObject);
    procedure listBoxVideoCompressorClick(Sender: TObject);
    procedure listBoxAudioClick(Sender: TObject);
    procedure listBoxAudioCompressorClick(Sender: TObject);
    procedure checkBoxPreviewClick(Sender: TObject);
    procedure buttonVideoPropertiesClick(Sender: TObject);
    procedure buttonVideoCompressorPropertiesClick(Sender: TObject);
    procedure buttonAudioPropertiesClick(Sender: TObject);
    procedure buttonAudioCompressorPropertiesClick(Sender: TObject);
    procedure buttonVideoPinPropertiesClick(Sender: TObject);
    procedure buttonFileNameClick(Sender: TObject);
  PRIVATE
    FRefreshing: boolean;
    
  PUBLIC

  END;

{**} VAR {*********************************************************************}
  MainForm: TMainForm;
  CaptureManager: TdxCaptureManager;

{**} IMPLEMENTATION {**********************************************************}

{$R *.dfm}

{******************************************************************************}
{** �������� � ������������� ������� CaptureManager                          **}
{******************************************************************************}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // ���������� ���� ����������
  FRefreshing := TRUE;

  try
    // ������� ������ CaptureManager
    CaptureManager := TdxCaptureManager.Create(
      panelVideo.Handle,
      panelVideo.ClientRect);

    listBoxVideo.Items.Add('�����������');
    listBoxVideoCompressor.Items.Add('�������c����');
    listBoxAudio.Items.Add('�����������');
    listBoxAudioCompressor.Items.Add('�����������');

    // ��������� ������ ����� � ��������������
    with CaptureManager do
    begin
      EnumVideoCaptureDevices(listBoxVideo.Items);
      EnumVideoCompressDevices(listBoxVideoCompressor.Items);
      EnumAudioCaptureDevices(listBoxAudio.Items);
      EnumAudioCompressDevices(listBoxAudioCompressor.Items);
    end;

    // ���� � ������� ������������ ���������� ������� �����������,
    // ��� ������������� ���� ����� �� ������ �� ���
    if listBoxVideo.Count > 1 then
      listBoxVideo.ItemIndex := 1
    else
      listBoxVideo.ItemIndex := 0;
    listBoxVideoClick(NIL);

    // ���������� ������ ����� ��-��������� �����������
    listBoxVideoCompressor.ItemIndex := 0;
    listBoxVideoCompressorClick(NIL);

    // ���� � ������� ������������ ���������� ������� �����,
    // ��� ������������� ���� ����� �� ������ �� ���
    if listBoxAudio.Count > 1 then
      listBoxAudio.ItemIndex := 1
    else
      listBoxAudio.ItemIndex := 0;
    listBoxAudioClick(NIL);

    // ���������� ������ ����� ��-��������� �����������
    listBoxAudioCompressor.ItemIndex := 0;
    listBoxAudioCompressorClick(NIL);

    // ������ ���� ��������
    CaptureManager.ConstructGraph;
    
  finally

    FRefreshing := FALSE;
  end;
end;

{******************************************************************************}
{** �������� ������� CaptureManager                                          **}
{******************************************************************************}
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if CaptureManager <> NIL then
     FreeAndNil(CaptureManager);
end;

{******************************************************************************}
{** �������� ������                                                          **}
{******************************************************************************}
procedure TMainForm.buttonStartCaptureClick(Sender: TObject);
begin
  with CaptureManager do
  begin
    // ������ ��� AVI �����
    CaptureFileName := editFileName.Text;

    // �������� ������
    StartCapture;
  end;

  // ������������� ������� ���� ������-����������
  panelRecord.Color := clRed;
end;

{******************************************************************************}
{** ������������� ������                                                     **}
{******************************************************************************}
procedure TMainForm.buttonStopCaptureClick(Sender: TObject);
begin
  // ��������������� ���� ������-����������
  panelRecord.Color := clBtnFace;

  // ������������� ������
  CaptureManager.StopCapture;
end;

{******************************************************************************}
{** ����� ���������� ������ � �����                                          **}
{******************************************************************************}
procedure TMainForm.listBoxVideoClick(Sender: TObject);
begin
  // ������ ��� ����������
  CaptureManager.VideoCaptureDeviceName :=
    listBoxVideo.Items.Strings[listBoxVideo.ItemIndex];

  // ������������� ���� ��������
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** ����� ���������� ������ �����                                            **}
{******************************************************************************}
procedure TMainForm.listBoxVideoCompressorClick(Sender: TObject);
begin
  // ������ ��� ����������
  CaptureManager.VideoCompressDeviceName :=
    listBoxVideoCompressor.Items.Strings[listBoxVideoCompressor.ItemIndex];

  // ������������� ���� ��������
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** ����� ���������� ������ �� ������                                        **}
{******************************************************************************}
procedure TMainForm.listBoxAudioClick(Sender: TObject);
begin
  // ������ ��� ����������
  CaptureManager.AudioCaptureDeviceName :=
    listBoxAudio.Items.Strings[listBoxAudio.ItemIndex];

  // ������������� ���� ��������
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** ����� ���������� ������ �����                                            **}
{******************************************************************************}
procedure TMainForm.listBoxAudioCompressorClick(Sender: TObject);
begin
  // ������ ��� ����������
  CaptureManager.AudioCompressDeviceName :=
    listBoxAudioCompressor.Items.Strings[listBoxAudioCompressor.ItemIndex];

  // ������������� ���� ��������
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** ���������� ������� ���������������� ���������                            **}
{******************************************************************************}
procedure TMainForm.checkBoxPreviewClick(Sender: TObject);
begin
  CaptureManager.Preview := checkBoxPreview.Checked;
end;

{******************************************************************************}
{** ����� �������� ������� ���������� ������ � �����                         **}
{******************************************************************************}
procedure TMainForm.buttonVideoPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCaptureDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoCaptureDeviceProperty');
  end;
end;

{******************************************************************************}
{** ����� �������� ������� ���������� ������ �����                           **}
{******************************************************************************}
procedure TMainForm.buttonVideoCompressorPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCompressDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoCompressDevicePropertys');
  end;
end;

{******************************************************************************}
{** ����� �������� ������� ���������� ������ �� ������                       **}
{******************************************************************************}
procedure TMainForm.buttonAudioPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayAudioCaptureDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayAudioCaptureDeviceProperty');
  end;
end;

{******************************************************************************}
{** ����� �������� ������� ���������� ������ �����                           **}
{******************************************************************************}
procedure TMainForm.buttonAudioCompressorPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayAudioCompressDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayAudioCompressDeviceProperty');
  end;
end;

{******************************************************************************}
{** ����� �������� ������� �������� ������ �����                             **}
{******************************************************************************}
procedure TMainForm.buttonVideoPinPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCapturePinPropertyPage(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoPropertyPage');
  end;
end;

{******************************************************************************}
{** ����� ����� ������������ �����                                           **}
{******************************************************************************}
procedure TMainForm.buttonFileNameClick(Sender: TObject);
begin
  if saveDialogMain.Execute then
  begin
    editFileName.Text := saveDialogMain.FileName;
  end;
end;

END.
