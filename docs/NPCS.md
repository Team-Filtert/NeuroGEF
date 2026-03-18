# Overview

NPCs are designed to be able to be created by adding node to a scene in setting their exported properties.

The nodes can be divided into 5 categories:
- Templates acts as the root node of the npc
- Actions are things the npc can do
- Triggers trigger actions when its condition is met
- Modes are like actions exsept they dont stop on their own
- Autos are nodes that other nodes add automatically and can be thought of as part of their parent

# Using the nodes
## Creating a new NPC

to create a new npc you make template node then set either its Sprite2ds texture or its AnimatedSprite2ds sprite frames

## Using triggers

triggers are added as the children of the template.  

When a triggers condition is meat it will trigger all its child action nodes one at a time from top to bottom, stoping after it finishes the last one.

## Using loops

loops are added as the children of the template.  

loops can be activated and deactivated by things like a NpcActionToggleMode node.  

when a loop is a activated it will trigger all its child action nodes one at a time from top to bottom, returning to the top after it finishes the last one.

## Using follows

follows are added as the children of the template.  

loops can be activated and deactivated by things like a NpcActionToggleMode node.

when a follow is a activated the npc will follow the node set as the target.

# Creating new nodes

all non auto NPC nodes should extend their corresponding base node

## Templates

in _ready the template must:
- create a sprite and collider nodes
- set the animation_player and animated_sprite nodes
- call connect_nodes()

in _physics_process the template must:
- call script_control(delta)

## Actions

in _preform_action the action must:
- define what the action should do when triggered

### If the action is not short and the NPC is expected to wait before perform the next one:

in _ready the action must:
- set wait to true

somewhere the action must:
- emit done_action when it is done

## Triggers

in _ready the trigger must:
- call connect_actions()

somewhere the trigger must:
- call trigger_actions() when its condition is met

## Modes

in _activate the mode must:
- define what the mode should do when it starts
- set is_active to true

in _deactivate the mode must:
- define what the mode should do when it stops
- set is_active to false
