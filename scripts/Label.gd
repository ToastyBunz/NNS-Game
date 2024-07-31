extends Label
@onready var sector_label = $"."

var score = 0

func new_sector(sector):
	sector_label.text = "Sector " + str(sector) 
