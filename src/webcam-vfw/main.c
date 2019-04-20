#include <stdio.h>
#include <stdbool.h>

#include <windows.h>
#include <vfw.h>

int main(int argc, char *argv[])
{
//    HWND hWnd = capCreateCaptureWindow(
//        "CaptureWindow1",
//        WS_CHILD | WS_VISIBLE,
//        9, 17, 320, 240, 0, 0);

//    capDriverConnect (hWnd, 0);

//    CAPTUREPARMS cp;
//    CAPSTATUS cs;
//    CAPDRIVERCAPS cds;

//    ZeroMemory(&cp, sizeof(CAPTUREPARMS));
//    capCaptureGetSetup(hWnd, &cp, sizeof(CAPTUREPARMS));
//    cp.dwRequestMicroSecPerFrame = 40000;
//    cp.fYield = TRUE;
//    cp.fCaptureAudio = FALSE;
//    cp.fLimitEnabled = FALSE;
//    cp.vKeyAbort = 0;
//    cp.fAbortLeftMouse = FALSE;
//    cp.fAbortRightMouse = FALSE;
//    capCaptureSetSetup(hWnd, &cp, sizeof(CAPTUREPARMS));

//    ZeroMemory(&cs, sizeof(CAPSTATUS));
//    capGetStatus(hWnd, &cs, sizeof(CAPSTATUS));

//    ZeroMemory(&cds, sizeof(CAPDRIVERCAPS));
//    capDriverGetCaps(hWnd, &cds, sizeof(CAPDRIVERCAPS));

//    capPreviewRate(hWnd, 30);
////    SendMessage(hWnd, WM_CAP_GET_VIDEOFORMAT, SizeOf(Bt), LongInt(@Bt));
////    Bt.bmiHeader.biWidth:= 320;
////    Bt.bmiHeader.biHeight:= 240;
////    Bt.bmiHeader.biSize:= SizeOf(Bt.bmiHeader);
////    Bt.bmiHeader.biPlanes:= 1;
////    Bt.bmiHeader.biBitCount:= 24;
////    SendMessage(hWndC, WM_CAP_SET_VIDEOFORMAT, SizeOf(Bt), LongInt(@Bt));
////    capSetCallbackOnFrame(hWndC, @capVideoFrameCallback);

////createthread(nil,0,@qwerty,nil,0,fg);
//    capPreview(hWnd, 1);
//    ShowWindow(hWnd, SW_SHOW);
////capOverlay(hWndC, True);
////capCaptureSequenceNoFile(hWndC);
////capDlgVideoFormat(hWndC);
////capFileSetCaptureFile(hWndC, 'c:\1.avi');
////capFileAlloc(hWndC, 524288000);
////capDlgVideoCompression(hWndC);
////capCaptureSequence(hWndC);

    return 0;
}
