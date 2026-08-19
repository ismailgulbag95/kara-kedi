Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# --- 1. BRIGHT GOLDEN COIN (coin_gold.png - 24x24) ---
$bmpGold = New-Object System.Drawing.Bitmap(24, 24)
$g1 = [System.Drawing.Graphics]::FromImage($bmpGold)
$g1.Clear([System.Drawing.Color]::Transparent)

$bGoldBorder = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 195, 135, 10)) # Dark Gold Rim
$bGoldMain = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 215, 30))   # Shiny Yellow Gold
$bGoldLight = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 245, 140)) # High Gloss Highlight
$bGoldPaw = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 210, 150, 15))    # Center Paw Engraving

# Outer circle
$g1.FillEllipse($bGoldBorder, 1, 1, 22, 22)
# Inner gold face
$g1.FillEllipse($bGoldMain, 3, 3, 18, 18)
# Top-left shine arc
$g1.FillEllipse($bGoldLight, 5, 4, 8, 5)
# Center Cat Paw Engraving
$g1.FillEllipse($bGoldPaw, 9, 11, 6, 5) # Main pad
$g1.FillEllipse($bGoldPaw, 8, 8, 2, 2)  # Toe 1
$g1.FillEllipse($bGoldPaw, 11, 7, 2, 2) # Toe 2
$g1.FillEllipse($bGoldPaw, 14, 8, 2, 2) # Toe 3

$bmpGold.Save("$assetsDir\coin_gold.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Also copy to base coin.png for UI icons
$bmpGold.Save("$assetsDir\coin.png", [System.Drawing.Imaging.ImageFormat]::Png)

# --- 2. COPPER / BRONZE SMALL COIN (coin_copper.png - 14x14) ---
$bmpCopper = New-Object System.Drawing.Bitmap(14, 14)
$g2 = [System.Drawing.Graphics]::FromImage($bmpCopper)
$g2.Clear([System.Drawing.Color]::Transparent)

$bCopperBorder = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 60, 20)) # Dark Copper/Brown Rim
$bCopperMain = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 205, 127, 50))  # Metallic Copper/Bronze
$bCopperLight = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 235, 165, 100)) # Warm Copper Highlight
$bCopperCenter = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 150, 80, 30))  # Center Dot

# Outer circle
$g2.FillEllipse($bCopperBorder, 1, 1, 12, 12)
# Inner copper face
$g2.FillEllipse($bCopperMain, 2, 2, 10, 10)
# Top-left warm highlight
$g2.FillEllipse($bCopperLight, 3, 2, 4, 3)
# Center engraving dot
$g2.FillEllipse($bCopperCenter, 5, 5, 4, 4)

$bmpCopper.Save("$assetsDir\coin_copper.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "GOLD_AND_COPPER_COIN_TEXTURES_CREATED"
