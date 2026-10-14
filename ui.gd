extends CanvasLayer

var last_energy

func _ready() -> void:
	last_energy = Global.energy

func _process(_delta: float) -> void:
	if Global.energy != last_energy:
		last_energy = Global.energy
		act_energy()

func act_energy():
	if last_energy > 99:
		$"tanques/1".frame = 0
	else:
		$"tanques/1".frame = 1
	if last_energy > 199:
		$"tanques/2".frame = 0
	else:
		$"tanques/2".frame = 1
	if last_energy > 299:
		$"tanques/3".frame = 0
	else:
		$"tanques/3".frame = 1
	$"en 10^0".frame = last_energy % 10
	$"en 10^1".frame = (last_energy % 100)/10
