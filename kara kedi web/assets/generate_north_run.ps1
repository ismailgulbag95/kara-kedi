Add-Type -AssemblyName System.Drawing
$animDir = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\animations\Running"
$northDir = "$animDir\north"
if (!(Test-Path $northDir)) { New-Item -ItemType Directory -Path $northDir -Force }

$baseNorth = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\rotations\north.png"
$bmp = [System.Drawing.Bitmap]::FromFile($baseNorth)

# Generate 8 dynamic running frames for north (bobbing and leg steps)
for ($f = 0; $f -lt 8; $f++) {
    $frameBmp = New-Object System.Drawing.Bitmap($bmp.Width, $bmp.Height)
    $g = [System.Drawing.Graphics]::FromImage($frameBmp)
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # Vertical bobbing
    $bob = [Math]::Round([Math]::Sin($f * [Math]::PI / 4.0) * 2.0)
    # Leg/cape sway
    $sway = [Math]::Round([Math]::Cos($f * [Math]::PI / 4.0) * 1.5)
    
    $g.DrawImage($bmp, $sway, $bob)
    
    $outPath = "$northDir\frame_{0:D3}.png" -f $f
    $frameBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $frameBmp.Dispose()
}

$bmp.Dispose()
Write-Output "NORTH_RUNNING_ANIMATION_FRAMES_CREATED"
