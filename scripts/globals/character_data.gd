extends Node

## Karakter Sınıfları Veritabanı ve Başarım/Kilit Tanımları (Singleton / Data)

const CHARACTERS = {
	"standard": {
		"id": "standard",
		"name": "Kara Kedi",
		"title": "Dengeli Sokak Savaşçısı",
		"description": "Klasik, dengeli ve her alanda istikrarlı sokak kedisi.",
		"portrait": "res://assets/textures/player_character/rotations/south.png",
		"base_path": "res://assets/textures/player_character/",
		"start_weapon": "sword",
		"start_weapon_name": "Kara Çelik Kılıç",
		"max_hp": 100.0,
		"move_speed": 220.0,
		"dmg_mult": 1.0,
		"attack_speed": 1.0,
		"crit_chance": 0.05,
		"range_bonus": 0.0,
		"buffs": ["Tüm temel statlar dengeli."],
		"debuffs": ["Hiçbir debuff veya zayıflığı yok."],
		"unlocked_by_default": true,
		"unlock_condition_text": "Başlangıçtan itibaren Açık."
	},
	"marksman": {
		"id": "marksman",
		"name": "Nişancı Kedi",
		"title": "Vahşi Batı Vaşağı (The Gunslinger)",
		"description": "Uzak mesafeden ağır mermiler yağdıran keskin nişancı kovboy vaşağı.",
		"portrait": "res://assets/textures/characters/marksman/portrait.png",
		"base_path": "res://assets/textures/characters/marksman/",
		"start_weapon": "magnum",
		"start_weapon_name": "Ağır Magnum",
		"max_hp": 80.0,
		"move_speed": 225.0,
		"dmg_mult": 1.4,
		"attack_speed": 1.0,
		"crit_chance": 0.15,
		"range_bonus": 100.0,
		"buffs": [
			"+%40 Menzilli Silah Hasarı",
			"+%30 Mermi Hızı & +100px Menzil",
			"+%15 Kritik Vuruş Şansı"
		],
		"debuffs": [
			"-%50 Yakın Dövüş Hasarı",
			"-20 Maksimum Can (80 HP)"
		],
		"unlocked_by_default": false,
		"unlock_condition_text": "Ağır Magnum ile toplam 100 fare öldür."
	}
}

static func get_character(id: String) -> Dictionary:
	if CHARACTERS.has(id):
		return CHARACTERS[id]
	return CHARACTERS["standard"]
