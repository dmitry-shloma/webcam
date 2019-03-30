// http://www.codeguru.com/cpp/g-m/multimedia/video/article.php/c9551/
// http://lists.mplayerhq.hu/pipermail/ffmpeg-devel/2007-April/027965.html
// http://msdn2.microsoft.com/en-us/library/ms787594.aspx
// http://msdn2.microsoft.com/en-us/library/ms787867.aspx
// NullRenderer wih reference clock set to NULL
// http://www.videolan.org/

// #include <wtypes.h>
// #include <unknwn.h>
// #include <ole2.h>
// #include <limits.h>
// #include <dshow.h>
#include <iostream>
#include <fstream>
#include <windows.h>
#include <initguid.h>
#include <objbase.h>
#include <objidl.h>
#include <boost/shared_array.hpp>
#include "error.hh"

using namespace hornetseye;

DEFINE_GUID( CLSID_VideoInputDeviceCategory, 0x860BB310, 0x5D01,
             0x11d0, 0xBD, 0x3B, 0x00, 0xA0, 0xC9, 0x11, 0xCE, 0x86);
DEFINE_GUID( CLSID_SystemDeviceEnum, 0x62BE5D10, 0x60EB, 0x11d0,
             0xBD, 0x3B, 0x00, 0xA0, 0xC9, 0x11, 0xCE, 0x86 );
DEFINE_GUID( CLSID_FilterGraph, 0xe436ebb3, 0x524f, 0x11ce,
             0x9f, 0x53, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70);
DEFINE_GUID( CLSID_SampleGrabber, 0xc1f400a0, 0x3f08, 0x11d3,
             0x9f, 0x0b, 0x00, 0x60, 0x08, 0x03, 0x9e, 0x37 );
DEFINE_GUID( CLSID_NullRenderer,0xc1f400a4, 0x3f08, 0x11d3,
             0x9f, 0x0b, 0x00, 0x60, 0x08, 0x03, 0x9e, 0x37 );
DEFINE_GUID( CLSID_VfwCapture, 0x1b544c22, 0xfd0b, 0x11ce,
             0x8c, 0x63, 0x0, 0xaa, 0x00, 0x44, 0xb5, 0x1e);
DEFINE_GUID( IID_IGraphBuilder, 0x56a868a9, 0x0ad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70);
DEFINE_GUID( IID_IBaseFilter, 0x56a86895, 0x0ad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );
DEFINE_GUID( IID_ICreateDevEnum, 0x29840822, 0x5b84, 0x11d0,
             0xbd, 0x3b, 0x00, 0xa0, 0xc9, 0x11, 0xce, 0x86 );
DEFINE_GUID( IID_IEnumFilters, 0x56a86893, 0xad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );
DEFINE_GUID( IID_IMediaSample, 0x56a8689a, 0x0ad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );
DEFINE_GUID( IID_ISampleGrabber, 0x6b652fff, 0x11fe, 0x4fce,
             0x92, 0xad, 0x02, 0x66, 0xb5, 0xd7, 0xc7, 0x8f );
DEFINE_GUID( IID_IMediaEvent, 0x56a868b6, 0x0ad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );
DEFINE_GUID( IID_IMediaControl, 0x56a868b1, 0x0ad4, 0x11ce,
             0xb0, 0x3a, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );
DEFINE_GUID( IID_IAMStreamConfig, 0xc6e13340, 0x30ac, 0x11d0,
             0xa1, 0x8c, 0x00, 0xa0, 0xc9, 0x11, 0x89, 0x56 );
DEFINE_GUID( IID_IVideoProcAmp, 0x4050560e, 0x42a7, 0x413a,
             0x85, 0xc2, 0x09, 0x26, 0x9a, 0x2d, 0x0f, 0x44 );
DEFINE_GUID( MEDIATYPE_Video, 0x73646976, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_I420, 0x30323449, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71);
DEFINE_GUID( MEDIASUBTYPE_YV12, 0x32315659, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_IYUV, 0x56555949, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_YUYV, 0x56595559, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_YUY2, 0x32595559, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_UYVY, 0x59565955, 0x0000, 0x0010,
             0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 );
