$dir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\variants"
$b64A = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$dir\variant_a.png"))
$b64B = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$dir\variant_b.png"))
$b64C = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$dir\variant_c.png"))

$html = @"
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <title>🎯 N&#304;&#350;ANCI KED&#304; (48x48 Piksel Sprite Tasar&#305;m Se&#231;enekleri)</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
    body { background: #080a10; color: #f0f0f0; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 24px; }
    .container { max-width: 980px; width: 100%; background: #111520; border: 3px solid #f5be23; border-radius: 20px; padding: 28px; box-shadow: 0 0 50px rgba(245, 190, 35, 0.35); display: flex; flex-direction: column; gap: 24px; }
    
    .header { text-align: center; border-bottom: 2px solid #2a3a55; padding-bottom: 16px; }
    .header h1 { color: #f5be23; font-size: 32px; letter-spacing: 1px; text-shadow: 0 0 15px rgba(245,190,35,0.4); }
    .header p { color: #8fa0b5; font-size: 14px; margin-top: 6px; }

    .variants-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
    
    .variant-card { background: #0c0e16; border: 2.5px solid #2a3a55; border-radius: 16px; padding: 18px; display: flex; flex-direction: column; align-items: center; gap: 14px; text-align: center; transition: all 0.2s ease; position: relative; }
    .variant-card:hover { border-color: #f5be23; transform: translateY(-4px); box-shadow: 0 0 25px rgba(245, 190, 35, 0.25); }

    .stage { background: radial-gradient(circle, #1a233a 0%, #0c0e14 70%); border: 2px solid #334460; border-radius: 12px; width: 160px; height: 160px; display: flex; justify-content: center; align-items: center; }
    .stage img { width: 120px; height: 120px; image-rendering: pixelated; }

    .tag { background: #202636; color: #f5be23; border: 1px solid #f5be23; padding: 4px 10px; border-radius: 12px; font-weight: bold; font-size: 11px; text-transform: uppercase; }
    .title { color: #fff; font-size: 18px; font-weight: bold; }
    .desc { font-size: 12px; color: #aaa; line-height: 1.4; min-height: 80px; }
    
    .scale-row { display: flex; gap: 12px; align-items: flex-end; background: #141824; padding: 8px 14px; border-radius: 8px; border: 1px solid #2a3a55; }
    .scale-label { font-size: 11px; color: #8fa0b5; text-align: center; }
  </style>
</head>
<body>

<div class="container">
  <div class="header">
    <h1>🎯 N&#304;&#350;ANCI KED&#304; - 48x48 P&#304;KSEL SPR&#304;TE VARYASYONLARI</h1>
    <p>Oyun i&#231;i ger&#231;ek boyut ve b&#252;y&#252;t&#252;lm&#252;&#351; g&#246;r&#252;n&#252;m. Be&#287;endi&#287;iniz se&#231;ene&#287;i (A, B veya C) belirterek 8-y&#246;nl&#252; animasyonunu &#252;retebiliriz.</p>
  </div>

  <div class="variants-grid">
    <!-- SEÇENEK A -->
    <div class="variant-card">
      <div class="tag">SE&#199;ENEK A</div>
      <div class="title">&#129312; Klasik Kovboy / Va&#351;ak</div>
      <div class="stage">
        <img src="data:image/png;base64,$b64A" alt="Se&#231;enek A">
      </div>
      <div class="scale-row">
        <div><img src="data:image/png;base64,$b64A" style="width:48px;height:48px;image-rendering:pixelated;"><div class="scale-label">1x (48px)</div></div>
        <div><img src="data:image/png;base64,$b64A" style="width:72px;height:72px;image-rendering:pixelated;"><div class="scale-label">1.5x</div></div>
      </div>
      <div class="desc">
        &#8226; S&#305;cak va&#351;ak kumral&#305; k&#252;rk & krem &#231;ene.<br>
        &#8226; Geni&#351; k&#305;vr&#305;k taba kovboy f&#246;tr &#350;apkas&#305; & alt&#305;n toka.<br>
        &#8226; Sa&#287; elde ah&#351;ap kabzal&#305; A&#287;&#305;r Magnum tabanca.<br>
        &#8226; &#199;apraz deri fi&#351;eklik & alt&#305;n mermiler, siyah g&#246;z band&#305;.
      </div>
    </div>

    <!-- SEÇENEK B -->
    <div class="variant-card">
      <div class="tag" style="color:#00e5ff; border-color:#00e5ff;">SE&#199;ENEK B</div>
      <div class="title">&#128373;&#65039;&#8205;&#9794;&#65039; G&#246;lge Noir / Mafya Kasketli</div>
      <div class="stage">
        <img src="data:image/png;base64,$b64B" alt="Se&#231;enek B">
      </div>
      <div class="scale-row">
        <div><img src="data:image/png;base64,$b64B" style="width:48px;height:48px;image-rendering:pixelated;"><div class="scale-label">1x (48px)</div></div>
        <div><img src="data:image/png;base64,$b64B" style="width:72px;height:72px;image-rendering:pixelated;"><div class="scale-label">1.5x</div></div>
      </div>
      <div class="desc">
        &#8226; Asil k&#246;m&#252;r/gece siyah&#305; k&#252;rk.<br>
        &#8226; Koyu gri Peaky/Noir d&#252;z kasket &#351;apka.<br>
        &#8226; Parlak g&#252;m&#252;&#351;/krom ikili namlulu Magnum.<br>
        &#8226; Parlayan mavi ni&#351;anc&#305; monokl g&#246;zl&#252;&#287;&#252; ve k&#305;rm&#305;z&#305; fular.
      </div>
    </div>

    <!-- SEÇENEK C -->
    <div class="variant-card">
      <div class="tag" style="color:#76ff03; border-color:#76ff03;">SE&#199;ENEK C</div>
      <div class="title">&#127894;&#65039; Askeri Komando / &#199;&#246;l Tilkisi</div>
      <div class="stage">
        <img src="data:image/png;base64,$b64C" alt="Se&#231;enek C">
      </div>
      <div class="scale-row">
        <div><img src="data:image/png;base64,$b64C" style="width:48px;height:48px;image-rendering:pixelated;"><div class="scale-label">1x (48px)</div></div>
        <div><img src="data:image/png;base64,$b64C" style="width:72px;height:72px;image-rendering:pixelated;"><div class="scale-label">1.5x</div></div>
      </div>
      <div class="desc">
        &#8226; Kamuflaj haki/kum zeytin k&#252;rk.<br>
        &#8226; Alt&#305;n br&#246;veli askeri haki komando beresi.<br>
        &#8226; K&#305;rm&#305;z&#305; lazer noktal&#305; taktik susturuculu tabanca.<br>
        &#8226; Haki h&#252;cum yele&#287;i ve k&#305;rm&#305;z&#305; taktik viz&#246;r g&#246;z.
      </div>
    </div>
  </div>
</div>

</body>
</html>
"@

[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\nisanci_varyasyonlar.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "VARIANTS_HTML_GENERATED_SUCCESSFULLY"
