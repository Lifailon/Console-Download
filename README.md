# Console-Download

<p align="center">
<a href="https://github.com/Lifailon/Console-Download"><img title="GitHub"src="https://img.shields.io/github/v/release/Lifailon/Console-Download?logo=GitHub&label=GitHub"></a>
<a href="https://www.nuget.org/packages/Console-Download"><img title="NuGet"src="https://img.shields.io/nuget/vpre/Console-Download?logo=nuget&label=NuGet"></a>
<a href="https://github.com/Lifailon/Console-Download/blob/rsa/LICENSE"><img title="License"src="https://img.shields.io/github/license/Lifailon/Console-Download?link=https%3A%2F%2Fgithub.com%2FLifailon%2FConsole-Download%2Fblob%2Frsa%2FLICENSE"></a>
</p>

A command-line tool that performs a single task - downloads a file by the transmitted URL and displays the download speed in real time. Upon completion (or interruption) of the download, displays metrics for the duration of its operation: duration, maximum, average and minimum download speed.

This tool is designed primarily to test the bandwidth of the network interface in order to debug the sensors of the monitoring system.

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
Invoke-Download -Url "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso" `
    -Path "C:\Users\Lifailon\Downloads" `
    -FileName "us-24.04.iso" `
    -Update 2
```

At the end of the download, you will be able to see the summary information:

```PowerShell
Url      : https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso
FileName : us-24.04.iso
FilePath : C:\Users\Lifailon\Downloads\us-24.04.iso
FullSize : 2627 MByte
DownSize : 2627 MByte
Time     : 00:01:14
Minimum  : 0,00 MByte/sec
Average  : 35,71 MByte/sec
Maximum  : 49,60 MByte/sec
```

**Default parameters:** the path `%USERPROFILE%\Downloads`, file name is taken from the url and data update time 1 seconds.

You can only pass url:

```PowerShell
Invoke-Download -Url "https://github.com/Lifailon/helperd/releases/download/0.0.1/Helper-Desktop-Setup-0.0.1.exe"
```

```PowerShell
Url      : https://github.com/Lifailon/helperd/releases/download/0.0.1/Helper-Desktop-Setup-0.0.1.exe
FileName : Helper-Desktop-Setup-0.0.1.exe
FilePath : C:\Users\Lifailon\Downloads\\Helper-Desktop-Setup-0.0.1.exe
FullSize : 73 MByte
DownSize : 73 MByte
Time     : 00:00:22
Minimum  : 0,40 MByte/sec
Average  : 3,61 MByte/sec
Maximum  : 5,80 MByte/sec
```

## 📶 Looking Glass Integration

The module contains the function of getting an up-to-date list of [Looking Class](https://github.com/gnif/LookingGlass) hosts endpoints from [Looking.House](https://looking.house).

```PowerShell
$urls = Get-LookingGlassList
```

You can filter the resulting list by region:

```PowerShell
$usaNy = $urls | Where-Object region -like *USA*NY*
```

Sample Host List for USA NY Region:

```PowerShell
$usaNy | Format-List

region    : USA, NY, Brooklyn
url10mb   : https://104-234-233-47.lg.looking.house/10.mb
url100mb  : https://104-234-233-47.lg.looking.house/100.mb
url1000mb : https://104-234-233-47.lg.looking.house/1000.mb

region    : USA, NY, Buffalo, 325 Delaware Ave #302
url10mb   : https://23-95-182-54.lg.looking.house/10.mb
url100mb  : https://23-95-182-54.lg.looking.house/100.mb
url1000mb : https://23-95-182-54.lg.looking.house/1000.mb

region    : USA, NY, Buffalo, 325 Delaware Avenue, Suite 300
url10mb   : https://199-188-100-133.lg.looking.house/10.mb
url100mb  : https://199-188-100-133.lg.looking.house/100.mb
url1000mb : https://199-188-100-133.lg.looking.house/1000.mb

region    : USA, NY, Buffalo, 350 Main St
url10mb   : https://66-248-241-252.lg.looking.house/10.mb
url100mb  : https://66-248-241-252.lg.looking.house/100.mb
url1000mb : https://66-248-241-252.lg.looking.house/1000.mb

region    : USA, NY, Buffalo
url10mb   : https://23-229-68-119.lg.looking.house/10.mb
url100mb  : https://23-229-68-119.lg.looking.house/100.mb
url1000mb : https://23-229-68-119.lg.looking.house/1000.mb

region    : USA, NY, Buffalo
url10mb   : https://23-229-68-15.lg.looking.house/10.mb
url100mb  : https://23-229-68-15.lg.looking.house/100.mb
url1000mb : https://23-229-68-15.lg.looking.house/1000.mb

region    : USA, NY, Garden City, 501 Franklin Ave
url10mb   : https://185-172-129-7.lg.looking.house/10.mb
url100mb  : https://185-172-129-7.lg.looking.house/100.mb
url1000mb : https://185-172-129-7.lg.looking.house/1000.mb

region    : USA, NY, New York
url10mb   : https://191-96-196-147.lg.looking.house/10.mb
url100mb  : https://191-96-196-147.lg.looking.house/100.mb
url1000mb : https://191-96-196-147.lg.looking.house/1000.mb

region    : USA, NY, New-York
url10mb   : https://5-188-0-17.lg.looking.house/10.mb
url100mb  : https://5-188-0-17.lg.looking.house/100.mb
url1000mb : https://5-188-0-17.lg.looking.house/1000.mb

region    : USA, NY, Staten Island, 7 Teleport Dr
url10mb   : https://144-208-126-12.lg.looking.house/10.mb
url100mb  : https://144-208-126-12.lg.looking.house/100.mb
url1000mb : https://144-208-126-12.lg.looking.house/1000.mb

region    : USA, NY, Staten Island, 7 Teleport Dr
url10mb   : https://172-111-48-4.lg.looking.house/10.mb
url100mb  : https://172-111-48-4.lg.looking.house/100.mb
url1000mb : https://172-111-48-4.lg.looking.house/1000.mb
```

Select the desired url by size and start download testing:

```PowerShell
$url1gb = $usaNy[0].url1000mb
Invoke-Download $url1gb

Url      : https://104-234-233-47.lg.looking.house/1000.mb
FileName : 1000.mb
FilePath : C:\Users\Lifailon\Downloads\1000.mb
FullSize : 1000 MByte
DownSize : 1000 MByte
Time     : 00:00:45
Minimum  : 0,10 MByte/sec
Average  : 22,95 MByte/sec
Maximum  : 29,70 MByte/sec
```