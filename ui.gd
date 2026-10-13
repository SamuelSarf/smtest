extends CanvasLayer

var last_energy = 0

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Global.energy != last_energy:
		last_energy = Global.energy
		act_energy()

func act_energy():
	if last_energy > 99:
		$"tanques/1".frame = 0
		if last_energy > 199:
			$"tanques/2".frame = 0
			if last_energy > 299:
				$"tanques/3".frame = 0
			else:
				$"tanques/3".frame = 1
		else:
			$"tanques/2".frame = 1
	else:
		$"tanques/1".frame = 1
	$"en 10^0".frame = last_energy % 10
	$"en 10^1".frame = floor((last_energy % 100)/10)
