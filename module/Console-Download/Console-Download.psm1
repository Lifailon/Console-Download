function Invoke-Download {
    <#
    .SYNOPSIS
    En:
    A command-line tool for downloads a file by the transmitted URL and displays the download speed in real time.
    Ru:
    Инструмент командной строки для загрузки файла по переданному URL адресу и отображение скорости загрузки в режиме реального времени.
    .DESCRIPTION
    Example:
    Invoke-Download -Url "https://releases.ubuntu.com/18.04/ubuntu-18.04.6-live-server-amd64.iso" -Path "C:\Users\Lifailon\Downloads" -FileName "us-18.04.6.iso" -Update 1
    Invoke-Download -Url "https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso"
    Invoke-Download -Url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.msi"
    .LINK
    https://github.com/Lifailon/Console-Download
    #>
    param (
        [Parameter(Mandatory = $True)][string]$Url,
        [string]$Path = "$home\Downloads\",
        [string]$FileName,
        [int]$Update = 2
    )
    try {
        # Если имя файла не было передано, забираем его из url
        if ($FileName.Length -eq 0) {
            $FileName = Split-Path -Path $url -Leaf
        }
        $FullName = "$Path\$FileName"
        # Проверяем, что файл не существует
        if (Test-Path $FullName) {
            Remove-Item $FullName -Force
        }
        # Получить размер файла из заголовка в МБ (100%)
        $fullSize = $($($(Invoke-WebRequest -Uri $url -Method Head).Headers["Content-Length"])/1mb).ToString(0)
        # Зафиксировать текущее время
        $startTime = Get-Date
        # Начать загрузку файла
        Start-Job {
            Invoke-WebRequest $using:Url -OutFile $using:FullName
        } | Out-Null
        # Дожидаемся создания файла
        while ($(Test-Path $FullName) -eq $false) {
            Start-Sleep -Milliseconds 100
        }
        # Массив для заполнения метриками скорости загрузки 
        $metrics = @()
        while ($true) {
            # Узнать текущий размер файла в МБ
            $currentSize = $($(Get-ChildItem $FullName).Length/1mb).ToString(0)
            # Получить текущую скорость загрузки и отдачи на интерфейсе через WMI
            $interface = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface | Select-Object Name,
                @{name="Received";expression={$($_.BytesReceivedPersec/1mb).ToString("0.0")}},
                @{name="Sent";expression={$($_.BytesSentPersec/1mb).ToString("0.0")}}
            # Добавляем скорость загрузки в массив
            $metrics += $interface.Received
            # Получаем текущий процент загрузки
            $downProc = $($($currentSize / $fullSize) * 100).ToString(0)
            if ($downProc -eq 0) {
                $downProc = 1
            }
            # Выводим прогресс
            Write-Progress -Activity "$($interface.Received) MByte/sec ($currentSize of $fullSize MByte)" -PercentComplete $downProc
            if ($downProc -eq 100) {
                # Дожидаемся успешного завершения потока
                while ($($(Get-Job).State) -ne "Completed") {
                    Start-Sleep -Milliseconds 100
                }
                # Освобождаем процесс
                Get-Job | Remove-Job -Force
                break
            }
            # Пауза между проверками
            Start-Sleep $Update
        }
    }
    # Обрабатываем прерывание работы
    catch {
        # Завершаем процесс
        Get-Job | Stop-Job
        Get-Job | Remove-Job -Force
    }
    finally {
        # Зафиксировать время по завершению
        $endTime = Get-Date
        # Получаем метрики
        [string]$runTime = $($endTime - $startTime).ToString('hh\:mm\:ss')
        $metrics = $metrics -replace ",","."
        $measure = $metrics | Measure-Object -Average -Maximum -Minimum
        $Collections = New-Object System.Collections.Generic.List[System.Object]
        $Collections.Add([PSCustomObject]@{
            Size    = "$fullSize MByte"
            Time    = $runTime
            Minimum = "$($measure.Minimum.ToString("0.00")) MByte/sec"
            Average = "$($measure.Average.ToString("0.00")) MByte/sec"
            Maximum = "$($measure.Maximum.ToString("0.00")) MByte/sec"
        })
        $Collections
    }
}