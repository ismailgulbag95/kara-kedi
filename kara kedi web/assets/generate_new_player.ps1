Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 48x48 Black Cat Hero (Unclothed, Red Cape, Black Feathered Hat)
$bmp = New-Object System.Drawing.Bitmap(48, 48)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)

# Brushes
$bFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 20, 20, 24))
$bDarkFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 10, 14))
$bCapeRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 220, 30, 45))
$bCapeShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 160, 20, 30))
$bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 215, 0))
$bGreenEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 240, 90))
$bWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
$bHat = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 30, 38))
$bFeather = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 240, 230))
$pWhisker = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 220, 220, 230), 1)

# 1. Flowing Red Cape in Background
$g.FillPolygon($bCapeShadow, @(
    [System.Drawing.Point]::new(15, 18),
    [System.Drawing.Point]::new(7, 44),
    [System.Drawing.Point]::new(22, 42),
    [System.Drawing.Point]::new(20, 22)
))
$g.FillPolygon($bCapeRed, @(
    [System.Drawing.Point]::new(18, 17),
    [System.Drawing.Point]::new(8, 42),
    [System.Drawing.Point]::new(24, 40),
    [System.Drawing.Point]::new(22, 20)
))

# 2. Sleek Black Cat Tail
$pTail = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 20, 20, 24), 3)
$g.DrawArc($pTail, 26, 26, 18, 18, 270, 180)

# 3. Athletic Legs & Paws
$g.FillRectangle($bDarkFur, 17, 34, 5, 11)
$g.FillRectangle($bDarkFur, 26, 34, 5, 11)
$g.FillEllipse($bFur, 15, 42, 8, 5)
$g.FillEllipse($bFur, 25, 42, 8, 5)

# 4. Sleek Athletic Black Torso & Arms
$g.FillRectangle($bFur, 18, 18, 12, 18)
# Golden Cape Clasp
$g.FillEllipse($bGold, 22, 18, 4, 4)
# Forearms & Paws
$g.FillRectangle($bFur, 13, 22, 5, 10)
$g.FillRectangle($bFur, 30, 22, 5, 10)
$g.FillEllipse($bFur, 12, 30, 6, 6)
$g.FillEllipse($bFur, 30, 30, 6, 6)

# 5. Black Cat Head
$g.FillEllipse($bFur, 16, 8, 16, 14)
# Cat Ears
$g.FillPolygon($bFur, @([System.Drawing.Point]::new(16, 10), [System.Drawing.Point]::new(19, 2), [System.Drawing.Point]::new(23, 8)))
$g.FillPolygon($bFur, @([System.Drawing.Point]::new(25, 8), [System.Drawing.Point]::new(29, 2), [System.Drawing.Point]::new(32, 10)))
# Inner Pink Ear
$bPink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 140, 160))
$g.FillPolygon($bPink, @([System.Drawing.Point]::new(18, 8), [System.Drawing.Point]::new(20, 4), [System.Drawing.Point]::new(22, 8)))
$g.FillPolygon($bPink, @([System.Drawing.Point]::new(26, 8), [System.Drawing.Point]::new(28, 4), [System.Drawing.Point]::new(30, 8)))

# 6. Glowing Emerald Eyes & Muzzle
$g.FillEllipse($bGreenEye, 19, 12, 4, 3)
$g.FillEllipse($bGreenEye, 25, 12, 4, 3)
$bPupil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 40, 0))
$g.FillRectangle($bPupil, 20, 12, 2, 3)
$g.FillRectangle($bPupil, 26, 12, 2, 3)
# Cute Snout & Whiskers
$g.FillEllipse($bPink, 23, 16, 2, 2)
$g.DrawLine($pWhisker, 16, 16, 11, 15)
$g.DrawLine($pWhisker, 16, 18, 12, 19)
$g.DrawLine($pWhisker, 32, 16, 37, 15)
$g.DrawLine($pWhisker, 32, 18, 36, 19)

# 7. Asil Siyah Şapka & Tüy (Cavalier Hat & White Feather)
$g.FillEllipse($bHat, 12, 5, 24, 7) # Hat Brim
$g.FillRectangle($bHat, 17, 1, 14, 6) # Hat Crown
$bHatBand = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 20, 30))
$g.FillRectangle($bHatBand, 17, 5, 14, 2) # Red Hat Band
# White Plume Feather flowing left
$g.FillPolygon($bFeather, @(
    [System.Drawing.Point]::new(19, 3),
    [System.Drawing.Point]::new(8, -1),
    [System.Drawing.Point]::new(12, 4)
))

$bmp.Save("$assetsDir\player.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "NEW_PLAYER_SPRITE_CREATED"
