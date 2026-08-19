Add-Type -AssemblyName System.Drawing

$filePath = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\animations\Running\south\frame_000.png"
$img = [System.Drawing.Image]::FromFile($filePath)
Write-Output "Width: $($img.Width), Height: $($img.Height)"
$img.Dispose()
