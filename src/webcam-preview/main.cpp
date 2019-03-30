#include <stdio.h>

#include <windows.h>
#include <dshow.h>

HRESULT InitCaptureGraphBuilder(
    IGraphBuilder **ppGraph, ICaptureGraphBuilder2 **ppBuild);

HRESULT InitCaptureGraphBuilder(
    IGraphBuilder **ppGraph,
    ICaptureGraphBuilder2 **ppBuild)
{
    if (!ppGraph || !ppBuild) {
        return E_POINTER;
    }

    IGraphBuilder *pGraph = NULL;
    ICaptureGraphBuilder2 *pBuild = NULL;

    // Create the Capture Graph Builder.
    HRESULT hr = CoCreateInstance(
        CLSID_CaptureGraphBuilder2,
        NULL,
        CLSCTX_INPROC_SERVER,
        IID_ICaptureGraphBuilder2,
        (void**)&pBuild);

    if (FAILED(hr)) {
        return hr;
    }

    hr = CoCreateInstance(
        CLSID_FilterGraph,
        0,
        CLSCTX_INPROC_SERVER,
        IID_IGraphBuilder,
        (void**)&pGraph);

    if (FAILED(hr)) {
        return hr;
    }

    // Initialize the Capture Graph Builder.
    pBuild->SetFiltergraph(pGraph);

    // Return both interface pointers to the caller.
    *ppBuild = pBuild;
    *ppGraph = pGraph; // The caller must release both interfaces.

    pBuild->Release();
    return S_OK;
}

https://docs.microsoft.com/en-us/windows/desktop/directshow/previewing-video

int main(int argc, char *argv[])
{
    if (CoInitializeEx(NULL, COINIT_APARTMENTTHREADED) != S_OK) {
        printf("CoInitializeEx error!\n");
        return 1;
    }

    ICreateDevEnum *pSysDevEnum = NULL;
    HRESULT hr = CoCreateInstance(
        CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,
        IID_ICreateDevEnum, (void **)&pSysDevEnum);
    if (FAILED(hr)) {
        printf("CoCreateInstance error!\n");
        return 1;
    }

    // Obtain a class enumerator for the video compressor category.
    IEnumMoniker *pEnumCat = NULL;
    hr = pSysDevEnum->CreateClassEnumerator(
        /*CLSID_VideoCompressorCategory*/CLSID_VideoInputDeviceCategory, &pEnumCat, 0);
    if (hr != S_OK) {
        printf("CreateClassEnumerator error!\n");
        return 1;
    }

    // Enumerate the monikers.
    IMoniker *pMoniker = NULL;
    ULONG cFetched;
    while(pEnumCat->Next(1, &pMoniker, &cFetched) == S_OK) {
        IPropertyBag *pPropBag;
        hr = pMoniker->BindToStorage(0, 0, IID_IPropertyBag,
            (void **)&pPropBag);
        if (SUCCEEDED(hr)) {
            // To retrieve the filter's friendly name, do the following:
            VARIANT varName;
            VariantInit(&varName);
            hr = pPropBag->Read(L"FriendlyName", &varName, 0);
            if (SUCCEEDED(hr)) {
                printf("%S\n", varName.bstrVal);
            }
            VariantClear(&varName);

            // To create an instance of the filter, do the following:
            IBaseFilter *pFilter;
            hr = pMoniker->BindToObject(NULL, NULL, IID_IBaseFilter,
                (void**)&pFilter);
            // Now add the filter to the graph.
            //Remember to release pFilter later.
            pPropBag->Release();
        }
        pMoniker->Release();
    }
    pEnumCat->Release();
    pSysDevEnum->Release();


    ICaptureGraphBuilder2 *pBuild = NULL; // Capture Graph Builder
    IBaseFilter *pCap = NULL; // Video capture filter.

    InitCaptureGraphBuilder(pBuild,)


    hr = pBuild->RenderStream(&PIN_CATEGORY_PREVIEW, &MEDIATYPE_Video,
        pCap, NULL, NULL);

    CoUninitialize();
    return 0;
}
