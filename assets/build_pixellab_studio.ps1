$outDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\hd_prototype"
$sheetImgPath = "$outDir\master_16frame_turnaround_sheet.png"

$sheetBase64 = ""
if (Test-Path $sheetImgPath) {
    $sheetBase64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($sheetImgPath))
}

# Collect all directions frames
$framesDict = @{}
$directions = @("south", "north", "east", "west")

foreach ($d in $directions) {
    $dirPath = "$outDir\$d"
    $files = Get-ChildItem "$dirPath\*.png" | Sort-Object Name
    $list = @()
    foreach ($f in $files) {
        $b64 = "data:image/png;base64," + [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($f.FullName))
        $list += $b64
    }
    $framesDict[$d] = $list
}

$jsonFrames = $framesDict | ConvertTo-Json -Compress

$html = @"
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <title>🎯 16 Kare 4-Y&#246;nl&#252; Turnaround Master Animasyon St&#252;dyosu</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { background: #05070c; color: #f0f0f0; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 24px; }
    .app-container { max-width: 1140px; width: 100%; background: #0c101a; border: 3px solid #f5be23; border-radius: 24px; padding: 28px; box-shadow: 0 0 60px rgba(245, 190, 35, 0.4); display: flex; flex-direction: column; gap: 24px; }
    
    .header { text-align: center; border-bottom: 2px solid #1c2738; padding-bottom: 16px; }
    .header h1 { color: #f5be23; font-size: 30px; letter-spacing: 1.5px; text-shadow: 0 0 20px rgba(245,190,35,0.4); }
    .header p { color: #8fa0b5; font-size: 14px; margin-top: 6px; }

    .main-layout { display: grid; grid-template-columns: 480px 1fr; gap: 28px; }

    /* MASTER SPRITE SHEET */
    .sheet-card { background: #070910; border: 2px solid #6e431f; border-radius: 18px; padding: 16px; display: flex; flex-direction: column; align-items: center; gap: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.7); }
    .sheet-img { width: 100%; border-radius: 12px; border: 2px solid #f5be23; object-fit: contain; box-shadow: 0 0 25px rgba(245,190,35,0.25); image-rendering: pixelated; }
    .sheet-title { font-size: 16px; font-weight: bold; color: #f5be23; text-align: center; }

    /* VIDEO / ANIMATION STUDIO */
    .studio-panel { background: #070910; border: 2px solid #1c2738; border-radius: 18px; padding: 20px; display: flex; flex-direction: column; gap: 16px; }
    
    .screen-stage { background: radial-gradient(circle, #1a253a 0%, #05070c 80%); border: 2px solid #f5be23; border-radius: 16px; height: 280px; display: flex; justify-content: center; align-items: center; position: relative; overflow: hidden; box-shadow: inset 0 0 40px rgba(0,0,0,0.9); }
    .grid-lines { position: absolute; width: 100%; height: 100%; background-size: 32px 32px; background-image: linear-gradient(to right, rgba(255,255,255,0.04) 1px, transparent 1px), linear-gradient(to bottom, rgba(255,255,255,0.04) 1px, transparent 1px); pointer-events: none; }
    #playerCanvas { image-rendering: pixelated; transition: transform 0.1s ease; }

    .controls-bar { display: flex; flex-direction: column; gap: 12px; background: #111624; border: 1.5px solid #1c2738; border-radius: 14px; padding: 14px; }
    
    .btn-row { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
    .btn { background: #182236; color: #fff; border: 1.5px solid #293a55; border-radius: 8px; padding: 8px 14px; font-size: 12px; font-weight: bold; cursor: pointer; transition: all 0.15s ease; }
    .btn:hover { background: #f5be23; color: #080a10; border-color: #ffe066; transform: scale(1.05); }
    .btn.active { background: #f5be23; color: #080a10; border-color: #ffe066; }

    .slider-group { display: flex; align-items: center; gap: 10px; font-size: 12px; color: #8fa0b5; }
    input[type=range] { accent-color: #f5be23; cursor: pointer; }

    .dir-selector { display: grid; grid-template-columns: repeat(2, 1fr); gap: 6px; }
    
    .status-badge { font-size: 12px; color: #00ff66; font-weight: bold; background: #0a2012; border: 1px solid #00ff66; padding: 4px 10px; border-radius: 8px; display: inline-block; }
  </style>
</head>
<body>

<div class="app-container">
  <div class="header">
    <h1>🎬 16 KARE 4-Y&#214;NL&#220; TURNAROUND MASTER AN&#304;MASYON ST&#220;DYOSU</h1>
    <p>&#214;n (G&#252;ney), Arka (Kuzey), Sa&#287; (Do&#287;u) ve Sol (Bat&#305;) A&#231;&#305;lar&#305;nda E&#351;zamanl&#305; Duru&#351; ve 4'er Karelik Ad&#305;mlama D&#246;ng&#252;s&#252;</p>
  </div>

  <div class="main-layout">
    <!-- MASTER 16-FRAME SPRITE SHEET -->
    <div class="sheet-card">
      <div class="sheet-title">&#128444;&#65039; 16 KAREL&#304;K MASTER SHEET (4 Sat&#305;r x 4 S&#252;tun)</div>
      <img src="data:image/png;base64,$sheetBase64" class="sheet-img" alt="Master Turnaround Sheet">
      <div style="font-size: 11px; color: #8fa0b5; text-align: center; line-height: 1.4;">
        <strong>Sat&#305;r 1:</strong> G&#252;ney (&#214;n Poz) | <strong>Sat&#305;r 2:</strong> Kuzey (Arka Poz)<br>
        <strong>Sat&#305;r 3:</strong> Do&#287;u (Sa&#287; Poz) | <strong>Sat&#305;r 4:</strong> Bat&#305; (Sol Poz)
      </div>
    </div>

    <!-- ANİMASYON VİDEO EKRANI & KONTROLLER -->
    <div class="studio-panel">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <span style="font-weight: bold; color: #f5be23; font-size: 15px;">&#128250; CANLI TURNAROUND OYNATICI</span>
        <span class="status-badge">&#9679; 4'ER KAREL&#304;K D&#214;NG&#220;</span>
      </div>

      <div class="screen-stage">
        <div class="grid-lines"></div>
        <canvas id="playerCanvas" width="256" height="256" style="width: 210px; height: 210px;"></canvas>
      </div>

      <!-- KONTROL PANELİ -->
      <div class="controls-bar">
        <!-- OYNAT / DURDUR & KARE ATLA -->
        <div class="btn-row">
          <div style="display: flex; gap: 8px;">
            <button class="btn" id="btnPlayPause" onclick="togglePlay()">&#9208;&#65039; Duraklat</button>
            <button class="btn" onclick="stepFrame()">&#9197; Ad&#305;m Ad&#305;m &#304;lerle</button>
          </div>

          <!-- YAKINLAŞTIRMA (ZOOM) -->
          <div class="slider-group">
            <span>Boyut:</span>
            <button class="btn" onclick="setZoom(160)" style="padding: 4px 8px;">1x</button>
            <button class="btn active" id="btnZ2" onclick="setZoom(210)" style="padding: 4px 8px;">1.5x</button>
            <button class="btn" onclick="setZoom(260)" style="padding: 4px 8px;">2x</button>
          </div>
        </div>

        <!-- HIZ AYARI -->
        <div class="btn-row" style="border-top: 1px solid #1c2738; padding-top: 10px;">
          <div class="slider-group">
            <span>Ad&#305;m H&#305;z&#305;:</span>
            <input type="range" id="speedSlider" min="60" max="350" value="140" oninput="updateSpeed(this.value)">
            <span id="speedVal" style="color:#f5be23; font-weight:bold;">140 ms</span>
          </div>

          <!-- YÖN SEÇİCİ -->
          <div class="dir-selector">
            <button class="btn active" id="dir-south" onclick="setDir('south')">&#11015;&#65039; G&#252;ney (&#214;n)</button>
            <button class="btn" id="dir-north" onclick="setDir('north')">&#11014;&#65039; Kuzey (Arka)</button>
            <button class="btn" id="dir-east" onclick="setDir('east')">&#10145;&#65039; Do&#287;u (Sa&#287;)</button>
            <button class="btn" id="dir-west" onclick="setDir('west')">&#11013;&#65039; Bat&#305; (Sol)</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
const framesData = $jsonFrames;
let currentDir = 'south';
let currentFrame = 0;
let isPlaying = true;
let animSpeed = 140;
let animTimer = null;

const canvas = document.getElementById('playerCanvas');
const ctx = canvas.getContext('2d');
ctx.imageSmoothingEnabled = false;

const preloaded = {};
for (const d in framesData) {
  preloaded[d] = framesData[d].map(src => {
    const img = new Image();
    img.src = src;
    return img;
  });
}

function drawFrame() {
  ctx.clearRect(0, 0, 256, 256);
  const arr = preloaded[currentDir];
  if (arr && arr.length > 0) {
    const img = arr[currentFrame % arr.length];
    if (img && img.complete) {
      ctx.drawImage(img, 0, 0, 256, 256);
    }
  }
}

function tick() {
  drawFrame();
  const arr = preloaded[currentDir];
  const maxF = arr ? arr.length : 4;
  currentFrame = (currentFrame + 1) % maxF;
}

function startLoop() {
  if (animTimer) clearInterval(animTimer);
  animTimer = setInterval(tick, animSpeed);
}

function togglePlay() {
  isPlaying = !isPlaying;
  const btn = document.getElementById('btnPlayPause');
  if (isPlaying) {
    btn.innerHTML = '&#9208;&#65039; Duraklat';
    startLoop();
  } else {
    btn.innerHTML = '&#9654;&#65039; Oynat';
    clearInterval(animTimer);
  }
}

function stepFrame() {
  if (isPlaying) togglePlay();
  const arr = preloaded[currentDir];
  const maxF = arr ? arr.length : 4;
  currentFrame = (currentFrame + 1) % maxF;
  drawFrame();
}

function setDir(d) {
  currentDir = d;
  document.querySelectorAll('.dir-selector .btn').forEach(b => b.classList.remove('active'));
  document.getElementById('dir-' + d).classList.add('active');
  currentFrame = 0;
  drawFrame();
}

function setZoom(size) {
  canvas.style.width = size + 'px';
  canvas.style.height = size + 'px';
  document.querySelectorAll('.slider-group .btn').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');
}

function updateSpeed(val) {
  animSpeed = parseInt(val);
  document.getElementById('speedVal').textContent = val + ' ms';
  if (isPlaying) startLoop();
}

startLoop();
</script>

</body>
</html>
"@

[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\pixellab_nisanci_onizleme.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "TURNAROUND_STUDIO_HTML_GENERATED_SUCCESSFULLY"
