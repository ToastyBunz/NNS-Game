extends Control
@onready var game = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/lv1_button.grab_focus()


func _on_lv_1_button_pressed():
	var this_level = "level_1"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_lv_2_button_pressed():
	var this_level = "level_2"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_lv_3_button_pressed():
	var this_level = "level_3"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()

func _on_lv_4_button_pressed():
	var this_level = "level_4"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_lv_5_button_pressed():
	var this_level = "level_5"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_lv_6_button_pressed():
	var this_level = "level_6"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_lv_7_button_pressed():
	var this_level = "level_7"
	var path = "res://levels_magazine/" + this_level + ".tscn"
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load(path).instantiate()
	level_child.name = this_level
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()


func _on_main_menu_pressed():
	var menu = load("res://scenes/menu.tscn").instantiate()
	game.add_child(menu)
	self.queue_free()
