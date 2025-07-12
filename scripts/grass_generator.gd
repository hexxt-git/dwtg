extends Node2D

# Grass generation settings
const WORLD_SIZE = 5000.0
const GRASS_COUNT = 300  # Number of grass instances to spawn

# Grass scene reference
@export var grass_scene: PackedScene

# Grass placement settings
@export var grass_scale_min: float = 0.8
@export var grass_scale_max: float = 1
@export var grass_rotation_variation: float = 30.0  # Degrees

# Grass appearance settings
@export var grass_color: Color = Color(0.1, 0.4, 0.1, 0.3)  # Dark green with 70% opacity

# Grass container
@onready var grass_container = $GrassContainer

func _ready():
	# Load the grass scene if not set in editor
	if not grass_scene:
		grass_scene = preload("res://scenes/Grass.tscn")
	
	generate_grass()

func generate_grass():
	# Clear existing grass
	for child in grass_container.get_children():
		child.queue_free()
	
	# Generate random grass positions without overlap checking
	for i in range(GRASS_COUNT):
		var pos = Vector2(
			randf_range(-WORLD_SIZE/2, WORLD_SIZE/2),
			randf_range(-WORLD_SIZE/2, WORLD_SIZE/2)
		)
		create_grass_instance(pos)
	
	print("Generated ", GRASS_COUNT, " grass positions")

func create_grass_instance(bush_pos: Vector2):
	var grass_instance = grass_scene.instantiate()
	grass_instance.position = bush_pos
	
	# Random scale
	var scale_factor = randf_range(grass_scale_min, grass_scale_max)
	grass_instance.scale = Vector2(scale_factor, scale_factor)
	
	# Random rotation
	var random_rotation_degrees = randf_range(-grass_rotation_variation/2, grass_rotation_variation/2)
	grass_instance.rotation_degrees = random_rotation_degrees
	
	# Random z-index for layering (grass behind player)
	grass_instance.z_index = randi_range(-5, -1)
	
	# Apply dark color and transparency
	grass_instance.modulate = grass_color
	
	grass_container.add_child(grass_instance)

# Function to regenerate grass (useful for testing)
func regenerate_grass():
	generate_grass()
