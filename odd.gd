extends "res://micro.gd"
var items: Array = []
var odd := 0
var col := Color.WHITE
var ocol := Color.WHITE

func setup() -> void:
	bg = Color("#9bf6ff")
	prompt = "SPOT!"
	dur = 5.0
	var h := randf()
	var dh := clampf(0.14 - (spd - 1.0) * 0.05, 0.06, 0.14)
	col = Color.from_hsv(h, 0.65, 0.95)
	ocol = Color.from_hsv(fmod(h + dh, 1.0), 0.65, 0.95)
	odd = randi() % 20
	for i in 20:
		items.append(Vector2(120.0 + (i % 4) * 160.0, 360.0 + floorf(i / 4.0) * 170.0))

func press(p: Vector2) -> void:
	for i in 20:
		var c: Vector2 = items[i]
		if c.distance_to(p) < 78.0:
			Sfx.play("tap")
			if i == odd:
				burst(c, ocol, 20, 520.0)
				Sfx.buzz(20)
			finish(i == odd)
			return

func art() -> void:
	var ink := Color(0.17, 0.1, 0.24)
	for i in 20:
		var c: Vector2 = items[i] + Vector2(0, sin(t * 4.0 + i) * 6.0)
		draw_circle(c, 66.0, ink)
		draw_circle(c, 58.0, ocol if i == odd else col)
		draw_circle(c + Vector2(-20, -10), 15.0, Color.WHITE)
		draw_circle(c + Vector2(20, -10), 15.0, Color.WHITE)
		draw_circle(c + Vector2(-18, -8), 7.0, ink)
		draw_circle(c + Vector2(22, -8), 7.0, ink)
		draw_arc(c + Vector2(0, 8), 22.0, 0.4, PI - 0.4, 12, ink, 6.0)
	if over:
		draw_arc(items[odd], 80.0, 0.0, TAU, 32, Color.WHITE, 10.0)
	txt("FIND THE ODD ONE!", Vector2(0, 260), 64)
