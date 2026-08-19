Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Drawing.Text;

public class ShowcaseBuilder
{
    public static void BuildShowcase(string pathA, string pathB, string pathC, string outPath)
    {
        int canvasW = 900;
        int canvasH = 480;

        using (Bitmap bmp = new Bitmap(canvasW, canvasH, PixelFormat.Format32bppArgb))
        using (Graphics g = Graphics.FromImage(bmp))
        {
            g.Clear(Color.FromArgb(255, 12, 16, 24));
            g.InterpolationMode = InterpolationMode.NearestNeighbor;
            g.PixelOffsetMode = PixelOffsetMode.Half;
            g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;

            // Title
            using (Font titleFont = new Font("Segoe UI", 18, FontStyle.Bold))
            using (Font subFont = new Font("Segoe UI", 11, FontStyle.Regular))
            using (Font cardTitleFont = new Font("Segoe UI", 13, FontStyle.Bold))
            using (Font tagFont = new Font("Segoe UI", 10, FontStyle.Bold))
            using (Font descFont = new Font("Segoe UI", 10, FontStyle.Regular))
            {
                // Header
                g.DrawString("NİŞANCI KEDİ - 48x48 PİKSEL SPRITE SEÇENEKLERİ", titleFont, new SolidBrush(Color.FromArgb(255, 245, 190, 35)), 20, 20);
                g.DrawString("Beğendiğiniz seçeneği (A, B veya C) belirterek 8-yönlü yürüme animasyonunu ürettirebilirsiniz.", subFont, new SolidBrush(Color.FromArgb(255, 150, 165, 185)), 22, 52);

                string[] titles = new string[] { "SEÇENEK A: Kovboy Vaşak", "SEÇENEK B: Gölge Noir / Mafya", "SEÇENEK C: Askeri Komando" };
                Color[] tagColors = new Color[] { Color.FromArgb(255, 245, 190, 35), Color.FromArgb(255, 0, 229, 255), Color.FromArgb(255, 118, 255, 3) };
                string[] descs = new string[] {
                    "• Sıcak vaşak kumralı kürk\n• Taba kovboy fötr şapkası & toka\n• Ahşap kabzalı Ağır Magnum\n• Çapraz altın fişeklik & göz bandı",
                    "• Kömür / gece siyahı asil kürk\n• Koyu gri Peaky / Noir kasket\n• Gümüş / krom gövdeli Magnum\n• Parlayan mavi monokl & kırmızı fular",
                    "• Kamuflaj haki / zeytin kürk\n• Altın bröveli askeri bere\n• Lazerli taktik susturucu tabanca\n• Haki hücum yeleği & taktik göz"
                };
                string[] paths = new string[] { pathA, pathB, pathC };

                for (int i = 0; i < 3; i++)
                {
                    int cardX = 20 + (i * 290);
                    int cardY = 90;
                    int cardW = 270;
                    int cardH = 360;

                    // Card Background
                    using (SolidBrush bg = new SolidBrush(Color.FromArgb(255, 18, 24, 36)))
                    using (Pen borderPen = new Pen(tagColors[i], 2))
                    {
                        g.FillRectangle(bg, cardX, cardY, cardW, cardH);
                        g.DrawRectangle(borderPen, cardX, cardY, cardW, cardH);
                    }

                    // Tag
                    g.DrawString(titles[i], cardTitleFont, new SolidBrush(tagColors[i]), cardX + 14, cardY + 12);

                    // Sprite Stage
                    int stageX = cardX + (cardW - 144) / 2;
                    int stageY = cardY + 45;
                    using (SolidBrush stageBg = new SolidBrush(Color.FromArgb(255, 8, 11, 18)))
                    using (Pen stagePen = new Pen(Color.FromArgb(255, 45, 60, 85), 1))
                    {
                        g.FillRectangle(stageBg, stageX, stageY, 144, 144);
                        g.DrawRectangle(stagePen, stageX, stageY, 144, 144);
                    }

                    // Draw 48x48 sprite enlarged (3x = 144px)
                    if (System.IO.File.Exists(paths[i]))
                    {
                        using (Bitmap sprite = (Bitmap)Image.FromFile(paths[i]))
                        {
                            g.DrawImage(sprite, new Rectangle(stageX, stageY, 144, 144), new Rectangle(0, 0, sprite.Width, sprite.Height), GraphicsUnit.Pixel);
                        }
                    }

                    // Descriptions
                    g.DrawString(descs[i], descFont, new SolidBrush(Color.FromArgb(255, 200, 210, 225)), cardX + 14, cardY + 205);
                }
            }

            bmp.Save(outPath, ImageFormat.Png);
        }
    }
}
"@ -ReferencedAssemblies System.Drawing

$dir = "d:\benim antigravitiler\kara kedi\assets\textures\characters\marksman\variants"
$out = "$dir\karsilastirma_tablosu.png"

[ShowcaseBuilder]::BuildShowcase("$dir\variant_a.png", "$dir\variant_b.png", "$dir\variant_c.png", $out)

# Copy to brain artifact directory so it embeds seamlessly
Copy-Item $out "C:\Users\ismai\.gemini\antigravity-ide\brain\200944e6-2772-419b-99f4-ab75905f249b\karsilastirma_tablosu.png" -Force

Write-Output "SHOWCASE_IMAGE_GENERATED_SUCCESS"
