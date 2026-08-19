Add-Type -AssemblyName System.Drawing
$uiDir = "d:\benim antigravitiler\kara kedi\assets\textures\ui"
if (!(Test-Path $uiDir)) { New-Item -ItemType Directory -Path $uiDir -Force }

# --- 1. CLOSED GOLDEN PADLOCK (lock_closed.png - 32x32) ---
$bmpClosed = New-Object System.Drawing.Bitmap(32, 32)
$g1 = [System.Drawing.Graphics]::FromImage($bmpClosed)
$g1.Clear([System.Drawing.Color]::Transparent)

# Shackle (Steel loop, closed)
$pSteel = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 200, 205, 215), 3)
$g1.DrawArc($pSteel, 9, 4, 14, 14, 180, 180)
$g1.DrawLine($pSteel, 9, 11, 9, 15)
$g1.DrawLine($pSteel, 23, 11, 23, 15)

# Golden Body
$bGold = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 245, 190, 35))
$bGoldDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 180, 130, 15))
$bKeyhole = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 40, 25, 10))

$g1.FillRectangle($bGoldDark, 6, 14, 20, 15)
$g1.FillRectangle($bGold, 7, 15, 18, 13)
# Keyhole
$g1.FillEllipse($bKeyhole, 14, 18, 4, 4)
$g1.FillPolygon($bKeyhole, @([System.Drawing.Point]::new(14, 20), [System.Drawing.Point]::new(18, 20), [System.Drawing.Point]::new(17, 24), [System.Drawing.Point]::new(15, 24)))

$bmpClosed.Save("$uiDir\lock_closed.png", [System.Drawing.Imaging.ImageFormat]::Png)

# --- 2. OPEN SILVER/STEEL PADLOCK (lock_open.png - 32x32) ---
$bmpOpen = New-Object System.Drawing.Bitmap(32, 32)
$g2 = [System.Drawing.Graphics]::FromImage($bmpOpen)
$g2.Clear([System.Drawing.Color]::Transparent)

# Open Shackle (Lifted and rotated)
$g2.DrawArc($pSteel, 9, 1, 14, 14, 180, 180)
$g2.DrawLine($pSteel, 9, 8, 9, 15) # Left inserted
$g2.DrawLine($pSteel, 23, 8, 23, 11) # Right open

# Steel/Bronze Body (Open State)
$bSilverDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 110, 120, 135))
$bSilver = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 175, 185, 200))

$g2.FillRectangle($bSilverDark, 6, 14, 20, 15)
$g2.FillRectangle($bSilver, 7, 15, 18, 13)
# Keyhole
$g2.FillEllipse($bKeyhole, 14, 18, 4, 4)
$g2.FillPolygon($bKeyhole, @([System.Drawing.Point]::new(14, 20), [System.Drawing.Point]::new(18, 20), [System.Drawing.Point]::new(17, 24), [System.Drawing.Point]::new(15, 24)))

$bmpOpen.Save("$uiDir\lock_open.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "LOCK_PIXEL_ART_TEXTURES_CREATED"
