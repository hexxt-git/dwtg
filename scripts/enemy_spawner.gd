extends Node2D

const BASE_SPAWN_INTERVAL = 4.0  # Time between spawns at difficulty 0
const MIN_SPAWN_INTERVAL = 0.1  # Minimum time between spawns (10 per second at difficulty 100)
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
	
	# Get current difficulty from player
	var difficulty = 0.0
	if player.has_method("get_difficulty"):
		difficulty = player.get_difficulty()
	
	# Calculate spawn interval based on difficulty
	var spawn_interval = calculate_spawn_interval(difficulty)
	
	# Update spawn timer
	spawn_timer += delta
	
	# Check if we should spawn an enemy
	if spawn_timer >= spawn_interval:
		# Check if we haven't reached max enemies
		var current_enemy_count = enemy_container.get_child_count()
		if current_enemy_count < MAX_ENEMIES:
			spawn_enemy()
		
		spawn_timer = 0.0

func calculate_spawn_interval(difficulty: float) -> float:
	# Linear interpolation from BASE_SPAWN_INTERVAL to MIN_SPAWN_INTERVAL
	# At difficulty 0: BASE_SPAWN_INTERVAL (4.0 seconds)
	# At difficulty 100: MIN_SPAWN_INTERVAL (0.1 seconds = 10 per second)
	# you reach 100 at 1000 seconds (16.666666666666668 minutes)
	var t = min(difficulty / 100.0, 1.0)  # Clamp to 0-1 range
	return lerp(BASE_SPAWN_INTERVAL, MIN_SPAWN_INTERVAL, t)

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
