# 2D Pixel Art & Visual Aesthetic Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the visual identity of *Kara Kedi: Fare İstilası* into a cohesive, professional 2D pixel art experience by applying 5 core artistic pillars: Hue Shifting palettes, Mixel-free pixel grid consistency, cluster silhouette design, 3-tier value separation with 2D lighting, and anime/arcade smear frames.

**Architecture:** 
1. Pixel-perfect rendering configuration in `project.godot` (snapping 2D transforms to pixel, uniform pixel density, pixel filter nearest).
2. Hue-shifted color lookup & palette styling for characters, enemies, collectibles, and arena tiles.
3. 3-tier value separation (dark desaturated floor, high-contrast crisp gameplay actors, emissive additive particles/projectiles).
4. Kinetic smear frames and directional motion trail FX on weapon swings and dashes.

**Tech Stack:** Godot 4.3 (GDScript 2.0, CanvasItem Shaders, PointLight2D, 2D Pixel Snap, Custom Particle VFX).

---

## Global Constraints

- **Engine:** Godot 4.3 Web and Mobile Compatible (GLES3 / Compatibility renderer).
- **Pixel Grid:** Uniform 1:1 or 2x integer scale, no mixed resolution pixels (Anti-Mixel).
- **Color Discipline:** Shadows shift to cool purple/navy (`#1b172a`), highlights shift to warm amber/gold (`#f7c844`), eyes/magic to emerald/cyan (`#38ef7d`).
- **File Integrity:** Zero breaking changes to existing gameplay mechanics, weapons, waves, and singleton APIs.

---

## File Structure Map

```
assets/
  shaders/
    palette_swap.gdshader         [NEW: Hue-shift & palette harmonization shader]
    emissive_glow.gdshader         [NEW: 2D light glow shader for projectiles & collectibles]
  textures/
    fx/
      smear_slash_16x32.png        [NEW: Elongated smear arc sprite]
      dash_trail_particle.png      [NEW: Motion blur trail particle]
scripts/
  vfx/
    smear_trail_emitter.gd        [NEW: Component for attaching smear lines to weapons/dashes]
  globals/
    game_manager.gd               [MODIFY: Hook palette and lighting configurations]
scenes/
  vfx/
    slash_arc_fx.tscn             [MODIFY: Upgrade with multi-tier smear frame animation]
  player.tscn                     [MODIFY: Pixel scale normalization & light aura]
  enemies/
    rat_small.tscn                [MODIFY: Silhouette enhancement & shadow layer]
    rat_dasher.tscn               [MODIFY: Smear trail attachment & silhouette]
    rat_tank.tscn                 [MODIFY: Bulk silhouette & cluster shading]
    boss_rat_king.tscn            [MODIFY: Royal silhouette, crown glow, shockwave smear]
  main.tscn                       [MODIFY: 2D WorldEnvironment, CanvasModulate ambient light]
```

---

## Tasks

### Task 1: Pixel Grid Consistency & Anti-Mixel Engine Configuration

**Files:**
- Modify: `project.godot`
- Modify: `scripts/player.gd:25-35`
- Modify: `scenes/player.tscn`

**Interfaces:**
- Consumes: Godot 2D rendering pipeline settings.
- Produces: Pixel-perfect viewport rendering where all sprites, tiles, and particles share the exact same screen pixel density with zero fractional blurring or mixel distortion.

- [ ] **Step 1: Configure project.godot for 2D pixel snapping and texture filtering**
  - Set `rendering/2d/snap/snap_2d_transforms_to_pixel=true`
  - Set `rendering/2d/snap/snap_2d_vertices_to_pixel=true`
  - Set `rendering/textures/canvas_textures/default_texture_filter=0` (Nearest)

- [ ] **Step 2: Normalize player base scale to integer grid**
  - Update `PLAYER_BASE_SCALE` in `scripts/player.gd` to `2.0` (clean 2x pixel grid) and adjust collision radius accordingly to avoid sub-pixel scaling.

- [ ] **Step 3: Test and verify integer rendering**
  - Run headless export and verify no sprite distortion occurs when rotating 8 directions.

---

### Task 2: Hue Shifting & Harmonized Color Palette System

**Files:**
- Create: `assets/shaders/palette_swap.gdshader`
- Modify: `scripts/player.gd`
- Modify: `scripts/enemy_base.gd`

**Interfaces:**
- Consumes: Sprite textures.
- Produces: Rich, non-linear shading where dark shadows shift towards deep night-indigo (`#181425`, `#262b44`) and lit areas shift towards warm sunlight (`#fee761`, `#ff0044`), eliminating flat gray/black shading.