DEFINE_GUID( MEDIASUBTYPE_RGB24, 0xe436eb7d, 0x524f, 0x11ce,
             0x9f, 0x53, 0x00, 0x20, 0xaf, 0x0b, 0xa7, 0x70 );

using namespace std;

typedef LONGLONG REFERENCE_TIME;

typedef struct tagVIDEOINFOHEADER {
        RECT rcSource;
        RECT rcTarget;
        DWORD dwBitRate;
        DWORD dwBitErrorRate;
        REFERENCE_TIME AvgTimePerFrame;
        BITMAPINFOHEADER bmiHeader;
} VIDEOINFOHEADER;

typedef struct _AMMediaType {
        GUID majortype;
        GUID subtype;
        BOOL bFixedSizeSamples;
        BOOL bTemporalCompression;
        ULONG lSampleSize;
        GUID formattype;
        IUnknown *pUnk;
        ULONG cbFormat;
        BYTE *pbFormat;
} AM_MEDIA_TYPE;

typedef struct _VIDEO_STREAM_CONFIG_CAPS
{
    GUID guid;
    ULONG VideoStandard;
    SIZE InputSize;
    SIZE MinCroppingSize;
    SIZE MaxCroppingSize;
    int CropGranularityX;
    int CropGranularityY;
    int CropAlignX;
    int CropAlignY;
    SIZE MinOutputSize;
    SIZE MaxOutputSize;
    int OutputGranularityX;
    int OutputGranularityY;
    int StretchTapsX;
    int StretchTapsY;
    int ShrinkTapsX;
    int ShrinkTapsY;
    LONGLONG MinFrameInterval;
    LONGLONG MaxFrameInterval;
    LONG MinBitsPerSecond;
    LONG MaxBitsPerSecond;
} VIDEO_STREAM_CONFIG_CAPS;

typedef LONGLONG REFERENCE_TIME;

typedef interface IBaseFilter IBaseFilter;
typedef interface IReferenceClock IReferenceClock;

typedef enum _FilterState {
        State_Stopped,
        State_Paused,
        State_Running
} FILTER_STATE;

typedef enum _PinDirection {
        PINDIR_INPUT,
        PINDIR_OUTPUT
} PIN_DIRECTION;

#define MAX_PIN_NAME 128
typedef struct _PinInfo {
        IBaseFilter *pFilter;
        PIN_DIRECTION dir;
        WCHAR achName[MAX_PIN_NAME];
} PIN_INFO;

#define INTERFACE IPin
DECLARE_INTERFACE_(IPin,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(Connect)(THIS_ IPin*,const AM_MEDIA_TYPE*) PURE;
   STDMETHOD(ReceiveConnection)(THIS_ IPin*,const AM_MEDIA_TYPE*) PURE;
   STDMETHOD(Disconnect)(THIS) PURE;
   STDMETHOD(ConnectedTo)(THIS_  IPin*) PURE;
   STDMETHOD(ConnectionMediaType)(THIS_ AM_MEDIA_TYPE*) PURE;
   STDMETHOD(QueryPinInfo)(THIS_ PIN_INFO*) PURE;
   STDMETHOD(QueryDirection)(THIS_ PIN_DIRECTION*) PURE;
};
#undef INTERFACE

DECLARE_ENUMERATOR_(IEnumPins,IPin*);

typedef LONG_PTR OAEVENT;

#define INTERFACE IMediaEvent
DECLARE_INTERFACE_(IMediaEvent,IDispatch)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(GetEventHandle)(THIS_ OAEVENT*) PURE;
   STDMETHOD(GetEvent)(THIS_ long*,LONG_PTR,LONG_PTR,long) PURE;
   STDMETHOD(WaitForCompletion)(THIS_ long,long*) PURE;
   STDMETHOD(CancelDefaultHandling)(THIS_ long) PURE;
   STDMETHOD(RestoreDefaultHandling)(THIS_ long) PURE;
   STDMETHOD(FreeEventParams)(THIS_ long,LONG_PTR,LONG_PTR) PURE;
};
#undef INTERFACE

