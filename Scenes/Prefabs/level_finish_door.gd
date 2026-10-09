extends Area2D
## Treasure chest at the end of each level. Opens and sends the pirate to the next scene.

@export var next_scene: PackedScene
var _used := false

func _on_body_entered(body):
	if _used or not body.is_in_group("Player") or next_scene == null:
		return
	_used = true
	$Sprite2D.frame = 1
	AudioManager.level_complete_sfx.play()
	body.movement_enabled = false
	await get_tree().create_timer(0.8).timeout
	SceneTransition.load_scene(next_scene)
