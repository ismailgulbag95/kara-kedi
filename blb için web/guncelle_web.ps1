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

# Oyuncu Yön Dokuları
$dirs = @("south", "north", "east", "west", "south-east", "south-west", "north-east", "north-west")
foreach ($d in $dirs) {
    $assets["player_$d"] = Get-Base64Image "$projectDir\assets\textures\player_character\rotations\$d.png"
}

# Oyuncu Koşu Kareleri (South & East & North)
foreach ($d in @("south", "east", "north")) {
    $frames = Get-ChildItem "$projectDir\assets\textures\player_character\animations\Running\$d\*.png" -ErrorAction SilentlyContinue | Sort-Object Name
    $idx = 0
    foreach ($fr in $frames) {
        $assets["run_${d}_$idx"] = Get-Base64Image $fr.FullName
        $idx++
    }
}

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
    .modal-backdrop { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(4, 6, 12, 0.94); backdrop-filter: blur(8px); display: none; flex-direction: column; justify-content: center; align-items: center; padding: 16px; z-index: 50; }
    .modal-box { background: #0f1118; border: 3px solid #f5be23; border-radius: 20px; width: 94%; max-width: 420px; padding: 22px; display: flex; flex-direction: column; align-items: center; gap: 14px; box-shadow: 0 0 35px rgba(245, 190, 35, 0.3); }

    .btn-action { background: #f5be23; color: #150f03; font-weight: bold; font-size: 18px; padding: 12px 28px; border: 2px solid #fff070; border-radius: 12px; cursor: pointer; transition: all 0.15s ease; outline: none; }
    .btn-action:hover { background: #c01010; color: #fff; border-color: #ff5555; transform: scale(1.06); box-shadow: 0 0 25px rgba(192, 16, 16, 0.85); }

    /* SHOP */
    .shop-box { background: #0c0e14; border: 3px solid #f5be23; border-radius: 18px; width: 98%; max-height: 95%; padding: 12px; display: flex; flex-direction: column; gap: 8px; overflow-y: auto; box-shadow: 0 0 35px rgba(245, 190, 35, 0.25); }
    .slots-grid { display: flex; justify-content: space-between; gap: 6px; }
    .slot-card { flex: 1; background: #131722; border: 2px solid #2a3547; border-radius: 8px; padding: 6px 4px; font-size: 11px; text-align: center; display: flex; flex-direction: column; gap: 4px; }
    .cards-wrapper { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .card-item { background: #11141e; border: 2.5px solid #2a3a55; border-radius: 12px; padding: 8px; display: flex; flex-direction: column; align-items: center; text-align: center; gap: 4px; position: relative; transition: transform 0.3s ease, opacity 0.3s ease; }
    .card-item.locked { border-color: #f5be23 !important; box-shadow: 0 0 14px rgba(245, 190, 35, 0.4); }
    .card-title { font-size: 13px; font-weight: bold; }
    .card-category { font-size: 10px; font-weight: bold; }
    .card-desc { font-size: 11px; color: #ccc; min-height: 36px; line-height: 1.3; }
    .btn-buy { width: 100%; background: #2575fc; border: none; color: white; padding: 6px; border-radius: 6px; font-size: 12px; font-weight: bold; cursor: pointer; }
    .btn-buy:disabled { background: #262a36; color: #667; cursor: not-allowed; }
    .btn-buy.combine { background: #00d2ff; color: #051520; }
    .btn-lock { background: transparent; border: 1px solid #445; color: #99a; padding: 3px 6px; font-size: 10px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; gap: 4px; }
    .btn-lock.active { border-color: #f5be23; color: #f5be23; }

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
      <h1 style="color: #f5be23; font-size: 26px; text-shadow: 0 0 15px rgba(245,190,35,0.6); text-align: center;">&#128062; KARA KED&#304; &#128062;</h1>
      <p style="color: #a0aec0; font-size: 13px; text-align: center; margin-top: -6px;">Fare &#304;stilas&#305; - Hayatta Kalma Roguelite (BLB Web)</p>
      
      <div id="cat-avatar" style="margin: 10px 0;"></div>

      <div style="background: #151924; border: 1.5px solid #2a3547; border-radius: 12px; padding: 12px; width: 100%; font-size: 12px; color: #cbd5e0; line-height: 1.5;">
        &#127918; <strong>Kontroller:</strong> WASD veya Ok Tu&#351;lar&#305;<br>
        &#128241; <strong>Mobil / Dokunmatik:</strong> Ekrana dokunarak Sanal Joystick<br>
        &#9876;&#65039; <strong>Otomatik Sald&#305;r&#305;:</strong> Silahlar menzildeki farelere otomatik vurur!<br>
        &#128230; <strong>Etkile&#351;im:</strong> Sand&#305;klar&#305; k&#305;r&#305;n, su kulelerini patlat&#305;n, s&#252;t toplay&#305;n!
      </div>

      <button class="btn-action" id="btn-start-game">&#9876;&#65039; OYUNA BA&#350;LA</button>
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
        <div class="slots-grid" id="shop-slots">
          <!-- 3 Slot -->
        </div>
      </div>

      <!-- MARKET TEKLİFLERİ (4 KART) -->
      <div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin: 4px 0;">
          <span style="font-size: 11px; font-weight: bold; color: #a0aec0;">MARKET KARTLARI</span>
          <button id="btn-reroll" style="background: #192233; color: #cbd5e0; border: 1px solid #334460; padding: 4px 8px; border-radius: 6px; font-size: 11px; cursor: pointer;">
            &#127922; Yenile (<span id="reroll-cost">2</span> &#129689;)
          </button>
        </div>
        <div class="cards-wrapper" id="shop-cards">
          <!-- 4 Cards -->
        </div>
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
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(140, t); osc.frequency.exponentialRampToValueAtTime(30, t + 0.4);
    g.gain.setValueAtTime(0.6, t); g.gain.linearRampToValueAtTime(0.01, t + 0.4);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.4);
  }
  playSplash() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(360, t); osc.frequency.exponentialRampToValueAtTime(140, t + 0.15);
    g.gain.setValueAtTime(0.3, t); g.gain.linearRampToValueAtTime(0.01, t + 0.15);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.15);
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

// Avatar
if (images['player_south']) {
  const av = document.getElementById('cat-avatar');
  if (av) {
    const ai = new Image(); ai.src = ASSETS_DATA['player_south'];
    ai.style.width = '70px'; ai.style.height = '70px'; ai.style.objectFit = 'contain';
    ai.style.filter = 'drop-shadow(0 0 10px #f5be23)';
    av.appendChild(ai);
  }
}

// Oyun Kurulumu
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

const TIER_COLORS = { 1: '#00ff66', 2: '#00d2ff', 3: '#b844ff', 4: '#ff2255' };

const WEAPONS_DB = [
  { id: 'sword', title: 'Kara \u00C7elik K\u0131l\u0131\u00E7', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: '120\u00B0 yay kesi\u015Fi ve y\u00FCksek geri tepme.', icon: 'item_sword' },
  { id: 'claws', title: '\u00C7ift Pen\u00E7e', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 9, desc: 'Seri yak\u0131n sald\u0131r\u0131, +%25 kritik \u015Fans\u0131.', icon: 'item_claws' },
  { id: 'fish_boomerang', title: 'K\u0131l\u00E7\u0131k Bumerang\u0131', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: 'Gidip gelen delici kemik.', icon: 'item_fish' },
  { id: 'yarn_bomb', title: '\u0130p Yuma\u011F\u0131 Bombas\u0131', category: 'weapon', slot_pref: 'Kuyruk Yuvas\u0131', cost: 11, desc: 'Geni\u015F patlay\u0131c\u0131 alan hasar\u0131.', icon: 'item_yarn' },
  { id: 'magnum', title: 'A\u011F\u0131r Magnum', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 12, desc: 'Y\u00FCksek hasar ve a\u011F\u0131r geri tepmeli mermi.', icon: 'item_magnum' },
  { id: 'glock', title: 'Seri Glock', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 10, desc: 'Saniyede 4.5 seri kur\u015Fun ya\u011Fmuru.', icon: 'item_glock' },
  { id: 'bow', title: 'Avc\u0131 Yay\u0131', category: 'weapon', slot_pref: 'Sa\u011F / Sol El', cost: 11, desc: 'D\u00FC\u015Fmanlar\u0131 delip ge\u00E7en keskin oklar.', icon: 'item_bow' }
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
  hasPlayedBefore: false,
  wave: 1,
  maxWaves: 15,
  waveTime: 25,
  coins: 0,
  score: 0,
  kills: 0,
  rerollCount: 0,
  marketOffers: [],
  player: {
    x: 0, y: 0, hp: 100, maxHp: 100, speed: 220, dmgMult: 1.0, attackSpeed: 1.0,
    critChance: 0.05, critMult: 2.0, magnetRadius: 130, iframe: 0, dir: 'south',
    animFrame: 0, animTimer: 0,
    weapons: [
      { id: 'sword', title: 'Kara \u00C7elik K\u0131l\u0131\u00E7', tier: 1, cooldown: 0 },
      null, null
    ]
  },
  enemies: [], projectiles: [], collectibles: [], props: [], vfx: [], floatingTexts: [],
  camera: { x: 0, y: 0, shake: 0 },
  keys: {}, joystick: { active: false, x: 0, y: 0 }
};

// İnteraktif Sahne Nesneleri (Props) Üretimi
function spawnWaveProps() {
  Game.props = [];
  
  // 1. Sandıklar (Loot Crates)
  const crateCount = Math.floor(Math.random() * 2) + 2;
  for (let i = 0; i < crateCount; i++) {
    Game.props.push({
      type: 'crate',
      x: (Math.random() - 0.5) * 1100,
      y: (Math.random() - 0.5) * 1700,
      hp: 35,
      maxHp: 35,
      radius: 20
    });
  }

  // 2. Çatı Su Kulesi (Water Tower)
  if (Game.wave % 3 === 0 || Game.wave === 1) {
    Game.props.push({
      type: 'water_tower',
      x: (Math.random() > 0.5 ? 1 : -1) * (300 + Math.random() * 200),
      y: (Math.random() > 0.5 ? 1 : -1) * (400 + Math.random() * 300),
      hp: 45,
      maxHp: 45,
      radius: 28
    });
  }

  // 3. Fare Yuvası (Rat Nest Spawner)
  if (Game.wave >= 3 && Math.random() < 0.65) {
    Game.props.push({
      type: 'rat_nest',
      x: (Math.random() > 0.5 ? 1 : -1) * 450,
      y: (Math.random() > 0.5 ? 1 : -1) * 700,
      hp: 80,
      maxHp: 80,
      radius: 26,
      spawnTimer: 4.5
    });
  }
}

// Oyunu Başlat / Sıfırla
function startNewGame() {
  Game.wave = 1;
  Game.coins = 0;
  Game.score = 0;
  Game.kills = 0;
  Game.player.hp = 100;
  Game.player.maxHp = 100;
  Game.player.speed = 220;
  Game.player.dmgMult = 1.0;
  Game.player.attackSpeed = 1.0;
  Game.player.critChance = 0.05;
  Game.player.critMult = 2.0;
  Game.player.magnetRadius = 130;
  Game.player.x = 0;
  Game.player.y = 0;
  Game.player.weapons = [
    { id: 'sword', title: 'Kara \u00C7elik K\u0131l\u0131\u00E7', tier: 1, cooldown: 0 },
    null, null
  ];
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

  spawnWaveProps();

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
        attackTimer: 3.0,
        enraged: false
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

      // Arena sınırlarında tut
      if (Math.abs(ex) < 650 && Math.abs(ey) < 980) {
        const roll = Math.random();
        if (Game.wave >= 4 && roll < 0.25) {
          // Dasher Rat
          Game.enemies.push({
            type: 'dasher',
            x: ex, y: ey,
            hp: 24 + Game.wave * 5, maxHp: 24 + Game.wave * 5,
            speed: 160, damage: 14, radius: 15, coinValue: 2,
            dashTimer: 2.5, isDashing: false, dashDur: 0
          });
        } else if (Game.wave >= 6 && roll < 0.45) {
          // Tank Rat
          Game.enemies.push({
            type: 'tank',
            x: ex, y: ey,
            hp: 65 + Game.wave * 12, maxHp: 65 + Game.wave * 12,
            speed: 85, damage: 22, radius: 22, coinValue: 4
          });
        } else if (Game.wave >= 3 && roll < 0.65) {
          // Spitter Rat
          Game.enemies.push({
            type: 'spitter',
            x: ex, y: ey,
            hp: 18 + Game.wave * 4, maxHp: 18 + Game.wave * 4,
            speed: 105, damage: 10, radius: 14, coinValue: 2,
            shootTimer: 2.5
          });
        } else {
          // Small Rat
          Game.enemies.push({
            type: 'small',
            x: ex, y: ey,
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

    // Yön tespiti
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

  // Sınır Çatıda Tut (Parapet)
  Game.player.x = Math.max(-620, Math.min(620, Game.player.x));
  Game.player.y = Math.max(-950, Math.min(950, Game.player.y));

  if (Game.player.iframe > 0) Game.player.iframe -= dt;

  // Kamera Takibi
  Game.camera.x += (Game.player.x - Game.camera.x) * 0.12;
  Game.camera.y += (Game.player.y - Game.camera.y) * 0.12;

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

    // Vuruş alanı
    const hitRadius = 100;
    damageArea(p.x + Math.cos(targetAngle) * 45, p.y + Math.sin(targetAngle) * 45, hitRadius, 25 * w.tier * p.dmgMult, 180, targetAngle);
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
    damageArea(p.x + Math.cos(targetAngle) * 35, p.y + Math.sin(targetAngle) * 35, 75, 14 * w.tier * p.dmgMult, 100, targetAngle, true);
  }
  else if (w.id === 'magnum') {
    w.cooldown = 0.85 / p.attackSpeed;
    if (closest) {
      const angle = Math.atan2(closest.y - p.y, closest.x - p.x);
      Game.projectiles.push({
        type: 'bullet',
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
        type: 'bullet',
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
        type: 'arrow',
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
      type: 'boomerang',
      x: p.x, y: p.y,
      vx: Math.cos(angle) * 450, vy: Math.sin(angle) * 450,
      startX: p.x, startY: p.y,
      returning: false,
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
      type: 'bomb',
      x: p.x, y: p.y,
      targetX: tx, targetY: ty,
      progress: 0,
      damage: 42 * w.tier * p.dmgMult,
      life: 0.6, radius: 12, color: '#b844ff'
    });
  }
}

function getClosestTarget(x, y, maxDist) {
  let closest = null;
  let minDist = maxDist;

  // Düşmanlar
  Game.enemies.forEach(e => {
    const d = Math.hypot(e.x - x, e.y - y);
    if (d < minDist) {
      minDist = d;
      closest = e;
    }
  });

  // İnteraktif Sandıklar & Yuvalar
  Game.props.forEach(pr => {
    const d = Math.hypot(pr.x - x, pr.y - y);
    if (d < minDist) {
      minDist = d;
      closest = pr;
    }
  });

  return closest;
}

function damageArea(x, y, radius, dmg, knock, knockAngle, extraCrit = false) {
  const isCrit = (Math.random() < (Game.player.critChance + (extraCrit ? 0.25 : 0)));
  const finalDmg = isCrit ? dmg * Game.player.critMult : dmg;

  // Düşmanlara Hasar
  Game.enemies.forEach(e => {
    const d = Math.hypot(e.x - x, e.y - y);
    if (d < radius + e.radius) {
      e.hp -= finalDmg;
      e.x += Math.cos(knockAngle) * (knock * 0.1);
      e.y += Math.sin(knockAngle) * (knock * 0.1);
      spawnFloatingText(Math.round(finalDmg), e.x, e.y - 10, isCrit);
    }
  });

  // Nesnelere Hasar (Sandık, Su Kulesi, Yuva)
  Game.props.forEach(pr => {
    const d = Math.hypot(pr.x - x, pr.y - y);
    if (d < radius + pr.radius) {
      pr.hp -= finalDmg;
      spawnFloatingText(Math.round(finalDmg), pr.x, pr.y - 10, false);
    }
  });
}

function spawnFloatingText(txt, x, y, isCrit) {
  Game.floatingTexts.push({
    text: (isCrit ? '⚡ ' : '') + txt,
    x: x, y: y,
    color: isCrit ? '#f5be23' : '#ffffff',
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

      // Düşman Çarpışması
      for (let j = Game.enemies.length - 1; j >= 0; j--) {
        const e = Game.enemies[j];
        if (Math.hypot(e.x - p.x, e.y - p.y) < e.radius + p.radius) {
          const isCrit = Math.random() < Game.player.critChance;
          const dmg = isCrit ? p.damage * Game.player.critMult : p.damage;
          e.hp -= dmg;
          spawnFloatingText(Math.round(dmg), e.x, e.y, isCrit);
          p.pierce--;
          if (p.pierce <= 0) { p.life = 0; break; }
        }
      }

      // Prop Çarpışması
      for (let j = Game.props.length - 1; j >= 0; j--) {
        const pr = Game.props[j];
        if (Math.hypot(pr.x - p.x, pr.y - p.y) < pr.radius + p.radius) {
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
        }
      });
    }
    else if (p.type === 'bomb') {
      p.progress += dt / p.life;
      p.x += (p.targetX - p.x) * 0.15;
      p.y += (p.targetY - p.y) * 0.15;
      if (p.progress >= 1.0) {
        p.life = 0;
        audio.playExplosion();
        Game.vfx.push({ type: 'explosion', x: p.targetX, y: p.targetY, radius: 120, life: 0.3, maxLife: 0.3 });
        damageArea(p.targetX, p.targetY, 120, p.damage, 220, 0);
      }
    }

    if (p.life <= 0) Game.projectiles.splice(i, 1);
  }
}

// İnteraktif Nesneleri Güncelle
function updateProps(dt) {
  for (let i = Game.props.length - 1; i >= 0; i--) {
    const pr = Game.props[i];

    // Fare Yuvası Spawn Döngüsü
    if (pr.type === 'rat_nest') {
      pr.spawnTimer -= dt;
      if (pr.spawnTimer <= 0) {
        pr.spawnTimer = 4.0;
        for (let k = 0; k < 3; k++) {
          Game.enemies.push({
            type: 'small',
            x: pr.x + (Math.random() - 0.5) * 40,
            y: pr.y + (Math.random() - 0.5) * 40,
            hp: 14 + Game.wave * 3, maxHp: 14 + Game.wave * 3,
            speed: 140, damage: 8, radius: 12, coinValue: 1
          });
        }
      }
    }

    // Kırılma / Patlama
    if (pr.hp <= 0) {
      if (pr.type === 'crate') {
        audio.playExplosion();
        // Altın ve Süt Düşür
        Game.collectibles.push({ type: 'coin', x: pr.x - 10, y: pr.y, val: 5 });
        Game.collectibles.push({ type: 'coin', x: pr.x + 10, y: pr.y, val: 5 });
        if (Math.random() < 0.6) {
          Game.collectibles.push({ type: 'milk', x: pr.x, y: pr.y - 12, heal: 25 });
        }
      }
      else if (pr.type === 'water_tower') {
        audio.playSplash();
        Game.vfx.push({ type: 'water_wave', x: pr.x, y: pr.y, radius: 240, life: 0.4, maxLife: 0.4 });
        damageArea(pr.x, pr.y, 240, 60, 350, 0);
      }
      else if (pr.type === 'rat_nest') {
        audio.playExplosion();
        for (let c = 0; c < 4; c++) {
          Game.collectibles.push({ type: 'coin', x: pr.x + (Math.random()-0.5)*30, y: pr.y + (Math.random()-0.5)*30, val: 3 });
        }
      }
      Game.props.splice(i, 1);
    }
  }
}

// Düşmanları Güncelle
function updateEnemies(dt) {
  const p = Game.player;

  for (let i = Game.enemies.length - 1; i >= 0; i--) {
    const e = Game.enemies[i];

    // Oyuncuya Doğru Hareket
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

      // Boss Saldırıları
      e.attackTimer -= dt;
      if (e.attackTimer <= 0) {
        e.attackTimer = (e.tier === 3) ? 2.2 : 3.5;
        // Şok Dalgası
        audio.playExplosion();
        Game.vfx.push({ type: 'boss_shock', x: e.x, y: e.y, radius: 180 * e.tier, life: 0.4, maxLife: 0.4 });
        if (Math.hypot(p.x - e.x, p.y - e.y) < 180 * e.tier && p.iframe <= 0) {
          p.hp -= e.damage * 0.8;
          p.iframe = 0.4;
          audio.playHurt();
        }
      }

      // Boss Can Barı Güncelle
      const bossBar = document.getElementById('boss-hp');
      if (bossBar) {
        bossBar.style.width = Math.max(0, (e.hp / e.maxHp) * 100) + '%';
      }
    }
    else {
      e.x += Math.cos(angle) * e.speed * dt;
      e.y += Math.sin(angle) * e.speed * dt;
    }

    // Oyuncuya Temas Hasarı
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

    // Ölüm
    if (e.hp <= 0) {
      Game.kills++;
      Game.score += e.type === 'boss' ? 5000 * e.tier : 100;

      // Coin Düşür
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

    // Mıknatıs Çekimi
    if (dist < p.magnetRadius) {
      const angle = Math.atan2(p.y - c.y, p.x - c.x);
      const spd = 450 + (1 - dist / p.magnetRadius) * 300;
      c.x += Math.cos(angle) * spd * dt;
      c.y += Math.sin(angle) * spd * dt;
    }

    // Toplama
    if (dist < 26) {
      if (c.type === 'coin') {
        Game.coins += c.val;
        Game.score += c.val * 10;
        audio.playCoin();
      } else if (c.type === 'milk') {
        p.hp = Math.min(p.maxHp, p.hp + c.heal);
        audio.playMeow();
        spawnFloatingText('+' + c.heal + ' HP', p.x, p.y - 20, false);
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

  const cx = canvas.width / 2 - Game.camera.x;
  const cy = canvas.height / 2 - Game.camera.y;

  // 1. Zemin (Çatı Katı)
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

  // 2. İnteraktif Nesneler (Props)
  Game.props.forEach(pr => {
    const px = pr.x + cx, py = pr.y + cy;
    ctx.save();
    if (pr.type === 'crate') {
      ctx.fillStyle = '#8a532b';
      ctx.fillRect(px - 18, py - 18, 36, 36);
      ctx.strokeStyle = '#f5be23';
      ctx.lineWidth = 2.5;
      ctx.strokeRect(px - 18, py - 18, 36, 36);
      ctx.fillStyle = '#ffd700';
      ctx.font = 'bold 16px sans-serif';
      ctx.fillText('\uD83D\uDCE6', px - 10, py + 6);
    }
    else if (pr.type === 'water_tower') {
      ctx.fillStyle = '#225588';
      ctx.beginPath();
      ctx.arc(px, py, pr.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#00d2ff';
      ctx.lineWidth = 3;
      ctx.stroke();
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 18px sans-serif';
      ctx.fillText('\uD83D\uDEB0', px - 11, py + 7);
    }
    else if (pr.type === 'rat_nest') {
      ctx.fillStyle = '#3a1e28';
      ctx.beginPath();
      ctx.arc(px, py, pr.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#ff3366';
      ctx.lineWidth = 3;
      ctx.stroke();
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 18px sans-serif';
      ctx.fillText('\uD83E\uDEB4', px - 11, py + 7);
    }
    ctx.restore();
  });

  // 3. Toplanabilirler (Coin & Süt)
  Game.collectibles.forEach(c => {
    const px = c.x + cx, py = c.y + cy;
    ctx.save();
    if (c.type === 'coin') {
      ctx.fillStyle = '#ffd700';
      ctx.beginPath();
      ctx.arc(px, py, 7, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#b8860b';
      ctx.lineWidth = 1.5;
      ctx.stroke();
    } else if (c.type === 'milk') {
      ctx.fillStyle = '#ffffff';
      ctx.beginPath();
      ctx.arc(px, py, 9, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#00d2ff';
      ctx.lineWidth = 2;
      ctx.stroke();
      ctx.font = 'bold 12px sans-serif';
      ctx.fillText('\uD83E\uDD5B', px - 7, py + 5);
    }
    ctx.restore();
  });

  // 4. Düşmanlar
  Game.enemies.forEach(e => {
    const px = e.x + cx, py = e.y + cy;
    ctx.save();
    if (e.type === 'boss') {
      ctx.fillStyle = (e.tier === 3) ? '#990033' : '#660011';
      ctx.beginPath();
      ctx.arc(px, py, e.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#f5be23';
      ctx.lineWidth = 4;
      ctx.stroke();
      ctx.fillStyle = '#ffd700';
      ctx.font = 'bold 24px sans-serif';
      ctx.fillText('\uD83D\uDC51', px - 14, py + 8);
    } else if (e.type === 'dasher') {
      ctx.fillStyle = '#cc5500';
      ctx.beginPath();
      ctx.arc(px, py, e.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#ffaa00';
      ctx.stroke();
    } else if (e.type === 'tank') {
      ctx.fillStyle = '#555566';
      ctx.beginPath();
      ctx.arc(px, py, e.radius, 0, Math.PI * 2);
      ctx.fill();
      ctx.strokeStyle = '#9999aa';
      ctx.lineWidth = 3;
      ctx.stroke();
    } else {
      ctx.fillStyle = '#886655';
      ctx.beginPath();
      ctx.arc(px, py, e.radius, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
  });

  // 5. Oyuncu (Kedi) - Tam 90px Dengeli Boyut
  const px = Game.player.x + cx, py = Game.player.y + cy;
  ctx.save();
  const dirImgKey = 'player_' + Game.player.dir;
  if (images[dirImgKey]) {
    const catSize = 90;
    ctx.drawImage(images[dirImgKey], px - catSize/2, py - catSize/2, catSize, catSize);
  } else {
    ctx.fillStyle = '#111';
    ctx.beginPath();
    ctx.arc(px, py, 20, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.restore();

  // 6. Mermiler & Efektler
  Game.projectiles.forEach(p => {
    const ppx = p.x + cx, ppy = p.y + cy;
    ctx.save();
    ctx.fillStyle = p.color;
    ctx.beginPath();
    ctx.arc(ppx, ppy, p.radius, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  });

  Game.vfx.forEach(v => {
    const vx = v.x + cx, vy = v.y + cy;
    ctx.save();
    if (v.type === 'slash') {
      ctx.strokeStyle = 'rgba(255, 230, 100, 0.8)';
      ctx.lineWidth = 6;
      ctx.beginPath();
      ctx.arc(vx, vy, 45, v.angle - 0.8, v.angle + 0.8);
      ctx.stroke();
    } else if (v.type === 'water_wave') {
      ctx.strokeStyle = 'rgba(0, 210, 255, ' + (v.life / v.maxLife) + ')';
      ctx.lineWidth = 10;
      ctx.beginPath();
      ctx.arc(vx, vy, v.radius * (1 - v.life / v.maxLife), 0, Math.PI * 2);
      ctx.stroke();
    } else if (v.type === 'boss_shock') {
      ctx.strokeStyle = 'rgba(255, 50, 50, ' + (v.life / v.maxLife) + ')';
      ctx.lineWidth = 8;
      ctx.beginPath();
      ctx.arc(vx, vy, v.radius * (1 - v.life / v.maxLife), 0, Math.PI * 2);
      ctx.stroke();
    }
    ctx.restore();
  });

  // 7. Floating Texts
  Game.floatingTexts.forEach(ft => {
    const ftx = ft.x + cx, fty = ft.y + cy;
    ctx.save();
    ctx.fillStyle = ft.color;
    ctx.font = 'bold ' + ft.size + 'px sans-serif';
    ctx.fillText(ft.text, ftx, fty);
    ctx.restore();
  });
}

// Dalga Sonu & Market
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
          // Boş yuva bul veya 1. yuvaya koy
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
          // Pasif Etki (Sınırsız alınabilir)
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
  document.getElementById('go-wave').textContent = Game.wave;
  document.getElementById('go-kills').textContent = Game.kills;
  document.getElementById('go-score').textContent = Game.score;
  document.getElementById('modal-gameover').style.display = 'flex';
}

function triggerVictory() {
  Game.state = 'VICTORY';
  document.getElementById('vic-score').textContent = Game.score;
  document.getElementById('vic-kills').textContent = Game.kills;
  document.getElementById('modal-victory').style.display = 'flex';
}

// Ana Oyun Döngüsü
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
  Game.state = 'MENU';
};
document.getElementById('btn-go-menu').onclick = () => {
  document.getElementById('modal-gameover').style.display = 'none';
  document.getElementById('modal-menu').style.display = 'flex';
  Game.state = 'MENU';
};
document.getElementById('btn-vic-menu').onclick = () => {
  document.getElementById('modal-victory').style.display = 'none';
  document.getElementById('modal-menu').style.display = 'flex';
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

requestAnimationFrame(gameLoop);
</script>
</body>
</html>
'@

$fullHtml = $htmlPart1 + $jsonAssets + $htmlPart2

[System.IO.File]::WriteAllText("$webDir\index.html", $fullHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$webDir\Kara_Kedi_Web.html", $fullHtml, [System.Text.Encoding]::UTF8)

# Readme / Guide
$readme = @"
# 🎮 Kara Kedi: BLB Web Sürümü

Bu klasör, projenin **tüm güncel mekaniklerini, nesnelerini ve boss savaşlarını** barındıran resmi web sürümüdür.

## 🚀 Nasıl Başlatılır?
- Doğrudan `index.html` veya `Kara_Kedi_Web.html` dosyasına çift tıklayarak tarayıcınızda oynayabilirsiniz.
- Güncellemeleri yenilemek için `guncelle_web.ps1` dosyasını çalıştırabilirsiniz.
"@
[System.IO.File]::WriteAllText("$webDir\README.md", $readme, [System.Text.Encoding]::UTF8)

# Bat başlatıcı
$batContent = "@echo off`nstart index.html"
[System.IO.File]::WriteAllText("$webDir\baslat.bat", $batContent, [System.Text.Encoding]::UTF8)

Write-Output "BLB_WEB_EDITION_GENERATED_SUCCESSFULLY"
