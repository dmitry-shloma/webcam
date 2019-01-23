UNIT FormMain;

{******************************************************************************}
{**  Тестирование класса TdshCaptureManager                                  **}
{**  Автор: Есенин Сергей Анатольевич                                        **}
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
{** Создание и инициализация объекта CaptureManager                          **}
{******************************************************************************}
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Выставляем флаг обновления
  FRefreshing := TRUE;

  try
    // Создаем объект CaptureManager
    CaptureManager := TdxCaptureManager.Create(
      panelVideo.Handle,
      panelVideo.ClientRect);

    listBoxVideo.Items.Add('Отсутствует');
    listBoxVideoCompressor.Items.Add('Отсутстcвует');
    listBoxAudio.Items.Add('Отсутствует');
    listBoxAudioCompressor.Items.Add('Отсутствует');

    // Заполняем списки аудио и видеоустройств
    with CaptureManager do
    begin
      EnumVideoCaptureDevices(listBoxVideo.Items);
      EnumVideoCompressDevices(listBoxVideoCompressor.Items);
      EnumAudioCaptureDevices(listBoxAudio.Items);
      EnumAudioCompressDevices(listBoxAudioCompressor.Items);
    end;

    // Если в системе присутствуют устройства захвата изображения,
    // тот останавливаем свой выбор на первом из них
    if listBoxVideo.Count > 1 then
      listBoxVideo.ItemIndex := 1
    else
      listBoxVideo.ItemIndex := 0;
    listBoxVideoClick(NIL);

    // Устройство сжатия видео по-умолчанию отсутствует
    listBoxVideoCompressor.ItemIndex := 0;
    listBoxVideoCompressorClick(NIL);

    // Если в системе присутствуют устройства захвата аудио,
    // тот останавливаем свой выбор на первом из них
    if listBoxAudio.Count > 1 then
      listBoxAudio.ItemIndex := 1
    else
      listBoxAudio.ItemIndex := 0;
    listBoxAudioClick(NIL);

    // Устройство сжатия аудио по-умолчанию отсутствует
    listBoxAudioCompressor.ItemIndex := 0;
    listBoxAudioCompressorClick(NIL);

    // Строим граф фильтров
    CaptureManager.ConstructGraph;
    
  finally

    FRefreshing := FALSE;
  end;
end;

{******************************************************************************}
{** Удаление объекта CaptureManager                                          **}
{******************************************************************************}
procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if CaptureManager <> NIL then
     FreeAndNil(CaptureManager);
end;

{******************************************************************************}
{** Начинаем запись                                                          **}
{******************************************************************************}
procedure TMainForm.buttonStartCaptureClick(Sender: TObject);
begin
  with CaptureManager do
  begin
    // Задаем имя AVI файла
    CaptureFileName := editFileName.Text;

    // Начинаем запись
    StartCapture;
  end;

  // Устанавливаем красный цвет панели-индикатора
  panelRecord.Color := clRed;
end;

{******************************************************************************}
{** Останавливаем запись                                                     **}
{******************************************************************************}
procedure TMainForm.buttonStopCaptureClick(Sender: TObject);
begin
  // Восстанавливаем цвет панели-индикатора
  panelRecord.Color := clBtnFace;

  // Останавливаем запись
  CaptureManager.StopCapture;
end;

{******************************************************************************}
{** Выбор устройства работы с видео                                          **}
{******************************************************************************}
procedure TMainForm.listBoxVideoClick(Sender: TObject);
begin
  // Задаем имя устройства
  CaptureManager.VideoCaptureDeviceName :=
    listBoxVideo.Items.Strings[listBoxVideo.ItemIndex];

  // Перестраиваем граф фильтров
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** Выбор устройства сжатия видео                                            **}
{******************************************************************************}
procedure TMainForm.listBoxVideoCompressorClick(Sender: TObject);
begin
  // Задаем имя устройства
  CaptureManager.VideoCompressDeviceName :=
    listBoxVideoCompressor.Items.Strings[listBoxVideoCompressor.ItemIndex];

  // Перестраиваем граф фильтров
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** Выбор устройства работы со звуком                                        **}
{******************************************************************************}
procedure TMainForm.listBoxAudioClick(Sender: TObject);
begin
  // Задаем имя устройства
  CaptureManager.AudioCaptureDeviceName :=
    listBoxAudio.Items.Strings[listBoxAudio.ItemIndex];

  // Перестраиваем граф фильтров
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** Выбор устройства сжатия звука                                            **}
{******************************************************************************}
procedure TMainForm.listBoxAudioCompressorClick(Sender: TObject);
begin
  // Задаем имя устройства
  CaptureManager.AudioCompressDeviceName :=
    listBoxAudioCompressor.Items.Strings[listBoxAudioCompressor.ItemIndex];

  // Перестраиваем граф фильтров
  if not FRefreshing then
     CaptureManager.ConstructGraph;
end;

{******************************************************************************}
{** Управление режимом предварительного просмотра                            **}
{******************************************************************************}
procedure TMainForm.checkBoxPreviewClick(Sender: TObject);
begin
  CaptureManager.Preview := checkBoxPreview.Checked;
end;

{******************************************************************************}
{** Вызов страницы свойств устройства работы с видео                         **}
{******************************************************************************}
procedure TMainForm.buttonVideoPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCaptureDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoCaptureDeviceProperty');
  end;
end;

{******************************************************************************}
{** Вызов страницы свойств устройства сжатия видео                           **}
{******************************************************************************}
procedure TMainForm.buttonVideoCompressorPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCompressDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoCompressDevicePropertys');
  end;
end;

{******************************************************************************}
{** Вызов страницы свойств устройства работы со звуком                       **}
{******************************************************************************}
procedure TMainForm.buttonAudioPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayAudioCaptureDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayAudioCaptureDeviceProperty');
  end;
end;

{******************************************************************************}
{** Вызов страницы свойств устройства сжатия звука                           **}
{******************************************************************************}
procedure TMainForm.buttonAudioCompressorPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayAudioCompressDeviceProperty(Handle)) then
  begin
    ShowMessage('Error in call: DisplayAudioCompressDeviceProperty');
  end;
end;

{******************************************************************************}
{** Вызов страницы свойств контакта потока видео                             **}
{******************************************************************************}
procedure TMainForm.buttonVideoPinPropertiesClick(Sender: TObject);
begin
  if FAILED(CaptureManager.DisplayVideoCapturePinPropertyPage(Handle)) then
  begin
    ShowMessage('Error in call: DisplayVideoPropertyPage');
  end;
end;

{******************************************************************************}
{** Выбор имени сохраняемого файла                                           **}
{******************************************************************************}
procedure TMainForm.buttonFileNameClick(Sender: TObject);
begin
  if saveDialogMain.Execute then
  begin
    editFileName.Text := saveDialogMain.FileName;
  end;
end;

END.
