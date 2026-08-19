$webDir = $PSScriptRoot
$projectDir = Split-Path -Path $webDir -Parent
$json = [System.IO.File]::ReadAllText("$webDir\embedded_assets.json", [System.Text.Encoding]::UTF8)

$htmlPart1 = @'
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Kara Kedi: Fare &#304;stilas&#305; | Web S&#252;r&#252;m&#252;</title>
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

  <div id="touch-joystick" class="interactive"><div id="touch-knob"></div></div>

  <!-- BAŞLANGIÇ MENÜSÜ -->
  <div class="modal-backdrop interactive" id="modal-menu" style="display: flex;">
    <div class="modal-box">
      <div id="cat-avatar" style="width: 76px; height: 76px; display: flex; align-items: center; justify-content: center;"></div>
      <h1 style="color: #f5be23; font-size: 34px; margin: 0; text-shadow: 0 0 12px rgba(245,190,35,0.4);">KARA KED&#304;</h1>
      <h2 style="color: #ff4444; font-size: 24px; margin: 0;">FARE &#304;ST&#304;LASI</h2>
      <div style="font-size: 14px; color: #8fa0b5;">15 Dalga Hayatta Kalma Roguelite</div>
      
      <div style="background: #131722; border: 1.5px solid #2a3a55; border-radius: 12px; padding: 12px; font-size: 13px; line-height: 1.5; color: #ccc; width: 100%;">
        <div style="color: #00d2ff; font-weight: bold; margin-bottom: 4px;">&#127918; NASIL OYNANIR?</div>
        &#8226; WASD / Y&#246;n Tu&#351;lar&#305; veya Dokunmatik Joystick ile hareket edin.<br>
        &#8226; Silahlar en yak&#305;n d&#252;&#351;manlara otomatik sald&#305;r&#305;r.<br>
        &#8226; D&#252;&#351;manlardan d&#252;&#351;en coinleri toplayarak dalga sonlar&#305;nda marketten yeni silahlar ve g&#252;&#231;lendirmeler sat&#305;n al&#305;n!<br>
        &#8226; 3 Silah Yuvan&#305;z&#305; y&#246;netin, ayn&#305; silahlar&#305; birle&#351;tirerek Tier 4 seviyesine kadar y&#252;kseltin!
      </div>

      <button class="btn-action" id="btn-start">&#9876;&#65039; SAVA&#350;A BA&#350;LA</button>
    </div>
  </div>

  <!-- MARKET (SHOP) -->
  <div class="modal-backdrop interactive" id="modal-shop">
    <div class="shop-box">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2 style="color: #f5be23; font-size: 18px; margin: 0;">&#127978; SAVA&#350; MARKET&#304;</h2>
        <div style="font-weight: bold; color: #ffd700; font-size: 14px;">&#129689; MEVCUT COIN: <span id="shop-coins">0</span></div>
      </div>
      <div class="slots-grid" id="slots-container"></div>
      <div class="cards-wrapper" id="cards-container"></div>
      <div style="display: flex; justify-content: space-between; gap: 8px; margin-top: 4px;">
        <button class="btn-action" id="btn-reroll" style="font-size: 13px; padding: 8px 16px;">&#128259; YEN&#304;LE (3 Coin)</button>
        <button class="btn-action" id="btn-next-wave" style="font-size: 13px; padding: 8px 16px; background: #00c853; border-color: #55ff88;">&#9876;&#65039; SONRAK&#304; DALGA</button>
      </div>
    </div>
  </div>

  <!-- GAME OVER -->
  <div class="modal-backdrop interactive" id="modal-gameover">
    <div class="modal-box" style="border-color: #ff3333;">
      <h1 style="color: #ff3333; font-size: 30px;">&#128128; OYUN B&#304;TT&#304;</h1>
      <div id="gameover-stats" style="font-size: 14px; text-align: center; line-height: 1.6; color: #ccc;"></div>
      <button class="btn-action" id="btn-retry" style="background: #ff3333; color: white; border-color: #ff8888;">&#128257; YEN&#304;DEN OYNA</button>
    </div>
  </div>

  <!-- VICTORY -->
  <div class="modal-backdrop interactive" id="modal-victory">
    <div class="modal-box" style="border-color: #00ff88; box-shadow: 0 0 35px rgba(0, 255, 136, 0.4);">
      <h1 style="color: #00ff88; font-size: 30px;">&#128081; ZAFER!</h1>
      <div style="font-size: 14px; color: #ddd; text-align: center;">Fare &#304;mparatoru ve t&#252;m istilac&#305; fareler yok edildi! Krall&#305;k kurtuldu!</div>
      <div id="victory-stats" style="font-size: 14px; text-align: center; line-height: 1.6; color: #ffeb3b;"></div>
      <button class="btn-action" id="btn-victory-restart" style="background: #00ff88; color: #000; border-color: #fff;">&#127942; TEKRAR OYNA</button>
    </div>
  </div>
</div>

<script>
const ASSETS_DATA = 
'@

$htmlPart2 = @'
;

