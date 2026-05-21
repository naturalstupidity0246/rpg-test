extends Control

#the blueprint
@export var battle_unit_scn: PackedScene

#IMPORTANT check your scene tree. names must match
@onready var speaker: Label = $mainlayout/PanelContainer/speaker
@onready var attack: Button = $mainlayout/action_btns/attack
@onready var run: Button = $mainlayout/action_btns/run
@onready var enemyside: VBoxContainer = $mainlayout/battlearea/enemyside
@onready var playerside: VBoxContainer = $mainlayout/battlearea/playerside

#THE LISTS
#we will use these arrays to track who is alive in the fight
var active_party_units: Array = [];
var active_enemy_units: Array = []

#NEW INITALIZER
#initialize the battle scene itself
func initialize(enemy_data_array: Array, player_status_array: Array):
	#write the text
	if enemy_data_array.size() > 1:
		speaker.text = "A WILD GROUP OF" + enemy_data_array[0].name + "S HAS BESTOWED UPON YE!"
	
	#2 spawn enemies loop
	for enemy_data in enemy_data_array:
		#create the unit from the loop
		var unit = battle_unit_scn.instantiate()
		#add it (the units) to the screen
		enemyside.add_child(unit)
		
		#set up the data from the unit
		unit.set_data(enemy_data) #function from battle_unit.gd
		
		
		#manually update the health bar from the persistent status
		unit.healthbar.max_value = enemy_data.health
		unit.healthbar.value = enemy_data.health
		
		#add the our tracking list
		active_enemy_units.append(unit)
	#spawn party loop
	for status in player_status_array:
		#create the unit from the loop
		var unit = battle_unit_scn.instantiate()
		#add it (the units) to the screen
		playerside.add_child(unit)
		#checkpoint callback: accessing the dictionary
		unit.set_data(status["data"])
		
		#manually update the health bar from the persistent status
		unit.healthbar.max_value = status["max_health"]
		unit.healthbar.value = status["current_health"]
		
		#add the our tracking list
		active_party_units.append(unit)

#so if you choose to run away.. you run away..
func _on_run_pressed() -> void:
	#unpause the game
	get_tree().paused = false;
	
	#destroy this battle scene
	queue_free()


#func _on_attack_pressed() -> void:
	##lock buttons so we can't spam the attack
	#attack.disabled = true;
	#run.disabled = true;
	#
	##deal fake damage
	#var player_hits = RandomNumberGenerator.new();
	#var enemy_got_Hit = player_hits.randi_range(10, 15);
	#current_enemy_health -= enemy_got_Hit;
	#enemyhealthbar.value = current_enemy_health;
	#text_label.text = "you hit the enemy and dealth" + str(enemy_got_Hit) + " damage!"
	#
	##THE MAGIC WORD! wait for 1 second
	#await get_tree().create_timer(1.0).timeout
	#
	##check results
	#if current_enemy_health <= 0:
		#win_battle()
	#else:
		#enemy_turn();

func win_battle():
	speaker.text = "You won!"
	await get_tree().create_timer(1.0).timeout
	
	get_tree().paused = false;
	queue_free()

#func enemy_turn():
	#text_label.text = "the monster takes it's turn!"
	#await get_tree().create_timer(1.0).timeout
	#
	##modify the REAL player script directly
	#player.current_health -= enemy_damage;
	#playerhealthbar.value = player.current_health;
	#
	#text_label.text = "you took " + str(enemy_damage) + " damage!"
	#await get_tree().create_timer(1.0).timeout
	#
	##check for game over
	#if player.current_health <= 0:
		#text_label.text = "you were defeated"
		#await get_tree().create_timer(2.0).timeout
		#
		##restart the game
		#get_tree().paused = false;
		#get_tree().reload_current_scene()
	#else:
		##give control back to the player;
		#attack.disabled = false;
		#run.disabled = false;
		#text_label.text = "what will you do?"
