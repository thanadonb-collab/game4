extends Node2D
## Shared level logic: music, title card, camera limits, fall-death and the parallax background.

@export var level_title: String = "Level"
@export var background_texture: Texture2D
@export var level_width: float = 4000.0
@export var level_height: float = 704.0
@export var music: AudioStream
## HP lost when a trap hits the pirate (falling into a pit still costs a life).
@export var trap_damage: int = 20

func _ready() -> void:
	GameManager.player = %Player
	if background_texture:
		$Level/Background1/BG.texture = background_texture
	if music:
		$MusicPlayer.stream = music
	$MusicPlayer.play(0)
	var cam: Camera2D = %Player.get_node("Camera2D")
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(level_width)
	cam.limit_bottom = int(level_height)
	var label: Label = $UserInterface/Label
	label.text = level_title
	label.pivot_offset = label.size / 2
	var tween = create_tween()
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE, 1)
	await get_tree().create_timer(3).timeout
	label.queue_free()

func _physics_process(_delta: float) -> void:
	var p = %Player
	if p.movement_enabled and p.global_position.y > level_height + 64:
		GameManager.death()

func _on_player_hit_enemy() -> void:
	GameManager.damage(5)

func _on_player_hit_trap() -> void:
	GameManager.damage(trap_damage)

func _on_music_player_finished() -> void:
	$MusicPlayer.play(0)