// --- WEB AUDIO API SES MOTORU ---
class AudioEngine {
  constructor() { this.ctx = null; }
  init() { if (!this.ctx) this.ctx = new (window.AudioContext || window.webkitAudioContext)(); }
  playSlash() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(680, t); osc.frequency.exponentialRampToValueAtTime(160, t + 0.13);
    g.gain.setValueAtTime(0.35, t); g.gain.linearRampToValueAtTime(0.01, t + 0.13);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.13);
  }
  playHit() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'triangle'; osc.frequency.setValueAtTime(180, t); osc.frequency.exponentialRampToValueAtTime(45, t + 0.11);
    g.gain.setValueAtTime(0.4, t); g.gain.linearRampToValueAtTime(0.01, t + 0.11);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.11);
  }
  playDamage() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sawtooth'; osc.frequency.setValueAtTime(220, t); osc.frequency.exponentialRampToValueAtTime(60, t + 0.22);
    g.gain.setValueAtTime(0.45, t); g.gain.linearRampToValueAtTime(0.01, t + 0.22);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.22);
  }
  playCoin() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(980, t); osc.frequency.setValueAtTime(1320, t + 0.05);
    g.gain.setValueAtTime(0.25, t); g.gain.linearRampToValueAtTime(0.01, t + 0.18);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.18);
  }
  playMagnum() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'sine'; osc.frequency.setValueAtTime(140, t); osc.frequency.exponentialRampToValueAtTime(30, t + 0.28);
    g.gain.setValueAtTime(0.6, t); g.gain.linearRampToValueAtTime(0.01, t + 0.28);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.28);
  }
  playGlock() {
    if (!this.ctx) return;
    const t = this.ctx.currentTime, osc = this.ctx.createOscillator(), g = this.ctx.createGain();
    osc.type = 'square'; osc.frequency.setValueAtTime(280, t); osc.frequency.exponentialRampToValueAtTime(80, t + 0.09);
    g.gain.setValueAtTime(0.3, t); g.gain.linearRampToValueAtTime(0.01, t + 0.09);
    osc.connect(g); g.connect(this.ctx.destination); osc.start(t); osc.stop(t + 0.09);
  }
  playBow() {
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
  enemies: [], projectiles: [], collectibles: [], vfx: [], floatingTexts: [],
  camera: { x: 0, y: 0, shake: 0 },
  keys: {}, joystick: { active: false, x: 0, y: 0 }
};

// Girdiler
window.addEventListener('keydown', e => Game.keys[e.key.toLowerCase()] = true);
window.addEventListener('keyup', e => Game.keys[e.key.toLowerCase()] = false);

// Mobil Joystick
const joyZone = document.getElementById('touch-joystick');
const joyKnob = document.getElementById('touch-knob');
if ('ontouchstart' in window) {
  joyZone.style.display = 'block';
  let startX = 0, startY = 0;
  joyZone.addEventListener('touchstart', e => {
    e.preventDefault();
    const rect = joyZone.getBoundingClientRect();
    startX = rect.left + rect.width / 2; startY = rect.top + rect.height / 2;
    Game.joystick.active = true;
  });
  joyZone.addEventListener('touchmove', e => {
    e.preventDefault();
    if (!Game.joystick.active) return;
    let dx = e.touches[0].clientX - startX, dy = e.touches[0].clientY - startY;
    const dist = Math.hypot(dx, dy), maxR = 36;
    if (dist > maxR) { dx = (dx / dist) * maxR; dy = (dy / dist) * maxR; }
    joyKnob.style.transform = 'translate(' + dx + 'px, ' + dy + 'px)';
    Game.joystick.x = dx / maxR; Game.joystick.y = dy / maxR;
  });
  const resetJoy = () => {
    Game.joystick.active = false; Game.joystick.x = 0; Game.joystick.y = 0;
    joyKnob.style.transform = 'translate(0, 0)';
  };
  joyZone.addEventListener('touchend', resetJoy);
  joyZone.addEventListener('touchcancel', resetJoy);
}

function startGame() {
  audio.init();
  audio.playWaveHorn();
  Game.state = 'PLAYING';
  Game.hasPlayedBefore = true;
  Game.wave = 1; Game.coins = 0; Game.score = 0; Game.kills = 0;
  Game.player.hp = 100; Game.player.maxHp = 100; Game.player.x = 0; Game.player.y = 0;
  Game.player.weapons = [
    { id: 'sword', title: 'Kara \u00C7elik K\u0131l\u0131\u00E7', tier: 1, cooldown: 0 },
    null, null
  ];
  startWave(1);
  document.querySelectorAll('.modal-backdrop').forEach(el => el.style.display = 'none');
}

function startWave(num) {
  Game.wave = num;
  Game.waveTime = (num === 5 || num === 10 || num === 15) ? 35 : 25;
  Game.enemies = []; Game.projectiles = []; Game.collectibles = []; Game.vfx = [];
  Game.bossSpawned = false;
  document.getElementById('hud-wave').textContent = num;
  document.getElementById('boss-hud').style.display = 'none';
  audio.playWaveHorn();
}

