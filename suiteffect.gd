extends Control

@onready var rect: ColorRect = $ColorRect

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	rect.visible = false
	resized.connect(_update_size)
	_update_size()
	play()

func _update_size() -> void:
	var mat: ShaderMaterial = rect.material
	var s := get_viewport_rect().size
	mat.set_shader_parameter("screen_size", s)
	mat.set_shader_parameter("pixel_size", s.x / 256.0)

func play() -> void:
	var mat: ShaderMaterial = rect.material
	rect.visible = true

	# 1: lines meet
	var t1 := create_tween()
	t1.tween_method(func(v): mat.set_shader_parameter("phase_meet", v),
					0.0, 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await t1.finished

	# 2: widen to 1/5
	var t2 := create_tween()
	t2.tween_method(func(v): mat.set_shader_parameter("phase_widen", v),
					0.0, 1.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await t2.finished

	# 3: morph to ellipse + expand to full width + brighten, all in parallel
	var t3 := create_tween().set_parallel(true)
	t3.tween_method(func(v): mat.set_shader_parameter("phase_morph", v),
					0.0, 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t3.tween_method(func(v): mat.set_shader_parameter("phase_expand", v),
					0.0, 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t3.tween_method(func(v): mat.set_shader_parameter("phase_brighten", v),
					0.0, 1.0, 0.6)
	await t3.finished

	# 4: fade bright back to base (still full-screen ellipse)
	var t4 := create_tween()
	t4.tween_method(func(v): mat.set_shader_parameter("phase_brighten", v),
					1.0, 0.0, 0.3)
	await t4.finished

	# 5: morph back to rect while shrinking vertically, keeping full width
	var t5 := create_tween().set_parallel(true)
	t5.tween_method(func(v): mat.set_shader_parameter("phase_morph", v),
					1.0, 0.0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t5.tween_method(func(v): mat.set_shader_parameter("phase_collapse_v", v),
					0.0, 1.0, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await t5.finished

	# 6: shrink horizontally to center, decelerating
	var t6 := create_tween()
	t6.tween_method(func(v): mat.set_shader_parameter("phase_collapse_h", v),
					0.0, 1.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await t6.finished

	rect.visible = false
