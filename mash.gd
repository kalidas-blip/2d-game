extends "res://micro.gd"
var m := 0.0
var pulse := 0.0

func setup() -> void:
	bg = Color("#ff9770")
	prompt = "MASH!"
	dur = 5.0

func press(_p: Vector2) -> void:
	m += 0.1
	pulse = 1.0
	Sfx.play("tap", 0.8 + m * 0.9)
	Sfx.buzz(10)
	if m >= 1.0:
		m = 1.0
		for c in ["#ffe14d", "#ff6ba6", "#7bf1a8", "#6ec6ff"]:
			burst(Vector2(360, 760), Color(c), 10, 700.0)
		finish(true)

func tick(d: float) -> void:
	m = maxf(0.0, m - 0.28 * d)
	pulse = maxf(0.0, pulse - d * 6.0)

func art() -> void:
	var sh := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * m * 14.0
	img("hero", Vector2(360, 760) + sh, 300.0 + m * 240.0 + pulse * 40.0, sin(t * 30.0) * m * 0.15)
	draw_rect(Rect2(60, 1080, 600, 70), Color("#2b193d"))
	draw_rect(Rect2(70, 1090, 580.0 * m, 50), Color("#ffe14d"))
	txt("TAP! TAP! TAP!", Vector2(0, 330), 90 + int(pulse * 14.0))
