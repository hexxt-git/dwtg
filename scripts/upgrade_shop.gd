extends Area2D

@export var upgrade_type: String = "fire_rate"  # "fire_rate", "damage", "speed"
@export var upgrade_cost: int = 70
@export var upgrade_value: float = 0.1  # 10% for fire rate, 5 for damage, 0.1 for speed

var player_in_zone: bool = false
var can_purchase: bool = true

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set collision layers to detect player
	collision_layer = 0
	collision_mask = 1  # Collide with player (layer 1)
	
	# Update visual appearance
	update_visual_appearance()

func _input(event):
	if event.is_action_pressed("interact") and player_in_zone and can_purchase:
		attempt_purchase()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_zone = true
		print("Player entered upgrade shop")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_zone = false
		print("Player exited upgrade shop")

func attempt_purchase():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_resource"):
		var player_money = player.get_resource("money")
		
		if player_money >= upgrade_cost:
			# Check if player can receive the upgrade
			if player.has_method("purchase_upgrade"):
				var success = player.purchase_upgrade(upgrade_type, upgrade_value, upgrade_cost)
				if success:
					print("Purchased ", upgrade_type, " upgrade for ", upgrade_cost, " money!")
					# Visual feedback
					flash_zone()
				else:
					print("Upgrade not available or already maxed!")
			else:
				print("Player doesn't support upgrades!")
		else:
			print("Need ", upgrade_cost, " money to purchase ", upgrade_type, " upgrade!")

func flash_zone():
	var color_rect = get_node_or_null("ColorRect")
	if color_rect:
		# Flash green to indicate successful purchase
		var original_color = color_rect.color
		color_rect.color = Color(0, 1, 0, 0.8)
		
		# Reset color after 0.5 seconds
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		color_rect.color = original_color

func update_visual_appearance():
	var color_rect = get_node_or_null("ColorRect")
	var label = get_node_or_null("Label")
	
	if color_rect:
		var base_color = Color(0.6, 0.2, 0.8, 0.3)  # Purple for upgrade zones
		color_rect.color = base_color
	
	if label:
		var upgrade_name = upgrade_type.replace("_", " ").capitalize()
		label.text = upgrade_name + " Upgrade\nCost: $" + str(upgrade_cost) + "\nPress E" 
