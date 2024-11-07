extends Node2D

#signal on_transition_finished

@onready var color_rect = $CanvasLayer/ColorRect
@onready var animation_player = $CanvasLayer/AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.connect("animation_finished", _on_animation_finished)

func _on_timer_timeout():
	color_rect.visible = true
	animation_player.play("fade_black")

func _on_animation_finished(anim_name):
	if anim_name == "fade_black":
		main_menu()

func main_menu():
	get_tree().paused = false 
	get_tree().reload_current_scene()
