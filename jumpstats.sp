#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <clientprefs>

// ConVar Defines
#define PLUGIN_VERSION              "0.2.1"
#define STATS_ENABLED               "1"
#define DISPLAY_DELAY_ROUNDSTART    "3"
#define BUNNY_HOP_CANCELS_ANNOUNCER "1"

// Jump Types
#define JUMP_INVALID                -3
#define JUMP_VERTICAL               -2
#define JUMP_TOO_SHORT              -1
#define JUMP_NONE                   0

#define VALID_JUMP_TYPES            4
#define JUMP_LJ                     1
#define JUMP_BHJ                    2
#define JUMP_MBHJ                   3
#define JUMP_LADJ                   4

// Jump Distances
#define IMPRESSIVE                  0
#define EXCELLENT                   1
#define OUTSTANDING                 2
#define UNREAL                      3
#define GODLIKE                     4

#define MINIMUM_LJ_DISTANCE         215.0
#define LJ_IMPRESSIVE               "230.0"
#define LJ_EXCELLENT                "235.0"
#define LJ_OUTSTANDING              "240.0"
#define LJ_UNREAL                   "245.0"
#define LJ_GODLIKE                  "250.0"

#define MINIMUM_BHJ_DISTANCE        215.0
#define BHJ_IMPRESSIVE              "248.0"
#define BHJ_EXCELLENT               "256.0"
#define BHJ_OUTSTANDING             "262.0"
#define BHJ_UNREAL                  "270.0"
#define BHJ_GODLIKE                 "278.0"

#define MINIMUM_MBHJ_DISTANCE       215.0
#define MBHJ_IMPRESSIVE             "248.0"
#define MBHJ_EXCELLENT              "256.0"
#define MBHJ_OUTSTANDING            "262.0"
#define MBHJ_UNREAL                 "270.0"
#define MBHJ_GODLIKE                "278.0"

#define MINIMUM_LADJ_DISTANCE       135.0
#define LADJ_IMPRESSIVE             "152.0"
#define LADJ_EXCELLENT              "158.0"
#define LADJ_OUTSTANDING            "164.0"
#define LADJ_UNREAL                 "170.0"
#define LADJ_GODLIKE                "176.0"


//Spec Defines
#define REFRESH_RATE                0.1
#define SPECMODE_NONE               0
#define SPECMODE_FIRSTPERSON        4
#define SPECMODE_3RDPERSON          5
#define SPECMODE_FREELOOK           6
#define MOUSE_LEFT                  (1 << 0)
#define MOUSE_RIGHT                 (1 << 1)

public Plugin:myinfo =
{
    name = "Jump Stats",
    author = "ceLoFaN",
    description = "Jump Stats for CS:GO",
    version = PLUGIN_VERSION,
    url = "steamcommunity.com/id/celofan"
};

/*\----ConVars----------------------------------------\*/
new Handle:g_hEnabled = INVALID_HANDLE;
new Handle:g_hDisplayDelayRoundstart = INVALID_HANDLE;
new Handle:g_hBunnyHopCancelsAnnouncer = INVALID_HANDLE;

new Handle:g_hLJImpressive = INVALID_HANDLE;
new Handle:g_hLJExcellent = INVALID_HANDLE;
new Handle:g_hLJOutstanding = INVALID_HANDLE;
new Handle:g_hLJUnreal = INVALID_HANDLE;
new Handle:g_hLJGodlike = INVALID_HANDLE;

new Handle:g_hBHJImpressive = INVALID_HANDLE;
new Handle:g_hBHJExcellent = INVALID_HANDLE;
new Handle:g_hBHJOutstanding = INVALID_HANDLE;
new Handle:g_hBHJUnreal = INVALID_HANDLE;
new Handle:g_hBHJGodlike = INVALID_HANDLE;

new Handle:g_hMBHJImpressive = INVALID_HANDLE;
new Handle:g_hMBHJExcellent = INVALID_HANDLE;
new Handle:g_hMBHJOutstanding = INVALID_HANDLE;
new Handle:g_hMBHJUnreal = INVALID_HANDLE;
new Handle:g_hMBHJGodlike = INVALID_HANDLE;

new Handle:g_hLadJImpressive = INVALID_HANDLE;
new Handle:g_hLadJExcellent = INVALID_HANDLE;
new Handle:g_hLadJOutstanding = INVALID_HANDLE;
new Handle:g_hLadJUnreal = INVALID_HANDLE;
new Handle:g_hLadJGodlike = INVALID_HANDLE;

new bool:g_bEnabled;
new Float:g_fDisplayDelayRoundstart;
new bool:g_bBunnyHopCancelsAnnouncer;

new Float:g_faQualityDistances[VALID_JUMP_TYPES + 1][5];
/*-----------------------------------------------------*/

//cookies
new Handle:g_hToggleStatsCookie = INVALID_HANDLE;

