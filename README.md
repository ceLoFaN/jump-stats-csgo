jump-stats-csgo
===============

CS:GO Jump Stats plugin for SourceMod

###Instalation

#####For Windows:
  1. Download the latest release.
  2. Extract the contents of the archive's main folder (usually named `jump-stats-csgo-x.x.x`) to the following path in your server `<your_dedicated_server>\csgo\`.
  3. Go to the following directory: `<your_dedicated_server>\csgo\addons\sourcemod\scripting\`.
  3. Drag and drop the main .sp file, named `jumpstats.sp` in this case, on the `compiler(.exe)` executable file. You can just execute `compiler.exe` to compile all the plugins in the scripting directory if you want.
  4. If the compilation succeeds you will find the compiled file, named `jumpstats.smx` in this case, in the `compiled` folder.
  5. Copy the compiled plugin to `\csgo\addons\sourcemod\plugins\` and you are ready to go. If your server was already running you might have to restart it or change the map for the plugin to load.
  
#####For Linux (and maybe Mac OS X):
  * Something similar to the Windows procedure. You can probably figure it out.
