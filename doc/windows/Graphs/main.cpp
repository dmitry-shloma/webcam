#include <dshow.h>


void DoFilePlayback()
{

    IGraphBuilder *pGraph = 0;
    IMediaControl *pMediaControl = 0;
    IMediaEvent   *pEvent = 0;
    CoInitialize(NULL);
    
    // Create the FGM and query for interfaces.
    CoCreateInstance(CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, 
                IID_IGraphBuilder, (void **)&pGraph);

    // Obtain the interface used to run, stop, and pause the graph
    pGraph->QueryInterface(IID_IMediaControl, (void **)&pMediaControl);
    // Obtain the interface to receive events from the graph
    pGraph->QueryInterface(IID_IMediaEvent, (void **)&pEvent);

    // Build the graph. IMPORTANT: Change string to a file on your system.
    pGraph->RenderFile(L"C:\\Example.avi", NULL);

    // Run the graph.
    pMediaControl->Run();

    // Wait for completion. 
    long evCode;
    pEvent->WaitForCompletion(INFINITE, &evCode);

    // Clean up.
    pMediaControl->Release();
    pEvent->Release();
    pGraph->Release();
    CoUninitialize();
}


void DoVideoCapture()
{
    IGraphBuilder *pGraph = 0;
    ICreateDevEnum *pDevEnum = 0;
    ICaptureGraphBuilder2 *pBuild = 0;

    HRESULT hr;
    CoInitialize(NULL);
     
    // Create the FGM.
    hr = CoCreateInstance(CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER,
        IID_IGraphBuilder, (void **)&pGraph );

    // Create the capture graph builder helper object
    hr = CoCreateInstance(CLSID_CaptureGraphBuilder2, NULL,
        CLSCTX_INPROC_SERVER, IID_ICaptureGraphBuilder2, (void **)&pBuild );
     
    // Tell the capture graph builder about the FGM.
    hr = pBuild->SetFiltergraph(pGraph);

    // Use the system device enumerator to find a video capture device.
    hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER,
        IID_ICreateDevEnum, (LPVOID*)&pDevEnum);

    // Use the first capture filter that we find.
    IEnumMoniker* pEnum = 0;
    IMoniker* pMoniker = 0;
    IBaseFilter *pCapture = 0;
    hr = pDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory,
        &pEnum, 0);
    if (S_OK == pEnum->Next(1, &pMoniker, NULL))
    {
        hr = pMoniker->BindToObject(0, 0, IID_IBaseFilter, (void **)&pCapture);
    }
    else
    {
        return; // No video capture devices!
    }

    pMoniker->Release();
    pEnum->Release();
    pDevEnum->Release();

    // Add the capture filter to the filter graph
    hr = pGraph->AddFilter(pCapture, L"CaptureFilter");

    // Build the preview part of the graph.
    hr = pBuild->RenderStream(&PIN_CATEGORY_PREVIEW, &MEDIATYPE_Video, 
        pCapture, NULL, NULL);

    // Build the file writing part of the graph.
    IBaseFilter *pMux = 0;
    pBuild->SetOutputFileName(&MEDIASUBTYPE_Avi, L"C:\\test.avi", &pMux, 0);
    hr = pBuild->RenderStream(&PIN_CATEGORY_CAPTURE, &MEDIATYPE_Video,
       pCapture, NULL, pMux);
   
    
    // Run the graph for 10 seconds.

    IMediaControl *pControl = 0;
    hr = pGraph->QueryInterface(IID_IMediaControl, (void **)&pControl);
    pControl->Run();

    // Note: In a real app, you would use IAMStreamControl or 
    // ICaptureGraphBuilder2::ControlStream to control the preview
    // and capture streams independently. We just sleep for 10 sec.

    Sleep(10000);

    pControl->Stop();
        
    // Clean up.
    pGraph->Release();
    pControl->Release();
    pBuild->Release();
    pCapture->Release();
    pMux->Release();
    CoUninitialize();
}


void main(void)
{
    DoFilePlayback();

    // Uncomment to test video capture:
    // DoVideoCapture();
}
