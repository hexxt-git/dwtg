extends Node2D

# Bush generation settings
const WORLD_SIZE = 5000.0
const BORDER_WIDTH = 900.0  # Width of the border area for bushes
const BUSH_SPACING = 40.0
const BUSH_SPACING_VARIATION = 20.0  # Random variation in spacing

# Bush scene reference
@export var bush_scene: PackedScene

# Bush placement settings
@export var bush_scale_min: float = 0.9
@export var bush_scale_max: float = 1.1
@export var bush_rotation_variation: float = 25.0  # Degrees

# Bush container
@onready var bush_container = $BushContainer

func _ready():
	# Load the bush scene if not set in editor
	if not bush_scene:
		bush_scene = preload("res://scenes/Bush.tscn")
	
	generate_border_bushes()

func generate_border_bushes():
	# Clear existing bushes
	for child in bush_container.get_children():
		child.queue_free()
	
	# Generate bushes along the four borders
	generate_border_line(Vector2(-WORLD_SIZE/2, -WORLD_SIZE/2), Vector2(WORLD_SIZE/2, -WORLD_SIZE/2), "top")    # Top border
	generate_border_line(Vector2(WORLD_SIZE/2, -WORLD_SIZE/2), Vector2(WORLD_SIZE/2, WORLD_SIZE/2), "right")   # Right border
	generate_border_line(Vector2(WORLD_SIZE/2, WORLD_SIZE/2), Vector2(-WORLD_SIZE/2, WORLD_SIZE/2), "bottom") # Bottom border
	generate_border_line(Vector2(-WORLD_SIZE/2, WORLD_SIZE/2), Vector2(-WORLD_SIZE/2, -WORLD_SIZE/2), "left")  # Left border
	
	print("Generated border bushes")

func generate_border_line(start_pos: Vector2, end_pos: Vector2, _border_name: String):
	var direction = (end_pos - start_pos).normalized()
	var current_pos = start_pos
	
	while current_pos.distance_to(end_pos) > BUSH_SPACING:
		# Add random variation to position in both axes
		var random_offset = Vector2(
			randf_range(-BORDER_WIDTH/2, BORDER_WIDTH/2),
			randf_range(-BORDER_WIDTH/2, BORDER_WIDTH/2)
		)
		
		var bush_pos = current_pos + random_offset
		create_bush_instance(bush_pos)
		
		# Move to next position with random spacing
		var spacing = BUSH_SPACING + randf_range(-BUSH_SPACING_VARIATION, BUSH_SPACING_VARIATION)
		current_pos += direction * spacing

func create_bush_instance(bush_pos: Vector2):
	var bush_instance = bush_scene.instantiate()
	bush_instance.position = bush_pos
	
	# Random scale
	var scale_factor = randf_range(bush_scale_min, bush_scale_max)
	bush_instance.scale = Vector2(scale_factor, scale_factor)
	
	# Random rotation
	var random_rotation_degrees = randf_range(-bush_rotation_variation/2, bush_rotation_variation/2)
	bush_instance.rotation_degrees = random_rotation_degrees
	
	# Random z-index for layering
	bush_instance.z_index = randi_range(1, 5)
	
	bush_container.add_child(bush_instance)

# Function to regenerate bushes (useful for testing)
func regenerate_bushes():
	generate_border_bushes()
