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
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SavePlugInManagerToFile(FileName:string);
    procedure LoadPlugInManagerFromFile(FileName:String);
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
begin
  PlugInModuleManager.LoadDLL('prjPlugIn1.Dll');
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create(Format('PlugIn "%s" Factory is not Registed', [GUIDToString(GUID_IDemoPlugIn1)]));
  F1.CreatePlugIn('Test1', P1);
  if Assigned(P1) then
  begin
    P1.GetParams.SetParamValue('Message', 'IDemoPlugIn1.ShowMessage Called:Hello world');
    P1.ShowMessage;
    SavePlugInManagerToFile('D:\PlugIns\Test1.txt');
    ShowMessage(Format('PlugIns are saved in %s, You can Restart this program to load plugins from this file', ['D:\PlugIns\Test1.txt']));
    F1.DestroyPlugIn(P1);
  end;
  Pointer(F1):=nil;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  F1,F2:IPlugInFactory;
  P1:IDemoPlugIn1;
  P2:IDemoPlugIn2;
begin
  PlugInModuleManager.LoadDLL('prjPlugIn1.Dll');
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create(Format('PlugIn "%s" Factory is not Registed', [GUIDToString(GUID_IDemoPlugIn1)]));
  F1.CreatePlugIn('Test1', P1);
  F2:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn2);
  if not Assigned(F2) then raise Exception.Create(Format('PlugIn "%s" Factory is not Registed', [GUIDToString(GUID_IDemoPlugIn2)]));
  F2.CreatePlugIn('Test2', P2);
  if Assigned(P1) then
  begin
    if Assigned(P2) then
    begin
      P2.GetParams.SetParamValue('A', 1000);
      P2.GetParams.SetParamValue('B', 1234);
      P2.GetParams.SetParamValue('Show', P1);

      P2.Start;
      SavePlugInManagerToFile('D:\PlugIns\Test2.txt');
      ShowMessage(Format('PlugIns are saved in %s, You can Restart this program to load plugins from this file', ['D:\PlugIns\Test2.txt']));

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
  F1:IPlugInFactory;
  P1:IDemoPlugIn1;
begin
  LoadPlugInManagerFromFile('D:\PlugIns\Test2.txt');
  F1:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn1);
  if not Assigned(F1) then raise Exception.Create('�������δע��');
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

procedure TForm1.Button4Click(Sender: TObject);
var
  F2:IPlugInFactory;
  P2:IDemoPlugIn2;
begin
  LoadPlugInManagerFromFile('D:\PlugIns\Test2.txt');
  F2:= PlugInModuleManager.GetFactory(GUID_IDemoPlugIn2);
  if not Assigned(F2) then raise Exception.Create('�������δע��');
  F2.GetPlugIn('Test2', P2);
  if Assigned(P2) then
  begin
    P2.DoShow;
    P2.GetParams.SetParamValue('A', 1111);
    P2.Calculate;
    F2.DestroyPlugIn(P2);
  end;
  Pointer(F2):=nil;
end;

procedure TForm1.LoadPlugInManagerFromFile(FileName: String);
var
  S:TStringList;
begin
  S:=TStringList.Create;
  S.LoadFromFile(FileName);

  PlugInModuleManager.FromString(PWideChar(S.Text));
  S.Free;

end;

procedure TForm1.SavePlugInManagerToFile(FileName: string);
var
  S:TStringList;
begin
    S:=TStringList.Create;
    S.Text:=PlugInModuleManager.ToString;
    S.SaveToFile(FileName);
    S.Free;
end;

end.
