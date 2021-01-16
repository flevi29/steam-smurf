@echo off

:: Insert your username and password here right after the '=' (equals sign)
:: NOTE it is your responsibility if a precious account gets stolen this way
:: as it's written down in plain text
set "username="
set "password="

:: Here's the default location for the Steam folder,
:: game is the desired game's executable full path
:: Edit what you need to
set "steamfolder=%ProgramFiles(x86)%\Steam"
set "game="

:: Specify the chosen game's Steam ID, which is a decimal number
:: One easy way to find it is to go to the store page of the game
:: It's in the address bar right next to 'store.steampowered.com/app/'
set "id="

:: -!- WARNING You should probably not edit anything from here on WARNING -!-
::  ------------------------------------------------------------------------

:: Set a custom name for the script so we can identify it by name
set "btchtitle=-==%~n0==-"
title %btchtitle%

set "steam=%steamfolder%\steam.exe"
set "connectionLogs=%steamfolder%\logs\connection_log.txt"
set "contentLogs=%steamfolder%\logs\content_log.txt"

:: Function or rather string for changing the content
:: of the script via $content ps variable
set "editandkillscript=$cmdpid = (Get-Process | ?{$_.mainWindowTitle -match \"%btchtitle%.*\"} | Select -ExpandProperty Id); $content | Set-Content '%btchtitle%.txt'; Start-Process powershell -Wait -ArgumentList \"-WindowStyle Hidden -Command `\" if ([System.IO.File]::Exists('%btchtitle%.txt')) { Get-Content '%btchtitle%.txt' | Set-Content '%0'; Remove-Item '%btchtitle%.txt' } else { Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Couldn''t create a file necessary to edit the script. Maybe read/write permission in this directory is not suitable, consider moving the script to another directory.', 'Error', 0, 16) | Out-Null; exit 1; } taskkill /PID $cmdpid /F; taskkill /PID $pid /F; `\" \" "

:: Validate variables, add missing/incorrect ones,
:: at least to whatever extent they're validateable
powershell -WindowStyle Normal -Command "if (\"%username%\" -ne \"\" -and \"%password%\" -ne \"\" -and \"%steamfolder%\" -ne \"\" -and \"%game%\" -ne \"\" -and !(\"%id%\" -match '\D' -or \"%id%\" -eq '') -and [System.IO.File]::Exists(\"%steam%\") -and [System.IO.File]::Exists(\"%game%\") -and [System.IO.Path]::GetExtension(\"%game%\") -eq '.exe') { exit 0; } Add-Type -AssemblyName System.Windows.Forms; function anyKeyCont () { Write-Host; Write-Host 'Press any key to continue . .'; cmd /c pause | Out-Null; } function canceled ($mesg) { Write-Host \"$mesg selection canceled\"; Write-Host \"You can always manually edit this batch file with your preferred text editor, and add what you need that way\"; Write-Host; Write-Host \"Press any key to exit . . .\"; cmd /c pause | Out-Null; exit 1; } $content = Get-Content \"%0\"; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=\"') { $content[$i] = \"set `\"username=$(Read-Host \"Username \")`\"\"; Write-Host; } elseif ($content[$i] -match 'set \"password=\"') { $content[$i] = \"set `\"password=$(Read-Host \"Password \")`\"\"; Write-Host; } elseif ($content[$i] -match 'set \"steamfolder=.*\"' -and ![System.IO.File]::Exists(\"%steam%\")) { Write-Host \"steamfolder variable is incorrect or empty, you're about to set it up\"; anyKeyCont; $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ ShowNewFolderButton = $false; Description = 'Select Steam folder'; SelectedPath = ${env:ProgramFiles(x86)} }; if ($FolderBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"steamfolder=$($FolderBrowser.SelectedPath)`\"\"; Write-Host; } else { canceled 'Steam folder'; } } elseif ($content[$i] -match 'set \"game=.*\"' -and (![System.IO.File]::Exists(\"%game%\") -or [System.IO.Path]::GetExtension(\"%game%\") -ne '.exe')) { Write-Host \"game variable is incorrect or empty, you're about to set it up\"; anyKeyCont; $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = 'Select game executable'; InitialDirectory = ${env:ProgramFiles(x86)}; Filter = 'Executable (*.exe)|*.exe' }; if ($FileBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"game=$($FileBrowser.FileName)`\"\"; Write-Host; } else { canceled 'Game executable'; } } elseif ($content[$i] -match 'set \"id=.*\"' -and (\"%id%\" -match '\D' -or \"%id%\" -eq '')) { Write-Host \"This is the steam id of the selected game, you can easily find it in the game's store page in the address bar\"; $content[$i] = \"set `\"id=$(Read-Host \"Steam game ID \")`\"\"; Write-Host; } } Write-Host \"You'll have to restart this script for it to work with the new information provided . .\"; anyKeyCont; %editandkillscript%; "

