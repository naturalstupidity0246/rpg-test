extends Control

#IMPORTANT check your scene tree. names must match
@onready var enemy: TextureRect = $mainlayout/battlearea/enemyside/VBoxContainer/enemy
@onready var text_label: Label = $mainlayout/PanelContainer/text
@onready var enemyhealthbar: ProgressBar = $mainlayout/battlearea/enemyside/VBoxContainer/enemyhealthbar
@onready var playerhealthbar: ProgressBar = $mainlayout/battlearea/playerside/VBoxContainer/playerhealthbar
@onready var attack: Button = $mainlayout/attack
@onready var run: Button = $mainlayout/run

#logic variables
var current_enemy_health: int = 0;
var enemy_damage: int = 0;
var player = CharacterBody2D;

#initialize the battle scene itself
func initialize(enemy_data: enemyData, player_ref: CharacterBody2D):
	player = player_ref #stores reference to player
	current_enemy_health = enemy_data.health; #gets the current enemy's health
	enemy_damage = enemy_data.damage #remember how hard this enemy hits
	
	#remember the health bars
	enemyhealthbar.max_value = enemy_data.health
	enemyhealthbar.value = current_enemy_health
	playerhealthbar.max_value = player.max_health
	playerhealthbar.value = player.current_health #use our ACTUAL health
	
	#setup texture and text
	enemy.texture = enemy_data.texture;
	text_label.text = "A WILD " + enemy_data.name + " HAS APPEARED!"

#so if you choose to run away.. you run away..
func _on_run_pressed() -> void:
	#unpause the game
	get_tree().paused = false;
	
	#destroy this battle scene
	queue_free()


func _on_attack_pressed() -> void:
	#lock buttons so we can't spam the attack
	attack.disabled = true;
	run.disabled = true;
	
	#deal fake damage
	var player_hits = RandomNumberGenerator.new();
	var enemy_got_Hit = player_hits.randi_range(10, 15);
	current_enemy_health -= enemy_got_Hit;
	enemyhealthbar.value = current_enemy_health;
	text_label.text = "you hit the enemy and dealth" + str(enemy_got_Hit) + " damage!"
	
	#THE MAGIC WORD! wait for 1 second
	await get_tree().create_timer(1.0).timeout
	
	#check results
	if current_enemy_health <= 0:
		win_battle()
	else:
		enemy_turn();

func win_battle():
	text_label.text = "You won!"
	await get_tree().create_timer(1.0).timeout
	
	get_tree().paused = false;
	queue_free()

func enemy_turn():
	text_label.text = "the monster takes it's turn!"
	await get_tree().create_timer(1.0).timeout
	
	#modify the REAL player script directly
	player.current_health -= enemy_damage;
	playerhealthbar.value = player.current_health;
	
	text_label.text = "you took " + str(enemy_damage) + " damage!"
	await get_tree().create_timer(1.0).timeout
	
	#check for game over
	if player.current_health <= 0:
		text_label.text = "you were defeated"
		await get_tree().create_timer(2.0).timeout
		
		#restart the game
		get_tree().paused = false;
		get_tree().reload_current_scene()
	else:
		#give control back to the player;
		attack.disabled = false;
		run.disabled = false;
		text_label.text = "what will you do?"
