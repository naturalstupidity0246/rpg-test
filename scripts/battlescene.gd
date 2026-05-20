extends Control

#IMPORTANT check your scene tree. names must match
@onready var enemy: TextureRect = $mainlayout/battlearea/enemyside/enemy
@onready var text_label: Label = $mainlayout/PanelContainer/text

#initialize the battle scene itself
func initialize(enemy_data: enemyData):
	enemy.texture = enemy_data.texture;
	text_label.text = "A WILD " + enemy_data.name + " HAS APPEARED!"

#so if you choose to run away.. you run away..
func _on_run_pressed() -> void:
	#unpause the game
	get_tree().paused = false;
	
	#destroy this battle scene
	queue_free()