:: Check for internet connection
powershell -WindowStyle Normal -Command "if (!(Get-NetRoute | ? DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where ConnectionState -eq 'Connected')) { Write-Host \"It appears you have no internet connection\"; Write-Host; exit 1; } exit 0; "
call :handleError

:: Function, or rather string for exiting Steam
set "exitSteam=$stmid = (Get-Process | ?{$_.path -eq \"%steam%\"} | Select -ExpandProperty Id); if ($stmid -ne $null) { Start-Process -FilePath \"%steam%\" -ArgumentList \"-shutdown\"; Wait-Process -Id $stmid; } "

:: Attempt login to Steam with provided information
powershell -WindowStyle Normal -Command "%exitSteam%; Start-Process -FilePath \"%steam%\" -ArgumentList \"-login %username% %password%\"; exit 0; "

:: Check if login attempt is successful
powershell -WindowStyle Normal -Command "$now = Get-Date -Format 'yyyy-MM-dd HH:mm'; $retries = 0; while ($retries -ge 0) { if ($retries -ge 1) { Start-Sleep -s 1; } if ($retries -ge 10) { Write-Host \"Something went wrong, maybe Steam doesn't print to logs\"; exit 1; } $content = Get-Content \"%connectionLogs%\" | select -Last 50; foreach ($line in $content) { $match = [regex]::Match($line, \"[\d]{4}-[\d]{2}-[\d]{2} ([\d]{2}:){2}[\d]{2}\"); if ($match.Success -and $match.Value -ge $now) { $match = [regex]::Match($line, \"RecvMsgClientLogOnResponse(?=\(\).+'OK')^|Connection Failed^|Invalid Password\"); if ($match.Success) { $retries = -2; break; } } } $retries++; } switch ($match.Value) { \"Invalid Password\" { Write-Host \"Invalid username and password combination\"; Write-Host; $content = Get-Content \"%0\"; $done = 0; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=.*\"') { $content[$i] = \"set `\"username=`\"\"; $done++; } elseif ($content[$i] -match 'set \"password=.*\"') { $content[$i] = \"set `\"password=`\"\"; $done++; } if ($done -eq 2) { break; } }; Write-Host \"Press any key to exit . .\"; cmd /c pause | Out-Null; %editandkillscript%; } \"Connection Failed\" { Write-Host \"Something went wrong. Maybe there's no internet\"; Write-Host; exit 1; } \"RecvMsgClientLogOnResponse\" { exit 0; } } exit 1; "
call :handleError

:: 'Function', needs $now to be set, returns true if game didn't start
:: because of bad config error message
set "checkIfGameFailedToStartFunction=function IsBadConfigGame () { if ([System.IO.File]::Exists(\"%contentLogs%\")) { return $false; } $content = Get-Content \"%contentLogs%\" | select -Last 50; foreach ($line in $content) { $match = [regex]::Match($line, \"[\d]{4}-[\d]{2}-[\d]{2} ([\d]{2}:){2}[\d]{2}\"); if ($match.Success -and $match.Value -ge $now) { $match = [regex]::Match($line, \"Failed running app %id% \(missing config section\)\"); if ($match.Success) { $now = Get-Date -Format 'yyyy-MM-dd HH:mm'; return $true; } } } return $false; }"

:: Starts game specified by id
set "startGame=Start-Process -FilePath \"%steam%\" -ArgumentList \"-applaunch %id%\""

:: Start the game and wait for it to exit with a hidden console window
powershell -WindowStyle Hidden -Command "$now = Get-Date -Format 'yyyy-MM-dd HH:mm'; %checkIfGameFailedToStartFunction%; %startGame%; $slepttime = 0; do { if ( IsBadConfigGame ) { %startGame%; Start-Sleep -s 4; } $gmid = (Get-Process | ?{$_.path -eq \"%game%\"} | Select -ExpandProperty Id); $slepttime++; Start-Sleep -s 1; } while ($gmid -eq $null -and $slepttime -le 10); if ($gmid -eq $null) { Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show(\"No running process of the game detected. Maybe it crashed, or ID and selected game don't match/are wrong (in this case you'll have to manually edit this script).\", 'Problem detecting or launching Steam title', 0, 48) | Out-Null; exit 1; } Wait-Process -Id $gmid; %exitSteam%; Start-Process -FilePath \"%steam%\"; exit 0; "
call :handleError

exit 0

:: 'Function' for terminating script after 'exceptions'
:handleError
if %errorlevel% gtr 0 (
  echo|set /p="Press any key to exit . . ."
  pause >nul
  exit 1
)
goto:eof
