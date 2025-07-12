extends Control

@onready var health_bar = $HealthBar
@onready var health_fill = $HealthBar/Fill
@onready var seed_bar = $SeedBar
@onready var seed_fill = $SeedBar/Fill
@onready var seed_label = $SeedBar/Label
@onready var water_bar = $WaterBar
@onready var water_fill = $WaterBar/Fill
@onready var water_label = $WaterBar/Label
@onready var rock_bar = $RockBar
@onready var rock_fill = $RockBar/Fill
@onready var rock_label = $RockBar/Label
@onready var iron_label = $IronLabel
@onready var money_label = $MoneyLabel
@onready var plants_label = $PlantsLabel
@onready var bullet_bar = $BulletBar
@onready var bullet_fill = $BulletBar/Fill
@onready var bullet_label = $BulletBar/Label
@onready var timer_label = $TimerLabel
@onready var kills_label = $KillsLabel
@onready var difficulty_label = $DifficultyLabel
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Make sure the HUD is always on top
	z_index = 100

func _process(_delta):
	if player:
		# Update health bar
		var health_percentage = float(player.current_hp) / float(player.MAX_HP)
		health_fill.size.x = health_bar.size.x * health_percentage
		
		# Update seed bar
		var seed_percentage = float(player.seeds) / float(player.MAX_SEEDS)
		seed_fill.size.x = seed_bar.size.x * seed_percentage
		seed_label.text = "Seeds: " + str(player.seeds) + "/" + str(player.MAX_SEEDS)
		
		# Update water bar
		var water_percentage = float(player.water) / float(player.MAX_WATER)
		water_fill.size.x = water_bar.size.x * water_percentage
		water_label.text = "Water: " + str(player.water) + "/" + str(player.MAX_WATER)
		
		# Update rock bar
		var rock_percentage = float(player.rocks) / float(player.MAX_ROCKS)
		rock_fill.size.x = rock_bar.size.x * rock_percentage
		rock_label.text = "Rocks: " + str(player.rocks) + "/" + str(player.MAX_ROCKS)
		
		# Update iron label
		iron_label.text = "Iron: " + str(player.iron)
		
		# Update money and plants
		money_label.text = "Money: $" + str(player.money)
		plants_label.text = "Plants: " + str(player.plants)
		
		# Update bullet bar
		var bullet_percentage = float(player.bullets) / float(player.MAX_BULLETS)
		bullet_fill.size.x = bullet_bar.size.x * bullet_percentage
		bullet_label.text = "Bullets: " + str(player.bullets) + "/" + str(player.MAX_BULLETS)
		
		# Update timer and kills
		var minutes = int(player.play_time) / 60
		var seconds = int(player.play_time) % 60
		timer_label.text = "Time: %02d:%02d" % [minutes, seconds]
		kills_label.text = "Kills: " + str(player.kills)
		
		# Update difficulty
		difficulty_label.text = "Difficulty: %.1f" % player.difficulty
