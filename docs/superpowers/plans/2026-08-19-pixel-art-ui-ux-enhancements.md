# 2D Pixel Art & UI/UX "Juice" Geliştirme Planı

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Kara Kedi oyununu 2D Pixel Art estetiğini destekleyen modern tipografi, squash & stretch buton animasyonları, interpolated (gecikmeli hasar izli) can barı, hitstop vuruş hissi, gelişmiş renk kodlu hasar rakamları (floating text) ve vignette/flash efektleriyle donatarak üst düzey oyun hissiyatına ("juice") ulaştırmak.

**Architecture:** Godot 4.3 GDScript, CanvasLayer UI, Tween tabanlı animasyon sistemi ve Engine time_scale yönetimi. UI ile oyun mantığı birbirinden bağımsız çalışacak şekilde singleton (GameManager) ve sinyaller üzerinden bağlanacaktır.

**Tech Stack:** Godot 4.3 (GDScript 2.0), CanvasItem Shaders, Tweening API, CanvasLayer, Control Nodes.

## Global Constraints

- Oyunun mevcut dalga döngüsü, silah yuvası sistemi ve karakter hareket mantığı korunacaktır.
- Performans 60 FPS sabit kalmalı; mobil cihazlarda çöp toplayıcı (GC) yükü yaratmayacak şekilde Tween ve Node örneklemeleri yönetilecektir.
- UI öğelerinde piksel netliği (Nearest Texture Filter) bozulmayacaktır.

---

### Task 1: UI Butonları İçin Evrensel Yaylanma (Squash & Stretch) Sistemi

**Files:**
- Create: `scripts/ui/ui_juice_helper.gd`
- Modify: `scripts/ui/shop.gd:1-40`
- Modify: `scripts/ui/main_menu.gd:1-45`
- Modify: `scripts/ui/hud.gd:1-45`

**Interfaces:**
- Produces: `UIJuiceHelper.apply_button_juice(button: Button, scale_factor: float = 0.92, duration: float = 0.08)`
- Consumes: Godot `Button` pressed/mouse_entered events and `create_tween()`

- [ ] **Step 1: UIJuiceHelper singleton/statik yardımcı sınıfını oluştur**

```gdscript
class_name UIJuiceHelper
extends RefCounted

## UI Elemanları için Yaylanma ve Mikro Animasyon Yardımcısı (Squash & Stretch)

static func attach_button_juice(btn: Button, press_scale: float = 0.90, hover_scale: float = 1.05) -> void:
	if not is_instance_valid(btn):
		return
	
	btn.pivot_offset = btn.size * 0.5
	btn.resized.connect(func(): btn.pivot_offset = btn.size * 0.5)
	
	btn.button_down.connect(func():
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(press_scale, press_scale), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	btn.button_up.connect(func():
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	)
	
	btn.mouse_entered.connect(func():
		if not btn.disabled:
			var tween = btn.create_tween()
			tween.tween_property(btn, "scale", Vector2(hover_scale, hover_scale), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	)
	
	btn.mouse_exited.connect(func():
		var tween = btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	)
```

- [ ] **Step 2: MainMenu, Shop ve HUD butonlarına Squash & Stretch bağla**

In `scripts/ui/main_menu.gd`:
```gdscript
func _ready() -> void:
	UIJuiceHelper.attach_button_juice($Control/Panel/PlayButton)
```

In `scripts/ui/hud.gd`:
```gdscript
func _ready() -> void:
	UIJuiceHelper.attach_button_juice(pause_btn)
```

In `scripts/ui/shop.gd`:
Attach to `reroll_btn`, `next_wave_btn` and all card purchase/lock buttons.

- [ ] **Step 3: Buton animasyonlarını yerel sunucuda test et**

Run: `curl.exe -I http://127.0.0.1:8060/index.html`
Verify: Butonlara tıklandığında içeri doğru esneyip yaylanarak geri dönmesi.

- [ ] **Step 4: Commit**

```bash
git add scripts/ui/ui_juice_helper.gd scripts/ui/main_menu.gd scripts/ui/hud.gd scripts/ui/shop.gd
git commit -m "feat(ui): add squash and stretch button juice animations"
```

---