typedef long OAFilterState;

#define INTERFACE IMediaControl
DECLARE_INTERFACE_(IMediaControl,IDispatch)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(Run)(THIS) PURE;
   STDMETHOD(Pause)(THIS) PURE;
   STDMETHOD(Stop)(THIS) PURE;
   STDMETHOD(GetState)(THIS_ LONG,OAFilterState*) PURE;
   STDMETHOD(RenderFile)(THIS_ BSTR) PURE;
   STDMETHOD(AddSourceFilter)(THIS_ BSTR,IDispatch**) PURE;
   STDMETHOD(get_FilterCollection)(THIS_ IDispatch**) PURE;
   STDMETHOD(get_RegFilterCollection)(THIS_ IDispatch**) PURE;
   STDMETHOD(StopWhenReady)(THIS) PURE;
};
#undef INTERFACE

#define INTERFACE IVideoProcAmp
DECLARE_INTERFACE_(IVideoProcAmp,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
};
#undef INTERFACE

#define INTERFACE IAMStreamConfig
DECLARE_INTERFACE_(IAMStreamConfig,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(SetFormat)(THIS_ AM_MEDIA_TYPE*) PURE;
   STDMETHOD(GetFormat)(THIS_ AM_MEDIA_TYPE**) PURE;
   STDMETHOD(GetNumberOfCapabilities)(THIS_ int*,int*) PURE;
   STDMETHOD(GetStreamCaps)(THIS_ int,AM_MEDIA_TYPE**,BYTE*) PURE;
};
#undef INTERFACE

#define INTERFACE IMediaFilter
DECLARE_INTERFACE_(IMediaFilter,IPersist)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(Stop)(THIS) PURE;
   STDMETHOD(Pause)(THIS) PURE;
   STDMETHOD(Run)(THIS_ REFERENCE_TIME) PURE;
   STDMETHOD(GetState)(THIS_ DWORD,FILTER_STATE*) PURE;
   STDMETHOD(SetSyncSource)(THIS_ IReferenceClock*) PURE;
   STDMETHOD(GetSyncSource)(THIS_ IReferenceClock**) PURE;
};
#undef INTERFACE

#define INTERFACE IBaseFilter
DECLARE_INTERFACE_(IBaseFilter,IMediaFilter)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(EnumPins)(THIS_ IEnumPins**) PURE;
};
#undef INTERFACE

#define INTERFACE IEnumFilters
DECLARE_INTERFACE_(IEnumFilters,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(Next)(THIS_ ULONG,IBaseFilter**,ULONG*) PURE;
   STDMETHOD(Skip)(THIS_ ULONG) PURE;
   STDMETHOD(Reset)(THIS) PURE;
   STDMETHOD(Clone)(THIS_ IEnumFilters**) PURE;
};
#undef INTERFACE

#define INTERFACE IFilterGraph
DECLARE_INTERFACE_(IFilterGraph,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(AddFilter)(THIS_ IBaseFilter*,LPCWSTR) PURE;
   STDMETHOD(RemoveFilter)(THIS_ IBaseFilter*) PURE;
   STDMETHOD(EnumFilters)(THIS_ IEnumFilters**) PURE;
   STDMETHOD(FindFilterByName)(THIS_ LPCWSTR,IBaseFilter**) PURE;
   STDMETHOD(ConnectDirect)(THIS_ IPin*,IPin*,const AM_MEDIA_TYPE*) PURE;
   STDMETHOD(Reconnect)(THIS_ IPin*) PURE;
   STDMETHOD(Disconnect)(THIS_ IPin*) PURE;
   STDMETHOD(SetDefaultSyncSource)(THIS) PURE;
};
#undef INTERFACE

