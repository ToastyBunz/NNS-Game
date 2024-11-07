extends Node2D

@export var chords = []
@export var waves = [25]
@export var triangle = false
@export var grey = true
@export var move_speed = 200 # Pixels / second

var chords_ref = ["A", "B", "C", "D", "E", "F", "G"]

func _ready():
	one_active_planet()

func generate_random_numbers() -> Array:
	var numbers = [0, 1, 2, 3, 4, 5, 6]
	var result = []
	var count = randi_range(1, numbers.size())  # Random count of numbers to pick

	for i in range(count):
		var chosen_index = randi_range(0, numbers.size() - 1)
		result.append(numbers[chosen_index])
		numbers.remove_at(chosen_index)  # Remove chosen number to avoid duplicates
		
	return result

func one_active_planet():
	var rands = generate_random_numbers()
	var n2 = 7  # Number of letters to select
	var holding = []

	# Loop to add letters with random active status
	for i in range(n2):
		var active = []
		var index = i % chords_ref.size()  # Wrap around if needed
		active.append(chords_ref[index])
		active.append(i)
		if rands.has(index):  # Set active based on rands
			active.append(1)
		else:
			active.append(0)
		holding.append(active)

	# Shuffle holding array randomly
	for i in range(holding.size()):
		var random_index = randi_range(0, holding.size() - 1)
		# Swap elements at i and random_index
		var temp = holding[i]
		holding[i] = holding[random_index]
		holding[random_index] = temp

	# Assign shuffled holding array to chords
	chords = holding

func refresh():
	one_active_planet()
