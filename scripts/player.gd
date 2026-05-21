extends CharacterBody2D

const speed = 100;
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var last_dir: Vector2 = Vector2.RIGHT
var can_move = true;

#-------------------------------------PARTY MEMBERS
@export var party_members: Array[Resource]
var party_status: Array = []


#-------------------------------------PLAYER STATS


func _ready():
	#loop through our starter cards and build our party
	for member in party_members:
		#create a dictionary to track realtime stats
		var status = {
			"data": member,
			"max_health": member.max_health,
			"current_health": member.max_health
		}
		
		party_status.append(status)

#-------------------------------------ENEMY RNG

@export var ground: TileMapLayer
@export var encounter_rate: float = 1.0; #100% chance of encountering a monster
@export var monsters: Array[enemyData] 

var distance_traveled: float = 0.0;
const ENCOUNTER_THRESHOLD: float = 50.0 #the time set between each monster encounter

#-------------------------------------ENEMY RNG

#main function.. processes everything player does
func _physics_process(delta: float) -> void:
	process_movement();
	process_animation() #related to the player's movement.. ignore
	move_and_slide();
	
	#-------------------------------------ENEMY RNG
	
	#track distance
	if velocity.length() > 0: #so if the player is moving to add to the distance traveled
		distance_traveled += velocity.length() * delta
		
		if distance_traveled > ENCOUNTER_THRESHOLD:
			distance_traveled = 0.0
			check_for_encounter()

func check_for_encounter():
	#get the tile we are standing on
	var map_pos = ground.local_to_map(global_position)
	var tile_data = ground.get_cell_tile_data(map_pos);
	
	#check our invisible monsters
	#add "tile_data and" to make sure tile actually exists
	if tile_data and tile_data.get_custom_data("is_encounter_zone"):
		print("oopsies!")
		
		#roll the dice
		if randf() < encounter_rate:
			print("BATTLE STARTED")
			# pick a random monster
			var random_monster = monsters.pick_random()
			print("A WILD " + random_monster.name + " HAS APPEARED!")
			SignalBus.encounter_started.emit(random_monster)
	

#-------------------------------------ANIMATION AND PLAYER MOVEMENT..

#processes movement
func process_movement() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down");
	
	if direction != Vector2.ZERO:
		velocity = direction * speed;
		last_dir = direction; #stores last direction
	else:
		velocity = Vector2.ZERO #sets velocity to 0, which means there is no input

#plays animation if player is idle
func process_animation() -> void:
	if velocity != Vector2.ZERO: #so if the player is moving
		play_animation("walking", last_dir);
	elif velocity == Vector2.ZERO || !can_move:
		play_animation("idle", last_dir);

#plays animation sprite corresponding to said movement
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		anim.play(prefix + "_side")
		if dir.x > 0:
			anim.flip_h = false
		elif dir.x < 0:
			anim.flip_h = true
	elif dir.y < 0:
		anim.play(prefix + "_up")
	elif dir.y > 0:
		anim.play(prefix + "_down")
