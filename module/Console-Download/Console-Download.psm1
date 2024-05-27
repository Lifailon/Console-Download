function Invoke-Download {
    <#
    .SYNOPSIS
        A command line tool for downloading files from a passed URL list in multithreaded mode and displays the download speed in real time.
    .PARAMETER Url
        Accepts one or an array of multiple urls (e.g. from a file)
    .PARAMETER Thread
        Accepts the number of threads to upload a single file multiple times from the same url
    .PARAMETER Path
        Directory for save files
    .EXAMPLE
        Invoke-Download -Url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip"
    .EXAMPLE
        Invoke-Download -Url "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip" -Thread 3
    .EXAMPLE
        $urls = @(
            "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip",
            "https://github.com/Lifailon/helperd/releases/download/0.0.1/Helper-Desktop-Setup-0.0.1.exe"
        )
        Invoke-Download $urls
    .EXAMPLE
        $urls = Get-Content "$home\Desktop\links.txt"
        Invoke-Download $urls
    .LINK
        https://github.com/Lifailon/Console-Download
    #>
    param (
        [Parameter(Mandatory = $True)][array]$Url,
        [ValidateRange(1,20)][int]$Thread = 1,
        [string]$Path = "$home\Downloads"
    )
    try {
        $startTime = Get-Date
        $update = 2
        $multithread = $false
        # Обрабатываем количество потоков
        if ($($Thread -ne 1) -and $($($Url.Count) -gt 1)) {
            Write-Warning "Unable to process multiple threads if more than one url is passed"
            $Thread = 1
        }
        if ($($Thread -gt 1) -and $($($Url.Count) -eq 1)) {
            $multithread = $true
        }
        elseif ($($Thread -eq 1) -and $($($Url.Count) -gt 1)) {
            $Thread = $Url.Count
        }
        # Очищаем файл для фиксации статуса выполнения заданий
        $statusTempFile = "$env:TEMP\console-download.temp"
        $null > $statusTempFile
        # Фиксируем статус всех задач для загрузки
        $(0..$($($Url.Count)-1)) | ForEach-Object {$false >> $statusTempFile}
        # Передаем +1 поток для фиксации скорости загрузки
        $arrayThread = @($(0..$($Url.Count)))
        # Задаем лимит для количества одновременно выполняемых потоков
        $ThrottleLimit = $($url.Count+1)
        # Если передаем один url и несколько потоков
        if ($multithread) {
            $arrayThread = @(0..$Thread)
            $ThrottleLimit = $($Thread+1)
        }
        # Основной цикл
        $metrics = $arrayThread | ForEach-Object -Parallel {
            try {
                if ($_ -eq 0) {
                    while ($true) {
                        # Получить текущую скорость загрузки на сетевом интерфейсе через WMI
                        $interface = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface
                        # Получаем процент для прогресс бара измерения скорости
                        [int]$percent = $($interface.BytesReceivedPersec/1mb).ToString("0")
                        if ($percent -eq 0) {
                            $percent = 1
                        }
                        elseif ($percent -gt 100) {
                            $percent = 100
                        }
                        # Выводм прогресс скорости загрузки
                        Write-Progress -Activity "$([string]$interface.Name)" -Status "$($($interface.BytesReceivedPersec/1mb).ToString("0.0")) MByte/sec" -PercentComplete $percent -Id 0
                        # Проверяем статус завершения всех задач
                        [array]$status = Get-Content $using:statusTempFile
                        if ($status -notcontains $false) {
                            break
                        }
                        # Выводим текущую скорость загрузки для фиксации в массив основого цикла
                        $($interface.BytesReceivedPersec/1mb).ToString("0.0")
                        Start-Sleep $using:update
                    }
                }
                else {
                    # Удаляем первое задание потока из индекса для обращения к массиву
                    $Index       = $_-1
                    # Назначаем порядковый номер для положения прогресс бара
                    $progressId  = $_+1
                    $UrlArray    = $using:Url
                    # Добавляем цифру к названию файла в многопоточном режиме
                    if ($using:multithread) {
                        $currentUrl  = $UrlArray[0]
                        $format      = $($(Split-Path -Path $currentUrl -Leaf) -split "\.")[-1]
                        $FileName    = $(Split-Path -Path $currentUrl -Leaf) -replace "\.$format$","-$_.$format"
                    } else {
                        # Забираем url из основного массива
                        $currentUrl  = $UrlArray[$Index]
                        # Забираем имя файла из url
                        $FileName    = Split-Path -Path $currentUrl -Leaf
                    }
                    # Удаляем параметры из названия url (если есть)
                    $FileName    = $FileName -replace "&.+|\?.+"
                    $PathDown    = $using:Path
                    $fullPath    = "$PathDown\$FileName"
                    # Проверяем, что файл не существует (удаляем)
                    if (Test-Path $fullPath) {
                        Remove-Item $fullPath -Force
                    }
                    # Получить размер файла из заголовка в МБ (100%)
                    $fullSize = $($($(Invoke-WebRequest -Uri $currentUrl -Method Head).Headers["Content-Length"])/1mb).ToString(0)
                    # Начать загрузку файла в фоновом потоке
                    Start-Job {
                        param (
                            $currentUrl,
                            $fullPath
                        )
                        # Invoke-WebRequest $currentUrl -OutFile $fullPath
                        $httpClient = [System.Net.Http.HttpClient]::new()
                        $response = $httpClient.GetAsync($currentUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
                        $stream = $response.Content.ReadAsStreamAsync().Result
                        $fileStream = [System.IO.File]::OpenWrite($fullPath)
                        try {
                            $buffer = New-Object byte[] 81920
                            while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
                                $fileStream.Write($buffer, 0, $bytesRead)
                            }
                        }
                        finally {
                            $stream.Dispose()
                            $fileStream.Dispose()
                        }
                    } -ArgumentList @($currentUrl,$fullPath) | Out-Null
                    # Дожидаемся создания файла
                    while ($(Test-Path $fullPath) -eq $false) {
                        Start-Sleep -Milliseconds 100
                    }
                    while ($true) {
                        # Узнать текущий размер файла в МБ
                        $currentSize = $($(Get-ChildItem $fullPath).Length/1mb).ToString(0)
                        # Высчитываем текущий процент загрузки
                        $downProc = $($($currentSize / $fullSize) * 100).ToString(0)
                        if ($downProc -eq 0) {
                            $downProc = 1
                        }
                        # Выводим прогресс загрузки
                        Write-Progress -Activity "$FileName" -PercentComplete $downProc -Status "$downProc % ($currentSize of $fullSize MByte)" -Id $progressId
                        if ($downProc -eq 100) {
                            # Дожидаемся успешного завершения потока
                            while ($($(Get-Job).State) -ne "Completed") {
                                Start-Sleep -Milliseconds 100
                            }
                            # Освобождаем потоки
                            Get-Job | Remove-Job -Force
                            # Фиксируем статус завершения работы по индексу в массив файла
                            $statusTempFile = $using:statusTempFile
                            [array]$status = Get-Content $statusTempFile
                            $status[$Index] = $true
                            $status > $statusTempFile
                            break
                        }
                        Start-Sleep $using:update
                    }
                }
            }
            catch {
                Get-Job | Stop-Job
                Get-Job | Remove-Job -Force
            }
        } -ThrottleLimit $ThrottleLimit
    }
    finally {
        $endTime = Get-Date
        [string]$runTime = $($endTime - $startTime).ToString('hh\:mm\:ss')
        $metrics = $metrics -replace ",","."
        $measure = $metrics | Measure-Object -Average -Maximum -Minimum
        $Collections = New-Object System.Collections.Generic.List[System.Object]
        $Collections.Add([PSCustomObject]@{
            Thread    = $Thread
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
        List of Looking Glass endpoints from Looking.House for download files.
    .EXAMPLE
        $urls = Get-LookingGlassList
        $usaNy = $urls | Where-Object region -like *USA*New*York*
        $url = $usaNy[0].url100mb
        Invoke-Download $url
        Invoke-Download $url -Thread 3
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