//----------------------------------------------------------------------------
// File: YuvGray.cpp
//
// Description: 
// YuvGray is a DirectShow transform filter that converts UYVY color images
// to grayscale.
//-----------------------------------------------------------------------------


#ifdef _DEBUG
#ifndef DEBUG
#define DEBUG
#endif
#endif

#include <streams.h>  // DirectShow base class library

#include <aviriff.h>  // defines 'FCC' macro


// Forward declares
void GetVideoInfoParameters(
    const VIDEOINFOHEADER *pvih, // Pointer to the format header.
    BYTE  * const pbData,        // Pointer to the first address in the buffer.
    DWORD *pdwWidth,         // Returns the width in pixels.
    DWORD *pdwHeight,        // Returns the height in pixels.
    LONG  *plStrideInBytes,  // Add this to a row to get the new row down
    BYTE **ppbTop,           // Returns pointer to the first byte in the top row of pixels.
    bool bYuv
    );


bool IsValidUYVY(const CMediaType *pmt);


// Define the filter's CLSID

// {A6512C9F-A47B-45ba-A054-0DB0D4BB87F7}
static const GUID CLSID_YuvGray = 
{ 0xa6512c9f, 0xa47b, 0x45ba, { 0xa0, 0x54, 0xd, 0xb0, 0xd4, 0xbb, 0x87, 0xf7 } };


static const WCHAR g_wszName[] = L"YUV Filter";   // A name for the filter 



//----------------------------------------------------------------------------
// CYuvGray Class
//
// This class defines the filter. It inherits CTransformFilter, which is a 
// base class for copy-transform filters. 
//-----------------------------------------------------------------------------

class CYuvGray : public CTransformFilter
{
public:

    // ctor
    CYuvGray(LPUNKNOWN pUnk, HRESULT *phr) :
        CTransformFilter(NAME("YUV Transform Filter"), pUnk, CLSID_YuvGray)
        {}

    // Overridden CTransformFilter methods
    HRESULT CheckInputType(const CMediaType *mtIn);
    HRESULT CheckTransform(const CMediaType *mtIn, const CMediaType *mtOut);
    HRESULT DecideBufferSize(IMemAllocator *pAlloc, ALLOCATOR_PROPERTIES *pProp);
    HRESULT GetMediaType(int iPosition, CMediaType *pMediaType);
    HRESULT Transform(IMediaSample *pIn, IMediaSample *pOut);

    // Override this so we can grab the video format
    HRESULT SetMediaType(PIN_DIRECTION direction, const CMediaType *pmt);

    // Static object-creation method (for the class factory)
    static CUnknown * WINAPI CreateInstance(LPUNKNOWN pUnk, HRESULT *pHr); 

private:
    HRESULT ProcessFrame(BYTE *pbInput, BYTE *pbOutput, long *pcbByte);

    VIDEOINFOHEADER m_VihIn;   // Holds the current video format (input)
    VIDEOINFOHEADER m_VihOut;  // Holds the current video format (output)

};



//----------------------------------------------------------------------------
// CYuvGray::CheckInputType
//
// Examine a proposed input type. Returns S_OK if we can accept his input type
// or VFW_E_TYPE_NOT_ACCEPTED otherwise. This filter accepts UYVY types only.
//-----------------------------------------------------------------------------

HRESULT CYuvGray::CheckInputType(const CMediaType *pmt)
{

    if (IsValidUYVY(pmt))
    {
        return S_OK;
    }
    else
    {
        return VFW_E_TYPE_NOT_ACCEPTED;
    }
}



//----------------------------------------------------------------------------
// CYuvGray::CheckTransform
//
// Compare an input type with an output type, and see if we can convert from 
// one to the other. The input type is known to be OK from ::CheckInputType,
// so this is really a check on the output type.
//-----------------------------------------------------------------------------


HRESULT CYuvGray::CheckTransform(const CMediaType *mtIn, const CMediaType *mtOut)
{

    if (!IsValidUYVY(mtOut))
    {
        return VFW_E_TYPE_NOT_ACCEPTED;
    }


    BITMAPINFOHEADER *pBmi = HEADER(mtIn);
    BITMAPINFOHEADER *pBmi2 = HEADER(mtOut);

    if ((pBmi->biWidth <= pBmi2->biWidth) &&
        (pBmi->biHeight == abs(pBmi2->biHeight)))
    {
       return S_OK;
    }
    return VFW_E_TYPE_NOT_ACCEPTED;

}


//----------------------------------------------------------------------------
// CYuvGray::GetMediaType
//
// Return an output type that we like, in order of preference, by index number.
//
// iPosition: index number
// pMediaType: Write the media type into this object.
//-----------------------------------------------------------------------------

