$html = Get-Content -Raw "Kara_Kedi_Web_Surumu.html"
$dirs = @("south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west")
$missing = 0
$found = 0
foreach ($d in $dirs) {
    if ($html.Contains("hero_rot_$d")) {
        $found++
    } else {
        Write-Host "Missing rotation: $d"
        $missing++
    }
    for ($f = 0; $f -lt 8; $f++) {
        if ($html.Contains("hero_run_${d}_$f")) {
            $found++
        } else {
            Write-Host "Missing run frame: hero_run_${d}_$f"
            $missing++
        }
    }
}
Write-Host "Verification result: $found assets found, $missing missing."
