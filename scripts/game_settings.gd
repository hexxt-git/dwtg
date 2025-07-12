extends Node

var player_name: String = ""

func _ready():
	# Load saved player name
	load_player_name()

func set_player_name(name: String):
	player_name = name
	save_player_name()

func get_player_name() -> String:
	return player_name

func save_player_name():
	var save_file = FileAccess.open("user://player_name.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(player_name)
		save_file.close()

func load_player_name():
	if FileAccess.file_exists("user://player_name.save"):
		var save_file = FileAccess.open("user://player_name.save", FileAccess.READ)
		if save_file:
			player_name = save_file.get_as_text().strip_edges()
			save_file.close() 