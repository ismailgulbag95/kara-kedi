import math
import random
from PIL import Image, ImageDraw

def create_topdown_rooftop_floor(size=128, filename="assets/textures/topdown_rooftop_floor.png"):
    img = Image.new("RGBA", (size, size), (34, 38, 48, 255))
    draw = ImageDraw.Draw(img)

    # 1. Çatı Katran & Çakıl Dokusu
    random.seed(101)
    for y in range(size):
        for x in range(size):
            noise = random.randint(-4, 4)
            r = max(26, min(50, 36 + noise))
            g = max(30, min(55, 40 + noise))
            b = max(40, min(68, 50 + noise))
            draw.point((x, y), fill=(r, g, b, 255))

    # 2. 64x64 Beton Plaka Derz Çizgileri
    for offset in [0, 64]:
        draw.line([(0, offset), (size, offset)], fill=(20, 22, 30, 255), width=2)
        draw.line([(offset, 0), (offset, size)], fill=(20, 22, 30, 255), width=2)
        draw.line([(0, offset + 1), (size, offset + 1)], fill=(55, 62, 78, 255), width=1)
        draw.line([(offset + 1, 0), (offset + 1, size)], fill=(55, 62, 78, 255), width=1)

    # 3. Su Tahliye Mazgalı (Drain Grate - 64x64 ortasında)
    gx, gy = 32, 32
    draw.rectangle([gx - 8, gy - 8, gx + 8, gy + 8], fill=(18, 20, 26, 255))
    for i in range(-6, 7, 3):
        draw.line([(gx + i, gy - 6), (gx + i, gy + 6)], fill=(50, 56, 70, 255))
        draw.line([(gx - 6, gy + i), (gx + 6, gy + i)], fill=(28, 32, 40, 255))

    img.save(filename, "PNG")
    print(f"Saved {filename}")

def create_topdown_parapet_ledge(size=64, filename="assets/textures/topdown_parapet_ledge.png"):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Üstten Bakış Kalın Çatı Parapet Duvarı / Bordürü
    # İç yüzey (çatıya bakan), üst kalın taş blok, dış uçurum gölgesi
    draw.rectangle([0, 0, size, size], fill=(45, 50, 64, 255))
    
    # Blok derzleri
    draw.line([(0, 0), (size, 0)], fill=(75, 84, 106, 255), width=3) # Dış parlak kenar
    draw.line([(0, size - 2), (size, size - 2)], fill=(22, 25, 34, 255), width=2) # İç gölge
    
    # Dikey taş blok ayrım çizgileri
    for bx in [0, 32, 64]:
        draw.line([(bx, 0), (bx, size)], fill=(25, 28, 38, 255), width=2)
        draw.line([(bx + 1, 0), (bx + 1, size)], fill=(65, 74, 95, 255), width=1)

    # Sarı-Siyah Güvenlik Şeridi (İç Kenar Boyunca)
    for x in range(-16, size + 16, 16):
        draw.polygon([(x, size - 12), (x + 8, size - 12), (x + 16, size - 2), (x + 8, size - 2)], fill=(230, 185, 35, 255))
        draw.polygon([(x + 8, size - 12), (x + 16, size - 12), (x + 24, size - 2), (x + 16, size - 2)], fill=(30, 32, 40, 255))

    img.save(filename, "PNG")
    print(f"Saved {filename}")

def create_ac_fan_sprites(filename_body="assets/textures/topdown_ac_body.png", filename_blade="assets/textures/topdown_fan_blade.png"):
    # 1. AC Havalandırma Kasası (64x64 Üstten Bakış)
    body = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d_body = ImageDraw.Draw(body)
    
    # Metal kasa
    d_body.rectangle([4, 4, 60, 60], fill=(52, 58, 72, 255))
    d_body.rectangle([6, 6, 58, 58], fill=(62, 70, 86, 255))
    d_body.rectangle([4, 4, 60, 6], fill=(85, 96, 118, 255)) # Işık
    d_body.rectangle([4, 58, 60, 60], fill=(28, 32, 42, 255)) # Gölge
    
    # Dairesel fan ızgara deliği
    d_body.ellipse([10, 10, 54, 54], fill=(16, 18, 24, 255))
    d_body.ellipse([11, 11, 53, 53], fill=(22, 26, 34, 255))
    
    # Köşe vidaları
    for cx, cy in [(8, 8), (56, 8), (8, 56), (56, 56)]:
        d_body.rectangle([cx-1, cy-1, cx+1, cy+1], fill=(120, 135, 165, 255))

    body.save(filename_body, "PNG")
    print(f"Saved {filename_body}")

    # 2. Dönen Fan Pervanesi (4 Kanat - 48x48)
    blade = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d_blade = ImageDraw.Draw(blade)
    cx, cy = 24, 24
    
    # 4 kanat
    for angle in [0, 90, 180, 270]:
        rad = math.radians(angle)
        rad_w = math.radians(angle + 35)
        p1 = (cx, cy)
        p2 = (cx + int(20 * math.cos(rad)), cy + int(20 * math.sin(rad)))
        p3 = (cx + int(18 * math.cos(rad_w)), cy + int(18 * math.sin(rad_w)))
        d_blade.polygon([p1, p2, p3], fill=(140, 155, 180, 240))
        d_blade.line([p1, p2], fill=(200, 215, 240, 255), width=2)
    
    # Orta göbek
    d_blade.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=(70, 80, 100, 255))
    d_blade.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=(180, 195, 220, 255))
    
    blade.save(filename_blade, "PNG")
    print(f"Saved {filename_blade}")

def create_water_tower(filename="assets/textures/topdown_water_tower.png"):
    img = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Üstten Bakış Yuvarlak Su Deposu
    cx, cy = 48, 48
    # Ayak gölgeleri
    for lx, ly in [(16, 16), (80, 16), (16, 80), (80, 80)]:
        draw.line([(lx, ly), (cx, cy)], fill=(12, 14, 20, 180), width=4)

    # Dış çember (ahşap/çelik fıçı gövde)
    draw.ellipse([14, 14, 82, 82], fill=(55, 60, 72, 255))
    draw.ellipse([16, 16, 80, 80], fill=(68, 75, 90, 255))
    
    # Konik çatı panelleri (8 dilim)
    for a in range(0, 360, 45):
        rad = math.radians(a)
        ex = cx + int(32 * math.cos(rad))
        ey = cy + int(32 * math.sin(rad))
        draw.line([(cx, cy), (ex, ey)], fill=(40, 45, 56, 255), width=2)
        draw.line([(cx, cy), (ex + 1, ey + 1)], fill=(90, 100, 120, 180), width=1)

    # Tepe kapağı
    draw.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], fill=(95, 108, 130, 255))
    draw.ellipse([cx - 4, cy - 4, cx + 4, cy + 4], fill=(130, 145, 175, 255))

    img.save(filename, "PNG")
    print(f"Saved {filename}")

if __name__ == "__main__":
    create_topdown_rooftop_floor()
    create_topdown_parapet_ledge()
    create_ac_fan_sprites()
    create_water_tower()
