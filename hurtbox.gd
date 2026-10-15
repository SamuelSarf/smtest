extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		# Ensure physics_quadrant_size is set to 1 in the Inspector
		var cell_coords = body.get_coords_for_body_rid(body_rid)
		var tile_data = body.get_cell_tile_data(cell_coords)
		print(tile_data)
		
		if tile_data and tile_data.get_custom_data("destructible"):
			print("alerta")
			body.erase_cell(cell_coords)