function update(dt) {
  if (Game.state !== 'PLAYING') return;

  // 1. Oyuncu Hareketi (8-Yönlü Birebir Açı & Animasyon Eşlemesi)
  let moveX = 0, moveY = 0;
  if (Game.keys['w'] || Game.keys['arrowup']) moveY -= 1;
  if (Game.keys['s'] || Game.keys['arrowdown']) moveY += 1;
  if (Game.keys['a'] || Game.keys['arrowleft']) moveX -= 1;
  if (Game.keys['d'] || Game.keys['arrowright']) moveX += 1;

  if (Game.joystick.active) { moveX = Game.joystick.x; moveY = Game.joystick.y; }

  const moveLen = Math.hypot(moveX, moveY);
  if (moveLen > 0.1) {
    moveX /= moveLen; moveY /= moveLen;
    Game.player.x += moveX * Game.player.speed * dt;
    Game.player.y += moveY * Game.player.speed * dt;

    // Arena Sınırları (-600..600, -900..900)
    Game.player.x = Math.max(-600, Math.min(600, Game.player.x));
    Game.player.y = Math.max(-900, Math.min(900, Game.player.y));

    // Godot player.gd açı mantığı
    const angle = Math.atan2(moveY, moveX);
    if (angle >= -Math.PI/8 && angle < Math.PI/8) Game.player.dir = 'east';
    else if (angle >= Math.PI/8 && angle < 3*Math.PI/8) Game.player.dir = 'south-east';
    else if (angle >= 3*Math.PI/8 && angle < 5*Math.PI/8) Game.player.dir = 'south';
    else if (angle >= 5*Math.PI/8 && angle < 7*Math.PI/8) Game.player.dir = 'south-east';
    else if (angle >= 7*Math.PI/8 || angle < -7*Math.PI/8) Game.player.dir = 'west';
    else if (angle >= -7*Math.PI/8 && angle < -5*Math.PI/8) Game.player.dir = 'north-west';
    else if (angle >= -5*Math.PI/8 && angle < -3*Math.PI/8) Game.player.dir = 'north';
    else if (angle >= -3*Math.PI/8 && angle < -Math.PI/8) Game.player.dir = 'north-east';

    Game.player.animTimer += dt;
    if (Game.player.animTimer >= 0.08) {
      Game.player.animTimer = 0;
      Game.player.animFrame = (Game.player.animFrame + 1) % 8;
    }
  } else {
    Game.player.animFrame = 0;
  }

  // Kamera & Sarsıntı
  Game.camera.x = Game.player.x; Game.camera.y = Game.player.y;
  if (Game.camera.shake > 0) Game.camera.shake = Math.max(0, Game.camera.shake - 35 * dt);
  if (Game.player.iframe > 0) Game.player.iframe -= dt;

  // 2. Dalga Yönetimi & Boss Kilit Sistemi
  Game.waveTime -= dt;
  const isBossWave = (Game.wave === 5 || Game.wave === 10 || Game.wave === 15);
  if (isBossWave && !Game.bossSpawned && Game.waveTime <= 34) spawnBoss();

  const bossAlive = Game.enemies.some(e => e.isBoss && e.hp > 0);
  if (Game.waveTime <= 0) {
    if (!bossAlive) { endWave(); return; }
    document.getElementById('hud-timer').textContent = '\u2694\uFE0F BOSS K\u0130L\u0130D\u0130';
  } else {
    const mins = Math.floor(Game.waveTime / 60), secs = Math.floor(Game.waveTime % 60);
    document.getElementById('hud-timer').textContent = '\u23F1\uFE0F ' + String(mins).padStart(2,'0') + ':' + String(secs).padStart(2,'0');
  }

  // Düşman Doğuşu
  if (Math.random() < (0.022 + Game.wave * 0.003)) spawnEnemy();

  // 3. Silahlar
  updateWeapons(dt);

  // 4. Düşmanlar
  for (let i = Game.enemies.length - 1; i >= 0; i--) {
    const e = Game.enemies[i];
    const dx = Game.player.x - e.x, dy = Game.player.y - e.y;
    const dist = Math.hypot(dx, dy);

    if (dist > 10) { e.x += (dx / dist) * e.speed * dt; e.y += (dy / dist) * e.speed * dt; }

    // Tüküren Fare: Yalnızca 380px menzile girdiğinde ateş eder
    if (e.type === 'spitter') {
      e.shootTimer = (e.shootTimer || 2.4) - dt;
      if (e.shootTimer <= 0) {
        if (dist <= 380) {
          Game.projectiles.push({
            x: e.x, y: e.y, vx: (dx/dist)*260, vy: (dy/dist)*260,
            damage: e.damage, isEnemy: true, life: 3.5
          });
        }
        e.shootTimer = 2.4;
      }
    }

    // Boss Saldırıları
    if (e.isBoss) {
      e.attackTimer = (e.attackTimer || 3.5) - dt;
      if (e.attackTimer <= 0) {
        audio.playBossRoar();
        Game.vfx.push({ type: 'shockwave', x: e.x, y: e.y, r: 10, maxR: 190, life: 0.5, damage: e.damage });
        Game.camera.shake = 14;
        e.attackTimer = (e.hp < e.maxHp * 0.5) ? 2.0 : 3.5;
      }
      document.getElementById('boss-hp').style.width = Math.max(0, (e.hp / e.maxHp) * 100) + '%';
    }

    // Temas Hasarı (90px boyuta göre 32px yarıçap)
    if (dist < (e.radius + 28) && Game.player.iframe <= 0) damagePlayer(e.damage);
  }

  // 5. Mermiler
  for (let i = Game.projectiles.length - 1; i >= 0; i--) {
    const p = Game.projectiles[i];
    p.x += p.vx * dt; p.y += p.vy * dt; p.life -= dt;

    if (p.isEnemy) {
      if (Math.hypot(p.x - Game.player.x, p.y - Game.player.y) < 28 && Game.player.iframe <= 0) {
        damagePlayer(p.damage); Game.projectiles.splice(i, 1); continue;
      }
    } else {
      for (const e of Game.enemies) {
        if (Math.hypot(p.x - e.x, p.y - e.y) < (e.radius + 14)) {
          damageEnemy(e, p.damage);
          if (p.pierce) { p.pierce--; if (p.pierce <= 0) { Game.projectiles.splice(i, 1); break; } }
          else { Game.projectiles.splice(i, 1); break; }
        }
      }
    }
    if (p.life <= 0) Game.projectiles.splice(i, 1);
  }

  // 6. Coinler (Altın ve Bakır)
  for (let i = Game.collectibles.length - 1; i >= 0; i--) {
    const c = Game.collectibles[i];
    const dx = Game.player.x - c.x, dy = Game.player.y - c.y, dist = Math.hypot(dx, dy);
    if (dist < Game.player.magnetRadius) {
      c.x += (dx / dist) * 480 * dt; c.y += (dy / dist) * 480 * dt;
      if (dist < 32) {
        Game.coins += c.val; Game.score += Math.floor(c.val * 50);
        audio.playCoin();
        document.getElementById('hud-coins').textContent = Math.floor(Game.coins);
        Game.collectibles.splice(i, 1);
      }
    }
  }

  // 7. VFX & Metinler
  for (let i = Game.vfx.length - 1; i >= 0; i--) {
    const v = Game.vfx[i]; v.life -= dt;
    if (v.type === 'shockwave') {
      v.r += (v.maxR / 0.5) * dt;
      if (Math.hypot(v.x - Game.player.x, v.y - Game.player.y) < v.r && Game.player.iframe <= 0) damagePlayer(v.damage);
    }
    if (v.life <= 0) Game.vfx.splice(i, 1);
  }

  for (let i = Game.floatingTexts.length - 1; i >= 0; i--) {
    const ft = Game.floatingTexts[i]; ft.y -= 30 * dt; ft.life -= dt;
    if (ft.life <= 0) Game.floatingTexts.splice(i, 1);
  }
}

