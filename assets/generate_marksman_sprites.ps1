Add-Type -AssemblyName System.Drawing

$srcDir = "d:\benim antigravitiler\kara kedi\assets\textures\player_character"
$destDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman"

# Ensure directories exist
New-Item -ItemType Directory -Path "$destDir\rotations" -Force | Out-Null
New-Item -ItemType Directory -Path "$destDir\animations\Running" -Force | Out-Null

$directions = @("east", "north", "north-east", "north-west", "south", "south-east", "south-west", "west")
foreach ($d in $directions) {
    New-Item -ItemType Directory -Path "$destDir\animations\Running\$d" -Force | Out-Null
}

function Build-Gunslinger-Frame {
    param (
        [string]$srcPath,
        [string]$dstPath,
        [string]$direction
    )

    if (-not (Test-Path $srcPath)) { return }

    $srcBmp = [System.Drawing.Bitmap]::FromFile($srcPath)
    $w = $srcBmp.Width
    $h = $srcBmp.Height
    $dstBmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

    # Copy src pixels to 2D array
    $grid = New-Object 'int[,]' $w, $h
    $alpha = New-Object 'int[,]' $w, $h

    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $p = $srcBmp.GetPixel($x, $y)
            $alpha[$x, $y] = $p.A
            if ($p.A -gt 25) {
                # Brightness
                $grid[$x, $y] = [int](($p.R + $p.G + $p.B) / 3.0)
            } else {
                $grid[$x, $y] = -1
            }
        }
    }
    $srcBmp.Dispose()

    # 1. REMOVE SWORD BLADE / HILT PIXELS
    # The sword blade is the thin diagonal stick on the left (x <= 18, y <= 27)
    for ($y = 0; $y -le 27; $y++) {
        for ($x = 0; $x -le 19; $x++) {
            if ($grid[$x, $y] -ge 0) {
                # Check if this pixel is disconnected from main cat head/torso (main head is at x >= 20)
                $connectedToBody = $false
                for ($dx = 1; $dx -le 3; $dx++) {
                    if (($x + $dx) -lt $w -and $grid[$x + $dx, $y] -ge 0) {
                        if (($x + $dx) -ge 20) { $connectedToBody = $true; break }
                    }
                }
                if (-not $connectedToBody -and $x -le 16) {
                    $grid[$x, $y] = -1
                    $alpha[$x, $y] = 0
                }
            }
        }
    }

    # Find cat body bounding box
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            if ($grid[$x, $y] -ge 0) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }

    if ($minX -ge $maxX) { $minX = 16; $maxX = 32; $minY = 6; $maxY = 42 }
    $headCenterX = [int](($minX + $maxX) / 2)
    $headTopY = $minY

    # 2. RENDER LYNX / DESERT FUR BASE
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $br = $grid[$x, $y]
            if ($br -ge 0) {
                $a = $alpha[$x, $y]
                if ($br -lt 35) {
                    # Dark outline / markings
                    $col = [System.Drawing.Color]::FromArgb($a, 48, 28, 14)
                } elseif ($br -lt 75) {
                    # Dark shadow tan fur
                    $col = [System.Drawing.Color]::FromArgb($a, 120, 75, 42)
                } elseif ($br -lt 125) {
                    # Base Lynx Tan
                    $col = [System.Drawing.Color]::FromArgb($a, 185, 125, 75)
                } else {
                    # Cream muzzle / highlight fur
                    $col = [System.Drawing.Color]::FromArgb($a, 235, 195, 155)
                }
                $dstBmp.SetPixel($x, $y, $col)
            } else {
                $dstBmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
            }
        }
    }

    # 3. DRAW PROMINENT BROWN COWBOY HAT (Across width 14..36, height topY-6..topY+3)
    $hatW = [Math]::Min(22, ($maxX - $minX + 8))
    $hatStartX = $headCenterX - [int]($hatW / 2)
    $hatBrimY = [Math]::Max(4, $headTopY + 2)
    $hatCrownY = [Math]::Max(1, $hatBrimY - 5)

    # Crown (Tepe Kısmı)
    $crownW = [int]($hatW * 0.6)
    $crownStartX = $headCenterX - [int]($crownW / 2)

    for ($cy = $hatCrownY; $cy -le $hatBrimY; $cy++) {
        for ($cx = $crownStartX; $cx -lt ($crownStartX + $crownW); $cx++) {
            if ($cx -ge 0 -and $cx -lt $w -and $cy -ge 0 -and $cy -lt $h) {
                if ($cy -eq $hatCrownY) {
                    # Hat Crown top crease
                    $dstBmp.SetPixel($cx, $cy, [System.Drawing.Color]::FromArgb(255, 95, 55, 26))
                } elseif ($cy -eq ($hatBrimY - 1)) {
                    # Gold Buckle Band
                    $isBuckle = ($cx -ge ($headCenterX - 1) -and $cx -le ($headCenterX + 1))
                    $col = if ($isBuckle) { [System.Drawing.Color]::FromArgb(255, 255, 215, 0) } else { [System.Drawing.Color]::FromArgb(255, 30, 20, 15) }
                    $dstBmp.SetPixel($cx, $cy, $col)
                } else {
                    # Crown Body
                    $dstBmp.SetPixel($cx, $cy, [System.Drawing.Color]::FromArgb(255, 135, 82, 42))
                }
            }
        }
    }

    # Brim (Geniş Kıvrık Kenarlık)
    for ($bx = $hatStartX; $bx -lt ($hatStartX + $hatW); $bx++) {
        if ($bx -ge 0 -and $bx -lt $w) {
            $isEdge = ($bx -eq $hatStartX -or $bx -eq ($hatStartX + $hatW - 1))
            $by = if ($isEdge) { $hatBrimY - 1 } else { $hatBrimY }
            if ($by -ge 0 -and $by -lt $h) {
                # Brim shadow underneath
                $dstBmp.SetPixel($bx, $by, [System.Drawing.Color]::FromArgb(255, 78, 44, 20))
                if (($by + 1) -lt $h -and -not $isEdge) {
                    $dstBmp.SetPixel($bx, $by + 1, [System.Drawing.Color]::FromArgb(255, 55, 30, 14))
                }
            }
        }
    }

    # 4. DRAW LYNX EAR TUFTS POKING OUT OF HAT
    # Left lynx ear tip
    $earLeftX = $crownStartX - 1
    $earRightX = $crownStartX + $crownW
    if ($earLeftX -ge 0 -and ($hatCrownY - 2) -ge 0) {
        $dstBmp.SetPixel($earLeftX, $hatCrownY - 1, [System.Drawing.Color]::FromArgb(255, 185, 125, 75))
        $dstBmp.SetPixel($earLeftX, $hatCrownY - 2, [System.Drawing.Color]::FromArgb(255, 25, 25, 25)) # Black tuft
    }
    if ($earRightX -lt $w -and ($hatCrownY - 2) -ge 0) {
        $dstBmp.SetPixel($earRightX, $hatCrownY - 1, [System.Drawing.Color]::FromArgb(255, 185, 125, 75))
        $dstBmp.SetPixel($earRightX, $hatCrownY - 2, [System.Drawing.Color]::FromArgb(255, 25, 25, 25)) # Black tuft
    }

    # 5. DRAW BANDOLIER (Çapraz Deri Fişeklik & Altın Mermiler)
    if ($direction -ne "north") {
        $bStart = $headTopY + 11
        for ($i = 0; $i -lt 8; $i++) {
            $bx = $headCenterX - 4 + $i
            $by = $bStart + $i
            if ($bx -ge 0 -and $bx -lt $w -and $by -ge 0 -and $by -lt $h) {
                if ($grid[$bx, $by] -ge 0) {
                    $dstBmp.SetPixel($bx, $by, [System.Drawing.Color]::FromArgb(255, 65, 35, 18))
                    if ($i % 2 -eq 0) {
                        # Shiny golden bullet
                        $dstBmp.SetPixel($bx, $by, [System.Drawing.Color]::FromArgb(255, 255, 215, 0))
                    }
                }
            }
        }
    }

    # 6. DRAW HEAVY MAGNUM REVOLVER IN HAND
    # In south/east/west/diagonals, draw a mini revolver held by cat paw
    if ($direction -like "*south*" -or $direction -eq "east" -or $direction -eq "west") {
        $gunX = $headCenterX - 7
        $gunY = $headTopY + 19

        if ($direction -eq "east") { $gunX = $headCenterX + 4 }
        elseif ($direction -eq "west") { $gunX = $headCenterX - 8 }

        # Gun Barrel (Dark gunmetal grey)
        for ($gx = 0; $gx -lt 4; $gx++) {
            if (($gunX + $gx) -ge 0 -and ($gunX + $gx) -lt $w -and $gunY -lt $h) {
                $dstBmp.SetPixel($gunX + $gx, $gunY, [System.Drawing.Color]::FromArgb(255, 45, 52, 60))
            }
        }
        # Cylinder & Hammer
        if (($gunX + 1) -ge 0 -and ($gunX + 1) -lt $w -and ($gunY - 1) -ge 0) {
            $dstBmp.SetPixel($gunX + 1, $gunY - 1, [System.Drawing.Color]::FromArgb(255, 70, 78, 88))
        }
        # Wood Grip
        if (($gunX + 1) -ge 0 -and ($gunX + 1) -lt $w -and ($gunY + 1) -lt $h) {
            $dstBmp.SetPixel($gunX + 1, $gunY + 1, [System.Drawing.Color]::FromArgb(255, 130, 65, 25))
        }
        # Gun Muzzle tip (metallic highlight)
        if ($gunX -ge 0 -and $gunX -lt $w) {
            $dstBmp.SetPixel($gunX, $gunY, [System.Drawing.Color]::FromArgb(255, 140, 150, 165))
        }
    }

    # 7. EYE PATCH & AMBER EYE (South & Side views)
    if ($direction -like "*south*" -or $direction -eq "east" -or $direction -eq "west") {
        $faceY = $hatBrimY + 3
        # Left eye patch
        $patchX = $headCenterX - 3
        if ($patchX -ge 0 -and ($patchX + 1) -lt $w -and $faceY -lt $h) {
            $dstBmp.SetPixel($patchX, $faceY, [System.Drawing.Color]::FromArgb(255, 20, 20, 20))
            $dstBmp.SetPixel($patchX + 1, $faceY, [System.Drawing.Color]::FromArgb(255, 20, 20, 20))
            # Strap
            if (($faceY - 1) -ge 0) { $dstBmp.SetPixel($patchX - 1, $faceY - 1, [System.Drawing.Color]::FromArgb(255, 30, 30, 30)) }
        }
        # Sharp Amber right eye
        $amberX = $headCenterX + 3
        if ($amberX -ge 0 -and $amberX -lt $w -and $faceY -lt $h) {
            $dstBmp.SetPixel($amberX, $faceY, [System.Drawing.Color]::FromArgb(255, 255, 185, 0))
            if (($amberX + 1) -lt $w) { $dstBmp.SetPixel($amberX + 1, $faceY, [System.Drawing.Color]::FromArgb(255, 255, 220, 50)) }
        }
    }

    $dstBmp.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $dstBmp.Dispose()
}

