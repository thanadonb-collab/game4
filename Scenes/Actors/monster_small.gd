extends Enemy

@onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer

func _ready() -> void:
	super._ready()


	var types = Array(anim_player.get_animation_list())

	if types.size() > 0:
		anim_player.play(types.pick_random())
