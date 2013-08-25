program prjPlugInDemo;

uses
  Vcl.Forms,
  utFormMain in 'utFormMain.pas' {Form1},
  utPlugInInterface in '..\Include\utPlugInInterface.pas',
  utPlugInManagerDLL in '..\Include\utPlugInManagerDLL.pas',
  utDemoPlugInInterface in 'utDemoPlugInInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
