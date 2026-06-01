# Architecture Overview

## The main scene

```
Main (Node)
  |_ SceneContainer (Node)
  |_ UILayer (CanvasLayer)
```

- **SceneContainer:** Holds the active gameplay scene. Scenes are swapped in and out of it as the player navigates the world or engages in combat, etc.
- **UILayer:** Holds active UI nodes and is managed through a stack, allowing them to be stacked, swapped or cleared easily.

> **Note about UI**: Simple menus and overlays work naturally with the stack, but UI scenes with complex animations or transitions between internal elements should be self-contained. These are still pushed onto the stack, but what happens inside them is up to the individual scene.

## Autoloads

### AudioManager

Handles the playback of bgm and global sfx, can handle multiple simultaneous global sfx with AudioStreamPolyphonic.

### Game

Owns the runtime state of the game, such as the player's party and inventory. This state is held as a `GameState` resource internally, and it takes care of its own serialization and deserialization.

### SaveManager

Handles reading and writing save files to disk. Serializes `Game.state` to JSON on save and deserializes it back on load. Keeps track of the current save slot.

### SceneManager

Holds a reference to `SceneContainer` and manages it by swapping scenes in and out of it.

### UIManager

Holds a reference to `UILayer` and manages it by pushing and popping scenes onto and off the stack.

## Ideas for later

- Registries for gameplay scenes, UI scenes, items and other resources.
- Game phases.
- Player spawning when switching between gameplay scenes needs some more thought.
- Document new resources.
- Grid based movement.
- NPCs.