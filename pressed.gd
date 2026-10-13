extends Control

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		$left.visible = true
	else:
		$left.visible = false
	if Input.is_action_pressed("move_right"):
		$right.visible = true
	else:
		$right.visible = false
	if Input.is_action_pressed("jump"):
		$a.visible = true
	else:
		$a.visible = false
	if Input.is_action_pressed("run"):
		$b.visible = true
	else:
		$b.visible = false
	if Input.is_action_pressed("attack"):
		$x.visible = true
	else:
		$x.visible = false
	if Input.is_action_pressed("crouch"):
		$down.visible = true
	else:
		$down.visible = false
