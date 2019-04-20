#include <stdio.h>

#include <windows.h>
#include <dshow.h>
#include <helper.h>

int main()
{
    HRESULT hr = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    if (FAILED(hr)) {
        printf("ERROR\n");
        return 1;
    }

    IEnumMoniker *pEnum = NULL;
    EnumerateDevices(CLSID_VideoInputDeviceCategory, &pEnum);

    struct DEVICE_INFO info;
    GetDeviceInformation(pEnum, &info);
//    printf("%S\n", info.FriendlyName);
//    printf("%S\n", info.DevicePath);

    CoUninitialize();
    return 0;
}

