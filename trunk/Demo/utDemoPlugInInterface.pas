unit utDemoPlugInInterface;

interface

uses utPlugInInterface;

const
  IID_IDemoPlugIn1                    = '{33771DF2-18C9-4EFA-8D06-4DAB4FCBAD16}';
  GUID_IDemoPlugIn1:TGUID             = IID_IDemoPlugIn1;

type
  IDemoPlugIn1=interface(IPlugIn)
    [IID_IDemoPlugIn1]
    procedure ShowMessage;
  end;

const
  IID_IDemoPlugIn2                    = '{33771DF2-18C9-4EFA-8D06-4DAB4FCBAD17}';
  GUID_IDemoPlugIn2:TGUID             = IID_IDemoPlugIn2;

type
  IDemoPlugIn2=interface(IPlugIn)
    [IID_IDemoPlugIn2]
    procedure Calculate;
    procedure SetShow(aShow:IDemoPlugIn1);
  end;

implementation

end.
