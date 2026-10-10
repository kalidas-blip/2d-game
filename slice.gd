extends "res://micro.gd"
var fr: Array = []
var trail: Array = []
var last := Vector2(-1, -1)
var left := 4

func setup() -> void:
	bg = Color("#ffd6a5")
	prompt = "SLICE!"
	dur = 6.0
	for i in 5:
		fr.append({"p": Vector2(randf_range(130.0, 590.0), randf_range(480.0, 1050.0)), "v": Vector2.from_angle(randf() * TAU) * randf_range(140.0, 230.0), "bomb": i == 4, "dead": false})

func press(p: Vector2) -> void:
	last = p
	cut(p, p)

func drag(p: Vector2) -> void:
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		last = Vector2(-1, -1)
		return
	if last.x >= 0.0:
		cut(last, p)
	last = p
	trail.append({"p": p, "t": 0.0})

func cut(a: Vector2, b: Vector2) -> void:
	for f in fr:
		if f.dead:
			continue
		var c: Vector2 = Geometry2D.get_closest_point_to_segment(f.p, a, b)
		if c.distance_to(f.p) < 64.0:
			f.dead = true
			Sfx.play("slice", randf_range(0.9, 1.2))
			if f.bomb:
				burst(f.p, Color("#ffb703"), 28, 640.0)
				Sfx.buzz(90)
				finish(false)
				return
			burst(f.p, Color("#ff5d5d"), 16, 480.0)
			Sfx.buzz(20)
			left -= 1
			if left <= 0:
				finish(true)
				return

func tick(d: float) -> void:
	for f in fr:
		f.p += f.v * d
		if f.p.x < 100.0 or f.p.x > 620.0:
			f.v = Vector2(-f.v.x, f.v.y)
			f.p = Vector2(clampf(f.p.x, 100.0, 620.0), f.p.y)
		if f.p.y < 420.0 or f.p.y > 1100.0:
			f.v = Vector2(f.v.x, -f.v.y)
			f.p = Vector2(f.p.x, clampf(f.p.y, 420.0, 1100.0))
	for q in trail:
		q.t += d * 3.0
	trail = trail.filter(func(q): return q.t < 1.0)

func art() -> void:
	for f in fr:
		if not f.dead:
			img("bomb" if f.bomb else "apple", f.p, 130.0, sin(t * 4.0 + f.p.x * 0.01) * 0.2)
	for q in trail:
		draw_circle(q.p, 16.0 * (1.0 - q.t), Color(1, 1, 1, 1.0 - q.t))
	txt("SWIPE THE APPLES!", Vector2(0, 280), 64)
