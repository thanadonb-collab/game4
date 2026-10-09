extends Area2D
## Whirlpool portal. Sends the player to the node at `target` (another portal or a Marker2D).

@export var target: NodePath
var _cooldown := false

func _ready() -> void:
	$Anim.play()

func _on_body_entered(body) -> void:
	if _cooldown or not body.is_in_group("Player"):
		return
	var dest = get_node_or_null(target)
	if dest == null:
		return
	if dest.has_method("block_for"):
		dest.block_for(1.0)
	AudioManager.play_sfx("portal")
	body.global_position = dest.global_position + Vector2(0, -12)
	body.velocity = Vector2.ZERO

func block_for(seconds: float) -> void:
	_cooldown = true
	await get_tree().create_timer(seconds).timeout
	_cooldown = false
