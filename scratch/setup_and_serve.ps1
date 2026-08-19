$ErrorActionPreference = "Stop"
$toolsDir = "C:\Users\YSR_MONSTER\.antigravity\tools"
if (-not (Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
}

$godotExe = Join-Path $toolsDir "Godot_v4.3-stable_win64_console.exe"
if (-not (Test-Path $godotExe)) {
    $godotZip = Join-Path $toolsDir "godot.zip"
    Write-Host "Downloading Godot 4.3 with curl..."
    curl.exe -L "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip" -o $godotZip
    Write-Host "Extracting Godot..."
    tar.exe -xf $godotZip -C $toolsDir
    Remove-Item $godotZip -Force
}

$templatesDir = "$env:APPDATA\Godot\export_templates\4.3.stable"
if (-not (Test-Path "$templatesDir\web_release.zip")) {
    $tpzFile = Join-Path $toolsDir "templates.tpz"
    $tpzExtract = Join-Path $toolsDir "tpz_temp"
    Write-Host "Downloading Export Templates with curl (fast)..."
    curl.exe -L "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz" -o $tpzFile
    Write-Host "Extracting Templates..."
    if (-not (Test-Path $tpzExtract)) { New-Item -ItemType Directory -Force -Path $tpzExtract | Out-Null }
    tar.exe -xf $tpzFile -C $tpzExtract
    if (-not (Test-Path $templatesDir)) { New-Item -ItemType Directory -Force -Path $templatesDir | Out-Null }
    Copy-Item "$tpzExtract\templates\*" $templatesDir -Recurse -Force
    Remove-Item $tpzFile -Force -ErrorAction SilentlyContinue
    Remove-Item $tpzExtract -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Exporting Godot Web build to build/web..."
$projectDir = "C:\Users\YSR_MONSTER\.antigravity\karakedi"
$buildDir = Join-Path $projectDir "build\web"
if (-not (Test-Path $buildDir)) { New-Item -ItemType Directory -Force -Path $buildDir | Out-Null }

$actualGodot = Join-Path $toolsDir "Godot_v4.3-stable_win64_console.exe"
if (-not (Test-Path $actualGodot)) {
    $actualGodot = (Get-ChildItem $toolsDir -Filter "*godot*win64*.exe" | Select-Object -First 1).FullName
}

Write-Host "Running Godot export..."
& $actualGodot --path $projectDir --headless --export-release "Web" "$buildDir\index.html"

# Download coi-serviceworker if not exists
$coiPath = Join-Path $buildDir "coi-serviceworker.js"
if (-not (Test-Path $coiPath)) {
    Write-Host "Downloading coi-serviceworker.js..."
    curl.exe -sSL "https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/master/coi-serviceworker.js" -o $coiPath
    (Get-Content "$buildDir\index.html") -replace '<head>', '<head><script src="coi-serviceworker.js"></script>' | Set-Content "$buildDir\index.html"
}

Write-Host "=== BUILD SUCCESSFUL ==="
Get-ChildItem $buildDir
