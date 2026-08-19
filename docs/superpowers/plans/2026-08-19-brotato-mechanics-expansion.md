# Brotato-Like Core Mechanics Expansion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate *Kara Kedi: Fare İstilası* into a full-depth Arena Roguelite Survivor by integrating the 5 missing genre-defining systems: Character Class Archetypes with unique passives, Weapon Class Synergies with weapon recycling (sell), In-wave dynamic Loot Crates & Fruit, Pre-shop Level-Up Stat Drafting, and Strategic Trade-off (Risk/Reward) shop items.

**Architecture:**
1. Character Archetypes in `scripts/globals/character_data.gd` & UI Selection in `scenes/ui/character_select.tscn`.
2. Weapon Tag/Synergy System in `scripts/globals/game_manager.gd` tracking synergies (Blade, Gun, Blunt, Wild) and weapon selling in `scripts/ui/shop.gd`.
3. Pre-Shop Level-Up Draft UI in `scenes/ui/level_up_draft.tscn` allowing 1-of-3 stat draft before opening the shop.
4. Dynamic In-Wave Loot Crates in `scenes/props/loot_crate.tscn` spawned by `scripts/wave_manager.gd` that drop healing milk bowls and extra gold.
5. Expanded Trade-off item catalog in `scripts/globals/game_manager.gd` with positive and negative stats.

**Tech Stack:** Godot 4.3 (GDScript 2.0, CanvasItem UI, 2D Area Physics, Custom Particles).

---

## Global Constraints

- **Engine:** Godot 4.3 Web & Mobile compatible.
- **Modularity:** Non-breaking extensions to existing `GameManager`, `Shop`, `Player`, and `WaveManager` classes.
- **Visuals:** Strict adherence to 2D pixel snap, hue-shifted shaders, outlined typography, and tactile UI juice.
- **Platform:** Works seamlessly with mobile touch controls and desktop keyboard/mouse.

---

## File Structure Map

```
scripts/
  globals/
    character_data.gd             [MODIFY: Add 4 archetype classes with starter stats & weapon loadouts]
    game_manager.gd               [MODIFY: Sinergy tracking, weapon selling, draft stat definitions]
  ui/
    character_select.gd           [NEW: UI controller for choosing starting cat class]
    level_up_draft.gd             [NEW: Pre-market 3-card stat level up screen]
    shop.gd                       [MODIFY: Weapon slot recycle/sell button & synergy bonus badges]
    hud.gd                        [MODIFY: Add synergy indicators & active class badge]
  props/
    loot_crate.gd                 [NEW: In-wave breakable chest dropping milk/coins]
  wave_manager.gd                 [MODIFY: Spawn loot crates & elite wave modifiers]
scenes/
  ui/
    character_select.tscn         [NEW: Character selection menu]
    level_up_draft.tscn           [NEW: Level-up stat drafting canvas layer]
  props/
    loot_crate.tscn               [NEW: Destructible wooden crate with break particle]
    milk_heal_item.tscn           [NEW: Floating healing milk bowl item]
  main.tscn                       [MODIFY: Mount LevelUpDraft & CharacterSelect canvas layers]
```

---

## Tasks

### Task 1: 4 Özgün Karakter Sınıfı (Character Archetypes) ve Seçim Menüsü

**Files:**
- Modify: `scripts/globals/character_data.gd`
- Modify: `scripts/globals/game_manager.gd`
- Create: `scripts/ui/character_select.gd`
- Create: `scenes/ui/character_select.tscn`
- Modify: `scripts/ui/main_menu.gd`

**Interfaces:**
- Consumes: Character configurations (Nişancı, Pençeci, Zırhlı Tank, Korsan Kedi).
- Produces: `GameManager.apply_character_archetype(char_id)` configuring base HP, move speed, damage modifiers, and starter weapon.

- [ ] **Step 1: Define 4 distinct cat archetypes in character_data.gd**
  - **1. Nişancı Kedi (Marksman):** Başlangıç Silahı: Glock. Statlar: +%30 Menzil, +%20 Hasar, -15 Maks Can.
  - **2. Vahşi Pençeci (Brawler):** Başlangıç Silahı: Pençe. Statlar: +%40 Saldırı Hızı, +%5 Can Çalma, -%20 Menzil.
  - **3. Zırhlı Kara Kedi (Tank/Juggernaut):** Başlangıç Silahı: Kara Çelik Kılıç. Statlar: +30 Maks Can, +4 Zırh, +6 Diken (Thorns), -%15 Hız.
  - **4. Şanslı Korsan Kedi (Lucky Swashbuckler):** Başlangıç Silahı: Balık Bumerangı. Statlar: +%50 Koin Kazancı, +%15 Kritik Şans, -%15 Taban Hasar.

- [ ] **Step 2: Create CharacterSelect UI with interactive cards & button juice**
  - Modal overlay appearing when starting game, showing character portrait, perks, red penalty labels, and "SEÇ & BAŞLA" button.

- [ ] **Step 3: Connect character selection to game start and verify base stat initialization**

---

### Task 2: Silah Sınıf Sinerjileri (Weapon Class Synergies) ve Geri Dönüşüm (Recycle / Sell)

**Files:**
- Modify: `scripts/globals/game_manager.gd`
- Modify: `scripts/ui/shop.gd`
- Modify: `scenes/ui/shop.tscn`

