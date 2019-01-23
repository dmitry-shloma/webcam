unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi;

type
  TForm4 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel2: TBevel;
    Image1: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Bevel3: TBevel;
    Label12: TLabel;
    Label13: TLabel;
    Timer1: TTimer;
    Image2: TImage;
    Image3: TImage;
    Image5: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  Autors: string = '*****'+'  Николаев В. А., Клюка В. П., Подоляк С. И., '+
    'Кучеренко В. К., Шлома Д. Н.  ';

var
  Form4: TForm4;
  CountForScroll: Integer = 4; // Счетчик для "авторской" "бегущей строки" 

implementation

{$R *.dfm}

function GetOSVersion(): string;
var lpVersionInfo: TOSVERSIONINFO;
    OSVersion,
    OSVersionAdd,
    OSVersionBuild,
    OSAllInfo: string;
begin
  lpVersionInfo.dwOSVersionInfOSize:= sizeof(TOSVERSIONINFO);
  GetVersionEx(lpVersionInfo);

  case lpVersionInfo.dwPlatformId of
    VER_PLATFORM_WIN32_NT:
      begin
      if (lpVersionInfo.dwMajorVersion = 5) and
         (lpVersionInfo.dwMinorVersion = 2) then
           OSVersion:= 'Microsoft Windows Server 2003';
      if (lpVersionInfo.dwMajorVersion = 5) and
         (lpVersionInfo.dwMinorVersion = 1) then
         OSVersion:= 'Microsoft Windows XP';
      if (lpVersionInfo.dwMajorVersion = 5) and
         (lpVersionInfo.dwMinorVersion = 0) then
         OSVersion:= 'Microsoft Windows 2000';
      if lpVersionInfo.dwMajorVersion <= 4 then
         OSVersion:= 'Microsoft Windows NT';
      OSVersionAdd:= lpVersionInfo.szCSDVersion;
      OSVersionBuild:= ' (сборка ' +
        IntTOStr(lpVersionInfo.dwBuildNumber) + ')';
      end;

    VER_PLATFORM_WIN32_WINDOWS:
      begin
      if (lpVersionInfo.dwMajorVersion = 4) and
         (lpVersionInfo.dwMinorVersion = 0) then
          begin
          OSVersion:= 'Microsoft Windows 95';
            if (lpVersionInfo.szCSDVersion[1]='C') or
            (lpVersionInfo.szCSDVersion[1]='B') then
             OSVersionAdd:= 'OSR2';
          end;
      if (lpVersionInfo.dwMajorVersion = 4) and
         (lpVersionInfo.dwMinorVersion = 10) then
          begin
            OSVersion:= 'Microsoft Windows 98';
            if lpVersionInfo.szCSDVersion[1] = 'A' then
              OSVersionAdd:= 'SE';
          end;
      if (lpVersionInfo.dwMajorVersion = 4) and
         (lpVersionInfo.dwMinorVersion = 90) then
         OSVersion:= 'Microsoft Windows Millennium Edition';
      end;
    VER_PLATFORM_WIN32s:
      OSVersion:= 'Microsoft Win32s';
  end;
  if (OSVersionAdd ='') and (OSVersionBuild='') then
    OSAllInfo:= OSVersion
  else
    OSAllInfo:= OSVersion + ', ' + OSVersionAdd + OSVersionBuild;
  Result:= OSAllInfo;
end;


procedure TForm4.Button1Click(Sender: TObject);
begin
  Close();
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Label7.Caption:= GetOSVersion();
  Label13.Caption:= Autors;
end;

procedure TForm4.FormHide(Sender: TObject);
begin
  Timer1.Enabled:= False;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Timer1.Enabled:= True;
end;

procedure TForm4.Label3Click(Sender: TObject);
begin
  ShellExecute(Form4.Handle, 'Open',
    'www.omgups.ru', nil, nil, SW_SHOWDEFAULT);

end;

procedure TForm4.Label4Click(Sender: TObject);
begin
  ShellExecute(Form4.Handle, 'Open',
    'mailto: Dim1983@Inbox.ru?'+
    'subject=Спасибо за отлично сделанную программу :)', nil, nil, SW_SHOWDEFAULT);

end;

procedure TForm4.Label7Click(Sender: TObject);
begin
  if Label7.Caption<>'Не определено' then ShellExecute(Form4.Handle, 'Open',
    'rundll32.exe', 'shell32.dll,Control_RunDLL sysdm.cpl', nil, SW_SHOWDEFAULT);
end;

procedure TForm4.Timer1Timer(Sender: TObject);
begin
  Label13.Caption:= Copy(Autors, CountForScroll+1,
    Length(Autors))+Copy(Autors, 1, CountForScroll);
  if CountForScroll=Length(Autors) then CountForScroll:=0 else Inc(CountForScroll);

end;

end.
