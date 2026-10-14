extends Sprite2D
@export var power:String = "Ice"

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if get_tree().paused:
		return
	var reveal: Node = preload("res://powerpopup.tscn").instantiate()
	add_child(reveal)
	await reveal.play_whole()
	Global.glace = true
	scale = Vector2.ZERO
	reveal = preload("res://suiteffect.tscn").instantiate()
	add_child(reveal)
	await reveal.get_child(0).play()
	get_tree().paused = false
	queue_free()
	
