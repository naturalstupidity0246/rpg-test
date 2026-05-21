extends VBoxContainer

@onready var unit_name: Label = $unit_name
@onready var character: TextureRect = $character
@onready var healthbar: ProgressBar = $healthbar

var unit_resource: Resource #can hold enemy OR ally data

func set_data(resource):
	unit_resource = resource;
	unit_name.text = resource.name;
	character.texture = resource.texture;
