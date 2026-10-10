extends "res://micro.gd"
var bx := 360.0
var fruits: Array = []
var got := 0

func setup() -> void:
	bg = Color("#7bdff2")
	prompt = "CATCH!"
	dur = 6.0
	for i in 5:
		fruits.append({"x": randf_range(90.0, 630.0), "y": -80.0 - i * 280.0, "bomb": i % 3 == 2})

func press(p: Vector2) -> void:
	bx = clampf(p.x, 90.0, 630.0)

func drag(p: Vector2) -> void:
	bx = clampf(p.x, 90.0, 630.0)

func tick(d: float) -> void:
	for f in fruits:
		f.y += 560.0 * d
		if f.y > H + 60.0:
			f.y = -80.0
			f.x = randf_range(90.0, 630.0)
		elif f.y > 1010.0 and f.y < 1110.0 and absf(f.x - bx) < 95.0:
			var hit := Vector2(f.x, 1040.0)
			f.y = -500.0
			f.x = randf_range(90.0, 630.0)
			if f.bomb:
				burst(hit, Color("#ffb703"), 28, 640.0)
				Sfx.play("hit")
				Sfx.buzz(90)
				finish(false)
				return
			got += 1
			burst(hit, Color("#ff5d5d"), 12)
			Sfx.play("pop", 1.0 + got * 0.2)
			Sfx.buzz(15)
			if got >= 3:
				finish(true)
				return

func art() -> void:
	cloud(Vector2(fposmod(100.0 + age * 25.0, 900.0) - 100.0, 330.0), 1.4)
	cloud(Vector2(fposmod(500.0 + age * 15.0, 900.0) - 100.0, 520.0), 0.9)
	draw_rect(Rect2(0, 1130, W, 150), Color("#3a7d44"))
	draw_rect(Rect2(0, 1130, W, 18), Color("#52b788"))
	for f in fruits:
		img("bomb" if f.bomb else "apple", Vector2(f.x, f.y), 120.0, sin(t * 6.0 + f.x) * 0.25)
	img("basket", Vector2(bx, 1085), 200.0)
	txt("%d / 3" % got, Vector2(0, 280), 90)
