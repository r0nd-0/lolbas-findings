<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:validation="urn:lolbas-defensive-validation"
    exclude-result-prefixes="msxsl validation">

  <msxsl:script language="C#" implements-prefix="validation"><![CDATA[
    [System.Runtime.InteropServices.DllImport("user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Unicode)]
    private static extern int MessageBoxW(System.IntPtr window, string text, string caption, uint type);

    public string ShowMessage()
    {
        MessageBoxW(
            System.IntPtr.Zero,
            "Inline XSLT C# executed inside Microsoft.XslDebugger.Host.exe.",
            "LOLBAS Defensive Validation",
            0x40);
        return "Validation completed";
    }
  ]]></msxsl:script>

  <xsl:output method="text" />
  <xsl:template match="/">
    <xsl:value-of select="validation:ShowMessage()" />
  </xsl:template>
</xsl:stylesheet>
