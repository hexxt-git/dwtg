extends Control

@onready var player_name_input = $PlayerNameInput
@onready var player_name_label = $PlayerNameLabel
@onready var start_button = $StartButton

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	$ExitButton.pressed.connect(_on_exit_button_pressed)
	$LoreButton.pressed.connect(_on_lore_button_pressed)
	$LeaderboardButton.pressed.connect(_on_leaderboard_button_pressed)
	
	# Load saved player name
	var saved_name = get_node("/root/GameSettings").get_player_name()
	if saved_name != "":
		player_name_input.text = saved_name
		player_name_label.text = "Player: " + saved_name
		start_button.disabled = false
	else:
		player_name_label.text = "Player: "
		start_button.disabled = true
	
	# Connect name input
	player_name_input.text_changed.connect(_on_name_changed)

func _on_start_button_pressed():
	# Change to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_exit_button_pressed():
	# Exit the game
	get_tree().quit() 

func _on_lore_button_pressed():
	# Change to the lore scene
	get_tree().change_scene_to_file("res://scenes/Lore.tscn")

func _on_leaderboard_button_pressed():
	# Clear any existing leaderboard stats (viewing mode)
	get_tree().set_meta("leaderboard_stats", {})
	# Change to the leaderboard scene
	get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")

func _on_name_changed(new_text: String):
	var trimmed_name = new_text.strip_edges()
	
	# Save player name globally
	get_node("/root/GameSettings").set_player_name(trimmed_name)
	
	# Update label
	if trimmed_name.length() > 0:
		player_name_label.text = "Player: " + trimmed_name
	else:
		player_name_label.text = "Player: "
	
	# Enable/disable start button based on name
	start_button.disabled = trimmed_name.length() == 0 
