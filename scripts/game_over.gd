extends Control

func _ready():
	# Connect button signals
	$RestartButton.pressed.connect(_on_restart_button_pressed)
	$MainMenuButton.pressed.connect(_on_main_menu_button_pressed)

func _on_restart_button_pressed():
	# Restart the game by changing to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_main_menu_button_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 