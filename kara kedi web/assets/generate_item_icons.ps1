Add-Type -AssemblyName System.Drawing
$itemsDir = "d:\benim antigravitiler\kara kedi\assets\textures\items"
if (!(Test-Path $itemsDir)) { New-Item -ItemType Directory -Path $itemsDir -Force }

function Create-Icon($filename, [scriptblock]$drawBlock) {
    $bmp = New-Object System.Drawing.Bitmap(48, 48)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.Clear([System.Drawing.Color]::Transparent)
    & $drawBlock $gfx
    $bmp.Save("$itemsDir\$filename", [System.Drawing.Imaging.ImageFormat]::Png)
}

# 1. Dev Kedi Zırhı (item_cat_armor.png)
Create-Icon "item_cat_armor.png" {
    param($g)
    $bMetal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 130, 140, 160))
    $bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 180, 40))
    $g.FillPolygon($bMetal, @([System.Drawing.Point]::new(10, 10), [System.Drawing.Point]::new(38, 10), [System.Drawing.Point]::new(34, 38), [System.Drawing.Point]::new(24, 44), [System.Drawing.Point]::new(14, 38)))
    $g.FillEllipse($bGold, 18, 18, 12, 12)
}

# 2. Dikenli Kürk (item_thorns.png)
Create-Icon "item_thorns.png" {
    param($g)
    $bDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 45, 40))
    $bSpike = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 90, 40))
    $g.FillEllipse($bDark, 10, 10, 28, 28)
    $g.FillPolygon($bSpike, @([System.Drawing.Point]::new(6, 24), [System.Drawing.Point]::new(14, 18), [System.Drawing.Point]::new(14, 30)))
    $g.FillPolygon($bSpike, @([System.Drawing.Point]::new(42, 24), [System.Drawing.Point]::new(34, 18), [System.Drawing.Point]::new(34, 30)))
    $g.FillPolygon($bSpike, @([System.Drawing.Point]::new(24, 6), [System.Drawing.Point]::new(18, 14), [System.Drawing.Point]::new(30, 14)))
    $g.FillPolygon($bSpike, @([System.Drawing.Point]::new(24, 42), [System.Drawing.Point]::new(18, 34), [System.Drawing.Point]::new(30, 34)))
}

# 3. Kedi Canlılığı (item_regen.png)
Create-Icon "item_regen.png" {
    param($g)
    $bHeart = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 50, 80))
    $bGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 230, 100))
    $g.FillEllipse($bHeart, 10, 12, 16, 16)
    $g.FillEllipse($bHeart, 22, 12, 16, 16)
    $g.FillPolygon($bHeart, @([System.Drawing.Point]::new(10, 22), [System.Drawing.Point]::new(38, 22), [System.Drawing.Point]::new(24, 40)))
    # + symbol
    $g.FillRectangle($bGreen, 21, 16, 6, 16)
    $g.FillRectangle($bGreen, 16, 21, 16, 6)
}

# 4. Ağır Çan Kolye (item_heavy_bell.png)
Create-Icon "item_heavy_bell.png" {
    param($g)
    $bBell = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 190, 30))
    $bStrap = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 40, 40))
    $g.FillRectangle($bStrap, 8, 8, 32, 6)
    $g.FillEllipse($bBell, 14, 16, 20, 20)
    $g.FillRectangle($bBell, 12, 32, 24, 6)
}

# 5. Kanlı Pençe (item_bloody_claw.png)
Create-Icon "item_bloody_claw.png" {
    param($g)
    $bBlood = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 220, 20, 40))
    $bClaw = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 230, 240))
    $g.FillPolygon($bClaw, @([System.Drawing.Point]::new(12, 36), [System.Drawing.Point]::new(18, 10), [System.Drawing.Point]::new(22, 36)))
    $g.FillPolygon($bClaw, @([System.Drawing.Point]::new(20, 36), [System.Drawing.Point]::new(28, 6), [System.Drawing.Point]::new(32, 36)))
    $g.FillPolygon($bClaw, @([System.Drawing.Point]::new(30, 36), [System.Drawing.Point]::new(38, 14), [System.Drawing.Point]::new(40, 36)))
    $g.FillEllipse($bBlood, 16, 28, 18, 14)
}

