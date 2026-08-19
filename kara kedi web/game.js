// ==========================================
// KARA KEDİ: FARE İSTİLASI - WEB OYUN MOTORU
// HTML5 Canvas + Web Audio API + 15 Wave Roguelite
// ==========================================

const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// --- 1. SES MOTORU (Web Audio API DSP Synthesis) ---
class WebAudioEngine {
  constructor() {
    this.ctx = null;
  }
  init() {
    if (!this.ctx) {
      this.ctx = new (window.AudioContext || window.webkitAudioContext)();
    }
  }
  playSlash() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(650, now);
    osc.frequency.exponentialRampToValueAtTime(180, now + 0.14);
    gain.gain.setValueAtTime(0.35, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.14);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.14);
  }
  playHit() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(180, now);
    osc.frequency.exponentialRampToValueAtTime(45, now + 0.12);
    gain.gain.setValueAtTime(0.4, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.12);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.12);
  }
  playDamage() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(220, now);
    osc.frequency.exponentialRampToValueAtTime(60, now + 0.22);
    gain.gain.setValueAtTime(0.5, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.22);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.22);
  }
  playCoin() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(980, now);
    osc.frequency.setValueAtTime(1320, now + 0.06);
    gain.gain.setValueAtTime(0.25, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.18);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.18);
  }
  playMagnum() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(140, now);
    osc.frequency.exponentialRampToValueAtTime(30, now + 0.28);
    gain.gain.setValueAtTime(0.6, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.28);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.28);
  }
  playGlock() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'square';
    osc.frequency.setValueAtTime(280, now);
    osc.frequency.exponentialRampToValueAtTime(80, now + 0.09);
    gain.gain.setValueAtTime(0.3, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.09);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.09);
  }
  playBow() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(360, now);
    osc.frequency.exponentialRampToValueAtTime(140, now + 0.15);
    gain.gain.setValueAtTime(0.3, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.15);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.15);
  }
  playWaveHorn() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(130, now);
    osc.frequency.setValueAtTime(195, now + 0.2);
    gain.gain.setValueAtTime(0.4, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.6);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.6);
  }
  playBossRoar() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.linearRampToValueAtTime(55, now + 0.8);
    gain.gain.setValueAtTime(0.6, now);
    gain.gain.linearRampToValueAtTime(0.01, now + 0.8);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.8);
  }
  playUpgrade() {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [440, 554, 659, 880].forEach((freq, idx) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + idx * 0.06);
      gain.gain.setValueAtTime(0.2, now + idx * 0.06);
      gain.gain.linearRampToValueAtTime(0.01, now + idx * 0.06 + 0.15);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now + idx * 0.06);
      osc.stop(now + idx * 0.06 + 0.15);
    });
  }
}
const audio = new WebAudioEngine();

// --- 2. DOKU YÜKLEYİCİ (Image Assets Loader) ---
const images = {};
function loadImage(key, path) {
  const img = new Image();
  img.src = path;
  images[key] = img;
}

// Temel görseller
loadImage('player_south', 'assets/textures/player_character/rotations/south.png');
loadImage('player_north', 'assets/textures/player_character/rotations/north.png');
loadImage('player_east', 'assets/textures/player_character/rotations/east.png');
loadImage('player_west', 'assets/textures/player_character/rotations/west.png');
loadImage('player_se', 'assets/textures/player_character/rotations/south-east.png');
loadImage('player_sw', 'assets/textures/player_character/rotations/south-west.png');
loadImage('player_ne', 'assets/textures/player_character/rotations/north-east.png');
loadImage('player_nw', 'assets/textures/player_character/rotations/north-west.png');

// Koşu kareleri
const RUN_DIRS = ['south', 'north', 'east', 'west', 'south-east', 'north-east', 'north-west'];
RUN_DIRS.forEach(dir => {
  for (let f = 0; f < 8; f++) {
    const fn = `frame_00${f}.png`;
    loadImage(`run_${dir}_${f}`, `assets/textures/player_character/animations/Running/${dir}/${fn}`);
  }
});

loadImage('tile_floor', 'assets/textures/tile_floor.png');
loadImage('tile_wall', 'assets/textures/tile_wall.png');
loadImage('rat_small', 'assets/textures/rat_small.png');
loadImage('rat_dasher', 'assets/textures/rat_dasher.png');
loadImage('rat_spitter', 'assets/textures/rat_spitter.png');
loadImage('rat_tank', 'assets/textures/rat_tank.png');
loadImage('rat_boss', 'assets/textures/rat_boss.png');
loadImage('spit_acid', 'assets/textures/projectile_acid.png');
loadImage('coin_gold', 'assets/textures/coin_gold.png');
loadImage('coin_copper', 'assets/textures/coin_copper.png');

