#if defined _jumpstats_included_
  #endinput
#endif
#define _jumpstats_included_

/**
 * JumpTypes.
 */
enum JumpType
{
	Jump_None,
	Jump_LJ,
	Jump_BHJ,
	Jump_MBHJ,
	Jump_LadJ,
	Jump_WHJ,
	Jump_LDHJ,
	Jump_LBHJ,
	Jump_End
};

//Jump consts
new const String:g_saJumpTypes[][] = {
    "None",
    "LJ",
    "BHJ",
    "MBHJ",
    "LadJ",
    "WHJ",
    "LDHJ",
    "LBHJ"
}
new const String:g_saPrettyJumpTypes[][] = {
    "None",
    "Long Jump",
    "BunnyHop Jump",
    "Multi BunnyHop Jump",
    "Ladder Jump",
    "WeirdHop Jump",
    "Ladder DropHop Jump",
    "Ladder BunnyHop Jump"
}

/**
 * @brief Interrupts a player's current jump stats recording.
 *
 * @param client    The target player.
 * @return          True if the jump was successfully interrupted, false otherwise.
 */
native JumpStats_InterruptJump(client);

/**
 * Called when player do a jump.
 */
forward OnJump(client, JumpType:type, Float:distance);