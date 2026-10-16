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

func _ready() -> void:
	damagetick = 0
	floor_max_angle = deg_to_rad(60.0)
	floor_snap_length = 8.0
	velocity = SceneTransition.velocity
	if SceneTransition.position:
		position = SceneTransition.position
		$"../Camera2D".position = SceneTransition.camera

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		$hurtbox.monitoring = true
		$hurtbox/AnimatedSprite2D.visible = true
		$hurtbox/AnimatedSprite2D.play()
		await $hurtbox/AnimatedSprite2D.animation_finished
		$hurtbox/AnimatedSprite2D.visible = false
		$hurtbox.monitoring = false
	if damagetick != 0:
		damagetick += 1
		$AnimatedSprite2D.self_modulate.a = 0.5 + 0.5*(floor(damagetick/4) % 2)
		if velocity.x*damageorigin > spezuli*4:
			velocity.x -= damageorigin*2
	if damagetick > 60:
		self_modulate.a = 1
		damagetick = 0

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
			momentumstate = 6
			velocity.x = 0
			$physicsbox.shape.set_size(Vector2(20, 20))
			momentumstate = 0
		else:
			movexground();
	else:
		momentumstate = 5
		movexair()
	jump() #and other airborne physics
	flip();
	move_and_slide()
	
func updateanim():
	if velocity.x:
		animated_spirte.play("iddle")
		
func jump():
	if Input.is_action_just_pressed("jump") and (is_on_floor() or (onsnow and velocity.y <= 0)):
		momentumstate = 5
		$physicsbox.shape.set_size(Vector2(20, 15))
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
