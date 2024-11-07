extends Node2D
#@onready var halo = $Planet/Halo

@onready var game = $".."
@onready var core_game = $"."
@onready var hud = $hud
@onready var level_progress = $hud/Level_progress
@onready var ships = $Ships
@onready var letters = $letters
@onready var explosion = $explosion
@onready var explosion_magazine = $Explosion_magazine

var letter_node = load("res://scenes/letter.tscn")
var ship_node = load("res://scenes/Alien_fighter.tscn")

var ALPHABET = []
var Active_chords = []
var level_waves = []
var triangle = false
var planet = null


var Section1 = []
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
var level = 1
var move_speed = 350 # Pixels / second
var modifier = ""



## Called when the node enters the scene tree for the first time.
func _ready():
	get_level_vars()
	Section1 = prep()
	hud.get_node("Hud_score/Label").text = '0'
	multiplier = 1
	initiate_ships()
	prep_signals(0)

func refresh_level_vars(path):  # Access the exported variables from the instanced scene
	var lvl = core_game.get_node(str(path))
	lvl.refresh()
	ALPHABET = lvl.chords
	level_waves = lvl.waves
	triangle = lvl.triangle
	move_speed = lvl.move_speed

func get_level_vars():
	var level_instance = core_game.get_child(-1).name	
	planet = core_game.get_node(level_instance +"/Planet")
	refresh_level_vars(level_instance)

func prep():
	var all_letters = get_node("letters")
	Section1 = ALPHABET

	var segs = Section1.size()
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
		if core_game.get_child(-1).name.to_int() > 1:
			new_letter_instance.get_node("Label").text = str(Section1[j][1] + 1)  # Set letter text
		else:
			new_letter_instance.get_node("Label").text = Section1[j][0]  # Set letter text
		new_letter_instance.name = "note_%s" % (j + 1)  # Give each note a unique name
		if Section1[j][-1] == 0:
			new_letter_instance.get_node("Label").add_theme_color_override("font_color", Color8(25, 25, 25)) # grey out non active letters
			#letters.get_child(j).get_node("Bonus_bar").get_node("TextureProgressBar").tint_over = Color(0.38, 0, 0)
			
		if Section1[j][1] == 0:
			hud.get_node("Hud_key/Label").text = "Key  " + Section1[j][0] 
			
		
		# Add the letter to the parent node
		all_letters.add_child(new_letter_instance)
		
	# Set the font color for the first note (planet 0)
	var zip = all_letters.get_child_count()
	if zip > 0:
		for i in range(zip):
			if Section1[i][-1] == 0:
				focus += 1
			else:
				all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204)) # not changing color when reset level runs
				break
	
	
	return Section1
	
func initiate_ships():
	for i in range(Section1.size()):
		ship_hight = round((Hscreen - 30) / 7 * (7 - i)) - 30
		var new_ship_instance = ship_node.instantiate()
		new_ship_instance.set_global_position(Vector2(ship_start_position, ship_hight))
		new_ship_instance.name = "alien_%s" % (i + 1)  # Give each note a unique name
		ships.add_child(new_ship_instance)

func next_level():

	# Construct the name of the current level node
	var current_level = str(core_game.get_child(-1).name)
	var current_level_num = core_game.get_child(-1).name.to_int()
	var next_level_name = "res://levels_magazine/level_" + str(current_level_num + 1) + ".tscn"

	if ResourceLoader.exists(next_level_name):  # Check if the path exists
		var thislevel = get_node(current_level)
		core_game.remove_child(thislevel)
		thislevel.queue_free()
		
		# Increment level for the next level load
		current_level_num += 1

		# Load the next level
		var level_path = "res://levels_magazine/level_" + str(current_level_num) + ".tscn"
		var level_scene = load(level_path)
		var level_instance = level_scene.instantiate()
		
		level_instance.name = "level_" + str(current_level_num)
		core_game.add_child(level_instance)  # Add the new level instance to the core_game node)
		get_level_vars()
		prep_signals(1)
		restart_level(1, 1)
		#get_level_vars()
		# Resume the game and reset scene if needed
		get_tree().paused = false
		#get_tree().reload_current_scene()

		hud.get_node("Hud_score/lvl").text = str(current_level_num)
	else:
		var credits = load("res://scenes/win_label.tscn").instantiate()
		game.add_child(credits)
		core_game.queue_free()

func next_level_hud():
	get_tree().paused = true
	var next_lvl_screen = hud.get_node("nxt_lvl/CanvasLayer")
	next_lvl_screen.get_node("Panel2/Score_number").text = str(score)
	next_lvl_screen.get_node("Panel2/Percentage_number").text = "100%"
	next_lvl_screen.visible = true
	var tester = hud.get_node("nxt_lvl/CanvasLayer")
	#print(tester)

