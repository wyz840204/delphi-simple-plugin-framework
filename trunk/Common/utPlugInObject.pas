unit utPlugInObject;

interface

  uses utPlugInInterface, System.Classes, System.Generics.Collections, SuperObject,
    System.Rtti, DBXJSON, DBXJSONReflect;

  type

    TIntObject = class(TObject, IInterface)
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
    end;

    TPlugIn      = class;
    TPlugInClass = class of TPlugIn;

    // 插件工厂，每个工厂仅生产一种插件产品
    TPlugInFactory = class(TIntObject, IPlugInFactory)
    protected
      FNamedList: TStringList; // 命名了的插件产品列表
      FUnNamedList: TList;     // 未命名的插件产品列表（不可持久性）
    private
    protected
      class function PlugInIID: TGUID; virtual;
      class function GetPlugInClass: TPlugInClass; virtual;
      procedure ClearNamed;
    public
      constructor Create;
      destructor Destroy; override;
      function FactoryName: PWideChar; virtual;
      function PlugInDescription: PWideChar; virtual;
      function PlugIn_IID: TGUID;

      function CreatePlugIn(const PlugName: PWideChar; out Obj): Boolean; virtual;
      procedure DestroyPlugIn(var Obj); virtual;

      function ToString: PWideChar; virtual;           // 保存工厂内所有插件参数信息
      procedure FromString(Value: PWideChar); virtual; // 读取工厂内的插件信息,并生成插件
      procedure GetPlugIn(const PlugName:PWideChar; var Obj);
    end;

    // {$M+}
    TPlugInParams = class(TIntObject, IInterface, IPlugInParams)
    private
      function BuildSO: ISuperObject;
    protected
    public
      constructor Create;
      destructor Destroy; override;
      function ToString: PWideChar; virtual;                     // 参数保存为字符串
      function FromString(Value: PWideChar): PWideChar; virtual; // 设定参数，返回错误信息
      function GetParamCount: Int32;
      function GetParamName(Index: Int32): PWideChar; virtual;
      function GetParamValue(Name: PWideChar): OleVariant; virtual;
      procedure SetParamValue(Name: PWideChar; Value: OleVariant); virtual;
      function GetPlugInIID: TGUID;
    end;
    // {$M-}

    TPlugInParamsClass = class of TPlugInParams;

    TPlugIn = class(TIntObject, IPlugIn)
    protected
      FName: String;
      FFactory: TPlugInFactory;
      FParams: TPlugInParams;
      class function GetPlugInParamsClass: TPlugInParamsClass; virtual;
    public
      constructor Create(Factory: TPlugInFactory; Name: String); virtual;
      destructor Destroy; override;
      function GetName: PWideChar;       // 读取插件实例名称
      function GetParams: IPlugInParams; // 读取插件参数接口
      function Start: Boolean; virtual;  // 运行插件
      procedure Stop; virtual;           // 停止插件
    end;

    // 每个提供插件的DLL,BPL包含一个TPlugInModule，管理多个工厂，即每个DLL,BPL可以有多个工厂，生产多种插件
    TPlugInModule = class(TIntObject, IPlugInModule)
    protected
      FAuthor: String;
      FDate: TDateTime;
      FVersion: String;
      FFactory: TStringList;
      class var FInstance: TPlugInModule;
    protected
      procedure Clear;
      procedure PlugInClear;
    public
      constructor Create;
      destructor Destroy; override;
      procedure RegistPlugInFactory(Factory: TPlugInFactory);

      function ToString: PWideChar; virtual;
      procedure FromString(Value: PWideChar); virtual;

      function Author: PWideChar;
      function Version: PWideChar;
      function ReleaseDate: TDateTime;

      function GetFactoryCount: Int32;
      function GetFactory(Index: Int32):IPlugInFactory;
      function GetFactoryByname(Name: PWideChar):IPlugInFactory;
      class function GetInstance: TPlugInModule;

      procedure SetInfo(AuthorValue: String; ReleaseDateValue: TDateTime; VersionValue: String);
    end;

  function GetPlugInModule: IPlugInModule; stdcall;

