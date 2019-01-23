program DSH_Cap_TEST;

uses
  Forms,
  FormMain in 'FormMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
