unit Unit1;

interface

uses
  Windows, Classes,
  Controls, Forms,
  StdCtrls, Buttons,
  UTVideoPlayer, Dialogs;


type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  V : TVideoRenderer;


implementation

uses Unit2;

{$R *.dfm}




procedure TForm1.BitBtn1Click(Sender: TObject);
begin
 If opendialog1.Execute then
  begin
   Form2.show;
   v.OpenFile(opendialog1.FileName,Form1.Handle,Form2.Handle);
   v.Play;
  end; 
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 v:=TVideoRenderer.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 v.Free;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
 Form2.show;
  v.Stop;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
 Form2.show;
 v.Pause;
end;

end.
