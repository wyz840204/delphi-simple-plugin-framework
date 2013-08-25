unit utPlugInManager;

interface

uses utPlugInInterface,  System.SysUtils, System.Rtti, ShlwApi, Windows, System.Generics.Collections, Ioutils;


type

  TPlugInModuleManager=class(TObject, IInterface, IPlugInModuleManager)
  protected
    type
      TModule=class
        FLibHandle:THandle;
        FModule:IPlugInModule;
      end;
  protected
    class var FInstance:TPlugInModuleManager;
    class var FAppPath:String;
    FDLLs: TDictionary<string, TModule>;
    FFactorys: TDictionary<TGUID, IPlugInFactory>;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure UnLoadAll;
  public
    constructor Create;
    destructor Destroy;override;
    function LoadDLL(FileName:PWideChar):IPlugInModule;
    procedure UnLoadDLL(FileName:PWideChar);
    function ToString:PWideChar;
    procedure FromString(Value:PWideChar);
    function GetModule(FileName:PWidechar):IPlugInModule;
    function GetFactory(PlugIn_IID:TGUID):IPlugInFactory;
    class function GetInstance:TPlugInModuleManager;
  end;

function GetPlugInModuleManager:IPlugInModuleManager;stdcall;

implementation

uses SuperObject;

/// 取绝对路径的函数。需要引用 ShlwApi.pas
/// S := GetAbsolutePath('C:\Windows\System32', '..\DEMO.TXT')
//  S 将得到 'C:\Windows\DEMO.TXT
function GetAbsolutePathEx(BasePath, RelativePath:string):string;
var
   Dest:array [0..MAX_PATH] of char;
begin
   FillChar(Dest,MAX_PATH+1,0);
   PathCombine(Dest,PChar(BasePath), PChar(RelativePath));
   Result:=string(Dest);
end;

function GetRelativePath(const Path, AFile: string): string;
  function GetAttr(IsDir: Boolean): DWORD;
  begin
       if IsDir then
         Result := FILE_ATTRIBUTE_DIRECTORY
       else
         Result := FILE_ATTRIBUTE_NORMAL;
  end;
var
   p: array[0..MAX_PATH] of Char;
begin
   PathRelativePathTo(p, PChar(Path), GetAttr(False), PChar(AFile), GetAttr(True));
   Result := StrPas(p);
end;

/// 取得本身程序的路径
function AppPath : string;
begin
  Result := extractFilePath(Paramstr(0));
end;



{ TPlugInModuleManager }

function TPlugInModuleManager.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TPlugInModuleManager._AddRef: Integer;
begin
  Result:=-1;
end;

function TPlugInModuleManager._Release: Integer;
begin
  Result:=-1;
end;

constructor TPlugInModuleManager.Create;
begin
  Assert(not Assigned(FInstance), Format('%s is Singleton Class', [Self.ClassName]));

  inherited Create;
  FDLLs:= TDictionary<string, TModule>.Create;
  FFactorys:= TDictionary<TGUID, IPlugInFactory>.Create;
end;

destructor TPlugInModuleManager.Destroy;
begin
  UnLoadAll;
  FFactorys.Free;
  FDlls.Free;
  inherited;
end;

procedure TPlugInModuleManager.FromString(Value: PWideChar);
var
  S,Item:ISuperObject;
  ja: TSuperArray;
  I:Integer;
  M:IPlugInModule;
begin
  UnLoadAll;
  S:=SO(Value);
  I:= S.I['ModuleCount'];
  ja:=S['Modules'].AsArray;
  for item in S['Modules'] do
  begin
    M:=LoadDLL(PWideChar(Item.S['FileName']));
    M.FromString(PWideChar(Item.S['Factories']));
  end;
end;

function TPlugInModuleManager.GetFactory(PlugIn_IID: TGUID): IPlugInFactory;
begin
  if not FFactorys.TryGetValue(PlugIn_IID, Result) then Result:=nil;
end;

function TPlugInModuleManager.GetModule(FileName: PWidechar): IPlugInModule;
var
  Fn:String;
  M:TModule;
begin
  Fn:=GetRelativePath(FAppPath, FileName);
  if not FDlls.TryGetValue(Fn, M) then Result:=nil
    else Result:=M.FModule;
