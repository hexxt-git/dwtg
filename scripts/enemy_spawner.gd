extends Node2D

const SPAWN_INTERVAL = 3  # Time between spawns
const SPAWN_DISTANCE = 600.0  # Distance from player to spawn enemies
const MAX_ENEMIES = 20  # Maximum number of enemies at once

@export var enemy_scene: PackedScene

@onready var player = get_node("../player")
@onready var enemy_container = $EnemyContainer

var spawn_timer = 0.0

func _ready():
	# Load the enemy scene if not set in editor
	if not enemy_scene:
		enemy_scene = preload("res://scenes/Enemy.tscn")

func _process(delta):
	if not player:
		print('no player')
		return
	
	# Update spawn timer
	spawn_timer += delta
	
	# Check if we should spawn an enemy
	if spawn_timer >= SPAWN_INTERVAL:
		# Check if we haven't reached max enemies
		var current_enemy_count = enemy_container.get_child_count()
		if current_enemy_count < MAX_ENEMIES:
			spawn_enemy()
		
		spawn_timer = 0.0

func spawn_enemy():
	# Get random angle around the player
	var random_angle = randf() * 2 * PI
	
	# Calculate spawn position
	var spawn_direction = Vector2(cos(random_angle), sin(random_angle))
	var spawn_position = player.global_position + (spawn_direction * SPAWN_DISTANCE)
	
	# Create enemy instance
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	enemy_container.add_child(enemy)
	
	print("Spawned enemy at: ", spawn_position) 
