extends CanvasLayer

@onready var reveal_rect: TextureRect = $RevealRect

func _ready() -> void:
	var mat := reveal_rect.material as ShaderMaterial
	mat.set_shader_parameter("split", 0.0)

func play_whole():
	get_tree().paused = true
	await play(false,0.5)
	await get_tree().create_timer(2.0).timeout 
	await play(true,0.2)
	queue_free()

func play(reverse: bool = false, duration: float = 0.5) -> void:
	var mat := reveal_rect.material as ShaderMaterial
	var from := 0.0 if reverse else 1.0
	var to   := 1.0 if reverse else 0.0
	# Actually let's define: forward = open (0→1), reverse = close (1→0)
	from = 1.0 if reverse else 0.0
	to   = 0.0 if reverse else 1.0
	mat.set_shader_parameter("split", from)
	var tween := create_tween()
	tween.tween_method(
		func(v): mat.set_shader_parameter("split", v),
		from, to, duration
	).set_trans(Tween.TRANS_CUBIC)\
	 .set_ease(Tween.EASE_OUT if not reverse else Tween.EASE_IN)
	await tween.finished