function updateWeapons(dt) {
  Game.player.weapons.forEach(w => {
    if (!w) return;
    w.cooldown -= dt;
    if (w.cooldown <= 0) {
      const target = findClosestEnemy();
      if (!target) return;

      const dx = target.x - Game.player.x, dy = target.y - Game.player.y, dist = Math.hypot(dx, dy);
      const tierMult = 1.0 + (w.tier - 1) * 0.45;

      if (w.id === 'sword' && dist <= 170) {
        w.cooldown = 0.55 / Game.player.attackSpeed;
        audio.playSlash();
        damageEnemy(target, 32 * tierMult * Game.player.dmgMult);
        Game.vfx.push({ type: 'slash', x: Game.player.x + (dx/dist)*45, y: Game.player.y + (dy/dist)*45, angle: Math.atan2(dy, dx), tier: w.tier, life: 0.16 });
      } else if (w.id === 'claws' && dist <= 150) {
        w.cooldown = 0.25 / Game.player.attackSpeed;
        audio.playSlash();
        damageEnemy(target, 16 * tierMult * Game.player.dmgMult);
      } else if (w.id === 'magnum' && dist <= 550) {
        w.cooldown = 1.1 / Game.player.attackSpeed;
        audio.playMagnum();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*800, vy: (dy/dist)*800, damage: 45 * tierMult, isEnemy: false, life: 1.2 });
      } else if (w.id === 'glock' && dist <= 500) {
        w.cooldown = 0.22 / Game.player.attackSpeed;
        audio.playGlock();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*860, vy: (dy/dist)*860, damage: 10 * tierMult, isEnemy: false, life: 1.0 });
      } else if (w.id === 'bow' && dist <= 520) {
        w.cooldown = 0.48 / Game.player.attackSpeed;
        audio.playBow();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*740, vy: (dy/dist)*740, damage: 24 * tierMult, pierce: 2, isEnemy: false, life: 1.4 });
      }
    }
  });
}

function findClosestEnemy() {
  let closest = null, minDist = Infinity;
  for (const e of Game.enemies) {
    const d = Math.hypot(e.x - Game.player.x, e.y - Game.player.y);
    if (d < minDist) { minDist = d; closest = e; }
  }
  return closest;
}

