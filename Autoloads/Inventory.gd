extends Node

var dice = [] #Array of all dice collected
#Todo, probably some kind of sorting algorithm
#This is the only reference to the dice that exists


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reset_inventory():
	dice.clear()
	add_dice(DiceHandler.get_knucklebone())
	add_dice(DiceHandler.get_knucklebone())



func add_dice(dice_dict):
	#Check if die is already in inventory
	for die in dice:
		if dice_dict == die[0]:
			die[1] += 1
			return true
	
	#Dice dict not found in inventory
	dice.append([dice_dict,1])
	return false


func remove_dice(dice_index):
	dice[dice_index][1] -= 1
#	check_clear()



#func check_clear(): #Never actually remove dice you pick up though lol
#	for die in dice:
#		if die[1] <= 0:
#			dice.erase(die)


func get_dice_dict(index):
	return dice[index][0]


func get_dice_count(index):
	return dice[index][1]


func get_dice_index(dict):
	return dice.find(dict)