loadImage('item_sword', 'assets/textures/sword.png');
loadImage('item_claws', 'assets/textures/claws.png');
loadImage('item_fish', 'assets/textures/fish_bone.png');
loadImage('item_yarn', 'assets/textures/yarn_bomb.png');
loadImage('item_magnum', 'assets/textures/items/weapon_magnum.png');
loadImage('item_glock', 'assets/textures/items/weapon_glock.png');
loadImage('item_bow', 'assets/textures/items/weapon_bow.png');
loadImage('bullet_magnum', 'assets/textures/bullet_magnum.png');
loadImage('bullet_glock', 'assets/textures/bullet_glock.png');
loadImage('bullet_arrow', 'assets/textures/arrow.png');

loadImage('lock_closed', 'assets/textures/ui/lock_closed.png');
loadImage('lock_open', 'assets/textures/ui/lock_open.png');

// --- 3. OYUN DEĞİŞKENLERİ & VERİ TABANI ---
const TIER_COLORS = {
  1: '#00ff66',
  2: '#00d2ff',
  3: '#b844ff',
  4: '#ff2255'
};

const WEAPONS_DB = [
  { id: 'sword', title: '🗡️ Kara Çelik Kılıç', tier: 1, cost: 10, desc: '120° yay kesişi ve yüksek geri tepme.\nHasar: 32 | Hız: 1.0s', icon: 'item_sword' },
  { id: 'claws', title: '🐾 Çift Pençe', tier: 1, cost: 9, desc: 'Seri yakın saldırı, +%25 kritik şansı.\nHasar: 16 | Hız: 0.45s', icon: 'item_claws' },
  { id: 'fish_boomerang', title: '🐟 Kılçık Bumerangı', tier: 1, cost: 10, desc: 'Gidip gelen delici kemik.\nHasar: 22 | Menzil: 340px', icon: 'item_fish' },
  { id: 'yarn_bomb', title: '🧶 İp Yumağı Bombası', tier: 1, cost: 11, desc: 'Geniş patlayıcı alan hasarı.\nHasar: 38 (Alan) | Menzil: 450px', icon: 'item_yarn' },
  { id: 'magnum', title: '💥 Ağır Magnum', tier: 1, cost: 12, desc: 'Yüksek hasar ve ağır geri tepmeli mermi.\nHasar: 45 | Hız: 1.1s', icon: 'item_magnum' },
  { id: 'glock', title: '⚡ Seri Glock', tier: 1, cost: 10, desc: 'Saniyede 4.5 seri kurşun yağmuru.\nHasar: 10 | Hız: 0.22s', icon: 'item_glock' },
  { id: 'bow', title: '🏹 Avcı Yayı', tier: 1, cost: 11, desc: 'Düşmanları delip geçen keskin oklar.\nHasar: 24 (Delme 2) | Hız: 0.48s', icon: 'item_bow' }
];

const ITEMS_DB = [
  { id: 'fish_soup', title: '🥣 Şifalı Balık Çorbası', cost: 7, desc: '+30 Maksimum Can, Canı yeniler.', effects: { maxHp: 30, heal: true }, icon: 'assets/textures/items/item_fish_soup.png' },
  { id: 'catnip_potion', title: '🌿 Kudurtucu Kedi Nanesi', cost: 8, desc: '+%25 Saldırı Hızı, +%10 Hasar.', effects: { attackSpeed: 0.25, dmgMult: 0.1 }, icon: 'assets/textures/items/item_catnip_potion.png' },
  { id: 'golden_bell', title: '🔔 Şanslı Çıngırak', cost: 8, desc: '+%18 Kritik Şansı, +%35 Kritik Hasarı.', effects: { critChance: 0.18, critMult: 0.35 }, icon: 'assets/textures/items/item_golden_bell.png' },
  { id: 'puma_boots', title: '👟 Puma Adımları', cost: 8, desc: '+45 Hareket Hızı, +%10 Kritik.', effects: { speed: 45, critChance: 0.1 }, icon: 'assets/textures/items/item_puma_boots.png' },
  { id: 'gold_magnet', title: '🧲 Altın Mıknatıs', cost: 7, desc: '+75 Coin Çekim Alanı, +15 Hız.', effects: { magnetRadius: 75, speed: 15 }, icon: 'assets/textures/items/item_gold_magnet.png' }
];