function damagePlayer(dmg) {
  Game.player.hp -= dmg; Game.player.iframe = 0.45;
  audio.playDamage(); Game.camera.shake = 10;
  document.getElementById('hud-hp').style.width = Math.max(0, (Game.player.hp / Game.player.maxHp) * 100) + '%';

  if (Game.player.hp <= 0) {
    Game.state = 'GAMEOVER';
    document.getElementById('gameover-stats').innerHTML = 'Ula&#351;&#305;lan Dalga: <b>' + Game.wave + '</b><br>&#214;ld&#252;r&#252;len Fare: <b>' + Game.kills + '</b><br>Toplanan Coin: <b>' + Math.floor(Game.coins) + '</b><br>Toplam Puan: <b>' + Game.score + '</b>';
    document.getElementById('modal-gameover').style.display = 'flex';
  }
}

function damageEnemy(e, dmg) {
  const isCrit = Math.random() < Game.player.critChance;
  const finalDmg = isCrit ? dmg * Game.player.critMult : dmg;
  e.hp -= finalDmg; audio.playHit();

  Game.floatingTexts.push({
    x: e.x, y: e.y - 12, text: (isCrit ? '\uD83D\uDCA5 ' : '') + Math.floor(finalDmg),
    color: isCrit ? '#ffd700' : '#ffffff', life: 0.6
  });

  if (e.hp <= 0) {
    Game.kills++; Game.score += e.isBoss ? 5000 : 100;
    // Büyük Altın Coin (0.75x)
    Game.collectibles.push({ x: e.x, y: e.y, val: e.baseCoin, type: 'gold' });
    // Küçük Bakır Coin (0.60x)
    if (Math.random() < 0.6) {
      Game.collectibles.push({ x: e.x + (Math.random()*20-10), y: e.y + (Math.random()*20-10), val: e.baseCoin / 2, type: 'copper' });
    }
    Game.enemies = Game.enemies.filter(x => x !== e);
  }
}

function spawnEnemy() {
  const side = Math.floor(Math.random() * 4);
  let x = 0, y = 0;
  if (side === 0) { x = Math.random()*1200 - 600; y = -900; }
  else if (side === 1) { x = Math.random()*1200 - 600; y = 900; }
  else if (side === 2) { x = -600; y = Math.random()*1800 - 900; }
  else { x = 600; y = Math.random()*1800 - 900; }

  const types = ['small', 'dasher', 'spitter', 'tank'];
  const t = types[Math.floor(Math.random() * Math.min(types.length, 1 + Math.floor(Game.wave / 3)))];

  let hp = 20, speed = 145, dmg = 10, radius = 14, baseCoin = 1;
  if (t === 'dasher') { hp = 32; speed = 185; dmg = 14; radius = 16; baseCoin = 2; }
  else if (t === 'spitter') { hp = 30; speed = 110; dmg = 12; radius = 16; baseCoin = 2; }
  else if (t === 'tank') { hp = 90; speed = 80; dmg = 18; radius = 24; baseCoin = 4; }

  Game.enemies.push({ x, y, hp, maxHp: hp, speed, damage: dmg, radius, type: t, baseCoin, isBoss: false });
}

function spawnBoss() {
  Game.bossSpawned = true; audio.playBossRoar();
  let hp = 850, dmg = 22, title = '\uD83D\uDC51 FARE KRALI (Mini-Boss)';
  if (Game.wave === 10) { hp = 1800; dmg = 32; title = '\uD83D\uDC51 B\u00DCY\u00DCK FARE KRALI'; }
  else if (Game.wave === 15) { hp = 6000; dmg = 45; title = '\uD83D\uDC80 FARE \u0130MPARATORU (MEGA-BOSS)'; }

  document.getElementById('boss-label').textContent = title;
  document.getElementById('boss-hud').style.display = 'flex';
  document.getElementById('boss-hp').style.width = '100%';

  Game.enemies.push({
    x: 0, y: -700, hp, maxHp: hp, speed: (Game.wave === 15) ? 140 : 100,
    damage: dmg, radius: 38, type: 'boss', baseCoin: 16, isBoss: true
  });
}

function endWave() {
  Game.collectibles = []; Game.projectiles = []; Game.enemies = [];
  if (Game.wave >= 15) {
    Game.state = 'VICTORY';
    document.getElementById('victory-stats').innerHTML = '&#214;ld&#252;r&#252;len Fare: <b>' + Game.kills + '</b><br>Kazan&#305;lan Coin: <b>' + Math.floor(Game.coins) + '</b><br>Toplam Skor: <b>' + Game.score + '</b>';
    document.getElementById('modal-victory').style.display = 'flex';
    return;
  }
  Game.state = 'SHOP';
  openShop();
}

// --- MARKET SİSTEMİ (Birebir Godot shop.gd) ---
function openShop() {
  document.getElementById('shop-coins').textContent = Math.floor(Game.coins);
  document.getElementById('modal-shop').style.display = 'flex';
  renderShopSlots();
  populateMarketCards();
}

