Add-Type -ReferencedAssemblies "System.Drawing" -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class AssetArtist
{
    public static void GenerateAllAssets(string outDir)
    {
        GenerateGasTank(outDir + "\\explosive_gas_tank.png");
        GenerateGrate(outDir + "\\sewer_vent_grate.png");
        GenerateCrate(outDir + "\\loot_crate_wood.png");
        GenerateMilkBowl(outDir + "\\milk_bowl_item.png");
    }

    private static void GenerateGasTank(string path)
    {
        int size = 48;
        using (Bitmap bmp = new Bitmap(size, size))
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.Half;
            g.Clear(Color.Transparent);

            // Shadow
            using (SolidBrush sh = new SolidBrush(Color.FromArgb(120, 10, 10, 15))) {
                g.FillEllipse(sh, 10, 36, 28, 10);
            }

            // Tank Body (Red metallic cylinder)
            using (SolidBrush bDark = new SolidBrush(Color.FromArgb(255, 140, 20, 20)))
            using (SolidBrush bMid = new SolidBrush(Color.FromArgb(255, 210, 35, 35)))
            using (SolidBrush bLight = new SolidBrush(Color.FromArgb(255, 255, 75, 75)))
            using (SolidBrush bHighlight = new SolidBrush(Color.FromArgb(255, 255, 150, 150)))
            {
                // Base
                g.FillRectangle(bMid, 14, 14, 20, 24);
                g.FillEllipse(bMid, 14, 30, 20, 8);
                g.FillEllipse(bMid, 14, 10, 20, 8);

                // Shading right/left
                g.FillRectangle(bDark, 14, 14, 4, 24);
                g.FillRectangle(bDark, 30, 14, 4, 24);
                // Highlight line
                g.FillRectangle(bLight, 19, 14, 5, 24);
                g.FillRectangle(bHighlight, 20, 16, 2, 20);
            }

            // Yellow Hazard Strip
            using (SolidBrush bHaz = new SolidBrush(Color.FromArgb(255, 245, 190, 35)))
            using (SolidBrush bHazD = new SolidBrush(Color.FromArgb(255, 180, 130, 15)))
            {
                g.FillRectangle(bHaz, 14, 22, 20, 6);
                g.FillRectangle(bHazD, 14, 22, 4, 6);
                // Diagonal stripes
                using (Pen p = new Pen(Color.FromArgb(255, 30, 30, 30), 2)) {
                    g.DrawLine(p, 17, 22, 21, 28);
                    g.DrawLine(p, 23, 22, 27, 28);
                    g.DrawLine(p, 29, 22, 33, 28);
                }
            }

            // Brass Valve on Top
            using (SolidBrush bBrass = new SolidBrush(Color.FromArgb(255, 212, 175, 55)))
            using (SolidBrush bSteel = new SolidBrush(Color.FromArgb(255, 160, 170, 185)))
            {
                g.FillRectangle(bSteel, 21, 8, 6, 4);
                g.FillRectangle(bBrass, 19, 5, 10, 3);
                g.FillRectangle(bBrass, 22, 3, 4, 3);
            }

            // Outer Outline
            using (Pen pOut = new Pen(Color.FromArgb(255, 35, 15, 15), 1.5f)) {
                g.DrawRectangle(pOut, 14, 12, 20, 26);
                g.DrawEllipse(pOut, 14, 10, 20, 8);
                g.DrawEllipse(pOut, 14, 30, 20, 8);
            }

            bmp.Save(path, ImageFormat.Png);
        }
    }

    private static void GenerateGrate(string path)
    {
        int size = 48;
        using (Bitmap bmp = new Bitmap(size, size))
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.Clear(Color.Transparent);

            // Dark Hole Shadow
            using (SolidBrush bHole = new SolidBrush(Color.FromArgb(255, 12, 10, 18))) {
                g.FillEllipse(bHole, 6, 6, 36, 36);
            }

            // Glowing Red Eyes inside hole
            using (SolidBrush bEye = new SolidBrush(Color.FromArgb(255, 255, 30, 60)))
            using (SolidBrush bGlow = new SolidBrush(Color.FromArgb(140, 255, 60, 80)))
            {
                g.FillEllipse(bGlow, 17, 18, 5, 4);
                g.FillEllipse(bGlow, 26, 18, 5, 4);
                g.FillRectangle(bEye, 18, 19, 3, 2);
                g.FillRectangle(bEye, 27, 19, 3, 2);

                g.FillEllipse(bGlow, 19, 27, 4, 4);
                g.FillEllipse(bGlow, 25, 27, 4, 4);
                g.FillRectangle(bEye, 20, 28, 2, 2);
                g.FillRectangle(bEye, 26, 28, 2, 2);
            }

            // Iron Rim
            using (Pen pRim = new Pen(Color.FromArgb(255, 65, 75, 90), 4)) {
                g.DrawEllipse(pRim, 6, 6, 36, 36);
            }
            using (Pen pRimH = new Pen(Color.FromArgb(255, 120, 135, 155), 1.5f)) {
                g.DrawArc(pRimH, 6, 6, 36, 36, 180, 120);
            }

            // Iron Bars
            using (Pen pBar = new Pen(Color.FromArgb(255, 80, 90, 105), 2.5f))
            using (Pen pBarH = new Pen(Color.FromArgb(255, 140, 155, 175), 1f))
            {
                for (int x = 12; x <= 36; x += 6) {
                    g.DrawLine(pBar, x, 8, x, 40);
                    g.DrawLine(pBarH, x - 0.5f, 9, x - 0.5f, 39);
                }
                g.DrawLine(pBar, 8, 24, 40, 24);
            }

            // Bolts
            using (SolidBrush bBolt = new SolidBrush(Color.FromArgb(255, 180, 190, 210))) {
                g.FillRectangle(bBolt, 6, 23, 3, 3);
                g.FillRectangle(bBolt, 39, 23, 3, 3);
                g.FillRectangle(bBolt, 23, 6, 3, 3);
                g.FillRectangle(bBolt, 23, 39, 3, 3);
            }

            bmp.Save(path, ImageFormat.Png);
        }
    }

    private static void GenerateCrate(string path)
    {
        int size = 32;
        using (Bitmap bmp = new Bitmap(size, size))
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.Clear(Color.Transparent);

            // Shadow
            using (SolidBrush sh = new SolidBrush(Color.FromArgb(120, 10, 10, 15))) {
                g.FillEllipse(sh, 4, 24, 24, 7);
            }

            // Wood Planks Body
            using (SolidBrush bWoodD = new SolidBrush(Color.FromArgb(255, 130, 75, 35)))
            using (SolidBrush bWoodM = new SolidBrush(Color.FromArgb(255, 180, 110, 55)))
            using (SolidBrush bWoodL = new SolidBrush(Color.FromArgb(255, 215, 145, 75)))
            {
                g.FillRectangle(bWoodM, 4, 4, 24, 24);
                // Planks
                g.FillRectangle(bWoodL, 4, 5, 24, 6);
                g.FillRectangle(bWoodM, 4, 13, 24, 6);
                g.FillRectangle(bWoodD, 4, 21, 24, 6);
            }

            // Iron Reinforcements
            using (SolidBrush bIron = new SolidBrush(Color.FromArgb(255, 70, 78, 95)))
            using (SolidBrush bIronL = new SolidBrush(Color.FromArgb(255, 130, 140, 160)))
            {
                // Border frame
                g.FillRectangle(bIron, 4, 4, 24, 3);
                g.FillRectangle(bIron, 4, 25, 24, 3);
                g.FillRectangle(bIron, 4, 4, 3, 24);
                g.FillRectangle(bIron, 25, 4, 3, 24);

                // Corner brackets
                g.FillRectangle(bIronL, 4, 4, 5, 5);
                g.FillRectangle(bIronL, 23, 4, 5, 5);
                g.FillRectangle(bIronL, 4, 23, 5, 5);
                g.FillRectangle(bIronL, 23, 23, 5, 5);

                // Diagonal cross
                using (Pen p = new Pen(bIron, 2)) {
                    g.DrawLine(p, 6, 6, 25, 25);
                    g.DrawLine(p, 25, 6, 6, 25);
                }
            }

            // Gold Lock / Emblem in Center
            using (SolidBrush bGold = new SolidBrush(Color.FromArgb(255, 255, 200, 30)))
            using (SolidBrush bGoldD = new SolidBrush(Color.FromArgb(255, 180, 130, 10)))
            {
                g.FillRectangle(bGold, 13, 13, 6, 6);
                g.FillRectangle(bGoldD, 15, 15, 2, 3);
            }

            // Outline
            using (Pen pOut = new Pen(Color.FromArgb(255, 30, 20, 15), 1)) {
                g.DrawRectangle(pOut, 3, 3, 25, 25);
            }

            bmp.Save(path, ImageFormat.Png);
        }
    }

    private static void GenerateMilkBowl(string path)
    {
        int size = 24;
        using (Bitmap bmp = new Bitmap(size, size))
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.Clear(Color.Transparent);

            // Soft Glow
            using (SolidBrush bGlow = new SolidBrush(Color.FromArgb(80, 0, 210, 255))) {
                g.FillEllipse(bGlow, 1, 3, 22, 18);
            }

            // Blue Ceramic Bowl
            using (SolidBrush bBowl = new SolidBrush(Color.FromArgb(255, 30, 110, 180)))
            using (SolidBrush bBowlL = new SolidBrush(Color.FromArgb(255, 70, 160, 235)))
            {
                g.FillEllipse(bBowl, 3, 6, 18, 14);
                g.FillEllipse(bBowlL, 3, 6, 18, 6);
            }

            // Pure White Fresh Milk
            using (SolidBrush bMilk = new SolidBrush(Color.FromArgb(255, 250, 250, 255)))
            using (SolidBrush bMilkH = new SolidBrush(Color.FromArgb(255, 255, 255, 255)))
            using (SolidBrush bCream = new SolidBrush(Color.FromArgb(255, 220, 235, 255)))
            {
                g.FillEllipse(bCream, 4, 7, 16, 8);
                g.FillEllipse(bMilk, 5, 8, 14, 6);
                g.FillRectangle(bMilkH, 8, 9, 4, 2);
            }

            // Small paw mark in bowl
            using (SolidBrush bPaw = new SolidBrush(Color.FromArgb(180, 255, 170, 200))) {
                g.FillEllipse(bPaw, 11, 10, 2, 2);
            }

            bmp.Save(path, ImageFormat.Png);
        }
    }
}
"@

[AssetArtist]::GenerateAllAssets("d:\benim antigravitiler\kara kedi\assets\textures")
Write-Output "ALL_PIXEL_ASSETS_GENERATED_SUCCESSFULLY"
