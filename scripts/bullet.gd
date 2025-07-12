extends Area2D

const SPEED = 500.0
const LIFETIME = 3.0  # How long the bullet exists before being destroyed

var velocity = Vector2.ZERO
var lifetime_timer = 0.0

func _ready():
	# Connect the body_entered signal to handle collisions
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Move the bullet
	position += velocity * delta
	
	# Update lifetime timer
	lifetime_timer += delta
	if lifetime_timer >= LIFETIME:
		queue_free()

func initialize(start_position: Vector2, direction: Vector2):
	position = start_position
	velocity = direction.normalized() * SPEED

func _on_body_entered(body):
	# Handle collision with other bodies
	if body.has_method("take_damage"):
		body.take_damage(5, velocity)  # Pass damage amount and bullet direction
	
	# Destroy the bullet on collision
	queue_free() 