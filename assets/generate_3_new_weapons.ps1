Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"
$itemsDir = "d:\benim antigravitiler\kara kedi\assets\textures\items"

# --- 1. MAGNUM REVOLVER (Silver Steel & Wooden Grip) ---
$bmpMagnum = New-Object System.Drawing.Bitmap(32, 32)
$g = [System.Drawing.Graphics]::FromImage($bmpMagnum)
$g.Clear([System.Drawing.Color]::Transparent)
$bSilver = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 215, 225))
$bDarkSteel = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 130, 145))
$bWood = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 150, 75, 30))
# Barrel & Cylinder
$g.FillRectangle($bSilver, 8, 10, 18, 5)
$g.FillRectangle($bDarkSteel, 10, 9, 8, 7) # Cylinder
$g.FillRectangle($bWood, 4, 14, 6, 10) # Grip
$g.FillRectangle($bDarkSteel, 8, 15, 3, 4) # Trigger guard
$bmpMagnum.Save("$assetsDir\magnum.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Copy to items
$bmpMagnumItem = New-Object System.Drawing.Bitmap(48, 48)
$gi = [System.Drawing.Graphics]::FromImage($bmpMagnumItem)
$gi.Clear([System.Drawing.Color]::Transparent)
$gi.DrawImage($bmpMagnum, 4, 4, 40, 40)
$bmpMagnumItem.Save("$itemsDir\weapon_magnum.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Magnum Bullet (Heavy Golden Slug)
$bmpSlug = New-Object System.Drawing.Bitmap(16, 16)
$gs = [System.Drawing.Graphics]::FromImage($bmpSlug)
$gs.Clear([System.Drawing.Color]::Transparent)
$bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 210, 50))
$bOrange = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 120, 20))
$gs.FillEllipse($bOrange, 2, 4, 12, 8)
$gs.FillEllipse($bGold, 4, 5, 8, 6)
$bmpSlug.Save("$assetsDir\bullet_magnum.png", [System.Drawing.Imaging.ImageFormat]::Png)

# --- 2. GLOCK PISTOL (Matte Black Compact Pistol) ---
$bmpGlock = New-Object System.Drawing.Bitmap(32, 32)
$g2 = [System.Drawing.Graphics]::FromImage($bmpGlock)
$g2.Clear([System.Drawing.Color]::Transparent)
$bBlack = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 45, 45, 52))
$bCharcoal = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 75, 75, 85))
# Slide & Grip
$g2.FillRectangle($bCharcoal, 8, 11, 16, 5)
$g2.FillRectangle($bBlack, 6, 14, 6, 9)
$g2.FillRectangle($bCharcoal, 10, 15, 3, 3)
$bmpGlock.Save("$assetsDir\glock.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Copy to items
$bmpGlockItem = New-Object System.Drawing.Bitmap(48, 48)
$g2i = [System.Drawing.Graphics]::FromImage($bmpGlockItem)
$g2i.Clear([System.Drawing.Color]::Transparent)
$g2i.DrawImage($bmpGlock, 4, 4, 40, 40)
$bmpGlockItem.Save("$itemsDir\weapon_glock.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Glock Bullet (Fast Yellow Spark Bullet)
$bmpGlockBullet = New-Object System.Drawing.Bitmap(14, 14)
$g2b = [System.Drawing.Graphics]::FromImage($bmpGlockBullet)
$g2b.Clear([System.Drawing.Color]::Transparent)
$bYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 240, 90))
$g2b.FillEllipse($bYellow, 2, 4, 10, 6)
$bmpGlockBullet.Save("$assetsDir\bullet_glock.png", [System.Drawing.Imaging.ImageFormat]::Png)

# --- 3. HUNTER'S BOW & ARROW (Wooden Bow & Feathered Arrow) ---
$bmpBow = New-Object System.Drawing.Bitmap(32, 32)
$g3 = [System.Drawing.Graphics]::FromImage($bmpBow)
$g3.Clear([System.Drawing.Color]::Transparent)
$pWood = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 170, 100, 45), 3)
$pString = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 240, 240, 240), 1)
$g3.DrawArc($pWood, 4, 4, 20, 24, -90, 180)
$g3.DrawLine($pString, 14, 4, 14, 28)
$bmpBow.Save("$assetsDir\bow.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Copy to items
$bmpBowItem = New-Object System.Drawing.Bitmap(48, 48)
$g3i = [System.Drawing.Graphics]::FromImage($bmpBowItem)
$g3i.Clear([System.Drawing.Color]::Transparent)
$g3i.DrawImage($bmpBow, 4, 4, 40, 40)
$bmpBowItem.Save("$itemsDir\weapon_bow.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Arrow (Shaft, Iron Tip, White Fletching)
$bmpArrow = New-Object System.Drawing.Bitmap(24, 24)
$ga = [System.Drawing.Graphics]::FromImage($bmpArrow)
$ga.Clear([System.Drawing.Color]::Transparent)
$pShaft = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 160, 95, 40), 2)
$bTip = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 220, 225, 235))
$bFeather = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 245, 255))
$ga.DrawLine($pShaft, 4, 12, 18, 12)
$ga.FillPolygon($bTip, @([System.Drawing.Point]::new(22, 12), [System.Drawing.Point]::new(17, 9), [System.Drawing.Point]::new(17, 15)))
$ga.FillPolygon($bFeather, @([System.Drawing.Point]::new(4, 12), [System.Drawing.Point]::new(1, 8), [System.Drawing.Point]::new(3, 12), [System.Drawing.Point]::new(1, 16)))
$bmpArrow.Save("$assetsDir\arrow.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "ALL_3_NEW_WEAPONS_TEXTURES_CREATED"
