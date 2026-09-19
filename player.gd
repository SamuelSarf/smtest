extends CharacterBody2D

@export var spezuli: float;
@export var jumpzuli: float;
var isfacingright: bool = false;
@onready var animated_spirte = $"../ground/aniamtedsprite";

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
	var input_axis = Input.get_axis("move_left", "move_right");
	velocity.x = input_axis*spezuli;