HRESULT CYuvGray::GetMediaType(int iPosition, CMediaType *pMediaType)
{
    // The output pin calls this method only if the input pin is connected.
    ASSERT(m_pInput->IsConnected());

    // There is only one output type that we want, which is the input type.

    if (iPosition < 0)
    {
        return E_INVALIDARG;
    }
    else if (iPosition == 0)
    {
        return m_pInput->ConnectionMediaType(pMediaType);
    }
    return VFW_S_NO_MORE_ITEMS;
}



//----------------------------------------------------------------------------
// CYuvGray::DecideBufferSize
//
// Decide the buffer size and other allocator properties, for the downstream
// allocator.
//
// pAlloc: Pointer to the allocator. 
// pProp: Contains the downstream filter's request (or all zeroes)
//-----------------------------------------------------------------------------

HRESULT CYuvGray::DecideBufferSize(IMemAllocator *pAlloc, ALLOCATOR_PROPERTIES *pProp)
{
    // Make sure the input pin connected.
    if (!m_pInput->IsConnected()) 
    {
        return E_UNEXPECTED;
    }

    // Our strategy here is to use the upstream allocator as the guideline, but
    // also defer to the downstream filter's request when it's compatible with us.

    // First, find the upstream allocator...
    ALLOCATOR_PROPERTIES InputProps;

    IMemAllocator *pAllocInput = 0;
    HRESULT hr = m_pInput->GetAllocator(&pAllocInput);

    if (FAILED(hr))
    {
        return hr;
    }

    // ... now get the properters

    hr = pAllocInput->GetProperties(&InputProps);
    pAllocInput->Release();

    if (FAILED(hr)) 
    {
        return hr;
    }

    // Buffer alignment should be non-zero [zero alignment makes no sense!]
    if (pProp->cbAlign == 0)
    {
        pProp->cbAlign = 1;
    }

    // Number of buffers must be non-zero
    if (pProp->cbBuffer == 0)
    {
        pProp->cBuffers = 1;
    }

    // For buffer size, find the maximum of the upstream size and 
    // the downstream filter's request.
    pProp->cbBuffer = max(InputProps.cbBuffer, pProp->cbBuffer);

   
    // Now set the properties on the allocator that was given to us,
    ALLOCATOR_PROPERTIES Actual;
    hr = pAlloc->SetProperties(pProp, &Actual);
    if (FAILED(hr)) 
    {
        return hr;
    }
    
    // Even if SetProperties succeeds, the actual properties might be
    // different than what we asked for. We check the result, but we only
    // look at the properties that we care about. The downstream filter
    // will look at them when NotifyAllocator is called.
    
    if (InputProps.cbBuffer > Actual.cbBuffer) 
    {
        return E_FAIL;
    }
    
    return S_OK;
}



//----------------------------------------------------------------------------
// CYuvGray::SetMediaType
//
// The CTransformFilter class calls this method when the media type is 
// set on either pin. This gives us a chance to grab the format block. 
//
// direction: Which pin (input or output) 
// pmt: The media type that is being set.
//
// Note: If the pins were friend classes of the filter, we could access the
// connection type directly. But this is easier than sub-classing the pins.
//-----------------------------------------------------------------------------

HRESULT CYuvGray::SetMediaType(PIN_DIRECTION direction, const CMediaType *pmt)
{
    if (direction == PINDIR_INPUT)
    {
        ASSERT(pmt->formattype == FORMAT_VideoInfo);
        VIDEOINFOHEADER *pVih = (VIDEOINFOHEADER*)pmt->pbFormat;

        // WARNING! In general you cannot just copy a VIDEOINFOHEADER
        // struct, because the BITMAPINFOHEADER member may be followed by
        // random amounts of palette entries or color masks. (See VIDEOINFO
        // structure in the DShow SDK docs.) Here it's OK because we just
        // want the information that's in the VIDEOINFOHEADER stuct itself.

        CopyMemory(&m_VihIn, pVih, sizeof(VIDEOINFOHEADER));
    }
    else   // output pin
    {
        ASSERT(direction == PINDIR_OUTPUT);
        ASSERT(pmt->formattype == FORMAT_VideoInfo);
        VIDEOINFOHEADER *pVih = (VIDEOINFOHEADER*)pmt->pbFormat;


        CopyMemory(&m_VihOut, pVih, sizeof(VIDEOINFOHEADER));
    }

    return S_OK;
}



