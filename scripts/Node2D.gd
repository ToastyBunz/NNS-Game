extends Node2D

signal noteModifier

# Variables to store the start and end positions of the drag
var start_position: Vector2
var end_position: Vector2
var dragging: bool = false
var frame_count = 0

# References to the sprites
@onready var node_2d = $Node2D
@onready var tri_dim = $Node2D/tri_dim
@onready var tri_min = $Node2D/tri_min


func _ready():
	# Initially hide both sprites
	tri_dim.hide()
	tri_min.hide()

func _input(event):
	# Detect left mouse button press to start dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging and record the start position
			start_position = event.position
			dragging = true
			node_2d.position = start_position
			
		else:
			# End dragging, hide both sprites
			dragging = false
			tri_dim.hide()
			tri_min.hide()
			emit_signal("noteModifier", "")  # Emit empty signal on release

func mouse_collection(delta):
	if dragging:
		frame_count += 1
		if frame_count >= 10:  # Every 10 frames
			end_position = get_global_mouse_position()
			var diff_position = start_position - end_position
			
			# Check the drag direction and show the corresponding sprite
			if diff_position.x > 10:
				tri_min.show()
				tri_dim.hide()
				emit_signal("noteModifier", "m")
			elif diff_position.x < -10:
				tri_dim.show()
				tri_min.hide()
				emit_signal("noteModifier", "d")
			else:
				tri_min.hide()
				tri_dim.hide()  # Hide both if the movement is minimal
				emit_signal("noteModifier", "")

			frame_count = 0

func _process(delta):
	mouse_collection(delta)
