unit utDemoPlugIn2;

interface

uses utPlugInInterface, utPlugInObject, utDemoPluginInterface;

type

  TDemoPlugIn2Params=class(TPlugInParams)
  protected
    FA:Double;
    FB:Double;
    FShow:IDemoPlugIn1;
  published
    property A:Double read FA write FA;
    property B:Double read FB write FB;
    property Show:IDemoPlugIn1 read FShow write FShow;
  end;

  TDemoPlugIn2=class(TPlugIn, IDemoPlugIn2)
  protected
    class function GetPlugInParamsClass:TPlugInParamsClass;override;
  public
    constructor Create(Factory:TPlugInFactory; Name:String);override;
    destructor Destroy;override;
    procedure Calculate;
    procedure DoShow;

    function Start:Boolean;override;   //运行插件
    function GetPlugInIID:TGUID;override;
  end;

  TDemoPlugInFactory2=class(TPlugInFactory)
  protected
    class function PlugInIID:TGUID;override;
    class function GetPlugInClass:TPlugInClass;override;
  public
    function FactoryName:PWideChar;override;
    function PlugInDescription:PWideChar;override;
  end;



implementation

uses Vcl.Dialogs, SysUtils;

{ TDemoPlugIn2 }

constructor TDemoPlugIn2.Create(Factory: TPlugInFactory; Name: String);
begin
  inherited;

end;

destructor TDemoPlugIn2.Destroy;
begin

  inherited;
end;

procedure TDemoPlugIn2.DoShow;
begin
  with TDemoPlugIn2Params(FParams) do
  if Assigned(FShow) then
  begin
    FShow.ShowMessage;
  end;
end;

function TDemoPlugIn2.GetPlugInIID: TGUID;
begin
  Result:=GUID_IDemoPlugIn2;
end;

class function TDemoPlugIn2.GetPlugInParamsClass: TPlugInParamsClass;
begin
  Result:=TDemoPlugIn2Params;
end;

procedure TDemoPlugIn2.Calculate;
begin
  with TDemoPlugIn2Params(FParams) do
  if Assigned(FShow) then
  begin
    FShow.GetParams.SetParamValue('Message', Format('A=%f'#$0D#$0A'B=%f'#$0D#$0A'A*B=%f', [A, B, A*B]));
  end;
  DoShow;
end;

function TDemoPlugIn2.Start: Boolean;
begin
  Calculate;
  Result:=True;
end;

{ TDemoPlugInFactory2 }

function TDemoPlugInFactory2.FactoryName: PWideChar;
begin
  Result:=PWideChar('加法计算插件工厂');
end;

class function TDemoPlugInFactory2.GetPlugInClass: TPlugInClass;
begin
  Result:=TDemoPlugIn2;
end;

function TDemoPlugInFactory2.PlugInDescription: PWideChar;
begin
  Result:=PWideChar('计算A+B的值');
end;

class function TDemoPlugInFactory2.PlugInIID: TGUID;
begin
  Result:=GUID_IDemoPlugIn2;
end;

var
  F:TDemoPlugInFactory2;

initialization
  TPlugInModule.GetInstance.SetInfo('Hexi', 0, '0.1');
  F:=TDemoPlugInFactory2.Create;
  TPlugInModule.GetInstance.RegistPlugInFactory(F);
finalization

end.


