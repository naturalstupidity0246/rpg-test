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

var current_player_index: int = 0;
var is_targeting_mode: bool = false;

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
		
		#update enemy health
		unit.current_health = enemy_data.health
		unit.max_health = enemy_data.health
		
		#manually update the health bar from the persistent status
		unit.healthbar.max_value = enemy_data.health
		unit.healthbar.value = enemy_data.health
		
		#connect the click signal
		unit.on_selected.connect(on_enemy_selected)
		
		#add the our tracking list
		active_enemy_units.append(unit)
		
	#spawn party loop
	for status in player_status_array:
		#if this hero is dead, we will skip them.
		if status["current_health"] <= 0:
			continue; #continue skips this iteration and move on to the next player
		#create the unit from the loop
		var unit = battle_unit_scn.instantiate()
		#add it (the units) to the screen
		playerside.add_child(unit)
		#checkpoint callback: accessing the dictionary
		unit.set_data(status["data"])
		
		#update actual health from player status
		unit.current_health = status["current_health"]
		unit.max_health = status["max_health"]
		
		#manually update the health bar from the persistent status
		unit.healthbar.max_value = status["max_health"]
		unit.healthbar.value = status["current_health"]
		
		#data link: connect our stats to the battle
		unit.linked_status = status #linked_status comes from battle_unit.gd.
		
		#add the our tracking list
		active_party_units.append(unit)
	
	start_player_turn();

func start_player_turn():
	#checks if we cycled through everyone
	if current_player_index >= active_party_units.size():
		enemy_phase() #all heroes moved, now enemies go.
		return
	#reset UI
	attack.disabled = false;
	is_targeting_mode = false;
	run.disabled = false;
	speaker.text = "What will " + active_party_units[current_player_index].data.name + " do??"


#so if you choose to run away.. you run away..
func _on_run_pressed() -> void:
	#unpause the game
	get_tree().paused = false;
	
	#destroy this battle scene
	queue_free()


func _on_attack_pressed() -> void:
	is_targeting_mode = true;
	speaker.text = "select a target"
	attack.disabled = true;

func on_enemy_selected(enemy_unit):
	if is_targeting_mode == true:
		is_targeting_mode = false;
		 
		#who are we targetting?
		var attacker = active_party_units[current_player_index]
		
		#deal damage
		speaker.text = attacker.data.name + " attacks!";
		await get_tree().create_timer(0.5).timeout
		var player_damage = randf_range(attacker.data.damage - 5, attacker.data.damage + 5)
		
		enemy_unit.take_damage(player_damage)
		
		#check if enemy is dead
		if enemy_unit.current_health <= 0:
			active_enemy_units.erase(enemy_unit)
		
		await get_tree().create_timer(1.0).timeout
		
		#check for win condition
		if active_enemy_units.size() <= 0:
			win_battle()
		else:
			#next hero
			current_player_index += 1;
			start_player_turn()

func enemy_phase():
	speaker.text = "IT'S THE ENEMY'S TURN!"
	await get_tree().create_timer(1.0).timeout
	
	#goes through each enemy
	for enemy in active_enemy_units:
		#stop if all party players are dead
		if active_party_units.size() <= 0:
			break;
		
		#pick a random target
		var target = active_party_units.pick_random() #pick random is a function
		
		#attack!
		speaker.text = enemy.data.name + " ATTACKS " + target.data.name + "!"
		target.take_damage(enemy.data.damage)
		await get_tree().create_timer(1).timeout
		
		#check if player is dead
		if target.current_health <= 0:
			active_party_units.erase(target)
	
	#end of enemy phase
	current_player_index = 0;
	if active_party_units.size() > 0:
		start_player_turn()
	else:
		game_over()

func win_battle():
	speaker.text = "YOU WON THE BATTLE!"
	await get_tree().create_timer(1.0).timeout
	#unpause the game
	get_tree().paused = false;
	#destroy this battle scene
	queue_free()

func game_over():
	speaker.text = "you lost :/"
	await get_tree().create_timer(1.0).timeout
	#unpause the game
	get_tree().paused = false;
	#destroy this battle scene
	queue_free()
	#reload current scene
	get_tree().reload_current_scene()