func prep_signals(rerun):
	#print('planet', planet)
	if rerun == 1: # refresh connections
		planet.get_node("Halo").connect("levelOver", game_over)
		planet.get_node("Halo").connect("enemyAttack", hit_sheilds)
	else: # refresh all
		planet.get_node("Halo").connect("levelOver", game_over)
		planet.get_node("Halo").connect("enemyAttack", hit_sheilds)
		hud.get_node("nxt_lvl/CanvasLayer").connect("changeLevel", next_level)
		hud.get_node("GameOver/CanvasLayer").connect("restartLevel", Callable(self, "restart_level"))
		hud.get_node("nxt_lvl/CanvasLayer").connect("restartLv", Callable(self, "restart_level"))
		
	if core_game.get_child(-1).name.to_int() >= 6:
		core_game.get_child(-1).get_node("mouse_diamond").connect("noteModifier", Callable(self, "drag_modifier"))

func drag_modifier(direction):
	modifier = direction

func hit_sheilds():
	var all_letters = get_node("letters")
	reset_ship(0)	
	if (focus + 1) != Section1.size(): # if this is not the last letter
		all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 0, 0))
		all_letters.get_child(focus + 1).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204))
		modify_multiplier(0)
		update_bonus(100, 0)
	focus += 1
	for i in range(focus, Section1.size()):
		if Section1[i][-1] == 1:
			break
		else:
			focus += 1
				
	if (focus) == Section1.size(): # if last letter in set
		waves_passed += 1
		level_progress.get_node("TextureProgressBar").value = (float(waves_passed) / float(level_waves[-1]))*100
		reset_level()

func game_over():
	get_node("hud/GameOver/CanvasLayer").game_over_hud()
	get_node("hud/GameOver/CanvasLayer/Panel2/Percentage_number").text = str((float(waves_passed) / float(level_waves[-1]))*100) + "%"
	get_node("hud/GameOver/CanvasLayer/Panel2/Score_number").text = str(score)

func activate_ships(delta):
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
		#print("collsion at", boom_position)
	if type == 1: # shot down
		explosion_instance.ship_explosion(boom_position, 1)
	if type == 2:
		pass
		
	ship.visible = false
	ship.position.x = ship_start_position # set ship back at x = 1300

func get_explosion_from_pool():
	for i in range(explosion_magazine.get_child_count()):
		var ex = explosion_magazine.get_child(i)
		if not ex.get_node("small_particles").emitting:
			return ex
			break
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _unhandled_input(Input):
		activate_ships(delta)
		var target_position = 133
		var percentage_progress = ((ship_start_position - current_ship_position) / (ship_start_position - target_position)) * 100
		update_bonus(percentage_progress, 1)


func reset_level(): #only resets letters
	var all_letters = get_node("letters")
	# Remove all child elements from all_letters node	
	for child in all_letters.get_children():
		child.queue_free()
	focus = 0
	refresh_level_vars("level_" + str(core_game.get_child(-1).name.to_int()))
	prep()

func restart_level(advancing, ship_exists): # restarts whole level
	if advancing == 0: # player is restarting failed level
		#print('not advancing')
		if ship_exists:
			reset_ship(2)
		
	#reset_ship(2)
	reset_level()
	level_progress.get_node("TextureProgressBar").value = 90 # set to zero
	waves_passed = 0
	score = 0
	hud.get_node("Hud_score/Label").text = str(score)
	modify_multiplier(0)
	
	core_game.get_child(-1).get_node('Planet/Halo').health = 3
	core_game.get_child(-1).get_node('Planet/Halo').visible = true
	core_game.get_child(-1).get_node('Planet/Halo/Halo_color').play("full_power")
	
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
			if (OS.get_keycode_string(event.key_label) + modifier) == str(Section1[focus][0]):
				update_bonus(100, 1) # set bar to 100%
				if multiplier < max_multiplier:
					modify_multiplier(1)
				score += 100 * multiplier
				hud.get_node("Hud_score/Label").text = str(score)
				all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(36, 217, 107))
				reset_ship(1)
				focus += 1
				for i in range(focus, Section1.size()):
					if Section1[i][-1] == 1:
						break
					else:
						focus += 1
						
				if focus != section_size:
					all_letters.get_child(focus).get_node("Label").add_theme_color_override("font_color", Color8(97, 203, 204))
				else:
					waves_passed += 25
					if level_progress.get_node("TextureProgressBar").value != 100:
						level_progress.get_node("TextureProgressBar").value = (float(waves_passed) / float(level_waves[-1]))*100
						reset_level()
					else:
						next_level_hud()
					
			else:
				modify_multiplier(0)
				update_bonus(100, 0) # set bar to 100% and turn red

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
		#print('dang it')
		multiplier = 1
		#hud.get_node("Hud_multiplier/Label").text = ""
		hud.get_node("Hud_multiplier/RichTextLabel").text = ""
		hud.get_node("Hud_multiplier/Label_shadow").text = ""