function renderShopSlots() {
  const container = document.getElementById('slots-container');
  container.innerHTML = '';
  const slotNames = ['Sa\u011F El (1)', 'Sol El (2)', 'Kuyruk (3)'];

  Game.player.weapons.forEach((w, idx) => {
    const el = document.createElement('div');
    el.className = 'slot-card';
    if (w) {
      el.style.borderColor = TIER_COLORS[w.tier];
      el.innerHTML = '<span style="color:' + TIER_COLORS[w.tier] + '; font-weight:bold;">' + w.title + ' [T' + w.tier + ']</span>' +
        '<button onclick="sellWeapon(' + idx + ')" style="background:#442; color:#ffdd44; border:none; padding:3px 4px; border-radius:4px; font-size:10px; cursor:pointer;">Sat (+' + Math.floor(w.tier * 6) + ')</button>';
    } else {
      el.innerHTML = '<span style="color:#778;">' + slotNames[idx] + ':<br>[BO\u015E YUVA]</span>';
    }
    container.appendChild(el);
  });
}

window.sellWeapon = function(idx) {
  const w = Game.player.weapons[idx];
  if (!w) return;
  Game.coins += Math.floor(w.tier * 6);
  Game.player.weapons[idx] = null;
  audio.playCoin();
  document.getElementById('shop-coins').textContent = Math.floor(Game.coins);
  renderShopSlots();
  renderMarketCards();
};

function populateMarketCards() {
  const preserved = Game.marketOffers.filter(c => c.locked);
  const pool = [...WEAPONS_DB, ...ITEMS_DB].sort(() => Math.random() - 0.5);
  Game.marketOffers = [...preserved];

  const wave = Game.wave;
  while (Game.marketOffers.length < 4 && pool.length > 0) {
    const candidate = { ...pool.pop() };
    candidate.locked = false;

    // Kademeli Tier Belirleme
    const r = Math.random();
    let offerTier = 1;
    if (wave <= 3) offerTier = 1;
    else if (wave <= 7) offerTier = (r < 0.30) ? 2 : 1;
    else if (wave <= 11) offerTier = (r < 0.15) ? 3 : (r < 0.50) ? 2 : 1;
    else offerTier = (r < 0.10) ? 4 : (r < 0.35) ? 3 : (r < 0.75) ? 2 : 1;

    candidate.tier = offerTier;
    if (candidate.category === 'weapon') {
      candidate.actualCost = Math.floor(candidate.cost * (1.0 + (offerTier - 1) * 0.75) + (wave - 1));
    } else {
      candidate.actualCost = candidate.cost + (wave - 1);
    }
    Game.marketOffers.push(candidate);
  }
  renderMarketCards();
}

function renderMarketCards() {
  const grid = document.getElementById('cards-container');
  grid.innerHTML = '';

  Game.marketOffers.forEach((item, idx) => {
    const card = document.createElement('div');
    card.className = 'card-item' + (item.locked ? ' locked' : '');
    card.id = 'card-' + idx;

    if (item.category === 'item') card.style.borderColor = '#e6a119';
    else card.style.borderColor = TIER_COLORS[item.tier];

    const sameSlot = Game.player.weapons.findIndex(w => w && w.id === item.id && w.tier === item.tier);
    const emptySlot = Game.player.weapons.findIndex(w => w === null);
    const canAfford = Game.coins >= item.actualCost;

    const lockIcon = item.locked ? (images.lock_closed ? images.lock_closed.src : '') : (images.lock_open ? images.lock_open.src : '');

    let actionBtnHtml = '';
    if (item.category === 'item') {
      // Pasif eşyalar yuva kısıtlamasından tamamen bağımsızdır!
      actionBtnHtml = '<button class="btn-buy" ' + (canAfford ? '' : 'disabled') + ' onclick="buyCardAnim(' + idx + ', \'item\', -1)">SATIN AL (' + item.actualCost + ' Coin)</button>';
    } else {
      // Silahlar için yuva kontrolleri
      if (sameSlot !== -1 && item.tier < 4) {
        actionBtnHtml = '<button class="btn-buy combine" ' + (canAfford ? '' : 'disabled') + ' onclick="buyCardAnim(' + idx + ', \'combine\', ' + sameSlot + ')">\u26A1 AL & B\u0130RLE\u015ET\u0130R (T' + item.tier + '->T' + (item.tier+1) + ') [' + item.actualCost + ' Coin]</button>';
      } else if (emptySlot !== -1) {
        actionBtnHtml = '<button class="btn-buy" ' + (canAfford ? '' : 'disabled') + ' onclick="buyCardAnim(' + idx + ', \'buy\', ' + emptySlot + ')">SATIN AL (' + item.actualCost + ' Coin)</button>';
      } else {
        actionBtnHtml = '<button class="btn-buy" disabled>YUVALAR DOLU (3/3)</button>';
      }
    }

    card.innerHTML = '<div style="font-size: 22px;">' + (item.category === 'item' ? '\u2728' : '\u2694\uFE0F') + '</div>' +
      '<div class="card-title" style="color:' + (item.category === 'item' ? '#ffd700' : TIER_COLORS[item.tier]) + ';">' + item.title + (item.category === 'weapon' ? ' [T' + item.tier + ']' : '') + '</div>' +
      '<div class="card-category" style="color:' + (item.category === 'weapon' ? '#44ff88' : '#66ccff') + ';">' + (item.category === 'weapon' ? '\u2694\uFE0F S\u0130LAH (' + item.slot_pref + ')' : '\u2728 PAS\u0130F E\u015EYA') + '</div>' +
      '<div class="card-desc">' + item.desc + '</div>' +
      actionBtnHtml +
      '<button class="btn-lock ' + (item.locked ? 'active' : '') + '" onclick="toggleLock(' + idx + ')">' +
      (lockIcon ? '<img src="' + lockIcon + '" style="width:14px; height:14px; vertical-align:middle;"> ' : (item.locked ? '\uD83D\uDD12 ' : '\uD83D\uDD13 ')) + (item.locked ? 'K\u0130L\u0130TL\u0130' : 'K\u0130L\u0130TLE') +
      '</button>';
    grid.appendChild(card);
  });
}

