unit utPlugInManagerDLL;

{$DEFINE DLL}

interface

  uses utPlugInInterface;

  var
    PlugInModuleManager: IPlugInModuleManager;

implementation

  {$IFDEF DLL}

  uses Windows, SysUtils;

  const
    DLLName   = 'prjPlugInManager.DLL';

  var
    LibHandle: THandle;
  {$ELSE}

  uses utPlugInManager;
  {$ENDIF}

  type
    Proc = function: IPlugInModuleManager;stdcall;

  procedure Init;
  {$IFDEF DLL}
  var
    P: Proc;
  begin
    LibHandle := SafeLoadLibrary(DLLName);
    if LibHandle <> INVALID_HANDLE_VALUE then
    begin
      P := GetProcAddress(LibHandle, 'GetPlugInModuleManager');
      if Assigned(P) then
        PlugInModuleManager := P();
    end
    else
      raise Exception.Create('无法打开库文件' + DLLName);
    if not Assigned(PlugInModuleManager) then
      raise Exception.Create(DLLName + '找不到指定函数');
  end;
  {$ELSE}
  begin
    PlugInModuleManager   := utPlugInManager.GetPlugInModuleManager;
  end;
  {$ENDIF}

  procedure Done;
  begin
    try
      {$IFDEF DLL}
      if LibHandle <> INVALID_HANDLE_VALUE then
        FreeLibrary(LibHandle);
      {$ENDIF}
      Pointer(PlugInModuleManager)   := nil;
    except
    end;
  end;

initialization

  Init;

finalization

  Done;

end.
