extends CharacterBody2D

@export var walk_speed: float = 20.0
@export var run_speed: float = 100.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 980.0

@export var chase_distance: float = 300.0     # start running
@export var attack_range: float = 40.0        # stop and attack
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0

@onready var fall_ray: RayCast2D = $FallDetector
@onready var wall_ray: RayCast2D = $WallDetector
@onready var ground_ray: RayCast2D = $GroundDetector
@onready var attack_area: Area2D = $AttackArea
var direction: float

var player: Node2D = null
var can_attack: bool = true
var is_attacking: bool = false

func _ready() -> void:
	floor_max_angle = deg_to_rad(60.0)
	floor_snap_length = 8.0
	player = $"../CharacterBody2D"
	$AttackArea/AnimatedSprite2D.visible = false
	$AttackArea/CollisionShape2D.shape.set_size(Vector2(45, 45))
	$AttackArea/CollisionShape2D.position = Vector2(-1.5,-9.5)
	$AttackArea.body_entered.connect(_on_body_entered)
	# Prevent the enemy from trying to reach a spot exactly on top of the player

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	if player == null:
		velocity.x = 0
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	# --- Attack ---
	if distance_to_player <= attack_range and can_attack:
		_start_attack()
		velocity.x = 0
		move_and_slide()
		return

	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return

	# --- Chase ---
	direction = sign(player.global_position.x - global_position.x)
	# Face direction (flip sprite)
	var flip = direction > 0
	if direction != 0:
		$AnimatedSprite2D.flip_h = flip
	if is_attacking:
		$AttackArea/CollisionShape2D.position.y = 0
		if flip:
			$AttackArea/AnimatedSprite2D.position.x = 38
		else:
			$AttackArea/AnimatedSprite2D.position.x = -38
		

	# --- Fall detection ---
	# Position the fall ray at the leading edge of the enemy
	fall_ray.position.x = abs(fall_ray.position.x) * direction
	fall_ray.force_raycast_update()

	var fall_ahead := not fall_ray.is_colliding() and is_on_floor()

	# --- Wall detection ---
	wall_ray.target_position.x = abs(wall_ray.target_position.x) * direction
	wall_ray.force_raycast_update()
	var wall_ahead := wall_ray.is_colliding()

	# --- Choose speed ---
	var speed := walk_speed
	if distance_to_player < chase_distance:
		speed = run_speed

	# --- Decide movement ---
	if fall_ahead:
		# Stop at the edge. Optionally jump if the gap is small.
		velocity.x = 0
	else:
		velocity.x = direction * speed

		# Jump if a wall blocks us (or the player is above us)
		if wall_ahead and is_on_floor():
			velocity.y = jump_velocity
			velocity.x = direction*run_speed

	move_and_slide()

func _start_attack() -> void:
	can_attack = false
	is_attacking = true
	$AttackArea/AnimatedSprite2D.visible = true
	# Play your attack animation here
	# $AnimatedSprite2D.play("attack")
	$AttackArea/CollisionShape2D.shape.set_size(Vector2(90, 64))
	if direction == -1:
		$AttackArea/CollisionShape2D.position = Vector2(-13,0)
		$AttackArea/AnimatedSprite2D.position.x = -38
	else:
		$AttackArea/CollisionShape2D.position = Vector2(13,0)
		$AttackArea/AnimatedSprite2D.position.x = 38
	#_deal_damage()
	await get_tree().create_timer(0.3).timeout  # wind-up / hit window
	#_deal_damage()
	is_attacking = false
	$AttackArea/AnimatedSprite2D.visible = false
	$AttackArea/CollisionShape2D.shape.set_size(Vector2(45, 45))
	$AttackArea/CollisionShape2D.position = Vector2(-1.5,-9.5)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
			
			
func _deal_damage() -> void:
	for body in attack_area.get_overlapping_bodies():
		print(body)
		if body.is_in_group("player") and body.has_method("deal_damage"):
			Global.energy -=30
			body.deal_damage(position.x)
			
func _on_body_entered(body):
	Global.energy -=30
	$"../CharacterBody2D".deal_damage(position.x)
	pass
