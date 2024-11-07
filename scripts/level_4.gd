extends Node2D


@export var chords = []
@export var waves = [25]
@export var triangle = false
@export var grey = true
@export var move_speed = 200 # Pixels / second

var chords_ref = ["A", "B", "C", "D", "E", "F", "G"]


func generate_random_numbers() -> Array:
	var numbers = [0, 1, 2, 3, 4, 5, 6]
	var result = []
	var count = randi_range(1, numbers.size())  # Random count of numbers to pick

	for i in count:
		var chosen_index = randi_range(0, numbers.size() - 1)
		result.append(numbers[chosen_index])
		numbers.remove_at(chosen_index)  # Remove chosen number to avoid duplicates
		
	result.sort()  # Sort the list in increasing order
	return result

func one_active_planet():
	var rands = generate_random_numbers()
	
	var all_letters = get_node("letters")
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
		if index >= 0 and index < rands.size():
			active.append(1)
			holding.append(active)  # Add letters to preletters array
		else:
			active.append(0)
			holding.append(active)  # Add letters to preletters array
		
	chords = holding
	
func refresh():
	one_active_planet()
	
