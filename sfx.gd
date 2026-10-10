extends Node
# Autoload "Sfx": sound pool, looping music, shared font, haptics and settings.
var snd := {}
var pool: Array = []
var idx := 0
var music: AudioStreamPlayer
var muted := false
var vibe := true
var font: Font

func _ready() -> void:
	font = ThemeDB.fallback_font
	if ResourceLoader.exists("res://bold.ttf"):
		font = load("res://bold.ttf")
	for n in ["tap", "win", "lose", "pop", "tick", "up", "hit", "start", "jump", "slice", "boss"]:
		snd[n] = load("res://%s.wav" % n)
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	music = AudioStreamPlayer.new()
	music.stream = load("res://music.wav")
	music.volume_db = -9.0
	music.finished.connect(_loop)
	add_child(music)
	music.play()

func _loop() -> void:
	music.play()

func play(n: String, pitch: float = 1.0) -> void:
	if muted:
		return
	var p: AudioStreamPlayer = pool[idx]
	idx = (idx + 1) % pool.size()
	p.stream = snd[n]
	p.pitch_scale = pitch
	p.play()

func buzz(ms: int) -> void:
	if vibe:
		Input.vibrate_handheld(ms)

func set_muted(m: bool) -> void:
	muted = m
	music.stream_paused = m
