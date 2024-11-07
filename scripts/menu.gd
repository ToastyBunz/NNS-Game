extends Control
@onready var game = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	var start = load("res://scenes/core_game.tscn").instantiate()
	var level_child = load("res://levels_magazine/level_1.tscn").instantiate()
	level_child.name = "level_1"
	start.add_child(level_child)
	game.add_child(start)
	self.queue_free()

func _on_levels_button_pressed():
	var levels = load("res://scenes/level_menu.tscn").instantiate()
	game.add_child(levels)
	self.queue_free()

func _on_quit_button_pressed():
	get_tree().quit()
