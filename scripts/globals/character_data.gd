class_name CharacterData
extends RefCounted

## Karakter Sınıfları Veritabanı ve Başarım/Kilit Tanımları (Static Data)


const CHARACTERS = {
	"standard": {
		"id": "standard",
		"name": "Kara Kedi",
		"title": "Dengeli Sokak Savaşçısı",
		"description": "Klasik, dengeli ve her alanda istikrarlı usta sokak kedisi.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"start_weapon": "sword",
		"start_weapon_name": "Kara Çelik Kılıç",
		"max_hp": 100.0,
		"move_speed": 220.0,
		"dmg_mult": 1.0,
		"attack_speed": 1.0,
		"crit_chance": 0.05,
		"armor": 0.0,
		"thorns": 0.0,
		"range_bonus": 0.0,
		"coin_mult": 1.0,
		"buffs": ["Tüm temel statlar dengeli ve çok yönlü."],
		"debuffs": ["Özel bir dezavantajı yok."],
		"unlocked_by_default": true
	},
	"marksman": {
		"id": "marksman",
		"name": "Nişancı Kedi",
		"title": "Keskin Gözlü Kovboy",
		"description": "Uzak mesafeden seri mermiler yağdıran hızlı silahşör.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"start_weapon": "glock",
		"start_weapon_name": "Seri Glock",
		"max_hp": 85.0,
		"move_speed": 230.0,
		"dmg_mult": 1.25,
		"attack_speed": 1.1,
		"crit_chance": 0.15,
		"armor": 0.0,
		"thorns": 0.0,
		"range_bonus": 60.0,
		"coin_mult": 1.0,
		"buffs": ["+%25 Hasar & +60px Saldırı Menzili", "+%15 Kritik Vuruş Şansı"],
		"debuffs": ["-15 Maksimum Can (85 HP)"],
		"unlocked_by_default": true
	},
	"brawler": {
		"id": "brawler",
		"name": "Vahşi Pençeci",
		"title": "Çılgın Sokak Boksörü",
		"description": "Düşmanların içine atılıp fırtına gibi pençe savuran yakın dövüş canavarı.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"start_weapon": "claws",
		"start_weapon_name": "Jilet Pençeler",
		"max_hp": 90.0,
		"move_speed": 245.0,
		"dmg_mult": 1.0,
		"attack_speed": 1.4,
		"crit_chance": 0.08,
		"armor": 1.0,
		"thorns": 0.0,
		"range_bonus": -25.0,
		"coin_mult": 1.0,
		"buffs": ["+%40 Saldırı Hızı", "+25 Hareket Hızı"],
		"debuffs": ["-%25 Saldırı Menzili"],
		"unlocked_by_default": true
	},
	"tank": {
		"id": "tank",
		"name": "Zırhlı Şövalye",
		"title": "Yıkılmaz Kaya Kedi",
		"description": "Ağır zırhı ve dikenleriyle fare sürülerine meydan okuyan dayanıklı tank.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"start_weapon": "sword",
		"start_weapon_name": "Kara Çelik Kılıç",
		"max_hp": 135.0,
		"move_speed": 185.0,
		"dmg_mult": 1.0,
		"attack_speed": 0.9,
		"crit_chance": 0.05,
		"armor": 4.0,
		"thorns": 8.0,
		"range_bonus": 0.0,
		"coin_mult": 1.0,
		"buffs": ["+35 Maksimum Can (135 HP)", "+4 Zırh & +8 Yansıtılan Diken Hasarı"],
		"debuffs": ["-%15 Hareket Hızı (185)"],
		"unlocked_by_default": true
	},
	"pirate": {
		"id": "pirate",
		"name": "Korsan Kedi",
		"title": "Hazine Avcısı",
		"description": "Bumerangıyla ganimet toplayan ve her köşeden altın çıkaran kurnaz korsan.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"start_weapon": "fish_boomerang",
		"start_weapon_name": "Kılçık Bumerang",
		"max_hp": 90.0,
		"move_speed": 225.0,
		"dmg_mult": 0.85,
		"attack_speed": 1.0,
		"crit_chance": 0.20,
		"armor": 0.0,
		"thorns": 0.0,
		"range_bonus": 20.0,
		"coin_mult": 1.5,
		"buffs": ["+%50 Fazla Koin Kazancı", "+%20 Yüksek Kritik Şansı"],
		"debuffs": ["-%15 Taban Hasar"],
		"unlocked_by_default": true
	}
}

static func get_character(id: String) -> Dictionary:
	if CHARACTERS.has(id):
		return CHARACTERS[id]
	return CHARACTERS["standard"]

