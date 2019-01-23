unit Unit2;

interface

uses
  Windows,
  Classes,
  Controls,
  Forms,
  UTVideoPlayer;


type
  TForm2 = class(TForm)
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

Uses Unit1;

{$R *.dfm}

procedure TForm2.FormResize(Sender: TObject);
 var r:trect;
begin
 If v.plState=stclosed then exit;
 r:=Form2.GetClientRect;
 v.SetVideoWindowSize(r);

end;

end.
 