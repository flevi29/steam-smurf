# Steam Smurf

Do you have a _"smurf"_ account? Did you ever feel like
it's such a pesky task to log off, wait, then copy-paste/remember
the login info for that account, log in, wait . . 
*you get the idea*  

Well, you don't have to go through that. With one
simple launch of this script, everything gets handled
for you.

> **NOTE** although the chances are low, it is your responsibility if a precious account gets stolen  
> This script stores your information as plain text **and you should know what that means**

![demo](https://raw.githubusercontent.com/FLevent29/steam-smurf/master/demo.png)

## How it works

Here's what the script does :
1. Validates information
2. Shuts down currently running Steam process 
3. Logs in with provided account info
4. Launches provided title 
5. Waits for provided title to terminate 
6. Shuts down Steam 
7. Launches Steam again so you can log back into your official/whichever account

> **NOTE** on step 4. at rare occasions Steam might warn you about some
> **_bad game configuration_**, and the game fails to start  
> The script will simply try to restart it, and 
> eventually should succeed if everything else is fine

## Download & Setup

- [Download smurf.bat](https://github.com/FLevent29/steam-smurf/releases/download/1.1/smurf.bat)

_Information_ the script needs :
- **Username**
- **Password**
- **Steam folder location** (if you did not choose default when installing Steam)
- **Game's executable location**
- **Game's Steam ID** (it's right next to ```store.steampowered.com/app/``` on the [game's store page](https://store.steampowered.com/))

> **NOTE** All of these can be entered manually, by **editing the script with a preferred text editor** like notepad,
> furthermore it is _**advised**_ to do so, because some wrong 
> information can only be corrected that way, and it's easier in my opinion
 
What I like to do on Windows 10 is to set up a _shortcut_ of the script in ```%appdata%\Microsoft\Windows\Start Menu\Programs``` . .  
This way I can quickly launch it just by pressing ```the Windows/Command-key``` and typing in the shortcuts' name, also I can set a custom icon . .

> Below you can see an example of how the script should look like for Dota 2 . .
> 
```bat
@echo off

:: Insert your username and password here right after the '=' (equals sign)
:: NOTE it is your responsibility if a precious account gets stolen this way
:: as it's written down in plain text
set "username=anonym"
set "password=mynona"

:: Here's the default location for the Steam folder,
:: game is the desired game's executable full path
:: Edit what you need to
set "steamfolder=%ProgramFiles(x86)%\Steam"
set "game=%steamfolder%\steamapps\common\dota 2 beta\game\bin\win64\dota2.exe"

:: Specify the chosen game's Steam ID, which is a decimal number
:: One easy way to find it is to go to the store page of the game
:: It's in the address bar right next to 'store.steampowered.com/app/'
set "id=570"
```