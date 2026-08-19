Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 1. Claws (32x32)
$bmpClaws = New-Object System.Drawing.Bitmap(32, 32)
$gfxClaws = [System.Drawing.Graphics]::FromImage($bmpClaws)
$gfxClaws.Clear([System.Drawing.Color]::Transparent)
$penClaw = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 240, 255), 2)
$brushGrip = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 50, 40))
$gfxClaws.FillEllipse($brushGrip, 6, 18, 12, 10)
# 3 curved razor claws
$gfxClaws.DrawArc($penClaw, 4, 2, 16, 20, 200, 100)
$gfxClaws.DrawArc($penClaw, 10, 4, 16, 20, 200, 100)
$gfxClaws.DrawArc($penClaw, 16, 8, 16, 20, 200, 100)
$bmpClaws.Save("$assetsDir\claws.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 2. Fish Bone Boomerang (32x32)
$bmpFish = New-Object System.Drawing.Bitmap(32, 32)
$gfxFish = [System.Drawing.Graphics]::FromImage($bmpFish)
$gfxFish.Clear([System.Drawing.Color]::Transparent)
$penBone = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 235, 245, 255), 2)
$brushBone = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 230, 250))
$brushEye = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 120, 220))
# Spine line
$gfxFish.DrawLine($penBone, 4, 26, 26, 6)
# Fish head
$gfxFish.FillPolygon($brushBone, @(
    [System.Drawing.Point]::new(24, 8),
    [System.Drawing.Point]::new(30, 2),
    [System.Drawing.Point]::new(22, 2)
))
$gfxFish.FillEllipse($brushEye, 25, 4, 3, 3)
# Rib bones
$gfxFish.DrawLine($penBone, 18, 14, 24, 18)
$gfxFish.DrawLine($penBone, 14, 18, 20, 22)
$gfxFish.DrawLine($penBone, 10, 22, 16, 26)
$gfxFish.DrawLine($penBone, 16, 12, 12, 6)
$gfxFish.DrawLine($penBone, 12, 16, 8, 10)
$bmpFish.Save("$assetsDir\fish_bone.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 3. Yarn Bomb (32x32)
$bmpYarn = New-Object System.Drawing.Bitmap(32, 32)
$gfxYarn = [System.Drawing.Graphics]::FromImage($bmpYarn)
$gfxYarn.Clear([System.Drawing.Color]::Transparent)
$brushYarn = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 230, 60, 110))
$penThread = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 140, 180), 2)
$gfxYarn.FillEllipse($brushYarn, 6, 6, 20, 20)
$gfxYarn.DrawArc($penThread, 8, 8, 16, 16, 30, 160)
$gfxYarn.DrawArc($penThread, 6, 10, 18, 12, 120, 180)
# Fuse / loose string
$penFuse = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 220, 80), 2)
$gfxYarn.DrawLine($penFuse, 18, 6, 26, 2)
$bmpYarn.Save("$assetsDir\yarn_bomb.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "NEW_WEAPONS_TEXTURES_CREATED"
