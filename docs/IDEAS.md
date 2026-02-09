# Combat Phases, Actions and Resolution

---

# General Idea

Combat will flow across the following different phases

| Phase            | Description                                                              |
|------------------|--------------------------------------------------------------------------|
| Input phase      | Collect the player's actions (attack, ability, heal, etc.), add to queue |
| AI phase         | Enemies decide actions, add to queue                                     |
| Resolution phase | Execute actions in the queue in order                                    |
| Check phase      | Win/lose conditions, loop around to input phase                          |
