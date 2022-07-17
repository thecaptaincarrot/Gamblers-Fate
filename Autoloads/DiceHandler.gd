extends Node

var KNUCKLEBONE

var dice = []

var commons = []
var uncommons = []
var rares = []


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	load_dice()
	Inventory.add_dice(dice[KNUCKLEBONE])
	generate_dice_bag()
	generate_dice_bag()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_dice():
	#Knuclebone should always be index 0
	
	#Now the rest
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
	var index = 0
	for file_name in files:
		#print(file)
		var dice_dict = {}
		var file_to_read = File.new()
		
		var path_to_file = directory_path + "/" + file_name
		file_to_read.open(path_to_file, File.READ)
		
		var text = file_to_read.get_as_text()
		dice_dict = parse_json(text)
		file_to_read.close()
		
		
		
		dice_dict["Index"] = index
		
		match dice_dict["Rarity"]:
			"Common":
				commons.append(index)
			"Uncommon":
				uncommons.append(index)
			"Rare":
				rares.append(index)
			"Default":
				KNUCKLEBONE = index
			
		index += 1
		dice.append(dice_dict)
		
		
		
	files.clear()


func generate_dice():
	#Generate dice based on rarity.
	#Dice Bags will always have at least an uncommon. If only commons are generated, generate an uncommon instead
	# 60%: Common, 30%: Uncommon, 10%: Rare
	var rarity_roll = rand_range(0,100)
	if rarity_roll < 70:
		commons.shuffle()
		var new_die = dice[commons.front()]
		return commons.front()
	elif rarity_roll < 95:
		uncommons.shuffle()
		var new_die = dice[uncommons.front()]
		return uncommons.front()
	else:
		rares.shuffle()
		var new_die = dice[rares.front()]
		return rares.front()


func generate_common():
	commons.shuffle()
	var new_die = dice[commons.front()]
	return commons.front()


func generate_uncommon():
	uncommons.shuffle()
	var new_die = dice[uncommons.front()]
	return uncommons.front()


func generate_rare():
	rares.shuffle()
	var new_die = dice[rares.front()]
	return rares.front()


func generate_dice_bag(): #generates 3 dice, one will be uncommon or better
	#this will automatically add it to the inventory. Be careful
	var dice_indices = []
	var common_check = true
	for i in range(0,3):
		var new_dice_index = generate_dice()
		dice_indices.append(new_dice_index)
		if dice[new_dice_index]["Rarity"] != "Common":
			common_check = false
	
	if common_check:
		dice_indices.pop_front()
		dice_indices.append(generate_uncommon())

	for index in dice_indices:
		Inventory.add_dice(dice[index])
	
	return dice_indices


func generate_rare_bag(): #generates 3 dice, 1 rare 2 uncommon
	#This will automatically add it to the inventory. be careful!
	var dice_indices = []
	var common_check = true
	
	dice_indices.append(generate_rare())
	dice_indices.append(generate_uncommon())
	dice_indices.append(generate_uncommon())
#	for i in range(0,3):
#		var new_dice_index = generate_dice()
#		dice_indices.append(new_dice_index)
#		if dice[new_dice_index]["Rarity"] != "Common":
#			common_check = false
	
#	if common_check:
#		dice_indices.pop_front()
#		dice_indices.append(generate_uncommon())
	
	for index in dice_indices:
		Inventory.add_dice(dice[index])
	return dice_indices




