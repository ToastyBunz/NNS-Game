
# box then gaps on sides
# why when there are seven notes does it not render?

extends Node2D
#@onready var halo = $Planet/Halo

@onready var interval_game = $"../.."
@onready var background = $Interval_Background
@onready var hud = $hud
@onready var level_progress = $Level_progress
@onready var ships = $Ships
@onready var letters = $letters
@onready var explosion = $explosion
@onready var explosion_magazine = $Explosion_magazine
@onready var planet = $Planet

var letter_node = load("res://scenes/letter.tscn")
var ship_node = load("res://scenes/Alien_fighter.tscn")

var level = 1
const ALPHABET = ["A", "B", "C", "D", "E", "F", "G"]
var Section1 = []
var level_waves = [25]
var focus = 0
var Wscreen = 1125
var Hscreen = 648
var waves = 0
var waves_passed = 0
var score = Global.score
var multiplier = Global.multiplayer
var points = 10
var random_int = 0
var max_multiplier = 4
var ship_hight = 0
var ship_start_position = 1200
var current_bonus_bar = 0
var current_ship_position = 0



func new_rand():
	random_int = randi_range(0, 6)
	#random_int = randi_range(2, 2)
	

func prep():
	var all_letters = get_node("letters")
	var n1 = randi_range(0, 6)  # Starting index in the ALPHABET
	#var n2 = randi_range(1, 7)  # Number of letters to select (at least 1 letter)
	var n2 = 7  # Number of letters to select (at least 1 letter)
	Section1 = []
	var preletters = []

	# Loop to add letters starting from n1, wrapping around if needed
	for i in range(n2):
		var index = (n1 + i) % ALPHABET.size()  # Ensure the index wraps around
		preletters.append(ALPHABET[index])  # Add letters to preletters array

	# Copy preletters into Section1 (or directly use Section1)
	Section1.append_array(preletters)

	var segs = preletters.size()
	var corblock = (segs - 1) * 150  # The total width occupied by the letters
	var padding = round((Wscreen - corblock) / 2)  # Calculate padding to center the letters
	var x_pos = 0
	var y_pos = Hscreen / 2  # Center the letters vertically

	for j in range(segs):
		if segs == 1:
			x_pos = Wscreen / 2
		else:
			x_pos = padding + (j * 150)  # Position letters with equal spacing
			
		# Instantiate the letter node and set position
		var new_letter_instance = letter_node.instantiate()
		new_letter_instance.set_global_position(Vector2(x_pos, y_pos))
		new_letter_instance.get_node("Label").text = Section1[j]  # Set letter text
		new_letter_instance.name = "note_%s" % (j + 1)  # Give each note a unique name
		
		# Add the letter to the parent node
		all_letters.add_child(new_letter_instance)
		
	# Set the font color for the first note (planet 0)
	if all_letters.get_child_count() > 0:
		all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204)) # not changing color when reset level runs
	Section1 = preletters
	
	hud.get_node("Hud_key/Label").text = "Key  " + Section1[0] 
	
	return Section1
	
func initiate_ships():
	for i in range(Section1.size()):
		ship_hight = round((Hscreen - 30) / 7 * (7 - i)) - 30
		var new_ship_instance = ship_node.instantiate()
		new_ship_instance.set_global_position(Vector2(ship_start_position, ship_hight))
		new_ship_instance.name = "alien_%s" % (i + 1)  # Give each note a unique name
		ships.add_child(new_ship_instance)
		
	

func prep_signals():
	planet.get_node("Halo").connect("levelOver", game_over)
	planet.get_node("Halo").connect("enemyAttack", hit_sheilds)


func hit_sheilds():
	var all_letters = get_node("letters")
	reset_ship(0)
	if (focus + 1) != Section1.size(): # if this is not the last letter
		all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 0, 0))
		all_letters.get_child(focus + 1).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204))
		modify_multiplier(0)
		update_bonus(100, 0)
	else: # if last letter in set
		waves_passed += 1
		level_progress.get_node("TextureProgressBar").value = (float(waves_passed) / float(level_waves[-1]))*100
		reset_level()
	focus += 1


func game_over():
	get_node("hud/GameOver/CanvasLayer").game_over_hud()
	get_node("hud/GameOver/CanvasLayer/Panel2/Percentage_number").text = str((float(waves_passed) / float(level_waves[-1]))*100) + "%"
	get_node("hud/GameOver/CanvasLayer/Panel2/Score_number").text = str(score)
	
