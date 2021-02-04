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
:: set "contentLogs=%steamfolder%\logs\content_log.txt"

:: Function or rather string for changing the content
:: of the script via $content ps variable
set "editAndKillScript=$cmdpid = (Get-Process | ?{$_.mainWindowTitle -match \"%btchtitle%.*\"} | Select -ExpandProperty Id); $content | Set-Content '%btchtitle%.txt'; Start-Process powershell -Wait -ArgumentList \"-WindowStyle Hidden -Command `\" if ([System.IO.File]::Exists('%btchtitle%.txt')) { Get-Content '%btchtitle%.txt' | Set-Content '%0'; Remove-Item '%btchtitle%.txt' } else { Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Couldn''t create a file necessary to edit the script. Maybe read/write permission in this directory is not suitable, consider moving the script to another directory.', 'Error', 0, 16) | Out-Null; exit 1; } taskkill /PID $cmdpid /F; taskkill /PID $pid /F; `\" \" "
set "psPause=cmd /c pause | Out-Null"

:: Validate variables, add missing/incorrect ones,
:: at least to whatever extent it's possible
echo|set /p="Validating variables . . ." & echo.
powershell -WindowStyle Normal -Command "if (\"%username%\" -ne \"\" -and \"%password%\" -ne \"\" -and \"%steamfolder%\" -ne \"\" -and \"%game%\" -ne \"\" -and !(\"%id%\" -match '\D' -or \"%id%\" -eq '') -and [System.IO.File]::Exists(\"%steam%\") -and [System.IO.File]::Exists(\"%game%\") -and [System.IO.Path]::GetExtension(\"%game%\") -eq '.exe') { exit 0; } Add-Type -AssemblyName System.Windows.Forms; function anyKeyCont () { Write-Host; Write-Host 'Press any key to continue . .'; %psPause%; } function canceled ($mesg) { Write-Host \"$mesg selection canceled\"; Write-Host \"You can always manually edit this batch file with your preferred text editor, and add what you need that way\"; Write-Host; Write-Host \"Press any key to exit . . .\"; %psPause%; exit 1; } $content = Get-Content \"%0\"; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=\"') { $content[$i] = \"set `\"username=$(Read-Host \"Username \")`\"\"; Write-Host; } elseif ($content[$i] -match 'set \"password=\"') { $content[$i] = \"set `\"password=$(Read-Host \"Password \")`\"\"; Write-Host; } elseif ($content[$i] -match 'set \"steamfolder=.*\"' -and ![System.IO.File]::Exists(\"%steam%\")) { Write-Host \"steamfolder variable is incorrect or empty, you're about to set it up\"; anyKeyCont; $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ ShowNewFolderButton = $false; Description = 'Select Steam folder'; SelectedPath = ${env:ProgramFiles(x86)} }; if ($FolderBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"steamfolder=$($FolderBrowser.SelectedPath)`\"\"; Write-Host; } else { canceled 'Steam folder'; } } elseif ($content[$i] -match 'set \"game=.*\"' -and (![System.IO.File]::Exists(\"%game%\") -or [System.IO.Path]::GetExtension(\"%game%\") -ne '.exe')) { Write-Host \"game variable is incorrect or empty, you're about to set it up\"; anyKeyCont; $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = 'Select game executable'; InitialDirectory = ${env:ProgramFiles(x86)}; Filter = 'Executable (*.exe)|*.exe' }; if ($FileBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"game=$($FileBrowser.FileName)`\"\"; Write-Host; } else { canceled 'Game executable'; } } elseif ($content[$i] -match 'set \"id=.*\"' -and (\"%id%\" -match '\D' -or \"%id%\" -eq '')) { Write-Host \"This is the steam id of the selected game, you can easily find it in the game's store page in the address bar\"; $content[$i] = \"set `\"id=$(Read-Host \"Steam game ID \")`\"\"; Write-Host; } } Write-Host \"You'll have to restart this script for it to work with the new information provided . .\"; anyKeyCont; %editAndKillScript%; "

:: Check for internet connection
echo|set /p="Checking for internet connection . . ." & echo.
powershell -WindowStyle Normal -Command "if (!(Get-NetRoute | ? DestinationPrefix -eq '0.0.0.0/0' | Get-NetIPInterface | Where ConnectionState -eq 'Connected')) { Write-Host \"No internet connection detected . . .\"; Write-Host; exit 1; } exit 0; "
call :handleError

