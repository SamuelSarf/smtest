extends Sprite2D
@export var power:String = "Ice"

func _ready() -> void:
	if Global.glace == true:
		queue_free()
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if get_tree().paused:
		return
	var reveal: Node = preload("res://powerpopup.tscn").instantiate()
	add_child(reveal)
	await reveal.play_whole()
	Global.glace = true
	scale = Vector2.ZERO
	evolveanimation()
	reveal = preload("res://suiteffect.tscn").instantiate()
	add_child(reveal)
	await reveal.get_child(0).play()
	$"../CharacterBody2D".set_collision_mask_value(7,true)
	$"../CharacterBody2D/AnimatedSprite2D".prefix = "glace"
	get_tree().paused = false
	queue_free()
	
func evolveanimation():
	var sprite = $"../CharacterBody2D/AnimatedSprite2D"
	sprite.animation = "evolve"
	await get_tree().create_timer(0.5).timeout
	sprite.frame = 1
	await get_tree().create_timer(0.5).timeout
	sprite.frame = 2
	await get_tree().create_timer(0.3).timeout
	sprite.frame = 1
	await get_tree().create_timer(0.2).timeout
	sprite.frame = 2
	await get_tree().create_timer(0.5).timeout
	sprite.frame = 3
