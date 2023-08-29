using System;
using System.IO;
using System.Management.Automation;
using System.ComponentModel;

// using System.Data;
// using System.Xml;
// using System.Configuration.Install;
using System.Diagnostics;

namespace Valid.Demo.DemoSnapin {

  [RunInstaller(true)]
  public class DemoSnapin : PSSnapIn {

    public DemoSnapin() : base() { }

    //name of the snapin
    public override string Name {
      get {
        return "Valid.Demo.PSDemo";
      }
    }
    // Vendor
    public override string Vendor {
      get {
        return "Valid";
      }
    }
    // Description
    public override string Description {
      get {
        return "This is a Demo PowerShell snap-in";
      }
    }
    
    // Code to implement the cmdlet Write-Hi
    [Cmdlet(VerbsCommunications.Write, "Hi")]
    public class SayHi : Cmdlet {
      protected override void ProcessRecord() {
        WriteObject("Hi, world!");
      }
    }

    // Code to implement the cmdlet Write-Hello
    [Cmdlet(VerbsCommunications.Write, "Hello")]
    public class SayHello : Cmdlet {
      protected override void ProcessRecord() {
        WriteObject("Hello, world!");
      }
    }

    // Code to implement the cmdlet Get-This
    [Cmdlet(VerbsCommon.Get, "This")]
    public class GetThis : Cmdlet {
      protected override void ProcessRecord() {
        WriteObject("Get This!");
      }
    }

    // Code to get System Uptime from performance counter
    [Cmdlet(VerbsCommon.Get, "Uptime")]
    public class GetUptimeCommand : Cmdlet {
      protected override void ProcessRecord() {
        using (var uptime = new PerformanceCounter("System","System Up Time")) {
          uptime.NextValue();
          WriteObject(TimeSpan.FromSeconds(uptime.NextValue()));
        }
      }
    }

  }
}

// C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe /target:library /reference:C:\Windows\Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll PSDemoSnapin.cs
// C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe   PSDemoSnapin.dll
// C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe PSDemoSnapin.dll
// Get-PSSnapin -Registered
// Add-PSSnapin Valid.Demo.PSDemo
// Write-Hi
// Write-Hello
// Remove-PSSnapin Valid.Demo.PSDemo -passthru
// C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe   /u PSDemoSnapin.dll
// C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /u PSDemoSnapin.dll

