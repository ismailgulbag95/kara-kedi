Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# 64x64 Solid Stone Wall Texture
$bmpWall = New-Object System.Drawing.Bitmap(64, 64)
$gfxWall = [System.Drawing.Graphics]::FromImage($bmpWall)
$bBase = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 35, 35, 45))
$bBrick1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 55, 55, 68))
$bBrick2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 45, 45, 56))
$pMortar = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 20, 20, 28), 2)
$bTorchGlow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 160, 40))

$gfxWall.FillRectangle($bBase, 0, 0, 64, 64)
# Bricks row 1
$gfxWall.FillRectangle($bBrick1, 2, 2, 28, 14)
$gfxWall.FillRectangle($bBrick2, 34, 2, 28, 14)
# Bricks row 2
$gfxWall.FillRectangle($bBrick2, 2, 18, 14, 14)
$gfxWall.FillRectangle($bBrick1, 18, 18, 28, 14)
$gfxWall.FillRectangle($bBrick2, 48, 18, 14, 14)
# Bricks row 3
$gfxWall.FillRectangle($bBrick1, 2, 34, 28, 14)
$gfxWall.FillRectangle($bBrick2, 34, 34, 28, 14)
# Bricks row 4
$gfxWall.FillRectangle($bBrick2, 2, 50, 14, 12)
$gfxWall.FillRectangle($bBrick1, 18, 50, 28, 12)
$gfxWall.FillRectangle($bBrick2, 48, 50, 14, 12)

# Mortar lines
$gfxWall.DrawLine($pMortar, 0, 16, 64, 16)
$gfxWall.DrawLine($pMortar, 0, 32, 64, 32)
$gfxWall.DrawLine($pMortar, 0, 48, 64, 48)

$bmpWall.Save("$assetsDir\tile_wall.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "TILE_WALL_GENERATED"
