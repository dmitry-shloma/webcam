unit MyCapture;

interface

uses
  Classes, StdCtrls, ActiveX, DirectShow9;

type
  TCapture = class(TObject)
  private
    type
      TMyClassEnumeratorInfo = record
        FriendlyName: array[0..255] of string;
        BaseFilter: array[0..255] of IBaseFilter;
        CountOfBaseFilter: Integer;
    end;
    procedure MyClassEnumerator(clsidDeviceClass: TGUID;
      out MyClassEnumeratorInfo: TMyClassEnumeratorInfo);
  public
    constructor Create();
    procedure GetCapDevices(CapDevices: TStrings);
    destructor Destroy(); override;
  end;

implementation
//----------------------------private---------------------------------------------

//--Перечисление кодеков, устройств ауд/вид захвата и т.д.)---------------------->
procedure TCapture.MyClassEnumerator(clsidDeviceClass: TGUID;
  out MyClassEnumeratorInfo: TMyClassEnumeratorInfo);
var
  CreateDevEnum: ICreateDevEnum;
  EnumMoniker: IEnumMoniker;
  Moniker: IMoniker;
  PropertyBag: IPropertyBag;
  FriendlyName: OleVariant;
  Count: Integer;
begin
  Count:=-1;
  CoCreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC_SERVER,
    IID_ICreateDevEnum, CreateDevEnum);
  if CreateDevEnum.CreateClassEnumerator(clsidDeviceClass,
    EnumMoniker, 0) = S_OK then
  begin
    while EnumMoniker.Next(1, Moniker, nil) = S_OK do
    begin
      Inc(Count);
      Moniker.BindToStorage(nil, nil, IID_IPropertyBag, PropertyBag);
      PropertyBag.Read('FriendlyName', FriendlyName, nil);
      MyClassEnumeratorInfo.FriendlyName[Count]:= FriendlyName;
      Moniker.BindToObject(nil, nil, IID_IBaseFilter,
        MyClassEnumeratorInfo.BaseFilter[Count]);
    end;
  end;
  MyClassEnumeratorInfo.CountOfBaseFilter:= Count;
end;
//-------------------------------------------------------------------------------<

//----------------------------public----------------------------------------------

constructor TCapture.Create;
begin
  inherited Create;
  //Инициализация COM
  {if Failed(}CoInitializeEx(nil, COINIT_APARTMENTTHREADED);{) then
  begin
    MessageBox(Handle, 'Ошибка инициализации COM', 'Ошибка', MB_ICONERROR);
    Exit;
  end;
  }
end;

procedure TCapture.GetCapDevices(CapDevices: TStrings);
begin
  CapDevices.Add('asd');
end;

destructor TCapture.Destroy;
begin
  CoUninitialize(); // Деинициализация COM
  inherited Destroy;
end;

end.
