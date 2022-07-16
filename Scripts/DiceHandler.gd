extends Node

var KNUCKLEBONE

var dice = []


# Called when the node enters the scene tree for the first time.
func _ready():
	load_dice()
	Inventory.add_dice(dice[0])
	Inventory.add_dice(dice[1])
	Inventory.add_dice(dice[2])
	Inventory.add_dice(dice[3])
	Inventory.add_dice(dice[3])
	Inventory.add_dice(dice[2])
	Inventory.add_dice(dice[1])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_dice():
	var files = []
	var dir = Directory.new()
	
	var directory_path = "res://DiceFiles/"
	
	dir.open(directory_path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".json"):
			files.append(file)
	dir.list_dir_end()
	
	#Actually Read the Files? Why is this a seperate loop though
	for file_name in files:
		#print(file)
		var dice_dict = {}
		var file_to_read = File.new()
		
		var path_to_file = directory_path + "/" + file_name
		file_to_read.open(path_to_file, File.READ)
		
		var text = file_to_read.get_as_text()
		dice_dict = parse_json(text)
		file_to_read.close()
		
		dice.append(dice_dict)
		
		
		
	files.clear()
