extends Area2D
## Pirate flag checkpoint: the player respawns here after losing a life.

var reached := false

func _on_body_entered(body) -> void:
	if reached or not body.is_in_group("Player"):
		return
	reached = true
	body.spawn_point = global_position + Vector2(0, -4)
	AudioManager.play_sfx("checkpoint")
	$Anim.play("raise")
	var ui = get_tree().get_first_node_in_group("GameUI")
	if ui:
		ui.alert("Checkpoint!")
