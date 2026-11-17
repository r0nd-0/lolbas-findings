using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace LolbasValidation
{
    public sealed class MessageBoxComponent : Component
    {
        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern int MessageBoxW(
            IntPtr window,
            string text,
            string caption,
            uint type);

        public MessageBoxComponent()
        {
            MessageBoxW(
                IntPtr.Zero,
                "Lc.exe loaded LcMessageBox.dll and instantiated the component.",
                "LOLBAS Defensive Validation",
                0x40);
        }
    }
}
