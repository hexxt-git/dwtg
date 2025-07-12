extends Label

var velocity = Vector2(0, -50)  # Move upward
var lifetime = 2.0  # How long the particle lives
var timer = 0.0

func _ready():
	# Set up the label properties
	add_theme_font_size_override("font_size", 24)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_shadow_color", Color.BLACK)
	add_theme_constant_override("shadow_offset_x", 1)
	add_theme_constant_override("shadow_offset_y", 1)

func _process(delta):
	timer += delta
	
	# Move the particle
	position += velocity * delta
	
	# Fade out over time
	var alpha = 1.0 - (timer / lifetime)
	modulate.a = alpha
	
	# Remove when lifetime is up
	if timer >= lifetime:
		queue_free()

func set_resource_type(resource_type: String, amount: int, is_positive: bool):
	# Set the text
	var sign = "+" if is_positive else "-"
	text = sign + str(amount) + " " + resource_type
	
	# Set color based on resource type
	var color
	match resource_type:
		"seed":
			color = Color(0.8, 0.6, 0.2)  # Brown
		"water":
			color = Color(0.2, 0.4, 0.8)  # Blue
		"plant":
			color = Color(0.2, 0.8, 0.2)  # Green
		"rock":
			color = Color(0.6, 0.6, 0.6)  # Gray
		"iron":
			color = Color(0.4, 0.4, 0.4)  # Dark Gray
		"money":
			color = Color(0.8, 0.8, 0.2)  # Yellow
		"bullet":
			color = Color(0.8, 0.2, 0.2)  # Red
		_:
			color = Color.WHITE
	
	# Make negative values red
	if not is_positive:
		color = Color.RED
	
	add_theme_color_override("font_color", color) 