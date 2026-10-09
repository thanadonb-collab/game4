extends Node2D
## Anchor swinging on a chain like a pendulum. The anchor body is in group "Traps".

@export var chain_length: float = 160.0
@export var max_angle_deg: float = 55.0
@export var period: float = 2.6
@export var phase: float = 0.0

var _t: float = 0.0

func _ready() -> void:
	_t = phase * period
	$Pivot/Chain.size.y = chain_length
	$Pivot/Anchor.position.y = chain_length + 22.0

func _physics_process(delta: float) -> void:
	_t += delta
	$Pivot.rotation = deg_to_rad(max_angle_deg) * sin(_t / period * TAU)
