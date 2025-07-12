extends Control

@onready var stats_container = $StatsContainer
@onready var money_label = $StatsContainer/MoneyLabel
@onready var bullets_label = $StatsContainer/BulletsLabel
@onready var timer_label = $StatsContainer/TimerLabel
@onready var kills_label = $StatsContainer/KillsLabel

func _ready():
	# Connect button signals
	$RestartButton.pressed.connect(_on_restart_button_pressed)
	$MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	
	# Display player stats
	display_stats()

func display_stats():
	var final_stats = get_tree().get_meta("final_stats", null)
	if final_stats:
		money_label.text = "Money Earned: $" + str(final_stats.current_money)
		bullets_label.text = "Bullets Used: " + str(final_stats.current_bullets)
		
		# Format play time
		var minutes = int(final_stats.play_time) / 60
		var seconds = int(final_stats.play_time) % 60
		timer_label.text = "Play Time: %02d:%02d" % [minutes, seconds]
		kills_label.text = "Kills: " + str(final_stats.kills)
		
	else:
		# Fallback if stats not found
		money_label.text = "Money Earned: $0"
		bullets_label.text = "Bullets Used: 0"
		timer_label.text = "Play Time: 00:00"
		kills_label.text = "Kills: 0"

func _on_restart_button_pressed():
	# Restart the game by changing to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_main_menu_button_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 