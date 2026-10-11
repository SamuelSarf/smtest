extends CharacterBody2D

@export var spezuli: float;
@export var jumpzuli: float;
var isfacingright: bool = false;
@onready var animated_spirte = $"../ground/aniamtedsprite";
var facing = 0
var momentumstate = 0 #0: standing; 1: moving: 2: slowing down; 3: finished slowing down; 4: turning around
var turningphase = 0
var turntarget = 0

func _physics_process(delta: float) -> void:
	jump(delta)
	movex();
	flip();
	move_and_slide()
	
func updateanim():
	if velocity.x:
		animated_spirte.play("iddle")
		
func jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jumpzuli
	if not is_on_floor():
		velocity.y += 980 * delta

func flip():
	if (isfacingright and (velocity.x < 0)) or ((not isfacingright) and (velocity.x > 0)):
		scale.x *= -1;
		isfacingright = not isfacingright;

func movex():
	#print(momentumstate)
	#print(facing)
	print(turntarget)
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
		if running:
			if abs(velocity.x) <= 4.75*spezuli:
				velocity.x += 0.25*spezuli*facing
		else:
			if abs(velocity.x) <= 2.75*spezuli:
				velocity.x += 0.1875*spezuli*facing
		if input_axis == 0:
			if abs(velocity.x) > 0.5*spezuli:
				velocity.x -= 0.5*spezuli*facing
			else:
				velocity.x = 0
				momentumstate = 2
				return
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
