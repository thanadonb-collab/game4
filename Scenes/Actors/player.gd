class_name Player
extends CharacterBody2D

signal hit_enemy
signal hit_trap




@export_category("Player Properties")
@export var move_speed: float = 300
@export var jump_force: float = 650
@export var gravity: float = 30
@export var max_jump_count: int = 2
@export var bullet_scene: PackedScene
@export var shoot_cooldown_time: float = 0.2
@export var bullet_lifetime = 2.0

var jump_count: int = 2

@export_category("Toggle Functions")
@export var double_jump: = false

var is_grounded: bool = false
var movement_enabled: bool = true
var spawn_point = Vector2(0, 0)
var is_attacking = false
var shoot_cooldown_timer = 0.0
var can_damage = true
var base_move_speed: float = 0.0
var base_jump_force: float = 0.0
var boost_timers: Dictionary = {}

@onready var player_sprite: AnimationPlayer = $Pirate/AnimationPlayer
@onready var player_node = $Pirate
@onready var bullet_marker = $BulletMarker
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles




func _ready() -> void:
	spawn_point = global_position
	base_move_speed = move_speed
	base_jump_force = jump_force
	if GameManager.save_player_position.x != 0:
		global_position = GameManager.save_player_position
		GameManager.save_player_position = Vector2.ZERO
	player_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	is_grounded = is_on_floor()
	movement()
	# still touching a trap when the invincibility ends -> take another hit
	if can_damage and movement_enabled:
		for b in $Collision.get_overlapping_bodies():
			if b.is_in_group("Traps"):
				hurt_by_trap(b)
				break

func _process(_delta):
	player_animations()
	flip_player()
	handle_shooting()
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= _delta




func movement():

	if !is_on_floor():
		velocity.y += gravity
	elif is_on_floor():
		jump_count = max_jump_count
		velocity.x = 0

	handle_jumping()


	if movement_enabled:
		if Input.is_action_pressed("Left"):
			velocity.x = -move_speed
		if Input.is_action_pressed("Right"):
			velocity.x = move_speed
	move_and_slide()


func handle_jumping():
	if Input.is_action_just_pressed("Jump") and movement_enabled:
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1


func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force


func player_animations():
	particle_trails.emitting = false
	if is_attacking:
		return

	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.current_animation = "Walk"
		else:
			player_sprite.current_animation = "Idle"
	else:
		player_sprite.current_animation = "Jump"



func flip_player():
	if velocity.x < 0:
		player_node.scale.x = -1
	elif velocity.x > 0:
		player_node.scale.x = 1


func death_tween():
	AudioManager.death_sfx.play()
	death_particles.emitting = true
	movement_enabled = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.parallel().tween_property(self, "position", Vector2(position.x, position.y - 100), 0.15)
	await tween.finished
	global_position = spawn_point
	await get_tree().create_timer(0.3).timeout
	movement_enabled = true
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(self, "position", spawn_point, 0.15)

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func damage_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	can_damage = false
	for i in range(1, 10):
		tween.tween_property(player_node, "modulate", Color.RED, 0.1)
		tween.tween_property(player_node, "modulate", Color.WHITE, 0.1)
	await tween.finished
	can_damage = true



func _on_collision_body_entered(body):
	if body.is_in_group("Traps"):
		hurt_by_trap(body)
		return
	if !can_damage: return
	if body.is_in_group("Enemy"):
		var dx = body.position.x - position.x
		velocity.y = -400
		if dx > 0:
			velocity.x = -300
		else:
			velocity.x = 300
		AudioManager.play_sfx("hurt")
		damage_tween()
		hit_enemy.emit()

func handle_shooting():
	if Input.is_action_just_pressed("Shoot") and movement_enabled and shoot_cooldown_timer <= 0:
		shoot()

func shoot():
	if bullet_scene == null:
		return
	is_attacking = true
	player_sprite.play("Attack")
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_marker.global_position
	var angle = deg_to_rad(randf_range(0, 20))
	var sign_x = 1.0 if player_node.scale.x > 0 else -1.0
	var dir = Vector2(cos(angle) * sign_x, -sin(angle))
	get_parent().add_child(bullet)
	bullet.shoot(dir, 600, bullet_lifetime)
	AudioManager.play_sfx("shoot")
	shoot_cooldown_timer = shoot_cooldown_time

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Attack":
		is_attacking = false


# ---------- Sunken City additions ----------

## Called by the giant clam: throws the player upward.
func launch(speed: float) -> void:
	velocity.y = -speed
	jump_count = max_jump_count
	jump_tween()

## Temporary power-up. kind: "speed" or "jump".
func apply_boost(kind: String, multiplier: float, duration: float) -> void:
	if kind == "speed":
		move_speed = base_move_speed * multiplier
		particle_trails.modulate = Color(0.5, 0.8, 1.0)
	elif kind == "jump":
		jump_force = base_jump_force * multiplier
	player_node.modulate = Color(0.75, 1.0, 1.0) if kind == "speed" else Color(0.8, 1.0, 0.8)
	var token = randi()
	boost_timers[kind] = token
	await get_tree().create_timer(duration).timeout
	if boost_timers.get(kind) != token:
		return
	boost_timers.erase(kind)
	if kind == "speed":
		move_speed = base_move_speed
		particle_trails.modulate = Color.WHITE
	else:
		jump_force = base_jump_force
	if boost_timers.is_empty():
		player_node.modulate = Color.WHITE

## Traps cost HP (see base_level.trap_damage) instead of killing instantly.
## Short knockback, then ~1.8 s of invincibility while the pirate flashes red.
func hurt_by_trap(body) -> void:
	if !can_damage or !movement_enabled:
		return
	var away = sign(global_position.x - body.global_position.x)
	if away == 0:
		away = -1.0 if player_node.scale.x > 0 else 1.0
	velocity = Vector2(140.0 * away, -330.0)
	AudioManager.play_sfx("hurt")
	if body.has_method("trigger"):
		body.trigger()   # sea mines explode only when they actually hit
	damage_tween()
	hit_trap.emit()
