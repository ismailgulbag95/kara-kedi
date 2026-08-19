Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;

public class GunslingerProcessor
{
    public static void ProcessImage(string srcPath, string dstPath, string direction)
    {
        using (Bitmap src = (Bitmap)Image.FromFile(srcPath))
        {
            int w = src.Width;
            int h = src.Height;
            using (Bitmap dst = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            {
                int[,] br = new int[w, h];
                int[,] a = new int[w, h];

                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        Color p = src.GetPixel(x, y);
                        a[x, y] = p.A;
                        if (p.A > 25)
                        {
                            br[x, y] = (p.R + p.G + p.B) / 3;
                        }
                        else
                        {
                            br[x, y] = -1;
                        }
                    }
                }

                // 1. Erase Sword Pixels (stick on the left: x <= 18, y <= 27)
                for (int y = 0; y <= 27; y++)
                {
                    for (int x = 0; x <= 19; x++)
                    {
                        if (br[x, y] >= 0)
                        {
                            bool connected = false;
                            for (int dx = 1; dx <= 3; dx++)
                            {
                                int nx = x + dx;
                                if (nx < w && br[nx, y] >= 0 && nx >= 20)
                                {
                                    connected = true;
                                    break;
                                }
                            }
                            if (!connected && x <= 16)
                            {
                                br[x, y] = -1;
                                a[x, y] = 0;
                            }
                        }
                    }
                }

                // Find Body Bounds
                int minX = w, maxX = 0, minY = h, maxY = 0;
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        if (br[x, y] >= 0)
                        {
                            if (x < minX) minX = x;
                            if (x > maxX) maxX = x;
                            if (y < minY) minY = y;
                            if (y > maxY) maxY = y;
                        }
                    }
                }

                if (minX >= maxX) { minX = 16; maxX = 32; minY = 6; maxY = 42; }
                int headCenterX = (minX + maxX) / 2;
                int headTopY = minY;

