extends Node

## Profesyonel Prosedürel Ses Sentezleyici Motoru (Organic DSP Audio Manager)
## Ateri/bip sesleri yerine tok baslı, organik ve sinematik ses dalgaları üretir.

var players_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 16

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		players_pool.append(player)

func _get_available_player() -> AudioStreamPlayer:
	for player in players_pool:
		if not player.playing:
			return player
	return players_pool[0]

# --- 1. KESKİN RÜZGAR VE METALİK KILIÇ/PENÇE SAVURMA SESİ ---
func play_slash() -> void:
	var sample_rate = 44100
	var duration = 0.16
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var prev_noise = 0.0
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		var white = randf_range(-1.0, 1.0)
		prev_noise = lerp(prev_noise, white, 0.45)
		
		var freq = lerp(650.0, 220.0, progress)
		var tone = sin(t * freq * TAU) * 0.4
		
		var env = sin(progress * PI) * (1.0 - progress * 0.3)
		var sample_val = clampf((prev_noise * 0.6 + tone) * env * 0.75, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -2.0
	p.pitch_scale = randf_range(0.92, 1.08)
	p.play()

# --- MAGNUM, GLOCK VE YAY ATEŞ SESLERİ ---
func play_magnum() -> void:
	var sample_rate = 44100
	var duration = 0.32
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		var boom = sin(t * lerp(120.0, 30.0, progress) * TAU)
		var crack = randf_range(-1.0, 1.0) * exp(-progress * 28.0)
		var env = exp(-progress * 9.0)
		var val = clampf((boom * 0.8 + crack * 0.6) * env * 0.95, -1.0, 1.0)
		data.encode_s16(i * 2, int(val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 2.0
	p.pitch_scale = randf_range(0.94, 1.06)
	p.play()

func play_glock() -> void:
	var sample_rate = 44100
	var duration = 0.12
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		var pop = sin(t * lerp(260.0, 60.0, progress) * TAU)
		var snap = randf_range(-1.0, 1.0) * exp(-progress * 35.0)
		var env = exp(-progress * 18.0)
		var val = clampf((pop * 0.7 + snap * 0.5) * env * 0.85, -1.0, 1.0)
		data.encode_s16(i * 2, int(val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -1.0
	p.pitch_scale = randf_range(0.95, 1.08)
	p.play()

func play_bow() -> void:
	var sample_rate = 44100
	var duration = 0.18
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		var twang = sin(t * lerp(340.0, 160.0, progress) * TAU)
		var swoosh = randf_range(-1.0, 1.0) * sin(progress * PI) * 0.3
		var env = exp(-progress * 12.0)
		var val = clampf((twang * 0.75 + swoosh) * env * 0.8, -1.0, 1.0)
		data.encode_s16(i * 2, int(val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -1.5
	p.pitch_scale = randf_range(0.92, 1.08)
	p.play()

# --- 2. TOK VE ETLİ VURUŞ SESİ (HEAVY IMPACT HIT) ---
func play_hit() -> void:
	var sample_rate = 44100
	var duration = 0.14
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		# Derin Sub-Bass düşüşü (160Hz -> 38Hz)
		var freq = lerp(160.0, 38.0, progress * progress)
		var bass = sin(t * freq * TAU)
		
		# Anlık etli darbe çıtırtısı (transient)
		var snap = randf_range(-1.0, 1.0) * exp(-progress * 25.0) * 0.6
		
		var env = exp(-progress * 14.0)
		var sample_val = clampf((bass * 0.85 + snap) * env * 0.85, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 0.0
	p.pitch_scale = randf_range(0.90, 1.10)
	p.play()

# --- 3. KARAKTER TOK HASAR ALMA SESİ (DAMAGE RUMBLE / GRUNT) ---
func play_damage() -> void:
	var sample_rate = 44100
	var duration = 0.22
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		var freq = lerp(90.0, 30.0, progress)
		var rumble = sin(t * freq * TAU) + sin(t * (freq * 0.5) * TAU) * 0.5
		var env = exp(-progress * 8.0)
		
		var sample_val = clampf(rumble * env * 0.9, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 2.0
	p.pitch_scale = randf_range(0.85, 1.05)
	p.play()

func play_hurt() -> void:
	play_damage()

# --- 4. SİNEMATİK BAS BOMBA PATLAMASI (CINEMATIC BASS BOOM) ---
func play_bomb_boom() -> void:
	var sample_rate = 44100
	var duration = 0.45
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var smooth_noise = 0.0
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		# Low-pass gürültü patlaması
		smooth_noise = lerp(smooth_noise, randf_range(-1.0, 1.0), 0.25)
		# Devasa Sub-bass darbesi (85Hz -> 24Hz)
		var bass = sin(t * lerp(85.0, 24.0, progress) * TAU) * 0.9
		
		var env = exp(-progress * 6.5)
		var sample_val = clampf((smooth_noise * 0.7 + bass) * env * 0.9, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 2.5
	p.pitch_scale = randf_range(0.9, 1.05)
	p.play()

# --- 5. BERRAK ARMONİK KRİSTAL KOİN SESİ (GLASSY CRYSTAL CHIME) ---
func play_coin() -> void:
	var sample_rate = 44100
	var duration = 0.15
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		# Çift kristal armonik (1350Hz + 2700Hz)
		var chime1 = sin(t * 1350.0 * TAU)
		var chime2 = sin(t * 2700.0 * TAU) * 0.45
		var chime3 = sin(t * 4050.0 * TAU) * 0.2
		
		var env = exp(-progress * 16.0)
		var sample_val = clampf((chime1 + chime2 + chime3) * env * 0.55, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -4.0
	p.pitch_scale = randf_range(0.98, 1.06)
	p.play()

# --- 6. DEVASE BOSS KÜKREMESİ (BOSS ROAR) ---
func play_boss_roar() -> void:
	var sample_rate = 44100
	var duration = 0.75
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var lpf = 0.0
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		lpf = lerp(lpf, randf_range(-1.0, 1.0), 0.15)
		var growl = sin(t * (60.0 + sin(t * 24.0) * 20.0) * TAU) * 0.8
		var env = sin(progress * PI) * (1.0 - progress * 0.2)
		
		var sample_val = clampf((lpf * 0.7 + growl) * env * 0.95, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 3.0
	p.play()

# --- 7. YÜKSELTME VE ZAFER FANFARI (VICTORY & UPGRADE) ---
func play_upgrade() -> void:
	play_coin()

func play_wave_horn() -> void:
	play_boss_roar()

func play_victory() -> void:
	var sample_rate = 44100
	var duration = 1.2
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		# Fanfar akoru (Do - Mi - Sol - Do)
		var chord = sin(t * 523.25 * TAU) * 0.4 + sin(t * 659.25 * TAU) * 0.35 + sin(t * 783.99 * TAU) * 0.35 + sin(t * 1046.5 * TAU) * 0.25
		var env = exp(-progress * 3.0)
		var sample_val = clampf(chord * env * 0.85, -1.0, 1.0)
		var s16 = int(sample_val * 32767.0)
		data.encode_s16(i * 2, s16)
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 2.0
	p.play()
