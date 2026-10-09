extends AnimatableBody2D
## Driftwood raft that travels between its start and start+travel (use a vertical travel for an elevator).

@export var travel: Vector2 = Vector2(192, 0)
@export var speed: float = 80.0
@export var wait_time: float = 0.6

var _origin: Vector2
var _dir := 1.0
var _k := 0.0
var _wait := 0.0

func _ready() -> void:
	_origin = position

func _physics_process(delta: float) -> void:
	if _wait > 0.0:
		_wait -= delta
		return
	var length := travel.length()
	if length <= 0.0:
		return
	_k += _dir * speed * delta / length
	if _k >= 1.0 or _k <= 0.0:
		_k = clamp(_k, 0.0, 1.0)
		_dir = -_dir
		_wait = wait_time
	position = _origin + travel * _k
