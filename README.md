jump-stats-csgo
===============

CS:GO Jump Stats plugin for SourceMod
###Description

JumpStats is currently able to record jump distances and recognise a few jump types. It also features a display for both alive players and spectators (distance, speed, key presses, bunnyhops) and a basic announcer (by chat and / or sound).

JumpStats can be paired with the [JumpTop plugin] (https://github.com/Kailo97/jump-top) in order to add jump top functionalities (jump tops by jump type, !jumptop, !record commands ...).

There are still a few bugs in this plugin which might or might not get fixed in the future.

###Installation

#####For Windows:
  1. Download the latest release. ( https://github.com/ceLoFaN/jump-stats-csgo/releases/ )
  2. Extract the archive contents into your server directory (you should see a csgo folder in it). If you do not wish to compile the plugin yourself go to step 7.
  3. Go to the following directory: `<your_dedicated_server>\csgo\addons\sourcemod\scripting\`.
  4. Drag and drop the main .sp file, named `jumpstats.sp` in this case, on the `compiler(.exe)` executable file. You can just execute `compiler.exe` to compile all the plugins in the scripting directory if you want.
  5. If the compilation succeeds you will find the compiled file, named `jumpstats.smx` in this case, in the `compiled` folder.
  6. Copy the compiled plugin to `\csgo\addons\sourcemod\plugins\`. 
  7. You are ready to go! If your server was already running you might have to restart it or change the map for the plugin to load.
  
#####For Linux (and maybe Mac OS X):
  * Something similar to the Windows procedure. You can probably figure it out.
