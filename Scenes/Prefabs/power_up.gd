extends Area2D
## Collectable power-up. kind: "speed" (swift rum), "jump" (air bubble) or "life" (heart).

@export_enum("speed", "jump", "life") var kind: String = "speed"
@export var duration: float = 8.0
@export var respawn_time: float = 5.0

var _t := 0.0
var _y0 := 0.0

func _ready() -> void:
	_y0 = position.y
	_t = randf() * TAU

func _process(delta: float) -> void:
	_t += delta
	position.y = _y0 + sin(_t * 3.0) * 4.0

func _on_body_entered(body) -> void:
	if not body.is_in_group("Player"):
		return
	var ui = get_tree().get_first_node_in_group("GameUI")
	match kind:
		"speed":
			body.apply_boost("speed", 1.6, duration)
			if ui: ui.alert("Swift Rum! Speed up")
		"jump":
			body.apply_boost("jump", 1.35, duration)
			if ui: ui.alert("Air Bubble! Jump higher")
		"life":
			GameManager.add_life()
			if ui: ui.alert("Extra life!")
	AudioManager.play_sfx("powerup")
	set_deferred("monitoring", false)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.25)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.25)
	await tween.finished
	if kind == "life":
		queue_free()
		return
	# speed/jump items come back so a level can never become impossible after a death
	await get_tree().create_timer(respawn_time).timeout
	scale = Vector2.ONE
	modulate.a = 1.0
	monitoring = true
