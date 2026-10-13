extends CharacterBody2D

@export var spezuli: float = 50;
@export var jumpzuli: float = 50;
var isfacingright: bool = false;
@onready var animated_spirte = $"../ground/aniamtedsprite";
var facing = 0
var momentumstate = 0 #0: standing; 1: moving: 2: slowing down; 3: finished slowing down; 4: turning around; 5: jumping; 6:landing
var turningphase = 0
var turntarget = 0
var jumping = false
@export var gravity:float = 500

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if momentumstate == 5:
			momentumstate = 6
			velocity.x = 0
			$hitbox.shape.set_size(Vector2(20, 20))
			momentumstate = 0
		else:
			movexground();
	else:
		movexair()
	jump(delta) #and other airborne physics
	flip();
	move_and_slide()
	
func updateanim():
	if velocity.x:
		animated_spirte.play("iddle")
		
func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		momentumstate = 5
		$hitbox.shape.set_size(Vector2(20, 15))
		jumping = true
		if abs(velocity.x) <= 0.125*spezuli:
			velocity.x = 0
		elif abs(velocity.x) <= 1*spezuli:
			velocity.x += 0.75*spezuli*facing
		elif abs(velocity.x) < 2.75*spezuli:
			velocity.x = 0.25*velocity.x + 1.375*spezuli*facing
		else:
			velocity.x -= 1.375*spezuli*facing
		velocity.y = -4.875*jumpzuli
	if not is_on_floor():
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
				if abs(velocity.x) <= 4.75*spezuli:
					if abs(velocity.x) >= 2.75*spezuli:
						velocity.x += 0.0625*spezuli*facing
					else:
						velocity.x += 0.25*spezuli*facing
						if abs(velocity.x) >= 2.5625*spezuli:
							velocity.x += 0.6875*spezuli*facing
			else:
				if abs(velocity.x) <= 2.75*spezuli:
					velocity.x += 0.1875*spezuli*facing
					if abs(velocity.x) > 2*spezuli:
						velocity.x = 2.75*spezuli*facing
		elif input_axis == 0:
			if abs(velocity.x) > 0.5*spezuli:
				velocity.x -= 0.5*spezuli*facing
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
			velocity.x = 0.3125*spezuli*facing
		else:
			velocity.x = 0.1875*spezuli*facing
		momentumstate = 3
		return
	if momentumstate == 3:
		velocity.x = 0
		momentumstate = 0
		return
	if momentumstate == 4:
		if (facing == -input_axis or turningphase <= 1) and abs(velocity.x) > 0.5*spezuli:
			velocity.x -= 0.5*spezuli*facing
		else:
			velocity.x = 0
		turningphase += 1
		if turningphase >= 6:
			facing = turntarget
			momentumstate = 0
		return
func movexair():
	var input_axis = Input.get_axis("move_left", "move_right");
	if input_axis == -1:
		facing = input_axis
		if velocity.x > -1.375*spezuli:
			velocity.x += -0.5*spezuli
			if velocity.x < -1.375*spezuli:
				velocity.x = -1.375*spezuli
	elif input_axis == 1:
		facing = input_axis
		if velocity.x < 1.375*spezuli:
			velocity.x += 0.5*spezuli
			if velocity.x > 1.375*spezuli:
				velocity.x = 1.375*spezuli