window.toggleLock = function(idx) {
  Game.marketOffers[idx].locked = !Game.marketOffers[idx].locked;
  renderMarketCards();
};

window.buyCardAnim = function(idx, action, slotIdx) {
  const cardEl = document.getElementById('card-' + idx);
  if (!cardEl) { executePurchase(idx, action, slotIdx); return; }

  // 1 Tek Akıcı 360° Dönüş & Parçalanma (0.64s)
  cardEl.style.transform = 'rotateY(180deg) scale(1.1)';
  cardEl.style.filter = 'brightness(2.2)';
  setTimeout(() => {
    cardEl.style.transform = 'rotateY(360deg) scale(1.3)';
    cardEl.style.opacity = '0';
    setTimeout(() => {
      executePurchase(idx, action, slotIdx);
    }, 280);
  }, 260);
};

function executePurchase(idx, action, slotIdx) {
  const item = Game.marketOffers[idx];
  if (Game.coins < item.actualCost) return;

  Game.coins -= item.actualCost;
  audio.playUpgrade();
  document.getElementById('shop-coins').textContent = Math.floor(Game.coins);

  if (item.category === 'item') {
    if (item.effects.maxHp) { Game.player.maxHp += item.effects.maxHp; Game.player.hp = Game.player.maxHp; }
    if (item.effects.speed) Game.player.speed += item.effects.speed;
    if (item.effects.attackSpeed) Game.player.attackSpeed += item.effects.attackSpeed;
    if (item.effects.critChance) Game.player.critChance += item.effects.critChance;
    if (item.effects.magnetRadius) Game.player.magnetRadius += item.effects.magnetRadius;
  } else {
    if (action === 'combine') {
      Game.player.weapons[slotIdx].tier += 1;
    } else {
      Game.player.weapons[slotIdx] = { id: item.id, title: item.title, tier: item.tier, cooldown: 0 };
    }
  }

  Game.marketOffers.splice(idx, 1);
  renderShopSlots();
  renderMarketCards();
}

document.getElementById('btn-next-wave').onclick = () => {
  document.getElementById('modal-shop').style.display = 'none';
  Game.state = 'PLAYING';
  startWave(Game.wave + 1);
};

document.getElementById('btn-reroll').onclick = () => {
  const cost = 3 + (Game.rerollCount * 2) + (Game.wave - 1) * 2;
  if (Game.coins >= cost) {
    Game.coins -= cost;
    Game.rerollCount++;
    audio.playUpgrade();
    document.getElementById('shop-coins').textContent = Math.floor(Game.coins);
    populateMarketCards();
  }
};

// Menü Butonları
document.getElementById('btn-start').onclick = startGame;
document.getElementById('btn-retry').onclick = () => {
  document.getElementById('modal-gameover').style.display = 'none';
  startGame();
};
document.getElementById('btn-victory-restart').onclick = () => {
  document.getElementById('modal-victory').style.display = 'none';
  startGame();
};
document.getElementById('btn-pause').onclick = () => {
  if (Game.state === 'PLAYING') Game.state = 'PAUSED';
  else if (Game.state === 'PAUSED') Game.state = 'PLAYING';
};

