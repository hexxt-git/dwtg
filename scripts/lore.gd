extends Control

func _ready():
	# Connect the back button signal
	$BackButton.pressed.connect(_on_back_button_pressed)
 
func _on_back_button_pressed():
	# Return to the main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 