# Process All Idle Rotations
Write-Output "Processing All Rotations without sword..."
$rotFiles = Get-ChildItem "$srcDir\rotations\*.png"
foreach ($f in $rotFiles) {
    $dirName = $f.BaseName
    $dst = "$destDir\rotations\$($f.Name)"
    Build-Gunslinger-Frame -srcPath $f.FullName -dstPath $dst -direction $dirName
}

# Process All Running Animation Frames
Write-Output "Processing All Running Animations without sword and with Magnum..."
foreach ($d in $directions) {
    $subDir = "$srcDir\animations\Running\$d"
    if (Test-Path $subDir) {
        $frames = Get-ChildItem "$subDir\*.png"
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\$d\$($fr.Name)"
            Build-Gunslinger-Frame -srcPath $fr.FullName -dstPath $dst -direction $d
        }
    } elseif ($d -eq "south-west" -and (Test-Path "$srcDir\animations\Running\south-east")) {
        $frames = Get-ChildItem "$srcDir\animations\Running\south-east\*.png"
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\south-west\$($fr.Name)"
            Build-Gunslinger-Frame -srcPath $fr.FullName -dstPath $dst -direction "south-west"
        }
    }
}

Write-Output "ALL_GUNSLINGER_FRAMES_REBUILT_CLEAN_NO_SWORD"