//stats
new Handle:g_hDisplayTimer = INVALID_HANDLE;
new Handle:g_hInitialDisplayTimer = INVALID_HANDLE;
new bool:g_baStats[MAXPLAYERS + 1] = {true, ...};
new bool:g_baJumped[MAXPLAYERS + 1] = {false, ...};
new bool:g_baCanJump[MAXPLAYERS + 1] = {true, ...};
new bool:g_baJustHopped[MAXPLAYERS + 1] = {false, ...};
new bool:g_baCanBhop[MAXPLAYERS + 1] = {false, ...};
new bool:g_baAntiJump[MAXPLAYERS + 1] = {true, ...};
new bool:g_baOnLadder[MAXPLAYERS + 1] = {false, ...};
new bool:g_baLadderJumped[MAXPLAYERS + 1] = {false, ...};
new bool:g_baAnnounceLastJump[MAXPLAYERS + 1] = {false, ...};
new Float:g_faJumpCoord[MAXPLAYERS + 1][3];
new Float:g_faLandCoord[MAXPLAYERS + 1][3];
new Float:g_faDistance[MAXPLAYERS + 1] = {0.0, ...};
new Float:g_faLastDistance[MAXPLAYERS + 1] = {0.0, ...};
new g_iaBhops[MAXPLAYERS + 1] = {0, ...};
new g_iaFrame[MAXPLAYERS + 1] = {0, ...};
new g_iaJumpType[MAXPLAYERS + 1] = {0, ...};
new g_iaLastJumpType[MAXPLAYERS + 1] = {0, ...};
new g_iaButtons[MAXPLAYERS+1] = {0, ...};
new g_iaMouseDisplay[MAXPLAYERS + 1] = {0, ...};

//Jump consts
new const String:g_saJumpTypes[][] = {
    "None",
    "LJ",
    "BHJ",
    "MBHJ",
    "LadJ"
}
new const String:g_saPrettyJumpTypes[][] = {
    "None",
    "LongJump",
    "BunnyHop Jump",
    "Multi BunnyHop Jump",
    "LadderJump"
}
new const String:g_saJumpQualities[][] = {
    "Impressive",
    "Excellent",
    "Outstanding",
    "Unreal",
    "Godlike"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
   CreateNative("JumpStats_InterruptJump", Native_InterruptJump);

   return APLRes_Success;
}

