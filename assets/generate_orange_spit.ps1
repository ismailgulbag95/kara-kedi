Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 18x18 Vibrant Flaming Orange Fireball / Spit Orb
$bmp = New-Object System.Drawing.Bitmap(18, 18)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)

$bOuter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 80, 0)) # Fiery Red-Orange
$bMid = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 160, 20)) # Vivid Orange
$bCore = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 240, 150)) # Bright Core

$g.FillEllipse($bOuter, 1, 1, 16, 16)
$g.FillEllipse($bMid, 3, 3, 12, 12)
$g.FillEllipse($bCore, 5, 5, 8, 8)

$bmp.Save("$assetsDir\projectile_acid.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "ORANGE_FIREBALL_TEXTURE_CREATED"
