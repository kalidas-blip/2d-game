extends "res://micro.gd"
var m := 0.0
var dir := 1.0
var zc := 0.5
var zw := 0.2
var perfect := false

func setup() -> void:
	bg = Color("#ffbf69")
	prompt = "STOP!"
	dur = 5.0
	zc = randf_range(0.2, 0.8)
	m = randf()

func tick(d: float) -> void:
	m += dir * d * 1.1
	if m > 1.0:
		m = 1.0
		dir = -1.0
	elif m < 0.0:
		m = 0.0
		dir = 1.0

func press(_p: Vector2) -> void:
	Sfx.play("tap")
	var ok := absf(m - zc) < zw / 2.0
	perfect = absf(m - zc) < zw * 0.15
	if ok:
		burst(Vector2(60.0 + m * 600.0, 616.0), Color("#3ddc84"), 18)
		Sfx.buzz(20)
	finish(ok)

func art() -> void:
	var x0 := 60.0
	var wd := 600.0
	draw_rect(Rect2(x0 - 12, 560, wd + 24, 112), Color("#2b193d"))
	draw_rect(Rect2(x0, 575, wd, 82), Color("#fff3d6"))
	draw_rect(Rect2(x0 + (zc - zw / 2.0) * wd, 575, zw * wd, 82), Color("#3ddc84"))
	var mx := x0 + m * wd
	draw_rect(Rect2(mx - 8, 530, 16, 170), Color("#ff3b6b"))
	draw_colored_polygon(PackedVector2Array([Vector2(mx - 28, 496), Vector2(mx + 28, 496), Vector2(mx, 540)]), Color("#ff3b6b"))
	img("hero", Vector2(360, 920), 260.0 + sin(t * 8.0) * 8.0)
	txt("TAP IN THE GREEN!", Vector2(0, 400), 60)
	if over and perfect:
		txt("PERFECT!", Vector2(0, 780), 90, Color("#fff176"))
