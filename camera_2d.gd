extends Camera2D
@onready var player: CharacterBody2D = $"../CharacterBody2D"
@onready var logic_layer: TileMapLayer = $"../TilemapL/camera"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var desired = player.global_position
	var new_pos = global_position
	var speed = 300 * delta
	var lookahead = speed + 2.0
	
	# Horizontal
	if desired.x < new_pos.x:
		if _allows(new_pos+Vector2(-130-lookahead,0), "allow_left"):
			new_pos.x = move_toward(new_pos.x, desired.x, speed)
	elif desired.x > new_pos.x:
		if _allows(new_pos+Vector2(130+lookahead,0), "allow_right"):
			new_pos.x = move_toward(new_pos.x, desired.x, speed)
	
	# Vertical
	if desired.y < new_pos.y:
		if _allows(new_pos+Vector2(0,-130-lookahead), "allow_up"):
			new_pos.y = move_toward(new_pos.y, desired.y, speed)
	elif desired.y > new_pos.y:
		if _allows(new_pos+Vector2(0,130+lookahead), "allow_down"):
			new_pos.y = move_toward(new_pos.y, desired.y, speed)
	
	global_position = new_pos

func _allows(world_pos: Vector2, direction: String) -> bool:
	var cell = logic_layer.local_to_map(logic_layer.to_local(world_pos))
	var data = logic_layer.get_cell_tile_data(cell)
	if data == null:
		return false
	return data.get_custom_data(direction)