- [ ] **Step 1: Write palette_swap.gdshader with smooth hue-luminance gradient remap**
  ```glsl
  shader_type canvas_item;
  uniform vec4 shadow_tint : source_color = vec4(0.12, 0.09, 0.22, 1.0);
  uniform vec4 mid_tone : source_color = vec4(0.24, 0.20, 0.35, 1.0);
  uniform vec4 highlight_tint : source_color = vec4(0.98, 0.82, 0.32, 1.0);
  uniform float tint_weight : hint_range(0.0, 1.0) = 0.35;
  
  void fragment() {
      vec4 col = texture(TEXTURE, UV);
      if (col.a < 0.01) discard;
      float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
      vec3 graded = mix(shadow_tint.rgb, highlight_tint.rgb, lum);
      COLOR = vec4(mix(col.rgb, graded, tint_weight), col.a);
  }
  ```

- [ ] **Step 2: Apply hue-shifted shading to Kara Kedi and enemy classes**
  - Equip `palette_swap.gdshader` with character-tailored parameters (Black Cat: dark purple-black fur with vibrant emerald eyes and warm gold feathers).

- [ ] **Step 3: Verify visual contrast against all background floors**

---

### Task 3: Silhouette Clarity & Cluster Design for Enemy Types

**Files:**
- Modify: `scenes/enemies/rat_small.tscn`
- Modify: `scenes/enemies/rat_dasher.tscn`
- Modify: `scenes/enemies/rat_spitter.tscn`
- Modify: `scenes/enemies/rat_tank.tscn`
- Modify: `scenes/enemies/boss_rat_king.tscn`

**Interfaces:**
- Consumes: Enemy base stats and collision nodes.
- Produces: Instant silhouette readability at 60 FPS in dense mob swarms using strong visual archetypes:
  - Small Rat: Compact, low-profile, rapid tail oscillation.
  - Dasher Rat: Aerodynamic elongated snout, bright red warning eyes.
  - Spitter Rat: Bulging luminous toxic-green abdomen.
  - Tank Rat: Heavy armored brow, thick spiked back cluster.
  - Boss Rat King: Majestic silhouette with crowned mantle and glowing golden eyes.

- [ ] **Step 1: Add distinct drop-shadow ellipse under all enemy nodes**
  - Add dark translucent ellipse Sprite2D (`Color(0.05, 0.05, 0.1, 0.45)`) below feet to ground characters in 2.5D space.

- [ ] **Step 2: Add visual outline / cluster definition**
  - Ensure high-contrast outlines (1px dark contour) so units never blend into one another when overlapping.

- [ ] **Step 3: Verify mob clarity during dense wave spawns (Dalga 5+)**

---

### Task 4: 3-Tier Value Separation & 2D Ambient Atmosphere

**Files:**
- Modify: `scenes/main.tscn`
- Modify: `scenes/coin.tscn`
- Modify: `scenes/weapons/*.tscn`

**Interfaces:**
- Consumes: Main viewport canvas and lighting.
- Produces: 3 distinct visual layers:
  1. **Background Layer (Floor & Walls):** Modulated darker (`#454d66`) with reduced saturation.
  2. **Gameplay Actors Layer (Cat & Rats):** Pure 100% luminance and crisp silhouettes.
  3. **Foreground Emissive Layer:** Glowing projectiles, coin glints, and magic bursts with soft 2D radial light.

- [ ] **Step 1: Adjust floor & arena walls value modulation**
  - Set `Background` modulate to `Color(0.68, 0.72, 0.85, 1.0)` to let bright foreground sprites pop.

- [ ] **Step 2: Add ambient 2D lighting to coins and projectiles**
  - Add soft radial light / glow material to `coin.tscn` (golden shimmer) and `projectile_acid.png` (toxic green glow).

- [ ] **Step 3: Verify depth hierarchy in browser on localhost:8060**

---

### Task 5: Kinetic Smear Frames & Arcade Motion FX

**Files:**
- Create: `scenes/vfx/smear_trail.tscn`
- Modify: `scripts/vfx/slash_arc_fx.gd`
- Modify: `scenes/vfx/slash_arc_fx.tscn`
- Modify: `scripts/rat_dasher.gd`

**Interfaces:**
- Consumes: Weapon attack angles and enemy dash velocity vectors.
- Produces: High-speed anime/arcade smear curves and ghost trails that give instant weight, momentum, and impact to attacks.

- [ ] **Step 1: Create animated 3-frame elongated smear arc for melee weapons**
  - Frame 1: Anticipation flash.
  - Frame 2: Wide distorted kinetic smear line (180-degree crescent).
  - Frame 3: Dissipating speed lines and spark debris.

- [ ] **Step 2: Add dynamic dash after-image ghosting to Dasher Rats and Player**
  - Spawns fading silhouette ghosts along the movement path during high-velocity bursts.

- [ ] **Step 3: Re-export Web build, test on local server, and capture verification recording**

---

## Verification Plan

### Automated / Headless Build Test:
- Run `powershell -ExecutionPolicy Bypass -File scratch/setup_and_serve.ps1`
- Verify Godot exit code 0 and successful `.pck` / `.wasm` generation.

### Browser Verification:
- Launch browser subagent on `http://localhost:8060`.
- Verify:
  1. No mixels / crisp pixel scaling.
  2. Hue-shifted color depth and 3-tier value separation.
  3. Smear frames on weapon swings.
  4. 60 FPS performance without console errors.
