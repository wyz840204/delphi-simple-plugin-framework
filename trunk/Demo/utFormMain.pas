unit utFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses utPlugInInterface, utPlugInManagerDLL, utDemoPlugInInterface;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  F1:IPlugInFactory;
  P1:IDemoPlugIn1;
  S:TStringList;
begin
  PlugInModuleManager.LoadDLL('prjPlugIn1.Dll');
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create('插件工厂未注册');
  F1.CreatePlugIn('Test1', P1);
  if Assigned(P1) then
  begin
    P1.GetParams.SetParamValue('Message', 'Hello world');
    P1.ShowMessage;
    S:=TStringList.Create;
    S.Text:=PlugInModuleManager.ToString;
    S.SaveToFile('D:\PlugIns\Test.txt');
    S.Free;

    F1.DestroyPlugIn(P1);
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  F1,F2:IPlugInFactory;
  P1:IDemoPlugIn1;
  P2:IDemoPlugIn2;
begin
  PlugInModuleManager.LoadDLL('prjPlugIn1.Dll');
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create('插件工厂未注册');
  F1.CreatePlugIn('Test1', P1);
  F2:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn2);
  if not Assigned(F2) then raise Exception.Create('插件工厂未注册');
  F2.CreatePlugIn('Test1', P2);
  if Assigned(P1) then
  begin
    if Assigned(P2) then
    begin
      P2.GetParams.SetParamValue('A', 1000);
      P2.GetParams.SetParamValue('B', 1234);
      P2.SetShow(P1);
      P2.Start;
      F2.DestroyPlugIn(P2);
    end;
    F1.DestroyPlugIn(P1);
  end;
  Pointer(F1):=nil;
  Pointer(F2):=nil;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  S:TStringList;
  F1,F2:IPlugInFactory;
  P1:IDemoPlugIn1;
begin
  S:=TStringList.Create;
  S.LoadFromFile('D:\PlugIns\Test.txt');

  PlugInModuleManager.FromString(PWideChar(S.Text));
  S.Free;
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create('插件工厂未注册');
  F1.GetPlugIn('Test1', P1);
  if Assigned(P1) then
  begin
    P1.ShowMessage;
    P1.GetParams.SetParamValue('Message', ' world Hello');
    P1.ShowMessage;
    F1.DestroyPlugIn(P1);
  end;
  Pointer(F1):=nil;
end;

end.
