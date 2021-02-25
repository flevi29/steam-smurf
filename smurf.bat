@echo off

:: Insert your username and password here right after the '=' (equals sign)
set "username="
set "password="
:: NOTE it is your responsibility if a precious account gets stolen this way
:: as it's written down in plain text

:: steamFolder is the path to the folder where steam.exe is
set "steamFolder=%ProgramFiles(x86)%\Steam"

:: id is the game's Steam ID
set "id="
:: One easy way to find it is to go to the store page of the game
:: It's in the address bar right next to 'store.steampowered.com/app/'

:: Optionally game is the desired game's executable full path
set "game="
:: Set this up if you wish for Steam to restart when you're done with the game
:: If you don't know what a path is then write any garbage in there and start the script

::  ------------------------------------------------------------------------

:: Check if PowerShell version 5.1.19041.610 or later
powershell -WindowStyle Normal -Command "$versionMinimum = [Version]'5.1.19041.610'; if ($versionMinimum -gt $PSVersionTable.PSVersion) { Write-Host \"This script requires PowerShell $versionMinimum or later\"; exit 1; } exit 0;"
call :handleError

:: Set a custom name for the script so we can identify it by name
set "btchtitle=-==%~n0==-"
title %btchtitle%

set "steam=%steamFolder%\steam.exe"
set "connectionLogs=%steamFolder%\logs\connection_log.txt"

:: 'Function' for changing the content
:: of the script via $content PS variable
set "editAndKillScript=$cmdpid = (Get-Process | ?{$_.mainWindowTitle -match \"%btchtitle%.*\"} | Select -ExpandProperty Id); $content | Set-Content '%btchtitle%.txt'; Start-Process powershell -WindowStyle Hidden -Wait -ArgumentList \"-Command `\" if ([System.IO.File]::Exists('%btchtitle%.txt')) { Get-Content '%btchtitle%.txt' | Set-Content '%0'; Remove-Item '%btchtitle%.txt' } else { Add-Type -AssemblyName PresentationCore,PresentationFramework; [System.Windows.MessageBox]::Show('Couldn''t create a file necessary to edit the script. Maybe read/write permission in this directory is not suitable, consider moving the script to another directory.', 'Error', 0, 16) | Out-Null; exit 1; } taskkill /PID $cmdpid /F; taskkill /PID $pid /F; Start-Process -FilePath '%0'; `\" \" "
:: Text -less pause for PS
set "psPause=cmd /c pause | Out-Null"
:: Press any key to continue
set "pressAnyCont=Write-Host; Write-Host 'Press any key to continue . .'; %psPause%;"
:: Folder/file selection 'canceled' state handler function definer
set "defineSelCanceled=function canceled ($mesg) { Write-Host \"$mesg selection canceled\"; Write-Host \"You can always manually edit this batch file with your preferred text editor, and add what you need that way\"; Write-Host; exit 1; }"
:: Exit PS if variables are correct with 0, otherwise 1
set "checkIfVariablesAreGood=if (\"%username%\" -ne '' -and \"%password%\" -ne '' -and \"%steamFolder%\" -ne '' -and !(\"%id%\" -match '\D' -or \"%id%\" -eq '') -and [System.IO.File]::Exists(\"%steam%\") -and (\"%game%\" -eq '' -or ([System.IO.File]::Exists(\"%game%\") -and [System.IO.Path]::GetExtension(\"%game%\") -eq '.exe'))) { exit 0; } exit 1; "
:: Gets all the game names, IDs and directory names into $gamesname, $gamesid and $gamesdir
set "getGames=[System.Collections.ArrayList]$gamesname = @(); [System.Collections.ArrayList]$gamesdir = @(); [System.Collections.ArrayList]$gamesid = @(); $acfs = (Get-ChildItem -File -Path '%steamFolder%\steamapps\*.acf').FullName; foreach ($acf in $acfs) { $acfcontent = Get-Content \"$acf\"; foreach ($line in $acfcontent) { $match = [regex]::Match($line, '\"(appid^^^|name^^^|installdir)\"[\s]+\"([\S ]+)\"'); if ($match.Success) { if ($match.Groups[1].Value -eq 'appid') { $gamesid.Add($match.Groups[2].Value) | Out-Null; } if ($match.Groups[1].Value -eq 'name') { $gamesname.Add($match.Groups[2].Value) | Out-Null; } if ($match.Groups[1].Value -eq 'installdir') { $gamesdir.Add($match.Groups[2].Value) | Out-Null; } } } }"
:: Prints all the games found and selects which game the user wants into $id PS variable
set "readId=Write-Host 'Select game (type line number)'; for ($j = 0; $j -lt $gamesid.Count; $j++) { Write-Host \"       $($j + 1). $($gamesname[$j]) // $($gamesid[$j]) ($($gamesdir[$j]))\"; } do { $index = (Read-Host \"index\") -as [int]; } while (!($index -ge 1 -and $index -le $gamesname.Count)); $id = $gamesid[$($index - 1)];"

