extends Label
@onready var sector_label = $"."

func this_level(level):
	sector_label.text = "Sector " + str(level) 
