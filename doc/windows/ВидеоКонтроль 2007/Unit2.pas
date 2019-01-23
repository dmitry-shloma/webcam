unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, IniFiles, DirectShow9, ActiveX, ImgList,
  Unit1, Buttons;

type
  TForm2 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ImageList1: TImageList;
    CheckBox1: TCheckBox;
    ListBox1: TListBox;
    TabSheet3: TTabSheet;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    ComboBox3: TComboBox;
    Button8: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    UpDown1: TUpDown;
    Edit1: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Edit2: TEdit;
    UpDown2: TUpDown;
    Label8: TLabel;
    Edit3: TEdit;
    UpDown3: TUpDown;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure WriteIni();
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  NameOfCam1FromIni, NameOfCam2FromIni, NameOfCoderFromIni: string;
  IniFile: TIniFile;
  My_ClassEnumInfo_CaptureDev,
  My_ClassEnumInfo_CoderVideo: TMy_ClassEnumeratorInfo;
  AMCameraControl1: IAMCameraControl;
  AMVfwCompressDialogs: IAMVfwCompressDialogs;
  SvoystvaCoder_Size: Integer;
  SvoystvaCoder: PChar;
  F: file;
  BaseFilter_VideoCapDevice1, BaseFilter_VideoCapDevice2,
  BaseFilter_VideoCoder: IBaseFilter;

implementation

{$R *.dfm}

procedure TForm2.WriteIni();
begin
  IniFile.WriteString('Видеокамера №1', 'Устройство захвата', ComboBox1.Text);
  IniFile.WriteInteger('Видеокамера №1', 'Увеличение кадра', UpDown1.Position);
  IniFile.WriteInteger('Видеокамера №1', 'Смещение кадра X', UpDown2.Position);
  IniFile.WriteInteger('Видеокамера №1', 'Смещение кадра Y', UpDown3.Position);
//------------------------------------------------------------------------------
  IniFile.WriteString('Видеокодировщик', 'Видеокодировщик', ComboBox3.Text);

end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Form2.Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  WriteIni();
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  WriteIni();
  Form2.Close();
end;

procedure TForm2.Button8Click(Sender: TObject);
var
//  pages: TCAGUID;
//  SpecifyPropertyPages: ISpecifyPropertyPages;
  Count: Integer;
begin
  for Count:= 0 to My_ClassEnumInfo_CoderVideo.CountOfBaseFilter do
  begin
    if My_ClassEnumInfo_CoderVideo.FriendlyName[Count]=
      ComboBox3.Items.Strings[ComboBox3.ItemIndex] then
      begin
        if Succeeded(My_ClassEnumInfo_CoderVideo.BaseFilter[Count].
          QueryInterface(IID_IAMVfwCompressDialogs, AMVfwCompressDialogs)) then
            AMVfwCompressDialogs.ShowDialog(VfwCompressDialog_Config, 0)
{        else if Succeeded(My_ClassEnumInfo_CoderVideo.BaseFilter[Count].
          QueryInterface(IID_ISpecifyPropertyPages, SpecifyPropertyPages)) then
          begin
            SpecifyPropertyPages.GetPages(pages);
            OleCreatePropertyFrame(Handle, 30, 30, nil, 1,
              @My_ClassEnumInfo_CoderVideo.BaseFilter[Count], pages.cElems,
                pages.pElems, 0, 0, nil );
          end}
          else
            MessageBox(Handle, 'Диалог настроек видеокодировщика не доступен',
              'Внимание', MB_ICONEXCLAMATION);
      end;
  end;
  //--Пишем в файл Coder.dat параметры сжатия выбранного видеокодировщика------>
  Rewrite(F, 1);
  if Succeeded(AMVfwCompressDialogs.GetState(nil^, SvoystvaCoder_Size)) then
  begin
    GetMem(SvoystvaCoder, SvoystvaCoder_Size); //Резервируем память
    AMVfwCompressDialogs.GetState(SvoystvaCoder^, SvoystvaCoder_Size);
    BlockWrite(F, SvoystvaCoder^, SvoystvaCoder_Size);
  end;

  //---------------------------------------------------------------------------<

