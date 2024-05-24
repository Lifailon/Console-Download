# Console-Download

A command-line tool that performs a single task - downloads a file by the transmitted URL and displays the download speed in real time. Upon completion (or interruption) of the download, displays metrics for the duration of its operation: duration, maximum, average and minimum download speed.

![Image alt](https://github.com/Lifailon/Console-Download/blob/rsa/image/example.gif)

## 🚀 Install

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