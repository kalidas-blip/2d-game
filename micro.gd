extends Node2D
# Base class for every micro-game. Games override setup/tick/art/press/drag/timeout.
signal done(win: bool)
const W := 720.0
const H := 1280.0
var t := 0.0
var age := 0.0
var spd := 1.0
var dur := 5.0
var over := false
var bg := Color("#ffd23f")
var prompt := "GO!"
var tex := {}
var parts: Array = []

func _ready() -> void:
	for n in ["hero", "apple", "bomb", "balloon", "rock", "mole", "hole", "basket", "boss"]:
		tex[n] = load("res://%s.png" % n)
	setup()

func setup() -> void:
	pass

func tick(_d: float) -> void:
	pass

func art() -> void:
	pass

func press(_p: Vector2) -> void:
	pass

func drag(_p: Vector2) -> void:
	pass

func timeout() -> void:
	finish(false)

func finish(w: bool) -> void:
	if over:
		return
	over = true
	done.emit(w)

func burst(p: Vector2, col: Color, n: int = 12, power: float = 420.0) -> void:
	for i in n:
		var v := Vector2.from_angle(randf() * TAU) * randf_range(0.3, 1.0) * power
		parts.append({"p": p, "v": v + Vector2(0.0, -120.0), "life": 1.0, "col": col, "r": randf_range(6.0, 14.0)})

func _process(delta: float) -> void:
	age += delta
	if not over:
		var d := delta * spd
		t += d
		tick(d)
		if t >= dur:
			timeout()
	for q in parts:
		q.p += q.v * delta
		q.v = Vector2(q.v.x * 0.97, q.v.y + 1100.0 * delta)
		q.life -= delta * 1.5
	parts = parts.filter(func(q): return q.life > 0.0)
	queue_redraw()

func _input(e: InputEvent) -> void:
	if over or age < 0.12:
		return
	if e is InputEventMouseButton:
		var b := e as InputEventMouseButton
		if b.pressed and b.button_index == MOUSE_BUTTON_LEFT:
			press(b.position)
	elif e is InputEventMouseMotion:
		drag((e as InputEventMouseMotion).position)

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), bg)
	var c := Vector2(W / 2.0, H / 2.0)
	var ray := bg.lightened(0.14)
	for i in 8:
		var a := age * 0.3 + i * TAU / 8.0
		draw_colored_polygon(PackedVector2Array([c, c + Vector2.from_angle(a) * 1500.0, c + Vector2.from_angle(a + TAU / 16.0) * 1500.0]), ray)
	var dot := bg.darkened(0.08)
	for y in 14:
		for x in 8:
			var o := 45.0 if y % 2 == 0 else 0.0
			draw_circle(Vector2(x * 100.0 + o, y * 100.0), 7.0 + 5.0 * sin(age * 2.0 + x * 0.7 + y * 0.5), dot)
	art()
	for q in parts:
		var pc: Color = q.col
		pc.a = clampf(q.life * 1.5, 0.0, 1.0)
		draw_circle(q.p, q.r * (0.4 + q.life * 0.6), pc)

func cloud(p: Vector2, s: float) -> void:
	var c := Color(1, 1, 1, 0.85)
	draw_circle(p, 40.0 * s, c)
	draw_circle(p + Vector2(48.0, 10.0) * s, 32.0 * s, c)
	draw_circle(p + Vector2(-48.0, 12.0) * s, 30.0 * s, c)
	draw_rect(Rect2(p.x - 48.0 * s, p.y + 12.0 * s, 96.0 * s, 30.0 * s), c)

func img(n: String, c: Vector2, sz: float, rot := 0.0, mod := Color.WHITE) -> void:
	draw_set_transform(c, rot, Vector2.ONE)
	draw_texture_rect(tex[n], Rect2(-sz / 2.0, -sz / 2.0, sz, sz), false, mod)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func txt(s: String, p: Vector2, size: int, col := Color.WHITE) -> void:
	var f: Font = Sfx.font
	draw_string_outline(f, p, s, HORIZONTAL_ALIGNMENT_CENTER, W, size, 14, Color(0.17, 0.1, 0.24))
	draw_string(f, p, s, HORIZONTAL_ALIGNMENT_CENTER, W, size, col)
