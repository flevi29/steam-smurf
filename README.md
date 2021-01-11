# Steam Smurf

Do you have a smurf account? Did you ever feel like
it's such a pesky task to log off, wait, then copy-paste/remember
the login info for the smurf account, log in, wait . . 
*you get the idea*
<br/><br/>
Well, you don't have to go through that. With one
simple launch of this script, everything gets handled
for you.

> **NOTE** although the chances are low, it is your responsibility if a precious account gets stolen
> <br/>This script stores your information in plain text **and you should know what that means**

![demo](https://raw.githubusercontent.com/FLevent29/steam-smurf/master/demo.png)

## How it works

Here's what the script does :
- Validates variables, and if something is wrong/missing it asks for user input
- Shuts down currently running Steam process 
- Logs in with provided smurf account info
- Launches provided title 
- Waits for provided title to terminate 
- Shuts down Steam 
- Launches Steam again so you can log back into your official/whichever account

## Setup

_Information_ the script might/will ask you for :
- **Username**
- **Password**
- **Steam folder location** (if you did not choose default when installing Steam)
- **Game's executable location**
- **Game's Steam ID** (it's right next to ```store.steampowered.com/app/``` on the [game's store page](https://store.steampowered.com/))

> **NOTE** All of these can be entered manually, by **editing the script with a preferred text editor** like notepad,
> furthermore it is _**advised**_ to do so, because some wrong 
> information can only be corrected that way, and it's easier in my opinion
 
What I like to do on Windows 10 is to set up a _shortcut_ in ```%appdata%\Microsoft\Windows\Start Menu\Programs``` of the script . .<br/>
This way I can just quickly press ```the Windows/Command-key``` and type in the shortcuts' name, also I can set a custom icon
> Below you can see an example of how the script should look like for Dota 2 . .

![demo1](https://raw.githubusercontent.com/FLevent29/steam-smurf/master/demo1.png)