#define INTERFACE IGraphBuilder
DECLARE_INTERFACE_(IGraphBuilder,IFilterGraph)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(Connect)(THIS_ IPin*,IPin*) PURE;
   STDMETHOD(Render)(THIS_ IPin*) PURE;
   STDMETHOD(RenderFile)(THIS_ LPCWSTR,LPCWSTR) PURE;
   STDMETHOD(AddSourceFilter)(THIS_ LPCWSTR,LPCWSTR,IBaseFilter**) PURE;
   STDMETHOD(SetLogFile)(THIS_ DWORD_PTR) PURE;
   STDMETHOD(Abort)(THIS) PURE;
};
#undef INTERFACE

#define INTERFACE ICreateDevEnum
DECLARE_INTERFACE_(ICreateDevEnum,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(CreateClassEnumerator)(THIS_ REFIID,IEnumMoniker**,DWORD);
};
#undef INTERFACE

#define INTERFACE IMediaSample
DECLARE_INTERFACE_(IMediaSample,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
};
#undef INTERFACE

#define INTERFACE ISampleGrabberCB
DECLARE_INTERFACE_(ISampleGrabberCB,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(SampleCB)(THIS_ double,IMediaSample*);
   STDMETHOD(BufferCB)(THIS_ double,BYTE*,long);
};
#undef INTERFACE

#define INTERFACE ISampleGrabber
DECLARE_INTERFACE_(ISampleGrabber,IUnknown)
{
   STDMETHOD(QueryInterface)(THIS_ REFIID,PVOID*) PURE;
   STDMETHOD_(ULONG,AddRef)(THIS) PURE;
   STDMETHOD_(ULONG,Release)(THIS) PURE;
   STDMETHOD(SetOneShot)(THIS_ BOOL);
   STDMETHOD(SetMediaType)(THIS_ const AM_MEDIA_TYPE*);
   STDMETHOD(GetConnectedMediaType)(THIS_ AM_MEDIA_TYPE*);
   STDMETHOD(SetBufferSamples)(THIS_ BOOL);
   STDMETHOD(GetCurrentBuffer)(THIS_ long*,long*);
   STDMETHOD(GetCurrentSample)(THIS_ IMediaSample**);
   STDMETHOD(SetCallBack)(THIS_ ISampleGrabberCB *,long);
};
#undef INTERFACE

HRESULT GetPin( IBaseFilter *pFilter, PIN_DIRECTION direction, int iNum,
                IPin **ppPin )
{
  cerr << "Get pin enumerator" << endl;
  IEnumPins *pEnum;
  HRESULT hr = pFilter->EnumPins( &pEnum );
  if ( hr == S_OK ) {
    ULONG ulFound;
    IPin *pPin;
    *ppPin = NULL;
    hr = E_FAIL;
    cerr << "Iterating through pins" << endl;
    while ( S_OK == pEnum->Next( 1, &pPin, &ulFound ) ) {
      PIN_DIRECTION pindir = (PIN_DIRECTION)( 1 - direction );
      cerr << "Querying direction of pin" << endl;
      pPin->QueryDirection( &pindir );
      if ( pindir == direction ) {
        if ( iNum == 0 ) {
          *ppPin = pPin;
          hr = S_OK;
          break;
        };
        iNum--;
      };
      pPin->Release();
    };
    pEnum->Release();
  } else
    cerr << "Failed to retrieve pin enumerator" << endl;
  return hr;
}

using namespace std;

#define ERRORMACRO2( condition, class, params, message )                      \
  {                                                                           \
    HRESULT hr = condition;                                                   \
    if ( FAILED( hr ) ) {                                                     \
      class _e params;                                                        \
      _e << message;                                                          \
      TCHAR *msg;                                                             \
      if ( FormatMessage( FORMAT_MESSAGE_ALLOCATE_BUFFER |                    \
                          FORMAT_MESSAGE_FROM_SYSTEM, 0, hr, 0, (LPTSTR)&msg, \
                          0, NULL ) != 0 ) {                                  \
        _e << ": " << msg << endl;                                     \
        LocalFree( msg );                                                     \
      };                                                                      \
      throw _e;                                                               \
    };                                                                        \
  };