:: Validate variables, add missing/incorrect ones,
:: at least to whatever extent it's reasonable
echo|set /p="Checking variables . . . "
powershell -Command "%checkIfVariablesAreGood%"
if %errorlevel% equ 0 (goto :Valid)
echo|set /p="Invalid" & echo.
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; %defineSelCanceled%; $content = Get-Content '%0'; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=\"') { $content[$i] = \"set `\"username=$(Read-Host \"Username \")`\"\"; } elseif ($content[$i] -match 'set \"password=\"') { $content[$i] = \"set `\"password=$(Read-Host \"Password \")`\"\"; } elseif ($content[$i] -match 'set \"steamFolder=.*\"' -and ![System.IO.File]::Exists(\"%steam%\")) { Write-Host \"`r`nsteamFolder variable is incorrect or empty, you're about to set it up\"; %pressAnyCont%; $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ ShowNewFolderButton = $false; Description = 'Select Steam folder'; SelectedPath = ${env:ProgramFiles(x86)} }; if ($FolderBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"steamFolder=$($FolderBrowser.SelectedPath)`\"\"; } else { canceled 'Steam folder'; } } elseif ($content[$i] -match 'set \"game=.+\"' -and (![System.IO.File]::Exists(\"%game%\") -or [System.IO.Path]::GetExtension(\"%game%\") -ne '.exe')) { Write-Host \"`r`ngame variable is incorrect, you're about to set it up\"; %pressAnyCont%; $common = \"${env:ProgramFiles(x86)}\Steam\steamapps\common\"; $iniDir = if (Test-Path $common) { $common } else { ${env:ProgramFiles(x86)} }; $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ Title = 'Select game executable'; InitialDirectory = $iniDir; Filter = 'Executable (*.exe)|*.exe' }; if ($FileBrowser.ShowDialog() -eq 'OK') { $content[$i] = \"set `\"game=$($FileBrowser.FileName)`\"\"; } else { canceled 'Game executable'; } } elseif ($content[$i] -match 'set \"id=.*\"' -and (\"%id%\" -match '\D' -or \"%id%\" -eq '')) { Write-Host \"Game ID wrong or empty`r`n\"; %getGames%; %readId%; $content[$i] = \"set `\"id=$id`\"\"; } } Write-Host 'Press any key to write new information to script . .'; %psPause%; %editAndKillScript%; "
call :handleError
:Valid
echo|set /p="OK" & echo.

:: Function for terminating current Steam process
:: Observation: Sometimes it fails to shut down
set "exitSteam=$stmpid = (Get-Process | ?{$_.path -eq \"%steam%\"} | Select -ExpandProperty Id); if ($stmpid -ne $null) { & '%steam%' -shutdown; Wait-Process -Id $stmpid | Out-Null; Start-Sleep -s 1; } "
:: Saves current time and date into $now PS variable
set "setNow=$now = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"
:: PS regex match string for the date format above
set "dateMatch=[regex]::Match($line, \"[\d]{4}-[\d]{2}-[\d]{2} ([\d]{2}:){2}[\d]{2}\")"
:: PS handler for invalid pass/username, rewrites script emptying username and password variables
set "invalidPassOrUsername=Write-Host \"Failed`r`nInvalid username and password combination\"; Write-Host; $content = Get-Content \"%0\"; $done = 0; for ($i=0; $i -lt $content.Length; $i++) { if ($content[$i] -match 'set \"username=.*\"') { $content[$i] = \"set `\"username=`\"\"; $done++; } elseif ($content[$i] -match 'set \"password=.*\"') { $content[$i] = \"set `\"password=`\"\"; $done++; } if ($done -eq 2) { break; } }; Write-Host \"Press any key to exit . .\"; %psPause%; %editAndKillScript%;"
:: Decides what to do depending on the value of $match PS variable
set "switchMatch=switch ($match.Value) { 'Invalid Password' { %exitSteam%; %invalidPassOrUsername%; } 'Password is not set' { %exitSteam%; %invalidPassOrUsername%; } 'Connection Failed' { Write-Host \"Failed`r`nSomething went wrong. Maybe there's no internet connection . . .`r`n\"; %exitSteam%; exit 1; } 'WGToken' { exit 0; } }"

:: Kill running Steam and attempt login to Steam with provided information
:: Then check if login attempt is successful
echo|set /p="Attempting login to Steam and launching game . . . "
powershell -WindowStyle Normal -Command "%exitSteam%; & '%steam%' -silent -login %username% %password% -applaunch %id%; %setNow%; $retries = 0; while ($retries -ge 0) { if ($retries -ge 50) { Write-Host \"`r`nSomething went wrong, maybe Steam got stuck or didn't start . . .\"; exit 1; } $content = Get-Content '%connectionLogs%' -Tail 50; foreach ($line in $content) { $match = %dateMatch%; if ($match.Success -and $match.Value -ge $now) { $match = [regex]::Match($line, \"WGToken^|Connection Failed^|Invalid Password^|Password is not set\"); if ($match.Success) { $retries = -2; break; } } } $retries++; Start-Sleep -s 1; } %switchMatch%; exit 1; "
call :handleError
echo|set /p="login OK" & echo.

:: If game variable isn't defined, then we're done
if "%game%" == "" (exit 0)

:: Gets game PID from executable
set "getGamePid=(Get-Process | ?{$_.path -eq \"%game%\"} | Select -ExpandProperty Id)"

:: Try detecting the game
echo|set /p="Detecting game . . . "
powershell -WindowStyle Normal -Command "$retries = 0; do { Start-Sleep -s 1; $gmpid = %getGamePid%; if ($retries -eq 5) { $retries++; Write-Host -NoNewLine \"`r`nIf game is installing/updating/configuring wait . .`r`nOtherwise feel free to close this window . .`r`nDetecting game . . . \" } else { $retries++; } } while ($gmpid -eq $null); exit 0; "
call :handleError

:: Wait for game to exit with a hidden console window
echo|set /p="Success" & echo. & echo|set /p="Waiting for game to exit . . . "
powershell -WindowStyle Hidden -Command "Wait-Process -Id %getGamePid%; %exitSteam%; & '%steam%'; exit 0; "

exit 0

:: 'Function' for terminating script after 'exceptions'
:handleError
if %errorlevel% equ 0 ( goto:eof )
echo|set /p="Press any key to exit . . ."
pause >nul
exit 1
