Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 64x64 Glowing Red/Orange Shockwave Ring
$bmp = New-Object System.Drawing.Bitmap(64, 64)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)

$pOuter = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 60, 40), 4)
$pInner = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 230, 100), 2)

$g.DrawEllipse($pOuter, 6, 6, 52, 52)
$g.DrawEllipse($pInner, 7, 7, 50, 50)

$bmp.Save("$assetsDir\shockwave_ring.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "SHOCKWAVE_RING_CREATED"
