extends Node

var enemies = []

var common_enemies = []
var rare_enemies = []

var to_fight = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_enemies():
	
	var files = []
	var dir = Directory.new()
	
	var directory_path = "res://EnemyFiles/"
	
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
	var index = 0
	for file_name in files:
		#print(file)
		var enemy_dict = {}
		var file_to_read = File.new()
		
		var path_to_file = directory_path +  file_name
		file_to_read.open(path_to_file, File.READ)
		
		var text = file_to_read.get_as_text()
		enemy_dict = JSON.parse(text).result
		enemy_dict["Index"] = index
		match enemy_dict["Type"]:
			"Common":
				common_enemies.append(index)
			"Rare":
				rare_enemies.append(index)
		
		index += 1
		file_to_read.close()
		
		enemies.append(enemy_dict)
		
	print(common_enemies)
	print(rare_enemies)
	files.clear()


func set_enemy_name(text):
	for enemy in enemies:
		if enemy["Name"] == text:
			to_fight = enemy["Index"]
			print("Found Enemy ",text)
			return
	
	print("Failed to find enemy ",text)
	pass


func get_enemy_from_index(index):
	return enemies[index]


func get_random_enemy():
	#based on rarities too at some point
	var dice_roll = rand_range(0,100)
	if dice_roll <= 80:
		return get_random_common_enemy()
	else:
		return get_random_boss()


func get_random_common_enemy():
	common_enemies.shuffle()
	return common_enemies.front()


func get_random_boss():
	rare_enemies.shuffle()
	return rare_enemies.front()


func get_current_enemy():
	return enemies[to_fight]
