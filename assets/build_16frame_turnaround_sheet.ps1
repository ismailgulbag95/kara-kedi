Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class MasterSheetSynthesizer
{
    public static void Synthesize(string frontPath, string backPath, string sidePath, string outSheetPath, string outFramesDir)
    {
        int cellW = 256;
        int cellH = 256;
        int sheetW = cellW * 4;
        int sheetH = cellH * 4;

        using (Bitmap frontBmp = (Bitmap)Image.FromFile(frontPath))
        using (Bitmap backBmp = (Bitmap)Image.FromFile(backPath))
        using (Bitmap sideBmp = (Bitmap)Image.FromFile(sidePath))
        using (Bitmap masterSheet = new Bitmap(sheetW, sheetH, PixelFormat.Format32bppArgb))
        using (Graphics gSheet = Graphics.FromImage(masterSheet))
        {
            gSheet.Clear(Color.Black);

            Bitmap[] baseDirs = new Bitmap[] { frontBmp, backBmp, sideBmp, sideBmp };
            string[] dirNames = new string[] { "south", "north", "east", "west" };

            // Walk offsets for 4 keyframes:
            // Frame 0: Left leg forward, coat slight tilt left, y=0
            // Frame 1: Passing pose, bob down y=3, knees bent
            // Frame 2: Right leg forward, coat slight tilt right, y=0
            // Frame 3: Passing pose, bob up y=-2
            int[] bobY = new int[] { 0, 4, 0, -3 };
            int[] legShift = new int[] { -6, 0, 6, 0 };

            for (int r = 0; r < 4; r++)
            {
                string dName = dirNames[r];
                string dDir = System.IO.Path.Combine(outFramesDir, dName);
                System.IO.Directory.CreateDirectory(dDir);

                Bitmap baseImg = baseDirs[r];
                bool isWest = (r == 3);

                for (int c = 0; c < 4; c++)
                {
                    int shift = legShift[c];
                    int bob = bobY[c];

                    using (Bitmap frameBmp = new Bitmap(cellW, cellH, PixelFormat.Format32bppArgb))
                    using (Graphics gFrame = Graphics.FromImage(frameBmp))
                    {
                        gFrame.Clear(Color.Transparent);
                        gFrame.InterpolationMode = InterpolationMode.HighQualityBicubic;
                        gFrame.PixelOffsetMode = PixelOffsetMode.Half;

                        // Upper body (Hat, Head, Gun Arm) with bob
                        int upperH = (int)(baseImg.Height * 0.58);
                        Rectangle srcUpper = new Rectangle(0, 0, baseImg.Width, upperH);
                        Rectangle dstUpper = new Rectangle(0, bob + 4, cellW, (int)(cellW * 0.58));

                        // Lower body (Legs, Boots, Lower Coat) with leg stride
                        int lowerH = baseImg.Height - upperH;
                        Rectangle srcLower = new Rectangle(0, upperH, baseImg.Width, lowerH);
                        Rectangle dstLower = new Rectangle((r >= 2 ? shift : 0), bob + dstUpper.Bottom - 8, cellW, cellH - dstUpper.Bottom + 8);

                        // Draw on frame
                        if (isWest)
                        {
                            // Draw Mirrored
                            gFrame.DrawImage(baseImg, new Rectangle(cellW, dstUpper.Y, -cellW, dstUpper.Height), srcUpper, GraphicsUnit.Pixel);
                            gFrame.DrawImage(baseImg, new Rectangle(cellW + (r >= 2 ? -shift : 0), dstLower.Y, -cellW, dstLower.Height), srcLower, GraphicsUnit.Pixel);
                        }
                        else
                        {
                            gFrame.DrawImage(baseImg, dstUpper, srcUpper, GraphicsUnit.Pixel);
                            gFrame.DrawImage(baseImg, dstLower, srcLower, GraphicsUnit.Pixel);
                        }

                        // Remove black background for transparent PNG
                        for (int y = 0; y < cellH; y++)
                        {
                            for (int x = 0; x < cellW; x++)
                            {
                                Color p = frameBmp.GetPixel(x, y);
                                if (p.R < 30 && p.G < 30 && p.B < 30)
                                {
                                    frameBmp.SetPixel(x, y, Color.Transparent);
                                }
                            }
                        }

                        // Save individual frame
                        string fPath = System.IO.Path.Combine(dDir, string.Format("frame_{0:D3}.png", c));
                        frameBmp.Save(fPath, ImageFormat.Png);

                        // Draw onto master sheet
                        gSheet.DrawImage(frameBmp, new Rectangle(c * cellW, r * cellH, cellW, cellH));
                    }
                }
            }

            masterSheet.Save(outSheetPath, ImageFormat.Png);
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b"
$front = "$brain\master_ref_front_south_1787148164831.jpg"
$back = "$brain\master_ref_back_turnaround_1787148385273.jpg"
$side = "$brain\master_ref_side_east_1787148212697.jpg"

$destDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\hd_prototype"
$sheetPath = "$destDir\master_16frame_turnaround_sheet.png"

[MasterSheetSynthesizer]::Synthesize($front, $back, $side, $sheetPath, $destDir)
Write-Output "MASTER_16FRAME_SHEET_SYNTHESIZED_SUCCESS"
