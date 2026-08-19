Add-Type -AssemblyName System.Drawing

$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"
New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

# 1. Floor Tile (64x64)
$bmpFloor = New-Object System.Drawing.Bitmap(64, 64)
$gfxFloor = [System.Drawing.Graphics]::FromImage($bmpFloor)
$gfxFloor.Clear([System.Drawing.Color]::FromArgb(255, 26, 26, 36))
$penGrid = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 38, 38, 52), 1)
$gfxFloor.DrawRectangle($penGrid, 0, 0, 63, 63)
$brushDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 45, 45, 65))
$gfxFloor.FillRectangle($brushDot, 12, 12, 4, 4)
$gfxFloor.FillRectangle($brushDot, 48, 48, 4, 4)
$bmpFloor.Save("$assetsDir\tile_floor.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Player (Black Cat Warrior) (48x48)
$bmpCat = New-Object System.Drawing.Bitmap(48, 48)
$gfxCat = [System.Drawing.Graphics]::FromImage($bmpCat)
$gfxCat.Clear([System.Drawing.Color]::Transparent)
# Body (Black / Dark Slate)
$brushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 18, 22))
$brushCape = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 40, 50))
$brushGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 204, 0))
$brushMuzzle = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 230, 240))
$brushEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 76, 217, 100))
# Cape in back
$gfxCat.FillPolygon($brushCape, @(
    [System.Drawing.Point]::new(14, 24),
    [System.Drawing.Point]::new(34, 24),
    [System.Drawing.Point]::new(38, 44),
    [System.Drawing.Point]::new(10, 44)
))
# Torso & Legs
$gfxCat.FillRectangle($brushDark, 16, 20, 16, 18)
$gfxCat.FillRectangle($brushDark, 16, 38, 6, 8)
$gfxCat.FillRectangle($brushDark, 26, 38, 6, 8)
# Gold Belt
$gfxCat.FillRectangle($brushGold, 15, 30, 18, 4)
# Head
$gfxCat.FillEllipse($brushDark, 14, 8, 20, 18)
# Cat Ears
$gfxCat.FillPolygon($brushDark, @(
    [System.Drawing.Point]::new(14, 12),
    [System.Drawing.Point]::new(18, 2),
    [System.Drawing.Point]::new(22, 10)
))
$gfxCat.FillPolygon($brushDark, @(
    [System.Drawing.Point]::new(26, 10),
    [System.Drawing.Point]::new(30, 2),
    [System.Drawing.Point]::new(34, 12)
))
# Inner ears
$brushInnerEar = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 220, 120, 140))
$gfxCat.FillPolygon($brushInnerEar, @(
    [System.Drawing.Point]::new(16, 11),
    [System.Drawing.Point]::new(18, 5),
    [System.Drawing.Point]::new(20, 10)
))
$gfxCat.FillPolygon($brushInnerEar, @(
    [System.Drawing.Point]::new(28, 10),
    [System.Drawing.Point]::new(30, 5),
    [System.Drawing.Point]::new(32, 11)
))
# Glowing Eyes
$gfxCat.FillEllipse($brushEye, 17, 14, 5, 4)
$gfxCat.FillEllipse($brushEye, 26, 14, 5, 4)
$brushPupil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 10, 10))
$gfxCat.FillRectangle($brushPupil, 19, 14, 2, 4)
$gfxCat.FillRectangle($brushPupil, 28, 14, 2, 4)
# Muzzle & Nose
$gfxCat.FillEllipse($brushMuzzle, 21, 18, 6, 4)
$brushNose = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 100, 130))
$gfxCat.FillRectangle($brushNose, 23, 18, 2, 2)
# Whiskers
$penWhisker = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 220, 220, 230), 1)
$gfxCat.DrawLine($penWhisker, 12, 19, 20, 19)
$gfxCat.DrawLine($penWhisker, 12, 22, 20, 21)
$gfxCat.DrawLine($penWhisker, 28, 19, 36, 19)
$gfxCat.DrawLine($penWhisker, 28, 21, 36, 22)
$bmpCat.Save("$assetsDir\player.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 3. Sword (32x32)
$bmpSword = New-Object System.Drawing.Bitmap(32, 32)
$gfxSword = [System.Drawing.Graphics]::FromImage($bmpSword)
$gfxSword.Clear([System.Drawing.Color]::Transparent)
$brushBlade = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 240, 255))
$brushEdge = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 180, 255))
$brushHilt = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 190, 40))
$brushGrip = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 110, 50, 20))
# Blade angled along diagonal
$gfxSword.FillPolygon($brushBlade, @(
    [System.Drawing.Point]::new(14, 14),
    [System.Drawing.Point]::new(28, 2),
    [System.Drawing.Point]::new(30, 4),
    [System.Drawing.Point]::new(18, 18)
))
$gfxSword.FillPolygon($brushEdge, @(
    [System.Drawing.Point]::new(16, 16),
    [System.Drawing.Point]::new(30, 2),
    [System.Drawing.Point]::new(30, 4),
    [System.Drawing.Point]::new(18, 18)
))
# Guard / Hilt
$gfxSword.FillRectangle($brushHilt, 11, 15, 8, 4)
# Grip
$gfxSword.FillPolygon($brushGrip, @(
    [System.Drawing.Point]::new(13, 17),
    [System.Drawing.Point]::new(16, 14),
    [System.Drawing.Point]::new(8, 22),
    [System.Drawing.Point]::new(5, 25)
))
# Pommel
$gfxSword.FillEllipse($brushHilt, 3, 24, 5, 5)
$bmpSword.Save("$assetsDir\sword.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 4. Small Rat (Scout) (32x32)
$bmpRatSmall = New-Object System.Drawing.Bitmap(32, 32)
$gfxRatSmall = [System.Drawing.Graphics]::FromImage($bmpRatSmall)
$gfxRatSmall.Clear([System.Drawing.Color]::Transparent)
$brushRatFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 100, 90))
$brushRatEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 50, 50))
$brushTail = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 140, 140))
# Tail
$gfxRatSmall.FillPolygon($brushTail, @(
    [System.Drawing.Point]::new(4, 20),
    [System.Drawing.Point]::new(8, 18),
    [System.Drawing.Point]::new(2, 28)
))
# Body
$gfxRatSmall.FillEllipse($brushRatFur, 8, 10, 16, 12)
# Head & Snout
$gfxRatSmall.FillPolygon($brushRatFur, @(
    [System.Drawing.Point]::new(18, 11),
    [System.Drawing.Point]::new(28, 16),
    [System.Drawing.Point]::new(18, 21)
))
# Ears
$gfxRatSmall.FillEllipse($brushTail, 16, 6, 6, 6)
# Eye
$gfxRatSmall.FillEllipse($brushRatEye, 21, 13, 3, 3)
# Teeth
$brushTeeth = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$gfxRatSmall.FillRectangle($brushTeeth, 26, 17, 2, 3)
$bmpRatSmall.Save("$assetsDir\rat_small.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 5. Tank Rat (Brute) (48x48)
$bmpRatTank = New-Object System.Drawing.Bitmap(48, 48)
$gfxRatTank = [System.Drawing.Graphics]::FromImage($bmpRatTank)
$gfxRatTank.Clear([System.Drawing.Color]::Transparent)
$brushTankFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 75, 65, 60))
$brushArmorPlates = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 140, 45, 35))
# Heavy Body
$gfxRatTank.FillEllipse($brushTankFur, 8, 10, 30, 26)
$gfxRatTank.FillPolygon($brushArmorPlates, @(
    [System.Drawing.Point]::new(14, 10),
    [System.Drawing.Point]::new(32, 10),
    [System.Drawing.Point]::new(36, 24),
    [System.Drawing.Point]::new(10, 24)
))
# Snout
$gfxRatTank.FillPolygon($brushTankFur, @(
    [System.Drawing.Point]::new(26, 16),
    [System.Drawing.Point]::new(44, 24),
    [System.Drawing.Point]::new(26, 32)
))
# Red glowing scars / eye
$gfxRatTank.FillEllipse($brushRatEye, 32, 19, 5, 4)
$gfxRatTank.FillRectangle($brushTeeth, 40, 25, 4, 5)
$bmpRatTank.Save("$assetsDir\rat_tank.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 6. Spitter Rat (36x36)
$bmpRatSpitter = New-Object System.Drawing.Bitmap(36, 36)
$gfxRatSpitter = [System.Drawing.Graphics]::FromImage($bmpRatSpitter)
$gfxRatSpitter.Clear([System.Drawing.Color]::Transparent)
$brushSpitFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 90, 70))
$brushVenom = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 230, 50))
$gfxRatSpitter.FillEllipse($brushSpitFur, 6, 10, 20, 16)
$gfxRatSpitter.FillPolygon($brushSpitFur, @(
    [System.Drawing.Point]::new(18, 12),
    [System.Drawing.Point]::new(32, 18),
    [System.Drawing.Point]::new(18, 24)
))
# Venom sac on neck
$gfxRatSpitter.FillEllipse($brushVenom, 14, 18, 10, 8)
$gfxRatSpitter.FillEllipse($brushVenom, 24, 14, 4, 4)
$bmpRatSpitter.Save("$assetsDir\rat_spitter.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 7. Dasher Rat (Avcı) (36x36)
$bmpRatDasher = New-Object System.Drawing.Bitmap(36, 36)
$gfxRatDasher = [System.Drawing.Graphics]::FromImage($bmpRatDasher)
$gfxRatDasher.Clear([System.Drawing.Color]::Transparent)
$brushDashFur = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 160, 85, 30))
$brushStripes = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 70, 30, 10))
$gfxRatDasher.FillEllipse($brushDashFur, 6, 10, 22, 14)
$gfxRatDasher.FillRectangle($brushStripes, 12, 10, 3, 14)
$gfxRatDasher.FillRectangle($brushStripes, 18, 10, 3, 14)
$gfxRatDasher.FillPolygon($brushDashFur, @(
    [System.Drawing.Point]::new(20, 11),
    [System.Drawing.Point]::new(34, 17),
    [System.Drawing.Point]::new(20, 23)
))
$gfxRatDasher.FillEllipse($brushGold, 26, 13, 4, 3)
$bmpRatDasher.Save("$assetsDir\rat_dasher.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 8. Green Coin (20x20)
$bmpCoin = New-Object System.Drawing.Bitmap(20, 20)
$gfxCoin = [System.Drawing.Graphics]::FromImage($bmpCoin)
$gfxCoin.Clear([System.Drawing.Color]::Transparent)
$brushEmerald = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 230, 118))
$brushGlow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 185, 255, 205))
$brushDarkEmerald = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 150, 70))
$gfxCoin.FillEllipse($brushDarkEmerald, 2, 2, 16, 16)
$gfxCoin.FillEllipse($brushEmerald, 4, 4, 12, 12)
$gfxCoin.FillEllipse($brushGlow, 6, 6, 4, 4)
$bmpCoin.Save("$assetsDir\coin_green.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 9. Acid Spit Projectile (16x16)
$bmpAcid = New-Object System.Drawing.Bitmap(16, 16)
$gfxAcid = [System.Drawing.Graphics]::FromImage($bmpAcid)
$gfxAcid.Clear([System.Drawing.Color]::Transparent)
$gfxAcid.FillEllipse($brushVenom, 2, 2, 12, 12)
$brushAcidCore = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 220, 255, 100))
$gfxAcid.FillEllipse($brushAcidCore, 5, 5, 6, 6)
$bmpAcid.Save("$assetsDir\projectile_acid.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "ALL_TEXTURES_GENERATED_SUCCESSFULLY"