// --- ÇİZİM MOTORU (Canvas Render) ---
function render() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  ctx.save();
  const shakeX = (Math.random() * 2 - 1) * Game.camera.shake;
  const shakeY = (Math.random() * 2 - 1) * Game.camera.shake;
  ctx.translate(canvas.width / 2 - Game.camera.x + shakeX, canvas.height / 2 - Game.camera.y + shakeY);

  // 1. Zemin & Sınırlar
  if (images.tile_floor && images.tile_floor.complete) {
    const pat = ctx.createPattern(images.tile_floor, 'repeat');
    ctx.fillStyle = pat;
    ctx.fillRect(-700, -1000, 1400, 2000);
  } else {
    ctx.fillStyle = '#141824';
    ctx.fillRect(-700, -1000, 1400, 2000);
  }

  // Zindan Duvar Sınırı
  ctx.strokeStyle = '#6e4c20'; ctx.lineWidth = 18;
  ctx.strokeRect(-610, -910, 1220, 1820);

  // 2. Coinler (Altın 0.75x, Bakır 0.60x)
  Game.collectibles.forEach(c => {
    const tex = (c.type === 'copper') ? images.coin_copper : images.coin_gold;
    const sz = (c.type === 'copper') ? 14 : 20;
    if (tex && tex.complete) {
      ctx.drawImage(tex, c.x - sz/2, c.y - sz/2, sz, sz);
    } else {
      ctx.fillStyle = (c.type === 'copper') ? '#cd7f32' : '#ffd700';
      ctx.beginPath(); ctx.arc(c.x, c.y, sz/2, 0, Math.PI*2); ctx.fill();
    }
  });

  // 3. Düşmanlar
  Game.enemies.forEach(e => {
    let texKey = 'rat_small';
    if (e.type === 'dasher') texKey = 'rat_dasher';
    else if (e.type === 'spitter') texKey = 'rat_spitter';
    else if (e.type === 'tank') texKey = 'rat_tank';
    else if (e.type === 'boss') texKey = 'rat_boss';

    const tex = images[texKey];
    const sz = e.radius * 2.2;
    if (tex && tex.complete) {
      ctx.drawImage(tex, e.x - sz/2, e.y - sz/2, sz, sz);
    } else {
      ctx.fillStyle = e.isBoss ? '#ff1111' : '#bb4444';
      ctx.beginPath(); ctx.arc(e.x, e.y, e.radius, 0, Math.PI*2); ctx.fill();
    }
  });

  // 4. Oyuncu (Kara Kedi - Godot Birebir 1.6x Dengeli İri Boyut: 90px)
  const p = Game.player;
  const runKey = 'run_' + p.dir + '_' + p.animFrame;
  const idleKey = 'player_' + p.dir.replace('-', '');
  const pTex = (p.animFrame > 0 && images[runKey]) ? images[runKey] : (images[idleKey] || images.player_south);

  if (p.iframe > 0 && Math.floor(Date.now() / 80) % 2 === 0) ctx.globalAlpha = 0.5;

  const pSz = 90; // Godot 1.6x Birebir İri Görsel Boyutu
  if (pTex && pTex.complete) {
    ctx.drawImage(pTex, p.x - pSz/2, p.y - pSz/2, pSz, pSz);
  } else {
    ctx.fillStyle = '#111';
    ctx.beginPath(); ctx.arc(p.x, p.y, 32, 0, Math.PI*2); ctx.fill();
  }
  ctx.globalAlpha = 1.0;

  // 5. Mermiler
  Game.projectiles.forEach(pr => {
    if (pr.isEnemy) {
      ctx.fillStyle = '#ff7700'; ctx.shadowColor = '#ffaa00'; ctx.shadowBlur = 10;
      ctx.beginPath(); ctx.arc(pr.x, pr.y, 8, 0, Math.PI*2); ctx.fill();
      ctx.shadowBlur = 0;
    } else {
      ctx.fillStyle = '#ffd700';
      ctx.beginPath(); ctx.arc(pr.x, pr.y, 6, 0, Math.PI*2); ctx.fill();
    }
  });

  // 6. VFX (Kılıç Kesme Efekti & Şok Dalgaları)
  Game.vfx.forEach(v => {
    if (v.type === 'slash') {
      ctx.save(); ctx.translate(v.x, v.y); ctx.rotate(v.angle);
      ctx.strokeStyle = TIER_COLORS[v.tier] || '#00ff66'; ctx.lineWidth = 7;
      ctx.beginPath(); ctx.arc(0, 0, 56, -1.0, 1.0); ctx.stroke();
      ctx.restore();
    } else if (v.type === 'shockwave') {
      ctx.strokeStyle = 'rgba(255, 60, 0, 0.8)'; ctx.lineWidth = 8;
      ctx.beginPath(); ctx.arc(v.x, v.y, v.r, 0, Math.PI*2); ctx.stroke();
    }
  });

  // 7. Hasar Metinleri
  Game.floatingTexts.forEach(ft => {
    ctx.font = 'bold 16px sans-serif'; ctx.fillStyle = ft.color;
    ctx.fillText(ft.text, ft.x - 14, ft.y);
  });

  ctx.restore();
}

let lastTime = performance.now();
function loop(now) {
  const dt = Math.min(0.1, (now - lastTime) / 1000);
  lastTime = now;
  update(dt);
  render();
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
</script>
</body>
</html>
'@

$fullHtml = $htmlPart1 + $json + $htmlPart2

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$webDir\Kara_Kedi_Web_Surumu.html", $fullHtml, $utf8NoBom)
[System.IO.File]::WriteAllText("$webDir\index.html", $fullHtml, $utf8NoBom)
[System.IO.File]::WriteAllText("$projectDir\Kara_Kedi_Web_Surumu.html", $fullHtml, $utf8NoBom)

Compress-Archive -Path "$webDir\*" -DestinationPath "$projectDir\kara-kedi-web.zip" -Force
Write-Output "WEB_SURUMU_GUNCELLENDI_BASARIYLA"
