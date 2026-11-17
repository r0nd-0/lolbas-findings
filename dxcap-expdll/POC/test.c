#define UNICODE
#define _UNICODE
#include <windows.h>

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    UNREFERENCED_PARAMETER(reserved);

    if (reason == DLL_PROCESS_ATTACH)
    {
        DisableThreadLibraryCalls(instance);
        MessageBoxW(
            NULL,
            L"Dxcap.exe loaded test.dll and executed DllMain.",
            L"LOLBAS Defensive Validation",
            MB_OK | MB_ICONINFORMATION);
    }

    return TRUE;
}
