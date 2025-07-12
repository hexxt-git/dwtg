extends Control

@onready var health_bar = $HealthBar
@onready var health_fill = $HealthBar/Fill
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Make sure the HUD is always on top
	z_index = 100

func _process(_delta):
		var health_percentage = float(player.current_hp) / float(player.MAX_HP)
		health_fill.size.x = health_bar.size.x * health_percentage