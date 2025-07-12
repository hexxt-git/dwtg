extends Sprite2D

func _ready():
	# Set the plant texture (using grass texture for now)
	var grass_texture = preload("res://assets/grass.png")
	texture = grass_texture
	
	# Set a green tint for the plant
	modulate = Color(0.3, 0.8, 0.3, 1.0)
	
	# Random rotation for variety
	rotation_degrees = randf_range(-15, 15)
	
	# Set z-index to be behind player but above grass
	z_index = -2 