extends Node2D
# Draws menu, pause and game-over screens, fuse timer, hearts, score and result banners.
const W := 720.0
const H := 1280.0
var g = null
var f: Font
var tex := {}
var sb := StyleBoxFlat.new()
var conf: Array = []
var prev := ""
var ink := Color(0.17, 0.1, 0.24)

func _ready() -> void:
	f = Sfx.font
	for n in ["hero", "hero_happy", "hero_sad", "bomb", "heart"]:
		tex[n] = load("res://%s.png" % n)

func spawn_confetti(n: int) -> void:
	var cols := [Color("#ffe14d"), Color("#ff6ba6"), Color("#7bf1a8"), Color("#6ec6ff"), Color("#ffffff")]
	for i in n:
		conf.append({"p": Vector2(randf() * W, -20.0 - randf() * 400.0), "v": Vector2(randf_range(-90.0, 90.0), randf_range(180.0, 520.0)), "a": randf() * TAU, "w": randf_range(-8.0, 8.0), "c": cols[randi() % cols.size()]})

func _process(delta: float) -> void:
	if g == null:
		return
	var st: String = g.state
	if st != prev:
		if st == "result" and g.won:
			spawn_confetti(70 if g.boss_win else 36)
		prev = st
	for q in conf:
		q.p += q.v * delta
		q.v = Vector2(q.v.x * 0.99, q.v.y + 900.0 * delta)
		q.a += q.w * delta
	conf = conf.filter(func(q): return q.p.y < H + 40.0)
	queue_redraw()

func txt(s: String, p: Vector2, size: int, col := Color.WHITE, a := 1.0, al: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER, w := W) -> void:
	col.a = a
	draw_string_outline(f, p, s, al, w, size, 14, Color(ink.r, ink.g, ink.b, a))
	draw_string(f, p, s, al, w, size, col)

func ptxt(s: String, y: float, size: int, k: float, col: Color, rot := 0.0, a := 1.0) -> void:
	draw_set_transform(Vector2(W / 2.0, y), rot, Vector2(k, k))
	txt(s, Vector2(-W / 2.0, 0.0), size, col, a)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func panel(r: Rect2, col: Color) -> void:
	sb.bg_color = col
	sb.set_corner_radius_all(24)
	sb.border_color = ink
	sb.set_border_width_all(6)
	draw_style_box(sb, r)

func rays(c1: Color, c2: Color, t: float) -> void:
	draw_rect(Rect2(0, 0, W, H), c1)
	var c := Vector2(W / 2.0, H / 2.0)
	for i in 10:
		var a := t * 0.25 + i * TAU / 10.0
		draw_colored_polygon(PackedVector2Array([c, c + Vector2.from_angle(a) * 1500.0, c + Vector2.from_angle(a + TAU / 20.0) * 1500.0]), c2)
	for i in 14:
		var x := fposmod(i * 97.0 + t * 20.0 * (1.0 + i % 3), 800.0) - 40.0
		var y := fposmod(i * 131.0 - t * (30.0 + i * 7.0), 1400.0) - 60.0
		draw_circle(Vector2(x, y), 14.0 + (i % 4) * 10.0, Color(1, 1, 1, 0.1))

func hero_at(n: String, p: Vector2, sz: float, rot: float) -> void:
	draw_set_transform(p, rot, Vector2.ONE)
	draw_texture_rect(tex[n], Rect2(-sz / 2.0, -sz / 2.0, sz, sz), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw() -> void:
	if g == null:
		return
	var st: String = g.state
	var t: float = g.hud_t
	if st == "menu":
		menu(t)
	elif st == "over":
		over(t)
	else:
		play(t)
		if st == "pause":
			pause_screen(t)
	for q in conf:
		draw_set_transform(q.p, q.a, Vector2.ONE)
		draw_rect(Rect2(-9, -5, 18, 10), q.c)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if g.fade > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0.1, 0.05, 0.2, g.fade * 0.85))

func menu(t: float) -> void:
	rays(Color("#4b2371"), Color("#6a35a0"), t)
	ptxt("MICRO", 400, 170, 1.0 + sin(t * 3.0) * 0.04, Color("#ffe14d"), sin(t * 2.0) * 0.04)
	ptxt("MANIA", 580, 170, 1.0 + sin(t * 3.0 + 1.5) * 0.04, Color("#ff6ba6"), -sin(t * 2.0) * 0.04)
	hero_at("hero", Vector2(360.0, 830.0 + sin(t * 5.0) * 18.0), 300.0, sin(t * 4.0) * 0.12)
	ptxt("TAP TO PLAY", 1040, 84, 1.0 + sin(t * 6.0) * 0.06, Color.WHITE)
	txt("BEST " + str(g.best), Vector2(0, 1110), 44, Color("#ffe14d"))
	panel(Rect2(40, 1150, 310, 90), Color("#8a7aa8") if Sfx.muted else Color("#7bf1a8"))
	txt("SOUND " + ("OFF" if Sfx.muted else "ON"), Vector2(40, 1210), 38, Color.WHITE, 1.0, HORIZONTAL_ALIGNMENT_CENTER, 310.0)
	panel(Rect2(370, 1150, 310, 90), Color("#7bf1a8") if Sfx.vibe else Color("#8a7aa8"))
	txt("VIBRATE " + ("ON" if Sfx.vibe else "OFF"), Vector2(370, 1210), 38, Color.WHITE, 1.0, HORIZONTAL_ALIGNMENT_CENTER, 310.0)

