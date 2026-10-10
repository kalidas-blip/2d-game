extends "res://micro.gd"
var hp := 12
var bx := 360.0
var flash := 0.0

func setup() -> void:
	bg = Color("#3a0ca3")
	prompt = "BOSS!"
	dur = 7.0

func tick(d: float) -> void:
	bx = 360.0 + sin(t * 2.2) * 170.0
	flash = maxf(0.0, flash - d * 5.0)

func press(p: Vector2) -> void:
	if p.distance_to(Vector2(bx, 700.0)) < 190.0:
		hp -= 1
		flash = 1.0
		Sfx.play("hit", 1.0 + (12 - hp) * 0.04)
		Sfx.buzz(20)
		burst(p, Color("#ffe14d"), 10, 380.0)
		if hp <= 0:
			for c in ["#ffe14d", "#ff6ba6", "#7bf1a8"]:
				burst(Vector2(bx, 700.0), Color(c), 14, 760.0)
			finish(true)

func art() -> void:
	var tint := Color(1.0, 1.0 - flash * 0.6, 1.0 - flash * 0.6)
	img("boss", Vector2(bx, 700.0 + sin(t * 5.0) * 10.0), 420.0 + flash * 24.0, sin(t * 3.0) * 0.06, tint)
	draw_rect(Rect2(60, 1090, 600, 56), Color(0.17, 0.1, 0.24))
	draw_rect(Rect2(68, 1098, 584.0 * hp / 12.0, 40), Color("#ff4d6d"))
	txt("HIT THE BOSS!", Vector2(0, 340), 72)
