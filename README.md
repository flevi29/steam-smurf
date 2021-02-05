# Steam Smurf

Do you have a _"smurf"_ account? Did you ever feel like
it's such a pesky task to log off, wait, then copy-paste/remember
the login info for that account, log in, wait . . 
*you get the idea*  

Well, you don't have to go through that. With one
simple launch of this script, everything gets handled
for you.

> :warning: Although the chances are low, it is your responsibility if a precious account gets stolen  
> This script [stores your information as plain text](https://www.passcamp.com/blog/dangers-of-storing-and-sharing-passwords-in-plaintext/)

![demo](demo.gif)

## How it works

Here's what the script does :
1. Validates information
2. Shuts down currently running Steam process 
3. Logs in with provided account info
4. Launches provided title 
5. Waits for provided title to terminate 
6. Shuts down Steam 
7. Launches Steam again so you can log back into 
   your official/whichever account

## Download & Setup

- [Download smurf.bat](https://github.com/FLevent29/steam-smurf/releases/download/1.1/smurf.bat)

_Information_ the script needs :
- **Username**
- **Password**
- **Steam folder location** (if you did not choose default when installing Steam)
- **Game's executable location**
- **Game's Steam ID** (it's right next to `store.steampowered.com/app/` on the [game's store page](https://store.steampowered.com/))

> :information_source: All of these can be entered manually, by
> **editing** the script with a preferred **text editor** like notepad,
> furthermore it is _**advised**_ to do so, because some wrong 
> information can only be corrected that way
 
On Windows 10 you could set up a _shortcut_ to the 
script in `%appdata%\Microsoft\Windows\Start Menu\Programs` . .  
This way you can quickly launch it by pressing 
<kbd>Win</kbd> and typing in the shortcuts' name,
also you can set an icon . .

Example of how the script should look like for Dota2 ↴

```bat
set "username=anonym"
set "password=mynona"

set "steamFolder=%ProgramFiles(x86)%\Steam"
set "game=%steamFolder%\steamapps\common\dota 2 beta\game\bin\win64\dota2.exe"

set "id=570"
```