int main(void)
{
  int retVal = 0;
  bool initialized = false;
  IGraphBuilder *pGraph = NULL;
  ICreateDevEnum *pCreateDevEnum = NULL;
  IEnumMoniker *pEm = NULL;
  IMoniker *pM = NULL;
  IBaseFilter *pSource = NULL;
  IVideoProcAmp *pAmp = NULL;
  IAMStreamConfig *pStreamConfig = NULL;
  IPin *pSourceOut = NULL;
  IBaseFilter *pGrabberBase = NULL;
  ISampleGrabber *pGrabber = NULL;
  IPin *pGrabberIn = NULL;
  IPin *pGrabberOut = NULL;
  IBaseFilter *pNull = NULL;
  IPin *pNullIn = NULL;
  IMediaControl *pControl = NULL;
  IMediaEvent *pEvent = NULL;
  VIDEO_STREAM_CONFIG_CAPS *pSCC = NULL;
  try {
    ERRORMACRO2( CoInitialize(NULL), Error, , "CoInitialize failed" );
    initialized = true;
    // CComPtr< IGraphBuilder > pGraph;
    // pGraph.CoCreateInstance( CLSID_FilterGraph );
    cerr << "Requesting filter graph builder" << endl;
    ERRORMACRO2( CoCreateInstance( CLSID_FilterGraph, NULL, CLSCTX_INPROC,
                                  IID_IGraphBuilder, (void **)&pGraph ),
                 Error, , "Could not get filter graph builder" );
    cerr << "Requesting device enumerator" << endl;
    ERRORMACRO2( CoCreateInstance( CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC,
                                  IID_ICreateDevEnum,
                                  (void **)&pCreateDevEnum ),
                Error, , "Could not get device enumerator" );
    cerr << "Requesting moniker enumerator" << endl;
    ERRORMACRO2( pCreateDevEnum->CreateClassEnumerator
                ( CLSID_VideoInputDeviceCategory, &pEm, 0 ), Error, ,
                "Error requesting moniker enumerator" );
    cerr << "Resetting moniker enumerator" << endl;
    ERRORMACRO2( pEm->Reset(), Error, ,
                "Error resetting moniker enumerator" );
    cerr << "Fetching moniker" << endl;
    ULONG ulFetched = 0;
    ERRORMACRO2( pEm->Next( 1, &pM, &ulFetched ), Error, ,
                "Error fetching moniker" );
    cerr << "Bind moniker to object" << endl;
    ERRORMACRO2( pM->BindToObject( 0, 0, IID_IBaseFilter,
                (void **)&pSource ), Error, ,
                "Error binding moniker to object" );
    CLSID clsid;
    ERRORMACRO2( pSource->GetClassID( &clsid ), Error, ,
                "Error getting class id" );
    if ( clsid == CLSID_VfwCapture )
      cerr << "This is an interface to Video for Windows (VFW)" << endl;
    else
      cerr << "This seems to be a DirectShow capture source" << endl;
    cerr << "Adding camera to filter graph" << endl;
    ERRORMACRO2( pGraph->AddFilter( pSource, L"Source" ), Error, ,
                "Error adding camera source to filter graph" );
    cerr << "Get output pin of camera" << endl;
    ERRORMACRO2( GetPin( pSource, PINDIR_OUTPUT, 0, &pSourceOut ),
                Error, , "Error getting output pin of camera" );
    cerr << "Requesting stream configuration API" << endl;
    ERRORMACRO2( pSourceOut->QueryInterface( IID_IAMStreamConfig,
                                            (void **)&pStreamConfig ),
                Error, , "Error requesting stream configuration API" );
    cerr << "Requesting number of capabilities" << endl;
    int piCount, piSize;
    ERRORMACRO2( pStreamConfig->GetNumberOfCapabilities( &piCount, &piSize ),
                 Error, , "Error getting number of capabilities" );
    cerr << "There are " << piCount << " stream capabilities" << endl;
    int width = 0;
    int height = 0;
    for ( int i=0; i<piCount; i++ ) {
      cerr << "Allocating shared memory" << endl;
      pSCC = (VIDEO_STREAM_CONFIG_CAPS *)CoTaskMemAlloc( piSize );
      AM_MEDIA_TYPE *mediaType;
      cerr << "Requesting stream capabilities of option " << i << endl;
      ERRORMACRO2( pStreamConfig->GetStreamCaps( i, &mediaType, (BYTE *)pSCC ),
                  Error, , "Error getting stream capabilities" );
      if ( mediaType->majortype == MEDIATYPE_Video &&
           mediaType->cbFormat != 0 ) {
        VIDEOINFOHEADER *infoHeader = (VIDEOINFOHEADER*)mediaType->pbFormat;
        const char *colourSpace;
        if ( mediaType->subtype == MEDIASUBTYPE_I420 )
          colourSpace = "I420";
        else if ( mediaType->subtype == MEDIASUBTYPE_YV12 )
          colourSpace = "YV12";
        else if ( mediaType->subtype == MEDIASUBTYPE_IYUV )
          colourSpace = "YV12";
        else if ( mediaType->subtype == MEDIASUBTYPE_YUYV )
          colourSpace = "YUY2";
        else if ( mediaType->subtype == MEDIASUBTYPE_YUY2 )
          colourSpace = "YUY2";
        else if ( mediaType->subtype == MEDIASUBTYPE_UYVY )
          colourSpace = "UYVY";
        else if ( mediaType->subtype == MEDIASUBTYPE_RGB24 )
          colourSpace = "RGB24";
        else
          colourSpace = "Unknown";
        cerr << infoHeader->bmiHeader.biWidth << 'x'
             << infoHeader->bmiHeader.biHeight << ' ' << colourSpace << endl;
        if ( mediaType->subtype == MEDIASUBTYPE_RGB24 &&
             infoHeader->bmiHeader.biWidth > width &&
             infoHeader->bmiHeader.biHeight > height ) {
          width = infoHeader->bmiHeader.biWidth;
          height = infoHeader->bmiHeader.biHeight;
          pStreamConfig->SetFormat( mediaType );
        };
      };
      if ( mediaType->cbFormat != 0 )
        CoTaskMemFree( (PVOID)mediaType->pbFormat );
      if ( mediaType->pUnk != NULL ) mediaType->pUnk->Release();
      CoTaskMemFree( (PVOID)mediaType );
    };
    cerr << "Creating sample grabber" << endl;
    ERRORMACRO2( CoCreateInstance( CLSID_SampleGrabber, NULL,
                                   CLSCTX_INPROC, IID_IBaseFilter,
                                   (void **)&pGrabberBase ),
                Error, , "Error creating sample grabber" );
    cerr << "Add grabber filter" << endl;
    ERRORMACRO2( pGraph->AddFilter( pGrabberBase, L"Grabber" ),
                Error, , "Error adding sample grabber to filter graph" );
    cerr << "Requesting sample grabber interface" << endl;
    ERRORMACRO2( pGrabberBase->QueryInterface( IID_ISampleGrabber,
                                              (void **)&pGrabber ),
                Error, , "Error requesting sample grabber interface" );
    /* AM_MEDIA_TYPE mt;
    memset( &mt, 0, sizeof(mt) );
    mt.majortype = MEDIATYPE_Video;
    mt.subtype = MEDIASUBTYPE_I420;
    pGrabber->SetMediaType( &mt ); */
    pGrabber->SetOneShot( TRUE );
    pGrabber->SetBufferSamples( TRUE ); // TRUE !!!
    cerr << "Creating null renderer" << endl;
    ERRORMACRO2( CoCreateInstance( CLSID_NullRenderer, NULL,
                                   CLSCTX_INPROC, IID_IBaseFilter,
                                   (void **)&pNull ),
                Error, , "Error creating Null Renderer" );
    cerr << "Add null filter" << endl;
    ERRORMACRO2( pGraph->AddFilter( pNull, L"Sink" ), Error, ,
                "Error adding null sink to filter graph" );
    cerr << "Requesting control interface" << endl;
    ERRORMACRO2( pGraph->QueryInterface( IID_IMediaControl,
                                        (void **)&pControl ),
                Error, , "Error requesting control interface" );
    cerr << "Requesting event interface" << endl;
    ERRORMACRO2( pGraph->QueryInterface( IID_IMediaEvent,
                                        (void **)&pEvent ),
                Error, , "Error requesting event interface" );
    cerr << "Get input pin of grabber" << endl;
    ERRORMACRO2( GetPin( pGrabberBase, PINDIR_INPUT, 0, &pGrabberIn ),
                Error, , "Error requesting input pin of grabber" );
    cerr << "Connecting input pin of grabber" << endl;
    ERRORMACRO2( pGraph->Connect( pSourceOut, pGrabberIn ),
                Error, , "Error connecting input pin of grabber" );
    cerr << "Get output pin of grabber" << endl;
    ERRORMACRO2( GetPin( pGrabberBase, PINDIR_OUTPUT, 0, &pGrabberOut ),
                 Error, , "Error requesting output pin of grabber" );
    cerr << "Get input pin of null renderer" << endl;
    ERRORMACRO2( GetPin( pNull, PINDIR_INPUT, 0, &pNullIn ),
                 Error, , "Error requesting input pin of grabber" );
    cerr << "Connecting output pin of grabber" << endl;
    ERRORMACRO2( pGraph->Connect( pGrabberOut, pNullIn ),
                 Error, , "Error connecting output pin of grabber" );
    cerr << "Running graph" << endl;
    ERRORMACRO2( pControl->Run(), Error, ,
                "Error running control graph" );
    long EvCode = 0;
    cerr << "Waiting for completion" << endl;
    ERRORMACRO2( pEvent->WaitForCompletion( INFINITE, &EvCode ),
                Error, , "Error waiting for completion" );
    long bufferSize = 0;
    ERRORMACRO2( pGrabber->GetCurrentBuffer( &bufferSize, NULL ),
                Error, , "Error requesting buffer size" );
    cerr << "Buffer size is " << bufferSize << endl;
    boost::shared_array< char > buffer( new char[bufferSize] );
    ERRORMACRO2( pGrabber->GetCurrentBuffer( &bufferSize,
                                            (long *)buffer.get() ),
                Error, , "Error requesting buffer" );
    AM_MEDIA_TYPE mediaType;
    pGrabber->GetConnectedMediaType( &mediaType );
    VIDEOINFOHEADER *infoHeader = (VIDEOINFOHEADER*)mediaType.pbFormat;
    cerr << infoHeader->bmiHeader.biWidth << 'x'
         << infoHeader->bmiHeader.biHeight << endl;
    ofstream f( "test.ppm", ios::binary );
    f << "P6" << endl
      << infoHeader->bmiHeader.biWidth << ' '
      << infoHeader->bmiHeader.biHeight << endl
      << 255 << endl;
    f.write( buffer.get(), bufferSize );
  } catch ( Error &e ) {
    cerr << e.what() << endl;
    retVal = 1;
  };
  if ( pSCC != NULL ) CoTaskMemFree( (PVOID)pSCC );
  if ( pControl != NULL ) pControl->Release();
  if ( pNull != NULL ) pNull->Release();
  if ( pGrabberOut != NULL ) pGrabberOut->Release();
  if ( pGrabberIn != NULL ) pGrabberIn->Release();
  if ( pGrabber != NULL ) pGrabber->Release();
  if ( pGrabberBase != NULL ) pGrabberBase->Release();
  if ( pSourceOut != NULL ) pSourceOut->Release();
  if ( pAmp != NULL ) pAmp->Release();
  if ( pSource != NULL ) pSource->Release();
  if ( pM != NULL ) pM->Release();
  if ( pEm != NULL ) pEm->Release();
  if ( pCreateDevEnum != NULL ) pCreateDevEnum->Release();
  if ( pGraph != NULL ) pGraph->Release();
  if ( initialized ) CoUninitialize();
  return retVal;
}