implementation

  uses System.SysUtils, System.TypInfo, VCL.Dialogs;

  { TIntObject }

  function TIntObject.QueryInterface(const IID: TGUID; out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then
      Result := 0
    else
      Result := E_NOINTERFACE;
  end;

  function TIntObject._AddRef: Integer;
  begin
    Result := -1;
  end;

  function TIntObject._Release: Integer;
  begin
    Result := -1;
  end;

  { TPlugInFactory }

  procedure TPlugInFactory.ClearNamed;
  var
    i: Integer;
  begin
    for i := 0 to FNamedList.Count - 1 do
      TPlugIn(FNamedList.Objects[i]).Free;
    FNamedList.Clear;
  end;

  constructor TPlugInFactory.Create;
  begin
    inherited Create;
    FNamedList            := TStringList.Create;
    FNamedList.Sorted     := True;
    FNamedList.Duplicates := dupError;
    FUnNamedList          := TList.Create;
  end;

  function TPlugInFactory.CreatePlugIn(const PlugName: PWideChar; out Obj): Boolean;
  var
    NewObj: TPlugIn;
    NewInt: IPlugIn;
  begin
    if PlugName <> '' then
    begin
      if FNamedList.IndexOf(PlugName) > 0 then
        raise Exception.Create(Format('插件"%s"已经存在，无法再创建！', [PlugName]));
    end;
    NewObj := GetPlugInClass.Create(Self, PlugName);
    if NewObj.QueryInterface(PlugIn_IID, NewInt) = S_OK then
    begin
      if PlugName <> '' then
        FNamedList.AddObject(PlugName, NewObj)
      else
        FUnNamedList.Add(NewObj);
      IPlugIn(Obj) := NewInt;
    end
    else
    begin
      NewObj.Free;
      raise Exception.Create(GetPlugInClass.ClassName + ' not support IPlugIn');
    end;
    Pointer(NewInt) := nil;
  end;

  destructor TPlugInFactory.Destroy;
  var
    i: Integer;
  begin
    for i := 0 to FUnNamedList.Count - 1 do
      TPlugIn(FUnNamedList[i]).Free;
    FUnNamedList.Free;
    ClearNamed;
    inherited;
  end;

  procedure TPlugInFactory.DestroyPlugIn(var Obj);
  var
    DelObj: TPlugIn;
    DelInt: IPlugIn;
    i: Integer;
    N: String;
  begin
    N := IPlugIn(Obj).GetName;
    if (N <> '') then
    begin
      i := FNamedList.IndexOf(N);
      if i >= 0 then
      begin
        DelObj := TPlugIn(FNamedList.Objects[i]);
        FNamedList.Delete(i);
        DelObj.Free;
        Pointer(Obj) := nil;
        Exit;
      end;
    end
    else
    begin
      for i := 0 to FUnNamedList.Count - 1 do
      begin
        if TPlugIn(FUnNamedList[i]).QueryInterface(IPlugIn, DelInt) = S_OK then
          if (DelInt = IPlugIn(Obj)) then
          begin
            DelObj := TPlugIn(FUnNamedList[i]);
            FUnNamedList.Delete(i);
            DelObj.Free;
            Pointer(Obj) := nil;
            Exit;
          end;
      end;
    end;
    raise Exception.Create(Format('当前工厂未产出插件"%s"', [N]));
  end;

  function TPlugInFactory.FactoryName: PWideChar;
  begin
    Result := PWideChar(ClassName);
  end;

  procedure TPlugInFactory.FromString(Value: PWideChar);
  var
    Jo, Item: ISuperObject;
    i: Integer;
    It: IPlugIn;
  begin
    Jo := SO(Value);
    if (Jo.S['Name'] <> FactoryName) or (Jo.S['PlugInIID'] <> UUIDToString(PlugInIID)) then
      raise Exception.Create('工厂参数不匹配。');

    for Item in Jo['PlugIns'] do
    begin
      CreatePlugIn(PWideChar(Item.S['PlugInName']), It);
      It.GetParams.FromString(PWideChar(Item.S['Params']));
    end;
  end;

  procedure TPlugInFactory.GetPlugIn(const PlugName:PWideChar; var Obj);
  var
    N: Integer;
  begin
    N := FNamedList.IndexOf(PlugName);
    if N >= 0 then
    begin
      if TPlugIn(FNamedList.Objects[N]).QueryInterface(PlugIn_IID, Obj)<>S_OK then
        Pointer(Obj):=nil;
    end
    else
      Pointer(Obj) := nil;
  end;

  class function TPlugInFactory.GetPlugInClass: TPlugInClass;
  begin
    Result := TPlugIn;
  end;

  function TPlugInFactory.PlugInDescription: PWideChar;
  begin
    Result := '';
  end;

  class function TPlugInFactory.PlugInIID: TGUID;
  begin
    Result := IPlugIn;
  end;

  function TPlugInFactory.PlugIn_IID: TGUID;
  begin
    Result := PlugInIID;
  end;

  function TPlugInFactory.ToString: PWideChar;
  var
    Jo, Ji, Ja: ISuperObject;
    i: Integer;
  begin
    Jo                := TSuperObject.Create(stObject);
    Ja                := TSuperObject.Create(stArray);
    Jo.S['Name']      := FactoryName;
    Jo.S['PlugInIID'] := UUIDToString(PlugInIID);
    for i             := 0 to FNamedList.Count - 1 do
    begin
      Ji                 := TSuperObject.Create(stObject);
      Ji.S['PlugInName'] := TPlugIn(FNamedList.Objects[i]).GetName;
      Ji.O['Params']     := SO(TPlugIn(FNamedList.Objects[i]).GetParams.ToString);
      Ja.AsArray.Add(Ji);
    end;
    Jo.O['PlugIns'] := Ja;
    Result          := PWideChar(Jo.AsJSon);
  end;

  { TPlugIn }

  constructor TPlugIn.Create(Factory: TPlugInFactory; Name: String);
  begin
    inherited Create;
    FFactory := Factory;
    FParams  := GetPlugInParamsClass.Create;
    FName    := Name;
  end;

  destructor TPlugIn.Destroy;
  begin
    FParams.Free;
    Pointer(FFactory) := nil;
    inherited;
  end;

  function TPlugIn.GetName: PWideChar;
  begin
    Result := PWideChar(FName);
  end;

  function TPlugIn.GetParams: IPlugInParams;
  begin
    Result := FParams;
  end;

  class function TPlugIn.GetPlugInParamsClass: TPlugInParamsClass;
  begin
    Result := TPlugInParams;
  end;

  function TPlugIn.Start: Boolean;
  begin

  end;

  procedure TPlugIn.Stop;
  begin

  end;

  { TPlugInParams }

  function TPlugInParams.BuildSO: ISuperObject;
  var
    FValue: TValue;
    FSrc: TSuperRttiContext;
  begin
    TValue.Make(@Self, PTypeInfo(Self.ClassInfo), FValue);
    FSrc   := TSuperRttiContext.Create;
    Result := FSrc.ToJson(FValue, SO);
    FSrc.Free;
  end;

  constructor TPlugInParams.Create;
  begin
    inherited Create;
  end;

  destructor TPlugInParams.Destroy;
  begin
    inherited;
  end;

  function TPlugInParams.FromString(Value: PWideChar): PWideChar;
  var
    FSo, Item: ISuperObject;
    ctx: TRttiContext;
    objType: TRttiType;
    Field: TRttiField;
    Prop: TRttiProperty;
    aValue: TValue;
    Data: String;
    i: NativeInt;
  begin
    ctx := TRttiContext.Create;
    FSo := SO(Value);
    try
      objType := ctx.GetType(Self.ClassInfo);
      for Prop in objType.GetProperties do
      begin
        Item := FSo.O[Prop.Name];
        if Assigned(Item) then
        begin
          aValue := Prop.GetValue(Self);
          case aValue.Kind of
            tkWChar, tkLString, tkWString, tkString, tkChar, tkUString:
              aValue := Item.AsString;
            tkInteger, tkInt64:
              aValue := Item.AsInteger;
            tkFloat:
              aValue := Item.AsDouble;
            tkEnumeration:
              aValue := TValue.FromOrdinal(aValue.TypeInfo, GetEnumValue(aValue.TypeInfo, Item.AsString));
            tkSet:
              begin
                i := StringToSet(aValue.TypeInfo, Item.AsString);
                TValue.Make(@i, aValue.TypeInfo, aValue);
              end;
            else
              raise Exception.Create('Type not Supported');
          end;
          Prop.SetValue(Self, aValue);
        end;
      end;
    finally
      ctx.Free;
    end;
    // var
    // FValue:TValue;
    // I:TArray<Integer>
    // FSrc:TSuperRttiContext;
    // var
    // FSo:ISuperObject;
    // begin
    // FSo:=SO(Value);
    // FSrc:=TSuperRttiContext.Create;
    // FSrc.FromJson(Self.ClassInfo, FSo, FValue);
    // FSrc.Free;
    // FValue.ExtractRawDataNoCOpy(@Self);
  end;

  function TPlugInParams.GetParamCount: Int32;
  // var
  // FSo:ISuperObject;
  begin
    Result := GetTypeData(Self.ClassInfo).PropCount;
    // FSo:=BuildSO;
    // Result:=FSo.AsObject.count;
  end;

  function TPlugInParams.GetParamName(Index: Int32): PWideChar;
  // var
  // FSo:ISuperObject;
  var
    PropCount, i: SmallInt;
    PropList: PPropList;
  begin
    PropCount := GetTypeData(Self.ClassInfo).PropCount;
    GetPropList(Self.ClassInfo, PropList);
    if (Index >= 0) and (Index < PropCount) then
      Result := PWideChar(WideString(PropList[Index]^.Name))
    else
      Result := nil;
    FreeMem(PropList);
    //
    // FSo:=BuildSO;
    // Result:=PWideChar(FSo.AsObject.GetNames.AsArray.S[Index]);
    // System.TypInfo.GetPropInfos();
  end;

  function TPlugInParams.GetParamValue(Name: PWideChar): OleVariant;
  var
    FSo: ISuperObject;
  begin
    Result := System.TypInfo.GetPropValue(Self, Name);
    // FSo:=BuildSO;
    // case FSo.AsObject.N[Name].DataType of
    // stNull: Result:=VarNull;
    // stBoolean: Result:=FSo.AsObject.B[Name];
    // stDouble: Result:=FSo.AsObject.D[Name];
    // stCurrency:  Result:=FSo.AsObject.C[Name];
    // stInt:  Result:=FSo.AsObject.I[Name];
    // stString: Result:=FSo.AsObject.S[Name];
    // end;
  end;

  function TPlugInParams.GetPlugInIID: TGUID;
  begin
    Result := IPlugInParams;
  end;

  procedure TPlugInParams.SetParamValue(Name: PWideChar; Value: OleVariant);
  // var
  // S, FSo:ISuperObject;
  // FValue:TValue;
  // FSrc:TSuperRttiContext;
  begin
    System.TypInfo.SetPropValue(Self, Name, Value);
    // FSo:=BuildSO;
    // ShowMessage(FSo.AsJSon(True, False));
    // S:=So(Value);
    // FSo.O[Name]:=S;
    //
    // ShowMessage(FSo.AsJSon(True, False));
    // FSrc:=TSuperRttiContext.Create;
    // FSrc.FromJson(Self.ClassInfo, FSo, FValue);
    // FSrc.Free;
    // FValue.ExtractRawData(Self);
  end;

  function TPlugInParams.ToString: PWideChar;
  var
    Item, Jo: ISuperObject;

    ctx: TRttiContext;
    objType: TRttiType;
    Field: TRttiField;
    Prop: TRttiProperty;
    Value: TValue;
    Data: String;
  begin
    ctx := TRttiContext.Create;
    Jo := TSuperObject.Create();
    try
      objType := ctx.GetType(Self.ClassInfo);
      for Prop in objType.GetProperties do
      begin
        Value := Prop.GetValue(Self);
        Item  := TSuperObject.Create();
        Jo.O[Prop.Name]:=Item;

        case Value.Kind of
          tkWChar, tkLString, tkWString, tkString, tkChar, tkUString:
            Jo.S[Prop.Name] := Value.ToString;

          tkInteger, tkInt64:
            Jo.I[Prop.Name] := Value.AsInt64;
          tkFloat:
            Jo.D[Prop.Name] := Value.AsExtended;
          tkEnumeration:
            Jo.S[Prop.Name] := Value.ToString;
          tkSet:
            Jo.S[Prop.Name] := Value.ToString;
          else
            raise Exception.Create('Type not Supported');
        end;
      end;
    finally
      ctx.Free;
    end;

    // var
    // Jo:ISuperObject;
    // begin
    // Jo:=BuildSO;
     Result:=PWideChar(Jo.AsJSon);
  end;

  { TPlugInModule }

  function TPlugInModule.Author: PWideChar;
  begin
    Result := PWideChar(FAuthor);
  end;

  procedure TPlugInModule.Clear;
  var
    i: Integer;
  begin
    for i := 0 to FFactory.Count - 1 do
      FFactory.Objects[i].Free;
    FFactory.Clear;
  end;

  constructor TPlugInModule.Create;
  begin
    if Assigned(FInstance) then
      raise Exception.Create('TPlugInModule is Singleton!');
    inherited Create;
    FFactory  := TStringList.Create;
    FInstance := Self;
  end;

  destructor TPlugInModule.Destroy;
  begin
    Clear;
    FInstance := nil;
    inherited;
  end;

  procedure TPlugInModule.FromString(Value: PWideChar);
  var
    Jo, Ja, S: ISuperObject;
    i: Integer;
    G: TGUID;
  begin
    PlugInClear;
    Jo            := SO(Value);
    Self.FAuthor  := Jo.S['Author'];
    Self.FDate    := JavaToDelphiDateTime(Jo.i['ReleaseDate']);
    Self.FVersion := Jo.S['FVersion'];
    Ja            := Jo.O['Factories'];
    for S in Ja do
    begin
      i := FFactory.IndexOf(S.S['Name']);
      if StringToUUID(S.S['PlugInIID'], G) and (i >= 0) then
        if TPlugInFactory(FFactory.Objects[i]).PlugIn_IID = G then
        begin
          TPlugInFactory(FFactory.Objects[i]).FromString(PWideChar(S.AsJSon));
        end;
    end;
  end;

  function TPlugInModule.GetFactory(Index: Int32):IPlugInFactory;
  var
    F: TPlugInFactory;
  begin
    F      := TPlugInFactory(FFactory.Objects[Index]);
    Result:=F;
  end;

  function TPlugInModule.GetFactoryByname(Name: PWideChar):IPlugInFactory;
  var
    F: TPlugInFactory;
    N: Integer;
  begin
    N := FFactory.IndexOfName(Name);
    if N >= 0 then
    begin
      F      := TPlugInFactory(FFactory.Objects[N]);
      Result:= F;
    end
    else
      Result := nil;
  end;

  function TPlugInModule.GetFactoryCount: Int32;
  begin
    Result := FFactory.Count;
  end;

  class function TPlugInModule.GetInstance: TPlugInModule;
  begin
    if not Assigned(FInstance) then
      FInstance := TPlugInModule.Create;
    Result      := FInstance;
  end;

  procedure TPlugInModule.PlugInClear;
  var
    i: Integer;
  begin
    for i := 0 to FFactory.Count - 1 do
      TPlugInFactory(FFactory.Objects[i]).ClearNamed;
  end;

  procedure TPlugInModule.RegistPlugInFactory(Factory: TPlugInFactory);
  begin
    if FFactory.IndexOf(Factory.FactoryName) >= 0 then
      raise Exception.Create(Format('插件类型 %s 已经注册，不能重复注册!', [Factory.FactoryName]));
    FFactory.AddObject(Factory.FactoryName, Factory);
  end;

  function TPlugInModule.ReleaseDate: TDateTime;
  begin
    Result := FDate;
  end;

  procedure TPlugInModule.SetInfo(AuthorValue: String; ReleaseDateValue: TDateTime; VersionValue: String);
  begin
    FAuthor  := AuthorValue;
    FDate    := ReleaseDateValue;
    FVersion := VersionValue;
  end;

  function TPlugInModule.ToString: PWideChar;
  var
    Jo, Ja, S: ISuperObject;
    i: Integer;
  begin
    Jo                  := TSuperObject.Create(stObject);
    Jo.S['Author']      := Self.FAuthor;
    Jo.i['ReleaseDate'] := DelphiToJavaDateTime(Self.FDate);
    Jo.S['FVersion']    := Self.FVersion;
    Ja                  := TSuperObject.Create(stArray);
    for i               := 0 to Self.FFactory.Count - 1 do
    begin
      S := SO(TPlugInFactory(Self.FFactory.Objects[i]).ToString);
      Ja.AsArray.Add(S);
    end;
    Jo.O['Factories'] := Ja;
    Result            := PWideChar(Jo.AsJSon);
  end;

  function TPlugInModule.Version: PWideChar;
  begin
    Result := PWideChar(FVersion);
  end;

  function GetPlugInModule: IPlugInModule; stdcall;
  begin
    Result := TPlugInModule.GetInstance;
  end;

initialization

  TPlugInModule.GetInstance;

finalization

  if Assigned(TPlugInModule.FInstance) then
    FreeAndNil(TPlugInModule.FInstance);

end.
