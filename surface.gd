extends Node2D
var icecounter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.glace == false:
		if icecounter > 3:
			icecounter = 0
			Global.energy -= 1
		else:
			icecounter += 1