## Called when the node enters the scene tree for the first time.
func _ready():
	Section1 = prep()
	hud.get_node("Hud_score/Label").text = '0'
	multiplier = 1
	initiate_ships()
	prep_signals()
	

func activate_ships(delta):
	var move_speed = 350  # Pixels per second
	var ship = ships.get_child(focus)
	ship.visible = true
	ship.position.x -= move_speed * delta
	current_ship_position = ship.position.x


func reset_ship(type):
	# set visibility to none
	var ship = ships.get_child(focus)
	var boom_position = ship.position
	
	var explosion_instance = get_explosion_from_pool()
	if type == 0: # impacts planet
		explosion_instance.ship_explosion(boom_position, 0)
		print("collsion at", boom_position)
	if type == 1: # shot down
		explosion_instance.ship_explosion(boom_position, 1)
		
	ship.visible = false
	ship.position.x = ship_start_position # set ship back at x = 1300


func get_explosion_from_pool():
	for i in range(explosion_magazine.get_child_count()):
		var ex = explosion_magazine.get_child(i)
		if not ex.get_node("small_particles").emitting:
			return ex
			break
	return null


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _unhandled_input(Input):
		activate_ships(delta)
		var target_position = 133
		var percentage_progress = ((ship_start_position - current_ship_position) / (ship_start_position - target_position)) * 100
		update_bonus(percentage_progress, 1)


	
func reset_level():
	var all_letters = get_node("letters")
	# Remove all child elements from all_letters node	
	for child in all_letters.get_children():
		child.queue_free()
	focus = 0
	new_rand()
	prep()


func update_bonus(new_value, color):
	var current_bonus_bar = letters.get_child(focus).get_node("Bonus_bar").get_node('TextureProgressBar')
	current_bonus_bar.value = new_value
	
	if color == 0:
		current_bonus_bar.set("tint_progress", Color(0.38, 0, 0))
		


func _unhandled_input(event): # playing the game
	var all_letters = get_node("letters")
	var section_size = Section1.size()
	
	if focus == section_size:
		focus = 0
	if event is InputEventKey:
		if event.pressed: 
			if OS.get_keycode_string(event.key_label) == Section1[focus]:
				update_bonus(100, 1) # set bar to 100%
				if multiplier < max_multiplier:
					modify_multiplier(1)
				score += 100 * multiplier
				hud.get_node("Hud_score/Label").text = str(score)
				all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(36, 217, 107))
				reset_ship(1)
				focus += 1
				if focus != section_size:
					all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204))
				else:
					waves_passed += 1
					level_progress.get_node("TextureProgressBar").value = (float(waves_passed) / float(level_waves[-1]))*100
					reset_level()
					
			else:
				modify_multiplier(0)
				update_bonus(100, 0) # set bar to 100% and turn red
				
##
#
#func next_level():
	#const FILE_START = "res://interval_levels/level_"
	#var current_scene_file = get_tree().current_scene.scene_file_path
	#var next_level_number = current_scene_file.to_int() + 1
	#var next_level_path = FILE_START + str(next_level_number) + ".tscn"
	#
	#get_tree().change_scene_to_file(next_level_path)


func modify_multiplier(correct):
	if correct == 1:
		multiplier += 1
		#hud.get_node("Hud_multiplier/Label").text = str(multiplier) + "X"
		hud.get_node("Hud_multiplier/RichTextLabel").text = str(multiplier) + "X"
		hud.get_node("Hud_multiplier/Label_shadow").text = str(multiplier) + "X"
		
		if multiplier == max_multiplier:
			hud.get_node("Hud_multiplier/RichTextLabel").text = "[shake rate=50level=10]%s[/shake]" %max_multiplier + "X"
			#hud.get_node("Hud_multiplier/RichTextLabel").add_theme_color_override("font_color", Color8(247, 0, 0)) want to change colors
	if correct == 0:
		print('dang it')
		multiplier = 1
		#hud.get_node("Hud_multiplier/Label").text = ""
		hud.get_node("Hud_multiplier/RichTextLabel").text = ""
		hud.get_node("Hud_multiplier/Label_shadow").text = ""
		