### Task 2: Gecikmeli Hasar İzi Bırakan Can Barı (Interpolated Health Bar)

**Files:**
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`

**Interfaces:**
- Produces: `HUD.update_hp(current: float, max_hp: float)` with dual-bar catchup animation.

- [ ] **Step 1: HUD sahnesine hasar izi barı (DamageLagBar) ekle**

In `scenes/ui/hud.tscn`, `BottomBar/HpBar` arkasına kırmızı/turuncu renkli `DamageLagBar` eklenir.

- [ ] **Step 2: HUD scriptinde kademeli dolum ve gecikmeli sönümleme kodunu yaz**

In `scripts/ui/hud.gd`:
```gdscript
@onready var hp_bar: ProgressBar = $Control/BottomBar/HpBar
@onready var damage_lag_bar: ProgressBar = $Control/BottomBar/DamageLagBar
@onready var hp_label: Label = $Control/BottomBar/HpLabel

var hp_tween: Tween

func update_hp(current: float, max_hp: float) -> void:
	hp_bar.max_value = max_hp
	damage_lag_bar.max_value = max_hp
	
	hp_bar.value = current
	hp_label.text = "%d / %d" % [int(current), int(max_hp)]
	
	if is_instance_valid(hp_tween):
		hp_tween.kill()
		
	hp_tween = create_tween()
	# 0.25 saniye bekle, sonra 0.35 saniyede kırmızı barı ana can değerine yaklaştır
	hp_tween.tween_property(damage_lag_bar, "value", current, 0.35).set_delay(0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
```

- [ ] **Step 3: Can barının vuruş anında titreşmesini ve renk değiştirmesini sağla**

Can %25'in altına düştüğünde barın kırmızı renkte nabız gibi atması (pulse effect).

- [ ] **Step 4: Commit**

```bash
git add scenes/ui/hud.tscn scripts/ui/hud.gd
git commit -m "feat(hud): implement interpolated health bar with damage lag trail"
```

---

### Task 3: Vuruş Hissiyatı (Hitstop / Freeze Frame) ve Trauma Screen Shake

**Files:**
- Modify: `scripts/globals/game_manager.gd`
- Modify: `scripts/main.gd`
- Modify: `scripts/player.gd`

**Interfaces:**
- Produces: `GameManager.hitstop(duration: float = 0.05, time_scale: float = 0.05)`
- Produces: `Main.add_trauma(amount: float)`

- [ ] **Step 1: GameManager içine Hitstop fonksiyonu ekle**

```gdscript
var hitstop_timer: SceneTreeTimer = null

func hitstop(duration: float = 0.05, slow_scale: float = 0.05) -> void:
	if Engine.time_scale < 1.0:
		return
	Engine.time_scale = slow_scale
	await get_tree().create_timer(duration * slow_scale, true, false, true).timeout
	Engine.time_scale = 1.0
```

- [ ] **Step 2: Main sahnesi kamera sarsıntısını Trauma sistemine geçir**

In `scripts/main.gd`:
```gdscript
var trauma: float = 0.0
const TRAUMA_DECAY: float = 1.8
const MAX_OFFSET: float = 14.0
const MAX_ROLL: float = 0.04

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
		
	if trauma > 0.0:
		trauma = max(0.0, trauma - TRAUMA_DECAY * delta)
		var shake = trauma * trauma # Non-linear shake feel
		camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * MAX_OFFSET * shake
		camera.rotation = randf_range(-1.0, 1.0) * MAX_ROLL * shake
	else:
		camera.offset = Vector2.ZERO
		camera.rotation = 0.0
```

- [ ] **Step 3: Kritik vuruşlarda ve hasar almada Hitstop & Trauma tetikle**

- [ ] **Step 4: Commit**

```bash
git add scripts/globals/game_manager.gd scripts/main.gd scripts/player.gd
git commit -m "feat(game-feel): add micro hitstop freeze frame and trauma camera shake"
```

---

### Task 4: Gelişmiş Renk Kodlu Hasar Rakamları (Tiered Floating Text)

**Files:**
- Modify: `scripts/vfx/floating_text.gd`
- Modify: `scenes/vfx/floating_text.tscn`
- Modify: `scripts/enemy_base.gd`

**Interfaces:**
- Consumes: `EnemyBase.take_damage(amount, dir, force, is_crit)`
- Produces: `FloatingText.setup(amount, type, custom_color)`

- [ ] **Step 1: FloatingText için zıplama ve süzülme animasyonunu zenginleştir**

In `scripts/vfx/floating_text.gd`:
```gdscript
func setup_damage(amount: int, is_crit: bool = false, is_boss: bool = false) -> void:
	var col = Color.WHITE
	var fsize = 14
	var prefix = ""
	
	if is_crit:
		col = Color(1.0, 0.85, 0.1) # Parlak Altın
		fsize = 18
		prefix = "⚡ "
	elif is_boss:
		col = Color(0.9, 0.3, 1.0) # Mor
		fsize = 17
	elif amount > 30:
		col = Color(1.0, 0.45, 0.2) # Turuncu
		fsize = 15
	
	label.text = prefix + str(amount)
	label.add_theme_color_override("font_color", col)
	label.add_theme_font_size_override("font_size", fsize)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	
	var rand_x = randf_range(-14.0, 14.0)
	position.x += rand_x
	
	scale = Vector2(0.4, 0.4)
	var tween = create_tween().set_parallel(true)
	var target_scale = Vector2(1.3, 1.3) if is_crit else Vector2(1.0, 1.0)
	tween.tween_property(self, "scale", target_scale, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 42.0, 0.50).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.50).set_delay(0.18)
	tween.chain().tween_callback(queue_free)
