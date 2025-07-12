extends Control

@onready var stats_container = $StatsContainer
@onready var money_label = $StatsContainer/MoneyLabel
@onready var plants_label = $StatsContainer/PlantsLabel
@onready var bullets_label = $StatsContainer/BulletsLabel
@onready var seeds_label = $StatsContainer/SeedsLabel
@onready var water_label = $StatsContainer/WaterLabel

func _ready():
	# Connect button signals
	$RestartButton.pressed.connect(_on_restart_button_pressed)
	$MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	
	# Display player stats
	display_stats()

func display_stats():
	var final_stats = get_tree().get_meta("final_stats", null)
	if final_stats:
		money_label.text = "Total Money Earned: $" + str(final_stats.total_money_earned)
		plants_label.text = "Total Plants Grown: " + str(final_stats.total_plants_grown)
		bullets_label.text = "Bullets Used: " + str(final_stats.total_bullets_used)
		seeds_label.text = "Total Seeds Collected: " + str(final_stats.total_seeds_collected)
		water_label.text = "Total Water Collected: " + str(final_stats.total_water_collected)
		
		# Calculate total value (current inventory + total earnings)
		var current_value = final_stats.current_money + (final_stats.current_plants * 40) + (final_stats.current_seeds * 5) + (final_stats.current_water * 5) + (final_stats.current_bullets * 0.2)
		var total_value = final_stats.total_money_earned + current_value
		$StatsContainer/TotalValueLabel.text = "Total Value (Score): $" + str(int(total_value))
	else:
		# Fallback if stats not found
		money_label.text = "Total Money Earned: $0"
		plants_label.text = "Total Plants Grown: 0"
		bullets_label.text = "Bullets Used: 0"
		seeds_label.text = "Total Seeds Collected: 0"
		water_label.text = "Total Water Collected: 0"
		$StatsContainer/TotalValueLabel.text = "Total Value (Score): $0"

func _on_restart_button_pressed():
	# Restart the game by changing to the game scene
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_main_menu_button_pressed():
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn") 