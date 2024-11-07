extends RayCast2D

@onready var line_2d = $Line2D  # Reference to Line2D

var is_casting = false

func _ready():
	# Ensure RayCast2D is enabled and set physics to inactive initially
	set_physics_process(false)
	enabled = true
	# Set initial points for Line2D
	line_2d.clear_points()
	line_2d.add_point(Vector2.ZERO)  # Start point
	line_2d.add_point(Vector2.ZERO)  # End point

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		# When mouse is clicked, start casting
		update_is_casting(true)
	elif event is InputEventMouseButton and not event.pressed:
		# When mouse is released, stop casting
		update_is_casting(false)

func update_is_casting(cast: bool):
	is_casting = cast
	
	if is_casting:
		appear()
	else:
		disappear()

	set_physics_process(is_casting)

func _physics_process(delta):
	# Assuming 'target_position' is defined and holds a valid position
	var cast_point = global_position + Vector2.RIGHT * 200  # Replace with correct logic
	
	force_raycast_update()  # Update raycast to check for collisions
	
	if is_colliding():
		cast_point = get_collision_point()  # Get where the raycast hit
	else:
		cast_point = global_position + Vector2.RIGHT * 200  # Ray goes to the right
	
	# Update Line2D points (from start to end of ray)
	line_2d.set_point_position(0, global_position)  # Ray starts at the RayCast2D position
	line_2d.set_point_position(1, cast_point)  # Ray ends at collision point or default range

func appear():
	# Make the line visible by setting appropriate width
	line_2d.width = 10.0  # Set to visible width

func disappear():
	# Make the line disappear by setting width to 0
	line_2d.width = 0.0
