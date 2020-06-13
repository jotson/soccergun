extends KinematicBody2D

var KICK_SPEED = 300
var FRICTION = 30
var OWNER = null

var velocity = Vector2()


func _ready():
	Game.Ball = self


func _physics_process(delta):
	move_and_slide(velocity)
	
	# Collision check
	if get_slide_count():
		var collision = get_slide_collision(0)
		var normal = collision.normal
		velocity = velocity.bounce(normal) * 0.8
		
		if collision.collider.is_in_group("player"):
			OWNER = collision.collider
			
	# Ball friction
	velocity *= (1 - FRICTION / 1000.0)

	# Stick to feet of owner
	if OWNER:
		position = OWNER.position + Vector2(20,0).rotated(OWNER.rotation)
		velocity = Vector2.ZERO
	
	
# Kick the ball
func kick(angle, v):
	velocity = Vector2(1,0).rotated(angle) * KICK_SPEED + v
	OWNER = null
