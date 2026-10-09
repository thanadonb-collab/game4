extends AnimatableBody2D
## Trap that drifts back and forth along a line (sea mines, jellyfish).
## Touching it kills the player (group "Traps").

@export var travel: Vector2 = Vector2(0, -48)
@export var period: float = 2.4
@export var phase: float = 0.0
@export var explodes: bool = false

var _origin: Vector2
var _t: float = 0.0

func _ready() -> void:
	_origin = position
	_t = phase * period
	if has_node("Anim"):
		$Anim.play()

func _physics_process(delta: float) -> void:
	_t += delta
	var k := (1.0 - cos(_t / period * TAU)) * 0.5
	position = _origin + travel * k

func trigger() -> void:
	if not explodes:
		return
	AudioManager.play_sfx("explosion")
	if has_node("Boom"):
		$Boom.emitting = true
	$Anim.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(3.0).timeout
	$Anim.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
