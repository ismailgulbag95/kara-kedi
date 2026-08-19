Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;

public class VariantGenerator
{
    public static void GenerateVariants(string srcPath, string outA, string outB, string outC)
    {
        using (Bitmap src = (Bitmap)Image.FromFile(srcPath))
        {
            int w = src.Width;
            int h = src.Height;

            int[,] br = new int[w, h];
            int[,] a = new int[w, h];

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    Color p = src.GetPixel(x, y);
                    a[x, y] = p.A;
                    br[x, y] = (p.A > 25) ? ((p.R + p.G + p.B) / 3) : -1;
                }
            }

            // Remove sword blade on left
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
                            if (nx < w && br[nx, y] >= 0 && nx >= 20) { connected = true; break; }
                        }
                        if (!connected && x <= 16) { br[x, y] = -1; a[x, y] = 0; }
                    }
                }
            }

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
            int headCenterX = (minX + maxX) / 2;
            int headTopY = minY;

            // ==========================================
            // VARIANT A: Klasik Kovboy / Çöl Vaşağı
            // ==========================================
            using (Bitmap bmpA = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            {
                // Fur
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        int v = br[x, y];
                        if (v >= 0)
                        {
                            int al = a[x, y];
                            Color c = (v < 35) ? Color.FromArgb(al, 48, 28, 14) :
                                      (v < 75) ? Color.FromArgb(al, 120, 75, 42) :
                                      (v < 125) ? Color.FromArgb(al, 185, 125, 75) :
                                                  Color.FromArgb(al, 235, 195, 155);
                            bmpA.SetPixel(x, y, c);
                        }
                    }
                }

                // Hat (Crown & Brim)
                int hatW = 20;
                int hatStartX = headCenterX - 10;
                int hatBrimY = headTopY + 2;
                int hatCrownY = hatBrimY - 5;

                for (int cy = hatCrownY; cy <= hatBrimY; cy++)
                {
                    for (int cx = headCenterX - 6; cx <= headCenterX + 5; cx++)
                    {
                        if (cx >= 0 && cx < w && cy >= 0 && cy < h)
                        {
                            Color c = (cy == hatCrownY) ? Color.FromArgb(255, 95, 55, 26) :
                                      (cy == hatBrimY - 1) ? ((cx >= headCenterX - 1 && cx <= headCenterX + 1) ? Color.FromArgb(255, 255, 215, 0) : Color.FromArgb(255, 30, 20, 15)) :
                                      Color.FromArgb(255, 135, 82, 42);
                            bmpA.SetPixel(cx, cy, c);
                        }
                    }
                }
                for (int bx = hatStartX; bx < hatStartX + hatW; bx++)
                {
                    if (bx >= 0 && bx < w && hatBrimY >= 0 && hatBrimY < h)
                    {
                        bool edge = (bx == hatStartX || bx == hatStartX + hatW - 1);
                        int by = edge ? (hatBrimY - 1) : hatBrimY;
                        bmpA.SetPixel(bx, by, Color.FromArgb(255, 78, 44, 20));
                    }
                }

                // Bandolier
                for (int i = 0; i < 7; i++)
                {
                    int bx = headCenterX - 3 + i, by = headTopY + 11 + i;
                    if (bx < w && by < h && br[bx, by] >= 0)
                    {
                        bmpA.SetPixel(bx, by, (i % 2 == 0) ? Color.FromArgb(255, 255, 215, 0) : Color.FromArgb(255, 65, 35, 18));
                    }
                }

                // Revolver
                int gx = headCenterX - 7, gy = headTopY + 19;
                for (int i = 0; i < 4; i++) bmpA.SetPixel(gx + i, gy, Color.FromArgb(255, 45, 52, 60));
                bmpA.SetPixel(gx + 1, gy - 1, Color.FromArgb(255, 70, 78, 88));
                bmpA.SetPixel(gx + 1, gy + 1, Color.FromArgb(255, 130, 65, 25)); // wood grip
                bmpA.SetPixel(gx, gy, Color.FromArgb(255, 140, 150, 165)); // muzzle

                // Eye patch & Amber eye
                bmpA.SetPixel(headCenterX - 3, hatBrimY + 3, Color.FromArgb(255, 20, 20, 20));
                bmpA.SetPixel(headCenterX - 2, hatBrimY + 3, Color.FromArgb(255, 20, 20, 20));
                bmpA.SetPixel(headCenterX + 3, hatBrimY + 3, Color.FromArgb(255, 255, 185, 0));

                bmpA.Save(outA, ImageFormat.Png);
            }

            // ==========================================
            // VARIANT B: 🕵️‍♂️ Gölge Dedektif / Kara Kasketli
            // ==========================================
            using (Bitmap bmpB = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            {
                // Pure Sleek Black/Charcoal Fur
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        int v = br[x, y];
                        if (v >= 0)
                        {
                            int al = a[x, y];
                            Color c = (v < 35) ? Color.FromArgb(al, 15, 15, 20) :
                                      (v < 75) ? Color.FromArgb(al, 32, 34, 45) :
                                      (v < 125) ? Color.FromArgb(al, 50, 54, 70) :
                                                  Color.FromArgb(al, 85, 90, 110);
                            bmpB.SetPixel(x, y, c);
                        }
                    }
                }

                // Noir Peaky Flat Cap (Gri Kasket)
                int capW = 18;
                int capStartX = headCenterX - 9;
                int capY = headTopY + 1;

                for (int cy = capY - 4; cy <= capY; cy++)
                {
                    for (int cx = capStartX + 2; cx < capStartX + capW - 2; cx++)
                    {
                        if (cx >= 0 && cx < w && cy >= 0 && cy < h)
                        {
                            bmpB.SetPixel(cx, cy, Color.FromArgb(255, 75, 80, 95));
                        }
                    }
                }
                for (int bx = capStartX; bx < capStartX + capW; bx++)
                {
                    if (bx >= 0 && bx < w && capY >= 0 && capY < h)
                    {
                        bmpB.SetPixel(bx, capY, Color.FromArgb(255, 45, 48, 60));
                    }
                }

                // Red Tie / Scarf
                bmpB.SetPixel(headCenterX, headTopY + 10, Color.FromArgb(255, 200, 20, 20));
                bmpB.SetPixel(headCenterX, headTopY + 11, Color.FromArgb(255, 220, 30, 30));
                bmpB.SetPixel(headCenterX, headTopY + 12, Color.FromArgb(255, 160, 15, 15));

                // Silver Dual-Tone Magnum
                int gx = headCenterX - 7, gy = headTopY + 19;
                for (int i = 0; i < 4; i++) bmpB.SetPixel(gx + i, gy, Color.FromArgb(255, 200, 210, 225));
                bmpB.SetPixel(gx + 1, gy - 1, Color.FromArgb(255, 240, 245, 255));
                bmpB.SetPixel(gx + 1, gy + 1, Color.FromArgb(255, 20, 20, 25)); // black grip
                bmpB.SetPixel(gx, gy, Color.FromArgb(255, 255, 255, 255)); // chrome muzzle

                // Glowing Monocle / Silver Eye
                bmpB.SetPixel(headCenterX - 3, capY + 3, Color.FromArgb(255, 0, 230, 255));
                bmpB.SetPixel(headCenterX - 2, capY + 3, Color.FromArgb(255, 0, 230, 255));
                bmpB.SetPixel(headCenterX + 3, capY + 3, Color.FromArgb(255, 255, 255, 255));

                bmpB.Save(outB, ImageFormat.Png);
            }

            // ==========================================
            // VARIANT C: 🎖️ Askeri Komando / Çöl Tilkisi
            // ==========================================
            using (Bitmap bmpC = new Bitmap(w, h, PixelFormat.Format32bppArgb))
            {
                // Camo Khaki / Olive Tan Fur
                for (int y = 0; y < h; y++)
                {
                    for (int x = 0; x < w; x++)
                    {
                        int v = br[x, y];
                        if (v >= 0)
                        {
                            int al = a[x, y];
                            Color c = (v < 35) ? Color.FromArgb(al, 35, 42, 25) :
                                      (v < 75) ? Color.FromArgb(al, 90, 105, 65) :
                                      (v < 125) ? Color.FromArgb(al, 145, 160, 110) :
                                                  Color.FromArgb(al, 205, 215, 175);
                            bmpC.SetPixel(x, y, c);
                        }
                    }
                }

                // Military Beret (Haki Yeşil Askeri Bere)
                int beretStartX = headCenterX - 7;
                int beretY = headTopY;

                for (int cy = beretY - 4; cy <= beretY + 1; cy++)
                {
                    for (int cx = beretStartX; cx <= headCenterX + 7; cx++)
                    {
                        if (cx >= 0 && cx < w && cy >= 0 && cy < h)
                        {
                            bool fold = (cx > headCenterX + 3 && cy >= beretY);
                            Color col = fold ? Color.FromArgb(255, 45, 60, 30) : Color.FromArgb(255, 68, 88, 48);
                            bmpC.SetPixel(cx, cy, col);
                        }
                    }
                }
                // Gold insignia badge on beret
                bmpC.SetPixel(headCenterX - 3, beretY - 1, Color.FromArgb(255, 255, 215, 0));

                // Tactical Camo Vest
                for (int y = headTopY + 10; y <= headTopY + 16; y++)
                {
                    for (int x = headCenterX - 4; x <= headCenterX + 4; x++)
                    {
                        if (x < w && y < h && br[x, y] >= 0)
                        {
                            bmpC.SetPixel(x, y, ((x + y) % 3 == 0) ? Color.FromArgb(255, 45, 58, 30) : Color.FromArgb(255, 78, 98, 55));
                        }
                    }
                }

                // Tactical Silenced Handgun with Laser Sight
                int gx = headCenterX - 7, gy = headTopY + 19;
                for (int i = 0; i < 5; i++) bmpC.SetPixel(gx + i, gy, Color.FromArgb(255, 30, 35, 35));
                bmpC.SetPixel(gx + 2, gy - 1, Color.FromArgb(255, 45, 55, 55));
                bmpC.SetPixel(gx + 2, gy + 1, Color.FromArgb(255, 55, 70, 45)); // olive grip
                bmpC.SetPixel(gx, gy, Color.FromArgb(255, 255, 0, 0)); // Red Laser dot

                // Red Tactical Visor / Eye
                bmpC.SetPixel(headCenterX - 3, beretY + 3, Color.FromArgb(255, 255, 40, 40));
                bmpC.SetPixel(headCenterX - 2, beretY + 3, Color.FromArgb(255, 255, 80, 80));
                bmpC.SetPixel(headCenterX + 3, beretY + 3, Color.FromArgb(255, 255, 40, 40));

                bmpC.Save(outC, ImageFormat.Png);
            }
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$src = "d:\benim antigravitiler\kara kedi\assets\textures\player_character\rotations\south.png"
$outDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\variants"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$outA = "$outDir\variant_a.png"
$outB = "$outDir\variant_b.png"
$outC = "$outDir\variant_c.png"

[VariantGenerator]::GenerateVariants($src, $outA, $outB, $outC)
Write-Output "VARIANTS_GENERATED_SUCCESSFULLY"
