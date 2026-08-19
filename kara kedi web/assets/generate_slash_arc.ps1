Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 48x48 Crescent Curved Slash Blade Arc
$bmp = New-Object System.Drawing.Bitmap(48, 48)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)

# Bright White / Cyan Glowing Slash Arc
$pGlow = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 100, 220, 255), 6)
$pCore = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 255, 255), 3)

$g.DrawArc($pGlow, 4, 4, 38, 38, -65, 130)
$g.DrawArc($pCore, 5, 5, 36, 36, -60, 120)

$bmp.Save("$assetsDir\slash_arc.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "SLASH_ARC_CREATED"
