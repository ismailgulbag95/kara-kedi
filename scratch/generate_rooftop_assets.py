import math
import random
from PIL import Image, ImageDraw

def create_city_skyline(width=960, height=540, filename="assets/textures/city_skyline.png"):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 1. Gökyüzü Gece Degradesi (Derin Lacivert -> Koyu Mor Gece)
    for y in range(height):
        t = y / float(height)
        r = int(12 + 18 * t)
        g = int(15 + 16 * t)
        b = int(28 + 35 * t)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    # 2. Uzak Arka Plan Binaları (Silüetler - Koyu İndigo)
    random.seed(42)
    bldg_x = 0
    while bldg_x < width:
        b_w = random.randint(35, 75)
        b_h = random.randint(180, 320)
        b_top = height - b_h
        color = (18, 22, 38, 255)
        draw.rectangle([bldg_x, b_top, bldg_x + b_w, height], fill=color)

        # Uzak minik pencereler
        for wy in range(b_top + 15, height - 20, 18):
            for wx in range(bldg_x + 6, bldg_x + b_w - 6, 12):
                if random.random() < 0.28:
                    win_col = random.choice([
                        (255, 220, 120, 140), # Sıcak sarı
                        (140, 210, 255, 120), # Soğuk mavi
                        (255, 180, 200, 110)  # Pembe neon
                    ])
                    draw.rectangle([wx, wy, wx + 4, wy + 7], fill=win_col)
        bldg_x += b_w + random.randint(-4, 6)

    # 3. Orta Plan Binaları (Daha Net ve Işıklı)
    random.seed(1337)
    bldg_x = -15
    while bldg_x < width + 30:
        b_w = random.randint(45, 90)
        b_h = random.randint(140, 260)
        b_top = height - b_h
        color = (14, 18, 30, 255)
        draw.rectangle([bldg_x, b_top, bldg_x + b_w, height], fill=color)
        draw.rectangle([bldg_x, b_top, bldg_x + b_w, b_top + 3], fill=(30, 40, 60, 255)) # Çatı kenarı

        # Çatı anteni / kırmızı uyarı ışığı
        if random.random() < 0.45:
            ant_x = bldg_x + b_w // 2
            draw.line([(ant_x, b_top), (ant_x, b_top - 20)], fill=(45, 55, 75, 255), width=2)
            draw.ellipse([ant_x - 2, b_top - 24, ant_x + 2, b_top - 20], fill=(255, 60, 60, 220))

        # Pencereler
        for wy in range(b_top + 12, height - 15, 15):
            for wx in range(bldg_x + 8, bldg_x + b_w - 8, 11):
                if random.random() < 0.35:
                    win_col = random.choice([
                        (255, 235, 140, 190), # Parlak Altın
                        (100, 220, 255, 170), # Neon Cyan
                        (255, 140, 180, 160)  # Magenta
                    ])
                    draw.rectangle([wx, wy, wx + 5, wy + 8], fill=win_col)
        bldg_x += b_w + random.randint(2, 10)

    # 4. Alt Kısım Sis/Işık Halesi (Şehir Sokak Işıltısı)
    for y in range(height - 120, height):
        factor = (y - (height - 120)) / 120.0
        glow_col = (40, 35, 65, int(160 * factor))
        draw.line([(0, y), (width, y)], fill=glow_col)

    img.save(filename, "PNG")
    print(f"Saved {filename}")

def create_rooftop_floor(size=64, filename="assets/textures/rooftop_floor.png"):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Katranlı / Endüstriyel Çatı Plakası (Koyu Metalik Antrasit)
    draw.rectangle([0, 0, size, size], fill=(42, 46, 56, 255))
    draw.rectangle([2, 2, size - 3, size - 3], fill=(48, 53, 65, 255))

    # Plaka çizgileri & köşe cıvataları
    draw.line([(0, size - 1), (size, size - 1)], fill=(28, 30, 38, 255))
    draw.line([(size - 1, 0), (size - 1, size)], fill=(28, 30, 38, 255))
    draw.line([(0, 0), (size, 0)], fill=(65, 72, 88, 255))
    draw.line([(0, 0), (0, size)], fill=(65, 72, 88, 255))

    # Izgara doku deseni
    for y in range(8, size - 8, 8):
        for x in range(8, size - 8, 8):
            draw.point((x, y), fill=(38, 42, 52, 255))

    # Cıvatalar (4 köşe)
    bolts = [(6, 6), (size - 7, 6), (6, size - 7), (size - 7, size - 7)]
    for bx, by in bolts:
        draw.rectangle([bx - 1, by - 1, bx + 1, by + 1], fill=(80, 90, 110, 255))
        draw.point((bx, by), fill=(130, 145, 175, 255))

    img.save(filename, "PNG")
    print(f"Saved {filename}")

def create_rooftop_railing(width=64, height=64, filename="assets/textures/rooftop_railing.png"):
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Alt Beton / Çatı Parapet Bordürü
    draw.rectangle([0, 44, width, height], fill=(36, 40, 50, 255))
    draw.rectangle([0, 44, width, 48], fill=(68, 76, 92, 255)) # Üst ışık
    draw.rectangle([0, 60, width, 64], fill=(20, 22, 28, 255)) # Alt gölge

    # Sarı-Siyah Güvenlik / İkaz Çizgileri
    for x in range(-16, width + 16, 16):
        draw.polygon([(x, 48), (x + 8, 48), (x + 16, 60), (x + 8, 60)], fill=(220, 180, 40, 255))

    # Demir Çit Korkuluk Direkleri (Çift Direk)
    posts = [8, width - 8]
    for px in posts:
        draw.rectangle([px - 2, 8, px + 2, 44], fill=(70, 78, 95, 255))
        draw.rectangle([px - 1, 8, px + 1, 44], fill=(110, 125, 150, 255)) # Parlama
        # Direk başı
        draw.ellipse([px - 3, 5, px + 3, 11], fill=(130, 145, 175, 255))

    # Yatay Güvenlik Rayları (3 Sıra Demir Boru)
    for ry in [14, 26, 38]:
        draw.rectangle([0, ry - 2, width, ry + 2], fill=(50, 56, 68, 255))
        draw.line([(0, ry - 1), (width, ry - 1)], fill=(120, 135, 160, 255))
        draw.line([(0, ry + 1), (width, ry + 1)], fill=(25, 28, 35, 255))

    img.save(filename, "PNG")
    print(f"Saved {filename}")

if __name__ == "__main__":
    create_city_skyline()
    create_rooftop_floor()
    create_rooftop_railing()
