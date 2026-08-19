$workspace = "d:\benim antigravitiler\kara kedi"
$tempDir = Join-Path $env:TEMP ("docx_" + [Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path "$tempDir\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$tempDir\word\_rels" -Force | Out-Null

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'@
[System.IO.File]::WriteAllText("$tempDir\[Content_Types].xml", $contentTypes, [System.Text.Encoding]::UTF8)

$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@
[System.IO.File]::WriteAllText("$tempDir\_rels\.rels", $rels, [System.Text.Encoding]::UTF8)

$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@
[System.IO.File]::WriteAllText("$tempDir\word\_rels\document.xml.rels", $docRels, [System.Text.Encoding]::UTF8)

$styles = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
        <w:sz w:val="24"/>
        <w:lang w:val="tr-TR"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>
'@
[System.IO.File]::WriteAllText("$tempDir\word\styles.xml", $styles, [System.Text.Encoding]::UTF8)

$docXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p>
      <w:pPr><w:jc w:val="center"/></w:pPr>
      <w:r>
        <w:rPr><w:b/><w:sz w:val="52"/><w:color w:val="1A1A1A"/></w:rPr>
        <w:t>KARA KEDİ: FARE İSTİLASI</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr><w:jc w:val="center"/></w:pPr>
      <w:r>
        <w:rPr><w:i/><w:sz w:val="28"/><w:color w:val="555555"/></w:rPr>
        <w:t>3 Silah Yuvası &amp; Brotato Market Tasarım Dokümanı (GDD v2)</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t></w:t></w:r></w:p>
    
    <w:p>
      <w:r>
        <w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="0B5394"/></w:rPr>
        <w:t>1. 3 SİLAH YUVASI SİSTEMİ (WEAPON SLOTS)</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Yuva 1 - Sağ El: Yakın Dövüş (Kılıç, Çift Pençe) veya Menzilli silahlar.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Yuva 2 - Sol El: İkinci yakın dövüş veya delici menzilli silah (Kılçık Bumerangı).</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Yuva 3 - Kuyruk: Özel alan etkili patlayıcı silahlar (İp Yumağı Bombası).</w:t></w:r></w:p>

    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p>
      <w:r>
        <w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="0B5394"/></w:rPr>
        <w:t>2. SİLAH CEPHANELİĞİ</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• 🗡️ Kara Çelik Kılıç: Geniş savurma, yüksek hasar ve geri tepme (33 Hasar).</w:t></w:r></w:p>
    <w:p><w:r><w:t>• 🐾 Çift Pençe: Çok hızlı seri vuruşlar, +%25 kritik hasar şansı.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• 🐟 Kılçık Bumerangı: 320px menzilli, düşmanları delip geçen ve kediye dönen kemik.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• 🧶 İp Yumağı Bombası: Kuyruktan atılan, farelerin içine düşüp patlayan alan etkili bomba.</w:t></w:r></w:p>

    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p>
      <w:r>
        <w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="0B5394"/></w:rPr>
        <w:t>3. BROTATO TARZI MARKET &amp; EŞYALAR</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Silah Satma &amp; Değiştirme: Markette takılı 3 silah görüntülenir, %60 koin iadesiyle satılabilir.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Kilit (Lock) Mekaniği: İstenilen bir kart dondurularak sonraki dalgaya saklanabilir.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Zar Atma (Reroll): 5 Koin karşılığında açık kartlar yeniden karıştırılır.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Brotato Tarzı Eşyalar: Kedi Nanesi (+%25 Hız / -%5 Can), Ağır Çan (+25 Can / +2 Zırh / -15 Hız), Gece Gözü, Dikenli Kürk vb.</w:t></w:r></w:p>

    <w:p><w:r><w:t></w:t></w:r></w:p>
    <w:p>
      <w:r>
        <w:rPr><w:b/><w:sz w:val="32"/><w:color w:val="0B5394"/></w:rPr>
        <w:t>4. WAVE VE MATEMATİKSEL DENGE</w:t>
      </w:r>
    </w:p>
    <w:p><w:r><w:t>• Dalga Süresi: 25.0 + (Wave * 3.5) saniye.</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Düşman Can Artışı: Base_HP * (1.0 + (Wave - 1) * 0.22).</w:t></w:r></w:p>
    <w:p><w:r><w:t>• Düşman Hasar Artışı: Base_DMG * (1.0 + (Wave - 1) * 0.12).</w:t></w:r></w:p>
    <w:p><w:r><w:t>• 👑 Elit Boss Savaşları: 5. ve 10. dalgalarda 350+ HP'li dev Elit Tank Fare ortaya çıkar.</w:t></w:r></w:p>
  </w:body>
</w:document>
'@
[System.IO.File]::WriteAllText("$tempDir\word\document.xml", $docXml, [System.Text.Encoding]::UTF8)

$outputDocx = Join-Path $workspace "Kara_Kedi_Oyun_Uretim_Dokumani.docx"
if (Test-Path $outputDocx) { Remove-Item $outputDocx -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputDocx)
Remove-Item -Recurse -Force $tempDir
Write-Output "DOCX_UPDATED_SUCCESS: $outputDocx"
