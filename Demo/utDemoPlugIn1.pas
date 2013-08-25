unit utDemoPlugIn1;

interface

uses utPlugInInterface, utPlugInObject, utDemoPlugInInterface;

type
  TDemoPlugIn1Params=class(TPlugInParams)
  protected
    FMessage:String;
  published
    property Message:String read FMessage write FMessage;
  end;

  TDemoPlugIn1=class(TPlugIn, IDemoPlugIn1)
  protected
    class function GetPlugInParamsClass:TPlugInParamsClass;override;
  public
    constructor Create(Factory:TPlugInFactory; Name:String);override;
    destructor Destroy;override;
    procedure ShowMessage;
    function Start:Boolean;override;   //运行插件
  end;

  TDemoPlugInFactory1=class(TPlugInFactory)
  protected
    class function PlugInIID:TGUID;override;
    class function GetPlugInClass:TPlugInClass;override;
  public
    function FactoryName:PWideChar;override;
    function PlugInDescription:PWideChar;override;
  end;



implementation

uses Vcl.Dialogs, SuperObject;

{ TDemoPlugIn1 }

constructor TDemoPlugIn1.Create(Factory: TPlugInFactory; Name: String);
begin
  inherited;

end;

destructor TDemoPlugIn1.Destroy;
begin

  inherited;
end;

class function TDemoPlugIn1.GetPlugInParamsClass: TPlugInParamsClass;
begin
  Result:=TDemoPlugIn1Params;
end;

procedure TDemoPlugIn1.ShowMessage;
begin
  Vcl.Dialogs.ShowMessage(TDemoPlugIn1Params(FParams).FMessage);
end;

function TDemoPlugIn1.Start: Boolean;
begin
  ShowMessage;
end;

{ TDemoPlugInFactory1 }

function TDemoPlugInFactory1.FactoryName: PWideChar;
begin
  Result:=PWideChar('消息对话框工厂');
end;

class function TDemoPlugInFactory1.GetPlugInClass: TPlugInClass;
begin
  Result:=TDemoPlugIn1;
end;

function TDemoPlugInFactory1.PlugInDescription: PWideChar;
begin
  Result:=PWideChar('产生消息对话框');
end;

class function TDemoPlugInFactory1.PlugInIID: TGUID;
begin
  Result:=GUID_IDemoPlugIn1;
end;

var
  F:TDemoPlugInFactory1;

initialization
  TPlugInModule.GetInstance.SetInfo('Hexi', 0, '0.1');
  F:=TDemoPlugInFactory1.Create;
  TPlugInModule.GetInstance.RegistPlugInFactory(F);
finalization

end.

