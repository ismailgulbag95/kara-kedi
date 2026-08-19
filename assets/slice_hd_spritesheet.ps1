Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class SpriteSheetSlicer
{
    public static void SliceSheet(string srcPath, string outDir)
    {
        using (Bitmap sheet = (Bitmap)Image.FromFile(srcPath))
        {
            int totalW = sheet.Width;
            int totalH = sheet.Height;

            int cols = 4;
            int rows = 4;
            int cellW = totalW / cols;
            int cellH = totalH / rows;

            string[] dirNames = new string[] { "south", "north", "east", "west" };

            for (int r = 0; r < rows; r++)
            {
                string d = dirNames[r];
                string dPath = System.IO.Path.Combine(outDir, d);
                System.IO.Directory.CreateDirectory(dPath);

                for (int c = 0; c < cols; c++)
                {
                    int startX = c * cellW;
                    int startY = r * cellH;

                    // Exclude top-left text label header if row 0 has it
                    int insetX = 6;
                    int insetY = (c == 0) ? 28 : 6;
                    int cropW = cellW - 12;
                    int cropH = cellH - 12;

                    using (Bitmap cell = new Bitmap(cropW, cropH, PixelFormat.Format32bppArgb))
                    using (Graphics g = Graphics.FromImage(cell))
                    {
                        g.DrawImage(sheet, new Rectangle(0, 0, cropW, cropH),
                                     new Rectangle(startX + insetX, startY + insetY, cropW, cropH), GraphicsUnit.Pixel);

                        // Chroma-key background (dark gray around #282828..#383838)
                        Color bgSample = sheet.GetPixel(startX + cellW / 2, startY + 8);
                        int bgR = bgSample.R, bgG = bgSample.G, bgB = bgSample.B;

                        for (int y = 0; y < cropH; y++)
                        {
                            for (int x = 0; x < cropW; x++)
                            {
                                Color p = cell.GetPixel(x, y);
                                int dist = Math.Abs(p.R - bgR) + Math.Abs(p.G - bgG) + Math.Abs(p.B - bgB);
                                // Also check for dark border lines
                                if (dist < 32 || (p.R < 35 && p.G < 35 && p.B < 35 && (x < 4 || x > cropW - 5 || y < 4 || y > cropH - 5)))
                                {
                                    cell.SetPixel(x, y, Color.Transparent);
                                }
                            }
                        }

                        // Resize to clean 128x128 high-res frame
                        using (Bitmap outFrame = new Bitmap(128, 128, PixelFormat.Format32bppArgb))
                        using (Graphics gOut = Graphics.FromImage(outFrame))
                        {
                            gOut.InterpolationMode = InterpolationMode.NearestNeighbor;
                            gOut.PixelOffsetMode = PixelOffsetMode.Half;
                            gOut.DrawImage(cell, new Rectangle(0, 0, 128, 128));

                            string outFileName = System.IO.Path.Combine(dPath, string.Format("frame_{0:D3}.png", c));
                            outFrame.Save(outFileName, ImageFormat.Png);
                        }
                    }
                }
            }
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$srcSheet = "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b\marksman_walk_spritesheet_1787147565272.jpg"
$destDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\hd_prototype"
New-Item -ItemType Directory -Path $destDir -Force | Out-Null

[SpriteSheetSlicer]::SliceSheet($srcSheet, $destDir)
Write-Output "HD_SPRITESHEET_SLICED_SUCCESSFULLY"
