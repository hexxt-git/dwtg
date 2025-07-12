extends Area2D

@export var resource_type: String = "seed"  # "seed", "water", "plant", or "money"
@export var collection_rate: float = 1.0  # Resources per second
@export var max_capacity: int = 100  # Maximum resources this zone can provide
@export var requires_seeds: int = 0  # Seeds required per collection
@export var requires_water: int = 0  # Water required per collection
@export var requires_plants: int = 0  # Plants required per collection
@export var requires_money: int = 0  # Money required per collection
@export var is_multi_recipe: bool = false  # If true, supports multiple recipes

var current_capacity: int
var player_in_zone: bool = false
var collection_timer: float = 0.0
var collection_interval: float = 1.0  # Collect every second

func _ready():
	# Set initial capacity
	current_capacity = max_capacity
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set collision layers to detect player
	collision_layer = 0
	collision_mask = 1  # Collide with player (layer 1)
	
	# Update visual appearance
	update_visual_appearance()

func update_visual_appearance():
	var capacity_percentage = float(current_capacity) / float(max_capacity)
	var color_rect = get_node_or_null("ColorRect")
	var label = get_node_or_null("Label")
	
	if color_rect:
		var base_color
		if is_multi_recipe:
			base_color = Color(0.8, 0.8, 0.2, 0.3)  # Yellow for selling zone
		else:
			match resource_type:
				"seed":
					base_color = Color(0.8, 0.6, 0.2, 0.3)
				"water":
					base_color = Color(0.2, 0.4, 0.8, 0.3)
				"plant":
					base_color = Color(0.2, 0.8, 0.2, 0.3)
				"money":
					base_color = Color(0.8, 0.8, 0.2, 0.3)
				"bullet":
					base_color = Color(0.8, 0.2, 0.2, 0.3)
				_:
					base_color = Color(0.6, 0.6, 0.6, 0.3)
		
		if current_capacity <= 0:
			color_rect.color = Color(0.3, 0.3, 0.3, 0.3)  # Gray when depleted
		else:
			color_rect.color = Color(base_color.r, base_color.g * capacity_percentage, base_color.b * capacity_percentage, base_color.a)
	
	if label:
		var zone_name
		if is_multi_recipe:
			zone_name = "Selling Zone"
		else:
			zone_name = resource_type.capitalize() + " Zone"
		
		if current_capacity <= 0:
			label.text = zone_name + " (Depleted)"
		else:
			label.text = zone_name

func _process(delta):
	if player_in_zone and current_capacity > 0:
		collection_timer += delta
		if collection_timer >= collection_interval:
			collect_resource()
			collection_timer = 0.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true
		print("Player entered ", resource_type, " collection zone")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
		print("Player exited ", resource_type, " collection zone")

func collect_resource():
	if current_capacity > 0:
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
					sold_something = true
					print("Sold 1 plant for 40 money")
				
				# Recipe 2: Sell seeds for 5 money
				elif player_seeds >= 1:
					player.add_resource("seed", -1)
					player.add_resource("money", 5)
					sold_something = true
					print("Sold 1 seed for 5 money")
				
				# Recipe 3: Sell water for 5 money
				elif player_water >= 1:
					player.add_resource("water", -1)
					player.add_resource("money", 5)
					sold_something = true
					print("Sold 1 water for 5 money")
				
				if sold_something:
					current_capacity -= 1
					update_visual_appearance()
				else:
					print("Nothing to sell! Need plants, seeds, or water")
			else:
				# Single recipe zone - original logic
				if player_seeds >= requires_seeds and player_water >= requires_water and player_plants >= requires_plants and player_money >= requires_money:
					# Consume required resources
					if requires_seeds > 0:
						player.add_resource("seed", -requires_seeds)
					if requires_water > 0:
						player.add_resource("water", -requires_water)
					if requires_plants > 0:
						player.add_resource("plant", -requires_plants)
					if requires_money > 0:
						player.add_resource("money", -requires_money)
					
					# Add the target resource
					if player.has_method("add_resource"):
						player.add_resource(resource_type, int(collection_rate))
					
					current_capacity -= int(collection_rate)
					
					# Update visual appearance
					update_visual_appearance()
					
					var requirement_text = ""
					if requires_seeds > 0:
						requirement_text += str(requires_seeds) + " seeds "
					if requires_water > 0:
						requirement_text += str(requires_water) + " water "
					if requires_plants > 0:
						requirement_text += str(requires_plants) + " plants "
					if requires_money > 0:
						requirement_text += str(requires_money) + " money "
					
					print("Converted ", requirement_text, "to ", int(collection_rate), " ", resource_type, ". Remaining: ", current_capacity)
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