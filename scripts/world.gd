extends Node2D

#we want to spawn the battle scene
@export var battle_scn: PackedScene
@onready var ui_layer: CanvasLayer = $UIlayer
@onready var player: CharacterBody2D = $player

func _ready():
	SignalBus.encounter_started.connect(start_battle)

func start_battle(enemy_data):
	#pause the game so the player can't move
	get_tree().paused = true;
	
	#create battle scene
	var battle_instance  = battle_scn.instantiate()
	
	#add it to the screen (make it a child of the UIlayer
	ui_layer.add_child(battle_instance)
	
	#we will pass a list of enemies
	#for testing, we will dupilicate one enmy three times
	var enemy_horde = [enemy_data, enemy_data, enemy_data]
	#pass the enemy AND player data to the battle scene
	battle_instance.initialize(enemy_horde, player.party_status)
	