:: Function, or rather string for exiting Steam
set "exitSteam=$stmpid = (Get-Process | ?{$_.path -eq \"%steam%\"} | Select -ExpandProperty Id); if ($stmpid -ne $null) { Start-Process -FilePath \"%steam%\" -ArgumentList \"-shutdown\"; Wait-Process -Id $stmpid; } "

:: Attempt login to Steam with provided information
echo|set /p="Attempting login to Steam . . ." & echo.
powershell -WindowStyle Normal -Command "%exitSteam%; Start-Process -FilePath \"%steam%\" -ArgumentList \"-login %username% %password%\"; exit 0; "

set "setNow=$now = Get-Date -Format 'yyyy-MM-dd HH:mm'"
set "dateMatch=[regex]::Match($line, \"[\d]{4}-[\d]{2}-[\d]{2} ([\d]{2}:){2}[\d]{2}\")"
set "invalidPassOrUsername=Write-Host \"Invalid username and password combination\"; Write-Host; $content = Get-Content \"%0\"; $done = 0; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=.*\"') { $content[$i] = \"set `\"username=`\"\"; $done++; } elseif ($content[$i] -match 'set \"password=.*\"') { $content[$i] = \"set `\"password=`\"\"; $done++; } if ($done -eq 2) { break; } }; Write-Host \"Press any key to exit . .\"; %psPause%; %editAndKillScript%;"

:: Check if login attempt is successful
echo|set /p="Checking if login successful . . ." & echo.
powershell -WindowStyle Normal -Command "%setNow%; $retries = 0; while ($retries -ge 0) { if ($retries -ge 30) { Write-Host \"Something went wrong, maybe Steam doesn't print to logs\"; exit 1; } $content = Get-Content \"%connectionLogs%\" | select -Last 50; foreach ($line in $content) { $match = %dateMatch%; if ($match.Success -and $match.Value -ge $now) { $match = [regex]::Match($line, \"RecvMsgClientLogOnResponse(?=\(\).+'OK')^|Connection Failed^|Invalid Password\"); if ($match.Success) { $retries = -2; break; } } } $retries++; Start-Sleep -s 1; } switch ($match.Value) { \"Invalid Password\" { %invalidPassOrUsername%; } \"Connection Failed\" { Write-Host \"Something went wrong. Maybe there's no internet\"; Write-Host; exit 1; } \"RecvMsgClientLogOnResponse\" { Start-Sleep -s 2; exit 0; } } exit 1; "
call :handleError

:: set "defineAccessDeniedFunction=function AccessDenied () { if ([System.IO.File]::Exists(\"%contentLogs%\")) { return $true; } $content = Get-Content \"%contentLogs%\" | select -Last 50; foreach ($line in $content) { $match = %dateMatch%; if ($match.Success -and $match.Value -ge $now) { $match = [regex]::Match($line, \".+%id%.+\(Access denied\)\"); if ($match.Success) { %setNow%; return $true; } } } return $false; }"

:: Starts game specified by id
set "startGame=Start-Process -FilePath \"%steam%\" -ArgumentList \"-applaunch %id%\""
:: Alerts user of failed game startup with a message box
set "alertUserOfFailure=Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show(\"No running process of the game detected. If it's just updating/installing ignore this. Otherwise maybe it crashed, or ID and selected game don't match/are wrong (in this case you'll have to manually edit this script).\", 'Problem detecting or launching Steam title', 0, 48) | Out-Null"
:: Gets game PID from executable
set "getGamePid=(Get-Process | ?{$_.path -eq \"%game%\"} | Select -ExpandProperty Id)"

:: Start the game and wait for it to exit with a hidden console window
echo|set /p="Attempting to start and detect game . . ." & echo.
powershell -WindowStyle Hidden -Command "%startGame%; $retries = 0; do { $gmpid = %getGamePid%; if ($gmpid -eq $null) { %startGame%; } $retries++; Start-Sleep -s 1; } while ($gmpid -eq $null -and $retries -lt 5); if ($gmpid -eq $null) { %alertUserOfFailure%; exit 1; } Wait-Process -Id $gmpid; %exitSteam%; Start-Process -FilePath \"%steam%\"; exit 0; "
if %errorlevel% equ 0 (exit 0)

:: Restore window so the user can see what's printed in case of error
powershell -WindowStyle Normal -Command "exit 1;"
call :handleError

:: 'Function' for terminating script after 'exceptions'
:handleError
if %errorlevel% gtr 0 (
  echo|set /p="Press any key to exit . . ."
  pause >nul
  exit 1
)
goto:eof