// Oyun Durumu
const Game = {
  state: 'MENU', // MENU, PLAYING, SHOP, GAMEOVER, VICTORY, PAUSED
  wave: 1,
  maxWaves: 15,
  waveTime: 25,
  coins: 0,
  score: 0,
  kills: 0,
  rerollCount: 0,
  marketOffers: [],
  
  // Oyuncu
  player: {
    x: 0,
    y: 0,
    hp: 100,
    maxHp: 100,
    speed: 220,
    dmgMult: 1.0,
    attackSpeed: 1.0,
    critChance: 0.08,
    critMult: 2.0,
    magnetRadius: 140,
    iframe: 0,
    dir: 'south',
    animFrame: 0,
    animTimer: 0,
    weapons: [
      { id: 'sword', title: '🗡️ Kara Çelik Kılıç', tier: 1, cooldown: 0 },
      null,
      null
    ]
  },

  // Sahne Nesneleri
  enemies: [],
  projectiles: [],
  collectibles: [],
  vfx: [],
  floatingTexts: [],
  
  camera: { x: 0, y: 0, shake: 0 },
  keys: {},
  joystick: { active: false, x: 0, y: 0 }
};

// --- 4. GİRDİLER (Controls) ---
window.addEventListener('keydown', e => {
  Game.keys[e.key.toLowerCase()] = true;
});
window.addEventListener('keyup', e => {
  Game.keys[e.key.toLowerCase()] = false;
});

// Mobile Joystick
const joyZone = document.getElementById('joystick-zone');
const joyKnob = document.getElementById('joystick-knob');
if ('ontouchstart' in window) {
  joyZone.style.display = 'block';
  let startX = 0, startY = 0;
  joyZone.addEventListener('touchstart', e => {
    e.preventDefault();
    const touch = e.touches[0];
    const rect = joyZone.getBoundingClientRect();
    startX = rect.left + rect.width / 2;
    startY = rect.top + rect.height / 2;
    Game.joystick.active = true;
  });
  joyZone.addEventListener('touchmove', e => {
    e.preventDefault();
    if (!Game.joystick.active) return;
    const touch = e.touches[0];
    let dx = touch.clientX - startX;
    let dy = touch.clientY - startY;
    const dist = Math.hypot(dx, dy);
    const maxR = 40;
    if (dist > maxR) {
      dx = (dx / dist) * maxR;
      dy = (dy / dist) * maxR;
    }
    joyKnob.style.transform = `translate(${dx}px, ${dy}px)`;
    Game.joystick.x = dx / maxR;
    Game.joystick.y = dy / maxR;
  });
  const resetJoy = () => {
    Game.joystick.active = false;
    Game.joystick.x = 0;
    Game.joystick.y = 0;
    joyKnob.style.transform = `translate(0px, 0px)`;
  };
  joyZone.addEventListener('touchend', resetJoy);
  joyZone.addEventListener('touchcancel', resetJoy);
}

// --- 5. OYUN DÖNGÜSÜ & MANTIK ---
function startGame() {
  audio.init();
  audio.playWaveHorn();
  Game.state = 'PLAYING';
  Game.wave = 1;
  Game.coins = 0;
  Game.score = 0;
  Game.kills = 0;
  Game.player.hp = 100;
  Game.player.maxHp = 100;
  Game.player.x = 0;
  Game.player.y = 0;
  Game.player.weapons = [
    { id: 'sword', title: '🗡️ Kara Çelik Kılıç', tier: 1, cooldown: 0 },
    null,
    null
  ];
  startWave(1);
  document.querySelectorAll('.modal-overlay').forEach(el => el.style.display = 'none');
}

function startWave(num) {
  Game.wave = num;
  Game.waveTime = (num === 5 || num === 10 || num === 15) ? 38 : (22 + (num - 1) * 2);
  Game.enemies = [];
  Game.projectiles = [];
  Game.collectibles = [];
  Game.vfx = [];
  Game.bossSpawned = false;
  document.getElementById('hud-wave').textContent = num;
  document.getElementById('boss-bar-container').style.display = 'none';
  audio.playWaveHorn();
}

