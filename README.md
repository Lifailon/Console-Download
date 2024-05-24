# Console-Download

<p align="center">
<a href="https://github.com/Lifailon/Console-Download"><img title="GitHub"src="https://img.shields.io/github/v/release/Lifailon/Console-Download?logo=GitHub&label=GitHub"></a>
<a href="https://www.nuget.org/packages/Console-Download"><img title="NuGet"src="https://img.shields.io/nuget/vpre/Console-Download?logo=nuget&label=NuGet"></a>
<a href="https://github.com/Lifailon/Console-Download/blob/rsa/LICENSE"><img title="License"src="https://img.shields.io/github/license/Lifailon/Console-Download?link=https%3A%2F%2Fgithub.com%2FLifailon%2FConsole-Download%2Fblob%2Frsa%2FLICENSE"></a>
</p>

A command-line tool that performs a single task - downloads a file by the transmitted URL and displays the download speed in real time. Upon completion (or interruption) of the download, displays metrics for the duration of its operation: duration, maximum, average and minimum download speed.

![Image alt](https://github.com/Lifailon/Console-Download/blob/rsa/image/example.gif)

## 🚀 Install

You must have a NuGet repository registered:

```PowerShell
Register-PSRepository -Name "NuGet" -SourceLocation "https://www.nuget.org/api/v2" -InstallationPolicy Trusted
```

Install the module from the [NuGet](https://www.nuget.org/packages/Console-Download) package manager:

```PowerShell
Install-Module Console-Download -Repository NuGet -Scope CurrentUser
```

You can import a module directly from GitHub into the current PowerShell session with a single command:

```PowerShell
Invoke-Expression $(Invoke-RestMethod "https://raw.githubusercontent.com/Lifailon/Console-Download/rsa/module/Console-Download/Console-Download.psm1")
```

## 📊 Start

```PowerShell
Invoke-Download -Url "https://releases.ubuntu.com/18.04/ubuntu-18.04.6-live-server-amd64.iso" -Path "C:\Users\Lifailon\Downloads" -FileName "us-18.04.6.iso" -Update 1
```

**Default parameters:** the path `%USERPROFILE%\Downloads`, file name is taken from the url and data update time 2 seconds.

At the end of the download, you will be able to see the summary information:

```PowerShell
Size    : 969 MByte
Time    : 00:00:27
Minimum : 0,10 MByte/sec
Average : 34,48 MByte/sec
Maximum : 57,50 MByte/sec
```