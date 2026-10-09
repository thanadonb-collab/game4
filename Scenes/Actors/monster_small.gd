extends Enemy

@onready var anim_player: AnimationPlayer = $Sprite/AnimationPlayer

func _ready() -> void:
	super._ready()
	# pick a real animation; "RESET" is a single static frame and made enemies look frozen
	var types = Array(anim_player.get_animation_list()).filter(func(a): return a != "RESET")
	if types.size() > 0:
		anim_player.play(types.pick_random())
