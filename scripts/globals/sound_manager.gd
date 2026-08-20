extends Node

## Profesyonel Prosedürel Ses & Müzik Sentezleyici Motoru (Organic DSP Audio & Voice AI Synthesizer)
## Ateri/bip sesleri yerine tok baslı, organik ve sinematik ses dalgaları, miyavlama ses sentezleyicisi ve procedural Synthwave BGM üretir.

var players_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 18

var bgm_player: AudioStreamPlayer
var current_bgm_track: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		players_pool.append(player)
		
	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)
	
	play_bgm("synthwave_wave")

func _get_available_player() -> AudioStreamPlayer:
	for player in players_pool:
		if not player.playing:
			return player
	return players_pool[0]

# --- 1. KEDI MİYAVLAMA & SES SENTEZLEYİCİSİ (VOICE AI MEOW SYNTHESIZER) ---
func play_meow(pitch_variant: float = 1.0) -> void:
	var sample_rate = 44100
	var duration = 0.38
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		
		# Miyav Formant Eğrisi: 550Hz -> 1250Hz -> 750Hz (Miy-Aaa-Uuu)
		var base_freq = 600.0
		if progress < 0.35:
			base_freq = lerp(550.0, 1300.0, progress / 0.35)
		else:
			base_freq = lerp(1300.0, 700.0, (progress - 0.35) / 0.65)
			
		var tone = sin(t * base_freq * TAU) * 0.5
		var harmonic = sin(t * base_freq * 2.0 * TAU) * 0.3
		var sub = sin(t * (base_freq * 0.5) * TAU) * 0.25
		
		var env = sin(progress * PI)
		var sample_val = clampf((tone + harmonic + sub) * env * 0.65, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample_val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -1.0
	p.pitch_scale = randf_range(0.95, 1.12) * pitch_variant
	p.play()

# --- 2. PENÇE ATILIMI (DODGE DASH WHOOSH) ---
func play_dash() -> void:
	var sample_rate = 44100
	var duration = 0.22
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var lpf = 0.0
	for i in range(num_samples):
		var progress = float(i) / float(num_samples)
		var white = randf_range(-1.0, 1.0)
		lpf = lerp(lpf, white, 0.35)
		var env = sin(progress * PI)
		data.encode_s16(i * 2, int(lpf * env * 0.7 * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -1.5
	p.pitch_scale = randf_range(1.1, 1.3)
	p.play()

# --- 3. SİLAH EVRİMİ (WEAPON FUSION CHIME) ---
func play_evolution() -> void:
	var sample_rate = 44100
	var duration = 1.4
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var progress = float(i) / float(num_samples)
		var chord = sin(t * 523.25 * TAU) * 0.35 + sin(t * 659.25 * TAU) * 0.35 + sin(t * 783.99 * TAU) * 0.3 + sin(t * 1046.5 * TAU) * 0.3
		var sparkle = sin(t * (2093.0 + sin(t * 15.0) * 120.0) * TAU) * 0.2
		var env = exp(-progress * 2.5)
		data.encode_s16(i * 2, int(clampf((chord + sparkle) * env * 0.85, -1.0, 1.0) * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 3.0
	p.play()

# --- 4. PROCEDURAL SYNTHWAVE BGM OYNATICI ---
func play_bgm(track_name: String) -> void:
	if current_bgm_track == track_name and bgm_player.playing:
		return
	current_bgm_track = track_name
	
	var stream = _generate_bgm_loop(track_name)
	bgm_player.stream = stream
	bgm_player.volume_db = -9.0
	bgm_player.play()

func _generate_bgm_loop(track_name: String) -> AudioStreamWAV:
	var sample_rate = 22050 # Hafif retro modülasyon
	var duration = 6.0 # 6 saniyelik dikişsiz synth döngüsü
	var num_samples = int(sample_rate * duration)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = num_samples
	
	var data = PackedByteArray()
	data.resize(num_samples * 2)
	
	var bpm = 124.0 if track_name == "synthwave_wave" else (140.0 if track_name == "boss_synth" else 90.0)
	var bps = bpm / 60.0
	
	for i in range(num_samples):
		var t = float(i) / float(sample_rate)
		var beat = fmod(t * bps, 1.0)
		@warning_ignore("unused_variable")
		var progress = float(i) / float(num_samples)
		
		var sample_val = 0.0
		if track_name == "synthwave_wave":
			# 80s Synthwave Arpeggio Bass & Pad
			var bass_freq = 65.41 # C2
			if fmod(t * bps, 4.0) > 2.0:
				bass_freq = 87.31 # F2
			var bass = sin(t * bass_freq * TAU) * 0.4
			var arp_notes = [261.63, 329.63, 392.00, 523.25]
			var note_idx = int(fmod(t * bps * 4.0, 4.0))
			var arp = sin(t * arp_notes[note_idx] * TAU) * 0.25 * exp(-beat * 6.0)
			sample_val = bass + arp
		elif track_name == "boss_synth":
			# Heavy Industrial Boss Metal Synth
			var b_freq = 43.65 if fmod(t * bps, 2.0) < 1.0 else 51.91
			var dist = clampf(sin(t * b_freq * TAU) * 2.5, -0.8, 0.8)
			var pulse = sin(t * (b_freq * 2.0) * TAU) * 0.3
			sample_val = (dist + pulse) * 0.5
		else:
			# Lo-Fi Shop Cat Track (Sıcak Lo-Fi Akorlar)
			var chord_c = sin(t * 261.63 * TAU) * 0.3 + sin(t * 329.63 * TAU) * 0.25 + sin(t * 392.00 * TAU) * 0.2
			sample_val = chord_c * 0.6
			
		data.encode_s16(i * 2, int(clampf(sample_val * 0.6, -1.0, 1.0) * 32767.0))
		
	stream.data = data
	return stream

# --- 5. DİĞER SES EFEKTLERİ ---
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
		data.encode_s16(i * 2, int(sample_val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -2.0
	p.pitch_scale = randf_range(0.92, 1.08)
	p.play()

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
	play_slash()

func play_bow() -> void:
	play_slash()

func play_hit() -> void:
	play_meow(0.85)

func play_damage() -> void:
	play_meow(0.75)

func play_hurt() -> void:
	play_meow(0.75)

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
		smooth_noise = lerp(smooth_noise, randf_range(-1.0, 1.0), 0.25)
		var bass = sin(t * lerp(85.0, 24.0, progress) * TAU) * 0.9
		var env = exp(-progress * 6.5)
		var sample_val = clampf((smooth_noise * 0.7 + bass) * env * 0.9, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample_val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = 2.5
	p.play()

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
		var chime1 = sin(t * 1350.0 * TAU)
		var chime2 = sin(t * 2700.0 * TAU) * 0.45
		var env = exp(-progress * 16.0)
		var sample_val = clampf((chime1 + chime2) * env * 0.55, -1.0, 1.0)
		data.encode_s16(i * 2, int(sample_val * 32767.0))
		
	stream.data = data
	var p = _get_available_player()
	p.stream = stream
	p.volume_db = -4.0
	p.play()

func play_boss_roar() -> void:
	play_bgm("boss_synth")

func play_upgrade() -> void:
	play_coin()

func play_wave_horn() -> void:
	play_coin()

func play_victory() -> void:
	play_evolution()

func play_explosion() -> void:
	play_bomb_boom()

func play_enemy_death() -> void:
	play_hit()
