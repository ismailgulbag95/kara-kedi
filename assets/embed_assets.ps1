Add-Type -AssemblyName System.Drawing

$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

function Get-Base64($path) {
    if (Test-Path $path) {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $b64 = [Convert]::ToBase64String($bytes)
        return "data:image/png;base64,$b64"
    }
    return ""
}

$imagesDict = @{}

# Load static rotations
$directions = @("south", "north", "east", "west", "south-east", "south-west", "north-east", "north-west")
foreach ($d in $directions) {
    $p = "$assetsDir\player_character\rotations\$d.png"
    $cleanKey = "player_" + $d.Replace("-", "")
    $imagesDict[$cleanKey] = Get-Base64 $p
}

# Load running frames
$runDirs = @("south", "north", "east", "west", "south-east", "north-east", "north-west")
foreach ($rd in $runDirs) {
    for ($f = 0; $f -lt 8; $f++) {
        $fn = "frame_{0:D3}.png" -f $f
        $p = "$assetsDir\player_character\animations\Running\$rd\$fn"
        $key = "run_${rd}_${f}"
        $imagesDict[$key] = Get-Base64 $p
    }
}

# Load other textures
$others = @{
    "tile_floor" = "$assetsDir\tile_floor.png";
    "tile_wall" = "$assetsDir\tile_wall.png";
    "rat_small" = "$assetsDir\rat_small.png";
    "rat_dasher" = "$assetsDir\rat_dasher.png";
    "rat_spitter" = "$assetsDir\rat_spitter.png";
    "rat_tank" = "$assetsDir\rat_tank.png";
    "rat_boss" = "$assetsDir\rat_boss.png";
    "spit_acid" = "$assetsDir\projectile_acid.png";
    "coin_gold" = "$assetsDir\coin_gold.png";
    "coin_copper" = "$assetsDir\coin_copper.png";
    "item_sword" = "$assetsDir\sword.png";
    "item_claws" = "$assetsDir\claws.png";
    "item_fish" = "$assetsDir\fish_bone.png";
    "item_yarn" = "$assetsDir\yarn_bomb.png";
    "item_magnum" = "$assetsDir\items\weapon_magnum.png";
    "item_glock" = "$assetsDir\items\weapon_glock.png";
    "item_bow" = "$assetsDir\items\weapon_bow.png";
    "bullet_magnum" = "$assetsDir\bullet_magnum.png";
    "bullet_glock" = "$assetsDir\bullet_glock.png";
    "bullet_arrow" = "$assetsDir\arrow.png";
    "lock_closed" = "$assetsDir\ui\lock_closed.png";
    "lock_open" = "$assetsDir\ui\lock_open.png";
    "player_icon" = "$assetsDir\player.png"
}

foreach ($k in $others.Keys) {
    $imagesDict[$k] = Get-Base64 $others[$k]
}

# Output as JSON for injection into game.js
$json = $imagesDict | ConvertTo-Json -Compress
[System.IO.File]::WriteAllText("d:\benim antigravitiler\kara kedi\web\embedded_assets.json", $json, [System.Text.Encoding]::UTF8)
Write-Output "EMBEDDED_ASSETS_JSON_GENERATED"
