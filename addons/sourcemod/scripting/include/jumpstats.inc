#if defined _jumpstats_natives_
  #endinput
#endif
#define _jumpstats_natives_

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
	Jump_LBHJ
};

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