extends Node

var field_dice = []  #inventory indices ex [1,1,1,1,2,3,4,4,8,5,5,5,5,5,5,6,1,2,3,3,1]

var enemy = {}

var attack_range = {}

var enemy_health = 3
var player_health = 3 #global???

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	load_enemy(EnemyHandler.enemies[0])


func load_enemy(enemy_dict):
	enemy = enemy_dict
	print(enemy)
	$PeoplePlane/EnemySprite.texture = load(enemy["Image"])
	$PeoplePlane/EnemyName.text = enemy["Name"]
	$AffinityBar.initialize(enemy["Ranges"])
	attack_range = enemy["Ranges"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_health < 3:
		$PeoplePlane/MCHearts/Heart3.frame = 0
	else:
		$PeoplePlane/MCHearts/Heart3.frame = 1
	if player_health < 2:
		$PeoplePlane/MCHearts/Heart2.frame = 0
	else:
		$PeoplePlane/MCHearts/Heart2.frame = 1
	if player_health < 1:
		$PeoplePlane/MCHearts/Heart1.frame = 0
	else:
		$PeoplePlane/MCHearts/Heart1.frame = 1
	
	if enemy_health < 3:
		$PeoplePlane/EnemyHearts/Heart3.frame = 0
	else:
		$PeoplePlane/EnemyHearts/Heart3.frame = 1
	if enemy_health < 2:
		$PeoplePlane/EnemyHearts/Heart2.frame = 0
	else:
		$PeoplePlane/EnemyHearts/Heart2.frame = 1
	if enemy_health < 1:
		$PeoplePlane/EnemyHearts/Heart1.frame = 0
		get_tree().change_scene("res://Map.tscn")
	else:
		$PeoplePlane/EnemyHearts/Heart1.frame = 1
		
	


func add_to_field(index):
	#1. check to see if an add is possible (field dice >= inventory total) DONE
	#2. add dice to field array DONE
	#3. tell dice plane to update DONE
	#4. Update Dice Selector TODO
	if field_dice.count(index) < Inventory.get_dice_count(index) and len(field_dice) < 5:
		field_dice.append(index)
		$DiceField.update_field(field_dice)
		print(field_dice)
	pass



func remove_from_field(index):
	field_dice.erase(index)
	$DiceField.update_field(field_dice)


func _on_Roll_pressed():
	if field_dice == []:
		return 
	
	var total_roll = 0
	var i = 0
	
	var to_erase = []
	print("Field Dice",  field_dice)
	for die_index in field_dice:
		var current_die = $DiceField/Dice.get_child(i)
		
		var die = Inventory.dice[die_index][0]
		var die_values = die["Values"]
		
		var roll = randi() % len(die_values)
		
		var die_roll = die_values[roll]
		
		total_roll += die_roll
		
		current_die.set_roll(roll)
		current_die.play_roll_animation()
		
		print(die["Break"])
		print(roll)
		if die["Break"].has(float(roll)):
			print("Hi")
			Inventory.remove_dice(die_index)
			to_erase.append(die_index)
			current_die.animation_queue.append("Break")
		i += 1
	
	if to_erase != []:
		for erase in to_erase:
			field_dice.erase(erase)
	
	print("total: ", total_roll)
	
	for x in attack_range:
		print(x)
		if total_roll >= x["Range"][0] and total_roll <= x["Range"][1]:
			match x["Type"]:
				"Crit":
					enemy_health -= 2
				"Damage":
					enemy_health -= 1
				"Attack":
					enemy_health -= 1
					player_health -= 1
				"Fail":
					player_health -= 1
	
	$DiceSelector.update()
