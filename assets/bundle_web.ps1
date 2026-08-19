$json = [System.IO.File]::ReadAllText("d:\benim antigravitiler\kara kedi\web\embedded_assets.json", [System.Text.Encoding]::UTF8)

$htmlHeader = @"
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Kara Kedi: Fare İstilası (Web Sürümü)</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; -webkit-user-select: none; }
    body { background-color: #08090d; color: #e0e0e0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; overflow: hidden; display: flex; justify-content: center; align-items: center; height: 100vh; width: 100vw; }
    #game-container { position: relative; width: 100%; height: 100%; max-width: 500px; max-height: 900px; aspect-ratio: 9 / 16; background: #000; box-shadow: 0 0 50px rgba(0,0,0,0.9), 0 0 20px rgba(255, 215, 0, 0.2); border-radius: 14px; overflow: hidden; border: 2px solid #2a3547; }
    canvas { width: 100%; height: 100%; display: block; image-rendering: pixelated; }
    .ui-layer { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; display: flex; flex-direction: column; }
    .interactive { pointer-events: auto; }
    #hud { display: flex; flex-direction: column; padding: 12px; gap: 8px; }
    .hud-top { display: flex; justify-content: space-between; align-items: center; }
    .hud-card { background: rgba(16, 20, 30, 0.88); backdrop-filter: blur(4px); border: 1px solid rgba(255, 215, 0, 0.35); padding: 6px 12px; border-radius: 8px; font-weight: bold; font-size: 14px; }
    .hp-bar-bg { width: 130px; height: 14px; background: rgba(40, 10, 10, 0.8); border: 1px solid #ff4444; border-radius: 7px; overflow: hidden; }
    .hp-bar-fill { height: 100%; background: linear-gradient(90deg, #ff2222, #ff6644); width: 100%; transition: width 0.15s ease; }
    #boss-bar-container { display: none; flex-direction: column; align-items: center; gap: 4px; }
    .boss-bar-bg { width: 85%; height: 16px; background: rgba(20, 0, 0, 0.9); border: 2px solid #ffaa00; border-radius: 8px; overflow: hidden; }
    .boss-bar-fill { height: 100%; background: linear-gradient(90deg, #ff0000, #ff8800); width: 100%; transition: width 0.1s linear; }
    .modal-overlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: rgba(4, 6, 12, 0.94); backdrop-filter: blur(8px); display: none; flex-direction: column; justify-content: center; align-items: center; padding: 16px; z-index: 100; }
    .modal-box { background: #10121a; border: 2px solid #f5be23; border-radius: 16px; width: 95%; max-width: 440px; padding: 22px; display: flex; flex-direction: column; align-items: center; gap: 14px; box-shadow: 0 0 35px rgba(245, 190, 35, 0.25); }
    .btn-gold { background: #f5be23; color: #1a1205; font-weight: bold; font-size: 18px; padding: 12px 28px; border: none; border-radius: 12px; cursor: pointer; transition: all 0.15s ease; }
    .btn-gold:hover { background: #c01010; color: #ffffff; transform: scale(1.05); box-shadow: 0 0 20px rgba(192, 16, 16, 0.8); }
    .shop-container { background: #0f1118; border: 2px solid #f5be23; border-radius: 16px; width: 98%; max-height: 94%; padding: 14px; display: flex; flex-direction: column; gap: 10px; overflow-y: auto; }
    .shop-slots-panel { display: flex; justify-content: space-between; gap: 6px; }
    .slot-item { flex: 1; background: #171a24; border: 2px solid #334; border-radius: 8px; padding: 6px; font-size: 11px; text-align: center; display: flex; flex-direction: column; gap: 4px; }
    .cards-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .shop-card { background: #131520; border: 2px solid #336699; border-radius: 12px; padding: 10px; display: flex; flex-direction: column; align-items: center; text-align: center; gap: 6px; transition: transform 0.3s ease, opacity 0.3s ease; position: relative; }
    .shop-card.locked { border-color: #ffd700 !important; box-shadow: 0 0 15px rgba(255, 215, 0, 0.35); }
    .card-title { font-size: 14px; font-weight: bold; color: #ffd700; }
    .card-desc { font-size: 11px; color: #ccc; min-height: 38px; }
    .card-btn { width: 100%; background: #2575fc; border: none; color: white; padding: 7px; border-radius: 6px; font-size: 12px; font-weight: bold; cursor: pointer; }
    .card-btn:disabled { background: #333; color: #777; cursor: not-allowed; }
    .card-btn.combine { background: #00d2ff; color: #000; }
    .card-lock-btn { background: transparent; border: 1px solid #444; color: #aaa; padding: 4px 8px; font-size: 11px; border-radius: 4px; cursor: pointer; display: flex; align-items: center; gap: 4px; }
    .card-lock-btn.active { border-color: #ffd700; color: #ffd700; }
    #joystick-zone { position: absolute; bottom: 20px; left: 20px; width: 120px; height: 120px; background: rgba(255, 255, 255, 0.08); border: 2px solid rgba(255, 255, 255, 0.2); border-radius: 50%; display: none; touch-action: none; }
    #joystick-knob { position: absolute; top: 35px; left: 35px; width: 50px; height: 50px; background: rgba(245, 190, 35, 0.7); border-radius: 50%; box-shadow: 0 0 10px rgba(245, 190, 35, 0.5); }
  </style>
</head>
<body>

<div id="game-container">
  <canvas id="gameCanvas" width="720" height="1280"></canvas>

  <div class="ui-layer" id="hud-layer">
    <div id="hud">
      <div class="hud-top">
        <div class="hud-card">🌊 DALGA <span id="hud-wave">1</span>/15</div>
        <div class="hud-card" id="hud-timer">⏱️ 00:25</div>
        <div class="hud-card">🪙 <span id="hud-coins">0</span></div>
      </div>
      <div class="hud-top">
        <div style="display: flex; align-items: center; gap: 6px;">
          <span style="font-size: 12px; font-weight: bold;">❤️ CAN</span>
          <div class="hp-bar-bg"><div class="hp-bar-fill" id="hud-hp-fill"></div></div>
        </div>
        <button class="hud-card interactive" id="btn-pause" style="cursor: pointer; background:#1b2230;">⏸️ Durdur</button>
      </div>
      <div id="boss-bar-container">
        <span id="boss-title" style="font-size: 12px; font-weight: bold; color: #ffaa00;">👑 FARE KRALI</span>
        <div class="boss-bar-bg"><div class="boss-bar-fill" id="boss-hp-fill"></div></div>
      </div>
    </div>
  </div>

  <div id="joystick-zone" class="interactive"><div id="joystick-knob"></div></div>

  <!-- BAŞLANGIÇ MENÜSÜ -->
  <div class="modal-overlay interactive" id="menu-overlay" style="display: flex;">
    <div class="modal-box">
      <div id="menu-cat-icon" style="width: 70px; height: 70px; display: flex; align-items: center; justify-content: center;"></div>
      <h1 style="color: #f5be23; font-size: 32px; text-align: center; margin: 0; text-shadow: 0 0 10px rgba(245,190,35,0.4);">KARA KEDİ</h1>
      <h2 style="color: #ff4444; font-size: 22px; text-align: center; margin: 0;">FARE İSTİLASI</h2>
      <div style="font-size: 14px; color: #8fa0b5;">15 Dalga Hayatta Kalma Roguelite</div>
      
      <div style="background: #141722; border: 1px solid #3a4860; border-radius: 10px; padding: 12px; font-size: 13px; line-height: 1.5; color: #ccc; width: 100%;">
        <div style="color: #00d2ff; font-weight: bold; margin-bottom: 4px;">🎮 NASIL OYNANIR?</div>
        • WASD / Yön Tuşları veya Dokunmatik Joystick ile hareket edin.<br>
        • Silahlar en yakın düşmanlara otomatik saldırır.<br>
        • Düşmanlardan düşen coinleri toplayarak dalga sonlarında marketten yeni silahlar ve güçlendirmeler satın alın!<br>
        • 3 Silah Yuvanızı yönetin, aynı silahları birleştirerek Tier 4 seviyesine kadar yükseltin!
      </div>

      <button class="btn-gold" id="btn-start-game">⚔️ SAVAŞA BAŞLA</button>
    </div>
  </div>

  <!-- MARKET (SHOP) -->
  <div class="modal-overlay interactive" id="shop-overlay">
    <div class="shop-container">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2 style="color: #f5be23; font-size: 18px; margin: 0;">🏪 SAVAŞ MARKETİ</h2>
        <div style="font-weight: bold; color: #ffd700; font-size: 14px;">🪙 MEVCUT COIN: <span id="shop-coins-val">0</span></div>
      </div>
      <div class="shop-slots-panel" id="shop-weapon-slots"></div>
      <div class="cards-grid" id="shop-cards-grid"></div>
      <div style="display: flex; justify-content: space-between; gap: 10px; margin-top: 4px;">
        <button class="btn-gold" id="btn-reroll" style="font-size: 13px; padding: 8px 16px;">🔄 YENİLE (3 Coin)</button>
        <button class="btn-gold" id="btn-next-wave" style="font-size: 13px; padding: 8px 16px; background: #00c853;">⚔️ SONRAKİ DALGA</button>
      </div>
    </div>
  </div>

  <!-- GAME OVER -->
  <div class="modal-overlay interactive" id="gameover-overlay">
    <div class="modal-box" style="border-color: #ff3333;">
      <h1 style="color: #ff3333; font-size: 28px;">💀 OYUN BİTTİ</h1>
      <div id="gameover-stats" style="font-size: 14px; text-align: center; line-height: 1.6; color: #ccc;"></div>
      <button class="btn-gold" id="btn-retry" style="background: #ff3333; color: white;">🔁 YENİDEN OYNA</button>
    </div>
  </div>

  <!-- VICTORY -->
  <div class="modal-overlay interactive" id="victory-overlay">
    <div class="modal-box" style="border-color: #00ff88; box-shadow: 0 0 35px rgba(0, 255, 136, 0.4);">
      <h1 style="color: #00ff88; font-size: 28px;">👑 ZAFER!</h1>
      <div style="font-size: 14px; color: #ddd; text-align: center;">Fare İmparatoru ve tüm istilacı fareler yok edildi! Krallık kurtuldu!</div>
      <div id="victory-stats" style="font-size: 14px; text-align: center; line-height: 1.6; color: #ffeb3b;"></div>
      <button class="btn-gold" id="btn-victory-restart" style="background: #00ff88; color: #000;">🏆 TEKRAR OYNA</button>
    </div>
  </div>
</div>

<script>
const ASSETS_DATA = $json;
"@

$gameScriptLines = [System.IO.File]::ReadAllLines("d:\benim antigravitiler\kara kedi\web\game.js", [System.Text.Encoding]::UTF8)

# Find line where TIER_COLORS starts
$startIdx = 0
for ($i = 0; $i -lt $gameScriptLines.Length; $i++) {
    if ($gameScriptLines[$i].Contains("const TIER_COLORS =")) {
        $startIdx = $i
        break
    }
}

$gameScriptBody = ($gameScriptLines[$startIdx..($gameScriptLines.Length - 1)]) -join "`n"
$audioEngineBody = ($gameScriptLines[0..171]) -join "`n"

$customLoader = @"

// Base64 Asset Loader
const images = {};
for (const key in ASSETS_DATA) {
  if (ASSETS_DATA[key]) {
    const img = new Image();
    img.src = ASSETS_DATA[key];
    images[key] = img;
  }
}
if (images['player_south']) {
  const catDiv = document.getElementById('menu-cat-icon');
  if (catDiv) {
    const iconImg = new Image();
    iconImg.src = ASSETS_DATA['player_south'];
    iconImg.style.width = '70px';
    iconImg.style.height = '70px';
    iconImg.style.objectFit = 'contain';
    iconImg.style.filter = 'drop-shadow(0 0 8px #f5be23)';
    catDiv.appendChild(iconImg);
  }
}
"@

$finalHtml = $htmlHeader + "`n" + $audioEngineBody + "`n" + $customLoader + "`n" + $gameScriptBody + "`n</script>`n</body>`n</html>"

[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\web\index.html", $finalHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\Kara_Kedi_Web_Surumu.html", $finalHtml, [System.Text.Encoding]::UTF8)

Write-Output "STANDALONE_INDEX_HTML_AND_SINGLE_FILE_CREATED_SUCCESSFULLY"