function update(dt) {
  if (Game.state !== 'PLAYING') return;

  // 1. Oyuncu Hareketi
  let moveX = 0, moveY = 0;
  if (Game.keys['w'] || Game.keys['arrowup']) moveY -= 1;
  if (Game.keys['s'] || Game.keys['arrowdown']) moveY += 1;
  if (Game.keys['a'] || Game.keys['arrowleft']) moveX -= 1;
  if (Game.keys['d'] || Game.keys['arrowright']) moveX += 1;

  if (Game.joystick.active) {
    moveX = Game.joystick.x;
    moveY = Game.joystick.y;
  }

  const moveLen = Math.hypot(moveX, moveY);
  if (moveLen > 0.1) {
    moveX /= moveLen;
    moveY /= moveLen;
    Game.player.x += moveX * Game.player.speed * dt;
    Game.player.y += moveY * Game.player.speed * dt;

    // Arena Sınırları (-620..620, -950..950)
    Game.player.x = Math.max(-620, Math.min(620, Game.player.x));
    Game.player.y = Math.max(-950, Math.min(950, Game.player.y));

    // Yön tespiti
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
    if (Game.player.animTimer >= 0.085) {
      Game.player.animTimer = 0;
      Game.player.animFrame = (Game.player.animFrame + 1) % 8;
    }
  } else {
    Game.player.animFrame = 0;
  }

  // Kamera Takibi & Sarsıntı
  Game.camera.x = Game.player.x;
  Game.camera.y = Game.player.y;
  if (Game.camera.shake > 0) Game.camera.shake = Math.max(0, Game.camera.shake - 35 * dt);

  // i-frame
  if (Game.player.iframe > 0) Game.player.iframe -= dt;

  // 2. Dalga Sayacı & Düşman Doğuşu
  Game.waveTime -= dt;
  const isBossWave = (Game.wave === 5 || Game.wave === 10 || Game.wave === 15);
  
  if (isBossWave && !Game.bossSpawned && Game.waveTime <= 35) {
    spawnBoss();
  }

  // Dalga Sonu Kontrolü (Boss varsa ölene kadar kilitlenir!)
  const bossAlive = Game.enemies.some(e => e.isBoss && e.hp > 0);
  if (Game.waveTime <= 0) {
    if (!bossAlive) {
      endWave();
      return;
    }
    document.getElementById('hud-timer').textContent = '⚔️ BOSS SAVAŞI';
  } else {
    const mins = Math.floor(Game.waveTime / 60);
    const secs = Math.floor(Game.waveTime % 60);
    document.getElementById('hud-timer').textContent = `⏱️ ${String(mins).padStart(2,'0')}:${String(secs).padStart(2,'0')}`;
  }

  // Normal Düşman Doğuşu
  if (Math.random() < (0.02 + Game.wave * 0.003)) {
    spawnEnemy();
  }

  // 3. Silah Saldırıları
  updateWeapons(dt);

  // 4. Düşman Güncellemeleri
  for (let i = Game.enemies.length - 1; i >= 0; i--) {
    const e = Game.enemies[i];
    const dx = Game.player.x - e.x;
    const dy = Game.player.y - e.y;
    const dist = Math.hypot(dx, dy);

    // Hareket
    if (dist > 10) {
      e.x += (dx / dist) * e.speed * dt;
      e.y += (dy / dist) * e.speed * dt;
    }

    // Tüküren Fare Atışı (Menzil 380px)
    if (e.type === 'spitter') {
      e.shootTimer = (e.shootTimer || 2.4) - dt;
      if (e.shootTimer <= 0) {
        if (dist <= 380) {
          Game.projectiles.push({
            x: e.x,
            y: e.y,
            vx: (dx / dist) * 260,
            vy: (dy / dist) * 260,
            damage: e.damage,
            isEnemy: true,
            life: 3.5
          });
        }
        e.shootTimer = 2.4;
      }
    }

    // Boss Özel Saldırıları
    if (e.isBoss) {
      e.attackTimer = (e.attackTimer || 3.5) - dt;
      if (e.attackTimer <= 0) {
        // Şok Dalgası
        audio.playBossRoar();
        Game.vfx.push({ type: 'shockwave', x: e.x, y: e.y, r: 10, maxR: 180, life: 0.5, damage: e.damage });
        Game.camera.shake = 12;
        e.attackTimer = (e.hp < e.maxHp * 0.5) ? 2.0 : 3.5;
      }
      document.getElementById('boss-hp-fill').style.width = `${Math.max(0, (e.hp / e.maxHp) * 100)}%`;
    }

    // Temas Hasarı
    if (dist < (e.radius + 20) && Game.player.iframe <= 0) {
      damagePlayer(e.damage);
    }
  }

  // 5. Mermiler
  for (let i = Game.projectiles.length - 1; i >= 0; i--) {
    const p = Game.projectiles[i];
    p.x += p.vx * dt;
    p.y += p.vy * dt;
    p.life -= dt;

    if (p.isEnemy) {
      if (Math.hypot(p.x - Game.player.x, p.y - Game.player.y) < 24 && Game.player.iframe <= 0) {
        damagePlayer(p.damage);
        Game.projectiles.splice(i, 1);
        continue;
      }
    } else {
      // Oyuncu Mermisi Düşman Vuruşu
      for (const e of Game.enemies) {
        if (Math.hypot(p.x - e.x, p.y - e.y) < (e.radius + 14)) {
          damageEnemy(e, p.damage);
          if (p.pierce) {
            p.pierce--;
            if (p.pierce <= 0) { Game.projectiles.splice(i, 1); break; }
          } else {
            Game.projectiles.splice(i, 1);
            break;
          }
        }
      }
    }

    if (p.life <= 0) Game.projectiles.splice(i, 1);
  }

  // 6. Coinler & Mıknatıs
  for (let i = Game.collectibles.length - 1; i >= 0; i--) {
    const c = Game.collectibles[i];
    const dx = Game.player.x - c.x;
    const dy = Game.player.y - c.y;
    const dist = Math.hypot(dx, dy);

    if (dist < Game.player.magnetRadius) {
      c.x += (dx / dist) * 450 * dt;
      c.y += (dy / dist) * 450 * dt;
      if (dist < 26) {
        Game.coins += c.val;
        Game.score += Math.floor(c.val * 50);
        audio.playCoin();
        document.getElementById('hud-coins').textContent = Math.floor(Game.coins);
        Game.collectibles.splice(i, 1);
      }
    }
  }

  // 7. VFX & Metinler
  for (let i = Game.vfx.length - 1; i >= 0; i--) {
    const v = Game.vfx[i];
    v.life -= dt;
    if (v.type === 'shockwave') {
      v.r += (v.maxR / 0.5) * dt;
      if (Math.hypot(v.x - Game.player.x, v.y - Game.player.y) < v.r && Game.player.iframe <= 0) {
        damagePlayer(v.damage);
      }
    }
    if (v.life <= 0) Game.vfx.splice(i, 1);
  }

  for (let i = Game.floatingTexts.length - 1; i >= 0; i--) {
    const ft = Game.floatingTexts[i];
    ft.y -= 30 * dt;
    ft.life -= dt;
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

      const dx = target.x - Game.player.x;
      const dy = target.y - Game.player.y;
      const dist = Math.hypot(dx, dy);
      const tierMult = 1.0 + (w.tier - 1) * 0.4;

      if (w.id === 'sword' && dist <= 160) {
        w.cooldown = 0.55 / Game.player.attackSpeed;
        audio.playSlash();
        damageEnemy(target, 32 * tierMult * Game.player.dmgMult);
        Game.vfx.push({ type: 'slash', x: Game.player.x + (dx/dist)*35, y: Game.player.y + (dy/dist)*35, angle: Math.atan2(dy, dx), tier: w.tier, life: 0.16 });
      } else if (w.id === 'claws' && dist <= 140) {
        w.cooldown = 0.25 / Game.player.attackSpeed;
        audio.playSlash();
        damageEnemy(target, 16 * tierMult * Game.player.dmgMult);
      } else if (w.id === 'magnum' && dist <= 550) {
        w.cooldown = 1.1 / Game.player.attackSpeed;
        audio.playMagnum();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*780, vy: (dy/dist)*780, damage: 45 * tierMult, isEnemy: false, life: 1.2 });
      } else if (w.id === 'glock' && dist <= 500) {
        w.cooldown = 0.22 / Game.player.attackSpeed;
        audio.playGlock();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*850, vy: (dy/dist)*850, damage: 10 * tierMult, isEnemy: false, life: 1.0 });
      } else if (w.id === 'bow' && dist <= 520) {
        w.cooldown = 0.48 / Game.player.attackSpeed;
        audio.playBow();
        Game.projectiles.push({ x: Game.player.x, y: Game.player.y, vx: (dx/dist)*720, vy: (dy/dist)*720, damage: 24 * tierMult, pierce: 2, isEnemy: false, life: 1.4 });
      }
    }
  });
}

