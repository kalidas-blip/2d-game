extends Node2D
# Game flow: menu -> play (micro-game) -> result -> next ... -> game over. Every 8th game is a boss.
const GAMES := ["catch", "pop", "dodge", "stop", "whack", "odd", "mash", "jump", "slice"]
const MAX_LIVES := 5
var state := "menu"
var lives := 4
var score := 0
var best := 0
var new_best := false
var streak := 0
var spd := 1.0
var played := 0
var last := ""
var cur = null
var hud = null
var won := false
var boss_win := false
var banner := ""
var rtimer := 0.0
var pt := 0.0
var hud_t := 0.0
var shake := 0.0
var fade := 1.0

func _ready() -> void:
	randomize()
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		best = int(cfg.get_value("s", "best", 0))
		Sfx.vibe = bool(cfg.get_value("s", "vibe", true))
		Sfx.set_muted(bool(cfg.get_value("s", "mute", false)))
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	hud = (load("res://hud.gd") as GDScript).new()
	hud.g = self
	layer.add_child(hud)

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("s", "best", best)
	cfg.set_value("s", "vibe", Sfx.vibe)
	cfg.set_value("s", "mute", Sfx.muted)
	cfg.save("user://save.cfg")

func start_run() -> void:
	lives = 4
	score = 0
	streak = 0
	spd = 1.0
	played = 0
	last = ""
	new_best = false
	Sfx.music.pitch_scale = 1.0
	Sfx.play("tap")
	next_game()

func next_game() -> void:
	if cur != null:
		cur.queue_free()
		cur = null
	played += 1
	banner = ""
	var boss := played % 8 == 0
	var n := "boss"
	if boss:
		banner = "BOSS STAGE!"
		Sfx.play("boss")
	else:
		n = GAMES[randi() % GAMES.size()]
		while n == last:
			n = GAMES[randi() % GAMES.size()]
		if played > 1 and (played - 1) % 4 == 0:
			spd = minf(spd * 1.15, 2.6)
			banner = "SPEED UP!"
			Sfx.music.pitch_scale = 1.0 + (spd - 1.0) * 0.2
			Sfx.play("up")
	last = n
	var g: GDScript = load("res://%s.gd" % n)
	cur = g.new()
	cur.spd = minf(spd, 1.3) if boss else spd
	cur.done.connect(on_done)
	add_child(cur)
	state = "play"
	pt = 0.0
	fade = 1.0
	if not boss:
		Sfx.play("start")

func on_done(w: bool) -> void:
	won = w
	state = "result"
	rtimer = 1.1
	boss_win = w and last == "boss"
	if w:
		streak += 1
		score += 3 if boss_win else 1
		if boss_win:
			lives = mini(lives + 1, MAX_LIVES)
			Sfx.play("up")
		Sfx.play("win", minf(1.0 + streak * 0.04, 1.3))
		Sfx.buzz(25)
	else:
		streak = 0
		lives -= 1
		shake = 1.0
		Sfx.play("lose")
		Sfx.buzz(200)

func end_run() -> void:
	if cur != null:
		cur.queue_free()
		cur = null
	if score > best:
		best = score
		new_best = true
		save()
	Sfx.music.pitch_scale = 1.0
	state = "over"
	rtimer = 0.8
	fade = 1.0

func go_menu() -> void:
	if cur != null:
		cur.queue_free()
		cur = null
	Sfx.music.stream_paused = Sfx.muted
	Sfx.music.pitch_scale = 1.0
	state = "menu"
	fade = 1.0

func pause_game() -> void:
	state = "pause"
	if cur != null:
		cur.set_process(false)
		cur.set_process_input(false)
	Sfx.music.stream_paused = true

func resume_game() -> void:
	state = "play"
	if cur != null:
		cur.set_process(true)
		cur.set_process_input(true)
	Sfx.music.stream_paused = Sfx.muted

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if state == "play":
			pause_game()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if state == "menu":
			get_tree().quit()
		elif state == "play":
			pause_game()
		elif state == "pause" or state == "over":
			go_menu()

func _process(d: float) -> void:
	hud_t += d
	fade = maxf(0.0, fade - d * 4.0)
	if state == "play":
		pt += d
	elif state == "result":
		rtimer -= d
		if rtimer <= 0.0:
			if lives <= 0:
				end_run()
			else:
				next_game()
	elif state == "over":
		rtimer = maxf(0.0, rtimer - d)
	shake = maxf(0.0, shake - d * 2.5)
	position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake * 18.0

func _input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton):
		return
	var b := e as InputEventMouseButton
	if not b.pressed or b.button_index != MOUSE_BUTTON_LEFT:
		return
	var p := b.position
	if state == "menu":
		if Rect2(40, 1150, 310, 90).has_point(p):
			Sfx.set_muted(not Sfx.muted)
			save()
		elif Rect2(370, 1150, 310, 90).has_point(p):
			Sfx.vibe = not Sfx.vibe
			save()
			Sfx.buzz(40)
		else:
			start_run()
	elif state == "pause":
		if p.y > 1040.0:
			go_menu()
		else:
			resume_game()
	elif state == "over" and rtimer <= 0.0:
		if p.y > 1140.0:
			go_menu()
		else:
			start_run()
