extends Control

const SERVER_URL = "https://dwtg.onrender.com"

@onready var leaderboard_list = $VBoxContainer/ScrollContainer/LeaderboardList
@onready var loading_label = $VBoxContainer/LoadingLabel
@onready var back_button = $VBoxContainer/BackButton

var http_request: HTTPRequest

func _ready():
	# Create HTTP request node
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Connect buttons
	back_button.pressed.connect(_on_back_pressed)
	
	# Load leaderboard on start
	fetch_leaderboard()



func fetch_leaderboard():
	show_loading("Loading leaderboard...")
	http_request.request(SERVER_URL + "/api/leaderboard?limit=10")

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	hide_loading()
	
	if response_code != 200:
		show_message("Error: " + str(response_code))
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		show_message("Error parsing response")
		return
	
	var response = json.data
	
	if response.has("success") and response.success:
		# Leaderboard data response
		update_leaderboard_display(response.data)
	else:
		show_message("Server error: " + str(response.get("error", "Unknown error")))

func update_leaderboard_display(leaderboard_data: Array):
	# Clear existing items
	for child in leaderboard_list.get_children():
		child.queue_free()
	
	if leaderboard_data.is_empty():
		var no_data_label = Label.new()
		no_data_label.text = "No scores yet. Be the first!"
		no_data_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		leaderboard_list.add_child(no_data_label)
		return
	
	# Add header
	var header = create_leaderboard_entry("Rank", "Player", "Score", "Kills", "Time", "Diff", true)
	leaderboard_list.add_child(header)
	
	# Add separator
	var separator = HSeparator.new()
	leaderboard_list.add_child(separator)
	
	# Add entries
	for i in range(leaderboard_data.size()):
		var entry = leaderboard_data[i]
		var rank = str(i + 1)
		var player_name = entry.player_name
		var score = str(entry.score)
		var kills = str(entry.kills)
		var time = format_time(entry.play_time)
		var difficulty = str(entry.difficulty)
		
		var entry_control = create_leaderboard_entry(rank, player_name, score, kills, time, difficulty, false)
		leaderboard_list.add_child(entry_control)

func create_leaderboard_entry(rank: String, player: String, score: String, kills: String, time: String, diff: String, is_header: bool) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	
	# Add background for alternating rows
	if not is_header:
		var bg = ColorRect.new()
		bg.color = Color(0.2, 0.2, 0.25, 0.3) if int(rank) % 2 == 0 else Color(0.15, 0.15, 0.2, 0.3)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.add_child(bg)
		bg.move_to_front()
		bg.z_index = -1
	
	var rank_label = Label.new()
	rank_label.text = rank
	rank_label.custom_minimum_size.x = 60
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		rank_label.add_theme_font_size_override("font_size", 16)
		rank_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		rank_label.add_theme_font_size_override("font_size", 14)
		# Highlight top 3
		if int(rank) <= 3:
			var colors = [Color.GOLD, Color.SILVER, Color(0.8, 0.5, 0.2)]  # Gold, Silver, Bronze
			rank_label.add_theme_color_override("font_color", colors[int(rank) - 1])
	hbox.add_child(rank_label)
	
	var player_label = Label.new()
	player_label.text = player
	player_label.custom_minimum_size.x = 150
	player_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if is_header:
		player_label.add_theme_font_size_override("font_size", 16)
		player_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		player_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(player_label)
	
	var score_label = Label.new()
	score_label.text = score
	score_label.custom_minimum_size.x = 100
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		score_label.add_theme_font_size_override("font_size", 16)
		score_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		score_label.add_theme_font_size_override("font_size", 14)
		score_label.add_theme_color_override("font_color", Color.GREEN)
	hbox.add_child(score_label)
	
	var kills_label = Label.new()
	kills_label.text = kills
	kills_label.custom_minimum_size.x = 80
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		kills_label.add_theme_font_size_override("font_size", 16)
		kills_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		kills_label.add_theme_font_size_override("font_size", 14)
		kills_label.add_theme_color_override("font_color", Color.RED)
	hbox.add_child(kills_label)
	
	var time_label = Label.new()
	time_label.text = time
	time_label.custom_minimum_size.x = 80
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		time_label.add_theme_font_size_override("font_size", 16)
		time_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		time_label.add_theme_font_size_override("font_size", 14)
		time_label.add_theme_color_override("font_color", Color.CYAN)
	hbox.add_child(time_label)
	
	var diff_label = Label.new()
	diff_label.text = diff
	diff_label.custom_minimum_size.x = 60
	diff_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		diff_label.add_theme_font_size_override("font_size", 16)
		diff_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		diff_label.add_theme_font_size_override("font_size", 14)
		diff_label.add_theme_color_override("font_color", Color.ORANGE)
	hbox.add_child(diff_label)
	
	return hbox

func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func show_loading(message: String):
	loading_label.text = message
	loading_label.visible = true

func hide_loading():
	loading_label.visible = false

func show_message(message: String):
	# You can implement a proper message dialog here
	print("Message: ", message)
	loading_label.text = message
	loading_label.visible = true
	
	# Color code messages
	if "success" in message.to_lower() or "submitted" in message.to_lower():
		loading_label.add_theme_color_override("font_color", Color.GREEN)
	elif "error" in message.to_lower():
		loading_label.add_theme_color_override("font_color", Color.RED)
	else:
		loading_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Hide message after 3 seconds
	get_tree().create_timer(3.0).timeout.connect(func(): loading_label.visible = false)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 
