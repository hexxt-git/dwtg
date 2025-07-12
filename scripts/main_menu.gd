extends Control

func _ready():
	# Connect button signals
	$StartButton.pressed.connect(_on_start_button_pressed)
	$ExitButton.pressed.connect(_on_exit_button_pressed)
	$LoreButton.pressed.connect(_on_lore_button_pressed)

func _on_start_button_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_exit_button_pressed():
	# Exit the game
	get_tree().quit() 

func _on_lore_button_pressed():
	# Change to the lore scene
	get_tree().change_scene_to_file("res://scenes/Lore.tscn") 
