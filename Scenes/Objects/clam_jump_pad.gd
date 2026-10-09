extends StaticBody2D
## Giant clam: launches the player high into the air when stepped on.

@export var launch_speed: float = 1050.0

func _on_trigger_body_entered(body) -> void:
	if body.is_in_group("Player") and body.has_method("launch"):
		body.launch(launch_speed)
		AudioManager.play_sfx("boing")
		$Sprite.frame = 1
		await get_tree().create_timer(0.35).timeout
		$Sprite.frame = 0
