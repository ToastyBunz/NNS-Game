extends CanvasLayer

signal restartLevel

@onready var game = $".."

func _ready():
	self.hide()

func _on_retry_button_pressed():
	get_tree().paused = false 
	self.hide()
	emit_signal("restartLevel", 0 , 1)

func _on_retreat_button_pressed():
	get_tree().paused = false 
	get_tree().reload_current_scene()


func game_over_hud():
	get_tree().paused = true
	self.show()





