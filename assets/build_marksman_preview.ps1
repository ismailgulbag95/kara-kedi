Add-Type -AssemblyName System.Drawing

$marksmanDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman"
$portraitPath = "$marksmanDir\portrait.jpg"

$portraitBase64 = ""
if (Test-Path $portraitPath) {
    $bytes = [System.IO.File]::ReadAllBytes($portraitPath)
    $portraitBase64 = [Convert]::ToBase64String($bytes)
}

# Collect all frames base64
$framesDict = @{}

$directions = @("east", "north", "north-east", "north-west", "south", "south-east", "south-west", "west")

foreach ($d in $directions) {
    $subDir = "$marksmanDir\animations\Running\$d"
    if (Test-Path $subDir) {
        $pngFiles = Get-ChildItem "$subDir\*.png" | Sort-Object Name
        $frameList = @()
        foreach ($f in $pngFiles) {
            $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
            $b64 = "data:image/png;base64," + [Convert]::ToBase64String($bytes)
            $frameList += $b64
        }
        $framesDict[$d] = $frameList
    }
}

$jsonFrames = $framesDict | ConvertTo-Json -Compress

$html = @"
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <title>🎯 Ni&#351;anc&#305; Kedi (The Gunslinger) | Karakter & Animasyon &#214;nizleme</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { background: #0a0c13; color: #f0f0f0; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
    .preview-container { background: #131722; border: 3px solid #f5be23; border-radius: 20px; max-width: 860px; width: 100%; padding: 28px; box-shadow: 0 0 45px rgba(245, 190, 35, 0.35); display: flex; flex-direction: column; gap: 22px; }
    
    .header { text-align: center; border-bottom: 2px solid #2a3a55; padding-bottom: 14px; }
    .header h1 { color: #f5be23; font-size: 32px; letter-spacing: 1px; text-shadow: 0 0 15px rgba(245,190,35,0.5); }
    .header p { color: #8fa0b5; font-size: 14px; margin-top: 4px; }

    .main-grid { display: grid; grid-template-columns: 320px 1fr; gap: 24px; }
    
    /* PORTRAIT CARD */
    .card-box { background: #0c0e14; border: 2.5px solid #6e431f; border-radius: 16px; padding: 14px; display: flex; flex-direction: column; align-items: center; gap: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.6); }
    .portrait-img { width: 100%; aspect-ratio: 1/1; border-radius: 12px; border: 2px solid #f5be23; object-fit: cover; box-shadow: 0 0 20px rgba(245,190,35,0.3); }
    .badge { background: #2b1807; color: #f5be23; border: 1.5px solid #f5be23; padding: 4px 12px; border-radius: 20px; font-weight: bold; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }

    /* ANIMATION STAGE */
    .anim-box { background: #0c0e14; border: 2px solid #2a3a55; border-radius: 16px; padding: 18px; display: flex; flex-direction: column; align-items: center; gap: 16px; }
    .canvas-stage { background: radial-gradient(circle, #1a233a 0%, #0c0e14 70%); border: 2px solid #f5be23; border-radius: 14px; width: 200px; height: 200px; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 25px rgba(0,0,0,0.8); }
    #spriteCanvas { width: 140px; height: 140px; image-rendering: pixelated; }

    .dir-buttons { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; width: 100%; }
    .btn-dir { background: #192233; color: #99aabf; border: 1.5px solid #2a3a55; border-radius: 8px; padding: 8px 4px; font-size: 12px; font-weight: bold; cursor: pointer; transition: all 0.15s ease; }
    .btn-dir:hover, .btn-dir.active { background: #f5be23; color: #100b02; border-color: #ffe066; transform: scale(1.04); }

    /* STATS & BUFFS */
    .stats-box { background: #0c0e14; border: 1.5px solid #2a3a55; border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 8px; font-size: 13px; line-height: 1.5; }
    .buff { color: #00ff66; font-weight: bold; }
    .debuff { color: #ff4444; font-weight: bold; }
    .unlock-req { background: #221a08; border-left: 4px solid #f5be23; padding: 8px 12px; border-radius: 4px; color: #ffd700; font-size: 13px; }
  </style>
</head>
<body>

<div class="preview-container">
  <div class="header">
    <h1>🎯 N&#304;&#350;ANCI KED&#304; (THE GUNSLINGER)</h1>
    <p>Karakter Tasar&#305;m&#305;, HD Pixel Art Kart&#305; & 8-Y&#246;nl&#252; Y&#252;r&#252;me Animasyonu Prototipi</p>
  </div>

  <div class="main-grid">
    <!-- PORTRE KARTI -->
    <div class="card-box">
      <img src="data:image/jpeg;base64,$portraitBase64" class="portrait-img" alt="Ni&#351;anc&#305; Kedi">
      <div class="badge">&#128299; Menzilli Uzman&#305;</div>
      <div style="font-size: 13px; color: #aaa; text-align: center;">Kovboy F&#246;tr &#350;apkas&#305;, Sa&#287; G&#246;z Band&#305;, Alt&#305;n Kehribar G&#246;z, &#199;apraz Deri Fi&#351;eklik & Mermiler</div>
    </div>

    <!-- ANİMASYON & STATLAR -->
    <div style="display: flex; flex-direction: column; gap: 16px;">
      <div class="anim-box">
        <div style="font-weight: bold; font-size: 14px; color: #f5be23;">&#127939; 8-Y&#214;NL&#220; CANLI Y&#220;R&#220;ME AN&#304;MASYONU</div>
        <div class="canvas-stage">
          <canvas id="spriteCanvas" width="48" height="48"></canvas>
        </div>
        
        <div class="dir-buttons">
          <button class="btn-dir" onclick="setDir('north')">&#11014;&#65039; Kuzey</button>
          <button class="btn-dir active" onclick="setDir('south')">&#11015;&#65039; G&#252;ney</button>
          <button class="btn-dir" onclick="setDir('east')">&#10145;&#65039; Do&#287;u</button>
          <button class="btn-dir" onclick="setDir('west')">&#11013;&#65039; Bat&#305;</button>
          <button class="btn-dir" onclick="setDir('north-east')">&#8599;&#65039; Kuzeydo&#287;u</button>
          <button class="btn-dir" onclick="setDir('north-west')">&#8598;&#65039; Kuzeybat&#305;</button>
          <button class="btn-dir" onclick="setDir('south-east')">&#8600;&#65039; G&#252;neydo&#287;u</button>
          <button class="btn-dir" onclick="setDir('south-west')">&#8601;&#65039; G&#252;neybat&#305;</button>
        </div>
      </div>

      <div class="stats-box">
        <div style="color: #00d2ff; font-weight: bold; margin-bottom: 2px;">&#9876;&#65039; BA&#350;LANGI&#199; S&#304;LAHI: <span style="color:#fff;">A&#287;&#305;r Magnum (45 DMG)</span></div>
        <div><span class="buff">&#10004; +%40 Menzilli Silah Hasar&#305;</span></div>
        <div><span class="buff">&#10004; +%30 Mermi H&#305;z&#305; & +100px Sald&#305;r&#305; Menzili</span></div>
        <div><span class="debuff">&#10008; -%50 Yak&#305;n D&#246;v&#252;&#351; Hasar&#305;</span></div>
        <div><span class="debuff">&#10008; -20 Maksimum Can (80 HP ile ba&#351;lar)</span></div>
        
        <div class="unlock-req" style="margin-top: 6px;">
          &#128274; <b>K&#304;L&#304;T A&#199;ILMA KO&#350;ULU:</b> A&#287;&#305;r Magnum ile toplam 100 fare &#246;ld&#252;r.
        </div>
      </div>
    </div>
  </div>
</div>

<script>
const framesData = $jsonFrames;
let currentDir = 'south';
let currentFrame = 0;
const canvas = document.getElementById('spriteCanvas');
const ctx = canvas.getContext('2d');
ctx.imageSmoothingEnabled = false;

const preloadedImages = {};
for (const dir in framesData) {
  preloadedImages[dir] = framesData[dir].map(src => {
    const img = new Image();
    img.src = src;
    return img;
  });
}

function setDir(dir) {
  currentDir = dir;
  document.querySelectorAll('.btn-dir').forEach(b => b.classList.remove('active'));
  event.target.classList.add('active');
}

function animLoop() {
  ctx.clearRect(0, 0, 48, 48);
  const dirFrames = preloadedImages[currentDir];
  if (dirFrames && dirFrames.length > 0) {
    const img = dirFrames[currentFrame % dirFrames.length];
    if (img && img.complete) {
      ctx.drawImage(img, 0, 0, 48, 48);
    }
  }
  currentFrame = (currentFrame + 1) % 8;
}
setInterval(animLoop, 95);
</script>

</body>
</html>
"@

[System.IO.File]::WriteAllText("$marksmanDir\nisanci_kedi_onizleme.html", $html, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\nisanci_kedi_onizleme.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "PREVIEW_HTML_GENERATED_SUCCESSFULLY"
