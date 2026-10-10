extends "res://micro.gd"
const GY := 900.0
var hy := 0.0
var vy := 0.0
var gx := 0.0
var obs: Array = []

func setup() -> void:
	bg = Color("#a0e7e5")
	prompt = "JUMP!"
	dur = 5.0
	var x := 900.0
	for i in 3:
		obs.append({"x": x, "bomb": randf() < 0.4})
		x += randf_range(520.0, 680.0)

func press(_p: Vector2) -> void:
	if hy <= 0.0 and vy <= 0.0:
		vy = 1100.0
		Sfx.play("jump")

func tick(d: float) -> void:
	gx += 520.0 * d
	if hy > 0.0 or vy > 0.0:
		vy -= 3000.0 * d
		hy += vy * d
		if hy <= 0.0:
			hy = 0.0
			vy = 0.0
			burst(Vector2(180.0, GY), Color("#d8f3dc"), 6, 200.0)
	for o in obs:
		o.x -= 520.0 * d
		if absf(o.x - 180.0) < 64.0 and hy < 85.0:
			burst(Vector2(180.0, GY - 60.0), Color("#ffb703"), 26, 620.0)
			Sfx.play("hit")
			Sfx.buzz(90)
			finish(false)
			return
	if obs[obs.size() - 1].x < 40.0:
		finish(true)

func art() -> void:
	cloud(Vector2(fposmod(120.0 - gx * 0.15, 900.0) - 100.0, 320.0), 1.3)
	cloud(Vector2(fposmod(560.0 - gx * 0.1, 900.0) - 100.0, 470.0), 0.9)
	draw_rect(Rect2(0, GY, W, H - GY), Color("#6a994e"))
	draw_rect(Rect2(0, GY, W, 22), Color("#52b788"))
	for i in 9:
		draw_rect(Rect2(fposmod(i * 110.0 - gx, 990.0) - 100.0, GY + 70.0, 60, 12), Color("#4a7c3a"))
	for o in obs:
		img("bomb" if o.bomb else "rock", Vector2(o.x, GY - 55.0), 110.0)
	var run := absf(sin(gx * 0.03)) * 10.0 if hy <= 0.0 else 0.0
	img("hero", Vector2(180.0, GY - 75.0 - hy - run), 150.0, clampf(-vy * 0.0004, -0.4, 0.4) + sin(gx * 0.03) * 0.05)
	txt("TAP TO JUMP!", Vector2(0, 300), 80)
