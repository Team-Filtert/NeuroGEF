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