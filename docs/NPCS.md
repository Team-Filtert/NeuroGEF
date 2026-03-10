# Overview

NPCs are designed to be able to be created by adding node to a scene in setting their exported properties.

The nodes can be divided into 5 categories:
- Templates acts as the root node of the npc
- Actions are things the npc can do
- Triggers trigger actions when its condition is met
- Modes are like actions exsept they dont stop on their own
- Autos are nodes that other nodes add automatically and can be thought of as part of their parent

# Nodes

## Templates

parent: none  
children: triggers, modes 

## Actions

parent: trigger, NpcLoop  
children: none

## Triggers

parent: template  
children: actions

# Modes

parent: template  
children NpcFollow: none  
children NpcLoop: actions