# Console-Download

<p align="center">
<a href="https://github.com/Lifailon/Console-Download"><img title="GitHub"src="https://img.shields.io/github/v/release/Lifailon/Console-Download?logo=GitHub&label=GitHub"></a>
<a href="https://www.nuget.org/packages/Console-Download"><img title="NuGet"src="https://img.shields.io/nuget/vpre/Console-Download?logo=nuget&label=NuGet"></a>
<a href="https://github.com/Lifailon/Console-Download/blob/rsa/LICENSE"><img title="License"src="https://img.shields.io/github/license/Lifailon/Console-Download?link=https%3A%2F%2Fgithub.com%2FLifailon%2FConsole-Download%2Fblob%2Frsa%2FLICENSE"></a>
</p>

A command line tool for downloading files from a passed URL list in multithreaded mode and displays the download speed in real time.

This tool is suitable for testing the network interface throughput via [Looking Glass hosts](#-looking-glass-integration) in order to debug monitoring system sensors or check Internet speed. Once all files have been downloaded, the maximum, average and minimum download speeds during operation are displayed.

![Image alt](https://github.com/Lifailon/Console-Download/blob/rsa/image/multithread.gif)

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

## ⏬ Start

Passing one URL to download one file to default directory (parameter Path: `%USERPROFILE%\Downloads`):

```PowerShell
Invoke-Download -Url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip"
```

Parallel downloading in multi-threaded mode of one file (from one URL) a specified number of times (available from 1 to 20):

```PowerShell
Invoke-Download -Url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip" -Thread 3
```

Download multiple files at once:

```PowerShell
$urls = @(
    "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip",
    "https://github.com/Lifailon/helperd/releases/download/0.0.1/Helper-Desktop-Setup-0.0.1.exe"
)
Invoke-Download $urls
```

Pass a list of URLs from a file:

```PowerShell
$urls = Get-Content "$home\Desktop\links.txt"
Invoke-Download $urls
```

Example result:

```PowerShell
Thread  : 2
Time    : 00:00:23
Minimum : 0,00 MByte/sec
Average : 8,89 MByte/sec
Maximum : 51,00 MByte/sec
```

## 📶 Looking Glass Integration

The module contains the function of getting an up-to-date list of [Looking Class](https://github.com/gnif/LookingGlass) hosts endpoints from [Looking.House](https://looking.house).

```PowerShell
$urls = Get-LookingGlassList
```

You can filter the resulting list by region:

```PowerShell
$usaNy = $urls | Where-Object region -like *USA*New*York*
```

Example host list for the US, New York region:

```PowerShell
$usaNy | Format-List

region    : USA, NY, New York
url10mb   : https://191-96-196-147.lg.looking.house/10.mb
url100mb  : https://191-96-196-147.lg.looking.house/100.mb
url1000mb : https://191-96-196-147.lg.looking.house/1000.mb

region    : USA, NY, New-York
url10mb   : https://5-188-0-17.lg.looking.house/10.mb
url100mb  : https://5-188-0-17.lg.looking.house/100.mb
url1000mb : https://5-188-0-17.lg.looking.house/1000.mb
```

Select the desired URL by sequence number (index) and size (file size 100 mbyte):

```PowerShell
$url = $usaNy[0].url100mb

Write-Host $url
https://191-96-196-147.lg.looking.house/100.mb
```

Start testing the download:

```PowerShell
Invoke-Download $url

Thread  : 1
Time    : 00:00:10
Minimum : 0,00 MByte/sec
Average : 9,90 MByte/sec
Maximum : 14,20 MByte/sec
```

Use multiple threads to download one file:

```PowerShell
Invoke-Download $url -Thread 3

Thread  : 3
Time    : 00:00:28
Minimum : 0,00 MByte/sec
Average : 12,64 MByte/sec
Maximum : 30,10 MByte/sec
```