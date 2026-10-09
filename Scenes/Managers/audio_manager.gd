extends Node

@onready var jump_sfx = $JumpSfx
@onready var coin_pickup_sfx = $CoinPickup
@onready var death_sfx = $DeathSfx
@onready var respawn_sfx = $RespawnSfx
@onready var level_complete_sfx = $LevelCompleteSfx

## Play a named one-shot effect: shoot, powerup, hurt, explosion, boing, portal, checkpoint.
func play_sfx(sfx_name: String) -> void:
	var node := get_node_or_null(sfx_name.capitalize() + "Sfx")
	if node:
		node.play()