//----------------------------------------------------------------------------
// CYuvGray::Transform
//
// Transform the image.
//
// pSource: Contains the source image.
// pDest:   Write the transformed image here.
//-----------------------------------------------------------------------------


HRESULT CYuvGray::Transform(IMediaSample *pSource, IMediaSample *pDest)
{
    // Note: The filter has already set the sample properties on pOut,
    // (see CTransformFilter::InitializeOutputSample).
    // You can override the timestamps if you need - but not in our case.


    // The filter already locked m_csReceive so we're OK.


    // Look for format changes from the video renderer.
    CMediaType *pmt = 0;
    if (S_OK == pDest->GetMediaType((AM_MEDIA_TYPE**)&pmt) && pmt)
    {

        // Notify our own output pin about the new type.
        m_pOutput->SetMediaType(pmt);
        DeleteMediaType(pmt);
    }


    // Get the addresses of the actual bufffers.
    BYTE *pBufferIn, *pBufferOut;

    pSource->GetPointer(&pBufferIn);
    pDest->GetPointer(&pBufferOut);

    long cbByte = 0;

    // Process the buffers
    HRESULT hr = ProcessFrame(pBufferIn, pBufferOut, &cbByte);

    // Set the size of the destination image.

    ASSERT(pDest->GetSize() >= cbByte);
    
    pDest->SetActualDataLength(cbByte);

    return hr;
}




//----------------------------------------------------------------------------
// CYuvGray::ProcessFrame
//
// Private method to process one frame.
//
// pbInput:  Pointer to the buffer that holds the image.
// pbOutput: Write the transformed image here.
// pcbBytes: Receives the number of bytes written.
//-----------------------------------------------------------------------------

HRESULT CYuvGray::ProcessFrame(BYTE *pbInput, BYTE *pbOutput, long *pcbByte)
{

    DWORD dwWidth, dwHeight;      // Width and height in pixels
    LONG  lStrideIn, lStrideOut;  // Stride in bytes
    BYTE  *pbSource, *pbTarget;   // First byte in first row, for source and target.

    *pcbByte = m_VihOut.bmiHeader.biSizeImage;

    GetVideoInfoParameters(&m_VihIn, pbInput, &dwWidth, &dwHeight, &lStrideIn, &pbSource, true);
    GetVideoInfoParameters(&m_VihOut, pbOutput, &dwWidth, &dwHeight, &lStrideOut, &pbTarget, true);

    // You could optimize this slightly by storing these values when the
    // media type is set, instead of re-calculating them for each frame.

    for (DWORD y = 0; y < dwHeight; y++)
    {
        WORD *pwTarget = (WORD*)pbTarget;
        WORD *pwSource = (WORD*)pbSource;

        for (DWORD x = 0; x < dwWidth; x++)
        {

            // Each WORD is a 'UY' or 'VY' block. 
            // Set the low byte (chroma) to 0x80 and leave the high byte (luma)

            WORD pixel = pwSource[x] & 0xFF00;
            pixel |= 0x0080;
            pwTarget[x] = pixel;
        }

        // Advance the stride on both buffers.

        pbTarget += lStrideOut;
        pbSource += lStrideIn;
    }

    return S_OK;

}



// COM stuff


//----------------------------------------------------------------------------
// CYuvGray::CreateInstance
//
// Static method that returns a new instance of our filter.
// Note: The DirectShow class factory object needs this method.
//
// pUnk: Pointer to the controlling IUnknown (usually NULL)
// pHR:  Set this to an error code, if an error occurs
//-----------------------------------------------------------------------------

CUnknown * WINAPI CYuvGray::CreateInstance(LPUNKNOWN pUnk, HRESULT *pHR) 
{
    CYuvGray *pFilter = new CYuvGray(pUnk, pHR );
    if (pFilter == NULL) 
    {
        *pHR = E_OUTOFMEMORY;
    }
    return pFilter;
} 


// The next bunch of structures define information for the class factory.

AMOVIESETUP_FILTER FilterInfo =
{
    &CLSID_YuvGray,     // CLSID
    g_wszName,          // Name
    MERIT_DO_NOT_USE,   // Merit
    0,                  // Number of AMOVIESETUP_PIN structs
    NULL                // Pin registration information.
};


CFactoryTemplate g_Templates[1] = 
{
    { 
      g_wszName,                // Name
      &CLSID_YuvGray,           // CLSID
      CYuvGray::CreateInstance, // Method to create an instance of MyComponent
      NULL,                     // Initialization function
      &FilterInfo               // Set-up information (for filters)
    }
};
int g_cTemplates = sizeof(g_Templates) / sizeof(g_Templates[0]);    


// Functions needed by the DLL, for registration.