public OnPluginStart()
{
    //ConVars here
    CreateConVar("hidenseek_version", PLUGIN_VERSION, "Version of JumpStats", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
    g_hEnabled = CreateConVar("sm_jumpstats", STATS_ENABLED, "Turns the jump stats On/Off (0=OFF, 1=ON)", FCVAR_NOTIFY|FCVAR_PLUGIN, true, 0.0, true, 1.0);
    g_hDisplayDelayRoundstart = CreateConVar("sm_display_delay_roundstart", DISPLAY_DELAY_ROUNDSTART, "Sets the roundstart delay before the display is shown.", _, true, 0.0);
    g_hBunnyHopCancelsAnnouncer = CreateConVar("sm_bunnyhop_cancels_announcer", BUNNY_HOP_CANCELS_ANNOUNCER, "Decides if bunny hopping after a jump cancels the announcer.", _, true, 0.0, true, 1.0);

    g_hLJImpressive = CreateConVar("sm_jumpstats_lj_impressive", LJ_IMPRESSIVE, "The distance required for an Impressive LongJump", _, true, 0.0);
    g_hLJExcellent = CreateConVar("sm_jumpstats_lj_excellent", LJ_EXCELLENT, "The distance required for an Excellent LongJump", _, true, 0.0);
    g_hLJOutstanding = CreateConVar("sm_jumpstats_lj_outstanding", LJ_OUTSTANDING, "The distance required for an Outstanding LongJump", _, true, 0.0);
    g_hLJUnreal = CreateConVar("sm_jumpstats_lj_unreal", LJ_UNREAL, "The distance required for an Unreal LongJump", _, true, 0.0);
    g_hLJGodlike = CreateConVar("sm_jumpstats_lj_godlike", LJ_GODLIKE, "The distance required for a Godlike LongJump", _, true, 0.0);

    g_hBHJImpressive = CreateConVar("sm_jumpstats_bhj_impressive", BHJ_IMPRESSIVE, "The distance required for an Impressive BunnyHop Jump", _, true, 0.0);
    g_hBHJExcellent = CreateConVar("sm_jumpstats_bhj_excellent", BHJ_EXCELLENT, "The distance required for an Excellent BunnyHop Jump", _, true, 0.0);
    g_hBHJOutstanding = CreateConVar("sm_jumpstats_bhj_outstanding", BHJ_OUTSTANDING, "The distance required for an Outstanding BunnyHop Jump", _, true, 0.0);
    g_hBHJUnreal = CreateConVar("sm_jumpstats_bhj_unreal", BHJ_UNREAL, "The distance required for an Unreal BunnyHop Jump", _, true, 0.0);
    g_hBHJGodlike = CreateConVar("sm_jumpstats_bhj_godlike", BHJ_GODLIKE, "The distance required for a Godlike BunnyHop Jump", _, true, 0.0);

    g_hMBHJImpressive = CreateConVar("sm_jumpstats_mbhj_impressive", MBHJ_IMPRESSIVE, "The distance required for an Impressive Multi BunnyHop Jump", _, true, 0.0);
    g_hMBHJExcellent = CreateConVar("sm_jumpstats_mbhj_excellent", MBHJ_EXCELLENT, "The distance required for an Excellent Multi BunnyHop Jump", _, true, 0.0);
    g_hMBHJOutstanding = CreateConVar("sm_jumpstats_mbhj_outstanding", MBHJ_OUTSTANDING, "The distance required for an Outstanding Multi BunnyHop Jump", _, true, 0.0);
    g_hMBHJUnreal = CreateConVar("sm_jumpstats_mbhj_unreal", MBHJ_UNREAL, "The distance required for an Unreal Multi BunnyHop Jump", _, true, 0.0);
    g_hMBHJGodlike = CreateConVar("sm_jumpstats_mbhj_godlike", MBHJ_GODLIKE, "The distance required for a Godlike Multi BunnyHop Jump", _, true, 0.0);

    g_hLadJImpressive = CreateConVar("sm_jumpstats_ladj_impressive", LADJ_IMPRESSIVE, "The distance required for an Impressive LadderJump", _, true, 0.0);
    g_hLadJExcellent = CreateConVar("sm_jumpstats_ladj_excellent", LADJ_EXCELLENT, "The distance required for an Excellent LadderJump", _, true, 0.0);
    g_hLadJOutstanding = CreateConVar("sm_jumpstats_ladj_outstanding", LADJ_OUTSTANDING, "The distance required for an Outstanding LadderJump", _, true, 0.0);
    g_hLadJUnreal = CreateConVar("sm_jumpstats_ladj_unreal", LADJ_UNREAL, "The distance required for an Unreal LadderJump", _, true, 0.0);
    g_hLadJGodlike = CreateConVar("sm_jumpstats_ladj_godlike", LADJ_GODLIKE, "The distance required for a Godlike LadderJump", _, true, 0.0);
    // Remember to add HOOKS to OnCvarChange | and also update OnConfigsExecuted
    //                                       V
    HookConVarChange(g_hEnabled, OnCvarChange);
    HookConVarChange(g_hDisplayDelayRoundstart, OnCvarChange);
    HookConVarChange(g_hBunnyHopCancelsAnnouncer, OnCvarChange);

    HookConVarChange(g_hLJImpressive, OnCvarChange);
    HookConVarChange(g_hLJExcellent, OnCvarChange);
    HookConVarChange(g_hLJOutstanding, OnCvarChange);
    HookConVarChange(g_hLJUnreal, OnCvarChange);
    HookConVarChange(g_hLJGodlike, OnCvarChange);

    HookConVarChange(g_hBHJImpressive, OnCvarChange);
    HookConVarChange(g_hBHJExcellent, OnCvarChange);
    HookConVarChange(g_hBHJOutstanding, OnCvarChange);
    HookConVarChange(g_hBHJUnreal, OnCvarChange);
    HookConVarChange(g_hBHJGodlike, OnCvarChange);

    HookConVarChange(g_hMBHJImpressive, OnCvarChange);
    HookConVarChange(g_hMBHJExcellent, OnCvarChange);
    HookConVarChange(g_hMBHJOutstanding, OnCvarChange);
    HookConVarChange(g_hMBHJUnreal, OnCvarChange);
    HookConVarChange(g_hMBHJGodlike, OnCvarChange);

    HookConVarChange(g_hLadJImpressive, OnCvarChange);
    HookConVarChange(g_hLadJExcellent, OnCvarChange);
    HookConVarChange(g_hLadJOutstanding, OnCvarChange);
    HookConVarChange(g_hLadJUnreal, OnCvarChange);
    HookConVarChange(g_hLadJGodlike, OnCvarChange);
    
    //Hooked'em
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end", OnRoundEnd);
    HookEvent("player_death", OnPlayerDeath);
    
    g_bEnabled = true;
    
    RegConsoleCmd("togglestats", Command_ToggleStats);
    AutoExecConfig(true, "jumpstats");
    
    g_hToggleStatsCookie = RegClientCookie("ToggleStatsCookie", "Me want cookie!", CookieAccess_Private);
    
    for(new iClient = 1; iClient <= MaxClients; iClient++) {
        if(IsClientInGame(iClient) && !IsFakeClient(iClient) && AreClientCookiesCached(iClient)) {
            OnClientCookiesCached(iClient);
        }
    }
}

public OnConfigsExecuted()
{
    g_bEnabled = GetConVarBool(g_hEnabled);
    g_fDisplayDelayRoundstart = GetConVarFloat(g_hDisplayDelayRoundstart);
    g_bBunnyHopCancelsAnnouncer = GetConVarBool(g_hBunnyHopCancelsAnnouncer);

    g_faQualityDistances[JUMP_LJ][IMPRESSIVE] = GetConVarFloat(g_hLJImpressive);
    g_faQualityDistances[JUMP_LJ][EXCELLENT] = GetConVarFloat(g_hLJExcellent);
    g_faQualityDistances[JUMP_LJ][OUTSTANDING] = GetConVarFloat(g_hLJOutstanding);
    g_faQualityDistances[JUMP_LJ][UNREAL] = GetConVarFloat(g_hLJUnreal);
    g_faQualityDistances[JUMP_LJ][GODLIKE] = GetConVarFloat(g_hLJGodlike);

    g_faQualityDistances[JUMP_BHJ][IMPRESSIVE] = GetConVarFloat(g_hBHJImpressive);
    g_faQualityDistances[JUMP_BHJ][EXCELLENT] = GetConVarFloat(g_hBHJExcellent);
    g_faQualityDistances[JUMP_BHJ][OUTSTANDING] = GetConVarFloat(g_hBHJOutstanding);
    g_faQualityDistances[JUMP_BHJ][UNREAL] = GetConVarFloat(g_hBHJUnreal);
    g_faQualityDistances[JUMP_BHJ][GODLIKE] = GetConVarFloat(g_hBHJGodlike);

    g_faQualityDistances[JUMP_MBHJ][IMPRESSIVE] = GetConVarFloat(g_hMBHJImpressive);
    g_faQualityDistances[JUMP_MBHJ][EXCELLENT] = GetConVarFloat(g_hMBHJExcellent);
    g_faQualityDistances[JUMP_MBHJ][OUTSTANDING] = GetConVarFloat(g_hMBHJOutstanding);
    g_faQualityDistances[JUMP_MBHJ][UNREAL] = GetConVarFloat(g_hMBHJUnreal);
    g_faQualityDistances[JUMP_MBHJ][GODLIKE] = GetConVarFloat(g_hMBHJGodlike);

    g_faQualityDistances[JUMP_LADJ][IMPRESSIVE] = GetConVarFloat(g_hLadJImpressive);
    g_faQualityDistances[JUMP_LADJ][EXCELLENT] = GetConVarFloat(g_hLadJExcellent);
    g_faQualityDistances[JUMP_LADJ][OUTSTANDING] = GetConVarFloat(g_hLadJOutstanding);
    g_faQualityDistances[JUMP_LADJ][UNREAL] = GetConVarFloat(g_hLadJUnreal);
    g_faQualityDistances[JUMP_LADJ][GODLIKE] = GetConVarFloat(g_hLadJGodlike);
}

public OnCvarChange(Handle:hConVar, const String:sOldValue[], const String:sNewValue[])
{
    decl String:sConVarName[64];
    GetConVarName(hConVar, sConVarName, sizeof(sConVarName));

    if(StrEqual("sm_jumpstats", sConVarName))
        g_bEnabled = GetConVarBool(hConVar); else
    if(StrEqual("sm_display_delay_roundstart", sConVarName))
        g_fDisplayDelayRoundstart = GetConVarFloat(hConVar); else
    if(StrEqual("sm_bunnyhop_cancels_announcer", sConVarName))
        g_bBunnyHopCancelsAnnouncer = GetConVarBool(hConVar); else

    if(StrEqual("sm_jumpstats_lj_impressive", sConVarName))
        g_faQualityDistances[JUMP_LJ][IMPRESSIVE] = GetConVarFloat(hConVar); else
    if(StrEqual("sm_jumpstats_lj_excellent", sConVarName))
        g_faQualityDistances[JUMP_LJ][EXCELLENT] = GetConVarFloat(hConVar); else
    if(StrEqual("sm_jumpstats_lj_outstanding", sConVarName))
        g_faQualityDistances[JUMP_LJ][OUTSTANDING] = GetConVarFloat(hConVar); else
    if(StrEqual("sm_jumpstats_lj_unreal", sConVarName))
        g_faQualityDistances[JUMP_LJ][UNREAL] = GetConVarFloat(hConVar); else
    if(StrEqual("sm_jumpstats_lj_godlike", sConVarName))
        g_faQualityDistances[JUMP_LJ][GODLIKE] = GetConVarFloat(hConVar);
}

public OnClientCookiesCached(iClient)
{
    decl String:sCookieValue[8];
    
    GetClientCookie(iClient, g_hToggleStatsCookie, sCookieValue, sizeof(sCookieValue));
    if(StrEqual(sCookieValue, "off"))
        g_baStats[iClient] = false;
    else
        g_baStats[iClient] = true;
}

public bool:InterruptJump(iClient) 
{
    if(iClient < 1 || iClient >= MaxClients)
        return false;

    g_baJumped[iClient] = false;
    g_baCanBhop[iClient] = false;
    g_baLadderJumped[iClient] = false;
    g_iaJumpType[iClient] = JUMP_INVALID;

    return true;
}

public Native_InterruptJump(Handle:hPlugin, iNumParams)
{
    if(iNumParams != 1) 
        return false;

    new iClient = GetNativeCell(1);
    return InterruptJump(iClient);
}

public OnMapEnd() {
    if(g_hDisplayTimer != INVALID_HANDLE) {
        KillTimer(g_hDisplayTimer);
        g_hDisplayTimer = INVALID_HANDLE;
    }

    if(g_hInitialDisplayTimer != INVALID_HANDLE) {
        KillTimer(g_hInitialDisplayTimer);
        g_hDisplayTimer = INVALID_HANDLE;
    }

    if(!g_bEnabled)
        return ;
}

public Action:OnRoundStart(Handle:hEvent, const String:sName[], bool:dontBroadcast)
{
    if(!g_bEnabled)
        return Plugin_Continue;

    if(g_hDisplayTimer != INVALID_HANDLE) {
        KillTimer(g_hDisplayTimer);
        g_hDisplayTimer = INVALID_HANDLE;
    }
    if(g_hInitialDisplayTimer != INVALID_HANDLE)
        KillTimer(g_hInitialDisplayTimer);
    g_hInitialDisplayTimer = CreateTimer(g_fDisplayDelayRoundstart, ShowDisplay);

    return Plugin_Continue;
}

public Action:ShowDisplay(Handle:hTimer)
{
    g_hInitialDisplayTimer = INVALID_HANDLE;
    if(g_hDisplayTimer != INVALID_HANDLE)
        KillTimer(g_hDisplayTimer);
    for(new iClient = 1; iClient <= MaxClients; iClient++) {
        g_iaButtons[iClient] = 0;
        g_iaMouseDisplay[iClient] = 0;
    }
    g_hDisplayTimer = CreateTimer(REFRESH_RATE, StatsDisplay, _, TIMER_REPEAT);
}

public Action:StatsDisplay(Handle:hTimer)
{
    if(g_bEnabled) {
        for(new iClient = 1; iClient <= MaxClients; iClient++) {
            if(IsClientInGame(iClient) && g_baStats[iClient]) {
                if(IsPlayerAlive(iClient)) {
                    decl String:sOutput[128];

                    Format(sOutput, sizeof(sOutput), "  Speed: %.1f ups\n", GetPlayerSpeed(iClient));

                    if(g_iaJumpType[iClient] != JUMP_VERTICAL) {
                        if(g_iaJumpType[iClient] > JUMP_TOO_SHORT) {
                            g_faLastDistance[iClient] = g_faDistance[iClient];
                            g_iaLastJumpType[iClient] = g_iaJumpType[iClient];
                        }

                        Format(sOutput, sizeof(sOutput),
                        "%s  Last Jump: %.1f units [%s]\n", sOutput, g_faLastDistance[iClient], g_saJumpTypes[g_iaLastJumpType[iClient]]);
                    }
                    else {
                        Format(sOutput, sizeof(sOutput), "%s  Last Jump: Vertical\n", sOutput);
                    }

                    Format(sOutput, sizeof(sOutput), "%s  BunnyHops: %i", sOutput, g_iaBhops[iClient]);
                    // feature to add: for 0 bunnyhops: show LJ Strafes (x% sync)
                    //                 for 1 bunnyhop:  show BJ Strafes (x% sync)
                    //                 for 2 bunnyhops: show Number of bunnyhops and average speed / sync / distance covered
                    PrintHintText(iClient, sOutput);
                }
                else {
                    if(IsClientObserver(iClient)) {
                        new iSpecMode = GetEntProp(iClient, Prop_Send, "m_iObserverMode");
                        if(iSpecMode == SPECMODE_FIRSTPERSON || iSpecMode == SPECMODE_3RDPERSON) {
                            new iSpectatedClient = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget");
                            if(iSpectatedClient > 1 && iSpectatedClient <= MaxClients) {
                                decl String:sOutput[256];
                                if(g_iaButtons[iSpectatedClient] & IN_FORWARD)
                                    Format(sOutput, sizeof(sOutput), "               [ W ]");
                                else
                                    Format(sOutput, sizeof(sOutput), "               [      ]");
                                if(g_iaButtons[iSpectatedClient] & IN_ATTACK)
                                    Format(sOutput, sizeof(sOutput), "%s                    [ATK1]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s                    [         ]", sOutput);
                                if(g_iaButtons[iSpectatedClient] & IN_ATTACK2)
                                    Format(sOutput, sizeof(sOutput), "%s  [ATK2]\n", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s  [          ]\n", sOutput);
                                ////////
                                if(g_iaButtons[iSpectatedClient] & IN_MOVELEFT)
                                    Format(sOutput, sizeof(sOutput), "%s  [ A ]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s  [     ]", sOutput);
                                if(g_iaButtons[iSpectatedClient] & IN_BACK)
                                    Format(sOutput, sizeof(sOutput), "%s      [ S ]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s      [     ]", sOutput);
                                if(g_iaButtons[iSpectatedClient] & IN_MOVERIGHT)
                                    Format(sOutput, sizeof(sOutput), "%s      [ D ]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s      [     ]", sOutput);
                                if(g_iaMouseDisplay[iSpectatedClient] & MOUSE_LEFT)
                                    Format(sOutput, sizeof(sOutput), "%s       [\xc2\xab--]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s       [      ]", sOutput);
                                if(g_iaMouseDisplay[iSpectatedClient] & MOUSE_RIGHT)
                                    Format(sOutput, sizeof(sOutput), "%s         [--\xc2\xbb]\n", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s         [      ]\n", sOutput);
                                ////////
                                if(g_iaButtons[iSpectatedClient] & IN_DUCK)
                                    Format(sOutput, sizeof(sOutput), "%s  [DUCK]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s  [          ]", sOutput);
                                if(g_iaButtons[iSpectatedClient] & IN_JUMP)
                                    Format(sOutput, sizeof(sOutput), "%s        [JUMP]", sOutput);
                                else
                                    Format(sOutput, sizeof(sOutput), "%s        [           ]", sOutput);
                                Format(sOutput, sizeof(sOutput), "%s    |   Speed: %.1f", sOutput, GetPlayerSpeed(iSpectatedClient));
                                PrintHintText(iClient, sOutput);
                            }
                        }
                    }
                }
            }
        }
    }
    for(new iClient = 1; iClient <= MaxClients; iClient++) {
        g_iaButtons[iClient] = 0;
        g_iaMouseDisplay[iClient] = 0;
    }
    return Plugin_Continue;
}

public Action:Command_ToggleStats(iClient, iArgs)
{
    if(iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient)) {
        g_baStats[iClient] = !g_baStats[iClient];
        if(!g_baStats[iClient])
            SetClientCookie(iClient, g_hToggleStatsCookie, "off");
        else
            SetClientCookie(iClient, g_hToggleStatsCookie, "on");
        
        PrintToChat(iClient, "\x04[JS] You have turned %s the Jump Stats.", g_baStats[iClient] ? "on" : "off");
    }
    return Plugin_Handled;
}

public SDKHook_StartTouch_Callback(iClient, iTouched)
{
    if(g_bEnabled && iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient)) {
        if(g_baJumped[iClient] && IsPlayerAlive(iClient)) {
            g_baCanJump[iClient] = true;
            if(iTouched > 0) 
                InterruptJump(iClient);
            else if(iTouched == 0) {
                if(GetEntityFlags(iClient) & FL_ONGROUND) {
                    if(!g_baJustHopped[iClient]) {
                        if(!g_baCanBhop[iClient]) {
                            CreateTimer(0.1, StopBhopRecord, iClient);
                            g_baAnnounceLastJump[iClient] = true;
                            g_baCanBhop[iClient] = true;
                        }            
                        RecordJump(iClient);
                        g_baJumped[iClient] = false;
                        g_baLadderJumped[iClient] = false;
                    }
                }
                else
                    InterruptJump(iClient);
            }
        }
    }
}

public OnClientDisconnect(iClient)
{
    SDKUnhook(iClient, SDKHook_StartTouch, SDKHook_StartTouch_Callback);
    g_iaButtons[iClient] = 0;
    g_baStats[iClient] = true;
    g_baJumped[iClient] = false;
    g_iaFrame[iClient] = 0;
    g_iaBhops[iClient] = 0;
    g_baCanJump[iClient] = true;
    g_faLastDistance[iClient] = 0.0;
}

public OnClientPutInServer(iClient)
{
    SDKHook(iClient, SDKHook_StartTouch, SDKHook_StartTouch_Callback);
    OnClientCookiesCached(iClient);
}

public Action:OnTakeDamage(iVictim, &iAttacker, &iInflictor, &Float:iDamage, &iDamageType)
{
    if(!g_bEnabled)
        return Plugin_Continue;

    if(iVictim == 0)
        return Plugin_Continue;

    //Insert Jump Interrupt here with ConVar

    return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:hEvent, const String:sName[], bool:bDontBroadcast)
{
    if(!g_bEnabled)
        return Plugin_Continue;

    // Insert Jump Interrupt here

    return Plugin_Continue;
}

public AnnounceLastJump(iClient)
{
    if(g_iaJumpType[iClient] > JUMP_NONE) {
        new iType = g_iaJumpType[iClient];

        new iQuality;
        for(iQuality = -1; iQuality < sizeof(g_saJumpQualities) - 1; iQuality++) {
            if(g_faDistance[iClient] < g_faQualityDistances[iType][iQuality + 1])
                break;
        }

        if(iQuality > -1) {
            decl String:sNickname[MAX_NAME_LENGTH];
            GetClientName(iClient, sNickname, sizeof(sNickname));

            decl String:sArticle[3] = "a";
            decl String:sFirstLetter[2];
            Format(sFirstLetter, sizeof(sFirstLetter), "%c", g_saPrettyJumpTypes[iType][0]);
            if(StrContains("aeiouh", sFirstLetter, false))
                Format(sArticle, sizeof(sArticle), "an");

            PrintToChatAll("[JS] %s did %s %s %.3f units %s.", 
                sNickname, sArticle, g_saJumpQualities[iQuality], g_faDistance[iClient], g_saPrettyJumpTypes[iType]);
        }
    }
}

public Action:StopBhopRecord(Handle:hTimer, any:iClient)
{
    if(iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient)) {
        g_baCanBhop[iClient] = false;
        if(g_bBunnyHopCancelsAnnouncer) {
            if(g_baAnnounceLastJump[iClient])
                AnnounceLastJump(iClient);
        }
    }
}

