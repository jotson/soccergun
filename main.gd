extends Node2D

var SPEED = 200
var has_ball = false


func _ready():
	pass


func _physics_process(delta):
	# Gamepad input
	var move_h = Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_v = Input.get_action_strength("down") - Input.get_action_strength("up")
	var move = Vector2(move_h, move_v) * SPEED
	
	if move.length():
		$player.rotation = move.angle()
	
	# Move
	var velocity = $player.move_and_slide(move)
	
	# Collision check
	for i in $player.get_slide_count():
		var collision = $player.get_slide_collision(i)
		prints("Collided", collision.collider.name)
		if collision.collider.name == 'ball':
			has_ball = true

	if has_ball:
		$ball.position = $player.position + Vector2(20,0).rotated($player.rotation)
	
	if has_ball and Input.is_action_pressed("kick"):
		has_ball = false
		$ball.kick(Vector2(1,0).rotated($player.rotation), velocity)
		
