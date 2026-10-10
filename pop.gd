extends "res://micro.gd"
var balls: Array = []

func setup() -> void:
	bg = Color("#ffafcc")
	prompt = "POP!"
	dur = 5.0
	for i in 6:
		balls.append({"p": Vector2(randf_range(110.0, 610.0), randf_range(350.0, 1100.0)), "v": Vector2(randf_range(-70.0, 70.0), randf_range(-160.0, -80.0)), "c": Color.from_hsv(randf(), 0.55, 1.0)})

func press(p: Vector2) -> void:
	for i in range(balls.size() - 1, -1, -1):
		var b = balls[i]
		if (b.p + Vector2(0, -14)).distance_to(p) < 105.0:
			burst(b.p, b.c, 16, 460.0)
			balls.remove_at(i)
			Sfx.play("pop", randf_range(0.9, 1.3))
			Sfx.buzz(15)
			if balls.is_empty():
				finish(true)
			return

func tick(d: float) -> void:
	for b in balls:
		b.p += b.v * d
		if b.p.x < 100.0 or b.p.x > 620.0:
			b.v = Vector2(-b.v.x, b.v.y)
			b.p = Vector2(clampf(b.p.x, 100.0, 620.0), b.p.y)
		if b.p.y < -120.0:
			b.p = Vector2(b.p.x, H + 120.0)

func art() -> void:
	for b in balls:
		var w: float = 190.0 + sin(t * 3.0 + b.p.x) * 6.0
		img("balloon", b.p, w, sin(t * 2.0 + b.p.y * 0.01) * 0.12, b.c)
	txt("%d left" % balls.size(), Vector2(0, 280), 80)