# 6. Sniper Gözlüğü (item_sniper_glass.png)
Create-Icon "item_sniper_glass.png" {
    param($g)
    $pRed = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 50, 50), 3)
    $bCyan = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 200, 255))
    $g.FillEllipse($bCyan, 12, 12, 24, 24)
    $g.DrawEllipse($pRed, 10, 10, 28, 28)
    $g.DrawLine($pRed, 24, 4, 24, 44)
    $g.DrawLine($pRed, 4, 24, 44, 24)
}

# 7. Öfke Nanesi (item_rage_mint.png)
Create-Icon "item_rage_mint.png" {
    param($g)
    $bLeaf = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 200, 70))
    $bFlame = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 120, 20))
    $g.FillEllipse($bLeaf, 14, 18, 20, 24)
    $g.FillPolygon($bFlame, @([System.Drawing.Point]::new(24, 6), [System.Drawing.Point]::new(32, 20), [System.Drawing.Point]::new(16, 20)))
}

# 8. Yıldırımlı Bıyık (item_lightning_whiskers.png)
Create-Icon "item_lightning_whiskers.png" {
    param($g)
    $bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 230, 40))
    $g.FillPolygon($bGold, @([System.Drawing.Point]::new(26, 6), [System.Drawing.Point]::new(14, 24), [System.Drawing.Point]::new(24, 24), [System.Drawing.Point]::new(20, 42), [System.Drawing.Point]::new(34, 22), [System.Drawing.Point]::new(24, 22)))
}

# 9. Puma Adımları (item_puma_boots.png)
Create-Icon "item_puma_boots.png" {
    param($g)
    $bBoot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 100, 40))
    $bWing = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 240, 250))
    $g.FillRectangle($bBoot, 16, 12, 12, 22)
    $g.FillPolygon($bBoot, @([System.Drawing.Point]::new(16, 28), [System.Drawing.Point]::new(36, 28), [System.Drawing.Point]::new(36, 36), [System.Drawing.Point]::new(16, 36)))
    $g.FillPolygon($bWing, @([System.Drawing.Point]::new(16, 14), [System.Drawing.Point]::new(6, 8), [System.Drawing.Point]::new(8, 20)))
}

# 10. Gölge Pelerini (item_shadow_cloak.png)
Create-Icon "item_shadow_cloak.png" {
    param($g)
    $bCloak = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 80, 40, 110))
    $bDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 20, 60))
    $g.FillPolygon($bCloak, @([System.Drawing.Point]::new(24, 10), [System.Drawing.Point]::new(38, 40), [System.Drawing.Point]::new(10, 40)))
    $g.FillEllipse($bDark, 18, 16, 12, 12)
}

# 11. Altın Mıknatıs (item_gold_magnet.png)
Create-Icon "item_gold_magnet.png" {
    param($g)
    $bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 170, 30))
    $bBlue = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 120, 240))
    $g.FillRectangle($bGold, 10, 14, 10, 24)
    $g.FillRectangle($bGold, 28, 14, 10, 24)
    $g.FillRectangle($bGold, 10, 10, 28, 10)
    $g.FillRectangle($bBlue, 10, 32, 10, 8)
    $g.FillRectangle($bBlue, 28, 32, 10, 8)
}

# 12. Tutumlu Kumbara (item_piggy_bank.png)
Create-Icon "item_piggy_bank.png" {
    param($g)
    $bPink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 140, 160))
    $bCoin = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 215, 0))
    $g.FillEllipse($bPink, 10, 14, 28, 22)
    $g.FillEllipse($bPink, 32, 20, 8, 8) # Snout
    $g.FillRectangle($bCoin, 21, 8, 6, 8) # Coin dropping in
}

# 13. Taze Fare Bifteği (item_rat_steak.png)
Create-Icon "item_rat_steak.png" {
    param($g)
    $bMeat = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 50, 60))
    $bBone = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 240, 230))
    $g.FillEllipse($bMeat, 10, 14, 28, 20)
    $g.FillEllipse($bBone, 18, 20, 8, 8)
}

# 14. Gece Avcısı Gözü (item_night_vision.png)
Create-Icon "item_night_vision.png" {
    param($g)
    $bEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 200, 30))
    $bPupil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 20, 20, 20))
    $g.FillEllipse($bEye, 8, 14, 32, 20)
    $g.FillEllipse($bPupil, 21, 16, 6, 16)
}

Write-Output "ALL_14_ITEM_ICONS_GENERATED_SUCCESSFULLY"
