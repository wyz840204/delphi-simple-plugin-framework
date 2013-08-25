unit utDemoPlugIn2;

interface

uses utPlugInInterface, utPlugInObject, utDemoPluginInterface;

const
  IID_IDemoPlugIn2                    = '{33771DF2-18C9-4EFA-8D06-4DAB4FCBAD17}';
  GUID_IDemoPlugIn2:TGUID             = IID_IDemoPlugIn2;

type
  IDemoPlugIn2=interface(IPlugIn)
    [IID_IDemoPlugIn2]
    procedure Calculate;
    procedure SetShow(aShow:IDemoPlugIn1);
  end;

  TDemoPlugIn2Params=class(TPlugInParams)
  protected
    FA:Double;
    FB:Double;
    FC:TObject;
  published
    property A:Double read FA write FA;
    property B:Double read FB write FB;
    property C:TObject read FC write FC;
  end;

  TDemoPlugIn2=class(TPlugIn, IDemoPlugIn2)
  protected
    FShow:IDemoPlugIn1;
    class function GetPlugInParamsClass:TPlugInParamsClass;override;
    procedure SetShow(aShow:IDemoPlugIn1);
  public
    constructor Create(Factory:TPlugInFactory; Name:String);override;
    destructor Destroy;override;
    procedure Calculate;
    function Start:Boolean;override;   //运行插件
    property Show:IDemoPlugIn1 read FShow write SetShow;
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

class function TDemoPlugIn2.GetPlugInParamsClass: TPlugInParamsClass;
begin
  Result:=TDemoPlugIn2Params;
end;

procedure TDemoPlugIn2.Calculate;
begin
  if Assigned(FShow) then
  begin
    FShow.GetParams.SetParamValue('Message', Format('A*B=%f', [TDemoPlugIn2Params(FParams).A*TDemoPlugIn2Params(FParams).B]));
    FShow.ShowMessage;
  end;
end;

procedure TDemoPlugIn2.SetShow(aShow: IDemoPlugIn1);
begin
  FShow:=aShow;
end;

function TDemoPlugIn2.Start: Boolean;
begin
  Calculate;
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


