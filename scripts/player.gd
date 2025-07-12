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
@onready var name_label = $NameLabel
var time_passed = 0.0
var original_sprite_y = 0.0
var vertical_flip_timer = 0.0
var actual_facing_right = false  # Track actual facing direction for gun
var visual_flip = false  # Track visual flip separately

# Health variables
var current_hp = MAX_HP
var is_invincible = false
var invincibility_timer = 0.0

# Resource variables
var seeds = 0
var water = 0
const MAX_SEEDS = 100
const MAX_WATER = 100

# Money and plants
var money = 0
var plants = 0

# Rocks and iron
var rocks = 0
var iron = 0
const MAX_ROCKS = 50
const MAX_IRON = 20

# Bullets
var bullets = 50
const MAX_BULLETS = 200

# Statistics tracking
var total_money_earned = 0
var total_bullets_used = 0
var total_seeds_collected = 0
var total_water_collected = 0
var total_rocks_collected = 0
var total_iron_collected = 0

# Timer and kill tracking
var play_time = 0.0
var kills = 0

# Difficulty system
var difficulty = 0.0
const DIFFICULTY_INCREMENT = 0.1  # Increase by 0.1 each second

# Upgrade system
var fire_rate_multiplier = 1.0
var damage_bonus = 0
var speed_multiplier = 1.0

func _ready():
	# Store the original Y position of the sprite for bobbing
	original_sprite_y = sprite.position.y
	
	# Add to player group for enemies to find
	add_to_group("player")
	
	# Set collision layers for enemy detection
	collision_layer = 1
	collision_mask = 4  # Collide with enemies (layer 4)
	
	# Set player name from global settings
	var player_name = get_node("/root/GameSettings").get_player_name()
	if player_name != "":
		name_label.text = player_name
	else:
		name_label.text = "Player"

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
	
	# Apply movement with speed multiplier
	velocity = input_vector * SPEED * speed_multiplier
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
	
	# Update play time
	play_time += delta
	
	# Update difficulty
	difficulty += DIFFICULTY_INCREMENT * delta

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

func add_resource(resource_type: String, amount: int):
	match resource_type:
		"seed":
			seeds = max(0, min(seeds + amount, MAX_SEEDS))
			if amount > 0:
				total_seeds_collected += amount
			print("Added ", amount, " seeds. Total: ", seeds)
		"water":
			water = max(0, min(water + amount, MAX_WATER))
			if amount > 0:
				total_water_collected += amount
			print("Added ", amount, " water. Total: ", water)
		"plant":
			plants = max(0, plants + amount)
			print("Added ", amount, " plants. Total: ", plants)
		"money":
			money = max(0, money + amount)
			if amount > 0:
				total_money_earned += amount
			print("Added ", amount, " money. Total: ", money)
		"rock":
			rocks = max(0, min(rocks + amount, MAX_ROCKS))
			if amount > 0:
				total_rocks_collected += amount
			print("Added ", amount, " rocks. Total: ", rocks)
		"iron":
			iron = max(0, min(iron + amount, MAX_IRON))
			if amount > 0:
				total_iron_collected += amount
			print("Added ", amount, " iron. Total: ", iron)
		"bullet":
			bullets = max(0, min(bullets + amount, MAX_BULLETS))
			print("Added ", amount, " bullets. Total: ", bullets)

func get_resource(resource_type: String) -> int:
	match resource_type:
		"seed":
			return seeds
		"water":
			return water
		"plant":
			return plants
		"money":
			return money
		"rock":
			return rocks
		"iron":
			return iron
		"bullet":
			return bullets
		_:
			return 0

func can_shoot() -> bool:
	return bullets > 0

func use_bullet():
	if bullets > 0:
		bullets -= 1
		total_bullets_used += 1
		print("Used 1 bullet. Remaining: ", bullets)
		return true
	return false

func purchase_upgrade(upgrade_type: String, value: float, cost: int) -> bool:
	if money < cost:
		return false
	
	match upgrade_type:
		"fire_rate":
			fire_rate_multiplier += value
			print("Fire rate upgraded! New multiplier: ", fire_rate_multiplier)
		"damage":
			damage_bonus += int(value)
			print("Damage upgraded! New bonus: ", damage_bonus)
		"speed":
			speed_multiplier += value
			print("Speed upgraded! New multiplier: ", speed_multiplier)
		_:
			print("Unknown upgrade type: ", upgrade_type)
			return false
	
	# Consume money
	add_resource("money", -cost)
	
	# Update gun if it exists
	var gun = get_node_or_null("Gun")
	if gun and gun.has_method("update_fire_rate"):
		gun.update_fire_rate(fire_rate_multiplier)
	
	return true

func get_damage_bonus() -> int:
	return damage_bonus

func get_max_resource(resource_type: String) -> int:
	match resource_type:
		"seed":
			return MAX_SEEDS
		"water":
			return MAX_WATER
		"rock":
			return MAX_ROCKS
		"iron":
			return MAX_IRON
		_:
			return 0

func add_kill():
	kills += 1
	print("Kill added! Total kills: ", kills)

func get_difficulty() -> float:
	return difficulty



func die():
	print("Player died!")
	
	# Store final stats before scene change
	var final_stats = {
		"current_money": money,
		"current_plants": plants,
		"current_seeds": seeds,
		"current_water": water,
		"current_rocks": rocks,
		"current_iron": iron,
		"current_bullets": bullets,
		"kills": kills,
		"play_time": play_time,
		"final_difficulty": difficulty
	}
	
	# Store stats in autoload or global variable
	get_tree().set_meta("final_stats", final_stats)
	
	set_process(false)
	set_physics_process(false)
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
