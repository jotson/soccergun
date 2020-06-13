extends Node2D

func _ready():
	$player1.AI = "human"
	$player1.TEAM = 1
	
	$player2.AI = "passer"
	$player2.TEAM = 1

	$player3.AI = "striker"
	$player3.TEAM = 2


func _physics_process(delta):
	pass
		
