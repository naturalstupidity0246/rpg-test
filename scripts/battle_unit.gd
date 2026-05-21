extends Control

@onready var unit_name: Label = $VBoxContainer/unit_name
@onready var healthbar: ProgressBar = $VBoxContainer/healthbar
@onready var character: TextureRect = $VBoxContainer/character

#add a signal to signify that the button has been clicked
signal on_selected(unit_instance)

#add variables to track health locally
var current_health: int;
var max_health: int;

var data: Resource #can hold enemy OR ally data

#add a variable to hold the lnik to the player's dictionary
var linked_status: Dictionary = {}

func set_data(resource):
	data = resource;
	unit_name.text = resource.name;
	character.texture = resource.texture;

func _on_selected_pressed() -> void:
	on_selected.emit(self)

func take_damage(amount):
	current_health -= amount;
	healthbar.value = current_health;
	
	#SAVE DATA update player file immediately
	if not linked_status.is_empty():
		linked_status["current_health"] = current_health
	
	#transparent blink animation, visualization of taking damage
	var tween = create_tween();
	tween.tween_property(TextureRect, "modulate", Color(1, 1, 1, 0.5), 0.1)
	
	if current_health <= 0:
		#wait for hurt anim to finish
		await tween.finished
		queue_free()
