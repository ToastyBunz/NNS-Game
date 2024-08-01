''' LV2 has only one random planet selected'''

extends Node2D
##@onready var halo = $Planet/Halo

@onready var interval_game = $"../.."
@onready var hud = $Hud
@onready var planets = $Planets
@onready var background = $Interval_Background

var level = 3
const ALPHABET = ["A", "B", "C", "D", "E", "F", "G"]
var Section1 = []
var focus = 0
var planet = 0
var Wscreen = 1152
var Hscreen = 648
var crew = 0
var full_ship = 3
var score = Global.score
var points = 10

var random_int = 0
var rand_planets = 0
var active_planets = []

	

func prep():
	Section1 = []
	random_int = randi_range(0, 6)
	var preletters = []
	for i in range(len(ALPHABET)):
		if i < random_int:
			preletters.append(ALPHABET[i])
		else:
			Section1.append( ALPHABET[i])
			
	Section1.append_array(preletters)
	print('section 1', Section1)
	return Section1
	
# ADDED x
func get_planets(num_planets, total_planets):
	active_planets = []
	var y = len(total_planets) - 1
	for i in num_planets:
		var z = randi_range(0, y)
		if z not in active_planets:
			active_planets.append(z)
		y = y - 1
	print('act', active_planets)
	active_planets
	return active_planets

# ADD Y
	
func solar_size():
	rand_planets = randi_range(1, 6)
	
	
func planet_height():
	var width = 0
	for j in range(7):
		if j in active_planets:
			var loc = active_planets.find(j)
			print('loc', loc)
			width = round((Wscreen - 30) / 7 * loc) + 100
		else:
			width = round((Wscreen - 30) / 7 * j) + 100
		
		var hight = round((Hscreen - 30) / 7 * (7 - j)) - 30
		planets.get_child(j).position = Vector2(width, hight)
	
	
## Called when the node enters the scene tree for the first time.
func _ready():
	hud.get_node("level_label").this_level(level)
	print('GALAXY 2')
	Section1 = prep()
	solar_size()
	active_planets = get_planets(rand_planets, Section1)
	active_planets
	for planet_tile in range(7):
		if planet_tile not in active_planets:
			planets.get_child(planet_tile).visible = false
			
	planets.get_child(active_planets[0]).get_node("Halo").get_node("HaloSprite").visible = true
	
	# organize the planets on the appropriate x, y 
	
	# hight gose inversly
	# need to set hight based on what interval it is
	
	#XXXXXXXXXXXXXXXX
	planet_height()

	for i in range(7):
		#draw horizontal lines
		var line = Line2D.new()
		var hight = round((Hscreen - 30) / 7 * (7 - i)) - 30
		line.points = [Vector2(0, hight), Vector2(get_viewport().size.x, hight)]
		line.width = 2
		line.default_color = Color(1, 1, 1)  # White color

		background.add_child(line)
		hud.get_node("Sector_Label").new_sector(Section1[focus])
		
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	

func reset_level():
	planet = 0
	focus = 0
	random_int = randi_range(0, 6)
	prep()
	solar_size()
	get_planets(rand_planets, Section1)
	hud.get_node("Sector_Label").new_sector(Section1[0])
	
	planet_height()
	
	for planet_tile in range(7):
		if planet_tile not in active_planets:
			planets.get_child(planet_tile).visible = false
		else:
			planets.get_child(planet_tile).visible = true
			planets.get_child(planet_tile).get_node("Halo").get_node("HaloSprite").play("WhiteRing")
			planets.get_child(planet_tile).get_node("Halo").get_node("HaloSprite").visible = false
	
	planets.get_child(active_planets[0]).get_node("Halo").get_node("HaloSprite").visible = true
	
	

func _unhandled_input(event):
	if focus == len(active_planets):
		focus = 0
	if event is InputEventKey:
		if event.pressed: 
			if OS.get_keycode_string(event.key_label) == Section1[active_planets[focus]]:
				print('great job!')
				planets.get_child(active_planets[planet]).get_node("Halo").get_node("HaloSprite").play("GreenRing")
				focus += 1
				planet += 1
				if planet != len(active_planets):
					planets.get_child(active_planets[planet]).get_node("Halo").get_node("HaloSprite").visible = true
			else:
				print('dang it')
				planets.get_child(active_planets[planet]).get_node("Halo").get_node("HaloSprite").play("RedRing")
				print('pressed',OS.get_keycode_string(event.key_label))
				print('correct', Section1[active_planets[focus]])
				print('correct', active_planets[focus])
			if focus == len(active_planets):
				print('round2')
				crew += 1
				
				Global.add_points(points)
				if crew == full_ship:
					next_level()
					crew = 0
				# activate animation
				reset_level()
#

func next_level():
	const FILE_START = "res://interval_levels/level_"
	var current_scene_file = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_file.to_int() + 1
	var next_level_path = FILE_START + str(next_level_number) + ".tscn"
	
	get_tree().change_scene_to_file(next_level_path)
