extends CharacterBody2D

const spezuli: float = 48;
const jumpzuli: float = 48;
var isfacingright: bool = false;
@onready var animated_spirte = $AnimatedSprite2D;
var facing = 0
var momentumstate = 0 #0: standing; 1: moving: 2: slowing down; 3: finished slowing down; 4: turning around; 5: air; 6:landing
var turningphase = 0
var turntarget = 0
var jumping = false
@export var consgravity:float = 48
var gravity = consgravity
var speed = spezuli
var jumpst = jumpzuli
var onsnow = false
var attacking = true
var damagetick = 0
var damageorigin
var slowing: bool = false
var canscratch = true
func _ready() -> void:
	if Global.glace == true:
		set_collision_mask_value(7,true)
	damagetick = 0
	floor_max_angle = deg_to_rad(60.0)
	floor_snap_length = 8.0
	velocity = SceneTransition.velocity
	if SceneTransition.position:
		position = SceneTransition.position
		$"../Camera2D".position = SceneTransition.camera
	if SceneTransition.direction:
		facing = SceneTransition.direction

func _process(delta: float) -> void:
	if canscratch:
		scratch()
	if damagetick != 0:
		damagetick += 1
		$AnimatedSprite2D.self_modulate.a = 0.5 + 0.5*(floor(damagetick/4) % 2)
		if velocity.x*damageorigin > spezuli*4:
			velocity.x -= damageorigin*2
	if damagetick > 60:
		self_modulate.a = 1
		damagetick = 0
func scratch():
	if Input.is_action_just_pressed("attack") and damagetick == 0:
		canscratch = false
		if Global.glace:
			$hurtbox/CollisionShape2D.shape.set_size(Vector2(25, 32))
			$hurtbox/CollisionShape2D.position = Vector2(-16.5,-3)
			$hurtbox/AnimatedSprite2D.position = Vector2(-17,4)
			$hurtbox/AnimatedSprite2D.animation = "glaceon"
		else:
			$hurtbox/CollisionShape2D.shape.set_size(Vector2(15, 12))
			$hurtbox/CollisionShape2D.position = Vector2(-6.5,2)
			$hurtbox/AnimatedSprite2D.position = Vector2(-9,3)
			$hurtbox/AnimatedSprite2D.animation = "eevee"
		$hurtbox.monitoring = true
		$hurtbox/AnimatedSprite2D.visible = true
		$hurtbox/AnimatedSprite2D.play()
		await $hurtbox/AnimatedSprite2D.animation_finished
		$hurtbox/AnimatedSprite2D.visible = false
		$hurtbox.monitoring = false
		await get_tree().create_timer(0.2).timeout
		canscratch = true
func _physics_process(delta: float) -> void:
	if onsnow:
		velocity = Vector2.ZERO
		jumpst = 20
		gravity = 20
		speed = 10
		floor_constant_speed = false
	else:
		jumpst = jumpzuli
		gravity = consgravity
		speed = spezuli
		floor_constant_speed = true
	if is_on_floor():
		if momentumstate == 5:
			$"../landing".play()
			momentumstate = 6
			velocity.x = 0
			if Global.glace:
				$physicsbox.shape.set_size(Vector2(20, 23))
				$physicsbox.position.y = 5
				momentumstate = 0
			else:
				$physicsbox.shape.set_size(Vector2(20, 15))
				$physicsbox.position.y = 5
				momentumstate = 0
		else:
			movexground();
	else:
		$physicsbox.shape.set_size(Vector2(20, 14))
		$physicsbox.position.y = 7
		slowing = false
		momentumstate = 5
		movexair()
	jump() #and other airborne physics
	flip();
	if damagetick == 0:
		move_and_slide()
	else:
		var collision := move_and_slide()
		if collision:
			for i in get_slide_collision_count():
				var normal := get_slide_collision(i).get_normal()
				# Only bounce off vertical walls (normal points along X)
				if abs(normal.x) > 0.7:
					velocity.x = -velocity.x*0.6
					break
	
