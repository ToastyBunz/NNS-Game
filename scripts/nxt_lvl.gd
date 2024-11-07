extends CanvasLayer

signal changeLevel
signal restartLv

func _ready():
	self.hide()

func _on_retry_button_pressed():
	get_tree().paused = false 
	self.hide()
	emit_signal("restartLv", 0, 0)

func _on_continue_button_pressed():
	emit_signal("changeLevel")
	self.hide()


func next_level_hud():
	get_tree().paused = true
	self.show()








