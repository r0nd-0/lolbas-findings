#define UNICODE
#define _UNICODE
#include <windows.h>

int WINAPI wWinMain(
    HINSTANCE instance,
    HINSTANCE previous,
    PWSTR command_line,
    int show_command)
{
    UNREFERENCED_PARAMETER(instance);
    UNREFERENCED_PARAMETER(previous);
    UNREFERENCED_PARAMETER(command_line);
    UNREFERENCED_PARAMETER(show_command);

    MessageBoxW(
        NULL,
        L"Xperf.exe started this benign child before ETW setup completed.",
        L"LOLBAS Defensive Validation",
        MB_OK | MB_ICONINFORMATION);

    return 0;
}
