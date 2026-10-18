extends Node2D
var icecounter = 0
@onready var attributes: TileMapLayer = $TilemapL/attributes
var frozen = true
func _ready() -> void:
	if SceneTransition.music == $music.stream:
		$music.play(SceneTransition.musicpart)
	else:
		$music.play()

func _physics_process(delta):
	var tile_coord = attributes.local_to_map(attributes.to_local($CharacterBody2D.global_position))
	var tile_data = attributes.get_cell_tile_data(tile_coord)
	if not tile_data:
		$CharacterBody2D.onsnow = false
		return
	if tile_data.get_custom_data("transition"):
		SceneTransition.velocity = $CharacterBody2D.velocity
		SceneTransition.position = $CharacterBody2D.position + 16*(tile_data.get_custom_data("targetanch")-tile_data.get_custom_data("anchor"))
		SceneTransition.direction = $CharacterBody2D.facing
		SceneTransition.camera = tile_data.get_custom_data("tcam")
		SceneTransition.music = $music.stream
		SceneTransition.musicpart = $music.get_playback_position()
		var transdir = tile_data.get_custom_data("transdir")
		if transdir == 0:
			Transition.to("res://"+tile_data.get_custom_data("transition")+".tscn", ("wipe_up"))
		elif transdir == 1:
			Transition.to("res://"+tile_data.get_custom_data("transition")+".tscn", ("wipe_left"))
		elif transdir == 2:
			Transition.to("res://"+tile_data.get_custom_data("transition")+".tscn", ("wipe_right"))
		return
	if tile_data.get_custom_data("snow") and Global.glace == false:
		$CanvasLayer.onsnow = true
		$CharacterBody2D.onsnow = true
	else:
		$CanvasLayer.onsnow = false
		$CharacterBody2D.onsnow = false

func _process(_delta: float) -> void:
	if Global.glace == false:
		if icecounter > 10:
			if $snowblips.playing == false:
				$snowblips.play()
			if $CharacterBody2D.onsnow == false:
				$snowblips.volume_db = -20
				icecounter = 0
			else:
				$snowblips.volume_db = -10
				icecounter = 6
			Global.energy -= 1
		else:
			icecounter += 1
