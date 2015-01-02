goo_experiment
==============
Development preview, need to be imported into GameMaker Studio to play/test.

Controls:

Player 1 (PS3 through SCP Driver, may work with Xbox and others): Dpad - move, X - jump, [] - weak attack,
/\ - strong attack, O - special attack, L1 - shield, R1 - Charge, Start - start/end match.

Right stick - move camera, L2 - zoom out, R2 - zoom in, Select - toggle debug.

Player 2 (keyboard): WASD - move, Space - jump, M - weak attack, K - strong attack, P - special attack,
Q - shield, E - Charge, R - start/end match.

Quick select:

Press and release "strong" to start a match with red as 1 and blue as 2.

Local match:

Each player selects a character (top 7 boxes) with "jump", once both are selected, press "start" to begin match.

Replay:

Press "charge" replay an online/local match, make sure to start a match first on new system, only 1 match is stored,
online takes priority.

Online:

Select the yellow box to go online, then choose to host (with username selected at start) or join someone else's lobby.
Select the green box to go offline, by hosting and leaving, you can go online and join your own lobby and play as a
client-client hairpin loop (some routers may not support this).

Warnings/crashing:

Holding any buttons (besides movement, start/select, camera) during match load. {Initialization issue, crash}

Attacking with certain directional inputs. {Moves not yet programmed, crash}

Attacking just at the end of recovery then attacking twice (semi-hard). {Out of bound access, crash}

Certain air attacks will cause you to fly or land fast. {Moves not yet programmed, end match}

Landing during an aeriel attack animation causes players to fall through. {Collision issue, end match}

Pushing players to the left causes fall through, on right, players merge. {Collision issue, end match}

Players reaching max distant apart, jump backwards, then move towards causes fall through (semi-hard).
{Collision issue, end match}

