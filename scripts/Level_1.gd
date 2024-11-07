extends Node2D
#@onready var halo = $Planet/Halo

@export var chords = []
@export var waves = [25]
@export var triangle = false
@export var grey = true
@export var move_speed = 350 # Pixels / second

var chords_ref = ["A", "B", "C", "D", "E", "F", "G"]

func one_active_planet():
	var rand_1 = randi_range(0, 6)  # Starting index in the ALPHABET
	var rand_2 = randi_range(0, 6)  # Starting index in the ALPHABET
	#var n2 = randi_range(1, 7)  # Number of letters to select (at least 1 letter)
	var n2 = 7  # Number of letters to select (at least 1 letter)
	var holding = []

	# Loop to add letters starting from n1, wrapping around if needed
	for i in range(n2):
		var active = []
		var index = (rand_1 + i) % n2  # Ensure the index wraps around
		active.append(chords_ref[index])
		active.append(i)
		active.append(1)
		holding.append(active)  # Add letters to preletters array
		
	chords = holding

	
func refresh():
	one_active_planet()
	