                // 2. Render Desert Lynx / Marksman Fur
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        int val = br[x, y];
                        if (val >= 0)
                        {
                            int alphaVal = a[x, y];
                            Color col;
                            if (val < 35) col = Color.FromArgb(alphaVal, 48, 28, 14); // Dark outline
                            else if (val < 75) col = Color.FromArgb(alphaVal, 120, 75, 42); // Shadow tan
                            else if (val < 125) col = Color.FromArgb(alphaVal, 185, 125, 75); // Base Lynx tan
                            else col = Color.FromArgb(alphaVal, 235, 195, 155); // Cream highlight
                            dst.SetPixel(x, y, col);
                        }
                        else
                        {
                            dst.SetPixel(x, y, Color.Transparent);
                        }
                    }
                }

                // 3. Draw Cowboy Hat
                int hatW = Math.Min(22, (maxX - minX + 8));
                int hatStartX = headCenterX - (hatW / 2);
                int hatBrimY = Math.Max(4, headTopY + 2);
                int hatCrownY = Math.Max(1, hatBrimY - 5);

                int crownW = (int)(hatW * 0.6);
                int crownStartX = headCenterX - (crownW / 2);

                // Hat Crown
                for (int cy = hatCrownY; cy <= hatBrimY; cy++)
                {
                    for (int cx = crownStartX; cx < (crownStartX + crownW); cx++)
                    {
                        if (cx >= 0 && cx < w && cy >= 0 && cy < h)
                        {
                            if (cy == hatCrownY)
                            {
                                dst.SetPixel(cx, cy, Color.FromArgb(255, 95, 55, 26));
                            }
                            else if (cy == (hatBrimY - 1))
                            {
                                bool isBuckle = (cx >= (headCenterX - 1) && cx <= (headCenterX + 1));
                                Color col = isBuckle ? Color.FromArgb(255, 255, 215, 0) : Color.FromArgb(255, 30, 20, 15);
                                dst.SetPixel(cx, cy, col);
                            }
                            else
                            {
                                dst.SetPixel(cx, cy, Color.FromArgb(255, 135, 82, 42));
                            }
                        }
                    }
                }

                // Hat Brim
                for (int bx = hatStartX; bx < (hatStartX + hatW); bx++)
                {
                    if (bx >= 0 && bx < w)
                    {
                        bool isEdge = (bx == hatStartX || bx == (hatStartX + hatW - 1));
                        int by = isEdge ? (hatBrimY - 1) : hatBrimY;
                        if (by >= 0 && by < h)
                        {
                            dst.SetPixel(bx, by, Color.FromArgb(255, 78, 44, 20));
                            if ((by + 1) < h && !isEdge)
                            {
                                dst.SetPixel(bx, by + 1, Color.FromArgb(255, 55, 30, 14));
                            }
                        }
                    }
                }

                // 4. Lynx Ear Tufts
                int earLeftX = crownStartX - 1;
                int earRightX = crownStartX + crownW;
                if (earLeftX >= 0 && (hatCrownY - 2) >= 0)
                {
                    dst.SetPixel(earLeftX, hatCrownY - 1, Color.FromArgb(255, 185, 125, 75));
                    dst.SetPixel(earLeftX, hatCrownY - 2, Color.FromArgb(255, 25, 25, 25));
                }
                if (earRightX < w && (hatCrownY - 2) >= 0)
                {
                    dst.SetPixel(earRightX, hatCrownY - 1, Color.FromArgb(255, 185, 125, 75));
                    dst.SetPixel(earRightX, hatCrownY - 2, Color.FromArgb(255, 25, 25, 25));
                }

                // 5. Bandolier (Ammo Belt)
                if (!direction.Contains("north"))
                {
                    int bStart = headTopY + 11;
                    for (int i = 0; i < 8; i++)
                    {
                        int bx = headCenterX - 4 + i;
                        int by = bStart + i;
                        if (bx >= 0 && bx < w && by >= 0 && by < h && br[bx, by] >= 0)
                        {
                            dst.SetPixel(bx, by, Color.FromArgb(255, 65, 35, 18));
                            if (i % 2 == 0)
                            {
                                dst.SetPixel(bx, by, Color.FromArgb(255, 255, 215, 0));
                            }
                        }
                    }
                }

                // 6. Heavy Magnum Revolver in Paw
                if (direction.Contains("south") || direction == "east" || direction == "west")
                {
                    int gunX = (direction == "east") ? (headCenterX + 4) : ((direction == "west") ? (headCenterX - 8) : (headCenterX - 7));
                    int gunY = headTopY + 19;

                    for (int gx = 0; gx < 4; gx++)
                    {
                        if ((gunX + gx) >= 0 && (gunX + gx) < w && gunY < h)
                        {
                            dst.SetPixel(gunX + gx, gunY, Color.FromArgb(255, 45, 52, 60));
                        }
                    }
                    if ((gunX + 1) >= 0 && (gunX + 1) < w && (gunY - 1) >= 0)
                    {
                        dst.SetPixel(gunX + 1, gunY - 1, Color.FromArgb(255, 70, 78, 88));
                    }
                    if ((gunX + 1) >= 0 && (gunX + 1) < w && (gunY + 1) < h)
                    {
                        dst.SetPixel(gunX + 1, gunY + 1, Color.FromArgb(255, 130, 65, 25)); // Wood grip
                    }
                    if (gunX >= 0 && gunX < w)
                    {
                        dst.SetPixel(gunX, gunY, Color.FromArgb(255, 140, 150, 165)); // Muzzle
                    }
                }

                // 7. Eye Patch & Amber Eye
                if (direction.Contains("south") || direction == "east" || direction == "west")
                {
                    int faceY = hatBrimY + 3;
                    int patchX = headCenterX - 3;
                    if (patchX >= 0 && (patchX + 1) < w && faceY < h)
                    {
                        dst.SetPixel(patchX, faceY, Color.FromArgb(255, 20, 20, 20));
                        dst.SetPixel(patchX + 1, faceY, Color.FromArgb(255, 20, 20, 20));
                        if ((faceY - 1) >= 0 && (patchX - 1) >= 0)
                        {
                            dst.SetPixel(patchX - 1, faceY - 1, Color.FromArgb(255, 30, 30, 30));
                        }
                    }
                    int amberX = headCenterX + 3;
                    if (amberX >= 0 && amberX < w && faceY < h)
                    {
                        dst.SetPixel(amberX, faceY, Color.FromArgb(255, 255, 185, 0));
                        if ((amberX + 1) < w)
                        {
                            dst.SetPixel(amberX + 1, faceY, Color.FromArgb(255, 255, 220, 50));
                        }
                    }
                }

                dst.Save(dstPath, ImageFormat.Png);
            }
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$srcDir = "d:\benim antigravitiler\kara kedi\assets\textures\player_character"
$destDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman"

# Process Rotations
$rotFiles = Get-ChildItem "$srcDir\rotations\*.png"
foreach ($f in $rotFiles) {
    $dirName = $f.BaseName
    $dst = "$destDir\rotations\$($f.Name)"
    [GunslingerProcessor]::ProcessImage($f.FullName, $dst, $dirName)
}

# Process Running Animations
$directions = @("east", "north", "north-east", "north-west", "south", "south-east", "south-west", "west")
foreach ($d in $directions) {
    $subDir = "$srcDir\animations\Running\$d"
    if (Test-Path $subDir) {
        $frames = Get-ChildItem "$subDir\*.png"
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\$d\$($fr.Name)"
            [GunslingerProcessor]::ProcessImage($fr.FullName, $dst, $d)
        }
    } elseif ($d -eq "south-west" -and (Test-Path "$srcDir\animations\Running\south-east")) {
        $frames = Get-ChildItem "$srcDir\animations\Running\south-east\*.png"
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\south-west\$($fr.Name)"
            [GunslingerProcessor]::ProcessImage($fr.FullName, $dst, "south-west")
        }
    }
}

Write-Output "FAST_C_SHARP_SPRITE_GENERATION_SUCCESS"
