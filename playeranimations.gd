extends AnimatedSprite2D
var scratching = false
var lastscrath = true
var prefix: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.glace:
		prefix = "glace"
	else:
		prefix = ""
	if not $"..".is_on_floor():
		animation = "falling"
		frame = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var momentumstate = $"..".momentumstate
	if $"..".canscratch == false and $"..".canscratch != lastscrath:
		scratching = true
	lastscrath = $"..".canscratch
	if scratching == true:
		if animation != prefix+"scratch":
			animation = prefix+"scratch"
			play()
		else:
			if frame == 4:
				scratching = false
		return
	if $"..".jumping == true:
		animation = prefix+"jumping"
		play()
	elif not $"..".is_on_floor():
		if $"..".damagetick != 0:
			animation = prefix+"damage"
			play()
		elif animation != prefix+"falling":
			animation = prefix+"falling"
			play()
	elif $"..".slowing == true:
		animation = prefix+"slowing"
		play()
	elif momentumstate == 1:
		animation = prefix+"walking"
		play()
	else:
		animation = prefix+"walking"
		stop()
		frame = 0
	if animation == prefix+"walking" and frame == 2:
		$"../../footsteps".play()