function findClosestEnemy() {
  let closest = null;
  let minDist = Infinity;
  for (const e of Game.enemies) {
    const d = Math.hypot(e.x - Game.player.x, e.y - Game.player.y);
    if (d < minDist) { minDist = d; closest = e; }
  }
  return closest;
}

function damagePlayer(dmg) {
  Game.player.hp -= dmg;
  Game.player.iframe = 0.45;
  audio.playDamage();
  Game.camera.shake = 8;
  document.getElementById('hud-hp-fill').style.width = `${Math.max(0, (Game.player.hp / Game.player.maxHp) * 100)}%`;

  if (Game.player.hp <= 0) {
    Game.state = 'GAMEOVER';
    document.getElementById('gameover-stats').innerHTML = `Ulaşılan Dalga: <b>${Game.wave}</b><br>Öldürülen Fare: <b>${Game.kills}</b><br>Toplanan Coin: <b>${Math.floor(Game.coins)}</b><br>Toplam Puan: <b>${Game.score}</b>`;
    document.getElementById('gameover-overlay').style.display = 'flex';
  }
}

function damageEnemy(e, dmg) {
  const isCrit = Math.random() < Game.player.critChance;
  const finalDmg = isCrit ? dmg * Game.player.critMult : dmg;
  e.hp -= finalDmg;
  audio.playHit();

  Game.floatingTexts.push({
    x: e.x,
    y: e.y - 10,
    text: (isCrit ? 'CRIT! ' : '') + Math.floor(finalDmg),
    color: isCrit ? '#ffd700' : '#ffffff',
    life: 0.6
  });

  if (e.hp <= 0) {
    // Düşman Ölümü
    Game.kills++;
    Game.score += e.isBoss ? 5000 : 100;
    
    // 1. Ana Altın Coin (Gold Coin, 0.75x)
    Game.collectibles.push({ x: e.x, y: e.y, val: e.baseCoin, type: 'gold' });
    // 2. Ek Bakır Coin (Copper Coin, 0.60x)
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

  let hp = 20, speed = 140, dmg = 10, radius = 14, baseCoin = 1;
  if (t === 'dasher') { hp = 28; speed = 180; dmg = 14; radius = 16; baseCoin = 2; }
  else if (t === 'spitter') { hp = 32; speed = 110; dmg = 12; radius = 16; baseCoin = 2; }
  else if (t === 'tank') { hp = 85; speed = 75; dmg = 20; radius = 24; baseCoin = 4; }

  Game.enemies.push({ x, y, hp, maxHp: hp, speed, damage: dmg, radius, type: t, baseCoin, isBoss: false });
}

function spawnBoss() {
  Game.bossSpawned = true;
  audio.playBossRoar();
  let hp = 850, dmg = 22, title = '👑 FARE KRALI (Mini-Boss)';
  if (Game.wave === 10) { hp = 1800; dmg = 32; title = '👑 BÜYÜK FARE KRALI'; }
  else if (Game.wave === 15) { hp = 6000; dmg = 44; title = '💀 FARE İMPARATORU (MEGA-BOSS)'; }

  document.getElementById('boss-title').textContent = title;
  document.getElementById('boss-bar-container').style.display = 'flex';
  document.getElementById('boss-hp-fill').style.width = '100%';

  Game.enemies.push({
    x: 0,
    y: -700,
    hp,
    maxHp: hp,
    speed: (Game.wave === 15) ? 135 : 100,
    damage: dmg,
    radius: 36,
    type: 'boss',
    baseCoin: 16,
    isBoss: true
  });
}

function endWave() {
  // Temizlik: Yerdeki koinler ve mermiler yeni wave'e sarkmaz!
  Game.collectibles = [];
  Game.projectiles = [];
  Game.enemies = [];

  if (Game.wave >= 15) {
    Game.state = 'VICTORY';
    document.getElementById('victory-stats').innerHTML = `Öldürülen Fare: <b>${Game.kills}</b><br>Kazanılan Coin: <b>${Math.floor(Game.coins)}</b><br>Toplam Skor: <b>${Game.score}</b>`;
    document.getElementById('victory-overlay').style.display = 'flex';
    return;
  }

  Game.state = 'SHOP';
  openShop();
}

// --- 6. MARKET (Shop Screen) ---
function openShop() {
  document.getElementById('shop-coins-val').textContent = Math.floor(Game.coins);
  document.getElementById('shop-overlay').style.display = 'flex';
  renderShopSlots();
  populateMarketCards();
}

function renderShopSlots() {
  const container = document.getElementById('shop-weapon-slots');
  container.innerHTML = '';
  const slotNames = ['Sağ El (1)', 'Sol El (2)', 'Kuyruk (3)'];

  Game.player.weapons.forEach((w, idx) => {
    const el = document.createElement('div');
    el.className = 'slot-item';
    if (w) {
      el.style.borderColor = TIER_COLORS[w.tier];
      el.innerHTML = `
        <span style="color:${TIER_COLORS[w.tier]}; font-weight:bold;">${w.title} [T${w.tier}]</span>
        <button onclick="sellWeapon(${idx})" style="background:#442; color:#ffdd44; border:none; padding:2px 4px; border-radius:4px; font-size:10px; cursor:pointer;">Sat (+${Math.floor(w.tier * 6)})</button>
      `;
    } else {
      el.innerHTML = `<span style="color:#778;">${slotNames[idx]}:<br>[BOŞ YUVA]</span>`;
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
  document.getElementById('shop-coins-val').textContent = Math.floor(Game.coins);
  renderShopSlots();
  renderMarketCards();
};

function populateMarketCards() {
  Game.marketOffers = [];
  const pool = [...WEAPONS_DB, ...ITEMS_DB].sort(() => Math.random() - 0.5);

  for (let i = 0; i < 4; i++) {
    const item = { ...pool[i] };
    item.locked = false;
    
    // Tier Dağılımı
    let tier = 1;
    const r = Math.random();
    if (Game.wave >= 12) { tier = (r < 0.1) ? 4 : (r < 0.35) ? 3 : (r < 0.75) ? 2 : 1; }
    else if (Game.wave >= 8) { tier = (r < 0.15) ? 3 : (r < 0.5) ? 2 : 1; }
    else if (Game.wave >= 4) { tier = (r < 0.3) ? 2 : 1; }

    item.tier = tier;
    item.actualCost = item.cost + Math.floor((tier - 1) * 6) + (Game.wave - 1);
    Game.marketOffers.push(item);
  }
  renderMarketCards();
}

function renderMarketCards() {
  const grid = document.getElementById('shop-cards-grid');
  grid.innerHTML = '';

  Game.marketOffers.forEach((item, idx) => {
    const card = document.createElement('div');
    card.className = `shop-card ${item.locked ? 'locked' : ''}`;
    if (item.effects) card.style.borderColor = '#e6a119';
    else card.style.borderColor = TIER_COLORS[item.tier];

    // Birleştirme kontrolü
    const sameSlot = Game.player.weapons.findIndex(w => w && w.id === item.id && w.tier === item.tier);
    const emptySlot = Game.player.weapons.findIndex(w => w === null);
    const canAfford = Game.coins >= item.actualCost;

    card.innerHTML = `
      <div style="font-size: 24px;">${item.effects ? '✨' : '⚔️'}</div>
      <div class="card-title" style="color:${item.effects ? '#ffd700' : TIER_COLORS[item.tier]};">${item.title} ${item.effects ? '' : `[T${item.tier}]`}</div>
      <div class="card-desc">${item.desc}</div>
      ${
        sameSlot !== -1 && item.tier < 4 ?
        `<button class="card-btn combine" ${canAfford ? '' : 'disabled'} onclick="buyCard(${idx}, 'combine', ${sameSlot})">⚡ BİRLEŞTİR (T${item.tier}->T${item.tier+1}) [${item.actualCost} Coin]</button>` :
        emptySlot !== -1 ?
        `<button class="card-btn" ${canAfford ? '' : 'disabled'} onclick="buyCard(${idx}, 'buy', ${emptySlot})">SATIN AL (${item.actualCost} Coin)</button>` :
        `<button class="card-btn" disabled>YUVALAR DOLU</button>`
      }
      <button class="card-lock-btn ${item.locked ? 'active' : ''}" onclick="toggleLock(${idx})">
        ${item.locked ? '🔒 KİLİTLİ' : '🔓 KİLİTLE'}
      </button>
    `;
    grid.appendChild(card);
  });
}

window.toggleLock = function(idx) {
  Game.marketOffers[idx].locked = !Game.marketOffers[idx].locked;
  renderMarketCards();
};

window.buyCard = function(idx, action, slotIdx) {
  const item = Game.marketOffers[idx];
  if (Game.coins < item.actualCost) return;

  Game.coins -= item.actualCost;
  audio.playUpgrade();
  document.getElementById('shop-coins-val').textContent = Math.floor(Game.coins);

  if (item.effects) {
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
};

document.getElementById('btn-next-wave').onclick = () => {
  document.getElementById('shop-overlay').style.display = 'none';
  Game.state = 'PLAYING';
  startWave(Game.wave + 1);
};

document.getElementById('btn-reroll').onclick = () => {
  if (Game.coins >= 3) {
    Game.coins -= 3;
    audio.playUpgrade();
    document.getElementById('shop-coins-val').textContent = Math.floor(Game.coins);
    populateMarketCards();
  }
};

// Menü ve Buton Dinleyicileri
document.getElementById('btn-start-game').onclick = startGame;
document.getElementById('btn-retry').onclick = startGame;
document.getElementById('btn-victory-restart').onclick = startGame;
document.getElementById('btn-pause').onclick = () => {
  if (Game.state === 'PLAYING') Game.state = 'PAUSED';
  else if (Game.state === 'PAUSED') Game.state = 'PLAYING';
};

// --- 7. RENDER (Çizim Motoru) ---
function render() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  ctx.save();
  // Kamera dönüşümü
  const shakeX = (Math.random() * 2 - 1) * Game.camera.shake;
  const shakeY = (Math.random() * 2 - 1) * Game.camera.shake;
  ctx.translate(canvas.width / 2 - Game.camera.x + shakeX, canvas.height / 2 - Game.camera.y + shakeY);

  // 1. Zemin & Duvarlar
  const floorPattern = ctx.createPattern(images.tile_floor || new Image(), 'repeat');
  if (floorPattern) {
    ctx.fillStyle = floorPattern;
    ctx.fillRect(-700, -1000, 1400, 2000);
  } else {
    ctx.fillStyle = '#161922';
    ctx.fillRect(-700, -1000, 1400, 2000);
  }

  // Sınır Çerçevesi
  ctx.strokeStyle = '#855e24';
  ctx.lineWidth = 16;
  ctx.strokeRect(-630, -960, 1260, 1920);

  // 2. Coinler
  Game.collectibles.forEach(c => {
    const tex = (c.type === 'copper') ? images.coin_copper : images.coin_gold;
    const sz = (c.type === 'copper') ? 14 : 20;
    if (tex && tex.complete) {
      ctx.drawImage(tex, c.x - sz/2, c.y - sz/2, sz, sz);
    } else {
      ctx.fillStyle = (c.type === 'copper') ? '#cd7f32' : '#ffd700';
      ctx.beginPath();
      ctx.arc(c.x, c.y, sz/2, 0, Math.PI*2);
      ctx.fill();
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
      ctx.beginPath();
      ctx.arc(e.x, e.y, e.radius, 0, Math.PI*2);
      ctx.fill();
    }
  });

  // 4. Oyuncu (Kara Kedi - 1.6x Dengeli Ölçek)
  const p = Game.player;
  const runKey = `run_${p.dir}_${p.animFrame}`;
  const idleKey = `player_${p.dir.replace('-', '')}`;
  const pTex = (p.animFrame > 0 && images[runKey]) ? images[runKey] : (images[idleKey] || images.player_south);

  if (p.iframe > 0 && Math.floor(Date.now() / 80) % 2 === 0) {
    ctx.globalAlpha = 0.5;
  }

  const pSz = 54; // 1.6x Dengeli Boyut
  if (pTex && pTex.complete) {
    ctx.drawImage(pTex, p.x - pSz/2, p.y - pSz/2, pSz, pSz);
  } else {
    ctx.fillStyle = '#111';
    ctx.beginPath();
    ctx.arc(p.x, p.y, 22, 0, Math.PI*2);
    ctx.fill();
  }
  ctx.globalAlpha = 1.0;

  // 5. Mermiler
  Game.projectiles.forEach(pr => {
    if (pr.isEnemy) {
      // Turuncu Tükürük Mermisi
      ctx.fillStyle = '#ff7700';
      ctx.shadowColor = '#ffaa00';
      ctx.shadowBlur = 10;
      ctx.beginPath();
      ctx.arc(pr.x, pr.y, 9, 0, Math.PI*2);
      ctx.fill();
      ctx.shadowBlur = 0;
    } else {
      ctx.fillStyle = '#ffd700';
      ctx.beginPath();
      ctx.arc(pr.x, pr.y, 6, 0, Math.PI*2);
      ctx.fill();
    }
  });

  // 6. VFX (Kılıç Hilal Kesme Dalgası & Şok Dalgaları)
  Game.vfx.forEach(v => {
    if (v.type === 'slash') {
      ctx.save();
      ctx.translate(v.x, v.y);
      ctx.rotate(v.angle);
      ctx.strokeStyle = TIER_COLORS[v.tier] || '#00ff66';
      ctx.lineWidth = 6;
      ctx.beginPath();
      ctx.arc(0, 0, 48, -1.0, 1.0);
      ctx.stroke();
      ctx.restore();
    } else if (v.type === 'shockwave') {
      ctx.strokeStyle = 'rgba(255, 60, 0, 0.8)';
      ctx.lineWidth = 8;
      ctx.beginPath();
      ctx.arc(v.x, v.y, v.r, 0, Math.PI*2);
      ctx.stroke();
    }
  });

  // 7. Uçuşan Sayılar
  Game.floatingTexts.forEach(ft => {
    ctx.font = 'bold 16px sans-serif';
    ctx.fillStyle = ft.color;
    ctx.fillText(ft.text, ft.x - 15, ft.y);
  });

  ctx.restore();
}

// --- 8. ANA DÖNGÜ (Main Loop) ---
let lastTime = performance.now();
function loop(now) {
  const dt = Math.min(0.1, (now - lastTime) / 1000);
  lastTime = now;

  update(dt);
  render();

  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
