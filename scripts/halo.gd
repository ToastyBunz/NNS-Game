extends CharacterBody2D

@export var health: int = 3  # Set initial health
@onready var halo = $"."

@onready var halo_color = $Halo_color  # Reference to AnimatedSprite2D
@onready var shield_impact = $Shield_impact  # Reference to Area2D

signal levelOver
signal enemyAttack

#func _ready():
	# Connect the body_entered signal of Shield_impact (Area2D) to this script
	#shield_impact.body_entered.connect(Callable(self, "on_shield_impact_body_entered"))

func _on_shield_impact_body_entered(body):
	health -= 1

	if health == 2:
		halo_color.play("damaged")
		emit_signal("enemyAttack")
	elif health == 1:
		halo.visible = false
		emit_signal("enemyAttack")
	else:
		emit_signal("levelOver")

	return health
	#pass # Replace with function body.
