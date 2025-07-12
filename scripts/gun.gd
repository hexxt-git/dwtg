extends Sprite2D

# Resting positions based on player facing direction
const RESTING_POSITION_RIGHT = Vector2(70, 0)
const RESTING_POSITION_LEFT = Vector2(-70, 0)
const TARGET_OFFSET = 40.0  # Offset when targeting

# Reference to the player to check facing direction
@onready var player: CharacterBody2D = get_parent()

# Bullet scene to instantiate
var bullet_scene = preload("res://scenes/Bullet.tscn")

# Shooting variables
var can_shoot = true
var shoot_cooldown = 0.333  # Time between shots
var base_cooldown = 0.333  # Base cooldown for calculations
var shoot_timer = 0.0
var mouse_was_pressed = false
var shot_queued = false  # Track if a shot was requested during cooldown
var auto_fire_timer = 0.0  # Timer for auto-fire when holding

func _ready() -> void:
	# Set initial position
	position = get_resting_position()

func _process(delta: float) -> void:
	# Get mouse position in world coordinates
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().global_position
	
	# Calculate direction from player to mouse
	var direction_to_mouse = -(mouse_pos - player_pos)
	
	# Calculate angle using atan2
	var target_angle = atan2(direction_to_mouse.y, direction_to_mouse.x)
	
	# Update gun rotation
	rotation = target_angle
	
	# Flip gun sprite based on direction
	# If angle is between -pi/2 and pi/2, the gun is pointing left, so flip it
	if target_angle >= -PI/2 and target_angle <= PI/2:
		flip_v = false
	else:
		flip_v = true
	
	# Get base resting position
	var base_position = get_resting_position()
	
	# Apply offset when targeting
	var offset_direction = Vector2(cos(target_angle), sin(target_angle)) * TARGET_OFFSET
	position = base_position - offset_direction
	
	# Handle shooting
	handle_shooting(delta, target_angle + PI, mouse_pos)

func get_resting_position() -> Vector2:
	# Check if player is facing right or left based on actual direction
	if player.actual_facing_right:
		# Player is facing right
		return RESTING_POSITION_RIGHT
	else:
		# Player is facing left
		return RESTING_POSITION_LEFT

func handle_shooting(delta: float, target_angle: float, mouse_pos: Vector2	):
	# Check if player has bullets
	var player = get_parent()
	if not player or not player.has_method("can_shoot") or not player.can_shoot():
		return  # Can't shoot without bullets
	
	# Update shoot timer
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= shoot_cooldown:
			can_shoot = true
			shoot_timer = 0.0
			
			# If a shot was queued during cooldown, fire it now
			if shot_queued:
				shoot_bullet(target_angle, mouse_pos)
				shot_queued = false
	
	# Check for mouse input
	var mouse_is_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_just_pressed = mouse_is_pressed and not mouse_was_pressed
	
	# Handle shooting
	if mouse_just_pressed:
		if can_shoot:
			# Can shoot immediately
			shoot_bullet(target_angle, mouse_pos)
		else:
			# Queue the shot for when cooldown ends
			shot_queued = true
	
	# Handle continuous firing while holding
	if mouse_is_pressed:
		auto_fire_timer += delta
		if auto_fire_timer >= shoot_cooldown and can_shoot:
			shoot_bullet(target_angle, mouse_pos)
			auto_fire_timer = 0.0
	else:
		# Reset auto-fire timer when not holding
		auto_fire_timer = 0.0
	
	# Update mouse state for next frame
	mouse_was_pressed = mouse_is_pressed

func update_fire_rate(multiplier: float):
	shoot_cooldown = base_cooldown / multiplier
	print("Fire rate updated! New cooldown: ", shoot_cooldown)

func shoot_bullet(target_angle: float, mouse_pos: Vector2):
	# Check if player can use a bullet
	var player = get_parent()
	if not player or not player.has_method("use_bullet") or not player.use_bullet():
		return  # Can't shoot without bullets
	
	# Calculate bullet spawn position from the gun tip
	var bullet_spawn_pos = global_position + Vector2(cos(target_angle), sin(target_angle)) * 50
	
	# Calculate bullet direction
	var bullet_direction = (mouse_pos - bullet_spawn_pos).normalized()
	
	# Create bullet instance
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	# Initialize the bullet
	bullet.initialize(bullet_spawn_pos, bullet_direction)
	
	# Set cooldown
	can_shoot = false
