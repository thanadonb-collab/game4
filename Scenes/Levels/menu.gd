extends Node2D

@onready var btn_continue: Button = $UI/btnContinue

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	$UI.size = get_viewport_rect().size
	btn_continue.disabled = !GameManager.has_gamesaved()
	GameManager.load_option()

	pass


func _process(delta: float) -> void:
	pass


func _on_btn_start_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	GameManager.restart()


func _on_btn_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/options.tscn")


func _on_btn_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/credit.tscn")


func _on_btn_continue_pressed() -> void:
	GameManager.load_game()


func _on_btn_exit_pressed() -> void:
	get_tree().quit()
