extends CharacterBody2D

const SPEED = 150.0  # Slower than player
const BOB_AMPLITUDE = 5.0  # How high the bobbing goes
const BOB_FREQUENCY = 20.0   # How fast the bobbing is
const VERTICAL_FLIP_INTERVAL = 0.3  # 300ms in seconds
const MAX_HP = 15
const KNOCKBACK_FORCE = 400.0
const KNOCKBACK_DURATION = 0.3

@onready var sprite = $Sprite2D
@onready var player = get_node("../../../player")

var time_passed = 0.0
var original_sprite_y = 0.0
var vertical_flip_timer = 0.0
var actual_facing_right = false  # Track actual facing direction
var visual_flip = false  # Track visual flip separately

# Health and damage variables
var current_hp = MAX_HP
var is_knockback = false
var knockback_timer = 0.0
var knockback_direction = Vector2.ZERO
var knockback_force = KNOCKBACK_FORCE  # Default knockback force

func _ready():
	# Store the original Y position of the sprite for bobbing
	original_sprite_y = sprite.position.y
	
	# Add to enemy group
	add_to_group("enemies")
	
	# Ensure collision detection is working
	collision_layer = 4
	collision_mask = 3

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	# Calculate direction to player
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Handle sprite flipping based on movement direction
	var movement_angle = abs(atan2(direction_to_player.y, direction_to_player.x))
	var is_mostly_vertical = movement_angle > (PI/2 - deg_to_rad(15)) and movement_angle < (PI/2 + deg_to_rad(15))
	
	if abs(direction_to_player.x) > 0.1:  # Significant horizontal movement
		# Horizontal movement - update actual facing direction and visual flip
		if direction_to_player.x > 0:
			actual_facing_right = true  # Facing right
			visual_flip = true
		elif direction_to_player.x < 0:
			actual_facing_right = false   # Facing left
			visual_flip = false
		vertical_flip_timer = 0.0  # Reset vertical flip timer
	elif is_mostly_vertical:
		# Very vertical movement (within 5 degrees) - only change visual flip, keep actual direction
		vertical_flip_timer += delta
		if vertical_flip_timer >= VERTICAL_FLIP_INTERVAL:
			visual_flip = !visual_flip  # Toggle visual flip only
			vertical_flip_timer = 0.0  # Reset timer
	else:
		# Not moving or diagonal movement - reset visual flip to match actual direction
		visual_flip = actual_facing_right
		vertical_flip_timer = 0.0
	
	# Apply visual flip to sprite
	sprite.flip_h = visual_flip
	
	# Handle knockback
	if is_knockback:
		knockback_timer += delta
		if knockback_timer < 0.2:
			sprite.modulate = Color(1, 0, 0, 0.5)
		else:
			sprite.modulate = Color(1, 0, 0, 1)
		if knockback_timer >= KNOCKBACK_DURATION:
			is_knockback = false
			knockback_timer = 0.0
		else:
			# Apply knockback movement
			velocity = knockback_direction * knockback_force
			move_and_slide()
			return
	
	# Apply movement toward player
	velocity = direction_to_player * SPEED
	move_and_slide()
	
	# Bobbing animation when moving
	if direction_to_player.length() > 0:
		time_passed += delta
		var bob_offset = sin(time_passed * BOB_FREQUENCY) * BOB_AMPLITUDE
		sprite.position.y = original_sprite_y + bob_offset
	else:
		# Reset sprite position when not moving
		sprite.position.y = original_sprite_y
		time_passed = 0.0

func take_damage(damage: int, bullet_direction: Vector2):
	current_hp -= damage
	print("Enemy took ", damage, " damage. HP: ", current_hp)
	
	# Apply knockback in the direction the bullet was traveling
	knockback_direction = bullet_direction.normalized()
	is_knockback = true
	knockback_timer = 0.0
	
	# Check if enemy is dead
	if current_hp <= 0:
		die()

func apply_knockback(direction: Vector2, force: float):
	# Apply knockback in the specified direction with custom force
	knockback_direction = direction.normalized()
	knockback_force = force  # Use the passed force parameter
	is_knockback = true
	knockback_timer = 0.0

func die():
	print("Enemy died!")
	queue_free() 
