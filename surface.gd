extends Node2D
var icecounter = 0
@onready var attributes: TileMapLayer = $TilemapL/attributes

func _ready() -> void:
	pass

func _physics_process(delta):
	var tile_coord = attributes.local_to_map(attributes.to_local($CharacterBody2D.global_position))
	var tile_data = attributes.get_cell_tile_data(tile_coord)
	if not tile_data:
		$CharacterBody2D.onsnow = false
		return
	if tile_data.get_custom_data("transition"):
		SceneTransition.velocity = $CharacterBody2D.velocity
		SceneTransition.position = $CharacterBody2D.position + 16*(tile_data.get_custom_data("targetanch")-tile_data.get_custom_data("anchor"))
		Transition.to("res://"+tile_data.get_custom_data("transition")+".tscn", "wipe_up")
		return
	if tile_data.get_custom_data("snow") and Global.glace == false:
		$CharacterBody2D.onsnow = true
	else:
		$CharacterBody2D.onsnow = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.glace == false:
		if icecounter > 6:
			if $snowblips.playing == false:
				$snowblips.play()
			if $CharacterBody2D.onsnow == false:
				$snowblips.volume_db = -10
				icecounter = 0
			else:
				$snowblips.volume_db = -5
				icecounter = 4
			Global.energy -= 1
		else:
			icecounter += 1
