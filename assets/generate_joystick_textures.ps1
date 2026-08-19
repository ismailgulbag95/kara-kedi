Add-Type -AssemblyName System.Drawing
$assetsDir = "d:\benim antigravitiler\kara kedi\assets\textures"

# Joystick Base (128x128)
$bmpBase = New-Object System.Drawing.Bitmap(128, 128)
$gfxBase = [System.Drawing.Graphics]::FromImage($bmpBase)
$gfxBase.Clear([System.Drawing.Color]::Transparent)
$brushBaseBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 30, 30, 45))
$penBaseBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 100, 200, 255), 3)
$gfxBase.FillEllipse($brushBaseBg, 4, 4, 120, 120)
$gfxBase.DrawEllipse($penBaseBorder, 4, 4, 120, 120)
$bmpBase.Save("$assetsDir\joystick_base.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Joystick Knob (56x56)
$bmpKnob = New-Object System.Drawing.Bitmap(56, 56)
$gfxKnob = [System.Drawing.Graphics]::FromImage($bmpKnob)
$gfxKnob.Clear([System.Drawing.Color]::Transparent)
$brushKnobBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 80, 160, 255))
$penKnobBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 200, 240, 255), 2)
$gfxKnob.FillEllipse($brushKnobBg, 3, 3, 50, 50)
$gfxKnob.DrawEllipse($penKnobBorder, 3, 3, 50, 50)
$bmpKnob.Save("$assetsDir\joystick_knob.png", [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "JOYSTICK_TEXTURES_CREATED"
