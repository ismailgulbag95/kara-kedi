Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class PixelLabAnimator
{
    public static void GenerateWalkCycle(string outDir)
    {
        int frameW = 48;
        int frameH = 48;
        string[] dirs = new string[] { "south", "north", "east", "west" };

        // 8 Keyframe walk cycle offsets (Contact, Down, Passing, Up, Contact2, Down2, Passing2, Up2)
        // Y bobbing: [0, 1, 0, -1, 0, 1, 0, -1]
        // Left Leg: [-3, -1, 0, 2, 3, 1, 0, -2]
        // Right Leg: [3, 1, 0, -2, -3, -1, 0, 2]
        // Arm / Gun swing: [2, 1, 0, -1, -2, -1, 0, 1]

        int[] bobY = new int[] { 0, 1, 0, -1, 0, 1, 0, -1 };
        int[] leftLegX = new int[] { -2, -1, 0, 1, 2, 1, 0, -1 };
        int[] rightLegX = new int[] { 2, 1, 0, -1, -2, -1, 0, 1 };
        int[] gunBob = new int[] { 0, 1, 0, -1, 0, 1, 0, -1 };

        foreach (string d in dirs)
        {
            string dirPath = System.IO.Path.Combine(outDir, d);
            System.IO.Directory.CreateDirectory(dirPath);

            for (int f = 0; f < 8; f++)
            {
                using (Bitmap bmp = new Bitmap(frameW, frameH, PixelFormat.Format32bppArgb))
                using (Graphics g = Graphics.FromImage(bmp))
                {
                    g.Clear(Color.Transparent);

                    int curBob = bobY[f];
                    int cx = 24;
                    int cy = 18 + curBob;

                    // 1. LEGS & BOOTS
                    int lX = cx - 5 + (d == "east" || d == "west" ? leftLegX[f] : 0);
                    int rX = cx + 4 + (d == "east" || d == "west" ? rightLegX[f] : 0);
                    int lY = 38 + (d == "south" || d == "north" ? leftLegX[f] : 0);
                    int rY = 38 + (d == "south" || d == "north" ? rightLegX[f] : 0);

                    // Left Boot
                    FillRect(bmp, lX, lY, 4, 6, Color.FromArgb(255, 45, 28, 14));
                    bmp.SetPixel(lX, lY + 5, Color.FromArgb(255, 210, 220, 230)); // Spur

                    // Right Boot
                    FillRect(bmp, rX, rY, 4, 6, Color.FromArgb(255, 45, 28, 14));
                    bmp.SetPixel(rX + 3, rY + 5, Color.FromArgb(255, 210, 220, 230)); // Spur

                    // 2. DUSTER COAT & BODY
                    int coatW = 16;
                    int coatH = 18;
                    int coatX = cx - 8;
                    int coatY = cy + 4;

                    // Coat Body
                    FillRect(bmp, coatX, coatY, coatW, coatH, Color.FromArgb(255, 155, 98, 52));
                    // Coat Outlines & Shadow
                    DrawRect(bmp, coatX, coatY, coatW, coatH, Color.FromArgb(255, 95, 58, 28));

                    // Front Vest / Shirt (if facing south/east/west)
                    if (d != "north")
                    {
                        FillRect(bmp, cx - 2, coatY + 2, 4, 9, Color.FromArgb(255, 60, 48, 38));
                        // Bandolier diagonal
                        for (int b = 0; b < 6; b++)
                        {
                            int bx = cx - 4 + b;
                            int by = coatY + 3 + b;
                            bmp.SetPixel(bx, by, Color.FromArgb(255, 55, 32, 15));
                            if (b % 2 == 0) bmp.SetPixel(bx, by, Color.FromArgb(255, 245, 190, 35));
                        }
                    }

                    // Coat bottom flap flare
                    int flapOffset = (f % 4 < 2) ? 1 : -1;
                    FillRect(bmp, coatX - 1 + flapOffset, coatY + coatH - 4, 3, 4, Color.FromArgb(255, 138, 85, 45));
                    FillRect(bmp, coatX + coatW - 2 - flapOffset, coatY + coatH - 4, 3, 4, Color.FromArgb(255, 138, 85, 45));

                    // 3. HEAD & LYNX FACE
                    int headW = 14;
                    int headH = 10;
                    int headX = cx - 7;
                    int headY = cy - 6;

                    // Base Tan Head
                    FillRect(bmp, headX, headY, headW, headH, Color.FromArgb(255, 178, 120, 70));
                    // Cream Muzzle
                    FillRect(bmp, cx - 3, headY + 5, 6, 4, Color.FromArgb(255, 230, 195, 155));

                    // Facial details
                    if (d == "south" || d == "east" || d == "west")
                    {
                        // Nose
                        bmp.SetPixel(cx, headY + 5, Color.FromArgb(255, 40, 25, 15));
                        // Eyes (Amber)
                        if (d == "south")
                        {
                            bmp.SetPixel(cx - 3, headY + 3, Color.FromArgb(255, 255, 190, 0));
                            bmp.SetPixel(cx + 3, headY + 3, Color.FromArgb(255, 255, 190, 0));
                            // Whiskers
                            bmp.SetPixel(cx - 6, headY + 6, Color.FromArgb(255, 245, 245, 250));
                            bmp.SetPixel(cx + 6, headY + 6, Color.FromArgb(255, 245, 245, 250));
                        }
                        else if (d == "east")
                        {
                            bmp.SetPixel(cx + 2, headY + 3, Color.FromArgb(255, 255, 190, 0));
                            bmp.SetPixel(cx + 5, headY + 6, Color.FromArgb(255, 245, 245, 250));
                        }
                        else if (d == "west")
                        {
                            bmp.SetPixel(cx - 2, headY + 3, Color.FromArgb(255, 255, 190, 0));
                            bmp.SetPixel(cx - 5, headY + 6, Color.FromArgb(255, 245, 245, 250));
                        }
                    }

                    // 4. COWBOY HAT (With wide brim, tall crown, buckle & lynx ear tips)
                    int hatBrimW = 22;
                    int hatBrimX = cx - 11;
                    int hatBrimY = headY + 1;
                    int hatCrownW = 12;
                    int hatCrownX = cx - 6;
                    int hatCrownY = hatBrimY - 6;

                    // Crown
                    FillRect(bmp, hatCrownX, hatCrownY, hatCrownW, 6, Color.FromArgb(255, 142, 88, 46));
                    // Crown top crease
                    FillRect(bmp, hatCrownX + 2, hatCrownY, hatCrownW - 4, 1, Color.FromArgb(255, 85, 48, 22));
                    // Hat Band & Gold Buckle
                    FillRect(bmp, hatCrownX, hatBrimY - 1, hatCrownW, 1, Color.FromArgb(255, 35, 22, 12));
                    bmp.SetPixel(cx, hatBrimY - 1, Color.FromArgb(255, 255, 215, 0));

                    // Brim
                    FillRect(bmp, hatBrimX, hatBrimY, hatBrimW, 2, Color.FromArgb(255, 92, 54, 25));
                    // Curved brim tips
                    bmp.SetPixel(hatBrimX, hatBrimY - 1, Color.FromArgb(255, 92, 54, 25));
                    bmp.SetPixel(hatBrimX + hatBrimW - 1, hatBrimY - 1, Color.FromArgb(255, 92, 54, 25));

                    // Lynx Ear Tufts poking from hat sides
                    bmp.SetPixel(hatCrownX - 1, hatCrownY + 1, Color.FromArgb(255, 178, 120, 70));
                    bmp.SetPixel(hatCrownX - 1, hatCrownY, Color.FromArgb(255, 20, 20, 20)); // Black tip
                    bmp.SetPixel(hatCrownX + hatCrownW, hatCrownY + 1, Color.FromArgb(255, 178, 120, 70));
                    bmp.SetPixel(hatCrownX + hatCrownW, hatCrownY, Color.FromArgb(255, 20, 20, 20)); // Black tip

                    // 5. HEAVY WESTERN REVOLVER
                    if (d != "north")
                    {
                        int gx = (d == "west") ? (cx - 14) : ((d == "east") ? (cx + 8) : (cx + 7));
                        int gy = cy + 12 + gunBob[f];

                        // Long Steel Barrel
                        FillRect(bmp, gx, gy, 5, 2, Color.FromArgb(255, 50, 58, 68));
                        // Cylinder
                        FillRect(bmp, gx + 2, gy - 1, 2, 2, Color.FromArgb(255, 80, 90, 102));
                        // Wood Grip
                        FillRect(bmp, gx + 3, gy + 2, 2, 2, Color.FromArgb(255, 135, 68, 28));
                        // Shiny Muzzle Tip
                        bmp.SetPixel(gx, gy, Color.FromArgb(255, 170, 185, 205));
                    }

                    string framePath = System.IO.Path.Combine(dirPath, string.Format("frame_{0:D3}.png", f));
                    bmp.Save(framePath, ImageFormat.Png);
                }
            }
        }
    }

    private static void FillRect(Bitmap b, int x, int y, int w, int h, Color c)
    {
        for (int py = y; py < y + h; py++)
        {
            for (int px = x; px < x + w; px++)
            {
                if (px >= 0 && px < b.Width && py >= 0 && py < b.Height)
                {
                    b.SetPixel(px, py, c);
                }
            }
        }
    }

    private static void DrawRect(Bitmap b, int x, int y, int w, int h, Color c)
    {
        for (int px = x; px < x + w; px++)
        {
            if (px >= 0 && px < b.Width)
            {
                if (y >= 0 && y < b.Height) b.SetPixel(px, y, c);
                if ((y + h - 1) >= 0 && (y + h - 1) < b.Height) b.SetPixel(px, y + h - 1, c);
            }
        }
        for (int py = y; py < y + h; py++)
        {
            if (py >= 0 && py < b.Height)
            {
                if (x >= 0 && x < b.Width) b.SetPixel(x, py, c);
                if ((x + w - 1) >= 0 && (x + w - 1) < b.Width) b.SetPixel(x + w - 1, py, c);
            }
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$outDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\pixellab_prototype"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

[PixelLabAnimator]::GenerateWalkCycle($outDir)
Write-Output "PIXELLAB_WALK_CYCLE_GENERATED_SUCCESS"
