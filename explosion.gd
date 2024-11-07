extends Node2D
@onready var small_particles = $small_particles
@onready var white_smoke = $white_smoke
@onready var orange_smoke = $orange_smoke
@onready var grey_smoke = $grey_smoke
@onready var explosion = $"."

var grav = -150

var speed = 100  # Speed at which the explosion slides to the left
var duration = 1.0  # Duration of the explosion in seconds
var time_passed = 0.0  # Track how long the explosion has been playing
var sliding = false  # Track whether the explosion is sliding


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func set_gravity(value):
		small_particles.gravity.x = value
		white_smoke.gravity.x = value
		orange_smoke.gravity.x = value
		grey_smoke.gravity.x = value
		
func set_direction(value):
	small_particles.direction.x = value
	white_smoke.direction.x = value
	orange_smoke.direction.x = value
	grey_smoke.direction.x = value

func ship_explosion(boom_position: Vector2, direction):
	if direction == 1:
		set_gravity(grav)
		set_direction(-1)
	else:
		set_gravity(0)
		set_direction(1)
		
	
	# if hit sheild need to set gravity in opposite direction
	explosion.position = boom_position
	small_particles.emitting = true
	white_smoke.emitting = true
	orange_smoke.emitting = true
	grey_smoke.emitting = true
	
	
