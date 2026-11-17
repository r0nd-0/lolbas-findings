using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;

namespace LolbasValidation
{
    public sealed class CanaryComponent : Component
    {
        public CanaryComponent()
        {
            string markerPath = Environment.GetEnvironmentVariable("LOLBAS_LC_MARKER");
            if (string.IsNullOrWhiteSpace(markerPath))
            {
                return;
            }

            using (Process current = Process.GetCurrentProcess())
            {
                File.WriteAllText(
                    markerPath,
                    "UTC=" + DateTime.UtcNow.ToString("O") + Environment.NewLine +
                    "PID=" + current.Id + Environment.NewLine +
                    "Image=" + current.MainModule.FileName + Environment.NewLine +
                    "ProcessName=" + current.ProcessName + Environment.NewLine +
                    "User=" + Environment.UserDomainName + "\\" + Environment.UserName + Environment.NewLine);
            }
        }
    }
}
