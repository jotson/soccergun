extends KinematicBody2D

var AI = "player"
var SPEED = 200
var BALL_SLOW = 0.8
var TEAM = 1 setget set_team
var PASS_TARGET = []
var DEFENSE_TARGET = []
var GUN_TARGET = []

var move = Vector2()


func _ready():
	pass


func set_team(value):
	TEAM = value
	if TEAM == 2:
		modulate = Color(0, 1, 0)
	

func _physics_process(delta):
	update()
	
	if $hurtCooldown.is_stopped():
		# Allow movement
		modulate.a = 1
		
		if AI == "human":
			get_human_input()
			
		if AI == "passer":
			ai_passer(delta)
			
		if AI == "striker":
			ai_striker(delta)
	else:
		# Flash while recovering from being shot and stop movement
		modulate.a = randf()
		move = Vector2()
	
	
func _draw():
	draw_line(Vector2(10, -10), Vector2(300, -50), Color("#22ffffff"))
	draw_line(Vector2(10, 10), Vector2(300, 50), Color("#22ffffff"))
		

# Stationary passer AI
func ai_passer(delta : float):
	# Aim towards a human controlled player on my team
	for player in get_tree().get_nodes_in_group('player'):
		if player.TEAM == TEAM and player.AI == "human":
			rotation = (player.position - position).angle()
			break

	# Pass the ball if I have it			
	if Game.Ball.OWNER == self:
		if rand_range(0, 1000) < 5:
			Game.Ball.kick(rotation, Vector2.ZERO)


func ai_striker(delta : float):
	# I do have the ball
	# Keep away from the other team!
	if Game.Ball.OWNER == self:
		if rand_range(0, 1000) < 20:
			var direction = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
			move = direction * SPEED * BALL_SLOW
			
		if rand_range(0, 1000) < 10:
			Game.Ball.kick(rotation, Vector2.ZERO)
		
	# I don't have the ball!
	# Go towards the ball!
	if Game.Ball.OWNER != self:
		var direction = (Game.Ball.position - position).normalized()
		move = direction * SPEED
		
	var velocity = move_and_slide(move * 0.5)
	if get_slide_count():
		var collision = get_slide_collision(0)
		if collision.collider.name == "walls":
			var normal = collision.normal
			velocity = velocity.bounce(normal)
			move = velocity
		
	rotation = move.angle()
		
	
# Human controlled input
func get_human_input():
	# Gamepad input
	var move_h = Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_v = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	move = Vector2(move_h, move_v) * SPEED
	if Game.Ball.OWNER == self:
		move *= BALL_SLOW
		
	# Rotate to input direction
	if move.length():
		rotation = move.angle()
	
	# Move
	var velocity = move_and_slide(move)

	# Kick	
	if Game.Ball.OWNER == self and Input.is_action_pressed("kick"):
		if PASS_TARGET.size():
			# Auto-aim
			# Kick to the first pass target
			var angle = (PASS_TARGET[0].position - position).angle()
			Game.Ball.kick(angle, Vector2(velocity.length(), 0).rotated(angle))
		else:
			# Otherwise just kick the ball forward
			Game.Ball.kick(rotation, velocity)
			
	# Shoot gun
	if Input.is_action_pressed("shoot_gun"):
		shoot()


# Shoot the gun
func shoot():
	# Do nothing if reloading
	if not $reloadTimer.is_stopped():
		return
		
	# Start reload timer
	$reloadTimer.start()
	
	for player in GUN_TARGET:
		if player.has_method("hurt"):
			player.hurt()
		
	
# Player was just shot!	
func hurt():
	# Do nothing if already shot
	if not $hurtCooldown.is_stopped():
		return
		
	# Start the hurt cooldown
	$hurtCooldown.start()
	

func _on_hurtCooldown_timeout():
	pass # Replace with function body.

	
func _on_reloadTimer_timeout():
	pass # Replace with function body.


# Auto-aim
# Keep track of teammates who I can pass the ball to
func _on_passArea_body_entered(body):
	if body != self and body.get("TEAM") and body.TEAM == TEAM and not PASS_TARGET.has(body):
		PASS_TARGET.append(body)


# Auto-aim
# Remove teammates who I cannot pass the ball to right now
func _on_passArea_body_exited(body):
	var index = PASS_TARGET.find(body)
	if index >= 0:
		PASS_TARGET.remove(index)


# Add other nearby team members to defense target list
func _on_defenseArea_body_entered(body):
	if body != self and body.get("TEAM") and body.TEAM != TEAM and not DEFENSE_TARGET.has(body):
		DEFENSE_TARGET.append(body)


# Remove other nearby team members from defense target list
func _on_defenseArea_body_exited(body):
	var index = DEFENSE_TARGET.find(body)
	if index >= 0:
		DEFENSE_TARGET.remove(index)


func _on_shootArea_body_entered(body):
	if body != self and body.get("TEAM") and body.TEAM != TEAM and not GUN_TARGET.has(body):
		GUN_TARGET.append(body)


func _on_shootArea_body_exited(body):
	var index = GUN_TARGET.find(body)
	if index >= 0:
		GUN_TARGET.remove(index)
