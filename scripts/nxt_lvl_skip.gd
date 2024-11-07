extends Node2D

signal skip

func _on_skp_pressed():
	print('skip')
	emit_signal('skip')