end;

procedure TForm2.CheckBox1Click(Sender: TObject);
begin
  Form2.AlphaBlendValue:= 150;
  if CheckBox1.Checked then Form2.AlphaBlend:= True
    else Form2.AlphaBlend:= False;

end;

procedure TForm2.FormCreate(Sender: TObject);
var
  Count: Integer;
  pMin, pMax, pSteppingDelta, pDefault, pCapsFlags: Integer;

begin
  IniFile:= TIniFile.Create(ExtractFilePath(Application.ExeName)+'Config.ini');
  // Читаем имена устройства захвата из файла настроек------------------------->
  NameOfCam1FromIni:= IniFile.ReadString('Видеокамера №1', 'Устройство захвата', '');
  NameOfCam2FromIni:= IniFile.ReadString('Видеокамера №2', 'Устройство захвата', '');
  NameOfCoderFromIni:= IniFile.ReadString('Видеокодировщик', 'Видеокодировщик', '');
  //---------------------------------------------------------------------------<

  //---Получаем список установленных в системе устройств видеозахвата---------->
  My_ClassEnumerator(CLSID_VideoInputDeviceCategory, My_ClassEnumInfo_CaptureDev);
  if My_ClassEnumInfo_CaptureDev.CountOfBaseFilter =-1 then Exit;
  //---------------------------------------------------------------------------<
  //---Заносим полученный список в ComboBox1 и ComboBox2----------------------->
  for Count:=0 to My_ClassEnumInfo_CaptureDev.CountOfBaseFilter do
  begin
    ComboBox1.Items.Add(My_ClassEnumInfo_CaptureDev.FriendlyName[Count]);

  end;
  //---------------------------------------------------------------------------<
  // Если среди перечисляемых устройств есть то которое выбрано для------------>
  // просмотра/записи то "подсвечиваем его" иначе "пустая строка"
  for Count:=0 to My_ClassEnumInfo_CaptureDev.CountOfBaseFilter do
  begin
    if ComboBox1.Items.Strings[Count]= NameOfCam1FromIni then
      ComboBox1.ItemIndex:=Count;
  end;
  //---------------------------------------------------------------------------<

  BaseFilter_VideoCapDevice1:= My_ClassEnumInfo_CaptureDev.BaseFilter[ComboBox1.ItemIndex];
  BaseFilter_VideoCapDevice1.QueryInterface(IID_IAMCameraControl,
    AMCameraControl1);
  //---------------
  AMCameraControl1.GetRange(CameraControl_Zoom, pMin, pMax, pSteppingDelta,
    pDefault, pCapsFlags);
  UpDown1.Min:= pMin;
  UpDown1.Max:= pMax;
  UpDown1.Increment:= pSteppingDelta;

  AMCameraControl1.GetRange(CameraControl_Pan, pMin, pMax, pSteppingDelta,
    pDefault, pCapsFlags);
  UpDown2.Min:= pMin;
  UpDown2.Max:= pMax;
  UpDown2.Increment:= pSteppingDelta;

  AMCameraControl1.GetRange(CameraControl_Tilt, pMin, pMax, pSteppingDelta,
    pDefault, pCapsFlags);
  UpDown3.Min:= pMin;
  UpDown3.Max:= pMax;
  UpDown3.Increment:= pSteppingDelta;
  //---------------------------------------------------------------------------<
  //-Читаем из файла настроек параметры для первой камеры (увеличение, сдвиг X, Y)
  UpDown1.Position:=IniFile.ReadInteger('Видеокамера №1', 'Увеличение кадра', 0);
  UpDown2.Position:= IniFile.ReadInteger('Видеокамера №1', 'Смещение кадра X', 0);
  UpDown3.Position:= IniFile.ReadInteger('Видеокамера №1', 'Смещение кадра Y', 0);
  //---------------------------------------------------------------------------<
  //---Применяем к видеоизображению прочитанные настройки----------------------->
  AMCameraControl1.Set_(CameraControl_Zoom, UpDown1.Position, CameraControl_Flags_Auto);
  AMCameraControl1.Set_(CameraControl_Pan, UpDown2.Position, CameraControl_Flags_Auto);
  AMCameraControl1.Set_(CameraControl_Tilt, UpDown3.Position, CameraControl_Flags_Auto);
  //---------------------------------------------------------------------------<
  //-Читаем из файла настроек параметры для второй камеры (увеличение, сдвиг X, Y)


  //---------------------------------------------------------------------------<

  //---Получаем список установленных в системе видеокодировщиков--------------->
  My_ClassEnumerator(CLSID_VideoCompressorCategory, My_ClassEnumInfo_CoderVideo);
  //---------------------------------------------------------------------------<
  //---Заносим полученный список в ComboBox3----------------------------------->
  for Count:=0 to My_ClassEnumInfo_CoderVideo.CountOfBaseFilter do
  begin
    ComboBox3.Items.Add(My_ClassEnumInfo_CoderVideo.FriendlyName[Count]);
  end;
  //---------------------------------------------------------------------------<
  // Если среди перечисляемых видеокодировщиков есть то которое выбрано для---->
  // сжатия то "подсвечиваем его" иначе "пустая строка"
  for Count:=0 to My_ClassEnumInfo_CoderVideo.CountOfBaseFilter do
  begin
    if ComboBox3.Items.Strings[Count]= NameOfCoderFromIni then
      ComboBox3.ItemIndex:=Count;
  end;
  //---------------------------------------------------------------------------<

  //---Устанавливаем прочитанные параметры сжатия------------------------------>
  for Count:= 0 to My_ClassEnumInfo_CoderVideo.CountOfBaseFilter do
  begin
    if My_ClassEnumInfo_CoderVideo.FriendlyName[Count]=
        ComboBox3.Items.Strings[ComboBox3.ItemIndex] then
    begin
      BaseFilter_VideoCoder:= My_ClassEnumInfo_CoderVideo.BaseFilter[Count];
      BaseFilter_VideoCoder.QueryInterface(IID_IAMVfwCompressDialogs, AMVfwCompressDialogs);
      AssignFile(F, ExtractFilePath(Application.ExeName)+'Coder.dat');
      Reset(F, 1);
      SvoystvaCoder_Size:= FileSize(F);
      GetMem(SvoystvaCoder, SvoystvaCoder_Size);
      BlockRead(F, SvoystvaCoder^, SvoystvaCoder_Size);
      if Failed(AMVfwCompressDialogs.SetState(SvoystvaCoder,
        SvoystvaCoder_Size)) then
      begin
        MessageBox(Form2.Handle, 'Не удалось применить параметры сжатия',
          'Ошибка', MB_ICONERROR);
      end;
    end;
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  if CheckBox1.Checked then CheckBox1.Checked:=False;
  Form2.Left:= Form1.Left+(Form1.Width-Form2.Width) div 2;
  Form2.Top:= Form1.Top+(Form1.Height-Form2.Height) div 2;
end;

//---------------------------------------------------------------------------<
procedure TForm2.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  if Button=btNext then UpDown1.Position:=UpDown1.Position+ UpDown1.Increment
    else UpDown1.Position:=UpDown1.Position- UpDown1.Increment;
  AMCameraControl1.Set_(CameraControl_Zoom, UpDown1.Position, CameraControl_Flags_Auto);
end;

procedure TForm2.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin
  if Button=btPrev then UpDown2.Position:=UpDown2.Position+ UpDown2.Increment
    else UpDown2.Position:=UpDown2.Position- UpDown2.Increment;
  AMCameraControl1.Set_(CameraControl_Pan, UpDown2.Position, CameraControl_Flags_Auto);
end;

procedure TForm2.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin
  if Button=btNext then UpDown3.Position:=UpDown3.Position+ UpDown3.Increment
    else UpDown3.Position:=UpDown3.Position- UpDown3.Increment;
  AMCameraControl1.Set_(CameraControl_Tilt, UpDown3.Position, CameraControl_Flags_Auto);
end;

end.