STDAPI DllRegisterServer(void)
{
    return AMovieDllRegisterServer2(TRUE);
}


STDAPI DllUnregisterServer()
{
    return AMovieDllRegisterServer2(FALSE);
}







//----------------------------------------------------------------------------
// GetVideoInfoParameters
//
// Helper function to get the important information out of a VIDEOINFOHEADER
//
//-----------------------------------------------------------------------------

void GetVideoInfoParameters(
    const VIDEOINFOHEADER *pvih, // Pointer to the format header.
    BYTE  * const pbData,        // Pointer to the first address in the buffer.
    DWORD *pdwWidth,         // Returns the width in pixels.
    DWORD *pdwHeight,        // Returns the height in pixels.
    LONG  *plStrideInBytes,  // Add this to a row to get the new row down
    BYTE **ppbTop,           // Returns pointer to the first byte in the top row of pixels.
    bool bYuv
    )
{
    LONG lStride;


    //  For 'normal' formats, biWidth is in pixels. 
    //  Expand to bytes and round up to a multiple of 4.
    if (pvih->bmiHeader.biBitCount != 0 &&
        0 == (7 & pvih->bmiHeader.biBitCount)) 
    {
        lStride = (pvih->bmiHeader.biWidth * (pvih->bmiHeader.biBitCount / 8) + 3) & ~3;
    } 
    else   // Otherwise, biWidth is in bytes.
    {
        lStride = pvih->bmiHeader.biWidth;
    }

    //  If rcTarget is empty, use the whole image.
    if (IsRectEmpty(&pvih->rcTarget)) 
    {
        *pdwWidth = (DWORD)pvih->bmiHeader.biWidth;
        *pdwHeight = (DWORD)(abs(pvih->bmiHeader.biHeight));
        
        if (pvih->bmiHeader.biHeight < 0 || bYuv)   // Top-down bitmap. 
        {
            *plStrideInBytes = lStride; // Stride goes "down"
            *ppbTop           = pbData; // Top row is first.
        } 
        else        // Bottom-up bitmap
        {
            *plStrideInBytes = -lStride;    // Stride goes "up"
            *ppbTop = pbData + lStride * (*pdwHeight - 1);  // Bottom row is first.
        }
    } 
    else   // rcTarget is NOT empty. Use a sub-rectangle in the image.
    {
        *pdwWidth = (DWORD)(pvih->rcTarget.right - pvih->rcTarget.left);
        *pdwHeight = (DWORD)(pvih->rcTarget.bottom - pvih->rcTarget.top);
        
        if (pvih->bmiHeader.biHeight < 0 || bYuv)   // Top-down bitmap.
        {
            // Same stride as above, but first pixel is modified down
            // and and over by the target rectangle.
            *plStrideInBytes = lStride;     
            *ppbTop = pbData +
                     lStride * pvih->rcTarget.top +
                     (pvih->bmiHeader.biBitCount * pvih->rcTarget.left) / 8;
        } 
        else  // Bottom-up bitmap.
        {
            *plStrideInBytes = -lStride;
            *ppbTop = pbData +
                     lStride * (pvih->bmiHeader.biHeight - pvih->rcTarget.top - 1) +
                     (pvih->bmiHeader.biBitCount * pvih->rcTarget.left) / 8;
        }
    }
}





bool IsValidUYVY(const CMediaType *pmt)
{

    // Note: The pmt->formattype member indicates what kind of data
    // structure is contained in pmt->pbFormat. But it's important
    // to check that pbFormat is non-NULL and the size (cbFormat) is
    // what we think it is. 


    if ((pmt->majortype == MEDIATYPE_Video) &&
        (pmt->subtype == MEDIASUBTYPE_UYVY) &&
        (pmt->formattype == FORMAT_VideoInfo) &&
        (pmt->pbFormat != NULL) &&
        (pmt->cbFormat >= sizeof(VIDEOINFOHEADER)))
    {
        VIDEOINFOHEADER *pVih = reinterpret_cast<VIDEOINFOHEADER*>(pmt->pbFormat);
        BITMAPINFOHEADER *pBmi = &(pVih->bmiHeader);

        // Sanity check
        if ((pBmi->biBitCount = 16) &&
            (pBmi->biCompression = FCC('UYVY')) &&
            (pBmi->biSizeImage >= DIBSIZE(*pBmi)))
        {
            return true;
        }


        // Note: The DIBSIZE macro calculates the real size of the bitmap,
        // taking DWORD alignment into account. For YUV formats, this works
        // only when the bitdepth is an even power of 2, not for all YUV types.

    }



    return false;
}





