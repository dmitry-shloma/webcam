unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, StrUtils, Unit1, Unit2;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    ComboBox1: TComboBox;
    Bevel1: TBevel;
    GroupBox2: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Bevel2: TBevel;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit13: TEdit;
    Button1: TButton;
    Bevel3: TBevel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Bevel4: TBevel;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    Button2: TButton;
    CheckBox1: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.Button1Click(Sender: TObject);
var
  Shablon: PChar;
  hRes: Cardinal;
  F: TextFile;
  Buffer: string;
  Count: Integer;
  label Metka1, Metka2;
begin
  for Count:= 0 to ComboBox2.Items.Count do
  if AnsiCompareText(ComboBox2.Items.Strings[Count], ComboBox2.Text)=0 then
    goto Metka1;
  ComboBox2.Items.Add(ComboBox2.Text);
  IniFile.WriteString('Слесарь', ComboBox2.Text, '');
  Metka1:

  for Count:= 0 to ComboBox3.Items.Count do
  if AnsiCompareText(ComboBox3.Items.Strings[Count], ComboBox3.Text)=0 then
    goto Metka2;
  ComboBox3.Items.Add(ComboBox3.Text);
  IniFile.WriteString('Мастер', ComboBox3.Text, '');
  Metka2:
  
  hRes:= FindResource(0, 'SHABLON', RT_RCDATA);
  if hRes=0 then
  begin
    MessageBox(Handle, 'Не найден шаблон электронного паспорта', 'Ошибка',
      MB_ICONERROR);
    Exit;
  end;
  Shablon:= LockResource(LoadResource(0, hRes));
  AssignFile(F, 'C:\1.rtf');
  Rewrite(F);
  Buffer:=StringReplace(Shablon, '77770', Edit1.Text, []);
  Buffer:=StringReplace(Buffer, '77771', ComboBox1.Text, []);
  Buffer:=StringReplace(Buffer, '77772', Edit13.Text, []);
  Buffer:=StringReplace(Buffer, '77773', Edit10.Text, []);
  Buffer:=StringReplace(Buffer, '77774', Edit11.Text, []);
  Buffer:=StringReplace(Buffer, '77775', ComboBox5.Text, []);
  Buffer:=StringReplace(Buffer, '77776', ComboBox4.Text, []);
  Buffer:=StringReplace(Buffer, '77777', Edit4.Text, []);
  Buffer:=StringReplace(Buffer, '77778', Edit6.Text, []);
  Buffer:=StringReplace(Buffer, '77779', Edit5.Text, []);
  Buffer:=StringReplace(Buffer, '777710', Edit8.Text, []);
  Buffer:=StringReplace(Buffer, '777711', Edit2.Text, []);
  Buffer:=StringReplace(Buffer, '777712', Edit9.Text, []);
  Buffer:=StringReplace(Buffer, '777713', Edit3.Text, []);
  Buffer:=StringReplace(Buffer, '777714', Edit7.Text, []);
  Buffer:=StringReplace(Buffer, '777715', ComboBox2.Text, []);
  Buffer:=StringReplace(Buffer, '777716', ComboBox3.Text, []);
  Write(F, Buffer);
  CloseFile(F);

end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  Form3.Close();
end;

procedure TForm3.CheckBox1Click(Sender: TObject);
begin
  Form3.AlphaBlendValue:= 150;
  if CheckBox1.Checked then Form3.AlphaBlend:= True
    else Form3.AlphaBlend:= False;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Form3.Left:= Form1.Left+(Form1.Width-Form3.Width) div 2;
  Form3.Top:= Form1.Top+(Form1.Height-Form3.Height) div 2;

  Edit1.Text:='';
  ComboBox1.ItemIndex:=0;
  Edit13.Text:='';
  Edit10.Text:='';
  Edit11.Text:='';
  ComboBox5.ItemIndex:=0;
  ComboBox4.ItemIndex:=0;
  Edit4.Text:='';
  Edit6.Text:='';
  Edit5.Text:='';
  Edit8.Text:='';
  Edit2.Text:='';
  Edit9.Text:='';
  Edit3.Text:='';
  Edit7.Text:='';
  ComboBox2.Text:='';
  ComboBox3.Text:='';

  IniFile.ReadSection('Слесарь', ComboBox2.Items);
  IniFile.ReadSection('Мастер', ComboBox3.Items);  
end;

end.
