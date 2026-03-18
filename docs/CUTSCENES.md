# Overview

cutscenes are made with dialogic. the only changes made are the additions of a few events, all of witch have > as their icon. All dialogic extensions are in addons/dialogic_additions.

# stuff I feel needs an explanation
## Path shortcuts

When an event asks for a character, if the character you want to reference is in the PlayerContainer you can use a shortcut to depending on its position. In order from top to bottom the shortcuts are player, pm1, and pm2 (pm = party member).

## Await

await is an event that prevents the next event from triggering until the character with a matching name completes one of a few events. currently these events are move and animate if "Is A Loop" is false.

## ToggleMode

ToggleMode is equivalent to NpcActionToggleMode. It either activates or deactivates the selected characters selected mode.