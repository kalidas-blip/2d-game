extends "res://micro.gd"
var holes: Array = []
var cur := -1
var up := 0.0
var wait := 0.4
var hits := 0

func setup() -> void:
	bg = Color("#a7c957")
	prompt = "WHACK!"
	dur = 6.0
	for r in 3:
		for c in 3:
			holes.append(Vector2(160.0 + c * 200.0, 520.0 + r * 230.0))

func tick(d: float) -> void:
	if cur == -1:
		wait -= d
		if wait <= 0.0:
			cur = randi() % 9
			up = 1.1
	else:
		up -= d
		if up <= 0.0:
			cur = -1
			wait = 0.2

func press(p: Vector2) -> void:
	if cur == -1:
		return
	var hp: Vector2 = holes[cur]
	if hp.distance_to(p + Vector2(0, 40)) < 105.0:
		burst(hp + Vector2(0, -60), Color("#ffe14d"), 14)
		hits += 1
		cur = -1
		wait = 0.25
		Sfx.play("pop", 1.0 + hits * 0.15)
		Sfx.buzz(25)
		if hits >= 3:
			finish(true)

func art() -> void:
	for i in 9:
		img("hole", holes[i], 200.0)
	if cur != -1:
		var k := clampf((1.1 - up) * 7.0, 0.0, 1.0)
		img("mole", holes[cur] + Vector2(0, -60.0 * k), 200.0 * k)
	txt("%d / 3" % hits, Vector2(0, 280), 90)