**Interfaces:**
- Consumes: Equipped weapons list in `GameManager.equipped_weapons`.
- Produces: Active synergy multipliers (e.g. 2x Kesici = +%15 Saldırı Hızı, 2x Ateşli = +%20 Menzil/Hasar, 3x İlkel = +20 Can).
- Produces: `GameManager.recycle_weapon(slot_index)` returning 60% of weapon cost.

- [ ] **Step 1: Tag all weapons with synergy categories in GameManager**
  - Kılıç / Pençe: `TAG_BLADE` (Kesici) -> 2 Silah: +%18 Saldırı Hızı, 3 Silah: +%35 Saldırı Hızı & +%5 Can Çalma.
  - Glock / Magnum / Yay: `TAG_GUN` (Menzilli) -> 2 Silah: +%20 Hasar & +%25 Menzil.
  - Bumerang / Yumak Bombası: `TAG_HEAVY` (İlkel/Ağır) -> 2 Silah: +15 Maks Can & +3 Zırh.

- [ ] **Step 2: Calculate synergy buffs dynamically on weapons_updated**
  - Compute active synergy bonuses and add them to character stats.

- [ ] **Step 3: Add "GERİ SAT" (Recycle) button under equipped weapon slots in shop UI**
  - Refund 60% of tier purchase cost and free the slot.

- [ ] **Step 4: Display active synergy tags in Shop and HUD top bar**

---

### Task 3: Dalga İçi Dinamik Hediye Sandıkları (Loot Crates) & İyileştirici Süt Çanağı

**Files:**
- Create: `scripts/props/loot_crate.gd`
- Create: `scenes/props/loot_crate.tscn`
- Create: `scenes/props/milk_heal_item.tscn`
- Modify: `scripts/wave_manager.gd`

**Interfaces:**
- Consumes: Arena spawn coordinates.
- Produces: Destructible in-wave crate that breaks on player attack/contact, dropping 1x Süt Çanağı (+20 Can) and 3-5x Altın Koin.

- [ ] **Step 1: Create LootCrate prop with 15 HP, wobble animation, and break debris particles**

- [ ] **Step 2: Create MilkHealItem collectible that heals player +20 HP with green floating text "+20 CAN"**

- [ ] **Step 3: Spawn 1-2 Loot Crates per wave in wave_manager.gd at random map positions**

- [ ] **Step 4: Verify loot crate spawning, destruction, and healing collection**

---

### Task 4: Dalga Sonu Seviye Atlama Stat Seçimi (Pre-Shop Level-Up Drafting)

**Files:**
- Create: `scripts/ui/level_up_draft.gd`
- Create: `scenes/ui/level_up_draft.tscn`
- Modify: `scripts/globals/game_manager.gd`
- Modify: `scripts/main.gd`

**Interfaces:**
- Consumes: `wave_completed` signal.
- Produces: Intermediate screen before shop where player chooses 1 of 3 free permanent stat boosts.

- [ ] **Step 1: Define pool of level-up stat cards in GameManager**
  - +5 Maksimum Can
  - +2 Zırh
  - +%8 Hasar Artışı
  - +%10 Saldırı Hızı
  - +%12 Hareket Hızı
  - +%5 Kritik Şans
  - +1.0 Can Yenileme (Regen)

- [ ] **Step 2: Create LevelUpDraft CanvasLayer with 3 animated cards and "Zar At (Reroll)" button**

- [ ] **Step 3: Sequence flow: Wave Finished -> LevelUpDraft -> Shop -> Next Wave**

---

### Task 5: Stratejik Risk/Ödül Eşyaları (Trade-Off / Curse Items)

**Files:**
- Modify: `scripts/globals/game_manager.gd`
- Modify: `scripts/ui/shop.gd`

**Interfaces:**
- Consumes: Shop offer generator.
- Produces: Double-edged items with green positive perks and red penalty drawbacks for deep build variety.

- [ ] **Step 1: Add 8 new trade-off items to shop catalog**
  - **Cam Hançer:** +%35 Hasar, -15 Maks Can.
  - **Ağır Şövalye Zırhı:** +6 Zırh, -%14 Hareket Hızı.
  - **Korsan Dürbünü:** +%40 Menzil, -%10 Saldırı Hızı.
  - **Kediotu İksiri:** +%30 Saldırı Hızı, -%10 Taban Hasar.
  - **Dikenli Tasma:** +10 Diken Hasarı, -5 Maks Can.
  - **Altın Çılgınlığı:** +%60 Koin Kazancı, +%15 Alınan Düşman Hasarı.
  - **Keskin Pençe Bileyicisi:** +%20 Kritik Şans, -2 Zırh.
  - **Vampir Dişi:** +%8 Can Çalma, -1.0 Pasif Can Yenileme.

- [ ] **Step 2: Format trade-off shop cards with distinct green/red stat bullet descriptions**

- [ ] **Step 3: Apply positive and negative delta values safely via apply_item_buff**

---

## Verification Plan

### Automated / Headless Build Test:
- Run `powershell -ExecutionPolicy Bypass -File scratch/setup_and_serve.ps1`
- Verify Godot exit code 0 and successful `.pck` / `.wasm` generation.

### Manual / In-Game Verification:
- Open `http://localhost:8060`
- Test:
  1. Character Selection screen displays 4 classes, each starting with correct stats and weapon.
  2. Equipping 2 same-category weapons displays synergy badge and applies stat bonus.
  3. Selling weapon in shop refunds coins and empties slot.
  4. Loot crates spawn in arena, drop milk healing items and extra coins.
  5. Completing a wave opens the 3-card Level Up draft before entering the shop.
  6. Buying trade-off items applies both the green bonus and red penalty.
