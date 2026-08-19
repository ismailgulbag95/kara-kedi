Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;

public class WesternLynxProcessor
{
    public static void ProcessImage(string srcPath, string dstPath, string direction, int frameIdx)
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

                // 1. Completely remove any old sword/blade pixels on the left
                for (int y = 0; y <= 28; y++)
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

                // 2. Base Fur (Warm Desert Lynx: Tan, Amber, Cream Muzzle)
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        int val = br[x, y];
                        if (val >= 0)
                        {
                            int alphaVal = a[x, y];
                            Color col;
                            if (val < 35) col = Color.FromArgb(alphaVal, 42, 26, 12); // Deep dark outline
                            else if (val < 75) col = Color.FromArgb(alphaVal, 115, 72, 38); // Shadow lynx fur
                            else if (val < 125) col = Color.FromArgb(alphaVal, 178, 120, 70); // Base lynx tan fur
                            else col = Color.FromArgb(alphaVal, 230, 195, 155); // Cream muzzle/cheeks
                            dst.SetPixel(x, y, col);
                        }
                    }
                }

                // 3. Western Duster Coat (Uzun Taba Deri Pardösü)
                // Covers shoulders down to lower legs
                int coatTopY = headTopY + 9;
                int coatBottomY = Math.Min(h - 4, maxY - 2);

                for (int y = coatTopY; y <= coatBottomY; y++)
                {
                    for (int x = minX - 1; x <= maxX + 1; x++)
                    {
                        if (x >= 0 && x < w && y < h)
                        {
                            if (br[x, y] >= 0 || (x == (minX - 1) && y >= (coatTopY + 4)) || (x == (maxX + 1) && y >= (coatTopY + 4)))
                            {
                                // Edge lapels & shading
                                bool isOuter = (x <= (minX) || x >= (maxX));
                                bool isFrontOpening = (!direction.Contains("north") && x >= (headCenterX - 1) && x <= (headCenterX + 1) && y <= (coatTopY + 7));

                                if (isFrontOpening)
                                {
                                    // Inner vest / shirt (Dark charcoal vest)
                                    dst.SetPixel(x, y, Color.FromArgb(255, 60, 48, 38));
                                }
                                else if (isOuter)
                                {
                                    // Coat outer fold & collar
                                    dst.SetPixel(x, y, Color.FromArgb(255, 95, 58, 28));
                                }
                                else if (y >= (coatTopY + 10))
                                {
                                    // Flowing coat flaps (animates slightly with frame)
                                    int flapOffset = (frameIdx % 2 == 0) ? 0 : 1;
                                    dst.SetPixel(x, y, Color.FromArgb(255, 138, 85, 45));
                                }
                                else
                                {
                                    // Coat upper body
                                    dst.SetPixel(x, y, Color.FromArgb(255, 155, 98, 52));
                                }
                            }
                        }
                    }
                }

                // 4. Cowboy Boots & Spurs (Kovboy Çizmeleri ve Mahmuzlar)
                for (int y = Math.Max(0, maxY - 4); y <= maxY; y++)
                {
                    for (int x = minX; x <= maxX; x++)
                    {
                        if (x < w && y < h && br[x, y] >= 0)
                        {
                            dst.SetPixel(x, y, Color.FromArgb(255, 45, 28, 14)); // Dark leather boots
                            // Silver spur pixel at bottom heel
                            if (y == maxY && (x == minX || x == maxX))
                            {
                                dst.SetPixel(x, y, Color.FromArgb(255, 210, 220, 230));
                            }
                        }
                    }
                }

                // 5. Cowboy Hat (Kovboy Şapkası)
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
                                dst.SetPixel(cx, cy, Color.FromArgb(255, 85, 48, 22)); // Crease
                            }
                            else if (cy == (hatBrimY - 1))
                            {
                                // Dark leather hat band with small gold buckle
                                bool isBuckle = (cx >= (headCenterX - 1) && cx <= (headCenterX + 1));
                                Color col = isBuckle ? Color.FromArgb(255, 255, 215, 0) : Color.FromArgb(255, 35, 22, 12);
                                dst.SetPixel(cx, cy, col);
                            }
                            else
                            {
                                dst.SetPixel(cx, cy, Color.FromArgb(255, 142, 88, 46));
                            }
                        }
                    }
                }

                // Hat Brim (Wide curved brim)
                for (int bx = hatStartX; bx < (hatStartX + hatW); bx++)
                {
                    if (bx >= 0 && bx < w)
                    {
                        bool isEdge = (bx == hatStartX || bx == (hatStartX + hatW - 1));
                        int by = isEdge ? (hatBrimY - 1) : hatBrimY;
                        if (by >= 0 && by < h)
                        {
                            dst.SetPixel(bx, by, Color.FromArgb(255, 92, 54, 25));
                            if ((by + 1) < h && !isEdge)
                            {
                                dst.SetPixel(bx, by + 1, Color.FromArgb(255, 62, 35, 16)); // Underside shadow
                            }
                        }
                    }
                }

                // 6. Lynx Ear Tufts (Siyah Uçlu Vaşak Kulakları)
                int earLeftX = crownStartX - 1;
                int earRightX = crownStartX + crownW;
                if (earLeftX >= 0 && (hatCrownY - 2) >= 0)
                {
                    dst.SetPixel(earLeftX, hatCrownY - 1, Color.FromArgb(255, 178, 120, 70));
                    dst.SetPixel(earLeftX, hatCrownY - 2, Color.FromArgb(255, 20, 20, 20)); // Black tuft
                }
                if (earRightX < w && (hatCrownY - 2) >= 0)
                {
                    dst.SetPixel(earRightX, hatCrownY - 1, Color.FromArgb(255, 178, 120, 70));
                    dst.SetPixel(earRightX, hatCrownY - 2, Color.FromArgb(255, 20, 20, 20)); // Black tuft
                }

                // 7. Gun Belt & Leather Holster (Mermi Kemeri & Tabanca Kılıfı)
                int beltY = headTopY + 14;
                if (beltY < h)
                {
                    for (int bx = minX; bx <= maxX; bx++)
                    {
                        if (bx < w && br[bx, beltY] >= 0)
                        {
                            dst.SetPixel(bx, beltY, Color.FromArgb(255, 55, 32, 15)); // Belt
                            if (bx % 2 == 0) dst.SetPixel(bx, beltY, Color.FromArgb(255, 245, 190, 35)); // Gold bullet
                        }
                    }
                    // Side holster on right leg
                    int holsterX = maxX;
                    if (holsterX < w && (beltY + 2) < h)
                    {
                        dst.SetPixel(holsterX, beltY + 1, Color.FromArgb(255, 45, 25, 12));
                        dst.SetPixel(holsterX, beltY + 2, Color.FromArgb(255, 45, 25, 12));
                    }
                }

                // 8. Heavy Western Revolver in Hand (Uzun Namlulu Revolver)
                if (direction.Contains("south") || direction == "east" || direction == "west")
                {
                    int gunX = (direction == "east") ? (headCenterX + 4) : ((direction == "west") ? (headCenterX - 9) : (headCenterX - 7));
                    int gunY = headTopY + 19;

                    // Long Steel Barrel
                    for (int gx = 0; gx < 5; gx++)
                    {
                        if ((gunX + gx) >= 0 && (gunX + gx) < w && gunY < h)
                        {
                            dst.SetPixel(gunX + gx, gunY, Color.FromArgb(255, 50, 58, 68));
                        }
                    }
                    // Cylinder
                    if ((gunX + 2) >= 0 && (gunX + 2) < w && (gunY - 1) >= 0)
                    {
                        dst.SetPixel(gunX + 2, gunY - 1, Color.FromArgb(255, 80, 90, 102));
                    }
                    // Wood Grip
                    if ((gunX + 2) >= 0 && (gunX + 2) < w && (gunY + 1) < h)
                    {
                        dst.SetPixel(gunX + 2, gunY + 1, Color.FromArgb(255, 135, 68, 28));
                    }
                    // Muzzle Highlight
                    if (gunX >= 0 && gunX < w)
                    {
                        dst.SetPixel(gunX, gunY, Color.FromArgb(255, 160, 175, 190));
                    }
                }

                // 9. Facial Features: Whiskers & Amber Eyes (South & Side views)
                if (direction.Contains("south") || direction == "east" || direction == "west")
                {
                    int faceY = hatBrimY + 3;
                    // Sharp Amber Eyes
                    int leftEyeX = headCenterX - 3;
                    int rightEyeX = headCenterX + 3;
                    if (leftEyeX >= 0 && faceY < h)
                    {
                        dst.SetPixel(leftEyeX, faceY, Color.FromArgb(255, 255, 190, 0));
                    }
                    if (rightEyeX < w && faceY < h)
                    {
                        dst.SetPixel(rightEyeX, faceY, Color.FromArgb(255, 255, 190, 0));
                    }
                    // White Lynx Whiskers (Bıyıklar)
                    int whiskerY = faceY + 3;
                    if (whiskerY < h)
                    {
                        if ((headCenterX - 5) >= 0) dst.SetPixel(headCenterX - 5, whiskerY, Color.FromArgb(255, 240, 240, 245));
                        if ((headCenterX + 5) < w) dst.SetPixel(headCenterX + 5, whiskerY, Color.FromArgb(255, 240, 240, 245));
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

# Ensure directories exist
New-Item -ItemType Directory -Path "$destDir\rotations" -Force | Out-Null
New-Item -ItemType Directory -Path "$destDir\animations\Running" -Force | Out-Null

$directions = @("east", "north", "north-east", "north-west", "south", "south-east", "south-west", "west")
foreach ($d in $directions) {
    New-Item -ItemType Directory -Path "$destDir\animations\Running\$d" -Force | Out-Null
}

# 1. Process Idle Rotations
$rotFiles = Get-ChildItem "$srcDir\rotations\*.png"
foreach ($f in $rotFiles) {
    $dirName = $f.BaseName
    $dst = "$destDir\rotations\$($f.Name)"
    [WesternLynxProcessor]::ProcessImage($f.FullName, $dst, $dirName, 0)
}

# 2. Process 8-Directional Running Animations
foreach ($d in $directions) {
    $subDir = "$srcDir\animations\Running\$d"
    if (Test-Path $subDir) {
        $frames = Get-ChildItem "$subDir\*.png" | Sort-Object Name
        $idx = 0
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\$d\$($fr.Name)"
            [WesternLynxProcessor]::ProcessImage($fr.FullName, $dst, $d, $idx)
            $idx++
        }
    } elseif ($d -eq "south-west" -and (Test-Path "$srcDir\animations\Running\south-east")) {
        $frames = Get-ChildItem "$srcDir\animations\Running\south-east\*.png" | Sort-Object Name
        $idx = 0
        foreach ($fr in $frames) {
            $dst = "$destDir\animations\Running\south-west\$($fr.Name)"
            [WesternLynxProcessor]::ProcessImage($fr.FullName, $dst, "south-west", $idx)
            $idx++
        }
    }
}

# Save portrait image from Karakter 1
Copy-Item "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b\marksman_western_sheriff_1787146512612.jpg" "$destDir\portrait.jpg" -Force
Copy-Item "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b\marksman_western_sheriff_1787146512612.jpg" "$destDir\portrait.png" -Force

Write-Output "WESTERN_LYNX_SPRITES_COMPLETED_SUCCESSFULLY"
