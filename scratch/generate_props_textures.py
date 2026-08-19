from PIL import Image, ImageDraw

def create_milk_bowl():
    # 20x20 pixel art milk bowl
    img = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Outer dark bowl rim
    # Red ceramic bowl with white/cream milk and highlight
    bowl_rim = (190, 50, 45, 255)
    bowl_base = (140, 30, 30, 255)
    bowl_shadow = (80, 15, 20, 255)
    milk_color = (245, 250, 255, 255)
    milk_shine = (255, 255, 255, 255)
    
    # Bowl shape
    draw.ellipse([2, 5, 17, 16], fill=bowl_base, outline=bowl_shadow)
    # Milk surface
    draw.ellipse([3, 5, 16, 11], fill=bowl_rim)
    draw.ellipse([4, 6, 15, 10], fill=milk_color)
    # Milk shine
    draw.point((7, 7), fill=milk_shine)
    draw.point((8, 7), fill=milk_shine)
    draw.point((6, 8), fill=milk_shine)
    
    img.save("assets/textures/milk_bowl.png")
    print("Created assets/textures/milk_bowl.png")

def create_loot_crate():
    # 28x28 pixel art wooden crate
    img = Image.new("RGBA", (28, 28), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    wood_dark = (75, 45, 25, 255)
    wood_mid = (145, 95, 55, 255)
    wood_light = (195, 140, 85, 255)
    wood_highlight = (225, 175, 115, 255)
    iron_brace = (60, 65, 80, 255)
    iron_rivet = (180, 190, 210, 255)
    
    # Main wood background
    draw.rectangle([2, 2, 25, 25], fill=wood_mid, outline=wood_dark)
    
    # Planks lines
    draw.line([(3, 9), (24, 9)], fill=wood_dark, width=1)
    draw.line([(3, 17), (24, 17)], fill=wood_dark, width=1)
    
    # Cross brace (X)
    draw.line([(4, 4), (23, 23)], fill=iron_brace, width=2)
    draw.line([(4, 23), (23, 4)], fill=iron_brace, width=2)
    
    # Outer frame
    draw.rectangle([2, 2, 25, 25], outline=iron_brace, width=2)
    
    # Top highlight
    draw.line([(3, 3), (24, 3)], fill=wood_highlight, width=1)
    draw.line([(3, 3), (3, 24)], fill=wood_light, width=1)
    
    # Corner rivets
    for rx, ry in [(4, 4), (23, 4), (4, 23), (23, 23), (14, 14)]:
        draw.point((rx, ry), fill=iron_rivet)
        
    img.save("assets/textures/loot_crate.png")
    print("Created assets/textures/loot_crate.png")

if __name__ == "__main__":
    create_milk_bowl()
    create_loot_crate()
