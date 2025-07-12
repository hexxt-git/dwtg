extends Control

@onready var stats_container = $StatsContainer
@onready var money_label = $StatsContainer/MoneyLabel
@onready var bullets_label = $StatsContainer/BulletsLabel
@onready var timer_label = $StatsContainer/TimerLabel
@onready var kills_label = $StatsContainer/KillsLabel
@onready var difficulty_label = $StatsContainer/DifficultyLabel

func _ready():
	# Connect button signals
	$RestartButton.pressed.connect(_on_restart_button_pressed)
	$MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	
	# Display player stats
	display_stats()
	
	# Auto-submit score after 1 seconds
	get_tree().create_timer(1.0).timeout.connect(_auto_submit_score)

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
		difficulty_label.text = "Final Difficulty: %.1f" % final_stats.final_difficulty
		
	else:
		# Fallback if stats not found
		money_label.text = "Money Earned: $0"
		bullets_label.text = "Bullets Used: 0"
		timer_label.text = "Play Time: 00:00"
		kills_label.text = "Kills: 0"
		difficulty_label.text = "Final Difficulty: 0.0"

func _on_restart_button_pressed():
	# Restart the game by changing to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_main_menu_button_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _auto_submit_score():
	# Get player name from global settings
	var player_name = get_node("/root/GameSettings").get_player_name()
	if player_name == "":
		return  # No name set, skip submission
	
	# Prepare game stats for leaderboard
	var final_stats = get_tree().get_meta("final_stats", null)
	if final_stats:
		var game_stats = {
			"player_name": player_name,
			"money": final_stats.current_money,
			"kills": final_stats.kills,
			"play_time": int(final_stats.play_time),
			"difficulty": int(final_stats.final_difficulty)
		}
		get_tree().set_meta("leaderboard_stats", game_stats)
		
		# Submit score automatically
		submit_score_to_server(game_stats)

func submit_score_to_server(game_stats: Dictionary):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_score_submitted)
	
	var data = {
		"player_name": game_stats.player_name,
		"score": game_stats.money,
		"kills": game_stats.kills,
		"play_time": game_stats.play_time,
		"difficulty": game_stats.difficulty
	}
	
	var json_string = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	http_request.request("http://localhost:3000/api/leaderboard", headers, HTTPClient.METHOD_POST, json_string)

func _on_score_submitted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		print("Score submitted successfully!")
	else:
		print("Failed to submit score: ", response_code) 