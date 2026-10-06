# Content Plan (from the design notes)

Content targets pulled from the team's notes (`Meeting.md`, `some_old_notes.txt`), mapped
against what the current code model supports. This is a **design** document, not a
statement of what's implemented — use it as the authoring checklist for chapter 1.

Legend: ✅ supported by the current model · ⚠️ needs a small addition · ❌ needs a new
mechanic.

---

## 1. Character stat targets

From the "smaller spreadsheet". Current `.tres` values are shown for comparison.

| Character | Type | HP | MP | DEF | ATK | Magic | SPD | Accuracy |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Neuro** (target) | Magic | 20 | 20 | 5 | 3 | 5 | 10 | 5 |
| `neuro.tres` (now) | — | 30 | 15 | 2 | 6 | 5 | 8 | 3 |
| **Evil** (target) | Physical | 30 | 15 | 6 | 5 | 2 | 8 | 3 |
| `evil` (now) | — | _no `CombatantData` yet; `evil.tscn` is an overworld NPC_ | | | | | | |

Notes:

- The stat names match the code (`max_health`, `max_mana`, `attack`, `magic`, `defense`,
  `speed`, `accuracy`).
- **"Accuracy" is the renamed crit stat** — it widens the QTE window (active) and improves
  the roll (relaxed). Anything the notes call "crit rate / reaction time" maps here.
- The current `.tres` stats are placeholders and don't match the target table yet; the
  numbers also assume equipment (`neuro` is equipped in the demo). Rebalance once the
  roster is authored.
- **Evil has no fighter resource yet.** To field Evil as a playable/enemy unit, author an
  `Evil` `PartyMember`/`EnemyData` with the stats above.

---

## 2. Items

### 2.1 Neurotonics (consumables)

All four are "drop from enemy or vending machine", available in all chapters.

| Item | Effect (from notes) | Model | Status |
| --- | --- | --- | --- |
| Blue Neurotonic | Heals 10% MP | `ItemAction.mana` ✅ (but the model is **flat**, not %) | ⚠️ %-based |
| Green Neurotonic | +10% defense for 4 rounds | `ItemAction` + `StatModifier(stat=defense, duration=4)` ✅ | ⚠️ %-based |
| Red Neurotonic | Heals 3% per round for 5 rounds | `ItemAction` + `HealOverTime(duration=5)` ✅ | ⚠️ %-based |
| Orange Neurotonic | 7% reaction-time buff for 4 rounds | `ItemAction` + `StatModifier(stat=accuracy, duration=4)` ✅ | ⚠️ %-based |

The status machinery already exists (`combat/data/status/`); only the **%** maths is a
model gap — `ItemAction`/`StatModifier` use flat numbers today.

### 2.2 Revive items (consumables)

| Item | Effect | Status |
| --- | --- | --- |
| Half cookie | Revive one member to 50% HP | ❌ no revive mechanic |
| Choc-chip cookie | Revive one member to full HP | ❌ |
| Cookie jar | Revive the whole party | ❌ |

`Combatant` has no revive path (a dead combatant fades and is skipped). Revive needs:
a way to target a downed member, and a `revive(percent)` on `Combatant` (or an
`ItemAction` subclass).

### 2.3 Chapter-1 food (consumables)

Yorkshire pudding, Crumpet, Fish n' chips, Beans on toast — names only, **effects not
specified yet**. Author as `Consumable`s once the effects are decided.

### 2.4 Weapons

Shortsword, Magic Stick, Child Sized Knife, Floorboard Sword, Fishing Rod.

⚠️ **Design conflict:** `Meeting.md` says *"weapons got cut, we only have armor and
artefacts now"*, but this list (and the current `Slot.WEAPON` / `CombatantData.weapon`)
still has weapons. Decide before authoring.

### 2.5 Armor

Shellmet (quest), Fishing Vest (fishing house), Witch outfit (shop), Climbing gear (cave).
→ `ItemEquipable(slot = ARMOR)` ✅.

### 2.6 Artefacts

| Item | Buff | Maps to |
| --- | --- | --- |
| Cat Ears | crit rate | `accuracy_modifier` |
| Blue Bow | magic | `magic_modifier` |
| Red Scarf | atk | `attack_modifier` |
| Ringpop | health | `max_health_modifier` |
| Shell Shield | def | `defense_modifier` |

All ✅ as `ItemEquipable(slot = ARTIFACT)`.

---

## 3. Action roster

From the "big spreadsheet" (Neuro and Evil). The description column is the in-game flavour
text; `Amount/Action` and `MP Cost` are the balance columns.

### Neuro

| Name | Type | Effect | Amount | MP | In code? |
| --- | --- | --- | --- | --- | --- |
| Basic Attack | Basic | Damage, Magic | 5 | 0 | ✅ `basic_attack.tres` (currently Physical — should be Magic) |
| Anvil Smash | Skill | Damage, Physical | 20 | 8 | ✅ `anvil_smash.tres` (power not tuned to 20) |
| Protective Bubble | Skill | Shield | 20 | 4 | ❌ no shield status |
| Healing Touch | Skill | Heal | 10 | 3 | ✅ `healing_touch.tres` |
| Drone Strike | Skill | Damage, Physical | 12 | 5 | ❌ to author |
| Magic Blast | Skill | Damage, Magic | 15 | 6 | ✅ `magic_blast.tres` |
| Colourful Array | Ultimate | Heal (regen, 3 turns) | 15 for 3 turns | 0 | ⚠️ author as `Ultimate` + `HealOverTime` |

### Evil

| Name | Type | Effect | Amount | MP | In code? |
| --- | --- | --- | --- | --- | --- |
| Basic Attack | Basic | Damage, Physical | 7 | 0 | ❌ (Evil has no fighter yet) |
| Blow up the crowd | Skill | Damage, Magic (all enemies) | 8 all | 5 | ❌ needs `hits_all` |
| Pipe Attack | Skill | Damage, Debuff, Physical | 15 dmg, -5 DEF | 8 | ⚠️ `Attack` + `StatModifier(defense)` |
| Fire it up | Skill | Buff, Debuff | +5 ATK, -5 DEF | 3 | ⚠️ party buff + side debuff |
| Flare | Skill | Burn (all enemies) | apply burn | 4 | ⚠️ `hits_all` + burn status |
| Fireball | Skill | Damage, Magic, Burn | 13 + burn | 6 | ✅ `fireball.tres` (Evil's version) |
| BOOM | Ultimate | Buff (berserk, 3 turns) | +5 all stats | 0 | ⚠️ `Ultimate` + `StatModifier`s |

**"Shield"** (`Protective Bubble`) has no model yet — the closest primitive is a
`StatModifier`, but a real shield (absorb N damage, or halve it) needs a new status.

---

## 4. Summary of gaps the content list exposes

1. **Percentage-based effects** (neurotonics) — the item/status model is flat-number only.
2. **Revive** — no mechanic at all.
3. **Shield / damage-absorb** — no status.
4. **Weapons** — design says cut, code/list still has them; pick one.
5. **Evil as a fighter** — stats are defined but there's no `CombatantData`.
6. **Tuning** — most existing action `.tres` are placeholders, not the spreadsheet numbers.

See `items_and_inventory.md` for how to author items, `combat.md` §5/§7 for actions and
statuses.
