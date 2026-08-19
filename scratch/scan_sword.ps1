Add-Type -AssemblyName System.Drawing

$f = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\animations\Running\south\frame_000.png"
$bmp = [System.Drawing.Bitmap]::FromFile($f)

Write-Output "Scanning marksman frame_000.png..."
for ($y = 0; $y -lt $bmp.Height; $y++) {
    $line = ""
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 20) {
            if ($p.R -gt 200 -and $p.G -gt 180 -and $p.B -lt 50) {
                # Gold / bullet / buckle
                $line += "G"
            } elseif ($p.R -lt 60 -and $p.G -lt 60 -and $p.B -lt 60) {
                # Dark gun / hat crease / patch
                $line += "X"
            } elseif ($p.R -gt $p.B) {
                # Brown hat / lynx fur
                $line += "M"
            } else {
                $line += "."
            }
        } else {
            $line += " "
        }
    }
    if ($line.Trim().Length -gt 0) {
        Write-Output ("{0:D2}: {1}" -f $y, $line)
    }
}
$bmp.Dispose()
