extends Area2D

@export var resource_type: String = "seed"  # "seed", "water", "plant", or "money"
@export var collection_rate: float = 1.0  # Resources per second
@export var requires_seeds: int = 0  # Seeds required per collection
@export var requires_water: int = 0  # Water required per collection
@export var requires_plants: int = 0  # Plants required per collection
@export var requires_money: int = 0  # Money required per collection
@export var is_multi_recipe: bool = false  # If true, supports multiple recipes

var player_in_zone: bool = false
var collection_timer: float = 0.0
var collection_interval: float = 1.0  # Collect every second

# Particle system for resource changes
var particle_scene = preload("res://scenes/ResourceParticle.tscn")

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set collision layers to detect player
	collision_layer = 0
	collision_mask = 1  # Collide with player (layer 1)
	
	# Update visual appearance
	update_visual_appearance()

func update_visual_appearance():
	var sprite = get_node_or_null("Sprite2D")
	var label = get_node_or_null("Label")
	
	if sprite:
		# Always show normal appearance when not in zone
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	if label:
		var zone_name
		if is_multi_recipe:
			zone_name = "Selling Zone"
		else:
			zone_name = resource_type.capitalize() + " Zone"
		
		label.text = zone_name

func check_player_can_use() -> bool:
	# Check if player has required resources
	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.has_method("get_resource"):
		return false
	
	var player_seeds = player.get_resource("seed")
	var player_water = player.get_resource("water")
	var player_plants = player.get_resource("plant")
	var player_money = player.get_resource("money")
	
	if is_multi_recipe:
		# For selling zone, check if player has anything to sell
		return player_plants >= 1 or player_seeds >= 1 or player_water >= 1
	else:
		# For other zones, check if player has required resources
		return player_seeds >= requires_seeds and player_water >= requires_water and player_plants >= requires_plants and player_money >= requires_money

func update_visual_appearance_for_player(can_use: bool):
	var sprite = get_node_or_null("Sprite2D")
	
	if sprite:
		if not can_use:
			# Make sprite gray when player can't use it
			sprite.modulate = Color(0.3, 0.3, 0.3, 0.5)
		else:
			# Normal appearance
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _process(delta):
	if player_in_zone:
		# Check if player has required resources
		var can_use = check_player_can_use()
		
		# Update visual based on whether player can use it
		update_visual_appearance_for_player(can_use)
		
		if can_use:
			collection_timer += delta
			if collection_timer >= collection_interval:
				collect_resource()
				collection_timer = 0.0
	else:
		# Player not in zone, show normal state
		update_visual_appearance()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true
		print("Player entered ", resource_type, " collection zone")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
		print("Player exited ", resource_type, " collection zone")

func collect_resource():
	# Find the player and check requirements
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_resource"):
		var player_seeds = player.get_resource("seed")
		var player_water = player.get_resource("water")
		var player_plants = player.get_resource("plant")
		var player_money = player.get_resource("money")
		
		if is_multi_recipe:
			# Multi-recipe selling zone - try different recipes
			var sold_something = false
			
			# Recipe 1: Sell plants for 40 money
			if player_plants >= 1:
				player.add_resource("plant", -1)
				player.add_resource("money", 40)
				create_resource_particle("plant", 1, false)  # -1 plant
				create_resource_particle("money", 40, true)  # +40 money
				sold_something = true
				print("Sold 1 plant for 40 money")
			
			# Recipe 2: Sell seeds for 5 money
			elif player_seeds >= 1:
				player.add_resource("seed", -1)
				player.add_resource("money", 5)
				create_resource_particle("seed", 1, false)  # -1 seed
				create_resource_particle("money", 5, true)  # +5 money
				sold_something = true
				print("Sold 1 seed for 5 money")
			
			# Recipe 3: Sell water for 5 money
			elif player_water >= 1:
				player.add_resource("water", -1)
				player.add_resource("money", 5)
				create_resource_particle("water", 1, false)  # -1 water
				create_resource_particle("money", 5, true)  # +5 money
				sold_something = true
				print("Sold 1 water for 5 money")
			
			if not sold_something:
				print("Nothing to sell! Need plants, seeds, or water")
		else:
			# Single recipe zone - original logic
			if player_seeds >= requires_seeds and player_water >= requires_water and player_plants >= requires_plants and player_money >= requires_money:
				# Consume required resources
				if requires_seeds > 0:
					player.add_resource("seed", -requires_seeds)
					create_resource_particle("seed", requires_seeds, false)  # -seeds
				if requires_water > 0:
					player.add_resource("water", -requires_water)
					create_resource_particle("water", requires_water, false)  # -water
				if requires_plants > 0:
					player.add_resource("plant", -requires_plants)
					create_resource_particle("plant", requires_plants, false)  # -plants
				if requires_money > 0:
					player.add_resource("money", -requires_money)
					create_resource_particle("money", requires_money, false)  # -money
				
				# Add the target resource
				if player.has_method("add_resource"):
					player.add_resource(resource_type, int(collection_rate))
					create_resource_particle(resource_type, int(collection_rate), true)  # +resource
				
				var requirement_text = ""
				if requires_seeds > 0:
					requirement_text += str(requires_seeds) + " seeds "
				if requires_water > 0:
					requirement_text += str(requires_water) + " water "
				if requires_plants > 0:
					requirement_text += str(requires_plants) + " plants "
				if requires_money > 0:
					requirement_text += str(requires_money) + " money "
				
				print("Converted ", requirement_text, "to ", int(collection_rate), " ", resource_type)
			else:
				var requirement_text = ""
				if requires_seeds > 0:
					requirement_text += str(requires_seeds) + " seeds "
				if requires_water > 0:
					requirement_text += str(requires_water) + " water "
				if requires_plants > 0:
					requirement_text += str(requires_plants) + " plants "
				if requires_money > 0:
					requirement_text += str(requires_money) + " money "
				
				print("Need ", requirement_text, "to collect ", resource_type)

func create_resource_particle(resource_type: String, amount: int, is_positive: bool):
	# Create a new particle instance
	var particle = particle_scene.instantiate()
	
	# Add it to the current scene
	get_tree().current_scene.add_child(particle)
	
	# Position it at the station location with small random offset and fixed shift
	var random_x = randf_range(-10, 10)
	var random_y = randf_range(-30, 30)
	
	# Add fixed shift based on positive/negative
	var fixed_x = 0
	
	if is_positive:
		fixed_x = 50  # Positive particles go to the right
	else:
		fixed_x = -50  # Negative particles go to the left
	
	particle.global_position = global_position + Vector2(random_x + fixed_x, random_y)
	
	# Set up the particle
	particle.set_resource_type(resource_type, amount, is_positive) 