```

- [ ] **Step 2: EnemyBase'de tüm vuruşlarda hasar rakamı üretilmesini sağla**

In `scripts/enemy_base.gd`:
```gdscript
_spawn_floating_damage(int(amount), is_crit)
```

- [ ] **Step 3: Commit**

```bash
git add scripts/vfx/floating_text.gd scenes/vfx/floating_text.tscn scripts/enemy_base.gd
git commit -m "feat(vfx): enhance tiered floating combat text with outline and bounce"
```

---

### Task 5: Vurulma Beyazlama Efekti (Flash White Shader) ve Atmosferik Vignette

**Files:**
- Create: `assets/shaders/hit_flash.gdshader`
- Create: `assets/shaders/vignette.gdshader`
- Modify: `scenes/main.tscn`
- Modify: `scripts/enemy_base.gd`
- Modify: `scripts/player.gd`

**Interfaces:**
- Produces: Shader material with `flash_modifier` parameter (0.0 = normal, 1.0 = solid white).

- [ ] **Step 1: Hit Flash Shader dosyasını oluştur**

`assets/shaders/hit_flash.gdshader`:
```glsl
shader_type canvas_item;

uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, flash_color.rgb, flash_modifier);
	COLOR = color;
}
```

- [ ] **Step 2: Vignette Shader ve CanvasLayer katmanı ekle**

`assets/shaders/vignette.gdshader`:
```glsl
shader_type canvas_item;

uniform vec4 vignette_color : source_color = vec4(0.0, 0.02, 0.05, 0.45);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.45;
uniform float outer_radius : hint_range(0.0, 1.0) = 0.95;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float vig = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(vignette_color.rgb, vig * vignette_color.a);
}
```

- [ ] **Step 3: Düşman ve karakter hasar aldığında shader flash_modifier'ı 0.08 saniyede tetikle**

- [ ] **Step 4: Commit**

```bash
git add assets/shaders/ scenes/main.tscn scripts/enemy_base.gd scripts/player.gd
git commit -m "feat(shader): add hit flash white shader and atmospheric screen vignette"
```

---

## Verification Plan

### Automated / Build Verification
- Godot headless export çalıştır: `powershell -ExecutionPolicy Bypass -File scratch/setup_and_serve.ps1`
- Hata veya script uyarısı olmadığını doğrula.

### Manual / Visual Verification
1. `http://localhost:8060` adresinde oyunu aç.
2. Ana menü ve market butonlarına tıklayarak yaylanma (Squash & Stretch) efektini gözlemle.
3. Düşmanlara saldırarak renkli hasar rakamlarını ve beyazlama efektini (Flash) test et.
4. Karakter hasar aldığında can barındaki gecikmeli kırmızı izi ve ekran sarsıntısını doğrula.
