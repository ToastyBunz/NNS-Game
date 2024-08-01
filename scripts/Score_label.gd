extends Label
@onready var score_label = $"."

var score = Global.score

func new_score(level):
	score_label.text = "Score: " + str(level) 
