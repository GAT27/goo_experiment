Goo
==============
Development preview, need to import [gmz](https://github.com/GAT27/goo_experiment/blob/master/Experiment_Goo_Q6.gmz?raw=true) file into GameMaker Studio to play/test. As of V1.99.344, GUI is broken again and online is not connecting properly.

#Controls:

* Player 1 (PS3 through SCP Driver, may work with Xbox and others): Dpad - move, X - jump, [] - weak attack,
/\ - strong attack, O - sbecial attack, L1 - shield, R1 - Charge, Start - start/pause match.

  Right stick - move camera, L2 - zoom out, R2 - zoom in, Select - toggle debug.

* Player 2 (keyboard): WASD - move, Space - jump, M - weak attack, K - strong attack, P - sbecial attack,
Q - shield, E - Charge, R - start/pause match.

#Pausing

Pressing "start" for 6 frames will pause the game, then either press "jump" to end match or "start" to unpause.

#Quick select:

Press and release "strong" to start a match with red as 1 and blue as 2.

#Local match:

Each player selects a character (top 7 boxes) with "jump", once both are selected, press "start" to begin match.

#Replay:

Press "charge" to replay an online/local match, make sure to start a match first on new system, only 1 match is stored,
online takes priority.

#Online (currently not working):

Select the yellow box to go online, then choose to host (with username selected at start) or join someone else's lobby.
Select the green box to go offline, by hosting and leaving, you can go online and join your own lobby and play as a
client-client hairpin loop (some routers may not support this).

#Warnings/crashing:

1. **FIXED** Holding any buttons (besides movement, start/select, camera) during match load. {Initialization issue, crash}

2. Sbecial attacking with certain directional inputs. {Moves not yet programmed, crash}

3. **FIXED** Attacking just at the end of recovery then attacking twice (semi-hard). {Out of bound access, crash}

4. **FIXED** Certain air attacks will cause you to fly or land fast. {Moves not yet programmed, end match}

5. **FIXED** Landing during an aeriel attack animation causes players to fall through. {Collision issue, end match}

6. **FIXED** Pushing players to the left causes fall through, on right, players merge. {Collision issue, end match}

7. **FIXED** Players reaching max distant apart, jump backwards, then move towards causes fall through (semi-hard).
{Collision issue, end match}

#Progress:

0. **STATUSES**
  * **I**N: Task is done (mostly)
  * **W**ORK: Task is being worked on
  * **N**EXT: Task is to be worked on next
  * **P**LAN: Task is mostly planned out and is on wait
  * **L**ATER: Task has not been fully planned out yet

1. Attacking
  * **I** Still weak: Standard jab
  * **I** Still strong: Strong smash
  * **I** Tilt weak: Safe get in
  * **I** Tilt strong: Fast get in
  * **I** Rushing weak: Hop in and out dash
  * **I** Rushing strong: Committed dash
  * **N->I** Downward weak: Low jab
  * **P->W** Downward strong: Different uppercuts based on charge
  * **N->I** Upward weak: Overhead
  * **N->I** Upward strong: Surface to air
  * **W->I** Nair weak: Crossup spin
  * **P->W** Nair strong: Explosion
  * **N->W** Fair weak: Air combo extender
  * **P->W** Fair strong: Air pop or burn ground
  * **N->W** Dair weak: Spiker
  * **P->W** Dair strong: Forced falling smash
  * **I** N sbecial: Fireball
  * **P->N** F sbecial: Heavy rushdown
  * **P->N** D sbecial: Quake pillar
  * **P->N** U sbecial: Aerial grab
  * **P->I** Grab weak: Fast but short ranged
  * **P->/** Grab strong BPF: Throw back, pummel, forward
  * **L->/** Release 123: Supers 123

2. Movement
  * **I** Move dash jump ect : Just play around; also, crouch to cancel a dash

3. Mechanics
  * **I** Shielding: Block low, mid, and high; uses up shield (like Smash)
  * **I** Blocking: Block low and mid; hold back for less damage (like SF)
  * **W->/** Perfect shield: Block ground and air; no damage or hitstun (like 3rd Strike)
  * **I** Passive charging: Buff up strong attacks and gain armor, but lose defense options
  * **P->N**Special charging: Buff up specials, but stays still
  * **I** Stocks: How many times you can get tired (similiar to Smash), charging gets faster, lose at 0
  * **I** Health: Lose at 0
  * **L->N** Ailment: Negative status effects
  * **I** Goo: Allows you to use sbecials and other things, 7 bars
  * **P->I** Boost: Speed meter for certain things, 1 bar
  * **I** Will: Life control against opponent, 2000 health to each, overcome to deplete their stock
  * **L->/** ???: Something certain characters will have
  * **I** Break focus: Use a bar to dash out off an attack animation (like SF4)
  * **P->W** Break shift: Use boost to return to neutral and have a few frames to move (like JojoASB)
  * **L->/** Break ghost: Use a bar and boost to send a copy to attack while you move about
  * **NEXTTIME:/->P** Cores: Sacrifice starting stats for extra benefits
