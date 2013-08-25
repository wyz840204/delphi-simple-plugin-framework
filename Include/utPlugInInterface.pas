unit utPlugInInterface;

interface

  const
    IID_IPlugInFactory       = '{640A9163-778D-4840-85F4-3B7EF8BEA115}';
    IID_IPlugInParams        = '{47EF7B55-E8B7-4939-9119-03635C1E21D0}';
    IID_IPlugIn              = '{C6A3DD8F-4F1D-4D1C-A997-4F813F9323B3}';
    IID_IPlugInModule        = '{3C4BA31F-4B8E-4323-BC6D-96BE6D637E03}';
    IID_IPlugInModuleManager = '{85B3D232-5E64-4211-9B57-823E423BF799}';

    GUID_IPlugInFactory       = IID_IPlugInFactory;
    GUID_IPlugInParams        = IID_IPlugInParams;
    GUID_IPlugIn              = IID_IPlugIn;
    GUID_IPlugInModule        = IID_IPlugInModule;
    GUID_IPlugInModuleManager = IID_IPlugInModuleManager;

  type

    IPlugIn = interface;

    // �������
    IPlugInFactory = interface
      [IID_IPlugInFactory]
      function FactoryName: PWideChar;       // ��������,Ψһ
      function PlugInDescription: PWideChar; // �������
      function PlugIn_IID: TGUID;            // ����ӿ�GUID

      function CreatePlugIn(const PlugName: PWideChar; out Obj): Boolean;
      procedure DestroyPlugIn(var Obj);

      function ToString: PWideChar;           // ���湤�������в��������Ϣ
      procedure FromString(Value: PWideChar); // ��ȡ�����ڵĲ����Ϣ,�����ɲ��
      procedure GetPlugIn(const PlugName: PWideChar; var Obj);
    end;

    // ��������ò���
    IPlugInParams = interface
      [IID_IPlugInParams]
      function ToString: PWideChar;                     // ��������Ϊ�ַ���
      function FromString(Value: PWideChar): PWideChar; // �趨���������ش�����Ϣ
      function GetParamCount: Int32;
      function GetParamName(Index: Int32): PWideChar;
      function GetParamValue(Name: PWideChar): OleVariant;
      procedure SetParamValue(Name: PWideChar; Value: OleVariant);
      function GetPlugInIID: TGUID;
    end;

    // ����ӿ�
    IPlugIn = interface
      [IID_IPlugIn]
      function GetName: PWideChar;       // ��ȡ���ʵ������
      function GetParams: IPlugInParams; // ��ȡ��������ӿ�
      function Start: Boolean;           // ���в��
      procedure Stop;                    // ֹͣ���
    end;

    // ����ģ�飬ÿ��DLL��ֻ��һ�����ģ��,
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