func updateanim():
	if velocity.x:
		animated_spirte.play("iddle")
		
func jump():
	if Input.is_action_just_pressed("jump") and (is_on_floor() or (onsnow and velocity.y <= 0)):
		momentumstate = 5
		jumping = true
		if abs(velocity.x) <= 0.125*speed:
			velocity.x = 0
		elif abs(velocity.x) <= 1*speed:
			velocity.x += 0.75*speed*facing
		elif abs(velocity.x) < 2.75*speed:
			velocity.x = 0.25*velocity.x + 1.375*speed*facing
		else:
			velocity.x -= 1.375*speed*facing
		velocity.y = -4.875*jumpst
		
	if not is_on_floor():
		if velocity.y < 5.03125*gravity:
			velocity.y += 0.109375*gravity
		if velocity.y >= 0:
			jumping = false
		if jumping == true and not Input.is_action_pressed("jump"):
			jumping = false
			velocity.y = -0.109375

func flip():
	if (isfacingright and (velocity.x < 0)) or ((not isfacingright) and (velocity.x > 0)):
		scale.x *= -1;
		isfacingright = not isfacingright;

func movexground():
	#print(momentumstate)
	#print(facing)
	#print(turntarget)
	var input_axis = Input.get_axis("move_left", "move_right");
	if Input.is_action_pressed("crouch"):
		input_axis = 0
	var running = Input.is_action_pressed("run")
	if momentumstate == 0 and input_axis != 0:
		if facing == input_axis:
			momentumstate = 1
			return
		else:
			if facing == 0:
				facing = input_axis
			else:
				turningphase = 0
				turntarget = input_axis
				momentumstate = 4
			return
	if momentumstate == 1:
		slowing = false
		if input_axis == facing:
			if running:
				if abs(velocity.x) <= 4.75*speed:
					if abs(velocity.x) >= 2.75*speed:
						velocity.x += 0.0625*speed*facing
					else:
						velocity.x += 0.25*speed*facing
						if abs(velocity.x) >= 2.5625*speed:
							velocity.x += 0.6875*speed*facing
			else:
				if abs(velocity.x) <= 2.75*speed:
					velocity.x += 0.1875*speed*facing
					if abs(velocity.x) > 2*speed:
						velocity.x = 2.75*speed*facing
		elif input_axis == 0:
			if abs(velocity.x) > 0.5*speed:
				velocity.x -= 0.5*speed*facing
				slowing = true
			else:
				velocity.x = 0
				momentumstate = 2
				return
		else:
			turningphase = 0
			turntarget = input_axis
			momentumstate = 4
	if momentumstate == 2:
		if running:
			velocity.x = 0.3125*speed*facing
		else:
			velocity.x = 0.1875*speed*facing
		momentumstate = 3
		return
	if momentumstate == 3:
		velocity.x = 0
		momentumstate = 0
		slowing = false
		return
	if momentumstate == 4:
		if (facing == -input_axis or turningphase <= 1) and abs(velocity.x) > 0.5*speed:
			velocity.x -= 0.5*speed*facing
		else:
			velocity.x = 0
		turningphase += 1
		if turningphase >= 6:
			facing = turntarget
			momentumstate = 0
		return
func movexair():
	if damagetick == 0 or damagetick > 20:
		var input_axis = Input.get_axis("move_left", "move_right");
		if input_axis == -1:
			facing = input_axis
			if velocity.x > -1.375*speed:
				velocity.x += -0.5*speed
				if velocity.x < -1.375*speed:
					velocity.x = -1.375*speed
		elif input_axis == 1:
			facing = input_axis
			if velocity.x < 1.375*speed:
				velocity.x += 0.5*speed
				if velocity.x > 1.375*speed:
					velocity.x = 1.375*speed

func deal_damage(origin:float) -> void:
	if damagetick == 0:
		$Damage.play()
		damagetick = 1
		damageorigin = sign(position.x-origin)
		velocity.x = spezuli*6*damageorigin
		if is_on_floor():
			velocity.y += -jumpzuli*3
