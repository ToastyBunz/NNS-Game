extends Node2D

@onready var interval_game = $planets
@onready var halo = $Planet/Halo
@onready var background = $Background
@onready var hud = $Hud


const ALPHABET = ["A", "B", "C", "D", "E", "F", "G"]
var Section1 = []
var focus = 0
var planet = 0
var Wscreen = 1152
var Hscreen = 648

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
	print(Section1[focus])
	interval_game.get_child(planet).get_node("Halo").get_node("HaloSprite").visible = true
	
	# organize the planets on the appropriate x, y 
	for j in range(7):
		# hight gose inversly
		# need to set hight based on what interval it is
		var width = round((Wscreen - 30) / 7 * j) + 100
		var hight = round((Hscreen - 30) / 7 * (7 - j)) - 30
		interval_game.get_child(j).position = Vector2(width, hight)
		
		#draw horizontal lines
		var line = Line2D.new()
		line.points = [Vector2(0, hight), Vector2(get_viewport().size.x, hight)]
		line.width = 2
		line.default_color = Color(1, 1, 1)  # White color

		background.add_child(line)
		hud.get_node("Sector_Label").new_sector(Section1[focus])
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
	
func reset_level():
	for planet_tile in range(7):
		interval_game.get_child(planet_tile).get_node("Halo").get_node("HaloSprite").play("WhiteRing")
		if planet_tile != 0:
			interval_game.get_child(planet_tile).get_node("Halo").get_node("HaloSprite").visible = false
		
	planet = 0
	focus = 0
	new_rand()
	prep()
	
	hud.get_node("Sector_Label").new_sector(Section1[focus])
	

func _unhandled_input(event):
	if focus == 7:
		focus = 0
	if event is InputEventKey:
		if event.pressed: 
			if OS.get_keycode_string(event.key_label) == Section1[focus]:
				print('great job!')
				interval_game.get_child(planet).get_node("Halo").get_node("HaloSprite").play("GreenRing")
				focus += 1
				planet += 1
				if planet != 7:
					interval_game.get_child(planet).get_node("Halo").get_node("HaloSprite").visible = true
			else:
				print('dang it')
				interval_game.get_child(planet).get_node("Halo").get_node("HaloSprite").play("RedRing")
			print(focus, planet)
			if focus == 7:
				reset_level()
#
#func _input(event):
	#print(event)
