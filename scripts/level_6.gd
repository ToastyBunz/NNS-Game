extends Node2D
#@onready var halo = $Planet/Halo

@export var chords = []
@export var waves = [25]
@export var triangle = false
@export var grey = true
@export var move_speed = 300 # Pixels / second

var chords_ref = ["A", "B", "C", "D", "E", "F", "G"]

#func _ready():
	#one_active_planet()


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
		if i in [1, 2, 5]:
			active.append(chords_ref[index] + "m")
		if i in [0, 3, 4]:
			active.append(chords_ref[index])
		if i in [6]:
			active.append(chords_ref[index] + "d")
			
		active.append(i)
		active.append(1)
		holding.append(active)  # Add letters to preletters array
		
	chords = holding
	#print(chords)
	
func refresh():
	one_active_planet()
	
