extends KinematicBody2D

var KICK_SPEED = 300
var FRICTION = 30

var velocity = Vector2()


func _ready():
	pass


func _physics_process(delta):
	move_and_slide(velocity)
	
	velocity *= (1 - FRICTION / 1000.0)

	# Collision check
	if get_slide_count():
		var collision = get_slide_collision(0)
		var normal = collision.normal
		velocity = velocity.bounce(normal) * 0.8
	
	
func kick(direction : Vector2, v : Vector2 = Vector2.ZERO):
	velocity = direction.normalized() * KICK_SPEED + v
