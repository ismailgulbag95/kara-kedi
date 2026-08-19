Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# Anthro Humanoid Rat Warrior (48x48)
$bmpRatTank = New-Object System.Drawing.Bitmap(48, 48)
$gfxRatTank = [System.Drawing.Graphics]::FromImage($bmpRatTank)
$gfxRatTank.Clear([System.Drawing.Color]::Transparent)

$brushFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 85, 75, 70))
$brushDarkFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 55, 45, 42))
$brushArmor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 160, 50, 40))
$brushMetal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 110, 115, 130))
$brushSkin = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 150, 150))
$brushRedEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 40, 40))
$brushTeeth = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 240))

# 1. Thick Scaly Rat Tail in background
$penTail = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 190, 130, 130), 3)
$gfxRatTank.DrawArc($penTail, 2, 22, 16, 22, 90, 180)

# 2. Muscular Legs & Claws (Standing humanoid stance)
$gfxRatTank.FillRectangle($brushDarkFur, 13, 34, 7, 12)
$gfxRatTank.FillRectangle($brushDarkFur, 27, 34, 7, 12)
$gfxRatTank.FillPolygon($brushDarkFur, @(
    [System.Drawing.Point]::new(11, 46),
    [System.Drawing.Point]::new(21, 46),
    [System.Drawing.Point]::new(20, 42),
    [System.Drawing.Point]::new(13, 42)
))
$gfxRatTank.FillPolygon($brushDarkFur, @(
    [System.Drawing.Point]::new(26, 46),
    [System.Drawing.Point]::new(36, 46),
    [System.Drawing.Point]::new(34, 42),
    [System.Drawing.Point]::new(27, 42)
))

# 3. Bulky Humanoid Torso with Spiked Armor Breastplate
$gfxRatTank.FillRectangle($brushFur, 12, 18, 24, 18)
$gfxRatTank.FillRectangle($brushArmor, 14, 20, 20, 14)
$gfxRatTank.FillRectangle($brushMetal, 16, 23, 16, 8)
# Spiked Belt
$brushGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 160, 40))
$gfxRatTank.FillRectangle($brushGold, 13, 32, 22, 4)

# 4. Spiked Shoulder Pads (Pauldrons) & Bulky Arms
$gfxRatTank.FillEllipse($brushMetal, 7, 17, 10, 10)
$gfxRatTank.FillEllipse($brushMetal, 31, 17, 10, 10)
$gfxRatTank.FillPolygon($brushArmor, @(
    [System.Drawing.Point]::new(7, 17),
    [System.Drawing.Point]::new(12, 11),
    [System.Drawing.Point]::new(17, 17)
))
$gfxRatTank.FillPolygon($brushArmor, @(
    [System.Drawing.Point]::new(31, 17),
    [System.Drawing.Point]::new(36, 11),
    [System.Drawing.Point]::new(41, 17)
))
# Forearms with iron spiked gauntlets
$gfxRatTank.FillRectangle($brushFur, 8, 24, 6, 10)
$gfxRatTank.FillRectangle($brushFur, 34, 24, 6, 10)
$gfxRatTank.FillEllipse($brushMetal, 6, 30, 8, 8)
$gfxRatTank.FillEllipse($brushMetal, 34, 30, 8, 8)

# 5. Fierce Ratman Head
$gfxRatTank.FillEllipse($brushFur, 14, 6, 20, 16)
# Big Round Rat Ears
$gfxRatTank.FillEllipse($brushDarkFur, 10, 2, 9, 9)
$gfxRatTank.FillEllipse($brushDarkFur, 29, 2, 9, 9)
$gfxRatTank.FillEllipse($brushSkin, 12, 4, 5, 5)
$gfxRatTank.FillEllipse($brushSkin, 31, 4, 5, 5)
# Snout & Muzzle
$gfxRatTank.FillPolygon($brushFur, @(
    [System.Drawing.Point]::new(19, 13),
    [System.Drawing.Point]::new(29, 13),
    [System.Drawing.Point]::new(24, 21)
))
$gfxRatTank.FillEllipse($brushSkin, 22, 18, 4, 3)
# Protruding Sharp Buckteeth
$gfxRatTank.FillRectangle($brushTeeth, 22, 20, 2, 4)
$gfxRatTank.FillRectangle($brushTeeth, 24, 20, 2, 4)

# 6. Glowing Red Battle Eyes & Scar
$gfxRatTank.FillEllipse($brushRedEye, 17, 10, 5, 4)
$gfxRatTank.FillEllipse($brushRedEye, 26, 10, 5, 4)
$brushDarkEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 0, 0))
$gfxRatTank.FillRectangle($brushDarkEye, 19, 10, 2, 4)
$gfxRatTank.FillRectangle($brushDarkEye, 27, 10, 2, 4)
# Battle Scar across right eye
$penScar = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 230, 70, 70), 1)
$gfxRatTank.DrawLine($penScar, 15, 7, 21, 15)

$bmpRatTank.Save("$assetsDir\rat_tank.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "ANTHRO_RAT_TANK_SPRITE_CREATED"
