Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 64x64 Giant Rat King Boss (Unclothed, Black Royal Cloak, Golden Crown)
$bmp = New-Object System.Drawing.Bitmap(64, 64)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::Transparent)

# Brushes
$bFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 50, 48))
$bDarkFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 38, 30, 28))
$bCloakBlack = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 25, 20, 25))
$bCloakTorn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 15, 12, 16))
$bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 200, 30))
$bRuby = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 30, 40))
$bRedEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 30, 30))
$bSkin = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 190, 130, 130))
$bTeeth = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 250, 250, 240))
$pClaw = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 240, 240), 2)

# 1. Dark Torn Black Cloak in Background
$g.FillPolygon($bCloakTorn, @(
    [System.Drawing.Point]::new(14, 20),
    [System.Drawing.Point]::new(4, 58),
    [System.Drawing.Point]::new(12, 54),
    [System.Drawing.Point]::new(20, 60),
    [System.Drawing.Point]::new(24, 26)
))
$g.FillPolygon($bCloakBlack, @(
    [System.Drawing.Point]::new(50, 20),
    [System.Drawing.Point]::new(60, 58),
    [System.Drawing.Point]::new(52, 54),
    [System.Drawing.Point]::new(44, 60),
    [System.Drawing.Point]::new(40, 26)
))

# 2. Giant Scaly Rat Tail
$pTail = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 160, 100, 100), 4)
$g.DrawArc($pTail, 2, 30, 24, 24, 90, 180)

# 3. Massive Muscular Legs & Claws (Standing Humanoid Stance)
$g.FillRectangle($bDarkFur, 18, 44, 9, 16)
$g.FillRectangle($bDarkFur, 37, 44, 9, 16)
$g.FillPolygon($bDarkFur, @([System.Drawing.Point]::new(15, 60), [System.Drawing.Point]::new(29, 60), [System.Drawing.Point]::new(27, 54), [System.Drawing.Point]::new(17, 54)))
$g.FillPolygon($bDarkFur, @([System.Drawing.Point]::new(35, 60), [System.Drawing.Point]::new(49, 60), [System.Drawing.Point]::new(47, 54), [System.Drawing.Point]::new(37, 54)))

# 4. Massive Natural Muscular Fur Torso
$g.FillRectangle($bFur, 16, 22, 32, 24)
# Cloak Collar across chest
$g.FillRectangle($bCloakBlack, 14, 20, 36, 6)
$g.FillEllipse($bRuby, 30, 21, 5, 5) # Ruby brooch

# 5. Bulky Muscular Arms & Sharp Claws
$g.FillRectangle($bFur, 10, 26, 8, 14)
$g.FillRectangle($bFur, 46, 26, 8, 14)
$g.FillEllipse($bFur, 8, 38, 10, 10)
$g.FillEllipse($bFur, 46, 38, 10, 10)
# Razor Claws
$g.DrawLine($pClaw, 8, 44, 4, 48)
$g.DrawLine($pClaw, 11, 46, 8, 52)
$g.DrawLine($pClaw, 54, 44, 58, 48)
$g.DrawLine($pClaw, 51, 46, 54, 52)

# 6. Menacing Rat King Head
$g.FillEllipse($bFur, 18, 8, 28, 20)
# Large Round Ears
$g.FillEllipse($bDarkFur, 12, 4, 12, 12)
$g.FillEllipse($bDarkFur, 40, 4, 12, 12)
$g.FillEllipse($bSkin, 15, 6, 6, 6)
$g.FillEllipse($bSkin, 43, 6, 6, 6)
# Snout & Razor Buckteeth
$g.FillPolygon($bFur, @([System.Drawing.Point]::new(25, 16), [System.Drawing.Point]::new(39, 16), [System.Drawing.Point]::new(32, 27)))
$g.FillEllipse($bSkin, 30, 24, 4, 3)
$g.FillRectangle($bTeeth, 29, 26, 3, 5)
$g.FillRectangle($bTeeth, 32, 26, 3, 5)

# 7. Glowing Crimson Battle Eyes
$g.FillEllipse($bRedEye, 23, 14, 6, 5)
$g.FillEllipse($bRedEye, 35, 14, 6, 5)
$bPupil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 230, 200))
$g.FillRectangle($bPupil, 25, 15, 2, 3)
$g.FillRectangle($bPupil, 37, 15, 2, 3)

# 8. Golden Ancient Crown with Rubies
$g.FillPolygon($bGold, @(
    [System.Drawing.Point]::new(22, 10),
    [System.Drawing.Point]::new(22, 1),
    [System.Drawing.Point]::new(27, 6),
    [System.Drawing.Point]::new(32, 0),
    [System.Drawing.Point]::new(37, 6),
    [System.Drawing.Point]::new(42, 1),
    [System.Drawing.Point]::new(42, 10)
))
$g.FillEllipse($bRuby, 26, 7, 3, 3)
$g.FillEllipse($bRuby, 31, 6, 3, 3)
$g.FillEllipse($bRuby, 36, 7, 3, 3)

$bmp.Save("$assetsDir\rat_boss.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "RAT_BOSS_SPRITE_CREATED"
