extends Node

var player_health = 3
var player_max_health = 4
var map_position

var photosensitivity = false

var gold = 200

var tile_completed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player_health = player_max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func reset():
	tile_completed = 0
	gold = 0
	player_max_health = 4 
	player_health = player_max_health
	map_position = -1
