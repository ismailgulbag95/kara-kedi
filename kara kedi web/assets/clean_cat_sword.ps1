Add-Type -AssemblyName System.Drawing

$rotDir = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\rotations"
$animDir = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\animations\Running"

# Script to replace sword blade pixels (silver/gray #A0..#E0, blade guards) with transparent or fur
function Clean-Sword-From-Image($path) {
    if (!(Test-Path $path)) { return }
    $bmp = [System.Drawing.Bitmap]::FromFile($path)
    $cleanBmp = New-Object System.Drawing.Bitmap($bmp.Width, $bmp.Height)
    
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        for ($y = 0; $y -lt $bmp.Height; $y++) {
            $col = $bmp.GetPixel($x, $y)
            if ($col.A -gt 20) {
                # Detect sword blade pixels: bright steel silver / light metallic grey / thin blade lines
                $isBlade = ($col.R -gt 150 -and $col.G -gt 150 -and $col.B -gt 150 -and [Math]::Abs($col.R - $col.G) -lt 25 -and [Math]::Abs($col.G - $col.B) -lt 25)
                # Exclude eyes (which are green/yellow) or feather (which is at top y < 10)
                if ($isBlade -and $y -gt 14 -and ($x -lt 20 -or $x -gt 28)) {
                    # Erase sword pixel (make transparent)
                    $cleanBmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
                } else {
                    $cleanBmp.SetPixel($x, $y, $col)
                }
            } else {
                $cleanBmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
            }
        }
    }
    $bmp.Dispose()
    $cleanBmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $cleanBmp.Dispose()
}

Get-ChildItem $rotDir -Filter "*.png" | ForEach-Object { Clean-Sword-From-Image $_.FullName }
Get-ChildItem $animDir -Recurse -Filter "*.png" | ForEach-Object { Clean-Sword-From-Image $_.FullName }
Write-Output "SWORD_PIXELS_CLEANED_SUCCESSFULLY"
