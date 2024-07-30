extends Node2D

@onready var interval_game = $"."

const ALPHABET = ["A", "B", "C", "D", "E", "F", "G"]
var Section1 = []
var focus = 0

var random_int = 0

func new_rand():
	random_int = randi_range(0, 6)
	

func prep():
	Section1 = []
	new_rand()
	var preletters = []
	for i in range(len(ALPHABET)):
		if i < random_int:
			preletters.append(ALPHABET[i])
		else:
			Section1.append( ALPHABET[i])
			
	Section1.append_array(preletters)
	return Section1
	

## Called when the node enters the scene tree for the first time.

func _ready():
	Section1 = prep()
	print(interval_game.get_child(0))
	
		


#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _unhandled_input(event):
	if focus == 7:
		focus = 0
	if event is InputEventKey:
		if event.pressed: 
			if OS.get_keycode_string(event.key_label) == Section1[focus]:
				print('great job!')
				focus += 1
			else:
				print('dang it')
				print(Section1[focus], OS.get_keycode_string(event.key_label))
#
#func _input(event):
	#print(event)