end;

class function TPlugInModuleManager.GetInstance: TPlugInModuleManager;
begin
  if not Assigned(FInstance) then
  begin
    FInstance:=TPlugInModuleManager.Create;
    FAppPath:=ExtractFilePath(ParamStr(0));
  end;
  Result:=FInstance;
end;


type
  TModuleFunc=function:IPlugInModule;stdcall;

function TPlugInModuleManager.LoadDLL(FileName: PWideChar): IPlugInModule;
var
  Fn:String;
  LibHandle:THandle;
  Module:IPlugInModule;
  P:TModuleFunc;
  M:TModule;
  i:Integer;
  F:IPlugInFactory;
begin
  Result:=nil;
  Fn:=FileName;
  if not FileExists(Fn) then Exit;
  Fn:=GetRelativePath(FAppPath, Fn);
  Fn:=Fn+ExtractFileName(FileName);
  if FDLls.TryGetValue(Fn, M) then Exit(M.FModule);
  LibHandle := SafeLoadLibrary(FileName);
  if LibHandle <> INVALID_HANDLE_VALUE then
  begin
      P := GetProcAddress(LibHandle, 'GetPlugInModule');
      if Assigned(P) then Module := P()
      else FreeLibrary(LibHandle);
  end
  else
    raise Exception.Create('无法打开库文件' + FileName);
  if not Assigned(Module) then
    raise Exception.Create(FileName + '找不到插件库接口函数');
  M:=TModule.Create;
  M.FLibHandle:=LibHandle;
  M.FModule:=Module;
  FDlls.Add(Fn, M);
  for i := 0 to Module.GetFactoryCount-1 do
  begin
    Module.GetFactory(i, F);
    if Assigned(F) then FFactorys.Add(F.PlugIn_IID, F);
  end;
  Pointer(F):=nil;
  Result:=Module;
  Pointer(Module):=nil;
end;

function TPlugInModuleManager.ToString: PWideChar;
var
  S,A, Item:ISuperObject;
  ja: TSuperArray;
  I:Integer;
  Pair:TPair<String, TModule>;
begin
  S:=TSuperObject.Create(stObject);
  S.I['ModuleCount']:=FDlls.Count;
  A:=TSuperObject.Create(stArray);
  for Pair in FDlls do
  begin
    Item:=TSuperObject.Create(stObject);
    Item.S['FileName']:=Pair.Key;
    Item.O['Factories']:=So(Pair.Value.FModule.ToString);
    A.AsArray.Add(Item);
  end;
  S.O['Modules']:=A;
  Result:=PWideChar( S.AsJSon(True, False));
end;

procedure TPlugInModuleManager.UnLoadAll;
var
  Pair:TPair<String, TModule>;
begin
  FFactorys.Clear;
  for Pair in FDlls do
  begin
    FreeLibrary(Pair.Value.FLibHandle);
    Pointer(Pair.Value.FModule):=nil;
    Pair.Value.Free;
  end;
  FDlls.Clear;
end;

procedure TPlugInModuleManager.UnLoadDLL(FileName: PWideChar);
var
  Fn:String;
  i:Integer;
  Module:TModule;
  F:IPlugInFactory;
begin
  if not FileExists(FileName) then Exit;
  Fn:=GetRelativePath(FAppPath, FileName);
  if not FDLls.TryGetValue(Fn, Module) then Exit;

  for i := 0 to Module.FModule.GetFactoryCount-1 do
  begin
    Module.FModule.GetFactory(i, F);
    if Assigned(F) then FFactorys.Remove(F.PlugIn_IID);
  end;
  Pointer(F):=nil;

  FreeLibrary(Module.FLibHandle);
  Pointer(Module.FModule):=nil;
  FDlls.Remove(Fn);
  Module.Free;
end;

function GetPlugInModuleManager:IPlugInModuleManager;stdcall;
begin
  Pointer(Result):=nil;
  if TPlugInModuleManager.FInstance.QueryInterface(IPlugInModuleManager, Result)<>S_OK then
  begin
    Result:=nil;
  end;
end;

initialization
  TPlugInModuleManager.GetInstance
finalization
  FreeAndNil(TPlugInModuleManager.FInstance);
end.