public RecordJump(iClient)
{
    GetClientAbsOrigin(iClient, g_faLandCoord[iClient]);
    new Float:fDelta;
    if((g_faLandCoord[iClient][2] >= 0.0 && g_faJumpCoord[iClient][2] >= 0.0) || 
    (g_faLandCoord[iClient][2] <= 0.0 && g_faJumpCoord[iClient][2] <= 0.0))
        fDelta = FloatAbs(g_faLandCoord[iClient][2] - g_faJumpCoord[iClient][2]);
    else
        fDelta = FloatAbs(g_faLandCoord[iClient][2]) + FloatAbs(g_faJumpCoord[iClient][2]);

    if(fDelta < 2.0) {  // allow a height difference of 2 units
        g_faJumpCoord[iClient][2] = 0.0;
        g_faLandCoord[iClient][2] = 0.0;
        g_faDistance[iClient] = GetVectorDistance(g_faJumpCoord[iClient], g_faLandCoord[iClient]) + 32.0;
        if(g_faDistance[iClient] >= MINIMUM_LJ_DISTANCE) {
            if(g_iaBhops[iClient] == 0) {
                if(g_baLadderJumped[iClient]) {
                    g_iaJumpType[iClient] = JUMP_LADJ;
                    g_baLadderJumped[iClient] = false;
                }
                else
                    g_iaJumpType[iClient] = JUMP_LJ;
            }
            else if(g_iaBhops[iClient] == 1)
                g_iaJumpType[iClient] = JUMP_BHJ;
            else
                g_iaJumpType[iClient] = JUMP_MBHJ;
        }
        else
            g_iaJumpType[iClient] = JUMP_TOO_SHORT;
    }
    else if(fDelta < 8.0) { // ladder jumps usually have a height difference of 1 to 7 units, so allow 8
        if(g_baLadderJumped[iClient]) {
            g_faJumpCoord[iClient][2] = 0.0;
            g_faLandCoord[iClient][2] = 0.0;
            g_faDistance[iClient] = GetVectorDistance(g_faJumpCoord[iClient], g_faLandCoord[iClient]) + 32.0;

            if(g_faDistance[iClient] >= MINIMUM_LADJ_DISTANCE) {
                g_iaJumpType[iClient] = JUMP_LADJ;
                g_faLastDistance[iClient] = g_faDistance[iClient];
            }
            else
                g_iaJumpType[iClient] = JUMP_TOO_SHORT;

            g_baLadderJumped[iClient] = false; 
        }
        else
            g_iaJumpType[iClient] = JUMP_VERTICAL;
    }
    else // the player probably didn't intend a longjump so the display will show the last valid jump
        g_iaJumpType[iClient] = JUMP_INVALID;

    if(!g_bBunnyHopCancelsAnnouncer)
        AnnounceLastJump(iClient);
    else
        g_baAnnounceLastJump[iClient] = true;
}

