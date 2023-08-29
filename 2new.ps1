$rootDirectory = Get-Location

function Move-FilesByExtension {
    param(
        [string]$rootDirectory
    )

    # Delete additional directories found outside the root directory
    Get-ChildItem -Path $rootDirectory -Directory | ForEach-Object {
        if (-not $_.FullName.StartsWith($rootDirectory)) {
            $null = Remove-Item -Path $_.FullName -Recurse -Force
        }
    }

    # Create main folders if they don't exist
    $mainFolders = @('Images', 'Documents', 'Audio', 'Videos', 'Zip', 'Other')
    $mainFolders | ForEach-Object {
        $folderPath = Join-Path -Path $rootDirectory -ChildPath $_
        if (-not (Test-Path -Path $folderPath -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $folderPath -Force
        }
    }

    $fileExtensions = @{}
    $logEntries = @{}
    $totalFilesMoved = 0

    Get-ChildItem -Path $rootDirectory -File -Recurse | ForEach-Object {
        $fileExtension = $_.Extension.TrimStart('.')
        $destinationFolder = ''

        if ($fileExtension -in @('jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'svg', 'webp', 'ico', 'raw', 'psd', 'ai', 'eps', 'pcx', 'pict', 'tif', 'svgz', 'odg', 'epsf', 'eps2', 'eps3', 'jpe', 'jif', 'jfif', 'jfi', 'heif', 'heic', 'avif', 'bpg', 'jp2', 'j2k', 'jpf', 'jpx', 'jpm', 'mj2', 'jxr', 'wdp', 'hdp')) {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Images'
        }
        elseif ($fileExtension -in @('doc', 'docx', 'txt', 'rtf', 'pdf', 'ppt', 'pptx', 'xls', 'xlsx', 'csv', 'odt', 'ods', 'odp', 'odg', 'odf', 'pages', 'numbers', 'key', 'tex', 'xml', 'html', 'htm', 'mht', 'msg', 'eml', 'mbox', 'epub', 'fb2', 'azw', 'djvu', 'pdb')) {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Documents'
        }
        elseif ($fileExtension -in @('mp3', 'wav', 'wma', 'aac', 'flac', 'alac', 'm4a', 'ogg', 'opus', 'aiff', 'ape', 'dsd', 'mid', 'midi', 'amr', 'ac3', 'dts', 'ra', 'rm', 'mpc', 'mp+', 'mpc', 'mpp', 'mpga', 'mp1', 'mp2', 'm4r', 'm4b', 'm4p', 'm4v')) {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Audio'
        }
        elseif ($fileExtension -in @('mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v', 'mpg', 'mpeg', '3gp', '3g2', 'm2v', 'rm', 'rmvb', 'vob', 'ts', 'mts', 'm2ts', 'divx', 'xvid', 'asf', 'swf', 'mpg4', 'mpeg4', 'ogv', 'f4v', 'h264', 'h265', 'hevc', 'rmhd')) {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Videos'
        }
        elseif ($fileExtension -in @('zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'z', 'tgz', 'tbz', 'tbz2', 'txz', 'tlz', 'taz', 'tar.gz', 'tar.bz2', 'tar.xz', 'tar.lz', 'tar.lzma', 'tar.Z', 'tar.z', 'tar.Z', 'tar.z', 'zipx', 'jar', 'war', 'ear', 'apk', 'sit', 'sitx', 'ace', 'arj', 'cab', 'iso', 'dmg', 'vhd', 'vmdk', 'wim', 'xar', 'zoo', 'par', 'lzh', 'lha')) {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Zip'
        }
        else {
            $destinationFolder = Join-Path -Path $rootDirectory -ChildPath 'Other'
        }

        if ($fileExtension) {
            $subFolder = Join-Path -Path $destinationFolder -ChildPath $fileExtension
            $null = New-Item -ItemType Directory -Path $subFolder -Force
            $destinationPath = Join-Path -Path $subFolder -ChildPath $_.Name

            # Check if the file already exists in the destination folder
            if (-not (Test-Path -Path $destinationPath)) {
                Move-Item -Path $_.FullName -Destination $destinationPath

                $timestamp = Get-Date -Format 'hh:mm:ss tt'
                $date = Get-Date -Format 'yyyy-MM-dd'
                $day = Get-Date -Format 'dddd'

                $logEntry = "$timestamp - $date ($day): Moved $($_.Name) to $destinationFolder\$fileExtension"

                # Check if the log entry has already been logged
                if (-not $logEntries.ContainsKey($logEntry)) {
                    $logEntries[$logEntry] = $true
                    $totalFilesMoved++
                    
                    # Append log entry to log file
                    $logPath = Join-Path -Path $rootDirectory -ChildPath 'log.txt'
                    if (Test-Path -Path $logPath) {
                        $logEntry | Out-File -FilePath $logPath -Append -Encoding utf8
                    }
                    else {
                        $logEntry | Out-File -FilePath $logPath -Encoding utf8
                    }
                }
            }
        }
    }

    if ($totalFilesMoved -gt 0) {
        $successMessage = "Files moved successfully."
        $logEntries[$successMessage] = $true

        $totalFilesMovedMessage = "Total files moved: $totalFilesMoved"
        $logEntries[$totalFilesMovedMessage] = $true

        $logCompletedMessage = "Logging process completed."
        $logEntries[$logCompletedMessage] = $true

        # Add two new lines
        $logEntries["`r`n"] = $true
        $logEntries["`r`n"] = $true

        # Write log entries to the log file
        $logEntries.Keys | Out-File -FilePath $logPath -Append -Encoding utf8
    }
}


# Example usage
Move-FilesByExtension -rootDirectory $rootDirectory

# Close the script after 10 seconds
Start-Sleep -Seconds 10
exit
