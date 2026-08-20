$webDir = $PSScriptRoot
$projectDir = Split-Path -Path $webDir -Parent

# 1. Dokuları Base64 olarak topla
$assets = @{}

function Get-Base64Image($path) {
    if (Test-Path $path) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $ext = [System.IO.Path]::GetExtension($path).Replace(".", "").ToLower()
        if ($ext -eq "jpg") { $ext = "jpeg" }
        return "data:image/$ext;base64," + [Convert]::ToBase64String($bytes)
    }
    return ""
}

$assets["floor"] = Get-Base64Image "$projectDir\assets\textures\topdown_rooftop_floor.png"
$assets["parapet"] = Get-Base64Image "$projectDir\assets\textures\topdown_parapet_ledge.png"
$assets["gas_tank"] = Get-Base64Image "$projectDir\assets\textures\explosive_gas_tank.png"
$assets["sewer_grate"] = Get-Base64Image "$projectDir\assets\textures\sewer_vent_grate.png"
$assets["loot_crate"] = Get-Base64Image "$projectDir\assets\textures\loot_crate_wood.png"
$assets["milk_bowl"] = Get-Base64Image "$projectDir\assets\textures\milk_bowl_item.png"

# Yeni Kara Kedi Kahraman Dokuları (Pixis Karakteri)
for ($i = 0; $i -lt 4; $i++) {
    $assets["hero_idle_$i"] = Get-Base64Image "$projectDir\assets\textures\karakedi_hero\frames\idle_$i.png"
}
for ($i = 0; $i -lt 6; $i++) {
    $assets["hero_walk_$i"] = Get-Base64Image "$projectDir\assets\textures\karakedi_hero\frames\walk_$i.png"
}
for ($i = 0; $i -lt 3; $i++) {
    $assets["hero_attack_$i"] = Get-Base64Image "$projectDir\assets\textures\karakedi_hero\frames\attack_$i.png"
}

# 8-Yönlü Dokular & Animasyonlar
$dirs = @("south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west")
foreach ($d in $dirs) {
    $assets["hero_rot_$d"] = Get-Base64Image "$projectDir\assets\textures\karakedi_hero\rotations\$d.png"
    $assets["player_$d"] = $assets["hero_rot_$d"]
    for ($f = 0; $f -lt 8; $f++) {
        $assets["hero_run_${d}_$f"] = Get-Base64Image "$projectDir\assets\textures\karakedi_hero\animations\Running\$d\frame_00$f.png"
    }
}
$assets["portrait_standard"] = $assets["hero_idle_0"]
if (-not $assets["portrait_standard"]) { $assets["portrait_standard"] = $assets["hero_rot_south"] }

$jsonAssets = $assets | ConvertTo-Json -Compress