public Action:OnPlayerRunCmd(iClient, &iButtons, &iImpulse, Float:faVelocity[3], Float:faAngles[3], &iWeapon)
{
    if(!g_bEnabled)
        return Plugin_Continue;
    
    // STATS START HERE
    // Record buttons pressed for displaying
    g_iaButtons[iClient] |= iButtons;
    
    // Record X-axis mouse movement for displaying
    static Float:s_fLastXAngle[MAXPLAYERS + 1]
    
    // Recording angles every 9 frames for optimisation
    if(g_iaFrame[iClient] == 8) {
        // The following code is duplicated for optimisation purposes
        if((s_fLastXAngle[iClient] < 0.0 && faAngles[1] < 0.0) || (s_fLastXAngle[iClient] > 0.0 && faAngles[1] > 0.0)) {
            if(faAngles[1] > s_fLastXAngle[iClient])
                g_iaMouseDisplay[iClient] |= MOUSE_LEFT;
            else if(s_fLastXAngle[iClient] > faAngles[1])
                g_iaMouseDisplay[iClient] |= MOUSE_RIGHT;
        }
        else if(s_fLastXAngle[iClient] > 90.0 || faAngles[1] > 90.0) {
            if(faAngles[1] < 0.0)
                g_iaMouseDisplay[iClient] |= MOUSE_LEFT;
            else
                g_iaMouseDisplay[iClient] |= MOUSE_RIGHT;
        }
        else {
            if(faAngles[1] > s_fLastXAngle[iClient])
                g_iaMouseDisplay[iClient] |= MOUSE_LEFT;
            else if(s_fLastXAngle[iClient] > faAngles[1])
                g_iaMouseDisplay[iClient] |= MOUSE_RIGHT;
        }
        s_fLastXAngle[iClient] = faAngles[1]
    }
    
    // Avoid multiple detection of the same jump
    g_iaFrame[iClient]++;
    if(g_iaFrame[iClient] == 9) {
        // The player is able to record a new bunny hop only after 9 frames from the last hop
        g_baJustHopped[iClient] = false;
        g_iaFrame[iClient] = 0;
    }
    
    // Interrupt the jump recording if the player movement type changes (ladder, swimming for example)
    if(g_baJumped[iClient] && GetEntityMoveType(iClient) != MOVETYPE_WALK) {
        InterruptJump(iClient);
    }
    if(GetEntityMoveType(iClient) == MOVETYPE_LADDER) {
        if(!g_baOnLadder[iClient]) {
            g_baOnLadder[iClient] = true;
            g_iaBhops[iClient] = 0;
        }
    }

    // The player is on the ground
    if(GetEntityFlags(iClient) & FL_ONGROUND) {
        if(iButtons & IN_JUMP) {
            if(g_baAntiJump[iClient] && !g_baJustHopped[iClient]) {       // avoid fake jumps and multiple bhop recordings (because runcmd runs on every frame and it can                                                                                                       // detect multiple instances of the same jump)
                if(g_baJumped[iClient]) {   // player jumped during the same frame he landed
                    RecordJump(iClient);
                    GetClientAbsOrigin(iClient, g_faJumpCoord[iClient]);
                    g_iaBhops[iClient]++;            // counts the number of normal bhops
                    g_iaFrame[iClient] = 0;            // used to avoid multiple recordings of a jump
                    g_baJustHopped[iClient] = true;    // the player bhopped, used to avoid multiple recordings
                    g_baJumped[iClient] = true;        // the player jumped (landing will set this to false)
                    g_baCanJump[iClient] = false;    // this variable looks like the opposite of g_baJumped but it is needed to avoid multiple recordings of both perf and norm bhops
                    g_baAnnounceLastJump[iClient] = false;
                }
                else if(g_baCanJump[iClient]) {
                    GetClientAbsOrigin(iClient, g_faJumpCoord[iClient]);
                    if(g_baCanBhop[iClient]) {       // if the bhop time hasn't expired yet
                        g_iaBhops[iClient]++;
                        g_baAnnounceLastJump[iClient] = false;
                    }
                    else {
                        g_iaBhops[iClient] = 0;
                        g_baAnnounceLastJump[iClient] = true;
                    }
                    g_iaFrame[iClient] = 0;
                    g_baJustHopped[iClient] = true;
                    g_baJumped[iClient] = true;
                    g_baCanJump[iClient] = false;
                }
            }
            else {
                g_baJumped[iClient] = false;
            }
        }
        else {    //the player didn't +jump this time (so we can assume a -jump was made before or even now)
            g_baCanJump[iClient] = true;
            if(g_baJumped[iClient]) {
                g_baJumped[iClient] = false;
                if(!g_baJustHopped[iClient]) {        // player jumped before
                    RecordJump(iClient);
                    g_baLadderJumped[iClient] = false; // just in case this was a ladder jump
                    if(!g_baCanBhop[iClient]) {  // !!! this should be moved to recently landed, not stopped jumping
                        CreateTimer(0.1, StopBhopRecord, iClient);    // give the player a chance to bhop
                        g_baCanBhop[iClient] = true;
                        g_baAnnounceLastJump = true;
                    }      
                }
            }
        }     
    }
    else if(GetEntityMoveType(iClient) == MOVETYPE_WALK)
        if(g_baOnLadder[iClient]) { // the player just detached from the ladder
            GetClientAbsOrigin(iClient, g_faJumpCoord[iClient]);
            g_baOnLadder[iClient] = false;
            g_baLadderJumped[iClient] = true; // this might not be 100% true but it works
            g_baJumped[iClient] = true;
        }

    if(!(iButtons & IN_JUMP))
        g_baAntiJump[iClient] = true;    // -jump has been recorded
    else
        g_baAntiJump[iClient] = false;   // +jump as been recorded
    // STATS END HERE

    return Plugin_Continue;
}

public Action:OnRoundEnd(Handle:hEvent, const String:name[], bool:dontBroadcast)
{
    if(!g_bEnabled)
        return Plugin_Continue;
    return Plugin_Continue;
}

stock Float:GetPlayerSpeed(iClient)
{
    new Float:faVelocity[3];
    GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", faVelocity);

    new Float:fSpeed;
    fSpeed = SquareRoot(faVelocity[0] * faVelocity[0] + faVelocity[1] * faVelocity[1]);
    fSpeed *= GetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue");

    return fSpeed;
}
