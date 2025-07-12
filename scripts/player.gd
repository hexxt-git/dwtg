extends CharacterBody2D

const SPEED = 300.0
const BOB_AMPLITUDE = 5.0  # How high the bobbing goes
const BOB_FREQUENCY = 20.0   # How fast the bobbing is
const VERTICAL_FLIP_INTERVAL = 0.3  # 300ms in seconds
const MAX_HP = 100
const ENEMY_DAMAGE = 20
const KNOCKBACK_RADIUS = 500.0
const KNOCKBACK_FORCE = 800.0
const INVINCIBILITY_DURATION = 3.0

@onready var sprite = $Sprite2D
var time_passed = 0.0
var original_sprite_y = 0.0
var vertical_flip_timer = 0.0
var actual_facing_right = false  # Track actual facing direction for gun
var visual_flip = false  # Track visual flip separately

# Health variables
var current_hp = MAX_HP
var is_invincible = false
var invincibility_timer = 0.0

func _ready():
	# Store the original Y position of the sprite for bobbing
	original_sprite_y = sprite.position.y
	
	# Add to player group for enemies to find
	add_to_group("player")
	
	# Set collision layers for enemy detection
	collision_layer = 1
	collision_mask = 4  # Collide with enemies (layer 4)

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	input_vector = input_vector.normalized()
	
	# Handle sprite flipping
	if input_vector.x != 0:
		# Horizontal movement - update actual facing direction and visual flip
		if input_vector.x > 0:
			actual_facing_right = true  # Facing right
			visual_flip = true
		elif input_vector.x < 0:
			actual_facing_right = false   # Facing left
			visual_flip = false
		vertical_flip_timer = 0.0  # Reset vertical flip timer
	elif input_vector.y != 0:
		# Vertical movement only - only change visual flip, keep actual direction
		vertical_flip_timer += delta
		if vertical_flip_timer >= VERTICAL_FLIP_INTERVAL:
			visual_flip = !visual_flip  # Toggle visual flip only
			vertical_flip_timer = 0.0  # Reset timer
	else:
		# Not moving - reset visual flip to match actual direction
		visual_flip = actual_facing_right
		vertical_flip_timer = 0.0
	
	# Apply visual flip to sprite
	sprite.flip_h = visual_flip
	
	# Apply movement
	velocity = input_vector * SPEED
	move_and_slide()
	
	# Check for enemy collisions
	check_enemy_collisions()
	
	# Update invincibility timer and flashing effect
	if is_invincible:
		invincibility_timer += delta
		if invincibility_timer >= INVINCIBILITY_DURATION:
			is_invincible = false
			invincibility_timer = 0.0
			# Make sure sprite is visible when invincibility ends
			sprite.modulate = Color.WHITE
		else:
			# Flash the sprite while invincible (every 0.1 seconds)
			var flash_alpha = 1.0 if int(invincibility_timer * 7) % 2 == 0 else 0.5
			sprite.modulate = Color(1, 1, 1, flash_alpha)
	
	# Bobbing animation when moving
	if input_vector.length() > 0:
		time_passed += delta
		var bob_offset = sin(time_passed * BOB_FREQUENCY) * BOB_AMPLITUDE
		sprite.position.y = original_sprite_y + bob_offset
	else:
		# Reset sprite position when not moving
		sprite.position.y = original_sprite_y
		time_passed = 0.0

func check_enemy_collisions():
	# Only check for collisions if not invincible
	if is_invincible:
		return
		
	# Get all overlapping bodies
	var overlapping_bodies = get_slide_collision_count()
	for i in range(overlapping_bodies):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		# Check if the colliding body is an enemy
		if body and body.is_in_group("enemies"):
			var does_die = take_damage(ENEMY_DAMAGE)
			if does_die:
				return
			# Knock back all nearby enemies
			knockback_nearby_enemies()
			# Make player invincible
			is_invincible = true
			invincibility_timer = 0.0

func take_damage(damage: int):
	current_hp -= damage
	print("Player took ", damage, " damage. HP: ", current_hp)
	
	# Check if player is dead
	if current_hp <= 0:
		die()
		return true
	return false

func knockback_nearby_enemies():
	# Get all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Calculate distance to enemy
		var distance = global_position.distance_to(enemy.global_position)
		
		# If enemy is within knockback radius
		if distance <= KNOCKBACK_RADIUS:
			# Calculate knockback direction (away from player)
			var knockback_direction = (enemy.global_position - global_position).normalized()
			
			# Apply knockback to enemy
			if enemy.has_method("apply_knockback"):
				enemy.apply_knockback(knockback_direction, KNOCKBACK_FORCE)

func die():
	print("Player died!")
	set_process(false)
	set_physics_process(false)
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
