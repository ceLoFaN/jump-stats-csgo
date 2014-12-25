jump-stats-csgo
===============

CS:GO Jump Stats plugin for SourceMod

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
