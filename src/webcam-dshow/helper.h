#ifndef HELPER_H
#define HELPER_H

#include <stdlib.h>
#include <dshow.h>

struct DEVICE_INFO {
    OLECHAR FriendlyName[255];
    OLECHAR DevicePath[255];
};

/**
 * @brief EnumerateDevices Перечисление системных устройств (кодеки, устройства ауд/вид захвата и т.д.)
 * @param category
 * @param ppEnum
 * @return
 */
HRESULT EnumerateDevices(REFGUID category, IEnumMoniker **ppEnum);

/**
 * @brief GetDeviceInformation Получение информации об устройстве
 * @param pEnum
 * @param info
 */
void GetDeviceInformation(IEnumMoniker *pEnum, struct DEVICE_INFO *info);

HRESULT EnumerateDevices(REFGUID category, IEnumMoniker **ppEnum)
{
    ICreateDevEnum *pDevEnum;
    HRESULT hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL,
        CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&pDevEnum));

    if (SUCCEEDED(hr)) {
        hr = pDevEnum->CreateClassEnumerator(category, ppEnum, 0);
        if (hr == S_FALSE) {
            hr = VFW_E_NOT_FOUND;  // The category is empty. Treat as an error.
        }
        pDevEnum->Release();
    }
    return hr;
}

void GetDeviceInformation(IEnumMoniker *pEnum, struct DEVICE_INFO *info)
{
    IMoniker *pMoniker = NULL;

    while (pEnum->Next(1, &pMoniker, NULL) == S_OK)
    {
        IPropertyBag *pPropBag;
        HRESULT hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));
        if (FAILED(hr)) {
            pMoniker->Release();
            continue;
        }

        VARIANT var;
        VariantInit(&var);

        // Get description or friendly name.
        hr = pPropBag->Read(L"Description", &var, 0);
        if (FAILED(hr)) {
            hr = pPropBag->Read(L"FriendlyName", &var, 0);
        }
        if (SUCCEEDED(hr)) {
            printf("%S\n", var.bstrVal);

//            StringCbCopy(info->FriendlyName, 255, var.bstrVal);
            VariantClear(&var);
        }

        hr = pPropBag->Write(L"FriendlyName", &var);

        hr = pPropBag->Read(L"DevicePath", &var, 0);
        if (SUCCEEDED(hr)) {
            // The device path is not intended for display.
            printf("Device path: %S\n", var.bstrVal);
//            StringCbCopy(info->DevicePath, 255, var.bstrVal);
            VariantClear(&var);
        }

        pPropBag->Release();
        pMoniker->Release();
    }
}

#endif // HELPER_H
