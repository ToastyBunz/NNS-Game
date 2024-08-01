extends Label
@onready var sector_label = $"."

func new_sector(sector):
	sector_label.text = "Sector " + str(sector) 
