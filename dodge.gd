extends "res://micro.gd"
var px := 360.0
var ppx := 360.0
var tilt := 0.0
var rocks: Array = []
var sp := 0.5

func setup() -> void:
	bg = Color("#b5e48c")
	prompt = "DODGE!"
	dur = 5.0

func press(p: Vector2) -> void:
	px = clampf(p.x, 70.0, 650.0)

func drag(p: Vector2) -> void:
	px = clampf(p.x, 70.0, 650.0)

func timeout() -> void:
	finish(true)

func tick(d: float) -> void:
	tilt = lerpf(tilt, clampf((px - ppx) * 0.02, -0.4, 0.4), 0.3)
	ppx = px
	sp -= d
	if sp <= 0.0:
		sp = 0.4
		var x := randf_range(60.0, 660.0)
		if randf() < 0.5:
			x = clampf(px + randf_range(-130.0, 130.0), 60.0, 660.0)
		rocks.append({"x": x, "y": -80.0, "r": randf() * TAU})
	for r in rocks:
		r.y += 760.0 * d
		r.r += d * 3.0
		if absf(r.x - px) < 66.0 and absf(r.y - 1090.0) < 68.0:
			burst(Vector2(px, 1090.0), Color("#ffb703"), 26, 620.0)
			Sfx.play("hit")
			Sfx.buzz(90)
			finish(false)
			return
	rocks = rocks.filter(func(r): return r.y < H + 100.0)

func art() -> void:
	cloud(Vector2(fposmod(300.0 + age * 20.0, 900.0) - 100.0, 340.0), 1.2)
	draw_rect(Rect2(0, 1160, W, 120), Color("#6a994e"))
	draw_rect(Rect2(0, 1160, W, 16), Color("#52b788"))
	for r in rocks:
		img("rock", Vector2(r.x, r.y), 120.0, r.r)
	img("hero", Vector2(px, 1090), 150.0, tilt + sin(t * 10.0) * 0.06)
	txt("SURVIVE!", Vector2(0, 280), 90)