# 2. Tam Kapsamlı HTML & JS Oyun Motoru
$htmlPart1 = @'
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Kara Kedi: Fare &#304;stilas&#305; | BLB Web S&#252;r&#252;m&#252;</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; -webkit-user-select: none; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { background-color: #050608; color: #f0f0f0; overflow: hidden; display: flex; justify-content: center; align-items: center; height: 100vh; width: 100vw; }
    #game-wrapper { position: relative; width: 100%; height: 100%; max-width: 480px; max-height: 854px; aspect-ratio: 9 / 16; background: #000; box-shadow: 0 0 50px rgba(0,0,0,0.95), 0 0 25px rgba(245, 190, 35, 0.25); border-radius: 16px; overflow: hidden; border: 3px solid #202636; }
    canvas { width: 100%; height: 100%; display: block; image-rendering: pixelated; }
    .ui-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; display: flex; flex-direction: column; }
    .interactive { pointer-events: auto; }

    /* HUD */
    #hud { display: flex; flex-direction: column; padding: 12px; gap: 8px; }
    .hud-row { display: flex; justify-content: space-between; align-items: center; }
    .hud-badge { background: rgba(14, 18, 28, 0.92); border: 1.5px solid rgba(245, 190, 35, 0.4); padding: 6px 12px; border-radius: 8px; font-weight: bold; font-size: 13px; color: #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.4); }
    .hp-container { display: flex; align-items: center; gap: 8px; }
    .hp-bar-bg { width: 130px; height: 14px; background: #2b0b0b; border: 1.5px solid #ff4444; border-radius: 7px; overflow: hidden; }
    .hp-bar-fill { height: 100%; background: linear-gradient(90deg, #ff2222, #ff6633); width: 100%; transition: width 0.15s ease-out; }
    #boss-hud { display: none; flex-direction: column; align-items: center; gap: 4px; margin-top: 4px; }
    .boss-bar-bg { width: 90%; height: 16px; background: #1f0505; border: 2px solid #f5be23; border-radius: 8px; overflow: hidden; }
    .boss-bar-fill { height: 100%; background: linear-gradient(90deg, #ff1100, #ff8800); width: 100%; transition: width 0.1s linear; }

    /* MODALS */
    .modal-backdrop { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(4, 6, 12, 0.94); backdrop-filter: blur(8px); display: none; flex-direction: column; justify-content: center; align-items: center; padding: 14px; z-index: 50; }
    .modal-box { background: #0f1118; border: 3px solid #f5be23; border-radius: 20px; width: 96%; max-width: 440px; padding: 18px; display: flex; flex-direction: column; align-items: center; gap: 12px; box-shadow: 0 0 35px rgba(245, 190, 35, 0.3); }

    .btn-action { background: #f5be23; color: #150f03; font-weight: bold; font-size: 16px; padding: 10px 24px; border: 2px solid #fff070; border-radius: 12px; cursor: pointer; transition: all 0.15s ease; outline: none; }
    .btn-action:hover { background: #c01010; color: #fff; border-color: #ff5555; transform: scale(1.04); box-shadow: 0 0 20px rgba(192, 16, 16, 0.8); }

    .char-card { background: #121622; border: 2px solid #28354d; border-radius: 12px; padding: 10px; display: flex; gap: 10px; align-items: center; cursor: pointer; transition: all 0.2s ease; }
    .char-card:hover { border-color: #00d2ff; }
    .char-card.selected { border-color: #f5be23 !important; background: #182236; box-shadow: 0 0 16px rgba(245, 190, 35, 0.4); }
    .char-card.locked { background: #0a0d14; border-color: #2b3548; cursor: default; }
    .char-card.locked .char-avatar-box { opacity: 0.45; filter: grayscale(90%); }
    .char-card.locked .char-title, .char-card.locked .char-stats { opacity: 0.55; }
    .quest-badge-box { background: rgba(35, 25, 10, 0.98); border: 1.5px solid #f5be23; border-radius: 8px; padding: 6px 8px; margin-top: 5px; box-shadow: 0 2px 10px rgba(0,0,0,0.6); }
    .char-avatar-box { width: 52px; height: 52px; background: #090c14; border-radius: 8px; display: flex; justify-content: center; align-items: center; border: 1.5px solid #334460; }
    .char-details { flex: 1; display: flex; flex-direction: column; gap: 2px; }
    .char-name-row { display: flex; justify-content: space-between; align-items: center; }
    .char-name { font-size: 14px; font-weight: bold; color: #f5be23; }
    .char-title { font-size: 10px; color: #8fa0b5; }
    .char-stats { font-size: 10px; color: #cbd5e0; margin-top: 2px; }
    .char-quest-bar { width: 100%; height: 8px; background: #222; border-radius: 4px; overflow: hidden; margin-top: 4px; border: 1px solid #444; }
    .char-quest-fill { height: 100%; background: #00d2ff; width: 0%; }

    /* SHOP */
    .shop-box { background: #0c0e14; border: 3px solid #f5be23; border-radius: 18px; width: 98%; max-height: 95%; padding: 12px; display: flex; flex-direction: column; gap: 8px; overflow-y: auto; box-shadow: 0 0 35px rgba(245, 190, 35, 0.25); }
    .slots-grid { display: flex; justify-content: space-between; gap: 6px; }
    .slot-card { flex: 1; background: #131722; border: 2px solid #2a3547; border-radius: 8px; padding: 6px 4px; font-size: 11px; text-align: center; display: flex; flex-direction: column; gap: 4px; }
    .cards-wrapper { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .card-item { background: #11141e; border: 2.5px solid #2a3a55; border-radius: 12px; padding: 8px; display: flex; flex-direction: column; align-items: center; text-align: center; gap: 4px; position: relative; }
    .card-title { font-size: 13px; font-weight: bold; }
    .card-category { font-size: 10px; font-weight: bold; }
    .card-desc { font-size: 11px; color: #ccc; min-height: 36px; line-height: 1.3; }
    .btn-buy { width: 100%; background: #2575fc; border: none; color: white; padding: 6px; border-radius: 6px; font-size: 12px; font-weight: bold; cursor: pointer; }
    .btn-buy:disabled { background: #262a36; color: #667; cursor: not-allowed; }

    /* JOYSTICK */
    #touch-joystick { position: absolute; bottom: 25px; left: 25px; width: 110px; height: 110px; background: rgba(255, 255, 255, 0.08); border: 2px solid rgba(255, 255, 255, 0.25); border-radius: 50%; display: none; touch-action: none; }
    #touch-knob { position: absolute; top: 32px; left: 32px; width: 46px; height: 46px; background: rgba(245, 190, 35, 0.8); border-radius: 50%; box-shadow: 0 0 12px rgba(245, 190, 35, 0.6); }
  </style>
</head>
<body>

<div id="game-wrapper">
  <canvas id="gameCanvas" width="720" height="1280"></canvas>

  <!-- HUD -->
  <div class="ui-overlay" id="hud-layer">
    <div id="hud">
      <div class="hud-row">
        <div class="hud-badge">&#127754; DALGA <span id="hud-wave">1</span>/15</div>
        <div class="hud-badge" id="hud-timer">&#9201;&#65039; 00:25</div>
        <div class="hud-badge">&#129689; <span id="hud-coins">0</span></div>
      </div>
      <div class="hud-row">
        <div class="hp-container">
          <span style="font-size: 12px; font-weight: bold; color: #ff5555;">&#10084;&#65039; CAN</span>
          <div class="hp-bar-bg"><div class="hp-bar-fill" id="hud-hp"></div></div>
        </div>
        <button class="hud-badge interactive" id="btn-pause" style="cursor: pointer; background: #192233;">&#9208;&#65039; Durdur</button>
      </div>
      <div id="boss-hud">
        <span id="boss-label" style="font-size: 12px; font-weight: bold; color: #f5be23;">&#128081; FARE KRALI</span>
        <div class="boss-bar-bg"><div class="boss-bar-fill" id="boss-hp"></div></div>
      </div>
    </div>
  </div>

  <!-- VIRTUAL JOYSTICK -->
  <div id="touch-joystick"><div id="touch-knob"></div></div>

  <!-- MAIN MENU -->
  <div class="modal-backdrop interactive" id="modal-menu" style="display: flex;">
    <div class="modal-box">
      <h1 style="color: #f5be23; font-size: 24px; text-shadow: 0 0 15px rgba(245,190,35,0.6); text-align: center;">&#128062; KARA KED&#304; &#128062;</h1>
      <p style="color: #a0aec0; font-size: 12px; text-align: center; margin-top: -6px;">Fare &#304;stilas&#305; - Hayatta Kalma Roguelite</p>
      
      <!-- Seçili Karakter Özeti -->
      <div style="background: #141a29; border: 2px solid #f5be23; border-radius: 12px; padding: 8px 12px; width: 100%; display: flex; align-items: center; justify-content: space-between;">
        <div>
          <span style="font-size: 10px; color: #8fa0b5;">SE&#199;&#304;L&#304; SAVA&#350;&#199;I:</span>
          <div id="menu-char-name" style="font-size: 14px; font-weight: bold; color: #f5be23;">Kara Kedi</div>
          <div id="menu-char-weapon" style="font-size: 11px; color: #00d2ff;">&#9876;&#65039; Kara &#199;elik K&#305;l&#305;&#231;</div>
        </div>
        <button id="btn-open-char-select" class="btn-action" style="font-size: 12px; padding: 6px 12px; background: #23344e; color: #fff; border-color: #3b5278;">&#128062; De&#287;i&#351;tir</button>
      </div>

      <div style="background: #151924; border: 1.5px solid #2a3547; border-radius: 12px; padding: 10px; width: 100%; font-size: 11px; color: #cbd5e0; line-height: 1.4;">
        &#127918; <strong>Kontroller:</strong> WASD veya Ok Tu&#351;lar&#305; / Sanal Joystick<br>
        &#128293; <strong>Patlay&#305;c&#305; Gaz T&#252;p&#252;:</strong> Vurarak patlat&#305;n, fareleri alevle k&#252;l edin!<br>
        &#128230; <strong>S&#252;rpriz Sand&#305;k:</strong> 5. saniyede d&#252;&#351;er; s&#252;t (+25 HP) ve alt&#305;n sa&#231;ar!
      </div>

      <button class="btn-action" id="btn-start-game" style="width: 100%; font-size: 18px; padding: 12px;">&#9876;&#65039; OYUNA BA&#350;LA</button>
    </div>
  </div>

  <!-- CHARACTER SELECT MODAL -->
  <div class="modal-backdrop interactive" id="modal-char-select">
    <div class="modal-box">
      <h2 style="color: #f5be23; font-size: 18px;">&#128062; SAVA&#350;&#199;I KED&#304; SE&#199;&#304;M&#304;</h2>
      <span style="font-size: 11px; color: #8fa0b5; margin-top: -6px;">G&#246;revleri tamamlayarak yeni karakterlerin kilidini a&#231;&#305;n!</span>
      
      <div class="char-grid" id="char-list-container">
        <!-- 5 Karakter Kartı -->
      </div>

      <button class="btn-action" id="btn-close-char-select" style="width: 100%; font-size: 14px; padding: 8px;">TAMAM &#10004;&#65039;</button>
    </div>
  </div>

  <!-- PAUSE MENU -->
  <div class="modal-backdrop interactive" id="modal-pause">
    <div class="modal-box">
      <h2 style="color: #f5be23; font-size: 24px;">&#9208;&#65039; OYUN DURDURULDU</h2>
      <button class="btn-action" id="btn-resume">&#9654;&#65039; DEVAM ET</button>
      <button class="btn-action" id="btn-pause-menu" style="background: #253347; color: #fff; border-color: #3b4d66; font-size: 14px; padding: 8px 18px;">ANA MEN&#220;YE D&#214;N</button>
    </div>
  </div>

  <!-- GAME OVER -->
  <div class="modal-backdrop interactive" id="modal-gameover">
    <div class="modal-box">
      <h1 style="color: #ff3333; font-size: 32px; text-shadow: 0 0 20px rgba(255,50,50,0.6);">&#128128; YEN&#304;LD&#304;N!</h1>
      <p style="color: #ccc; font-size: 14px;">Kedinin 9 can&#305; da t&#252;kendi...</p>
      
      <div style="background: #180808; border: 1.5px solid #ff3333; border-radius: 12px; padding: 12px; width: 100%; text-align: center; font-size: 14px;">
        Ula&#351;&#305;lan Dalga: <strong id="go-wave" style="color:#f5be23;">1</strong><br>
        Avlanan Fare: <strong id="go-kills" style="color:#00ff66;">0</strong><br>
        Kazan&#305;lan Skor: <strong id="go-score" style="color:#00d2ff;">0</strong>
      </div>

      <button class="btn-action" id="btn-retry">&#128260; TEKRAR DENE</button>
      <button class="btn-action" id="btn-go-menu" style="background: #253347; color: #fff; border-color: #3b4d66; font-size: 14px; padding: 8px 18px;">ANA MEN&#220;</button>
    </div>
  </div>

  <!-- VICTORY -->
  <div class="modal-backdrop interactive" id="modal-victory">
    <div class="modal-box">
      <h1 style="color: #00ff66; font-size: 30px; text-shadow: 0 0 20px rgba(0,255,100,0.6);">&#127942; ZAFER!</h1>
      <p style="color: #ccc; font-size: 13px; text-align: center;">Fare Krall&#305;&#287;&#305; tamamen yok edildi! &#199;at&#305;lar art&#305;k g&#252;vende!</p>
      
      <div style="background: #08180c; border: 1.5px solid #00ff66; border-radius: 12px; padding: 12px; width: 100%; text-align: center; font-size: 14px;">
        Toplam Skor: <strong id="vic-score" style="color:#f5be23;">0</strong><br>
        Yok Edilen Fare: <strong id="vic-kills" style="color:#00d2ff;">0</strong>
      </div>

      <button class="btn-action" id="btn-vic-menu">&#127881; ANA MEN&#220;</button>
    </div>
  </div>

  <!-- SHOP -->
  <div class="modal-backdrop interactive" id="modal-shop">
    <div class="shop-box">
      <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #202636; padding-bottom: 6px;">
        <div>
          <h2 style="color: #f5be23; font-size: 18px;">&#128722; KARA KED&#304; MARKET&#304;</h2>
          <span style="font-size: 11px; color: #8fa0b5;">Silah ve pasif g&#252;&#231;lendirmeler al&#305;n</span>
        </div>
        <div style="display: flex; gap: 8px; align-items: center;">
          <div class="hud-badge" style="background: #1a2233; color: #ffd700;">&#129689; <span id="shop-coins">0</span></div>
          <button id="btn-next-wave" class="btn-action" style="font-size: 13px; padding: 8px 16px;">SONRAK&#304; DALGA &#10145;&#65039;</button>
        </div>
      </div>

      <!-- KUŞANILAN SİLAHLAR (3 YUVA) -->
      <div>
        <span style="font-size: 11px; font-weight: bold; color: #a0aec0; margin-bottom: 4px; display: block;">KU&#350;ANILAN S&#304;LAHLAR (3 YUVA)</span>
        <div class="slots-grid" id="shop-slots"></div>
      </div>

      <!-- MARKET TEKLİFLERİ (4 KART) -->
      <div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin: 4px 0;">
          <span style="font-size: 11px; font-weight: bold; color: #a0aec0;">MARKET KARTLARI</span>
          <button id="btn-reroll" style="background: #192233; color: #cbd5e0; border: 1px solid #334460; padding: 4px 8px; border-radius: 6px; font-size: 11px; cursor: pointer;">
            &#127922; Yenile (<span id="reroll-cost">2</span> &#129689;)
          </button>
        </div>
        <div class="cards-wrapper" id="shop-cards"></div>
      </div>
    </div>
  </div>

</div>

<script>
const ASSETS_DATA = 
'@

$htmlPart2 = @'
;

// Ses Motoru
class AudioEngine {
  constructor() { this.ctx = null; }
  init() { if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)(); }
  playMeow() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(450, t); osc.frequency.exponentialRampToValueAtTime(750, t + 0.1);
    osc.frequency.exponentialRampToValueAtTime(400, t + 0.25);
    g.gain.setValueAtTime(0.35, t); g.gain.linearRampToValueAtTime(0.01, t + 0.25);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.25);
  }
  playHurt() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(320, t); osc.frequency.exponentialRampToValueAtTime(80, t + 0.18);
    g.gain.setValueAtTime(0.4, t); g.gain.linearRampToValueAtTime(0.01, t + 0.18);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.18);
  }
  playCoin() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(880, t); osc.frequency.setValueAtTime(1320, t + 0.06);
    g.gain.setValueAtTime(0.25, t); g.gain.linearRampToValueAtTime(0.01, t + 0.14);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.14);
  }
  playSword() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'triangle'; osc.frequency.setValueAtTime(580, t); osc.frequency.exponentialRampToValueAtTime(180, t + 0.12);
    g.gain.setValueAtTime(0.3, t); g.gain.linearRampToValueAtTime(0.01, t + 0.12);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.12);
  }
  playGun() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'square'; osc.frequency.setValueAtTime(950, t); osc.frequency.exponentialRampToValueAtTime(60, t + 0.14);
    g.gain.setValueAtTime(0.35, t); g.gain.linearRampToValueAtTime(0.01, t + 0.14);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.14);
  }
  playExplosion() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(160, t); osc.frequency.exponentialRampToValueAtTime(25, t + 0.5);
    g.gain.setValueAtTime(0.7, t); g.gain.linearRampToValueAtTime(0.01, t + 0.5);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.5);
  }
  playWaveHorn() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(130, t); osc.frequency.setValueAtTime(195, t + 0.2);
    g.gain.setValueAtTime(0.4, t); g.gain.linearRampToValueAtTime(0.01, t + 0.55);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.55);
  }
  playBossRoar() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(90, t); osc.frequency.linearRampToValueAtTime(55, t + 0.8);
    g.gain.setValueAtTime(0.6, t); g.gain.linearRampToValueAtTime(0.01, t + 0.8);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.8);
  }
  playUpgrade() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime;
    [440, 554, 659, 880].forEach((freq, idx) => {
      const osc = this.ctx.createOscillator(), g = this.ctx.createGain();
      osc.type = 'sine'; osc.frequency.setValueAtTime(freq, t + idx * 0.05);
      g.gain.setValueAtTime(0.2, t + idx * 0.05); g.gain.linearRampToValueAtTime(0.01, t + idx * 0.05 + 0.14);
      osc.connect(g); g.connect(this.ctx.destination); osc.start(t + idx * 0.05); osc.stop(t + idx * 0.05 + 0.14);
    });
  }
}
const audio = new AudioEngine();

// Görselleri Yükle
const images = {};
for (const k in ASSETS_DATA) {
  if (ASSETS_DATA[k]) {
    const img = new Image();
    img.src = ASSETS_DATA[k];
    images[k] = img;
  }
}

// 5 Karakter Veritabanı ve Kilit Görevleri
const CHARACTERS_DB = [
  {
    id: 'standard', name: 'Kara Kedi', title: 'Dengeli Sokak Sava\u015F\u00E7\u0131s\u0131',
    start_weapon: 'sword', start_weapon_name: 'Kara \u00C7elik K\u0131l\u0131\u00E7',
    max_hp: 100, speed: 220, dmg_mult: 1.0, attack_speed: 1.0, crit_chance: 0.05, armor: 0,
    coin_mult: 1.0, magnet_radius: 130, buffs: 'T\u00FCm temel statlar dengeli ve &#231;ok y&#246;nl&#252;.',
    unlocked_by_default: true, quest: 'Ba\u015Flang\u0131\u00E7ta a\u00E7\u0131k.'
  },
  {
    id: 'marksman', name: 'Ni\u015Fanc\u0131 Kedi', title: 'Keskin G\u00F6zl\u00FC Kovboy',
    start_weapon: 'glock', start_weapon_name: 'Seri Glock',
    max_hp: 85, speed: 230, dmg_mult: 1.25, attack_speed: 1.1, crit_chance: 0.15, armor: 0,
    coin_mult: 1.0, magnet_radius: 130, buffs: '+%25 Hasar & +60px Menzil, +%15 Kritik.',
    unlocked_by_default: false, quest_type: 'magnum_kills', quest_target: 100,
    quest: 'A\u011F\u0131r Magnum ile 100 d\u00FC\u015Fman \u00F6ld\u00FCr.'
  },
  {
    id: 'brawler', name: 'Vah\u015Fi Pen\u00E7eci', title: '\u00C7\u0131lg\u0131n Sokak Boks\u00F6r\u00FC',
    start_weapon: 'claws', start_weapon_name: 'Jilet Pen\u00E7eler',
    max_hp: 90, speed: 245, dmg_mult: 1.0, attack_speed: 1.4, crit_chance: 0.08, armor: 1,
    coin_mult: 1.0, magnet_radius: 130, buffs: '+%40 Sald\u0131r\u0131 H\u0131z\u0131, +25 Hareket H\u0131z\u0131, +1 Z\u0131rh.',
    unlocked_by_default: false, quest_type: 'claws_kills', quest_target: 150,
    quest: '\u00C7ift Pen\u00E7e ile 150 d\u00FC\u015Fman \u00F6ld\u00FCr.'
  },
  {
    id: 'chonky', name: '\u015Ei\u015Fko Kedi', title: 'Tombul & Y\u0131k\u0131lmaz Kaya',
    start_weapon: 'sword', start_weapon_name: 'Kara \u00C7elik K\u0131l\u0131\u00E7',
    max_hp: 140, speed: 180, dmg_mult: 1.0, attack_speed: 0.9, crit_chance: 0.05, armor: 4,
    coin_mult: 1.0, magnet_radius: 130, buffs: '+40 Can (140 HP), +4 Z\u0131rh, Diken Hasar\u0131.',
    unlocked_by_default: false, quest_type: 'milk_collected', quest_target: 12,
    quest: 'Oyunlarda 12 \u015Eifal\u0131 S\u00FCt Kasesi (\uD83E\uDD5B) topla.'
  },
  {
    id: 'pirate', name: 'Korsan Kedi', title: 'Hazine Avc\u0131s\u0131',
    start_weapon: 'fish_boomerang', start_weapon_name: 'K\u0131l\u00E7\u0131k Bumerang',
    max_hp: 90, speed: 225, dmg_mult: 0.85, attack_speed: 1.0, crit_chance: 0.20, armor: 0,
    coin_mult: 1.5, magnet_radius: 180, buffs: '+%50 Fazla Alt\u0131n (1.5x), +%20 Kritik \u015Fans\u0131.',
    unlocked_by_default: false, quest_type: 'total_coins', quest_target: 300,
    quest: 'Oyunlarda toplam 300 Alt\u0131n topla.'
  }
];

// Kalıcı İlerleme (Save/Load via localStorage)
let SaveData = {
  selected_character: 'standard',
  unlocked: ['standard'],
  quests: { magnum_kills: 0, claws_kills: 0, milk_collected: 0, total_coins: 0 }
};

try {
  const loaded = localStorage.getItem('kara_kedi_save');
  if (loaded) {
    SaveData = JSON.parse(loaded);
    if (!SaveData.unlocked.includes('standard')) SaveData.unlocked.push('standard');
  }
} catch(e) {}

function saveProgress() {
  try {
    localStorage.setItem('kara_kedi_save', JSON.stringify(SaveData));
  } catch(e) {}
}

function checkUnlocks() {
  let unlockedNew = false;
  CHARACTERS_DB.forEach(c => {
    if (!SaveData.unlocked.includes(c.id) && c.quest_type) {
      const cur = SaveData.quests[c.quest_type] || 0;
      if (cur >= c.quest_target) {
        SaveData.unlocked.push(c.id);
        unlockedNew = true;
      }
    }
  });
  if (unlockedNew) saveProgress();
}

// Oyun Kurulumu
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

const TIER_COLORS = { 1: '#00ff66', 2: '#00d2ff', 3: '#b844ff', 4: '#ff2255' };

const WEAPONS_DB = [
  { id: 'sword', title: 'Kara \u00C7elik K\u0131l\u0131\u00E7', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: '120\u00B0 yay kesi\u015Fi ve y\u00FCksek geri tepme.' },
  { id: 'claws', title: '\u00C7ift Pen\u00E7e', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 9, desc: 'Seri yak\u0131n sald\u0131r\u0131, +%25 kritik \u015Fans\u0131.' },
  { id: 'fish_boomerang', title: 'K\u0131l\u00E7\u0131k Bumerang\u0131', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: 'Gidip gelen delici kemik.' },
  { id: 'yarn_bomb', title: '\u0130p Yuma\u011F\u0131 Bombas\u0131', category: 'weapon', slot_pref: 'Kuyruk Yuvas\u0131', cost: 11, desc: 'Geni\u015F patlay\u0131c\u0131 alan hasar\u0131.' },
  { id: 'magnum', title: 'A\u011F\u0131r Magnum', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 12, desc: 'Y\u00FCksek hasar ve a\u011F\u0131r geri tepmeli mermi.' },
  { id: 'glock', title: 'Seri Glock', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: 'Saniyede 4.5 seri kur\u015Fun ya\u011Fmuru.' },
  { id: 'bow', title: 'Avc\u0131 Yay\u0131', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 11, desc: 'D\u00FC\u015Fmanlar\u0131 delip ge\u00E7en keskin oklar.' }
];

const ITEMS_DB = [
  { id: 'fish_soup', title: '\u015Eifal\u0131 Bal\u0131k \u00C7orbas\u0131', category: 'item', cost: 7, desc: '+30 Maksimum Can, Can\u0131 yeniler.', effects: { maxHp: 30, heal: true } },
  { id: 'catnip_potion', title: 'Kudurtucu Kedi Nanesi', category: 'item', cost: 8, desc: '+%25 Sald\u0131r\u0131 H\u0131z\u0131, +%10 Hasar.', effects: { attackSpeed: 0.25, dmgMult: 0.1 } },
  { id: 'golden_bell', title: '\u015Eansl\u0131 \u00C7\u0131ng\u0131rak', category: 'item', cost: 8, desc: '+%18 Kritik \u015Fans\u0131, +%35 Kritik Hasar\u0131.', effects: { critChance: 0.18, critMult: 0.35 } },
  { id: 'puma_boots', title: 'Puma Ad\u0131mlar\u0131', category: 'item', cost: 8, desc: '+45 Hareket H\u0131z\u0131, +%10 Kritik.', effects: { speed: 45, critChance: 0.1 } },
  { id: 'gold_magnet', title: 'Alt\u0131n M\u0131knat\u0131s', category: 'item', cost: 7, desc: '+75 Coin \u00C7ekim Alan\u0131, +15 H\u0131z.', effects: { magnetRadius: 75, speed: 15 } }
];

const Game = {
  state: 'MENU',
  wave: 1,
  maxWaves: 15,
  waveTime: 25,
  crateTimer: 5.0,
  coins: 0,
  score: 0,
  kills: 0,
  player: {
    x: 0, y: 0, hp: 100, maxHp: 100, speed: 220, dmgMult: 1.0, attackSpeed: 1.0,
    critChance: 0.05, critMult: 2.0, magnetRadius: 130, iframe: 0, dir: 'south',
    animFrame: 0, animTimer: 0,
    weapons: [null, null, null]
  },
  enemies: [], projectiles: [], collectibles: [], props: [], vfx: [], floatingTexts: [],
  camera: { x: 0, y: 0, shake: 0 },
  keys: {}, joystick: { active: false, x: 0, y: 0 }
};

// Karakter Seçim Menüsünü Oluştur
function renderCharacterSelectModal() {
  checkUnlocks();
  const container = document.getElementById('char-list-container');
  container.innerHTML = '';

  const selectedChar = CHARACTERS_DB.find(c => c.id === SaveData.selected_character) || CHARACTERS_DB[0];
  document.getElementById('menu-char-name').textContent = selectedChar.name;
  document.getElementById('menu-char-weapon').textContent = '🗡️ ' + selectedChar.start_weapon_name;

  CHARACTERS_DB.forEach(c => {
    const isUnlocked = SaveData.unlocked.includes(c.id) || c.unlocked_by_default;
    const isSelected = (c.id === SaveData.selected_character);

    const card = document.createElement('div');
    card.className = 'char-card' + (isSelected ? ' selected' : '') + (isUnlocked ? '' : ' locked');

    let questHtml = '';
    if (!isUnlocked) {
      const cur = SaveData.quests[c.quest_type] || 0;
      const pct = Math.min(100, Math.floor((cur / c.quest_target) * 100));
      questHtml = `
        <div class="quest-badge-box">
          <div style="font-size:11px; font-weight:bold; color:#ffe600;">🔒 GEREKSİNİM: ${c.quest}</div>
          <div style="display:flex; justify-content:space-between; align-items:center; margin-top:4px;">
            <div class="char-quest-bar" style="flex:1; margin-top:0; height:8px;"><div class="char-quest-fill" style="width:${pct}%; background:#ffe600;"></div></div>
            <span style="font-size:10px; font-weight:bold; color:#ffffff; margin-left:8px;">${cur} / ${c.quest_target} (%${pct})</span>
          </div>
        </div>
      `;
    }

    card.innerHTML = `
      <div class="char-avatar-box">
        <span style="font-size:24px;">🐱</span>
      </div>
      <div class="char-details">
        <div class="char-name-row">
          <span class="char-name">${c.name}</span>
          <span style="font-size:10px; color:${isUnlocked ? (isSelected ? '#f5be23' : '#00ff66') : '#ff4444'}; font-weight:bold;">
            ${isUnlocked ? (isSelected ? '✓ SEÇİLDİ' : 'SEÇ') : 'KİLİTLİ'}
          </span>
        </div>
        <span class="char-title">${c.title}</span>
        <div class="char-stats">❤️ Can: ${c.max_hp} | ⚡ Hız: ${c.speed} | 🗡️ ${c.start_weapon_name}</div>
        <div style="font-size:9px; color:#00ff88; margin-top:1px;">✨ ${c.buffs}</div>
        ${questHtml}
      </div>
    `;

    if (isUnlocked) {
      card.onclick = () => {
        SaveData.selected_character = c.id;
        saveProgress();
        renderCharacterSelectModal();
        audio.playUpgrade();
      };
    }

    container.appendChild(card);
  });
}

function applyCharacterToGame() {
  const c = CHARACTERS_DB.find(char => char.id === SaveData.selected_character) || CHARACTERS_DB[0];
  Game.player.hp = c.max_hp;
  Game.player.maxHp = c.max_hp;
  Game.player.speed = c.speed;
  Game.player.dmgMult = c.dmg_mult;
  Game.player.attackSpeed = c.attack_speed;
  Game.player.critChance = c.crit_chance;
  Game.player.critMult = 2.0;
  Game.player.magnetRadius = c.magnet_radius;
  Game.player.weapons = [
    { id: c.start_weapon, title: c.start_weapon_name, tier: 1, cooldown: 0 },
    null, null
  ];
}

// İnteraktif Sahne Nesneleri (Props) Üretimi
function setupWaveProps() {
  Game.props = [];
  Game.crateTimer = 5.0; // İlk sandık 5 saniye sonra düşecek
  
  for (let i = 0; i < 2; i++) {
    Game.props.push({
      type: 'gas_tank',
      x: (i === 0 ? -1 : 1) * (280 + Math.random() * 150),
      y: (Math.random() - 0.5) * 800,
      hp: 30, maxHp: 30, radius: 22
    });
  }

  // Dalga numarasına göre dinamik lağım kapağı sayısı (Wave 1-2: 2, Wave 3-5: 3, Wave 6-9: 4, Wave 10+: 5)
  let grateCount = 2;
  if (Game.wave >= 10) grateCount = 5;
  else if (Game.wave >= 6) grateCount = 4;
  else if (Game.wave >= 3) grateCount = 3;

  for (let i = 0; i < grateCount; i++) {
    Game.props.push({
      type: 'sewer_grate',
      x: (Math.random() - 0.5) * 900,
      y: (Math.random() - 0.5) * 1400,
      hp: 999999, maxHp: 999999, radius: 24,
      spawnTimer: 2.0 + Math.random() * 2.5, shakeTimer: 0
    });
  }
}

function spawnLootCrate() {
  const existingCrates = Game.props.filter(p => p.type === 'crate');
  if (existingCrates.length >= 3) return;

  Game.props.push({
    type: 'crate',
    x: (Math.random() - 0.5) * 1050,
    y: (Math.random() - 0.5) * 1650,
    hp: 25, maxHp: 25, radius: 20
  });
}

function startNewGame() {
  Game.wave = 1;
  Game.coins = 0;
  Game.score = 0;
  Game.kills = 0;
  applyCharacterToGame();
  startWave();
}

function startWave() {
  Game.state = 'PLAYING';
  Game.waveTime = (Game.wave === 5 || Game.wave === 10 || Game.wave === 15) ? 40 : 25;
  Game.enemies = [];
  Game.projectiles = [];
  Game.collectibles = [];
  Game.vfx = [];
  Game.floatingTexts = [];
  Game.player.x = 0;
  Game.player.y = 0;

  setupWaveProps();

  document.querySelectorAll('.modal-backdrop').forEach(m => m.style.display = 'none');
  document.getElementById('hud-wave').textContent = Game.wave;
  document.getElementById('boss-hud').style.display = 'none';

  audio.playWaveHorn();

  // Boss Spawn (Wave 5, 10, 15)
  if (Game.wave === 5 || Game.wave === 10 || Game.wave === 15) {
    const tier = (Game.wave === 15) ? 3 : (Game.wave === 10 ? 2 : 1);
    const maxHp = (tier === 3) ? 6000 : (tier === 2 ? 1800 : 850);
    const bName = (tier === 3) ? '\uD83D\uDC51 FARE \u0130MPARATORU' : '\uD83D\uDC51 FARE KRALI';
    
    setTimeout(() => {
      Game.enemies.push({
        type: 'boss',
        tier: tier,
        name: bName,
        x: 0,
        y: -400,
        hp: maxHp,
        maxHp: maxHp,
        speed: tier === 3 ? 135 : (tier === 2 ? 110 : 95),
        damage: tier === 3 ? 44 : (tier === 2 ? 32 : 22),
        radius: tier === 3 ? 48 : 36,
        coinValue: tier === 3 ? 64 : (tier === 2 ? 32 : 16),
        attackTimer: 3.0
      });
      document.getElementById('boss-hud').style.display = 'flex';
      document.getElementById('boss-label').textContent = bName;
      audio.playBossRoar();
    }, 1000);
  }
}

// Fare Spawn Motoru
let spawnTimer = 0;
function updateSpawner(dt) {
  spawnTimer -= dt;
  if (spawnTimer <= 0) {
    const maxEnemies = 20 + Game.wave * 8;
    if (Game.enemies.length < maxEnemies) {
      const angle = Math.random() * Math.PI * 2;
      const dist = 550 + Math.random() * 200;
      const ex = Game.player.x + Math.cos(angle) * dist;
      const ey = Game.player.y + Math.sin(angle) * dist;

      if (Math.abs(ex) < 650 && Math.abs(ey) < 980) {
        const roll = Math.random();
        if (Game.wave >= 4 && roll < 0.25) {
          Game.enemies.push({
            type: 'dasher', x: ex, y: ey,
            hp: 24 + Game.wave * 5, maxHp: 24 + Game.wave * 5,
            speed: 160, damage: 14, radius: 15, coinValue: 2,
            dashTimer: 2.5, isDashing: false, dashDur: 0
          });
        } else if (Game.wave >= 6 && roll < 0.45) {
          Game.enemies.push({
            type: 'tank', x: ex, y: ey,
            hp: 65 + Game.wave * 12, maxHp: 65 + Game.wave * 12,
            speed: 85, damage: 22, radius: 22, coinValue: 4
          });
        } else if (Game.wave >= 3 && roll < 0.65) {
          Game.enemies.push({
            type: 'spitter', x: ex, y: ey,
            hp: 18 + Game.wave * 4, maxHp: 18 + Game.wave * 4,
            speed: 105, damage: 10, radius: 14, coinValue: 2,
            shootTimer: 2.5
          });
        } else {
          Game.enemies.push({
            type: 'small', x: ex, y: ey,
            hp: 12 + Game.wave * 3, maxHp: 12 + Game.wave * 3,
            speed: 130 + Math.random() * 20, damage: 8, radius: 12, coinValue: 1
          });
        }
      }
    }
    spawnTimer = Math.max(0.2, 1.2 - Game.wave * 0.06);
  }
}

// Oyuncu ve Silah Güncellemeleri
function updatePlayer(dt) {
  let dx = 0, dy = 0;
  if (Game.keys['KeyW'] || Game.keys['ArrowUp']) dy -= 1;
  if (Game.keys['KeyS'] || Game.keys['ArrowDown']) dy += 1;
  if (Game.keys['KeyA'] || Game.keys['ArrowLeft']) dx -= 1;
  if (Game.keys['KeyD'] || Game.keys['ArrowRight']) dx += 1;

  if (Game.joystick.active) {
    dx = Game.joystick.x;
    dy = Game.joystick.y;
  }

  const len = Math.hypot(dx, dy);
  if (len > 0.1) {
    const nx = dx / len, ny = dy / len;
    Game.player.x += nx * Game.player.speed * dt;
    Game.player.y += ny * Game.player.speed * dt;

    if (Math.abs(nx) > Math.abs(ny)) {
      Game.player.dir = (nx > 0) ? 'east' : 'west';
    } else {
      Game.player.dir = (ny > 0) ? 'south' : 'north';
    }

    Game.player.animTimer += dt;
    if (Game.player.animTimer >= 0.085) {
      Game.player.animTimer = 0;
      Game.player.animFrame = (Game.player.animFrame + 1) % 8;
    }
  }

  // Sınır
  Game.player.x = Math.max(-620, Math.min(620, Game.player.x));
  Game.player.y = Math.max(-950, Math.min(950, Game.player.y));

  if (Game.player.iframe > 0) Game.player.iframe -= dt;

  // Kamera Takibi
  Game.camera.x += (Game.player.x - Game.camera.x) * 0.12;
  Game.camera.y += (Game.player.y - Game.camera.y) * 0.12;
  if (Game.camera.shake > 0) Game.camera.shake -= dt * 15;

  // Silahları Ateşle
  Game.player.weapons.forEach(w => {
    if (!w) return;
    w.cooldown -= dt;
    if (w.cooldown <= 0) {
      fireWeapon(w);
    }
  });
}

function fireWeapon(w) {
  const p = Game.player;
  const closest = getClosestTarget(p.x, p.y, 400);

  if (w.id === 'sword') {
    w.cooldown = 0.75 / p.attackSpeed;
    const targetAngle = closest ? Math.atan2(closest.y - p.y, closest.x - p.x) : (p.dir === 'east' ? 0 : (p.dir === 'west' ? Math.PI : (p.dir === 'south' ? Math.PI/2 : -Math.PI/2)));
    
    Game.vfx.push({
      type: 'slash',
      x: p.x + Math.cos(targetAngle) * 35,
      y: p.y + Math.sin(targetAngle) * 35,
      angle: targetAngle,
      life: 0.16, maxLife: 0.16
    });
    audio.playSword();
    damageArea(p.x + Math.cos(targetAngle) * 45, p.y + Math.sin(targetAngle) * 45, 100, 25 * w.tier * p.dmgMult, 180, targetAngle, false, 'sword');
  }
  else if (w.id === 'claws') {
    w.cooldown = 0.4 / p.attackSpeed;
    const targetAngle = closest ? Math.atan2(closest.y - p.y, closest.x - p.x) : 0;
    Game.vfx.push({
      type: 'claws',
      x: p.x + Math.cos(targetAngle) * 28,
      y: p.y + Math.sin(targetAngle) * 28,
      angle: targetAngle,
      life: 0.12, maxLife: 0.12
    });
    audio.playSword();
    damageArea(p.x + Math.cos(targetAngle) * 35, p.y + Math.sin(targetAngle) * 35, 75, 14 * w.tier * p.dmgMult, 100, targetAngle, true, 'claws');
  }
  else if (w.id === 'magnum') {
    w.cooldown = 0.85 / p.attackSpeed;
    if (closest) {
      const angle = Math.atan2(closest.y - p.y, closest.x - p.x);
      Game.projectiles.push({
        type: 'bullet', source: 'magnum',
        x: p.x, y: p.y,
        vx: Math.cos(angle) * 750, vy: Math.sin(angle) * 750,
        damage: 34 * w.tier * p.dmgMult,
        life: 1.2, pierce: 2, radius: 6, color: '#f5be23'
      });
      audio.playGun();
    }
  }
  else if (w.id === 'glock') {
    w.cooldown = 0.22 / p.attackSpeed;
    if (closest) {
      const angle = Math.atan2(closest.y - p.y, closest.x - p.x) + (Math.random() - 0.5) * 0.15;
      Game.projectiles.push({
        type: 'bullet', source: 'glock',
        x: p.x, y: p.y,
        vx: Math.cos(angle) * 820, vy: Math.sin(angle) * 820,
        damage: 13 * w.tier * p.dmgMult,
        life: 0.9, pierce: 1, radius: 4, color: '#00d2ff'
      });
      audio.playGun();
    }
  }
  else if (w.id === 'bow') {
    w.cooldown = 0.9 / p.attackSpeed;
    if (closest) {
      const angle = Math.atan2(closest.y - p.y, closest.x - p.x);
      Game.projectiles.push({
        type: 'arrow', source: 'bow',
        x: p.x, y: p.y,
        vx: Math.cos(angle) * 650, vy: Math.sin(angle) * 650,
        damage: 28 * w.tier * p.dmgMult,
        life: 1.5, pierce: 4, radius: 5, color: '#00ff66'
      });
      audio.playGun();
    }
  }
  else if (w.id === 'fish_boomerang') {
    w.cooldown = 1.1 / p.attackSpeed;
    const angle = closest ? Math.atan2(closest.y - p.y, closest.x - p.x) : 0;
    Game.projectiles.push({
      type: 'boomerang', source: 'fish_boomerang',
      x: p.x, y: p.y,
      vx: Math.cos(angle) * 450, vy: Math.sin(angle) * 450,
      startX: p.x, startY: p.y, returning: false,
      damage: 18 * w.tier * p.dmgMult,
      life: 2.2, radius: 10, color: '#ff9900'
    });
    audio.playSword();
  }
  else if (w.id === 'yarn_bomb') {
    w.cooldown = 1.4 / p.attackSpeed;
    const tx = closest ? closest.x : p.x + (Math.random() - 0.5) * 200;
    const ty = closest ? closest.y : p.y + (Math.random() - 0.5) * 200;
    Game.projectiles.push({
      type: 'bomb', source: 'yarn_bomb',
      x: p.x, y: p.y, targetX: tx, targetY: ty, progress: 0,
      damage: 42 * w.tier * p.dmgMult,
      life: 0.6, radius: 12, color: '#b844ff'
    });
  }
}

function getClosestTarget(x, y, maxDist) {
  let closest = null;
  let minDist = maxDist;

  Game.enemies.forEach(e => {
    const d = Math.hypot(e.x - x, e.y - y);
    if (d < minDist) { minDist = d; closest = e; }
  });

  Game.props.forEach(pr => {
    if (pr.type !== 'sewer_grate') {
      const d = Math.hypot(pr.x - x, pr.y - y);
      if (d < minDist) { minDist = d; closest = pr; }
    }
  });

  return closest;
}

function damageArea(x, y, radius, dmg, knock, knockAngle, extraCrit = false, sourceWeapon = '') {
  const isCrit = (Math.random() < (Game.player.critChance + (extraCrit ? 0.25 : 0)));
  const finalDmg = isCrit ? dmg * Game.player.critMult : dmg;

  Game.enemies.forEach(e => {
    const d = Math.hypot(e.x - x, e.y - y);
    if (d < radius + e.radius) {
      e.hp -= finalDmg;
      e.lastSource = sourceWeapon;
      e.x += Math.cos(knockAngle) * (knock * 0.1);
      e.y += Math.sin(knockAngle) * (knock * 0.1);
      spawnFloatingText(Math.round(finalDmg), e.x, e.y - 10, isCrit);
    }
  });

  Game.props.forEach(pr => {
    if (pr.type !== 'sewer_grate') {
      const d = Math.hypot(pr.x - x, pr.y - y);
      if (d < radius + pr.radius) {
        pr.hp -= finalDmg;
        spawnFloatingText(Math.round(finalDmg), pr.x, pr.y - 10, false);
      }
    }
  });
}

function spawnFloatingText(txt, x, y, isCrit, color = null) {
  Game.floatingTexts.push({
    text: (isCrit ? '⚡ ' : '') + txt,
    x: x, y: y,
    color: color ? color : (isCrit ? '#f5be23' : '#ffffff'),
    size: isCrit ? 18 : 13,
    life: 0.6, maxLife: 0.6
  });
}

// Proje Güncelleme & Çarpışma
function updateProjectiles(dt) {
  for (let i = Game.projectiles.length - 1; i >= 0; i--) {
    const p = Game.projectiles[i];
    p.life -= dt;

    if (p.type === 'bullet' || p.type === 'arrow') {
      p.x += p.vx * dt;
      p.y += p.vy * dt;

      for (let j = Game.enemies.length - 1; j >= 0; j--) {
        const e = Game.enemies[j];
        if (Math.hypot(e.x - p.x, e.y - p.y) < e.radius + p.radius) {
          const isCrit = Math.random() < Game.player.critChance;
          const dmg = isCrit ? p.damage * Game.player.critMult : p.damage;
          e.hp -= dmg;
          e.lastSource = p.source;
          spawnFloatingText(Math.round(dmg), e.x, e.y, isCrit);
          p.pierce--;
          if (p.pierce <= 0) { p.life = 0; break; }
        }
      }

      for (let j = Game.props.length - 1; j >= 0; j--) {
        const pr = Game.props[j];
        if (pr.type !== 'sewer_grate' && Math.hypot(pr.x - p.x, pr.y - p.y) < pr.radius + p.radius) {
          pr.hp -= p.damage;
          spawnFloatingText(Math.round(p.damage), pr.x, pr.y, false);
          p.pierce--;
          if (p.pierce <= 0) { p.life = 0; break; }
        }
      }
    }
    else if (p.type === 'boomerang') {
      if (!p.returning) {
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        if (Math.hypot(p.x - p.startX, p.y - p.startY) > 280) p.returning = true;
      } else {
        const toP = Math.atan2(Game.player.y - p.y, Game.player.x - p.x);
        p.x += Math.cos(toP) * 450 * dt;
        p.y += Math.sin(toP) * 450 * dt;
        if (Math.hypot(Game.player.x - p.x, Game.player.y - p.y) < 25) p.life = 0;
      }

      Game.enemies.forEach(e => {
        if (Math.hypot(e.x - p.x, e.y - p.y) < e.radius + p.radius) {
          e.hp -= p.damage * dt * 4;
          e.lastSource = 'fish_boomerang';
        }
      });
    }
    else if (p.type === 'bomb') {
      p.progress += dt / p.life;
      p.x += (p.targetX - p.x) * 0.15;
      p.y += (p.targetY - p.y) * 0.15;
      if (p.progress >= 1.0) {
        p.life = 0;
        triggerDetailedExplosion(p.targetX, p.targetY, 130, p.damage, false);
      }
    }

    if (p.life <= 0) Game.projectiles.splice(i, 1);
  }
}

// Detaylı Patlama Efekti ve Hasar Yöneticisi
function triggerDetailedExplosion(x, y, radius, damage, isGasTank = false) {
  audio.playExplosion();
  Game.camera.shake = 12;

  Game.vfx.push({
    type: 'detailed_explosion',
    x: x, y: y,
    maxRadius: radius,
    life: 0.55, maxLife: 0.55,
    particles: Array.from({ length: 32 }, () => ({
      vx: (Math.random() - 0.5) * 320,
      vy: (Math.random() - 0.5) * 320,
      size: Math.random() * 8 + 4,
      color: Math.random() > 0.4 ? '#ff6600' : (Math.random() > 0.5 ? '#ffd700' : '#444444')
    }))
  });

  Game.enemies.forEach(e => {
    const dist = Math.hypot(e.x - x, e.y - y);
    if (dist < radius + e.radius) {
      e.hp -= damage;
      const angle = Math.atan2(e.y - y, e.x - x);
      e.x += Math.cos(angle) * 120;
      e.y += Math.sin(angle) * 120;
      spawnFloatingText(Math.round(damage), e.x, e.y - 12, true, '#ff3300');
    }
  });

  if (isGasTank) {
    const pDist = Math.hypot(Game.player.x - x, Game.player.y - y);
    if (pDist < radius * 0.7 && Game.player.iframe <= 0) {
      Game.player.hp -= 12;
      Game.player.iframe = 0.4;
      audio.playHurt();
      const pAngle = Math.atan2(Game.player.y - y, Game.player.x - x);
      Game.player.x += Math.cos(pAngle) * 50;
      Game.player.y += Math.sin(pAngle) * 50;
      spawnFloatingText('-12 HP (Alev)', Game.player.x, Game.player.y - 20, false, '#ff4444');
    }
  }
}

// İnteraktif Nesneleri Güncelle
function updateProps(dt) {
  Game.crateTimer -= dt;
  if (Game.crateTimer <= 0) {
    spawnLootCrate();
    Game.crateTimer = 10 + Math.random() * 5;
  }

  for (let i = Game.props.length - 1; i >= 0; i--) {
    const pr = Game.props[i];

    if (pr.type === 'sewer_grate') {
      pr.spawnTimer -= dt;
      if (pr.spawnTimer <= 0) {
        pr.spawnTimer = 4.2;
        pr.shakeTimer = 0.3;
        for (let k = 0; k < 3; k++) {
          Game.enemies.push({
            type: 'small',
            x: pr.x + (Math.random() - 0.5) * 35,
            y: pr.y + (Math.random() - 0.5) * 35,
            hp: 14 + Game.wave * 3, maxHp: 14 + Game.wave * 3,
            speed: 140, damage: 8, radius: 12, coinValue: 1
          });
        }
      }
      if (pr.shakeTimer > 0) pr.shakeTimer -= dt;
    }

    if (pr.hp <= 0) {
      if (pr.type === 'gas_tank') {
        triggerDetailedExplosion(pr.x, pr.y, 160, 120, true);
      }
      else if (pr.type === 'sewer_grate') {
        audio.playExplosion();
        for (let c = 0; c < 3; c++) {
          Game.collectibles.push({ type: 'coin', x: pr.x + (Math.random()-0.5)*30, y: pr.y + (Math.random()-0.5)*30, val: 2 });
        }
      }
      else if (pr.type === 'crate') {
        audio.playExplosion();
        Game.camera.shake = 5;
        const roll = Math.random();
        if (roll < 0.45) {
          Game.collectibles.push({ type: 'milk', x: pr.x, y: pr.y, heal: 25 });
          Game.collectibles.push({ type: 'coin', x: pr.x + 10, y: pr.y, val: 2 });
        } else if (roll < 0.85) {
          const coinCount = Math.floor(Math.random() * 4) + 5;
          for (let c = 0; c < coinCount; c++) {
            Game.collectibles.push({ type: 'coin', x: pr.x + (Math.random()-0.5)*30, y: pr.y + (Math.random()-0.5)*30, val: 2 });
          }
        } else {
          Game.collectibles.push({ type: 'milk', x: pr.x, y: pr.y, heal: 25 });
          for (let c = 0; c < 6; c++) {
            Game.collectibles.push({ type: 'coin', x: pr.x + (Math.random()-0.5)*40, y: pr.y + (Math.random()-0.5)*40, val: 3 });
          }
        }
      }
      Game.props.splice(i, 1);
    }
  }
}

// Düşmanları Güncelle & Kills Takibi
function updateEnemies(dt) {
  const p = Game.player;

  for (let i = Game.enemies.length - 1; i >= 0; i--) {
    const e = Game.enemies[i];
    const angle = Math.atan2(p.y - e.y, p.x - e.x);

    if (e.type === 'dasher') {
      e.dashTimer -= dt;
      if (e.isDashing) {
        e.dashDur -= dt;
        e.x += Math.cos(e.dashAngle) * 360 * dt;
        e.y += Math.sin(e.dashAngle) * 360 * dt;
        if (e.dashDur <= 0) { e.isDashing = false; e.dashTimer = 2.8; }
      } else {
        e.x += Math.cos(angle) * e.speed * dt;
        e.y += Math.sin(angle) * e.speed * dt;
        if (e.dashTimer <= 0 && Math.hypot(p.x - e.x, p.y - e.y) < 180) {
          e.isDashing = true;
          e.dashAngle = angle;
          e.dashDur = 0.35;
        }
      }
    }
    else if (e.type === 'boss') {
      e.x += Math.cos(angle) * e.speed * dt;
      e.y += Math.sin(angle) * e.speed * dt;

      e.attackTimer -= dt;
      if (e.attackTimer <= 0) {
        e.attackTimer = (e.tier === 3) ? 2.2 : 3.5;
        audio.playExplosion();
        Game.vfx.push({ type: 'boss_shock', x: e.x, y: e.y, radius: 180 * e.tier, life: 0.4, maxLife: 0.4 });
        if (Math.hypot(p.x - e.x, p.y - e.y) < 180 * e.tier && p.iframe <= 0) {
          p.hp -= e.damage * 0.8;
          p.iframe = 0.4;
          audio.playHurt();
        }
      }

      const bossBar = document.getElementById('boss-hp');
      if (bossBar) {
        bossBar.style.width = Math.max(0, (e.hp / e.maxHp) * 100) + '%';
      }
    }
    else {
      e.x += Math.cos(angle) * e.speed * dt;
      e.y += Math.sin(angle) * e.speed * dt;
    }

    if (Math.hypot(p.x - e.x, p.y - e.y) < p.radius || Math.hypot(p.x - e.x, p.y - e.y) < e.radius + 14) {
      if (p.iframe <= 0) {
        p.hp -= e.damage;
        p.iframe = 0.35;
        audio.playHurt();
        Game.camera.shake = 8;
        if (p.hp <= 0) {
          triggerGameOver();
          return;
        }
      }
    }

    if (e.hp <= 0) {
      Game.kills++;
      Game.score += e.type === 'boss' ? 5000 * e.tier : 100;

      // Silah Görev Takibi
      if (e.lastSource === 'magnum') {
        SaveData.quests.magnum_kills = (SaveData.quests.magnum_kills || 0) + 1;
      } else if (e.lastSource === 'claws') {
        SaveData.quests.claws_kills = (SaveData.quests.claws_kills || 0) + 1;
      }
      checkUnlocks();

      const dropCount = e.type === 'boss' ? 12 * e.tier : (Math.random() < 0.8 ? 1 : 2);
      for (let c = 0; c < dropCount; c++) {
        Game.collectibles.push({
          type: 'coin',
          x: e.x + (Math.random() - 0.5) * 20,
          y: e.y + (Math.random() - 0.5) * 20,
          val: e.coinValue
        });
      }

      if (e.type === 'boss') {
        document.getElementById('boss-hud').style.display = 'none';
      }

      Game.enemies.splice(i, 1);
    }
  }
}

// Toplanabilir Nesneleri Güncelle (Coin & Süt)
function updateCollectibles(dt) {
  const p = Game.player;
  for (let i = Game.collectibles.length - 1; i >= 0; i--) {
    const c = Game.collectibles[i];
    const dist = Math.hypot(p.x - c.x, p.y - c.y);

    if (dist < p.magnetRadius) {
      const angle = Math.atan2(p.y - c.y, p.x - c.x);
      const spd = 450 + (1 - dist / p.magnetRadius) * 300;
      c.x += Math.cos(angle) * spd * dt;
      c.y += Math.sin(angle) * spd * dt;
    }

    if (dist < 26) {
      if (c.type === 'coin') {
        Game.coins += c.val;
        Game.score += c.val * 10;
        SaveData.quests.total_coins = (SaveData.quests.total_coins || 0) + c.val;
        checkUnlocks();
        audio.playCoin();
      } else if (c.type === 'milk') {
        p.hp = Math.min(p.maxHp, p.hp + c.heal);
        SaveData.quests.milk_collected = (SaveData.quests.milk_collected || 0) + 1;
        checkUnlocks();
        audio.playMeow();
        spawnFloatingText('+' + c.heal + ' HP (S\u00FCt)', p.x, p.y - 20, false, '#00d2ff');
      }
      Game.collectibles.splice(i, 1);
    }
  }
}

// Görsel Efektler & Floating Texts
function updateVFX(dt) {
  for (let i = Game.vfx.length - 1; i >= 0; i--) {
    const v = Game.vfx[i];
    v.life -= dt;
    if (v.life <= 0) Game.vfx.splice(i, 1);
  }
  for (let i = Game.floatingTexts.length - 1; i >= 0; i--) {
    const ft = Game.floatingTexts[i];
    ft.life -= dt;
    ft.y -= 35 * dt;
    if (ft.life <= 0) Game.floatingTexts.splice(i, 1);
  }
}

// Ana Çizim (Render) Döngüsü
function render() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  let shakeX = 0, shakeY = 0;
  if (Game.camera.shake > 0) {
    shakeX = (Math.random() - 0.5) * Game.camera.shake * 2;
    shakeY = (Math.random() - 0.5) * Game.camera.shake * 2;
  }

  const cx = canvas.width / 2 - Game.camera.x + shakeX;
  const cy = canvas.height / 2 - Game.camera.y + shakeY;

  if (images['floor']) {
    const pat = ctx.createPattern(images['floor'], 'repeat');
    ctx.save();
    ctx.translate(cx, cy);
    ctx.fillStyle = pat;
    ctx.fillRect(-680, -1020, 1360, 2040);
    ctx.strokeStyle = '#f5be23';
    ctx.lineWidth = 6;
    ctx.strokeRect(-680, -1020, 1360, 2040);
    ctx.restore();
  }

  Game.props.forEach(pr => {
    const px = pr.x + cx, py = pr.y + cy;
    ctx.save();
    if (pr.type === 'gas_tank') {
      if (images['gas_tank']) {
        ctx.drawImage(images['gas_tank'], px - 24, py - 24, 48, 48);
      } else {
        ctx.fillStyle = '#cc2222';
        ctx.fillRect(px - 14, py - 18, 28, 36);
      }
    }
    else if (pr.type === 'sewer_grate') {
      const shakeOffset = pr.shakeTimer > 0 ? (Math.random() - 0.5) * 6 : 0;
      if (images['sewer_grate']) {
        ctx.drawImage(images['sewer_grate'], px - 24 + shakeOffset, py - 24, 48, 48);
      } else {
        ctx.fillStyle = '#222';
        ctx.beginPath(); ctx.arc(px + shakeOffset, py, 24, 0, Math.PI * 2); ctx.fill();
      }
    }
    else if (pr.type === 'crate') {
      if (images['loot_crate']) {
        ctx.drawImage(images['loot_crate'], px - 18, py - 18, 36, 36);
      } else {
        ctx.fillStyle = '#8a532b';
        ctx.fillRect(px - 16, py - 16, 32, 32);
      }
    }
    ctx.restore();
  });

  Game.collectibles.forEach(c => {
    const px = c.x + cx, py = c.y + cy;
    ctx.save();
    if (c.type === 'coin') {
      ctx.fillStyle = '#ffd700';
      ctx.beginPath(); ctx.arc(px, py, 7, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#b8860b'; ctx.lineWidth = 1.5; ctx.stroke();
    } else if (c.type === 'milk') {
      if (images['milk_bowl']) {
        ctx.drawImage(images['milk_bowl'], px - 14, py - 14, 28, 28);
      } else {
        ctx.fillStyle = '#ffffff';
        ctx.beginPath(); ctx.arc(px, py, 10, 0, Math.PI * 2); ctx.fill();
      }
    }
    ctx.restore();
  });

  Game.enemies.forEach(e => {
    const px = e.x + cx, py = e.y + cy;
    ctx.save();
    if (e.type === 'boss') {
      ctx.fillStyle = (e.tier === 3) ? '#990033' : '#660011';
      ctx.beginPath(); ctx.arc(px, py, e.radius, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#f5be23'; ctx.lineWidth = 4; ctx.stroke();
      ctx.fillStyle = '#ffd700'; ctx.font = 'bold 24px sans-serif';
      ctx.fillText('\uD83D\uDC51', px - 14, py + 8);
    } else if (e.type === 'dasher') {
      ctx.fillStyle = '#cc5500';
      ctx.beginPath(); ctx.arc(px, py, e.radius, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#ffaa00'; ctx.stroke();
    } else if (e.type === 'tank') {
      ctx.fillStyle = '#555566';
      ctx.beginPath(); ctx.arc(px, py, e.radius, 0, Math.PI * 2); ctx.fill();
      ctx.strokeStyle = '#9999aa'; ctx.lineWidth = 3; ctx.stroke();
    } else {
      ctx.fillStyle = '#886655';
      ctx.beginPath(); ctx.arc(px, py, e.radius, 0, Math.PI * 2); ctx.fill();
    }
    ctx.restore();
  });

  const px = Game.player.x + cx, py = Game.player.y + cy;
  ctx.save();
  const isMoving = (Game.player.animTimer > 0);
  const dir = Game.player.dir || 'south';
  
  // Zemin Gölgesi
  ctx.fillStyle = 'rgba(0, 0, 0, 0.42)';
  ctx.beginPath();
  ctx.ellipse(px, py + 18, 18, 9, 0, 0, Math.PI * 2);
  ctx.fill();
  
  let frameImg = null;
  if (isMoving) {
    const fIdx = Math.floor(Game.player.animFrame) % 8;
    frameImg = images['hero_run_' + dir + '_' + fIdx] || images['hero_rot_' + dir] || images['player_' + dir] || images['hero_rot_south'];
  } else {
    frameImg = images['hero_rot_' + dir] || images['player_' + dir] || images['hero_rot_south'];
  }
  
  if (frameImg) {
    const catSize = 72;
    ctx.translate(px, py);
    if (isMoving) {
      const bob = Math.sin(Date.now() * 0.016) * 0.06;
      ctx.scale(1.0 + bob, 1.0 - bob);
    }
    ctx.drawImage(frameImg, -catSize/2, -catSize/2, catSize, catSize);
  } else {
    ctx.fillStyle = '#f5be23';
    ctx.beginPath(); ctx.arc(px, py, 20, 0, Math.PI * 2); ctx.fill();
  }
  ctx.restore();

  Game.projectiles.forEach(p => {
    const ppx = p.x + cx, ppy = p.y + cy;
    ctx.save();
    ctx.fillStyle = p.color;
    ctx.beginPath(); ctx.arc(ppx, ppy, p.radius, 0, Math.PI * 2); ctx.fill();
    ctx.restore();
  });

  Game.vfx.forEach(v => {
    const vx = v.x + cx, vy = v.y + cy;
    ctx.save();
    if (v.type === 'detailed_explosion') {
      const progress = 1 - (v.life / v.maxLife);
      ctx.strokeStyle = `rgba(255, ${Math.floor(180 * (1 - progress))}, 0, ${v.life / v.maxLife})`;
      ctx.lineWidth = 14 * (1 - progress);
      ctx.beginPath(); ctx.arc(vx, vy, v.maxRadius * progress, 0, Math.PI * 2); ctx.stroke();

      ctx.fillStyle = `rgba(255, 240, 100, ${Math.max(0, 0.7 - progress)})`;
      ctx.beginPath(); ctx.arc(vx, vy, v.maxRadius * 0.5 * (1 - progress * 0.5), 0, Math.PI * 2); ctx.fill();

      if (v.particles) {
        v.particles.forEach(pt => {
          ctx.fillStyle = pt.color;
          ctx.beginPath(); ctx.arc(vx + pt.vx * progress, vy + pt.vy * progress, pt.size * (1 - progress), 0, Math.PI * 2); ctx.fill();
        });
      }
    }
    else if (v.type === 'slash') {
      ctx.strokeStyle = 'rgba(255, 230, 100, 0.8)';
      ctx.lineWidth = 6;
      ctx.beginPath(); ctx.arc(vx, vy, 45, v.angle - 0.8, v.angle + 0.8); ctx.stroke();
    }
    else if (v.type === 'boss_shock') {
      ctx.strokeStyle = 'rgba(255, 50, 50, ' + (v.life / v.maxLife) + ')';
      ctx.lineWidth = 8;
      ctx.beginPath(); ctx.arc(vx, vy, v.radius * (1 - v.life / v.maxLife), 0, Math.PI * 2); ctx.stroke();
    }
    ctx.restore();
  });

  Game.floatingTexts.forEach(ft => {
    const ftx = ft.x + cx, fty = ft.y + cy;
    ctx.save();
    ctx.fillStyle = ft.color;
    ctx.font = 'bold ' + ft.size + 'px sans-serif';
    ctx.fillText(ft.text, ftx, fty);
    ctx.restore();
  });
}

function completeWave() {
  if (Game.wave >= Game.maxWaves) {
    triggerVictory();
    return;
  }
  Game.state = 'SHOP';
  openShop();
}

function openShop() {
  const modal = document.getElementById('modal-shop');
  document.getElementById('shop-coins').textContent = Game.coins;
  renderShopSlots();
  generateShopCards();
  modal.style.display = 'flex';
}

function renderShopSlots() {
  const container = document.getElementById('shop-slots');
  container.innerHTML = '';
  Game.player.weapons.forEach((w, idx) => {
    const div = document.createElement('div');
    div.className = 'slot-card';
    if (w) {
      div.innerHTML = `
        <span style="color:${TIER_COLORS[w.tier]}; font-weight:bold;">${w.title}</span>
        <span style="color:#f5be23; font-size:10px;">Sv. ${w.tier}</span>
      `;
    } else {
      div.innerHTML = `<span style="color:#556;">BO\u015E YUVA ${idx+1}</span>`;
    }
    container.appendChild(div);
  });
}

function generateShopCards() {
  const container = document.getElementById('shop-cards');
  container.innerHTML = '';

  const pool = [...WEAPONS_DB, ...ITEMS_DB];
  const offers = [];
  while (offers.length < 4) {
    const item = pool[Math.floor(Math.random() * pool.length)];
    if (!offers.includes(item)) offers.push(item);
  }

  offers.forEach(item => {
    const card = document.createElement('div');
    card.className = 'card-item';
    const isWeapon = item.category === 'weapon';
    const canAfford = Game.coins >= item.cost;

    card.innerHTML = `
      <div class="card-title" style="color:#f5be23;">${item.title}</div>
      <div class="card-category" style="color:${isWeapon ? '#00d2ff' : '#00ff66'};">${isWeapon ? 'S\u0130LAH' : 'PAS\u0130F E\u015EYA'}</div>
      <div class="card-desc">${item.desc}</div>
      <button class="btn-buy" ${canAfford ? '' : 'disabled'}>${item.cost} \uD83E\uDE99 SATIN AL</button>
    `;

    card.querySelector('.btn-buy').onclick = () => {
      if (Game.coins >= item.cost) {
        Game.coins -= item.cost;
        audio.playUpgrade();
        if (isWeapon) {
          let placed = false;
          for (let i = 0; i < 3; i++) {
            if (!Game.player.weapons[i]) {
              Game.player.weapons[i] = { id: item.id, title: item.title, tier: 1, cooldown: 0 };
              placed = true;
              break;
            }
          }
          if (!placed) Game.player.weapons[0] = { id: item.id, title: item.title, tier: 1, cooldown: 0 };
        } else {
          if (item.effects.maxHp) { Game.player.maxHp += item.effects.maxHp; Game.player.hp += item.effects.maxHp; }
          if (item.effects.attackSpeed) Game.player.attackSpeed += item.effects.attackSpeed;
          if (item.effects.dmgMult) Game.player.dmgMult += item.effects.dmgMult;
          if (item.effects.critChance) Game.player.critChance += item.effects.critChance;
          if (item.effects.speed) Game.player.speed += item.effects.speed;
        }
        document.getElementById('shop-coins').textContent = Game.coins;
        renderShopSlots();
        card.style.opacity = '0.3';
        card.querySelector('.btn-buy').disabled = true;
      }
    };

    container.appendChild(card);
  });
}

function triggerGameOver() {
  Game.state = 'GAMEOVER';
  saveProgress();
  document.getElementById('go-wave').textContent = Game.wave;
  document.getElementById('go-kills').textContent = Game.kills;
  document.getElementById('go-score').textContent = Game.score;
  document.getElementById('modal-gameover').style.display = 'flex';
}

function triggerVictory() {
  Game.state = 'VICTORY';
  saveProgress();
  document.getElementById('vic-score').textContent = Game.score;
  document.getElementById('vic-kills').textContent = Game.kills;
  document.getElementById('modal-victory').style.display = 'flex';
}

let lastTime = performance.now();
function gameLoop(now) {
  const dt = Math.min(0.05, (now - lastTime) / 1000);
  lastTime = now;

  if (Game.state === 'PLAYING') {
    Game.waveTime -= dt;
    const min = Math.floor(Game.waveTime / 60);
    const sec = Math.floor(Game.waveTime % 60);
    document.getElementById('hud-timer').textContent = `\u23F1\uFE0F ${min.toString().padStart(2, '0')}:${sec.toString().padStart(2, '0')}`;
    document.getElementById('hud-coins').textContent = Game.coins;
    document.getElementById('hud-hp').style.width = Math.max(0, (Game.player.hp / Game.player.maxHp) * 100) + '%';

    updateSpawner(dt);
    updatePlayer(dt);
    updateProjectiles(dt);
    updateProps(dt);
    updateEnemies(dt);
    updateCollectibles(dt);
    updateVFX(dt);

    if (Game.waveTime <= 0) {
      completeWave();
    }
  }

  render();
  requestAnimationFrame(gameLoop);
}

// Buton Etkileşimleri
document.getElementById('btn-start-game').onclick = () => { audio.init(); startNewGame(); };
document.getElementById('btn-next-wave').onclick = () => { Game.wave++; startWave(); };
document.getElementById('btn-retry').onclick = () => { startNewGame(); };

document.getElementById('btn-open-char-select').onclick = () => {
  renderCharacterSelectModal();
  document.getElementById('modal-char-select').style.display = 'flex';
};
document.getElementById('btn-close-char-select').onclick = () => {
  document.getElementById('modal-char-select').style.display = 'none';
  renderCharacterSelectModal();
};

document.getElementById('btn-pause').onclick = () => {
  if (Game.state === 'PLAYING') {
    Game.state = 'PAUSED';
    document.getElementById('modal-pause').style.display = 'flex';
  }
};
document.getElementById('btn-resume').onclick = () => {
  Game.state = 'PLAYING';
  document.getElementById('modal-pause').style.display = 'none';
};
document.getElementById('btn-pause-menu').onclick = () => {
  document.getElementById('modal-pause').style.display = 'none';
  document.getElementById('modal-menu').style.display = 'flex';
  renderCharacterSelectModal();
  Game.state = 'MENU';
};
document.getElementById('btn-go-menu').onclick = () => {
  document.getElementById('modal-gameover').style.display = 'none';
  document.getElementById('modal-menu').style.display = 'flex';
  renderCharacterSelectModal();
  Game.state = 'MENU';
};
document.getElementById('btn-vic-menu').onclick = () => {
  document.getElementById('modal-victory').style.display = 'none';
  document.getElementById('modal-menu').style.display = 'flex';
  renderCharacterSelectModal();
  Game.state = 'MENU';
};

// Klavye Dinleyicileri
window.addEventListener('keydown', e => { Game.keys[e.code] = true; });
window.addEventListener('keyup', e => { Game.keys[e.code] = false; });

// Dokunmatik / Mobil Joystick
const joyBox = document.getElementById('touch-joystick');
const joyKnob = document.getElementById('touch-knob');
let joyTouchId = null;

window.addEventListener('touchstart', e => {
  if (Game.state !== 'PLAYING') return;
  const touch = e.changedTouches[0];
  joyBox.style.display = 'block';
  joyBox.style.left = (touch.clientX - 55) + 'px';
  joyBox.style.top = (touch.clientY - 55) + 'px';
  joyTouchId = touch.identifier;
  Game.joystick.active = true;
});

window.addEventListener('touchmove', e => {
  if (!Game.joystick.active) return;
  for (let i = 0; i < e.changedTouches.length; i++) {
    const t = e.changedTouches[i];
    if (t.identifier === joyTouchId) {
      const rect = joyBox.getBoundingClientRect();
      const centerX = rect.left + rect.width / 2;
      const centerY = rect.top + rect.height / 2;
      let dx = t.clientX - centerX;
      let dy = t.clientY - centerY;
      const dist = Math.hypot(dx, dy);
      const maxR = 40;
      if (dist > maxR) {
        dx = (dx / dist) * maxR;
        dy = (dy / dist) * maxR;
      }
      joyKnob.style.transform = `translate(${dx}px, ${dy}px)`;
      Game.joystick.x = dx / maxR;
      Game.joystick.y = dy / maxR;
    }
  }
});

window.addEventListener('touchend', () => {
  Game.joystick.active = false;
  joyBox.style.display = 'none';
  joyKnob.style.transform = 'translate(0px, 0px)';
});

renderCharacterSelectModal();
requestAnimationFrame(gameLoop);
</script>
</body>
</html>
'@

$fullHtml = $htmlPart1 + $jsonAssets + $htmlPart2

[System.IO.File]::WriteAllText("$webDir\index.html", $fullHtml, [System.Text.Encoding]::UTF8)

Write-Output "WEB_BUILD_COMPLETED: index.html"
