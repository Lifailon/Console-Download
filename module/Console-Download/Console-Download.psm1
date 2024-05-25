function Invoke-Download {
    <#
    .SYNOPSIS
    A command-line tool for downloads a file by the transmitted URL and displays the download speed in real time.
    .DESCRIPTION
    Example:
    Invoke-Download -Url "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso" -Path "C:\Users\Lifailon\Downloads" -FileName "us-24.04.iso" -Update 2
    Invoke-Download -Url "https://github.com/Lifailon/helperd/releases/download/0.0.1/Helper-Desktop-Setup-0.0.1.exe"
    Invoke-Download -Url "https://104-234-233-47.lg.looking.house/1000.mb"
    .LINK
    https://github.com/Lifailon/Console-Download
    #>
    param (
        [Parameter(Mandatory = $True)][string]$Url,
        [string]$Path = "$home\Downloads\",
        [string]$FileName,
        [int]$Update = 1
    )
    try {
        # Если имя файла не было передано, забираем его из url
        if ($FileName.Length -eq 0) {
            $FileName = Split-Path -Path $url -Leaf
            # Удаляем параметры из названия url (если есть)
            $FileName = $FileName -replace "&.+|\?.+"
        }
        $FullPath = "$Path\$FileName"
        # Проверяем, что файл не существует
        if (Test-Path $FullPath) {
            Remove-Item $FullPath -Force
        }
        # Получить размер файла из заголовка в МБ (100%)
        $fullSize = $($($(Invoke-WebRequest -Uri $url -Method Head).Headers["Content-Length"])/1mb).ToString(0)
        # Зафиксировать текущее время
        $startTime = Get-Date
        # Начать загрузку файла
        Start-Job {
            Invoke-WebRequest $using:Url -OutFile $using:FullPath
        } | Out-Null
        # Дожидаемся создания файла
        while ($(Test-Path $FullPath) -eq $false) {
            Start-Sleep -Milliseconds 100
        }
        # Массив для заполнения метриками скорости загрузки 
        $metrics = @()
        while ($true) {
            # Узнать текущий размер файла в МБ
            $currentSize = $($(Get-ChildItem $FullPath).Length/1mb).ToString(0)
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
            Url       = $Url
            FileName  = $FileName
            FilePath  = $FullPath
            FullSize  = "$fullSize MByte"
            DownSize  = "$currentSize MByte"
            Time      = $runTime
            Minimum   = "$($measure.Minimum.ToString("0.00")) MByte/sec"
            Average   = "$($measure.Average.ToString("0.00")) MByte/sec"
            Maximum   = "$($measure.Maximum.ToString("0.00")) MByte/sec"
        })
        $Collections
    }
}

function Get-LookingGlassList {
    <#
    .SYNOPSIS
    List of Looking Glass endpoints from Looking.House for download files
    .DESCRIPTION
    Example:
    $urls = Get-LookingGlassList
    $usaNy = $urls | Where-Object region -like *USA*NY*
    $url1gb = $usaNy[0].url1000mb
    Invoke-Download $url1gb
    .LINK
    https://github.com/Lifailon/Console-Download
    https://looking.house
    #>
    param (
        [int]$countryCount = 600
    )
    $lh = Invoke-RestMethod "https://looking.house/points.php?country=$countryCount"
    # Создаем массив, который будет содержать строки с url для загрузки
    $lh_url = $($lh -split 'href=\"') -split '" type='
    # Очищаем строки с содержимым региона
    $lh_url_name = $($lh_url -replace ".+?ModalMap\(.+\s'", "++++") -replace "'\);.+", "---"
    # Создаем массив со строками региона и оставляем один якорь (+) вначале строки
    $lh_url_name_array = $($lh_url_name -split "\+\+\+") -split "---"
    # Создаем временный массив и основной массив с заголовками
    $arr_temp = ""
    $arr_main = @()
    $arr_main += @("region; url10mb; url100mb; url1000mb;")
    # Заполняем с использованием csv формата
    $lh_url_name_array | ForEach-Object {
        # Забираем регион (удаляем якорь и излишки в конце строки)
        if (($_ -match "^\+")) {
            $arr_temp += "$($_ -replace "^\+" -replace "<.+"); "
        }
        # Забираем url
        elseif ($_ -match "^http.+\.mb$") {
            $arr_temp += "$($_)"
            # Проверяем, что был получен последний url
            if ($_ -match "1000") {
                # Добавляем в основной массив и очищаем временный
                $arr_main += @($arr_temp)
                $arr_temp = ""
            }
            else {
                $arr_temp += "; "
            }
        }
    }
    # Конвертируем в объект
    $arr_main | ConvertFrom-Csv -Delimiter ";"
}