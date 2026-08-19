Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public class AsepriteWalkEngineFixed
{
    public static void GenerateAsepriteWalk(string frontPath, string backPath, string sidePath, string outSheetPath, string outFramesDir)
    {
        int frameSize = 256;
        int sheetW = frameSize * 4;
        int sheetH = frameSize * 4;

        using (Bitmap frontRaw = (Bitmap)Image.FromFile(frontPath))
        using (Bitmap backRaw = (Bitmap)Image.FromFile(backPath))
        using (Bitmap sideRaw = (Bitmap)Image.FromFile(sidePath))
        using (Bitmap masterSheet = new Bitmap(sheetW, sheetH, PixelFormat.Format32bppArgb))
        using (Graphics gSheet = Graphics.FromImage(masterSheet))
        {
            gSheet.Clear(Color.FromArgb(255, 10, 14, 22));

            // Clean & prepare 4 directional bases scaled to 220x220 inside 256x256
            Bitmap[] baseDirs = new Bitmap[4];
            baseDirs[0] = PrepareBase(frontRaw, frameSize, false);
            baseDirs[1] = PrepareBase(backRaw, frameSize, false);
            baseDirs[2] = PrepareBase(sideRaw, frameSize, false);
            baseDirs[3] = PrepareBase(sideRaw, frameSize, true); // West mirrored

            string[] dirNames = new string[] { "south", "north", "east", "west" };

            // 4 Aseprite keyframes:
            // 0: Left step forward
            // 1: Passing (Down)
            // 2: Right step forward
            // 3: Passing (Up)
            int[] bodyBob = new int[] { 0, 5, 0, -4 };
            int[] legLShift = new int[] { -10, -2, 8, -2 };
            int[] legRShift = new int[] { 8, -2, -10, -2 };

            for (int r = 0; r < 4; r++)
            {
                string dName = dirNames[r];
                string dDir = System.IO.Path.Combine(outFramesDir, dName);
                System.IO.Directory.CreateDirectory(dDir);

                Bitmap baseImg = baseDirs[r];
                bool isSide = (r >= 2);

                int headH = (int)(frameSize * 0.40); // Head & hat
                int torsoH = (int)(frameSize * 0.32); // Torso & coat
                int legsH = frameSize - headH - torsoH; // Legs & boots

                Rectangle srcHead = new Rectangle(0, 0, frameSize, headH);
                Rectangle srcTorso = new Rectangle(0, headH, frameSize, torsoH);
                Rectangle srcLeftLeg = new Rectangle(0, headH + torsoH, frameSize / 2, legsH);
                Rectangle srcRightLeg = new Rectangle(frameSize / 2, headH + torsoH, frameSize / 2, legsH);
                Rectangle srcFullLegs = new Rectangle(0, headH + torsoH, frameSize, legsH);

                for (int c = 0; c < 4; c++)
                {
                    int bBob = bodyBob[c];
                    int lL = legLShift[c];
                    int lR = legRShift[c];

                    using (Bitmap frameBmp = new Bitmap(frameSize, frameSize, PixelFormat.Format32bppArgb))
                    using (Graphics gFrame = Graphics.FromImage(frameBmp))
                    {
                        gFrame.Clear(Color.Transparent);
                        gFrame.InterpolationMode = InterpolationMode.NearestNeighbor;
                        gFrame.PixelOffsetMode = PixelOffsetMode.Half;

                        int destHeadY = 8 + bBob;
                        int destTorsoY = destHeadY + headH;
                        int destLegsY = destTorsoY + torsoH - 6;

                        // 1. LEGS (Behind coat)
                        if (isSide)
                        {
                            int stride = (c == 0) ? -12 : ((c == 2) ? 12 : 0);
                            int legBob = (c == 1) ? 3 : ((c == 3) ? -3 : 0);

                            // Back Leg
                            gFrame.DrawImage(baseImg,
                                new Rectangle(stride, destLegsY + legBob, frameSize, legsH),
                                srcFullLegs, GraphicsUnit.Pixel);

                            // Front Leg
                            gFrame.DrawImage(baseImg,
                                new Rectangle(-stride, destLegsY, frameSize, legsH),
                                srcFullLegs, GraphicsUnit.Pixel);
                        }
                        else
                        {
                            // Front / Back View
                            // Left Leg
                            gFrame.DrawImage(baseImg,
                                new Rectangle(0, destLegsY + (c == 0 ? -4 : (c == 2 ? 4 : 0)), frameSize / 2, legsH),
                                srcLeftLeg, GraphicsUnit.Pixel);

                            // Right Leg
                            gFrame.DrawImage(baseImg,
                                new Rectangle(frameSize / 2, destLegsY + (c == 2 ? -4 : (c == 0 ? 4 : 0)), frameSize / 2, legsH),
                                srcRightLeg, GraphicsUnit.Pixel);
                        }

                        // 2. TORSO & COAT (Solid, stays anchored)
                        gFrame.DrawImage(baseImg,
                            new Rectangle(0, destTorsoY, frameSize, torsoH),
                            srcTorso, GraphicsUnit.Pixel);

                        // 3. HEAD & HAT (Bobs naturally)
                        gFrame.DrawImage(baseImg,
                            new Rectangle(0, destHeadY, frameSize, headH),
                            srcHead, GraphicsUnit.Pixel);

                        // Save frame
                        string fPath = System.IO.Path.Combine(dDir, string.Format("frame_{0:D3}.png", c));
                        frameBmp.Save(fPath, ImageFormat.Png);

                        // Draw on master sheet
                        gSheet.DrawImage(frameBmp, new Rectangle(c * frameSize, r * frameSize, frameSize, frameSize));
                    }
                }
            }

            masterSheet.Save(outSheetPath, ImageFormat.Png);

            // Clean up bases
            for (int i = 0; i < 4; i++) baseDirs[i].Dispose();
        }
    }

    private static Bitmap PrepareBase(Bitmap src, int targetSize, bool mirrorX)
    {
        Bitmap res = new Bitmap(targetSize, targetSize, PixelFormat.Format32bppArgb);
        using (Graphics g = Graphics.FromImage(res))
        {
            g.Clear(Color.Transparent);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = PixelOffsetMode.Half;

            // Find bounds inside src (excluding black background)
            int minX = src.Width, maxX = 0, minY = src.Height, maxY = 0;
            for (int y = 0; y < src.Height; y += 4)
            {
                for (int x = 0; x < src.Width; x += 4)
                {
                    Color p = src.GetPixel(x, y);
                    if (p.R > 25 || p.G > 25 || p.B > 25)
                    {
                        if (x < minX) minX = x;
                        if (x > maxX) maxX = x;
                        if (y < minY) minY = y;
                        if (y > maxY) maxY = y;
                    }
                }
            }

            if (minX >= maxX || minY >= maxY)
            {
                minX = 0; maxX = src.Width - 1; minY = 0; maxY = src.Height - 1;
            }

            int charW = maxX - minX + 1;
            int charH = maxY - minY + 1;

            int drawH = (int)(targetSize * 0.88);
            int drawW = (int)((float)charW / charH * drawH);
            int destX = (targetSize - drawW) / 2;
            int destY = (targetSize - drawH) / 2 + 4;

            if (mirrorX)
            {
                g.DrawImage(src,
                    new Rectangle(destX + drawW, destY, -drawW, drawH),
                    new Rectangle(minX, minY, charW, charH),
                    GraphicsUnit.Pixel);
            }
            else
            {
                g.DrawImage(src,
                    new Rectangle(destX, destY, drawW, drawH),
                    new Rectangle(minX, minY, charW, charH),
                    GraphicsUnit.Pixel);
            }

            // Remove any remaining pure black pixels
            for (int y = 0; y < targetSize; y++)
            {
                for (int x = 0; x < targetSize; x++)
                {
                    Color p = res.GetPixel(x, y);
                    if (p.R < 25 && p.G < 25 && p.B < 25)
                    {
                        res.SetPixel(x, y, Color.Transparent);
                    }
                }
            }
        }
        return res;
    }
}
"@ -ReferencedAssemblies System.Drawing

$brain = "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b"
$front = "$brain\master_ref_front_south_1787148164831.jpg"
$back = "$brain\master_ref_back_turnaround_1787148385273.jpg"
$side = "$brain\master_ref_side_east_1787148212697.jpg"

$destDir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\hd_prototype"
$sheetPath = "$destDir\master_16frame_turnaround_sheet.png"

[AsepriteWalkEngineFixed]::GenerateAsepriteWalk($front, $back, $side, $sheetPath, $destDir)
Write-Output "ALL_ASEPRITE_FRAMES_RENDERED_SUCCESSFULLY"
