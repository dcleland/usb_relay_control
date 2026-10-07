program RelayCtl;

uses
  Vcl.Forms,
  RelayCtlU in 'RelayCtlU.pas' {HidRlyForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(THidRlyForm, HidRlyForm);
  Application.Run;
end.
