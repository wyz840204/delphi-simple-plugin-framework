unit utPlugInInterface;

interface

  const
    IID_IPlugInFactory       = '{640A9163-778D-4840-85F4-3B7EF8BEA115}';
    IID_IPlugInParams        = '{47EF7B55-E8B7-4939-9119-03635C1E21D0}';
    IID_IPlugIn              = '{C6A3DD8F-4F1D-4D1C-A997-4F813F9323B3}';
    IID_IPlugInModule        = '{3C4BA31F-4B8E-4323-BC6D-96BE6D637E03}';
    IID_IPlugInModuleManager = '{85B3D232-5E64-4211-9B57-823E423BF799}';

    GUID_IPlugInFactory:TGUID       = IID_IPlugInFactory;
    GUID_IPlugInParams:TGUID        = IID_IPlugInParams;
    GUID_IPlugIn:TGUID              = IID_IPlugIn;
    GUID_IPlugInModule:TGUID        = IID_IPlugInModule;
    GUID_IPlugInModuleManager:TGUID = IID_IPlugInModuleManager;

  type

    IPlugIn = interface;
    PPlugIn = ^IPlugIn;

    // 插件工厂
    IPlugInFactory = interface
      [IID_IPlugInFactory]
      function FactoryName: PWideChar;       // 工厂名称,唯一
      function PlugInDescription: PWideChar; // 插件描述
      function PlugIn_IID: TGUID;            // 插件接口GUID

      function CreatePlugIn(const PlugName: PWideChar; out Obj): Boolean;
      procedure DestroyPlugIn(var Obj);

      function ToString: PWideChar;           // 保存工厂内所有插件参数信息
      procedure FromString(Value: PWideChar); // 读取工厂内的插件信息,并生成插件
      procedure GetPlugIn(const PlugName: PWideChar; var Obj);
      function AddCreateNotify(const Listener:IPlugIn; const PlugName:PWideChar):IPlugIn;
    end;

    // 插件的配置参数
    IPlugInParams = interface
      [IID_IPlugInParams]
      function ToString: PWideChar;                     // 参数保存为字符串
      function FromString(Value: PWideChar): PWideChar; // 设定参数，返回错误信息
      function GetParamCount: Int32;
      function GetParamName(Index: Int32): PWideChar;
      function GetParamValue(Name: PWideChar): OleVariant;
      procedure SetParamValue(Name: PWideChar; Value: OleVariant);
      function GetPlugIn:IPlugIn;
    end;

    TPlugInNotifyType=(pntCreate, pntDestroy);

    // 插件接口
    IPlugIn = interface
      [IID_IPlugIn]
      function GetName: PWideChar;       // 读取插件实例名称
      function GetParams: IPlugInParams; // 读取插件参数接口
      function Start: Boolean;           // 运行插件
      procedure Stop;                    // 停止插件
      procedure AddNotifyListener(const Listener:IPlugIn);
      procedure DelNotifyListener(const Listener:IPlugIn);
      procedure Notify(const Notifier:IPlugIn; const aType:TPlugInNotifyType);
      function GetPlugInIID:TGUID;
    end;

    // 工厂模块，每个DLL中只有一个插件模块,
    IPlugInModule = interface
      [IID_IPlugInModule]
      function Author: PWideChar;
      function Version: PWideChar;
      function ReleaseDate: TDateTime;
      function ToString: PWideChar;
      procedure FromString(Value: PWideChar);

      function GetFactoryCount: Int32;
      function GetFactory(Index: Int32): IPlugInFactory;
      function GetFactoryByname(Name: PWideChar): IPlugInFactory;
    end;

    IPlugInModuleManager = interface
      [IID_IPlugInModuleManager]
      function LoadDLL(FileName: PWideChar): IPlugInModule;
      procedure UnLoadDLL(FileName: PWideChar);
      function ToString: PWideChar;
      procedure FromString(Value: PWideChar);
      function GetModule(FileName: PWideChar): IPlugInModule;
      function GetFactory(PlugIn_IID: TGUID): IPlugInFactory;
    end;

implementation

end.
