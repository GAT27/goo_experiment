goo_experiment
==============
Development preview, need to be imported into GameMaker Studio to play/test.

#Controls:

* Player 1 (PS3 through SCP Driver, may work with Xbox and others): Dpad - move, X - jump, [] - weak attack,
/\ - strong attack, O - special attack, L1 - shield, R1 - Charge, Start - start/end match.

  Right stick - move camera, L2 - zoom out, R2 - zoom in, Select - toggle debug.

* Player 2 (keyboard): WASD - move, Space - jump, M - weak attack, K - strong attack, P - special attack,
Q - shield, E - Charge, R - start/end match.

#Quick select:

Press and release "strong" to start a match with red as 1 and blue as 2.

#Local match:

Each player selects a character (top 7 boxes) with "jump", once both are selected, press "start" to begin match.

#Replay:

Press "charge" replay an online/local match, make sure to start a match first on new system, only 1 match is stored,
online takes priority.

#Online:

Select the yellow box to go online, then choose to host (with username selected at start) or join someone else's lobby.
Select the green box to go offline, by hosting and leaving, you can go online and join your own lobby and play as a
client-client hairpin loop (some routers may not support this).

#Warnings/crashing:

1. Holding any buttons (besides movement, start/select, camera) during match load. {Initialization issue, crash}

2. Attacking with certain directional inputs. {Moves not yet programmed, crash}

3. Attacking just at the end of recovery then attacking twice (semi-hard). {Out of bound access, crash}

4. Certain air attacks will cause you to fly or land fast. {Moves not yet programmed, end match}

5. Landing during an aeriel attack animation causes players to fall through. {Collision issue, end match}

6. Pushing players to the left causes fall through, on right, players merge. {Collision issue, end match}

7. Players reaching max distant apart, jump backwards, then move towards causes fall through (semi-hard).
{Collision issue, end match}

#Progress:

0. **STATUSES**
  * IN: Task is done (mostly)
  * WORK: Task is being worked on
  * NEXT: Task is to be worked on next
  * PLAN: Task is mostly planned out and is on wait
  * LATER: Task has not been fully planned out yet

1. Attacking
  * Still weak **IN**: Standard jab
  * Still strong **IN**: Strong smash
  * Tilt weak **IN**: Safe get in
  * Tilt strong **IN**: Fast get in
  * Rushing weak **IN**: Hop in and out dash
  * Rushing strong **IN**: Committed dash
  * Downward weak **NEXT**: Low jab
  * Downward strong **PLAN**: Different uppercuts based on charge
  * Upward weak **NEXT**: Overhead
  * Upward strong **NEXT**: Surface to air
  * Nair weak **WORK**: Crossup spin
  * Nair strong **PLAN**: Explosion
  * Fair weak **NEXT**: Air combo extender
  * Fair strong **PLAN**: Air pop or burn ground
  * Dair weak **NEXT**: Spiker
  * Dair strong **PLAN**: Forced falling smash
  * N special **IN**: Fireball
  * F special **PLAN**: Heavy rushdown
  * D special **PLAN**: Quake pillar
  * U special **PLAN**: Aerial grab
  * Grab weak **PLAN**: Fast but short ranged
  * Grab strong BPF **PLAN**: Throw back, pummel, forward
  * Release 123 **LATER**: Supers 123

2. Movement
  * Move dash jump ect **IN**: Just play around; also, crouch to cancel a dash

3. Mechanics
  * Shielding **IN**: Block low, mid, and high; uses up shield (like Smash)
  * Blocking **IN**: Block low and mid; hold back for less damage (like SF)
  * Perfect shield **WORK**: Block ground and air; no damage or hitstun (like 3rd Strike)
  * Passive charging **IN**: Buff up strong attacks and gain armor, but lose defense options
  * Special charging **PLAN**: Buff up specials, but stays still
  * Stocks **IN**: How many times you can get tired (similiar to Smash), charging gets faster, lose at 0
  * Health **IN**: Lose at 0
  * Ailment **LATER**: Negative status effects
  * Meter **IN**: Allows you to use specials and other things, 7 bars
  * Boost **PLAN**: Speed meter for certain things, 1 bar
  * Will **IN**: Life control against opponent, 2000 health to each, overcome to deplete their stock
  * ??? **LATER**: Something certain characters will have
  * Break focus **IN**: Use a bar to dash out off an attack animation (like SF4)
  * Break shift **PLAN**: Use boost to return to neutral and have a few frames to move (like JojoASB)
  * Break ghost **LATER**: Use a bar and boost to send a copy to attack while you move about
  * GEMS **NEXT TIME :/**: ???
