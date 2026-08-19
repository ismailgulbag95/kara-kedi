Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class CleanWalkSlicer
{
    public static void ProcessAll(string southImg, string northImg, string eastImg, string outBaseDir)
    {
        Process2x2(southImg, System.IO.Path.Combine(outBaseDir, "south"), false);
        Process2x2(northImg, System.IO.Path.Combine(outBaseDir, "north"), false);
        Process2x2(eastImg, System.IO.Path.Combine(outBaseDir, "east"), false);
        Process2x2(eastImg, System.IO.Path.Combine(outBaseDir, "west"), true); // Mirror for west
    }

    private static void Process2x2(string srcPath, string outDir, bool mirrorH)
    {
        System.IO.Directory.CreateDirectory(outDir);
        using (Bitmap sheet = (Bitmap)Image.FromFile(srcPath))
        {
            int totalW = sheet.Width;
            int totalH = sheet.Height;
            int halfW = totalW / 2;
            int halfH = totalH / 2;

            // 4 quadrants: (0,0), (halfW,0), (0,halfH), (halfW,halfH)
            Rectangle[] quads = new Rectangle[] {
                new Rectangle(0, 0, halfW, halfH),
                new Rectangle(halfW, 0, halfW, halfH),
                new Rectangle(0, halfH, halfW, halfH),
                new Rectangle(halfW, halfH, halfW, halfH)
            };

            for (int i = 0; i < 4; i++)
            {
                Rectangle q = quads[i];
                using (Bitmap quadBmp = new Bitmap(q.Width, q.Height, PixelFormat.Format32bppArgb))
                using (Graphics g = Graphics.FromImage(quadBmp))
                {
                    g.DrawImage(sheet, new Rectangle(0, 0, q.Width, q.Height), q, GraphicsUnit.Pixel);

                    // Chroma key solid black background
                    int minX = q.Width, maxX = 0, minY = q.Height, maxY = 0;
                    for (int y = 0; y < q.Height; y++)
                    {
                        for (int x = 0; x < q.Width; x++)
                        {
                            Color p = quadBmp.GetPixel(x, y);
                            // Pure black or near black
                            if (p.R < 28 && p.G < 28 && p.B < 28)
                            {
                                quadBmp.SetPixel(x, y, Color.Transparent);
                            }
                            else
                            {
                                if (x < minX) minX = x;
                                if (x > maxX) maxX = x;
                                if (y < minY) minY = y;
                                if (y > maxY) maxY = y;
                            }
                        }
                    }

                    // Centered 128x128 output
                    using (Bitmap outFrame = new Bitmap(128, 128, PixelFormat.Format32bppArgb))
                    using (Graphics gOut = Graphics.FromImage(outFrame))
                    {
                        gOut.InterpolationMode = InterpolationMode.NearestNeighbor;
                        gOut.PixelOffsetMode = PixelOffsetMode.Half;

                        if (maxX > minX && maxY > minY)
                        {
                            int charW = maxX - minX + 1;
                            int charH = maxY - minY + 1;
                            int targetH = 116;
                            int targetW = (int)((float)charW / charH * targetH);
                            int destX = (128 - targetW) / 2;
                            int destY = (128 - targetH) / 2 + 4;

                            if (mirrorH)
                            {
                                // Draw mirrored horizontally
                                gOut.DrawImage(quadBmp,
                                    new Rectangle(destX + targetW, destY, -targetW, targetH),
                                    new Rectangle(minX, minY, charW, charH),
                                    GraphicsUnit.Pixel);
                            }
                            else
                            {
                                gOut.DrawImage(quadBmp,
                                    new Rectangle(destX, destY, targetW, targetH),
                                    new Rectangle(minX, minY, charW, charH),
                                    GraphicsUnit.Pixel);
                            }
                        }

                        string outFileName = System.IO.Path.Combine(outDir, string.Format("frame_{0:D3}.png", i));
                        outFrame.Save(outFileName, ImageFormat.Png);
                    }
                }
            }
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b"
$south = "$brain\marksman_front_walk_cycle_1787147819185.jpg"
$north = "$brain\marksman_back_walk_cycle_1787147836217.jpg"
$east = "$brain\marksman_side_walk_cycle_1787147799268.jpg"

$outDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\hd_prototype"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

[CleanWalkSlicer]::ProcessAll($south, $north, $east, $outDir)
Write-Output "ALL_CLEAN_WALK_CYCLES_SLICED_SUCCESSFULLY"