func over(t: float) -> void:
	rays(Color("#7a1f3d"), Color("#9c2c52"), t)
	ptxt("GAME", 300, 160, 1.0, Color.WHITE, -0.05)
	ptxt("OVER", 470, 160, 1.0 + sin(t * 4.0) * 0.03, Color("#ff5d8f"), 0.05)
	hero_at("hero_sad", Vector2(360.0, 690.0 + sin(t * 3.0) * 8.0), 240.0, sin(t * 2.0) * 0.08)
	ptxt("SCORE " + str(g.score), 920, 96, 1.0, Color("#ffe14d"))
	if g.new_best:
		ptxt("NEW BEST!", 1010, 76, 1.0 + sin(t * 8.0) * 0.08, Color("#7bf1a8"))
	else:
		txt("BEST " + str(g.best), Vector2(0, 1010), 60)
	if g.rtimer <= 0.0:
		ptxt("TAP TO RETRY", 1100, 70, 1.0 + sin(t * 6.0) * 0.05, Color.WHITE)
		panel(Rect2(220, 1160, 280, 84), Color("#ff6ba6"))
		txt("MENU", Vector2(0, 1218), 46)

func pause_screen(t: float) -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.08, 0.04, 0.18, 0.8))
	ptxt("PAUSED", 520, 150, 1.0 + sin(t * 4.0) * 0.03, Color("#ffe14d"))
	ptxt("TAP TO RESUME", 680, 64, 1.0 + sin(t * 6.0) * 0.05, Color.WHITE)
	panel(Rect2(220, 1060, 280, 84), Color("#ff6ba6"))
	txt("QUIT", Vector2(0, 1118), 46)

func play(t: float) -> void:
	var cur = g.cur
	if cur == null:
		return
	draw_rect(Rect2(0, 0, W, 140), Color(0.1, 0.05, 0.25, 0.55))
	var lv := int(g.lives)
	for i in maxi(4, lv):
		var c := Color.WHITE if i < lv else Color(0.15, 0.15, 0.2, 0.6)
		draw_texture_rect(tex["heart"], Rect2(22 + i * 58, 12, 50, 50), false, c)
	txt("SCORE " + str(g.score), Vector2(0, 58), 46, Color("#ffe14d"), 1.0, HORIZONTAL_ALIGNMENT_RIGHT, W - 24.0)
	if g.streak >= 2:
		txt("x%d STREAK" % g.streak, Vector2(24, 178), 34, Color("#ffb347"), 1.0, HORIZONTAL_ALIGNMENT_LEFT, W)
	var frac := 1.0 - clampf(float(cur.t) / float(cur.dur), 0.0, 1.0)
	var x0 := 40.0
	var x1 := 600.0
	var sx := x0 + (1.0 - frac) * (x1 - x0)
	draw_line(Vector2(sx, 104), Vector2(x1, 104), Color("#e8b872"), 12.0)
	draw_line(Vector2(x0, 104), Vector2(sx, 104), Color(0.2, 0.12, 0.25, 0.7), 4.0)
	draw_circle(Vector2(sx, 104), 14.0 + randf() * 6.0, Color("#ffec6e"))
	draw_circle(Vector2(sx, 104), 7.0, Color("#ff5a36"))
	var jig := sin(t * 40.0) * (1.0 - frac) * 5.0
	draw_texture_rect(tex["bomb"], Rect2(606, 58 + jig, 92, 92), false)
	var pt: float = g.pt
	if g.state == "play" and pt < 1.0:
		var a := clampf((1.0 - pt) * 2.5, 0.0, 1.0)
		ptxt(str(cur.prompt), 700, 170, 1.0 + maxf(0.0, 0.5 - pt) * 0.8, Color("#fff176"), sin(t * 22.0) * 0.03, a)
		if g.banner != "":
			ptxt(str(g.banner), 470, 96, 1.0, Color("#ff5d8f"), 0.0, a)
	if g.state == "result":
		var rt: float = 1.1 - g.rtimer
		var w: bool = g.won
		draw_rect(Rect2(0, 0, W, H), Color(0.2, 0.9, 0.4, 0.28) if w else Color(1.0, 0.2, 0.3, 0.3))
		var k := minf(1.0, rt * 7.0) + sin(rt * 16.0) * 0.06
		ptxt("WIN!" if w else "OUCH!", 640, 210, k, Color.WHITE, -0.07)
		if g.boss_win:
			ptxt("BOSS DOWN!", 760, 90, k, Color("#ffe14d"))
			txt("+3 SCORE   +1 HEART", Vector2(0, 840), 46)
		elif w and g.streak >= 3:
			ptxt("STREAK x%d" % g.streak, 760, 84, k, Color("#ffe14d"))
		hero_at("hero_happy" if w else "hero_sad", Vector2(360.0, 1000.0 - absf(sin(rt * 9.0)) * (60.0 if w else 0.0)), 280.0, sin(rt * 12.0) * (0.12 if w else 0.05))
